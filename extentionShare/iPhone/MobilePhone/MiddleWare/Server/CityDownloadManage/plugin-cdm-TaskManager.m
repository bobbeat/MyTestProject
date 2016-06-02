//
//  TaskManager.m
//  plugin-CityDataManager
//
//  Created by mark on 11-11-3.
//  Copyright (c) 2011年 Autonavi. All rights reserved.
//

#import "plugin-cdm-TaskManager.h"
#import "plugin-cdm-Task.h"
#import "ANParamValue.h"
#import "plugin-cdm-IntegratedDownLoadTask.h"
#import "plugin-cdm-RoadDownloadTask.h"
#import "NSString+Category.h"
#import "GDBL_Interface.h"
#import "SectionInfo.h"
#import "Play.h"
#import "Quotation.h"
#import "plugin-cdm-DownloadTask.h"
#import "MWCityDownloadMapDataList.h"
#import "GDBL_DataVerify.h"


//static TaskManager* instance;

@implementation TaskManager
@synthesize delegate,taskList,TravelTaskList;


+(TaskManager*)taskManager
{
    static TaskManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[TaskManager alloc] init];
    });
    return instance;
}



-(void)dealloc
{
    [taskList release];
    [TravelTaskList release];
    //[mTaskStatusList release];
    [super dealloc];
}

-(id)init
{
    self = [super init];
    if(self!=nil)
    {
        //mTaskStatusList = [[NSMutableArray alloc]init];
        taskList = [[NSMutableArray alloc]init];
        TravelTaskList = [[NSMutableArray alloc]init];
    }
    return self;
}

-(void)syncRemoveTasklistItem:(int)index
{
    @synchronized(taskList)
	{
        [taskList removeObjectAtIndex:index];
    }
}

// 返回-1表示加入失败，>=0表示成功加入后在TaskManager中的索引
-(int)addTask:(Task*) task atFirst:(BOOL) first
{
    if(NO==[self _taskExisted:task])
    {
        task.delegate = self;
        task.status = TASK_STATUS_READY;
        
        if(first)
        {
            @synchronized(taskList)
            {
            [taskList insertObject:task atIndex:0];
            }
            
            return 0;
        }
        else
        {   @synchronized(taskList)
            {
            [taskList addObject:task];
            }
           
            return [taskList count]-1;
        }
    }
    else
    {
        DownloadTask *downtask = (DownloadTask*) task;
        if(downtask==nil || downtask.url == nil)
        {
            return -1;
        }
        for (int i =0;i<[taskList count];i++)
        {
            DownloadTask *t = [taskList caObjectsAtIndex:i];
            if(t.taskId == task.taskId  && t.status == TASK_STATUS_FINISH)//只有下载完成的才允许更新
            {
                t.title = downtask.title;
                t.updatetype = downtask.updatetype;
                t.version = downtask.version;
                t.updated = downtask.updated;
                t.all_size =downtask.all_size;
                t.all_unzipsize = downtask.all_unzipsize;
                t.all_suburl = downtask.all_suburl;
                t.all_md5 = downtask.all_md5;
                t.add_size = downtask.add_size;
                t.add_unzipsize = downtask.add_unzipsize;
                t.add_suburl =downtask.add_suburl;
                t.add_md5 =downtask.add_md5;
                t.zhname = downtask.zhname;
                t.enname = downtask.enname;
                t.twname = downtask.twname;
                t.url = downtask.url;
                t.current = 0;
                t.total = downtask.total;
                t.selected = NO;
                t.status = TASK_STATUS_READY;
                t.updated = NO;
                t.delegate = self;
                return i;
            }
        }
    }
    return -1;
}

//将本地存在的地图数据添加到下载队列中，并把状态置为完成
-(int)addLocalTask:(Task*) task atFirst:(BOOL) first
{
    if(![self _taskExisted:task])
    {
        task.delegate = self;
        task.status = TASK_STATUS_FINISH;
        
        if(first)
        {
            @synchronized(taskList)
            {
            [taskList insertObject:task atIndex:0];
            }
            return 0;
        }
        else
        {
            @synchronized(taskList)
            {
            [taskList addObject:task];
            }
            return [taskList count]-1;
        }
    }
    else if([self _taskExisted:task])
    {
        for (DownloadTask *t in taskList)
        {
            if (t.taskId == task.taskId)
            {
                //add by hlf for 对比本地数据版本号和下载列表保存的数据版本号，如果本地数据版本号大于等于下载列表保存版本号则把本地的版本号同步到下载列表，同时把状态设置为已完成 at 2014.07.29
                BOOL bUpdateTask = NO;
                
                NSString *localVersion = [NSString stringWithFormat:@"%@",((DownloadTask *)task).version];
                NSString *listVersion = [NSString stringWithFormat:@"%@",t.version];
                if(task.taskId != 0)
                {
                    if (localVersion && listVersion) {
                        
                        NSString *localBigVersion = [localVersion CutToNSString:@"."];
                        NSString *localSmallVersion = [localVersion CutNSStringFromBackWard:@"."];
                        NSString *listBigVersion = [listVersion CutToNSString:@"."];
                        NSString *listSmallVersion = [listVersion CutNSStringFromBackWard:@"."];
                        
                        int localVersionValue = [[NSString stringWithFormat:@"%@%@",localBigVersion,localSmallVersion] intValue];
                        int listVersionValue = [[NSString stringWithFormat:@"%@%@",listBigVersion,listSmallVersion] intValue];
                        
                        if (localVersionValue >= listVersionValue) {
                            bUpdateTask = YES;
                        }
                        
                    }
                }
                else//基础资源
                {
                    if (localVersion && listVersion) {
                        int localVersionValue = [localVersion intValue];
                        int listVersionValue = [listVersion intValue];
                        
                        if (localVersionValue >= listVersionValue) {
                            bUpdateTask = YES;
                        }
                    }

                }
                

                if (bUpdateTask || t.status == TASK_STATUS_FINISH) {
                    
                    if (t.status != TASK_STATUS_FINISH)//若用户拖入完整的城市数据，则删除对应未下载完成的文件
                    {
                        
                        NSString *stringt = @"/";
                        NSRange range = [t.url rangeOfString:stringt options:NSBackwardsSearch];
                        if (range.length != 0)
                        {
                            NSString *name = [t.url substringFromIndex:range.location+1];
                            
                            NSFileManager *fileManager = [NSFileManager defaultManager];
                            
                            NSString *filePath = [NSString stringWithFormat:@"%@/%@.tmp",DataDownload_PATH,name];
                            
                            if([fileManager fileExistsAtPath:filePath])
                            {
                                [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
                                
                            }
                        }
                    }
                    t.status = TASK_STATUS_FINISH;
                    t.version = ((DownloadTask*)task).version;
                }
                
                
                
            }
	    }
        return 0;
    }
	else
    {
		return -1;
	}
    
}

//根据语言选择对应的城市名称 add by xyy
-(NSString*)getTaskTitle:(DownloadTask*) task
{
    if (!task) {
        return @"";
    }
    
    if (fontType == 0)
    {
        return task.zhname;
    }
    else if (fontType == 1)
    {
        return task.twname;
    }
    else
    {
        return task.enname;
        
    }
    
}

// 移除索引为index处的任务，该操作会删除该任务。
// 如果恰好该任务处于运行状态，removeTask后，整个TaskManager中将无任务在执行
-(BOOL)removeTask:(int) index
{
    NSLog(@"removeTask:index");
    int count = [taskList count];
    if(index>=0 && index < count)
    {
        Task* t = [taskList caObjectsAtIndex:index];
        [t erase];
//        [taskList removeObjectAtIndex:index];
        [self syncRemoveTasklistItem:index];
        //[mTaskStatusList removeObjectAtIndex:index];
        return  YES;
    }
    return NO;
    
}

// 移除任务id的任务，该操作会删除该任务。
// 如果恰好该任务处于运行状态，removeTaskId后，整个TaskManager中将无任务在执行
-(BOOL)removeTaskId:(long) taskId
{
    NSLog(@"removeTaskId:taskid");
    int count = [taskList count];
	for (int i = 0; i < count; i++)
	{
        Task* t = [taskList caObjectsAtIndex:i];
		if (taskId == t.taskId) {
			if (taskId == 0) {
				[t erase];
                [self syncRemoveTasklistItem:i];
			}
			else {
				[t erase];
                [self syncRemoveTasklistItem:i];
			}
			return YES;
		}
	}
    return NO;
    
}

// 移除所有状态为status的任务，返回移除的个数
-(int)removeTasksForStatus:(int) status
{
    NSLog(@"removeTasksForStatus");
    int count = 0;
    while (1) {
        int index = [self _firstIndexWithStatus:status];
        if(index>=0)
        {
            [self removeTask:index];
            ++count;
        }
        else
        {
            break;
        }
    }
    return count;
}

// 移除所有任务
- (void)removeAllTask
{
    for (Task *_task in taskList) {
        [_task erase];
    }
    @synchronized(taskList){
    [taskList removeAllObjects];
    }
    
	[NSKeyedArchiver archiveRootObject:taskList toFile:DataDownloadlistFile_PATH];
}

//勾选所有任务
- (void)selectAllTask:(BOOL)flag
{
    if (flag) {
        for (Task *task in taskList) {
            task.selected = YES;
        }
    }
    else{
        for (Task *task in taskList) {
            task.selected = NO;
        }
    }
    
}

//移除所选项目
- (void)removeSelectedTask
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    for (Task *task in taskList) {
        if (task.selected) {
            [array addObject:task];
        }
    }
    
    for(Task *task in array)
    {
        if(task.selected)
        {
            [self update_erase:task.taskId];
        }
    }
    
    
    [array release];
    
}
//add by xyy for 删除分删除数据和删除更新，正在下载且本地数据存在只删除正在下载的数据，否则全部删除。
-(void)update_erase:(int) taskID
{
    DownloadTask *task = [self getTaskWithTaskID:taskID];
    if(task.status == TASK_STATUS_FINISH)
    {
        [self removeTaskId:taskID];
    }
    else
    {
        if(taskID == 0)//基础资源
        {
            BOOL isBaseResExist = [GDBL_DataVerify checkBaseRoadDataExist];
            if(isBaseResExist)//基础资源存在
            {
                BOOL bforce = [[MWCityDownloadMapDataList citydownloadMapDataList]GetBasicResourceStatus];
                if(bforce)
                {
                    //基础资源强制更新不可删除
                    GDAlertView *alertView = [[GDAlertView alloc] initWithTitle:nil andMessage:STR(@"CityDownloadManage_basicResourcesDeleted",Localize_CityDownloadManage)];
                    [alertView addButtonWithTitle:STR(@"Universal_ok", Localize_Universal) type:GDAlertViewButtonTypeCancel handler:nil];
                    [alertView show];
                    [alertView release];
                    
                }
                else
                {
                    //删除tmp文件
                    [task DeleteTempFiles];
                    task.status = TASK_STATUS_FINISH;
                    task.version = [ANDataSource getNaviVersion];
                    task.current = task.total;
                    [self getUpdateStatus];
                }

            }
            else//基础资源不存在
            {
                [self removeTaskId:taskID];
            }
            
        }
        else//城市
        {
            Gbool bData = NO;
            GADMINCODE adminCode = {0};
            adminCode.euRegionCode = eREGION_CODE_CHN;
            adminCode.nAdCode = taskID;
            
            GSTATUS res = GD_ERR_FAILED;
            
            if ([ANParamValue sharedInstance].isInit) {
                res = [MWAdminCode GetAdareaDataStatus:&adminCode bHasData:&bData];
            }
            else{
                res = [MWEngineInit InitData];
                if (res == GD_ERR_OK) {
                    res = [MWAdminCode GetAdareaDataStatus:&adminCode bHasData:&bData];
                    [MWEngineInit UninitData];
                }
            }
            if(res == GD_ERR_OK && bData)//数据存在
            {       //删除tmp文件，恢复task的状态
                [task DeleteTempFiles];
                 NSString *version = [MWEngineTools GetMapCityVersionNoV:taskID];
                task.version = version;
                task.status = TASK_STATUS_FINISH;
                task.current = task.total;
                [self getUpdateStatus];
            }
            else//数据不存在或者返回错误
            {
                [self removeTaskId:taskID];
            }
            
        }
            
    }
}

// TaskManager可能处于两种状态：
// 1、无任何任务在执行：TaskManager按某种策略选择一个任务来执行
// 2、有任务在执行：直接返回
-(BOOL)start
{
    if([self isRunning])
    {
        return NO;
    }
    else
    {
        int index = [self _selectOneTaskToRun];
        if(index<0)
        {
            return NO;
        }
        else
        {
            return [self start:index];
        }
    }
}

// 停止TaskManager中正在执行的任务，整个TaskManager处于停止状态
-(BOOL)stop
{
    int index = [self _firstIndexWithStatus:TASK_STATUS_RUNNING];
    if (index>=0) {
        return [self stop:index];
    }
    return NO;
}

- (BOOL)stopRunning
{
    int index = [self _firstIndexWithStatus:TASK_STATUS_RUNNING];
    if (index>=0) {
        return [self stopCurrent:index];
    }
    return NO;
}
// TaskManager可能处于两种状态：
// 1、无任何任务在执行：TaskManager按index来选择任务
// 2、有任务在执行：
//      分两种情况：
//      1、正在执行的任务就是index，那么直接返回；
//      2、正在执行的任务不是index，那么让正在执行的任务变为等待，转而执行index指定的任务
-(BOOL)start:(int)index
{
    int indexRunning = [self _firstIndexWithStatus:TASK_STATUS_RUNNING];
    if (indexRunning == index || index > (int)(taskList.count -1)) {
        return NO;
    }
    else
    {
        // 先停止正在执行的任务
        if (indexRunning >= 0)
        {
            Task* t = [taskList caObjectsAtIndex:indexRunning];
            t.status = TASK_STATUS_READY;
            [t stop];

        }
        
        Task* t = [taskList caObjectsAtIndex:index];
        t.status = TASK_STATUS_RUNNING;
        [t run];
        
        return YES;
    }
}

- (BOOL)firstStart:(int)index
{
    if (index > (int)(taskList.count -1)) {
        return NO;
    }
    Task* t = [taskList caObjectsAtIndex:index];
    t.status = TASK_STATUS_RUNNING;
    [t run];
    return YES;
}
- (void)startWithTaskID:(int)taskID
{
    
    for (int i = 0; i < taskList.count; i++) {
        Task *tmp = [taskList caObjectsAtIndex:i];
        if (tmp.taskId == taskID) {
            [self start:i];
            return;
        }
    }
}

- (void)stopWithTaskID:(int)taskID
{
    
    for (int i = 0; i < taskList.count; i++) {
        Task *tmp = [taskList caObjectsAtIndex:i];
        if (tmp.taskId == taskID) {
            [self stop:i];
            return;
        }
    }
}
// 停止TaskManager中index对应的任务：注意：只有状态为TASK_STATUS_RUNNING的任务才能被stop
// 1、index对应的任务处于等待状态，那么直接返回
// 2、index对应的任务处于执行状态，那么让正在执行的任务变为等待
-(BOOL)stop:(int)index
{
    int count = [taskList count];
    if(index>=0 && index<count)
    {
        
        Task* t = [taskList caObjectsAtIndex:index];
        if(t.status==TASK_STATUS_RUNNING || t.status==TASK_STATUS_READY)
        {
            
            t.status = TASK_STATUS_BLOCK;
            [t stop];
            
            [self start];
            return YES;
        }
    }
    return NO;
}

//只暂停指定索引的任务，不自动下载等待的任务
- (BOOL)stopCurrent:(int)index
{
    int count = [taskList count];
    if(index>=0 && index<count)
    {
        
        Task* t = [taskList caObjectsAtIndex:index];
        if(t.status==TASK_STATUS_RUNNING)
        {
            
            t.status = TASK_STATUS_BLOCK;
            [t stop];
            
            return YES;
        }
    }
    return NO;
}
//暂停所有的任务
- (void)stopAllTask
{
    int indexRunning = [self _firstIndexWithStatus:TASK_STATUS_RUNNING];
    if (indexRunning >= 0) {
        Task* t = [taskList caObjectsAtIndex:indexRunning];
        [t stop];
    }
    for (Task *task in taskList) {
        if (task.status == TASK_STATUS_RUNNING || task.status == TASK_STATUS_READY) {
            task.status = TASK_STATUS_BLOCK;
        }
    }
}

//开始所有的任务
- (void)startAllTask
{
    
    for (Task *task in taskList) {
        if (task.status == TASK_STATUS_BLOCK) {
            task.status = TASK_STATUS_READY;
        }
    }
    
    [self start];
}

// 返回YES表示TaskManager中有任务正在运行
-(BOOL)isRunning
{
    return [self _firstIndexWithStatus:TASK_STATUS_RUNNING]<0?NO:YES;
}

//是否全部都在下载，等待下载，或者都已完成
- (BOOL)isAllRunning
{
    int irunningnum = 0;
    int ireadynum = 0;
    for (Task *task in taskList) {
        
        if (task.status == TASK_STATUS_BLOCK) {
            return NO;
        }
        if(task.status == TASK_STATUS_RUNNING)
        {
            irunningnum += 1;
        }
        else if(task.status == TASK_STATUS_READY)
        {
            ireadynum +=1;
        }
    }
    
    if(irunningnum ==0 && ireadynum>0)//只有ready 没有run
    {
        return NO;
    }
    
    return YES;
}

//是否全部暂停
- (BOOL)isAllStop
{
    for (Task *task in taskList) {
        
        if (task.status == TASK_STATUS_READY || task.status == TASK_STATUS_RUNNING) {
            return NO;
        }
    }
    
    return YES;
}

//是否有任务选中
- (BOOL)isSelectedTask
{
    for (Task *task in taskList) {
        
        if (task.selected) {
            return YES;
        }
    }
    
    return NO;
}

//是否全部选中
- (BOOL)isAllSelected
{
    for (Task *task in taskList) {
        
        if (!task.selected) {
            return NO;
        }
    }
    
    return YES;
}

// 把TaskManager中的所有任务信息保存到文件系统，一般是在退出程序时调用
-(BOOL)store
{
    /*
     1、序列化整个mTaskList
     */
    
    @synchronized(taskList){
        
        if ([taskList count] <= 0) {
            return NO;
        }
        
        if (![NSKeyedArchiver archiveRootObject:taskList toFile:DataDownloadlistFile_PATH]){
            return NO;
        }
        else {
            return YES;
        }
        
    }
    
}

//删除一体化时保存tasklist到任务列表文件中
-(BOOL)removeCountryTaskList
{
    
	if (![NSKeyedArchiver archiveRootObject:taskList toFile:DataDownloadlistFile_PATH]){
		return NO;
	}
	else {
		return YES;
	}
    
}
// 从文件系统还原通过save保存的所有任务信息，一般是在进入程序时调用，该方法调用将把TaskManager中的所有任务更新为最后一次调用save保存的任务
-(BOOL)restore
{
    /*
     1、反序列化各个Task对象，构建处mTaskList
     2、遍历mTaskList，把task.delegate = self;
     */
	
	NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithFile:DataDownloadlistFile_PATH];
    @synchronized(taskList){
	[taskList removeAllObjects];
	[taskList addObjectsFromArray:array];
    }
    [self moveTmpFile];
	[self addLocalDataToList];
	return YES;
	
}

//将本地数据添加到任务列表中，在引擎未初始化之前调用
-(void)addLocalDataToList
{
    
    __block TaskManager *weakSelf = self;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
	int count = [taskList count];
    
    BOOL isBaseResExist = [GDBL_DataVerify checkBaseRoadDataExist];
    
    for (int i = 0;i < count ; i++) {
        
        DownloadTask* task = [taskList caObjectsAtIndex:i];
        
        //数据还未下载完成，用户通过电脑把数据删除－把任务从任务列表中清除
        if (task.status != TASK_STATUS_FINISH && task.current != 0) {
            
            NSString *stringt = @"/";
            NSRange range = [task.url rangeOfString:stringt options:NSBackwardsSearch];
            
            if (range.length != 0) {
                
                NSString *name = [task.url substringFromIndex:range.location+1];
                
                NSString *filePath = [NSString stringWithFormat:@"%@/%@.tmp",DataDownload_PATH,name];
                
                Gbool bData = NO;
                GADMINCODE adminCode = {0};
                adminCode.euRegionCode = eREGION_CODE_CHN;
                adminCode.nAdCode = task.taskId;
                
                GSTATUS res = GD_ERR_FAILED;
                
                if ([ANParamValue sharedInstance].isInit) {
                    res = [MWAdminCode GetAdareaDataStatus:&adminCode bHasData:&bData];
                }
                else{
                    res = [MWEngineInit InitData];//add by hlf for 提高 GetAdareaDataStatus 接口调用效率，需在引擎为初始化之前调用 at 2014.07.29
                    
                    if (res == GD_ERR_OK) {
                        
                        res = [MWAdminCode GetAdareaDataStatus:&adminCode bHasData:&bData];
                        [MWEngineInit UninitData];
                    }
                }
                
                
                
                if(res == GD_ERR_OK && ![[NSFileManager defaultManager] fileExistsAtPath:filePath] && !bData) {//tmp文件不存在，且数据不存在
                    
                    [task erase];
//                    [taskList removeObjectAtIndex:i];
                    [self syncRemoveTasklistItem:i];
                    i--;
                }
            }
            
        }
        
        //数据下载完成，且不为基础资源，如果检测到数据不存在，则删除任务
        if (task.status == TASK_STATUS_FINISH && task.taskId != 0) {
            
            Gbool bData = NO;
            GADMINCODE adminCode = {0};
            adminCode.euRegionCode = eREGION_CODE_CHN;
            adminCode.nAdCode = task.taskId;
            
            GSTATUS res = GD_ERR_FAILED;
            
            if ([ANParamValue sharedInstance].isInit) {
                res = [MWAdminCode GetAdareaDataStatus:&adminCode bHasData:&bData];
            }
            else{
                res = [MWEngineInit InitData];//add by hlf for 提高 GetAdareaDataStatus 接口调用效率，需在引擎为初始化之前调用 at 2014.07.29
                
                if (res == GD_ERR_OK) {
                    
                    res = [MWAdminCode GetAdareaDataStatus:&adminCode bHasData:&bData];
                    [MWEngineInit UninitData];
                }
            }
            
            if (res == GD_ERR_OK && !bData) {
                
//                [task erase];
//                [taskList removeObjectAtIndex:i];
                [self syncRemoveTasklistItem:i];
                i--;
                
            }
        }
        
        
        //如果基础资源下载完成，检测到数据不存在，则把任务删除。
        
        if (task.taskId == 0 && task.status == TASK_STATUS_FINISH && !isBaseResExist)
        {
            [task erase];
//            [taskList removeObjectAtIndex:i];
            [self syncRemoveTasklistItem:i];
            i--;
           
        }
        
        count = [taskList count];
        
        
    }
    
    if (isBaseResExist)
    {
        //将基础资源添加到任务列表中
        plugin_cdm_RoadDownloadTask *baseTask = [[plugin_cdm_RoadDownloadTask alloc] init];
        
        baseTask.title = STR(@"CityDownloadManage_baseResources", Localize_CityDownloadManage);
        baseTask.taskId = 0;
        baseTask.url = nil;
        
        NSString *version = [ANDataSource getNaviVersion];
        baseTask.version = version;
        [weakSelf addLocalTask:baseTask atFirst:YES];
        [baseTask release];
    }
    
    //添加本地分城市数据到任务列表中
    GADAREALIST *ppAdareaList = {0};
    GADMINCODE adminCode = {0};
    adminCode.euRegionCode = eREGION_CODE_CHN;
    adminCode.nAdCode = 0;
    
    
    
    GSTATUS temAreaNum = GD_ERR_FAILED;
    
    if ([ANParamValue sharedInstance].isInit) {
        temAreaNum = [MWAdminCode GetAdareaWithDataList:&adminCode list:&ppAdareaList];
    }
    else{
        temAreaNum = [MWEngineInit InitData];//add by hlf for 提高 GetAdareaDataStatus 接口调用效率，需在引擎为初始化之前调用 at 2014.07.29
        
        if (temAreaNum == GD_ERR_OK) {
            
            temAreaNum = [MWAdminCode GetAdareaWithDataList:&adminCode list:&ppAdareaList];
            [MWEngineInit UninitData];
        }
    }
        
        int dataCount = 0;
        if (temAreaNum == GD_ERR_OK)
        {
            dataCount = ppAdareaList->lNumberOfAdarea;
            
            //pc端删除documents目录的全部文件，又通过pc端重新拖入数据
            for(int i = 0;i < [taskList count]; i++)
            {
                DownloadTask* task = [taskList caObjectsAtIndex:i];
                if (task.taskId != 0 && task.status == TASK_STATUS_FINISH)
                {
                    if (dataCount == 0)
                    {
//                        [task erase];
                        //                        [taskList removeObjectAtIndex:i];
                        [self syncRemoveTasklistItem:i];
                        i--;
                    }
                    else {
                        
                        
                        BOOL bData = NO;
                        for (int j=0; j<dataCount; j++)
                        {
                            int proAdminCode = ppAdareaList->pAdarea[j].lAdminCode/10000;//截取前两位判断是否直辖市
                            
                            switch (proAdminCode) {
                                case 11:
                                case 12:
                                case 31:
                                case 50:
                                case 81:
                                case 82:
                                {
                                    if (task.taskId ==ppAdareaList->pAdarea[j].lAdminCode ) {
                                        bData = YES;
                                    }
                                }
                                    break;
                                default:
                                {
                                    for (int k = 0; k < ppAdareaList->pAdarea[j].lNumberOfSubAdarea; k++) {
                                        if (task.taskId ==ppAdareaList->pAdarea[j].pSubAdarea[k].lAdminCode ) {
                                            bData = YES;
                                        }
                                    }
                                }
                                    break;
                            }
                            
                            
                        }
                        if (!bData) {
//                            [task erase];
                            //                            [taskList removeObjectAtIndex:i];
                            [self syncRemoveTasklistItem:i];
                            i--;
                        }
                    }
                    
                }
            }
            
            
            for (int i=0; i<dataCount; i++) {
                
                int proAdminCode = ppAdareaList->pAdarea[i].lAdminCode/10000;//截取前两位判断是否直辖市
                NSLog(@"ladmincode:%d",ppAdareaList->pAdarea[i].lAdminCode);
                switch (proAdminCode) {
                    case 11:
                    case 12:
                    case 31:
                    case 50:
                    case 81:
                    case 82:
                    {
                        DownloadTask *task = [[DownloadTask alloc] init];
                        task.taskId =ppAdareaList->pAdarea[i].lAdminCode;
                        NSString *name =  GcharToNSString(ppAdareaList->pAdarea[i].szAdminName) ;
                        task.title = name;
                        task.total = 0;
                        task.url = nil;
                        
                        NSString *version = [MWEngineTools GetMapCityVersionNoV:ppAdareaList->pAdarea[i].lAdminCode];//获取版本信息
                        task.version = version;
                        [weakSelf addLocalTask:task atFirst:NO];
                        [task release];
                    }
                        break;
                    default:
                    {
                        NSLog(@"subadarea:%d",ppAdareaList->pAdarea[i].lNumberOfSubAdarea);
                        for (int j = 0; j < ppAdareaList->pAdarea[i].lNumberOfSubAdarea; j++)
                        {
                            DownloadTask *task = [[DownloadTask alloc] init];
                            task.taskId = ppAdareaList->pAdarea[i].pSubAdarea[j].lAdminCode;
                            NSString *name = GcharToNSString(ppAdareaList->pAdarea[i].pSubAdarea[j].szAdminName) ;
                            NSString *version = [MWEngineTools GetMapCityVersionNoV:ppAdareaList->pAdarea[i].pSubAdarea[j].lAdminCode];
                            task.version = version;
                            task.title = name;
                            task.total = 0;
                            task.url = nil;
                            
                            [weakSelf addLocalTask:task atFirst:NO];
                            [task release];
                        }
                    }
                        break;
                }
            }
        }
        
//        [weakSelf moveTmpFile];
       
    });
    
    
}

//通过taskid获取任务
- (Task *)getTaskWithTaskID:(int)taskID
{
    for (Task *temp in taskList) {
        if (temp.taskId == taskID) {
            
            return temp;
        }
        
    }
    return nil;
}

//通过taskid获取行号
- (int )getTaskIndex :(int)taskID finished:(BOOL)isfinished
{
    int index = 0;
    for (Task *temp in taskList) {
        if (temp.taskId == taskID) {
            
            return index;
        }
        if((temp.status == TASK_STATUS_FINISH) == isfinished)
        {
            index++;
        }
        
    }
    return -1;
}

//获取相应类型的对应索引的任务,taskStatus传入yes则获取完成的任务，否则获取非完成的。
- (Task *)getTaskWithIndex:(int)index taskStatus:(BOOL)taskStatus
{
    
    int taskIndex = 0;
    if (taskStatus) {
        for (Task *temp in taskList) {
            if (temp.status == TASK_STATUS_FINISH) {
                if (index == taskIndex) {
                    return temp;
                }
                taskIndex ++;
            }
            
        }
        
    }
    else{
        for (Task *temp in taskList) {
            if (temp.status != TASK_STATUS_FINISH) {
                if (index == taskIndex) {
                    return temp;
                }
                taskIndex ++;
            }
            
        }
    }
    return nil;
}

//获取完成的任务个数
- (int)getFinishTaskNumber
{
    int finishNumber = 0;
    for (Task *task in taskList) {
        if (task.status == TASK_STATUS_FINISH) {
            finishNumber ++;
        }
    }
    return finishNumber;
}

//modify by xyy
//获取任务列表中等待和正在下载的所有任务需要的空间大小：所有解压后大小之和加上最大压缩包
-(long long)getNeedSize:(NSArray *)downloadArray
{
    long long total;//总大小
	long long maxzipsize;//最大压缩包的大小
    total = 0;
    maxzipsize = 0;
    int count = [taskList count];
    //    NSArray *tasklist = [TaskManager taskManager].taskList;
    //	int count = [tasklist count];
    for (int i=0;i<count;i++)
    {
        DownloadTask *t = [taskList caObjectsAtIndex:i];
        if(t.status == TASK_STATUS_READY || t.status == TASK_STATUS_RUNNING )
        {
            if(t.total == t.all_size)
            {
                total += t.all_unzipsize-t.current;
                if(maxzipsize < t.all_size)
                {
                    maxzipsize = t.all_size;
                }
            }
            else
            {
                total += t.add_unzipsize-t.current;
                if(maxzipsize < t.add_size)
                {
                    maxzipsize = t.add_size;
                }
                
            }
        }
        
    }
    for(Quotation *quotation in downloadArray)
    {
        if(quotation.updatetype == 0)//全量更新
        {
            total +=quotation.all_unzipsize;
            if(maxzipsize < quotation.all_size)
            {
                maxzipsize = quotation.all_size;
            }
        }
        else
        {
            total +=quotation.add_unzipsize;
            if(maxzipsize < quotation.add_size)
            {
                maxzipsize = quotation.add_size;
            }
        }
    }
    total += maxzipsize;
    return total;
    
}


//获取任务列表中所有任务需要的流量大小
-(long long)getAllTaskNeedSize
{
	long long total;//总大小
    total = 0;
    
	int count = [taskList count];
    for (int i=0;i<count;i++) {
        DownloadTask* t = [taskList caObjectsAtIndex:i];
        if(t.status == TASK_STATUS_READY || t.status == TASK_STATUS_RUNNING)
        {
            total += t.total - t.current;
        }
        
    }
    return total;
}


//有更新返回YES，全部最新返回NO
-(BOOL)checkUpdate
{
    @synchronized(taskList)
	{
        for(DownloadTask *task in taskList)
        {
            if(task.status == TASK_STATUS_FINISH)
            {
                if(task.updated)
                {
                    return YES;
                }
                
            }
        }
        return NO;
    }
}

//add by xyy
//检查已下载城市是否
//有更新返回YES，全部最新返回NO
-(BOOL)getUpdateStatus
{
    @synchronized(taskList)
	{
    BOOL ret = NO;
    for(DownloadTask *task in taskList)
    {
        if(task.status == TASK_STATUS_FINISH)
        {
            BOOL isupdate = [[MWCityDownloadMapDataList citydownloadMapDataList] comperMapVersion:task.taskId version:task.version];
            task.updated = isupdate;
            if(isupdate)
            {
                ret = YES;
            }
            
        }
    }
    return ret;
    }
}

//add by xyy
//已下载完成任务同最新数据列表同步各个字段信息。
-(void)checkTaskInfo
{
    @synchronized(taskList)
	{
    for(DownloadTask *task in taskList)
    {
        if(task.status == TASK_STATUS_FINISH)//不要更改updated字段
        {
            DownloadTask *newtask = [self getTaskInfoFromMapList:task.taskId];
            if(!newtask)
            {
                NSLog(@"not found task taskid%d",task.taskId);
                continue;
            }
            task.zhname = newtask.zhname;
            task.twname = newtask.twname;
            task.enname = newtask.enname;
            if(!task.updated)//无更新添加version字段，有更新version用原来的
            {
                task.version = newtask.version;
            }
            task.updatetype = newtask.updatetype;
            task.all_suburl = newtask.all_suburl;
            task.all_size = newtask.all_size;
            task.all_unzipsize = newtask.all_unzipsize;
            task.all_md5 = newtask.all_md5;
            task.add_suburl = newtask.add_suburl;
            task.add_size = newtask.add_size;
            task.add_unzipsize = newtask.add_unzipsize;
            task.add_md5 = newtask.add_md5;
            task.total = newtask.total;
            task.url = newtask.url;
            task.current = newtask.total;
            
        }
        if(fontType==0)
        {
            task.title = task.zhname;
        }
        else if(fontType == 1)
        {
            task.title = task.twname;
        }
        else
        {
            task.title = task.enname;
        }
        
    }
    }

}

//add by xyy
//全部更新
-(void)updateAll
{
    NSArray *noCrossArray = [[MWCityDownloadMapDataList citydownloadMapDataList] getNoCrossVersions];
    NSMutableArray *tmpTasklist = [[NSMutableArray alloc]init];
    BOOL  bHasBaseData = NO;
    for(DownloadTask *task in taskList)
    {
        if(task.taskId == 0)
        {
            bHasBaseData = YES;
        }
        if(task.updated && task.status == TASK_STATUS_FINISH)
        {
            BOOL notCross = NO;
            for(NSString * version in noCrossArray)
            {
                if(task.version && [task.version compare:version] == 0)
                {
                    notCross = YES;
                    break;
                }
            }
            if(notCross)
            {
                [task erase];//不支持交叉的数据先删除再更新，其他一般更新的直接更新，下载完成解压之前再删数据（见downloadtask）
            }
            [tmpTasklist addObject:task];
//            [self updatecity:task.taskId];
        }
    }
    if(bHasBaseData == NO)
    {
        [self updatecity:0];
    }
    
    for(DownloadTask *task in tmpTasklist)
    {
        [self updatecity:task.taskId];
    }
    [tmpTasklist release];
}

//add by xyy
//已经知道adcode对应的城市有更新，进行相应的更新
-(void)updatecity:(int)adcode
{
    DownloadTask *task = [self getTaskInfoFromMapList:adcode];
    if(task && task.title)
    {
        if(task.taskId == 0)
        {
            [self addTask:task atFirst:YES];
        }
        else
        {
            [self addTask:task atFirst:NO];
        }
    }
    
}

//add by xyy
//从数据下载列表获取指定adcode城市的信息，实例化为downtask
-(id) getTaskInfoFromMapList:(int)adcode
{
    NSArray *sectionArray = [[MWCityDownloadMapDataList citydownloadMapDataList] getMapDataList];
    BOOL  findtask = NO;
    DownloadTask *task;
    if(adcode==0)//基础资源用RoadDownloadTask实例化
    {
        task = [[[plugin_cdm_RoadDownloadTask alloc]init ]autorelease];
    }
    else
    {
        task = [[[DownloadTask alloc]init ]autorelease];

    }
    
    for(SectionInfo *sectioninfo in sectionArray)
    {
        if(sectioninfo.play.admincode == adcode)
        {
            findtask = YES;
            task.zhname = sectioninfo.play.zhname;
            task.twname = sectioninfo.play.twname;
            task.enname = sectioninfo.play.enname;
            task.version = sectioninfo.play.version;
            task.updatetype = sectioninfo.play.updatetype;
            task.all_suburl = sectioninfo.play.all_suburl;
            task.all_size = sectioninfo.play.all_size;
            task.all_unzipsize = sectioninfo.play.all_unzipsize;
            task.all_md5 = sectioninfo.play.all_md5;
            task.add_suburl = sectioninfo.play.add_suburl;
            task.add_size = sectioninfo.play.add_size;
            task.add_unzipsize = sectioninfo.play.add_unzipsize;
            task.add_md5 = sectioninfo.play.add_md5;
            task.taskId = sectioninfo.play.admincode;
            if(task.updatetype==1)//增量
            {
                if(task.taskId!=0){
                    Gbool bData = NO;
                    GADMINCODE adminCode = {0};
                    adminCode.euRegionCode = eREGION_CODE_CHN;
                    adminCode.nAdCode = task.taskId;
                    GSTATUS res = GD_ERR_FAILED;
                    
                    if ([ANParamValue sharedInstance].isInit) {
                        res = [MWAdminCode GetAdareaDataStatus:&adminCode bHasData:&bData];
                    }
                    else{
                        res = [MWEngineInit InitData];
                        if (res == GD_ERR_OK) {
                            res = [MWAdminCode GetAdareaDataStatus:&adminCode bHasData:&bData];
                            [MWEngineInit UninitData];
                        }
                    }
                    if(res == GD_ERR_OK && bData)//数据存在
                    {
                        task.total = sectioninfo.play.add_size;
                        task.url = sectioninfo.play.add_suburl;
                    }
                    else
                    {
                        task.total = sectioninfo.play.all_size;
                        task.url = sectioninfo.play.all_suburl;
                    }
                }
                else//基础资源
                {
                    BOOL isBaseResExist = [GDBL_DataVerify checkBaseRoadDataExist];
                    if(isBaseResExist)
                    {
                        task.total = sectioninfo.play.add_size;
                        task.url = sectioninfo.play.add_suburl;
                    }
                    else
                    {
                        task.total = sectioninfo.play.all_size;
                        task.url = sectioninfo.play.all_suburl;
                    }

                }

            }
            else
            {
                task.total = sectioninfo.play.all_size;
                task.url = sectioninfo.play.all_suburl;
            }
            if(fontType ==0)
            {
                task.title = task.zhname;
            }
            else if(fontType == 1)
            {
                task.title = task.twname;
            }
            else
            {
                task.title = task.enname;
            }
            task.current = 0;
            break;
        }
        else if(sectioninfo.play.quotations && [sectioninfo.play.quotations count]>0)
        {
            BOOL breaktag = NO;
            for (Quotation *quotation in sectioninfo.play.quotations)
            {
                if(quotation.admincode == adcode)
                {
                    findtask = YES;
                    task.zhname = quotation.zhname;
                    task.twname = quotation.twname;
                    task.enname = quotation.enname;
                    task.version = quotation.version;
                    task.updatetype = quotation.updatetype;
                    task.all_suburl = quotation.all_suburl;
                    task.all_size = quotation.all_size;
                    task.all_unzipsize = quotation.all_unzipsize;
                    task.all_md5 = quotation.all_md5;
                    task.add_suburl = quotation.add_suburl;
                    task.add_size = quotation.add_size;
                    task.add_unzipsize = quotation.add_unzipsize;
                    task.add_md5 = quotation.add_md5;
                    task.taskId = quotation.admincode;
                    if(task.updatetype==1)//增量
                    {
                        Gbool bData = NO;
                        GADMINCODE adminCode = {0};
                        adminCode.euRegionCode = eREGION_CODE_CHN;
                        adminCode.nAdCode = task.taskId;
                        GSTATUS res = GD_ERR_FAILED;
                        
                        if ([ANParamValue sharedInstance].isInit) {
                            res = [MWAdminCode GetAdareaDataStatus:&adminCode bHasData:&bData];
                        }
                        else{
                            res = [MWEngineInit InitData];
                            if (res == GD_ERR_OK) {
                                res = [MWAdminCode GetAdareaDataStatus:&adminCode bHasData:&bData];
                                [MWEngineInit UninitData];
                            }
                        }
                        if(res == GD_ERR_OK && bData)//数据存在
                        {

                            task.total = quotation.add_size;
                            task.url = quotation.add_suburl;
                        }
                        else
                        {
                            task.total = quotation.all_size;
                            task.url = quotation.all_suburl;
                        }
                    }
                    
                    else
                    {
                        task.total = quotation.all_size;
                        task.url = quotation.all_suburl;
                    }
                    if(fontType ==0)
                    {
                        task.title = task.zhname;
                    }
                    else if(fontType == 1)
                    {
                        task.title = task.twname;
                    }
                    else
                    {
                        task.title = task.enname;
                    }
                    task.current = 0;
                    breaktag = YES;
                    break;
                }
                
            }
            if(breaktag) {break;}
        }
    }
    
    if(findtask)  return task;
    else  return nil;
    
}

//获取不匹配数据的task
-(NSArray *)getNoMatchTask
{
    NSMutableArray *notmatchtasklist = [[[NSMutableArray alloc]init]autorelease];
    NSArray *notmatchversions = [[MWCityDownloadMapDataList citydownloadMapDataList] getNoMatchVersions];
    if(!notmatchversions ||[notmatchversions count]==0 )
    {
        return nil;
    }
    for(DownloadTask *task in taskList)
    {
        if(task.status == TASK_STATUS_FINISH && task.updated)
        {
            
            for(NSString *version in notmatchversions)
            {
                if(task.version && [task.version compare:version]==0)
                {
                    [notmatchtasklist addObject:task];
                }
            }
            
        }
    }
    if([notmatchtasklist count]>0)
    {
        return notmatchtasklist;
    }
    return nil;
}
-(void) processNoMatchTask
{
    NSArray *nomatchTasklist = [self getNoMatchTask];
    if(!nomatchTasklist || [nomatchTasklist count]==0)
    {
        return;
    }
    for(DownloadTask *task in nomatchTasklist)
    {
        [task erase];//先删除数据在更新下载
        [self updatecity:task.taskId];
    }


}

//add by xyy
//获取不交叉数据的task
-(NSArray *)getNoCrossTask
{
    NSMutableArray *notcrosstasklist = [[[NSMutableArray alloc]init]autorelease];
    NSArray *notcrossversions = [[MWCityDownloadMapDataList citydownloadMapDataList] getNoCrossVersions];
    if(!notcrossversions ||[notcrossversions count]==0 )
    {
        return nil;
    }
    for(DownloadTask *task in taskList)
    {
        if(task.status == TASK_STATUS_FINISH && task.updated)
        {
            
            for(NSString *version in notcrossversions)
            {
                if(task.version && [task.version compare:version]==0)
                {
                    [notcrosstasklist addObject:task];
                }
            }
            
        }
    }
    if([notcrosstasklist count]>0)
    {
        return notcrosstasklist;
    }
    return nil;
}

//add by xyy
//不支持交叉的处理
-(void) processNoCrossTask
{
    NSArray *nomatchTasklist = [self getNoCrossTask];

    if(!nomatchTasklist)
    {
        return;
    }
    NSString *citynames=@"";
    int count = [nomatchTasklist count];
    int i=0;
    for(DownloadTask *task in nomatchTasklist)
    {
        i++;
        citynames = [citynames stringByAppendingString:task.title];
        if(i>2)
        {
            break;
        }
        if(count>= 2 && i!=count)
        {
            citynames = [citynames stringByAppendingString:@","];
        }
    }
    if(fontType ==0 || fontType ==1)
    {
        if(count>2)
        {
            citynames = [citynames stringByAppendingFormat:@"......等%d",count];
        }
        else{
            citynames = [citynames stringByAppendingFormat:@"%d",count];
        }
    }

    else
    {
        citynames = @" ";
    }
    
    
    NSString *strTitle = [NSString stringWithFormat:STR(@"CityDownloadManage_noMatchUpdate",Localize_CityDownloadManage),citynames];
    
    GDAlertView *alertView = [[GDAlertView alloc] initWithTitle:nil andMessage:strTitle];
    [alertView addButtonWithTitle:STR(@"Universal_cancel", Localize_Universal) type:GDAlertViewButtonTypeCancel handler:nil];//不操作
    [alertView addButtonWithTitle:STR(@"CityDownloadManage_update", Localize_CityDownloadManage) type:GDAlertViewButtonTypeDefault handler:^(GDAlertView *alertView){
        for(DownloadTask *task in nomatchTasklist)
        {
            [task erase];//先删除数据在更新下载
            [self updatecity:task.taskId];
        }

    }];
    [alertView show];
    [alertView release];
}

//删除不兼容的数据版本号的任务
- (void)removeNotMatchTaskWithArray:(NSArray *)array
{
    if (!array) {
        return;
    }
    
    NSMutableArray *removeArray = [[NSMutableArray alloc] init];
    
    for (NSString *string in array) {
        
        for (DownloadTask *task in taskList) {
            
            if (task.status == TASK_STATUS_FINISH && [string isEqualToString:task.version]) {
                
                [task erase];
                [removeArray addObject:task];
                
            }
        }
    }
    
    if (removeArray.count > 0) {
        @synchronized(taskList){
        [taskList removeObjectsInArray:removeArray];
        }
    }
    [removeArray release];
}

//移动下载临时文件到DataDownload_PATH目录下
- (void)moveTmpFile
{
    @synchronized(taskList){
        
        for (DownloadTask *task in taskList) {
            
            if (task.status != TASK_STATUS_FINISH) {
                
                NSString *fileName = [task.url CutNSStringFromBackWard:@"/"];
                
                if (fileName) {
                    
                    NSString *tmpFileString = [NSString stringWithFormat:@"%@/%@.tmp",document_path,fileName];
                    
                    if ([[NSFileManager defaultManager] fileExistsAtPath:tmpFileString]) {
                        
                        if (![[NSFileManager defaultManager] fileExistsAtPath:DataDownload_PATH]) {
                            [[NSFileManager defaultManager] createDirectoryAtPath:DataDownload_PATH withIntermediateDirectories:NO attributes:nil error:nil];
                        }
                        
                        NSString *newTmpFileString = [NSString stringWithFormat:@"%@%@.tmp",DataDownload_PATH,fileName];
                        
                        [[NSFileManager defaultManager] moveItemAtPath:tmpFileString toPath:newTmpFileString error:nil];
                        
                    }
                }
                
            }
        }
    }
}

#pragma mark - 私有方法

// 从头开始向尾扫描mTaskList列表，直到遇到一个状态为TASK_STATUS_READY的任务对象
// 返回指<0则表示没找到可被执行的任务，否则表示所选任务的索引
-(int)_selectOneTaskToRun
{
    return [self _firstIndexWithStatus:TASK_STATUS_READY];
}


// 返回队列中，状态为status的第一个任务的索引
// 返回指<0则表示没找到可被执行的任务，否则表示任务的索引
-(int)_firstIndexWithStatus:(int)status
{
    int count = [taskList count];
    for (int i=0;i<count;i++) {
        
        if(((Task*)[taskList caObjectsAtIndex:i]).status == status)
        {
            return i;
        }
    }
    return -1;
}

//返回队列中，任务id为taskID的任务索引
- (int)_indexWithTaskID:(int)taskID
{
    int count = [taskList count];
    for (int i=0;i<count;i++) {
        
        if(((Task*)[taskList caObjectsAtIndex:i]).taskId == taskID)
        {
            return i;
        }
    }
    return 0;
}
// 根据taskId来判断task是否已经存在队列中
-(BOOL)_taskExisted:(Task*)task
{
    for (Task* t in taskList) {
        // 用任务id来比较
        if(t.taskId == task.taskId)
        {
            return YES;
        }
    }
    return NO;
}



#pragma mark - TaskStatusDelegate委托回调

-(void)progress:(Task*)sender current:(long long)current total:(long long)total
{
    if (sender) {
//        NSLog(@"%@:%lld,%lld",sender.title,current,total);
    }
    
	if ([delegate respondsToSelector:@selector(progress:current:total:)]) {
        [delegate progress:sender current:current total:total];
	}
}

-(void)finished:(Task*)sender
{
	sender.status = TASK_STATUS_FINISH;
	
    [self store];
    [self start];
	
    if ([delegate respondsToSelector:@selector(finished:)]) {
	    [delegate finished:sender];
	}
}

-(void)exception:(Task*)sender exception:(id)exception
{
    if (((NSError *)exception).code == DOWNLOADHANDLETYPE_CURRENTLAGERTOTAL || ((NSError *)exception).code == DOWNLOADHANDLETYPE_NOSPACE ||((NSError *)exception).code == DOWNLOADHANDLETYPE_UPZIPFAIL || ((NSError *)exception).code == DOWNLOADHANDLETYPE_CURRENTSMALLTOTAL) {
        [self update_erase:sender.taskId];
    }
    
    [self stopRunning];
    //modify by xyy at 2014.8.23 for 网络异常时，界面卡住。
    //网络异常时，不进行store，延迟1s继续下载数据，防止网络连续异常时不断进行读写操作
//    [self store];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([delegate respondsToSelector:@selector(exception:exception:)]) {
            [delegate exception:sender exception:exception];//异常回调函数：重新下载数据
        }
    });
    
}
- (void)unZipFinish:(Task*)sender
{
    if ([delegate respondsToSelector:@selector(unZipFinish:)]) {
        [delegate unZipFinish:sender];
    }
    
}


@end

//
//  DialectDownloadManage.m
//  AutoNavi
//
//  Created by longfeng.huang on 14-1-15.
//
//

#import "MWDialectDownloadManage.h"
#import "plugin-cdm-Task.h"
#import "GDStatusBarOverlay.h"
#import "MWPreference.h"
#import "XMLDictionary.h"
#import "GDAlertView.h"
#import "MWTTS.h"
#import "JSON.h"

#define kDialectUnZipType              @".zip"
#define DialectState                   3
#define DialectID                      1
#define DialectCurrent                 0

static MWDialectDownloadManage *instance;

@implementation MWDialectDownloadManage

@synthesize dialectTaskList,serviceDialectTaskList,delegate,dialectDownloadURL,dialectMatchVersion,dialectSize,cancelDialectCheck,dialectName;

+ (MWDialectDownloadManage *)sharedInstance
{
    if (instance == nil) {
        instance = [[MWDialectDownloadManage alloc] init];
        [instance restore];
        [instance ServiceRestore];

    }
    return instance;
}

- (id)init
{
    if (self = [super init]) {
        dialectTaskList = [[NSMutableArray alloc] init];
        serviceDialectTaskList = [[NSMutableArray alloc] init];
    }
    return self;
}

/*!
  @brief 请求方言下载链接
  */
- (void)RequestDialect
{
    
    NSString *signString = [[NSString stringWithFormat:@"%@%d@%@",KNetChannelID,SOFTVERSIONCODE,kNetSignKey] stringFromMD5];
    
    NSMutableDictionary *urlParams = [[NSMutableDictionary alloc] init];
    
    [urlParams setValue:VendorID forKey:@"imei"];
    [urlParams setValue:[NSString stringWithFormat:@"%d",SOFTVERSIONCODE] forKey:@"apkversion"];
    [urlParams setValue:MapVersionNoV forKey:@"mapversion"];
    [urlParams setValue:deviceModel forKey:@"model"];
    [urlParams setValue:DeviceResolutionString forKey:@"resolution"];
    [urlParams setValue:CurrentSystemVersion forKey:@"os"];
    [urlParams setValue:UserID_Account forKey:@"userid"];
    [urlParams setValue:KNetChannelID forKey:@"syscode"];
    [urlParams setValue:PID forKey:@"pid"];
    [urlParams setValue:SID forKey:@"sid"];
    [urlParams setValue:signString forKey:@"sign"];
    
    NSMutableDictionary *bodyDic = [[NSMutableDictionary alloc] init];
    [bodyDic setValue:@"0001" forKeyPath:@"activitycode"];
    [bodyDic setValue:[NSNumber numberWithInt:NetFontType] forKeyPath:@"language"];
    [bodyDic setValue:NetProcessTime forKeyPath:@"processtime"];
    [bodyDic setValue:[NSNumber numberWithInt:1] forKeyPath:@"protversion"];
    
    NSMutableDictionary *svccontDic = [[NSMutableDictionary alloc] init];
    [svccontDic setValue:[NSString stringWithFormat:@"%d",SOFTVERSIONCODE] forKeyPath:@"clientver"];
    [bodyDic setValue:svccontDic forKeyPath:@"svccont"];
    
    NSString *bodyString = [bodyDic JSONRepresentation];
    
    NetBaseRequestCondition *condition = [NetBaseRequestCondition requestCondition];
    condition.httpHeaderFieldParams = urlParams;
    condition.baceURL = kDialectRequestURL;
    condition.requestType = RT_DialectRequest;
    condition.httpMethod = @"POST";
    condition.urlParams = nil;
    condition.bodyData = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    
    [[NetExt sharedInstance] requestWithCondition:condition delegate:self];
    [svccontDic release];
    [bodyDic release];
    [urlParams release];
    
}


/*!
  @brief 方言下载网络状态判断处理
  */
- (void)newFuntionDialectNetWorkHandle:(MWDialectDownloadTask *)sender Type:(RequestType)requestType
{
    
    int netType = NetWorkType;
    int taskID = sender.taskId;
    
    if (netType == 2) {
        
        if ([self isRunningWithTaskID:taskID]) {
            [self stopWithOutOtherStartWithTaskID:taskID];
        }
        
        [self startWithTaskID:taskID];
        
    }
    else if(netType == 1){
        
        if ([self isRunningWithTaskID:taskID]) {
            [self stopWithOutOtherStartWithTaskID:taskID];
        }
        
        long long totalsize = sender.total - sender.current;
        
        NSString *title = [self getDialectTitle:sender.title];
        NSString *Unit = @"";
        float size;
        if (totalsize >= 1024*1024*1024) {
            Unit = @"GB";
            size = totalsize*1.0/1024/1024/1024;
        }
        else if(1024*1024 <= totalsize < 1024*1024*1024)
        {
            Unit = @"MB";
            size = totalsize*1.0/1024/1024;
        }
        else if(totalsize < 1024*1024){
            Unit = @"KB";
            size = totalsize*1.0/1024;
        }
        
        GDAlertView *alertView = [[GDAlertView alloc] initWithTitle:nil andMessage:[NSString stringWithFormat:STR(@"Universal_downloadDialectWithNoWIFI",Localize_Universal),title,size,Unit] ];
        
        [alertView addButtonWithTitle:STR(@"Universal_no", Localize_Universal) type:GDAlertViewButtonTypeCancel handler:^(GDAlertView *alertView){
            
           if (sender.current == 0) {
               [self removeTaskId:sender.taskId];
           }
            if (delegate && [delegate respondsToSelector:@selector(exception:exception:)]) {
                [delegate exception:sender exception:[NSNumber numberWithInt:DOWNLOADHANDLETYPE_3GDOWNLOAD]];
            }
            
        }];
        [alertView addButtonWithTitle:STR(@"Universal_yes", Localize_Universal) type:GDAlertViewButtonTypeDefault handler:^(GDAlertView *alertView){
        
            
            [self startWithTaskID:taskID];
            
            if (delegate && [delegate respondsToSelector:@selector(exception:exception:)]) {
                [delegate exception:sender exception:[NSNumber numberWithInt:DOWNLOADHANDLETYPE_3GDOWNLOAD]];
            }
            
        }];
        [alertView show];
        [alertView release];
        
        
    }
    else {
        
        if ([self isRunningWithTaskID:taskID]) {
            [self stopWithOutOtherStartWithTaskID:taskID];
        }
        
        
        if (delegate && [delegate respondsToSelector:@selector(exception:exception:)]) {
            [delegate exception:sender exception:[NSNumber numberWithInt:DOWNLOADHANDLETYPE_NONETWORK]];//无网络连接
        }
        
    }
}

/*!
  @brief 获取本地方言列表
  @return
  */
- (NSMutableArray *)getDialectTaskIDList
{
    NSMutableArray *taskIDArray = [[NSMutableArray alloc] init];
    
    if (serviceDialectTaskList && serviceDialectTaskList.count > 0)
    {
        for (MWDialectDownloadTask *task in serviceDialectTaskList) {
            
            if (fontType == 2 && task.dialectFontType == 2) {
                [taskIDArray addObject:task];
            }
            else if (fontType != 2 && task.dialectFontType != 2){
                [taskIDArray addObject:task];
            }
            
        }
    }
    else {
        
        if (fontType == 2) {
            for (MWDialectDownloadTask *dTask in dialectTaskList) {
                
                if (dTask.dialectFontType == 2) {
                    [taskIDArray addObject:dTask];
                }
            }
        }
        else {
            
            for (MWDialectDownloadTask *dTask in dialectTaskList) {
                
                if (dTask.dialectFontType != 2) {
                    [taskIDArray addObject:dTask];
                }
            }
        }
        
    }
    
    return [taskIDArray autorelease];
}

/*!
  @brief 获取本地方言
 .@param taskID 方言id
  @return MWDialectDownloadTask 方言对象
  */
- (MWDialectDownloadTask *)getLocalDialectTaskWithTaskID:(int)taskID
{
    
    if (serviceDialectTaskList && serviceDialectTaskList.count > 0)
    {
        
        MWDialectDownloadTask *task = nil;
       
        for (MWDialectDownloadTask *tmp in serviceDialectTaskList) {
            if (tmp.taskId == taskID) {
                task = tmp;
            }
        }
        
        if (task && [self _taskExisted:task]) {
            
            MWDialectDownloadTask *downTask = [self getTaskWithTaskID:task.taskId];
            if (![downTask.version isEqualToString:task.version])
            {
                downTask.beNeedUpdate = YES;
            }
            else{
                downTask.beNeedUpdate = NO;
            }
            return downTask;
            
        }
        else{
            return task;
        }
    }
    else{
        
        MWDialectDownloadTask *dTask = [self getTaskWithTaskID:taskID];
        return dTask;
    }
    

}

- (MWDialectDownloadTask *)getTaskFromDictionary:(NSDictionary *)dic
{
    if (!dic) {
        return nil;
    }
    
    MWDialectDownloadTask *task = [[MWDialectDownloadTask alloc] init];
    
    task.title = [dic objectForKey:@"name"] ? [dic objectForKey:@"name"] : @"";
    task.url = [dic objectForKey:@"downloadurl"];
    task.status = DialectState;
    task.taskId = [[dic objectForKey:@"id"] intValue];
    task.version = [dic objectForKey:@"version"];
    task.folderName = [dic objectForKey:@"folder"];
    task.total = [[dic objectForKey:@"size"] intValue];
    task.current = DialectCurrent;
    task.dialectHasRecord = [[dic objectForKey:@"hastape"] boolValue];
    task.dialectPlaySpeed = [[dic objectForKey:@"speed"] intValue];
    task.dialectRoleID = [[dic objectForKey:@"roleid"] intValue];
    task.beNeedUpdate = NO;
    task.dialectFontType = fontType;
    task.md5 = [dic objectForKey:@"md5"];
    
    return [task autorelease];
}

/*!
  @brief 同步网络方言列表到本地
  @return
  */
- (BOOL)addDialectListFromNetToLocal:(id)dialectArr
{
    
    if ([dialectArr isKindOfClass:[NSDictionary class]]) {
        
        
        MWDialectDownloadTask *task = [self getTaskFromDictionary:dialectArr];
        
        if (task) {
            
            MWDialectDownloadTask *_task = [self getTaskWithTaskID:task.taskId];
            
            if (_task && ![_task.version isEqualToString:task.version])
            {
                _task.beNeedUpdate = YES;
            }
            
            [serviceDialectTaskList removeAllObjects];
            [serviceDialectTaskList addObject:task];
        }
        
        
    }
    else if ([dialectArr isKindOfClass:[NSArray class]]){
        
        [serviceDialectTaskList removeAllObjects];
        
        for (NSDictionary *dic in dialectArr) {
            
            MWDialectDownloadTask *task = [self getTaskFromDictionary:dic];
            
            if (task) {
                
                MWDialectDownloadTask *_task = [self getTaskWithTaskID:task.taskId];
                
                if (_task && _task.status == TASK_STATUS_FINISH && ![_task.version isEqualToString:task.version])
                {
                    _task.beNeedUpdate = YES;
                    
                }
                
                [serviceDialectTaskList addObject:task];
            }
        }
    }
    
    
    if ([NSKeyedArchiver archiveRootObject:serviceDialectTaskList toFile:dialectConfigDocumentPath]) {
       
    }
    
    
    return YES;
}

/*!
  @brief 切换语音播报
 .@param taskID 任务id，本地默认的方言传－1，其他传相对应的id
  @return
  */
- (BOOL)switchTTSPathWithTaskID:(int)taskID
{
    if (fontType == 2) {
        
        if (taskID == 0) {
            
            [[MWPreference sharedInstance] setValue:PREF_IS_LZLDIALECT Value:0];
            [[MWPreference sharedInstance] setValue:PREF_TTSROLEINDEX Value:0];
            
        }
        else{
            
            MWDialectDownloadTask *task = [self getTaskWithTaskID:taskID];
            
            if (task && task.status == TASK_STATUS_FINISH) {
                
                [[MWTTS SharedInstance] SetTTSSpeed:task.dialectPlaySpeed];
                [[MWTTS SharedInstance] SetTTSUsePrompts:task.dialectHasRecord];
                [[MWTTS SharedInstance] SetTTSFolder:task.folderName];
                
                [[MWPreference sharedInstance] setValue:PREF_TTSROLEINDEX Value:task.dialectRoleID];
                [[MWPreference sharedInstance] setValue:PREF_IS_LZLDIALECT Value:task.taskId];
            }
        }
        
        
    }
    else {
        
        if (taskID == 0) {
            
            [[MWPreference sharedInstance] setValue:PREF_TTSROLEINDEX Value:0];
            [[MWPreference sharedInstance] setValue:PREF_IS_LZLDIALECT Value:0];
            
        }
        else{
            
            MWDialectDownloadTask *_mTask = [self getTaskWithTaskID:taskID];
            
            if (_mTask && _mTask.status == TASK_STATUS_FINISH) {
                
                [[MWTTS SharedInstance] SetTTSSpeed:_mTask.dialectPlaySpeed];
                [[MWTTS SharedInstance] SetTTSUsePrompts:_mTask.dialectHasRecord];
                [[MWTTS SharedInstance] SetTTSFolder:_mTask.folderName];
                [[MWPreference sharedInstance] setValue:PREF_TTSROLEINDEX Value:_mTask.dialectRoleID];
                [[MWPreference sharedInstance] setValue:PREF_IS_LZLDIALECT Value:_mTask.taskId];
            }
        }
        
    }
    
    return YES;
}

/*!
  @brief 下载更新语音
 .@param taskID 任务id
  @return
  */
- (BOOL)downloadTTSWithTaskID:(int)taskID
{
    
    MWDialectDownloadTask *_mTask = [self getTaskWithTaskID:taskID];
    if (_mTask) {
        if (_mTask.status == TASK_STATUS_FINISH) {
            
            if (_mTask.beNeedUpdate) {
                
                [self addTaskToListWithTaskID:taskID requestType:RT_DialectRequest];
                
            }
            
        }
        else{
            if (_mTask.status == TASK_STATUS_BLOCK || _mTask.status == TASK_STATUS_READY) {
                [self newFuntionDialectNetWorkHandle:_mTask Type:RT_DialectRequest];
            }
            else{
                [self stop:index];
            }
            
            return NO;
        }
    }
    else{
        
        [self addTaskToListWithTaskID:taskID requestType:RT_DialectRequest];
        return NO;
    }
    
    
    
    return YES;
}


/*!
  @brief 把skinTaskList中的所有任务信息保存到文件系统，一般是在退出程序时调用
  @return 成功返回 YES 失败返回 NO
  */
-(BOOL)store
{
    /*
     1、序列化整个skinTaskList
     */
    
    @synchronized(self)
	{
        NSString *Path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *filename = [Path stringByAppendingPathComponent:kDialectPlist];
        if (![NSKeyedArchiver archiveRootObject:dialectTaskList toFile:filename]){
            return NO;
        }
        else {
            return YES;
        }
    }
    
}

/*!
  @brief 从文件系统还原通过save保存的所有任务信息，一般是在进入程序时调用，该方法调用将把skinTaskList中的所有任务更新为最后一次调用save保存的任务
  @return 成功返回 YES 失败返回 NO
  */
-(BOOL)restore
{
    /*
     1、反序列化各个Task对象，构建处skinTaskList
     2、遍历skinTaskList，把task.delegate = self;
     */
	
	NSString *Path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	NSString *filename = [Path stringByAppendingPathComponent:kDialectPlist];
	NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithFile:filename];
	[dialectTaskList removeAllObjects];
	[dialectTaskList addObjectsFromArray:array];
	
    for (MWDialectDownloadTask *task in dialectTaskList) {
        
//        if (task.status == TASK_STATUS_RUNNING) {//如果上次退出时是运行状态，恢复的时候置为暂停
//            task.status = TASK_STATUS_BLOCK;
//        }
		task.delegate = self;
	}
    
    [self unZipFileInPath:Dialect_path MatchContent:kDialectUnZipType];
	return YES;
	
}

/*!
  @brief 把serviceDialectTaskList中的所有任务信息保存到文件系统，一般是在退出程序时调用
  @return 成功返回 YES 失败返回 NO
  */
-(BOOL)serviceStore
{
    /*
     1、序列化整个serviceDialectTaskList
     */
    
	if (![NSKeyedArchiver archiveRootObject:serviceDialectTaskList toFile:dialectConfigDocumentPath]){
		return NO;
	}
	else {
		return YES;
	}
    
}

/*!
  @brief 从文件系统还原通过save保存的所有任务信息，一般是在进入程序时调用，该方法调用将把skinTaskList中的所有任务更新为最后一次调用save保存的任务
  @return 成功返回 YES 失败返回 NO
  */
-(BOOL)ServiceRestore
{
    /*
     1、反序列化各个Task对象，构建处serviceDialectTaskList
     2、遍历serviceDialectTaskList，把task.delegate = self;
     */
	
	NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithFile:dialectConfigDocumentPath];
	[serviceDialectTaskList removeAllObjects];
	[serviceDialectTaskList addObjectsFromArray:array];
	
	return YES;
	
}

/*!
  @brief 获取方言名称
  */
- (NSString *)getDialectTitle:(NSString *)arrayString
{
    NSArray *stringArray = [arrayString componentsSeparatedByString:@","];
    NSString *returnTitle = @"";
    if(stringArray.count >= 3)
    {
        returnTitle = [stringArray objectAtIndex:fontType];
    }
    else {
        returnTitle = arrayString;
    }
    return returnTitle;
}

#pragma mark - 下载管理

/*!
  @brief 将任务添加到任务列表中
  */
-(BOOL)addTaskToListWithTaskID:(int)taskID requestType:(RequestType)type
{
    
    MWDialectDownloadTask *dialectTask = nil;
    
    for (MWDialectDownloadTask *task in serviceDialectTaskList) {
        if (task.taskId == taskID) {
            dialectTask = task;
        }
    }
    
    if (dialectTask) {
        MWDialectDownloadTask *tmpTask = [[[MWDialectDownloadTask alloc] init] autorelease];
        tmpTask.url = dialectTask.url;
        tmpTask.status = dialectTask.status;
        tmpTask.current = dialectTask.current;
        tmpTask.total = dialectTask.total;
        tmpTask.dialectHasRecord = dialectTask.dialectHasRecord;
        tmpTask.dialectPlaySpeed = dialectTask.dialectPlaySpeed;
        tmpTask.title = dialectTask.title;
        tmpTask.beNeedUpdate = dialectTask.beNeedUpdate;
        tmpTask.folderName = dialectTask.folderName;
        tmpTask.dialectRoleID = dialectTask.dialectRoleID;
        tmpTask.taskId = dialectTask.taskId;
        tmpTask.version = dialectTask.version;
        tmpTask.dialectFontType = dialectTask.dialectFontType;
        tmpTask.md5 = dialectTask.md5;
        
        int _index = [self addTask:tmpTask atFirst:NO];
        
        if (_index >= 0) {
            
            MWDialectDownloadTask *task = [dialectTaskList objectAtIndex:_index];
            
            [self newFuntionDialectNetWorkHandle:task Type:type];
            return YES;
        }

    }
    
    [self store];
    
    
    return NO;
}

/*!
  @brief 添加任务到任务队列
  @return 返回-1表示加入失败，>=0表示成功加入后在skinTaskList中的索引
  */
-(int)addTask:(MWDialectDownloadTask*) task atFirst:(BOOL) first
{
    if(NO==[self _taskExisted:task])
    {
        task.delegate = self;
        task.status = TASK_STATUS_BLOCK;
        if(first)
        {
            [dialectTaskList insertObject:task atIndex:0];
            return 0;
        }
        else
        {
            [dialectTaskList addObject:task];
            return [dialectTaskList count]-1;
        }
    }
    else
    {
        [self removeTaskId:task.taskId];
        
        task.delegate = self;
        task.status = TASK_STATUS_BLOCK;
        
        [dialectTaskList addObject:task];
        
        return [dialectTaskList count]-1;
    }
}

/*!
  @brief 将本地存在的地图数据添加到下载队列中，并把状态置为完成
  @return 返回相对应的索引
  */
-(int)addLocalTask:(MWDialectDownloadTask*)task atFirst:(BOOL) first
{
    if(NO==[self _taskExisted:task])//任务列表中无，则添加
    {
        task.delegate = self;
        task.status = TASK_STATUS_FINISH;
        if(first)
        {
            [dialectTaskList insertObject:task atIndex:0];
            return 0;
        }
        else
        {
            [dialectTaskList addObject:task];
            return [dialectTaskList count]-1;
        }
    }
    else if(YES==[self _taskExisted:task] )
    {
        for (MWDialectDownloadTask *t in dialectTaskList)
        {
            if (t.taskId == task.taskId)
            {
                if (t.status != TASK_STATUS_FINISH)//若用户拖入完整的城市数据，则删除对应未下载完成的文件
                {
                    NSString *stringt = @"/";
                    NSRange range = [t.url rangeOfString:stringt options:NSBackwardsSearch];
                    if (range.length != 0)
                    {
                        NSString *name = [t.url substringFromIndex:range.location+1];
                        //   NSString *name = [NSString stringWithFormat:@"%@",[t.url CutFromNSString:@"cityupdatedata/"]];
                        NSFileManager *fileManager = [NSFileManager defaultManager];
                        NSArray *paths;
                        NSError *error;
                        NSString *documentsDirectory;
                        paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                        documentsDirectory = [[NSString alloc] initWithFormat:@"%@", [paths objectAtIndex:0]];
                        NSString *filePath = [NSString stringWithFormat:@"%@/%@.tmp",documentsDirectory,name];
                        [documentsDirectory release];
                        if([fileManager fileExistsAtPath:filePath])
                        {
                            [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
                            
                        }
                    }
                }
                t.status = TASK_STATUS_FINISH;
            }
	    }
        return 0;
    }
	else
    {
		return -1;
	}
    
}

/*!
  @brief TaskManager可能处于两种状态：1、无任何任务在执行：TaskManager按某种策略选择一个任务来执行 2、有任务在执行：直接返回
  @return 成功返回 YES 失败返回 NO
  */
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

/*!
  @brief  任务可能处于两种状态：
 1、无任何任务在执行：TaskManager按index来选择任务
 2、有任务在执行：
 1.1、正在执行的任务就是index，那么直接返回；
 2.1、正在执行的任务不是index，那么让正在执行的任务变为等待，转而执行index指定的任务
  @param  index 要下载的索引值
  @return 成功返回 YES 失败返回 NO
  */
-(BOOL)start:(int)index
{
    int indexRunning = [self _firstIndexWithStatus:TASK_STATUS_RUNNING];
    if (indexRunning == index || index > (int)(dialectTaskList.count -1)) {
        return NO;
    }
    else
    {
        // 先停止正在执行的任务
        if (indexRunning >= 0)
        {
            
            MWDialectDownloadTask* t = [dialectTaskList objectAtIndex:index];
            t.status = TASK_STATUS_READY;
            return YES;
            
        }
        
        
        MWDialectDownloadTask* t = [dialectTaskList objectAtIndex:index];
        t.status = TASK_STATUS_RUNNING;
        [t run];
        
        return YES;
    }
}

/*!
  @brief 下载指定id的任务
  @return
  */
- (void)startWithTaskID:(int)taskID
{
    
    for (int i = 0; i < dialectTaskList.count; i++) {
        MWDialectDownloadTask *tmp = [dialectTaskList objectAtIndex:i];
        if (tmp.taskId == taskID) {
            [self start:i];
            return;
        }
    }
}

/*!
  @brief 停止TaskManager中正在执行的任务，整个TaskManager处于停止状态
  @return 成功返回 YES 失败返回 NO
  */
-(BOOL)stop
{
    
    int index = [self _firstIndexWithStatus:TASK_STATUS_RUNNING];
    if (index>=0) {
        return [self stop:index];
    }
    return NO;
}

/*!
  @brief 停止TaskManager中index对应的任务：注意：只有状态为TASK_STATUS_RUNNING的任务才能被stop
  @param index对应的任务处于等待状态，那么直接返回，对应的任务处于执行状态，那么让正在执行的任务变为等待
  @return 成功返回 YES 失败返回 NO
  */
-(BOOL)stop:(int)index
{
    int count = [dialectTaskList count];
    if(index>=0 && index<count)
    {
        // 只有状态为TASK_STATUS_RUNNING的任务才能被stop
        MWDialectDownloadTask* t = [dialectTaskList objectAtIndex:index];
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

/*!
  @brief 停止TaskManager中taskID对应的任务：注意：只有状态为TASK_STATUS_RUNNING的任务才能被stop
  @param taskID对应的任务处于等待状态，那么直接返回，对应的任务处于执行状态，那么让正在执行的任务变为等待
  @return 成功返回 YES 失败返回 NO
  */
- (BOOL)stopWithTaskID:(int)taskID
{
    BOOL res = NO;
    
    for (int i = 0; i < dialectTaskList.count; i++) {
        MWDialectDownloadTask *tmp = [dialectTaskList objectAtIndex:i];
        if (tmp.taskId == taskID) {
            res = [self stop:i];
        }
    }
    
    return res;
}

/*!
  @brief 只暂停指定索引的任务，不自动下载等待的任务
  @param index 任务索引
  @return 成功返回 YES 失败返回 NO
  */
- (BOOL)stopCurrent:(int)index
{
    int count = [dialectTaskList count];
    if(index>=0 && index<count)
    {
        
        Task* t = [dialectTaskList objectAtIndex:index];
        if(t.status==TASK_STATUS_RUNNING)
        {
            
            t.status = TASK_STATUS_BLOCK;
            [t stop];
            
            return YES;
        }
    }
    return NO;
}

/*!
  @brief 只暂停指定索引的任务，不自动下载等待的任务
  @param taskID 任务id
  @return 成功返回 YES 失败返回 NO
  */
- (BOOL)stopWithOutOtherStartWithTaskID:(int)taskID
{
    int count = [dialectTaskList count];
    
    for (int i = 0; i < count ; i++ ) {
        
        MWDialectDownloadTask* t = [dialectTaskList objectAtIndex:i];
        if(t.taskId == taskID)
        {
            
            t.status = TASK_STATUS_BLOCK;
            [t stop];
            
            return YES;
        }
    }
    
    return NO;
}

/*!
  @brief 暂停所有的任务
  */
- (void)stopAllTask
{
    for (MWDialectDownloadTask *task in dialectTaskList) {
        if (task.status == TASK_STATUS_RUNNING || task.status == TASK_STATUS_READY) {
            task.status = TASK_STATUS_BLOCK;
        }
    }
}

/*!
  @brief  返回YES表示TaskManager中有任务正在运行
  @return 有任务在运行返回 YES 没有返回 NO
  */
-(BOOL)isRunning
{
    return [self _firstIndexWithStatus:TASK_STATUS_RUNNING]<0?NO:YES;
}

/*!
  @brief  返回YES表示TaskManager中对应的taskID任务正在运行
  @return 有任务在运行返回 YES 没有返回 NO
  */
- (BOOL)isRunningWithTaskID:(int)taskID
{
    BOOL res = NO;
    
    MWDialectDownloadTask *task = [self getTaskWithTaskID:taskID];
    
    if (task && task.status == TASK_STATUS_RUNNING) {
        
        res = YES;
    }
    
    return res;
}

/*!
  @brief 通过taskid获取任务
  @param taskID 任务ID
  @return 返回对应的任务
  */
- (MWDialectDownloadTask *)getTaskWithTaskID:(int)taskID
{
    for (MWDialectDownloadTask *temp in dialectTaskList) {
        if (temp.taskId == taskID) {
            
            return temp;
        }
        
    }
    return nil;
}


/*!
  @brief 移除索引为index处的任务，该操作会删除该任务。如果恰好该任务处于运行状态，removeTask后，整个TaskManager中将无任务在执行
  @param index 任务索引
  @return 成功返回 YES 失败返回 NO
  */
-(BOOL)removeTask:(int) index
{
    int count = [dialectTaskList count];
    if(index>=0 && index < count)
    {
        MWDialectDownloadTask* t = [dialectTaskList objectAtIndex:index];
        [t erase];
        [dialectTaskList removeObjectAtIndex:index];
        return  YES;
    }
    return NO;
}

/*!
  @brief 移除索引为index处的任务，该操作会删除该任务。如果恰好该任务处于运行状态，removeTaskId后，整个TaskManager中将无任务在执行
  @param taskId 任务ID
  @return 成功返回 YES 失败返回 NO
  */
-(BOOL)removeTaskId:(long) taskId
{
    int count = [dialectTaskList count];
	for (int i = 0; i < count; i++)
	{
        MWDialectDownloadTask* t = [dialectTaskList objectAtIndex:i];
		if (taskId == t.taskId) {
			if (taskId == 0) {
				[t erase];
				[dialectTaskList removeAllObjects];
			}
			else {
				[t erase];
				[dialectTaskList removeObjectAtIndex:i];
			}
			return YES;
		}
	}
    return NO;
}

/*!
  @brief  删除某一状态的任务
  @return 返回删除个数
  */
-(int)removeTasksForStatus:(int) status
{
    
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

/*!
  @brief  从头开始向尾扫描mTaskList列表，直到遇到一个状态为TASK_STATUS_READY的任务对象
  @return 返回指<0则表示没找到可被执行的任务，否则表示所选任务的索引
  */
-(int)_selectOneTaskToRun
{
    return [self _firstIndexWithStatus:TASK_STATUS_READY];
}

/*!
  @brief 返回队列中，状态为status的第一个任务的索引
  @param status 任务状态
  @return 返回指<0则表示没找到可被执行的任务，否则表示任务的索引
  */
-(int)_firstIndexWithStatus:(int)status
{
    int count = [dialectTaskList count];
    for (int i=0;i<count;i++) {
        if(((MWDialectDownloadTask*)[dialectTaskList objectAtIndex:i]).status == status)
        {
            return i;
        }
    }
    return -1;
}

/*!
  @brief 根据taskId来判断task是否已经存在队列中
  @param task 任务对象
  @return 成功返回 YES 失败返回 NO
  */
-(BOOL)_taskExisted:(MWDialectDownloadTask*)task
{
    for (MWDialectDownloadTask* t in dialectTaskList) {
        // 用任务id来比较
        if(t.taskId == task.taskId)
        {
            return YES;
        }
    }
    return NO;
}


/*!
  @brief 获取任务列表中所有任务需要的空间大小
  @return 所需空间大小
  */
-(long long)getNeedSize
{
	long long size;
	size = 0;
    
	int count = [dialectTaskList count];
    for (int i=0;i<count;i++) {
        MWDialectDownloadTask* t = [dialectTaskList objectAtIndex:i];
        if(t.status == TASK_STATUS_READY || t.status == TASK_STATUS_RUNNING)
        {
            size += (t.total - t.current);
        }
    }
    return size;
}

/**
 *解压目录下所有文件
 *rootPath:要解压的路径名称(尾部无需/),matchName:要匹配的结尾名称,nil或""则不验证匹配
 */
-(BOOL) unZipFileInPath:(NSString *)rootPath MatchContent:(NSString*)matchName
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (fileManager==nil)
	{
        return nil;
    }
	//	NSLog(@"search files in path:%@,match text:%@",rootPath,matchName);
	NSError *error = nil;
	
	//fileList便是包含有该文件夹下所有文件的文件名及文件夹名的数组
	NSArray* fileList = [[NSArray alloc]initWithArray:[fileManager contentsOfDirectoryAtPath:rootPath error:&error]] ;
    
    //以下这段代码则可以列出给定一个文件夹里的所有子文件夹名
	NSMutableArray *fileArray = [[[NSMutableArray alloc] init] autorelease];
	signed char isDir = NO;
	//在上面那段程序中获得的fileList中列出文件名
	for (NSString *file in fileList)
	{
		NSString *path = [rootPath stringByAppendingPathComponent:file];
		[fileManager fileExistsAtPath:path isDirectory:(&isDir)];
		if (isDir)
		{
			//[dirArray addObject:file];文件夹
		}
		else
		{
			//			[dirArray addObject:[file stringByDeletingPathExtension]];//去除扩展名，文件
            if (matchName!=nil&&[matchName length]>0)
            {
                //匹配文件名结尾的字符
                if ([file hasSuffix:matchName]==YES)
                {
                    [fileArray addObject:path];
                }
            }
		}
        
		isDir = NO;
	}
	[fileList release];
    
    if (fileArray.count > 0) {
        for ( NSString *fileName in fileArray) {
            for (MWDialectDownloadTask *task in dialectTaskList) {
                if ([fileName hasSuffix:[task getFilename]]) {
                    [task checkZipFileAndUnZipFile];
                    return YES;
                }
            }
        }
        
    }
    return NO;
}


#pragma mark - 下载委托回调

-(void)progress:(MWDialectDownloadTask*)sender current:(long long)current total:(long long)total
{
    NSLog(@"%lld,%lld",current,total);
    
    if (delegate && [delegate respondsToSelector:@selector(progress:current:total:)]) {
        [delegate progress:sender current:current total:total];
    }
    
	
}

-(void)finished:(MWDialectDownloadTask*)sender
{
	sender.status = TASK_STATUS_FINISH;
    
    [self start];
    
    if (delegate && [delegate respondsToSelector:@selector(finished:)]) {
        [delegate finished:sender];
    }
}

-(void)exception:(MWDialectDownloadTask*)sender exception:(id)exception
{
    
    int exceptionCode = ((NSError *)exception).code;
    
    if (exceptionCode == DOWNLOADHANDLETYPE_UPZIPFAIL) {//解压失败，删除数据，重新下载
        
        [self removeTaskId:sender.taskId];
        
    }
    else if( exceptionCode == DOWNLOADHANDLETYPE_CURRENTLAGERTOTAL || exceptionCode == DOWNLOADHANDLETYPE_UPZIPFAIL || exceptionCode == DOWNLOADHANDLETYPE_CURRENTSMALLTOTAL || exceptionCode == DOWNLOADHANDLETYPE_MD5NOMATCH ){//下载失败
       
        if (delegate && [delegate respondsToSelector:@selector(exception:exception:)]) {
            [delegate exception:sender exception:[NSNumber numberWithInt:exceptionCode]];
        }
        
        [self removeTaskId:sender.taskId];
        
    }
    
    else {
        
        
        [self newFuntionDialectNetWorkHandle:sender Type:RT_DialectRequest];
        
    }
    
    [self store];
    
}

- (void)unZipFinish:(MWDialectDownloadTask*)sender
{
    
    if (delegate && [delegate respondsToSelector:@selector(unZipFinish:)]) {
        [delegate unZipFinish:sender];
    }
    else if ([ANParamValue sharedInstance].isInit){
        
    }
    
    
    [self store];
    
}

#pragma mark - url请求回调
//服务器成功应答
- (void)request:(NetRequestExt *)request didFinishLoadingWithData:(NSData *)data
{
    
    if (data && [data length])
    {
        char *szResult = (char *)[data bytes];
        
        NSString *tmp = [NSString stringWithFormat:@"%s",szResult];
        
        NSLog(@"方言请求结果：%@",tmp);
        
        NSDictionary *dialectDic = [NSJSONSerialization
                                    
                                    JSONObjectWithData:data
                                    
                                    options:NSJSONReadingMutableLeaves
                                    
                                    error:nil];
        
        if (dialectDic && [dialectDic objectForKey:@"response"]) {
            
            NSString *rspcode = [[dialectDic objectForKey:@"response"] objectForKey:@"rspcode"];
            
            if ([rspcode isEqualToString:@"0000"]) {
                
                NSDictionary *svccont = [dialectDic objectForKey:@"svccont"];
                
                if (svccont) {
                    [self addDialectListFromNetToLocal:[svccont objectForKey:@"list"]];
                }
                
                if ([_reqDelegate respondsToSelector:@selector(requestToViewCtrWithRequestType:didFinishLoadingWithResult:)])
                {
                    [_reqDelegate requestToViewCtrWithRequestType:request.requestCondition.requestType didFinishLoadingWithResult:nil];
                }
            }
            else
            {
                if ([_reqDelegate respondsToSelector:@selector(requestToViewCtrWithRequestType:didFailWithError:)])
                {
                    [_reqDelegate requestToViewCtrWithRequestType:request.requestCondition.requestType didFailWithError:nil];
                }
            }
        }
        else {
            
            if ([_reqDelegate respondsToSelector:@selector(requestToViewCtrWithRequestType:didFailWithError:)])
            {
                [_reqDelegate requestToViewCtrWithRequestType:request.requestCondition.requestType didFailWithError:nil];
            }
            
        }
        
        
    }
    else{
        
        
        if ([_reqDelegate respondsToSelector:@selector(requestToViewCtrWithRequestType:didFailWithError:)])
        {
            [_reqDelegate requestToViewCtrWithRequestType:request.requestCondition.requestType didFailWithError:nil];
        }
    }
}

- (void)request:(NetRequestExt *)request didFailWithError:(NSError *)error
{
    
	if ([_reqDelegate respondsToSelector:@selector(requestToViewCtrWithRequestType:didFailWithError:)])
    {
        [_reqDelegate requestToViewCtrWithRequestType:request.requestCondition.requestType didFailWithError:error];
    }
    
}
@end

//
//  MWSkinDownloadManager.m
//  AutoNavi
//
//  Created by huang longfeng on 13-11-19.
//
//

#import "MWSkinDownloadManager.h"
#import "plugin-cdm-Task.h"
#import "MWSkinDownloadTask.h"
#import "GDStatusBarOverlay.h"
#import "MWPreference.h"

#define kSkinURL                    @"iphonedata/skin_down/?"
#define kSkinUnZipType              @".zip"


static MWSkinDownloadManager *instance;

@implementation MWSkinDownloadManager

@synthesize skinTaskList,delegate,skinDownloadURL,skinMatchVersion,skinSize,cancelSkinCheck,skinName,skinID,updateVersionDictionary;

+ (MWSkinDownloadManager *)sharedInstance
{
    if (instance == nil) {
        instance = [[MWSkinDownloadManager alloc] init];
        [instance restore];
        [instance restoreSkinUpdateVersion];
    }
    return instance;
}

- (id)init
{
    if (self = [super init]) {
        skinTaskList = [[NSMutableArray alloc] init];
        
        self.updateVersionDictionary = [[[NSMutableDictionary alloc] init] autorelease];
    }
    return self;
}

/*!
  @brief 请求皮肤下载链接
  */
- (void)RequestSkinURLWithSkinID:(int)skinid
{
    self.skinID = skinid;
    
    
	NSMutableDictionary *urlParams = [[NSMutableDictionary alloc] init];
    [urlParams setValue:[NSString stringWithFormat:@"%.1f",SOFTVERSIONNUM] forKey:@"client"];
    [urlParams setValue:[NSString stringWithFormat:@"%d",skinid] forKey:@"skinID"];
    [urlParams setValue:@"1.0" forKey:@"skinVersion"];
    
    NetBaseRequestCondition *condition = [NetBaseRequestCondition requestCondition];
    condition.baceURL = [kNetDomain stringByAppendingString:kSkinURL];
    condition.requestType = RT_SkinDownload;
    condition.httpMethod = @"GET";
    condition.urlParams = urlParams;
    
    [[NetExt sharedInstance] requestWithCondition:condition delegate:self];
    [urlParams release];
    
}

/*!
  @brief 请求皮肤是否需要更新
  */
- (void)RequestSkinUpdateWithSkinID:(int)skinid
{
    self.skinID = skinid;
    
    
	NSMutableDictionary *urlParams = [[NSMutableDictionary alloc] init];
    [urlParams setValue:[NSString stringWithFormat:@"%.1f",SOFTVERSIONNUM] forKey:@"client"];
    [urlParams setValue:[NSString stringWithFormat:@"%d",skinid] forKey:@"skinID"];
    [urlParams setValue:[[GDSkinColor sharedInstance] getSkinVersion] forKey:@"skinVersion"];
    
    NetBaseRequestCondition *condition = [NetBaseRequestCondition requestCondition];
    condition.baceURL = [kNetDomain stringByAppendingString:kSkinURL];
    condition.requestType = RT_SkinUpdate;
    condition.httpMethod = @"GET";
    condition.urlParams = urlParams;
    
    [[NetExt sharedInstance] requestWithCondition:condition delegate:self];
    [urlParams release];
    
}

/*!
  @brief 皮肤下载网络状态判断处理
  */
- (void)skinNetWorkHandle:(Task *)sender
{
    int netType = NetWorkType;
    
    int taskID = 0;
    
    if (sender) {
        taskID = sender.taskId;
    }
    else{
        taskID = self.skinID;
    }
    
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

        [self startWithTaskID:taskID];
    
    }
    else {
        
        if ([self isRunningWithTaskID:taskID]) {
            [self stopWithOutOtherStartWithTaskID:taskID];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_SkinCheckResult object:[NSNumber numberWithInt:3]];
        
        if (delegate && [delegate respondsToSelector:@selector(exception:exception:)]) {
            [delegate exception:sender exception:[NSNumber numberWithInt:DOWNLOADHANDLETYPE_NONETWORK]];//无网络连接
        }
        
    }
}

/*!
  @brief 开始皮肤检测
  @return
  */
- (void)skinCheckContinue
{
    Task *task = [self getTaskWithTaskID:[[MWPreference sharedInstance] getValue:PREF_SKINTYPE]];
    
    if (task && task.status != TASK_STATUS_FINISH) {
        [self skinNetWorkHandle:task];
        return;
    }
    
    [self RequestSkinUpdateWithSkinID:[[MWPreference sharedInstance] getValue:PREF_SKINTYPE]];
}

/*!
  @brief 开始皮肤检测
  @return
  */
- (void)skinCheckStart
{
    
    if (0 == NetWorkType) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_SkinCheckResult object:[NSNumber numberWithInt:2]];
        
    }
    else {
        
        [self skinCheckContinue];
        
    }
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
    
	NSString *Path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	NSString *filename = [Path stringByAppendingPathComponent:kSkinPlist];
	if (![NSKeyedArchiver archiveRootObject:skinTaskList toFile:filename]){
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
-(BOOL)restore
{
    /*
     1、反序列化各个Task对象，构建处skinTaskList
     2、遍历skinTaskList，把task.delegate = self;
     */
	
	NSString *Path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	NSString *filename = [Path stringByAppendingPathComponent:kSkinPlist];
	NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithFile:filename];
	[skinTaskList removeAllObjects];
	[skinTaskList addObjectsFromArray:array];
	
    for (Task *task in skinTaskList) {
		task.delegate = self;
	}
    
    [self unZipFileInPath:Skin_path MatchContent:kSkinUnZipType];
	return YES;
	
}
#pragma mark - 更新管理

/*!
  @brief 把updateVersionDictionary中的所有任务信息保存到文件系统，一般是在退出程序时调用
  @return 成功返回 YES 失败返回 NO
  */
- (BOOL)storeSkinUpdateVersion
{
    NSString *Path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	NSString *filename = [Path stringByAppendingPathComponent:kSkinUpdateVersion];
	if (![NSKeyedArchiver archiveRootObject:updateVersionDictionary toFile:filename]){
		return NO;
	}
	else {
		return YES;
	}
}

/*!
  @brief 从文件系统还原通过save保存的所有任务信息，一般是在进入程序时调用，该方法调用将把updateVersionDictionary中的所有任务更新为最后一次调用save保存的任务
  @return 成功返回 YES 失败返回 NO
  */
- (BOOL)restoreSkinUpdateVersion
{
    NSString *Path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	NSString *filename = [Path stringByAppendingPathComponent:kSkinUpdateVersion];
	NSMutableDictionary *array = [NSKeyedUnarchiver unarchiveObjectWithFile:filename];
	[updateVersionDictionary removeAllObjects];
    
	self.updateVersionDictionary = [NSMutableDictionary dictionaryWithDictionary:array];
    
	return YES;
}

/*!
  @brief 设置更新版本号
  */
- (void)setUpdateVersion:(NSString *)version
{
//    int skinType = 0;
//    GDBL_GetParamExt(SKINTYPE, &skinType);
//    
//    [updateVersionDictionary setObject:version forKey:[NSNumber numberWithInt:skinType]];
    
    
}
#pragma mark - 下载管理

/*!
  @brief 将任务添加到任务列表中
  */
-(void)addTaskToList
{
    MWSkinDownloadTask *travelTask = [[MWSkinDownloadTask alloc] init];
    
    travelTask.title  = self.skinName;
    travelTask.taskId = self.skinID;
    travelTask.url    = self.skinDownloadURL;
    travelTask.total  = self.skinSize;
    
    [self addTask:travelTask atFirst:NO];
    [travelTask release];
    
    [self store];
}

/*!
  @brief 添加任务到任务队列
  @return 返回-1表示加入失败，>=0表示成功加入后在skinTaskList中的索引
  */
-(int)addTask:(Task*) task atFirst:(BOOL) first
{
    if(NO==[self _taskExisted:task])
    {
        task.delegate = self;
        task.status = TASK_STATUS_READY;
        if(first)
        {
            [skinTaskList insertObject:task atIndex:0];
            return 0;
        }
        else
        {
            [skinTaskList addObject:task];
            return [skinTaskList count]-1;
        }
    }
    else
    {
        [self removeTaskId:task.taskId];
        
        task.delegate = self;
        task.status = TASK_STATUS_READY;
        
        [skinTaskList addObject:task];
        
        return [skinTaskList count]-1;
    }
}

/*!
  @brief 将本地存在的地图数据添加到下载队列中，并把状态置为完成
  @return 返回相对应的索引
  */
-(int)addLocalTask:(Task*)task atFirst:(BOOL) first
{
    if(NO==[self _taskExisted:task])//任务列表中无，则添加
    {
        task.delegate = self;
        task.status = TASK_STATUS_FINISH;
        if(first)
        {
            [skinTaskList insertObject:task atIndex:0];
            return 0;
        }
        else
        {
            [skinTaskList addObject:task];
            return [skinTaskList count]-1;
        }
    }
    else if(YES==[self _taskExisted:task] )
    {
        for (MWSkinDownloadTask *t in skinTaskList)
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
    if (indexRunning == index || index > (int)(skinTaskList.count -1)) {
        return NO;
    }
    else
    {
        // 先停止正在执行的任务
        if (indexRunning >= 0)
        {
            
            Task* t = [skinTaskList objectAtIndex:index];
            t.status = TASK_STATUS_READY;
            return YES;
            
        }
        
        
        Task* t = [skinTaskList objectAtIndex:index];
        t.status = TASK_STATUS_RUNNING;
        [t run];
        
        if (delegate && [delegate respondsToSelector:@selector(progress:current:total:)]) {
            [delegate progress:t current:t.current total:t.total];
        }
        
        return YES;
    }
}

/*!
  @brief 下载指定id的任务
  @return
  */
- (void)startWithTaskID:(int)taskID
{
    
    for (int i = 0; i < skinTaskList.count; i++) {
        Task *tmp = [skinTaskList objectAtIndex:i];
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
    int count = [skinTaskList count];
    if(index>=0 && index<count)
    {
        // 只有状态为TASK_STATUS_RUNNING的任务才能被stop
        Task* t = [skinTaskList objectAtIndex:index];
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
    
    for (int i = 0; i < skinTaskList.count; i++) {
        Task *tmp = [skinTaskList objectAtIndex:i];
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
    int count = [skinTaskList count];
    if(index>=0 && index<count)
    {
        
        Task* t = [skinTaskList objectAtIndex:index];
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
    int count = [skinTaskList count];
    
    for (int i = 0; i < count ; i++ ) {
        
        Task* t = [skinTaskList objectAtIndex:i];
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
    for (Task *task in skinTaskList) {
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
    
    Task *task = [self getTaskWithTaskID:taskID];
    
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
- (Task *)getTaskWithTaskID:(int)taskID
{
    for (Task *temp in skinTaskList) {
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
    int count = [skinTaskList count];
    if(index>=0 && index < count)
    {
        Task* t = [skinTaskList objectAtIndex:index];
        [t erase];
        [skinTaskList removeObjectAtIndex:index];
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
    int count = [skinTaskList count];
	for (int i = 0; i < count; i++)
	{
        Task* t = [skinTaskList objectAtIndex:i];
		if (taskId == t.taskId) {
			if (taskId == 0) {
				[t erase];
				[skinTaskList removeAllObjects];
			}
			else {
				[t erase];
				[skinTaskList removeObjectAtIndex:i];
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
    int count = [skinTaskList count];
    for (int i=0;i<count;i++) {
        if(((Task*)[skinTaskList objectAtIndex:i]).status == status)
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
-(BOOL)_taskExisted:(Task*)task
{
    for (Task* t in skinTaskList) {
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
    
	int count = [skinTaskList count];
    for (int i=0;i<count;i++) {
        Task* t = [skinTaskList objectAtIndex:i];
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
            for (MWSkinDownloadTask *task in skinTaskList) {
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

-(void)progress:(Task*)sender current:(long long)current total:(long long)total
{
    NSLog(@"%lld,%lld",current,total);
    
        if (delegate && [delegate respondsToSelector:@selector(progress:current:total:)]) {
            [delegate progress:sender current:current total:total];
        }
    
	
}

-(void)finished:(Task*)sender
{
	sender.status = TASK_STATUS_FINISH;
    
    [self start];
    
    if (delegate && [delegate respondsToSelector:@selector(finished:)]) {
        [delegate finished:sender];
    }
}

-(void)exception:(Task*)sender exception:(id)exception
{
    
    int exceptionCode = ((NSError *)exception).code;

    if (exceptionCode == DOWNLOADHANDLETYPE_UPZIPFAIL) {//解压失败，删除数据，重新下载
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_SkinCheckResult object:[NSNumber numberWithInt:5]];
        
        [self removeTaskId:sender.taskId];
        
        [self addTaskToList];
        [self skinNetWorkHandle:sender];
    }
    else if( exceptionCode == DOWNLOADHANDLETYPE_CURRENTLAGERTOTAL || exceptionCode == DOWNLOADHANDLETYPE_UPZIPFAIL || exceptionCode == DOWNLOADHANDLETYPE_CURRENTSMALLTOTAL  ){//下载失败
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_SkinCheckResult object:[NSNumber numberWithInt:4]];
        
        [self removeTaskId:sender.taskId];
        
        if (delegate && [delegate respondsToSelector:@selector(exception:exception:)]) {
            [delegate exception:sender exception:[NSNumber numberWithInt:exceptionCode]];
        }
    }
    
    else {
        [self skinNetWorkHandle:sender];
        
    }
    
    [self store];
    
}

- (void)unZipFinish:(Task*)sender
{
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_SkinCheckResult object:[NSNumber numberWithInt:1]];
    
    if (delegate && [delegate respondsToSelector:@selector(unZipFinish:)]) {
        [delegate unZipFinish:sender];
    }
    else if ([ANParamValue sharedInstance].isInit){
        
        double delayInSeconds = 0.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            // - 删 by fjs  皮肤下载解压完成后提示语句            
        });
        
    }
   
    if (sender) {
        NSString *skinVersion = [[GDSkinColor sharedInstance] getSkinVersion] ? [[GDSkinColor sharedInstance] getSkinVersion] : @"";
        
        [[MWSkinDownloadManager sharedInstance] setUpdateVersion:skinVersion];
    }
    
}

#pragma mark - url请求回调
//服务器成功应答
- (void)request:(NetRequestExt *)request didFinishLoadingWithData:(NSData *)data
{
    
    if (data && [data length])
    {
        char *szResult = (char *)[data bytes];

        NSString *tmp = [NSString stringWithFormat:@"%s",szResult];
        
        NSLog(@"皮肤请求结果：%@",tmp);
        
        NSString *result = [tmp CutFromNSString:@"<Result>" Tostring:@"</Result>"];
        if (RT_SkinDownload == request.requestCondition.requestType) {
            if ([result isEqualToString:@"SUCCESS"]) {//皮肤与当前软件版本匹配
                
                
                self.skinSize = [[tmp CutFromNSString:@"<Size>" Tostring:@"</Size>"] intValue];
                self.skinDownloadURL = [tmp CutFromNSString:@"<Url>" Tostring:@"</Url>"];
                if (self.skinDownloadURL && [self.skinDownloadURL length]) {
                    
                    [self addTaskToList];
                    
                    [self skinNetWorkHandle:nil];
                }
                else{
                    if (delegate && [delegate respondsToSelector:@selector(exception:exception:)]) {
                        [delegate exception:nil exception:[NSNumber numberWithInt:DOWNLOADHANDLETYPE_URLREQUESTFAIL]];//url请求失败
                    }
                }
                
            }
            else if ([result isEqualToString:@"FAIL"])
            {
                NSString *failString = [tmp CutFromNSString:@"<Error>" Tostring:@"</Error>"];
                if ([failString isEqualToString:@"ERROR_NO_MATCH"])
                {//皮肤与当前软件版本不匹配
                    self.skinSize = [[tmp CutFromNSString:@"<Size>" Tostring:@"</Size>"] intValue];
                    self.skinDownloadURL = [tmp CutFromNSString:@"<Url>" Tostring:@"</Url>"];
                    if (self.skinDownloadURL && [self.skinDownloadURL length]) {
                        
                        [self addTaskToList];
                        
                        [self skinNetWorkHandle:nil];
                    }
                    else{
                        if (delegate && [delegate respondsToSelector:@selector(exception:exception:)]) {
                            [delegate exception:nil exception:[NSNumber numberWithInt:DOWNLOADHANDLETYPE_URLREQUESTFAIL]];//url请求失败
                        }
                    }
                }
                else if ([failString isEqualToString:@"ERROR_SKIN_ID"])
                {//皮肤id不存在
                    if (delegate && [delegate respondsToSelector:@selector(exception:exception:)]) {
                        [delegate exception:nil exception:[NSNumber numberWithInt:DOWNLOADHANDLETYPE_NOSKINID]];
                    }
                }
                else
                {
                    if (delegate && [delegate respondsToSelector:@selector(exception:exception:)]) {
                        [delegate exception:nil exception:[NSNumber numberWithInt:DOWNLOADHANDLETYPE_URLREQUESTFAIL]];//url请求失败
                    }
                }
                
            }
        }
        else if(RT_SkinUpdate == request.requestCondition.requestType){
            if ([result isEqualToString:@"SUCCESS"]) {//皮肤与当前软件版本匹配

                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_SkinCheckResult object:[NSNumber numberWithInt:1]];
            }
            else if ([result isEqualToString:@"FAIL"])
            {
                NSString *failString = [tmp CutFromNSString:@"<Error>" Tostring:@"</Error>"];
                if ([failString isEqualToString:@"ERROR_NO_MATCH"])
                {//皮肤与当前软件版本不匹配
                    self.skinSize = [[tmp CutFromNSString:@"<Size>" Tostring:@"</Size>"] intValue];
                    self.skinDownloadURL = [tmp CutFromNSString:@"<Url>" Tostring:@"</Url>"];
                    if (self.skinDownloadURL && [self.skinDownloadURL length]) {
                        
                        [self addTaskToList];
                        
                        [self skinNetWorkHandle:nil];
                    }
                    else{
                        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_SkinCheckResult object:[NSNumber numberWithInt:2]];
                    }
                }
                else if ([failString isEqualToString:@"ERROR_SKIN_ID"])
                {//皮肤id不存在
                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_SkinCheckResult object:[NSNumber numberWithInt:2]];
                }
                else
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_SkinCheckResult object:[NSNumber numberWithInt:2]];
                }
                
            }
        }
        
        
    }
    else{
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_SkinCheckResult object:[NSNumber numberWithInt:2]];
        
        if (delegate && [delegate respondsToSelector:@selector(exception:exception:)]) {
            [delegate exception:nil exception:[NSNumber numberWithInt:DOWNLOADHANDLETYPE_URLREQUESTFAIL]];//url请求失败
        }
    }
}

- (void)request:(NetRequestExt *)request didFailWithError:(NSError *)error
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_SkinCheckResult object:[NSNumber numberWithInt:3]];
    
	if (delegate && [delegate respondsToSelector:@selector(exception:exception:)]) {
        [delegate exception:nil exception:[NSNumber numberWithInt:DOWNLOADHANDLETYPE_URLREQUESTFAIL]];//url请求失败
    }
    
}

@end

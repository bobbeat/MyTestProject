//
//  MWCloudDetourManage.m
//  AutoNavi
//
//  Created by longfeng.huang on 14-3-24.
//
//

#import "MWCloudDetourManage.h"
#import "MWCloudDetourTask.h"
#import "JSONKit.h"
#import "XMLDictionary.h"


#define kCloudDetourActivitycode @"0001"
#define kCloudDetourFilePrefix   @"avoidinfo_"
#define kCloudDetourActionCode   0
#define kCloudDetourProtversion  1

@interface MWCloudDetourManage ()
{
    
}

@property (nonatomic ,assign)    BOOL isUpdateCloudAvoidSuccess;

@end

@implementation MWCloudDetourManage

@synthesize delegate,cloudDetourTaskList,isUpdateCloudAvoidSuccess;

+ (instancetype)sharedInstance {
    
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        sharedInstance = [[self alloc] init];
        
        [sharedInstance restore];
    });
    
    return sharedInstance;
}

- (id)init
{
    if (self = [super init])
    {
        
        cloudDetourTaskList = [[NSMutableArray alloc] init];
        
    }
    return self;
}

/*!
  @brief 请求云端规避
  */
- (void)RequestCloudDetour
{
    
    if (isUpdateCloudAvoidSuccess) {
        return;
    }
    
    [self removeTasksForStatus:TASK_STATUS_BLOCK];
    [self removeTasksForStatus:TASK_STATUS_READY];
    [self removeTasksForStatus:TASK_STATUS_RUNNING];
    
    NSString *postSting = [self getXMLString];
    
    NSString *signString = [[NSString stringWithFormat:@"%@%d%@@%@",KNetChannelID,SOFTVERSIONCODE,MapVersionNoV,kNetSignKey] stringFromMD5];
    NSMutableDictionary *urlParams = [[NSMutableDictionary alloc] init];
    [urlParams setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@",kNetRequestStringBoundary] forKey:@"Content-Type"];
    [urlParams setValue:VendorID forKey:@"imei"];
    [urlParams setValue:[NSString stringWithFormat:@"%d",SOFTVERSIONCODE] forKey:@"apkversion"];
    [urlParams setValue:MapVersionNoV forKey:@"mapversion"];
    [urlParams setValue:deviceModel forKey:@"model"];
    [urlParams setValue:DeviceResolutionString forKey:@"resolution"];
    [urlParams setValue:CurrentSystemVersion forKey:@"os"];
    [urlParams setValue:UserID_Account forKey:@"userid"];
    [urlParams setValue:KNetChannelID forKey:@"syscode"];
    [urlParams setValue:PID forKey:@"pid"];
    [urlParams setValue:signString forKey:@"sign"];
    
    NetBaseRequestCondition *condition = [NetBaseRequestCondition requestCondition];
    
    condition.requestType = nil;
    condition.httpMethod = @"POST";
    condition.urlParams = nil;
    condition.baceURL = kCloudDetourURL;
    condition.bodyData = [postSting dataUsingEncoding:NSUTF8StringEncoding];
    condition.httpHeaderFieldParams = urlParams;
    
    [[NetExt sharedInstance] requestWithCondition:condition delegate:self];
    [urlParams release];
}


/*!
  @brief 把cloudDetourTaskList中的所有任务信息保存到文件系统，一般是在退出程序时调用
  @return 成功返回 YES 失败返回 NO
  */
-(BOOL)store
{
    /*
     1、序列化整个cloudDetourTaskList
     */
    
	NSString *Path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	NSString *filename = [Path stringByAppendingPathComponent:kCloudDetourPlist];
	if (![NSKeyedArchiver archiveRootObject:cloudDetourTaskList toFile:filename]){
		return NO;
	}
	else {
		return YES;
	}
    
}

/*!
  @brief 从文件系统还原通过save保存的所有任务信息，一般是在进入程序时调用，该方法调用将把cloudDetourTaskList中的所有任务更新为最后一次调用save保存的任务
  @return 成功返回 YES 失败返回 NO
  */
-(BOOL)restore
{
    /*
     1、反序列化各个Task对象，构建处cloudDetourTaskList
     2、遍历cloudDetourTaskList，把task.delegate = self;
     */
	
	NSString *Path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	NSString *filename = [Path stringByAppendingPathComponent:kCloudDetourPlist];
	NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithFile:filename];
	[cloudDetourTaskList removeAllObjects];
	[cloudDetourTaskList addObjectsFromArray:array];
	
    for (Task *task in cloudDetourTaskList) {
		task.delegate = self;
	}
    
	return YES;
	
}

#pragma mark - 下载管理


/*!
  @brief 添加任务到任务队列
  @return 返回-1表示加入失败，>=0表示成功加入后在carOwnerTaskList中的索引
  */
-(int)addTask:(MWCloudDetourTask*) task atFirst:(BOOL) first
{
    if(NO==[self _taskExisted:task])
    {
        task.delegate = self;
        task.status = TASK_STATUS_READY;
        if(first)
        {
            [cloudDetourTaskList insertObject:task atIndex:0];
            return 0;
        }
        else
        {
            [cloudDetourTaskList addObject:task];
            return [cloudDetourTaskList count]-1;
        }
    }
    else
    {
        
        task.current = 0;
        task.delegate = self;
        task.status = TASK_STATUS_READY;
        
        return [cloudDetourTaskList count]-1;
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
    if (indexRunning == index || index > (int)(cloudDetourTaskList.count -1)) {
        return NO;
    }
    else
    {
        // 先停止正在执行的任务
        if (indexRunning >= 0)
        {
            
            Task* t = [cloudDetourTaskList objectAtIndex:index];
            t.status = TASK_STATUS_READY;
            return YES;
            
        }
        
        
        Task* t = [cloudDetourTaskList objectAtIndex:index];
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
    
    for (int i = 0; i < cloudDetourTaskList.count; i++) {
        
        MWCloudDetourTask *tmp = [cloudDetourTaskList objectAtIndex:i];
        
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
    int count = [cloudDetourTaskList count];
    if(index>=0 && index<count)
    {
        // 只有状态为TASK_STATUS_RUNNING的任务才能被stop
        Task* t = [cloudDetourTaskList objectAtIndex:index];
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
    if (!taskID) {
        return NO;
    }
    
    BOOL res = NO;
    
    for (int i = 0; i < cloudDetourTaskList.count; i++) {
        
        MWCloudDetourTask *tmp = [cloudDetourTaskList objectAtIndex:i];
        
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
    int count = [cloudDetourTaskList count];
    if(index>=0 && index<count)
    {
        
        Task* t = [cloudDetourTaskList objectAtIndex:index];
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
    if (!taskID) {
        return NO;
    }
    
    int count = [cloudDetourTaskList count];
    
    for (int i = 0; i < count ; i++ ) {
        
        MWCloudDetourTask* t = [cloudDetourTaskList objectAtIndex:i];
        
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
    for (Task *task in cloudDetourTaskList) {
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
- (BOOL)isRunningWithTaskID:(NSString *)taskID
{
    BOOL res = NO;
    
    MWCloudDetourTask *task = [self getTaskWithTaskID:taskID];
    
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
- (MWCloudDetourTask *)getTaskWithTaskID:(int)taskID
{
    for (MWCloudDetourTask *temp in cloudDetourTaskList) {
        
        if (temp.taskId== taskID) {
            
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
    int count = [cloudDetourTaskList count];
    if(index>=0 && index < count)
    {
        Task* t = [cloudDetourTaskList objectAtIndex:index];
        [t erase];
        [cloudDetourTaskList removeObjectAtIndex:index];
        return  YES;
    }
    return NO;
}

/*!
  @brief 移除索引为index处的任务，该操作会删除该任务。如果恰好该任务处于运行状态，removeTaskId后，整个TaskManager中将无任务在执行
  @param taskId 任务ID
  @return 成功返回 YES 失败返回 NO
  */
-(BOOL)removeTaskId:(int) taskId
{
    int count = [cloudDetourTaskList count];
	for (int i = 0; i < count; i++)
	{
        MWCloudDetourTask* t = [cloudDetourTaskList objectAtIndex:i];
		if (t.taskId == taskId ) {
            
			
            [t erase];
            [cloudDetourTaskList removeObjectAtIndex:i];
			
			return YES;
		}
	}
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        [self store];
    });
    
    return NO;
}

/*!
  @brief  删除某一下载状态的任务
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
  @brief  删除某一状态的任务
  @return 返回删除个数
  */
-(int)removeTasksForServiceStatus:(int) status
{
    
    int count = 0;
    while (1) {
        int index = [self _firstIndexWithServiceStatus:status];
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
  @brief  移除所有任务
  */
- (void)removeAllTask
{
    for (MWCloudDetourTask *_task in cloudDetourTaskList) {
        [_task erase];
    }
    
    [cloudDetourTaskList removeAllObjects];
    
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
    int count = [cloudDetourTaskList count];
    for (int i=0;i<count;i++) {
        if(((MWCloudDetourTask*)[cloudDetourTaskList objectAtIndex:i]).status == status)
        {
            return i;
        }
    }
    return -1;
}

/*!
  @brief 返回队列中，状态为status的第一个任务的索引
  @param status 任务状态
  @return 返回指<0则表示没找到可被执行的任务，否则表示任务的索引
  */
-(int)_firstIndexWithServiceStatus:(int)status
{
    int count = [cloudDetourTaskList count];
    
    for (int i = 0 ; i < count ; i++)
    {
        if(((MWCloudDetourTask*)[cloudDetourTaskList objectAtIndex:i]).status == status)
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
-(BOOL)_taskExisted:(MWCloudDetourTask*)task
{
    for (MWCloudDetourTask * t in cloudDetourTaskList)
    {
    
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
    
	int count = [cloudDetourTaskList count];
    for (int i=0;i<count;i++) {
        Task* t = [cloudDetourTaskList objectAtIndex:i];
        if(t.status == TASK_STATUS_READY || t.status == TASK_STATUS_RUNNING)
        {
            size += (t.total - t.current);
        }
    }
    return size;
}


/*!
  @brief 从字典中解析任务
  @return 返回 任务
  */
- (MWCloudDetourTask *)getTaskFromDictionary:(NSDictionary *)dic
{
    if (!dic) {
        return nil;
    }
    
    MWCloudDetourTask *task = [[MWCloudDetourTask alloc] init];
    
    task.total = [[dic objectForKey:@"size"] intValue];
    task.url = [dic objectForKey:@"url"];
    task.md5 = [dic objectForKey:@"md5"];
    task.taskId =[[dic objectForKey:@"versioncode"] intValue];
    
    
    return [task autorelease];
}

/*!
  @brief 同步车主服务列表到本地
  @return
  */
- (BOOL)addCloudDetourFromNetToLocal:(NSData *)cloudDetourData
{
    
    NSDictionary *dialectDic = [NSDictionary dictionaryWithXMLData:cloudDetourData];
    
    id response = [dialectDic objectForKey:@"response"];
    
    id responCode = [response objectForKey:@"rspcode"];
    
    if (response &&  [responCode isEqualToString:@"0000"]  )
    {
        
        if ([[response objectForKey:@"update"] intValue] == 1) {
            id dialectArr = [response objectForKey:@"avoidinfo"];
            
            
            if (dialectArr && [dialectArr isKindOfClass:[NSDictionary class]]) {
                
                
                MWCloudDetourTask  *task = [self getTaskFromDictionary:dialectArr];
                
                task.delegate = self;
                
                if (task) {
                    
                    [self addTask:task atFirst:NO];
                    [self startWithTaskID:task.taskId];
                }
                
            }
        }
        else if ([[response objectForKey:@"update"] intValue] == 0)
        {
            isUpdateCloudAvoidSuccess = YES;
        }
        
    
    }
    
    return YES;
}



/*!
  @brief 从json字符串中获取对应语言的字符串
  @return 返回字符串
  */
- (NSString *)getStringFormJson:(NSString *)jsonString
{
    if (!jsonString) {
        return @"";
    }
    
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSDictionary *photo = [NSJSONSerialization
                           
                           JSONObjectWithData:data
                           
                           options:NSJSONReadingMutableLeaves
                           
                           error:nil];
    
    
    if (fontType == 0) {
        return [photo objectForKey:@"zw"] ? [photo objectForKey:@"zw"] : @"";
    }
    else if (fontType == 1){
        return [photo objectForKey:@"ft"] ? [photo objectForKey:@"ft"] : @"";
    }
    else if (fontType == 2){
        return [photo objectForKey:@"yw"] ? [photo objectForKey:@"yw"] : @"";
    }
    
    return @"";
}

/*!
  @brief 获取上传xml字符串
  @return 返回xml字符串
  */
- (NSString *)getXMLString
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYYMMddhhmmss"];
    NSString *dateString = [formatter stringFromDate: [NSDate date]];
    [formatter release];
    
    int language = 0;     //程序语言
    if (fontType == 0) {
        language = 0;
    }
    else if (fontType == 1)
    {
        language = 2;
    }
    else if (fontType == 2)
    {
        language = 1;
    }
    
    NSString *avoidVersion = [self getCloudDetourVersion];
    
    NSString *postXMLString = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?><opg><activitycode>%@</activitycode><processtime>%@</processtime><actioncode>%d</actioncode><protversion>%d</protversion><language>%d</language><svccont><map_version>%@</map_version><app_version>%@</app_version><engine_version>%@</engine_version><avoid_version>%@</avoid_version></svccont></opg>",kCloudDetourActivitycode,dateString,kCloudDetourActionCode,kCloudDetourProtversion,language,MapVersionNoV,[NSString stringWithFormat:@"%d",SOFTVERSIONCODE],GDEngineNOVVersion,avoidVersion];
    NSLog(@"云端避让xml：%@",postXMLString);
    return postXMLString;
}

/*!
  @brief 解析json数据
  @return 返回解析后的数据
  */
- (id)parseJSONData:(NSData *)data error:(NSError **)error
{
    NSError *parseError = nil;
	id result =[data objectFromJSONDataWithParseOptions:JKParseOptionStrict error:&parseError];
	
	if (parseError && (error != nil))
    {
        *error = parseError;
	}
	
	return result;
}

/*!
  @brief 获取避让文件版本号
  */
- (NSString *)getCloudDetourVersion
{
    NSString *string = @"new";
    
    NSArray *files = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:CloudDetour_path error:nil];
    
    for (NSString *fileName in files)
    {
        NSRange range = [fileName rangeOfString:kCloudDetourFilePrefix options:NSCaseInsensitiveSearch];
        if (range.length != 0 && cloudDetourTaskList.count > 0)
        {
            NSString *_mString = [fileName CutToNSStringBackWard:@"_"];
            if (_mString) {
                string = [fileName CutFromNSString:_mString Tostring:@"."];
            }
            
            
            break;
        }
    }
    
    return string;
}

/*!
  @brief 更新云端避让文件
  */
- (void)updateCloudAvoidPath
{
    
    NSArray *files = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:CloudDetour_path error:nil];
    
    BOOL isExistFile = NO;
    
    for (NSString *fileName in files)
    {
        NSRange range = [fileName rangeOfString:kCloudDetourFilePrefix options:NSCaseInsensitiveSearch];
        if (range.length != 0 && ![fileName hasSuffix:@".tmp"] && ![fileName hasSuffix:@".zip"])
        {
            isExistFile = YES;
            
            NSString *detourFilePath = [NSString stringWithFormat:@"%@%@",CloudDetour_path,fileName];
            [MWRouteDetour UpdateCloudAvoidInfo:detourFilePath];
            
            //add by hlf for 数据升级造成的避让文件不兼容处理 at 2014.10.30 获取避让道路所在的城市，对比城市版本号是否一样，不一样则调用数据升级接口升级
            GDETOURROADCITYINFO *detourRoadCityInfo = {0};
            int numberCity = 0;
            
            GSTATUS res = [MWRouteDetour GetDetourRoadCityInfo:NSStringToGchar(detourFilePath) ppCityInfos:&detourRoadCityInfo pnNumberOfCity:&numberCity];
            if (res == GD_ERR_OK) {
                
                for (int i = 0; i < numberCity; i ++ ) {
                    
                    NSString *version = [MWEngineTools GetMapCityVersionNoV:detourRoadCityInfo[i].stAdcode.nAdCode];
                    NSString *bigVersion = [version CutToNSString:@"."];
                    NSString *SmallVersion = [version CutNSStringFromBackWard:@"."];
                    
                    if (bigVersion && SmallVersion && bigVersion.length > 0 && SmallVersion.length > 0 && ([bigVersion intValue] != detourRoadCityInfo[i].stVersion.nData1 || [SmallVersion intValue] != detourRoadCityInfo[i].stVersion.nData2)) {
                        
                        GADMINCODE adminCode = {0};
                        adminCode.euRegionCode = eREGION_CODE_CHN;
                        adminCode.nAdCode = detourRoadCityInfo[i].stAdcode.nAdCode;
                        
                        enumDBTYPE type = eDB_TYPE_ALL;
                        
                        [MWEngineTools UpdateCityDBFinished:&adminCode type:type];
                        
                    }
                }
            }
            
            break;
        }
        
    }
}
#pragma mark - 下载委托回调

/*!
  @brief 数据下载进度回调
  */
-(void)progress:(MWCloudDetourTask*)sender current:(long long)current total:(long long)total
{
    NSLog(@"%lld,%lld",current,total);
    
    if (delegate && [delegate respondsToSelector:@selector(progress:current:total:)]) {
        [delegate progress:sender current:current total:total];
    }
    
	
}

/*!
  @brief 数据下载完成回调
  */
-(void)finished:(MWCloudDetourTask*)sender
{
    
	sender.status = TASK_STATUS_FINISH;
    
    if (delegate && [delegate respondsToSelector:@selector(finished:)]) {
        [delegate finished:sender];
    }
}

/*!
  @brief 数据下载异常回调
  */
-(void)exception:(MWCloudDetourTask*)sender exception:(id)exception
{
    
    
}

/*!
  @brief 数据解压完成回调
  */
- (void)unZipFinish:(MWCloudDetourTask*)sender
{
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        
        if (cloudDetourTaskList.count == 2) {
            [self removeTask:0];
        }
        [self store];
        
        [self updateCloudAvoidPath];
        
        isUpdateCloudAvoidSuccess = YES;
    });
    
}

#pragma mark - url请求回调
/*!
  @brief 请求应答成功回调
  */
- (void)request:(NetRequestExt *)request didFinishLoadingWithData:(NSData *)data
{
    
    if (data && [data length])
    {
        NSString *tmp = [[[NSString alloc ] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
        
        NSLog(@"云端避让请求结果：%@",tmp);
                
        [self addCloudDetourFromNetToLocal:data];
        
    }
    else{
        
       
    }
}

/*!
  @brief 请求失败回调
  */
- (void)request:(NetRequestExt *)request didFailWithError:(NSError *)error
{
    
    NSLog(@"cloudDetourFail");
}

@end

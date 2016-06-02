//
//  MWCarOwnerServiceManage.m
//  AutoNavi
//
//  Created by longfeng.huang on 14-2-27.
//
//

#import "MWCarOwnerServiceManage.h"
#import "plugin-cdm-Task.h"
#import "GDStatusBarOverlay.h"
#import "XMLDictionary.h"
#import "MWMapOperator.h"
#import "NSString+Category.h"
#import "JSONKit.h"

#define kCarOwnerServiceUnZipType              @".zip"
#define kCarOwnerServiceActivityCodeList       @"0004"
#define kCarOwnerServiceActivityCodeMore       @"0005"
#define kCarOwnerServiceActivityCodeDetail     @"0002"
#define kCarOwnerServiceIcon                   @"/icon/icon.png"

@interface MWCarOwnerServiceManage ()
{
    
}

@property (nonatomic ,assign)  BOOL isMore;
@property (nonatomic ,retain)  MWCarOwnerServiceTask *detailCarServiceTask;

@end

static MWCarOwnerServiceManage *instance;

@implementation MWCarOwnerServiceManage

@synthesize carOwnerTaskList,carOwnerMoreTaskList,delegate,isMore,detailCarServiceTask,reqDelegare;

+ (MWCarOwnerServiceManage *)sharedInstance
{
    if (instance == nil) {
        instance = [[MWCarOwnerServiceManage alloc] init];
        [instance restore];
    }
    return instance;
}

- (id)init
{
    if (self = [super init]) {
        
        carOwnerTaskList = [[NSMutableArray alloc] init];
        carOwnerMoreTaskList  = [[NSMutableArray alloc] init];
        detailCarServiceTask = [[MWCarOwnerServiceTask alloc] init];
    }
    return self;
}

/*!
  @brief 请求车主服务列表
  */
- (void)RequestCarOwnerService
{
    self.isMore = NO;
    
    [self removeVipTask];
   
    NSString *body = [self getPostXMLStringWithRequestTyep:RT_CarOwnerServiceRequest Task:nil];
    
    
    NSString *signString = [[NSString stringWithFormat:@"%@%@%d@%@",KNetChannelID,[NSString stringWithFormat:@"%f",IOS_VERSION],SOFTVERSIONCODE,kNetSignKey] stringFromMD5];
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
    
    condition.requestType = RT_CarOwnerServiceRequest;
    condition.httpMethod = @"POST";
    condition.urlParams = nil;
    condition.baceURL = kCarOwnerServiceURL;
    condition.bodyData = [body dataUsingEncoding:NSUTF8StringEncoding];
    condition.httpHeaderFieldParams = urlParams;
    
    [[NetExt sharedInstance] requestWithCondition:condition delegate:self];
    [urlParams release];
}

/*!
  @brief 请求车主服务列表(更多)
  */
- (void)RequestMoreCarOwnerService
{
    
	NSString *body = [self getPostXMLStringWithRequestTyep:RT_CarOwnerServiceUnInstallRequest Task:nil];
    
    
    NSString *signString = [[NSString stringWithFormat:@"%@%@%d@%@",KNetChannelID,[NSString stringWithFormat:@"%f",IOS_VERSION],SOFTVERSIONCODE,kNetSignKey] stringFromMD5];
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
    
    condition.requestType = RT_CarOwnerServiceUnInstallRequest;
    condition.httpMethod = @"POST";
    condition.urlParams = nil;
    condition.baceURL = kCarOwnerServiceURL;
    condition.bodyData = [body dataUsingEncoding:NSUTF8StringEncoding];
    condition.httpHeaderFieldParams = urlParams;
    
    [[NetExt sharedInstance] requestWithCondition:condition delegate:self];
    [urlParams release];
    
}

/*!
  @brief 请求车主服务列表(详情)
  */
- (void)RequestCarOwnerServiceDetail:(MWCarOwnerServiceTask *)task
{
    if (!task) {
        return;
    }
    
	NSString *body = [self getPostXMLStringWithRequestTyep:RT_CarOwnerServiceDetailRequest Task:task];
    
    
    NSString *signString = [[NSString stringWithFormat:@"%@%@@%@",KNetChannelID,task.serviceID,kNetSignKey] stringFromMD5];
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
    
    condition.requestType = RT_CarOwnerServiceDetailRequest;
    condition.httpMethod = @"POST";
    condition.urlParams = nil;
    condition.baceURL = kCarOwnerServiceURL;
    condition.bodyData = [body dataUsingEncoding:NSUTF8StringEncoding];
    condition.httpHeaderFieldParams = urlParams;
    
    [[NetExt sharedInstance] requestWithCondition:condition delegate:self];
    [urlParams release];
    
}

/*!
  @brief 把carOwnerTaskList中的所有任务信息保存到文件系统，一般是在退出程序时调用
  @return 成功返回 YES 失败返回 NO
  */
-(BOOL)store
{
    /*
     1、序列化整个carOwnerTaskList
     */
    
	NSString *Path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	NSString *filename = [Path stringByAppendingPathComponent:kCarOwnerServicePlist];
	if (![NSKeyedArchiver archiveRootObject:carOwnerTaskList toFile:filename]){
		return NO;
	}
	else {
		return YES;
	}
    
}

/*!
  @brief 从文件系统还原通过save保存的所有任务信息，一般是在进入程序时调用，该方法调用将把carOwnerTaskList中的所有任务更新为最后一次调用save保存的任务
  @return 成功返回 YES 失败返回 NO
  */
-(BOOL)restore
{
    /*
     1、反序列化各个Task对象，构建处carOwnerTaskList
     2、遍历carOwnerTaskList，把task.delegate = self;
     */
	
	NSString *Path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	NSString *filename = [Path stringByAppendingPathComponent:kCarOwnerServicePlist];
	NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithFile:filename];
	[carOwnerTaskList removeAllObjects];
	[carOwnerTaskList addObjectsFromArray:array];
	
    for (Task *task in carOwnerTaskList) {
		task.delegate = self;
	}
    
    [self unZipFileInPath:CarOwnerService_path MatchContent:kCarOwnerServiceUnZipType];
	return YES;
	
}

#pragma mark - 下载管理


/*!
  @brief 添加任务到任务队列
  @return 返回-1表示加入失败，>=0表示成功加入后在carOwnerTaskList中的索引
  */
-(int)addTask:(MWCarOwnerServiceTask*) task atFirst:(BOOL) first
{
    if(NO==[self _taskExisted:task])
    {
        task.delegate = self;
        task.status = TASK_STATUS_READY;
        if(first)
        {
            [carOwnerTaskList insertObject:task atIndex:0];
            return 0;
        }
        else
        {
            [carOwnerTaskList addObject:task];
            return [carOwnerTaskList count]-1;
        }
    }
    else
    {
        
        task.current = 0;
        task.delegate = self;
        task.status = TASK_STATUS_READY;
    
        return [carOwnerTaskList count]-1;
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
    if (indexRunning == index || index > (int)(carOwnerTaskList.count -1)) {
        return NO;
    }
    else
    {
        // 先停止正在执行的任务
        if (indexRunning >= 0)
        {
            
            Task* t = [carOwnerTaskList objectAtIndex:index];
            t.status = TASK_STATUS_READY;
            return YES;
            
        }
        
        
        Task* t = [carOwnerTaskList objectAtIndex:index];
        t.status = TASK_STATUS_RUNNING;
        [t run];
        
        if (delegate && [delegate respondsToSelector:@selector(progress:current:total:)]) {
            [delegate progress:t current:0 total:0];
        }
        
        return YES;
    }
}

/*!
  @brief 下载指定id的任务
  @return
  */
- (void)startWithTaskID:(NSString *)taskID
{
    if (!taskID) {
        return;
    }
    
    for (int i = 0; i < carOwnerTaskList.count; i++) {
        
        MWCarOwnerServiceTask *tmp = [carOwnerTaskList objectAtIndex:i];
        
        if ([tmp.serviceID isEqualToString:taskID]) {
            
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
    int count = [carOwnerTaskList count];
    if(index>=0 && index<count)
    {
        // 只有状态为TASK_STATUS_RUNNING的任务才能被stop
        Task* t = [carOwnerTaskList objectAtIndex:index];
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
- (BOOL)stopWithTaskID:(NSString *)taskID
{
    if (!taskID) {
        return NO;
    }
    
    BOOL res = NO;
    
    for (int i = 0; i < carOwnerTaskList.count; i++) {
        
        MWCarOwnerServiceTask *tmp = [carOwnerTaskList objectAtIndex:i];
        
        if ([tmp.serviceID isEqualToString:taskID]) {
            
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
    int count = [carOwnerTaskList count];
    if(index>=0 && index<count)
    {
        
        Task* t = [carOwnerTaskList objectAtIndex:index];
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
- (BOOL)stopWithOutOtherStartWithTaskID:(NSString *)taskID
{
    if (!taskID) {
        return NO;
    }
    
    int count = [carOwnerTaskList count];
    
    for (int i = 0; i < count ; i++ ) {
        
        MWCarOwnerServiceTask* t = [carOwnerTaskList objectAtIndex:i];
        
        if([t.serviceID isEqualToString:taskID])
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
    for (Task *task in carOwnerTaskList) {
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
    
    MWCarOwnerServiceTask *task = [self getTaskWithTaskID:taskID];
    
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
- (MWCarOwnerServiceTask *)getTaskWithTaskID:(NSString *)taskID
{
    for (MWCarOwnerServiceTask *temp in carOwnerTaskList) {
        
        if ([temp.serviceID isEqualToString:taskID]) {
            
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
    int count = [carOwnerTaskList count];
    if(index>=0 && index < count)
    {
        Task* t = [carOwnerTaskList objectAtIndex:index];
        [t erase];
        [carOwnerTaskList removeObjectAtIndex:index];
        return  YES;
    }
    return NO;
}

/*!
  @brief 移除索引为index处的任务，该操作会删除该任务。如果恰好该任务处于运行状态，removeTaskId后，整个TaskManager中将无任务在执行
  @param taskId 任务ID
  @return 成功返回 YES 失败返回 NO
  */
-(BOOL)removeTaskId:(NSString *) taskId
{
    int count = [carOwnerTaskList count];
	for (int i = 0; i < count; i++)
	{
        MWCarOwnerServiceTask* t = [carOwnerTaskList objectAtIndex:i];
		if ([t.serviceID isEqualToString:taskId]) {
            
			
            [t erase];
            [carOwnerTaskList removeObjectAtIndex:i];
			
			return YES;
		}
	}
    
    dispatch_async(dispatch_get_main_queue(), ^{
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
  @brief  删除推荐列表，检测已安装任务的安装包如果不存在则删除任务
  */
-(void)removeVipTask
{
    
    [self removeTasksForServiceStatus:1];
    [self removeTasksForServiceStatus:2];
    
    NSMutableArray *removeTask = [[NSMutableArray alloc] init];
    for (MWCarOwnerServiceTask *task in carOwnerTaskList) {
        if (task.serviceStatus == 3 || task.serviceStatus == 4 || task.serviceStatus == 5 || task.serviceStatus == 6 || task.serviceStatus == 7) {
            task.serviceStatus = 0;
        }
        if (task.serviceStatus == 0 && ![[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@%@",CarOwnerService_path,task.serviceID]]) {
            
            [removeTask addObject:task];
        }
    }
    
    if (removeTask.count > 0) {
        [carOwnerTaskList removeObjectsInArray:removeTask];
    }
    
    [removeTask release];
    
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
    int count = [carOwnerTaskList count];
    for (int i=0;i<count;i++) {
        if(((MWCarOwnerServiceTask*)[carOwnerTaskList objectAtIndex:i]).status == status)
        {
            return i;
        }
    }
    return -1;
}

/*!
  @brief 返回队列中，状态为serviceStatus的第一个任务的索引
  @param serviceStatus 任务状态
  @return 返回指<0则表示没找到可被执行的任务，否则表示任务的索引
  */
-(int)_firstIndexWithServiceStatus:(int)serviceStatus
{
    int count = [carOwnerTaskList count];
    for (int i=0;i<count;i++) {
        if(((MWCarOwnerServiceTask*)[carOwnerTaskList objectAtIndex:i]).serviceStatus == serviceStatus)
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
-(BOOL)_taskExisted:(MWCarOwnerServiceTask*)task
{
    for (MWCarOwnerServiceTask* t in carOwnerTaskList) {
        // 用任务id来比较
        if([t.serviceID isEqualToString:task.serviceID])
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
    
	int count = [carOwnerTaskList count];
    for (int i=0;i<count;i++) {
        Task* t = [carOwnerTaskList objectAtIndex:i];
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
            for (MWCarOwnerServiceTask *task in carOwnerTaskList) {
                if ([fileName hasSuffix:[task getFilename]]) {
                    [task checkZipFileAndUnZipFile];
                    return YES;
                }
            }
        }
        
    }
    return NO;
}

/*!
  @brief 从字典中解析任务
  @return 返回 任务
  */
- (MWCarOwnerServiceTask *)getTaskFromDictionary:(NSDictionary *)dic
{
    if (!dic) {
        return nil;
    }
    
    MWCarOwnerServiceTask *task = [[MWCarOwnerServiceTask alloc] init];
    
    task.serviceID = [dic objectForKey:@"serviceid"] ? [dic objectForKey:@"serviceid"] : @"";
    task.versionCode = [dic objectForKey:@"versioncode"];
    task.versionName = [dic objectForKey:@"versionname"];
    task.title = [dic objectForKey:@"title"];
    task.vendor = [dic objectForKey:@"vendor"];
    task.total = [[dic objectForKey:@"size"] intValue];
    task.warning = [dic objectForKey:@"warning"];
    task.updatedesc = [dic objectForKey:@"updatedesc"];
    task.releasetime = [dic objectForKey:@"releasetime"];
    task.form = [[dic objectForKey:@"form"] intValue];
    task.serviceStatus = [[dic objectForKey:@"status"] intValue];
    task.iconUrl = [dic objectForKey:@"iconurl"];
    task.url = [dic objectForKey:@"url"];
    task.vip = [dic objectForKey:@"vip"] ? [[dic objectForKey:@"vip"] intValue] : 0;
    task.md5 = [dic objectForKey:@"md5"];
    task.description = [dic objectForKey:@"description"];
    task.usedesc = [dic objectForKey:@"usedesc"];
    task.servicedesc = [dic objectForKey:@"servicedesc"];
    task.current = 0;
    task.status = 5;
    
    
    return [task autorelease];
}

/*!
  @brief 同步车主服务列表到本地
  @return
  */
- (BOOL)addCarOwnerServiceListFromNetToLocal:(NSData *)carOwnerData
{
    
    NSDictionary *dialectDic = [NSDictionary dictionaryWithXMLData:carOwnerData];
    
    if ([[[[dialectDic objectForKey:@"response"] objectForKey:@"service"] objectForKey:@"more"] intValue] > 0) {
        self.isMore = YES;
    }
    else{
        self.isMore = NO;
    }
    
    id dialectArr = [[[dialectDic objectForKey:@"response"] objectForKey:@"service"] objectForKey:@"item"];
    
    
    if ([dialectArr isKindOfClass:[NSDictionary class]]) {
        
        
        MWCarOwnerServiceTask *task = [self getTaskFromDictionary:dialectArr];
        
        task.delegate = self;
        
        if (task) {
            
            MWCarOwnerServiceTask *_task = [self getTaskWithTaskID:task.serviceID];
            
            if (_task) {
                
                _task.serviceID = task.serviceID;
                _task.versionCode = task.versionCode;
                _task.versionName = task.versionName;
                _task.title = task.title;
                _task.vendor = task.vendor;
                _task.total = task.total;
                _task.warning = task.warning;
                _task.updatedesc = task.updatedesc;
                _task.releasetime = task.releasetime;
                _task.form = task.form;
                _task.serviceStatus = task.serviceStatus;
                _task.iconUrl = task.iconUrl;
                _task.url = task.url;
                _task.vip =  task.vip;
                _task.md5 = task.md5;
                _task.current = task.current;
                _task.status = task.status;
                _task.servicedesc = task.servicedesc;
                _task.delegate = self;
                
            }
            else{
                
                if (carOwnerTaskList.count == 0) {
                    
                    [carOwnerTaskList addObject:task];
                }
                else{
                    
                    [carOwnerTaskList insertObject:task atIndex:0];
                }
                
            }
            
        }
        
        
    }
    else if ([dialectArr isKindOfClass:[NSArray class]]){
        
        int insertIndex = 0;
        for (NSDictionary *dic in dialectArr) {
            
            MWCarOwnerServiceTask *task = [self getTaskFromDictionary:dic];
            
            task.delegate = self;
            
            if (task) {
                MWCarOwnerServiceTask *_task = [self getTaskWithTaskID:task.serviceID];
                
                if (_task) {
                    
                    
                    _task.serviceID = task.serviceID;
                    _task.versionCode = task.versionCode;
                    _task.versionName = task.versionName;
                    _task.title = task.title;
                    _task.vendor = task.vendor;
                    _task.total = task.total;
                    _task.warning = task.warning;
                    _task.updatedesc = task.updatedesc;
                    _task.releasetime = task.releasetime;
                    _task.form = task.form;
                    _task.serviceStatus = task.serviceStatus;
                    _task.iconUrl = task.iconUrl;
                    _task.url = task.url;
                    _task.vip =  task.vip;
                    _task.md5 = task.md5;
                    _task.current = task.current;
                    _task.status = task.status;
                    _task.servicedesc = task.servicedesc;
                    _task.delegate = self;
                    
                }
                else{
                    
                    if (insertIndex < carOwnerTaskList.count ) {
                        
                        [carOwnerTaskList insertObject:task atIndex:insertIndex];
                        
                    }
                    else{
                        
                        [carOwnerTaskList addObject:task];
                    }
                    
                    insertIndex ++;
                    
                    
                }
                
                
            }
            
        }
    }
    
    
    return YES;
}

/*!
  @brief 同步车主服务列表(更多)到本地
  @return
  */
- (BOOL)addMoreCarOwnerServiceListFromNetToLocal:(NSData *)carOwnerData
{
    NSDictionary *dialectDic = [NSDictionary dictionaryWithXMLData:carOwnerData];
    
    id dialectArr = [[[dialectDic objectForKey:@"response"] objectForKey:@"service"] objectForKey:@"item"];
    
    [carOwnerMoreTaskList removeAllObjects];
    
    if ([dialectArr isKindOfClass:[NSDictionary class]]) {
        
        
        MWCarOwnerServiceTask *task = [self getTaskFromDictionary:dialectArr];
        
        if (task) {
            
            
            [carOwnerMoreTaskList addObject:task];
        }
        
        
    }
    else if ([dialectArr isKindOfClass:[NSArray class]]){
        
        
        for (NSDictionary *dic in dialectArr) {
            
            MWCarOwnerServiceTask *task = [self getTaskFromDictionary:dic];
            
            if (task) {
                [carOwnerMoreTaskList addObject:task];
            }
        }
    }
    
    if (carOwnerMoreTaskList.count == 0) {
        self.isMore = NO;
    }
    return YES;
}

/*!
  @brief 解析服务详情
  @return
  */
- (BOOL)addDetailCarOwnerService:(NSData *)carOwnerData
{
    NSDictionary *dialectDic = [NSDictionary dictionaryWithXMLData:carOwnerData];
    
    id dialectArr = [[dialectDic objectForKey:@"response"] objectForKey:@"service"];
    
    
    if ([dialectArr isKindOfClass:[NSDictionary class]]) {
        
        
        self.detailCarServiceTask = [self getTaskFromDictionary:dialectArr];
        
        
    }
    else if ([dialectArr isKindOfClass:[NSArray class]]){
        
        
        for (NSDictionary *dic in dialectArr) {
            
            self.detailCarServiceTask = [self getTaskFromDictionary:dic];
            
        }
    }
    
    
    return YES;
}

/*!
  @brief 获取服务详情
  @return
  */
- (MWCarOwnerServiceTask *)getDetailCarOwnerServiceTask
{
    return self.detailCarServiceTask;
}

/*!
  @brief 安装服务后进行排序（推荐的服务放到已安装服务的最前面，普通服务放到已安装服务的最后面）
  @return 成功返回 YES 失败返回 NO
  */
- (BOOL) installFinishSort:(MWCarOwnerServiceTask *)task
{
    if (!task) {
        return NO;
    }
    
    MWCarOwnerServiceTask *obj = [self getTaskWithTaskID:task.serviceID];
    
    if (!obj) {
        return NO;
    }
    
    if (task.vip == 1) {
        
        [obj retain];
        
        int installIndex = -1;
        for (int i = 0; i < carOwnerTaskList.count ; i++) {
            MWCarOwnerServiceTask *_task = [carOwnerTaskList objectAtIndex:i];
            if (_task.serviceStatus == 0 || _task.serviceStatus == 3 || _task.serviceStatus == 4 || _task.serviceStatus == 5 || _task.serviceStatus == 6 || _task.serviceStatus == 7) {
                installIndex = i;
                break;
            }
        }
        
        int count = [carOwnerTaskList count];
        for (int i = 0; i < count; i++)
        {
            MWCarOwnerServiceTask* t = [carOwnerTaskList objectAtIndex:i];
            if ([t.serviceID isEqualToString:task.serviceID]) {
                
                [carOwnerTaskList removeObjectAtIndex:i];
                
                break;
            }
        }

        
        if (installIndex >= 0 ) {
            
            if (installIndex == 0) {
                [carOwnerTaskList insertObject:obj atIndex:installIndex];
            }
            else{
                [carOwnerTaskList insertObject:obj atIndex:(installIndex-1)];
            }
        
        }
        else{
            [carOwnerTaskList addObject:obj];
        }
        
        [obj release];
    }
    else {
        return NO;
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
  @brief 是否有更多服务列表
  @return
  */
- (BOOL)isMore
{
    return isMore;
}

/*!
  @brief 组装请求xml
  @return 返回相对应请求类型的xml
  */
- (NSString *)getPostXMLStringWithRequestTyep:(RequestType)requestType Task:(MWCarOwnerServiceTask *)requestTask
{
    NSString *xmlString = @"";
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYYMMddhhmmss"];
    NSString *dateString = [formatter stringFromDate: [NSDate date]];
    [formatter release];
    
    int actionCode = 0;   //0:请求 1:应答
    int protversion = 2;  //协议版本号大于1时不下发主题类型插件
    int pluginxmlv = 1;   //服务协议版本号
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
    
    int adminCode = [MWAdminCode GetCurAdminCode]; //行政编码
    
    GCARINFO carInfo = {0};
    [[MWMapOperator sharedInstance] GMD_GetCarInfo:&carInfo];
    
    if (RT_CarOwnerServiceRequest == requestType) {
        
        NSMutableString *itemString = [[[NSMutableString alloc] init] autorelease];
        
        for (MWCarOwnerServiceTask *task in carOwnerTaskList) {
            if (task.serviceStatus == 0 || task.serviceStatus == 3 || task.serviceStatus == 4 || task.serviceStatus == 5 || task.serviceStatus == 6 || task.serviceStatus == 7) {
                NSString *versionCode = @"1";
                NSDictionary *installDic = [self getInstallCarOwnerServiceInfoWithTaskID:task.serviceID];
                if (installDic) {
                    versionCode = [installDic objectForKey:@"version-code"];
                }
                [itemString appendFormat:@"<item><serviceid>%@</serviceid><versioncode>%@</versioncode><installtime>%@</installtime></item>",task.serviceID,versionCode,task.installTime];
            }
        }
        
        xmlString = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\" ?><opg><activitycode>%@</activitycode><processtime>%@</processtime><actioncode>%d</actioncode><protversion>%d</protversion><language>%d</language><svccont><adcode>%d</adcode><x>%d</x><y>%d</y><service>%@</service><osversion>%@</osversion><hostversion>%@</hostversion><pluginxmlv>%d</pluginxmlv></svccont></opg>",kCarOwnerServiceActivityCodeList,dateString,actionCode,protversion,language,adminCode,carInfo.Coord.x,carInfo.Coord.y,itemString,[NSString stringWithFormat:@"%f",IOS_VERSION],[NSString stringWithFormat:@"%d",SOFTVERSIONCODE],pluginxmlv];
    }
    else if (RT_CarOwnerServiceUnInstallRequest == requestType)
    {
        NSMutableString *itemString = [[[NSMutableString alloc] init] autorelease];
        
        for (MWCarOwnerServiceTask *task in carOwnerTaskList) {
            if (task.serviceStatus == 0 || task.serviceStatus == 3 || task.serviceStatus == 4 || task.serviceStatus == 5 || task.serviceStatus == 6 || task.serviceStatus == 7) {
                [itemString appendFormat:@"<item><serviceid>%@</serviceid></item>",task.serviceID];
            }
        }
        
        xmlString = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\" ?><opg><activitycode>%@</activitycode><processtime>%@</processtime><actioncode>%d</actioncode><protversion>%d</protversion><language>%d</language><svccont><adcode>%d</adcode><x>%d</x><y>%d</y><service>%@</service><osversion>%@</osversion><hostversion>%@</hostversion><pluginxmlv>%d</pluginxmlv><page>%d</page><size>%d</size></svccont></opg>",kCarOwnerServiceActivityCodeMore,dateString,actionCode,protversion,language,adminCode,carInfo.Coord.x,carInfo.Coord.y,itemString,[NSString stringWithFormat:@"%f",IOS_VERSION],[NSString stringWithFormat:@"%d",SOFTVERSIONCODE],pluginxmlv,1,20];
    }
    else if (RT_CarOwnerServiceDetailRequest == requestType)
    {
        xmlString = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"UTF-8\" ?> <opg><activitycode>%@</activitycode> <processtime>%@</processtime><actioncode>%d</actioncode><protversion>%d</protversion><language>%d</language><svccont><serviceid>%@</serviceid><versioncode>%@</versioncode><hostversion>%@</hostversion><osversion>%@</osversion><pluginxmlv>%d</pluginxmlv><adcode>%d</adcode></svccont></opg>",kCarOwnerServiceActivityCodeDetail,dateString,actionCode,protversion,language,requestTask.serviceID,requestTask.versionCode,[NSString stringWithFormat:@"%d",SOFTVERSIONCODE],[NSString stringWithFormat:@"%f",IOS_VERSION],pluginxmlv,adminCode];
    }
    return xmlString;
}

/*!
  @brief 服务置顶
  @return 成功返回 YES 失败返回 NO
  */
- (BOOL)moveTaskToTopWithTaskID:(NSString *)taskID
{
    if (!taskID) {
        return NO;
    }
    
    MWCarOwnerServiceTask *obj = [self getTaskWithTaskID:taskID];
    
    if (!obj) {
        return NO;
    }
    
    [obj retain];
    
        
    int installIndex = -1;
    for (int i = 0; i < carOwnerTaskList.count ; i++) {
        MWCarOwnerServiceTask *_task = [carOwnerTaskList objectAtIndex:i];
        if (_task.serviceStatus == 0 || _task.serviceStatus == 3 || _task.serviceStatus == 4 || _task.serviceStatus == 5 || _task.serviceStatus == 6 || _task.serviceStatus == 7) {
            installIndex = i;
            break;
        }
    }
    
    
    int count = [carOwnerTaskList count];
	for (int i = 0; i < count; i++)
	{
        MWCarOwnerServiceTask* t = [carOwnerTaskList objectAtIndex:i];
		if ([t.serviceID isEqualToString:taskID]) {
			
            [carOwnerTaskList removeObjectAtIndex:i];
			
			break;
		}
	}
    
    if (installIndex >= 0 ) {
        
        if (installIndex >= carOwnerTaskList.count) {
            
            [carOwnerTaskList addObject:obj];
        }
        else{
            
            [carOwnerTaskList insertObject:obj atIndex:installIndex];
        }
        
    }
    else{
        [carOwnerTaskList addObject:obj];
    }
    
    [obj release];
    
    return YES;
}

/*!
  @brief 获取安装服务图标
  */
- (UIImage *)getInstallCarOwnerServiceIconWithTaskID:(NSString *)serviceID
{
    NSString *dictionaryPath = [NSString stringWithFormat:@"%@/%@/%@",CarOwnerService_path,serviceID,kCarOwnerServiceIcon];
    UIImage *iconImage = [[UIImage alloc] initWithContentsOfFile:dictionaryPath];
    return [iconImage autorelease];
}

/*!
  @brief 获取安装服务信息
  */
- (NSDictionary *)getInstallCarOwnerServiceInfoWithTaskID:(NSString *)serviceID
{
    NSString *dictionaryPath = [NSString stringWithFormat:@"%@/%@/%@",CarOwnerService_path,serviceID,kCarOwnerServiceDictionary];
    NSDictionary *dictionary = [[NSDictionary alloc] initWithContentsOfFile:dictionaryPath];
    
    return [dictionary autorelease];
}

#pragma mark - 下载委托回调
/*!
  @brief 数据下载进度回调
  */
-(void)progress:(MWCarOwnerServiceTask*)sender current:(long long)current total:(long long)total
{
    NSLog(@"%lld,%lld",current,total);
    
    if (delegate && [delegate respondsToSelector:@selector(progress:current:total:)]) {
        [delegate progress:sender current:current total:total];
    }
    
	
}

/*!
  @brief 数据下载完成回调
  */
-(void)finished:(MWCarOwnerServiceTask*)sender
{
    
	sender.status = TASK_STATUS_FINISH;
    
    [self start];
    
    if (delegate && [delegate respondsToSelector:@selector(finished:)]) {
        [delegate finished:sender];
    }
}

/*!
  @brief 数据下载异常回调
  */
-(void)exception:(MWCarOwnerServiceTask*)sender exception:(id)exception
{
    if (!sender) {
        return;
    }
    
    int exceptionCode = ((NSError *)exception).code;
    
    if (exceptionCode == DOWNLOADHANDLETYPE_UPZIPFAIL) {//解压失败，删除数据，重新下载
        
        if (delegate && [delegate respondsToSelector:@selector(exception:exception:)]) {
            [delegate exception:sender exception:[NSNumber numberWithInt:exceptionCode]];
        }
    
        double delayInSeconds = 0.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            
            [GDStatusBarOverlay showWithAutoHideMessage:STR(@"CarService_DownloadFail", Localize_CarService) duration:1.5 animated:YES];
            
        });
    }
    else if( exceptionCode == DOWNLOADHANDLETYPE_CURRENTLAGERTOTAL || exceptionCode == DOWNLOADHANDLETYPE_UPZIPFAIL || exceptionCode == DOWNLOADHANDLETYPE_CURRENTSMALLTOTAL  ){//下载失败
        
        if (delegate && [delegate respondsToSelector:@selector(exception:exception:)]) {
            [delegate exception:sender exception:[NSNumber numberWithInt:exceptionCode]];
        }
        
        double delayInSeconds = 0.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            
            [GDStatusBarOverlay showWithAutoHideMessage:STR(@"CarService_DownloadFail", Localize_CarService) duration:1.5 animated:YES];
            
        });
        
    }
    else if (exceptionCode == DOWNLOADHANDLETYPE_MD5NOMATCH)
    {
        if (delegate && [delegate respondsToSelector:@selector(exception:exception:)]) {
            [delegate exception:sender exception:[NSNumber numberWithInt:exceptionCode]];
        }
    }
    else {
       
        if (delegate && [delegate respondsToSelector:@selector(exception:exception:)]) {
            [delegate exception:sender exception:[NSNumber numberWithInt:DOWNLOADHANDLETYPE_NONETWORK]];//无网络连接
        }
        
//        int netType = NetWorkType;
//        
//        if (netType == 2 || netType == 1) {
//            
//            if ([self isRunningWithTaskID:sender.serviceID]) {
//                [self stopWithOutOtherStartWithTaskID:sender.serviceID];
//            }
//            
//            [self startWithTaskID:sender.serviceID];
//        }
//        else {
//            
//            if (delegate && [delegate respondsToSelector:@selector(exception:exception:)]) {
//                [delegate exception:sender exception:[NSNumber numberWithInt:DOWNLOADHANDLETYPE_NONETWORK]];//无网络连接
//            }
//            
//        }
    }
    
    [self store];
    
}

/*!
  @brief 数据解压完成回调
  */
- (void)unZipFinish:(MWCarOwnerServiceTask*)sender
{
    
    if (sender) {
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"YYYYMMddhhmmss"];
        NSString *dateString = [formatter stringFromDate: [NSDate date]];
        [formatter release];
        
        [self installFinishSort:sender];
        sender.serviceStatus = 0;
        sender.vip = 0;
        sender.installTime = dateString;
        
        double delayInSeconds = 0.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            
            NSString *string = [NSString stringWithFormat:@"%@ %@",[self getStringFormJson:sender.title],STR(@"CityDownloadManage_completeDownload", Localize_CityDownloadManage)];
            [GDStatusBarOverlay showWithAutoHideMessage:string duration:1.5 animated:YES];
            
        });
        
    }
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        [self store];
    });
    
    if (delegate && [delegate respondsToSelector:@selector(unZipFinish:)]) {
        [delegate unZipFinish:sender];
    }
    else if ([ANParamValue sharedInstance].isInit){
        
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_HandleUIUpdate object:[NSNumber numberWithInt:UIUpdate_CarServiceDownloadFinish] userInfo:nil];
    
}

#pragma mark - url请求回调
/*!
  @brief 请求应答成功回调
  */
- (void)request:(NetRequestExt *)request didFinishLoadingWithData:(NSData *)data
{
    NSLog(@"didFinishLoadingWithData..........");
    if (data && [data length])
    {
        NSString *tmp = [[[NSString alloc ] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
        
        NSLog(@"车主服务请求结果：%@",tmp);
        
        __block MWCarOwnerServiceManage *weakSelf = self;
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
        dispatch_async(queue, ^{
            
            NSDictionary *dialectDic = [NSDictionary dictionaryWithXMLData:data];
            
            if ([[[dialectDic objectForKey:@"response"] objectForKey:@"rspcode"] isEqualToString:@"0000"]) {
                
                if (RT_CarOwnerServiceRequest == request.requestCondition.requestType)
                {
                    [weakSelf addCarOwnerServiceListFromNetToLocal:data];
                }
                else if(RT_CarOwnerServiceUnInstallRequest == request.requestCondition.requestType){
                    
                    [weakSelf addMoreCarOwnerServiceListFromNetToLocal:data];
                }
                else if (RT_CarOwnerServiceDetailRequest == request.requestCondition.requestType)
                {
                    [weakSelf addDetailCarOwnerService:data];
                }
                
                if ([reqDelegare respondsToSelector:@selector(requestToViewCtrWithRequestType:didFinishLoadingWithResult:)])
                {
                    [reqDelegare requestToViewCtrWithRequestType:request.requestCondition.requestType didFinishLoadingWithResult:nil];
                }
            }
            else{
                if ([reqDelegare respondsToSelector:@selector(requestToViewCtrWithRequestType:didFailWithError:)])
                {
                    [reqDelegare requestToViewCtrWithRequestType:request.requestCondition.requestType didFailWithError:nil];
                }
            }
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                
            });
        });
        
        
        
        
        
    }
    else{
        
        if ([reqDelegare respondsToSelector:@selector(requestToViewCtrWithRequestType:didFailWithError:)])
        {
            [reqDelegare requestToViewCtrWithRequestType:request.requestCondition.requestType didFailWithError:nil];
        }
    }
}

/*!
  @brief 请求失败回调
  */
- (void)request:(NetRequestExt *)request didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError..........");
	if ([reqDelegare respondsToSelector:@selector(requestToViewCtrWithRequestType:didFailWithError:)])
    {
        [reqDelegare requestToViewCtrWithRequestType:request.requestCondition.requestType didFailWithError:nil];
    }
    
}

@end

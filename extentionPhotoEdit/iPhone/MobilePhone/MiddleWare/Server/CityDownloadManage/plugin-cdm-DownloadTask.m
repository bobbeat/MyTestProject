//
//  DownloadTask.m
//  plugin-CityDataManager
//
//  Created by mark on 11-11-4.
//  Copyright (c) 2011年 Autonavi. All rights reserved.
//

#import "plugin-cdm-DownloadTask.h"
#import "ZipArchive.h"
#import "ANParamValue.h"

#import "ANReachability.h"
#import "ANOperateMethod.h"
#import "GDAlertView.h"
#import  "UIDevice+Category.h"
#import "MWCityDownloadMapDataList.h"
#import "Play.h"

static NSString* KB = @"KB";
static NSString* MB = @"MB";

#define DOCUMENTS_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]//文件最终存放目录


@implementation DownloadTask

@synthesize url,version,updatetype,all_suburl,all_size,all_unzipsize,all_md5,add_suburl,add_size,add_unzipsize,add_md5,zhname,enname,twname;


/*
 NSCoding协议内容(由龙峰填充)
 */

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:title forKey:@"tasklist1key"];
    [encoder encodeInt:taskId forKey:@"tasklist2key"];
    [encoder encodeInt64:current forKey:@"tasklist3key"];
    [encoder encodeInt64:total forKey:@"tasklist4key"];
    [encoder encodeInt:status forKey:@"tasklist5key"];
    [encoder encodeObject:url forKey:@"tasklist6key"];
    [encoder encodeObject:version forKey:@"tasklist7key"];
    [encoder encodeInt:updatetype forKey:@"tasklist8key"];
    [encoder encodeInt64:all_size forKey:@"tasklist9key"];
    [encoder encodeInt64:all_unzipsize forKey:@"tasklist10key"];
    [encoder encodeObject:all_suburl forKey:@"tasklist11key"];
    [encoder encodeObject:all_md5 forKey:@"tasklist12key"];
    [encoder encodeObject:add_suburl forKey:@"tasklist13key"];
    [encoder encodeInt64:add_size  forKey:@"tasklist14key"];
    [encoder encodeInt64:add_unzipsize forKey:@"tasklist15key"];
    [encoder encodeObject:add_md5 forKey:@"tasklist16key"];
    [encoder encodeObject:zhname forKey:@"tasklist17key"];
    [encoder encodeObject:twname forKey:@"tasklist18key"];
    [encoder encodeObject:enname forKey:@"tasklist19key"];
    
}


- (id)initWithCoder:(NSCoder *) decoder
{
    if (self = [super init])
    {
        self.title = [decoder decodeObjectForKey:@"tasklist1key"];
        self.taskId = [decoder decodeIntForKey:@"tasklist2key"];
        self.current = [decoder decodeInt64ForKey:@"tasklist3key"];
        self.total = [decoder decodeInt64ForKey:@"tasklist4key"];
        self.status = [decoder decodeIntForKey:@"tasklist5key"];
        self.url = [decoder decodeObjectForKey:@"tasklist6key"];
        self.version = [decoder decodeObjectForKey:@"tasklist7key"];
        self.updatetype = [decoder decodeIntForKey:@"tasklist8key"];
        self.all_size = [decoder decodeInt64ForKey:@"tasklist9key"];
        self.all_unzipsize = [decoder decodeInt64ForKey:@"tasklist10key"];
        self.all_suburl = [decoder decodeObjectForKey:@"tasklist11key"];
        self.all_md5 = [decoder decodeObjectForKey:@"tasklist12key"];
        self.add_suburl = [decoder decodeObjectForKey:@"tasklist13key"];
        self.add_size  = [decoder decodeInt64ForKey:@"tasklist14key"];
        self.add_unzipsize = [decoder decodeInt64ForKey:@"tasklist15key"];
        self.add_md5 = [decoder decodeObjectForKey:@"tasklist16key"];
        self.zhname = [decoder decodeObjectForKey:@"tasklist17key"];
        self.twname = [decoder decodeObjectForKey:@"tasklist18key"];
        self.enname = [decoder decodeObjectForKey:@"tasklist19key"];
    }
    
    return self;
}


// 获取文件名，从后往后找“/”定位
- (NSString *)getFilename
{
    NSString *stringt = @"/";
    
    NSRange range = [url rangeOfString:stringt options:NSBackwardsSearch];
    if (range.length==0)
    {
        return @"";//即下载地址是错误的，后面处理
    }
    
    NSString *strdata = [url substringFromIndex:range.location+1];//去除前面的无关信息
    return strdata;
}


// 获取文件存储路径
- (void)createFilepath
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:DataDownload_PATH]) //要是文件目录不存在，创建目录
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:DataDownload_PATH withIntermediateDirectories:NO attributes:nil error:nil];
    }
    
    // 公司内部协议，未完成下载的文件统一未.tmp文件
    filePath = [[NSString alloc] initWithString:[DataDownload_PATH stringByAppendingFormat:@"%@.tmp",filename]];
}


// 执行下载任务
- (void)run
{
    NSLog(@"url=%@",url);
    ////add by xyy
    if(url==nil)//首次下载
    {
        if (updatetype==1)//全量更新
        {
            url = all_suburl;
            total = all_size;
        }
        else
        {
            url = add_size;
            total = add_size;
        }
    }
    /////////////
    
    //判断url是否为空，如果为空，提示。
    if (url == nil)
    {
        GDAlertView *alertView = [[GDAlertView alloc] initWithTitle:@"Cannot Open the Request!" andMessage:STR(@"CityDownloadManage_urlEmpty",Localize_CityDownloadManage)] ;
        
        [alertView addButtonWithTitle:STR(@"Universal_ok", Localize_Universal) type:GDAlertViewButtonTypeCancel handler:nil];
        [alertView show];
        [alertView release];
        
        return;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(donetMethod) name:kReachabilityChangedNotification object: nil];
    
    // 获取文件名，若文件名未空即下载地址是错误的
    if (filename)
    {
        [filename release];
        filename = nil;
    }
    filename = [[NSString alloc] initWithString:[self getFilename]];
    if (filename == nil)
    {
        GDAlertView *alertView = [[GDAlertView alloc] initWithTitle:@"Cannot Open the Request!" andMessage:STR(@"CityDownloadManage_urlError",Localize_CityDownloadManage)] ;
        
        [alertView addButtonWithTitle:STR(@"Universal_ok", Localize_Universal) type:GDAlertViewButtonTypeCancel handler:nil];
        [alertView show];
        [alertView release];
        return;
    }
    
    // 创建文件存储路径
    [self createFilepath];
    if (tmpPath)
    {
        [tmpPath release];
        tmpPath = nil;
    }
    tmpPath = [[NSString alloc] initWithString:filePath];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath])//若选择重新下载任务，会删除之前的临时文件
    {
        NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
        current = [fileAttributes fileSize];
    }
    else
    {
        current = 0;
    }
    
    // 判断是新下载还是继续下载，current＝0未新下载，否则为续传（若临时文件不存在统一做重新下载）
    if (current==0)
    {
        if([[NSFileManager defaultManager] fileExistsAtPath:filePath])//若选择重新下载任务，会删除之前的临时文件
        {
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        }
        
        fileStream = [NSOutputStream outputStreamToFileAtPath:filePath append:NO];
        [fileStream retain];
        assert(fileStream != nil);
        [fileStream open];//打开文件流准备接受数据
        
        NSURL* turl = [NSURL URLWithString:url];
        NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:turl];
        [request setTimeoutInterval:10.0f];
        
        [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];//add by hlf for 重新下载不使用缓存 at 2014.08.07
        assert(request != nil);
        URLConnection = [NSURLConnection connectionWithRequest:request delegate:self];
        [request release];
    }
    else
    {
        if(![[NSFileManager defaultManager] fileExistsAtPath:filePath])
        {//判断继续下载的时候临时文件是否还存在，不存在就重新下载，并修改相应的参数
            current = 0;
            total = 0;
            
            fileStream = [NSOutputStream outputStreamToFileAtPath:filePath append:NO];
            [fileStream retain];
            assert(fileStream != nil);
            [fileStream open];
            
            NSURL* turl = [NSURL URLWithString:url];
            NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:turl];
            [request setTimeoutInterval:10.0f];
            [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];//add by hlf for 重新下载不使用缓存 at 2014.08.07
            
            assert(request != nil);
            URLConnection = [NSURLConnection connectionWithRequest:request delegate:self];
            [request release];
        }
        else //续传的实现
        {
            fileStream = [NSOutputStream outputStreamToFileAtPath:filePath append:YES];
            [fileStream retain];
            assert(fileStream != nil);
            [fileStream open];
            
            NSLog(@"续传：%lld,%lld",current,total);
            
            NSURL* turl = [NSURL URLWithString:url];
            NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:turl];
            [request setTimeoutInterval:10.0f];
            [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];//add by hlf for 重新下载不使用缓存 at 2014.08.07
            
            NSString* contentRang = [[NSString alloc] initWithFormat:@" bytes=%lld-%lld",current,total];
            [request addValue:contentRang forHTTPHeaderField:@"Range"];
            [request setValue:contentRang forHTTPHeaderField:@"Range"];
            [contentRang release];
            assert(request != nil);
            URLConnection = [NSURLConnection connectionWithRequest:request delegate:self];
            
            [request release];
        }
    }
    
}


- (void)donetMethod
{
    int netflag = NetWorkType;
    
    switch (netflag)
    {
        case 2:
        {
            if (self.status == TASK_STATUS_RUNNING) {
                [self stopconnection];
                [self run];
            }
            
        }
            break;
            
        default:
            break;
    }
}


// 停止任务的实现
- (void)stopconnection
{
    if (filePath != nil)
    {
        [filePath release];
        filePath = nil;
    }
    
    if (URLConnection != nil)
    {
        @try {
            
            [URLConnection cancel];
            URLConnection = nil;
        }
        @catch (NSException *exception) {
            
        }
        
    }
    
    if (fileStream != nil)
    {
        [fileStream close];
        [fileStream release];
        fileStream = nil;
    }
}


// 执行停止任务
- (void)stop
{
    
    [self stopconnection];
}


// 删除任务以及任务相关的资源
- (void)erase
{
    // 停止下载任务
    [self stopconnection];
    
    if ([NSThread isMultiThreaded])
    {
        if (mythread!=nil)
        {
            [mythread cancel];
            [mythread release];
            mythread = nil;
        }
    }
    
    
    //删除城市数据前需要告诉引擎
    [self performSelectorOnMainThread:@selector(DeleteCity) withObject:nil waitUntilDone:NO];
    
    
}


// 删除城市数据
- (void)deleteFiles
{
    //删除解压后的城市数据
    GADMINCODE admin = {0};
    admin.euRegionCode = eREGION_CODE_CHN;
    admin.nAdCode = self.taskId;
    GDATADIRINFO dataDir = {0};
    
    GSTATUS res = [MWAdminCode GetAdareaDirList:&admin nMaxCnt:1 list:&dataDir];
    
    if (res == GD_ERR_OK) {
        
        NSString *fileString = GcharToNSString(dataDir.szDir);
        NSString *path = [NSString stringWithFormat:@"%@%@",Map_Data_Path,fileString];
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            //删除城市数据前需要告诉引擎
            if ([ANParamValue sharedInstance].isInit) {
                
                Gbool bBusy = Gfalse;
                GSTATUS res = [MWEngineTools IsAllModulesBusy:&bBusy];
                
                if (res != GD_ERR_OK || bBusy) {//引擎繁忙则不进行解压操作
                    return;
                }
                
                __block GADMINCODE adminCode = {0};
                adminCode.euRegionCode = eREGION_CODE_CHN;
                adminCode.nAdCode = self.taskId;
                
                enumDBTYPE type = eDB_TYPE_ALL;
                
                [MWEngineTools DeleteCityDB:&adminCode type:type];
                
            }
            
            //重命名，延迟2s删除
            NSString *renamegdPath = [NSString stringWithFormat:@"%@_del",[path substringToIndex:path.length-1]];
            [[NSFileManager defaultManager] moveItemAtPath:path toPath:renamegdPath error:nil];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)),  dispatch_get_main_queue(), ^{
                [[NSFileManager defaultManager] removeItemAtPath:renamegdPath error:nil];
//                [self performSelectorInBackground:@selector(removefiles:) withObject:renamegdPath ];
            });
            
        }
        
        
    }
    
}

// 返回任务的进度百分比[0~100]
- (int)percent
{
    return (current*100.0/total);
}


// 某个任务的进度描述
- (NSString*)description
{
    /*
     1、字节>=1MB的，以MB为单位，保留2位小数
     2、字节<1MB的，以KB为单位，保留2位小数
     */
    float cur,tot;
    NSString* unit1,*unit2;
    int mb = 1024*1024;
    int kb = 1024;
    if(current<mb)
    {
        cur = current*1.0f/kb;
        unit1 = KB;
    }
    else
    {
        cur = current*1.0f/mb;
        unit1 = MB;
    }
    if(total<mb)
    {
        tot = total*1.0f/kb;
        unit2 = KB;
    }
    else
    {
        tot = total*1.0f/mb;
        unit2 = MB;
    }
    
    return [NSString stringWithFormat:@"%.2f%@/%.2f%@",cur,unit1,tot,unit2];
}


// 获取文件还未下载的大小，即所需空间大小
- (long long)getNeedSize
{
    return (total-current);
}

//基础资源更新处理流程
-(void) processBasicResource
{
    int isForce = NO;//是否强制更新
    SectionInfo *sectioninfo = [[MWCityDownloadMapDataList citydownloadMapDataList]GetBasicResourceSectionInfo];
    if(sectioninfo && sectioninfo.play.status==1)//判断基础资源强制更新
    {
        isForce = YES;
    }
    
    if(total == all_size)//全量更新
    {
        if (isForce)
        {
            GDAlertView *alertView = [[GDAlertView alloc] initWithTitle:nil andMessage:STR(@"CityDownloadManage_basicresouce_restart",Localize_CityDownloadManage)] ;
            
            [alertView addButtonWithTitle:STR(@"Universal_ok", Localize_Universal) type:GDAlertViewButtonTypeCancel handler:^(GDAlertView *alertView){
                [[UIApplication sharedApplication] exitApplication];//退出导航
            }];
            [alertView show];
            [alertView release];
        }
        else
        {
            GDAlertView *alertView = [[GDAlertView alloc] initWithTitle:nil andMessage:STR(@"CityDownloadManage_basicresouce_restart",Localize_CityDownloadManage)] ;
            
            [alertView addButtonWithTitle:STR(@"Universal_ok", Localize_Universal) type:GDAlertViewButtonTypeCancel handler:^(GDAlertView *alertView){
                [self deleteFiles];//非强制全量需要先删除数据
                [[UIApplication sharedApplication] exitApplication];//退出导航
            }];
            [alertView show];
            [alertView release];
        }
    }
    else//增量更新
    {
        if (isForce)
        {
            GDAlertView *alertView = [[GDAlertView alloc] initWithTitle:nil andMessage:STR(@"CityDownloadManage_basicresouce_restart",Localize_CityDownloadManage)] ;
            
            [alertView addButtonWithTitle:STR(@"Universal_ok", Localize_Universal) type:GDAlertViewButtonTypeCancel handler:^(GDAlertView *alertView){
                [[UIApplication sharedApplication] exitApplication];//退出导航
            }];
            [alertView show];
            [alertView release];
        }
        else
        {
            GDAlertView *alertView = [[GDAlertView alloc] initWithTitle:nil andMessage:STR(@"CityDownloadManage_basicresouce_restart",Localize_CityDownloadManage)] ;
            
            [alertView addButtonWithTitle:STR(@"Universal_cancel", Localize_Universal) type:GDAlertViewButtonTypeCancel handler:nil];//非强制增量取消什么也不做，下次进导航自动解压
            [alertView addButtonWithTitle:STR(@"Universal_ok", Localize_Universal) type:GDAlertViewButtonTypeCancel handler:^(GDAlertView *alertView){
                [[UIApplication sharedApplication] exitApplication];//退出导航
            }];
            [alertView show];
            [alertView release];
        }
    }
}

// 下载任务联网响应，主要是返回的任务大小
- (void)connection:(NSURLConnection *)aconnection didReceiveResponse:(NSURLResponse *)response
{
    flag=0;
    if (total==0) //保证total在有值的时候不被改变（主要用于续传的情况）
    {
        total = [response expectedContentLength];
    }
    NSLog(@"total==%@,%lld",self.title,[response expectedContentLength]);
    // Check for bad connection
    if ([response expectedContentLength] < 0)
    {
        // 警告提示信息，由产品定义
        
        [self stopconnection];
        [delegate exception:self exception:[NSError errorWithDomain:@"error_currensize" code:DOWNLOADHANDLETYPE_CURRENTSMALLTOTAL userInfo:nil]];
        return;
    }
}


// 开始接收服务器的数据
- (void)connection:(NSURLConnection *)aconnection didReceiveData:(NSData *)data
{
    
    long long disksize = [UIDevice getCurDiskSpaceInBytes];
    if (disksize<(long long)[data length])
    {
        [self stopconnection];
        [delegate exception:self exception:[NSError errorWithDomain:@"error_storage" code:DOWNLOADHANDLETYPE_NOSPACE userInfo:nil]];
        return;
    }
    current = current + (long long)[data length];
    
    // 写入内容
    NSInteger dataLength;
    const uint8_t *dataBytes;
    NSInteger bytesWrittenSoFar;
    NSInteger bytesWritten;
    
    dataLength = [data length];
    dataBytes = [data bytes];
    bytesWrittenSoFar = 0;
    
    do
    {
        bytesWritten = [fileStream write:&dataBytes[bytesWrittenSoFar] maxLength:dataLength - bytesWrittenSoFar];
        
        //assert(bytesWritten != 0);
        if (bytesWritten == 0)
        {
            break;
        }
        
        if (bytesWritten == -1)
        {
            break;
        }
        else
        {
            bytesWrittenSoFar += bytesWritten;
        }
        
    }
    while ( bytesWrittenSoFar != dataLength);
    
    // 通知相应的界面做相应的进度的更新
    [delegate progress:self current:current total:total];
}


// 联网失败
- (void)connection:(NSURLConnection *)aconnection didFailWithError:(NSError *)error
{
    [delegate exception:self exception:error];
}


// 数据接收完成
- (void)connectionDidFinishLoading:(NSURLConnection *)aconnection
{
    
    // 通知相应的界面做相应的进度的更新
    [delegate finished:self];
    
    NSString* destinctionPath = [NSString stringWithFormat:@"%@%@",DataDownload_PATH,filename];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:DataDownload_PATH])
    {
        if ([[NSFileManager defaultManager] fileExistsAtPath:destinctionPath])
        {// 移除之前的旧版本数据
            [[NSFileManager defaultManager] removeItemAtPath:destinctionPath error:nil];
        }
        
        // 移动文件.tmp --> .zip
        NSError* err = nil;
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]){
            [[NSFileManager defaultManager] moveItemAtPath:filePath toPath:destinctionPath error:&err];
        }
        
        // 停止任务，做解压的准备
        [self stopconnection];
        
        //modify by xyy  for md5校验
        NSString *taskmd5String;
        if(self.total == self.add_size)
        {
            taskmd5String = self.add_md5;
        }
        else
        {
            taskmd5String = self.all_md5;
        }
        NSString *temp_path = [NSString stringWithFormat:@"%@%@",DataDownload_PATH,[self getFilename]];
        NSString *md5String = [NSString getFileMD5WithPath:temp_path];
        
        int result = [md5String compare:taskmd5String options:NSCaseInsensitiveSearch];
        if (!md5String || NSOrderedSame != result) {
            
            GDAlertView *alertView = [[GDAlertView alloc] initWithTitle:nil andMessage:STR(@"CarService_DownloadCheckMd5",Localize_CarService)] ;
            
            [alertView addButtonWithTitle:STR(@"Universal_ok", Localize_Universal) type:GDAlertViewButtonTypeCancel handler:nil];
            [alertView show];
            [alertView release];
            
            self.current = 0;
            self.status = TASK_STATUS_BLOCK;
            [self deleteZipFile];
            
            
            [delegate exception:self exception:[NSError errorWithDomain:@"error_ziparchive" code:DOWNLOADHANDLETYPE_MD5NOMATCH userInfo:nil]];
            
            return;
        }
        //启动解压
   
        [self performSelectorOnMainThread:@selector(startUnzipThread) withObject:nil waitUntilDone:NO];

    }
    
}



// 解压线程
- (void)ZipArchive
{
    NSAutoreleasePool* pool =[[NSAutoreleasePool alloc] init];
    NSMutableDictionary* threadDict = [[NSThread currentThread] threadDictionary];
    NSString* destinctionPath = [[NSString alloc] initWithString:[threadDict valueForKey:@"destinctionPath"]];
    int admincode = [[threadDict valueForKey:@"admincode"] intValue];
    //先解压到download目录
    BOOL isinit = [[threadDict valueForKey:@"isInit"] boolValue];

    BOOL result = YES;//判断是否解压成功
    ZipArchive* za = [[ZipArchive alloc] init];
    
    if ([za UnzipOpenFile:destinctionPath])
    {
        int ret = [za getRetValue];
        if( ret!=UNZ_OK )
        {
            [za OutputErrorMessage:@"Failed"];
        }
        
        do
        {
            if([[NSThread currentThread] isCancelled])
            {
                result = NO;
                if([[NSFileManager defaultManager] fileExistsAtPath:destinctionPath])
                {
                    [[NSFileManager defaultManager] removeItemAtPath:destinctionPath error:nil];// 解压成功后删除压缩文件
                }
                
            }
            
            long long disksize = [UIDevice getCurDiskSpaceInBytes];
            NSDictionary *dic = [[NSFileManager defaultManager] attributesOfItemAtPath:destinctionPath error:nil];
            unsigned long long  size = [dic fileSize];
            if (disksize < size) {
                
                [delegate exception:self exception:[NSError errorWithDomain:@"error_storage" code:DOWNLOADHANDLETYPE_NOSPACE userInfo:nil]];
                
                result = NO;
                break;
            }
            int zaResult = -1;
            if(admincode == 0 || !isinit){
                zaResult = [za UnzipFileTo:DOCUMENTS_FOLDER overWrite:YES retValue:&ret filesize:disksize];
            }
            else
            {
                zaResult = [za UnzipFileTo:DataDownload_PATH overWrite:YES retValue:&ret filesize:disksize];
            }
            if (zaResult!=2)
            {
                if (zaResult==1)
                {
                    [delegate exception:self exception:[NSError errorWithDomain:@"error_storage" code:DOWNLOADHANDLETYPE_NOSPACE userInfo:nil]];
                }
                else
                {
                    [delegate exception:self exception:[NSError errorWithDomain:@"error_ziparchive" code:DOWNLOADHANDLETYPE_UPZIPFAIL userInfo:nil]];
                }
                
                result = NO;
                break;
            }
        }while (ret==UNZ_OK && UNZ_OK!=UNZ_END_OF_LIST_OF_FILE) ;
        
        [za UnzipCloseFile];
    }
    [za release];
    
    if (result)
    {
        //数据压缩包放在所有都成功以后删除，基础资源的解压完成可以直接删除(用重命名，延迟删除，防止基础资源最后才解压完）
        NSError *error;
        if((admincode == 0 || !isinit) && [[NSFileManager defaultManager] fileExistsAtPath:destinctionPath])
        {
            //重命名，延迟2s删除
            NSString *renamegdPath = [NSString stringWithFormat:@"%@_del",destinctionPath];
            [[NSFileManager defaultManager] moveItemAtPath:destinctionPath toPath:renamegdPath error:&error];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)),  dispatch_get_main_queue(), ^{
                [[NSFileManager defaultManager] removeItemAtPath:renamegdPath error:nil];
            });
        }
        else
        {
            NSString *renamegdPath = [NSString stringWithFormat:@"%@_del",destinctionPath];
            [[NSFileManager defaultManager] moveItemAtPath:destinctionPath toPath:renamegdPath error:&error];
        }
        
        //数据解压完告诉引擎
        if(isinit)
        {
            [self performSelectorOnMainThread:@selector(UpdateCityFinished) withObject:nil waitUntilDone:NO];
        }
        if ([delegate respondsToSelector:@selector(unZipFinish:)]) {
            [delegate unZipFinish:self];
        }
        
    }
    
    [destinctionPath release];
    
    [pool release];
    
}

- (void)dealloc
{
    self.url = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (tmpPath)
    {
        [tmpPath release];
        tmpPath = nil;
    }
    
    if (URLConnection != nil)
    {
        @try {
            
            [URLConnection cancel];
            URLConnection = nil;
        }
        @catch (NSException *exception) {
            
        }
        
    }
    
    if (filePath != nil)
    {
        [filePath release];
        filePath = nil;
    }
    
    if (fileStream != nil)
    {
        [fileStream close];
        [fileStream release];
        fileStream = nil;
    }
    if (filename)
    {
        [filename release];
        filename = nil;
    }
    if (mythread)
    {
        [mythread cancel];
        [mythread release];
        mythread = nil;
    }
    
    CRELEASE(zhname);
    CRELEASE(enname);
    CRELEASE(twname);
    CRELEASE(version);
    CRELEASE(all_suburl);
    CRELEASE(all_md5);
    CRELEASE(add_suburl);
    CRELEASE(add_md5);
    
    [super dealloc];
}

#pragma mark - 数据处理


//启动解压线程进行解压
-(void)startUnzipThread
{
    //基础资源更新,不解压
    if([ANParamValue sharedInstance].isInit && taskId==0)//引擎已经初始化
    {
        [self processBasicResource];
        return;
    }
    
    //下载完成  城市数据解压到datadownload目录，基础资源第一次下载直接解压覆盖
    NSString* destinctionPath = [NSString stringWithFormat:@"%@%@",DataDownload_PATH,filename];
    mythread = [[NSThread alloc] initWithTarget:self  selector:@selector(ZipArchive) object:nil ];
    NSMutableDictionary* threadDict = [mythread threadDictionary];
    [threadDict setValue:destinctionPath forKey:@"destinctionPath"];
    NSString  *admincode = [NSString stringWithFormat:@"%d",taskId];
    [threadDict setValue:admincode forKey:@"admincode"];
    NSString  *isinit = [NSString stringWithFormat:@"%d",[ANParamValue sharedInstance].isInit];
    [threadDict setValue:isinit forKey:@"isInit"];
    [mythread start];//开始启动线程
}

//解压完成
- (void)UpdateCityFinished
{
    if ([ANParamValue sharedInstance].isInit) {
        //1.删除旧数据
        //判断引擎是否繁忙，不繁忙则进行旧数据的删除（先通知引擎，再删数据）
        if(total == all_size && self.taskId!=0)//基础资源直接解压，不用删除旧数据
        {
            [self deleteFiles];
        }
        
        //2 更新数据（prepare，rename，finish）
        Gbool bBusy = Gfalse;
        GSTATUS res = [MWEngineTools IsAllModulesBusy:&bBusy];
        GADMINCODE adminCode = {0};
        adminCode.euRegionCode = eREGION_CODE_CHN;
        adminCode.nAdCode = self.taskId;
        enumDBTYPE type = eDB_TYPE_ALL;
       //通知引擎prepare
        GSTATUS preResult = [MWEngineTools PrepareUpdateCityDB:&adminCode type:type];
        NSLog(@"准备更新数据：%@,%d",self.title,preResult);
        
        NSRange range = [filename rangeOfString:@"."];
        if (range.length==0 || res != GD_ERR_OK || bBusy || preResult != GD_ERR_OK)
        {
            if(self.taskId !=0){
                //压缩包
                NSError *error;
                NSString* destinctionPath = [NSString stringWithFormat:@"%@%@",DataDownload_PATH,filename];
                NSString *renamegdPath = [NSString stringWithFormat:@"%@_del",destinctionPath];
                
                if([[NSFileManager defaultManager] fileExistsAtPath:renamegdPath])
                {
                    [[NSFileManager defaultManager] moveItemAtPath:renamegdPath toPath:destinctionPath error:nil];
                    
                }
                
            }

            return;
        }
        //重命名 rename
        if(self.taskId !=0){
            NSString *dirname = [filename substringToIndex:range.location];//去除无关信息
            NSString *srcdir = [[NSString alloc] initWithString:[DataDownload_PATH stringByAppendingFormat:@"data/chn/%@",dirname]];
            NSString *dstdir = [[NSString alloc] initWithString:[document_path stringByAppendingFormat:@"/data/chn/%@",dirname]];
            if([[NSFileManager defaultManager] fileExistsAtPath:srcdir])
            {
                [[NSFileManager defaultManager]moveItemAtPath:srcdir toPath:dstdir error:nil];
            }
            [srcdir release];
            [dstdir release];
        }
        //通知引擎finish
        GSTATUS rest = [MWEngineTools UpdateCityDBFinished:&adminCode type:type];
        NSLog(@"下载完成:%@%d",self.title,rest);
        
        if(self.taskId !=0){
            //删除压缩包
            NSError *error;
            NSString* destinctionPath = [NSString stringWithFormat:@"%@%@",DataDownload_PATH,filename];
            NSString *renamegdPath = [NSString stringWithFormat:@"%@_del",destinctionPath];

            if([[NSFileManager defaultManager] fileExistsAtPath:renamegdPath])
            {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)),  dispatch_get_main_queue(), ^{
                    [[NSFileManager defaultManager] removeItemAtPath:renamegdPath error:nil];
                });
                
            }

        }
        
        
    }
}

-(void) removefiles:(NSString*)filedir
{
    [[NSFileManager defaultManager] removeItemAtPath:filedir error:nil];
}


-(void)DeleteTempFiles
{
    // 停止下载任务
    [self stopconnection];
    
    if ([NSThread isMultiThreaded])
    {
        if (mythread!=nil)
        {
            [mythread cancel];
            [mythread release];
            mythread = nil;
        }
    }
    
    
    //删除临时文件和压缩文件
    NSError *error = nil;
    
    if (url && [url length]!=0)
    {
        NSString *gdtmpPath = [[NSString alloc] initWithString:[DataDownload_PATH stringByAppendingFormat:@"%@",[self getFilename]]];
        if([[NSFileManager defaultManager] fileExistsAtPath:gdtmpPath])
        {
            //重命名，延迟2s删除
            NSString *renamegdtmpPath = [NSString stringWithFormat:@"%@_del",gdtmpPath];
            [[NSFileManager defaultManager] moveItemAtPath:gdtmpPath toPath:renamegdtmpPath error:&error];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)),  dispatch_get_main_queue(), ^{
                [[NSFileManager defaultManager] removeItemAtPath:renamegdtmpPath error:nil];
//                [self performSelectorInBackground:@selector(removefiles:) withObject:renamegdtmpPath ];

            });
            
            
        }
        
        NSString *gdPath = [[NSString alloc] initWithString:[DataDownload_PATH stringByAppendingFormat:@"%@.tmp",[self getFilename]]];
        if([[NSFileManager defaultManager] fileExistsAtPath:gdPath])
        {
            //重命名，延迟2s删除
            NSString *renamegdPath = [NSString stringWithFormat:@"%@_del",gdPath];
            [[NSFileManager defaultManager] moveItemAtPath:gdPath toPath:renamegdPath error:&error];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [[NSFileManager defaultManager] removeItemAtPath:renamegdPath error:nil];
//                [self performSelectorInBackground:@selector(removefiles:) withObject:renamegdPath ];
            });
            
        }
        [gdPath release];
        gdPath = nil;
        
        [gdtmpPath release];
        gdtmpPath = nil;
    }
    
}

//删除下载完成的文件zip包
- (void)deleteZipFile
{
    
    NSError *error = nil;
    
    if (url && [url length]!=0)
    {
        NSString *gdtmpPath = [[NSString alloc] initWithString:[DataDownload_PATH stringByAppendingFormat:@"%@",[self getFilename]]];
        if([[NSFileManager defaultManager] fileExistsAtPath:gdtmpPath])
        {
            //重命名，延迟2s删除
            NSString *renamegdPath = [NSString stringWithFormat:@"%@_del",gdtmpPath];
            [[NSFileManager defaultManager] moveItemAtPath:gdtmpPath toPath:renamegdPath error:&error];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)),  dispatch_get_main_queue(), ^{
                [[NSFileManager defaultManager] removeItemAtPath:renamegdPath error:nil];
//                [self performSelectorInBackground:@selector(removefiles:) withObject:renamegdPath ];
            });
            
        }
        
        [gdtmpPath release];
        gdtmpPath = nil;
    }
}

//删除数据
- (void)DeleteCity
{
    if ([ANParamValue sharedInstance].isInit) {
        
        Gbool bBusy = Gfalse;
        GSTATUS res = [MWEngineTools IsAllModulesBusy:&bBusy];
        
        if (res != GD_ERR_OK || bBusy)//引擎繁忙则不进行解压操作
        {
            return;
        }
        
        GADMINCODE adminCode = {0};
        adminCode.euRegionCode = eREGION_CODE_CHN;
        adminCode.nAdCode = self.taskId;
        
        enumDBTYPE type = eDB_TYPE_ALL;
        
        GSTATUS rest = [MWEngineTools DeleteCityDB:&adminCode type:type];
        NSLog(@"删除数据：%@,%d",self.title,rest);
        
    }
    
    NSLog(@"deleteData");
    current=0;

    //删除解压后的城市数据
    
    GADMINCODE admin = {0};
    admin.euRegionCode = eREGION_CODE_CHN;
    admin.nAdCode = self.taskId;
    GDATADIRINFO dataDir = {0};
    
    GSTATUS res = [MWAdminCode GetAdareaDirList:&admin nMaxCnt:1 list:&dataDir];
    
    if (res == GD_ERR_OK) {
        NSError *error = nil;
        NSString *fileString = [[NSString alloc] initWithString: GcharToNSString(dataDir.szDir)];
        NSString *path = [NSString stringWithFormat:@"%@%@",Map_Data_Path,fileString];
        [fileString release];
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            //重命名，延迟2s删除
            NSString *renamegdPath = [NSString stringWithFormat:@"%@_del",[path substringToIndex:path.length-1]];
            [[NSFileManager defaultManager] moveItemAtPath:path toPath:renamegdPath error:&error];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)),  dispatch_get_main_queue(), ^{
                [[NSFileManager defaultManager] removeItemAtPath:renamegdPath error:nil];
//                [self performSelectorInBackground:@selector(removefiles:) withObject:renamegdPath ];
            });
            
        }
    }
    
    //删除临时文件和压缩文件
    NSError *error = nil;
    
    if (url && [url length]!=0)
    {
        NSString *gdtmpPath = [[NSString alloc] initWithString:[DataDownload_PATH stringByAppendingFormat:@"%@",[self getFilename]]];
        if([[NSFileManager defaultManager] fileExistsAtPath:gdtmpPath])
        {
            //重命名，延迟2s删除
            NSString *renamegdPath =  [NSString stringWithFormat:@"%@_del",gdtmpPath];
            [[NSFileManager defaultManager] moveItemAtPath:gdtmpPath toPath:renamegdPath error:&error];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)),  dispatch_get_main_queue(), ^{
                [[NSFileManager defaultManager] removeItemAtPath:renamegdPath error:nil];
//                [self performSelectorInBackground:@selector(removefiles:) withObject:renamegdPath ];
            });
        }
        
        NSString *gdPath = [[NSString alloc] initWithString:[DataDownload_PATH stringByAppendingFormat:@"%@.tmp",[self getFilename]]];
        if([[NSFileManager defaultManager] fileExistsAtPath:gdPath])
        {
            //重命名，延迟2s删除
            NSString *renamegdPath = [NSString stringWithFormat:@"%@_del",gdPath];
            [[NSFileManager defaultManager] moveItemAtPath:gdPath toPath:renamegdPath error:&error];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)),  dispatch_get_main_queue(), ^{
                [[NSFileManager defaultManager] removeItemAtPath:renamegdPath error:nil];
//                [self performSelectorInBackground:@selector(removefiles:) withObject:renamegdPath ];
            });
            
        }
        [gdPath release];
        gdPath = nil;
        
        [gdtmpPath release];
        gdtmpPath = nil;
    }
    
}

@end


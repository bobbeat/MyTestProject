//
//  MWCarOwnerServiceTask.m
//  AutoNavi
//
//  Created by longfeng.huang on 14-2-26.
//
//

#import "MWCarOwnerServiceTask.h"
#import "ZipArchive.h"
#import "ANReachability.h"
#import  "UIDevice+Category.h"

@implementation MWCarOwnerServiceTask

@synthesize serviceID,versionCode,serviceName,versionName,vendor,warning,updatedesc,releasetime,form,serviceStatus,iconUrl,vip,md5,servicedesc,folderName,installTime,description,usedesc;

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
	[encoder encodeObject:serviceID forKey:@"tasklist7key"];
	[encoder encodeObject:versionCode forKey:@"tasklist8key"];
    [encoder encodeObject:serviceName forKey:@"tasklist9key"];
	[encoder encodeObject:versionName forKey:@"tasklist10key"];
    [encoder encodeObject:vendor forKey:@"tasklist11key"];
	[encoder encodeObject:warning forKey:@"tasklist12key"];
    [encoder encodeObject:updatedesc forKey:@"tasklist13key"];
	[encoder encodeObject:releasetime forKey:@"tasklist14key"];
	[encoder encodeInt64:form forKey:@"tasklist15key"];
	[encoder encodeInt64:serviceStatus forKey:@"tasklist16key"];
	[encoder encodeInt64:vip forKey:@"tasklist17key"];
	[encoder encodeObject:iconUrl forKey:@"tasklist18key"];
    [encoder encodeObject:md5 forKey:@"tasklist19key"];
	[encoder encodeObject:servicedesc forKey:@"tasklist20key"];
    [encoder encodeObject:folderName forKey:@"tasklist21key"];
    [encoder encodeObject:installTime forKey:@"tasklist22key"];
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
		self.serviceID = [decoder decodeObjectForKey:@"tasklist7key"];
		self.versionCode = [decoder decodeObjectForKey:@"tasklist8key"];
        self.serviceName = [decoder decodeObjectForKey:@"tasklist9key"];
		self.versionName = [decoder decodeObjectForKey:@"tasklist10key"];
        self.vendor = [decoder decodeObjectForKey:@"tasklist11key"];
		self.warning = [decoder decodeObjectForKey:@"tasklist12key"];
        self.updatedesc = [decoder decodeObjectForKey:@"tasklist13key"];
		self.releasetime = [decoder decodeObjectForKey:@"tasklist14key"];
		self.form = [decoder decodeInt64ForKey:@"tasklist15key"];
        self.serviceStatus = [decoder decodeInt64ForKey:@"tasklist16key"];
		self.vip = [decoder decodeInt64ForKey:@"tasklist17key"];
		self.iconUrl = [decoder decodeObjectForKey:@"tasklist18key"];
		self.md5 = [decoder decodeObjectForKey:@"tasklist19key"];
        self.servicedesc = [decoder decodeObjectForKey:@"tasklist20key"];
        self.folderName = [decoder decodeObjectForKey:@"tasklist21key"];
        self.installTime = [decoder decodeObjectForKey:@"tasklist22key"];
	}
	
	return self;
}


// 获取文件存储路径
- (void)createFilepath
{
	if (![[NSFileManager defaultManager] fileExistsAtPath:CarOwnerService_path]) //要是文件目录不存在，创建目录
	{
		[[NSFileManager defaultManager] createDirectoryAtPath:CarOwnerService_path withIntermediateDirectories:NO attributes:nil error:nil];
	}
	
	// 公司内部协议，未完成下载的文件统一未.tmp文件
	filePath = [[NSString alloc] initWithString:[CarOwnerService_path stringByAppendingFormat:@"%@.tmp",filename]];
}

// 执行下载任务
- (void)run
{
    NSLog(@"车主服务下载链接=%@",url);
	//判断url是否为空，如果为空，提示。
	if (url == nil)
	{
        GDAlertView *alertView = [[GDAlertView alloc] initWithTitle:@"Cannot Open the Request!" andMessage:STR(@"CityDownloadManage_urlEmpty",Localize_CityDownloadManage)] ;
        
        [alertView addButtonWithTitle:STR(@"Universal_ok", Localize_Universal) type:GDAlertViewButtonTypeCancel handler:nil];
        [alertView show];
        [alertView release];
        
		return;
	}
	
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
		NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:turl];
        [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
        //[request setNetworkServiceType:NSURLNetworkServiceTypeVoice];
		assert(request != nil);
		URLConnection = [NSURLConnection connectionWithRequest:request delegate:self];
        
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
			NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:turl];
            [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
            //[request setNetworkServiceType:NSURLNetworkServiceTypeVoice];
			assert(request != nil);
			URLConnection = [NSURLConnection connectionWithRequest:request delegate:self];
		}
		else //续传的实现
		{
			fileStream = [NSOutputStream outputStreamToFileAtPath:filePath append:YES];
			[fileStream retain];
			assert(fileStream != nil);
			[fileStream open];
			
			NSURL* turl = [NSURL URLWithString:url];
			NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:turl];
            [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
			//[request setNetworkServiceType:NSURLNetworkServiceTypeVoice];
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


// 数据接收完成
- (void)connectionDidFinishLoading:(NSURLConnection *)aconnection
{
    
	// 通知相应的界面做相应的进度的更新
	[delegate finished:self];
    
    
    
	NSString* destinctionPath = [CarOwnerService_path stringByAppendingFormat:@"%@",filename];
	[destinctionPath retain];
	if ([[NSFileManager defaultManager] fileExistsAtPath:CarOwnerService_path])
	{
		if ([[NSFileManager defaultManager] fileExistsAtPath:destinctionPath])
		{// 移除之前的旧版本数据
			[[NSFileManager defaultManager] removeItemAtPath:destinctionPath error:nil];
		}
		
		// 移动文件
		NSError* err = nil;
        if([[NSFileManager defaultManager] fileExistsAtPath:filePath])
        {
		    [[NSFileManager defaultManager] moveItemAtPath:filePath toPath:destinctionPath error:&err];
        }
		
		// 停止任务，做解压的准备
		[self stopconnection];
		
        //md5校验
        NSString *temp_path = [NSString stringWithFormat:@"%@%@",CarOwnerService_path,[self getFilename]];
        NSString *md5String = [NSString getFileMD5WithPath:temp_path];
        if (![md5String isEqualToString:self.md5]) {
            
            GDAlertView *alertView = [[GDAlertView alloc] initWithTitle:nil andMessage:STR(@"CarService_DownloadCheckMd5",Localize_CarService)] ;
            
            [alertView addButtonWithTitle:STR(@"Universal_ok", Localize_Universal) type:GDAlertViewButtonTypeCancel handler:nil];
            [alertView show];
            [alertView release];
            
            self.current = 0;
            self.status = 4;
            [self erase];
            
            if (destinctionPath)
            {
                [destinctionPath release];
                destinctionPath=nil;
            }
            
            [delegate exception:self exception:[NSError errorWithDomain:@"error_ziparchive" code:DOWNLOADHANDLETYPE_MD5NOMATCH userInfo:nil]];
            return;
        }
        
        
		NSMutableDictionary* threadDict = [[NSThread currentThread] threadDictionary];// 线程传参
		[threadDict setValue:destinctionPath forKey:@"destinctionPath"];
		NSString  *admincode = [NSString stringWithFormat:@"%d",taskId];
		[threadDict setValue:admincode forKey:@"admincode"];
		//[NSThread detachNewThreadSelector:@selector(ZipArchive) toTarget:self withObject:nil];
		mythread = [[NSThread alloc] initWithTarget:self  selector:@selector(ZipArchive) object:nil ];
		[mythread start];//开始启动线程
	}
	
	if (destinctionPath)
	{
		[destinctionPath release];
		destinctionPath=nil;
	}
}

// 删除任务以及任务相关的资源
- (void)erase
{
	// 停止下载任务
	[self stopconnection];
	
	NSError *error;
    
    NSString *fileName = nil;
    NSString *temp_path = [self getFilename];
    fileName = [[NSString alloc] initWithString:[CarOwnerService_path stringByAppendingFormat:@"%@.tmp",temp_path]];
	// 删除临时文件并初始化下载数据
	if (fileName!=nil && [fileName length]!=0)
	{
		if([[NSFileManager defaultManager] fileExistsAtPath:fileName])
		{
			[[NSFileManager defaultManager] removeItemAtPath:fileName error:&error];
		}
	}
    [fileName release];
    
    NSString *zipName = [[NSString alloc] initWithString:[CarOwnerService_path stringByAppendingFormat:@"%@",temp_path]];
    if (zipName) {
        if([[NSFileManager defaultManager] fileExistsAtPath:zipName])
		{
			[[NSFileManager defaultManager] removeItemAtPath:zipName error:&error];
		}
    }
    [zipName release];
    
    NSString *dialectFileName = [[NSString alloc] initWithString:[CarOwnerService_path stringByAppendingFormat:@"%@",serviceID]];
    if([[NSFileManager defaultManager] fileExistsAtPath:dialectFileName])
    {
        [[NSFileManager defaultManager] removeItemAtPath:dialectFileName error:&error];
    }
    [dialectFileName release];
    
    
}

//检测是否有压缩文件未解压
- (void)checkZipFileAndUnZipFile
{
    NSString *gdtmpPath = [NSString stringWithFormat:@"%@%@",CarOwnerService_path,[self getFilename]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:gdtmpPath]) {
        NSMutableDictionary* threadDict = [[NSThread currentThread] threadDictionary];// 线程传参
        [threadDict setValue:gdtmpPath forKey:@"destinctionPath"];
        
        mythread = [[NSThread alloc] initWithTarget:self  selector:@selector(ZipArchive) object:nil ];
        [mythread start];//开始启动线程
    }
    
}

// 解压线程
- (void)ZipArchive
{
	NSAutoreleasePool* pool =[[NSAutoreleasePool alloc] init];
	
	NSMutableDictionary* threadDict = [[NSThread mainThread] threadDictionary];
	NSString* destinctionPath = [[NSString alloc] initWithString:[threadDict valueForKey:@"destinctionPath"]];
	int admincode = [[threadDict valueForKey:@"admincode"] intValue];
	
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
//				[NSThread exit];//终止线程
			}
            
			long long disksize = [UIDevice getCurDiskSpaceInBytes];
			NSDictionary *dic = [[NSFileManager defaultManager] attributesOfItemAtPath:destinctionPath error:nil];
            unsigned long long  size = [dic fileSize];
            if (disksize < size) {
                
                [delegate exception:self exception:[NSError errorWithDomain:@"error_storage" code:DOWNLOADHANDLETYPE_NOSPACE userInfo:nil]];
                
                result = NO;
                break;
            }
			int zaResult = [za UnzipFileTo:CarOwnerService_path overWrite:YES retValue:&ret filesize:disksize];
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
		NSError *error;
        if([[NSFileManager defaultManager] fileExistsAtPath:destinctionPath])
        {
		    [[NSFileManager defaultManager] removeItemAtPath:destinctionPath error:&error];// 解压成功后删除压缩文件
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
    if (serviceID) {
        [serviceID release];
        serviceID = nil;
    }
    if (versionCode) {
        [versionCode release];
        versionCode = nil;
    }
    if (serviceName) {
        [serviceName release];
        serviceName = nil;
    }
    if (versionName) {
        [versionName release];
        versionName = nil;
    }
    if (vendor) {
        [vendor release];
        vendor = nil;
    }
    if (warning) {
        [warning release];
        warning = nil;
    }
    if (updatedesc) {
        [updatedesc release];
        updatedesc = nil;
    }
    if (releasetime) {
        [releasetime release];
        releasetime = nil;
    }
    if (folderName) {
        [folderName release];
        folderName = nil;
    }
    if (iconUrl) {
        [iconUrl release];
        iconUrl = nil;
    }
    if (md5) {
        [md5 release];
        md5 = nil;
    }
    if (servicedesc) {
        [servicedesc release];
        servicedesc = nil;
    }
    if (installTime) {
        [installTime release];
        installTime = nil;
    }
    
    if (description) {
        [description release];
        description = nil;
    }
    
    if (usedesc) {
        [usedesc release];
        usedesc = nil;
    }
    [super dealloc];
    
}

@end

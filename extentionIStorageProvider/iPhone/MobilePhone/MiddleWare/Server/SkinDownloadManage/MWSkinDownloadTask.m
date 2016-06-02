//
//  MWSkinDownloadTask.m
//  AutoNavi
//
//  Created by huang longfeng on 13-11-19.
//
//

#import "MWSkinDownloadTask.h"
#import "ZipArchive.h"
#import "MWSkinDownloadManager.h"
#import "ANReachability.h"
#import  "UIDevice+Category.h"

#define SKIN_PATH [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]//文件最终存放目录
#define SKIN_FILENAME  @"com.skin.pink"
@implementation MWSkinDownloadTask

// 获取文件存储路径
- (void)createFilepath
{
	if (![[NSFileManager defaultManager] fileExistsAtPath:Skin_path]) //要是文件目录不存在，创建目录
	{
		[[NSFileManager defaultManager] createDirectoryAtPath:Skin_path withIntermediateDirectories:NO attributes:nil error:nil];
	}
	
	// 公司内部协议，未完成下载的文件统一未.tmp文件
	filePath = [[NSString alloc] initWithString:[Skin_path stringByAppendingFormat:@"%@.tmp",filename]];
}

// 执行下载任务
- (void)run
{
    NSLog(@"url=%@",url);
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

    if (current < total)
	{
		[self stopconnection];
		[delegate exception:self exception:[NSError errorWithDomain:@"error_currensize" code:DOWNLOADHANDLETYPE_CURRENTSMALLTOTAL userInfo:nil]];
		return;
	}
	// 通知相应的界面做相应的进度的更新
	[delegate finished:self];
    
	NSString* destinctionPath = [Skin_path stringByAppendingFormat:@"%@",filename];
	[destinctionPath retain];
	if ([[NSFileManager defaultManager] fileExistsAtPath:Skin_path])
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
    fileName = [[NSString alloc] initWithString:[Skin_path stringByAppendingFormat:@"%@.tmp",temp_path]];
	// 删除临时文件并初始化下载数据
	if (fileName!=nil && [fileName length]!=0)
	{
		if([[NSFileManager defaultManager] fileExistsAtPath:fileName])
		{
			[[NSFileManager defaultManager] removeItemAtPath:fileName error:&error];
		}
	}
    [fileName release];
    
    NSString *skinFileName = [[NSString alloc] initWithString:[Skin_path stringByAppendingFormat:@"%@",[[GDSkinColor sharedInstance] getFolderByID:self.taskId]]];
    if([[NSFileManager defaultManager] fileExistsAtPath:skinFileName])
    {
        [[NSFileManager defaultManager] removeItemAtPath:skinFileName error:&error];
    }
    [skinFileName release];
    
}

- (void)checkZipFileAndUnZipFile
{
    NSString *gdtmpPath = [NSString stringWithFormat:@"%@%@",Skin_path,[self getFilename]];
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
			int zaResult = [za UnzipFileTo:Skin_path overWrite:YES retValue:&ret filesize:disksize];
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
    [NSThread exit];
}

@end

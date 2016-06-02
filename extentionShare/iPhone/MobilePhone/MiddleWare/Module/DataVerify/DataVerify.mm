//
//  DataVerify.mm
//  New_GNaviServer
//
//  Created by yang yi on 12-3-31.
//  Copyright 2012 autonavi.com. All rights reserved.
//
#import "GDBL_Interface.h"
#import "DataVerify.h"
#import "GDBL_DataVerify.h"
#import "MWSkinDownloadManager.h"


@implementation DataVerify
@synthesize zlibCitysList;

static int unZip = 0;

-(id)init
{
	if (self = [super init])
	{
       
    }
	return self;
}

 /**检测数据版本主流程*/
-(int) runCheckData
{
	dataVerifyResult = DATAVERITY_CHECK_SUCCESS;
    while (!isCheckFinish)
	{
        //检测是否有压缩文件存在
		isZlibOfCitysExist = [self checkZlibOfCitysExist];
		if (isZlibOfCitysExist)
		{
            unZip = 1;
			dataVerifyResult = DATAVERITY_UNCOMPRESS_CITYS_ZLIB;
			break;
		}
        else
        {
            
            //检测基础路网数据是否完整
            isBaseRoadDataExist = [self checkBaseRoadDataExist];
            if (isBaseRoadDataExist)
            {
                //引擎初始化
                static int i = 0;
                if (i++ == 0)
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kEngineInit object:nil];
                }
                
                //dataVerifyResult = CHECK_SUCCESS;
                //break;
               
            }
            else
            {
                //基础资源不存在
                dataVerifyResult = DATAVERITY_BASE_ROAD_DATA_NOT_EXIST;
                break;
                
            }
            
        }
        break;
    }
    return dataVerifyResult;
}

-(void)dealloc
{
    if (zlibCitysList) {
        [zlibCitysList release];
        zlibCitysList = nil;
    }
    
    [super dealloc];
}
#pragma mark public out 

/**进入导航程序*/
-(void) handlerEntryNaviApp
{    
	[[NSNotificationCenter defaultCenter] postNotificationName:kDataVerify object:nil];
}

/**继续下载数据 0:第一次进入下载 1:未下载完成在次进入下载*/
-(void) handerContinuedownLoadState:(int)mapDownState
{
	[[NSNotificationCenter defaultCenter] postNotificationName:kDataDownload object:[NSNumber numberWithInt:mapDownState]];
}

/**退出导航程序*/
-(void) handerQuitApplication
{
    [[UIApplication sharedApplication] exitApplication];//退出导航
}

#pragma mark Private 供内部调用方法

/**验证本地是否有分城市压缩包*/
-(BOOL) checkZlibOfCitysExist
{
    if (zlibCitysList)
    {
        [zlibCitysList release];
        zlibCitysList = nil;
    }
	zlibCitysList= [[self searchFilesInPath:document_path MatchContent:@".zip"]retain];
    return [zlibCitysList count]>0?YES:NO;
}
/**验证本地是否有基础数据*/
-(BOOL) checkBaseRoadDataExist
{
/*    if (![[NSFileManager defaultManager] fileExistsAtPath:navi_PATH]) {
        return NO;
    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:chnOverall_PATH]) {
        return NO;
    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:overall_PATH]) {
        return NO;
    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:download_PATH]) {
        return NO;
    }
    return YES;
 */

    Gbool bhasData = Gfalse;
    GSTATUS res = [MWEngineTools CheckResource:&bhasData];
    
    if (res != GD_ERR_OK || bhasData!=Gtrue) {
        return NO;
    }
    
    bhasData = Gfalse;
    GADMINCODE adminCode;
    adminCode.euRegionCode = eREGION_CODE_NULL;
    adminCode.nAdCode = 0;
    res = [MWEngineTools CheckAdareaData:&adminCode bOk:&bhasData];
    
    if (res != GD_ERR_OK || bhasData!=Gtrue) {
        return NO;
    }
    
    bhasData = Gfalse;
    adminCode.euRegionCode = eREGION_CODE_CHN;
    adminCode.nAdCode = 0;
    res = [MWEngineTools CheckAdareaData:&adminCode bOk:&bhasData];
    
    if (res != GD_ERR_OK || bhasData!=Gtrue) {
        return NO;
    }
    
    return YES;
}

/**
 *获取目录下所有文件
 *rootPath:要查找的路径名称(尾部无需/),matchName:要匹配的结尾名称,nil或""则不验证匹配
 */
-(NSMutableArray*) searchFilesInPath:(NSString *)rootPath MatchContent:(NSString*)matchName
{
    NSFileManager *fileManager = [NSFileManager defaultManager];	
    if (fileManager==nil)
	{
        return nil;
    }
	
	NSError *error = nil;
	
	//fileList便是包含有该文件夹下所有文件的文件名及文件夹名的数组
	NSArray* fileList = [[NSArray alloc]initWithArray:[fileManager contentsOfDirectoryAtPath:rootPath error:&error]] ;
    
    //以下这段代码则可以列出给定一个文件夹里的所有子文件夹名
	NSMutableArray *fileArray = [[[NSMutableArray alloc] init] autorelease];
	BOOL isDir = NO;
    
	//在上面那段程序中获得的fileList中列出文件名
	for (NSString *file in fileList) 
	{
		NSString *path = [rootPath stringByAppendingPathComponent:file];
		[fileManager fileExistsAtPath:path isDirectory:(&isDir)];
		if (isDir) 
		{
			
		}
		else 
		{
			
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
    
    //add by hlf for 解压 DataDownload_PATH 目录下的压缩文件
    NSArray* fileListPath = [[NSArray alloc]initWithArray:[fileManager contentsOfDirectoryAtPath:DataDownload_PATH error:&error]] ;
    for (NSString *file in fileListPath)
	{
		NSString *path = [DataDownload_PATH stringByAppendingPathComponent:file];
		[fileManager fileExistsAtPath:path isDirectory:(&isDir)];
		if (isDir)
		{
			
		}
		else
		{
			
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
    
    [fileListPath release];
	[fileList release];
    
    return fileArray;    
}

@end

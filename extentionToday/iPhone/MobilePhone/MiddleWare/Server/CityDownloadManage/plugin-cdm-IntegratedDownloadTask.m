//
//  plugin-cdm-IntegratedDownloadTask.m
//  plugin-CityDataManager
//
//  Created by GHY on 11-12-9.
//  Copyright 2011 Autonavi. All rights reserved.
//

#import "plugin-cdm-IntegratedDownloadTask.h"
#import "MWCloudDetourManage.h"

#define DOCUMENTS_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]//文件最终存放目录

@implementation IntegratedDownloadTask

// 删除任务以及任务相关的资源
- (void)erase   
{
	// 停止下载任务
	[self stopconnection];
	
	NSError *error;
	
		NSString *Gfname = [self getFilename];
		[Gfname retain];
	if ([Gfname length]!=0) 
	{
		NSString* GPath = [[NSString alloc] initWithString:[DOCUMENTS_FOLDER stringByAppendingFormat:@"/%@",Gfname]];
		if (GPath!=nil) 
		{
			if([[NSFileManager defaultManager] fileExistsAtPath:GPath])
			{
				[[NSFileManager defaultManager] removeItemAtPath:GPath error:&error];
			}
		}
		
		[GPath release];
		GPath = nil;
	}
	
	[Gfname release];
	Gfname = nil;
	
	// 删除临时文件并初始化下载数据
	if (tmpPath!=nil && [tmpPath length]!=0) 
	{
		if([[NSFileManager defaultManager] fileExistsAtPath:tmpPath])
		{
			[[NSFileManager defaultManager] removeItemAtPath:tmpPath error:&error];
		}
		
		[tmpPath release];
		tmpPath = nil;
	}
    
    [[MWCloudDetourManage sharedInstance] removeAllTask];//add by hlf for 删除全国数据同时删除云端避让文件 at 2014.04.02
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
	
	NSString* destinctionPath = [DOCUMENTS_FOLDER stringByAppendingFormat:@"/%@",filename];
	[destinctionPath retain];
	if ([[NSFileManager defaultManager] fileExistsAtPath:DOCUMENTS_FOLDER]) 
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
	}
	
	if (destinctionPath) 
	{
		[destinctionPath release];
		destinctionPath=nil;
	}
}

@end

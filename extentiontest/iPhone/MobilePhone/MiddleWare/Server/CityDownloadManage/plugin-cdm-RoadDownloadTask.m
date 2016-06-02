//
//  plugin-cdm-RoadDownloadTask.m
//  plugin-CityDataManager
//
//  Created by GHY on 11-12-12.
//  Copyright 2011 Autonavi. All rights reserved.
//

#import "plugin-cdm-RoadDownloadTask.h"
#import "MWCloudDetourManage.h"

#define DOCUMENTS_FOLDER [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]//文件最终存放目录

@implementation plugin_cdm_RoadDownloadTask


// 删除任务以及任务相关的资源
- (void)erase   
{
	// 停止下载任务
	[self stopconnection];
	
    //删除城市数据需要告诉引擎
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
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            GSTATUS rest = [MWEngineTools DeleteCityDB:&adminCode type:type];
            NSLog(@"删除数据：%@,%d",self.title,rest);
            
        });
    }

    //删除基础资源文件
    NSError *error = nil;
    if([[NSFileManager defaultManager] fileExistsAtPath:navi_PATH])
    {
        [[NSFileManager defaultManager] removeItemAtPath:navi_PATH error:&error];
    }
    if([[NSFileManager defaultManager] fileExistsAtPath:download_PATH])
    {
        [[NSFileManager defaultManager] removeItemAtPath:download_PATH error:&error];
    }
    if([[NSFileManager defaultManager] fileExistsAtPath:chnOverall_PATH])
    {
        [[NSFileManager defaultManager] removeItemAtPath:chnOverall_PATH error:&error];
    }
    if([[NSFileManager defaultManager] fileExistsAtPath:overall_PATH])
    {
        [[NSFileManager defaultManager] removeItemAtPath:overall_PATH error:&error];
    }
	
   
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
	
	current=0;
	total=0;
    
    [[MWCloudDetourManage sharedInstance] removeAllTask];//add by hlf for 删除基础数据同时删除云端避让文件 at 2014.04.02
}

@end

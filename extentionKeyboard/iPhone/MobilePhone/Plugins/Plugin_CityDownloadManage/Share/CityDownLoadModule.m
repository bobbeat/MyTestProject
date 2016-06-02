//
//  cityDownLoadModule.m
//  AutoNavi
//
//  Created by huang longfeng on 11-12-14.
//  Copyright 2011 autonavi. All rights reserved.
//

#import "CityDownLoadModule.h"
#import "Map_Download.h"
#import "CityDataManagerFirstViewController.h"
#import "plugin-cdm-DownCityDataController.h"
#import "DMDataDownloadManagerViewController.h"

@implementation CityDownLoadModule
//加载地图数据下载模块
// 导航模块调用该方法进入子模块	
//传入:parma NoData无数据时进入的接口; HasData有数据时进入的接口
// 返回值：0失败；1成功
-(int) enter:(NSObject *)param
{
	if ([[(NSDictionary *)param objectForKey:@"parma"] isEqualToString:@"NoData"] ) {      //无完整数据时模块入口
		
		[[TaskManager taskManager] restore];
					
        if ([[TaskManager taskManager].taskList count] == 0) {
            Map_Download   *Map_Download_Controller = [[Map_Download alloc] init];
            [[(NSDictionary *)param objectForKey:@"controller"] pushViewController:Map_Download_Controller animated:NO];
            [Map_Download_Controller release];
            return YES;
        }
        else {
            DMDataDownloadManagerViewController *controll = [[DMDataDownloadManagerViewController alloc] initWithViewType:GDDownloadViewTypeManager DataType:0 CityAdminCodeArray:nil];
            [[(NSDictionary *)param objectForKey:@"controller"] pushViewController:controll animated:YES];
            [controll release];
				
            return YES;
        }
			
		return NO;
	}
	else if([[(NSDictionary *)param objectForKey:@"parma"] isEqualToString:@"HasData"]) {    //从地图升级管理入口进入下载列表
		
			DMDataDownloadManagerViewController *controll = [[DMDataDownloadManagerViewController alloc] initWithViewType:GDDownloadViewTypeManager DataType:1 CityAdminCodeArray:nil];
            [[(NSDictionary *)param objectForKey:@"controller"] pushViewController:controll animated:YES];
            [controll release];
			return YES;
				return NO;
	}
    else if([[(NSDictionary *)param objectForKey:@"parma"] isEqualToString:@"assignDownData"]){
		
        DMDataDownloadManagerViewController *controll = [[DMDataDownloadManagerViewController alloc] initWithViewType:GDDownloadViewTypeList DataType:3 CityAdminCodeArray:(NSDictionary *)[(NSDictionary *)param objectForKey:@"cityAdmincode"]];
        [[(NSDictionary *)param objectForKey:@"controller"] pushViewController:controll animated:YES];
        [controll release];
            
        return YES;

	}
    else if([[(NSDictionary *)param objectForKey:@"parma"] isEqualToString:@"updateAllData"]){
		
        DMDataDownloadManagerViewController *controll = [[DMDataDownloadManagerViewController alloc] initWithViewType:GDDownloadViewTypeManager DataType:3 CityAdminCodeArray:nil];
        [[(NSDictionary *)param objectForKey:@"controller"] pushViewController:controll animated:YES];
        [controll release];
        
        return YES;
        
	}
    
	return NO;
	   
}

-(NSString *)viewControllerName
{
    
    return nil;
    
}

// 导航模块调用该方法离开子模块（一般情况下，子模块是调用backToNavi回到导航主模块）
// 返回值：0失败；1成功
-(int)leave
{
	return YES;
}

// 导航模块调用该方法终止子模块（在导航模块因某种原因而需要退出程序，而此时子模块可能还处于执行中，此时导航模块将调用该方法）
// 返回值：0失败；1成功
-(int)exit
{
	return YES;
}

@end

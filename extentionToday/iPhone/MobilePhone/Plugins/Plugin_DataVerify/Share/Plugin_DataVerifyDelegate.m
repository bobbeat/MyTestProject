//
//  Plugin_DataVerifyDelegate.m
//  plugin_DataVerify
//
//  Created by yi yang on 11-12-16.
//  Copyright (c) 2011年 autonavi.com. All rights reserved.
//

#import "Plugin_DataVerifyDelegate.h"
#import "Plugin_DataVerifyUncompressController.h"
#import "Plugin_DataVerify_Globall.h"
#import "GDBL_DataVerify.h"

@implementation Plugin_DataVerifyDelegate

-(id)init
{
    self =[super init];
    if (self) {
        
    }
    return self;
}
// 导航模块调用该方法进入子模块,param:NSArray* {UINavigationController* navigationController,	NSNumber* type 1:iPhone,0 iPad}
// 返回值：0失败；1成功
-(int) enter:(id)param
{
    
    if ([param isKindOfClass:[NSArray class]]) {
        
        NSArray* values=(NSArray*)param;
        
        if ([values count]>1&&[[values objectAtIndex:0] isKindOfClass:[UINavigationController class]]) {
            UINavigationController* navigation = (UINavigationController*)[values objectAtIndex:0];
			
            //数据检测
            
			int nResult = GDBL_CheckData();
			
            if (nResult == GD_ER_OK)
            {
                
            }
            else if (nResult == GD_ER_DATAUNCOMPRESS)
            {
                NSArray *zlibCitysList= nil;
                if (GDBL_GetDataZlibs(&zlibCitysList) == GD_ERR_OK)
                {
                    Plugin_DataVerifyUncompressController *unCompressController = [[Plugin_DataVerifyUncompressController alloc] initWithFileList:zlibCitysList ZipTodestPath:[NSHomeDirectory() stringByAppendingFormat:@"/Documents/"] DataVerityType:GD_ER_DATAUNCOMPRESS];
                    [navigation pushViewController:unCompressController animated:NO];
                    [unCompressController release];
                }
            }
            else if (nResult == GD_ER_BASELOADDOWNLOADING)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:kDataDownload object:[NSNumber numberWithInt:1]];
            }
            else if (nResult == GD_ER_BASELOADNOTEXIST)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:kDataDownload object:[NSNumber numberWithInt:0]];
            }
			
            return 0;
        }        
    }
    return 0;
    
}

// 导航模块调用该方法离开子模块（一般情况下，子模块是调用backToNavi回到导航主模块）
// 返回值：0失败；1成功
-(int) leave
{
    return 1;
}

// 导航模块调用该方法终止子模块（在导航模块因某种原因而需要退出程序，而此时子模块可能还处于执行中，此时导航模块将调用该方法）
// 返回值：0失败；1成功
-(int) exit
{
    return 1;
}
-(void) dealloc
{
    [super dealloc];
}
@end

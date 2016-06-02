//
//  GDBL_DataVerify.h
//  plugin_DataVerify
//
//  Created by Autonavi on 12-5-4.
//  Copyright 2012 autonavi.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GDBL_Interface.h"
#import "DataVerify.h"

#define ZIPName                       @".zip"              
#define GD_ER_OK				      0x00000040
#define GD_ER_DATAUNCOMPRESS	      0x00000044
#define GD_ER_FAILED			      0x00000045
#define GD_ER_BASELOADDOWNLOADING	  0x00000046
#define GD_ER_BASELOADNOTEXIST		  0x00000048

@interface GDBL_DataVerify : NSObject {
    
}

+(GDBL_DataVerify *)sharedInstance;


GSTATUS GDBL_CheckData();

GSTATUS GDBL_GetDataZlibs(NSArray **dataZlibs);

void GDBL_EntryNaviApp();

/**
 *检测基础资源是否存在
 */
+ (BOOL)checkBaseRoadDataExist;

@end

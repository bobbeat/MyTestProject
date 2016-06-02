//
//  Plugin_DataVerify_Globall.h
//  plugin_DataVerify
//
//  Created by yi yang on 11-12-2.
//  Copyright 2011年 autonavi.com. All rights reserved.
//

#define LANGUAGE_ZH		0
#define LANGUAGE_HK		1
#define LANGUAGE_EN     2
#ifndef plugin_DataVerify_Plugin_DataVerify_Globall_h
#define plugin_DataVerify_Plugin_DataVerify_Globall_h
#define IPHONE5_OFFSET (([[UIScreen mainScreen] currentMode].size.height == 1136.0f) ? (88.0f) : (0.0f))

#define IPHONE5_OFFSET          (([[UIScreen mainScreen] currentMode].size.height == 1136.0f) ? (88.0f) : (0.0f))

#define DATA_GETLANGUAGE fontType
#if 1
#define face_change
#endif


#define DEBUG_INFO 0

int	g_NaviStatus_Interface_Flag;

int g_NaviStatus_interface_orient; //默认可以横竖屏
int g_NaviStatus_interface_state;

typedef enum
{
    ALERT_BASE_ROAD_NOT_INTEGRATED=1,   //基础路网数据不完整
    ALERT_MAP_UNDER_VERSION=2,          //地图版本低于引擎版本
    ALERT_INTEGRATE_UNDER_VERSION=3,    //(一体化数据)地图版本低于引擎版本
    ALERT_UPDATA_APPLICATION=4,         //更新程序
    ALERT_DELETE_DATA_FAIL=5,            //删除数据失败
    
    ALERT_GO_NAVIGATE=6,
    ALERT_GO_DOWNLOAD=7
}AlertType;


#endif

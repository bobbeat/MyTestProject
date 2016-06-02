//
//  CarServiceVarDefine.h
//  AutoNavi
//
//  Created by jiangshu-fu on 14-3-6.
//
//

#ifndef AUTONAVI_CARSERVICE_VAR_DEFINE
#define AUTONAVI_CARSERVICE_VAR_DEFINE

//通知名称
#define CAR_SERVICE_NOTIFICATION_KEY @"CarServiceNotificationKey"

#pragma mark- ---  车主服务项目的级别（默认,推荐,更新,禁用）  ---
//typedef enum CARSERVICE_LEVEL{
//    CARSERVICE_LEVEL_DEFAULT    = 0,    //默认
//    CARSERVICE_LEVEL_RECOMMEND  = 1,    //推荐
//    CARSERVICE_LEVEL_UPDATE     = 2,    //更新
//    CARSERVICE_LEVEL_DISABLE    = 3,    //禁用
//}CARSERVICE_LEVEL;

#define CARSERVICE_DETAIL_LABEL_WIDTH   (isiPhone ? 275.0f : 710.0f)
#define CARSERVICE_ITEMVIEW_HEIGHT      (isiPhone ? 78.0f : 96.0f)

#define CARSERVICE_SAVE_CLOSE_KEY  @"carServiceSaveCloseKey"

#define CAR_SERVICE_MODE_HTML       @"0"
#define CAR_SERVICE_MODE_LOCAL_MODE @"1"
#define CAR_SERVICE_MODE_LOCAL_HTML_HAS_TOOLBAR @"2"

//定义下载下来的plist文件中的字段
#define CAR_SERVICE_ENTRY       @"entry"
#define CAR_SERVICE_ENTRY_PARAM @"entry-param"
#define CAR_SERVICE_FORM        @"form"
#define CAR_SERVICE_TITLE_CN    @"title-cn"
#define CAR_SERVICE_TITLE_EN    @"title-en"
#define CAR_SERVICE_TITLE_TW    @"title-tw"
#define CAR_SERVICE_NEED_LOGIN  @"needLogin"



#endif
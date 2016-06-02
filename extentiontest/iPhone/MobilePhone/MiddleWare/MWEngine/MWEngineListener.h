//
//  MWEngineListener.h
//  AutoNavi
//
//  Created by gaozhimin on 14-7-9.
//
//

#import <Foundation/Foundation.h>

/************************************************************************/
/* 消息ID定义                                                         */
/************************************************************************/
#define WM_USER				      0x0400
#define NOTIFY_SHOWMAP			  @"_SHOWMAP"
#define NOTIFY_UPDATE_VIEWINFO    @"_NOTITY_UPDATE_VIEWINFO"
#define NOTIFY_STARTTODEMO		  @"_STARTDEMO"
#define NOTIFY_STARTTODEMO2		  @"_STARTDEMO2"
#define NOTIFY_UPDATEFAVORITE	  @"_UPDATEFAVORITE"
#define	NOTIFY_GETPOIDATA		  @"_GETPOIDATA"
#define NOTIFY_BUS				  @"_BUS"
#define NOTIFY_TRACKREPLAY		  @"_TRACKREPLAY"
#define NOTIFY_PARALLEL_NOTIFY	  @"_PARALLEL_NOTIFY"
#define NOTIFY_TMCUPDATE_NOTIFY	  @"_TMCUPDATE_NOTIFY"


#define kStartDataVerify          @"DataVerify"
#define kEngineInit               @"EngineInit"
#define kDataVerify               @"DataVerifyBackToNavi"
#define kDataDownload             @"CityDataDownload"
#define NOTIFY_SkinCheckResult    @"SkinCheckResult"      //皮肤更新结果：1.成功 2.取消下载 3.网络连接异常 4.皮肤下载异常 5.皮肤解压异常
#define NOTIFY_HandleUIUpdate     @"HandleUIUpdate" //更新ui通知，传入ui更新枚举类型HMI_UIUpdateType

#define NOTIFY_USERINFO_TMC_OPEN  @"notify_userinfo_tmc_open"   //是否成功开启的 TMC

#define NET_TIMEOUT_SYN          5.0f	//SET CONNECT TIMEOUT INTERVAL
#define NET_TIMEOUT_ASYN         15.0f	//SET CONNECT TIMEOUT INTERVAL

/*!
  @brief 监听引擎通知
  */
@interface MWEngineListener : NSObject

/*
 * @brief: 初始化监听类
 */
+ (MWEngineListener *)sharedInstance;

@end

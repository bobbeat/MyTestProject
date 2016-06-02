//
//  GDBL_LaunchRequest.h
//  AutoNavi
//
//  Created by huang longfeng on 13-5-24.
//
//

#import <Foundation/Foundation.h>
#import "NetKit.h"

#define kLaunchRequestErrorDomain        @"LaunchRequestErrorDomain"//开机请求错误码

@interface GDBL_LaunchRequest : NSObject <NetRequestExtDelegate>

+ (GDBL_LaunchRequest *) sharedInstance;

/**
 用户行为统计上传
 
 @param control NetReqToViewCtrDelegate对象，用于接收请求完成发生的消息
 @see NetReqToViewCtrDelegate
 */
- (BOOL) Net_UserBehaviorCountRequest:(id<NetReqToViewCtrDelegate>) control  withRequestType:(RequestType)type;


/**
 用户偏航统计上传 
 
 @param control NetReqToViewCtrDelegate对象，用于接收请求完成发生的消息
 @see NetReqToViewCtrDelegate
 */
- (BOOL) Net_UserYawCountRequest:(id<NetReqToViewCtrDelegate>) control  withRequestType:(RequestType)type;

/**
 软件版本升级
 
 @param control NetReqToViewCtrDelegate对象，用于接收请求完成发生的消息
 @see NetReqToViewCtrDelegate
 */
- (BOOL) Net_SoftWareVersionUpdateRequest:(id<NetReqToViewCtrDelegate>) control  withRequestType:(RequestType)type;

/**
 网络地图的后台开关控制
 
 @param control NetReqToViewCtrDelegate对象，用于接收请求完成发生的消息
 @see NetReqToViewCtrDelegate
 */
- (BOOL) Net_NetWorkSwitchControlRequest:(id<NetReqToViewCtrDelegate>) control  withRequestType:(RequestType)type;



/**
  上传token至http://iphone.autonavi.com:8080/userToken/token
 */

- (BOOL) Net_UploadTokenWithControl:(id<NetReqToViewCtrDelegate>)control uuid:(NSString *)uuid token:(NSString *)token  withRequestType:(RequestType)type;

//软件升级测试接口
- (BOOL) Net_UpdateAppWithControl:(id<NetReqToViewCtrDelegate>)control withRequestType:(RequestType)type;

/**
 *	开机图片加载
 *  @param  window  父视图
 *
 */
- (void)NET_LaunchImage:(UIWindow *)window;

/**
 *	开机语音请求
 *
 *	@param	control	控制器
 *	@param	type	请求类型
 *
 *	@return	成功 返回yes
 */
- (BOOL)NET_PowerVoiceRequest:(id<NetReqToViewCtrDelegate>)control withRequestType:(RequestType)type;

/**
 *	开机语音下载
 *
 *	@param	control	控制器
 *	@param	voiceUrl 下载链接
 *	@param	type	请求类型
 *
 *	@return	成功 返回yes
 */
- (BOOL)NET_PowerVoiceDownload:(id<NetReqToViewCtrDelegate>)control WithRequestType:(RequestType)type DownloadUrl:(NSString *)voiceUrl;

/*!
  @brief 取消所有请求
  @return 成功返回YES
  */
- (BOOL)Net_CancelAllRequest;

/*!
  @brief 取消某个类型的请求
  @return 成功返回YES
  */
- (BOOL)Net_CancelRequestWithType:(RequestType)requestType;

/**
 *	开机图片后台下载
 *
 *	@param	imageUrl 下载链接
 *	@param	type	请求类型
 *
 *	@return	成功 返回yes
 */
- (BOOL)NET_BackgroundLaunchImageDownload:(id<NetReqToViewCtrDelegate>)control WithRequestType:(RequestType)type DownloadUrl:(NSString *)imageUrl;

/***
 * @name    市场的统计设备信息上传
 * @param	control	控制器
 * @param	type	请求类型
 * @author  by bazinga
 ***/
- (BOOL) Net_MarketBanner;

/*
 @bief 检测动态闪屏屏幕方向
 */
- (void)CheckImageViewDirection:(CGSize)size;


@end

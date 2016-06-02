//
//  SYNetAPI.h
//  SuYun
//
//  Created by yu.liao on 15/5/15.
//  Copyright (c) 2015年 yu.liao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SYNetObj.h"
#import "NetRequest.h"

@protocol SYNetDelegate;

@protocol NetRequestDelegate;

#pragma mark - SYNetAPI Interface

@interface SYNetAPI : NSObject<NetRequestDelegate>

/*!
 @brief 实现了SYNetDelegate协议的类指针
 */
@property (nonatomic, weak) id<SYNetDelegate> delegate;

/*!
 @brief  货主和司机端登录接口
 @param  request 具体属性字段请参考 LoginRequest 类。
 */
- (void)login:(LoginRequest *)request;

/*!
 @brief  货主和司机端注销接口
 @param  request 具体属性字段请参考 LogoutRequest 类。
 */
- (void)logout:(LogoutRequest *)request;

/*!
 @brief  请求短信验证码接口
 @param  request 具体属性字段请参考 VerifyCodeRequest 类。
 */
- (void)getVerifyCode:(VerifyCodeRequest *)request;


/*!
 @brief  图片上传
 @param  request 具体属性字段请参考 UploadImageRequest 类。
 */
- (void)uploadImage:(UploadImageRequest *)request;

/*!
 @brief  司机工作状态上报
 @param  request 具体属性字段请参考 DriverReportStatusRequest 类。
 */
- (void)driverReportStatus:(DriverReportStatusRequest *)request;

/*!
 @brief  司机认证
 @param  request 具体属性字段请参考 DriverAuthRequest 类。
 */
- (void)driverAuth:(DriverAuthRequest *)request;

@end

#pragma mark - SYNetDelegate

/** SYNet errorCode */
typedef NS_ENUM(NSInteger, SYNetErrorCode)
{
//    SYNetErrorSuccess                  = 0,  //成功
//  
//    SYNetErrorInvalidSCode             = 1001, // 用户不存在
//    SYNetErrorInvalidKey               = 1002, // 密码错误
//    SYNetErrorInvalidService           = 1003, // 短信验证码错误
//    SYNetErrorInvalidResponse          = 1004, // 司机用户已存在
//    SYNetErrorInsufficientPrivileges   = 1005, // 短信验证码下发成功
//    SYNetErrorOverQuota                = 1006, // 司机状态上报失败
//    SYNetErrorInvalidParams            = 1007, // 司机实时位置上报失败
//    SYNetErrorInvalidProtocol          = 1008, // 短信验证码过期
//    SYNetErrorInvalidProtocol          = 1009, // 常用路线个数超过限定值
//    SYNetErrorInvalidProtocol          = 1010, // 添加司机到我的车队，司机已存在
//    
//    SYNetErrorInvalidProtocol          = 2001, // 上传图片，服务器异常
//    SYNetErrorInvalidProtocol          = 2002, // 注销服务异常
//    SYNetErrorInvalidProtocol          = 2003, // 验证码下发失败
//    SYNetErrorInvalidProtocol          = 2004, // 订单创建异常
//    SYNetErrorInvalidProtocol          = 2005, // 查询和司机相关订单异常
//    SYNetErrorInvalidProtocol          = 2006, // 查询货主订单异常
//    SYNetErrorInvalidProtocol          = 2007, // 抢单异常
//    SYNetErrorInvalidProtocol          = 2008, // sessionId过期或用户登录其他客户端
//    SYNetErrorInvalidProtocol          = 2009, // 设置常用路线异常
//    SYNetErrorInvalidProtocol          = 2010, // 删除常用路线异常
//    SYNetErrorInvalidProtocol          = 2011, // 查询常用路线列表异常
//    SYNetErrorInvalidProtocol          = 2012, // 货主选择司机异常
//    SYNetErrorInvalidProtocol          = 2013, // 已抢单订单不可取消
//    SYNetErrorInvalidProtocol          = 2014, // 取消订单异常
//    SYNetErrorInvalidProtocol          = 2015, // 货主添加司机到我的车队异常
//    SYNetErrorInvalidProtocol          = 2016, // 货主查询我的车队司机异常
//    SYNetErrorInvalidProtocol          = 2017, // 货主删除我的车队司机异常
//    SYNetErrorInvalidProtocol          = 2018, // 货主查询我的车队司机实时位置异常
//    SYNetErrorInvalidProtocol          = 2019, // 查询推送给司机的订单异常
//    
//    SYNetErrorInvalidProtocol          = 9999, // 服务器异常
    
    SYNetErrorUnknown                  = 1, // 未知错误
    SYNetErrorTimeOut                  = 2, // 网络连接超时
    SYNetErrorCannotFindHost           = 3, // 找不到主机
    SYNetErrorBadURL                   = 4, // URL异常
    SYNetErrorNotConnectedToInternet   = 5, // 网络连接异常
    SYNetErrorCannotConnectToHost      = 6, // 服务器连接失败
    SYNetErrorInvalidResponse          = 7, // 请求服务响应错误
    SYNetErrorParamCode                = 8, // 后台下发的错误码
};

/** SYNet errorDomain */
extern NSString *const SYNetErrorDomain;

/** 对应SYNetErrorParamCode的错误码的key*/
extern NSString *const SYNetErrorParamCodeKey;

@protocol SYNetDelegate <NSObject>

@optional
/*!
 @brief 当请求发生错误时，会调用代理的此方法.
 @param request 发生错误的请求.
 @param error   返回的错误.
 */
- (void)netRequest:(id)request didFailWithError:(NSError *)error;

/*!
 @brief 请求短信验证码的回调函数
 @param request 发起请求的请求选项(具体字段参考GetVerifyCodeRequest类中的定义)
 @param response 请求结果(具体字段参考VerifyCodeResponse类中的定义)
 */
- (void)onVerifyCodeDone:(VerifyCodeRequest *)request response:(VerifyCodeResponse *)response;

/*!
 @brief 登录的回调函数
 @param request 发起请求的请求选项(具体字段参考LoginRequest类中的定义)
 @param response 请求结果(具体字段参考LoginResponse类中的定义)
 */
- (void)onLoginDone:(LoginRequest *)request response:(LoginResponse *)response;

/*!
 @brief 注销的回调函数
 @param request 发起请求的请求选项(具体字段参考LogoutRequest类中的定义)
 @param response 请求结果(具体字段参考LogoutResponse类中的定义)
 */
- (void)onLogoutDone:(LogoutRequest *)request response:(LogoutResponse *)response;

/*!
 @brief 司机工作状态上报
 @param request 发起请求的请求选项(具体字段参考DriverReportStatusRequest类中的定义)
 @param response 请求结果(具体字段参考DriverReportStatusResponse类中的定义)
 */
- (void)onDriverReportStatusDone:(DriverReportStatusRequest *)request response:(DriverReportStatusResponse *)response;

/*!
 @brief 司机认证
 @param request 发起请求的请求选项(具体字段参考DriverReportStatusRequest类中的定义)
 @param response 请求结果(具体字段参考DriverReportStatusResponse类中的定义)
 */
- (void)onDriverAuthDone:(DriverAuthRequest *)request response:(DriverAuthResponse *)response;

/*!
 @brief 图片上传
 @param request 发起请求的请求选项(具体字段参考UploadImageRequest类中的定义)
 @param response 请求结果(具体字段参考UploadImageResponse类中的定义)
 */
- (void)onUploadImageDone:(UploadImageRequest *)request response:(UploadImageResponse *)response;

@end
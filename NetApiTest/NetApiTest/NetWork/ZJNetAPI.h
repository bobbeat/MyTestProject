//
//  ZJNetAPI.h
//  SuYun
//
//  Created by yu.liao on 15/5/15.
//  Copyright (c) 2015年 yu.liao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZJNetObj.h"
#import "NetRequest.h"

@protocol ZJNetDelegate;

@protocol NetRequestDelegate;

#pragma mark - ZJNetAPI Interface

@interface ZJNetAPI : NSObject<NetRequestDelegate>

/*!
 @brief 实现了ZJNetDelegate协议的类指针
 */
@property (nonatomic, weak) id<ZJNetDelegate> delegate;

/*!
 @brief  注册
 @param  request 具体属性字段请参考 RegitsterRequest 类。
 */
- (void)registerAction:(RegitsterRequest *)request;

/*!
 @brief  获取用户信息
 @param  request 具体属性字段请参考 GetUserInfoRequest 类。
 */
- (void)getUserInfoAction:(GetUserInfoRequest *)request;

/*!
 @brief  更改用户信息
 @param  request 具体属性字段请参考 UpdateUserInfoRequest 类。
 */
- (void)updateUserInfoAction:(UpdateUserInfoRequest *)request;

/*!
 @brief  添加车辆信息
 @param  request 具体属性字段请参考 AddCarInfoRequest 类。
 */
- (void)addCarInfoAction:(AddCarInfoRequest *)request;

/*!
 @brief  添加车辆信息
 @param  request 具体属性字段请参考 UpdateCarInfoRequest 类。
 */
- (void)updateCarInfoAction:(UpdateCarInfoRequest *)request;

/*!
 @brief  获取车辆信息
 @param  request 具体属性字段请参考 GetCarInfoRequest 类。
 */
- (void)getCarInfoAction:(GetCarInfoRequest *)request;
/*!
 @brief  登录接口
 @param  request 具体属性字段请参考 LoginRequest 类。
 */
- (void)loginAction:(LoginRequest *)request;

/*!
 @brief  获取城市窗口信息
 @param  request 具体属性字段请参考 GetCityInfoRequest 类。
 */
- (void)getCityInfoAction:(GetCityInfoRequest *)request;

/*!
 @brief  获取任务图片资源
 @param  request 具体属性字段请参考 ResGetRequest 类。
 */
- (void)getTaskResAction:(GetTaskResRequest *)request;

/*!
 @brief  获取用户图片资源
 @param  request 具体属性字段请参考 GetUserResRequest 类。
 */
- (void)getUserResAction:(GetUserResRequest *)request;

/*!
 @brief  获取任务详情
 @param  request 具体属性字段请参考 GetTaskDetailRequest 类。
 */
- (void)getTaskDetailAction:(GetTaskDetailRequest *)request;

/*!
 @brief  获取用户任务信息
 @param  request 具体属性字段请参考 GetUserTaskInfoRequest 类。
 */
- (void)getUserTaskInfoAction:(GetUserTaskInfoRequest *)request;

/*!
 @brief  申请任务接口
 @param  request 具体属性字段请参考 ApplyTaskRequest 类。
 */
- (void)applyTaskAction:(ApplyTaskRequest *)request;
/*!
 @brief  注销接口
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


@end

#pragma mark - ZJNetDelegate

/** ZJNet errorCode */
typedef NS_ENUM(NSInteger, ZJNetErrorCode)
{
//    ZJNetErrorSuccess                  = 0,  //成功
//  
//    ZJNetErrorInvalidSCode             = 1001, // 用户不存在
//    ZJNetErrorInvalidKey               = 1002, // 密码错误
//    ZJNetErrorInvalidService           = 1003, // 短信验证码错误
//    ZJNetErrorInvalidResponse          = 1004, // 司机用户已存在
//    ZJNetErrorInsufficientPrivileges   = 1005, // 短信验证码下发成功
//    ZJNetErrorOverQuota                = 1006, // 司机状态上报失败
//    ZJNetErrorInvalidParams            = 1007, // 司机实时位置上报失败
//    ZJNetErrorInvalidProtocol          = 1008, // 短信验证码过期
//    ZJNetErrorInvalidProtocol          = 1009, // 常用路线个数超过限定值
//    ZJNetErrorInvalidProtocol          = 1010, // 添加司机到我的车队，司机已存在
//    
//    ZJNetErrorInvalidProtocol          = 2001, // 上传图片，服务器异常
//    ZJNetErrorInvalidProtocol          = 2002, // 注销服务异常
//    ZJNetErrorInvalidProtocol          = 2003, // 验证码下发失败
//    ZJNetErrorInvalidProtocol          = 2004, // 订单创建异常
//    ZJNetErrorInvalidProtocol          = 2005, // 查询和司机相关订单异常
//    ZJNetErrorInvalidProtocol          = 2006, // 查询货主订单异常
//    ZJNetErrorInvalidProtocol          = 2007, // 抢单异常
//    ZJNetErrorInvalidProtocol          = 2008, // sessionId过期或用户登录其他客户端
//    ZJNetErrorInvalidProtocol          = 2009, // 设置常用路线异常
//    ZJNetErrorInvalidProtocol          = 2010, // 删除常用路线异常
//    ZJNetErrorInvalidProtocol          = 2011, // 查询常用路线列表异常
//    ZJNetErrorInvalidProtocol          = 2012, // 货主选择司机异常
//    ZJNetErrorInvalidProtocol          = 2013, // 已抢单订单不可取消
//    ZJNetErrorInvalidProtocol          = 2014, // 取消订单异常
//    ZJNetErrorInvalidProtocol          = 2015, // 货主添加司机到我的车队异常
//    ZJNetErrorInvalidProtocol          = 2016, // 货主查询我的车队司机异常
//    ZJNetErrorInvalidProtocol          = 2017, // 货主删除我的车队司机异常
//    ZJNetErrorInvalidProtocol          = 2018, // 货主查询我的车队司机实时位置异常
//    ZJNetErrorInvalidProtocol          = 2019, // 查询推送给司机的订单异常
//    
//    ZJNetErrorInvalidProtocol          = 9999, // 服务器异常
    
    ZJNetErrorUnknown                  = 1, // 未知错误
    ZJNetErrorTimeOut                  = 2, // 网络连接超时
    ZJNetErrorCannotFindHost           = 3, // 找不到主机
    ZJNetErrorBadURL                   = 4, // URL异常
    ZJNetErrorNotConnectedToInternet   = 5, // 网络连接异常
    ZJNetErrorCannotConnectToHost      = 6, // 服务器连接失败
    ZJNetErrorInvalidResponse          = 7, // 请求服务响应错误
    ZJNetErrorParamCode                = 8, // 后台下发的错误码
};

/** ZJNet errorDomain */
extern NSString *const ZJNetErrorDomain;

/** 对应ZJNetErrorParamCode的错误码的key*/
extern NSString *const ZJNetErrorParamCodeKey;

@protocol ZJNetDelegate <NSObject>

@optional
/*!
 @brief 当请求发生错误时，会调用代理的此方法.
 @param request 发生错误的请求.
 @param error   返回的错误.
 */
- (void)netRequest:(id)request didFailWithError:(NSError *)error;

/*!
 @brief 请求注册的回调函数
 @param request 发起请求的请求选项(具体字段参考RegitsterRequest类中的定义)
 @param response 请求结果(具体字段参考RegitsterResponse类中的定义)
 */
- (void)onRegisterDone:(RegitsterRequest *)request response:(RegitsterResponse *)response;

/*!
 @brief 获取用户信息的回调函数
 @param request 发起请求的请求选项(具体字段参考GetUserInfoRequest类中的定义)
 @param response 请求结果(具体字段参考GetUserInfoResponse类中的定义)
 */
- (void)onGetUserInfoDone:(GetUserInfoRequest *)request response:(GetUserInfoResponse *)response;

/*!
 @brief 更新用户信息的回调函数
 @param request 发起请求的请求选项(具体字段参考UpdateUserInfoRequest类中的定义)
 @param response 请求结果(具体字段参考UpdateUserInfoResponse类中的定义)
 */
- (void)onUpdateUserInfoDone:(UpdateUserInfoRequest *)request response:(UpdateUserInfoResponse *)response;

/*!
 @brief 添加车辆信息的回调函数
 @param request 发起请求的请求选项(具体字段参考AddCarInfoRequest类中的定义)
 @param response 请求结果(具体字段参考AddCarInfoResponse类中的定义)
 */
- (void)onAddCarInfoDone:(AddCarInfoRequest *)request response:(AddCarInfoResponse *)response;

/*!
 @brief 更新车辆信息的回调函数
 @param request 发起请求的请求选项(具体字段参考AddCarInfoRequest类中的定义)
 @param response 请求结果(具体字段参考AddCarInfoResponse类中的定义)
 */
- (void)onUpdateCarInfoDone:(UpdateCarInfoRequest *)request response:(UpdateCarInfoResponse *)response;

/*!
 @brief 获取车辆信息的回调函数
 @param request 发起请求的请求选项(具体字段参考GetCarInfoRequest类中的定义)
 @param response 请求结果(具体字段参考GetCarInfoResponse类中的定义)
 */
- (void)onGetCarInfoDone:(GetCarInfoRequest *)request response:(GetCarInfoResponse *)response;
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
 @brief 获取城市窗口任务信息的回调函数
 @param request 发起请求的请求选项(具体字段参考GetCityInfoRequest类中的定义)
 @param response 请求结果(具体字段参考GetCityInfoResponse类中的定义)
 */
- (void)onGetCityInfoDone:(GetCityInfoRequest *)request response:(GetCityInfoResponse *)response;

/*!
 @brief 获取资源的回调函数
 @param request 发起请求的请求选项(具体字段参考GetTaskResRequest类中的定义)
 @param response 请求结果(具体字段参考GetTaskResResponse类中的定义)
 */
- (void)onGetResDone:(GetTaskResRequest *)request response:(GetTaskResResponse *)response;

/*!
 @brief 获取用户资源的回调函数
 @param request 发起请求的请求选项(具体字段参考GetUserResRequest类中的定义)
 @param response 请求结果(具体字段参考GetUserResResponse类中的定义)
 */
- (void)onGetUserResDone:(GetUserResRequest *)request response:(GetUserResResponse *)response;

/*!
 @brief 获取任务详情的回调函数
 @param request 发起请求的请求选项(具体字段参考GetTaskDetailRequest类中的定义)
 @param response 请求结果(具体字段参考GetTaskDetailResponse类中的定义)
 */
- (void)onGetTaskDetailDone:(GetTaskDetailRequest *)request response:(GetTaskDetailResponse *)response;

/*!
 @brief 获取用户任务信息的回调函数
 @param request 发起请求的请求选项(具体字段参考GetUserTaskInfoRequest类中的定义)
 @param response 请求结果(具体字段参考GetUserTaskInfoResponse类中的定义)
 */
- (void)onGetUserTaskInfoDone:(GetUserTaskInfoRequest *)request response:(GetUserTaskInfoResponse *)response;

/*!
 @brief 申请任务回调
 @param request 发起请求的请求选项(具体字段参考ApplyTaskRequest类中的定义)
 @param response 请求结果(具体字段参考ApplyTaskResponse类中的定义)
 */
- (void)onApplyTaskDone:(ApplyTaskRequest *)request response:(ApplyTaskResponse *)response;
/*!
 @brief 注销的回调函数
 @param request 发起请求的请求选项(具体字段参考LogoutRequest类中的定义)
 @param response 请求结果(具体字段参考LogoutResponse类中的定义)
 */
- (void)onLogoutDone:(LogoutRequest *)request response:(LogoutResponse *)response;

/*!
 @brief 图片上传
 @param request 发起请求的请求选项(具体字段参考UploadImageRequest类中的定义)
 @param response 请求结果(具体字段参考UploadImageResponse类中的定义)
 */
- (void)onUploadImageDone:(UploadImageRequest *)request response:(UploadImageResponse *)response;

@end
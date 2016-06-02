//
//  NetRequest.h
//  SuYun
//
//  Created by yu.liao on 15/5/19.
//  Copyright (c) 2015年 yu.liao. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NetRequestCondition;

@protocol NetRequestDelegate;

/*!
 @brief 网络请求对象
 */
@interface NetRequest : NSObject<NSURLConnectionDelegate>
{
    NSURLConnection                 *connection;
    NSMutableData                   *responseData;

}

/*!
 @brief 实现了NetRequestDelegate协议的类指针
 */
@property (nonatomic, weak) id<NetRequestDelegate>       delegate;

/*!
 @brief 网络请求基本参数
 */
@property (nonatomic, strong) NetRequestCondition         *requestCondition;

/*!
 @brief 网络请求对象
 @param condition 网络请求的基本参数。具体属性字段参考 NetRequestCondition 类
 @param delegate  实现了NetRequestDelegate协议的类指针
 */
+ (NetRequest *)requestWithCondition:(NetRequestCondition *)condition delegate:(id<NetRequestDelegate>)delegate;


/*!
 @brief 开启和断开网络连接
 */
- (void)connect;
- (void)disconnect;

@end

#pragma mark - NetRequestDelegate

/** Net errorCode */
typedef NS_ENUM(NSInteger, NetErrorCode)
{
    NetErrorUnknown                  = 1, // 未知错误
    NetErrorTimeOut                  = 2, // 网络连接超时
    NetErrorCannotFindHost           = 3, // 找不到主机
    NetErrorBadURL                   = 4, // URL异常
    NetErrorNotConnectedToInternet   = 5, // 网络连接异常
    NetErrorCannotConnectToHost      = 6, // 服务器连接失败
    NetErrorInvalidResponse          = 7, // 请求服务响应错误
};

/** Net ErrorDomain */
extern NSString *const NetErrorDomain;

/** StatusCode: userinfo's key in NetErrorDomain*/
extern NSString *const NetErrorFailingStatusCodeKey;

@protocol NetRequestDelegate <NSObject>

/*!
 @brief 当请求发生错误时，会调用代理的此方法.
 @param request 发生错误的请求.
 @param error   返回的错误.
 */
- (void)request:(NetRequest *)request didFailWithError:(NSError *)error;

/*!
 @brief 网络请求回调函数
 @param request 发起的网络请求(具体字段参考NetRequest类中的定义)
 @param data     后台下发的数据
 */
- (void)request:(NetRequest *)request didFinishLoadingWithData:(NSData *)data;

@end
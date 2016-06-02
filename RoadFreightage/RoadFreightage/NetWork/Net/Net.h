//
//  Net.h
//  SuYun
//
//  Created by yu.liao on 15/5/19.
//  Copyright (c) 2015年 yu.liao. All rights reserved.
//

#import <Foundation/Foundation.h>

//#define kNetRequestStringBoundary        @"----------httppost123--" //分隔符

@class  NetRequest;

@class  NetRequestCondition;

@protocol NetRequestDelegate;
/*!
 @brief  网络请求对象集合
 */
@interface Net : NSObject
{
    NSMutableSet *requests;
}

+ (Net *)sharedInstance;

/*!
 @brief 添加网络请求对象
 @param condition 网络请求的基本参数。具体属性字段参考 NetRequestCondition 类
 @param delegate  实现了NetRequestDelegate协议的类指针
 */
- (NetRequest *)requestWithCondition:(NetRequestCondition *)condition delegate:(id<NetRequestDelegate>)delegate;

/*!
 @brief 取消集合中的某个类型的网络请求
 */
- (void)cancelRequestWithType:(NSInteger)requestType;

/*!
 @brief 取消集合中的所有网络请求
 */
- (void)cancelAllRequests;

@end

/*!
 @brief  base64编码
 */
@interface NSString (Base64Encoding)

+ (NSString *)base64Encoding:(NSData *)data;

@end

/*!
 @brief  body包含UIImage和NSData对象的可变字典按固定格式转换成服务器可识别的数据，
        HTTPHeaderField:[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"multipart/form-data; boundary=%@",netRequestStringBoundary  ],@"Content-Type", nil]
 */
extern NSString *const netRequestStringBoundary; //分隔符

@interface NSMutableData (PostBodyHasRawData)

+ (NSMutableData *)postBodyHasRawData:(NSMutableDictionary *)dictionary;

@end

//
//  NetRequestCondition.h
//  SuYun
//
//  Created by yu.liao on 15/5/19.
//  Copyright (c) 2015年 yu.liao. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 @brief 网络请求的基本参数
 */

@interface NetRequestCondition : NSObject

/*!
  @brief 请求ID
  */
@property (nonatomic,assign) int requestID;

/*!
  @brief 请求超时时间 若是 0 为默认值，默认为 12s
  @see
  */
@property (nonatomic,assign) NSInteger timeout;

/*!
  @brief URL的基础，例如 www.xxx.com?x=1&y=2 那么此baceURL表示 www.xxx.com?部分
  */
@property (nonatomic,copy) NSString  *baceURL;

/*!
  @brief 请求方式 两种：1 @"GET"(默认) 2 @"POST"，默认是 @"GET"
  */
@property (nonatomic,copy) NSString  *httpMethod;

/*!
  @brief URL中参数的字典，如 www.xxx.com?x=1&y=2  中 x=1&y=2 部分，
 便可用字典组装成 [NSDictionary dictionaryWithObjectsAndKeys:@"1",@"x",@"2",@"y", nil]
  */
@property (nonatomic,retain) NSMutableDictionary  *urlParams;

/*!
  @brief 请求时，http头域的字典，如 [request setValue:@"text/html" forHTTPHeaderField:@"Content-Type"];
 便可用字典组装成 [NSDictionary dictionaryWithObjectsAndKeys:@"@"text/html"",@"Content-Type", nil]
  */
@property (nonatomic,retain) NSMutableDictionary  *httpHeaderFieldParams;

/*!
  @brief @"POST"上传方式时，http所带body
  */
@property (nonatomic,retain) NSData       *bodyData;


/*!
  @brief NetRequestCondition 对象
  */
+ (instancetype)requestCondition;


@end

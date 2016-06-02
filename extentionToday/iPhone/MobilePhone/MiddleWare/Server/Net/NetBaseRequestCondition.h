//
//  NetBaseRequestCondition.h
//  AutoNavi
//
//  Created by gaozhimin on 13-7-25.
//
//

#import <Foundation/Foundation.h>
#import "NetTypedef.h"

/**!
  @brief 请求条件的基类
  **/
@interface NetBaseRequestCondition : NSObject

/*!
  @brief 请求类型
  @see RequestType
  */
@property (nonatomic,assign) RequestType requestType;

/*!
  @brief 请求超时时间 若是0为默认值（异步12s,同步10s）
  @see
  */
@property (nonatomic,assign) int timeout;

/*!
  @brief URL的基础，例如 www.xxx.com?x=1&y=2 那么此baceURL表示 www.xxx.com?部分
  */
@property (nonatomic,copy) NSString  *baceURL;

/*!
  @brief 请求方式 两种：1 @"GET" 2 @"POST"
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
  @brief 返回一个自动释放的 NetBaseRequestCondition 对象
  */
+ (id)requestCondition;

@end

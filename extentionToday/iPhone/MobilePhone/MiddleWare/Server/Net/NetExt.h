//
//  NetExt.h
//  AutoNavi
//
//  Created by yu.liao on 13-5-14.
//
//

#import <Foundation/Foundation.h>
#import "NetRequestExt.h"
#import "NetConstant.h"
#import "NetOperation.h"
#import "NetBaseRequestCondition.h"

@protocol NetRequestExtDelegate;
@protocol NetSynRequestExtDelegate;

@interface NetExt : NSObject
{
    NSMutableSet *requests;
    NSOperationQueue *m_operationQueue;
}

+ (NetExt *)sharedInstance;

/**
 * @brief 异步请求调用接口
 *
 *	@param	condition	请求条件
 *
 *	@param	delegate	回调委托，各自模块调用时传入，用于接收服务器返回的消息  @see NetSynRequestExtDelegate
 *
 *	@return	返回NetRequestExt对象
 */
- (NetRequestExt *)requestWithCondition:(NetBaseRequestCondition *)condition delegate:(id<NetRequestExtDelegate>)delegate;

/**
 *  @brief	异步取消请求接口，取消对应requestType的请求
 *
 *	@param	requestType	请求条件
 *
 *	@return	返回YES
 */
- (void)Net_CancelRequestWithType:(RequestType)requestType;

/**
 *  @brief	异步取消所有请求接口
 *
 *	@return	返回YES
 */
- (void)cancelAllRequests;

/**
 *  @brief	同步请求调用接口
 *
 *	@param	condition	请求条件
 *
 *	@param	delegate	回调委托，各自模块调用时传入，用于接收服务器返回的消息 @see NetSynRequestExtDelegate
 *
 *	@return	返回NetOperation对象
 */
- (NetOperation *)synRequestWithCondition:(NetBaseRequestCondition *)condition delegate:(id<NetSynRequestExtDelegate>)delegate;

/**
 *  @brief	同步取消请求接口，取消对应requestType的请求
 *
 *	@param	requestType	请求条件
 *
 *	@return	返回YES
 */
- (void)cancelOperationWithType:(RequestType)requestType;

/**
 *  @brief	同步取消所有请求接口
 *
 *	@return	返回YES
 */
- (void)cancelAllOperation;



/**
 *  @brief	字典转化为json数据,ImageEncode为图片编码方式
 *
 *	@param	dictionary	需要转换成JSON的字典
 *
 *	@param	imageEncode	是否需要Base64位编码
 *
 *	@return	返回Json数据
 */
- (NSData *)DictionaryToJSON:(NSMutableDictionary *)dictionary ImageEncode:(ImageEncode)imageEncode;


/**
 *  @brief	将字典转换成表单数据
 *
 *	@param	dictionary	需要转换成表单的字典
 *
 *	@return	返回表单数据
 */
- (NSMutableData *)postBodyData:(NSMutableDictionary *)dictionary;



@end

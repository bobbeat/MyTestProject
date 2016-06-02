//
//  NetRequestExtDelegate.h
//  AutoNavi
//
//  Created by yu.liao on 13-5-14.
//
//

#import <Foundation/Foundation.h>
#import "NetRequestExt.h"
#import "NetOperation.h"

/**
 *  @brief	异步、同步回调委托
 */
@protocol NetRequestExtDelegate <NSObject>

/**
 *  @brief	异步请求失败回调委托
 *
 *	@param	request	自定义NetRequestExt对象，其中有包含请求条件，delegate对象 @see NetRequestExt
 *
 *	@param	error 通常有三种错误 ，
 一:网络超时 NSURLErrorTimedOut
 二:网络连接错误 除NSURLErrorTimedOut外，其他系统返回的值皆为网络连接错误，如:NSURLErrorCannotFindHost、NSURLErrorCannotConnectToHost等 
 三:服务器挂掉，自定义的error,当error的成员变量domain值为宏KNetResponseErrorDomain时，便是此类型的Error。如果终端需要提示，需提示"服务器返回内容异常，HTTP error(error.code)" 其中HTTP error后面要跟error的成员变量code
 *
 */
- (void)request:(NetRequestExt *)request didFailWithError:(NSError *)error;

/**
 *  @brief	异步请求成功回调委托
 *
 *	@param	request	自定义NetRequestExt对象，其中有包含请求条件，delegate对象 @see NetRequestExt
 *
 *	@param	data	服务器下发的数据
 *
 */
- (void)request:(NetRequestExt *)request didFinishLoadingWithData:(NSData *)data;

@end


@protocol NetSynRequestExtDelegate <NSObject>


/**
 *  @brief	同步请求失败回调委托
 *
 *	@param	operation	自定义NetRequestExt对象，其中有包含请求条件，delegate对象 @see NetOperation
 *
 *	@param	error 通常有三种错误 ，
 一:网络超时 NSURLErrorTimedOut
 二:网络连接错误 除NSURLErrorTimedOut外，其他系统返回的值皆为网络连接错误，如:NSURLErrorCannotFindHost、NSURLErrorCannotConnectToHost等
 三:服务器挂掉，自定义的error,当error的成员变量domain值为宏KNetResponseErrorDomain时，便是此类型的Error。如果终端需要提示，需提示"服务器返回内容异常，HTTP error(error.code)" 其中HTTP error后面要跟error的成员变量code
 *
 */
- (void)synRequest:(NetOperation *)operation didFailWithError:(NSError *)error;

/**
 *  @brief	同步请求成功回调委托
 *
 *	@param	operation	自定义NetRequestExt对象，其中有包含请求条件，delegate对象 @see NetOperation
 *
 *	@param	data	服务器下发的数据
 *
 */
- (void)synRequest:(NetOperation *)operation didFinishLoadingWithData:(NSData *)data;

@end
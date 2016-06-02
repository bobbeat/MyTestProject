//
//  NetReqToViewCtrDelegate.h
//  AutoNavi
//
//  Created by yu.liao on 13-5-14.
//
//

#import <Foundation/Foundation.h>

/**
 *  @brief	上层回调委托
 */
@protocol NetReqToViewCtrDelegate <NSObject>

/**
 *  @brief	请求成功回调委托
 *
 *	@param	RequestType	请求类型
 *
 *	@param	result	对下发数据进行处理过后的结果，id类型可以是NSDictionary NSArray
 *
 */
- (void)requestToViewCtrWithRequestType:(RequestType)requestType didFinishLoadingWithResult:(id)result;

/**
 *  @brief	请求失败回调委托
 *
 *	@param	RequestType	请求类型
 *
 *	@param	error	错误信息，上层需根据error的值来判断网络连接超时还是网络连接错误
 *
 */
- (void)requestToViewCtrWithRequestType:(RequestType)requestType didFailWithError:(NSError *)error;

@end

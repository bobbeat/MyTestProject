//
//  MWFeedBackRequest.h
//  AutoNavi
//
//  Created by weisheng on 14-6-11.
//
//

#import <Foundation/Foundation.h>
#import "MWFeedbackRequestCondition.h"
@interface MWFeedBackRequest : NSObject<NetRequestExtDelegate>
{
    
}
@property(assign ,nonatomic)id<NetReqToViewCtrDelegate>feedBackDelegate;
+(MWFeedBackRequest *)sharedInstance;

#pragma mark AOS 后台反馈
#pragma mark 用户反馈的接口
/**
 *	用户反馈的接口
 *
 *	@param	type	请求类型
 *	@param	delegate	回调委托
 *  @param  description 反馈问题的具体描述
 *	@return	成功返回GD_ERR_OK, 失败返回对应出错码
 */
- (void)Net_FeedbackGetUser:(MWFeedbackFunctionCondition *)description requestType:(RequestType)type delegate:(id<NetReqToViewCtrDelegate>)delegate;
#pragma mark POI点报错的接口
/**
 *	POI点报错的接口
 *  @param  poi    poi点的具体信息
 *	@param	type	请求类型
 *	@param	delegate	回调委托
 *  @param  description 反馈问题的具体描述
 *	@return	成功返回GD_ERR_OK, 失败返回对应出错码
 */
- (void)Net_FeedbackGetUserFromPoi:(MWPoi *)poi withDescription:(MWFeedbackFunctionCondition *)description  requestType:(RequestType)type delegate:(id<NetReqToViewCtrDelegate>)delegate;

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
@end

//
//  MWNetSearchOperator.h
//  AutoNavi
//
//  Created by gaozhimin on 14-2-25.
//
//

#import <Foundation/Foundation.h>
#import "MWNetSearchOption.h"
#import "NetKit.h"
#import "XMLDictionary.h"
/**  网络请求接口返回状态码说明
 
 状态码        说明
 0000       成功取得结果
 0011       验证签名错误
 1001       请求 xml 格式错误
 1002
 1003       syscode 参数为空
 1004       参与鉴权的其余参数均为空(除 syscode 和 sign 外的参数)
 1005       sign 参数为空
 1006       鉴权失败
 1007       鉴权接口访问失败
 1008       servcode参数为空
 */
@interface MWNetSearchOperator : NSObject
{

}
/*
 *	POI搜索、交叉路口搜索请求接口
 *	@param	type	请求类型
 *	@param	option	POI搜索、交叉路口搜索条件
 *	@param	delegate	回调委托
 *	@return 成功返回GD_ERR_OK, 失败返回对应出错码 注：GD_ERR_NET_FAILED 表示未连接网络
 */

+ (GSTATUS)MWNetKeywordSearchWith:(RequestType)type  option:(MWNetKeyWordSearchOption *)option delegate:(id<NetReqToViewCtrDelegate>)delegate;

/**
 *	周边搜索请求接口
 *
 *	@param	type	请求类型
 *	@param	option	周边搜索条件
 *	@param	delegate回调委托
 *
 *	@return 成功返回GD_ERR_OK, 失败返回对应出错码 注：GD_ERR_NET_FAILED 表示未连接网络
 */

+ (GSTATUS)MWNetAroundSearchWith:(RequestType)type  option:(MWNetAroundSearchOption *)option delegate:(id<NetReqToViewCtrDelegate>)delegate;
/**
 *	沿线周边搜索请求接口
 *
 *	@param	type	请求类型
 *	@param	option	沿线周边搜索条件
 *	@param	delegate回调委托
 *
 *	@return 成功返回GD_ERR_OK, 失败返回对应出错码 注：GD_ERR_NET_FAILED 表示未连接网络
 */
+ (GSTATUS)MWNetLineArroundSearchWith:(RequestType)type  option:(MWNetLineSearchOption *)option delegate:(id<NetReqToViewCtrDelegate>)delegate;

/**
 *	目的地请求接口
 *
 *	@param	type	请求类型
 *	@param	option	目的地请求接口条件
 *	@param	delegate回调委托
 *
 *	@return 成功返回GD_ERR_OK, 失败返回对应出错码 注：GD_ERR_NET_FAILED 表示未连接网络
 */

+ (GSTATUS)MWNetParkStopSearchWith:(RequestType)type  option:(MWNetParkStopSearchOption *)option delegate:(id<NetReqToViewCtrDelegate>)delegate;
/**
 *	取消请求接口
 *
 *	@param	type	取消请求的类型
 *
 */
+ (void)MWCancelNetSearchWith:(RequestType)type;
@end

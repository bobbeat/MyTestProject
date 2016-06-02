//
//  MWICallRequest.h
//  AutoNavi
//
//  Created by weisheng on 14-6-11.
//
//

#import <Foundation/Foundation.h>

@interface MWICallRequest : NSObject<NetRequestExtDelegate>
@property(assign ,nonatomic)id<NetReqToViewCtrDelegate>icallNetDelegate;
+(MWICallRequest *)sharedInstance;
#pragma mark 人工导航接口
#pragma mark 判断当前的有没有绑定手机号码
/*
 *	接口用于实现客户端 //判断当前的有没有绑定手机号码
 *
 *	@param	type	请求类型
 *	@param	phone	绑定的电话号码
 *	@param	license_val	验证码
 *	@param	delegate	回调委托
 *
 *	@return	成功返回GD_ERR_OK, 失败返回对应出错码
 */
- (void)Net_accountGet95190PhoneWith:(RequestType)type delegate:(id<NetReqToViewCtrDelegate>)delegate;
#pragma mark 获取手机号的验证码

/*
 *	智驾绑定手机号时的验证码
 *
 *	@param	type	请求类型
 *	@param	phone	绑定智驾的手机号码
 *	@param	delegate	委托回调
 *
 *	@return	成功返回GD_ERR_OK, 失败返回对应出错码
 */
- (void)Net_accountGet95190CheckNumberWith:(RequestType)type phone:(NSString *)phone delegate:(id<NetReqToViewCtrDelegate>)delegate;
#pragma mark 客户端向服务端绑定用于95190服务的电话号码
/**
 *	接口用于实现客户端向服务端绑定用于95190服务的电话号码。
 *
 *	@param	type	请求类型
 *	@param	phone	绑定的电话号码
 *	@param	license_val	验证码
 *	@param	delegate	回调委托
 *
 *	@return	成功返回GD_ERR_OK, 失败返回对应出错码
 */
- (void)Net_accountBind95190PhoneWith:(RequestType)type phone:(NSString *)phone license_val:(NSString *)license_val delegate:(id<NetReqToViewCtrDelegate>)delegate;
#pragma mark 修改95190服务的电话号码
/*
 *	接口用于实现客户端向服务端修改95190服务的电话号码。
 *
 *	@param	type	请求类型
 *	@param	phone	绑定的电话号码
 *	@param	license_val	验证码
 *	@param	delegate	回调委托
 *
 *	@return	成功返回GD_ERR_OK, 失败返回对应出错码
 */
- (void)Net_accountModify95190PhoneWith:(RequestType)type phone:(NSString *)phone license_val:(NSString *)license_val delegate:(id<NetReqToViewCtrDelegate>)delegate;

#pragma mark 知服务端拨打95190电话
/** 66666666
 *	用于实现客户端通知服务端拨打95190电话。
 *
 *	@param	phone	手机号码
 *	@param	type	请求类型
 *	@param	delegate	回调委托
 *
 *	@return	成功返回GD_ERR_OK, 失败返回对应出错码
 */
- (void)Net_accountPreCall95190With:(RequestType)type phone:(NSString *)phone delegate:(id<NetReqToViewCtrDelegate>)delegate;

#pragma mark 拨打电话后 获取目的地
/*
 *	此接口用于实现客户端从服务端获取当前用户通过95190设置的目的地(拨打电话后设置),（拨打电话后获取刚设置的目的）。
 *
 *	@param	type	请求类型
 *	@param	phone	绑定的手机号码
 *	@param	delegate	回调委托
 *
 *	@return	成功返回GD_ERR_OK, 失败返回对应出错码
 */
- (void)Net_accountGetCurrentDesWith:(RequestType)type phone:(NSString *)phone delegate:(id<NetReqToViewCtrDelegate>)delegate;

#pragma mark 获取上一次用户通过95190设置的目的地
/*
 *	实现客户端从服务端获取上一次用户通过95190设置的目的地。
 *
 *	@param	type	请求类型
 *	@param	delegate	回调委托
 *
 *	@return	成功返回GD_ERR_OK, 失败返回对应出错码
 */
- (void)Net_accountGetOldDestinationWith:(RequestType)type phone:(NSString *)phone delegate:(id<NetReqToViewCtrDelegate>)delegate;

/*
 *	接口用于根据错误码提示响应的问题
 *	@param	errorCode	错误码
 */
-(void)getErrorCodeType:(int)errorCode;
@end

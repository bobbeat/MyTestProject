//
//  MWAccountOperator.h
//  AutoNavi
//
//  Created by gaozhimin on 13-9-8.
//
//

#import <Foundation/Foundation.h>
#import "NetKit.h"

@interface MWAccountOperator : NSObject
/**
 *	登出
 *
 *	@param	type	请求类型
 *  @param	delegate    回调委托
 *	@return	成功返回GD_ERR_OK, 失败返回对应出错码
 *
 */
+ (GSTATUS)accountLogoutWith:(RequestType)type delegate:(id<NetReqToViewCtrDelegate>)delegate;

/**
 *	第三方登录
 *
 *	@param	tpuserid	第三方用户唯一码
 *	@param	tpusername	第三方用户名
 *	@param	tptype	第三方类型 1:新浪微博 2：腾讯微博
 *	@param	delegate	回调委托
 *
 *	@return	成功返回GD_ERR_OK, 失败返回对应出错码
 */
+ (GSTATUS)accountThirdLoginWith:(RequestType)type  tpuserid:(NSString *)tpuserid tpusername:(NSString *)tpusername tptype:(NSString *)tptype delegate:(id<NetReqToViewCtrDelegate>)delegate;

/**
 *	高德账户登录
 *
 *	@param	type	请求类型
 *	@param	phone	用户名
 *	@param	password	密码
 *	@param	vtype	登陆类型 1：邮箱 2：手机		
 *	@param	delegate	回调委托
 *
 *	@return	成功返回GD_ERR_OK, 失败返回对应出错码
 */
+ (GSTATUS)accountLoginWith:(RequestType)type phone:(NSString *)phone password:(NSString *)password  type:(NSString *)vtype  delegate:(id<NetReqToViewCtrDelegate>)delegate;

/**
 *	重置密码
 *
 *	@param	type	请求类型
 *	@param	phone	手机号
 *	@param	newpw	新密码
 *	@param	delegate	回调委托
 *
 *	@return	成功返回GD_ERR_OK, 失败返回对应出错码
 */
+ (GSTATUS)accountResetPwdWith:(RequestType)type phone:(NSString *)phone newpw:(NSString *)newpw  delegate:(id<NetReqToViewCtrDelegate>)delegate;

/**
 *	修改密码
 *
 *	@param	type	请求类型
 *	@param	oldpw	旧密码
 *	@param	newpw	新密码
 *	@param	tpuserid	第三方id
 *	@param	tptype	第三方类型 1:新浪微博 2：腾讯微博
 *	@param	delegate	回调委托
 *
 *	@return	成功返回GD_ERR_OK, 失败返回对应出错码
 */
+ (GSTATUS)accountModifyPwdWith:(RequestType)type oldpw:(NSString *)oldpw newpw:(NSString *)newpw  tpuserid:(NSString *)tpuserid tptype:(NSString *)tptype delegate:(id<NetReqToViewCtrDelegate>)delegate;

/**
 *	邮箱重置密码
 *
 *	@param	type	请求类型
 *	@param	email	邮箱
 *	@param	delegate	回调委托
 *
 *	@return	成功返回GD_ERR_OK, 失败返回对应出错码
 */
+ (GSTATUS)accountSendEmailWith:(RequestType)type email:(NSString *)email delegate:(id<NetReqToViewCtrDelegate>)delegate;

/**
 *	获取用户信息
 *
 *	@param	type	请求类型
 *	@param	tpuserid	第三方id
 *	@param	tptype	第三方类型 1:新浪微博 2：腾讯微博
 *	@param	delegate	回调委托
 *
 *	@return	成功返回GD_ERR_OK, 失败返回对应出错码
 */
+ (GSTATUS)accountGetProfileWith:(RequestType)type tpuserid:(NSString *)tpuserid tptype:(NSString *)tptype delegate:(id<NetReqToViewCtrDelegate>)delegate;

/**
 *	注册
 *
 *	@param	type	请求类型
 *	@param	phone	用户名
 *	@param	szPwd	密码
 *	@param	tpuserid	第三方id
 *	@param	tptype	第三方类型 1:新浪微博 2：腾讯微博
 *	@param	delegate	回调委托
 *
 *	@return	成功返回GD_ERR_OK, 失败返回对应出错码
 */
+ (GSTATUS)accountRegistWith:(RequestType)type phone:(NSString *)phone szPwd:(NSString *)szPwd tpuserid:(NSString *)tpuserid tptype:(NSString *)tptype delegate:(id<NetReqToViewCtrDelegate>)delegate;

/**
 *	用户下载头像图片
 *
 *	@param	type    请求类型
 *	@param	imagepath	下载图片的路径
 *	@param	tpuserid	第三方id
 *	@param	tptype	第三方类型 1:新浪微博 2：腾讯微博
 *	@param	delegate	回调委托
 *
 *	@return	成功返回GD_ERR_OK, 失败返回对应出错码
 */
+ (GSTATUS)accountGetHeadWith:(RequestType)type imagepath:(NSString *)imagepath tpuserid:(NSString *)tpuserid tptype:(NSString *)tptype delegate:(id<NetReqToViewCtrDelegate>)delegate;

/**
 *	此接口用于用户上传头像   支持终端裁剪或者不裁剪，不裁剪的情况需终端给出裁剪区域，后台裁剪后的头像为50×50.
 *  上传文件格式限制：.jpg/.jpeg/.png/.gif'/.tiff'/.bmp
 *  上传文件大小限制：小于2M
 *
 *	@param	type	请求类型
 *	@param	image	上传图片
 *	@param	rect	裁剪区域
 *	@param	tpuserid	第三方id
 *	@param	tptype	第三方类型 1:新浪微博 2：腾讯微博
 *	@param	delegate	回调委托
 *
 *	@return	成功返回GD_ERR_OK, 失败返回对应出错码
 */
+ (GSTATUS)accountUploadHeadWith:(RequestType)type image:(UIImage *)image rect:(CGRect)rect tpuserid:(NSString *)tpuserid tptype:(NSString *)tptype delegate:(id<NetReqToViewCtrDelegate>)delegate;

/**
 *	获取手机验证码，以支持后续的手机绑定。
 *
 *	@param	type	请求类型
 *	@param	phone	欲绑定11位手机号码
 *	@param	vtype	获取验证码类型
 *	@param	delegate	委托回调
 *
 *	@return	成功返回GD_ERR_OK, 失败返回对应出错码
 */
+ (GSTATUS)accountGetPhoneCheckNumberWith:(RequestType)type phone:(NSString *)phone vtype:(NSString *)vtype delegate:(id<NetReqToViewCtrDelegate>)delegate;


/**
 *	智驾绑定手机号时的验证码
 *
 *	@param	type	请求类型
 *	@param	phone	绑定智驾的手机号码
 *	@param	delegate	委托回调
 *
 *	@return	成功返回GD_ERR_OK, 失败返回对应出错码
 */
+ (GSTATUS)accountGet95190CheckNumberWith:(RequestType)type phone:(NSString *)phone delegate:(id<NetReqToViewCtrDelegate>)delegate;

/**
 *	此接口用于实现用户通过短信验证码进行下一步的注册
 *
 *	@param	type	请求类型
 *	@param	phone	手机号码
 *	@param	license_val	验证码
 *	@param	delegate	回调委托
 *
 *	@return	成功返回GD_ERR_OK, 失败返回对应出错码
 */
+ (GSTATUS)accountCheckCodeWith:(RequestType)type phone:(NSString *)phone license_val:(NSString *)license_val delegate:(id<NetReqToViewCtrDelegate>)delegate;

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
+ (GSTATUS)accountBind95190PhoneWith:(RequestType)type phone:(NSString *)phone license_val:(NSString *)license_val delegate:(id<NetReqToViewCtrDelegate>)delegate;

/**
 *	接口用于实现客户端向服务端修改95190服务的电话号码。
 *
 *	@param	type	请求类型
 *	@param	phone	绑定的电话号码
 *	@param	license_val	验证码
 *	@param	delegate	回调委托
 *
 *	@return	成功返回GD_ERR_OK, 失败返回对应出错码
 */
+ (GSTATUS)accountModify95190PhoneWith:(RequestType)type phone:(NSString *)phone license_val:(NSString *)license_val delegate:(id<NetReqToViewCtrDelegate>)delegate;

/**
 *	接口用于实现客户端向服务端修改95190服务的电话号码。
 *
 *	@param	type	请求类型
 *	@param	phone	绑定的电话号码
 *	@param	license_val	验证码
 *	@param	delegate	回调委托
 *
 *	@return	成功返回GD_ERR_OK, 失败返回对应出错码
 */
+ (GSTATUS)accountGet95190PhoneWith:(RequestType)type delegate:(id<NetReqToViewCtrDelegate>)delegate;

/**
 *	此接口用于实现客户端向服务端解除已绑定用于95190服务的电话号码。
 *
 *	@param	type   请求类型
 *	@param	delegate    委托回调
 *  
 *	@return 成功返回GD_ERR_OK, 失败返回对应出错码
 */
+ (GSTATUS)accountClear95190PhoneWith:(RequestType)type delegate:(id<NetReqToViewCtrDelegate>)delegate;

/**
 *	实现客户端从服务端获取上一次用户通过95190设置的目的地。
 *
 *	@param	type	请求类型
 *	@param	delegate	回调委托
 *
 *	@return	成功返回GD_ERR_OK, 失败返回对应出错码
 */
+ (GSTATUS)accountGetOldDestinationWith:(RequestType)type phone:(NSString *)phone delegate:(id<NetReqToViewCtrDelegate>)delegate;

/**
 *	此接口用于实现客户端从服务端获取当前用户95190的服务状态。
 *
 *	@param	type	请求类型
 *	@param	delegate	回调委托
 *
 *	@return	成功返回GD_ERR_OK, 失败返回对应出错码
 */
+ (GSTATUS)accountGet95190StatusWith:(RequestType)type delegate:(id<NetReqToViewCtrDelegate>)delegate;

/**
 *	此接口用于实现客户端向服务端验证用户订购95190服务有效性。
 *
 *	@param	type	请求类型
 *	@param	phone	电话号码
 *	@param	body	收据
 *	@param	delegate	回调委托
 *
 *	@return	成功返回GD_ERR_OK, 失败返回对应出错码
 */
+ (GSTATUS)accountBuy95190ServiceWith:(RequestType)type phone:(NSString *)phone body:(NSString *)body delegate:(id<NetReqToViewCtrDelegate>)delegate;

/**
 *	此接口用于实现修改用户信息。
 *
 *	@param	type	请求类型
 *	@param	nickName	昵称
 *	@param	province	省
 *	@param	city	市
 *	@param	birthday	出生日期
 *	@param	signature	签名
 *	@param	sex	性别
 *	@param	firstname	姓氏
 *	@param	tpuserid	第三方id
 *	@param	tptype	第三方类型 1 新浪 2腾讯
 *	@param	delegate	回调委托
 *
 *	@return	成功返回GD_ERR_OK, 失败返回对应出错码
 */
+ (GSTATUS)accountUpadataProfileWith:(RequestType)type nickName:(NSString *)nickName province:(NSString *)province city:(NSString *)city birthday:(NSString *)birthday signature:(NSString *)signature sex:(NSString *)sex firstname:(NSString *)firstname tpuserid:(NSString *)tpuserid tptype:(NSString *)tptype delegate:(id<NetReqToViewCtrDelegate>)delegate;

/**
 *	此接口用于旧用户绑定手机，绑定成功后可以用手机进行登录。
 *
 *	@param	type	请求类型
 *	@param	phone	绑定的手机号码
 *	@param	delegate	回调委托
 *
 *	@return	成功返回GD_ERR_OK, 失败返回对应出错码
 */
+ (GSTATUS)accountOldBindPhoneWith:(RequestType)type phone:(NSString *)phone delegate:(id<NetReqToViewCtrDelegate>)delegate;

/**
 *	接口用于实现客户端向服务端申请使用95190免费30天服务。
 *
 *	@param	type	请求类型
 *	@param	phone	手机
 *	@param	delegate	回调委托
 *
 *	@return	成功返回GD_ERR_OK, 失败返回对应出错码
 */
+ (GSTATUS)accountFree95190With:(RequestType)type phone:(NSString *)phone delegate:(id<NetReqToViewCtrDelegate>)delegate;

/**
 *	用于实现客户端通知服务端拨打95190电话。
 *
 *	@param	phone	手机号码
 *	@param	type	请求类型
 *	@param	delegate	回调委托
 *
 *	@return	成功返回GD_ERR_OK, 失败返回对应出错码
 */
+ (GSTATUS)accountPreCall95190With:(RequestType)type phone:(NSString *)phone delegate:(id<NetReqToViewCtrDelegate>)delegate;

/**
 *	此接口用于实现客户端从服务端获取当前用户通过95190设置的目的地(拨打电话后设置),（拨打电话后获取刚设置的目的）。
 *
 *	@param	type	请求类型
 *	@param	phone	绑定的手机号码
 *	@param	delegate	回调委托
 *
 *	@return	成功返回GD_ERR_OK, 失败返回对应出错码
 */
+ (GSTATUS)accountGetCurrentDesWith:(RequestType)type phone:(NSString *)phone delegate:(id<NetReqToViewCtrDelegate>)delegate;

/**
 *	此接口用于实现客户端从服务端获取95190订购任务栏文字信息
 *
 *	@param	type	请求类型
 *	@param	delegate	回调委托
 *
 *	@return	成功返回GD_ERR_OK, 失败返回对应出错码
 */
+ (GSTATUS)accountGet95190TextWith:(RequestType)type delegate:(id<NetReqToViewCtrDelegate>)delegate;

/**
 *	此接口用于实现客户端从服务端获取95190按钮信息
 *
 *	@param	type	请求类型
 *	@param	delegate	回调委托
 *
 *	@return	成功返回GD_ERR_OK, 失败返回对应出错码
 */
+ (GSTATUS)accountGet95190ButtonWith:(RequestType)type delegate:(id<NetReqToViewCtrDelegate>)delegate;


/**
 *	此接口用于实现取消所有请求
 *
 *	@return	成功返回GD_ERR_OK, 失败返回对应出错码
 */
+ (GSTATUS)accountCancelAllReq;

/**
 *	此接口用于取消某类请求
 *
 *	@return	成功返回GD_ERR_OK, 失败返回对应出错码
 */
+ (GSTATUS)accountCancelReqWith:(RequestType)type;

/**
 *	取消对应委托的请求
 *
 *	@param	delegate	对应委托
 *
 *	@return	@return	成功返回GD_ERR_OK, 失败返回对应出错码
 */
+ (GSTATUS)accountCancelReqWithdelegate:(id<NetReqToViewCtrDelegate>)delegate;

/**********************************************************************
 * 函数名称: accountGetInfo
 * 功能描述: 获取账号信息
 * 输入参数:
 
 * 输出参数: array
 
 数组顺序   取出类型            值说明
 0          int                登陆状态 0未登录，1老用户登录，2新用户登录，3新浪微博帐号登录，4腾讯微博帐号登录，5 新浪帐号绑定高德帐号 6 腾讯帐号绑定高德帐号
 1        NSString             账户名 (手机或者邮箱)
 2        NSString             密码
 3        NSString             昵称
 4         NSData              图片
 5        NSString             第三方uuid，若登陆状态为3或5，则是新浪UUID；若是4或6，则为腾讯UUID
 6        NSString             第三方账户名
 7        NSString             UserId      (必定有值)
 * 返 回 值: 成功返回GD_ERR_OK, 失败返回对应出错码
 * 修改日期			版本号		修改人		修改内容
 * ---------------------------------------------------------------------
 * 2012/12/27        1.0		高志闽
 **********************************************************************/
+ (GSTATUS)accountGetInfo:(NSArray **)array;
@end

//
//  MWAccountOperator.m
//  AutoNavi
//
//  Created by gaozhimin on 13-9-8.
//
//

#import "MWAccountOperator.h"
#import "Account.h"
#import "MWAccountDealData.h"

@implementation MWAccountOperator

/**
 *	登出
 *
 *	@param	type	请求类型
 *  @param	delegate    回调委托
 *	@return	成功返回GD_ERR_OK, 失败返回对应出错码
 *
 */
+ (GSTATUS)accountLogoutWith:(RequestType)type delegate:(id<NetReqToViewCtrDelegate>)delegate
{
//    [MWAccountOperator accountCancelAllReq];  //退出登陆时  取消所有请求

    NetBaseRequestCondition *condition = [NetBaseRequestCondition requestCondition];
    condition.baceURL = [NSString stringWithFormat:@"%@%@",kNetDomain,HEAD_LOGOUT];
    condition.requestType = type;
    condition.httpMethod = @"GET";
    
    MWAccountDealData *deal = [MWAccountDealData  createDealingWith:type delegate:delegate];   //创建请求监听对象
    NetRequestExt* request = [[NetExt sharedInstance] requestWithCondition:condition delegate:deal]; //开始请求
    if (request == nil)
    {
        return GD_ERR_FAILED;
    }
    return GD_ERR_OK;

}

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
+ (GSTATUS)accountThirdLoginWith:(RequestType)type  tpuserid:(NSString *)tpuserid tpusername:(NSString *)tpusername tptype:(NSString *)tptype delegate:(id<NetReqToViewCtrDelegate>)delegate
{
    NSMutableDictionary *loginParam=[[[NSMutableDictionary alloc] init] autorelease];
    
    if ([deviceTokenEx length] > 0)
    {
        [loginParam setObject:deviceTokenEx forKey:@"token"];
    }
    if (tpuserid)
    {
        [loginParam setObject:tpuserid forKey:@"tpuserid"];
    }
    if (tpusername)
    {
        [loginParam setObject:tpusername forKey:@"tpusername"];
    }
	if (deviceID)
    {
        [loginParam setObject:deviceID forKey:@"uuid"];
    }
    
    
    NSString *sign = [[NSString stringWithFormat:@"%@%@%@",deviceID,tpuserid,KEY_MD5] stringFromMD5];
    if (sign)
    {
        [loginParam setObject:sign forKey:@"sign"];
    }
    
    if (tptype)
    {
        [loginParam setObject:tptype forKey:@"tptype"];
    }
    
    
	NetBaseRequestCondition *condition = [NetBaseRequestCondition requestCondition];
    condition.baceURL = [NSString stringWithFormat:@"%@%@",kNetDomain,HEAD_THIRD_LOGIN];
    condition.requestType = type;
    condition.urlParams = loginParam;
    condition.httpMethod = @"GET";
    
    MWAccountDealData *deal = [MWAccountDealData  createDealingWith:type delegate:delegate];   //创建请求监听对象
    NetRequestExt* request = [[NetExt sharedInstance] requestWithCondition:condition delegate:deal]; //开始请求
    if (request == nil)
    {
        return GD_ERR_FAILED;
    }
    return GD_ERR_OK;

}

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
+ (GSTATUS)accountLoginWith:(RequestType)type phone:(NSString *)phone password:(NSString *)password  type:(NSString *)vtype  delegate:(id<NetReqToViewCtrDelegate>)delegate
{
    NSMutableDictionary *loginParam=[[[NSMutableDictionary alloc] init] autorelease];
    
    if (deviceID)
    {
        [loginParam setObject:deviceID forKey:@"uuid"];
    }
    
    if ([deviceTokenEx length] > 0)
    {
        [loginParam setObject:deviceTokenEx forKey:@"token"];
    }
    if (password)
    {
        [loginParam setObject:password forKey:@"password"];
    }
    if (vtype)
    {
        [loginParam setObject:vtype forKey:@"type"];
    }
	
    if (phone)
    {
        if ([vtype isEqualToString:@"1"])
        {
            [loginParam setObject:phone forKey:@"email"];
        }
        else
        {
            [loginParam setObject:phone forKey:@"phone"];
        }
    }
    
    
    [[Account AccountInstance] setAccountName:phone Password:password];
    
	NetBaseRequestCondition *condition = [NetBaseRequestCondition requestCondition];
    condition.baceURL = [NSString stringWithFormat:@"%@%@",kNetDomain,HEAD_LOGIN];
    condition.requestType = type;
    condition.urlParams = loginParam;
    condition.httpMethod = @"GET";
    
    MWAccountDealData *deal = [MWAccountDealData  createDealingWith:type delegate:delegate];   //创建请求监听对象
    NetRequestExt* request = [[NetExt sharedInstance] requestWithCondition:condition delegate:deal]; //开始请求
    if (request == nil)
    {
        return GD_ERR_FAILED;
    }
    return GD_ERR_OK;
}

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
+ (GSTATUS)accountResetPwdWith:(RequestType)type phone:(NSString *)phone newpw:(NSString *)newpw  delegate:(id<NetReqToViewCtrDelegate>)delegate
{
    NSMutableDictionary *modifyPwdParam=[[[NSMutableDictionary alloc] init] autorelease];
    if (phone)
    {
        [modifyPwdParam setObject:phone forKey:@"phone"];
    }
    if (newpw)
    {
        [modifyPwdParam setObject:newpw forKey:@"newpw"];
    }
    
    
	
    
	NetBaseRequestCondition *condition = [NetBaseRequestCondition requestCondition];
    condition.baceURL = [NSString stringWithFormat:@"%@%@",kNetDomain,HEAD_RESET_PWD];
    condition.requestType = type;
    condition.urlParams = modifyPwdParam;
    condition.httpMethod = @"GET";
    
    MWAccountDealData *deal = [MWAccountDealData  createDealingWith:type delegate:delegate];   //创建请求监听对象
    NetRequestExt* request = [[NetExt sharedInstance] requestWithCondition:condition delegate:deal]; //开始请求
    if (request == nil)
    {
        return GD_ERR_FAILED;
    }
    return GD_ERR_OK;
}

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
+ (GSTATUS)accountModifyPwdWith:(RequestType)type oldpw:(NSString *)oldpw newpw:(NSString *)newpw  tpuserid:(NSString *)tpuserid tptype:(NSString *)tptype delegate:(id<NetReqToViewCtrDelegate>)delegate
{
    NSMutableDictionary *modifyPwdParam=[[[NSMutableDictionary alloc] init] autorelease];
    if (oldpw)
    {
        [modifyPwdParam setObject:oldpw forKey:@"oldpw"];
    }
    if (newpw)
    {
        [modifyPwdParam setObject:newpw forKey:@"newpw"];
    }
    
    if (tptype)
    {
        [modifyPwdParam setObject:tptype forKey:@"tptype"];
    }
    if (tpuserid)
    {
        [modifyPwdParam setObject:tpuserid forKey:@"tpuserid"];
    }
	

	NSArray *array = [[Account AccountInstance] getAccountInfo];
    [[Account AccountInstance] setAccountName:[array objectAtIndex:1] Password:newpw];
    
	NetBaseRequestCondition *condition = [NetBaseRequestCondition requestCondition];
    condition.baceURL = [NSString stringWithFormat:@"%@%@",kNetDomain,HEAD_UPDATE_PWD];
    condition.requestType = type;
    condition.urlParams = modifyPwdParam;
    condition.httpMethod = @"GET";
    
    MWAccountDealData *deal = [MWAccountDealData  createDealingWith:type delegate:delegate];   //创建请求监听对象
    NetRequestExt* request = [[NetExt sharedInstance] requestWithCondition:condition delegate:deal]; //开始请求
    if (request == nil)
    {
        return GD_ERR_FAILED;
    }
    return GD_ERR_OK;
}

/**
 *	邮箱重置密码
 *
 *	@param	type	请求类型
 *	@param	email	邮箱
 *	@param	delegate	回调委托
 *
 *	@return	成功返回GD_ERR_OK, 失败返回对应出错码
 */
+ (GSTATUS)accountSendEmailWith:(RequestType)type email:(NSString *)email delegate:(id<NetReqToViewCtrDelegate>)delegate
{
    NSMutableDictionary *modifyPwdParam=[[[NSMutableDictionary alloc] init] autorelease];
    if (email)
    {
        [modifyPwdParam setObject:email forKey:@"email"];
    }
    
	NetBaseRequestCondition *condition = [NetBaseRequestCondition requestCondition];
    condition.baceURL = [NSString stringWithFormat:@"%@%@",kNetDomain,HEAD_SEND_PWD_EMAIL];
    condition.requestType = type;
    condition.urlParams = modifyPwdParam;
    condition.httpMethod = @"GET";
    
    MWAccountDealData *deal = [MWAccountDealData  createDealingWith:type delegate:delegate];   //创建请求监听对象
    NetRequestExt* request = [[NetExt sharedInstance] requestWithCondition:condition delegate:deal]; //开始请求
    if (request == nil)
    {
        return GD_ERR_FAILED;
    }
    return GD_ERR_OK;
}

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
+ (GSTATUS)accountGetProfileWith:(RequestType)type tpuserid:(NSString *)tpuserid tptype:(NSString *)tptype delegate:(id<NetReqToViewCtrDelegate>)delegate
{
    NSMutableDictionary *getProfileParams=[[[NSMutableDictionary alloc] init] autorelease];
    if (tptype)
    {
        [getProfileParams setObject:tptype forKey:@"tptype"];
    }
    if (tpuserid)
    {
        [getProfileParams setObject:tpuserid forKey:@"tpuserid"];
    }
	
    NetBaseRequestCondition *condition = [NetBaseRequestCondition requestCondition];
    condition.baceURL = [NSString stringWithFormat:@"%@%@",kNetDomain,HEAD_GET_PROFILE];
    condition.requestType = type;
    condition.urlParams = getProfileParams;
    condition.httpMethod = @"GET";
    
    MWAccountDealData *deal = [MWAccountDealData  createDealingWith:type delegate:delegate];   //创建请求监听对象
    NetRequestExt* request = [[NetExt sharedInstance] requestWithCondition:condition delegate:deal]; //开始请求
    if (request == nil)
    {
        return GD_ERR_FAILED;
    }
    return GD_ERR_OK;
}

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
+ (GSTATUS)accountRegistWith:(RequestType)type phone:(NSString *)phone szPwd:(NSString *)szPwd tpuserid:(NSString *)tpuserid tptype:(NSString *)tptype delegate:(id<NetReqToViewCtrDelegate>)delegate
{
    [[Account AccountInstance] setAccountName:phone Password:szPwd];
	NSMutableDictionary *registParams=[[[NSMutableDictionary alloc] init] autorelease];
    if (phone)
    {
        [registParams setObject:phone forKey:@"phone"];
        [registParams setObject:phone forKey:@"username"];
    }
    if (szPwd)
    {
        [registParams setObject:szPwd forKey:@"password"];
    }
    if (deviceID) {
        [registParams setObject:deviceID forKey:@"uuid"];
    }
    if (tpuserid)
    {
        [registParams setObject:tpuserid forKey:@"tpuserid"];
    }
    
    if (tptype)
    {
        [registParams setObject:tptype forKey:@"tptype"];
    }
    
    NetBaseRequestCondition *condition = [NetBaseRequestCondition requestCondition];
    condition.baceURL = [NSString stringWithFormat:@"%@%@",kNetDomain,HEAD_REGIST];
    condition.requestType = type;
    condition.urlParams = registParams;
    condition.httpMethod = @"GET";
    
    MWAccountDealData *deal = [MWAccountDealData  createDealingWith:type delegate:delegate];   //创建请求监听对象
    NetRequestExt* request = [[NetExt sharedInstance] requestWithCondition:condition delegate:deal]; //开始请求
    if (request == nil)
    {
        return GD_ERR_FAILED;
    }
    return GD_ERR_OK;
}

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
+ (GSTATUS)accountGetHeadWith:(RequestType)type imagepath:(NSString *)imagepath tpuserid:(NSString *)tpuserid tptype:(NSString *)tptype delegate:(id<NetReqToViewCtrDelegate>)delegate
{
    NSMutableDictionary *getAuthPicparams=[[[NSMutableDictionary alloc] init] autorelease];
    if (imagepath)
    {
        [getAuthPicparams setObject:imagepath forKey:@"imagepath"];
    }
    
	if (tpuserid)
    {
        [getAuthPicparams setObject:tpuserid forKey:@"tpuserid"];
    }
    if (tptype)
    {
        [getAuthPicparams setObject:tptype forKey:@"tptype"];
    }
    
    NetBaseRequestCondition *condition = [NetBaseRequestCondition requestCondition];
    condition.baceURL = [NSString stringWithFormat:@"%@%@",kNetDomain,HEAD_GET_HEAD];
    condition.requestType = type;
    condition.urlParams = getAuthPicparams;
    condition.httpMethod = @"GET";
    
    MWAccountDealData *deal = [MWAccountDealData  createDealingWith:type delegate:delegate];   //创建请求监听对象
    NetRequestExt* request = [[NetExt sharedInstance] requestWithCondition:condition delegate:deal]; //开始请求
    if (request == nil)
    {
        return GD_ERR_FAILED;
    }
    return GD_ERR_OK;
}

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
+ (GSTATUS)accountUploadHeadWith:(RequestType)type image:(UIImage *)image rect:(CGRect)rect tpuserid:(NSString *)tpuserid tptype:(NSString *)tptype delegate:(id<NetReqToViewCtrDelegate>)delegate
{
    NSMutableDictionary *url_params = [[[NSMutableDictionary alloc] init] autorelease];
    NSMutableDictionary *content_params = [[[NSMutableDictionary alloc] init] autorelease];
    
    NSString* fileKey = @"headimg";
    if (image)
    {
        [content_params setObject:image forKey:fileKey];
    }
    if (rect.origin.x || rect.origin.y || rect.size.width || rect.size.height)
    {
        [url_params setObject:[NSString stringWithFormat:@"%.0f",rect.origin.x] forKey:@"left"];
        [url_params setObject:[NSString stringWithFormat:@"%.0f",rect.origin.y] forKey:@"top"];
        [url_params setObject:[NSString stringWithFormat:@"%.0f",rect.size.width] forKey:@"width"];
        [url_params setObject:[NSString stringWithFormat:@"%.0f",rect.size.height] forKey:@"height"];
    }
	if (tpuserid)
    {
        [url_params setObject:tpuserid forKey:@"tpuserid"];
    }
    
    if (tptype)
    {
        [url_params setObject:tptype forKey:@"tptype"];
    }
    
    
    NSMutableDictionary *dic_head = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"multipart/form-data; boundary=%@",kNetRequestStringBoundary  ],@"Content-Type", nil];
    NSData *body = [[NetExt sharedInstance] postBodyData:content_params];
    
    NetBaseRequestCondition *condition = [NetBaseRequestCondition requestCondition];
    condition.baceURL = [NSString stringWithFormat:@"%@%@",kNetDomain,HEAD_UPLOAD_HEAD];
    condition.requestType = type;
    condition.urlParams = url_params;
    condition.httpHeaderFieldParams = dic_head;
    condition.httpMethod = @"POST";
    condition.bodyData = body;
    
    
    MWAccountDealData *deal = [MWAccountDealData  createDealingWith:type delegate:delegate];   //创建请求监听对象
    NetRequestExt* request = [[NetExt sharedInstance] requestWithCondition:condition delegate:deal]; //开始请求
    if (request == nil)
    {
        return GD_ERR_FAILED;
    }
    return GD_ERR_OK;
}

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
+ (GSTATUS)accountGetPhoneCheckNumberWith:(RequestType)type phone:(NSString *)phone vtype:(NSString *)vtype delegate:(id<NetReqToViewCtrDelegate>)delegate
{
    NSMutableDictionary *Params = [[[NSMutableDictionary alloc] init] autorelease];
    if (phone)
    {
        [Params setObject:phone forKey:@"phone"];
    }
    if (deviceID)
    {
        [Params setObject:deviceID forKey:@"uuid"];
    }
    
    
    NSString *license_id = [license_id_normal stringByAppendingString:phone];
    NSString *sign = [[NSString stringWithFormat:@"%@%@%@",deviceID,phone,KEY_MD5] stringFromMD5];
    
    if (license_id)
    {
        [Params setObject:license_id forKey:@"license_id"];
    }
    if (sign)
    {
        [Params setObject:sign forKey:@"sign"];
    }
    if (vtype)
    {
        [Params setObject:vtype forKey:@"vtype"];
    }
    
	NetBaseRequestCondition *condition = [NetBaseRequestCondition requestCondition];
    condition.baceURL = [NSString stringWithFormat:@"%@%@",kNetDomain,HEAD_GET_CHECK_NUMBER];
    condition.requestType = type;
    condition.urlParams = Params;
    condition.httpMethod = @"GET";
    
    MWAccountDealData *deal = [MWAccountDealData  createDealingWith:type delegate:delegate];   //创建请求监听对象
    NetRequestExt* request = [[NetExt sharedInstance] requestWithCondition:condition delegate:deal]; //开始请求
    if (request == nil)
    {
        return GD_ERR_FAILED;
    }
    return GD_ERR_OK;
}


/**
 *	智驾绑定手机号时的验证码
 *
 *	@param	type	请求类型
 *	@param	phone	绑定智驾的手机号码
 *	@param	delegate	委托回调
 *
 *	@return	成功返回GD_ERR_OK, 失败返回对应出错码
 */
+ (GSTATUS)accountGet95190CheckNumberWith:(RequestType)type phone:(NSString *)phone delegate:(id<NetReqToViewCtrDelegate>)delegate
{
    NSMutableDictionary *Params = [[[NSMutableDictionary alloc] init] autorelease];
    if (phone)
    {
        [Params setObject:phone forKey:@"phone"];
    }
    if (deviceID)
    {
        [Params setObject:deviceID forKey:@"uuid"];
    }
    
    
    NSString *license_id = [license_id_95190 stringByAppendingFormat:@"%@",phone];
    NSString *sign = [[NSString stringWithFormat:@"%@%@%@",deviceID,phone,KEY_MD5] stringFromMD5];

    if (license_id)
    {
        [Params setObject:license_id forKey:@"license_id"];
    }
    if (sign)
    {
        [Params setObject:sign forKey:@"sign"];
    }
    
    NSArray *array = [[Account AccountInstance] getAccountInfo];
    int loginType = [[array objectAtIndex:0] intValue];
    if (loginType == 5 || loginType == 3)
    {
        [Params setObject:@"1" forKey:@"tptype"];
        [Params setObject:[array objectAtIndex:5] forKey:@"tpuserid"];
    }
    else if (loginType == 6 || loginType == 4)
    {
        [Params setObject:@"2" forKey:@"tptype"];
        [Params setObject:[array objectAtIndex:5] forKey:@"tpuserid"];
        
    }
    
    [Params setObject:VendorID forKey:@"imei"];
    [Params setObject:@"1" forKey:@"origin"];
    [Params setObject:deviceID forKey:@"mac"];
    [Params setObject:deviceTokenEx forKey:@"token"];
    	
	NetBaseRequestCondition *condition = [NetBaseRequestCondition requestCondition];
    condition.baceURL = [NSString stringWithFormat:@"%@%@",kNetDomain,HEAD_GET_95190CHECK];
    condition.requestType = type;
    condition.urlParams = Params;
    condition.httpMethod = @"GET";
    
    MWAccountDealData *deal = [MWAccountDealData  createDealingWith:type delegate:delegate];   //创建请求监听对象
    NetRequestExt* request = [[NetExt sharedInstance] requestWithCondition:condition delegate:deal]; //开始请求
    if (request == nil)
    {
        return GD_ERR_FAILED;
    }
    return GD_ERR_OK;
}

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
+ (GSTATUS)accountCheckCodeWith:(RequestType)type phone:(NSString *)phone license_val:(NSString *)license_val delegate:(id<NetReqToViewCtrDelegate>)delegate
{
    NSMutableDictionary *Params = [[[NSMutableDictionary alloc] init] autorelease];
    if (phone)
    {
        [Params setObject:phone forKey:@"phone"];
    }
    if (deviceID)
    {
        [Params setObject:deviceID forKey:@"uuid"];
    }
    
    NSString *license_id = [license_id_normal stringByAppendingString:phone];
    if (license_id)
    {
        [Params setObject:license_id forKey:@"license_id"];
    }
    if (license_val)
    {
        [Params setObject:license_val forKey:@"license_val"];
    }
    
    
	NetBaseRequestCondition *condition = [NetBaseRequestCondition requestCondition];
    condition.baceURL = [NSString stringWithFormat:@"%@%@",kNetDomain,HEAD_CHECK_COEDE];
    condition.requestType = type;
    condition.urlParams = Params;
    condition.httpMethod = @"GET";
    
    MWAccountDealData *deal = [MWAccountDealData  createDealingWith:type delegate:delegate];   //创建请求监听对象
    NetRequestExt* request = [[NetExt sharedInstance] requestWithCondition:condition delegate:deal]; //开始请求
    if (request == nil)
    {
        return GD_ERR_FAILED;
    }
    return GD_ERR_OK;
}

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
+ (GSTATUS)accountBind95190PhoneWith:(RequestType)type phone:(NSString *)phone license_val:(NSString *)license_val delegate:(id<NetReqToViewCtrDelegate>)delegate
{
    NSMutableDictionary *Params = [[[NSMutableDictionary alloc] init] autorelease];
    if (phone)
    {
        [Params setObject:phone forKey:@"phone"];
    }
    if (deviceID)
    {
        [Params setObject:deviceID forKey:@"uuid"];
    }
    
    NSString *license_id = [license_id_95190 stringByAppendingString:phone];
    if (license_id)
    {
        [Params setObject:license_id forKey:@"license_id"];
    }
    if (license_val)
    {
        [Params setObject:license_val forKey:@"license_val"];
    }
    
    NSArray *array = [[Account AccountInstance] getAccountInfo];
    int loginType = [[array objectAtIndex:0] intValue];
    if (loginType == 5 || loginType == 3)
    {
        [Params setObject:@"1" forKey:@"tptype"];
        [Params setObject:[array objectAtIndex:5] forKey:@"tpuserid"];
    }
    else if (loginType == 6 || loginType == 4)
    {
        [Params setObject:@"2" forKey:@"tptype"];
        [Params setObject:[array objectAtIndex:5] forKey:@"tpuserid"];
        
    }
    
    if (VendorID)
    {
        [Params setObject:VendorID forKey:@"imei"];
    }
    [Params setObject:@"1" forKey:@"origin"];
    if (deviceID)
    {
        [Params setObject:deviceID forKey:@"mac"];
    }
    if (deviceTokenEx)
    {
        [Params setObject:deviceTokenEx forKey:@"token"];
    }
    
    
    NetBaseRequestCondition *condition = [NetBaseRequestCondition requestCondition];
    condition.baceURL = [NSString stringWithFormat:@"%@%@",kNetDomain,HEAD_BIND_95190PHONE_NUMBER];
    condition.requestType = type;
    condition.urlParams = Params;
    condition.httpMethod = @"GET";
    
    MWAccountDealData *deal = [MWAccountDealData  createDealingWith:type delegate:delegate];   //创建请求监听对象
    NetRequestExt* request = [[NetExt sharedInstance] requestWithCondition:condition delegate:deal]; //开始请求
    if (request == nil)
    {
        return GD_ERR_FAILED;
    }
    return GD_ERR_OK;
}

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
+ (GSTATUS)accountModify95190PhoneWith:(RequestType)type phone:(NSString *)phone license_val:(NSString *)license_val delegate:(id<NetReqToViewCtrDelegate>)delegate
{
    NSMutableDictionary *Params = [[[NSMutableDictionary alloc] init] autorelease];
    if (phone)
    {
        [Params setObject:phone forKey:@"phone"];
    }
    if (deviceID)
    {
        [Params setObject:deviceID forKey:@"uuid"];
    }
    
    NSString *license_id = [license_id_95190 stringByAppendingString:phone];
    if (license_id)
    {
        [Params setObject:license_id forKey:@"license_id"];
    }
    if (license_val)
    {
        [Params setObject:license_val forKey:@"license_val"];
    }
    
    NSArray *array = [[Account AccountInstance] getAccountInfo];
    int loginType = [[array objectAtIndex:0] intValue];
    if (loginType == 5 || loginType == 3)
    {
        [Params setObject:@"1" forKey:@"tptype"];
        [Params setObject:[array objectAtIndex:5] forKey:@"tpuserid"];
    }
    else if (loginType == 6 || loginType == 4)
    {
        [Params setObject:@"2" forKey:@"tptype"];
        [Params setObject:[array objectAtIndex:5] forKey:@"tpuserid"];
        
    }
    
    if (VendorID)
    {
        [Params setObject:VendorID forKey:@"imei"];
    }
    [Params setObject:@"1" forKey:@"origin"];
    if (deviceID)
    {
        [Params setObject:deviceID forKey:@"mac"];
    }
    if (deviceTokenEx)
    {
        [Params setObject:deviceTokenEx forKey:@"token"];
    }
    
    NetBaseRequestCondition *condition = [NetBaseRequestCondition requestCondition];
    condition.baceURL = [NSString stringWithFormat:@"%@%@",kNetDomain,HEAD_MODIFY_95190PHONE_NUMBER];
    condition.requestType = type;
    condition.urlParams = Params;
    condition.httpMethod = @"GET";
    
    MWAccountDealData *deal = [MWAccountDealData  createDealingWith:type delegate:delegate];   //创建请求监听对象
    NetRequestExt* request = [[NetExt sharedInstance] requestWithCondition:condition delegate:deal]; //开始请求
    if (request == nil)
    {
        return GD_ERR_FAILED;
    }
    return GD_ERR_OK;
}

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
+ (GSTATUS)accountGet95190PhoneWith:(RequestType)type delegate:(id<NetReqToViewCtrDelegate>)delegate

{
    NSMutableDictionary *Params = [[[NSMutableDictionary alloc] init] autorelease];
    
    
    if (VendorID)
    {
        [Params setObject:VendorID forKey:@"imei"];
    }
    [Params setObject:@"1" forKey:@"origin"];
    if (deviceID)
    {
        [Params setObject:deviceID forKey:@"uuid"];
        [Params setObject:deviceID forKey:@"mac"];
    }
    if (deviceTokenEx)
    {
        [Params setObject:deviceTokenEx forKey:@"token"];
    }
    
    NetBaseRequestCondition *condition = [NetBaseRequestCondition requestCondition];
    condition.baceURL = [NSString stringWithFormat:@"%@%@",kNetDomain,HEAD_GET_95190PHONE_NUMBER];
    condition.requestType = type;
    condition.urlParams = Params;
    condition.httpMethod = @"GET";
    
    MWAccountDealData *deal = [MWAccountDealData  createDealingWith:type delegate:delegate];   //创建请求监听对象
    NetRequestExt* request = [[NetExt sharedInstance] requestWithCondition:condition delegate:deal]; //开始请求
    if (request == nil)
    {
        return GD_ERR_FAILED;
    }
    return GD_ERR_OK;
}
/**
 *	此接口用于实现客户端向服务端解除已绑定用于95190服务的电话号码。
 *
 *	@param	type   请求类型
 *	@param	delegate    委托回调
 *
 *	@return 成功返回GD_ERR_OK, 失败返回对应出错码
 */
+ (GSTATUS)accountClear95190PhoneWith:(RequestType)type delegate:(id<NetReqToViewCtrDelegate>)delegate
{
    NSMutableDictionary *Params = [[[NSMutableDictionary alloc] init] autorelease];
    
    NSArray *array = [[Account AccountInstance] getAccountInfo];
    int loginType = [[array objectAtIndex:0] intValue];
    if (loginType == 5 || loginType == 3)
    {
        [Params setObject:@"1" forKey:@"tptype"];
        [Params setObject:[array objectAtIndex:5] forKey:@"tpuserid"];
    }
    else if (loginType == 6 || loginType == 4)
    {
        [Params setObject:@"2" forKey:@"tptype"];
        [Params setObject:[array objectAtIndex:5] forKey:@"tpuserid"];
        
    }

    if (VendorID)
    {
        [Params setObject:VendorID forKey:@"imei"];
    }
    [Params setObject:@"1" forKey:@"origin"];
    if (deviceID)
    {
        [Params setObject:deviceID forKey:@"uuid"];
        [Params setObject:deviceID forKey:@"mac"];
    }
    if (deviceTokenEx)
    {
        [Params setObject:deviceTokenEx forKey:@"token"];
    }
    
	NetBaseRequestCondition *condition = [NetBaseRequestCondition requestCondition];
    condition.baceURL = [NSString stringWithFormat:@"%@%@",kNetDomain,HEAD_CLEAR_95190PHONE_NUMBER];
    condition.requestType = type;
    condition.urlParams = Params;
    condition.httpMethod = @"GET";
    
    MWAccountDealData *deal = [MWAccountDealData  createDealingWith:type delegate:delegate];   //创建请求监听对象
    NetRequestExt* request = [[NetExt sharedInstance] requestWithCondition:condition delegate:deal]; //开始请求
    if (request == nil)
    {
        return GD_ERR_FAILED;
    }
    return GD_ERR_OK;
}

/**
 *	实现客户端从服务端获取上一次用户通过95190设置的目的地。
 *
 *	@param	type	请求类型
 *	@param	delegate	回调委托
 *
 *	@return	成功返回GD_ERR_OK, 失败返回对应出错码
 */
+ (GSTATUS)accountGetOldDestinationWith:(RequestType)type phone:(NSString *)phone delegate:(id<NetReqToViewCtrDelegate>)delegate
{
    NSMutableDictionary *Params = [[[NSMutableDictionary alloc] init] autorelease];
    if ([phone length] > 0)
    {
        [Params setObject:phone forKey:@"phonenum"];
    }
    
    NSString *sign = [[NSString stringWithFormat:@"%@%@",phone,KEY_MD5] stringFromMD5];
    [Params setObject:sign forKey:@"sign"];
    
    if (VendorID)
    {
        [Params setObject:VendorID forKey:@"imei"];
    }
    [Params setObject:@"1" forKey:@"origin"];
    if (deviceID)
    {
        [Params setObject:deviceID forKey:@"mac"];
    }
    if (deviceTokenEx)
    {
        [Params setObject:deviceTokenEx forKey:@"token"];
    }
    
	NetBaseRequestCondition *condition = [NetBaseRequestCondition requestCondition];
    condition.baceURL = [NSString stringWithFormat:@"%@%@",kNetDomain,HEAD_GET_95190_DESTINATION];
    condition.requestType = type;
    condition.urlParams = Params;
    condition.httpMethod = @"GET";
    
    MWAccountDealData *deal = [MWAccountDealData  createDealingWith:type delegate:delegate];   //创建请求监听对象
    NetRequestExt* request = [[NetExt sharedInstance] requestWithCondition:condition delegate:deal]; //开始请求
    if (request == nil)
    {
        return GD_ERR_FAILED;
    }
    return GD_ERR_OK;
}

/**
 *	此接口用于实现客户端从服务端获取当前用户95190的服务状态。
 *
 *	@param	type	请求类型
 *	@param	delegate	回调委托
 *
 *	@return	成功返回GD_ERR_OK, 失败返回对应出错码
 */
+ (GSTATUS)accountGet95190StatusWith:(RequestType)type delegate:(id<NetReqToViewCtrDelegate>)delegate
{
    NSMutableDictionary *Params = [[[NSMutableDictionary alloc] init] autorelease];
    [Params setObject:@"xml" forKey:@"out"];
    if (deviceID)
    {
        [Params setObject:deviceID forKey:@"uuid"];
    }
    
    
    NSArray *array = [[Account AccountInstance] getAccountInfo];
    int loginType = [[array objectAtIndex:0] intValue];
    if (loginType == 5 || loginType == 3)
    {
        [Params setObject:@"1" forKey:@"tptype"];
        [Params setObject:[array objectAtIndex:5] forKey:@"tpuserid"];
    }
    else if (loginType == 6 || loginType == 4)
    {
        [Params setObject:@"2" forKey:@"tptype"];
        [Params setObject:[array objectAtIndex:5] forKey:@"tpuserid"];
        
    }
	
	NetBaseRequestCondition *condition = [NetBaseRequestCondition requestCondition];
    condition.baceURL = [NSString stringWithFormat:@"%@%@",kNetDomain,HEAD_GET_95190_STATUS];
    condition.requestType = type;
    condition.urlParams = Params;
    condition.httpMethod = @"GET";
    
    MWAccountDealData *deal = [MWAccountDealData  createDealingWith:type delegate:delegate];   //创建请求监听对象
    NetRequestExt* request = [[NetExt sharedInstance] requestWithCondition:condition delegate:deal]; //开始请求
    if (request == nil)
    {
        return GD_ERR_FAILED;
    }
    return GD_ERR_OK;
}

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
+ (GSTATUS)accountBuy95190ServiceWith:(RequestType)type phone:(NSString *)phone body:(NSString *)body delegate:(id<NetReqToViewCtrDelegate>)delegate
{
    NSMutableDictionary *Params = [[[NSMutableDictionary alloc] init] autorelease];
    [Params setObject:@"xml" forKey:@"out"];
    if (phone)
    {
        [Params setObject:phone forKey:@"phone"];
    }
    if (deviceID)
    {
        [Params setObject:deviceID forKey:@"uuid"];
    }
    
    [Params setObject:[NSString stringWithFormat:@"%.1f",SOFTVERSIONNUM] forKey:@"version"];
    
    NSString *sign = [[NSString stringWithFormat:@"%@%@",deviceID,KEY_MD5] stringFromMD5];
    if (sign)
    {
        [Params setObject:sign forKey:@"sign"];
    }
    
    
    NSArray *array = [[Account AccountInstance] getAccountInfo];
    int loginType = [[array objectAtIndex:0] intValue];
    if (loginType == 5 || loginType == 3)
    {
        [Params setObject:@"1" forKey:@"tptype"];
        [Params setObject:[array objectAtIndex:5] forKey:@"tpuserid"];
    }
    else if (loginType == 6 || loginType == 4)
    {
        [Params setObject:@"2" forKey:@"tptype"];
        [Params setObject:[array objectAtIndex:5] forKey:@"tpuserid"];
        
    }
    
	
	NetBaseRequestCondition *condition = [NetBaseRequestCondition requestCondition];
    condition.baceURL = [NSString stringWithFormat:@"%@%@",kNetDomain,HEAD_BUY_95190_SERVICE];
    condition.requestType = type;
    condition.urlParams = Params;
    condition.bodyData = [body dataUsingEncoding:NSUTF8StringEncoding];
    condition.httpMethod = @"POST";
    
    MWAccountDealData *deal = [MWAccountDealData  createDealingWith:type delegate:delegate];   //创建请求监听对象
    NetRequestExt* request = [[NetExt sharedInstance] requestWithCondition:condition delegate:deal]; //开始请求
    if (request == nil)
    {
        return GD_ERR_FAILED;
    }
    return GD_ERR_OK;
}

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
+ (GSTATUS)accountUpadataProfileWith:(RequestType)type nickName:(NSString *)nickName province:(NSString *)province city:(NSString *)city birthday:(NSString *)birthday signature:(NSString *)signature sex:(NSString *)sex firstname:(NSString *)firstname tpuserid:(NSString *)tpuserid tptype:(NSString *)tptype delegate:(id<NetReqToViewCtrDelegate>)delegate
{
    NSMutableDictionary *modifyProfileParams = [[[NSMutableDictionary alloc] init] autorelease];
    if (tptype)
    {
        [modifyProfileParams setObject:tptype forKey:@"tptype"];
    }
    if (tpuserid)
    {
        [modifyProfileParams setObject:tpuserid forKey:@"tpuserid"];
    }
    if (nickName)
    {
        [modifyProfileParams setObject:nickName forKey:@"nickname"];
    }
 	if (birthday)
    {
        [modifyProfileParams setObject:birthday forKey:@"birthday"];
    }
    if (signature)
    {
        [modifyProfileParams setObject:signature forKey:@"signature"];
    }
    if (province)
    {
        [modifyProfileParams setObject:province forKey:@"province"];
    }
    if (city)
    {
        [modifyProfileParams setObject:city forKey:@"city"];
    }
    if (firstname)
    {
        [modifyProfileParams setObject:firstname forKey:@"firstname"];
    }
	if (sex)
    {
        [modifyProfileParams setObject:sex forKey:@"sex"];
    }
	
	
	NetBaseRequestCondition *condition = [NetBaseRequestCondition requestCondition];
    condition.baceURL = [NSString stringWithFormat:@"%@%@",kNetDomain,HEAD_UPDATE_PROFILE];
    condition.requestType = type;
    condition.urlParams = modifyProfileParams;
    condition.httpMethod = @"GET";
    
    MWAccountDealData *deal = [MWAccountDealData  createDealingWith:type delegate:delegate];   //创建请求监听对象
    NetRequestExt* request = [[NetExt sharedInstance] requestWithCondition:condition delegate:deal]; //开始请求
    if (request == nil)
    {
        return GD_ERR_FAILED;
    }
    return GD_ERR_OK;
}

/**
 *	此接口用于旧用户绑定手机，绑定成功后可以用手机进行登录。
 *
 *	@param	type	请求类型
 *	@param	phone	绑定的手机号码
 *	@param	delegate	回调委托
 *
 *	@return	成功返回GD_ERR_OK, 失败返回对应出错码
 */
+ (GSTATUS)accountOldBindPhoneWith:(RequestType)type phone:(NSString *)phone delegate:(id<NetReqToViewCtrDelegate>)delegate
{
    NSMutableDictionary *Params = [[[NSMutableDictionary alloc] init] autorelease];
    if (phone)
    {
        [Params setObject:phone forKey:@"phone"];
    }
    
    
	
	NetBaseRequestCondition *condition = [NetBaseRequestCondition requestCondition];
    condition.baceURL = [NSString stringWithFormat:@"%@%@",kNetDomain,HEAD_OLD_USER_BIND_PHONE_NUMBER];
    condition.requestType = type;
    condition.urlParams = Params;
    condition.httpMethod = @"GET";
    
    MWAccountDealData *deal = [MWAccountDealData  createDealingWith:type delegate:delegate];   //创建请求监听对象
    NetRequestExt* request = [[NetExt sharedInstance] requestWithCondition:condition delegate:deal]; //开始请求
    if (request == nil)
    {
        return GD_ERR_FAILED;
    }
    return GD_ERR_OK;
}

/**
 *	接口用于实现客户端向服务端申请使用95190免费30天服务。
 *
 *	@param	type	请求类型
 *	@param	phone	手机
 *	@param	delegate	回调委托
 *
 *	@return	成功返回GD_ERR_OK, 失败返回对应出错码
 */
+ (GSTATUS)accountFree95190With:(RequestType)type phone:(NSString *)phone delegate:(id<NetReqToViewCtrDelegate>)delegate
{
    NSMutableDictionary *Params = [[[NSMutableDictionary alloc] init] autorelease];
    if (phone)
    {
        [Params setObject:phone forKey:@"phone"];
    }
    if (deviceID)
    {
        [Params setObject:deviceID forKey:@"uuid"];
    }
    
    
    NSString *sign = [[NSString stringWithFormat:@"%@%@",deviceID,KEY_MD5] stringFromMD5];
    [Params setObject:sign forKey:@"sign"];
    
    NSArray *array = [[Account AccountInstance] getAccountInfo];
    int loginType = [[array objectAtIndex:0] intValue];
    if (loginType == 5 || loginType == 3)
    {
        [Params setObject:@"1" forKey:@"tptype"];
        [Params setObject:[array objectAtIndex:5] forKey:@"tpuserid"];
    }
    else if (loginType == 6 || loginType == 4)
    {
        [Params setObject:@"2" forKey:@"tptype"];
        [Params setObject:[array objectAtIndex:5] forKey:@"tpuserid"];
        
    }
	
    NetBaseRequestCondition *condition = [NetBaseRequestCondition requestCondition];
    condition.baceURL = [NSString stringWithFormat:@"%@%@",kNetDomain,HEAD_FREE_95190];
    condition.requestType = type;
    condition.urlParams = Params;
    condition.httpMethod = @"GET";
    
    MWAccountDealData *deal = [MWAccountDealData  createDealingWith:type delegate:delegate];   //创建请求监听对象
    NetRequestExt* request = [[NetExt sharedInstance] requestWithCondition:condition delegate:deal]; //开始请求
    if (request == nil)
    {
        return GD_ERR_FAILED;
    }
    return GD_ERR_OK;
}

/**
 *	用于实现客户端通知服务端拨打95190电话。
 *
 *	@param	phone	手机号码
 *	@param	type	请求类型
 *	@param	delegate	回调委托
 *
 *	@return	成功返回GD_ERR_OK, 失败返回对应出错码
 */
+ (GSTATUS)accountPreCall95190With:(RequestType)type phone:(NSString *)phone delegate:(id<NetReqToViewCtrDelegate>)delegate
{
    NSMutableDictionary *Params = [[[NSMutableDictionary alloc] init] autorelease];
    if (phone)
    {
        [Params setObject:phone forKey:@"phonenum"];
    }
    
    NSString *sign = [[NSString stringWithFormat:@"%@%@",phone,KEY_MD5] stringFromMD5];
    if (sign)
    {
        [Params setObject:sign forKey:@"sign"];
    }
    
    // 传入当前的经纬度
    GCARINFO pCarInfo;
    GDBL_GetCarInfo(&pCarInfo);
    [Params setObject:[NSString stringWithFormat:@"%d",pCarInfo.Coord.x] forKey:@"lon"];
    [Params setObject:[NSString stringWithFormat:@"%d",pCarInfo.Coord.y] forKey:@"lat"];
    
    if (VendorID)
    {
        [Params setObject:VendorID forKey:@"imei"];
    }
    [Params setObject:@"1" forKey:@"origin"];
    if (deviceID)
    {
        [Params setObject:deviceID forKey:@"uuid"];
        [Params setObject:deviceID forKey:@"mac"];
    }
    if (deviceTokenEx)
    {
        [Params setObject:deviceTokenEx forKey:@"token"];
    }
	
    NetBaseRequestCondition *condition = [NetBaseRequestCondition requestCondition];
    condition.baceURL = [NSString stringWithFormat:@"%@%@",kNetDomain,HEAD_PRE_CALL_95190];
    condition.requestType = type;
    condition.urlParams = Params;
    condition.httpMethod = @"GET";
    
    MWAccountDealData *deal = [MWAccountDealData  createDealingWith:type delegate:delegate];   //创建请求监听对象
    NetRequestExt* request = [[NetExt sharedInstance] requestWithCondition:condition delegate:deal]; //开始请求
    if (request == nil)
    {
        return GD_ERR_FAILED;
    }
    return GD_ERR_OK;
}

/**
 *	此接口用于实现客户端从服务端获取当前用户通过95190设置的目的地(拨打电话后设置),（拨打电话后获取刚设置的目的）。
 *
 *	@param	type	请求类型
 *	@param	phone	绑定的手机号码
 *	@param	delegate	回调委托
 *
 *	@return	成功返回GD_ERR_OK, 失败返回对应出错码
 */
+ (GSTATUS)accountGetCurrentDesWith:(RequestType)type phone:(NSString *)phone delegate:(id<NetReqToViewCtrDelegate>)delegate
{
    NSMutableDictionary *Params = [[[NSMutableDictionary alloc] init] autorelease];
    if ([phone length] > 0)
    {
        [Params setObject:phone forKey:@"phonenum"];
    }

    NSString *sign = [[NSString stringWithFormat:@"%@%@",phone,KEY_MD5] stringFromMD5];
    if (sign)
    {
        [Params setObject:sign forKey:@"sign"];
    }
    
    if (VendorID)
    {
        [Params setObject:VendorID forKey:@"imei"];
    }
    [Params setObject:@"1" forKey:@"origin"];
    if (deviceID)
    {
        [Params setObject:deviceID forKey:@"mac"];
    }
    if (deviceTokenEx)
    {
        [Params setObject:deviceTokenEx forKey:@"token"];
    }
    
    NetBaseRequestCondition *condition = [NetBaseRequestCondition requestCondition];
    condition.baceURL = [NSString stringWithFormat:@"%@%@",kNetDomain,HEAD_GET_CURRENT95190_DES];
    condition.requestType = type;
    condition.urlParams = Params;
    condition.httpMethod = @"GET";
    
    MWAccountDealData *deal = [MWAccountDealData  createDealingWith:type delegate:delegate];   //创建请求监听对象
    NetRequestExt* request = [[NetExt sharedInstance] requestWithCondition:condition delegate:deal]; //开始请求
    if (request == nil)
    {
        return GD_ERR_FAILED;
    }
    return GD_ERR_OK;
}

/**
 *	此接口用于实现客户端从服务端获取95190订购任务栏文字信息
 *
 *	@param	type	请求类型
 *	@param	delegate	回调委托
 *
 *	@return	成功返回GD_ERR_OK, 失败返回对应出错码
 */
+ (GSTATUS)accountGet95190TextWith:(RequestType)type delegate:(id<NetReqToViewCtrDelegate>)delegate
{
    NetBaseRequestCondition *condition = [NetBaseRequestCondition requestCondition];
    condition.baceURL = [NSString stringWithFormat:@"%@%@",kNetDomain,HEAD_GET_95190_TEXT];
    condition.requestType = type;
    condition.httpMethod = @"GET";
    
    MWAccountDealData *deal = [MWAccountDealData  createDealingWith:type delegate:delegate];   //创建请求监听对象
    NetRequestExt* request = [[NetExt sharedInstance] requestWithCondition:condition delegate:deal]; //开始请求
    if (request == nil)
    {
        return GD_ERR_FAILED;
    }
    return GD_ERR_OK;
}

/**
 *	此接口用于实现客户端从服务端获取95190按钮信息
 *
 *	@param	type	请求类型
 *	@param	delegate	回调委托
 *
 *	@return	成功返回GD_ERR_OK, 失败返回对应出错码
 */
+ (GSTATUS)accountGet95190ButtonWith:(RequestType)type delegate:(id<NetReqToViewCtrDelegate>)delegate
{
    NetBaseRequestCondition *condition = [NetBaseRequestCondition requestCondition];
    condition.baceURL = [NSString stringWithFormat:@"%@%@",kNetDomain,HEAD_Get_95190ButtonInfo];
    condition.requestType = type;
    condition.httpMethod = @"GET";
    
    MWAccountDealData *deal = [MWAccountDealData  createDealingWith:type delegate:delegate];   //创建请求监听对象
    NetRequestExt* request = [[NetExt sharedInstance] requestWithCondition:condition delegate:deal]; //开始请求
    if (request == nil)
    {
        return GD_ERR_FAILED;
    }
    return GD_ERR_OK;
}

/**
 *	此接口用于实现取消所有请求
 *
 *	@return	成功返回GD_ERR_OK, 失败返回对应出错码
 */
+ (GSTATUS)accountCancelAllReq
{
    [[NetExt sharedInstance] cancelAllRequests];
    [MWAccountDealData  clearAllDealing];
    return GD_ERR_OK;
}

/**
 *	此接口用于取消某类请求
 *
 *	@return	成功返回GD_ERR_OK, 失败返回对应出错码
 */
+ (GSTATUS)accountCancelReqWith:(RequestType)type
{
    [[NetExt sharedInstance] Net_CancelRequestWithType:type];
    [MWAccountDealData  deletaDealingWith:type];
    return GD_ERR_OK;
}

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
+ (GSTATUS)accountGetInfo:(NSArray **)array
{
    NSArray *temp = [[Account AccountInstance] getAccountInfo];
    *array = temp;
    return GD_ERR_OK;
}
@end

//
//  GDBL_Account.m
//  New_GNaviServer
//
//  Created by yang yi on 12-3-26.
//  Copyright 2012 autonavi.com. All rights reserved.
//

#import "GDBL_Account.h"

#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>

@implementation GDBL_Account

/**********************************************************************
 * 函数名称: GDBL_AccountUnBindToken
 * 功能描述: 注销-取消绑定TOKEN	 
 * 输入参数: 
 * 输出参数: 
 * 返 回 值: 成功返回GD_ERR_OK, 失败返回对应出错码
 * 修改日期			版本号		修改人		修改内容
 * ---------------------------------------------------------------------
 * 2012/03/26        1.0			杨毅
 **********************************************************************/
GSTATUS GDBL_AccountUnBindToken(void)
{

	NSDictionary *unBindTokenResult = [[Account AccountInstance] parseXMLWithParam:nil WithHeader:HEAD_UNBIND_TOKEN];
	if ([ [unBindTokenResult objectForKey:KEY_FOR_RESULT] isEqual:PARSE_OK]) 
	{
		return GD_ERR_OK;
	}
	else {
		return GD_ERR_PARSE_ERROR;
	}	
}
/**********************************************************************
 * 函数名称: GDBL_AccountLogout
 * 功能描述: 登出	 
 * 输入参数: 
 * 输出参数: 
 * 返 回 值: 成功返回GD_ERR_OK, 失败返回对应出错码
 * 修改日期			版本号		修改人		修改内容
 * ---------------------------------------------------------------------
 * 2012/03/26        1.0			杨毅
 **********************************************************************/
GSTATUS GDBL_AccountLogout(void)
{
//	if([[Net instance] connectedToNetwork]==NO)
//	{
//		return GD_ERR_NETCONNECT_ERROR;
//	}
	GDBL_CANCLE_ALL_REQ();  //退出登陆时  取消所有请求
	[[Account AccountInstance]parseWithParam:nil WithHeader:REQ_LOGOUT];
	return GD_ERR_OK;
   	
}

/**********************************************************************
 * 函数名称: GDBL_ThirdLogin
 * 功能描述: 第三方登录
 * 输入参数:
 tpuserid	第三方用户唯一码
 tpusername	第三方用户名
 tptype	第三方类型
 uuid	硬件唯一标识码
 sign	加密码
 * 输出参数:
 * 返 回 值: 成功返回GD_ERR_OK, 失败返回对应出错码
 * 修改日期			版本号		修改人		修改内容
 * ---------------------------------------------------------------------
 * 2012/03/26        1.0			杨毅
 **********************************************************************/
GSTATUS GDBL_ThirdLogin (NSString *tpuserid,NSString *tpusername,NSString *uuid,NSString *sign,int tptype,NSString *token)
{
    NSMutableDictionary *loginParam=[[[NSMutableDictionary alloc] init] autorelease];
    
    if ([token length] > 0)
    {
        [loginParam setObject:token forKey:@"token"];
    }
    [loginParam setObject:tpuserid forKey:@"tpuserid"];
	[loginParam setObject:tpusername forKey:@"tpusername"];
    
    [loginParam setObject:uuid forKey:@"uuid"];
    [loginParam setObject:sign forKey:@"sign"];
    [loginParam setObject:[NSString stringWithFormat:@"%d",tptype] forKey:@"tptype"];
    
	[[Account AccountInstance]parseWithParam:loginParam WithHeader:REQ_THIRD_LOGIN];
	
	return GD_ERR_OK;
}

/**********************************************************************
 * 函数名称: GDBL_AccountLogin
 * 功能描述: 登录	 
 * 输入参数:
 phone	手机号码
 password	密码	
 tpye	登录类型	0：用户名，1：邮箱 2：手机		
 * 输出参数: 
 * 返 回 值: 成功返回GD_ERR_OK, 失败返回对应出错码
 * 修改日期			版本号		修改人		修改内容
 * ---------------------------------------------------------------------
 * 2012/03/26        1.0			杨毅
 **********************************************************************/
GSTATUS GDBL_AccountLogin (NSString *phone,NSString *password,int type,NSString *uuid,NSString *token)
{
	NSMutableDictionary *loginParam=[[[NSMutableDictionary alloc] init] autorelease];
    
    [loginParam setObject:uuid forKey:@"uuid"];
    if ([token length] > 0)
    {
        [loginParam setObject:token forKey:@"token"];
    }
    
    [loginParam setObject:password forKey:@"password"];
	[loginParam setObject:[NSString stringWithFormat:@"%d",type] forKey:@"type"];
    if (type == 1)
    {
        [loginParam setObject:phone forKey:@"email"];
    }
    else
    {
        [loginParam setObject:phone forKey:@"phone"];
    }
   
    

    [[Account AccountInstance] setAccountName:phone Password:password];

	[[Account AccountInstance]parseWithParam:loginParam WithHeader:REQ_LOGIN];
	
	return GD_ERR_OK;
	
}
/**********************************************************************
 * 函数名称: GDBL_AccountResetPwd
 * 功能描述: 修改密码	 
 * 输入参数: 1.phone 手机号
			2.szNewPwd
 * 输出参数: 
 * 返 回 值: 成功返回GD_ERR_OK, 失败返回对应出错码
 * 修改日期			版本号		修改人		修改内容
 * ---------------------------------------------------------------------
 * 2013/06/04        1.0		高志闽
 **********************************************************************/
GSTATUS GDBL_AccountResetPwd (NSString *phone,NSString *newpw)
{
	NSMutableDictionary *modifyPwdParam=[[[NSMutableDictionary alloc] init] autorelease];
    [modifyPwdParam setObject:phone forKey:@"phone"];
    [modifyPwdParam setObject:newpw forKey:@"newpw"];

	
	[[Account AccountInstance]parseWithParam:modifyPwdParam WithHeader:REQ_RESET_PWD];
    
	return GD_ERR_OK;
	
}

/**********************************************************************
 * 函数名称: GDBL_AccountModifyPwd
 * 功能描述: 修改密码
 * 输入参数: 
 1.oldpw 旧密码
 2.newpw 新密码
 * 输出参数:
 * 返 回 值: 成功返回GD_ERR_OK, 失败返回对应出错码
 * 修改日期			版本号		修改人		修改内容
 * ---------------------------------------------------------------------
 * 2013/06/04        1.0		高志闽
 **********************************************************************/
GSTATUS GDBL_AccountModifyPwd (NSString *oldpw,NSString *newpw,NSString *tpuserid,int tptype)
{
	NSMutableDictionary *modifyPwdParam=[[[NSMutableDictionary alloc] init] autorelease];
    [modifyPwdParam setObject:oldpw forKey:@"oldpw"];
    [modifyPwdParam setObject:newpw forKey:@"newpw"];
    if (tptype)
    {
        [modifyPwdParam setObject:[NSString stringWithFormat:@"%d",tptype] forKey:@"tptype"];
    }
    if (tpuserid)
    {
        [modifyPwdParam setObject:tpuserid forKey:@"tpuserid"];
    }
	
	[[Account AccountInstance]parseWithParam:modifyPwdParam WithHeader:REQ_UPDATE_PWD];
	NSArray *array = [[Account AccountInstance] getAccountInfo];
    [[Account AccountInstance] setAccountName:[array objectAtIndex:1] Password:newpw];
    
	return GD_ERR_OK;
	
}

/**********************************************************************
 * 函数名称: GDBL_AccountSendEmail
 * 功能描述: 邮箱重置密码
 * 输入参数:
 1.email 邮箱
 * 输出参数:
 * 返 回 值: 成功返回GD_ERR_OK, 失败返回对应出错码
 * 修改日期			版本号		修改人		修改内容
 * ---------------------------------------------------------------------
 * 2013/06/04        1.0		高志闽
 **********************************************************************/
GSTATUS GDBL_AccountSendEmail(NSString *email)
{
	NSMutableDictionary *modifyPwdParam=[[[NSMutableDictionary alloc] init] autorelease];
    [modifyPwdParam setObject:email forKey:@"email"];
    
	[[Account AccountInstance]parseWithParam:modifyPwdParam WithHeader:REQ_SEND_PWD_EMAIL];
	
	return GD_ERR_OK;
	
}

/**********************************************************************
 * 函数名称: GDBL_AccountGetProfile
 * 功能描述: 获取用户信息	 
 * 输入参数: 
 tpuserid	第三方用户唯一码	
 tptype     第三方类型	否	1:新浪微博 2：腾讯微博
 * 输出参数: 
 * 返 回 值: 成功返回GD_ERR_OK, 失败返回对应出错码
 * 修改日期			版本号		修改人		修改内容
 * ---------------------------------------------------------------------
 * 2012/03/26        1.0			杨毅
 **********************************************************************/
GSTATUS GDBL_AccountGetProfile(NSString *tpuserid,int tptype)
{
    
	
	NSMutableDictionary *getProfileParams=[[[NSMutableDictionary alloc] init] autorelease];
    if (tptype)
    {
        [getProfileParams setObject:[NSString stringWithFormat:@"%d",tptype] forKey:@"tptype"];
    }
    if (tpuserid)
    {
        [getProfileParams setObject:tpuserid forKey:@"tpuserid"];
    }
	[[Account AccountInstance]parseWithParam:getProfileParams WithHeader:REQ_GET_PROFILE];
	
    return GD_ERR_OK;
	
//	NSDictionary *result = [[Account AccountInstance] parseXMLWithParam:getProfileParams WithHeader:HEAD_GET_PROFILE];
//	if ([[result objectForKey:KEY_FOR_RESULT] isEqual:PARSE_OK]) {
//		*pMyProfile = [[result objectForKey:KEY_FOR_PROFILE] retain];
//		//NSLog(@"GDBL_AccountGetProfile:%@",*pMyProfile->userName);
//		return GD_ERR_OK;
//	}
//	else {
//		return GD_ERR_PARSE_ERROR;
//	}
	
}

/**********************************************************************
 * 函数名称: GDBL_AccountRegist
 * 功能描述: 注册	 
 * 输入参数:	1.szUserName
			2.szPwd
			3.szEMail
			4.szPhone
			5.szAuthCode
 * 输出参数: 
 * 返 回 值: 成功返回GD_ERR_OK, 失败返回对应出错码
 * 修改日期			版本号		修改人		修改内容
 * ---------------------------------------------------------------------
 * 2012/03/26        1.0			杨毅
 **********************************************************************/
GSTATUS GDBL_AccountRegist(NSString *uuid,NSString *phone,NSString *szPwd,NSString *username,NSString *tpuserid,int tptype)
{
	NSMutableDictionary *registParams=[[[NSMutableDictionary alloc] init] autorelease];
    if (phone)
    {
        [registParams setObject:phone forKey:@"phone"];
    }
    if (szPwd)
    {
        [registParams setObject:szPwd forKey:@"password"];
    }
    if (username)
    {
        [registParams setObject:username forKey:@"username"];
    }
    if (uuid) {
        [registParams setObject:uuid forKey:@"uuid"];
    }
    if (tpuserid)
    {
        [registParams setObject:tpuserid forKey:@"tpuserid"];
    }
    
    if (tptype)
    {
        [registParams setObject:[NSString stringWithFormat:@"%d",tptype] forKey:@"tptype"];
    }
    
	[[Account AccountInstance]parseWithParam:registParams WithHeader:REQ_REGIST];
	return GD_ERR_OK;	
}
/**********************************************************************
 * 函数名称: GDBL_AccountAuthPic
 * 功能描述: 获取验证码图片	 
 * 输入参数:  
 * 输出参数: void* pImgData
 * 返 回 值: 成功返回GD_ERR_OK, 失败返回对应出错码
 * 修改日期			版本号		修改人		修改内容
 * ---------------------------------------------------------------------
 * 2012/03/26        1.0			杨毅
 **********************************************************************/
GSTATUS GDBL_AccountAuthPic(Gchar** pImgData, int* nLen)
{
//	if([[Net instance] connectedToNetwork]==NO)
//	{
//		return GD_ERR_NETCONNECT_ERROR;
//	}
	NSMutableDictionary *getAuthPicparams=[[[NSMutableDictionary alloc] init] autorelease];
    [getAuthPicparams setObject:deviceID forKey:@"uuid"];
	
	NSData* imgData=[[Account AccountInstance] getResultData:getAuthPicparams WithHeader:HEAD_GET_AUTH_IMG] ;
	if (imgData!=nil)
	{
        *nLen = [imgData length];
		*pImgData = (char *)[imgData bytes];
		
//		memcpy(pImgData,[imgData bytes], *nLen);
		return GD_ERR_OK;
	}else {
		return GD_ERR_UNKNOWN_ERROR;
	}
	
}

/**********************************************************************
 * 函数名称: GDBL_GET_HEAD
 * 功能描述:  此接口用于用户下载头像图片
 * 输入参数:
 imagepath:下载图片的路径
 * 输出参数:
 image : 下载的图片
 * 返 回 值: 成功返回GD_ERR_OK, 失败返回对应出错码
 * 修改日期			版本号		修改人		修改内容
 * ---------------------------------------------------------------------
 * 2012/12/27        1.0		高志闽
 **********************************************************************/
GSTATUS GDBL_GET_HEAD(NSString* imagepath,Gchar** pImgData, int* nLen,NSString *tpuserid,int tptype)
{
    NSMutableDictionary *getAuthPicparams=[[[NSMutableDictionary alloc] init] autorelease];
    [getAuthPicparams setObject:imagepath forKey:@"imagepath"];
	if (tpuserid)
    {
        [getAuthPicparams setObject:tpuserid forKey:@"tpuserid"];
    }
    if (tptype)
    {
        [getAuthPicparams setObject:[NSString stringWithFormat:@"%d",tptype] forKey:@"tptype"];
    }
	NSData* imgData=[[Account AccountInstance] getResultData:getAuthPicparams WithHeader:HEAD_GET_HEAD] ;
	if (imgData!=nil)
	{
        *nLen = [imgData length];
		*pImgData = (char *)[imgData bytes];
		
		return GD_ERR_OK;
	}else {
		return GD_ERR_UNKNOWN_ERROR;
	}
}

/**********************************************************************
 * 函数名称: GDBL_UPLOAD_HEAD
 * 功能描述:   此接口用于用户上传头像。支持终端裁剪或者不裁剪，不裁剪的情况需终端给出裁剪区域，后台裁剪后的头像为50×50.
 上传文件格式限制：.jpg/.jpeg/.png/.gif'/.tiff'/.bmp
 上传文件大小限制：小于2M
 * 输入参数:
 image 上传图片
 out	输出格式
 left	图片裁剪区域左X
 top	图片裁剪区域上Y
 width	裁剪区域宽度
 height	裁剪区域高度
 
 * 输出参数:
 * 返 回 值: 成功返回GD_ERR_OK, 失败返回对应出错码
 * 修改日期			版本号		修改人		修改内容
 * ---------------------------------------------------------------------
 * 2012/12/27        1.0		高志闽
 **********************************************************************/
GSTATUS GDBL_UPLOAD_HEAD(UIImage* image,int left,int top,int width,int height,NSString *tpuserid,int tptype)
{
    NSMutableDictionary *getAuthPicparams=[[[NSMutableDictionary alloc] init] autorelease];
    NSString* fileKey = @"headimg";
    NSString* fileName = @"headimg";
    NSString* fileType = @"imgae/png";
    if (image)
    {
        [getAuthPicparams setObject:image forKey:fileKey];
    }
    if (left)
    {
        [getAuthPicparams setObject:[NSString stringWithFormat:@"%d",left] forKey:@"left"];
    }
    if (top)
    {
        [getAuthPicparams setObject:[NSString stringWithFormat:@"%d",top] forKey:@"top"];
    }
    if (width)
    {
        [getAuthPicparams setObject:[NSString stringWithFormat:@"%d",width] forKey:@"width"];
    }
    if (height)
    {
        [getAuthPicparams setObject:[NSString stringWithFormat:@"%d",height] forKey:@"height"];
    }
	if (tpuserid)
    {
        [getAuthPicparams setObject:tpuserid forKey:@"tpuserid"];
    }
    
    if (tptype)
    {
        [getAuthPicparams setObject:[NSString stringWithFormat:@"%d",tptype] forKey:@"tptype"];
    }
        
	[[Account AccountInstance] parseWithParam:getAuthPicparams WithHeader:REQ_UPLOAD_HEAD fileKey:fileKey];
	return GD_ERR_OK;
}


/**********************************************************************
 * 函数名称: GDBL_GetPhoneCheckNumber
 * 功能描述: 此接口用于获取手机验证码，以支持后续的手机绑定。
 * 输入参数:
 phone:欲绑定11位手机号码
 uuid:mac地址或其他硬件唯一码识别字符串
 license_id:用于绑定此次验证码
 * 输出参数:
 * 返 回 值: 成功返回GD_ERR_OK, 失败返回对应出错码
 * 修改日期			版本号		修改人		修改内容
 * ---------------------------------------------------------------------
 * 2012/12/21        1.0		高志闽
 **********************************************************************/
GSTATUS GDBL_GetPhoneCheckNumber(NSString *phone, NSString *uuid, NSString *license_id,int vtype,NSString *sign)
{
	
	NSMutableDictionary *Params = [[[NSMutableDictionary alloc] init] autorelease];
    [Params setObject:phone forKey:@"phone"];
    [Params setObject:uuid forKey:@"uuid"];
    [Params setObject:license_id forKey:@"license_id"];
    [Params setObject:sign forKey:@"sign"];
    [Params setObject:[NSString stringWithFormat:@"%d",vtype] forKey:@"vtype"];

    [[Account AccountInstance]parseWithParam:Params WithHeader:REQ_GET_CHECK_NUMBER];
	
	return GD_ERR_OK;
}

/**********************************************************************
 * 函数名称: GDBL_Get_95190_CheckNumber
 * 功能描述: 此接口用于获取手机验证码，以支持后续的手机绑定。
 * 输入参数:
 phone:欲绑定11位手机号码
 uuid:mac地址或其他硬件唯一码识别字符串
 license_id:用于绑定此次验证码
 * 输出参数:
 * 返 回 值: 成功返回GD_ERR_OK, 失败返回对应出错码
 * 修改日期			版本号		修改人		修改内容
 * ---------------------------------------------------------------------
 * 2012/12/21        1.0		高志闽
 **********************************************************************/
GSTATUS GDBL_Get_95190_CheckNumber(NSString *phone, NSString *uuid, NSString *license_id,NSString *sign)
{

	NSMutableDictionary *Params = [[[NSMutableDictionary alloc] init] autorelease];
    [Params setObject:phone forKey:@"phone"];
    [Params setObject:uuid forKey:@"uuid"];
    [Params setObject:license_id forKey:@"license_id"];
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
    [Params setObject:VendorID forKey:@"imei"];
    [Params setObject:@"1" forKey:@"origin"];
    [Params setObject:deviceID forKey:@"mac"];
    [Params setObject:deviceTokenEx forKey:@"token"];
    [[Account AccountInstance]parseWithParam:Params WithHeader:REQ_GET_95190CHECK];
	
	return GD_ERR_OK;
}

/**********************************************************************
 * 函数名称: GDBL_CheckCode
 * 功能描述: 此接口用于实现用户通过短信验证码进行下一步的注册
 * 输入参数:
 phone:欲绑定11位手机号码
 uuid:mac地址或其他硬件唯一码识别字符串
 license_id:用于绑定此次验证码
 * 输出参数:
 * 返 回 值: 成功返回GD_ERR_OK, 失败返回对应出错码
 * 修改日期			版本号		修改人		修改内容
 * ---------------------------------------------------------------------
 * 2012/12/21        1.0		高志闽
 **********************************************************************/
GSTATUS GDBL_CheckCode(NSString *phone, NSString *uuid, NSString *license_id,NSString *license_val)
{
    NSMutableDictionary *Params = [[[NSMutableDictionary alloc] init] autorelease];
    [Params setObject:phone forKey:@"phone"];
    [Params setObject:uuid forKey:@"uuid"];
    [Params setObject:license_id forKey:@"license_id"];
    [Params setObject:license_val forKey:@"license_val"];

    
    [[Account AccountInstance]parseWithParam:Params WithHeader:REQ_CHECK_CODE];
	
	return GD_ERR_OK;
}

/**********************************************************************
 * 函数名称: GDBL_BIND_95190PHONE_NUMBER
 * 功能描述: 此接口用于实现客户端向服务端修改已绑定用于95190服务的电话号码。
 * 输入参数:
 phone:欲绑定11位手机号码
 uuid:mac地址或其他硬件唯一码识别字符串
 license_id:用于绑定此次验证码
 license_val:手机短信收到的验证码
 * 输出参数:
 * 返 回 值: 成功返回GD_ERR_OK, 失败返回对应出错码
 * 修改日期			版本号		修改人		修改内容
 * ---------------------------------------------------------------------
 * 2012/12/21        1.0		高志闽
 **********************************************************************/
GSTATUS GDBL_BIND_95190PHONE_NUMBER(NSString *phone, NSString *uuid, NSString *license_id, NSString *license_val)
{
	
	NSMutableDictionary *Params = [[[NSMutableDictionary alloc] init] autorelease];
    [Params setObject:phone forKey:@"phone"];
    [Params setObject:uuid forKey:@"uuid"];
    [Params setObject:license_id forKey:@"license_id"];
    [Params setObject:license_val forKey:@"license_val"];
    
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

    [[Account AccountInstance]parseWithParam:Params WithHeader:REQ_BIND_95190PHONE_NUMBER];
	
	return GD_ERR_OK;
}

/**********************************************************************
 * 函数名称: GDBL_Clear_95190PHONE_NUMBER
 * 功能描述: 此接口用于实现客户端向服务端解除已绑定用于95190服务的电话号码。
 * 输入参数:
 uuid:mac地址或其他硬件唯一码识别字符串
 
 * 输出参数:
 * 返 回 值: 成功返回GD_ERR_OK, 失败返回对应出错码
 * 修改日期			版本号		修改人		修改内容
 * ---------------------------------------------------------------------
 * 2012/12/21        1.0		高志闽
 **********************************************************************/
GSTATUS GDBL_Clear_95190PHONE_NUMBER(NSString *uuid)
{
	
	NSMutableDictionary *Params = [[[NSMutableDictionary alloc] init] autorelease];
    [Params setObject:uuid forKey:@"uuid"];
    
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
    
    [[Account AccountInstance]parseWithParam:Params WithHeader:REQ_CLEAR_95190PHONE_NUMBER];
	
	return GD_ERR_OK;
}

/**********************************************************************
 * 函数名称: GDBL_GET_PHONE_NUMBER
 * 功能描述:  此接口用于实现客户端从服务端获取当前用户手机绑定情况。
 * 输入参数:
 * 输出参数:
 * 返 回 值: 成功返回GD_ERR_OK, 失败返回对应出错码
 * 修改日期			版本号		修改人		修改内容
 * ---------------------------------------------------------------------
 * 2012/12/21        1.0		高志闽
 **********************************************************************/
GSTATUS GDBL_GET_PHONE_NUMBER(NSString *uuid)
{
 
    NSMutableDictionary *Params = [[[NSMutableDictionary alloc] init] autorelease];
    [Params setObject:@"xml" forKey:@"out"];
    [Params setObject:uuid forKey:@"uuid"];

    [[Account AccountInstance]parseWithParam:Params WithHeader:REQ_GET_95190PHONE_NUMBER];
	
	return GD_ERR_OK;
}

/**********************************************************************
 * 函数名称: GDBL_GET_95190_DESTINATION
 * 功能描述:  此接口用于实现客户端从服务端获取当前用户通过95190设置的目的地。
 * 输入参数:
 * 输出参数:
 * 返 回 值: 成功返回GD_ERR_OK, 失败返回对应出错码
 * 修改日期			版本号		修改人		修改内容
 * ---------------------------------------------------------------------
 * 2012/12/21        1.0		高志闽
 **********************************************************************/
GSTATUS GDBL_GET_95190_DESTINATION(NSString *uuid)
{
//    if([[Net instance] connectedToNetwork]==NO)
//	{
//		return GD_ERR_NETCONNECT_ERROR;
//	}
    
    NSMutableDictionary *Params = [[[NSMutableDictionary alloc] init] autorelease];
    [Params setObject:@"xml" forKey:@"out"];
    [Params setObject:uuid forKey:@"uuid"];
    
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

    
    [[Account AccountInstance]parseWithParam:Params WithHeader:REQ_GET_95190_DESTINATION];
	
	return GD_ERR_OK;
}

/**********************************************************************
 * 函数名称: GDBL_GET_95190_STATUS
 * 功能描述:  此接口用于实现客户端从服务端获取当前用户95190的服务状态。
 * 输入参数:
 * 输出参数:
 * 返 回 值: 成功返回GD_ERR_OK, 失败返回对应出错码
 * 修改日期			版本号		修改人		修改内容
 * ---------------------------------------------------------------------
 * 2012/12/21        1.0		高志闽
 **********************************************************************/
GSTATUS GDBL_GET_95190_STATUS(NSString *uuid)
{
//    if([[Net instance] connectedToNetwork]==NO)
//	{
//		return GD_ERR_NETCONNECT_ERROR;
//	}
    
    NSMutableDictionary *Params = [[[NSMutableDictionary alloc] init] autorelease];
    [Params setObject:@"xml" forKey:@"out"];
    [Params setObject:uuid forKey:@"uuid"];
    
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

    [[Account AccountInstance]parseWithParam:Params WithHeader:REQ_GET_95190_STATUS];
	
	return GD_ERR_OK;
}

/**********************************************************************
 * 函数名称: GDBL_BUY_95190_SERVICE
 * 功能描述:   此接口用于实现客户端向服务端验证用户订购95190服务有效性。
 * 输入参数:
 * 输出参数:
 * 返 回 值: 成功返回GD_ERR_OK, 失败返回对应出错码
 * 修改日期			版本号		修改人		修改内容
 * ---------------------------------------------------------------------
 * 2012/12/21        1.0		高志闽
 **********************************************************************/
GSTATUS GDBL_BUY_95190_SERVICE(NSString *phone, NSString *uuid,NSString *version,NSString *body,NSString *sign)
{
//    if([[Net instance] connectedToNetwork]==NO)
//	{
//		return GD_ERR_NETCONNECT_ERROR;
//	}
    
    NSMutableDictionary *Params = [[[NSMutableDictionary alloc] init] autorelease];
    [Params setObject:@"xml" forKey:@"out"];
    [Params setObject:phone forKey:@"phone"];
    [Params setObject:uuid forKey:@"uuid"];
    [Params setObject:version forKey:@"version"];
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
    
    [[Account AccountInstance]parseWithParam:Params WithHeader:REQ_BUY_95190_SERVICE WithBody:body];
	
	return GD_ERR_OK;
}

/**********************************************************************
 * 函数名称: GDBL_Account_Upadata_Profile
 * 功能描述:   此接口用于实现修改用户信息。
 * 输入参数:
 NSString=nil，sex=0表示输入参数无效
 
 * 输出参数:
 * 返 回 值: 成功返回GD_ERR_OK, 失败返回对应出错码
 * 修改日期			版本号		修改人		修改内容
 * ---------------------------------------------------------------------
 * 2012/12/21        1.0		高志闽
 **********************************************************************/
GSTATUS GDBL_Account_Upadata_Profile(NSString *nickName, NSString *url,NSString *province,NSString *city,NSString *birthday,NSString *signature,int sex,NSString *firstname,NSString *tpuserid,int tptype)
{

	NSMutableDictionary *modifyProfileParams = [[[NSMutableDictionary alloc] init] autorelease];
    if (tptype)
    {
        [modifyProfileParams setObject:[NSString stringWithFormat:@"%d",tptype] forKey:@"tptype"];
    }
    if (tpuserid)
    {
        [modifyProfileParams setObject:tpuserid forKey:@"tpuserid"];
    }
    if (nickName)
    {
        [modifyProfileParams setObject:nickName forKey:@"nickname"];
    }
    if (url)
    {
        [modifyProfileParams setObject:url forKey:@"url"];
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
        [modifyProfileParams setObject:[NSNumber numberWithInt:sex] forKey:@"sex"];
    }
	
	
	[[Account AccountInstance]parseWithParam:modifyProfileParams WithHeader:REQ_UPDATE_PROFILE];
    
	return GD_ERR_OK;
}

/**********************************************************************
 * 函数名称: GDBL_BIND_PHONE_NUMBER
 * 功能描述:  此接口用于实现用户通过短信验证码绑定手机。
 * 输入参数:
 
 * 输出参数:
 * 返 回 值: 成功返回GD_ERR_OK, 失败返回对应出错码
 * 修改日期			版本号		修改人		修改内容
 * ---------------------------------------------------------------------
 * 2012/12/21        1.0		高志闽
 **********************************************************************/
GSTATUS GDBL_BIND_PHONE_NUMBER(NSString *phone, NSString *uuid, NSString *license_id, NSString *license_val)
{
//    if([[Net instance] connectedToNetwork]==NO)
//	{
//		return GD_ERR_NETCONNECT_ERROR;
//	}
	
	NSMutableDictionary *Params = [[[NSMutableDictionary alloc] init] autorelease];
    [Params setObject:phone forKey:@"phone"];
    [Params setObject:uuid forKey:@"uuid"];
    [Params setObject:license_id forKey:@"license_id"];
    [Params setObject:license_val forKey:@"license_val"];
    

    [[Account AccountInstance]parseWithParam:Params WithHeader:REQ_BIND_PHONE_NUMBER];
	
	return GD_ERR_OK;
}

/**********************************************************************
 * 函数名称: GDBL_OLD_USER_BIND_PHONE_NUMBER
 * 功能描述: 此接口用于旧用户绑定手机，绑定成功后可以用手机进行登录。。
 * 输入参数:
 
 * 输出参数:
 * 返 回 值: 成功返回GD_ERR_OK, 失败返回对应出错码
 * 修改日期			版本号		修改人		修改内容
 * ---------------------------------------------------------------------
 * 2012/12/21        1.0		高志闽
 **********************************************************************/
GSTATUS GDBL_OLD_USER_BIND_PHONE_NUMBER(NSString *phone)
{
    NSMutableDictionary *Params = [[[NSMutableDictionary alloc] init] autorelease];
    [Params setObject:phone forKey:@"phone"];
    

    [[Account AccountInstance]parseWithParam:Params WithHeader:REQ_OLD_USER_BIND_PHONE_NUMBER];
	
	return GD_ERR_OK;
}
/**********************************************************************
 * 函数名称: GDBL_FREE_95190
 * 功能描述:  此接口用于实现客户端向服务端申请使用95190免费30天服务。
 * 输入参数:
 
 * 输出参数:
 * 返 回 值: 成功返回GD_ERR_OK, 失败返回对应出错码
 * 修改日期			版本号		修改人		修改内容
 * ---------------------------------------------------------------------
 * 2012/12/21        1.0		高志闽
 **********************************************************************/
GSTATUS GDBL_FREE_95190(NSString *phone, NSString *uuid,NSString *sign)
{

	
	NSMutableDictionary *Params = [[[NSMutableDictionary alloc] init] autorelease];
    [Params setObject:phone forKey:@"phone"];
    [Params setObject:uuid forKey:@"uuid"];
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
    
    [[Account AccountInstance]parseWithParam:Params WithHeader:REQ_FREE_95190];
	
	return GD_ERR_OK;
}

/**********************************************************************
 * 函数名称: GDBL_ORDER_EN_CHECK
 * 功能描述:  此接口用于实现客户端从服务端判断当前用户是否有英文版使用权限。
 * 输入参数:
 
 * 输出参数:
 * 返 回 值: 成功返回GD_ERR_OK, 失败返回对应出错码
 * 修改日期			版本号		修改人		修改内容
 * ---------------------------------------------------------------------
 * 2012/12/27        1.0		高志闽
 **********************************************************************/
GSTATUS GDBL_ORDER_EN_CHECK(NSString *uuid)
{
//    if([[Net instance] connectedToNetwork]==NO)
//	{
//		return GD_ERR_NETCONNECT_ERROR;
//	}
	
	NSMutableDictionary *Params = [[[NSMutableDictionary alloc] init] autorelease];
    [Params setObject:uuid forKey:@"uuid"];

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
    
    [[Account AccountInstance]parseWithParam:Params WithHeader:REQ_ORDER_EN_CHECK];
	
	return GD_ERR_OK;
}

/**********************************************************************
 * 函数名称: GDBL_PRE_CALL_95190
 * 功能描述:  此接口用于实现客户端通知服务端拨打95190电话。
 * 输入参数:
 
 * 输出参数:
 * 返 回 值: 成功返回GD_ERR_OK, 失败返回对应出错码
 * 修改日期			版本号		修改人		修改内容
 * ---------------------------------------------------------------------
 * 2012/12/27        1.0		高志闽
 **********************************************************************/
GSTATUS GDBL_PRE_CALL_95190(NSString *phone)
{
	NSMutableDictionary *Params = [[[NSMutableDictionary alloc] init] autorelease];
    [Params setObject:deviceID forKey:@"uuid"];
    [Params setObject:phone forKey:@"phone"];
    // 传入当前的经纬度
    GCARINFO pCarInfo;
    GDBL_GetCarInfo(&pCarInfo);
    [Params setObject:[NSString stringWithFormat:@"%d",pCarInfo.Coord.x] forKey:@"lon"];
    [Params setObject:[NSString stringWithFormat:@"%d",pCarInfo.Coord.y] forKey:@"lat"];

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
    [[Account AccountInstance]parseWithParam:Params WithHeader:REQ_PRE_CALL_95190];
	
	return GD_ERR_OK;
}

/**********************************************************************
 * 函数名称: GDBL_GET_CURRENT95190_DES
 * 功能描述:  此接口用于实现客户端从服务端获取当前用户通过95190设置的目的地(拨打电话后设置),（拨打电话后获取刚设置的目的）。
 * 输入参数:
 
 * 输出参数:
 * 返 回 值: 成功返回GD_ERR_OK, 失败返回对应出错码
 * 修改日期			版本号		修改人		修改内容
 * ---------------------------------------------------------------------
 * 2012/12/27        1.0		高志闽
 **********************************************************************/
GSTATUS GDBL_GET_CURRENT95190_DES(NSString *uuid)
{
	
	NSMutableDictionary *Params = [[[NSMutableDictionary alloc] init] autorelease];
    [Params setObject:uuid forKey:@"uuid"];
    
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
    [[Account AccountInstance]parseWithParam:Params WithHeader:REQ_GET_CURRENT95190_DES];
    
	
	return GD_ERR_OK;
}

/**********************************************************************
 * 函数名称: GDBL_GET_EN_TEXT
 * 功能描述:  此接口用于实现客户端从服务端获取英文版订购任务栏文字信息
 * 输入参数:
 
 * 输出参数:
 * 返 回 值: 成功返回GD_ERR_OK, 失败返回对应出错码
 * 修改日期			版本号		修改人		修改内容
 * ---------------------------------------------------------------------
 * 2012/12/27        1.0		高志闽
 **********************************************************************/
GSTATUS GDBL_GET_EN_TEXT()
{
//    if([[Net instance] connectedToNetwork]==NO)
//	{
//		return GD_ERR_NETCONNECT_ERROR;
//	}
    
    [[Account AccountInstance]parseWithParam:nil WithHeader:REQ_GET_EN_TEXT];
    
    return GD_ERR_OK;
}

/**********************************************************************
 * 函数名称: GDBL_GET_95190_TEXT
 * 功能描述:  此接口用于实现客户端从服务端获取95190订购任务栏文字信息
 * 输入参数:
 
 * 输出参数:
 * 返 回 值: 成功返回GD_ERR_OK, 失败返回对应出错码
 * 修改日期			版本号		修改人		修改内容
 * ---------------------------------------------------------------------
 * 2012/12/27        1.0		高志闽
 **********************************************************************/
GSTATUS GDBL_GET_95190_TEXT()
{
//    if([[Net instance] connectedToNetwork]==NO)
//	{
//		return GD_ERR_NETCONNECT_ERROR;
//	}
    
    [[Account AccountInstance]parseWithParam:nil WithHeader:REQ_GET_95190_TEXT];
    
    return GD_ERR_OK;
}

/**********************************************************************
 * 函数名称: GDBL_CANCLE_ALL_REQ
 * 功能描述:  此接口用于实现取消所有请求
 * 输入参数:
 
 * 输出参数:
 * 返 回 值: 成功返回GD_ERR_OK, 失败返回对应出错码
 * 修改日期			版本号		修改人		修改内容
 * ---------------------------------------------------------------------
 * 2012/12/27        1.0		高志闽
 **********************************************************************/
GSTATUS GDBL_CANCLE_ALL_REQ()
{
    [[Account AccountInstance] CancelAllREQ];
    return GD_ERR_OK;
}


/**********************************************************************
 * 函数名称: GDBL_GetAccountInfo
 * 功能描述: 获取账号信息
 * 输入参数:
 
 * 输出参数: array
 
 数组顺序  值说明
 0      登陆状态 0未登录，1老用户登录，2新用户登录，3新浪微博帐号登录，4腾讯微博帐号登录，5 新浪帐号绑定高德帐号 6 腾讯帐号绑定高德帐号
 1      账户名 (手机或者邮箱)
 2      密码
 3      昵称
 4      图片
 5      第三方uuid，若登陆状态为3或5，则是新浪UUID；若是4或6，则为腾讯UUID
 6      第三方账户名
 7      UserId      (必定有值)
 8      登陆令牌UserSId      (登陆后才有值)
 
 * 返 回 值: 成功返回GD_ERR_OK, 失败返回对应出错码
 * 修改日期			版本号		修改人		修改内容
 * ---------------------------------------------------------------------
 * 2012/12/27        1.0		高志闽
 **********************************************************************/
GSTATUS GDBL_GetAccountInfo(NSArray **array)
{
    NSArray *temp = [[Account AccountInstance] getAccountInfo];
    *array = temp;
    return GD_ERR_OK;
}

GSTATUS GDBL_setAccountInfo(NSArray *array)
{
    [[Account AccountInstance] setAccountInfo:array];
    return GD_ERR_OK;
}

/**
 *	回复默认值
 *
 *	@return	成功返回GD_ERR_OK, 失败返回对应出错码
 */
GSTATUS GDBL_clearAccountInfo()
{
    NSString *userName = @"";
    NSMutableArray *array = nil;
    GDBL_GetAccountInfo(&array);
    if (array && [array count] >= 6)
    {
        userName = [array objectAtIndex:1];
    }
    array = [[[NSMutableArray alloc] init] autorelease];
    [array  addObject:[[[NSNumber alloc] initWithInt:0] autorelease]]; //登陆状态 0未登录，1老用户登录，2新用户登录，3新浪微博帐号登录，4腾讯微博帐号登录，5 新浪帐号绑定高德帐号 6 腾讯帐号绑定高德帐号
    [array  addObject:userName];		//账户名
    [array  addObject:@""];      //密码
    [array  addObject:@""];        //昵称
    [array  addObject:UIImagePNGRepresentation( IMAGE(@"non_head.png", IMAGEPATH_TYPE_1))]; //图片
    [array  addObject:@""];        //第三方uuid，若登陆状态为3或5，则是新浪UUID；若是4或6，则为腾讯UUID
    [array  addObject:@""];        //tpusername
    [array  addObject:@""];        //userid
    GDBL_setAccountInfo(array);
    return GD_ERR_OK;
}

/**
 *	保存用户头像至本地文件
 *
 *	@param	image	要保存的头像
 *
 *	@return	成功返回GD_ERR_OK, 失败返回对应出错码
 */
GSTATUS GDBL_setAccountImage(UIImage *image)
{
    if (image == nil)
    {
        return GD_ERR_FAILED;
    }
    NSMutableArray *array = [NSMutableArray arrayWithArray:[[Account AccountInstance] getAccountInfo]];
    if ([array count] > 4)
    {
        [array replaceObjectAtIndex:4 withObject:UIImagePNGRepresentation(image)];
        if ([[Account AccountInstance] setAccountInfo:array])
        {
            return GD_ERR_OK;
        }
    }
    return GD_ERR_FAILED;
}

/**
 *	保存用户昵称至本地文件
 *
 *	@param	nickName	要保存的昵称
 *
 *	@return	成功返回GD_ERR_OK, 失败返回对应出错码
 */
GSTATUS GDBL_setAccountNickName(NSString *nickName)
{
    NSMutableArray *array = [NSMutableArray arrayWithArray:[[Account AccountInstance] getAccountInfo]];
    if ([array count] > 3)
    {
        [array replaceObjectAtIndex:3 withObject:nickName?nickName:@""];
        if ([[Account AccountInstance] setAccountInfo:array])
        {
            return GD_ERR_OK;
        }
    }
    return GD_ERR_FAILED;
}

/**
 *	保存用户userid至本地文件
 *
 *	@param	userid	要保存的userid
 *
 *	@return	成功返回GD_ERR_OK, 失败返回对应出错码
 */
GSTATUS GDBL_setAccountUserID(NSString *userid)
{
    NSMutableArray *array = [NSMutableArray arrayWithArray:[[Account AccountInstance] getAccountInfo]];
    if ([array count] > 7)
    {
        [array replaceObjectAtIndex:7 withObject:userid?userid:@""];
        if ([[Account AccountInstance] setAccountInfo:array])
        {
            return GD_ERR_OK;
        }
    }
    return GD_ERR_FAILED;
}
@end

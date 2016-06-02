//
//  Plugin_Account_Globall.h
//  plugin_account
//
//  Created by yi yang on 11-12-9.
//  Copyright (c) 2011年 autonavi.com. All rights reserved.
//

#ifndef Plugin_Login_Plugin_Login_Globall_h
#define Plugin_Login_Plugin_Login_Globall_h
#import <QuartzCore/QuartzCore.h>
#import "VCTranslucentBarButtonItem.h"

#if 1
#define face_change
#endif

#define LANGUAGE_ZH		0
#define LANGUAGE_HK		1
#define LANGUAGE_EN     2

//style:UIBarButtonItemStyleDone
#define BARLEFTBUTTON [[[UIBarButtonItem alloc] initWithTitle:@"back" style:UIBarButtonItemStylePlain target:self action:[self.navigationController popViewControllerAnimated:YES]] autorelease]//UIBarButtonItem

#define GOBACK [self.navigationController popViewControllerAnimated:YES]

#define BARBUTTONRIGHT(TITLE, SELECTOR) [[[VCTranslucentBarButtonItem alloc] initWithType:VCTranslucentBarButtonItemTypeNormal title:TITLE target:self action:SELECTOR] autorelease];

#define BARBUTTON(TITLE, SELECTOR)	[[[VCTranslucentBarButtonItem alloc] initWithType:VCTranslucentBarButtonItemTypeBackward title:nil target:self action:SELECTOR] autorelease]

#define ACC_GETLANGUAGE  fontType

#define IPHONE5_OFFSET (([[UIScreen mainScreen] currentMode].size.height == 1136.0f) ? (88.0f) : (0.0f))

#pragma mark regist interface 


#pragma mark UI reference

#define CONFIRM_BTN		@"确定"
#define BACK_BTN		@"返回"
#define CANCEL_BTN		@"取消"

#define HK_CONFIRM_BTN	@"確定"
#define HK_BACK_BTN		@"返回"
#define HK_CANCEL_BTN		@"取消"

#define EN_CONFIRM_BTN	@"Confirm"
#define EN_BACK_BTN		@"Back"
#define EN_CANCEL_BTN		@"Cancel"

/***************************************注册成功，手机号码验证成功，登陆成功的消息传递*/

#define SUCCESSED_NOTIFY @"SUCCESSED_NOTIFY"
#define LOGIN_SUCCESSED @"LOGIN_SUCCESSED"
#define RIGIST_SUCCESSED @"RIGIST_SUCCESSED"
#define LOGOUT_SUCCESSED @"LOGOUT_SUCCESSED"
#define PHONE_NUM_CHECK_SUCCESSED @"PHONE_NUM_CHECK_SUCCESSED"
#define UPDATAE_SUCCESSED @"UPDATAE_SUCCESSED"

/***************************************注册成功，手机号码验证成功，登陆成功的消息传递*/

/***************************************95190错误信息定义*/
//获取手机验证码
#define ERROR_BEEN_ORDERED @"ERROR_BEEN_ORDERED"
#define ERROR_PHONE_BOUND @"ERROR_PHONE_BOUND"
#define ERROR_PHONE_USED @"ERROR_PHONE_USED"
#define ERROR_SMS_FAIL  @"ERROR_SMS_FAIL "
#define ERROR_LICENSE_CHECK @"ERROR_LICENSE_CHECK"
//用户申请使用95190免费服务（30天）
#define ERROR_INUSE_95190 @"ERROR_INUSE_95190"
//用户订购95190服务验证
#define ERROR_VERIFY_RECEIPT @"ERROR_VERIFY_RECEIPT"
//针对用户订购修改绑定电话号码
#define ERROR_OVER_TIMES @"ERROR_OVER_TIMES"
//获取当前用户95190的服务状态
#define ERROR_NOORDER_INFO  @"ERROR_NOORDER_INFO "
//获取用户95190目的地
#define ERROR_NODEST_INFO @"ERROR_NODEST_INFO"
//获取用户95190当前目的地
#define ERROR_NOCURDEST_INFO @"ERROR_NOCURDEST_INFO"
//获取当前用户手机绑定情况
#define ERROR_NOT_BOUND @"ERROR_NOT_BOUND"
//获取当前用户英文版购买情况
#define ERROR_NOT_ORDER_ENGLISH @"ERROR_NOT_ORDER"
//当前用户失效 Authenticate 为 False
#define ERROR_False_Authenticate @"ERROR_False_Authenticate"

/***************************************95190错误信息定义*/  

#define ERROR_NET				@"网络连接失败,请确认网络状态"
#define ERROR_USER_FORMAT		@"用户名不合法,请输入合法的邮箱地址"
#define ERROR_PWD_LEN			@"密码长度要求6-32位英文字母或数字"
#define ERROR_PWD_FORMAT		@"密码格式不合法,请输入数字或字母"
#define ERROR_PWD_NOT_FIT		@"密码与确认密码不同"
#define ERROR_MOBILE_FORMAT		@"您输入的手机号有误,请重新输入"
#define ERROR_NICK				@"昵称命名不合法"
#define ERROR_AUTH_LEN			@"请输入验证码"

#define HK_ERROR_NET			@"網絡連接失敗,請確認網絡狀態"
#define HK_ERROR_USER_FORMAT	@"用戶名不合法,請輸入合法的郵箱地址"
#define HK_ERROR_PWD_LEN		@"密碼長度要求6-32位英文字母或數字"
#define HK_ERROR_PWD_FORMAT		@"密碼格式不合法,請輸入數字或字母"
#define HK_ERROR_PWD_NOT_FIT	@"密碼與確認密碼不同"
#define HK_ERROR_MOBILE_FORMAT	@"您輸入的手機號有誤,請重新輸入"
#define HK_ERROR_NICK			@"昵稱命名不合法"
#define HK_ERROR_AUTH_LEN		@"請輸入驗證碼"

#define EN_ERROR_NET			@"Internet connection failure, please confirm"
#define EN_ERROR_USER_FORMAT	@"User name is not valid Please enter a valid email address"
#define EN_ERROR_PWD_LEN		@"Password requires 6-32 alphabets or numbers"
#define EN_ERROR_LC_PWD_LEN		@"password requires 6-32 alphabets or numbers"
#define EN_ERROR_PWD_FORMAT		@"The password format is invalid, please enter numbers or letters"
#define EN_ERROR_LC_PWD_FORMAT	@"password format is invalid, please enter numbers or letters"
#define EN_ERROR_PWD_NOT_FIT	@"Password confirm failure"
#define EN_ERROR_LC_PWD_NOT_FIT	@"password confirm failure"
#define EN_ERROR_MOBILE_FORMAT	@"Invalid phone number"
#define EN_ERROR_NICK			@"Invalid nickname"
#define EN_ERROR_AUTH_LEN		@"Please enter verification code"

#define SUCC_SEND_EMAIL			@"申请已经发到您的注册邮箱"
#define SUCC_UPDATA_PWD			@"密码修改成功,请妥善保存您的密码"
#define SUCC_UPDATA_PROFILE		@"更新资料成功"
#define SUCC_LOGOUT				@"注销成功"
#define SUCC_LOGIN				@"登录成功"
#define SUCC_REGIST				@"注册成功"

#define HK_SUCC_SEND_EMAIL		@"申請已經發到您的注冊郵箱"
#define HK_SUCC_UPDATA_PWD		@"密碼修改成功,請妥善保存您的密碼"
#define HK_SUCC_UPDATA_PROFILE	@"更新資料成功"
#define HK_SUCC_LOGOUT			@"注銷成功"
#define HK_SUCC_LOGIN			@"登錄成功"
#define HK_SUCC_REGIST			@"注冊成功"

#define EN_SUCC_SEND_EMAIL		@"Application has sent to your e-mail address."
#define EN_SUCC_UPDATA_PWD		@"Password modified successfully, please keep your password."
#define EN_SUCC_UPDATA_PROFILE	@"Info update successfully."
#define EN_SUCC_LOGOUT			@"Logout success."
#define EN_SUCC_LOGIN			@"Login successful."
#define EN_SUCC_REGIST			@"Registration  successful."

#define FAIL_LOGIN				@"登录失败,请确认用户名和密码是否正确"
#define	FAIL_USER_EXIST			@"该用户名已被注册"
#define	FAIL_MAIL_EXIST			@"该邮箱已被注册"
#define	FAIL_MOBILE_EXIST		@"该电话已被注册"
#define FAIL_PARAMS				@"验证码错误"

#define HK_FAIL_LOGIN			@"登錄失敗,請確認用戶名和密碼是否正確"
#define	HK_FAIL_USER_EXIST		@"該用戶名已被注冊"
#define	HK_FAIL_MAIL_EXIST		@"該郵箱已被注冊"
#define	HK_FAIL_MOBILE_EXIST	@"該電話已被注冊"
#define HK_FAIL_PARAMS			@"驗證碼錯誤"

#define EN_FAIL_LOGIN			@"Fail to log in, please confirm your username and password."
#define	EN_FAIL_USER_EXIST		@"The username has been registered."
#define	EN_FAIL_MAIL_EXIST		@"The e-mail address has been registered."
#define	EN_FAIL_MOBILE_EXIST	@"The phone number has been registered."
#define EN_FAIL_PARAMS			@"Verification code error."

#define FAIL_MODIFY_PWD			@"修改密码失败,请确认您的原密码"
#define FAIL_UNFIND				@"帐号或密码不匹配或不存在"
#define FAIL_SEND_EMAIL			@"邮件发送失败,请确认您的邮箱是否正确或重试"

#define HK_FAIL_MODIFY_PWD		@"修改密碼失敗,請確認您的原密碼"
#define HK_FAIL_UNFIND			@"帳號或密碼不匹配或不存在"
#define HK_FAIL_SEND_EMAIL		@"郵件發送失敗,請確認您的郵箱是否正確或重試"

#define EN_FAIL_MODIFY_PWD		@"Fail to change password, please confirm your original password."
#define EN_FAIL_UNFIND			@"Account or password does not match or exist."
#define EN_FAIL_SEND_EMAIL		@"Fail to send e-mail, please confirm your e-mail address or try again."

#define	FAIL_PWD_ERROR			@"密码错误"
#define	FAIL_USER_NOT_EXIST		@"用户帐号不存在"
#define	FAIL_MAIL_UNFIND		@"邮箱不存在或未注册"
#define	FAIL_TEL_SEND			@"邮件发送失败"

#define	HK_FAIL_PWD_ERROR		@"密碼錯誤"
#define	HK_FAIL_USER_NOT_EXIST	@"用戶帳號不存在"
#define	HK_FAIL_MAIL_UNFIND		@"郵箱不存在或未注冊"
#define	HK_FAIL_TEL_SEND		@"郵件發送失敗"

#define	EN_FAIL_PWD_ERROR		@"Password Error."
#define	EN_FAIL_USER_NOT_EXIST	@"User account does not exit."
#define	EN_FAIL_MAIL_UNFIND		@"E-mail address doesn't exit or isn't registered."
#define	EN_FAIL_TEL_SEND		@"Fail to send e-mail"

#define MATCH_MAIL @"0123456789QWERTYUIOPASDFGHJKLZXCVBNMqwertyuiopasdfghjklzxcvbnm.@-_"
#define MATCH_PWD @"0123456789QWERTYUIOPASDFGHJKLZXCVBNMqwertyuiopasdfghjklzxcvbnm"

//#define COOKIE_SUPPORT	1
//#define NET_METHOD  0		//1:GET,0:POST
//#define NET_TIMEOUT 5.0f	//SET CONNECT TIMEOUT INTERVAL

int	g_NaviStatus_Interface_Flag;

int g_NaviStatus_interface_orient; //默认可以横竖屏
int g_NaviStatus_interface_state;

int moveHeight;						//param for keyboard

int g_UI_Type;						//default =1(iphone),0(ipad)
int g_Font_Size;					//font


UITextField *currText;				//param for splitSpace

typedef enum GD_Account_ItemType
{
    GD_Account_Item_NickName = 100,
    GD_Account_Item_ModifyPSW,
    GD_Account_Item_Area,
    GD_Account_Item_FirstName,
    GD_Account_Item_sex,
    GD_Account_Item_telNumber,
    GD_Account_Item_Signature,
    
}GD_Account_ItemType;

#endif

//
//  Account.h
//  New_GNaviServer
//
//  Created by yang yi on 12-3-26.
//  Copyright 2012 autonavi.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GDBL_Account.h"
#import "NetKit.h"

#pragma mark regist interface 

#define HEAD_REGIST			@"auth/register_byphone_v2?"
#define HEAD_GET_AUTH_IMG	@"website/check_codeimage/?"
#define HEAD_LOGIN			@"auth/login_v2?"
#define HEAD_THIRD_LOGIN	@"auth/login_tpuser_v2?"
#define HEAD_LOGOUT			@"auth/logout_v2?"
#define HEAD_UNBIND_TOKEN	@"auth/unbindtoken/?"
#define HEAD_GET_PROFILE	@"auth/myprofile_v2?"
#define HEAD_UPDATE_PROFILE @"auth/updateprofile_v2?"
#define HEAD_RESET_PWD		@"auth/resetpw_byphone_v2?"
#define HEAD_UPDATE_PWD		@"auth/updatepassword_v2?"
#define HEAD_SEND_PWD_EMAIL @"auth/sendpasswordemail_v2?"
#define HEAD_GET_CHECK_NUMBER @"auth/auth_getvcode_sms_v2?"
#define HEAD_GET_95190CHECK @"iphoneorder/order_getvcode_sms_v2?"
#define HEAD_BIND_95190PHONE_NUMBER @"iphoneorder/order_bindphone_sms_v2?"
#define HEAD_OLD_USER_BIND_PHONE_NUMBER @"auth/bind_phone_foruser_v2?"
#define HEAD_MODIFY_95190PHONE_NUMBER @"iphoneorder/order_bindphone_sms_v2?"
#define HEAD_CLEAR_95190PHONE_NUMBER @"iphoneorder/order_cancelbindphone_v2?"
#define HEAD_GET_95190PHONE_NUMBER @"iphoneorder/order_get_bindstate_v2?"
#define HEAD_GET_95190_DESTINATION @"iphoneorder/order_getdest_95190_byphone_v2_v2?"
#define HEAD_GET_95190_STATUS @"iphoneorder/order_getstate_95190?"
#define HEAD_BUY_95190_SERVICE @"iphoneorder/order_95190?"
#define HEAD_FREE_95190 @"iphoneorder/order_95190_free?"
#define HEAD_ORDER_EN_CHECK @"iphoneorder/order_en_check?"
#define HEAD_PRE_CALL_95190 @"iphoneorder/pre_call_95190_byphone_v2_v2?"
#define HEAD_GET_CURRENT95190_DES @"iphoneorder/order_getcurdest_95190_byphone_v2_v2?"
#define HEAD_GET_EN_TEXT @"iphoneorder/order_en_taskbar_txt?"
#define HEAD_GET_95190_TEXT @"iphoneorder/order_95190_taskbar_txt?"
#define HEAD_CHECK_COEDE @"auth/auth_checkvcode_sms_v2?"
#define HEAD_GET_HEAD @"auth/download_headimage_v2?"
#define HEAD_UPLOAD_HEAD @"auth/upload_headimage_v2?"
#define HEAD_Get_95190ButtonInfo @"iphoneorder/order_tel_image_button_txt?"
#pragma mark xml reference

#define XML_DEBUG 0				//是否打印LOG信息

#define FREE_USER @"free"   //免费用户
#define BUY_USER @"buy"        //订购用户
#define LIMIT_DAYS 540        //95190订购最大天数

#define KEY_FOR_RESULT @"Result"    	//parse xml result
#define KEY_FOR_MESSAGE @"Message"  	//reponse detail
#define KEY_FOR_AUTH @"Authenticate"	//is Authenticate
#define KEY_FOR_TIMESTAMP @"TimeStamp"	//TimeStamp
#define KEY_FOR_Error @"Error"	//TimeStamp
#define KEY_FOR_PROFILE @"profile"		//account info
#define KEY_FOR_95190_POI @"95190POI"		//poi info
#define KEY_FOR_Text1 @"text1"		//文字栏 info
#define KEY_FOR_Text2 @"text2"		//文字栏 info

#define PARSE_OK				@"OK"
#define PARSE_CHECK_SUCCESS				@"SUCCESS"
#define PARSE_CHECK_FAIL				@"FAIL"

#define FREE_95190_FAILE			@"FREE_95190_FAILE"  //开通免费95190失败，如：遭到攻击
#define BUY_95190_FAILE			@"BUY_95190_FAILE"  //向苹果购买95190成功后，上传收据失败，如：遭到攻击
#define BUY_95190_TIMEOUT			@"BUY_95190_TIMEOUT"  //向苹果购买95190成功后，上传收据时，网络连接超时
#define NET_CON_TIMEOUT			@"NET_CON_TIMEOUT"  //网络连接超时
#define NET_CON_FAILE			@"NET_CON_FAILE"  //网络连接失败
#define PARSE_DATA_NIL			@"PARSE_FAIL"
#define PARSE_ERROR				@"PARSE_ERROR"

#define PARSE_LOGIN_ERROR		@"LOGIN_ERROR"
#define PARSE_ALREADY_LOGIN		@"ALREADY_LOGIN"
#define PARSE_USER_NOT_EXISTS	@"ERROR_USER_NOTEXIST"
#define PARSE_USER_NOT_ACTIVATE	@"USER_NOT_ACTIVATE"
#define PARSE_UNKNOWN_ERROR		@"UNKNOWN_ERROR"
#define PARSE_SEND_MAIL_ERROR	@"ERROR_SENDEMAIL_FAIL"
#define ERROR_NO_THISUSER       @"ERROR_NO_THISUSER"   //邮箱未注册
#define PARSE_USER_EXISTS		@"USER_ALREADY_EXISTS"
#define PARSE_EMAIL_EXISTS		@"EMAIL_ALREADY_EXISTS"
#define PARSE_TEL_EXISTS		@"TEL_ALREADY_EXISTS"
#define PARSE_PARAMS_ERROR		@"PARAMS_ERROR"
#define TP_USER           @"TP_USER"
#define GD_USER           @"GD_USER"
#define ERROR_SENDMSG_MORE8           @"ERROR_SENDMSG_MORE8"
#define ERROR_PHONE_NOT_REGISTERED  @"ERROR_PHONE_NOT_REGISTERED"
#define ERROR_BOUND_PHONE @"ERROR_BOUND_PHONE"
#define ERROR_PHONE_REGISTERED @"ERROR_PHONE_REGISTERED"

/*Authenticate为False时，传送消息至高德增值服务界面更新登陆状态*/

 #define RELOAD_NOTIFY @"RELOAD_NOTIFY"

#define THIRD_LODIN_FINISH @"thirdloginfinish"
 /**************************************************/

#define COOKIE_SUPPORT	1
#define NET_METHOD  1		//1:GET,0:POST


//typedef struct GACCOUNTINFO{
//	long userId;			//用户ID 
//	NSString* userName;		//用户名
//	NSString* nickName;		//呢称
//	NSString* firstName;	//姓氏
//	NSString* lastName;		//名字
//	NSString* telNumber;	//手机号
//	NSString* email;		//邮箱
//	NSString* deviceId;		//硬件ID(uuid)
//	NSString* phoneDevice;	//导航设备使用电话号码
//	int sex;				//性别
//	int age;				//年龄
//	NSString* country;		//国家
//	NSString* province;		//省份
//	NSString* city;			//城市名称或城市代码
//}AccountInfo;

@interface AccountInfo : NSObject {
	long userId;			//用户ID
	NSString* userName;		//用户名
	NSString* nickName;		//呢称
	NSString* firstName;	//姓氏
	NSString* lastName;		//名字
	NSString* telNumber;	//手机号
	NSString* email;		//邮箱
	NSString* deviceId;		//硬件ID(uuid)
	NSString* phoneDevice;	//导航设备使用电话号码
	int sex;				//性别
	int age;				//年龄
	NSString* country;		//国家
	NSString* province;		//省份
	NSString* city;			//城市名称或城市代码
        
    int  m_retaiDay;		//剩余天数
    NSString* m_order;		//免费用户or订购用户
    NSString* m_end_timer;		//结束时间
    NSString* m_Destination;		//95190下发目的地
    NSString* m_tel_95190;		//95190绑定手机
    NSString* gdusername;		//高德账户名
    NSString* headimage;		//头像图片信息
    NSString* signature;		//头像图片信息
    NSString* tpusername;		//第三方账户名称
    NSString* Gd_User_Name;		//第三方账户绑定的高德账户名
    NSString* loginType;		//登陆帐号类型
}
@property (nonatomic, readwrite)long userId;		//用户ID
@property (nonatomic, copy) NSString* userName;	//用户名
@property (nonatomic, copy)NSString* nickName;	//呢称
@property (nonatomic, copy)NSString* firstName;	//姓氏
@property (nonatomic, copy)NSString* lastName;	//名字
@property (nonatomic, copy)NSString* telNumber;	//手机号
@property (nonatomic, copy)NSString* email;		//邮箱
@property (nonatomic, copy)NSString* deviceId;	//硬件ID(uuid)
@property (nonatomic, copy)NSString* phoneDevice;	//导航设备使用电话号码
@property (nonatomic, readwrite)int sex;			//性别
@property (nonatomic, readwrite)int age;			//年龄
@property (nonatomic, copy)NSString* country;		//国家
@property (nonatomic, copy)NSString* province;	//省份
@property (nonatomic, copy)NSString* city;		//城市名称或城市代码
@property (nonatomic, copy)NSString* birthday;		//出生年月
@property (nonatomic, copy)NSString* loginType;		//登陆帐号类型
@property (nonatomic, copy)NSString* gdusername;		//高德账户名
@property (nonatomic, copy)NSString* headimage;		//头像图片信息
@property (nonatomic, copy)NSString* signature;		//头像图片信息
@property (nonatomic, copy)NSString* tpusername;		//第三方账户名称
@property (nonatomic, copy)NSString* Gd_User_Name;		//第三方账户绑定的高德账户名
@property (nonatomic, assign)int tptype;		//第三方账户绑定的类型 1 新浪 2 腾讯

@property (nonatomic, assign)int  m_retaiDay;			//剩余天数
@property (nonatomic, copy)NSString* m_order;		//免费用户or订购用户
@property (nonatomic, copy)NSString* m_end_timer;		//结束时间
@property (nonatomic, copy)NSString* m_Destination;		//95190下发目的地
@property (nonatomic, copy)NSString* m_tel_95190;		//95190绑定手机

@end

@interface Account : NSObject<NetRequestExtDelegate>
{
}


#pragma mark Public
+(Account*) AccountInstance;

//拼接搜索参数字串
-(NSString *)createPostURL:(NSMutableDictionary *)params;
-(NSData *)getResultData:(NSMutableDictionary *)params WithHeader:(NSString*)header;
//按搜索参数获取请求数据并解析结果
-(BOOL) parseWithParam:(NSMutableDictionary *)params WithHeader:(RequestType ) opType;
-(BOOL) parseWithParam:(NSMutableDictionary *)params WithHeader:(RequestType ) opType WithBody:(NSString *)body;
-(BOOL) parseWithParam:(NSMutableDictionary *)params WithHeader:(RequestType ) opType  fileKey:(NSString *)fileKey;
#pragma mark public methods
/**
 *注销TOKEN
 */
-(BOOL) unbindTokenWithDelegate:(id)target;

/**
 *退出
 */
-(BOOL)logoutWithDelegate:(id)target;

//删除UGC同步时间截
- (BOOL)deleteUgcServerTime;

-(int)setLoginStatus:(int) status;

-(int)setAccountName:(NSString*) name Password:(NSString*)pwd;
-(int)setAccountInfo:(NSArray *)array;
-(NSArray *)getAccountInfo;


-(void)accountRequestSucceeded:(NSData *)data WithOperation:(id)op;
-(void)accountRequestFailured:(NSError *)error withOperation:(id)op;
-(void)CancelAllREQ;

@end



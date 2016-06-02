//
//  AccountNotify.h
//  AutoNavi
//
//  Created by gaozhimin on 13-5-9.
//
//

#import <Foundation/Foundation.h>

typedef enum Account_Alert
{
    /*一类提示框*/
    Account_Alert_Net_Error = 1101,//网络连接出错,请检查网络连接后重试
    Account_Alert_Net_TimeOut ,   //网络连接出错,请检查网络连接后重试
    Account_Alert_Input_Phone,  //请输入11位手机号码
    Account_Alert_Input_Check,  //请输入验证码
    Account_Alert_Input_Password,  //请输入密码
    Account_Alert_Input_Email,  //请输入注册邮箱地址
    Account_Alert_Check_Error,  //验证码错误
    Account_Alert_Email_Error,  //注册邮箱错误
    Account_Alert_Phone_Registed,  //您的手机号码已被注册
    Account_Alert_Phone_Unregisted,  //手机号尚未注册，请注册
    Account_Alert_Password_Condition,  //密码要求是6-32位英文或数字，请重新输入
    Account_Alert_Password_Different,  //确认密码与密码不一致
    Account_Alert_NewPassword_Different,  //确认密码与新密码不一致
    Account_Alert_OldPassword_Error,  //旧密码错误
    Account_Alert_Nickname_Condition,  //请输入1-24位数字，字母
    Account_Alert_Signature_Condition,  //输入签名字符长度不能超过140个字符
    Account_Alert_Input_Account, //请输入注册的手机号或邮箱
    Account_Alert_Non_Account, //帐号不存在
    Account_Alert_Non_User, //该用户不存在
    Account_Alert_Password_Error, //用户不存在或者密码错误
    Account_Alert_ModifyPassword_Success, //密码修改成功
    Account_Alert_Modify_Error, //修改失败，请重试
    Account_Alert_Relogin, //请重新登录
    Account_Alert_Regist_Error, //注册失败，请重试
    Account_Alert_profile_fail, //获取资料失败
    Account_Alert_SendEmail_Fail, //获取资料失败
    Account_Alert_Phone_Different,//手机号和获取验证码的手机号不一致，请重新输入
    Account_Alert_Bind_Error,//手机绑定失败，请重试
    /*一类提示框*/
    
    /*二类提示框*/
    Account_Alert_SMS_Limit,  //抱歉，已达到今天短信数量的上限，请您明天再使用
    Account_Alert_Email_Success,  //邮件已发送,请按邮件提示重置密码
    Account_Alert_Check_Success,  //验证码发送成功
    Account_Alert_Regist_Success,  //恭喜您注册成功
    Account_Alert_Password_Success,  //密码设置成功
    Account_Alert_Sex_Success,  //修改性别成功
    Account_Alert_Nickname_Success,  //修改昵称成功
    Account_Alert_Age_Success,  //修改年龄成功
    Account_Alert_Region_Success,  //修改地区成功
    Account_Alert_Signature_Success,  //修改签名成功
    Account_Alert_Head_Success,  //修改头像成功
    Account_Alert_Bind_Success,  //绑定手机号成功
    Account_Alert_First_Success,  //修改姓氏成功
    Account_Alert_Unbind_Success,  //解除成功
    Account_Alert_ThirdToGD_Success,  //您已绑定成功
    /*二类提示框*/
    
    
    /*三类提示框*/
    Account_Alert_User_Agreement,  //我已阅读并同意用户使用协议
    /*三类提示框*/
}Account_Alert;

@interface AccountNotify : NSObject <UIAlertViewDelegate>

+ (AccountNotify *)SharedInstance;

#pragma mark - 弹出框提示
- (void)ShowAccountMessageWithTag:(Account_Alert)Tag delegate:(id)delegate;

@end

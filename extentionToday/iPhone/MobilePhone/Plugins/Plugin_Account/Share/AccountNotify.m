//
//  AccountNotify.m
//  AutoNavi
//
//  Created by gaozhimin on 13-5-9.
//
//

#import "AccountNotify.h"
#import "GDBL_Account.h"
#import "ANParamValue.h"
#import "AccountPersonalData.h"
#import "GDAlertView.h"

Class object_getClass(id object);

static AccountNotify *g_Plugin_Account_Notify = nil;

@interface AccountNotify()
{
    BOOL bShowNetError;
}

@end

@implementation AccountNotify

+ (AccountNotify *)SharedInstance
{
    if (g_Plugin_Account_Notify == nil)
    {
        g_Plugin_Account_Notify = [[AccountNotify alloc] init];
    }
    return g_Plugin_Account_Notify;
}

- (id)init
{
    if (self = [super init])
    {
        bShowNetError = NO;
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(AccountNotifyMessage:) name:NOTIFY_ACCOUNT object:nil];
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}
#pragma mark - notify method

- (void)AccountNotifyMessage:(NSNotification *)notify
{
    AccountPersonalData *personalData = [AccountPersonalData SharedInstance];
    
    NSArray* result = (NSArray*)[notify object];
    
    NSString *net_result = [result objectAtIndex:0];
    int requestType=[[result objectAtIndex:1] intValue];
    if ([net_result isEqualToString:NET_CON_TIMEOUT] || [net_result isEqualToString:PARSE_DATA_NIL] || [net_result isEqualToString:PARSE_ERROR] )
    {
        
    }
    if (requestType == REQ_GET_PROFILE)
    {
        personalData.isGetUserInfo = 0;
    }
    
    if ([result count] >= 3)
    {
        /*PARSE_OK*/
        int nResult = [[result objectAtIndex:2] intValue];
        if (requestType == REQ_GET_PROFILE)
        {
            if (nResult == GD_ERR_OK)
            {
                personalData.isGetUserInfo = 2;
                NSMutableArray *accountInfoArray = [NSMutableArray arrayWithArray:[[Account AccountInstance] getAccountInfo]];
                
                AccountInfo *userinfo = [[result objectAtIndex:3] objectForKey:KEY_FOR_PROFILE];
                if ([userinfo.loginType isEqualToString:TP_USER]) //第三方登陆获取资料
                {
                    if ([userinfo.userName length] > 0) //说明绑定高德帐号
                    {
                        if (userinfo.tptype == 1)
                        {
                            [accountInfoArray replaceObjectAtIndex:5 withObject:personalData.m_accountXLWBuuid];
                            [[Account AccountInstance] setLoginStatus:5]; //第三方登录成高德登录
                        }
                        else if (userinfo.tptype == 2)
                        {
                            [accountInfoArray replaceObjectAtIndex:5 withObject:personalData.m_accountTXWBuuid];
                            [[Account AccountInstance] setLoginStatus:6]; //第三方登录成高德登录
                        }
                        else
                        {
                            [[Account AccountInstance] setLoginStatus:5]; //第三方登录成高德登录
                        }
                    }
                    else
                    {
                        [[NSNotificationCenter defaultCenter] postNotificationName:HEAD_GET_PROFILE object:result];
                        return;
                    }
                    
                }
                personalData.m_accountEmail = userinfo.email;
                personalData.m_accountNickNmae = userinfo.nickName;
                personalData.m_accountPhoneNumber = userinfo.telNumber;
                personalData.m_profileAge = userinfo.age;
                personalData.m_profileProvince = userinfo.province;
                personalData.m_profileCity = userinfo.city;
                personalData.m_profileSex = userinfo.sex;
                personalData.m_profileNickName = userinfo.nickName;
                personalData.m_icallFirstName = userinfo.firstName;
                personalData.m_icallSex = userinfo.sex;
                personalData.m_profileSignature = userinfo.signature;
                
                [accountInfoArray replaceObjectAtIndex:3 withObject:userinfo.nickName];
                [accountInfoArray replaceObjectAtIndex:6 withObject:userinfo.tpusername];
                if ([userinfo.birthday length] > 0)
                {
                    NSArray *array = [userinfo.birthday componentsSeparatedByString:@"-"];
                    if ([array count] == 3)
                    {
                        personalData.m_profileYear = [[array objectAtIndex:0] intValue];
                        personalData.m_profileMonth = [[array objectAtIndex:1] intValue];
                        personalData.m_profileDay = [[array objectAtIndex:2] intValue];
                    }
                }
                if ([userinfo.headimage length] > 0)
                {
                     personalData.m_profileHeadUrl = userinfo.headimage;
                    [NSThread detachNewThreadSelector:@selector(GetImageWithURL:) toTarget:self withObject:userinfo.headimage];
                }
                [[Account AccountInstance] setAccountInfo:accountInfoArray];
                
            }
        }
        else if (requestType == REQ_UPDATE_PWD)
        {
            if (nResult == GD_ERR_OK)
            {
                [self ShowAccountMessageWithTag:Account_Alert_ModifyPassword_Success delegate:self];
            }
            else
            {
                [self ShowAccountMessageWithTag:Account_Alert_OldPassword_Error delegate:self];
            }
        }
        else if (requestType == REQ_UPLOAD_HEAD)
        {
            if (nResult == GD_ERR_OK)
            {
                personalData.m_profileHead = personalData.p_profileHead;
                if (personalData.bTip)
                {
                    [self ShowAccountMessageWithTag:Account_Alert_Head_Success delegate:self];
                }

                NSData *data = UIImagePNGRepresentation(personalData.m_profileHead);
                NSMutableArray *accountInfoArray = [NSMutableArray arrayWithArray:[[Account AccountInstance] getAccountInfo]];
                [accountInfoArray replaceObjectAtIndex:4 withObject:data];
                [[Account AccountInstance] setAccountInfo:accountInfoArray];
            }
            else
            {
                if (personalData.bTip)
                {
                    [self ShowAccountMessageWithTag:Account_Alert_Modify_Error delegate:self];
                }
            }
        }
        else if (requestType == REQ_SEND_PWD_EMAIL)
        {
            int nResult = [[result objectAtIndex:2] intValue];
            
            if (nResult == GD_ERR_OK)
            {
                [self ShowAccountMessageWithTag:Account_Alert_Email_Success delegate:self];
            }
            else if(nResult == GD_ERR_USER_NOT_EXISTS)
            {
                [self ShowAccountMessageWithTag:Account_Alert_Non_User delegate:self];
            }
            else
            {
                [self ShowAccountMessageWithTag:Account_Alert_Non_User delegate:self];
            }
        }
        else if (requestType == REQ_UPDATE_PROFILE)
        {
            int nResult = [[result objectAtIndex:2] intValue];
            
            if (nResult == GD_ERR_OK)
            {
                if (personalData.m_modifyType == ACCOUNT_MODIFY_SEX)
                {
                    personalData.m_profileSex = personalData.p_profileSex;
                    [self ShowAccountMessageWithTag:Account_Alert_Sex_Success delegate:self];
                }
                else if (personalData.m_modifyType == ACCOUNT_MODIFY_REGION)
                {
                    personalData.m_profileProvince = personalData.p_profileProvince;
                    personalData.m_profileCity = personalData.p_profileCity;
                    [self ShowAccountMessageWithTag:Account_Alert_Region_Success delegate:self];
                }
                else if (personalData.m_modifyType == ACCOUNT_MODIFY_AGE)
                {
                    personalData.m_profileYear = personalData.p_profileYear;
                    personalData.m_profileMonth = personalData.p_profileMonth;
                    personalData.m_profileDay = personalData.p_profileDay;
                    [self ShowAccountMessageWithTag:Account_Alert_Age_Success delegate:self];
                }
                else if (personalData.m_modifyType == ACCOUNT_MODIFY_NICK)
                {
                    personalData.m_profileNickName = personalData.p_profileNickName;
                    [self ShowAccountMessageWithTag:Account_Alert_Nickname_Success delegate:self];
                    GDBL_setAccountNickName(personalData.m_profileNickName);
                }
                else if (personalData.m_modifyType == ACCOUNT_MODIFY_SIGN)
                {
                    personalData.m_profileSignature = personalData.p_profileSignature;
                    [self ShowAccountMessageWithTag:Account_Alert_Signature_Success delegate:self];
                }
                else if (personalData.m_modifyType == ACCOUNT_MODIFY_FIRST_NAME)
                {
                    personalData.m_icallFirstName = personalData.p_icallFirstName;
                    [self ShowAccountMessageWithTag:Account_Alert_First_Success delegate:self];
                }
                else if (personalData.m_modifyType == ACCOUNT_MODIFY_TXINFO)
                {
                    personalData.m_profileNickName = personalData.p_profileNickName;
                    personalData.m_profileSex = personalData.p_profileSex;
                    personalData.m_profileYear = personalData.p_profileYear;
                    personalData.m_profileMonth = personalData.p_profileMonth;
                    personalData.m_profileDay = personalData.p_profileDay;
                    personalData.m_profileProvince = personalData.p_profileProvince;
                    personalData.m_profileCity = personalData.p_profileCity;
                    personalData.m_profileSignature = personalData.p_profileSignature;
                }
                else if (personalData.m_modifyType == ACCOUNT_MODIFY_XLINFO)
                {
                    personalData.m_profileNickName = personalData.p_profileNickName;
                    personalData.m_profileSex = personalData.p_profileSex;
                    personalData.m_profileProvince = personalData.p_profileProvince;
                    personalData.m_profileCity = personalData.p_profileCity;
                    personalData.m_profileSignature = personalData.p_profileSignature;
                }
            }
            else
            {
                if (!(personalData.m_modifyType == ACCOUNT_MODIFY_TXINFO || personalData.m_modifyType == ACCOUNT_MODIFY_XLINFO))
                {
                    [self ShowAccountMessageWithTag:Account_Alert_Modify_Error delegate:self];
                    
                }
            }
        }
        else if (requestType == REQ_CLEAR_95190PHONE_NUMBER)
        {
            int nResult = [[result objectAtIndex:2] intValue];
            
            if (nResult == GD_ERR_OK)
            {
                personalData.m_icallPhoneNumber = @"";
                [self ShowAccountMessageWithTag:Account_Alert_Unbind_Success delegate:self];
            }
            else
            {
                [self ShowAccountMessageWithTag:Account_Alert_Modify_Error delegate:self];
            }
        }
        else if (requestType == REQ_GET_95190_STATUS)
        {
            int nResult = [[result objectAtIndex:2] intValue];
            if (nResult != GD_ERR_OK)
            {
                [personalData AccountClearIcall];
            }
        }
        else  if (requestType == REQ_BUY_95190_SERVICE)
        {
            int nResult = [[result objectAtIndex:2] intValue];
            if (nResult == GD_ERR_OK)
            {
                AccountInfo *userInfo = [[result objectAtIndex:3] objectForKey:KEY_FOR_PROFILE];
                personalData.m_icallOrder = BUY_USER;
                personalData.m_icallPhoneNumber = userInfo.m_tel_95190;
                personalData.m_icallRemainDay = [NSString stringWithFormat:@"%d",userInfo.m_retaiDay];
            }
        }
        else  if (requestType == REQ_FREE_95190)
        {
            int nResult = [[result objectAtIndex:2] intValue];
            if (nResult == GD_ERR_OK)
            {
                AccountInfo *userInfo = [[result objectAtIndex:3] objectForKey:KEY_FOR_PROFILE];
                personalData.m_icallOrder = FREE_USER;
                personalData.m_icallPhoneNumber = userInfo.m_tel_95190;
                personalData.m_icallRemainDay = [NSString stringWithFormat:@"%d",userInfo.m_retaiDay];
            }
        }
    }
    
    
    if (requestType == REQ_LOGIN)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:HEAD_LOGIN object:result];
    }
    else if (requestType == REQ_REGIST)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:HEAD_REGIST object:result];
    }
    else if (requestType == REQ_GET_95190_TEXT)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:HEAD_GET_95190_TEXT object:result];
    }
    else if (requestType == REQ_GET_95190_STATUS)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:HEAD_GET_95190_STATUS object:result];
    }
    else  if (requestType == REQ_BUY_95190_SERVICE)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:HEAD_BUY_95190_SERVICE object:result];
    }
    else  if (requestType == REQ_GET_CHECK_NUMBER)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:HEAD_GET_CHECK_NUMBER object:result];
    }
    else  if (requestType == REQ_CHECK_CODE)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:HEAD_CHECK_COEDE object:result];
    }
    else  if (requestType == REQ_RESET_PWD)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:HEAD_UPDATE_PWD object:result];
    }
    else  if (requestType == REQ_FREE_95190)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:HEAD_FREE_95190 object:result];
    }
    else  if (requestType == REQ_GET_PROFILE)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:HEAD_GET_PROFILE object:result];
    }
    else  if (requestType == REQ_THIRD_LOGIN)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:HEAD_THIRD_LOGIN object:result];
    }
    else if (requestType == REQ_UPDATE_PWD)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:HEAD_UPDATE_PWD object:result];
    }
    else if (requestType == REQ_SEND_PWD_EMAIL)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:HEAD_SEND_PWD_EMAIL object:result];
    }
    else if (requestType == REQ_UPDATE_PROFILE)
    {
        if (!(personalData.m_modifyType == ACCOUNT_MODIFY_XLINFO || personalData.m_modifyType == ACCOUNT_MODIFY_TXINFO))
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:HEAD_UPDATE_PROFILE object:result];
        }
        else
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:ACCOUNT_RELOAD_TABLEVIEW object:nil];
        }
    }
    else if (requestType == REQ_BIND_95190PHONE_NUMBER)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:HEAD_BIND_95190PHONE_NUMBER object:result];
    }
    else if (requestType == REQ_GET_95190CHECK)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:HEAD_GET_95190CHECK object:result];
    }
    else if (requestType == REQ_OLD_USER_BIND_PHONE_NUMBER)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:HEAD_OLD_USER_BIND_PHONE_NUMBER object:result];
    }
    else if (requestType == REQ_UPLOAD_HEAD)
    {
        if (personalData.bTip)
        {
            personalData.bTip = NO;
            [[NSNotificationCenter defaultCenter] postNotificationName:HEAD_UPLOAD_HEAD object:result];
        }
        else
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:ACCOUNT_RELOAD_TABLEVIEW object:nil];
        }
    }
    else if (requestType == REQ_BIND_95190PHONE_NUMBER)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:HEAD_BIND_95190PHONE_NUMBER object:result];
    }
    else if (requestType == REQ_CLEAR_95190PHONE_NUMBER)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:HEAD_CLEAR_95190PHONE_NUMBER object:result];
    }
    else if (requestType == REQ_LOGOUT)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:HEAD_LOGOUT object:result];
    }

}

- (void)GetImageWithURL:(NSString *)str_url
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    AccountPersonalData *personalData = [AccountPersonalData SharedInstance];
    char *imgSZData = NULL;
    int nLen = 0;
    NSArray *tmpArray;
    GDBL_GetAccountInfo(&tmpArray);
    int loginType = [[tmpArray objectAtIndex:0] intValue];
    
    if (loginType == 5)
    {
        GDBL_GET_HEAD(str_url,&imgSZData,&nLen,personalData.m_accountXLWBuuid,1);
    }
    else if (loginType == 6)
    {
        GDBL_GET_HEAD(str_url,&imgSZData,&nLen,personalData.m_accountTXWBuuid,2);
    }
    else
    {
        GDBL_GET_HEAD(str_url,&imgSZData,&nLen,nil,0);
    }
    
    NSData* imgData = [NSData dataWithBytes:imgSZData length:nLen];
   
    if (imgData)
    {
        UIImage *image = [UIImage imageWithData:imgData];
        if (image)
        {
            personalData.m_profileHead = image;
            personalData.bDefaultHead = NO;

            NSData *data = UIImagePNGRepresentation(personalData.m_profileHead);
            NSMutableArray *accountInfoArray = [NSMutableArray arrayWithArray:[[Account AccountInstance] getAccountInfo]];
            [accountInfoArray replaceObjectAtIndex:4 withObject:data];
            [[Account AccountInstance] setAccountInfo:accountInfoArray];
            
            [self performSelectorOnMainThread:@selector(UpdateTableView) withObject:nil waitUntilDone:YES];
        }
    }
    
    [pool release];
}

- (void)UpdateTableView
{
    NSArray *array = [NSArray arrayWithObjects:PARSE_OK,[NSNumber numberWithBool:YES],[NSNumber numberWithInt:GD_ERR_OK], nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:HEAD_GET_PROFILE object:array];
}

#pragma mark - 弹出框提示
- (void)ShowAccountMessageWithTag:(Account_Alert)Tag delegate:(id)delegate
{
    /*一类提示框*/
    if (Tag == Account_Alert_Net_Error)
    {
        [self AlertWithType:1 title:nil content:STR(@"Account_NetError", Localize_Account) delegate:delegate tag:Tag];
    }
    else if (Tag == Account_Alert_Net_TimeOut)
    {
        [self AlertWithType:1 title:nil content:STR(@"Account_NetTimeout", Localize_Account) delegate:delegate tag:Tag];
    }
    else if (Tag == Account_Alert_Input_Phone)
    {
        [self AlertWithType:1 title:nil content:STR(@"Account_Input11Phone", Localize_Account) delegate:delegate tag:Tag];
    }
    else if (Tag == Account_Alert_Input_Check)
    {
        [self AlertWithType:1 title:nil content:STR(@"Account_InputVerification", Localize_Account) delegate:delegate tag:Tag];
    }
    else if (Tag == Account_Alert_Input_Password)
    {
        [self AlertWithType:1 title:nil content:STR(@"Account_InputPassword", Localize_Account) delegate:delegate tag:Tag];
    }
    else if (Tag == Account_Alert_Input_Email)
    {
        [self AlertWithType:1 title:nil content:STR(@"Account_InputEmail", Localize_Account) delegate:delegate tag:Tag];
    }
    else if (Tag == Account_Alert_Check_Error)
    {
        [self AlertWithType:1 title:nil content:STR(@"Account_VerificationError", Localize_Account) delegate:delegate tag:Tag];
    }
    else if (Tag == Account_Alert_Email_Error)
    {
        [self AlertWithType:1 title:nil content:STR(@"Account_EmailError", Localize_Account) delegate:delegate tag:Tag];
    }
    else if (Tag == Account_Alert_Phone_Registed)
    {
        [self AlertWithType:1 title:nil content:STR(@"Account_PhoneRegistered", Localize_Account) delegate:delegate tag:Tag];
    }
    else if (Tag == Account_Alert_Phone_Unregisted)
    {
        [self AlertWithType:1 title:nil content:STR(@"Account_NoPhone", Localize_Account) delegate:delegate tag:Tag];
    }
    else if (Tag == Account_Alert_Password_Condition)
    {
        [self AlertWithType:1 title:nil content:STR(@"Account_PasswordConditionAlert", Localize_Account) delegate:delegate tag:Tag];
    }
    else if (Tag == Account_Alert_Password_Different)
    {
        [self AlertWithType:1 title:nil content:STR(@"Account_PasswordDif", Localize_Account) delegate:delegate tag:Tag];
    }
    else if (Tag == Account_Alert_NewPassword_Different)
    {
        [self AlertWithType:1 title:nil content:STR(@"Account_NewPasswordDif", Localize_Account) delegate:delegate tag:Tag];
    }
    else if (Tag == Account_Alert_OldPassword_Error)
    {
        [self AlertWithType:1 title:nil content:STR(@"Account_OldPasswordError", Localize_Account) delegate:delegate tag:Tag];
    }
    else if (Tag == Account_Alert_Nickname_Condition)
    {
        [self AlertWithType:1 title:nil content:STR(@"Account_ContentCondition", Localize_Account) delegate:delegate tag:Tag];
    }
    else if (Tag == Account_Alert_Signature_Condition)
    {
       [self AlertWithType:1 title:nil content:STR(@"Account_SignatureCondition", Localize_Account) delegate:delegate tag:Tag];
    }
    else if (Tag == Account_Alert_Input_Account)
    {
        [self AlertWithType:1 title:nil content:STR(@"Account_InputAccount", Localize_Account) delegate:delegate tag:Tag];
    }
    else if (Tag == Account_Alert_Non_Account)
    {
        [self AlertWithType:1 title:nil content:STR(@"Account_NoAccount", Localize_Account) delegate:delegate tag:Tag];
    }
    else if (Tag == Account_Alert_Password_Error)
    {
        [self AlertWithType:1 title:nil content:STR(@"Account_UserPasswordError", Localize_Account) delegate:delegate tag:Tag];
    }
    else if (Tag == Account_Alert_ModifyPassword_Success)
    {
        [self AlertWithType:1 title:nil content:STR(@"Account_ModifyPassSuccess", Localize_Account) delegate:delegate tag:Tag];
    }
    else if (Tag == Account_Alert_Modify_Error)
    {
        [self AlertWithType:1 title:nil content:STR(@"Account_ModifyError", Localize_Account) delegate:delegate tag:Tag];
    }
    else if (Tag == Account_Alert_Non_User)
    {
        [self AlertWithType:1 title:nil content:STR(@"Account_NoUser", Localize_Account) delegate:delegate tag:Tag];
    }
    else if (Tag == Account_Alert_Relogin)
    {
        [self AlertWithType:1 title:nil content:STR(@"Account_Relogin", Localize_Account) delegate:delegate tag:Tag];
    }
    else if (Tag == Account_Alert_Regist_Error)
    {
        [self AlertWithType:1 title:nil content:STR(@"Account_RegistError", Localize_Account) delegate:delegate tag:Tag];
    }
    else if (Tag == Account_Alert_profile_fail)
    {
        [self AlertWithType:1 title:nil content:STR(@"Account_GetDataError", Localize_Account) delegate:delegate tag:Tag];
    }
    else if (Tag == Account_Alert_SendEmail_Fail)
    {
        [self AlertWithType:1 title:nil content:STR(@"Account_SendEmailFail", Localize_Account) delegate:delegate tag:Tag];
    }
    else if (Tag == Account_Alert_Phone_Different)
    {
        [self AlertWithType:1 title:nil content:STR(@"Account_PhoneCheck", Localize_Account) delegate:delegate tag:Tag];
    }
    else if (Tag == Account_Alert_Bind_Error)
    {
        [self AlertWithType:1 title:nil content:STR(@"Account_BindError", Localize_Account) delegate:delegate tag:Tag];
    }
    
    /*一类提示框*/
    
    /*二类提示框*/
    else if (Tag == Account_Alert_SMS_Limit)
    {
        [self AlertWithType:2 title:nil content:STR(@"Account_MessageLimit", Localize_Account) delegate:delegate tag:Tag];
    }
    else if (Tag == Account_Alert_Email_Success)
    {
        [self AlertWithType:2 title:nil content:STR(@"Account_SuccessSendEmail", Localize_Account) delegate:delegate tag:Tag];
    }
    else if (Tag == Account_Alert_Check_Success)
    {
        [self AlertWithType:2 title:nil content:STR(@"Account_SuccessSendVerification", Localize_Account) delegate:delegate tag:Tag];
    }
    else if (Tag == Account_Alert_Regist_Success)
    {
        [self AlertWithType:2 title:nil content:STR(@"Account_SuccessRegister", Localize_Account) delegate:delegate tag:Tag];
    }
    else if (Tag == Account_Alert_Password_Success)
    {
        [self AlertWithType:2 title:nil content:STR(@"Account_SuccessSetPass", Localize_Account) delegate:delegate tag:Tag];
    }
    else if (Tag == Account_Alert_Sex_Success)
    {
        [self AlertWithType:2 title:nil content:STR(@"Account_SuccessModifyGender", Localize_Account) delegate:delegate tag:Tag];
    }
    else if (Tag == Account_Alert_Nickname_Success)
    {
        [self AlertWithType:2 title:nil content:STR(@"Account_SuccessModifyNick", Localize_Account) delegate:delegate tag:Tag];
    }
    else if (Tag == Account_Alert_Age_Success)
    {
        [self AlertWithType:2 title:nil content:STR(@"Account_SuccessModifyAge", Localize_Account) delegate:delegate tag:Tag];
    }
    else if (Tag == Account_Alert_Region_Success)
    {
        [self AlertWithType:2 title:nil content:STR(@"Account_SuccessModifyRegion", Localize_Account) delegate:delegate tag:Tag];
    }
    else if (Tag == Account_Alert_Signature_Success)
    {
        [self AlertWithType:2 title:nil content:STR(@"Account_SuccessModifySign", Localize_Account) delegate:delegate tag:Tag];
    }
    else if (Tag == Account_Alert_Head_Success)
    {
        [self AlertWithType:2 title:nil content:STR(@"Account_SuccessModifyHead", Localize_Account) delegate:delegate tag:Tag];
    }
    else if (Tag == Account_Alert_Bind_Success)
    {
        [self AlertWithType:2 title:nil content:STR(@"Account_SuccessBindPhone", Localize_Account) delegate:delegate tag:Tag];
    }
    else if (Tag == Account_Alert_First_Success)
    {
        [self AlertWithType:2 title:nil content:STR(@"Account_SuccessModifyFirstName", Localize_Account) delegate:delegate tag:Tag];
    }
    else if (Tag == Account_Alert_Unbind_Success)
    {
        [self AlertWithType:2 title:nil content:STR(@"Account_SuccessRemove", Localize_Account) delegate:delegate tag:Tag];
    }
    else if (Tag == Account_Alert_ThirdToGD_Success)
    {
        [self AlertWithType:2 title:nil content:STR(@"Account_SuccessBind", Localize_Account) delegate:delegate tag:Tag];
    }
    /*二类提示框*/
    
    
    /*三类提示框*/
    
    /*三类提示框*/
}

- (void)AlertWithType:(int)type title:(NSString *)title content:(NSString *)content delegate:(id)delegate tag:(int)tag
{
    NSString *other = STR(@"Universal_ok", Localize_Universal);
    NSString *cancel = STR(@"Universal_cancel", Localize_Universal);
    
    GDAlertView *alert;
    if (type == 1)
    {
        
        __block id weakDelegate = delegate;
        
        Class origin = object_getClass(weakDelegate);
        alert = [[GDAlertView alloc] initWithTitle:title andMessage:content];
        
        [alert addButtonWithTitle:other type:GDAlertViewButtonTypeDefault handler:^(GDAlertView *alertView)
         {
             if (origin == object_getClass(weakDelegate))
             {
                 if (weakDelegate && [weakDelegate respondsToSelector:@selector(alertView:clickedButtonAtIndex:)])
                 {
                     [weakDelegate alertView:(UIAlertView *)alertView clickedButtonAtIndex:0];
                 }
             }
         }];
        
    }
    else if (type == 2)
    {
        alert = [[GDAlertView alloc] initWithTitle:title andMessage:content];
        
        [self performSelector:@selector(DisppearAlert:) withObject:alert afterDelay:2.0f];
    }
    else
    {
        __block id weakDelegate = delegate;
        
        Class origin = object_getClass(weakDelegate);
        alert = [[GDAlertView alloc] initWithTitle:title andMessage:content];
        [alert addButtonWithTitle:cancel type:GDAlertViewButtonTypeCancel handler:nil];
        [alert addButtonWithTitle:other type:GDAlertViewButtonTypeDefault handler:^(GDAlertView *alertView)
         {
             if (origin == object_getClass(weakDelegate))
             {
                 if (weakDelegate && [weakDelegate respondsToSelector:@selector(alertView:clickedButtonAtIndex:)])
                 {
                     [weakDelegate alertView:(UIAlertView *)alertView clickedButtonAtIndex:1];
                 }
             }
        }];
        
        
        
    }
    alert.tag = tag;
    [alert show];
    [alert release];
}

- (void)DisppearAlert:(GDAlertView *)view
{
    [view dismissAnimated:YES];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case Account_Alert_Net_Error:
            bShowNetError = NO;
            break;
            
        default:
            break;
    }
}

@end

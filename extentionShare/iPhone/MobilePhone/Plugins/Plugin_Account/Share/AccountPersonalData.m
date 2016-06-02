//
//  AccountPersonalData.m
//  AutoNavi
//
//  Created by gaozhimin on 13-5-15.
//
//

#import "AccountPersonalData.h"
#import "ANDataSource.h"
#import "GDBL_Account.h"
#import "ANParamValue.h"
#import "Plugin_Account_Utility.h"
#import "NSString+Category.h"
#import "MWAccountOperator.h"
#import "MWAccountRequest.h"
#import "Account.h"

static AccountPersonalData *g_AccountPersonalData = nil;

@interface AccountPersonalData()<NetReqToViewCtrDelegate>
{
    GDBL_SinaWeibo      * _sinaWeibo;
    GDBL_TCWeibo        * _tcWeibo;
    AccountPersonalData *m_personalData;
    MWAccountRequest *m_accountNetReq;
}

@end

@implementation AccountPersonalData

@synthesize m_accountEmail,m_accountNickNmae,m_accountPhoneNumber,m_accountTXWBName,m_accountXLWBName,m_icallFirstName,m_icallPhoneNumber,m_icallRemainDay,m_icallSex,m_icallOrder,m_profileAge,m_profileCity,m_profileCountry,m_profileHead,m_profileNickName,m_profileProvince,m_profileSignature,m_profileSex,m_profileCode,m_profileLocation,m_profileDay,m_profileMonth,m_profileYear,m_accountTXWBuuid,m_accountXLWBuuid,m_modifyType,m_profileHeadUrl;

@synthesize p_profileAge,p_profileCity,p_profileCode,p_profileCountry,p_profileDay,p_profileLocation,p_profileMonth,p_profileNickName,p_profileProvince,p_profileSex,p_profileSignature,p_profileYear,p_profileHead,p_icallFirstName;

@synthesize bDefaultHead,bTip,bUploadTX,bUploadXL,bThirdToGD;
@synthesize isGetUserInfo;

@synthesize m_TX_Info,m_XL_Info;

+ (AccountPersonalData *)SharedInstance
{
    if (g_AccountPersonalData == nil)
    {
        g_AccountPersonalData = [[AccountPersonalData alloc] init];
    }
    return g_AccountPersonalData;
}

- (id)init
{
    if (self = [super init])
    {
        
        _sinaWeibo=[GDBL_SinaWeibo shareSinaWeibo];//新浪微博初始化
        _sinaWeibo.delegate = self;
        
        m_personalData = self;
        
        self.bUploadXL = YES;
        self.bUploadTX = YES;
        self.bDefaultHead = YES;
        [self AccountClearAll];
        [self LoadFromFile];
        
    }
    return self;
}

- (void)LoadFromFile
{
    
    NSMutableArray *array=[[[NSMutableArray alloc] initWithContentsOfFile:account_path] autorelease];
    if ([array count] > 0)
    {

        int loginTyoe = [[array objectAtIndex:0] intValue];
        if (loginTyoe == 1)
        {
            self.m_accountEmail = [array objectAtIndex:1];
        }
        else if (loginTyoe == 2 || loginTyoe == 5 || loginTyoe == 6)
        {
            self.m_accountPhoneNumber = [array objectAtIndex:1];
        }
        
        if (loginTyoe != 0 && [array count] > 3)
        {
            NSData *data = [array objectAtIndex:4];
            if (data)
            {
                self.m_profileHead = [UIImage imageWithData:data];
                bDefaultHead = NO;
            }
            
            self.m_profileNickName = [array objectAtIndex:3];
            self.m_accountNickNmae = [array objectAtIndex:3];
        }
    }
}

- (void)AccountClearProfile
{
    self.m_profileHead = IMAGE(@"non_head.png", IMAGEPATH_TYPE_1) ;
    self.m_profileCountry = @"";
    self.m_profileCity = @"";
    self.m_profileProvince = @"";
    self.m_profileNickName = @"高德用户";
    self.m_profileSignature = @"";
    self.m_profileSex = 0;
    self.m_profileAge = 0;
    self.m_profileHeadUrl = @"";
    self.m_profileYear = 0;
    self.m_profileMonth = 0;
    self.m_profileDay = 0;
    
    //智驾的姓氏和性别 与资料里面的一样
    self.m_icallFirstName = @"";
    self.m_icallSex = 0;
}

- (void)AccountClearAccount
{
    self.m_accountXLWBName = @"";
    self.m_accountTXWBName = @"";
    self.m_accountEmail = @"";
    self.m_accountNickNmae = @"高德用户";
    self.m_accountPhoneNumber = @"";
}

- (void)AccountClearIcall
{
    self.m_icallPhoneNumber = @"";
    self.m_icallOrder = @"";
    self.m_icallRemainDay = @"未开通";
}

- (void)AccountClearAll
{
    m_personalData.bUploadXL = YES;
    m_personalData.bUploadTX = YES;
    isGetUserInfo = 0;
    [self AccountClearIcall];
    [self AccountClearProfile];
    [self AccountClearAccount];
}

- (NSString *)m_accountNickNmae
{
    return m_profileNickName;
}

//图片缩放到指定大小尺寸
- (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size changeRect:(CGRect)changRect
{
	// 创建一个bitmap的context
	// 并把它设置成为当前正在使用的context
	UIGraphicsBeginImageContext(size);
	// 绘制改变大小的图片
	[img drawInRect:changRect];
	// 从当前context中创建一个改变大小后的图片
	UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
	// 使当前的context出堆栈
	UIGraphicsEndImageContext();
	// 返回新的改变大小后的图片
	return scaledImage;
}

- (NSString *)m_icallRemainDay
{

    return m_icallRemainDay;
}

- (UIImage *)m_profileHead
{
    if (m_profileHead == nil)
    {
        self.m_profileHead = IMAGE(@"non_head.png", IMAGEPATH_TYPE_1);
    }
    
    return [self scaleToSize:m_profileHead size:CGSizeMake(ACCOUNT_HEAD_SIZE, ACCOUNT_HEAD_SIZE) changeRect:CGRectMake(0, 0, ACCOUNT_HEAD_SIZE, ACCOUNT_HEAD_SIZE)];
}

- (int)m_profileAge
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY"];
    NSString *DateYear = [formatter stringFromDate: [NSDate date]];
    [formatter release];
    
    if (m_profileYear == 0)
    {
        m_profileYear = [DateYear intValue];
    }
    
    return [DateYear intValue] - self.m_profileYear;
}

- (NSString *)m_profileCity
{
    if (m_profileCity == nil)
    {
        return @"";
    }
    return m_profileCity;
    
}

- (NSString *)m_profileSignature
{
    if (m_profileSignature == nil)
    {
        return @"";
    }
    return m_profileSignature;
}

- (NSString *)m_profileProvince
{
    if (m_profileCity == nil)
    {
        return @"";
    }
    return m_profileProvince;
}

- (void)setM_profileCode:(NSString *)profileCode
{
    MWAreaInfo *info = [MWAdminCode GetCurAdareaWith:[profileCode intValue]];
    self.m_profileProvince = info.szProvName;
    self.m_profileCity = info.szCityName;
}

- (NSString *)m_accountTXWBName
{
    if ([m_accountTXWBName length] == 0)
    {
        return STR(@"Account_NonAccept", Localize_Account);
    }
    return m_accountTXWBName;
}

- (NSString *)m_accountXLWBName
{
    if ([m_accountXLWBName length] == 0)
    {
        return STR(@"Account_NonAccept", Localize_Account);
    }
    return m_accountXLWBName;
}

- (int)m_icallSex
{
    return m_profileSex;
}


- (void)Account_GetUserinfo
{
    NSArray *tmpArray;
    GDBL_GetAccountInfo(&tmpArray);
    int loginType = [[tmpArray objectAtIndex:0] intValue];//0未登录，1老用户登录，2新用户登录，3新浪微博帐号登录，4腾讯微博帐号登录，5 新浪帐号绑定高德帐号 6 腾讯帐号绑定高德帐号
    if (loginType == 0)
    {
        return;
    }
    else if (loginType == 3)
    {
        [self Account_GetXLinfoWith:self];
    }
    else if (loginType == 4)
    {
        [self Account_GetTXinfoWith:self];
        
    }
    else if (loginType == 5)
    {
        isGetUserInfo = 1;
        NSArray *array = [[Account AccountInstance] getAccountInfo];
        [self Account_ThirdLoginWith:[array objectAtIndex:5] tpusername:[array objectAtIndex:6] type:1];
    }
    else if (loginType == 6)
    {
        isGetUserInfo = 1;
        NSArray *array = [[Account AccountInstance] getAccountInfo];
        [self Account_ThirdLoginWith:[array objectAtIndex:5] tpusername:[array objectAtIndex:6] type:2];
        
    }
    else
    {
        isGetUserInfo = 1;
//        [MWAccountOperator accountGetProfileWith:REQ_GET_PROFILE tpuserid:nil tptype:0 delegate:self];
    }
}

- (void)requestToViewCtrWithRequestType:(RequestType)requestType didFinishLoadingWithResult:(id)result
{
    if (requestType == REQ_THIRD_LOGIN)
    {
        if ([[result objectForKey:@"Result"] isEqualToString:@"SUCCESS"])
        {
            NSArray *tmpArray;
            GDBL_GetAccountInfo(&tmpArray);
            int loginType = [[tmpArray objectAtIndex:0] intValue];
            if (loginType == 3 || loginType == 5)
            {
                [MWAccountOperator accountGetProfileWith:REQ_GET_PROFILE tpuserid:m_personalData.m_accountXLWBuuid tptype:@"1" delegate:self];
                return;
            }
            else if (loginType == 4 || loginType == 6)
            {
                [MWAccountOperator accountGetProfileWith:REQ_GET_PROFILE tpuserid:m_personalData.m_accountTXWBuuid tptype:@"2" delegate:self];
                return;
            }
        }

    }
    else if (requestType == REQ_GET_PROFILE)
    {
        if ([[result objectForKey:@"Result"] isEqualToString:@"SUCCESS"])
        {
            AccountPersonalData *personalData = [AccountPersonalData SharedInstance];
            
            personalData.isGetUserInfo = 2;
            NSMutableArray *accountInfoArray = [NSMutableArray arrayWithArray:[[Account AccountInstance] getAccountInfo]];
            
            if ([[result objectForKey:@"Login_Type"] isEqualToString:TP_USER]) //第三方登陆获取资料
            {
                if ([[result objectForKey:@"username"] length] > 0) //说明绑定高德帐号
                {
                    [accountInfoArray replaceObjectAtIndex:1 withObject:[result objectForKey:@"username"]];    //替换帐号名称
                    if ([[result objectForKey:@"tptype"] intValue] == 1)
                    {
                        [accountInfoArray replaceObjectAtIndex:5 withObject:personalData.m_accountXLWBuuid?personalData.m_accountXLWBuuid:@""];
                        [accountInfoArray replaceObjectAtIndex:0 withObject:[NSNumber numberWithInt:5]]; //第三方登录成高德登录
                    }
                    else if ([[result objectForKey:@"tptype"] intValue] == 2)
                    {
                        [accountInfoArray replaceObjectAtIndex:5 withObject:personalData.m_accountTXWBuuid?personalData.m_accountTXWBuuid:@""];
                        [accountInfoArray replaceObjectAtIndex:0 withObject:[NSNumber numberWithInt:6]]; //第三方登录成高德登录
                    }
                    else
                    {
                        [accountInfoArray replaceObjectAtIndex:0 withObject:[NSNumber numberWithInt:5]]; //第三方登录成高德登录
                    }
                }
                else
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:HEAD_GET_PROFILE object:[NSNumber numberWithBool:YES]];
                    [[NSNotificationCenter defaultCenter] postNotificationName:THIRD_LODIN_FINISH  object:[NSNumber numberWithInt:1] userInfo:nil];
                    return;
                }
                
            }
            personalData.m_accountEmail = [result objectForKey:@"email"];
            personalData.m_accountNickNmae = [result objectForKey:@"nickname"];
            personalData.m_accountPhoneNumber = [result objectForKey:@"phone"];
            personalData.m_profileAge = [[result objectForKey:@"age"] intValue];
            personalData.m_profileProvince = [result objectForKey:@"province"];
            personalData.m_profileCity = [result objectForKey:@"city"];
            personalData.m_profileSex = [[result objectForKey:@"sex"] intValue];
            personalData.m_profileNickName = [result objectForKey:@"nickname"];
            personalData.m_icallFirstName = [result objectForKey:@"firstname"];
            personalData.m_icallSex = [[result objectForKey:@"sex"] intValue];
            personalData.m_profileSignature = [result objectForKey:@"signature"];
            
            [accountInfoArray replaceObjectAtIndex:3 withObject:[result objectForKey:@"nickname"]?[result objectForKey:@"nickname"]:@""];
            [accountInfoArray replaceObjectAtIndex:6 withObject:[result objectForKey:@"tpusername"]?[result objectForKey:@"tpusername"]:@""];
            if ([[result objectForKey:@"birthday"] length] > 0)
            {
                NSArray *array = [[result objectForKey:@"birthday"] componentsSeparatedByString:@"-"];
                if ([array count] == 3)
                {
                    personalData.m_profileYear = [[array objectAtIndex:0] intValue];
                    personalData.m_profileMonth = [[array objectAtIndex:1] intValue];
                    personalData.m_profileDay = [[array objectAtIndex:2] intValue];
                }
            }
            [[Account AccountInstance] setAccountInfo:accountInfoArray];
            
            if ([[result objectForKey:@"headimage"] length] > 0)
            {
                personalData.m_profileHeadUrl = [result objectForKey:@"headimage"];
                [self GetImageWithURL:personalData.m_profileHeadUrl];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:HEAD_GET_PROFILE object:[NSNumber numberWithBool:YES]];
        }
        else
        {
            if ([[result objectForKey:@"Authenticate"] isEqualToString:@"False"])
            {
                [[Account AccountInstance] setLoginStatus:0];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:HEAD_GET_PROFILE object:[NSNumber numberWithBool:NO]];
        }
        //add by xyy for第三方登陆绑定手机号等跳转
        [[NSNotificationCenter defaultCenter] postNotificationName:THIRD_LODIN_FINISH  object:[NSNumber numberWithInt:1] userInfo:nil];
    }
    else if(requestType == REQ_GET_HEAD)
    {
        AccountPersonalData *personalData = [AccountPersonalData SharedInstance];
        UIImage *image = [UIImage imageWithData:result];
        NSLog(@"%f,%f",image.size.width,image.size.height);
        if (image)
        {
            personalData.m_profileHead = image;
            personalData.bDefaultHead = NO;
            
            NSData *data = UIImagePNGRepresentation(personalData.m_profileHead);
            NSMutableArray *accountInfoArray = [NSMutableArray arrayWithArray:[[Account AccountInstance] getAccountInfo]];
            [accountInfoArray replaceObjectAtIndex:4 withObject:data];
            [[Account AccountInstance] setAccountInfo:accountInfoArray];
            [self UpdateTableView];
        }
    }
    else if (requestType == REQ_UPDATE_PROFILE)
    {
        AccountPersonalData *personalData = [AccountPersonalData SharedInstance];
        if ([[result objectForKey:@"Result"] isEqualToString:@"SUCCESS"])
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
    }
}

- (void)requestToViewCtrWithRequestType:(RequestType)requestType didFailWithError:(NSError *)error
{
    if (requestType == REQ_GET_PROFILE || requestType == REQ_THIRD_LOGIN)
    {
        isGetUserInfo = 0;
        [[NSNotificationCenter defaultCenter] postNotificationName:HEAD_GET_PROFILE object:[NSNumber numberWithBool:NO]];
        //登陆或者获取信息失效，登陆都算失败
        [[Account AccountInstance] setLoginStatus:0];
        [[NSNotificationCenter defaultCenter] postNotificationName:THIRD_LODIN_FINISH  object:[NSNumber numberWithInt:0] userInfo:nil];
        
        
    }
}

- (void)GetImageWithURL:(NSString *)str_url
{
    AccountPersonalData *personalData = [AccountPersonalData SharedInstance];
    NSArray *tmpArray;
    GDBL_GetAccountInfo(&tmpArray);
    int loginType = [[tmpArray objectAtIndex:0] intValue];
    
    
    if (loginType == 5)
    {
        [MWAccountOperator accountGetHeadWith:REQ_GET_HEAD imagepath:str_url tpuserid:personalData.m_accountXLWBuuid tptype:@"1" delegate:self];
    }
    else if (loginType == 6)
    {
        [MWAccountOperator accountGetHeadWith:REQ_GET_HEAD imagepath:str_url tpuserid:personalData.m_accountTXWBuuid tptype:@"2" delegate:self];
    }
    else
    {
//        [MWAccountOperator accountGetHeadWith:REQ_GET_HEAD imagepath: personalData.m_profileHeadUrl tpuserid:nil tptype:nil delegate:self];
        CRELEASE(m_accountNetReq);
        m_accountNetReq = [[MWAccountRequest alloc]init];
        [m_accountNetReq accountGetImageRequest:REQ_GET_HEAD imageUrl:personalData.m_profileHeadUrl];
        m_accountNetReq.delegate = self;
    }
    
}

- (void)UpdateTableView
{
    [[NSNotificationCenter defaultCenter] postNotificationName:HEAD_GET_PROFILE object:[NSNumber numberWithInt:YES]];
}

#pragma mark -获取腾讯，新浪用户信息

- (void)Account_GetTXinfoWith:(id<NetReqToViewCtrDelegate>)delegate
{
    isGetUserInfo = 1;
    
    
    _tcWeibo=[GDBL_TCWeibo shareTCWeibo];//腾讯微博初始化
    _tcWeibo.delegate = self;
    
    if ([_tcWeibo isAuthValid])
    {
        [_tcWeibo getUserInfo];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:HEAD_GET_PROFILE object:[NSNumber numberWithBool:NO]];
        NSArray *tmpArray;
        GDBL_GetAccountInfo(&tmpArray);
        int loginType = [[tmpArray objectAtIndex:0] intValue];
        if (loginType == 4)
        {
            [[Account AccountInstance] setLoginStatus:0];
        }
    }
}

- (void)Account_GetXLinfoWith:(id<NetReqToViewCtrDelegate>)delegate
{
    isGetUserInfo = 1;
    
    _sinaWeibo=[GDBL_SinaWeibo shareSinaWeibo];//新浪微博初始化
    _sinaWeibo.delegate = self;
    if (_sinaWeibo.sinaweibo.isAuthValid)
    {
        [_sinaWeibo getUserInfo];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:HEAD_GET_PROFILE object:[NSNumber numberWithBool:NO]];
        NSArray *tmpArray;
        GDBL_GetAccountInfo(&tmpArray);
        int loginType = [[tmpArray objectAtIndex:0] intValue];
        if (loginType == 3)
        {
            [[Account AccountInstance] setLoginStatus:0];
        }
    }
}

#pragma mark -上传腾讯，新浪用户信息
- (void)UploadTXInfo:(NSDictionary *)userInfo  //上传腾讯用户信息
{
    if (self.bThirdToGD == NO)  //是否为第三方帐号转向高德帐号
    {
        if (self.bUploadTX == NO || self.bUploadXL == NO)  //是否授权微博帐号
        {
            return;
        }
    }
    BOOL bUpdateInfo = NO;
    self.bUploadTX = NO;
    NSDictionary *dic_data = [userInfo objectForKey:@"data"];
    if (m_personalData.m_profileSex != 0)
    {
        m_personalData.p_profileSex = m_personalData.m_profileSex;
    }
    else
    {
        int sex = [[dic_data objectForKey:@"sex"] intValue];
        if (sex == 0)
        {
            sex = 2;
        }
        m_personalData.p_profileSex = sex;
        bUpdateInfo = YES;
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY"];
    NSString *DateYear = [formatter stringFromDate: [NSDate date]];
    [formatter release];
    
    if (m_personalData.m_profileYear != 0 && m_personalData.m_profileYear < [DateYear intValue])
    {
        m_personalData.p_profileYear = m_personalData.m_profileYear;
        m_personalData.p_profileMonth = m_personalData.m_profileMonth;
        m_personalData.p_profileDay = m_personalData.m_profileDay;
    }
    else
    {
        m_personalData.p_profileYear = [[dic_data objectForKey:@"birth_year"] intValue];
        m_personalData.p_profileMonth = [[dic_data objectForKey:@"birth_month"] intValue];
        m_personalData.p_profileDay = [[dic_data objectForKey:@"birth_day"] intValue];
        bUpdateInfo = YES;
    }
    
    if ([m_personalData.m_profileProvince length] > 0)
    {
        m_personalData.p_profileProvince = m_personalData.m_profileProvince;
        m_personalData.p_profileCity = m_personalData.m_profileCity;
    }
    else
    {
        int code = [[NSString stringWithFormat:@"%02d%02d00",
                     [[dic_data objectForKey:@"province_code"] intValue],
                     [[dic_data objectForKey:@"city_code"] intValue]
                     ] intValue];

        MWAreaInfo *info = [MWAdminCode GetCurAdareaWith:code];
        m_personalData.p_profileProvince = info.szProvName;
        m_personalData.p_profileCity = info.szCityName;
        bUpdateInfo = YES;
    }
    
    m_personalData.p_profileSignature = m_personalData.m_profileSignature;
    
    if ([m_personalData.m_profileNickName isEqualToString:@"高德用户"] || [m_personalData.m_profileNickName length] == 0)
    {
          m_personalData.p_profileNickName = [dic_data objectForKey:@"nick"];
        bUpdateInfo = YES;
    }
    else
    {
        m_personalData.p_profileNickName = m_personalData.m_profileNickName;
    }
    
    if (!([m_personalData.m_profileHeadUrl length] > 0))
    {
        [NSThread detachNewThreadSelector:@selector(GetTXImageWithURL:) toTarget:self withObject:[NSString stringWithFormat:@"%@/50",[dic_data objectForKey:@"head"]]];
    }
    
    if (bUpdateInfo)
    {
        NSString *birthDay = [NSString stringWithFormat:@"%d-%d-%d",m_personalData.p_profileYear,m_personalData.p_profileMonth,m_personalData.p_profileDay];
        m_personalData.m_modifyType = ACCOUNT_MODIFY_TXINFO;
        [MWAccountOperator accountUpadataProfileWith:REQ_UPDATE_PROFILE nickName:m_personalData.p_profileNickName province:m_personalData.p_profileProvince city:m_personalData.p_profileCity birthday:birthDay signature:nil sex:[NSString  stringWithFormat:@"%d",m_personalData.p_profileSex] firstname:nil tpuserid:m_personalData.m_accountTXWBuuid tptype:@"2" delegate:self];
    }
}

- (void)GetTXImageWithURL:(NSString *)str_url
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSURL *url = [NSURL URLWithString:str_url];
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    NSData *received = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    UIImage *image = [UIImage imageWithData:received];
    if (image)
    {
        [self performSelectorOnMainThread:@selector(UpLoadTXImage:) withObject:image waitUntilDone:YES];
    }
    
    
    [request release];
    
    [pool release];
}

- (void)UpLoadTXImage:(UIImage *)image
{
    m_personalData.p_profileHead = [[AccountPersonalData SharedInstance] scaleToSize:image size:CGSizeMake(50, 50) changeRect:CGRectMake(0, 0, 50, 50)];
    [MWAccountOperator accountUploadHeadWith:REQ_UPLOAD_HEAD image:m_personalData.p_profileHead rect:CGRectZero tpuserid:m_accountTXWBuuid tptype:@"2" delegate:nil];   //无需任何提示，故delegate为空
}

- (void)UploadXLInfo:(NSDictionary *)newuserInfo
{
    if (self.bThirdToGD == NO)  //是否为第三方帐号转向高德帐号
    {
        if (self.bUploadXL == NO || self.bUploadTX == NO)  //是否授权微博帐号
        {
            return;
        }
    }
    
    self.bUploadXL = NO;
    BOOL bUpdateInfo = NO;
    NSDictionary *dic_data = newuserInfo;
    if (m_personalData.m_profileSex != 0)
    {
        m_personalData.p_profileSex = m_personalData.m_profileSex;
    }
    else
    {
        int sex = [[dic_data objectForKey:@"sex"] intValue];
        if ([[dic_data objectForKey:@"gender"] isEqualToString:@"m"])
        {
            sex = 1;
        }
        else
        {
            sex = 2;
        }
        m_personalData.p_profileSex = sex;
        bUpdateInfo = YES;
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY"];
    NSString *DateYear = [formatter stringFromDate: [NSDate date]];
    [formatter release];
    
    if (m_personalData.m_profileYear != 0 && m_personalData.m_profileYear < [DateYear intValue])
    {
        m_personalData.p_profileYear = m_personalData.m_profileYear;
        m_personalData.p_profileMonth = m_personalData.m_profileMonth;
        m_personalData.p_profileDay = m_personalData.m_profileDay;
    }
    else
    {
        m_personalData.p_profileYear = [[dic_data objectForKey:@"birth_year"] intValue];
        m_personalData.p_profileMonth = [[dic_data objectForKey:@"birth_month"] intValue];
        m_personalData.p_profileDay = [[dic_data objectForKey:@"birth_day"] intValue];
        bUpdateInfo = YES;
    }
    
    if ([m_personalData.m_profileProvince length] > 0)
    {
        m_personalData.p_profileProvince = m_personalData.m_profileProvince;
        m_personalData.p_profileCity = m_personalData.m_profileCity;
    }
    else
    {
        int code = [[NSString stringWithFormat:@"%02d%02d00",
                                        [[dic_data objectForKey:@"province"] intValue],
                                        [[dic_data objectForKey:@"city"] intValue]
                                        ] intValue];
        MWAreaInfo *info = [MWAdminCode GetCurAdareaWith:code];
        m_personalData.p_profileProvince = info.szProvName;
        m_personalData.p_profileCity = info.szCityName;
        bUpdateInfo = YES;
    }
    
    if ([m_personalData.m_profileSignature length] > 0)
    {
        m_personalData.p_profileSignature = m_personalData.m_profileSignature;
    }
    else
    {
        m_personalData.p_profileSignature = [dic_data objectForKey:@"description"];
        if ([m_personalData.p_profileSignature length] > 140)
        {
            m_personalData.p_profileSignature = [m_personalData.m_profileSignature substringToIndex:139];
        }
        if([m_personalData.p_profileSignature length] > 0)
        {
            bUpdateInfo = YES;
        }
    }
    
    if ([m_personalData.m_profileNickName isEqualToString:@"高德用户"] || [m_personalData.m_profileNickName length] == 0)
    {
        m_personalData.p_profileNickName = [dic_data objectForKey:@"screen_name"];
        bUpdateInfo = YES;
    }
    else
    {
        m_personalData.p_profileNickName = m_personalData.m_profileNickName;
    }
    
    if (!([m_personalData.m_profileHeadUrl length] > 0))
    {
        [NSThread detachNewThreadSelector:@selector(GetXLImageWithURL:) toTarget:self withObject:[NSString stringWithFormat:@"%@/50",[dic_data objectForKey:@"profile_image_url"]]];
    }
    
    if (bUpdateInfo == YES)
    {
        m_personalData.m_modifyType = ACCOUNT_MODIFY_XLINFO;
        [MWAccountOperator accountUpadataProfileWith:REQ_UPDATE_PROFILE nickName:m_personalData.p_profileNickName province:m_personalData.p_profileProvince city:m_personalData.p_profileCity birthday:nil signature:m_personalData.p_profileSignature sex:[NSString  stringWithFormat:@"%d",m_personalData.p_profileSex] firstname:nil tpuserid:m_personalData.m_accountXLWBuuid tptype:@"1" delegate:self];
    }
}

- (void)GetXLImageWithURL:(NSString *)str_url
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSURL *url = [NSURL URLWithString:str_url];
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    NSData *received = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
    UIImage *image = [UIImage imageWithData:received];
    if (image)
    {
        [self performSelectorOnMainThread:@selector(UpLoadXLImage:) withObject:image waitUntilDone:YES];
    }
    
    [request release];
    
    [pool release];
}

- (void)UpLoadXLImage:(UIImage *)image
{
    m_personalData.p_profileHead = [[AccountPersonalData SharedInstance] scaleToSize:image size:CGSizeMake(50, 50) changeRect:CGRectMake(0, 0, 50, 50)];
    [MWAccountOperator accountUploadHeadWith:REQ_UPLOAD_HEAD image:m_personalData.p_profileHead rect:CGRectZero tpuserid:m_accountXLWBuuid tptype:@"1" delegate:nil];   //无需任何提示，故delegate为空
}


#pragma mark -  腾讯，新浪 回调
#pragma mark -  新浪 获取用户信息回调－成功
-(void)onGetUserInfo:(NSDictionary *)newuserInfo
{
    NSDictionary *dic_data = newuserInfo;
    m_personalData.m_profileNickName = [dic_data objectForKey:@"screen_name"];
    m_personalData.m_profileLocation = [dic_data objectForKey:@"location"];
    
    m_personalData.m_accountXLWBName = m_personalData.m_profileNickName;
    m_personalData.m_profileCode = [NSString stringWithFormat:@"%02d%02d00",
                                    [[dic_data objectForKey:@"province"] intValue],
                                    [[dic_data objectForKey:@"city"] intValue]
                                    ];
    m_personalData.m_profileSignature = [dic_data objectForKey:@"description"];
    if ([[dic_data objectForKey:@"gender"] isEqualToString:@"m"])
    {
        m_personalData.m_profileSex = 1;
    }
    else
    {
        m_personalData.m_profileSex = 2;
    }
    
    m_personalData.m_accountXLWBuuid = [NSString stringWithFormat:@"%d",[[dic_data objectForKey:@"id"] intValue]];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/50",[dic_data objectForKey:@"profile_image_url"]]];
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    NSData *received = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    [request release];
    
    m_personalData.m_profileHead = [[[UIImage alloc]initWithData:received] autorelease];
//    [self.tableView reloadData];
    
    m_personalData.m_XL_Info = newuserInfo;
    
    NSData *data = UIImagePNGRepresentation(m_personalData.m_profileHead);
    NSMutableArray *accountInfoArray = [NSMutableArray arrayWithArray:[[Account AccountInstance] getAccountInfo]];
    [accountInfoArray replaceObjectAtIndex:3 withObject:m_personalData.m_profileNickName?m_personalData.m_profileNickName:@""];
    [accountInfoArray replaceObjectAtIndex:4 withObject:data?data:[NSData data]];
    [accountInfoArray replaceObjectAtIndex:5 withObject:m_personalData.m_accountXLWBuuid?m_personalData.m_accountXLWBuuid:@""];
    [[Account AccountInstance] setAccountInfo:accountInfoArray];
    
//    NSString *sign = [[NSString stringWithFormat:@"%@%@%@",deviceID,m_personalData.m_accountXLWBuuid,KEY_MD5] stringFromMD5];
//    GDBL_ThirdLogin(m_personalData.m_accountXLWBuuid, m_personalData.m_accountNickNmae, deviceID, sign, 1,deviceTokenEx);
    
    [MWAccountOperator accountThirdLoginWith:REQ_THIRD_LOGIN tpuserid:m_personalData.m_accountXLWBuuid tpusername:m_personalData.m_accountNickNmae tptype:@"1" delegate:self];
}



//获取用户信息回调－失败
-(void)onGetUserInfoFailed:(NSError *)error
{
    m_personalData.isGetUserInfo = 0;
    [[NSNotificationCenter defaultCenter] postNotificationName:HEAD_GET_PROFILE object:[NSNumber numberWithBool:NO]];
}

#pragma mark - login callback

- (void)TCWeiboAreadyLogIn:(WeiboApi *)TCweibo
{
    
}


- (void)TCGetUserInfo:(NSDictionary *)userInfo
{
    if ([[userInfo objectForKey:@"msg"] isEqual:@"ok"])
    {
        NSDictionary *dic_data = [userInfo objectForKey:@"data"];
        m_personalData.m_profileNickName = [dic_data objectForKey:@"nick"];
        m_personalData.m_profileLocation = [dic_data objectForKey:@"location"];
        m_personalData.m_profileCode =[NSString stringWithFormat:@"%02d%02d00",
                                       [[dic_data objectForKey:@"province_code"] intValue],
                                       [[dic_data objectForKey:@"city_code"] intValue]
                                       ];
        m_personalData.m_profileMonth = [[dic_data objectForKey:@"birth_month"] intValue];
        m_personalData.m_profileYear = [[dic_data objectForKey:@"birth_year"] intValue];
        m_personalData.m_profileDay = [[dic_data objectForKey:@"birth_day"] intValue];
        m_personalData.m_profileSex = [[dic_data objectForKey:@"sex"] intValue];
        
//        NSArray *array = [dic_data objectForKey:@"tweetinfo"];
//        if ([array count] > 0)
//        {
//            NSDictionary *data_tweetinfo = [array objectAtIndex:0];
//            m_personalData.m_profileSignature = [data_tweetinfo objectForKey:@"text"];
//            if ([m_personalData.m_profileSignature length] > 140)
//            {
//                m_personalData.m_profileSignature = [m_personalData.m_profileSignature substringToIndex:139];
//            }
//        }
        
        
        m_personalData.m_accountTXWBuuid = [NSString stringWithFormat:@"%@",[dic_data objectForKey:@"openid"]];
        
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/50",[dic_data objectForKey:@"head"]]];
        NSURLRequest *request = [[NSURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
        NSData *received = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        [request release];
        
        m_personalData.m_profileHead = [[[UIImage alloc]initWithData:received] autorelease];
        m_personalData.m_accountTXWBName = m_personalData.m_profileNickName;
        
        
        NSData *data = UIImagePNGRepresentation(m_personalData.m_profileHead);
        NSMutableArray *accountInfoArray = [NSMutableArray arrayWithArray:[[Account AccountInstance] getAccountInfo]];
        [accountInfoArray replaceObjectAtIndex:3 withObject:m_personalData.m_profileNickName?m_personalData.m_profileNickName:@""];
        [accountInfoArray replaceObjectAtIndex:4 withObject:data?data:[NSData data]];
        [accountInfoArray replaceObjectAtIndex:5 withObject:m_personalData.m_accountTXWBuuid?m_personalData.m_accountTXWBuuid:@""];
        [[Account AccountInstance] setAccountInfo:accountInfoArray];
        
//        [self.tableView reloadData];
        
        
        m_personalData.m_TX_Info = userInfo;
        
//        NSString *sign = [[NSString stringWithFormat:@"%@%@%@",deviceID,m_personalData.m_accountTXWBuuid,KEY_MD5] stringFromMD5];
//        GDBL_ThirdLogin(m_personalData.m_accountTXWBuuid, m_personalData.m_accountNickNmae, deviceID, sign, 2,deviceTokenEx);
        
         [MWAccountOperator accountThirdLoginWith:REQ_THIRD_LOGIN tpuserid:m_personalData.m_accountTXWBuuid tpusername:m_personalData.m_accountNickNmae tptype:@"2" delegate:self];
        
        return;
    }
    m_personalData.isGetUserInfo = 0;
    [[NSNotificationCenter defaultCenter] postNotificationName:HEAD_GET_PROFILE object:[NSNumber numberWithBool:NO]];
}

-(void)TCGetUserInfoFailed:(NSError *) error
{
    m_personalData.isGetUserInfo = 0;
    [[NSNotificationCenter defaultCenter] postNotificationName:HEAD_GET_PROFILE object:[NSNumber numberWithBool:NO]];
}

#pragma mark - 第三方登陆

- (void)Account_ThirdLoginWith:(NSString *)uuid tpusername:(NSString *)tpusername type:(int)type
{
    if (type == 1)
    {
        self.m_accountXLWBuuid = uuid;
    }
    else if (type == 2)
    {
        self.m_accountTXWBuuid = uuid;
    }
    isGetUserInfo = 1;
//    NSString *sign = [[NSString stringWithFormat:@"%@%@%@",deviceID,uuid,KEY_MD5] stringFromMD5];
//    GDBL_ThirdLogin(uuid, tpusername, deviceID, sign, type,deviceTokenEx);
    [MWAccountOperator accountThirdLoginWith:REQ_THIRD_LOGIN tpuserid:uuid tpusername:tpusername tptype:[NSString stringWithFormat:@"%d",type] delegate:self];
}

- (void)dealloc
{
    if (m_profileCity)
    {
        [m_profileCity release];
        m_profileCity = nil;
    }
    if (m_profileCountry)
    {
        [m_profileCountry release];
        m_profileCountry = nil;
    }
    if (m_profileProvince)
    {
        [m_profileProvince release];
        m_profileProvince = nil;
    }
    if (m_profileNickName)
    {
        [m_profileNickName release];
        m_profileNickName = nil;
    }
    if (m_profileHead)
    {
        [m_profileHead release];
        m_profileHead = nil;
    }
    if (m_profileSignature)
    {
        [m_profileSignature release];
        m_profileSignature = nil;
    }
    if (m_accountEmail)
    {
        [m_accountEmail release];
        m_accountEmail = nil;
    }
    if (m_accountNickNmae)
    {
        [m_accountNickNmae release];
        m_accountNickNmae = nil;
    }
    if (m_accountPhoneNumber)
    {
        [m_accountPhoneNumber release];
        m_accountPhoneNumber = nil;
    }
    if (m_accountTXWBName)
    {
        [m_accountTXWBName release];
        m_accountTXWBName = nil;
    }
    if (m_accountXLWBName)
    {
        [m_accountXLWBName release];
        m_accountXLWBName = nil;
    }
    if (m_icallFirstName)
    {
        [m_icallFirstName release];
        m_icallFirstName = nil;
    }
    if (m_icallOrder)
    {
        [m_icallOrder release];
        m_icallOrder = nil;
    }
    if (m_icallPhoneNumber)
    {
        [m_icallPhoneNumber release];
        m_icallPhoneNumber = nil;
    }
    if (m_icallRemainDay)
    {
        [m_icallRemainDay release];
        m_icallRemainDay = nil;
    }
    
    [super dealloc];
}

@end

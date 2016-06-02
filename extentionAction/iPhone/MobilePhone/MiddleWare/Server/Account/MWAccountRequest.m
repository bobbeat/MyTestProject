//
//  MWAccountRequest.m
//  AutoNavi
//
//  Created by yaying.xiao on 14-10-20.
//
//

#import "MWAccountRequest.h"
#import "JSON.h"
#import "DDXML.h"
#import "ThreeDes.h"
#import "XMLDictionary.h"
#import "Account.h"
#import "Plugin_Account_Utility.h"
#import "AccountPersonalData.h"

@implementation MWAccountRequest

@synthesize delegate,strcheckcode,struserid,strsid,strusername,strnickname,strphone,strimageurl;


- (id)init
{
    self = [super init];
    if (self)
    {
        NSArray *accontinfo = [[Account AccountInstance] getAccountInfo];
        self.strusername = [accontinfo objectAtIndex:1];
        self.struserid = [accontinfo objectAtIndex:7];
        self.strsid = [accontinfo objectAtIndex:8];
        self.strnickname = [accontinfo objectAtIndex:3];
    }
    return self;
}

- (void)dealloc
{
    CRELEASE(strcheckcode);
    CRELEASE(struserid);
    CRELEASE(strsid);
    CRELEASE(strusername);
    CRELEASE(strnickname);
    CRELEASE(strphone);
    CRELEASE(strimageurl);
    
    [super dealloc];
}


- (void)accountRegistRequest:(RequestType)type  username:(NSString*)username password:(NSString*)pwd
{
    NSString *uri= @"/nis/user/reg";
    NSString *baseUrl = [NSString stringWithFormat:@"%@%@",kAccountRequestURL,uri];
    NSString *imei = IDFA;
    NSString *processtime = NetProcessTime;
    NSString *signString = [[NSString stringWithFormat:@"%@%@%@@%@",KNetChannelID,uri,processtime,kNetSignKey] stringFromMD5];
    //拼接xml请求
    NSString *xmlbodydata = nil;
    DDXMLElement*  opg = [DDXMLElement elementWithName: @"opg"];
    DDXMLElement*  protversion =[DDXMLElement elementWithName: @"protversion"];
    [protversion setStringValue:@"2"];
    [opg addChild:protversion];
    
    DDXMLElement*  language =[DDXMLElement elementWithName: @"language"];
    [language setStringValue:[NSString stringWithFormat:@"%d",NetFontType]];
    [opg addChild:language];
    
    DDXMLElement*  info = [DDXMLElement elementWithName:@"info"];
    DDXMLElement*  xmlimei =[DDXMLElement elementWithName: @"imei"];
    [xmlimei setStringValue:imei];
    [info addChild:xmlimei];
    DDXMLElement*  xmlusername =[DDXMLElement elementWithName: @"username"];
    [xmlusername setStringValue:username];
    [info addChild:xmlusername];
    DDXMLElement*  xmlpwd =[DDXMLElement elementWithName: @"pwd"];
    [xmlpwd setStringValue:[ThreeDes encrypt:pwd]];
    [info addChild:xmlpwd];
    
    DDXMLElement*  svccont = [DDXMLElement elementWithName:@"svccont"];
    [svccont addChild:info];
    [opg addChild:svccont];
    xmlbodydata = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\" ?>%@",[opg XMLString]];
    
    //httpheader
    NSMutableDictionary *headerParams = [[NSMutableDictionary alloc] init];
    [headerParams setValue:processtime forKey:@"timestamp"];
    [headerParams setValue:@"1" forKey:@"en"];//0不加密；1请求数据加密；2请求和应答数据都加密
    [headerParams setValue:[ThreeDes encrypt:IDFA] forKey:@"imei"];
    [headerParams setValue:[NSString stringWithFormat:@"%d",SOFTVERSIONCODE] forKey:@"apkversion"];
    [headerParams setValue:MapVersionNoV forKey:@"mapversion"];
    [headerParams setValue:deviceModel forKey:@"model"];
    [headerParams setValue:DeviceResolutionString forKey:@"resolution"];
    [headerParams setValue:CurrentSystemVersion  forKey:@"os"];
    [headerParams setValue:UserID_Account forKey:@"userid"];
    [headerParams setValue:UserSID forKey:@"sid"];
    [headerParams setValue:KNetChannelID forKey:@"syscode"];
    [headerParams setValue:PID forKey:@"pid"];
    [headerParams setValue:signString forKey:@"sign"];
    
    NetBaseRequestCondition *condition = [NetBaseRequestCondition requestCondition];
    condition.requestType = REQ_REGIST;
    condition.httpHeaderFieldParams = headerParams;
    condition.httpMethod = @"POST";
    condition.bodyData = [[ThreeDes encrypt:xmlbodydata] dataUsingEncoding:NSUTF8StringEncoding];
    condition.urlParams = nil;
    condition.baceURL = baseUrl;
    
    [[NetExt sharedInstance] requestWithCondition:condition delegate:self];
    [headerParams release];
}



- (void)accountLoginRequest:(RequestType)type  username:(NSString*)username password:(NSString*)pwd
{
    NSString *uri= @"/nis/user/login";
    NSString *baseUrl = [NSString stringWithFormat:@"%@%@",kAccountRequestURL,uri];
    NSString *imei = IDFA;
    NSString *processtime = NetProcessTime;
    NSString *signString = [[NSString stringWithFormat:@"%@%@%@@%@",KNetChannelID,uri,processtime,kNetSignKey] stringFromMD5];
    //拼接xml请求
    NSString *xmlbodydata = nil;
    DDXMLElement*  opg = [DDXMLElement elementWithName: @"opg"];
    DDXMLElement*  protversion =[DDXMLElement elementWithName: @"protversion"];
    [protversion setStringValue:@"2"];
    [opg addChild:protversion];
    
    DDXMLElement*  language =[DDXMLElement elementWithName: @"language"];
    [language setStringValue:[NSString stringWithFormat:@"%d",NetFontType]];
    [opg addChild:language];
    
    DDXMLElement*  info = [DDXMLElement elementWithName:@"info"];
    DDXMLElement*  xmlimei =[DDXMLElement elementWithName: @"imei"];
    [xmlimei setStringValue:imei];
    [info addChild:xmlimei];
    DDXMLElement*  xmlusername =[DDXMLElement elementWithName: @"username"];
    [xmlusername setStringValue:username];
    [info addChild:xmlusername];
    DDXMLElement*  xmlpwd =[DDXMLElement elementWithName: @"pwd"];
    [xmlpwd setStringValue:[ThreeDes encrypt:pwd]];
    [info addChild:xmlpwd];
    
    DDXMLElement*  svccont = [DDXMLElement elementWithName:@"svccont"];
    [svccont addChild:info];
    [opg addChild:svccont];
    xmlbodydata = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\" ?>%@",[opg XMLString]];
    
    //httpheader
    NSMutableDictionary *headerParams = [[NSMutableDictionary alloc] init];
    [headerParams setValue:processtime forKey:@"timestamp"];
    [headerParams setValue:@"1" forKey:@"en"];//0不加密；1请求数据加密；2请求和应答数据都加密
    [headerParams setValue:[ThreeDes encrypt:IDFA] forKey:@"imei"];
    [headerParams setValue:[NSString stringWithFormat:@"%d",SOFTVERSIONCODE] forKey:@"apkversion"];
    [headerParams setValue:MapVersionNoV forKey:@"mapversion"];
    [headerParams setValue:deviceModel forKey:@"model"];
    [headerParams setValue:DeviceResolutionString forKey:@"resolution"];
    [headerParams setValue:CurrentSystemVersion  forKey:@"os"];
    [headerParams setValue:UserID_Account forKey:@"userid"];
    [headerParams setValue:UserSID forKey:@"sid"];
    [headerParams setValue:KNetChannelID forKey:@"syscode"];
    [headerParams setValue:PID forKey:@"pid"];
    [headerParams setValue:signString forKey:@"sign"];
    
    NetBaseRequestCondition *condition = [NetBaseRequestCondition requestCondition];
    condition.requestType = REQ_LOGIN;
    condition.httpHeaderFieldParams = headerParams;
    condition.httpMethod = @"POST";
    condition.bodyData = [[ThreeDes encrypt:xmlbodydata] dataUsingEncoding:NSUTF8StringEncoding];
    condition.urlParams = nil;
    condition.baceURL = baseUrl;
    
    [[NetExt sharedInstance] requestWithCondition:condition delegate:self];
    [headerParams release];
    self.strusername = username;
}



//判断是否登陆
- (void)accountLoginStatusRequest:(RequestType)type
{
    NSString *uri= @"/nis/user/loginstatus";
    NSString *baseUrl = [NSString stringWithFormat:@"%@%@",kAccountRequestURL,uri];
    NSString *imei = IDFA;
    NSString *processtime = NetProcessTime;
    NSString *signString = [[NSString stringWithFormat:@"%@%@%@@%@",KNetChannelID,uri,processtime,kNetSignKey] stringFromMD5];
    //拼接xml请求
    NSString *xmlbodydata = nil;
    DDXMLElement*  opg = [DDXMLElement elementWithName: @"opg"];
    DDXMLElement*  protversion =[DDXMLElement elementWithName: @"protversion"];
    [protversion setStringValue:@"2"];
    [opg addChild:protversion];
    
    DDXMLElement*  language =[DDXMLElement elementWithName: @"language"];
    [language setStringValue:[NSString stringWithFormat:@"%d",NetFontType]];
    [opg addChild:language];
    
    DDXMLElement*  info = [DDXMLElement elementWithName:@"info"];
    DDXMLElement*  xmlimei =[DDXMLElement elementWithName: @"imei"];
    [xmlimei setStringValue:imei];
    [info addChild:xmlimei];
    DDXMLElement*  xmlsid =[DDXMLElement elementWithName: @"sid"];
    [xmlsid setStringValue:self.strsid];
    [info addChild:xmlsid];
    
    DDXMLElement*  svccont = [DDXMLElement elementWithName:@"svccont"];
    [svccont addChild:info];
    [opg addChild:svccont];
    xmlbodydata = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\" ?>%@",[opg XMLString]];
    
    //httpheader
    NSMutableDictionary *headerParams = [[NSMutableDictionary alloc] init];
    [headerParams setValue:processtime forKey:@"timestamp"];
    [headerParams setValue:@"1" forKey:@"en"];//0不加密；1请求数据加密；2请求和应答数据都加密
    [headerParams setValue:[ThreeDes encrypt:IDFA] forKey:@"imei"];
    [headerParams setValue:[NSString stringWithFormat:@"%d",SOFTVERSIONCODE] forKey:@"apkversion"];
    [headerParams setValue:MapVersionNoV forKey:@"mapversion"];
    [headerParams setValue:deviceModel forKey:@"model"];
    [headerParams setValue:DeviceResolutionString forKey:@"resolution"];
    [headerParams setValue:CurrentSystemVersion  forKey:@"os"];
    [headerParams setValue:UserID_Account forKey:@"userid"];
    [headerParams setValue:UserSID forKey:@"sid"];
    [headerParams setValue:KNetChannelID forKey:@"syscode"];
    [headerParams setValue:PID forKey:@"pid"];
    [headerParams setValue:signString forKey:@"sign"];
    
    NetBaseRequestCondition *condition = [NetBaseRequestCondition requestCondition];
    condition.requestType = REQ_LOGIN_STATUS;
    condition.httpHeaderFieldParams = headerParams;
    condition.httpMethod = @"POST";
    condition.bodyData = [[ThreeDes encrypt:xmlbodydata] dataUsingEncoding:NSUTF8StringEncoding];
    condition.urlParams = nil;
    condition.baceURL = baseUrl;
    
    [[NetExt sharedInstance] requestWithCondition:condition delegate:self];
    [headerParams release];
}

//重置密码
- (void) accountpwdResetRequest:(RequestType)type username:(NSString*)username password:(NSString*)pwd checkcode:(NSString*)checkcode
{
    NSString *uri= @"/nis/user/pwdreset";
    NSString *baseUrl = [NSString stringWithFormat:@"%@%@",kAccountRequestURL,uri];
    NSString *imei = IDFA;
    NSString *processtime = NetProcessTime;
    NSString *signString = [[NSString stringWithFormat:@"%@%@%@@%@",KNetChannelID,uri,processtime,kNetSignKey] stringFromMD5];
    //拼接xml请求
    NSString *xmlbodydata = nil;
    DDXMLElement*  opg = [DDXMLElement elementWithName: @"opg"];
    DDXMLElement*  protversion =[DDXMLElement elementWithName: @"protversion"];
    [protversion setStringValue:@"2"];
    [opg addChild:protversion];
    
    DDXMLElement*  language =[DDXMLElement elementWithName: @"language"];
    [language setStringValue:[NSString stringWithFormat:@"%d",NetFontType]];
    [opg addChild:language];
    
    DDXMLElement*  info = [DDXMLElement elementWithName:@"info"];
    DDXMLElement*  xmlimei =[DDXMLElement elementWithName: @"imei"];
    [xmlimei setStringValue:imei];
    [info addChild:xmlimei];
    DDXMLElement*  xmlusername =[DDXMLElement elementWithName: @"username"];
    [xmlusername setStringValue:[ThreeDes encrypt:username]];
    [info addChild:xmlusername];
    DDXMLElement*  xmlpwd =[DDXMLElement elementWithName: @"pwd"];
    [xmlpwd setStringValue:[ThreeDes encrypt:pwd]];
    [info addChild:xmlpwd];
    DDXMLElement*  xmlcheckcode =[DDXMLElement elementWithName: @"checkcode"];
    [xmlcheckcode setStringValue:checkcode];
    [info addChild:xmlcheckcode];
    
    DDXMLElement*  svccont = [DDXMLElement elementWithName:@"svccont"];
    [svccont addChild:info];
    [opg addChild:svccont];
    xmlbodydata = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\" ?>%@",[opg XMLString]];
    
    //httpheader
    NSMutableDictionary *headerParams = [[NSMutableDictionary alloc] init];
    [headerParams setValue:processtime forKey:@"timestamp"];
    [headerParams setValue:@"1" forKey:@"en"];//0不加密；1请求数据加密；2请求和应答数据都加密
    [headerParams setValue:[ThreeDes encrypt:IDFA] forKey:@"imei"];
    [headerParams setValue:[NSString stringWithFormat:@"%d",SOFTVERSIONCODE] forKey:@"apkversion"];
    [headerParams setValue:MapVersionNoV forKey:@"mapversion"];
    [headerParams setValue:deviceModel forKey:@"model"];
    [headerParams setValue:DeviceResolutionString forKey:@"resolution"];
    [headerParams setValue:CurrentSystemVersion  forKey:@"os"];
    [headerParams setValue:UserID_Account forKey:@"userid"];
    [headerParams setValue:UserSID forKey:@"sid"];
    [headerParams setValue:KNetChannelID forKey:@"syscode"];
    [headerParams setValue:PID forKey:@"pid"];
    [headerParams setValue:signString forKey:@"sign"];
    
    NetBaseRequestCondition *condition = [NetBaseRequestCondition requestCondition];
    condition.requestType = REQ_RESET_PWD;
    condition.httpHeaderFieldParams = headerParams;
    condition.httpMethod = @"POST";
    condition.bodyData = [[ThreeDes encrypt:xmlbodydata] dataUsingEncoding:NSUTF8StringEncoding];
    condition.urlParams = nil;
    condition.baceURL = baseUrl;
    
    [[NetExt sharedInstance] requestWithCondition:condition delegate:self];
    [headerParams release];

}

//注销
- (void)accountLogoutRequest:(RequestType)type
{
    NSString *uri= @"/nis/user/logout";
    NSString *baseUrl = [NSString stringWithFormat:@"%@%@",kAccountRequestURL,uri];
    NSString *imei = IDFA;
    NSString *processtime = NetProcessTime;
    NSString *signString = [[NSString stringWithFormat:@"%@%@%@@%@",KNetChannelID,uri,processtime,kNetSignKey] stringFromMD5];
    //拼接xml请求
    NSString *xmlbodydata = nil;
    DDXMLElement*  opg = [DDXMLElement elementWithName: @"opg"];
    DDXMLElement*  protversion =[DDXMLElement elementWithName: @"protversion"];
    [protversion setStringValue:@"2"];
    [opg addChild:protversion];
    
    DDXMLElement*  language =[DDXMLElement elementWithName: @"language"];
    [language setStringValue:[NSString stringWithFormat:@"%d",NetFontType]];
    [opg addChild:language];
    
    DDXMLElement*  info = [DDXMLElement elementWithName:@"info"];
    DDXMLElement*  xmlimei =[DDXMLElement elementWithName: @"imei"];
    [xmlimei setStringValue:imei];
    [info addChild:xmlimei];
    DDXMLElement*  xmluserid =[DDXMLElement elementWithName: @"userid"];
    [xmluserid setStringValue:self.struserid];
    [info addChild:xmluserid];
    
    DDXMLElement*  svccont = [DDXMLElement elementWithName:@"svccont"];
    [svccont addChild:info];
    [opg addChild:svccont];
    xmlbodydata = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\" ?>%@",[opg XMLString]];
    
    //httpheader
    NSMutableDictionary *headerParams = [[NSMutableDictionary alloc] init];
    [headerParams setValue:processtime forKey:@"timestamp"];
    [headerParams setValue:@"1" forKey:@"en"];//0不加密；1请求数据加密；2请求和应答数据都加密
    [headerParams setValue:[ThreeDes encrypt:IDFA] forKey:@"imei"];
    [headerParams setValue:[NSString stringWithFormat:@"%d",SOFTVERSIONCODE] forKey:@"apkversion"];
    [headerParams setValue:MapVersionNoV forKey:@"mapversion"];
    [headerParams setValue:deviceModel forKey:@"model"];
    [headerParams setValue:DeviceResolutionString forKey:@"resolution"];
    [headerParams setValue:CurrentSystemVersion  forKey:@"os"];
    [headerParams setValue:UserID_Account forKey:@"userid"];
    [headerParams setValue:UserSID forKey:@"sid"];
    [headerParams setValue:KNetChannelID forKey:@"syscode"];
    [headerParams setValue:PID forKey:@"pid"];
    [headerParams setValue:signString forKey:@"sign"];
    
    NetBaseRequestCondition *condition = [NetBaseRequestCondition requestCondition];
    condition.requestType = REQ_LOGOUT;
    condition.httpHeaderFieldParams = headerParams;
    condition.httpMethod = @"POST";
    condition.bodyData = [[ThreeDes encrypt:xmlbodydata] dataUsingEncoding:NSUTF8StringEncoding];
    condition.urlParams = nil;
    condition.baceURL = baseUrl;
    
    [[NetExt sharedInstance] requestWithCondition:condition delegate:self];
    [headerParams release];
}


//绑定手机号
- (void) accountbindphoneRequest:(RequestType)type newphone:(NSString*)newphone  checkcode:(NSString*)checkcode
{
    NSString *uri= @"/nis/user/bindphone";
    NSString *baseUrl = [NSString stringWithFormat:@"%@%@",kAccountRequestURL,uri];
    NSString *imei = IDFA;
    NSString *processtime = NetProcessTime;
    NSString *signString = [[NSString stringWithFormat:@"%@%@%@@%@",KNetChannelID,uri,processtime,kNetSignKey] stringFromMD5];
    //拼接xml请求
    NSString *xmlbodydata = nil;
    DDXMLElement*  opg = [DDXMLElement elementWithName: @"opg"];
    DDXMLElement*  protversion =[DDXMLElement elementWithName: @"protversion"];
    [protversion setStringValue:@"2"];
    [opg addChild:protversion];
    
    DDXMLElement*  language =[DDXMLElement elementWithName: @"language"];
    [language setStringValue:[NSString stringWithFormat:@"%d",NetFontType]];
    [opg addChild:language];
    
    DDXMLElement*  info = [DDXMLElement elementWithName:@"info"];
    DDXMLElement*  xmlimei =[DDXMLElement elementWithName: @"imei"];
    [xmlimei setStringValue:imei];
    [info addChild:xmlimei];
    DDXMLElement*  xmluserid =[DDXMLElement elementWithName: @"userid"];
    [xmluserid setStringValue:self.struserid];
    [info addChild:xmluserid];
    DDXMLElement*  xmlphone =[DDXMLElement elementWithName: @"newphone"];
    [xmlphone setStringValue:newphone];
    [info addChild:xmlphone];
    DDXMLElement*  xmlcheckcode =[DDXMLElement elementWithName: @"checkcode"];
    [xmlcheckcode setStringValue:checkcode];
    [info addChild:xmlcheckcode];
    
    DDXMLElement*  svccont = [DDXMLElement elementWithName:@"svccont"];
    [svccont addChild:info];
    [opg addChild:svccont];
    xmlbodydata = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\" ?>%@",[opg XMLString]];
    
    //httpheader
    NSMutableDictionary *headerParams = [[NSMutableDictionary alloc] init];
    [headerParams setValue:processtime forKey:@"timestamp"];
    [headerParams setValue:@"1" forKey:@"en"];//0不加密；1请求数据加密；2请求和应答数据都加密
    [headerParams setValue:[ThreeDes encrypt:IDFA] forKey:@"imei"];
    [headerParams setValue:[NSString stringWithFormat:@"%d",SOFTVERSIONCODE] forKey:@"apkversion"];
    [headerParams setValue:MapVersionNoV forKey:@"mapversion"];
    [headerParams setValue:deviceModel forKey:@"model"];
    [headerParams setValue:DeviceResolutionString forKey:@"resolution"];
    [headerParams setValue:CurrentSystemVersion  forKey:@"os"];
    [headerParams setValue:UserID_Account forKey:@"userid"];
    [headerParams setValue:UserSID forKey:@"sid"];
    [headerParams setValue:KNetChannelID forKey:@"syscode"];
    [headerParams setValue:PID forKey:@"pid"];
    [headerParams setValue:signString forKey:@"sign"];
    
    NetBaseRequestCondition *condition = [NetBaseRequestCondition requestCondition];
    condition.requestType = REQ_BIND_PHONE_NUMBER;
    condition.httpHeaderFieldParams = headerParams;
    condition.httpMethod = @"POST";
    condition.bodyData = [[ThreeDes encrypt:xmlbodydata] dataUsingEncoding:NSUTF8StringEncoding];
    condition.urlParams = nil;
    condition.baceURL = baseUrl;
    
    [[NetExt sharedInstance] requestWithCondition:condition delegate:self];
    [headerParams release];
    
    self.strusername = newphone;
    
}

- (void) accountChangeNickNameRequest:(RequestType)type nickname:(NSString*)nickname
{
    NSString *uri= @"/nis/user/nickname";
    NSString *baseUrl = [NSString stringWithFormat:@"%@%@",kAccountRequestURL,uri];
    NSString *imei = IDFA;
    NSString *processtime = NetProcessTime;
    NSString *signString = [[NSString stringWithFormat:@"%@%@%@@%@",KNetChannelID,uri,processtime,kNetSignKey] stringFromMD5];
    //拼接xml请求
    NSString *xmlbodydata = nil;
    DDXMLElement*  opg = [DDXMLElement elementWithName: @"opg"];
    DDXMLElement*  protversion =[DDXMLElement elementWithName: @"protversion"];
    [protversion setStringValue:@"2"];
    [opg addChild:protversion];
    
    DDXMLElement*  language =[DDXMLElement elementWithName: @"language"];
    [language setStringValue:[NSString stringWithFormat:@"%d",NetFontType]];
    [opg addChild:language];
    
    DDXMLElement*  info = [DDXMLElement elementWithName:@"info"];
    DDXMLElement*  xmluserid =[DDXMLElement elementWithName: @"userid"];
    [xmluserid setStringValue:self.struserid];
    [info addChild:xmluserid];
    DDXMLElement*  xmlnickname =[DDXMLElement elementWithName: @"nickname"];
    [xmlnickname setStringValue:nickname];
    [info addChild:xmlnickname];
    
    DDXMLElement*  svccont = [DDXMLElement elementWithName:@"svccont"];
    [svccont addChild:info];
    [opg addChild:svccont];
    xmlbodydata = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"utf-8\" ?>%@",[opg XMLString]];
    
    //httpheader
    NSMutableDictionary *headerParams = [[NSMutableDictionary alloc] init];
    [headerParams setValue:processtime forKey:@"timestamp"];
    [headerParams setValue:@"1" forKey:@"en"];//0不加密；1请求数据加密；2请求和应答数据都加密
    [headerParams setValue:[ThreeDes encrypt:IDFA] forKey:@"imei"];
    [headerParams setValue:[NSString stringWithFormat:@"%d",SOFTVERSIONCODE] forKey:@"apkversion"];
    [headerParams setValue:MapVersionNoV forKey:@"mapversion"];
    [headerParams setValue:deviceModel forKey:@"model"];
    [headerParams setValue:DeviceResolutionString forKey:@"resolution"];
    [headerParams setValue:CurrentSystemVersion  forKey:@"os"];
    [headerParams setValue:UserID_Account forKey:@"userid"];
    [headerParams setValue:UserSID forKey:@"sid"];
    [headerParams setValue:KNetChannelID forKey:@"syscode"];
    [headerParams setValue:PID forKey:@"pid"];
    [headerParams setValue:signString forKey:@"sign"];
    
    NetBaseRequestCondition *condition = [NetBaseRequestCondition requestCondition];
    condition.requestType = REQ_CHANGE_NICKNAME;
    condition.httpHeaderFieldParams = headerParams;
    condition.httpMethod = @"POST";
    condition.bodyData = [[ThreeDes encrypt:xmlbodydata] dataUsingEncoding:NSUTF8StringEncoding];
    condition.urlParams = nil;
    condition.baceURL = baseUrl;
    
    [[NetExt sharedInstance] requestWithCondition:condition delegate:self];
    [headerParams release];
    self.strnickname = nickname;
    
}

//头像
- (void)accountHeaderImgRequest:(RequestType)type image:(UIImage*)image ;
{
    NSString *uri= @"/nis/user/headerimg";
    NSString *baseUrl = [NSString stringWithFormat:@"%@%@",kAccountRequestURL,uri];
    NSString *imei = IDFA;
    NSString *processtime = NetProcessTime;
    NSString *signString = [[NSString stringWithFormat:@"%@%@%@@%@",KNetChannelID,uri,processtime,kNetSignKey] stringFromMD5];

    //bodydata
    NSData *data = UIImagePNGRepresentation(image);
    char *buffer1 = malloc([data length] + 5);
    char *buffer=buffer1;
    Byte protversion = 100;
    memcpy(buffer, &protversion, sizeof(Byte));
    buffer++;
    int datalen = [data length];
    memcpy(buffer, &datalen, sizeof(int));
    buffer += sizeof(int);
    memcpy(buffer, [data bytes], datalen);
    
    //httpheader
    NSMutableDictionary *headerParams = [[NSMutableDictionary alloc] init];
    [headerParams setValue:processtime forKey:@"timestamp"];
    [headerParams setValue:@"0" forKey:@"en"];//0不加密；1请求数据加密；2请求和应答数据都加密
    [headerParams setValue:[ThreeDes encrypt:IDFA] forKey:@"imei"];
    [headerParams setValue:[NSString stringWithFormat:@"%d",SOFTVERSIONCODE] forKey:@"apkversion"];
    [headerParams setValue:MapVersionNoV forKey:@"mapversion"];
    [headerParams setValue:deviceModel forKey:@"model"];
    [headerParams setValue:DeviceResolutionString forKey:@"resolution"];
    [headerParams setValue:CurrentSystemVersion  forKey:@"os"];
    [headerParams setValue:UserID_Account forKey:@"userid"];
    [headerParams setValue:UserSID forKey:@"sid"];
    [headerParams setValue:KNetChannelID forKey:@"syscode"];
    [headerParams setValue:PID forKey:@"pid"];
    [headerParams setValue:signString forKey:@"sign"];
    
    NetBaseRequestCondition *condition = [NetBaseRequestCondition requestCondition];
    condition.requestType = REQ_UPLOAD_HEAD;
    condition.httpHeaderFieldParams = headerParams;
    condition.httpMethod = @"POST";
    condition.bodyData = [NSData dataWithBytes:buffer1 length:datalen+5] ;
    condition.urlParams = nil;
    condition.baceURL = baseUrl;
    
    [[NetExt sharedInstance] requestWithCondition:condition delegate:self];
    [headerParams release];
    free(buffer1);
    
}

//验证码请求
- (void)accountCheckCodeRequest:(RequestType)type phone:(NSString*)phone actiontype:(NSString*)actiontype
{
    NSString *uri= @"/nis/clientvalidata";
    NSString *baseUrl = [NSString stringWithFormat:@"%@%@",kAccountRequestURL,uri];
    NSString *imei = IDFA;
    NSString *processtime = NetProcessTime;
    NSString *signString = [[NSString stringWithFormat:@"%@%@%@@%@",KNetChannelID,uri,processtime,kNetSignKey] stringFromMD5];
    //bodydata
    NSMutableDictionary *bodydataDict = [[NSMutableDictionary alloc]init];
    NSMutableDictionary *svccont = [[NSMutableDictionary alloc]init];
    [svccont setValue:[ThreeDes encrypt:phone] forKey:@"phone"];
    [svccont setValue:actiontype forKey:@"actiontype"];
    
    [bodydataDict setValue:@"1" forKey:@"protversion"];
    [bodydataDict setValue:[NSString stringWithFormat:@"%d",NetFontType] forKey:@"language"];
    [bodydataDict setValue:svccont forKey:@"svccont"];
    
    //httpheader
    NSMutableDictionary *headerParams = [[NSMutableDictionary alloc] init];
    [headerParams setValue:processtime forKey:@"timestamp"];
    [headerParams setValue:@"1" forKey:@"en"];//0不加密；1请求数据加密；2请求和应答数据都加密
    [headerParams setValue:[ThreeDes encrypt:IDFA] forKey:@"imei"];
    [headerParams setValue:[NSString stringWithFormat:@"%d",SOFTVERSIONCODE] forKey:@"apkversion"];
    [headerParams setValue:MapVersionNoV forKey:@"mapversion"];
    [headerParams setValue:deviceModel forKey:@"model"];
    [headerParams setValue:DeviceResolutionString forKey:@"resolution"];
    [headerParams setValue:CurrentSystemVersion  forKey:@"os"];
    [headerParams setValue:UserID_Account forKey:@"userid"];
    [headerParams setValue:UserSID forKey:@"sid"];
    [headerParams setValue:KNetChannelID forKey:@"syscode"];
    [headerParams setValue:PID forKey:@"pid"];
    [headerParams setValue:signString forKey:@"sign"];
    //request
    NetBaseRequestCondition *condition = [NetBaseRequestCondition requestCondition];
    condition.requestType = REQ_CHECK_CODE;
    condition.httpHeaderFieldParams = headerParams;
    condition.httpMethod = @"POST";
    condition.bodyData = [[ThreeDes encrypt:[bodydataDict JSONRepresentation]] dataUsingEncoding:NSUTF8StringEncoding];
    condition.urlParams = nil;
    condition.baceURL = baseUrl;
    
    [[NetExt sharedInstance] requestWithCondition:condition delegate:self];
    [headerParams release];
    [svccont release];
    [bodydataDict release];
}

//验证码请求
- (void)accountGetImageRequest:(RequestType)type imageUrl:(NSString*)imageurl
{
    if(imageurl == nil)
    {
        return;
    }
//    NSString *imageurl123 = @"http://d.hiphotos.baidu.com/image/pic/item/9e3df8dcd100baa1be1b3d214510b912c8fc2e70.jpg";
    NetBaseRequestCondition *condition = [NetBaseRequestCondition requestCondition];
    condition.requestType = REQ_GET_HEAD;
//    condition.httpHeaderFieldParams = headerParams;
    condition.httpMethod = @"GET";
    condition.urlParams = nil;
    condition.baceURL = imageurl;
    
    [[NetExt sharedInstance] requestWithCondition:condition delegate:self];
//    [headerParams release];
}



- (void)processLoadingData:(RequestType)type  dicdata:(NSDictionary*)requestDic
{
    if(type == REQ_REGIST)
    {
        NSDictionary *svccont = [requestDic objectForKey:@"svccont"];
        NSDictionary *info = [svccont objectForKey:@"info"];
        self.struserid = [info objectForKey:@"userid"];

    }
    else if(type == REQ_LOGIN)
    {
        NSDictionary *svccont = [requestDic objectForKey:@"svccont"];
        NSDictionary *info = [svccont objectForKey:@"info"];
        self.struserid = [info objectForKey:@"userid"];
        self.strsid = [info objectForKey:@"sid"];
        self.strphone = [info objectForKey:@"mobile"];
        self.strnickname = [info objectForKey:@"nickname"];
        self.strimageurl = [info objectForKey:@"headerimg"];
        int logtype = 2;//登陆状态（0未登录，1邮箱，2手机）
        BOOL IsPhone = [[Plugin_Account_Utility shareInstance]bCheckPhone:self.strusername];
        if(IsPhone)
        {
            logtype = 2;
        }
        else
        {
            logtype = 1;
        }
        
        if(logtype == 1 && self.strphone && [[Plugin_Account_Utility shareInstance]bCheckPhone:self.strphone])
        {
            self.strusername = self.strphone;
        }
        
        NSMutableArray *accountinfo = [[NSMutableArray alloc]initWithArray:[[Account AccountInstance]getAccountInfo]];
        [accountinfo replaceObjectAtIndex:0 withObject:[NSNumber numberWithInt:logtype]];
        [accountinfo replaceObjectAtIndex:7 withObject:self.struserid];
        [accountinfo replaceObjectAtIndex:8 withObject:self.strsid];
        [accountinfo replaceObjectAtIndex:1 withObject:self.strusername];
        [accountinfo replaceObjectAtIndex:3 withObject:self.strnickname];
        [[Account AccountInstance]setAccountInfo:accountinfo];
        [accountinfo release];
        
        AccountPersonalData *personalData = [AccountPersonalData SharedInstance];
        personalData.m_profileHeadUrl = self.strimageurl;
        //请求下载头像，正确返回的时候设置头像信息
    }
    
    else if(type == REQ_LOGOUT)
    {
        self.strsid = @"";
        NSMutableArray *accountinfo = [[NSMutableArray alloc]initWithArray:[[Account AccountInstance]getAccountInfo]];
        [accountinfo replaceObjectAtIndex:8 withObject:self.strsid];
        [accountinfo replaceObjectAtIndex:0 withObject:[NSNumber numberWithInt:0]];//未登录
        [[Account AccountInstance]setAccountInfo:accountinfo];
        [accountinfo release];
    }
    else if(type == REQ_CHANGE_NICKNAME || type == REQ_BIND_PHONE_NUMBER)
    {
        NSMutableArray *accountinfo = [[NSMutableArray alloc]initWithArray:[[Account AccountInstance]getAccountInfo]];
        [accountinfo replaceObjectAtIndex:7 withObject:self.struserid];
        [accountinfo replaceObjectAtIndex:8 withObject:self.strsid];
        [accountinfo replaceObjectAtIndex:1 withObject:self.strusername];
        [accountinfo replaceObjectAtIndex:3 withObject:self.strnickname];
        [[Account AccountInstance]setAccountInfo:accountinfo];
        [accountinfo release];
    }

}

#pragma mark - 请求回调
/*!
  @brief 请求应答成功回调
  */
- (void)request:(NetRequestExt *)request didFinishLoadingWithData:(NSData *)data
{
    if(request.requestCondition.requestType == REQ_GET_HEAD)
    {
        if (data && [data length])
        {
            NSMutableArray *accountInfoArray = [NSMutableArray arrayWithArray:[[Account AccountInstance] getAccountInfo]];
            [accountInfoArray replaceObjectAtIndex:4 withObject:data];
            [[Account AccountInstance] setAccountInfo:accountInfoArray];
            if (delegate && [delegate respondsToSelector:@selector(requestToViewCtrWithRequestType:didFinishLoadingWithResult:)])
            {
                [delegate requestToViewCtrWithRequestType:request.requestCondition.requestType didFinishLoadingWithResult:nil];
            }
        }
        return;
    }
    if (data && [data length])
    {
        NSString *tmp = [[[NSString alloc ] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
        
        
        if (request.requestCondition.requestType == REQ_CHECK_CODE)//验证码返回格式是json
        {
            NSLog(@"验证码获取结果：%@",tmp);
            NSDictionary *requestDic = [NSJSONSerialization
                                        
                                        JSONObjectWithData:data
                                        
                                        options:NSJSONReadingMutableLeaves
                                        
                                        error:nil];
            if (requestDic)
            {
                NSDictionary *responseDic = [requestDic objectForKey:@"response"];
                
                if (responseDic )//&& [[responseDic objectForKey:@"rspcode"] isEqualToString:@"0000"])
                {
                    NSDictionary *svccont = [requestDic objectForKey:@"svccont"];
                    NSString *identifyCode = [svccont objectForKey:@"identifyCode"];
                    NSString *desc = [svccont objectForKey:@"desc"];
                    NSString *expiryDate = [svccont objectForKey:@"expiryDate"];
                    NSLog(@"%@,%@,%@",identifyCode,desc,expiryDate);
                    self.strcheckcode = identifyCode;
                    
                    NSMutableDictionary *retResult = [[NSMutableDictionary alloc]init];
                    NSString *rspcode = [responseDic objectForKey:@"rspcode"];
                    [retResult setValue:rspcode forKey:@"rspcode" ];
                    if (delegate && [delegate respondsToSelector:@selector(requestToViewCtrWithRequestType:didFinishLoadingWithResult:)])
                    {
                        [delegate requestToViewCtrWithRequestType:request.requestCondition.requestType didFinishLoadingWithResult:retResult];
                    }
                    [retResult release];
                    
                }

            }
            else//requestDic为空
            {
                if (delegate &&[delegate respondsToSelector:@selector(requestToViewCtrWithRequestType:didFailWithError:)])
                {
                    [delegate requestToViewCtrWithRequestType:request.requestCondition.requestType didFailWithError:nil];
                }
            }
            
        }//endof request type

        else
        {
            NSDictionary *requestDic = [NSDictionary dictionaryWithXMLData:data];
            NSDictionary *requestresponse = [requestDic objectForKey:@"response"];
            NSString *rspcode = [requestresponse objectForKey:@"rspcode"];
            if([rspcode isEqualToString:@"0000"])
            {
                [self processLoadingData:request.requestCondition.requestType  dicdata:requestDic];
            }
            if (delegate && [delegate respondsToSelector:@selector(requestToViewCtrWithRequestType:didFinishLoadingWithResult:)])
            {
                NSMutableDictionary *retResult = [[NSMutableDictionary alloc]init];
                [retResult setValue:rspcode forKey:@"rspcode" ];
                [delegate requestToViewCtrWithRequestType:request.requestCondition.requestType didFinishLoadingWithResult:retResult];
                [retResult release];
            }
        }
        
        
    }// endof data && data length
    else
    {
        if (delegate && [delegate respondsToSelector:@selector(requestToViewCtrWithRequestType:didFailWithError:)])
        {
            [delegate requestToViewCtrWithRequestType:request.requestCondition.requestType didFailWithError:nil];
        }
    }
    
}
/*!
  @brief 请求失败回调
  */
- (void)request:(NetRequestExt *)request didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError..........");
    if(request.requestCondition.requestType == REQ_GET_HEAD)
    {
        return;
    }
    

    if (delegate &&[delegate respondsToSelector:@selector(requestToViewCtrWithRequestType:didFailWithError:)])
    {
        [delegate requestToViewCtrWithRequestType:request.requestCondition.requestType didFailWithError:error];
    }
    
    else
    {
        if (delegate && [delegate respondsToSelector:@selector(requestToViewCtrWithRequestType:didFailWithError:)])
        {
            [delegate requestToViewCtrWithRequestType:request.requestCondition.requestType didFailWithError:error];
        }
    }
}


@end

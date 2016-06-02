//
//  MWICallRequest.m
//  AutoNavi
//
//  Created by weisheng on 14-6-11.
//
//

#import "MWICallRequest.h"
#import "JSON.h"
#import "JSONKit.h"
#import "ThreeDes.h"
static MWICallRequest * instance = nil;
@implementation MWICallRequest

@synthesize icallNetDelegate;
+(MWICallRequest *)sharedInstance // 用户反馈
{
    if (instance == nil)
    {
        instance = [[MWICallRequest alloc] init];
    }//人工导航
    return instance;
}
-(NSMutableDictionary *)httpHeaderField:(RequestType)type
{
    NSMutableDictionary *Params = [NSMutableDictionary dictionary] ;
    if (VendorID)
    {
        [Params setObject:VendorID forKey:@"imei"];//设备终端唯一标示
    }
    if (MapVersionNoV) {
        [Params setObject:MapVersionNoV forKey:@"mapversion"];//获取地图数据版本号
    }
    if (SOFTVERSIONCODE) {
        [Params setObject:[NSString stringWithFormat:@"%d",SOFTVERSIONCODE] forKey:@"apkversion"];//应用软件版本号
    }
    if (DeviceResolutionName) {
        [Params setObject:DeviceResolutionName forKey:@"model"];//用户机型
    }
    if (DeviceResolutionString) {
        [Params setObject:DeviceResolutionString forKey:@"resolution"];//终端分辨率
    }
    if (CurrentSystemVersion) {
        [Params setObject:CurrentSystemVersion forKey:@"os"];//系统版本号
    }
    if (LoginStatus_Account) {
        if (UserID_Account) {
            [Params setObject:UserID_Account forKey:@"userid"];//userid
        }
    }
    [Params setObject:@"" forKey:@"sid"];//登录令牌
    if (KNetChannelID) {
        [Params setObject:KNetChannelID forKey:@"syscode"];//软件安装渠道编号
    }
    if (PID) {
        [Params setObject:PID forKey:@"pid"];//￼产品编号
    }
    NSString * string = @"";
    if (type == REQ_PRE_CALL_95190) {
        if ([Params objectForKey:@"syscode"]) {
            string = [Params objectForKey:@"syscode"];
        }
        if ([Params objectForKey:@"userid"]) {
            string = [string stringByAppendingString: [Params objectForKey:@"userid"]];
        }
        GCARINFO pCarInfo;
        GDBL_GetCarInfo(&pCarInfo);
        string = [string stringByAppendingString:[NSString stringWithFormat:@"%f",pCarInfo.Coord.x/1000000.0]];
        string = [string stringByAppendingString:[NSString stringWithFormat:@"%f",pCarInfo.Coord.y/1000000.0]];
    }
    else if (type == REQ_GET_95190CHECK)
    {
        if ([Params objectForKey:@"syscode"]) {
            string = [Params objectForKey:@"syscode"];
        }
        if (VendorID) {
           string = [string stringByAppendingString:VendorID];
        }
    }
    else
    {
        if ([Params objectForKey:@"syscode"]) {
            string = [Params objectForKey:@"syscode"];
            NSLog(@"%@",string);
        }
        if ([Params objectForKey:@"userid"]) {
            NSLog(@"%@",[Params objectForKey:@"userid"]);
            string = [string stringByAppendingString:[Params objectForKey:@"userid"]];
            NSLog(@"%@",string);
        }
    }
    if (string) {
        NSLog(@"%@",string);
        NSString * sign = [[NSString stringWithFormat:@"%@@%@",string,kNetSignKey] stringFromMD5];
        if (sign)
        {
            [Params setObject:sign forKey:@"sign"];
        }
    }
    NSLog(@"%@",Params);
    return Params;
    
}
-(NSString *)getSysTimeNow
{
    NSString * date;
    NSDateFormatter* formatter = [[[NSDateFormatter alloc]init] autorelease];
    [formatter setDateFormat:@"YYYYMMddhhmmss"];
    date = [formatter stringFromDate:[NSDate date]];
    return date;
}


#pragma mark 判断当前的有没有绑定手机号码
/*
 *	接口用于实现获取服务号码
 *	@param	type	请求类型
 *	@param	phone	绑定的电话号码
 *	@param	license_val	验证码
 *	@param	delegate	回调委托
 *
 *	@return	成功返回GD_ERR_OK, 失败返回对应出错码
 */
- (void)Net_accountGet95190PhoneWith:(RequestType)type delegate:(id<NetReqToViewCtrDelegate>)delegate
{
    icallNetDelegate = delegate;
    NSMutableDictionary *Params = [NSMutableDictionary dictionary];
    
    [Params setObject:@"0004" forKey:@"activitycode"];
    
    [Params setObject:[NSString stringWithFormat:@"%d",NetFontType] forKey:@"language"];
    
    [Params setObject:@"1" forKey:@"protversion"];
    if ([self getSysTimeNow]) {
        [Params setObject:[self getSysTimeNow] forKey:@"processtime"];
    }
    if (![NSJSONSerialization isValidJSONObject:Params]) {
        return;
    }
    NSData * data=[NSJSONSerialization dataWithJSONObject:Params options:NSJSONWritingPrettyPrinted error:nil];
    NSLog(@"%@",[[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding] autorelease]);
    NetBaseRequestCondition *condition = [NetBaseRequestCondition requestCondition];
    condition.baceURL = kICallURL;
    NSLog(@"%@",kICallURL);
    condition.requestType = type;
    condition.httpHeaderFieldParams =[self httpHeaderField:type];
    condition.bodyData =data;
    condition.httpMethod = @"POST";
    [[NetExt sharedInstance] requestWithCondition:condition delegate:self]; //开始请求
    
}
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
- (void)Net_accountGet95190CheckNumberWith:(RequestType)type phone:(NSString *)phone delegate:(id<NetReqToViewCtrDelegate>)delegate
{
    icallNetDelegate = delegate;
    NSMutableDictionary * Params = [[NSMutableDictionary alloc]init];
    [Params setObject:@"0004" forKey:@"activitycode"];
    [Params setObject:@"1"    forKey:@"protversion"];
    [Params setObject:[NSString stringWithFormat:@"%d",NetFontType] forKey:@"language"];
    if ([self getSysTimeNow]) {
        [Params setObject:[self getSysTimeNow] forKey:@"processtime"];
    }
    NSMutableDictionary * dicsvccont = [NSMutableDictionary dictionary];
    if (phone) {
        [dicsvccont setObject:[ThreeDes encrypt:phone] forKey:@"phone"];
    }
    [Params setObject:dicsvccont forKey:@"svccont"];
    NSLog(@"%@",Params);
    if (![NSJSONSerialization isValidJSONObject:Params]) {
        return;
    }
    NSData * data = [NSJSONSerialization dataWithJSONObject:Params options:NSJSONWritingPrettyPrinted error:nil];
    NSLog(@"%@",[[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding] autorelease]);
	NetBaseRequestCondition *condition = [NetBaseRequestCondition requestCondition];
    condition.baceURL = kICallSMSURL;
    condition.requestType = type;
    condition.bodyData = data;
    condition.httpHeaderFieldParams = [self httpHeaderField:type];
    condition.httpMethod = @"POST";
    
    [[NetExt sharedInstance] requestWithCondition:condition delegate:self];
    [Params release];
}
#pragma mark 客户端向服务端绑定用于95190服务的电话号码
/*
 *	接口用于实现客户端向服务端绑定用于95190服务的电话号码。
 *
 *	@param	type	请求类型
 *	@param	phone	绑定的电话号码
 *	@param	license_val	验证码
 *	@param	delegate	回调委托
 *
 *	@return	成功返回GD_ERR_OK, 失败返回对应出错码
 */
- (void)Net_accountBind95190PhoneWith:(RequestType)type phone:(NSString *)phone license_val:(NSString *)license_val delegate:(id<NetReqToViewCtrDelegate>)delegate
{
    icallNetDelegate = delegate;
    NSMutableDictionary *Params = [NSMutableDictionary dictionary];
    
    [Params setObject:@"0005" forKey:@"activitycode"];
    [Params setObject:@"1" forKey:@"protversion"];
    if ([self getSysTimeNow]) {
        [Params setObject:[self getSysTimeNow] forKey:@"processtime"];
    }
    [Params setObject:[NSString stringWithFormat:@"%d",NetFontType] forKey:@"language"];
    NSMutableDictionary * dic =[NSMutableDictionary dictionary];
    if (phone) {
        [dic setObject:[ThreeDes encrypt:phone] forKey:@"phone"];
    }
    if (license_val) {
        [dic setObject:license_val forKey:@"chekcode"];
    }
    [Params setObject:dic forKey:@"svccont"];
    NSLog(@"%@",Params);
    if (![NSJSONSerialization isValidJSONObject:Params]) {
        return;
    }
    NSData * data=[NSJSONSerialization dataWithJSONObject:Params options:NSJSONWritingPrettyPrinted error:nil];
    NetBaseRequestCondition *condition = [NetBaseRequestCondition requestCondition];
    condition.baceURL = kICallURL;
    condition.requestType = type;
    condition.bodyData = data;
    condition.httpHeaderFieldParams = [self httpHeaderField:type];
    condition.httpMethod = @"POST";
    [[NetExt sharedInstance] requestWithCondition:condition delegate:self];
    
}

#pragma mark 修改95190服务的电话号码
/*
 *	绑定服务号码
 *
 *	@param	type	请求类型
 *	@param	phone	绑定的电话号码
 *	@param	license_val	验证码
 *	@param	delegate	回调委托
 *
 *	@return	成功返回GD_ERR_OK, 失败返回对应出错码
 */
- (void)Net_accountModify95190PhoneWith:(RequestType)type phone:(NSString *)phone license_val:(NSString *)license_val delegate:(id<NetReqToViewCtrDelegate>)delegate
{
    icallNetDelegate = delegate;
    NSMutableDictionary *Params = [NSMutableDictionary dictionary];
    [Params setObject:@"0005" forKey:@"activitycode"];
    [Params setObject:@"1" forKey:@"protversion"];
    if ([self getSysTimeNow]) {
        [Params setObject:[self getSysTimeNow] forKey:@"processtime"];
    }
    [Params setObject:[NSString stringWithFormat:@"%d",NetFontType] forKey:@"language"];
    NSMutableDictionary * dic =[NSMutableDictionary dictionary];
    if (phone) {
        [dic setObject:[ThreeDes encrypt:phone] forKey:@"phone"];
    }
    if (license_val) {
        [dic setObject:license_val forKey:@"chekcode"];
    }
    [Params setObject:dic forKey:@"svccont"];
    if (![NSJSONSerialization isValidJSONObject:Params]) {
        return;
    }
    NSData * data=[NSJSONSerialization dataWithJSONObject:Params options:NSJSONWritingPrettyPrinted error:nil];
    NetBaseRequestCondition *condition = [NetBaseRequestCondition requestCondition];
    condition.baceURL = kICallURL;
    condition.requestType = type;
    //condition.urlParams = Params;
    condition.httpHeaderFieldParams = [self httpHeaderField:type];
    condition.bodyData = data;
    condition.httpMethod = @"POST";
    [[NetExt sharedInstance] requestWithCondition:condition delegate:self];
}

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
- (void)Net_accountPreCall95190With:(RequestType)type phone:(NSString *)phone delegate:(id<NetReqToViewCtrDelegate>)delegate
{
    icallNetDelegate = delegate;
    GCARINFO pCarInfo;
    GDBL_GetCarInfo(&pCarInfo);
    
	NSMutableDictionary * Params = [NSMutableDictionary dictionary];
    [Params setObject:@"0001" forKey:@"activitycode"];
    [Params setObject:@"0" forKey:@"protversion"];
    [Params setObject:[self getSysTimeNow] forKey:@"processtime"];
    [Params setObject:[NSString stringWithFormat:@"%d",NetFontType] forKey:@"language"];
    
    
    NSMutableDictionary * dic =[NSMutableDictionary dictionary];
    [dic setObject:@"0" forKey:@"type"];
    [dic setObject:[NSString stringWithFormat:@"%f",pCarInfo.Coord.x/1000000.0] forKey:@"x"];
    [dic setObject:[NSString stringWithFormat:@"%f",pCarInfo.Coord.y/1000000.0] forKey:@"y"];
    if (phone) {
        [dic setObject:[ThreeDes encrypt:phone] forKey:@"phone"];
    }
    [Params setObject:dic forKey:@"svccont"];
    if (![NSJSONSerialization isValidJSONObject:Params]) {
        return;
    }
    NSData * data=[NSJSONSerialization dataWithJSONObject:Params options:NSJSONWritingPrettyPrinted error:nil];
    NSLog(@"%@",[[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding] autorelease]);
    NetBaseRequestCondition *condition = [NetBaseRequestCondition requestCondition];
    condition.baceURL = kICallURL;
    condition.requestType = type;
    //condition.urlParams = Params;
    condition.httpHeaderFieldParams = [self httpHeaderField:type];
    condition.bodyData = data;
    condition.httpMethod = @"POST";
    
    [[NetExt sharedInstance] requestWithCondition:condition delegate:self];
}
#pragma mark 拨打电话后 获取目的地
/*
 *	下载目的地接口
 *
 *	@param	type	请求类型
 *	@param	phone	绑定的手机号码
 *	@param	delegate	回调委托
 *
 *	@return	成功返回GD_ERR_OK, 失败返回对应出错码
 */
- (void)Net_accountGetCurrentDesWith:(RequestType)type phone:(NSString *)phone delegate:(id<NetReqToViewCtrDelegate>)delegate
{
    icallNetDelegate = delegate;
    NSMutableDictionary *Params = [NSMutableDictionary dictionary];
    [Params setObject:@"0002" forKey:@"activitycode"];
    [Params setObject:@"1" forKey:@"protversion"];
    [Params setObject:[NSString stringWithFormat:@"%d",NetFontType] forKey:@"language"];
    
    if ([self getSysTimeNow]) {
        [Params setObject:[self getSysTimeNow] forKey:@"processtime"];
    }
    NSMutableDictionary * dic =[NSMutableDictionary dictionary];
    if (phone) {
        [dic setObject:[ThreeDes encrypt:phone] forKey:@"phone"];
    }
    [Params setObject:dic forKey:@"svccont"];
    NSLog(@"%@",Params);
    if (![NSJSONSerialization isValidJSONObject:Params]) {
        return;
    }
    NSData * data=[NSJSONSerialization dataWithJSONObject:Params options:NSJSONWritingPrettyPrinted error:nil];
    NSLog(@"%@",[[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding] autorelease]);
    NetBaseRequestCondition *condition = [NetBaseRequestCondition requestCondition];
    condition.baceURL = kICallURL;
    condition.requestType = type;
    condition.httpHeaderFieldParams = [self httpHeaderField:type];
    condition.bodyData = data;
    //condition.urlParams = Params;
    condition.httpMethod = @"POST";
    
    [[NetExt sharedInstance] requestWithCondition:condition delegate:self];
}
#pragma mark 获取上一次用户通过95190设置的目的地
/**
 *	下载目的地接口
 *
 *	@param	type	请求类型
 *	@param	delegate	回调委托
 *
 *	@return	成功返回GD_ERR_OK, 失败返回对应出错码
 */
- (void)Net_accountGetOldDestinationWith:(RequestType)type phone:(NSString *)phone delegate:(id<NetReqToViewCtrDelegate>)delegate
{
    icallNetDelegate = delegate;
    NSMutableDictionary *Params = [NSMutableDictionary dictionary];
    [Params setObject:@"0002" forKey:@"activitycode"];
    [Params setObject:@"1" forKey:@"protversion"];
    
    [Params setObject:[NSString stringWithFormat:@"%d",NetFontType] forKey:@"language"];
    
    if ([self getSysTimeNow]) {
        [Params setObject:[self getSysTimeNow] forKey:@"processtime"];
    }
    NSMutableDictionary * dic =[NSMutableDictionary dictionary];
    if (phone) {
        [dic setObject:[ThreeDes encrypt:phone] forKey:@"phone"];
    }
    [Params setObject:dic forKey:@"svccont"];
    NSLog(@"%@",Params);
    if (![NSJSONSerialization isValidJSONObject:Params]) {
        return;
    }
    NSData * data=[NSJSONSerialization dataWithJSONObject:Params options:NSJSONWritingPrettyPrinted error:nil];
    NSLog(@"%@",[[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding] autorelease]);
	NetBaseRequestCondition *condition = [NetBaseRequestCondition requestCondition];
    condition.baceURL = kICallURL;
    condition.requestType = type;
    condition.httpHeaderFieldParams = [self httpHeaderField:type];
    condition.bodyData = data;
    condition.httpMethod = @"POST";
    
    [[NetExt sharedInstance] requestWithCondition:condition delegate:self];
}
/**
 *	根据状态返回当前的错误信息
 */
-(void)getErrorCodeType:(int)errorCode
{
    
    NSString * string = @"";
    switch (errorCode) {
        case 1002:
        {string = @"内部服务器错误(请求失败)";
            string = STR(@"Icall_Type1002",Localize_Icall);
            
        }break;
        case 1008:
        {string = @"￼userid 为空";
            string = STR(@"Icall_Type1008", Localize_Icall);
            
        }break;
        case 1011:
        { string = @"缺少请求参数";
         string=   STR(@"Icall_Type1011", Localize_Icall);
            
        }break;
        case 1013:
        { string = @"￼软件鉴权失败";
            string=STR(@"Icall_Type1013", Localize_Icall);
            
        }break;
        case 1014:
        {string = @"syscode 不能为空";
            string =    STR(@"Icall_Type1014", Localize_Icall);
            
        }break;
        case 1026:
        {string = @"软件版本号不能为空";
            string=   STR(@"Icall_Type1026", Localize_Icall);
            
            
        }break;
        case 1027:
        {string = @"imei 参数不能为空";
            string=   STR(@"Icall_Type1027", Localize_Icall);
            
            
        }break;
        case 1101:
        {string = @"请求目的地失效";
            string=   STR(@"Icall_Type1101", Localize_Icall);
            
        }break;
        case 1102:
        {string = @"目的地还未设置";
            string=   STR(@"Icall_Type1102", Localize_Icall);
            
        }break;
        case 1103:
        {string = @"用户不存在";
            string=    STR(@"Icall_Type1103", Localize_Icall);
            
        }break;
        case 1104:
        { string = @"无法获取到目的地";
            string =  STR(@"Icall_Type1104", Localize_Icall);
            
            
        }break;
        case 1105:
        { string = @"服务号码为空或非法";
            string=  STR(@"Icall_Type1105", Localize_Icall);
        }break;
        case 1106:
        {  string = @"验证码失效";
            string=  STR(@"Icall_Type1106", Localize_Icall);
            
        }break;
            
        default:
        {
            string = @"其他错误";
            string=  STR(@"Icall_TypeOther", Localize_Icall);
            
        }break;
    }
    [POICommon showAutoHideAlertView:string showTime:2.0f];
}
#pragma mark
#pragma mark NetRequestExtDelegate
- (void)request:(NetRequestExt *)request didFinishLoadingWithData:(NSData *)data
{
    NSDictionary * result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    NSLog(@"%@",result);
    if (icallNetDelegate&&[icallNetDelegate respondsToSelector:@selector(requestToViewCtrWithRequestType:didFinishLoadingWithResult:)])
    {
        [icallNetDelegate requestToViewCtrWithRequestType:request.requestCondition.requestType didFinishLoadingWithResult:result];
    }
}

- (void)request:(NetRequestExt *)request didFailWithError:(NSError *)error
{
    if (icallNetDelegate && [icallNetDelegate respondsToSelector:@selector(requestToViewCtrWithRequestType:didFailWithError:)]) {
        [icallNetDelegate requestToViewCtrWithRequestType:request.requestCondition.requestType didFailWithError:error];
    }
}

-(void)dealloc
{
    CRELEASE(icallNetDelegate);
    [super dealloc];
}
@end

//
//  MWFeedBackRequest.m
//  AutoNavi
//
//  Created by weisheng on 14-6-11.
//
//

#import "MWFeedBackRequest.h"
#import "MWMapOperator.h"


static MWFeedBackRequest * feedBack = nil;
@implementation MWFeedBackRequest
@synthesize feedBackDelegate;
+(MWFeedBackRequest *)sharedInstance // 用户反馈
{
    if (feedBack == nil)
    {
        feedBack = [[MWFeedBackRequest alloc] init];
    }
    return feedBack;
}
#pragma mark 用户反馈的接口
/**
 *	用户反馈的接口
 *  @param  description 反馈问题的具体描述
 *  @paran  errorType   反馈类型
 *	@param	type	请求类型
 *	@param	delegate	回调委托
 *	@return	成功返回GD_ERR_OK, 失败返回对应出错码
 */
- (void)Net_FeedbackGetUser:(MWFeedbackFunctionCondition *)description requestType:(RequestType)type delegate:(id<NetReqToViewCtrDelegate>)delegate;
{
    feedBackDelegate = delegate;
    NSMutableDictionary *postParam = [NSMutableDictionary dictionary];
    if (MapVersionNoV) {
        [postParam setObject:MapVersionNoV forKey:@"did"];//获取地图数据版本号
    }
    if (SOFT_AOS_VERSION) {
        [postParam setObject:[NSString stringWithFormat:@"%@",SOFT_AOS_VERSION] forKey:@"div"];//应用软件版本号
    }
    if (GDEngineNOVVersion) {
        [postParam setObject:GDEngineNOVVersion forKey:@"die"];//引擎版本号
    }
    if (USER_DEVICE_INFO_DIC) {
        [postParam setObject:USER_DEVICE_INFO_DIC forKey:@"dic"];//软件安装渠道编号
    }
    if (USER_DEVICE_INFO_MAC) {
        [postParam setObject:USER_DEVICE_INFO_MAC forKey:@"diu"];//设备唯一吗
    }
     //dip = appid, 产品代码 请求发起方的应用唯一标识, 可严格区分不同应用、不同平台等等
    if (USER_DEVICE_INFO_APPID) {
        [postParam setObject:USER_DEVICE_INFO_APPID forKey:@"dip"];
    }
    //channel	授权号, 由系统统一分配
    if (USER_DEVICE_INFO_CHANNEL) {
        [postParam setObject:USER_DEVICE_INFO_CHANNEL forKey:@"channel"];
    }
    //获取用户userid
    if (UserID_Account) {
        if (UserID_Account) {
            [postParam setObject:UserID_Account forKey:@"userid"];//userid
        }
    }
    GCARINFO carInfo = {0};
    [[MWMapOperator sharedInstance] GMD_GetCarInfo:&carInfo];
    GCOORD pcoord ={0};
    pcoord.x = carInfo.Coord.x;
    pcoord.y = carInfo.Coord.y;
    int adcode = [MWAdminCode GetAdminCode:pcoord];
    
    if (adcode) {
        [postParam setObject:[NSString stringWithFormat:@"%d",adcode] forKey:@"adcode"];
    }
    //推送设备令牌
    if (deviceTokenEx) {
        [postParam setObject:deviceTokenEx forKey:@"token"];
    }
    [postParam setObject:@"1000" forKey:@"type"];
    NSMutableDictionary * dicUdes = [NSMutableDictionary dictionary];
    //问题描述 ＝ 如位置错误+用户输入描述
    if (description.errorDesc) {
          NSString * string = [description.errorDesc  stringByReplacingOccurrencesOfString:@"&" withString:@""];
          string = [[self getQuestionTypeName:1000] stringByAppendingString:string];
          [dicUdes setObject:string forKey:@"uDes"];
    }
    if (![NSJSONSerialization isValidJSONObject:dicUdes]) {
        return;
    }
    NSData * data = [NSJSONSerialization dataWithJSONObject:dicUdes options:NSJSONWritingPrettyPrinted error:nil];
    NSString * stringDes = [[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding] autorelease];
    if (stringDes) {
          [postParam setObject:stringDes forKey:@"description"];
    }
    //手机号或邮箱+机型信息/系统版本/分辨率
    NSString * stringTel = description.tel;
    //stringTel = [[[stringTel stringByAppendingFormat:@"+%@",deviceModel] stringByAppendingFormat:@"/%@",CurrentSystemVersion] stringByAppendingFormat:@"/%@",DeviceResolutionString];
    NSMutableString * stringContact = [NSMutableString stringWithFormat:@"%@+%@/%@/%@",stringTel,deviceModel,CurrentSystemVersion,DeviceResolutionString];
    if (stringContact) {
        [postParam setObject:stringContact forKey:@"contact"];
    }
    [postParam setObject:@"json" forKey:@"output"];
    //MD5加密 USER_DEVICE_INFO_CHANNEL＋类型＋问题描述 ＋key
    NSMutableString * encryptChannel = [[NSMutableString alloc]initWithFormat:@"%@%@%@@%@",USER_DEVICE_INFO_CHANNEL,[postParam objectForKey:@"type"],stringDes,USER_DEVICE_INFO_KEY];
    NSString *returnString = [[encryptChannel stringFromMD5] uppercaseString];
    if (returnString) {
        [postParam setObject:returnString forKey:@"sign"];
    }
    NSMutableDictionary * picture = [NSMutableDictionary dictionary];
    if (description.pic) {//反馈图片
        [picture setObject:description.pic forKey:@"picture"];
    }
    NSData * bodyData = [[NetExt sharedInstance]postBodyData:picture];
    NetBaseRequestCondition * condition = [NetBaseRequestCondition requestCondition];
    condition.requestType = type;
    condition.baceURL = UserFeedBack_URL;
    condition.bodyData = bodyData;
    condition.urlParams = postParam;
    NSMutableDictionary * dicHead = [NSMutableDictionary dictionary];
    [dicHead setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@",kNetRequestStringBoundary] forKey:@"Content-Type"];
    condition.httpHeaderFieldParams = dicHead;
    condition.httpMethod = @"POST";
    [[NetExt sharedInstance] requestWithCondition:condition delegate:self];
    [encryptChannel release];
}
#pragma mark POI点报错的接口
/**
 *	POI点报错的接口
 *  @param  poi    poi点的具体信息
 *  @param  description 反馈问题的具体描述 不能为空
 *	@param	type	请求类型
 *	@param	delegate	回调委托
 *	@return	成功返回GD_ERR_OK, 失败返回对应出错码
 */
- (void)Net_FeedbackGetUserFromPoi:(MWPoi *)poi withDescription:(MWFeedbackFunctionCondition *)description requestType:(RequestType)type delegate:(id<NetReqToViewCtrDelegate>)delegate
{
    feedBackDelegate = delegate;
    NSMutableDictionary *postParam = [NSMutableDictionary dictionary];
    if (MapVersionNoV) {
        [postParam setObject:MapVersionNoV forKey:@"did"];//获取地图数据版本号
    }
    if (SOFT_AOS_VERSION) {
        [postParam setObject:[NSString stringWithFormat:@"%@",SOFT_AOS_VERSION] forKey:@"div"];//应用软件版本号
    }
    if (GDEngineNOVVersion) {
        [postParam setObject:GDEngineNOVVersion forKey:@"die"];//引擎版本号
    }
    if (USER_DEVICE_INFO_DIC) {
        [postParam setObject:USER_DEVICE_INFO_DIC forKey:@"dic"];//软件安装渠道编号
    }
    if (USER_DEVICE_INFO_MAC) {
        [postParam setObject:USER_DEVICE_INFO_MAC forKey:@"diu"];//设备唯一吗
    }
    if (USER_DEVICE_INFO_APPID) {//dip = appid, 产品代码 请求发起方的应用唯一标识, 可严格区分不同应用、不同平台等等
        [postParam setObject:USER_DEVICE_INFO_APPID forKey:@"dip"];
    }
    if (USER_DEVICE_INFO_CHANNEL) {//channel	授权号, 由系统统一分配
        [postParam setObject:USER_DEVICE_INFO_CHANNEL forKey:@"channel"];
    }
    if (description.questionType) {//问题类型
         [postParam setObject:[NSString stringWithFormat:@"%d",description.questionType] forKey:@"type"];
    }
    NSMutableDictionary * dicUdes = [NSMutableDictionary dictionary];
    if (description.errorDesc) {//描述 ＝ 如位置错误+用户输入描述
         NSString * string = [description.errorDesc  stringByReplacingOccurrencesOfString:@"&" withString:@""];
        string = [[self getQuestionTypeName:description.questionType] stringByAppendingString:string];
        [dicUdes setObject:string forKey:@"uDes"];
    }
    if (![NSJSONSerialization isValidJSONObject:dicUdes]) {
        return;
    }
    NSData * data = [NSJSONSerialization dataWithJSONObject:dicUdes options:NSJSONWritingPrettyPrinted error:nil];
    NSString * stringDes = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    if (stringDes) {
        [postParam setObject:stringDes forKey:@"description"];
    }
    [postParam setObject:@"json" forKey:@"output"];
    //MD5加密 USER_DEVICE_INFO_CHANNEL＋类型＋问题描述 ＋key
    NSMutableString * encryptChannel = [[NSMutableString alloc]initWithFormat:@"%@%@%@@%@",USER_DEVICE_INFO_CHANNEL,[postParam objectForKey:@"type"],stringDes,USER_DEVICE_INFO_KEY];
    
    NSString *returnString = [[encryptChannel stringFromMD5] uppercaseString];
    if (returnString) {
        [postParam setObject:returnString forKey:@"sign"];
    }
    if (UserID_Account) {//获取用户userid
        [postParam setObject:UserID_Account forKey:@"userid"];
    }
    if (deviceTokenEx) {//推送设备令牌
        [postParam setObject:deviceTokenEx forKey:@"token"];
    }
    if (description.tel) {//电话
        [postParam setObject:description.tel forKey:@"contact"];
    }
    if (poi) {
        if (poi.szName) {//名称错误
            [postParam setObject:poi.szName forKey:@"name"];
        }
        if (poi.szAddr) {//地址错误
            [postParam setObject:poi.szAddr forKey:@"address"];
        }
        if (poi.lAdminCode) {
            [postParam setObject:[NSString stringWithFormat:@"%d",poi.lAdminCode] forKey:@"adcode"];
        }
        if (poi.szTel) {//电话错误
            [postParam setObject:poi.szTel forKey:@"tel"];
        }
        [postParam setObject:[NSString stringWithFormat:@"%lf",poi.latitude/1000000.0] forKey:@"latitude"];
        [postParam setObject:[NSString stringWithFormat:@"%lf",poi.longitude/1000000.0] forKey:@"longitude"];
        
        NSString * stringPoi = [NSString string];
        NSString * stringLoc = [NSString string];
        GCARINFO carInfo = {0};
        [[MWMapOperator sharedInstance] GMD_GetCarInfo:&carInfo];
        //当前位置
        stringLoc = [NSString stringWithFormat:@"%lf,%lf|",carInfo.Coord.x/1000000.0,carInfo.Coord.y/1000000.0];
        //poi点的位置
        stringPoi = [NSString stringWithFormat:@"%@,%@",[postParam objectForKey:@"longitude"],[postParam objectForKey:@"latitude"]];
        stringLoc = [stringLoc stringByAppendingString:stringPoi];
        if (stringLoc) {
            [postParam setObject:stringLoc forKey:@"points"];
        }
    }
    NSMutableDictionary * picture = [NSMutableDictionary dictionary];
    if (description.pic) {
        [picture setObject:description.pic forKey:@"picture"];
    }
    NSData * bodyData = [[NetExt sharedInstance]postBodyData:picture];
    NetBaseRequestCondition * condition = [NetBaseRequestCondition requestCondition];
    condition.requestType = type;
    condition.baceURL = UserFeedBack_URL;
    condition.urlParams = postParam;
    condition.httpMethod = @"POST";
    NSMutableDictionary * dicHead = [NSMutableDictionary dictionary];
    [dicHead setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@",kNetRequestStringBoundary] forKey:@"Content-Type"];
    condition.bodyData  = bodyData;
    condition.httpHeaderFieldParams = dicHead;
    [[NetExt sharedInstance] requestWithCondition:condition delegate:self];
    [encryptChannel release];
    [stringDes release];
}
/*通过问题反馈的type 获取问题反馈的名称*/
-(NSString *)getQuestionTypeName:(int)questionType
{
    if (questionType) {
        NSString * stringName = nil ;
        if (questionType == 2002) {
            stringName = STR(@"TS_NoAddress", Localize_UserFeedback);
        }else if (questionType == 2000)
        {
            stringName = STR(@"TS_OtherError", Localize_UserFeedback);
        }else if (questionType == 2007)
        {
            stringName = STR(@"TS_LocationError", Localize_UserFeedback);
        }else if (questionType == 2003)
        {
            stringName = STR(@"TS_MessageError", Localize_UserFeedback);
        }else
        {
            stringName = STR(@"TS_UserFeedback", Localize_UserFeedback);
        }
        return [NSString stringWithFormat:@"%@:",stringName];
    }
    return nil;
}
//取消所有请求
- (BOOL)Net_CancelAllRequest
{
    [[NetExt sharedInstance] cancelAllRequests];
    return YES;
}
//取消某个类型的请求
- (BOOL)Net_CancelRequestWithType:(RequestType)requestType
{
    [[NetExt sharedInstance] Net_CancelRequestWithType:requestType];
    return YES;
}
#pragma mark
#pragma mark NetRequestExtDelegate
- (void)request:(NetRequestExt *)request didFinishLoadingWithData:(NSData *)data
{
    NSDictionary * result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    if (feedBackDelegate&&[feedBackDelegate respondsToSelector:@selector(requestToViewCtrWithRequestType:didFinishLoadingWithResult:)])
    {
        [feedBackDelegate requestToViewCtrWithRequestType:request.requestCondition.requestType didFinishLoadingWithResult:result];
    }
}

- (void)request:(NetRequestExt *)request didFailWithError:(NSError *)error
{
    if (feedBackDelegate && [feedBackDelegate respondsToSelector:@selector(requestToViewCtrWithRequestType:didFailWithError:)]) {
        [feedBackDelegate requestToViewCtrWithRequestType:request.requestCondition.requestType didFailWithError:error];
    }
}
-(void)dealloc
{
    CRELEASE(feedBackDelegate);
    [super dealloc];
}
@end

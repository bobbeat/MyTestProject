//
//  ZJNetAPI.m
//  SuYun
//
//  Created by yu.liao on 15/5/15.
//  Copyright (c) 2015年 yu.liao. All rights reserved.
//

#import "ZJNetAPI.h"
#import "NetRequestCondition.h"
#import "Net.h"
#import "NSObject+Category.h"
#import "NSString+Category.H"
#import <CommonCrypto/CommonDigest.h>

NSString *const ZJNetErrorDomain = @"ZJNetErrorDomain";

NSString *const ZJNetErrorParamCodeKey = @"ZJNetErrorParamCodeKey";

#define SID       @"sid"
#define UserID    @"userid"
#define UserType  @"usertype"
#define PlatForm  @"platform"




#define ZJBaseAddrURL @"http://120.25.252.71:8081"
#define RegisterURL          [NSString  stringWithFormat:@"%@%@",ZJBaseAddrURL,@"/user/info/add?"]
#define GetUserInfoURL          [NSString  stringWithFormat:@"%@%@",ZJBaseAddrURL,@"/user/info/get?"]
#define UpdateUserInfoURL          [NSString  stringWithFormat:@"%@%@",ZJBaseAddrURL,@"/user/info/update?"]
#define AddCarInfoURL          [NSString  stringWithFormat:@"%@%@",ZJBaseAddrURL,@"/car/info/add?"]
#define UpdateCarInfoURL        [NSString  stringWithFormat:@"%@%@",ZJBaseAddrURL,@"/car/info/update?"]
#define GetCarInfoURL        [NSString  stringWithFormat:@"%@%@",ZJBaseAddrURL,@"/car/info/get?"]
#define LoginURL             [NSString  stringWithFormat:@"%@%@",ZJBaseAddrURL,@"/user/info/login?"]
#define GetCityInfoURL             [NSString  stringWithFormat:@"%@%@",ZJBaseAddrURL,@"/dialog/info/get?"]
#define GetTaskResURL             [NSString  stringWithFormat:@"%@%@",ZJBaseAddrURL,@"/res/data/get?"]
#define GetTaskDetailURL             [NSString  stringWithFormat:@"%@%@",ZJBaseAddrURL,@"/task/info/get?"]
#define GetUserTaskInfoURL             [NSString  stringWithFormat:@"%@%@",ZJBaseAddrURL,@"/task/perform/get?"]
#define ApplyTaskInfoURL             [NSString  stringWithFormat:@"%@%@",ZJBaseAddrURL,@"/task/perform/apply?"]
#define UploadImageURL         [NSString  stringWithFormat:@"%@%@",ZJBaseAddrURL,@"/res/data/put?"]
#define VerifyCodeURL          [NSString  stringWithFormat:@"%@%@",ZJBaseAddrURL,@"/res/data/put?"]

#define GetUserResURL           [NSString  stringWithFormat:@"%@%@",ZJBaseAddrURL,@"/res/data/getuser?"]

#define accessKey  @"18359713441"
#define secretKey  @"aaaaaa"

@implementation ZJNetAPI

- (NSString *)getSignFunc:(NSString *)httpVerb contentMd5:(NSString *)contentMd5 contentType:(NSString *)contentType resouce:(NSString *)resouce
{
    NSMutableString *mutableStr = [NSMutableString string];
    [mutableStr appendString:httpVerb];
    [mutableStr appendString:accessKey];
    [mutableStr appendString:secretKey];
    [mutableStr appendString:contentMd5];
    [mutableStr appendString:contentType];
    [mutableStr appendString:resouce];
    
    
    NSString *strKeyMD5 = [[NSString stringWithFormat:@"%@%@",accessKey,secretKey] stringFromMD5];
    NSString *key = [strKeyMD5 substringFromIndex:3];
    NSString *sign = [NSString getShaMd5With:mutableStr key:key];
    return sign;
}

/*!
 @brief  注册
 @param  request 具体属性字段请参考 RegitsterRequest 类。
 */
- (void)registerAction:(RegitsterRequest *)request
{
    NSMutableDictionary *params =[[NSMutableDictionary alloc] init];
    [params setObject:request.tel forKey:@"tel"];
    [params setObject:request.time forKey:@"date"];
    [params setObject:request.passwd forKey:@"passwd"];
    [params setObject:request.nickname forKey:@"nickname"];
    [params setObject:request.useraddr forKey:@"useraddr"];
    NSLog(@"\r\n%s:params = %@\r\n",__func__,params);
    
    if (![NSJSONSerialization isValidJSONObject:params]) {
        return;
    }
    NSData * data=[NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:nil];
    NSString *strMd5 = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] stringFromMD5];
    NSMutableDictionary *urlParams =[[NSMutableDictionary alloc] init];
    NSString *sign = [self getSignFunc:@"PUT" contentMd5:strMd5 contentType:@"json" resouce:@"/user/info/add"];
    [urlParams setObject:sign forKey:@"sign"];
    
    NetRequestCondition *condition = [NetRequestCondition requestCondition];
    condition.baceURL = RegisterURL;
    condition.requestID = ZJNetType_Register;
    condition.bodyData = data;
    condition.httpMethod = @"POST";
    condition.requestObject = request;
    condition.urlParams = urlParams;
    [[Net sharedInstance] requestWithCondition:condition delegate:self];
}

/*!
 @brief  获取用户信息
 @param  request 具体属性字段请参考 GetUserInfoRequest 类。
 */
- (void)getUserInfoAction:(GetUserInfoRequest *)request
{
    NSMutableDictionary *params =[[NSMutableDictionary alloc] init];
    [params setObject:request.tel forKey:@"tel"];
    [params setObject:request.time forKey:@"date"];
    NSLog(@"\r\n%s:params = %@\r\n",__func__,params);
    
    if (![NSJSONSerialization isValidJSONObject:params]) {
        return;
    }
    NSData * data=[NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:nil];
    NSString *strMd5 = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] stringFromMD5];
    NSMutableDictionary *urlParams =[[NSMutableDictionary alloc] init];
    NSString *sign = [self getSignFunc:@"PUT" contentMd5:strMd5  contentType:@"json" resouce:@"/user/info/get"];
    [urlParams setObject:sign forKey:@"sign"];
    
    NetRequestCondition *condition = [NetRequestCondition requestCondition];
    condition.baceURL = GetUserInfoURL;
    condition.requestID = ZJNetType_GetUserInfo;
    condition.bodyData = data;
    condition.httpMethod = @"POST";
    condition.requestObject = request;
    condition.urlParams = urlParams;
    [[Net sharedInstance] requestWithCondition:condition delegate:self];
}

/*!
 @brief  更改用户信息
 @param  request 具体属性字段请参考 UpdateUserInfoRequest 类。
 */
- (void)updateUserInfoAction:(UpdateUserInfoRequest *)request
{
    NSDictionary *dic = [request.userInfoObject getProperties];
    NSMutableDictionary *params =[[NSMutableDictionary alloc] initWithDictionary:dic];
    [params setObject:request.time forKey:@"date"];
    
    NSLog(@"\r\n%s:params = %@\r\n",__func__,params);
    
    if (![NSJSONSerialization isValidJSONObject:params]) {
        return;
    }
    NSData * data=[NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:nil];
    NSString *strMd5 = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] stringFromMD5];
    NSMutableDictionary *urlParams =[[NSMutableDictionary alloc] init];
    NSString *sign = [self getSignFunc:@"PUT" contentMd5:strMd5  contentType:@"json" resouce:@"/user/info/update"];
    [urlParams setObject:sign forKey:@"sign"];
    
    NetRequestCondition *condition = [NetRequestCondition requestCondition];
    condition.baceURL = UpdateUserInfoURL;
    condition.requestID = ZJNetType_UpdateUserInfo;
    condition.bodyData = data;
    condition.httpMethod = @"POST";
    condition.requestObject = request;
    condition.urlParams = urlParams;
    [[Net sharedInstance] requestWithCondition:condition delegate:self];
}

/*!
 @brief  添加车辆信息
 @param  request 具体属性字段请参考 AddCarInfoRequest 类。
 */
- (void)addCarInfoAction:(AddCarInfoRequest *)request
{
    NSMutableDictionary *params =[[NSMutableDictionary alloc] init];
    [params setObject:request.carInfoObject.tel forKey:@"tel"];
    [params setObject:request.time forKey:@"date"];
    [params setObject:request.carInfoObject.car_num forKey:@"car_num"];
    [params setObject:request.carInfoObject.brand forKey:@"brand"];
    [params setObject:request.carInfoObject.model forKey:@"model"];
    [params setObject:request.carInfoObject.colour forKey:@"colour"];
    NSLog(@"\r\n%s:params = %@\r\n",__func__,params);
    
    if (![NSJSONSerialization isValidJSONObject:params]) {
        return;
    }
    NSData * data=[NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:nil];
    NSString *strMd5 = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] stringFromMD5];
    NSMutableDictionary *urlParams =[[NSMutableDictionary alloc] init];
    NSString *sign = [self getSignFunc:@"PUT" contentMd5:strMd5  contentType:@"json" resouce:@"/car/info/add"];
    [urlParams setObject:sign forKey:@"sign"];
    
    NetRequestCondition *condition = [NetRequestCondition requestCondition];
    condition.baceURL = AddCarInfoURL;
    condition.requestID = ZJNetType_AddCarInfo;
    condition.bodyData = data;
    condition.httpMethod = @"POST";
    condition.requestObject = request;
    condition.urlParams = urlParams;
    [[Net sharedInstance] requestWithCondition:condition delegate:self];
}

/*!
 @brief  添加车辆信息
 @param  request 具体属性字段请参考 UpdateCarInfoRequest 类。
 */
- (void)updateCarInfoAction:(UpdateCarInfoRequest *)request
{
    NSMutableDictionary *params =[[NSMutableDictionary alloc] init];
    [params setObject:request.carInfoObject.tel forKey:@"tel"];
    [params setObject:request.time forKey:@"date"];
    [params setObject:request.carInfoObject.car_num forKey:@"car_num"];
    [params setObject:request.carInfoObject.brand forKey:@"brand"];
    [params setObject:request.carInfoObject.model forKey:@"model"];
    [params setObject:request.carInfoObject.colour forKey:@"colour"];
    NSLog(@"\r\n%s:params = %@\r\n",__func__,params);
    
    if (![NSJSONSerialization isValidJSONObject:params]) {
        return;
    }
    NSData * data=[NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:nil];
    NSString *strMd5 = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] stringFromMD5];
    NSMutableDictionary *urlParams =[[NSMutableDictionary alloc] init];
    NSString *sign = [self getSignFunc:@"PUT" contentMd5:strMd5  contentType:@"json" resouce:@"/car/info/update"];
    [urlParams setObject:sign forKey:@"sign"];
    
    NetRequestCondition *condition = [NetRequestCondition requestCondition];
    condition.baceURL = UpdateCarInfoURL;
    condition.requestID = ZJNetType_UpdateCarInfo;
    condition.bodyData = data;
    condition.httpMethod = @"POST";
    condition.requestObject = request;
    condition.urlParams = urlParams;
    [[Net sharedInstance] requestWithCondition:condition delegate:self];
}

/*!
 @brief  获取车辆信息
 @param  request 具体属性字段请参考 GetCarInfoRequest 类。
 */
- (void)getCarInfoAction:(GetCarInfoRequest *)request
{
    NSMutableDictionary *params =[[NSMutableDictionary alloc] init];
    [params setObject:request.tel forKey:@"tel"];
    [params setObject:request.time forKey:@"date"];
    NSLog(@"\r\n%s:params = %@\r\n",__func__,params);
    
    if (![NSJSONSerialization isValidJSONObject:params]) {
        return;
    }
    NSData * data=[NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:nil];
    NSString *strMd5 = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] stringFromMD5];
    NSMutableDictionary *urlParams =[[NSMutableDictionary alloc] init];
    NSString *sign = [self getSignFunc:@"PUT" contentMd5:strMd5  contentType:@"json" resouce:@"/car/info/get"];
    [urlParams setObject:sign forKey:@"sign"];
    
    NetRequestCondition *condition = [NetRequestCondition requestCondition];
    condition.baceURL = GetCarInfoURL;
    condition.requestID = ZJNetType_GetCarInfo;
    condition.bodyData = data;
    condition.httpMethod = @"POST";
    condition.requestObject = request;
    condition.urlParams = urlParams;
    [[Net sharedInstance] requestWithCondition:condition delegate:self];
}

- (void)loginAction:(LoginRequest *)request
{
    NSMutableDictionary *params =[[NSMutableDictionary alloc] init];
    [params setObject:request.tel forKey:@"tel"];
    [params setObject:request.passwd forKey:@"passwd"];
    [params setObject:request.time forKey:@"date"];
    NSLog(@"\r\n%s:params = %@\r\n",__func__,params);
    
    if (![NSJSONSerialization isValidJSONObject:params]) {
        return;
    }
    
    NSData * data=[NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:nil];
    NSString *strMd5 = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] stringFromMD5];
    NSMutableDictionary *urlParams =[[NSMutableDictionary alloc] init];
    NSString *sign = [self getSignFunc:@"PUT" contentMd5:strMd5  contentType:@"json" resouce:@"/user/info/login"];
    [urlParams setObject:sign forKey:@"sign"];
    
    NetRequestCondition *condition = [NetRequestCondition requestCondition];
    condition.baceURL = LoginURL;
    condition.requestID = ZJNetType_Login;
    condition.bodyData = data;
    condition.httpMethod = @"POST";
    condition.urlParams = urlParams;
    [[Net sharedInstance] requestWithCondition:condition delegate:self];
}

/*!
 @brief  获取城市窗口信息
 @param  request 具体属性字段请参考 GetCityInfoRequest 类。
 */
- (void)getCityInfoAction:(GetCityInfoRequest *)request
{
    CGSize size = [[UIScreen mainScreen] bounds].size;
    CGFloat scale = [[UIScreen mainScreen] scale];
    int height = size.height*scale;
    int width = size.width*scale;
    NSString *screen_size = [NSString stringWithFormat:@"%d*%d",(int)height,(int)width];
    NSMutableDictionary *params =[[NSMutableDictionary alloc] init];
    [params setObject:request.current_city forKey:@"current_city"];
    [params setObject:request.dialog_id forKey:@"dialog_id"];
    [params setObject:screen_size forKey:@"screen_size"];
    [params setObject:request.time forKey:@"date"];
    NSLog(@"\r\n%s:params = %@\r\n",__func__,params);
    
    if (![NSJSONSerialization isValidJSONObject:params]) {
        return;
    }
    NSData * data=[NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:nil];
    NSString *strMd5 = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] stringFromMD5];
    NSMutableDictionary *urlParams =[[NSMutableDictionary alloc] init];
    NSString *sign = [self getSignFunc:@"PUT" contentMd5:strMd5  contentType:@"json" resouce:@"/car/info/get"];
    [urlParams setObject:sign forKey:@"sign"];
    
    NetRequestCondition *condition = [NetRequestCondition requestCondition];
    condition.baceURL = GetCityInfoURL;
    condition.requestID = ZJNetType_GetCityInfo;
    condition.bodyData = data;
    condition.httpMethod = @"POST";
    condition.requestObject = request;
    [[Net sharedInstance] requestWithCondition:condition delegate:self];
}

/*!
 @brief  获取图片资源
 @param  request 具体属性字段请参考 ResGetRequest 类。
 */
- (void)getTaskResAction:(GetTaskResRequest *)request
{
    NSDictionary *dic = [request getProperties];
    NSMutableDictionary *params =[[NSMutableDictionary alloc] initWithDictionary:dic];
    
    NSLog(@"\r\n%s:params = %@\r\n",__func__,params);
    
    if (![NSJSONSerialization isValidJSONObject:params]) {
        return;
    }
    NSData * data=[NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:nil];
    
    
    NetRequestCondition *condition = [NetRequestCondition requestCondition];
    condition.baceURL = GetTaskResURL;
    condition.requestID = ZJNetType_GetResInfo;
    condition.bodyData = data;
    condition.httpMethod = @"POST";
    condition.requestObject = request;
    [[Net sharedInstance] requestWithCondition:condition delegate:self];
}

/*!
 @brief  获取用户图片资源
 @param  request 具体属性字段请参考 GetUserResRequest 类。
 */
- (void)getUserResAction:(GetUserResRequest *)request
{
    NSDictionary *dic = [request getProperties];
    NSMutableDictionary *params =[[NSMutableDictionary alloc] initWithDictionary:dic];
    [params setObject:request.time forKey:@"date"];
    NSLog(@"\r\n%s:params = %@\r\n",__func__,params);
    
    if (![NSJSONSerialization isValidJSONObject:params]) {
        return;
    }
    NSData * data=[NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:nil];
    
    NSString *strMd5 = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] stringFromMD5];
    NSMutableDictionary *urlParams =[[NSMutableDictionary alloc] init];
    NSString *sign = [self getSignFunc:@"PUT" contentMd5:strMd5  contentType:@"json" resouce:@"/res/data/getuser"];
    [urlParams setObject:sign forKey:@"sign"];
    
    NetRequestCondition *condition = [NetRequestCondition requestCondition];
    condition.baceURL = GetUserResURL;
    condition.requestID = ZJNetType_GetUserResInfo;
    condition.bodyData = data;
    condition.httpMethod = @"POST";
    condition.requestObject = request;
    condition.urlParams = urlParams;
    [[Net sharedInstance] requestWithCondition:condition delegate:self];
}
/*!
 @brief  获取任务详情
 @param  request 具体属性字段请参考 GetTaskDetailRequest 类。
 */
- (void)getTaskDetailAction:(GetTaskDetailRequest *)request
{
    NSDictionary *dic = [request getProperties];
    NSMutableDictionary *params =[[NSMutableDictionary alloc] initWithDictionary:dic];
    
    NSLog(@"\r\n%s:params = %@\r\n",__func__,params);
    
    if (![NSJSONSerialization isValidJSONObject:params]) {
        return;
    }
    NSData * data=[NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:nil];
    
    NetRequestCondition *condition = [NetRequestCondition requestCondition];
    condition.baceURL = GetTaskDetailURL;
    condition.requestID = ZJNetType_GetTaskDetailInfo;
    condition.bodyData = data;
    condition.httpMethod = @"POST";
    condition.requestObject = request;
    [[Net sharedInstance] requestWithCondition:condition delegate:self];
}

/*!
 @brief  获取用户任务信息
 @param  request 具体属性字段请参考 GetUserTaskInfoRequest 类。
 */
- (void)getUserTaskInfoAction:(GetUserTaskInfoRequest *)request
{
    NSDictionary *dic = [request getProperties];
    NSMutableDictionary *params =[[NSMutableDictionary alloc] initWithDictionary:dic];
    [params setObject:request.time forKey:@"date"];
    NSLog(@"\r\n%s:params = %@\r\n",__func__,params);
    
    if (![NSJSONSerialization isValidJSONObject:params]) {
        return;
    }
    NSData * data=[NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:nil];
    NSString *strMd5 = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] stringFromMD5];
    NSMutableDictionary *urlParams =[[NSMutableDictionary alloc] init];
    NSString *sign = [self getSignFunc:@"PUT" contentMd5:strMd5  contentType:@"json" resouce:@"/task/perform/get"];
    [urlParams setObject:sign forKey:@"sign"];
    
    NetRequestCondition *condition = [NetRequestCondition requestCondition];
    condition.baceURL = GetUserTaskInfoURL;
    condition.requestID = ZJNetType_GetUserTaskInfo;
    condition.bodyData = data;
    condition.httpMethod = @"POST";
    condition.requestObject = request;
    condition.urlParams = urlParams;
    [[Net sharedInstance] requestWithCondition:condition delegate:self];
}

/*!
 @brief  申请任务接口
 @param  request 具体属性字段请参考 ApplyTaskRequest 类。
 */
- (void)applyTaskAction:(ApplyTaskRequest *)request
{
    NSDictionary *dic = [request getProperties];
    NSMutableDictionary *params =[[NSMutableDictionary alloc] initWithDictionary:dic];
    [params setObject:request.time forKey:@"date"];
    NSLog(@"\r\n%s:params = %@\r\n",__func__,params);
    
    if (![NSJSONSerialization isValidJSONObject:params]) {
        return;
    }
    NSData * data=[NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:nil];
    NSString *strMd5 = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] stringFromMD5];
    NSMutableDictionary *urlParams =[[NSMutableDictionary alloc] init];
    NSString *sign = [self getSignFunc:@"PUT" contentMd5:strMd5  contentType:@"json" resouce:@"/task/perform/apply"];
    [urlParams setObject:sign forKey:@"sign"];
    
    NetRequestCondition *condition = [NetRequestCondition requestCondition];
    condition.baceURL = ApplyTaskInfoURL;
    condition.requestID = ZJNetType_ApplyTask;
    condition.bodyData = data;
    condition.httpMethod = @"POST";
    condition.requestObject = request;
    condition.urlParams = urlParams;
    [[Net sharedInstance] requestWithCondition:condition delegate:self];
}

- (void)logout:(LogoutRequest *)request;
{
    NSMutableDictionary *params =[[NSMutableDictionary alloc] init];
    [params setObject:request.sid forKey:SID];
    [params setObject:[NSNumber numberWithInt:request.userid]  forKey:UserID];
    [params setObject:request.usertype forKey:UserType];
    [params setObject:request.platform forKey:PlatForm];
    NSLog(@"\r\n%s:params = %@\r\n",__func__,params);
    
    if (![NSJSONSerialization isValidJSONObject:params]) {
        return;
    }
    NSData * data=[NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:nil];
    
    NetRequestCondition *condition = [NetRequestCondition requestCondition];
    condition.baceURL = nil;
    condition.requestID = request.requestType;
    condition.bodyData = data;
    condition.httpMethod = @"POST";
    [[Net sharedInstance] requestWithCondition:condition delegate:self];
}

- (void)getVerifyCode:(VerifyCodeRequest *)request
{
    NSMutableDictionary *params =[[NSMutableDictionary alloc] init];
    [params setObject:request.sid forKey:SID];
    [params setObject:[NSNumber numberWithInt:request.userid] forKey:UserID];
    [params setObject:request.usertype forKey:UserType];
    [params setObject:request.platform forKey:PlatForm];
    [params setObject:request.phone forKey:@"phone"];
    NSLog(@"\r\n%s:params = %@\r\n",__func__,params);
    
    if (![NSJSONSerialization isValidJSONObject:params]) {
        return;
    }
    NSData * data=[NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:nil];
    
    NetRequestCondition *condition = [NetRequestCondition requestCondition];
    condition.baceURL = VerifyCodeURL;
    condition.requestID = request.requestType;
    condition.bodyData = data;
    condition.httpMethod = @"POST";
    [[Net sharedInstance] requestWithCondition:condition delegate:self];
}

- (void)uploadImage:(UploadImageRequest *)request
{
    UIImage *image = request.image;
    NSDictionary *dic = [request getProperties];
    NSMutableDictionary *params =[[NSMutableDictionary alloc] initWithDictionary:dic];
    NSLog(@"\r\n%s:params = %@\r\n",__func__,params);
    if (!image) {
        return;
    }
    NSData * data = UIImagePNGRepresentation(image);
    unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(data.bytes, (CC_LONG)strlen(data.bytes), outputBuffer);
    NSMutableString *md5String = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; count++){
        [md5String appendFormat:@"%02x",outputBuffer[count]];
    }
    NSMutableDictionary *urlParams =[[NSMutableDictionary alloc] init];
    NSMutableString *str = [[NSMutableString alloc] initWithString:@"/res/data/put?"];
    [str appendString:@"index="];
    [str appendString:request.index];
    if ([request.task length] != 0) {
        [str appendString:@"&task="];
        [str appendString:request.task];
    }
    else
    {
        [str appendString:@"&task="];
    }
    [str appendString:@"&date="];
    [str appendString:request.time];
    
    for (NSString *key in [params allKeys])
    {
        if ([key isEqualToString:@"image"]) {
            continue;
        }
        NSString *value = [params objectForKey:key];
        [urlParams setObject:value forKey:key];
    }
    
    NSString *sign = [self getSignFunc:@"PUT" contentMd5:md5String contentType:@"png" resouce:str];
    [urlParams setObject:sign forKey:@"sign"];
    [urlParams setObject:request.time forKey:@"date"];
    [urlParams setObject:md5String forKey:@"md5"];
    [urlParams setObject:@"png" forKey:@"type"];
    
    NetRequestCondition *condition = [NetRequestCondition requestCondition];
    condition.baceURL = UploadImageURL;
    condition.requestID = ZJNetType_UploadImage;
    condition.bodyData = data;
    condition.httpMethod = @"POST";
    condition.requestObject = request;
    condition.urlParams = urlParams;
    [[Net sharedInstance] requestWithCondition:condition delegate:self];
}

#pragma mark -  Private Methods
#define ErrorCode @"errorcode"

-(void)handleRegisterWithRequest:(NetRequest *)request responseData:(NSData *)data
{
    NSDictionary * result;
    id object = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    if ([object isKindOfClass:[NSDictionary class]])
    {
        result = object;
    }
    else if ([object isKindOfClass:[NSArray class]])
    {
        result = [object objectAtIndex:0];
    }
    long errorCode = [[result objectForKey:@"state"] longValue];
    RegitsterRequest *requestInstance = request.requestCondition.requestObject;
    if (errorCode == 0)
    {
        RegitsterResponse *response = [[RegitsterResponse alloc] init];
        
        UserInfoObject *userinfo = [[UserInfoObject alloc] init];
        [userinfo setPropertiesWirh:result];
        
        response.userInfoObject = userinfo;
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(onRegisterDone:response:)])
        {
            [self.delegate onRegisterDone:requestInstance response:response];
        }
    }
    else
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(netRequest:didFailWithError:)])
        {
            [self.delegate netRequest:requestInstance didFailWithError:[NSError errorWithDomain:ZJNetErrorDomain code:ZJNetErrorParamCode userInfo:@{NSLocalizedDescriptionKey:@"获取数据错误",ZJNetErrorParamCodeKey:[NSNumber numberWithLong:errorCode]}]];
        }
    }
    
}

-(void)handleGetUserInfoWithRequest:(NetRequest *)request responseData:(NSData *)data
{
    NSDictionary * result;
    id object = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    if ([object isKindOfClass:[NSDictionary class]])
    {
        result = object;
    }
    else if ([object isKindOfClass:[NSArray class]])
    {
        result = [object objectAtIndex:0];
    }
    long errorCode = [[result objectForKey:@"state"] longValue];
    GetUserInfoRequest *requestInstance = request.requestCondition.requestObject;
    if (errorCode == 0)
    {
        GetUserInfoResponse *response = [[GetUserInfoResponse alloc] init];
        UserInfoObject *userinfo = [[UserInfoObject alloc] init];
        [userinfo setPropertiesWirh:result];
        response.userInfoObject = userinfo;
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(onGetUserInfoDone:response:)])
        {
            [self.delegate onGetUserInfoDone:requestInstance response:response];
        }
    }
    else
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(netRequest:didFailWithError:)])
        {
            [self.delegate netRequest:requestInstance didFailWithError:[NSError errorWithDomain:ZJNetErrorDomain code:ZJNetErrorParamCode userInfo:@{NSLocalizedDescriptionKey:@"获取数据错误",ZJNetErrorParamCodeKey:[NSNumber numberWithLong:errorCode]}]];
        }
    }
    
}

-(void)handleUpdateUserInfoWithRequest:(NetRequest *)request responseData:(NSData *)data
{
    NSDictionary * result;
    id object = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    if ([object isKindOfClass:[NSDictionary class]])
    {
        result = object;
    }
    else if ([object isKindOfClass:[NSArray class]])
    {
        result = [object objectAtIndex:0];
    }
    long errorCode = [[result objectForKey:@"state"] longValue];
    UpdateUserInfoRequest *requestInstance = request.requestCondition.requestObject;
    if (errorCode == 0)
    {
        UpdateUserInfoResponse *response = [[UpdateUserInfoResponse alloc] init];
        UserInfoObject *userinfo = [[UserInfoObject alloc] init];
        [userinfo setPropertiesWirh:result];
        response.userInfoObject = userinfo;
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(onUpdateUserInfoDone:response:)])
        {
            [self.delegate onUpdateUserInfoDone:requestInstance response:response];
        }
    }
    else
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(netRequest:didFailWithError:)])
        {
            [self.delegate netRequest:requestInstance didFailWithError:[NSError errorWithDomain:ZJNetErrorDomain code:ZJNetErrorParamCode userInfo:@{NSLocalizedDescriptionKey:@"获取数据错误",ZJNetErrorParamCodeKey:[NSNumber numberWithLong:errorCode]}]];
        }
    }
    
}

-(void)handleAddCarInfoWithRequest:(NetRequest *)request responseData:(NSData *)data
{
    NSDictionary * result;
    id object = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    if ([object isKindOfClass:[NSDictionary class]])
    {
        result = object;
    }
    else if ([object isKindOfClass:[NSArray class]])
    {
        result = [object objectAtIndex:0];
    }
    long errorCode = [[result objectForKey:@"state"] longValue];
    AddCarInfoRequest *requestInstance = request.requestCondition.requestObject;
    if (errorCode == 0)
    {
        AddCarInfoResponse *response = [[AddCarInfoResponse alloc] init];
        
        UserInfoObject *carInfoObject = [[UserInfoObject alloc] init];
        [carInfoObject setPropertiesWirh:result];
        
        response.carInfoObject = carInfoObject;
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(onRegisterDone:response:)])
        {
            [self.delegate onAddCarInfoDone:requestInstance response:response];
        }
    }
    else
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(netRequest:didFailWithError:)])
        {
            [self.delegate netRequest:requestInstance didFailWithError:[NSError errorWithDomain:ZJNetErrorDomain code:ZJNetErrorParamCode userInfo:@{NSLocalizedDescriptionKey:@"获取数据错误",ZJNetErrorParamCodeKey:[NSNumber numberWithLong:errorCode]}]];
        }
    }
    
}

-(void)handleUpdateCarInfoWithRequest:(NetRequest *)request responseData:(NSData *)data
{
    NSDictionary * result;
    id object = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    if ([object isKindOfClass:[NSDictionary class]])
    {
        result = object;
    }
    else if ([object isKindOfClass:[NSArray class]])
    {
        result = [object objectAtIndex:0];
    }
    long errorCode = [[result objectForKey:@"state"] longValue];
    UpdateCarInfoRequest *requestInstance = request.requestCondition.requestObject;
    if (errorCode == 0)
    {
        UpdateCarInfoResponse *response = [[UpdateCarInfoResponse alloc] init];
        
        UserInfoObject *carInfoObject = [[UserInfoObject alloc] init];
        [carInfoObject setPropertiesWirh:result];
        
        response.carInfoObject = carInfoObject;
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(onUpdateCarInfoDone:response:)])
        {
            [self.delegate onUpdateCarInfoDone:requestInstance response:response];
        }
    }
    else
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(netRequest:didFailWithError:)])
        {
            [self.delegate netRequest:requestInstance didFailWithError:[NSError errorWithDomain:ZJNetErrorDomain code:ZJNetErrorParamCode userInfo:@{NSLocalizedDescriptionKey:@"获取数据错误",ZJNetErrorParamCodeKey:[NSNumber numberWithLong:errorCode]}]];
        }
    }
    
}

-(void)handleGetCarInfoWithRequest:(NetRequest *)request responseData:(NSData *)data
{
    NSDictionary * result;
    id object = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    if ([object isKindOfClass:[NSDictionary class]])
    {
        result = object;
    }
    else if ([object isKindOfClass:[NSArray class]])
    {
        result = [object objectAtIndex:0];
    }
    long errorCode = [[result objectForKey:@"state"] longValue];
    GetCarInfoRequest *requestInstance = request.requestCondition.requestObject;
    if (errorCode == 0)
    {
        GetCarInfoResponse *response = [[GetCarInfoResponse alloc] init];
        
        UserInfoObject *carInfoObject = [[UserInfoObject alloc] init];
        [carInfoObject setPropertiesWirh:result];
        
        response.carInfoObject = carInfoObject;
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(onGetCarInfoDone:response:)])
        {
            [self.delegate onGetCarInfoDone:requestInstance response:response];
        }
    }
    else
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(netRequest:didFailWithError:)])
        {
            [self.delegate netRequest:requestInstance didFailWithError:[NSError errorWithDomain:ZJNetErrorDomain code:ZJNetErrorParamCode userInfo:@{NSLocalizedDescriptionKey:@"获取数据错误",ZJNetErrorParamCodeKey:[NSNumber numberWithLong:errorCode]}]];
        }
    }
    
}

-(void)handleVerifyCodeWithRequest:(NetRequest *)request responseData:(NSData *)data
{
    
}

-(void)handleLoginWithRequest:(NetRequest *)request responseData:(NSData *)data
{
    NSDictionary * result;
    id object = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    if ([object isKindOfClass:[NSDictionary class]])
    {
        result = object;
    }
    else if ([object isKindOfClass:[NSArray class]])
    {
        result = [object objectAtIndex:0];
    }
    long errorCode = [[result objectForKey:@"state"] longValue];
    LoginRequest *requestInstance = request.requestCondition.requestObject;
    if (errorCode == 0)
    {
        LoginResponse *response = [[LoginResponse alloc] init];
        
        [response setPropertiesWirh:result];
        
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(onLoginDone:response:)])
        {
            [self.delegate onLoginDone:requestInstance response:response];
        }
    }
    else
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(netRequest:didFailWithError:)])
        {
            [self.delegate netRequest:requestInstance didFailWithError:[NSError errorWithDomain:ZJNetErrorDomain code:ZJNetErrorParamCode userInfo:@{NSLocalizedDescriptionKey:@"获取数据错误",ZJNetErrorParamCodeKey:[NSNumber numberWithLong:errorCode]}]];
        }
    }
    
}

-(void)handleGetCityInfoWithRequest:(NetRequest *)request responseData:(NSData *)data
{
    NSDictionary * result;
    NSArray *array = nil;
    id object = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    if ([object isKindOfClass:[NSDictionary class]])
    {
        result = object;
    }
    else if ([object isKindOfClass:[NSArray class]])
    {
        result = [object objectAtIndex:0];
        array = object;
    }
    long errorCode = [[result objectForKey:@"state"] longValue];
    GetCityInfoRequest *requestInstance = request.requestCondition.requestObject;
    if (errorCode == 0)
    {
        GetCityInfoResponse *response = [[GetCityInfoResponse alloc] init];
        
        for (int i = 0; i < [array count]; i++) {
            CityInfoObject *temp = [[CityInfoObject alloc] init];
            [temp setPropertiesWirh:[array objectAtIndex:i]];
            [response.cityInfoArray addObject:temp];
        }
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(onGetCityInfoDone:response:)])
        {
            [self.delegate onGetCityInfoDone:requestInstance response:response];
        }
    }
    else
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(netRequest:didFailWithError:)])
        {
            [self.delegate netRequest:requestInstance didFailWithError:[NSError errorWithDomain:ZJNetErrorDomain code:ZJNetErrorParamCode userInfo:@{NSLocalizedDescriptionKey:@"获取数据错误",ZJNetErrorParamCodeKey:[NSNumber numberWithLong:errorCode]}]];
        }
    }
    
}

-(void)handleGetResWithRequest:(NetRequest *)request responseData:(NSData *)data
{
    NSDictionary * result;
    NSArray *array = nil;
    id object = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    if ([object isKindOfClass:[NSDictionary class]])
    {
        result = object;
    }
    else if ([object isKindOfClass:[NSArray class]])
    {
        result = [object objectAtIndex:0];
        array = object;
    }
    
    long errorCode = [[result objectForKey:@"state"] longValue];
    GetTaskResRequest *requestInstance = request.requestCondition.requestObject;
    if (errorCode == 0)
    {
        GetTaskResResponse *response = [[GetTaskResResponse alloc] init];
        
        response.image = [UIImage imageWithData:data];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(onGetResDone:response:)])
        {
            [self.delegate onGetResDone:requestInstance response:response];
        }
    }
    else
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(netRequest:didFailWithError:)])
        {
            [self.delegate netRequest:requestInstance didFailWithError:[NSError errorWithDomain:ZJNetErrorDomain code:ZJNetErrorParamCode userInfo:@{NSLocalizedDescriptionKey:@"获取数据错误",ZJNetErrorParamCodeKey:[NSNumber numberWithLong:errorCode]}]];
        }
    }
    
}

-(void)handleGetUserResWithRequest:(NetRequest *)request responseData:(NSData *)data
{
    NSDictionary * result;
    NSArray *array = nil;
    id object = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    if ([object isKindOfClass:[NSDictionary class]])
    {
        result = object;
    }
    else if ([object isKindOfClass:[NSArray class]])
    {
        result = [object objectAtIndex:0];
        array = object;
    }
    
    long errorCode = [[result objectForKey:@"state"] longValue];
    GetUserResRequest *requestInstance = request.requestCondition.requestObject;
    if (errorCode == 0)
    {
        GetUserResResponse *response = [[GetUserResResponse alloc] init];
        
        response.image = [UIImage imageWithData:data];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(onGetUserResDone:response:)])
        {
            [self.delegate onGetUserResDone:requestInstance response:response];
        }
    }
    else
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(netRequest:didFailWithError:)])
        {
            [self.delegate netRequest:requestInstance didFailWithError:[NSError errorWithDomain:ZJNetErrorDomain code:ZJNetErrorParamCode userInfo:@{NSLocalizedDescriptionKey:@"获取数据错误",ZJNetErrorParamCodeKey:[NSNumber numberWithLong:errorCode]}]];
        }
    }
    
}


-(void)handleGetTaskDetailWithRequest:(NetRequest *)request responseData:(NSData *)data
{
    NSDictionary * result;
    NSArray *array = nil;
    id object = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    if ([object isKindOfClass:[NSDictionary class]])
    {
        result = object;
    }
    else if ([object isKindOfClass:[NSArray class]])
    {
        result = [object objectAtIndex:0];
        array = object;
    }
    long errorCode = [[result objectForKey:@"state"] longValue];
    GetTaskDetailRequest *requestInstance = request.requestCondition.requestObject;
    if (errorCode == 0)
    {
        GetTaskDetailResponse *response = [[GetTaskDetailResponse alloc] init];
        
        for (int i = 0; i < [array count]; i++) {
            CityInfoObject *temp = [[CityInfoObject alloc] init];
            [temp setPropertiesWirh:[array objectAtIndex:i]];
            [response.cityInfoArray addObject:temp];
        }
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(onGetTaskDetailDone:response:)])
        {
            [self.delegate onGetTaskDetailDone:requestInstance response:response];
        }
    }
    else
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(netRequest:didFailWithError:)])
        {
            [self.delegate netRequest:requestInstance didFailWithError:[NSError errorWithDomain:ZJNetErrorDomain code:ZJNetErrorParamCode userInfo:@{NSLocalizedDescriptionKey:@"获取数据错误",ZJNetErrorParamCodeKey:[NSNumber numberWithLong:errorCode]}]];
        }
    }
    
}

-(void)handleGetUserTaskInfoWithRequest:(NetRequest *)request responseData:(NSData *)data
{
    NSDictionary * result;
    NSArray *array = nil;
    id object = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    if ([object isKindOfClass:[NSDictionary class]])
    {
        result = object;
    }
    else if ([object isKindOfClass:[NSArray class]])
    {
        result = [object objectAtIndex:0];
        array = object;
    }
    long errorCode = [[result objectForKey:@"state"] longValue];
    GetUserTaskInfoRequest *requestInstance = request.requestCondition.requestObject;
    if (errorCode == 0)
    {
        GetUserTaskInfoResponse *response = [[GetUserTaskInfoResponse alloc] init];
        
//        for (int i = 0; i < [array count]; i++) {
//            CityInfoObject *temp = [[CityInfoObject alloc] init];
//            [temp setPropertiesWirh:[array objectAtIndex:i]];
//            [response.cityInfoArray addObject:temp];
//        }
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(onGetUserTaskInfoDone:response:)])
        {
            [self.delegate onGetUserTaskInfoDone:requestInstance response:response];
        }
    }
    else
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(netRequest:didFailWithError:)])
        {
            [self.delegate netRequest:requestInstance didFailWithError:[NSError errorWithDomain:ZJNetErrorDomain code:ZJNetErrorParamCode userInfo:@{NSLocalizedDescriptionKey:@"获取数据错误",ZJNetErrorParamCodeKey:[NSNumber numberWithLong:errorCode]}]];
        }
    }
    
}

-(void)handleApplyTaskWithRequest:(NetRequest *)request responseData:(NSData *)data
{
    NSDictionary * result;
    NSArray *array = nil;
    id object = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    if ([object isKindOfClass:[NSDictionary class]])
    {
        result = object;
    }
    else if ([object isKindOfClass:[NSArray class]])
    {
        result = [object objectAtIndex:0];
        array = object;
    }
    long errorCode = [[result objectForKey:@"state"] longValue];
    ApplyTaskRequest *requestInstance = request.requestCondition.requestObject;
    if (errorCode == 0)
    {
        ApplyTaskResponse *response = [[ApplyTaskResponse alloc] init];
        
        //        for (int i = 0; i < [array count]; i++) {
        //            CityInfoObject *temp = [[CityInfoObject alloc] init];
        //            [temp setPropertiesWirh:[array objectAtIndex:i]];
        //            [response.cityInfoArray addObject:temp];
        //        }
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(onApplyTaskDone:response:)])
        {
            [self.delegate onApplyTaskDone:requestInstance response:response];
        }
    }
    else
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(netRequest:didFailWithError:)])
        {
            [self.delegate netRequest:requestInstance didFailWithError:[NSError errorWithDomain:ZJNetErrorDomain code:ZJNetErrorParamCode userInfo:@{NSLocalizedDescriptionKey:@"获取数据错误",ZJNetErrorParamCodeKey:[NSNumber numberWithLong:errorCode]}]];
        }
    }
    
}

-(void)handleLogoutWithRequest:(NetRequest *)request responseData:(NSData *)data
{
    NSDictionary * result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    
    long errorCode = [[result objectForKey:@"state"] longValue];
    
    LogoutRequest *logoutObj = nil;
    
    if (errorCode == 0)
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(onLogoutDone:response:)])
        {
            [self.delegate onLogoutDone:logoutObj response:nil];
        }
    }
    else
    {
        [self.delegate netRequest:logoutObj didFailWithError:[NSError errorWithDomain:ZJNetErrorDomain code:ZJNetErrorParamCode userInfo:@{NSLocalizedDescriptionKey:@"获取数据错误",ZJNetErrorParamCodeKey:[NSNumber numberWithLong:errorCode]}]];
    }
    
}

-(void)handleUploadImageWithRequest:(NetRequest *)request responseData:(NSData *)data
{
    NSDictionary * result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    
    long errorCode = [[result objectForKey:@"state"] longValue];
    
    if (errorCode == 0)
    {
        UploadImageResponse *response = [[UploadImageResponse alloc] init];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(onUploadImageDone:response:)])
        {
            [self.delegate onUploadImageDone:nil response:response];
        }
    }
    else
    {
        [self.delegate netRequest:nil didFailWithError:[NSError errorWithDomain:ZJNetErrorDomain code:ZJNetErrorParamCode userInfo:@{NSLocalizedDescriptionKey:@"获取数据错误",ZJNetErrorParamCodeKey:[NSNumber numberWithLong:errorCode]}]];
    }
    
}


- (void)request:(NetRequest *)request handleResponseData:(NSData *)data
{
    switch (request.requestCondition.requestID) {
        case ZJNetType_Register:
        {
            [self handleRegisterWithRequest:request responseData:data];
        }
            break;
        case ZJNetType_GetUserInfo:
        {
            [self handleGetUserInfoWithRequest:request responseData:data];
        }
            break;
        case ZJNetType_UpdateUserInfo:
        {
            [self handleUpdateUserInfoWithRequest:request responseData:data];
        }
            break;
        case ZJNetType_AddCarInfo:
        {
            [self handleAddCarInfoWithRequest:request responseData:data];
        }
            break;
        case ZJNetType_UpdateCarInfo:
        {
            [self handleUpdateCarInfoWithRequest:request responseData:data];
        }
            break;
        case ZJNetType_GetCarInfo:
        {
            [self handleGetCarInfoWithRequest:request responseData:data];
        }
            break;
        case ZJNetType_VerifyCode:
        {
            if (self.delegate && [self.delegate respondsToSelector:@selector(onVerifyCodeDone:response:)])
            {
                [self handleVerifyCodeWithRequest:request responseData:data];
            }
        }
            break;
        case ZJNetType_Login:
        {
            [self handleLoginWithRequest:request responseData:data];
        }
            break;
        case ZJNetType_GetCityInfo:
        {
            [self handleGetCityInfoWithRequest:request responseData:data];
        }
            break;
        case ZJNetType_GetResInfo:
        {
            [self handleGetResWithRequest:request responseData:data];
        }
            break;
        case ZJNetType_GetUserResInfo:
        {
            [self handleGetUserResWithRequest:request responseData:data];
        }
            break;

        case ZJNetType_GetTaskDetailInfo:
        {
            [self handleGetTaskDetailWithRequest:request responseData:data];
        }
            break;
        case ZJNetType_GetUserTaskInfo:
        {
            [self handleGetUserTaskInfoWithRequest:request responseData:data];
        }
            break;
        case ZJNetType_ApplyTask:
        {
            [self handleApplyTaskWithRequest:request responseData:data];
        }
            break;
        case ZJNetType_Logout:
        {
            [self handleLogoutWithRequest:request responseData:data];
        }
            break;
        case ZJNetType_UploadImage:
        {
            [self handleUploadImageWithRequest:request responseData:data];
        }
            break;
        default:
            break;
    }
}

- (void)request:(NetRequest *)request failedWithError:(NSError *)error
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(netRequest:didFailWithError:)])
    {
        [self.delegate netRequest:request.requestCondition.requestObject didFailWithError:[self parseError:error]];
    }

}

- (NSError *)parseError:(NSError *) error
{
    NSError *tmpError;
    switch (error.code) {
        case NetErrorUnknown:
            tmpError = [NSError errorWithDomain:ZJNetErrorDomain code:ZJNetErrorUnknown userInfo:error.userInfo];
            break;
        case NetErrorBadURL:
            tmpError = [NSError errorWithDomain:ZJNetErrorDomain code:ZJNetErrorBadURL userInfo:error.userInfo];
            break;
        case NetErrorTimeOut:
            tmpError = [NSError errorWithDomain:ZJNetErrorDomain code:ZJNetErrorTimeOut userInfo:error.userInfo];
            break;
        case NetErrorCannotFindHost:
            tmpError = [NSError errorWithDomain:ZJNetErrorDomain code:ZJNetErrorCannotFindHost userInfo:error.userInfo];
            break;
        case NetErrorCannotConnectToHost:
            tmpError = [NSError errorWithDomain:ZJNetErrorDomain code:ZJNetErrorCannotConnectToHost userInfo:error.userInfo];
            break;
        case NetErrorNotConnectedToInternet:
            tmpError = [NSError errorWithDomain:ZJNetErrorDomain code:ZJNetErrorNotConnectedToInternet userInfo:error.userInfo];
            break;
        case NetErrorInvalidResponse:
            tmpError = [NSError errorWithDomain:ZJNetErrorDomain code:ZJNetErrorInvalidResponse userInfo:error.userInfo];
            break;
        default:
            tmpError = [NSError errorWithDomain:ZJNetErrorDomain code:ZJNetErrorUnknown userInfo:error.userInfo];
            break;
    }
    
    return tmpError;
}

#pragma mark - NetRequestDelegate

- (void)request:(id)request didFailWithError:(NSError *)error
{
    [self request:request failedWithError:error];
}


- (void)request:(NetRequest *)request didFinishLoadingWithData:(NSData *)data
{
    [self request:request handleResponseData:data];
}

@end

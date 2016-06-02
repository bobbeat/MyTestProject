//
//  GDBL_TCWeibo.m
//  AutoNavi
//
//  Created by huang longfeng on 13-4-26.
//
//

#import "GDBL_TCWeibo.h"
#import "JSONKit.h"
#import "NSObject+SBJSON.h"

#define WiressSDKDemoAppKey     @"801044496"
#define WiressSDKDemoAppSecret  @"99b567b2a6eba74f4cf3a4e46c719ad7"
#define REDIRECTURI             @"http://itunes.apple.com/cn/app/id324101974?mt=8"
#define TCWBSDKAPIDomain        @"https://open.t.qq.com/api/"

int g_sendWeibo = -1;
int g_getUserInfo = -1;

static BOOL g_tcAuthValid = NO;

@implementation GDBL_TCWeibo

static GDBL_TCWeibo * __shareTCWeibo;

@synthesize  delegate,weiboEngine;

+(GDBL_TCWeibo *) shareTCWeibo
{
    if (__shareTCWeibo == nil) {
        __shareTCWeibo = [[GDBL_TCWeibo alloc] init];
    }
    return __shareTCWeibo;
}

-(id)init
{
    if (self=[super init]) {
        WeiboApi *engine = [[WeiboApi alloc] initWithAppKey:WiressSDKDemoAppKey andSecret:WiressSDKDemoAppSecret andRedirectUri:REDIRECTURI andAuthModeFlag:0 andCachePolicy:0];
        WeiboApiObject *api_object = [engine getToken];
        if (api_object)
        {
            [engine SetToken:api_object];
        }
        self.weiboEngine = engine;
    }
    return self;
}

- (void)removeAuthData
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"TCWeiboAuthData"];
}

- (void)setController:(UIViewController *)controller
{
    
}
//登录新浪博客
-(void)logIn:(UIViewController *)ctl
{
    [self.weiboEngine loginWithDelegate:self andRootController:ctl];
}

//检测授权是否有效
- (BOOL)isAuthValid
{
    [self.weiboEngine checkAuthValid:0 andDelegete:self];
    return g_tcAuthValid;
}

-(void)logOut
{
    NSURL *deleteURL = [NSURL URLWithString:TCWBSDKAPIDomain];
    NSHTTPCookieStorage *allCookie = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *cookieArray=[allCookie cookiesForURL:deleteURL];
    //deleteURL即为请求的源地址,删除对应源地址产生的cookie
    for(id obj in cookieArray)
    {
        [allCookie deleteCookie:obj];
    }
    if ([self isAuthValid])
    {
        [weiboEngine cancelAuth];
    }
    [self removeAuthData];
}

-(void)getUserInfo
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
    [dic setObject:@"json" forKey:@"format"];
    g_getUserInfo = [weiboEngine requestWithParams:dic apiName:@"user/info" httpMethod:@"GET" delegate:self];
    [dic release];
}

//发送新潮微博
-(void)TCSendWeibo:(NSString *)weiboString
      WeiboImage:(UIImage *) weiboImage
{
    if (weiboImage==nil)
    {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
        [dic setObject:@"json" forKey:@"format"];
        if (weiboString != nil) {
            [dic setObject:weiboString forKey:@"content"];
        }
        g_sendWeibo = [weiboEngine requestWithParams:dic apiName:@"t/add" httpMethod:@"POST" delegate:self];
        [dic release];
    }
    else
    {
        // post image status
        NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:1];
        [dic setObject:@"json" forKey:@"format"];
        if (weiboString != nil) {
            [dic setObject:weiboString forKey:@"content"];
        }
        NSData *dataImage = UIImageJPEGRepresentation(weiboImage, 1.0);
        if (dataImage != nil) {
            [dic setObject:dataImage forKey:@"pic"];
        }
        g_sendWeibo = [weiboEngine requestWithParams:dic apiName:@"t/add_pic" httpMethod:@"POST" delegate:self];
        [dic release];
    }
    
    
}
#pragma mark - login callback

/**
 * @brief   授权成功后的回调
 * @param   INPUT   wbapi 成功后返回的WeiboApi对象，accesstoken,openid,refreshtoken,expires 等授权信息都在此处返回
 * @return  无返回
 */
- (void)DidAuthFinished:(WeiboApiObject *)wbobj
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(TCWeiboDidLogIn:)]) {
        [self.delegate TCWeiboDidLogIn:weiboEngine];
    }
}

/**
 * @brief   授权成功后的回调
 * @param   INPUT   wbapi   weiboapi 对象，取消授权后，授权信息会被清空
 * @return  无返回
 */
- (void)DidAuthCanceled:(WeiboApiObject *)wbobj
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(TCWeiboLogInDidCancel:)]) {
        [self.delegate TCWeiboLogInDidCancel:weiboEngine];
    }
}

/**
 * @brief   授权成功后的回调
 * @param   INPUT   error   标准出错信息
 * @return  无返回
 */
- (void)DidAuthFailWithError:(NSError *)error
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(TCWeibo:logInDidFailWithError:)]) {
        [self.delegate TCWeibo:weiboEngine logInDidFailWithError:error];
    }
}

/**
 * @brief   选择使用服务器验证token有效性（checkAuthValid）时，需实现此回调
 * @param   INPUT   bResult   检查结果，yes 为有效，no 为无效
 * @param   INPUT   strSuggestion 当bResult 为no 时，此参数为建议。
 * @return  无返回
 */
- (void)didCheckAuthValid:(BOOL)bResult suggest:(NSString*)strSuggestion
{
    g_tcAuthValid = bResult;
}


//登录成功回调
- (void)onSuccessLogin
{
   
}

//登录失败回调
- (void)onFailureLogin:(NSError *)error
{
    
}

/**
 * @brief   接口调用成功后的回调
 * @param   INPUT   data    接口返回的数据
 * @param   INPUT   request 发起请求时的请求对象，可以用来管理异步请求
 * @return  无返回
 */
- (void)didReceiveRawData:(NSData *)data reqNo:(int)reqno
{
//    NSLog(@"%@",[[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease]);
    if (reqno == g_getUserInfo)
    {
        NSError *parseError = nil;
        id result =[data objectFromJSONDataWithParseOptions:JKParseOptionStrict error:&parseError];
        
        if (parseError)
        {
            if (self.delegate && [self.delegate respondsToSelector:@selector(TCSendWeiboFailedWithError:)]) {
                [self.delegate TCSendWeiboFailedWithError:parseError];
            }
        }
        else
        {
            if (self.delegate && [self.delegate respondsToSelector:@selector(TCGetUserInfo:)]) {
                [self.delegate TCGetUserInfo:result];
            }
        }
        g_getUserInfo = -1;
    }
    else if (reqno == g_sendWeibo)
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(TCSendWeiboSucceed)]) {
            [self.delegate TCSendWeiboSucceed];
        }
        g_sendWeibo = -1;
    }
}
/**
 * @brief   接口调用失败后的回调
 * @param   INPUT   error   接口返回的错误信息
 * @param   INPUT   request 发起请求时的请求对象，可以用来管理异步请求
 * @return  无返回
 */
- (void)didFailWithError:(NSError *)error reqNo:(int)reqno
{
    if (reqno == g_getUserInfo)
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(TCGetUserInfoFailed:)]) {
            [self.delegate TCGetUserInfoFailed:error];
        }
        g_getUserInfo = -1;
    }
    else if (reqno == g_sendWeibo)
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(TCSendWeiboFailedWithError:)]) {
            [self.delegate TCSendWeiboFailedWithError:error];
        }
        g_sendWeibo = -1;
    }
}

//获取用户信息成功
- (void)getUserInfoSuccessCallBack:(id)result
{
    
}
//获取用户信息失败
- (void)getUserInfoFailureCallBack:(NSError *)error
{
    
}
//sso失败回调
//-(void)onLoginFailed:(WBErrCode)errCode msg:(NSString*)msg
//{
//    if (self.delegate && [self.delegate respondsToSelector:@selector(TCWeibo:logInDidFailWithError:)]) {
//        [self.delegate TCWeibo:weiboEngine logInDidFailWithError:nil];
//    }
//}
////sso登录成功
//-(void)onLoginSuccessed:(NSString*)name token:(WBToken*)token
//{
//    if (self.delegate && [self.delegate respondsToSelector:@selector(TCWeiboDidLogIn:)]) {
//        [self.delegate TCWeiboDidLogIn:weiboEngine];
//    }
//}
@end

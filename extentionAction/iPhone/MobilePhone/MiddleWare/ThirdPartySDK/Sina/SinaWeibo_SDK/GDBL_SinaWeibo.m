//
//  GDBL_SinaWeibo.m
//  sinaweibo_sdk
//  Add by hlf at 2013.04.25
//  Copyright (c) 2013年 SINA. All rights reserved.
//

#import "GDBL_SinaWeibo.h"

@implementation GDBL_SinaWeibo

static GDBL_SinaWeibo * __shareSNWeibo;

@synthesize  delegate,sinaweibo;

+(GDBL_SinaWeibo *) shareSinaWeibo
{
    if (__shareSNWeibo == nil) {
        __shareSNWeibo = [[GDBL_SinaWeibo alloc] init];
    }
    return __shareSNWeibo;
}

-(id)init
{
    if (self=[super init]) {
        [WeiboSDK enableDebugMode:NO];
        [WeiboSDK registerApp:kAppKey];
        
        sinaweibo = [[SinaWeibo alloc] initWithAppKey:kAppKey appSecret:kAppSecret appRedirectURI:kAppRedirectURI ssoCallbackScheme:kAppCallbackScheme andDelegate:self];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSDictionary *sinaweiboInfo = [defaults objectForKey:@"SinaWeiboAuthData"];
        if ([sinaweiboInfo objectForKey:@"AccessTokenKey"] && [sinaweiboInfo objectForKey:@"ExpirationDateKey"] && [sinaweiboInfo objectForKey:@"UserIDKey"])
        {
            sinaweibo.accessToken = [sinaweiboInfo objectForKey:@"AccessTokenKey"];
            sinaweibo.expirationDate = [sinaweiboInfo objectForKey:@"ExpirationDateKey"];
            sinaweibo.userID = [sinaweiboInfo objectForKey:@"UserIDKey"];
        }
    }
    return self;
}

- (void)removeAuthData
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"SinaWeiboAuthData"];
}

- (void)storeAuthData
{   
    NSDictionary *authData = [NSDictionary dictionaryWithObjectsAndKeys:
                              sinaweibo.accessToken, @"AccessTokenKey",
                              sinaweibo.expirationDate, @"ExpirationDateKey",
                              sinaweibo.userID, @"UserIDKey",
                              sinaweibo.refreshToken, @"refresh_token", nil];
    [[NSUserDefaults standardUserDefaults] setObject:authData forKey:@"SinaWeiboAuthData"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


//登录新浪博客
- (void)logIn:(UINavigationController *)controller
{
    
        WBAuthorizeRequest *request = [WBAuthorizeRequest request];
        request.redirectURI = kAppRedirectURI;
        request.scope = @"email,direct_messages_write";
        request.userInfo = @{@"SSO_From": @"SendMessageToWeiboViewController",
                             @"Other_Info_1": [NSNumber numberWithInt:123],
                             @"Other_Info_2": @[@"obj1", @"obj2"],
                             @"Other_Info_3": @{@"key1": @"obj1", @"key2": @"obj2"}};
        [WeiboSDK sendRequest:request];
        
}

-(void)logOut
{
    [sinaweibo logOut];
}

-(void)getUserInfo
{
    [sinaweibo requestWithURL:@"users/show.json"
                       params:[NSMutableDictionary dictionaryWithObject:sinaweibo.userID forKey:@"uid"]
                   httpMethod:@"GET"
                     delegate:self];
}

//发送新潮微博
-(void)sendWeibo:(NSString *)weiboString
      WeiboImage:(UIImage *) weiboImage
{
    if (weiboImage==nil) {
        [sinaweibo requestWithURL:@"statuses/update.json"
                           params:[NSMutableDictionary dictionaryWithObjectsAndKeys:weiboString, @"status", nil]
                       httpMethod:@"POST"
                         delegate:self];
        
    }
    else 
    {
        // post image status
        
        NSMutableDictionary * param=[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     weiboString, @"status",
                                     weiboImage, @"pic", nil];
        [sinaweibo requestWithURL:@"statuses/upload.json"
                           params:param
                       httpMethod:@"POST"
                         delegate:self];
    }
    
    
}

- (void)sinaweiboDidLogIn:(SinaWeibo *)newsinaweibo
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(sinaweiboDidLogIn:)]) {
        [self.delegate sinaweiboDidLogIn:newsinaweibo];
    }
}
- (void)sinaweiboAreadyLogIn:(SinaWeibo *)newsinaweibo
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(sinaweiboAreadyLogIn:)]) {
        [self.delegate sinaweiboAreadyLogIn:newsinaweibo];
    }
}
- (void)sinaweiboDidLogOut:(SinaWeibo *)newsinaweibo
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(sinaweiboDidLogOut:)]) {
        [self.delegate sinaweiboDidLogOut:newsinaweibo];
    }
}

- (void)sinaweiboLogInDidCancel:(SinaWeibo *)newsinaweibo
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(sinaweiboLogInDidCancel:)]) {
        [self.delegate sinaweiboLogInDidCancel:newsinaweibo];
    }
}

- (void)sinaweibo:(SinaWeibo *)newsinaweibo logInDidFailWithError:(NSError *)error
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(sinaweibo:logInDidFailWithError:)]) {
        [self.delegate sinaweibo:newsinaweibo logInDidFailWithError:error];
    }
}

- (void)sinaweibo:(SinaWeibo *)newsinaweibo accessTokenInvalidOrExpired:(NSError *)error
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(sinaweibo:accessTokenInvalidOrExpired:)]) {
        [self.delegate sinaweibo:newsinaweibo accessTokenInvalidOrExpired:error];
    }
}


#pragma mark - SinaWeiboRequest Delegate

- (void)request:(SinaWeiboRequest *)request didFailWithError:(NSError *)error
{
    if ([request.url hasSuffix:@"users/show.json"])
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(onGetUserInfoFailed:)]) {
            [self.delegate onGetUserInfoFailed:error];
        }
    }
    else if ([request.url hasSuffix:@"statuses/update.json"])
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(sendWeiboFailedWithError:)]) {
            [self.delegate sendWeiboFailedWithError:error];
        }
    }
    else if ([request.url hasSuffix:@"statuses/upload.json"])
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(sendWeiboFailedWithError:)]) {
            [self.delegate sendWeiboFailedWithError:error];
        }
    }
}

- (void)request:(SinaWeiboRequest *)request didFinishLoadingWithResult:(id)result
{
    if ([request.url hasSuffix:@"users/show.json"])
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(onGetUserInfo:)]) {
            [self.delegate onGetUserInfo:[result retain]];
        }
    }
    else if ([request.url hasSuffix:@"statuses/update.json"])
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(sendWeiboSucceed)]) {
            [self.delegate sendWeiboSucceed];
        }
    }
    else if ([request.url hasSuffix:@"statuses/upload.json"])
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(sendWeiboSucceed)]) {
            [self.delegate sendWeiboSucceed];
        }
    }
    
}

@end

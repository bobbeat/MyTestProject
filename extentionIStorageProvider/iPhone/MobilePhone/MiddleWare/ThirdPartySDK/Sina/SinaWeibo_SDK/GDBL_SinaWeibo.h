//
//  GDBL_SinaWeibo.h
//  sinaweibo_sdk
//  Add by hlf at 2013.04.25
//  Copyright (c) 2013年 SINA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SinaWeibo.h"
#import "SinaWeiboRequest.h"
#import "WeiboSDK.h"
#import <Availability.h>

#define kAppKey             @"1529070077"
#define kAppSecret          @"576a40e9e67f8b2a3d3723b89aa06b7b"
#define kAppRedirectURI     @"http://itunes.apple.com/cn/app/id324101974?mt=8"
#define kAppCallbackScheme  @"wb1529070077://"

@protocol GDBL_SinaWeiboDelegate <NSObject>
@optional

- (void)sinaweiboDidLogIn:(SinaWeibo *)sinaweibo;
- (void)sinaweiboAreadyLogIn:(SinaWeibo *)sinaweibo;
- (void)sinaweiboDidLogOut:(SinaWeibo *)sinaweibo;
- (void)sinaweiboLogInDidCancel:(SinaWeibo *)sinaweibo;
- (void)sinaweibo:(SinaWeibo *)sinaweibo logInDidFailWithError:(NSError *)error;
- (void)sinaweibo:(SinaWeibo *)sinaweibo accessTokenInvalidOrExpired:(NSError *)error;


-(void)sendWeiboSucceed;
-(void)sendWeiboFailedWithError:(NSError *) error;
-(void)onGetUserInfo:(NSDictionary *)userInfo;
-(void)onGetUserInfoFailed:(NSError *) error;
@end

@interface GDBL_SinaWeibo : NSObject<SinaWeiboDelegate, SinaWeiboRequestDelegate>
{
    SinaWeibo *sinaweibo;
}
@property(nonatomic,assign) id<GDBL_SinaWeiboDelegate> delegate;
@property(nonatomic,retain) SinaWeibo * sinaweibo;

+(GDBL_SinaWeibo *) shareSinaWeibo;
- (void)removeAuthData;
- (void)storeAuthData;

//登录新浪博客
- (void)logIn:(UINavigationController *)controller;

//退出登录
-(void)logOut;

//获取用户信息
-(void)getUserInfo;

//发送新潮微博
-(void)sendWeibo:(NSString *)weiboString
      WeiboImage:(UIImage *) weiboImage;
- (BOOL)handleOpenURL:(NSURL *)url;
@end

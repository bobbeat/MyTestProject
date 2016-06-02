//
//  GDBL_TCWeibo.h
//  AutoNavi
//
//  Created by huang longfeng on 13-4-26.
//
//

#import <Foundation/Foundation.h>
#import "WeiboApi.h"


@protocol GDBL_TCWeiboDelegate <NSObject>
@optional

- (void)TCWeiboDidLogIn:(WeiboApi *)TCweibo;
- (void)TCWeiboAreadyLogIn:(WeiboApi *)TCweibo;
- (void)TCWeiboDidLogOut:(WeiboApi *)TCweibo;
- (void)TCWeiboLogInDidCancel:(WeiboApi *)TCweibo;
- (void)TCWeibo:(WeiboApi *)TCweibo logInDidFailWithError:(NSError *)error;
- (void)TCWeibo:(WeiboApi *)TCweibo accessTokenInvalidOrExpired:(NSError *)error;


-(void)TCSendWeiboSucceed;
-(void)TCSendWeiboFailedWithError:(NSError *) error;
-(void)TCGetUserInfo:(NSDictionary *)userInfo;
-(void)TCGetUserInfoFailed:(NSError *) error;
@end

@interface GDBL_TCWeibo : NSObject <WeiboAuthDelegate>
{
    WeiboApi                  *weiboEngine;
}

@property (nonatomic, retain) WeiboApi   *weiboEngine;
@property(nonatomic,assign) id<GDBL_TCWeiboDelegate> delegate;

+(GDBL_TCWeibo *) shareTCWeibo;

- (void)removeAuthData;
- (void)storeAuthData;

- (void)setController:(UIViewController *)controller;
//登录新浪博客
-(void)logIn:(UIViewController *)ctl;

//检测授权是否有效
- (BOOL)isAuthValid;

//退出登录
-(void)logOut;

//获取用户信息
-(void)getUserInfo;

//发送新潮微博
-(void)TCSendWeibo:(NSString *)weiboString
        WeiboImage:(UIImage *) weiboImage;
@end

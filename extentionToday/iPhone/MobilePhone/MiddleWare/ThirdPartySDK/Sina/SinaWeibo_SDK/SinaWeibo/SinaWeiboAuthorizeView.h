//
//  SinaWeiboAuthorizeView.h
//  sinaweibo_ios_sdk
//
//  Created by longfeng huang on 5/2/13.
//  Copyright (c) 2012 SINA. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SinaWeiboAuthorizeViewDelegate;

@interface SinaWeiboAuthorizeView : UIViewController <UIWebViewDelegate>
{
    UIWebView *webView;
    
    id<SinaWeiboAuthorizeViewDelegate> delegate;
    
    NSString *appRedirectURI;
    NSDictionary *authParams;
    UIInterfaceOrientation         _orientation;
    BOOL  isOAuthClick;
}

@property (nonatomic, assign) id<SinaWeiboAuthorizeViewDelegate> delegate;
@property (nonatomic, readwrite) UIInterfaceOrientation orientation;

- (id)initWithAuthParams:(NSDictionary *)params
                delegate:(id<SinaWeiboAuthorizeViewDelegate>)delegate;

- (void)show;

@end

@protocol SinaWeiboAuthorizeViewDelegate <NSObject>

- (void)authorizeView:(SinaWeiboAuthorizeView *)authView
        didRecieveAuthorizationCode:(NSString *)code;
- (void)authorizeView:(SinaWeiboAuthorizeView *)authView
        didFailWithErrorInfo:(NSDictionary *)errorInfo;
- (void)authorizeViewDidCancel:(SinaWeiboAuthorizeView *)authView;

@end
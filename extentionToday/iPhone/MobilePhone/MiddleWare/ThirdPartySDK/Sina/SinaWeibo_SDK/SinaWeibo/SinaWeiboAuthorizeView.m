//
//  SinaWeiboAuthorizeView.m
//  sinaweibo_ios_sdk
//
//  Created by Wade Cheng on 4/19/12.
//  Copyright (c) 2012 SINA. All rights reserved.
//

#import "SinaWeiboAuthorizeView.h"
#import "SinaWeiboRequest.h"
#import "SinaWeibo.h"
#import "SinaWeiboConstants.h"
#import <QuartzCore/QuartzCore.h>
#import "QLoadingView.h"

@implementation SinaWeiboAuthorizeView

@synthesize delegate,orientation;

#pragma mark - Memory management
CGRect ApplicationFrame(UIInterfaceOrientation interfaceOrientation) {
	
	CGRect bounds = [[UIScreen mainScreen] applicationFrame];
	if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
		CGFloat width = bounds.size.width;
		bounds.size.width = bounds.size.height;
		bounds.size.height = width;
	}
	bounds.origin.x = 0;
	return bounds;
}
- (UIInterfaceOrientation)currentOrientation
{
    return [UIApplication sharedApplication].statusBarOrientation;
}
- (id)initWithAuthParams:(NSDictionary *)params
                delegate:(id<SinaWeiboAuthorizeViewDelegate>)_delegate
{
    if ((self = [self init]))
    {
        self.delegate = _delegate;
        authParams = [params copy];
        appRedirectURI = [[authParams objectForKey:@"redirect_uri"] retain];
        
        self.orientation = [self currentOrientation];
        CGRect frame = ApplicationFrame(self.orientation);
        frame.origin.y = 0;
        frame.size.height -= 30;
        
        // add the web view
        webView = [[UIWebView alloc] initWithFrame:frame];
        webView.opaque = NO;
		[webView setDelegate:self];
        
        NSString *sysVersion = CurrentSystemVersion;
        if ([sysVersion floatValue] < 4.0)
        {
            webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        }
		[self.view addSubview:webView];
    }
    return self;
}

- (void)viewDidLoad {
	
	[super viewDidLoad];
    
    if (fontType == 0) {
		self.title =@"新浪微博授权";
		self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc]
												  initWithTitle:@"取消"
												  style:UIBarButtonItemStylePlain
												  target:self
												  action:@selector(cancel:)]
												 autorelease];
	}
	else if (fontType == 1) {
		self.title =@"新浪微博授權";
		self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc]
												  initWithTitle:@"取消"
												  style:UIBarButtonItemStylePlain
												  target:self
												  action:@selector(cancel:)]
												 autorelease];
	}
	else if(fontType == 2)
	{
		self.title =@"Sina microblogging authorization";
		self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc]
												  initWithTitle:@"Cancel"
												  style:UIBarButtonItemStylePlain
												  target:self
												  action:@selector(cancel:)]
												 autorelease];
	}
    
    if (fontType == 0) {
        [QLoadingView showDefaultLoadingView:@"加载中..."];
    }
    else if (fontType == 1) {
        [QLoadingView showDefaultLoadingView:@"加載中..."];
    }
    else if(fontType == 2)
    {
        [QLoadingView showDefaultLoadingView:@"Loading..."];
    }
    isOAuthClick = NO;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    CGRect frame = ApplicationFrame(self.orientation);
	frame.origin.y = 0;
	frame.size.height -= 30;
	webView.frame = frame;
    
}
-(void)viewWillDisappear:(BOOL)animated
{
	[webView  stringByEvaluatingJavaScriptFromString:@"document.open();document.close()"];//每次退出前都清除uiwebview缓存，避免上次访问失败下次进来时显示的还是访问失败的页面
	[super viewWillDisappear:animated];
}
- (void) didRotateFromInterfaceOrientation: (UIInterfaceOrientation) fromInterfaceOrientation {
	self.orientation = self.interfaceOrientation;
	
	CGRect frame = ApplicationFrame(self.orientation);
	frame.origin.y = 0;
	frame.size.height -= 30;
	webView.frame = frame;
	
}
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if(toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
    {
        
    }
    else if(toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        
    }
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if(interfaceOrientation == UIDeviceOrientationUnknown)
    {
        return NO;
    }
    if (!OrientationSwitch)
    {
        return (Orientation == interfaceOrientation);
    }
    self.orientation = interfaceOrientation;
	return  YES;
    
}
- (void)dealloc
{
    webView.delegate = nil;
    [webView loadRequest: [NSURLRequest requestWithURL: [NSURL URLWithString: @""]]];
    [webView release], webView = nil;
    
    [authParams release], authParams = nil;
    [appRedirectURI release], appRedirectURI = nil;
    [super dealloc];
}

- (void) cancel: (id) sender {
	if ([webView isLoading]) {
		[webView stopLoading];
	}
    
	[self.navigationController popViewControllerAnimated:YES];
	
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	switch (alertView.tag)
	{
		case 0:
            switch(buttonIndex + 1)
		{
			case 1:
			{
				[self.navigationController popViewControllerAnimated:YES];
				
			}
			    break;
		}
            
		default:
			break;
			
	}
}
#pragma mark - WBAuthorizeWebView Public Methods

- (void)show
{
    
    NSString *authPagePath = [SinaWeiboRequest serializeURL:kSinaWeiboWebAuthURL
                                                     params:authParams httpMethod:@"GET"];
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:authPagePath]]];
}


#pragma mark - UIWebViewDelegate Methods

- (void)webViewDidStartLoad:(UIWebView *)aWebView
{
	if (isOAuthClick == NO) {
        isOAuthClick = YES;
    }
    else {
        if (fontType == 0) {
            [QLoadingView showLoadingView:@"请求中..." view:(UIWindow *)self.view];
        }
        else if (fontType == 1) {
            [QLoadingView showLoadingView:@"请求中..." view:(UIWindow *)self.view];
        }
        else if(fontType == 2)
        {
            [QLoadingView showLoadingView:@"Request..." view:(UIWindow *)self.view];
        }
        
    }
    
}

- (void)webViewDidFinishLoad:(UIWebView *)aWebView
{
	
    [QLoadingView hideWithAnimated:YES];
}

- (void)webView:(UIWebView *)aWebView didFailLoadWithError:(NSError *)error
{
    if (self.navigationController.topViewController  != self) {
        return;
    }
    [QLoadingView hideWithAnimated:YES];
    if ([[error localizedDescription] isEqualToString:@"帧框加载已中断"]) {
		return;
	}
    if ([[error localizedDescription] rangeOfString:@"NSURLErrorDomain" options:NSCaseInsensitiveSearch].location != NSNotFound ) {
		[self.navigationController popViewControllerAnimated:YES];
		return;
	}
	UIAlertView *alterview = [[UIAlertView alloc] initWithTitle:@"" message:[error localizedDescription]  delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
	alterview.tag = 0;
	[alterview show];
	[alterview release];
}

- (BOOL)webView:(UIWebView *)aWebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    
    
    NSString *url = request.URL.absoluteString;
    NSLog(@"url = %@", url);
    
    NSString *siteRedirectURI = [NSString stringWithFormat:@"%@%@", kSinaWeiboSDKOAuth2APIDomain, appRedirectURI];
    
    if ([url hasPrefix:appRedirectURI] || [url hasPrefix:siteRedirectURI])
    {
        NSString *error_code = [SinaWeiboRequest getParamValueFromUrl:url paramName:@"error_code"];
        
        if (error_code)
        {
            NSString *error = [SinaWeiboRequest getParamValueFromUrl:url paramName:@"error"];
            NSString *error_uri = [SinaWeiboRequest getParamValueFromUrl:url paramName:@"error_uri"];
            NSString *error_description = [SinaWeiboRequest getParamValueFromUrl:url paramName:@"error_description"];
            
            NSDictionary *errorInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                       error, @"error",
                                       error_uri, @"error_uri",
                                       error_code, @"error_code",
                                       error_description, @"error_description", nil];
            
            if (delegate && [delegate respondsToSelector:@selector(authorizeView:didFailWithErrorInfo:)]) {
                [delegate authorizeView:self didFailWithErrorInfo:errorInfo];
            }
        
        }
        else
        {
            NSString *code = [SinaWeiboRequest getParamValueFromUrl:url paramName:@"code"];
            if (code)
            {
                
                if (delegate && [delegate respondsToSelector:@selector(authorizeView:didRecieveAuthorizationCode:)]) {
                    [delegate authorizeView:self didRecieveAuthorizationCode:code];
                }
                if (fontType == 0) {
                    [QLoadingView showDefaultLoadingView:@"授权成功"];
                }
                else if (fontType == 1) {
                    [QLoadingView showDefaultLoadingView:@"授權成功"];
                }
                else if(fontType == 2)
                {
                    [QLoadingView showDefaultLoadingView:@"Success"];
                }
                
                [QLoadingView hideWithAnimated:YES];
                [self.navigationController popViewControllerAnimated:NO];
            
            }
        }
        
        return NO;
    }
    
    return YES;
}


@end

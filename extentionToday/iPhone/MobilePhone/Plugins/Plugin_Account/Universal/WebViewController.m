//
//  WebViewController.m
//  AutoNavi
//
//  Created by gaozhimin on 12-12-28.
//
//

#import "WebViewController.h"
#import "QLoadingView.h"
#import "Plugin_Account_Globall.h"
#import "Plugin_Account_Utility.h"
#import "GDBL_Account.h"

#define REQ_YHXY [NSString stringWithFormat:@"%@annex/iphonepage/95190/mzsm.html",kNetDomain]
#define REQ_YHXY_TW [NSString stringWithFormat:@"%@annex/iphonepage/95190/mzsm_tw.html",kNetDomain]
#define REQ_YHXY_EN [NSString stringWithFormat:@"%@annex/iphonepage/95190/mzsm_en.html",kNetDomain]

@interface WebViewController ()
{
    UIWebView *m_webView;
    NSString *m_url;
    
    BOOL bPopAlert;
}

@end

@implementation WebViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithURL:(NSString *)url
{
    if (self = [super init])
    {
        m_url = [url retain];
    }
    return self;
}

- (id)init
{
    return [self initWithURL:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    bPopAlert = NO;
	// Do any additional setup after loading the view.
    
    if ([m_url isEqualToString:REQ_YHXY_EN] || [m_url isEqualToString:REQ_YHXY_TW] || [m_url isEqualToString:REQ_YHXY])
    {
        self.title = STR(@"Account_YHXY", Localize_Account);
    }
    else
    {
        self.title = STR(@"Account_MZDM", Localize_Account);
    }
    self.navigationItem.leftBarButtonItem = [[[VCTranslucentBarButtonItem alloc] initWithType:VCTranslucentBarButtonItemTypeBackward title:@"Back" target:self action:@selector(GoBack:)] autorelease];
    
    m_webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
	m_webView.backgroundColor = GETSKINCOLOR(HUD_CLEAR_BACKGROUND_COLOR);
	[m_webView setOpaque:NO];
	m_webView.scalesPageToFit = YES;
	m_webView.autoresizesSubviews = YES;
	m_webView.clipsToBounds = YES;
	m_webView.delegate = self;
	[self.view addSubview:m_webView];
	[m_webView release];
    
    
    NSURL *url=[NSURL URLWithString:m_url];
    NSURLRequest *resquestobj=[NSURLRequest requestWithURL:url];
    [m_webView loadRequest:resquestobj];
    
    [QLoadingView showLoadingView:nil view:(UIWindow *)self.view];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [self setViewFrame:Interface_Flag];
}

- (void)dealloc
{
    [m_url release];
    [super dealloc];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark nomal method

- (void)GoBack:(id)sender
{
	[self.navigationController popViewControllerAnimated:YES];
}

-(void) setViewFrame:(int)flag
{
    m_webView.frame =  self.view.bounds;
    if (![m_webView  isLoading])
    {
        [m_webView reload];
    }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    if(toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
	{
		[self setViewFrame:1];
	}
	else if(toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
	{
		[self setViewFrame:0];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if (!OrientationSwitch)
    {
        return (Orientation == interfaceOrientation);
    }
	return  YES;
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	switch (alertView.tag)
    {
        case 1:
            [self.navigationController popViewControllerAnimated:YES];
            break;
        default:
            break;
    }
}

#pragma mark
#pragma mark UIWebView delegate
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [QLoadingView hideWithAnimated:NO];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if ([error code] == NSURLErrorTimedOut)
    {
        [[Plugin_Account_Utility shareInstance] UIAlertFormWithErrorType:NET_CON_TIMEOUT Delegate:self Tag:-1];
        [QLoadingView hideWithAnimated:NO];//动画停止
        return;
    }
	if ( [error code] != NSURLErrorCancelled)  
    {
        if (!bPopAlert)
        {
            bPopAlert = YES;
            if (ACC_GETLANGUAGE== LANGUAGE_ZH) {
                [[Plugin_Account_Utility shareInstance] UIAlertFormWithTip:ERROR_NET BtnText:CONFIRM_BTN Delegate:self Tag:1];
            } else if (ACC_GETLANGUAGE== LANGUAGE_HK) {
                [[Plugin_Account_Utility shareInstance] UIAlertFormWithTip:HK_ERROR_NET BtnText:HK_CONFIRM_BTN Delegate:self Tag:1];
            } else {
                [[Plugin_Account_Utility shareInstance] UIAlertFormWithTip:EN_ERROR_NET BtnText:EN_CONFIRM_BTN Delegate:self Tag:1];
            }
            [QLoadingView hideWithAnimated:NO];//动画停止
        }
    }
}



@end

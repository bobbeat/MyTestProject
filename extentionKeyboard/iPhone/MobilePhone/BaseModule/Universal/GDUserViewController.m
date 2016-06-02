//
//  GDUserViewController.m
//  AutoNavi
//
//  Created by gaozhimin on 13-9-15.
//
//

#import "GDUserViewController.h"
#import "QLoadingView.h"
#import "GDBL_Account.h"
#import "GDAlertView.h"
#import "MWDefine.h"
#import "POICommon.h"
#import "MainDefine.h"

#define REQ_GDUSER_AGREEMENT [NSString stringWithFormat:@"%@annex/iphonepage/user_register/service_terms.html",kNetDomain]

@interface GDUserViewController ()
{
    UINavigationBar *_navigationBar;
    UIWebView *_webView;
    UIImageView *_bottomImage;
    UIButton *_gobackButton;
    UIButton *_forwardButton;
    UIButton *_freshButton;
    BOOL _interfaceState;
}

@end

@implementation GDUserViewController

#pragma mark -
#pragma mark viewcontroller
- (id)init
{
	self = [super init];
	if (self)
	{
		
	}
	return self;
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}
- (void)viewDidUnLoad
{
	[super viewDidLoad];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
    
    [self initControl];
    self.title = STR(@"Main_Agreement",Localize_RouteOverview);
    self.navigationItem.leftBarButtonItem = LEFTBARBUTTONITEM(STR(nil,nil), @selector(GoBack:));
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationReceived:) name:MWDISMISSMODLEVIEWCONTROLLER object:nil];
}
// Called when the view is about to made visible. Default does nothing
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    
    
}
// Called when the view has been fully transitioned onto the screen. Default does nothing

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}
// Called when the view is dismissed, covered or otherwise hidden. Default does nothing

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

// Called after the view was dismissed, covered or otherwise hidden. Default does nothing
-(void)viewDidDisappear:(BOOL)animated;
{
    [super viewDidDisappear:animated];
}
//IOS 7

#pragma mark -
#pragma mark control related
//初始化控件
-(void) initControl{
    
    NSString *tmpTitle;
    tmpTitle = STR(@"Main_Agreement", Localize_Main);
    _navigationBar=[POICommon allocNavigationBar:nil];
    
    UINavigationItem *navigationitem = [POICommon allocNavigationItem:tmpTitle rightTitle:nil];
    
    UIBarButtonItem *item=LEFTBARBUTTONITEM(@"", @selector(GoBack:));;
    [navigationitem setLeftBarButtonItem:item];
    [_navigationBar pushNavigationItem:navigationitem animated:NO];
    [self.view addSubview:_navigationBar];
    
    
    _webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
	_webView.backgroundColor = GETSKINCOLOR(MAIN_LABEL_CLEARBACK_COLOR);
	[_webView setOpaque:NO];
	_webView.scalesPageToFit = YES;
	_webView.autoresizesSubviews = YES;
	_webView.clipsToBounds = YES;
	_webView.delegate = self;
	[self.view addSubview:_webView];
	[_webView release];
    
    
    NSURL *url=[NSURL URLWithString:REQ_GDUSER_AGREEMENT];
    NSURLRequest *resquestobj=[NSURLRequest requestWithURL:url];
    [_webView loadRequest:resquestobj];
    [QLoadingView showDefaultLoadingView:STR(@"Universal_loading", Localize_Universal)];
    
    _bottomImage = [[UIImageView alloc] init];
    _bottomImage.image = [IMAGE(@"web_bottom_bg.png", IMAGEPATH_TYPE_1) stretchableImageWithLeftCapWidth:IMAGE(@"web_bottom_bg.png", IMAGEPATH_TYPE_1).size.width/2 topCapHeight:IMAGE(@"web_bottom_bg.png", IMAGEPATH_TYPE_1).size.height/2];
    _bottomImage.userInteractionEnabled = YES;
    [self.view addSubview:_bottomImage];
    [_bottomImage release];
    
    
    _gobackButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_gobackButton setImage:IMAGE(@"goback1.png", IMAGEPATH_TYPE_1) forState:UIControlStateNormal];
    [_gobackButton setImage:IMAGE(@"goback2.png", IMAGEPATH_TYPE_1) forState:UIControlStateHighlighted];
    [_gobackButton setImage:IMAGE(@"goback3.png", IMAGEPATH_TYPE_1) forState:UIControlStateDisabled];
    [_gobackButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    _gobackButton.tag = 1;
    [_bottomImage addSubview:_gobackButton];
    
    _forwardButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_forwardButton setImage:IMAGE(@"goforward1.png", IMAGEPATH_TYPE_1) forState:UIControlStateNormal];
    [_forwardButton setImage:IMAGE(@"goforward2.png", IMAGEPATH_TYPE_1) forState:UIControlStateHighlighted];
    [_forwardButton setImage:IMAGE(@"goforward3.png", IMAGEPATH_TYPE_1) forState:UIControlStateDisabled];
    [_forwardButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    _forwardButton.tag = 2;
    [_bottomImage addSubview:_forwardButton];
    
    _freshButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_freshButton setImage:IMAGE(@"fresh1.png", IMAGEPATH_TYPE_1) forState:UIControlStateNormal];
    [_freshButton setImage:IMAGE(@"fresh2.png", IMAGEPATH_TYPE_1) forState:UIControlStateHighlighted];
    [_freshButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    _freshButton.tag = 3;
    [_bottomImage addSubview:_freshButton];
    
}

//调整控件竖屏坐标和图片
-(void)changePortraitControlFrameWithImage
{
    CGSize size = {MAIN_POR_WIDTH,MAIN_POR_HEIGHT};
    
    [_navigationBar setFrame:CGRectMake(0.0, 0.0, APPWIDTH, 44.0 + DIFFENT_STATUS_HEIGHT)];
    UIImageView *tmp = (UIImageView *)[_navigationBar viewWithTag:1];
    [tmp setFrame:CGRectMake(0.0, 0.0, APPWIDTH, 44.0 + DIFFENT_STATUS_HEIGHT)];
    [tmp setImage:IMAGE(@"navigatorBarBg.png",IMAGEPATH_TYPE_1)];
    
    int buttonWidth = 80;
    int buttonHeight = 45;
    if (isPad)
    {
        buttonWidth = 160;
        buttonHeight = 70;
    }
    _bottomImage.frame = CGRectMake(0, size.height - buttonHeight, size.width, buttonHeight);
    _gobackButton.frame = CGRectMake(0, 0, buttonWidth, buttonHeight);
    _forwardButton.frame = CGRectMake(buttonWidth, 0, buttonWidth, buttonHeight);
    _freshButton.frame = CGRectMake(size.width - buttonWidth, 0, buttonWidth, buttonHeight);
    [self setButtonStatus];
    
    _webView.frame = CGRectMake(0, _navigationBar.bounds.size.height, size.width, size.height - _navigationBar.bounds.size.height - buttonHeight);
}

//调整控件横屏坐标和图片
-(void)changeLandscapeControlFrameWithImage
{
    CGSize size =  {MAIN_LAND_WIDTH,MAIN_LAND_HEIGHT};
    
    [_navigationBar setFrame:CGRectMake(0.0, 0.0, size.width, isPad?(44.0 + DIFFENT_STATUS_HEIGHT):(30.0+ DIFFENT_STATUS_HEIGHT))];
    UIImageView *tmp = (UIImageView *)[_navigationBar viewWithTag:1];
    [tmp setFrame:CGRectMake(0.0, 0.0, size.width,isPad?(44.0 + DIFFENT_STATUS_HEIGHT):(30.0+ DIFFENT_STATUS_HEIGHT))];
    [tmp setImage:IMAGE(@"navigatorBarBg.png",IMAGEPATH_TYPE_1)];
    
    _webView.frame = CGRectMake(0, _navigationBar.bounds.size.height, size.width, size.height - _navigationBar.bounds.size.height);
    [self setButtonStatus];
}

//改变控件文本
-(void)changeControlText
{
    
}

#pragma mark -
#pragma mark control action

- (void)buttonAction:(UIButton *)button
{
    switch (button.tag)
    {
        case 1:
        {
            [_webView goBack];
            break;
        }
        case 2:
        {
            [_webView goForward];
            break;
        }
        case 3:
        {
            [_webView reload];
            break;
        }
            
        default:
            break;
    }
}

- (void)GoBack:(id)sender
{
    [QLoadingView hideWithAnimated:NO];
	[self dismissModalViewControllerAnimated:YES];
}
#pragma mark -
#pragma mark logic relate
-	(void)landscapeLogic
{
    
    
}
-	(void)portraitLogic
{
    
    
}

- (void)setButtonStatus
{
    if (_webView.canGoBack)
    {
        _gobackButton.enabled = YES;
    }
    else
    {
        _gobackButton.enabled = NO;
    }
    
    if (_webView.canGoForward)
    {
        _forwardButton.enabled = YES;
    }
    else
    {
        _forwardButton.enabled = NO;
    }
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return  UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (interfaceOrientation == UIDeviceOrientationPortrait)
    {
        return YES;
    }
	return  NO;
}

#pragma mark -
#pragma mark notification
-(void)notificationReceived:(NSNotification*) notification
{
    if ([[notification name] isEqualToString:MWDISMISSMODLEVIEWCONTROLLER])
    {
        [self dismissModalViewControllerAnimated:NO];
    }
}

#pragma mark -
#pragma mark UIWebView delegate
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self setButtonStatus];
    [QLoadingView hideWithAnimated:NO];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self setButtonStatus];
    if ([error code] == NSURLErrorTimedOut)
    {
        __block GDUserViewController *weakself = self;
        GDAlertView *alertView = [[GDAlertView alloc] initWithTitle:nil andMessage:STR(@"Universal_networkTimeout", Localize_Universal)];
        [alertView addButtonWithTitle:STR(@"Universal_ok", Localize_Universal) type:GDAlertViewButtonTypeDefault handler:^(GDAlertView *alertView)
         {
             [weakself dismissModalViewControllerAnimated:YES];
         }];
        [alertView show];
        [alertView release];
    }
    
	if ([error code] != NSURLErrorCancelled)
    {
        __block GDUserViewController *weakself = self;
        GDAlertView *alertView = [[GDAlertView alloc] initWithTitle:nil andMessage:STR(@"Universal_networkError", Localize_Universal)];
        [alertView addButtonWithTitle:STR(@"Universal_ok", Localize_Universal) type:GDAlertViewButtonTypeDefault handler:^(GDAlertView *alertView)
         {
             [weakself dismissModalViewControllerAnimated:YES];
         }];
        [alertView show];
        [alertView release];
    }
    [QLoadingView hideWithAnimated:NO];//动画停止
    
}



@end

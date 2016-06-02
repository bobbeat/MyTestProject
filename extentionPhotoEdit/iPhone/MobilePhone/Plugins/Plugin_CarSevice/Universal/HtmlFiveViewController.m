//
//  htmlFiveViewController.m
//  AutoNavi
//
//  Created by jiangshu-fu on 14-3-11.
//
//

#import "HtmlFiveViewController.h"
#import "CarServiceJavascriptBridge.h"
#import "CarServiceVarDefine.h"

@interface HtmlFiveViewController ()
{
    UIWebView *_webView;
    CarServiceJavascriptBridge *_carserviceJavascriptBridege;
    BOOL _isReqister;
    //导航条
    UINavigationBar *_navigationBar;
    
    UIImageView *_bottomImage;
    UIButton *_freshButton;
    UIButton *_gobackButton;
    UIButton *_forwardButton;
    
    BOOL _isRequestComplete;
}
@end

@implementation HtmlFiveViewController

@synthesize isBrowser = _isBrowser;
@synthesize viewTitle = _viewTitle;
@synthesize webUrl = _webUrl;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id) initWithWebUrl:(NSString *)webUrl withTitle:(NSString *)viewTitle withBrowser:(BOOL) isBrowser
{
    self = [super init];
    if(self)
    {
        self.webUrl = webUrl;
        NSLog(@"HTML5_URL = %@",webUrl);
        self.viewTitle = viewTitle;
        self.isBrowser = isBrowser;
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    
    _webView = [[UIWebView alloc]init];
    [self loadRequest:self.webUrl  isLocation:NO];

    [self.view addSubview:_webView];
    [_webView release];
    //JavaScript bridge 数据处理
    _carserviceJavascriptBridege = [[CarServiceJavascriptBridge alloc] initWithWebview:_webView
                                                                   withwebViewDelegate:self];
   
    [self webViewInit];
    
    _isRequestComplete = YES;

    //刷新~前进~后退
    _bottomImage = [[UIImageView alloc] init];
    _bottomImage.image = [IMAGE(@"web_bottom_bg.png", IMAGEPATH_TYPE_1) stretchableImageWithLeftCapWidth:IMAGE(@"web_bottom_bg.png", IMAGEPATH_TYPE_1).size.width/2 topCapHeight:IMAGE(@"web_bottom_bg.png", IMAGEPATH_TYPE_1).size.height/2];
    _bottomImage.userInteractionEnabled = YES;
    [self.view addSubview:_bottomImage];
    [_bottomImage release];
    _bottomImage.hidden = !self.isBrowser;
    
    
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
    [self showLoadingViewInView:@"" view:self.view];
    
    //导航条
    _navigationBar = nil;
    [self initNavigation:_viewTitle];
    
    if([[ANDataSource sharedInstance] isNetConnecting] == NO)
    {
        GDAlertView *alertView=[[GDAlertView alloc] initWithTitle:nil andMessage:STR(@"Account_NetError",Localize_Account)];
        [alertView addButtonWithTitle:STR(@"POI_OK", Localize_POI) type:GDAlertViewButtonTypeDefault handler:^(GDAlertView *alertView){
            NSLog(@"木有网络~你看不到。");
        }];
        [alertView show];
        [alertView release];
    }
    
}

- (void) initNavigation:(NSString *)title
{
    if(_navigationBar)
    {
        [_navigationBar popNavigationItemAnimated:NO];
        [_navigationBar removeFromSuperview];
    }
    _navigationBar = [POICommon allocNavigationBar:title];
    
    UINavigationItem *navigationitem = [[UINavigationItem alloc] init];
    UIBarButtonItem *item=LEFTBARBUTTONITEM(@"", @selector(leftBtnEvent:));
    
    [navigationitem setLeftBarButtonItem:item];
    [_navigationBar pushNavigationItem:navigationitem animated:NO];
    [self.view addSubview:_navigationBar];
    [navigationitem release];
}

- (void)buttonAction:(UIButton *)button
{
    if(_isRequestComplete == NO)
    {
        return ;
    }
    switch (button.tag)
    {
        case 1:
        {
            [_webView goBack];
            NSLog(@".................goBack");
            break;
        }
        case 2:
        {
            [_webView goForward];
            NSLog(@".................goForward");
            break;
        }
        case 3:
        {
            [_webView reload];
            NSLog(@".................reload");
            break;
        }
            
        default:
            break;
    }
    _isRequestComplete = NO;
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
    _freshButton.enabled = YES;
}

- (void) loadRequest:(NSString *)urlString isLocation:(BOOL)isLocation
{
    
    
    
    NSLog(@"____________%@",urlString);
    NSURL *url = nil;
    if(isLocation)
    {
        url = [[NSURL alloc]initFileURLWithPath:urlString];
    }
    else
    {
        if(urlString)
        {
            url = [NSURL URLWithString:urlString];
        }
        else
        {
            url = [[NSURL alloc]init];
        }
    }
//    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:60.0f];
    [_webView loadRequest:request];
    if(isLocation)
    {
        [url release];
        url = nil;
    }
    else
    {
        if(!urlString)
        {
            [url release];
            url = nil;
        }
    }
}


- (void) dealloc
{
    if(_carserviceJavascriptBridege)
    {
        [_carserviceJavascriptBridege release];
        _carserviceJavascriptBridege = nil;
    }
    CRELEASE(_webUrl);
    CRELEASE(_viewTitle);
    [super dealloc];
}


#pragma mark-  ---  按钮响应事件  ---
- (void)leftBtnEvent:(id)sender
{
    if(_isReqister)
    {
        [_webView stringByEvaluatingJavaScriptFromString:@"navAPI.btnBack()"];
    }
    else
    {
        [self closeViewController];
    }
}

- (void) setRegister:(BOOL)isRegister
{
    _isReqister = isRegister;
}

- (void) updateTitle:(NSString *)title
{
    [self initNavigation:title];
}

#pragma mark- ---  网页响应事件  ---
- (void) webViewInit
{
    //注册事件
    __block HtmlFiveViewController *blockSelf = self;
    
    _carserviceJavascriptBridege.webRegister = ^(){
        [blockSelf setRegister:YES];
    };
    
    //关闭webView
    _carserviceJavascriptBridege.webCloseView = ^(){
        [blockSelf dismissModalViewControllerAnimated:YES];
    };
    //打开URL
    
    _carserviceJavascriptBridege.webOpenUrl = ^(NSString *url, BOOL isOpenUrlLocal, BOOL isBrowse,NSString *webTitle){
        if(isOpenUrlLocal)
        {
            HtmlFiveViewController *webViewController = [[HtmlFiveViewController alloc] initWithWebUrl:url
                                                                                             withTitle:webTitle
                                                                                           withBrowser:isBrowse];
            [blockSelf presentModalViewController:webViewController animated:YES];
            [webViewController release];
        }
        else
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        }
    };

    
    
//
    //更新标题
    _carserviceJavascriptBridege.webUpdateTitle = ^(NSString *titleString){
        [blockSelf updateTitle:titleString];
    };
//
//    //重载页面
    _carserviceJavascriptBridege.webReload = ^(){
        [blockSelf loadRequest:blockSelf.webUrl isLocation:NO];
    };
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/***
 * @name    关闭浏览器，当前界面
 * @param
 * @author  by bazinga
 ***/
- (void) closeViewController
{
     [self dismissModalViewControllerAnimated:YES];
}


- (void) changePortraitControlFrameWithImage
{
    int buttonWidth = 80;
    int buttonHeight = 45;
    if (isPad)
    {
        buttonWidth = 160;
        buttonHeight = 90;
    }
    
    float isBrowser = self.isBrowser ? buttonHeight : 0;

    float screenHeight = SCREENHEIGHT - (((float)NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) ? 0 : 20);
    float screenWidth = SCREENWIDTH ;
     CGFloat navigationHeight = _navigationBar.frame.size.height;
    
    _webView.frame = CGRectMake(0, navigationHeight, screenWidth, screenHeight - navigationHeight - isBrowser);
    
    
    CGSize size = _webView.bounds.size;
    
    
    _bottomImage.frame = CGRectMake(0, screenHeight - buttonHeight, size.width, buttonHeight);
    _gobackButton.frame = CGRectMake(0, 0, buttonWidth, buttonHeight);
    _forwardButton.frame = CGRectMake(buttonWidth, 0, buttonWidth, buttonHeight);
    _freshButton.frame = CGRectMake(size.width - buttonWidth, 0, buttonWidth, buttonHeight);
    [self setButtonStatus];
}

static bool isRequestSuccess = YES;
-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    isRequestSuccess = YES;
    _isRequestComplete = YES;
    [self hideLoadingViewWithAnimated:YES];
    [self setButtonStatus];
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    _isRequestComplete = YES;
    if([error code] == NSURLErrorCancelled || [error code] == 102)
    {
        _freshButton.enabled = YES;
        return;
    }

    if(isRequestSuccess)
    {
        NSLog(@"...............didFailLoadWithError && isRequestSuccess %@   %@" ,webView.request.URL,webView.request.URL.host);
        NSString *errorPath=[[NSBundle mainBundle] pathForResource:@"web_plugin_error_page" ofType:@"html"];
        NSString *htmlString = [[NSString alloc]initWithContentsOfFile:errorPath encoding:NSUTF8StringEncoding error:nil];
        NSString *path = [[NSBundle mainBundle] bundlePath];
        NSURL *baseURL = [NSURL fileURLWithPath:path];
        [webView loadHTMLString:htmlString baseURL:baseURL];
        
        isRequestSuccess = NO;
        
        self.webUrl = [NSString  stringWithFormat:@"%@", [webView.request.URL absoluteString]];
    }
    [self hideLoadingViewWithAnimated:YES];
    _isReqister = NO;
    [self setButtonStatus];
    _freshButton.enabled = NO;
    NSLog(@"...............didFailLoadWithError");
}

#pragma mark -  ---  横竖屏设置  ---
- (BOOL)shouldAutorotate {
    return NO;
}
- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIDeviceOrientationPortrait);
}

@end

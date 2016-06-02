//
//  SettingSinaWeiboViewController.m
//  AutoNavi
//
//  Created by huang on 13-8-13.
//
//

#import "SettingSinaWeiboViewController.h"
#import "QLoadingView.h"
@interface SettingSinaWeiboViewController ()
{
    UIImageView *_bottomImage;
    UIButton *_freshButton;
    UIButton *_gobackButton;
    UIButton *_forwardButton;
    UINavigationBar *_navigationBar;
}
@end

@implementation SettingSinaWeiboViewController
@synthesize webUrl;
#pragma mark -
#pragma mark viewcontroller ,
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
    self.webUrl=nil;
    [GDAlertView shouldAutorotate:YES];
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

#pragma mark -
#pragma mark control related
//初始化控件
-(void) initControl{
  
    [GDAlertView shouldAutorotate:NO];
    [self showLoadingViewInView:STR(@"Universal_loading", Localize_Universal) view:self.view];
    self.navigationItem.leftBarButtonItem=LEFTBARBUTTONITEM(@"", @selector(leftBtnEvent:));
    _webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    _webView.delegate = self;
    _webView.backgroundColor = [UIColor clearColor];
    _webView.opaque = NO;
    NSURL *url =[NSURL URLWithString:webUrl];
    NSURLRequest *request =[NSURLRequest requestWithURL:url];
    [_webView loadRequest:request];
    [_webView setScalesPageToFit:YES];
    [self.view addSubview:_webView];
    [_webView release];
    
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


//调整控件竖屏坐标和图片
-(void)changePortraitControlFrameWithImage
{

    CGSize size = self.view.bounds.size;
    int buttonWidth = 80;
    int buttonHeight = 45;
    if (isPad)
    {
        buttonWidth = 160;
        buttonHeight = 90;
    }
    _bottomImage.frame = CGRectMake(0, CCOMMON_CONTENT_HEIGHT - buttonHeight, size.width, buttonHeight);
    _gobackButton.frame = CGRectMake(0, 0, buttonWidth, buttonHeight);
    _forwardButton.frame = CGRectMake(buttonWidth, 0, buttonWidth, buttonHeight);
    _freshButton.frame = CGRectMake(size.width - buttonWidth, 0, buttonWidth, buttonHeight);
    _webView.frame = CGRectMake(0.0f, 0, size.width, CCOMMON_CONTENT_HEIGHT- buttonHeight+3);
    [self setButtonStatus];
}

//调整控件横屏坐标和图片
-(void)changeLandscapeControlFrameWithImage
{
//    [_webView setFrame:CGRectMake(0.0f, 0.0f, APPHEIGHT, CONTENTHEIGHT_H)];
//    CGSize size = self.view.bounds.size;
//    int buttonWidth = 80;
//    int buttonHeight = 45;
//    if (isPad)
//    {
//        buttonWidth = 160;
//        buttonHeight = 90;
//    }
//    _bottomImage.frame = CGRectMake(0, size.height - buttonHeight, size.width, buttonHeight);
//    _gobackButton.frame = CGRectMake(0, 0, buttonWidth, buttonHeight);
//    _forwardButton.frame = CGRectMake(buttonWidth, 0, buttonWidth, buttonHeight);
//    _freshButton.frame = CGRectMake(size.width - buttonWidth, 0, buttonWidth, buttonHeight);
//    [_webView setFrame:CGRectMake(0.0f, 0.0f, size.width, size.height-buttonHeight)];
// 
//    [self setButtonStatus];

}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [_webView reload];
}

//改变控件文本
-(void)changeControlText
{
    self.navigationItem.leftBarButtonItem =LEFTBARBUTTONITEM(STR(@"Setting_Back",Localize_Setting), @selector(leftBtnEvent:));
//    self.title=STR(@"Setting_SinaWeibo",Localize_Setting);
}

-(void)leftBtnEvent:(id)object
{
    [QLoadingView hideWithAnimated:NO];
    [self dismissModalViewControllerAnimated:YES];
}
- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return  UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIDeviceOrientationPortrait);
    
}


#pragma mark -
#pragma mark UIWebViewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self hideLoadingViewWithAnimated:YES];
    [self setButtonStatus];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self hideLoadingViewWithAnimated:YES];
    [self setButtonStatus];
    if (error.code==NSURLErrorCancelled) {
        return;
    }
    GDAlertView *alertView=[[GDAlertView alloc] initWithTitle:nil andMessage:STR(@"Account_NetError",Localize_Account)];
    [alertView addButtonWithTitle:STR(@"POI_OK", Localize_POI) type:GDAlertViewButtonTypeDefault handler:^(GDAlertView *alertView){
        [self leftBtnEvent:nil];
    }];
    [alertView show];
    [alertView release];
    
}
@end

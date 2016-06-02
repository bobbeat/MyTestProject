//
//  SettingNewVersionIntroduceViewController.m
//  AutoNavi
//
//  Created by huang on 13-8-13.
//
//

#import "SettingNewVersionIntroduceViewController.h"
#import "MyScrollView.h"
#import "MWDialectDownloadManage.h"
#import "POIDefine.h"
#import "ANParamValue.h"
#import "MainDefine.h"

#define  INTRODUCE_IMAGE_NAME @"image"
#define  IMAGE_COUNT 2

@interface SettingNewVersionIntroduceViewController ()
{
    id _target;
    SEL _selector;
}

@end

@implementation SettingNewVersionIntroduceViewController

#pragma mark -
#pragma mark viewcontroller ,
- (id)initWithTarget:(id)target selector:(SEL)sel
{
    self = [super init];
    if (self)
    {
        _target = target;
        _selector = sel;
        
        NSMutableArray *names = [[NSMutableArray alloc] init];
        for (int i = 0; i < IMAGE_COUNT; i++)
        {
            [names addObject:[NSString stringWithFormat:@"%@%d.jpg",INTRODUCE_IMAGE_NAME,i]];
        }
        for (int i = 0; i < IMAGE_COUNT; i++)
        {
            [names addObject:[NSString stringWithFormat:@"%@%d_h.jpg",INTRODUCE_IMAGE_NAME,i]];
        }
        _scrollView = [[MyScrollView alloc] initWithFrame:CGRectMake(0,0,MAIN_POR_WIDTH, MAIN_POR_HEIGHT) names:names hasHScreen:YES];
        [self.view addSubview:_scrollView];
        [_scrollView release];
        [names release];

    }
    return self;
}

- (id)init
{
    return [self initWithTarget:nil selector:nil];
}


- (void)dealloc
{
    [ANParamValue sharedInstance].isWarningView = NO;
    [ANParamValue sharedInstance].beFirstNewFun = 0;
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
    if (Interface_Flag == 0)
    {
        [self changePortraitControlFrameWithImage];
    }
    else if(Interface_Flag == 1)
    {
        [self changeLandscapeControlFrameWithImage];
    }
}
// Called when the view is dismissed, covered or otherwise hidden. Default does nothing

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
      [ANParamValue sharedInstance].beFirstNewFun = 0;
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationReceived:) name:NOTIFY_popScrollView object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationReceived:) name:NOTIFY_HideNavigation object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationReceived:) name:NOTIFY_ShowNavigation object:nil];

	    self.navigationController.navigationBarHidden=YES;
    //判断是否第一次使用
    if ([[ANParamValue sharedInstance] new_fun_flag] == 1)
    {
        NSString *tmpTitle;
        tmpTitle=STR(@"Setting_NewFeatures", Localize_Setting);
        _navigationBar = [POICommon allocNavigationBar:tmpTitle];
       
        
        UINavigationItem *navigationitem = [[UINavigationItem alloc] init];
        UIBarButtonItem *item=LEFTBARBUTTONITEM(@"", @selector(leftBtnEvent:));;
        [navigationitem setLeftBarButtonItem:item];
        [_navigationBar pushNavigationItem:navigationitem animated:NO];
        [self.view addSubview:_navigationBar];
        [navigationitem release];
	}
   
}
-(void)speechEvent:(id)sender
{
    if ([sender isKindOfClass:[UITapGestureRecognizer class]]) {
         if ([sender numberOfTapsRequired] != 1)
         {
             return;
         }
    }
    
    
    [self goBack];
    
}
-(void)leftBtnEvent:(id)object
{
   [self.navigationController popViewControllerAnimated:YES];
    if ([_target respondsToSelector:_selector])
    {
        [_target performSelector:_selector];
    }
}
-(void)goBack:(id)sender
{
    if ([sender isKindOfClass:[UITapGestureRecognizer class]]) {
        if ([sender numberOfTapsRequired] != 1)
        {
            return;
        }
    }
    [self goBack];
}
-(void)goBack
{
	[[MWPreference sharedInstance] setValue:PREF_NEWFUNINTRODUCE Value:1];
    [self.navigationController popViewControllerAnimated:NO];
    if ([_target respondsToSelector:_selector])
    {
        [_target performSelector:_selector];
    }
}
-(void)hideNavigation
{
    _navigationBar.hidden = YES;
}
-(void)showNavigation
{
    _navigationBar.hidden = NO;
}
-(void)changeLandscapeControlFrameWithImage
{
    [self changePortraitControlFrameWithImage];
    _scrollView.center = self.view.center;
    CGAffineTransform at =CGAffineTransformMakeRotation(M_PI / 2 );
    [_scrollView setTransform:at];
}
-(void)changePortraitControlFrameWithImage
{
    CGAffineTransform at =CGAffineTransformMakeRotation(0);
    [_scrollView setTransform:at];
	[_scrollView setHV:0 newFrame:CGRectMake(0,0,MAIN_POR_WIDTH ,MAIN_POR_HEIGHT)];
    
    UIButton *speechButton=[UIButton buttonWithType:UIButtonTypeCustom];
    speechButton.frame =CGRectMake(APPWIDTH*(IMAGE_COUNT-1), 336, 300, 44);
    [speechButton setTintColor:[UIColor blackColor]];
    [speechButton setTitle:@"马上启用林志玲语音播报" forState:UIControlStateNormal];
    [speechButton.titleLabel setFont:[UIFont systemFontOfSize:20]];
    [speechButton setBackgroundImage:[IMAGE(@"SettingGreenBtn1.png", IMAGEPATH_TYPE_1) stretchableImageWithLeftCapWidth:30 topCapHeight:5] forState:UIControlStateNormal];
    [speechButton setBackgroundImage:[IMAGE(@"SettingGreenBtn2.png", IMAGEPATH_TYPE_1) stretchableImageWithLeftCapWidth:30 topCapHeight:5] forState:UIControlStateHighlighted];
    [speechButton addTarget:self action:@selector(speechEvent:) forControlEvents:UIControlEventTouchUpInside];
    [_scrollView addSubview:speechButton];
    speechButton.hidden = YES;
    
    UIButton* button1=[UIButton buttonWithType:UIButtonTypeCustom];
    button1.frame =CGRectMake(APPWIDTH*(IMAGE_COUNT-1), 300, 300, 44);
    [button1.titleLabel setFont:[UIFont systemFontOfSize:20]];
    [button1 setTitle:@"跳过,进入导航" forState:UIControlStateNormal];
    [button1 setTitleColor:RGBCOLOR(250, 216, 216) forState:UIControlStateNormal];
    [button1 setTitleColor:RGBCOLOR(250, 216, 216) forState:UIControlStateHighlighted];
    [button1 setBackgroundImage:[IMAGE(@"SettingRedBtn1.png", IMAGEPATH_TYPE_1) stretchableImageWithLeftCapWidth:5 topCapHeight:5] forState:UIControlStateNormal];
    [button1 setBackgroundImage:[IMAGE(@"SettingRedBtn2.png", IMAGEPATH_TYPE_1) stretchableImageWithLeftCapWidth:5 topCapHeight:5] forState:UIControlStateHighlighted];
    [button1 addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
    [_scrollView addSubview:button1];
    button1.hidden = YES;
    if (isPad) {
        int y=APPHEIGHT-175;
        speechButton.center=CGPointMake(APPWIDTH*(IMAGE_COUNT-1)+APPWIDTH/2, y-69);
        button1.center=CGPointMake(APPWIDTH*(IMAGE_COUNT-1)+APPWIDTH/2, y);
    }
    else
    {
        if (iPhone5) {
            speechButton.center=CGPointMake(APPWIDTH*(IMAGE_COUNT-1)+APPWIDTH/2, 405);
            button1.center=CGPointMake(APPWIDTH*(IMAGE_COUNT-1)+APPWIDTH/2, 475);
        }
        else{
            speechButton.center=CGPointMake(APPWIDTH*(IMAGE_COUNT-1)+APPWIDTH/2, 304);
            button1.center=CGPointMake(APPWIDTH*(IMAGE_COUNT-1)+APPWIDTH/2, 373);
        }
        
    }
    
	if ([[ANParamValue sharedInstance] new_fun_flag] == 1)
    {
        [_navigationBar setFrame:CGRectMake(0.0, 0.0, APPWIDTH, 44.0)];
        UIImageView *tmp = (UIImageView *)[_navigationBar viewWithTag:1];
        [tmp setFrame:CGRectMake(0.0, 0.0, APPWIDTH, 44.0)];
        [tmp setImage:IMAGE(@"navigatorBarBg.png",IMAGEPATH_TYPE_1)];
        
        speechButton.enabled = NO;
        button1.enabled = NO;
    }
    else
    {
        
        speechButton.enabled = YES;
        button1.enabled = YES;
        
        if ((NSFoundationVersionNumber <NSFoundationVersionNumber_iOS_6_0)) {
            UITapGestureRecognizer *singleFingerOne = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(speechEvent:)] autorelease];
            singleFingerOne.numberOfTouchesRequired = 1;
            //手指数
            singleFingerOne.numberOfTapsRequired = 1; //tap次数
            [speechButton addGestureRecognizer:singleFingerOne];
            
            UITapGestureRecognizer *singleFingerOne2 = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goBack:)] autorelease];
            singleFingerOne2.numberOfTouchesRequired = 1;
            //手指数
            singleFingerOne2.numberOfTapsRequired = 1; //tap次数
            [button1 addGestureRecognizer:singleFingerOne2];
        }
        
    }

}



#pragma mark -
#pragma mark notification
-(void)notificationReceived:(NSNotification*) notification
{
 
    if ([notification.name isEqualToString:NOTIFY_HideNavigation]) {
        [self hideNavigation];
    }
    else if([notification.name isEqualToString:NOTIFY_ShowNavigation])
    {
        [self showNavigation];
    }
    else if([notification.name isEqualToString:NOTIFY_popScrollView])
    {
        [self goBack];
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
    return (interfaceOrientation == UIDeviceOrientationPortrait);

}

#pragma mark -
#pragma mark xxx delegate

@end

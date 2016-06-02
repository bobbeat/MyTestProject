//
//  WarningViewController.m
//  AutoNavi
//
//  Created by gaozhimin on 13-9-15.
//
//

#import "WarningViewController.h"
#import "WarningLable.h"
#import "GDUserViewController.h"
#import "MainDefine.h"
#import "MWDefine.h"


typedef enum ButtonType {
    Button_Accept = 1,
    Button_Tip = 2
}ButtonType;

@interface WarningViewController ()<warningLableDelegate>
{
    UIButton *_agreeButton;
    UIButton *_tipButton;
    
    UILabel *_titleLable;
    UIImageView *_topImageView;
    UIImageView *_bottomImageView;
    WarningLable *_contentLable;
    UIScrollView *_contentScrollView;
    UILabel *_tipLable;
    id _target;
    SEL _selector;
}

@end

@implementation WarningViewController

#pragma mark -
#pragma mark viewcontroller

- (id)initWithTarget:(id)target selector:(SEL)sel 
{
    self = [super init];
	if (self)
	{
		_target = target;
        _selector = sel;
	}
	return self;
}

- (id)init
{
	return [self initWithTarget:nil selector:nil];
}


- (void)dealloc
{
//    [ANParamValue sharedInstance].bSupportAutorate = YES;
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
    [self.navigationController.navigationBar setHidden:YES];
    [self initControl];
//    [ANParamValue sharedInstance].bSupportAutorate = NO;
    [ANParamValue sharedInstance].isWarningView  = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationReceived:) name:MWDISMISSMODLEVIEWCONTROLLER object:nil];
    
}
// Called when the view is about to made visible. Default does nothing
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    if (IOS_7) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    }
    
    
}
// Called when the view has been fully transitioned onto the screen. Default does nothing

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}
// Called when the view is dismissed, covered or otherwise hidden. Default does nothing

-(void)viewWillDisappear:(BOOL)animated
{
    if (IOS_7) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }
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
-(void) initControl
{
    int titleFont = 20;
    int contentFont = 13;

    int acceptFont = 14;
    
    if (isPad)
    {
        titleFont = 30;
        contentFont = 21;
        acceptFont = 24;
    }
    CGSize size = self.view.bounds.size;
    
    
    _bottomImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width,100)];
    _bottomImageView.image = [IMAGE(@"warning_bottom.png", IMAGEPATH_TYPE_1) stretchableImageWithLeftCapWidth:2 topCapHeight:10];
    [self.view addSubview:_bottomImageView];
    [_bottomImageView release];
    
    _agreeButton = [self createButtonWithTitle:STR(@"Main_Accept", Localize_Main) normalImage:@"CommonBtn1.png" heightedImage:@"CommonBtn2.png" tag:Button_Accept strechParamX:8 strechParamY:16];
    _agreeButton.titleLabel.font = [UIFont systemFontOfSize:acceptFont];
    [_agreeButton setTitleColor:GETSKINCOLOR(ACCOUNT_BUTTON_TITLE_COLOR) forState:UIControlStateNormal];
    [self.view addSubview:_agreeButton];
    
    _tipButton = [self createButtonWithTitle:nil normalImage:@"warning_prompt1.png" heightedImage:nil tag:Button_Tip strechParamX:8 strechParamY:16];
    [_tipButton setBackgroundImage:IMAGE(@"warning_prompt2.png", IMAGEPATH_TYPE_1)  forState:UIControlStateSelected];
    [self.view addSubview:_tipButton];
    
    
    _titleLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, size.width, 50)];
    _titleLable.textColor = GETSKINCOLOR(WARNING_TITLE_COLOR);
    _titleLable.font = [UIFont boldSystemFontOfSize:titleFont];
    _titleLable.backgroundColor = GETSKINCOLOR(HUD_LABEL_CLEAR_BACK_COLOR);
    _titleLable.textAlignment = NSTextAlignmentCenter;
    _titleLable.text = STR(@"Main_Warning", Localize_Main);
    [self.view addSubview:_titleLable];
    [_titleLable release];
    
    _tipLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, size.width, 50)];
    _tipLable.textColor = GETSKINCOLOR(WARNING_TIP_COLOR);
    _tipLable.font = [UIFont systemFontOfSize:contentFont];
    _tipLable.backgroundColor =  GETSKINCOLOR(HUD_LABEL_CLEAR_BACK_COLOR);
    _tipLable.textAlignment = NSTextAlignmentLeft;
    _tipLable.text = STR(@"Main_NoTip", Localize_Main);
    [self.view addSubview:_tipLable];
    [_tipLable release];
    
    
    _contentScrollView = [[UIScrollView alloc] init];
    _contentScrollView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_contentScrollView];
    
    
    _contentLable = [[WarningLable alloc] initWithFrame:CGRectMake(0, 0, size.width, 50) clickContent:STR(@"Main_Agreement", Localize_Main) delegate:self];
    _contentLable.textColor = TEXTCOLOR;
    _contentLable.font = [UIFont systemFontOfSize:contentFont];
    _contentLable.backgroundColor =  GETSKINCOLOR(HUD_LABEL_CLEAR_BACK_COLOR);
    _contentLable.textAlignment = NSTextAlignmentLeft;
    _contentLable.numberOfLines = 14;
    _contentLable.text = STR(@"Main_WarningContent", Localize_Main);
    [_contentScrollView addSubview:_contentLable];
    [_contentLable release];
    
    _topImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width - 50, 1)];
    _topImageView.backgroundColor = GETSKINCOLOR(WARNING_TITLE_COLOR);
    _topImageView.image = [IMAGE(@"warning_line.png", IMAGEPATH_TYPE_1) stretchableImageWithLeftCapWidth:0 topCapHeight:0];
    [self.view addSubview:_topImageView];
    [_topImageView release];
    
    
    
//    _agreementButton = [[Plugin_ColorTitleButton alloc] init];
//    [_agreementButton addTarget:self action:@selector(btn_agreement_click)forControlEvents:UIControlEventTouchUpInside];
//    _agreementButton.titleLabel.font = [UIFont boldSystemFontOfSize:contentFont];
//    [_agreementButton setTitleColor:TITLECOLOR forState:(UIControlState)UIControlStateNormal];
//    [_agreementButton setTitle:STR(@"Main_Agreement", Localize_Main) forState:UIControlStateNormal];
//    [self.view  addSubview:_agreementButton];
//    [_agreementButton release];
    
   
}

//调整控件竖屏坐标和图片
-(void)changePortraitControlFrameWithImage
{
    CGSize size = {MAIN_POR_WIDTH,MAIN_POR_HEIGHT};
    if (isPad)
    {
        [_agreeButton setFrame:CGRectMake(0, 0, 700, 70)];
        [_agreeButton setCenter:CGPointMake(size.width/2, size.height - 45)];
        [_tipButton setFrame:CGRectMake(0, 0, 42, 42)];
        
        
        _titleLable.center = CGPointMake(size.width/2, 70 + DIFFENT_STATUS_HEIGHT);
        _topImageView.frame = CGRectMake(100, 120+ DIFFENT_STATUS_HEIGHT, size.width - 200, 1);
        _bottomImageView.frame = CGRectMake(0, size.height - 95, size.width, 95);

        _tipLable.frame = CGRectMake(155, 780+ DIFFENT_STATUS_HEIGHT, 600, 80);
        
        [_tipButton setCenter:CGPointMake(126, 820 + DIFFENT_STATUS_HEIGHT)];
        float divHeight = 45.0f;
       
        [_tipButton setCenter:CGPointMake(126,
                                          _bottomImageView.frame.origin.y
                                          - divHeight
                                          - _tipButton.frame.size.height / 2)];
        
        [_tipLable setCenter:CGPointMake(_tipButton.frame.origin.x
                                         + _tipButton.frame.size.width
                                         + _tipLable.frame.size.width / 2
                                         + 10.0f,
                                         _bottomImageView.frame.origin.y
                                         - divHeight
                                         - _tipButton.frame.size.height / 2)];
        
        //设置宽度，不然 label 的高度获取会出现错误
        _contentLable.frame = CGRectMake(0, 0 ,size.width - 200, size.height);
        float labelHeight = [_contentLable boundingHeightForWidth] + 20;
        
        _contentLable.frame = CGRectMake(0, 0, size.width - 200, labelHeight);
        _contentScrollView.frame = CGRectMake(100, 150+ DIFFENT_STATUS_HEIGHT, size.width - 200, 665);
        _contentScrollView.contentSize = CGSizeMake(size.width - 200, labelHeight);
    }
    else
    {
        [_agreeButton setFrame:CGRectMake(0, 0, size.width - 20, 46)];
        [_agreeButton setCenter:CGPointMake(size.width/2, size.height - 30 )];
        [_tipButton setFrame:CGRectMake(0, 0, 26, 26)];
       
        
        _titleLable.center = CGPointMake(size.width/2, 25 + DIFFENT_STATUS_HEIGHT);
        _topImageView.frame = CGRectMake(25, 45 + DIFFENT_STATUS_HEIGHT , size.width - 50, 1);
        _bottomImageView.frame = CGRectMake(0, size.height - 65 , size.width, 65);
        
               _tipLable.frame = CGRectMake(0, 0, 300, 40);
        [_tipLable setCenter:CGPointMake(55 + 150.0f,
                                        _bottomImageView.frame.origin.y
                                         - 6
                                         - _tipButton.frame.size.height / 2)];
        [_tipButton setCenter:CGPointMake(35,
                                          _bottomImageView.frame.origin.y
                                          - 6
                                          - _tipButton.frame.size.height / 2)];
        
        //设置宽度，不然 label 的高度获取会出现错误
        _contentLable.frame = CGRectMake(0, 0 ,size.width - 40, size.height);
        float labelHeight = [_contentLable boundingHeightForWidth] + 20;
        _contentLable.frame = CGRectMake(0, 0,size.width - 40, labelHeight);
        _contentScrollView.frame = CGRectMake(20, 55 + DIFFENT_STATUS_HEIGHT,size.width - 40, 305 + iPhoneOffset);
        _contentScrollView.contentSize = CGSizeMake(size.width - 40, labelHeight);

    }
}

//调整控件横屏坐标和图片
-(void)changeLandscapeControlFrameWithImage
{
    CGSize size = {MAIN_LAND_WIDTH,MAIN_LAND_HEIGHT};
    if (isPad)
    {
        [_agreeButton setFrame:CGRectMake(0, 0, size.width - 70, 70)];
        [_agreeButton setCenter:CGPointMake(size.width/2, size.height - 45)];
        [_tipButton setFrame:CGRectMake(0, 0, 42, 42)];
        
        
        _titleLable.center = CGPointMake(size.width/2, 70 + DIFFENT_STATUS_HEIGHT);
        _topImageView.frame = CGRectMake(100, 120+ DIFFENT_STATUS_HEIGHT, size.width - 200, 1);
        _bottomImageView.frame = CGRectMake(0, size.height - 95, size.width, 95);
        
        _tipLable.frame = CGRectMake(155, 780+ DIFFENT_STATUS_HEIGHT, 600, 80);
        
        float divHeight = 35.0f;
        
        [_tipButton setCenter:CGPointMake(126,
                                          _bottomImageView.frame.origin.y - divHeight - _tipButton.frame.size.height / 2)];
        
        [_tipLable setCenter:CGPointMake(_tipButton.frame.origin.x  + _tipButton.frame.size.width + _tipLable.frame.size.width / 2 + 10.0f,
                                         _bottomImageView.frame.origin.y - divHeight - _tipButton.frame.size.height / 2)];
        
        //设置宽度，不然 label 的高度获取会出现错误
        _contentLable.frame = CGRectMake(0, 0 ,size.width - 40, size.height);
        float labelHeight = [_contentLable boundingHeightForWidth] + 20;
        _contentLable.frame = CGRectMake(0,
                                         0,
                                         size.width - 200,
                                         labelHeight);
        _contentScrollView.frame = CGRectMake(100,
                                              _topImageView.frame.origin.y + 30.0f,
                                              size.width - 200,
                                              _tipButton.frame.origin.y - _topImageView.frame.origin.y - 40);
        
        _contentScrollView.contentSize = CGSizeMake(size.width - 200,
                                                    labelHeight);
        
    }
    else
    {
        [_agreeButton setFrame:CGRectMake(0, 0, size.width - 20, 46)];
        [_agreeButton setCenter:CGPointMake(size.width/2, size.height - 30 )];
        [_tipButton setFrame:CGRectMake(0, 0, 26, 26)];
        
        
        _titleLable.center = CGPointMake(size.width/2, 25 + DIFFENT_STATUS_HEIGHT);
        _topImageView.frame = CGRectMake(25, 45 + DIFFENT_STATUS_HEIGHT , size.width - 50, 1);
        _bottomImageView.frame = CGRectMake(0, size.height - 65 , size.width, 65);
        

        _tipLable.frame = CGRectMake(0, 0, 300, 40);
        [_tipLable setCenter:CGPointMake(55 + 150.0f,
                                         _bottomImageView.frame.origin.y
                                         - 11
                                         - _tipButton.frame.size.height / 2)];
        [_tipButton setCenter:CGPointMake(35,
                                          _bottomImageView.frame.origin.y
                                          - 11
                                          - _tipButton.frame.size.height / 2)];
        
        //设置宽度，不然 label 的高度获取会出现错误
        _contentLable.frame = CGRectMake(0, 0 ,size.width - 40, size.height);
        float labelHeight = [_contentLable boundingHeightForWidth] + 10;
        _contentLable.frame = CGRectMake(0, 0 ,size.width - 40, labelHeight);
        _contentScrollView.frame = CGRectMake(20,
                                              55 + DIFFENT_STATUS_HEIGHT,
                                              size.width - 40,
                                              _tipButton.frame.origin.y - _topImageView.frame.origin.y - 15);
        _contentScrollView.contentSize = CGSizeMake(size.width - 40, labelHeight);
    }
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
        case Button_Accept:
        {
            if ([_target respondsToSelector:_selector])
            {
                [_target performSelector:_selector];
            }
            [self.navigationController popViewControllerAnimated:NO];
            break;
        }
            
        case Button_Tip:
        {
            button.selected = !button.selected;
            [[MWPreference sharedInstance] setValue:PREF_STARTUPWARNING Value:!button.selected];
            break;
        }
        default:
            break;
    }
}

#pragma mark -
#pragma mark logic relate
-	(void)landscapeLogic
{
    
    
}
-	(void)portraitLogic
{
    
    
}

//- (BOOL)shouldAutorotat÷

#pragma mark -
#pragma mark notification
-(void)notificationReceived:(NSNotification*) notification
{
    if ([[notification name] isEqualToString:MWDISMISSMODLEVIEWCONTROLLER])
    {
        [self.navigationController popViewControllerAnimated:NO];
    }
}

#pragma mark -
#pragma mark warningLableDelegate delegate

- (void)clickContentSuccessWith:(WarningLable *)label
{
    NSLog(@"clickContentSuccessWith");
    GDUserViewController *ctl = [[GDUserViewController alloc] init];
    [self.navigationController presentModalViewController:ctl animated:YES];
    [ctl release];
}

@end

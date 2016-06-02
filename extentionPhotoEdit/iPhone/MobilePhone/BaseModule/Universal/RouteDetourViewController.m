//
//  RouteDetourViewController.m
//  AutoNavi
//
//  Created by jiangshu.fu on 13-8-22.
//
//

#import "RouteDetourViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "CustomBtn.h"
#import "CustomRealTimeTraffic.h"
#import "MWMapOperator.h"
#import "ColorLable.h"
#import "MainDefine.h"

@interface RouteDetourViewController ()

@end

@implementation RouteDetourViewController

enum {
    BUTTON_DETOUR_ENLARGEMAP = 36,
    BUTTON_DETOUR_NARROWMAP ,
    BUTTON_DETOUR_BEFORE_DETOUR,
    BUTTON_DETOUR_AFTER_DETOUR,
    BUTTON_DETOUR_RECOVER,
    BUTTON_DETOUR_FAIL_DETOUR,
};

@synthesize  isDlgFromRoadList = _isDlgFromRoadList; //0 从trafficInfomapVc进入，需要避让道路；1 从路线详情进入，已经避让
@synthesize isSuccessDetour = _isSuccessDetour;     //是否避让成功
@synthesize stringTrafficInfo = _stringTrafficInfo;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id) initWithHandle:(GHGUIDEROUTE *)handle
{
    self = [super init];
    if(self)
    {
        _guideRouteHandle = handle;
        //顶部
        _imageViewNaviTopBG = [[UIImageView alloc]init];
        _imageViewNaviTopBG.backgroundColor = GETSKINCOLOR(ROUTE_BLACK_TOP_BAR_COLOR);
        [self.view addSubview:_imageViewNaviTopBG];
        _imageViewNaviTopBG.userInteractionEnabled = YES;
        _imageViewNaviTopBG.hidden = YES;
//        _buttonTrafficEvent = [[UIImageView alloc]init];
//        [_imageViewNaviTopBG addSubview:_buttonTrafficEvent];
//        [_buttonTrafficEvent release];
        
        
        _colorLabel = [[ColorLable alloc]initWithFrame:CGRectMake(100.0f, 0, APPWIDTH - 130.0f, 59.0f) ColorArray:[NSArray arrayWithObject:GETSKINCOLOR(ROUTE_DETOUR_CUSTOMER_COLOR)]];
        _colorLabel.backgroundColor = GETSKINCOLOR(HUD_LABEL_CLEAR_BACK_COLOR);
        [_imageViewNaviTopBG addSubview: _colorLabel];
        [_colorLabel release];
        [_imageViewNaviTopBG release];
    }
    return  self;
}

#pragma mark -
#pragma mark viewcontroller ,

- (void)dealloc
{
    if ([ANParamValue sharedInstance].isMove)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_GOTOCPP object:nil];
    }
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    //
    if (_detourRoadInfo) {
        free(_detourRoadInfo);
        _detourRoadInfo = NULL;
    }

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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationReceived:) name:NOTIFY_SHOWMAP object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationReceived:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationReceived:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationReceived:) name:NOTIFY_UPDATE_VIEWINFO object:nil];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleUIUpdate:) name:NOTIFY_HandleUIUpdate object:nil];
   [self initControl];
    
    

}
// Called when the view is about to made visible. Default does nothing
//显示时设置地图
- (void)viewWillAppear:(BOOL)animated
{
    _MapViewType = GMAP_VIEW_TYPE_MULTI_DIFF;
     _mapView  = [MapViewManager ShowMapViewInController:self]; //要放在调用 [super viewWillAppear:animated] 之前，切换多次地图后，会造成无法放大缩小
    [[MWPreference sharedInstance] setValue:PREF_MAP_TMC_SHOW_OPTION Value:YES]; //避让界面都显示路径TMC,根据路径判断是否显示事件
	[super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
//    [[MWPreference sharedInstance] setValue:PREF_SHOW_MAP_GRAY_BKGND Value:YES];
    
    [_mapView setRecognizeSwitchOn:EVENT_NONE];
    _buttonAfterDetour.hidden = NO;
    _buttonBeforDetour.hidden = NO;
    _buttonFailDetour.hidden = YES;
    
    [self setRouteInfoToButton];
    
    
    if (Interface_Flag == 1)
	{
		[self changeLandscapeControlFrameWithImage];
		
	}
	else if(Interface_Flag == 0)
	{
		[self changePortraitControlFrameWithImage];
	}
    [[MWMapOperator sharedInstance] MW_SaveInfoForCurrrentMapView];
//    _buttonRecover.hidden = YES;
}
// Called when the view has been fully transitioned onto the screen. Default does nothing

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _mapView.delegate = self;
}
// Called when the view is dismissed, covered or otherwise hidden. Default does nothing
// 显示时设置地图
// 消失时重新设置地图显示区域大小
-(void)viewWillDisappear:(BOOL)animated
{
     _mapView.delegate = nil;
    [super viewWillDisappear:animated];
    GHGUIDEROUTE guideDetour[4] = {0};
    int nRealCount = 0;
    GSTATUS nStatus = [MWRouteGuide GetGuideRouteList:guideDetour count:4 returnCount:&nRealCount];
    if (nRealCount > 1)  //微享进入后，未选择避让道路，自动选择避让前，防止崩溃
    {
        _forbidSwapBuffer = YES;
        //
        // 1停止导航
        nStatus =[MWRouteGuide StopGuide:Gfalse];
        for (int i=0; i<nRealCount; i++) {
            if (guideDetour[i]!=NULL && guideDetour[i]!=_guideRouteHandle) {
                nStatus = [MWRouteGuide  StartGuide:guideDetour[i]];
                break;
            }
        }
        [MWRouteDetour ClearDetourRoad];//清空规避道路
        [self RecoverTheOriginalDetourRoadInfo];//恢复规避道路
        [[MWMapOperator sharedInstance] MW_GoToCCP];
    }
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
    // 地图设置
    _mapView  = [MapViewManager ShowMapViewInController:self];
    _mapView.clipsToBounds = YES;
    
    [_mapView setRecognizeSwitchOn:EVENT_NONE];

    //放大缩小
    _buttonEnlargeMap = [self createButtonWithTitle:nil normalImage:@"mainEnlargeMap.png" heightedImage:@"mainEnlargeMapPress.png" tag:BUTTON_DETOUR_ENLARGEMAP withImageType:IMAGEPATH_TYPE_2];
    UILongPressGestureRecognizer *longPress =[[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(ZoomInLongPressed:)]autorelease];
	longPress.minimumPressDuration =0.2;
	[_buttonEnlargeMap addGestureRecognizer:longPress];
	[_buttonEnlargeMap addTarget:self action:@selector(incFun:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_buttonEnlargeMap];
    
    _buttonNarrowMap = [self createButtonWithTitle:nil normalImage:@"mainNarrow.png" heightedImage:@"mainNarrowPress.png" tag:BUTTON_DETOUR_NARROWMAP withImageType:IMAGEPATH_TYPE_2];
    longPress =[[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(ZoomOutLongPressed:)]autorelease];
	longPress.minimumPressDuration =0.2;
	[_buttonNarrowMap addGestureRecognizer:longPress];
	[_buttonNarrowMap addTarget:self action:@selector(decFun:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_buttonNarrowMap];

    
    
    //底部
    _imageViewNaviBottomBG = [[UIImageView alloc]init];
    _imageViewNaviBottomBG.backgroundColor = GETSKINCOLOR(ROUTE_BLACK_BAR_COLOR);
    [self.view addSubview:_imageViewNaviBottomBG];
    _imageViewNaviBottomBG.userInteractionEnabled = YES;
    
    UIImage *beforeImage = IMAGE(@"Main_buttonDetourBefore.png", IMAGEPATH_TYPE_1);
    UIImage *beforePressImage = IMAGE(@"Main_buttonDetourBeforePress.png", IMAGEPATH_TYPE_1);
    UIColor *textColor = GETSKINCOLOR(@"MainDetourTextColor");
    //按钮避让前
    _buttonBeforDetour = [UIButton buttonWithType:UIButtonTypeCustom];
    _buttonBeforDetour.tag = BUTTON_DETOUR_BEFORE_DETOUR;
    [_buttonBeforDetour addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_buttonBeforDetour setBackgroundImage:[beforeImage stretchableImageWithLeftCapWidth:beforeImage.size.width / 2
                                                                            topCapHeight:beforeImage.size.height /2]
                                  forState:UIControlStateNormal];
    [_buttonBeforDetour setBackgroundImage:[beforePressImage stretchableImageWithLeftCapWidth:beforePressImage.size.width / 2
                                                                            topCapHeight:beforePressImage.size.height /2]
                                  forState:UIControlStateHighlighted];
    
    [_imageViewNaviBottomBG addSubview:_buttonBeforDetour];

    
   _labelBeforDetour = [self createLabelWithText:STR(@"Route_beforeDetour", Localize_RouteOverview)
                                      fontSize:16
                                 textAlignment:NSTextAlignmentCenter];
    
    _labelBeforDistance = [self createLabelWithText:STR(@"Route_beforeDetour", Localize_RouteOverview)
                                           fontSize:16
                                      textAlignment:NSTextAlignmentRight];
    _labelBeforToll = [self createLabelWithText:STR(@"Route_beforeDetour", Localize_RouteOverview)
                                         fontSize:14
                                    textAlignment:NSTextAlignmentLeft];
    [_labelBeforDetour setTextColor:textColor];
    [_labelBeforDistance setTextColor:textColor];
    [_labelBeforToll setTextColor:textColor];
    [_buttonBeforDetour addSubview:_labelBeforDetour];
    [_buttonBeforDetour addSubview:_labelBeforDistance];
    [_buttonBeforDetour addSubview:_labelBeforToll];
    
    
    
    
    //按钮避让后
    UIImage *afterImage = IMAGE(@"Main_buttonDetourAfter.png", IMAGEPATH_TYPE_1);
    UIImage *afterPressImage = IMAGE(@"Main_buttonDetourAfterPress.png", IMAGEPATH_TYPE_1);
    _buttonAfterDetour = [UIButton buttonWithType:UIButtonTypeCustom];
    _buttonAfterDetour.tag = BUTTON_DETOUR_AFTER_DETOUR;
    [_buttonAfterDetour addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_buttonAfterDetour addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_buttonAfterDetour setBackgroundImage:[afterImage stretchableImageWithLeftCapWidth:afterImage.size.width / 2
                                                                            topCapHeight:afterImage.size.height /2]
                                  forState:UIControlStateNormal];
    [_buttonAfterDetour setBackgroundImage:[afterPressImage stretchableImageWithLeftCapWidth:afterPressImage.size.width / 2
                                                                                topCapHeight:afterPressImage.size.height /2]
                                  forState:UIControlStateHighlighted];
    [_imageViewNaviBottomBG addSubview:_buttonAfterDetour];
    _labelAfterDetour = [self createLabelWithText:STR(@"Route_afterDetour", Localize_RouteOverview)
                                         fontSize:16
                                    textAlignment:NSTextAlignmentCenter];
    
    _labelAfterDistance = [self createLabelWithText:STR(@"Route_afterDetour", Localize_RouteOverview)
                                           fontSize:16
                                      textAlignment:NSTextAlignmentRight];
    _labelAfterToll = [self createLabelWithText:STR(@"Route_afterDetour", Localize_RouteOverview)
                                       fontSize:14
                                  textAlignment:NSTextAlignmentLeft];
    [_labelAfterDistance setTextColor:textColor];
    [_labelAfterDetour setTextColor:textColor];
    [_labelAfterToll setTextColor:textColor];
    [_buttonAfterDetour addSubview:_labelAfterDetour];
    [_buttonAfterDetour addSubview:_labelAfterDistance];
    [_buttonAfterDetour addSubview:_labelAfterToll];
    
    
    

    _labelMeter = [self createButtonWithTitle:nil normalImage:@"mainScaleIcon.png" heightedImage:nil tag:56 ];
    [_labelMeter.titleLabel setFont:[UIFont systemFontOfSize:10]];
    if([[MWPreference sharedInstance] getValue:PREF_DAYNIGHTMODE] == 1)
    {
        [_labelMeter setTitleColor:GETSKINCOLOR(MAIN_NIGHT_METER_COLOR) forState:UIControlStateNormal];
    }
    else
    {
        [_labelMeter setTitleColor:GETSKINCOLOR(MAIN_DAY_METER_COLOR) forState:UIControlStateNormal];
    }
    [self.view addSubview:_labelMeter];


    //避让失败
    _buttonFailDetour = [self createButtonWithTitle:STR(@"RouteDetour_AfterDetour",Localize_RouteOverview) normalImage:@"DetourContrast-detour.png" heightedImage:nil tag:BUTTON_DETOUR_FAIL_DETOUR];
	[self.view addSubview:_buttonFailDetour];
    _buttonFailDetour.showsTouchWhenHighlighted = YES;
    

}

//调整控件竖屏坐标和图片
-(void)changePortraitControlFrameWithImage
{
    // 按钮 126 背景高度146
    // 地图区域
    
    [_mapView setmyFrame:CGRectMake(0.0f, 0.0f, MAIN_POR_WIDTH, MAIN_POR_HEIGHT)];
    
    [[MWPreference sharedInstance] setValue:PREF_DISPLAY_ORIENTATION Value:1];
    [self showContrastMapInfo:NO];
    //拉起控制中心的时候，切屏，出现地图界面错乱问题。 延迟0.1S 刷图
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[MWMapOperator sharedInstance] MW_ShowMapView:_MapViewType WithParma1:-1 WithParma2:0 WithParma3:0];
    });
    if(isiPhone)
    {
        //放大，缩小
        [_buttonEnlargeMap setFrame:CGRectMake(0.0f, 0.0f, 40.0f, 42.0f)];
        [_buttonEnlargeMap setCenter:CGPointMake(MAIN_POR_WIDTH-26.0f, MAIN_POR_HEIGHT-157.5f)];
    
        [_buttonNarrowMap setFrame:CGRectMake(0.0f, 0.0f, 40.0f, 42.0f)];
        [_buttonNarrowMap setCenter:CGPointMake(MAIN_POR_WIDTH-26.0f, MAIN_POR_HEIGHT-115.5f)];
    
        [_labelMeter setFrame:CGRectMake(0.0f, 0.0f, 36.0f, 12.0f)];
        [_labelMeter setCenter:CGPointMake(MAIN_POR_WIDTH-26.0f, MAIN_POR_HEIGHT-85.5f)];
        
    
    
        // 顶部背景
        [_imageViewNaviTopBG setFrame:CGRectMake(0, 0, MAIN_POR_WIDTH, 59.0f + DIFFENT_STATUS_HEIGHT)];
//        [_buttonTrafficEvent setFrame:CGRectMake(0, 0, 26.0f, 34.0f)];
//        [_buttonTrafficEvent setCenter:CGPointMake(25.0f, 59.0f / 2 + DIFFENT_STATUS_HEIGHT)];
        [_colorLabel setFrame:CGRectMake(20.0f, 5 + DIFFENT_STATUS_HEIGHT, MAIN_POR_WIDTH - 40.0f, 49.0f)];
        _colorLabel.font = [UIFont systemFontOfSize:20.0f];
        
        //底部背景
        [_imageViewNaviBottomBG setFrame:CGRectMake(0, 0, MAIN_POR_WIDTH, 73.0f)];
        [_imageViewNaviBottomBG setCenter:CGPointMake(MAIN_POR_WIDTH / 2, MAIN_POR_HEIGHT -  73.0f / 2)];
        //避让前
        
        float space=7.0f;
        float width=(MAIN_POR_WIDTH-space*3)/2;
        float height=60.0f;
        [_buttonBeforDetour setFrame:CGRectMake( 2*space + width, (CGRectGetHeight(_imageViewNaviBottomBG.frame)-height)/2.0f , width,height)];
    
        [_labelBeforDetour setFrame: CGRectMake(0, 6, _buttonBeforDetour.frame.size.width, 19.0f)];
        _labelBeforDetour.font = [UIFont systemFontOfSize:13.0f];
        _labelBeforDetour.textAlignment = NSTextAlignmentCenter;
        
        [_labelBeforDistance setFrame:CGRectMake(0,
                                             27.5f,
                                             _buttonBeforDetour.frame.size.width / 2 - 5.0f,
                                             20.0f)];
        _labelBeforDistance.font = [UIFont systemFontOfSize:15.0f];
        _labelBeforDistance.textAlignment = NSTextAlignmentRight;
        
        [_labelBeforToll setFrame:CGRectMake(_buttonBeforDetour.frame.size.width / 2 + 5,
                                             31.0f,
                                             _buttonBeforDetour.frame.size.width / 2-5,
                                             16.0f)];
        _labelBeforToll.font = [UIFont systemFontOfSize:13.0f];
        _labelBeforToll.textAlignment = NSTextAlignmentLeft;
    
        //避让后
        [_buttonAfterDetour setFrame:CGRectMake( space , (CGRectGetHeight(_imageViewNaviBottomBG.frame)-height)/2.0f , width,height)];
        [_labelAfterDetour setFrame: CGRectMake(0, 6, _buttonBeforDetour.frame.size.width, 19.0f)];
        _labelAfterDetour.font = [UIFont systemFontOfSize:13.0f];
        _labelAfterDetour.textAlignment = NSTextAlignmentCenter;
        
        [_labelAfterDistance setFrame:CGRectMake(0,
                                                 27.5f,
                                                 _buttonBeforDetour.frame.size.width / 2 - 5.0f,
                                                 20.0f)];
        _labelAfterDistance.font = [UIFont systemFontOfSize:15.0f];
        _labelAfterDistance.textAlignment = NSTextAlignmentRight;
        
        [_labelAfterToll setFrame:CGRectMake(_buttonBeforDetour.frame.size.width / 2 + 5,
                                             31.0f,
                                             _buttonBeforDetour.frame.size.width / 2-5,
                                             16.0f)];
        _labelAfterToll.font = [UIFont systemFontOfSize:13.0f];
        _labelAfterToll.textAlignment = NSTextAlignmentLeft;

    }
    else
    {
        //放大，缩小
        [_buttonEnlargeMap setFrame:CGRectMake(0.0f, 0.0f, 60, 63)];
        [_buttonEnlargeMap setCenter:CGPointMake(MAIN_POR_WIDTH-36.0f, (1596-55)/2.0f - 11)];
        
        [_buttonNarrowMap setFrame:CGRectMake(0.0f, 0.0f, 60, 63)];
        [_buttonNarrowMap setCenter:CGPointMake(MAIN_POR_WIDTH-36.0f, (1706-55)/2.0f - 3)];
        
        [_labelMeter setFrame:CGRectMake(0.0f, 0.0f, 50, 20.0f)];
        [_labelMeter setCenter:CGPointMake(MAIN_POR_WIDTH-36.0f, (1785-50)/2.0f)];
        
        
        
        // 顶部背景
        [_imageViewNaviTopBG setFrame:CGRectMake(0, 0, MAIN_POR_WIDTH, 88  + DIFFENT_STATUS_HEIGHT)];
//        CGFloat ratio = 88.0f/59.0f;
//        [_buttonTrafficEvent setFrame:CGRectMake(0, 0 , 26.0f * ratio, 34.0f * ratio )];
//        [_buttonTrafficEvent setCenter:CGPointMake(65.0f, 88.0f / 2  + DIFFENT_STATUS_HEIGHT)];
        
        
        [_colorLabel setFrame:CGRectMake(40.0f, 10 + DIFFENT_STATUS_HEIGHT, MAIN_POR_WIDTH - 80.0f, 68)];
        [_colorLabel setFont:[UIFont systemFontOfSize:26]];
        
        //底部背景
        [_imageViewNaviBottomBG setFrame:CGRectMake(0, 0, MAIN_POR_WIDTH, 109)];
        [_imageViewNaviBottomBG setCenter:CGPointMake(MAIN_POR_WIDTH / 2, MAIN_POR_HEIGHT -  109 / 2)];
        //避让前
//        96;
        float space=12;
        float width=(MAIN_POR_WIDTH-space*3)/2;
        float height=96;
        [_buttonBeforDetour setFrame:CGRectMake( 2*space + width, (CGRectGetHeight(_imageViewNaviBottomBG.frame)-height)/2.0f , width,height)];
        
        [_labelBeforDetour setFrame: CGRectMake(0, 21, _buttonBeforDetour.frame.size.width, 19.0f)];
        _labelBeforDetour.font = [UIFont systemFontOfSize:22];
        _labelBeforDetour.textAlignment = NSTextAlignmentCenter;
        
        [_labelBeforDistance setFrame:CGRectMake(0,
                                                 53,
                                                 _buttonBeforDetour.frame.size.width / 2 - 5.0f,
                                                 25)];
        _labelBeforDistance.font = [UIFont systemFontOfSize:18];
        _labelBeforDistance.textAlignment = NSTextAlignmentRight;
        
        [_labelBeforToll setFrame:CGRectMake(_buttonBeforDetour.frame.size.width / 2 + 5+10,
                                             57,
                                             _buttonBeforDetour.frame.size.width / 2-5,
                                             20)];
        _labelBeforToll.font = [UIFont systemFontOfSize:18];
        _labelBeforToll.textAlignment = NSTextAlignmentLeft;
        
        //避让后
        [_buttonAfterDetour setFrame:CGRectMake(space, (CGRectGetHeight(_imageViewNaviBottomBG.frame)-height)/2.0f , width,height)];
        
        [_labelAfterDetour setFrame: CGRectMake(0, 21, _buttonBeforDetour.frame.size.width, 19.0f)];
        _labelAfterDetour.font = [UIFont systemFontOfSize:22];
        _labelAfterDetour.textAlignment = NSTextAlignmentCenter;
        
        [_labelAfterDistance setFrame:CGRectMake(0,
                                                 53,
                                                 _buttonBeforDetour.frame.size.width / 2 - 5.0f,
                                                 25)];
        _labelAfterDistance.font = [UIFont systemFontOfSize:18];
        _labelAfterDistance.textAlignment = NSTextAlignmentRight;
        
        [_labelAfterToll setFrame:CGRectMake(_buttonBeforDetour.frame.size.width / 2 + 5+10,
                                             57,
                                             _buttonBeforDetour.frame.size.width / 2-5,
                                             20)];
        _labelAfterToll.font = [UIFont systemFontOfSize:18];
        _labelAfterToll.textAlignment = NSTextAlignmentLeft;

    }
     [self reloadEnlargeAndNarrowImage];
}


- (void) reloadEnlargeAndNarrowImage
{
    //竖屏状态或者是iPad都不用横屏的图片
    if(Interface_Flag == 0 || !isiPhone)
    {
        [_buttonEnlargeMap setBackgroundImage:IMAGE(@"mainEnlargeMap.png", IMAGEPATH_TYPE_2) forState:UIControlStateNormal];
        [_buttonEnlargeMap setBackgroundImage:IMAGE(@"mainEnlargeMapPress.png", IMAGEPATH_TYPE_2) forState:UIControlStateHighlighted];
        [_buttonNarrowMap setBackgroundImage:IMAGE(@"mainNarrow.png", IMAGEPATH_TYPE_2) forState:UIControlStateNormal];
        [_buttonNarrowMap setBackgroundImage:IMAGE(@"mainNarrowPress.png", IMAGEPATH_TYPE_2) forState:UIControlStateHighlighted];
    }
    else
    {
        [_buttonEnlargeMap setBackgroundImage:IMAGE(@"mainEnlargeMapLandscape.png", IMAGEPATH_TYPE_2) forState:UIControlStateNormal];
        [_buttonEnlargeMap setBackgroundImage:IMAGE(@"mainEnlargeMapPressLandscape.png", IMAGEPATH_TYPE_2) forState:UIControlStateHighlighted];
        [_buttonNarrowMap setBackgroundImage:IMAGE(@"mainNarrowLandscape.png", IMAGEPATH_TYPE_2) forState:UIControlStateNormal];
        [_buttonNarrowMap setBackgroundImage:IMAGE(@"mainNarrowPressLandscape.png", IMAGEPATH_TYPE_2) forState:UIControlStateHighlighted];
    }
}

//调整控件横屏坐标和图片
-(void)changeLandscapeControlFrameWithImage
{
    // 地图区域
    [_mapView setmyFrame:CGRectMake(0.0f, 0.0f,MAIN_LAND_WIDTH, MAIN_LAND_HEIGHT)];
    [[MWPreference sharedInstance] setValue:PREF_DISPLAY_ORIENTATION Value:0];
    //
    [self showContrastMapInfo:NO];
    //拉起控制中心的时候，切屏，出现地图界面错乱问题。 延迟0.1S 刷图
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[MWMapOperator sharedInstance] MW_ShowMapView:_MapViewType WithParma1:-1 WithParma2:0 WithParma3:0];
    });
    
    if(isiPhone)
    {
        //放大，缩小
        [_buttonEnlargeMap setFrame:CGRectMake(0.0f, 0.0f, 42.0f, 40.0f)];
        [_buttonEnlargeMap setCenter:CGPointMake(MAIN_LAND_WIDTH - 69.0f, MAIN_LAND_HEIGHT-69.0f)];
        
        [_buttonNarrowMap setFrame:CGRectMake(0.0f, 0.0f, 42.0f, 40.0f)];
        [_buttonNarrowMap setCenter:CGPointMake(MAIN_LAND_WIDTH - 27.0f, MAIN_LAND_HEIGHT-69.0f)];
        
        [_labelMeter setFrame:CGRectMake(0.0f, 0.0f, 36.0f, 12.0f)];
        [_labelMeter setCenter:CGPointMake(MAIN_LAND_WIDTH - 26.0f, MAIN_LAND_HEIGHT-101.0f)];
        _labelMeter.titleLabel.font = [UIFont systemFontOfSize:10.0f];


        
        // 顶部背景
        [_imageViewNaviTopBG setFrame:CGRectMake(0, 0, MAIN_LAND_WIDTH, 59.0f + DIFFENT_STATUS_HEIGHT)];
//        [_buttonTrafficEvent setFrame:CGRectMake(0, 0, 26.0f, 34.0f)];
//        [_buttonTrafficEvent setCenter:CGPointMake(25.0f, 59.0f / 2 + DIFFENT_STATUS_HEIGHT)];
        [_colorLabel setFrame:CGRectMake(20.0f, 5 + DIFFENT_STATUS_HEIGHT, MAIN_LAND_WIDTH - 40.0f, 49.0f)];
        _colorLabel.font = [UIFont systemFontOfSize:20.0f];
        
        //底部背景
        [_imageViewNaviBottomBG setFrame:CGRectMake(0, 0, MAIN_LAND_WIDTH, 48.0f)];
        [_imageViewNaviBottomBG setCenter:CGPointMake(MAIN_LAND_WIDTH / 2, MAIN_LAND_HEIGHT -  48.0f / 2.0f)];
        //避让前
        [_buttonBeforDetour setFrame:CGRectMake(MAIN_LAND_WIDTH / 2 + 4.0f,
                                                (48.0f-36.0f) / 2,
                                                MAIN_LAND_WIDTH / 2 - 8.0f,
                                                36.0f)];
        float buttonWidth = _buttonBeforDetour.frame.size.width;
        [_labelBeforDetour setFrame: CGRectMake(0, 0, buttonWidth / 3.0f - 5.0f, 36.0f)];
        _labelBeforDetour.font = [UIFont systemFontOfSize:15.0f];
        _labelBeforDetour.textAlignment = NSTextAlignmentRight;
        
        [_labelBeforDistance setFrame:CGRectMake(buttonWidth / 3.0f - 3.0f,
                                                 0,
                                                 buttonWidth / 3.0f + 5.0f,
                                                 36.0f)];
        _labelBeforDistance.font = [UIFont systemFontOfSize:15.0f];
        _labelBeforDistance.textAlignment = NSTextAlignmentCenter;
        
        [_labelBeforToll setFrame:CGRectMake(buttonWidth * 2.0f/ 3.0f + 5.0f,
                                             0,
                                             buttonWidth * 2.0f/ 3.0f - 7.0f,
                                             36.0f)];
        _labelBeforToll.font = [UIFont systemFontOfSize:15.0f];
        _labelBeforToll.textAlignment = NSTextAlignmentLeft;
        //避让后
        [_buttonAfterDetour setFrame:CGRectMake(8, (48.0f-36.0f) / 2,MAIN_LAND_WIDTH / 2 - 8.0f,36.0f)];
        
        [_labelAfterDetour setFrame: CGRectMake(0, 0, buttonWidth / 3.0f - 5.0f, 36.0f)];
        _labelAfterDetour.font = [UIFont systemFontOfSize:15.0f];
        _labelAfterDetour.textAlignment = NSTextAlignmentRight;
        
        [_labelAfterDistance setFrame:CGRectMake(buttonWidth / 3.0f - 3.0f,
                                                 0,
                                                 buttonWidth / 3.0f + 5.0f,
                                                 36.0f)];
        _labelAfterDistance.font = [UIFont systemFontOfSize:15.0f];
        _labelAfterDistance.textAlignment = NSTextAlignmentCenter;
        
        [_labelAfterToll setFrame:CGRectMake(buttonWidth * 2.0f/ 3.0f + 5.0f,
                                             0,
                                             buttonWidth/ 3.0f - 7.0f,
                                             36.0f)];
        _labelAfterToll.font = [UIFont systemFontOfSize:15.0f];
         _labelAfterToll.textAlignment = NSTextAlignmentLeft;
    }
    else
    {
        
      
       
        
        [_buttonEnlargeMap setFrame:CGRectMake(0.0f, 0.0f, 60, 63)];
        [_buttonNarrowMap setFrame:CGRectMake(0.0f, 0.0f, 60, 63)];
        [_labelMeter setFrame:CGRectMake(0.0f, 0.0f, 56, 24.0f)];
        
        [_buttonEnlargeMap setCenter:CGPointMake(MAIN_LAND_WIDTH - 36.0f, (1161-55)/2.0f - 8)];
        if([[UIScreen mainScreen] scale] == 2)
        {
            [_buttonNarrowMap setCenter:CGPointMake(MAIN_LAND_WIDTH - 36.0f,(1271-55)/2.0f)];
        }
        else
        {
            [_buttonNarrowMap setCenter:CGPointMake(MAIN_LAND_WIDTH - 36.0f,(1271-55)/2.0f - 1)];
        }
        
        [_labelMeter setCenter:CGPointMake(MAIN_LAND_WIDTH - 36.0f, (1350-55)/2.0f)];

        
        // 顶部背景
        [_imageViewNaviTopBG setFrame:CGRectMake(0, 0, MAIN_LAND_WIDTH, 83 + DIFFENT_STATUS_HEIGHT)];
//        CGFloat ratio = 88.0f/59.0f;
//        [_buttonTrafficEvent setFrame:CGRectMake(0, 0, 26.0f * ratio, 34.0f * ratio)];
//        [_buttonTrafficEvent setCenter:CGPointMake(60.0f, 88.0f / 2 + DIFFENT_STATUS_HEIGHT)];
        [_colorLabel setFrame:CGRectMake(40.0f, 10 + DIFFENT_STATUS_HEIGHT, MAIN_LAND_WIDTH - 80.0f, 63)];
        [_colorLabel setFont:[UIFont systemFontOfSize:26]];
        
        float space=12;
        float width=(MAIN_LAND_WIDTH-space*3)/2;
        float height=54;

        //底部背景
        [_imageViewNaviBottomBG setFrame:CGRectMake(0, 0, MAIN_LAND_WIDTH, 72)];
        [_imageViewNaviBottomBG setCenter:CGPointMake(MAIN_LAND_WIDTH / 2, MAIN_LAND_HEIGHT -  72 / 2.0f)];
        //避让前
        [_buttonBeforDetour setFrame:CGRectMake(space*2+width,
                                                (72-height) / 2,
                                               width,
                                                height)];
        float buttonWidth = _buttonBeforDetour.frame.size.width;
        [_labelBeforDetour setFrame: CGRectMake(0, 0, buttonWidth / 3.0f - 5.0f, height)];
        _labelBeforDetour.font = [UIFont systemFontOfSize:18];
        _labelBeforDetour.textAlignment = NSTextAlignmentRight;
        
        [_labelBeforDistance setFrame:CGRectMake(buttonWidth / 3.0f - 3.0f,
                                                 0,
                                                 buttonWidth / 3.0f + 5.0f,
                                                 height)];
        _labelBeforDistance.font = [UIFont systemFontOfSize:22];
        _labelBeforDistance.textAlignment = NSTextAlignmentCenter;
        
        [_labelBeforToll setFrame:CGRectMake(buttonWidth * 2.0f/ 3.0f + 5.0f,
                                             0,
                                             buttonWidth * 2.0f/ 3.0f - 7.0f,
                                             height)];
        _labelBeforToll.font = [UIFont systemFontOfSize:18];
        _labelBeforToll.textAlignment = NSTextAlignmentLeft;
        //避让后
        [_buttonAfterDetour setFrame:CGRectMake(space, (72-height) / 2,width,height)];
        
        [_labelAfterDetour setFrame: CGRectMake(0, 0, buttonWidth / 3.0f - 5.0f, height)];
        _labelAfterDetour.font = [UIFont systemFontOfSize:18];
        _labelAfterDetour.textAlignment = NSTextAlignmentRight;
        
        [_labelAfterDistance setFrame:CGRectMake(buttonWidth / 3.0f - 3.0f,
                                                 0,
                                                 buttonWidth / 3.0f + 5.0f,
                                                 height)];
        _labelAfterDistance.font = [UIFont systemFontOfSize:22];
        _labelAfterDistance.textAlignment = NSTextAlignmentCenter;
        
        [_labelAfterToll setFrame:CGRectMake(buttonWidth * 2.0f/ 3.0f + 5.0f,
                                             0,
                                             buttonWidth/ 3.0f - 7.0f,
                                             height)];
        _labelAfterToll.font = [UIFont systemFontOfSize:18];
        _labelAfterToll.textAlignment = NSTextAlignmentLeft;

    }
     [self reloadEnlargeAndNarrowImage];
}

//改变控件文本
-(void)changeControlText
{
    
}

#pragma mark -
#pragma mark control action
- (void) buttonAction:(id)sender
{
    if([ANParamValue sharedInstance].isRequestParking  != 2)
    {
        [ANParamValue sharedInstance].isRequestParking = 1;
    }
    UIButton *button  =  (UIButton *)sender;
    switch (button.tag) {
        //避让前和避让失败
        case  BUTTON_DETOUR_BEFORE_DETOUR:
        case BUTTON_DETOUR_FAIL_DETOUR:
        {
            _forbidSwapBuffer = YES;
            //
            // 1停止导航
            GSTATUS nStatus =[MWRouteGuide StopGuide:Gfalse];
            
            GHGUIDEROUTE guideDetour[4] = {0};
            int nRealCount;
            nStatus = [MWRouteGuide GetGuideRouteList:guideDetour count:4 returnCount:&nRealCount];
            nStatus = [MWRouteGuide DelGuideRoute:_guideRouteHandle];
            for (int i=0; i<nRealCount; i++) {
                if (guideDetour[i]!=NULL && guideDetour[i]!=_guideRouteHandle) {
                    nStatus = [MWRouteGuide  StartGuide:guideDetour[i]];
                    break;
                }
            }
            [MWRouteDetour ClearDetourRoad];//清空规避道路
            [self RecoverTheOriginalDetourRoadInfo];//恢复规避道路
            [[MWMapOperator sharedInstance] MW_GoToCCP];
            [self.navigationController popToRootViewControllerAnimated:NO];
            //
        }
            break;
        //避让后
        case  BUTTON_DETOUR_AFTER_DETOUR:
        {
            _forbidSwapBuffer = YES;
            
            // 1停止导航
            GSTATUS nStatus =[MWRouteGuide StopGuide:Gfalse];
            // 2 删除路线
            GHGUIDEROUTE guideDetour[4]= {0};
            int nRealCount;
            nStatus = [MWRouteGuide GetGuideRouteList:guideDetour count:4 returnCount:&nRealCount];
            
            for (int i=0; i<nRealCount; i++) {
                if (guideDetour[i]!=NULL && guideDetour[i]!=_guideRouteHandle) {
                    nStatus = [MWRouteGuide DelGuideRoute:guideDetour[i]];
                }
            }
            // 使用一条路线引导
            nStatus = [MWRouteGuide  StartGuide:_guideRouteHandle];
            [[MWMapOperator sharedInstance] MW_GoToCCP];
            [self.navigationController popToRootViewControllerAnimated:NO];
        }
            break;
        default:
            break;
    }
}

- (void)viewInfoInCondition:(NSInteger)condition {
    
	switch (condition)
	{
		case 0:
		{
			//获取当前比例尺

			[_labelMeter setTitle:[[MWMapOperator sharedInstance] GetCurrentScale]
                         forState:UIControlStateNormal];
            
            [self setZoomButtonsRespondStatus];
        }
        break;
			
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


- (void) setTrafficeImage:(int) typeID
{
//    if (typeID == 2 || typeID == 3) {
//        [_buttonTrafficEvent setImage:IMAGE(@"TrafficIcon_4.png", IMAGEPATH_TYPE_1) ];
//    }
//    else if(typeID == 4 || typeID == 5)
//    {
//        [_buttonTrafficEvent setImage:IMAGE(@"TrafficIcon_5.png", IMAGEPATH_TYPE_1) ];
//    }
//    else if (typeID == 33)
//    {
//        [_buttonTrafficEvent setImage:IMAGE(@"TrafficIcon_21.png", IMAGEPATH_TYPE_1) ];
//    }
//    else if (typeID == 34)
//    {
//        [_buttonTrafficEvent setImage:IMAGE(@"TrafficIcon_22.png", IMAGEPATH_TYPE_1)];
//    }
//    else if (typeID == 35)
//    {
//        [_buttonTrafficEvent setImage:IMAGE(@"TrafficIcon_23.png", IMAGEPATH_TYPE_1) ];
//    }
//    else if (typeID == 36)
//    {
//        [_buttonTrafficEvent setImage:IMAGE(@"TrafficIcon_24.png", IMAGEPATH_TYPE_1) ];
//    }
//    else if (typeID == 37)
//    {
//        [_buttonTrafficEvent setImage:IMAGE(@"TrafficIcon_25.png", IMAGEPATH_TYPE_1) ];
//    }
//    else if (typeID == 38)
//    {
//        [_buttonTrafficEvent setImage:IMAGE(@"TrafficIcon_26.png", IMAGEPATH_TYPE_1) ];
//    }
//    else if (typeID == 39)
//    {
//        [_buttonTrafficEvent setImage:IMAGE(@"TrafficIcon_27.png", IMAGEPATH_TYPE_1) ];
//    }
}

- (void) setStringTrafficInfo:(NSString *)stringTrafficInfo  distance:(NSString *)distance range:(NSString *)range
{
    _stringTrafficInfo = stringTrafficInfo;
    if(_stringTrafficInfo == nil)
    {
        _imageViewNaviTopBG.hidden = YES;
    }
    else
    {
        [_colorLabel setColorText:distance,range,nil];
        _colorLabel.text = _stringTrafficInfo;
        _imageViewNaviTopBG.hidden = NO;
    }
}

// 绘制地图，因为特殊情况，在绘制完地图后，移动0米
-(void) showContrastMapInfo:(BOOL) bReset
{
    if (_MapViewType == GMAP_VIEW_TYPE_MULTI_DIFF)
    {
        [[MWMapOperator sharedInstance] MW_ShowMapView:_MapViewType WithParma1:-1 WithParma2:0 WithParma3:0];
        
    } else
    {
        [[MWMapOperator sharedInstance] MW_ShowMapView:_MapViewType WithParma1:0 WithParma2:0 WithParma3:0];
        
    }
    GMOVEMAP stMoveMap;
    stMoveMap.eOP = MOVEMAP_OP_DRAG;
    stMoveMap.deltaCoord.x = 0;
    stMoveMap.deltaCoord.y = 0;
    [[MWMapOperator sharedInstance] MW_MoveMapView:_MapViewType TypeAndCoord:&stMoveMap];
    [[MWMapOperator sharedInstance] MW_SaveInfoForCurrrentMapView];
    // 设置比例尺
    [self setZoomButtonsRespondStatus];
    if (bReset)
    {
//        _buttonRecover.hidden = YES;
    }
}

- (void)setZoomButtonsRespondStatus
{
    GZOOMLEVEL nScale = [[MWMapOperator sharedInstance] GetMapScaleLevelWithType:_MapViewType];
    if (nScale ==ZOOM_15_M)
    {
        _buttonEnlargeMap.alpha = ALPHA_HIDEN;
        _buttonEnlargeMap.enabled = NO;
        _buttonNarrowMap.alpha = ALPHA_APEAR;
        _buttonNarrowMap.enabled = YES;
    }
    else if (nScale ==ZOOM_500_KM)
    {
        _buttonEnlargeMap.alpha = ALPHA_APEAR;
        _buttonNarrowMap.alpha = ALPHA_HIDEN;
        _buttonEnlargeMap.enabled = YES;
        _buttonNarrowMap.enabled = NO;
    }
    else {
        _buttonEnlargeMap.alpha = ALPHA_APEAR;
        _buttonNarrowMap.alpha = ALPHA_APEAR;
        _buttonEnlargeMap.enabled = YES;
        _buttonNarrowMap.enabled = YES;
    }
}

#pragma mark 保存原有的规避信息
- (void) SaveOriginalDetourRoadInfo
{
    _detourRoadInfo = NULL;
    _numCountOfDetourRoad = 0;
    GDETOURROADLIST* pDetourRoadList=nil;
    GDBL_GetDetourRoadList(&pDetourRoadList);
    if (pDetourRoadList!=nil) {
        if (pDetourRoadList->nNumberOfDetourRoad>0) {
            _numCountOfDetourRoad = pDetourRoadList->nNumberOfDetourRoad;
            _detourRoadInfo = (GDETOURROADINFO*)malloc(sizeof(GDETOURROADINFO)*_numCountOfDetourRoad);
            for (int i=0; i<_numCountOfDetourRoad; i++) {
                _detourRoadInfo[i] = pDetourRoadList->pDetourRoad[i];
            }
        }
    }
    GDBL_ClearDetourRoad();
    free(_detourRoadInfo);
}

-(void) RecoverTheOriginalDetourRoadInfo
{
    if (_numCountOfDetourRoad>0) {
        for (int i=0; i<_numCountOfDetourRoad; i++) {
            GDBL_AddDetourRoad(&_detourRoadInfo[i]);
        }
    }
}


#pragma mark 路径信息
- (void) setRouteInfoToButton
{
    // 获取原有路径的全程和历时信息
    GHGUIDEROUTE guideDetour[4]= {0};
    int nRealCount;
    [MWRouteGuide GetGuideRouteList:guideDetour count:4 returnCount:&nRealCount];
    //
    NSString* szTime = nil;
    NSString* szDistance = nil;
    NSString *sztoll = nil;
    for (int i=0; i<nRealCount; i++)
    {
        if (guideDetour[i]!=NULL&&guideDetour[i]!=_guideRouteHandle)
        {
            szTime= [MWRouteGuide GetPathStatisticInfoWithMainID:2 GuideHandel: guideDetour[i]];
            szDistance = [MWRouteGuide GetPathStatisticInfoWithMainID:1 GuideHandel:guideDetour[i]];
            sztoll = [MWRouteGuide GetPathStatisticInfoWithMainID:0 GuideHandel: guideDetour[i]];
        }
    }
    // 成功显示两条不一样的路径，进行对比

        /*
         1 check if the dialog is from trafficInfoMap
         2 Add the delay time to the total time of the original route
         */
        if (!self.isDlgFromRoadList)
        {
            szTime = [[CustomRealTimeTraffic sharedInstance] RtcTotalTimeOfRoute:[CustomRealTimeTraffic sharedInstance].psCurrentIndexForMove];
        }
//        [_buttonBeforDetour setTitle:[NSString stringWithFormat:@"%@ %@ %@",sztoll ,szDistance,szTime] forState:UIControlStateNormal];
        _labelBeforToll.text = [NSString stringWithFormat:STR(@"RouteOverview_TollGateTotal", Localize_RouteOverview),sztoll];
        _labelBeforDistance.text  = szDistance;
        
        // 规避后的信息
        szTime= [MWRouteGuide GetPathStatisticInfoWithMainID:2 GuideHandel: _guideRouteHandle];
        szDistance = [MWRouteGuide GetPathStatisticInfoWithMainID:1 GuideHandel: _guideRouteHandle];
        sztoll = [MWRouteGuide GetPathStatisticInfoWithMainID:0 GuideHandel: _guideRouteHandle];
        _labelAfterToll.text = [NSString stringWithFormat:STR(@"RouteOverview_TollGateTotal", Localize_RouteOverview),sztoll];
        _labelAfterDistance.text = szDistance;
    
}



#pragma mark -
#pragma mark notification
-(void)notificationReceived:(NSNotification*) notification
{
    if (self.navigationController.topViewController != self) {
        return;
    }

    if ([notification.name isEqual:NOTIFY_SHOWMAP]&&self.navigationController.topViewController==self) {
        if (!_forbidSwapBuffer) //禁止刷图,解决界面切换时地图会闪来闪去的问题
        {
            [_mapView swapBuffers];
        }
        [self setZoomButtonsRespondStatus];
//        if ([[MWMapOperator sharedInstance] MW_CheckIfChangeOnMapViewInfo])
//        {
//            _buttonRecover.hidden = NO;
//        } else {
//            _buttonRecover.hidden = YES;
//        }
    }
    //
    if ([notification.name isEqual:NOTIFY_STARTTODEMO2])//新路径演算
	{
		NSArray *result = [notification object];
        if ([[result objectAtIndex:1] intValue] == 0) {
            _guideRouteHandle = (GHGUIDEROUTE)[[result objectAtIndex:0] intValue];//路径操作句柄
            
            // 判断是否成功
            GGUIDEROUTEINFO stGuideRouteInfo = {0};
            GSTATUS nStatus = [MWRouteGuide GetGuideRouteInfo:_guideRouteHandle routeInfo:&stGuideRouteInfo];
            if (stGuideRouteInfo.bHasAvoidRoad==FALSE)
            {
                _isSuccessDetour = TRUE;
                nStatus = [MWRouteGuide  AddGuideRoute:_guideRouteHandle];//添加到路线管理列表
            }
            else
            {
                _isSuccessDetour = FALSE;
            }
        }
        else
        {
            _isSuccessDetour = FALSE;
            
            [self createAlertViewWithTitle:STR(@"RouteDetour_FailRoute", Localize_RouteOverview) message:nil cancelButtonTitle:STR (@"RouteOverview_Back", Localize_RouteOverview)otherButtonTitles:nil tag:200];
        }
	}
    if ([notification.name isEqual:NOTIFY_UPDATE_VIEWINFO]) {
        [self viewInfoInCondition:0];
    }
}

- (void)handleUIUpdate:(NSNotification *)result
{
    switch ([[result object] intValue]) {
        case UIUpdate_MapDayNightModeChange:
        {
            int type = [[result.userInfo objectForKey:@"dayNightMode"]integerValue];
            if(type == 0)
            {
                [_labelMeter setTitleColor:GETSKINCOLOR(MAIN_DAY_METER_COLOR) forState:UIControlStateNormal];
            }
            else
            {
                [_labelMeter setTitleColor:GETSKINCOLOR(MAIN_NIGHT_METER_COLOR) forState:UIControlStateNormal];
            }
            [self setDayAndNightStyle];
        }
            break;
        default:
            break;
    }
}


#pragma mark -
#pragma mark xxx delegate

#pragma mark =========================================================
#pragma mark Touch
#pragma mark =========================================================

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	
	switch ([touches count])
	{
		case 1:
		{
			[self dispatchFirstTouchAtPoint:[[[touches allObjects] objectAtIndex:0] locationInView:_mapView] secondTouchAtPoint:CGPointMake(0.0, 0.0)];
		}
			break;
			
		default:
			break;
	}
	[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_TOUCH object:nil];
}


- (void)dispatchFirstTouchAtPoint:(CGPoint)firstTouchPoint secondTouchAtPoint:(CGPoint)touchPoint {
	
	
	static CGPoint firstPoint;
	
	if (firstTouchPoint.x!=0 || firstTouchPoint.y!=0)
	{
		firstPoint = firstTouchPoint;
	}
	
	if (touchPoint.x!=0 || touchPoint.y!=0)
	{
		int dX = (int)(touchPoint.x - firstPoint.x);
		int dY = (int)(touchPoint.y - firstPoint.y);
		
		firstPoint = touchPoint;
		_isNeedRecover = TRUE;
        GMOVEMAP stMoveMap;
        stMoveMap.eOP = MOVEMAP_OP_DRAG;
        stMoveMap.deltaCoord.x = -dX;
        stMoveMap.deltaCoord.y = -dY;
        [[MWMapOperator sharedInstance] MW_MoveMapView:_MapViewType TypeAndCoord:&stMoveMap];
	}
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	
	switch ([touches count])
	{
		case 1:
		{
        
		}
			break;
			
        default:
            break;
    }
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	
	
}
#pragma mark   NSTimer *m_timerInc, *m_timerDec;
- (void)ZoomInLongPressed:(UILongPressGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan)
	{
        _isLonePressed = YES;
		_timerInc = [NSTimer scheduledTimerWithTimeInterval:0.2f
                                                      target:self
                                                    selector:@selector(incFun:)
                                                    userInfo:nil
                                                     repeats:YES];
        [_timerInc fire];
	}
	else if (recognizer.state == UIGestureRecognizerStateChanged)
	{
        
	}else 	if (recognizer.state == UIGestureRecognizerStateEnded)
	{
        [self Stop_Idec:_buttonEnlargeMap];
	}
    
}

- (void)ZoomOutLongPressed:(UILongPressGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan)
	{
        _isLonePressed = YES;
		_timerDec = [NSTimer scheduledTimerWithTimeInterval:0.2f
                                                      target:self
                                                    selector:@selector(decFun:)
                                                    userInfo:nil
                                                     repeats:YES];
        [_timerDec fire];
	}
	else if (recognizer.state == UIGestureRecognizerStateChanged)
	{
        
	}else 	if (recognizer.state == UIGestureRecognizerStateEnded)
	{
        [self Stop_Idec:_buttonNarrowMap];
	}
}

- (void)decFun:(NSTimer *)timer {
	if (_isLonePressed)
    {
        _isLonePressed = NO;
        return;
    }
	[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_TOUCH object:[NSNumber numberWithBool:NO]];

    GZOOMLEVEL nScale = [[MWMapOperator sharedInstance] GetMapScaleLevelWithType:_MapViewType];
    if (nScale==ZOOM_500_KM)
    {
        [self setZoomButtonsRespondStatus];
        if (_timerDec != nil) {
            [_timerDec invalidate];
            _timerDec = nil;
        }
        return;
    }

    [[MWMapOperator sharedInstance] MW_ZoomMapView:_MapViewType ZoomFlag:GSETMAPVIEW_LEVEL_OUT ZoomLevel:0];
}


- (void)incFun:(NSTimer *)timer {
    if (_isLonePressed)
    {
        _isLonePressed = NO;
        return;
    }
	[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_TOUCH object:[NSNumber numberWithBool:NO]];

    GZOOMLEVEL nScale = [[MWMapOperator sharedInstance] GetMapScaleLevelWithType:_MapViewType];
    if (nScale == ZOOM_15_M)
    {
        [self setZoomButtonsRespondStatus];
        if (_timerInc != nil) {
            [_timerInc invalidate];
            _timerInc = nil;
        }
        return;
    }

    [[MWMapOperator sharedInstance] MW_ZoomMapView:_MapViewType ZoomFlag:GSETMAPVIEW_LEVEL_IN ZoomLevel:0];
}


- (void)Stop_Idec:(id)sender {
	
	NSLog(@"Stop_Idec");
	UIButton *button = (UIButton *)sender;
	if (button.tag==BUTTON_DETOUR_ENLARGEMAP)
	{
		if (_timerInc != nil) {
            [_timerInc invalidate];
            _timerInc = nil;
        }
	}
	else if (button.tag==BUTTON_DETOUR_NARROWMAP)
	{
        if (_timerDec != nil) {
            [_timerDec invalidate];
            _timerDec = nil;
        }
	}
}
#pragma mark xxx delegate
-(void)mapView:(PaintingView *)mapView GestureRecognizer:(UIGestureRecognizer *)recognizer gestureType:(RECOGNIZETYPE)gesturetype  withParam:(int)param
{
}


//设置白天黑夜图片
- (void) setDayAndNightStyle
{
    [self reloadEnlargeAndNarrowImage];
}


@end

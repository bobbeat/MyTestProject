//
//  RoutePlanningAndDetailViewController.m
//  AutoNavi
//
//  Created by jiangshu-fu on 14-7-18.
//
//

#import "RoutePlanningAndDetailViewController.h"
#import "PaintingView.h"
#import "UMengEventDefine.h"
#import "MainDefine.h"
#import "MWMapAddIconOperator.h"
#import "Plugin_CarService.h"
#import "RouteDetailButton.h"
#import "RouteDetourViewController.h"
#import "RouteDetailListCell.h"
#import "RoutePointViewController.h"
#import "RouteDetailListView.H"
#import "Plugin_POI.h"
#import "GDPopPOI.h"
#import "MWCloudDetourManage.h"

@interface CustomPageControl : UIPageControl

@end

@implementation CustomPageControl

- (id) init
{
    self = [super init];
    if (self ) {
        if ([self respondsToSelector:@selector(setCurrentPageIndicatorTintColor:)]
            && [self respondsToSelector:@selector(setPageIndicatorTintColor:)]) {
            [self setCurrentPageIndicatorTintColor:[UIColor clearColor]];
            [self setPageIndicatorTintColor:[UIColor clearColor]];
        }
    }
    return self;
}

- (void)setCurrentPage:(NSInteger)currentPage
{
    [super setCurrentPage:currentPage];
    if (NSFoundationVersionNumber < NSFoundationVersionNumber_iOS_6_0)
    {
        NSArray *subView = self.subviews;
        for (int i = 0; i < [subView count]; i++)
        {
            id tempView = [subView objectAtIndex:i];
            if([tempView isKindOfClass:[UIImageView class]])
            {
                ((UIImageView *)tempView).hidden = YES;
            }
        }
    }

    [self setNeedsDisplay];
}

- (void)setNumberOfPages:(NSInteger)numberOfPages
{
    [super setNumberOfPages:numberOfPages];
    
    [self setNeedsDisplay];
    
}

- (void)drawRect:(CGRect)iRect
{

        int i;
        CGRect rect;
        UIImage *image;
    
        iRect = self.bounds;
    
        if (self.opaque) {
            [self.backgroundColor set];
            UIRectFill(iRect);
        }
    
        UIImage *_activeImage = [UIImage imageNamed:@"PageHightlight.png"];
        UIImage *_inactiveImage = [UIImage imageNamed:@"PageNormal.png"];
        CGFloat _kSpacing = 5.0f;

        if (self.hidesForSinglePage && self.numberOfPages == 1) {
            return;
        }
        
        rect.size.height = _activeImage.size.height;
        rect.size.width = self.numberOfPages * _activeImage.size.width + (self.numberOfPages - 1) * _kSpacing;
        rect.origin.x = floorf((iRect.size.width - rect.size.width) / 2.0);
        rect.origin.y = floorf((iRect.size.height - rect.size.height) / 2.0);
        rect.size.width = _activeImage.size.width;
    
        for (i = 0; i < self.numberOfPages; ++i) {
            image = (i == self.currentPage) ? _activeImage : _inactiveImage;
            [image drawInRect:rect];
            rect.origin.x += _activeImage.size.width + _kSpacing;
        }

}

@end

#pragma  mark - ---  下划线按钮  ---
@interface UnderLineButton:UIButton
@end

@implementation UnderLineButton

- (void) drawRect:(CGRect)rect
{
    [super drawRect:rect];
    CGRect textRect = self.titleLabel.frame;
    
    // need to put the line at top of descenders (negative value)
    CGFloat descender = self.titleLabel.font.descender + 3;
    
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    
    // set to same colour as text
    CGContextSetStrokeColorWithColor(contextRef, self.titleLabel.textColor.CGColor);
    
    CGContextMoveToPoint(contextRef, textRect.origin.x, textRect.origin.y + textRect.size.height + descender);
    
    CGContextAddLineToPoint(contextRef, textRect.origin.x + textRect.size.width, textRect.origin.y + textRect.size.height + descender);
    
    CGContextClosePath(contextRef);
    CGContextDrawPath(contextRef, kCGPathStroke);
}
@end




#pragma mark - ---  路线详情界面  ---
//可点击按钮的tag
typedef enum ROUTEPLANNING_BUTTON_TYPE
{
    ROUTEPLANNING_BUTTON_BEGIN = 17,   //开始导航
    ROUTEPLANNING_BUTTON_SIMU,         //模拟导航
    ROUTEPLANNING_BUTTON_ENLARGE,      //放大
    ROUTEPLANNING_BUTTON_NARROW,       //缩小
    ROUTEPLANNING_BUTTON_LIST,          //路线详情
    ROUTEPLANNING_BUTTON_AVOID,        //躲避拥堵
}ROUTEPLANNING_BUTTON_TYPE;

//路线概览的路线详情
typedef enum ROUTEPLANNING_ROUTE_INFO
{
    ROUTEPLANNING_ROUTE_TOLL = 36,     //加油站
    ROUTEPLANNING_ROUTE_DISTANCE,      //距离
    ROUTEPLANNING_ROUTE_ARRIVETIME,    //到达时间
}ROUTEPLANNING_ROUTE_INFO;

#define ROUTE_BOTTOM_BUTTON_WIDTH  (isiPhone ? 319.0f : 782.0f)
#define ROUTE_BOTTOM_BUTTON_HEIGHT (isiPhone ? (Interface_Flag == 0 ?  73.0f : 76.0f ):112.0f)
#define ROUTE_BEGINBUTTON_WIDTH (isiPhone ? 100.0f : 200.0f)

@interface RoutePlanningAndDetailViewController ()

@end

@implementation RoutePlanningAndDetailViewController


#pragma mark -
#pragma mark viewcontroller ,
- (id)init
{
	self = [super init];
	if (self)
	{
		_isDeleteRoute = YES;
        _isAnimate = YES;
        _isCountPlane = YES;
        _isAvoid = NO;
        _isEvent = NO;
//        _guideRouteHandle = {0};
	}
	return self;
}

- (id) initWithDeleteRoute:(BOOL) deleteRoute
{
    self = [self init];
    if(self)
    {
        _isDeleteRoute = deleteRoute;
    }
    return self;
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    CRELEASE(popPoiInfo);
    CRELEASE(_maneuverInfo);
    CRELEASE(_arrayDetailButton);
    CRELEASE(_detailViewController);
	CRELEASE(_arrayIndex);
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
    
    /**
     播报全程概览语音
     **********************************************************************/
    if (_isDeleteRoute)
    {
        [MWRouteGuide PlayWholeRouteSound];
    }
    else
    {
        [MWRouteGuide readdRouteHandler]; //modify by gzm for 重新添加remove的路径句柄，这个接口需要在初始化控件前调用 at 2014-10-17
    }
    
    _arrayIndex = [[NSMutableArray alloc]initWithObjects:[NSNumber numberWithInt:0],
                                                         [NSNumber numberWithInt:1],
                                                         [NSNumber numberWithInt:2],
                                                         [NSNumber numberWithInt:3], nil];
    _mapViewType = GMAP_VIEW_TYPE_MULTIWHOLE;
    _maneuverInfo = nil;
    //显示图片
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(notificationReceived:)
                                                 name:NOTIFY_SHOWMAP
                                               object:nil];
    //回到前台
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(notificationReceived:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    //进入后台
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(notificationReceived:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    //更新界面控件显示
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(notificationReceived:)
                                                 name:NOTIFY_UPDATE_VIEWINFO
                                               object:nil];
    //白天黑夜切换收到的通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleUIUpdate:)
                                                 name:NOTIFY_HandleUIUpdate
                                               object:nil];
//    self.title = STR(@"Route_planningRoute", Localize_RouteOverview);
    self.navigationItem.leftBarButtonItem = LEFTBARBUTTONITEM(STR(@"RouteOverview_Back", Localize_RouteOverview), nil);
//    self.navigationItem.rightBarButtonItem = RIGHTBARBUTTONITEM(STR(@"Route_addWayPt", Localize_RouteOverview), @selector(addWayPoint:));
    [self initNavigation:STR(@"Route_planningRoute", Localize_RouteOverview)];
    [self initControl];
    
    //计时
    _timerCountDown = [NSTimer scheduledTimerWithTimeInterval:1.0f
                                                       target:self
                                                     selector:@selector(StartNavigation:)
                                                     userInfo:nil
                                                      repeats:YES];
    //显示光标
    [[MWPreference sharedInstance] setValue:PREF_MAPSHOWCURSOR Value:1];
    _iTimeCount = 9;
    [_timerCountDown fire];
    _isClickOpenTMC = NO;

    [[MWCloudDetourManage sharedInstance] RequestCloudDetour];//add by hlf for 云端规避文件下载
}
- (void) initNavigation:(NSString *)title
{
    if(_navigationBar)
    {
        [_navigationBar popNavigationItemAnimated:NO];
        [_navigationBar removeFromSuperview];
    }
    _navigationBar = [POICommon allocNavigationBar:title ];
    
    UINavigationItem *navigationitem = [[UINavigationItem alloc] init];
    UIBarButtonItem *item= LEFTBARBUTTONITEM(@"",
                                            @selector(backPress:));
    [navigationitem setLeftBarButtonItem:item];
    UINavigationItem *navigationitem1 = [[UINavigationItem alloc] init];
    UIBarButtonItem *item1= RIGHTBARBUTTONITEM(STR(@"Route_addWayPt", Localize_RouteOverview),
                                               @selector(addWayPoint:));
    [navigationitem setRightBarButtonItem:item1 animated:NO];
    
    [_navigationBar pushNavigationItem:navigationitem animated:NO];
    [self.view addSubview:_navigationBar];
    [navigationitem release];
    [navigationitem1 release];
}




// Called when the view is about to made visible. Default does nothing
- (void)viewWillAppear:(BOOL)animated
{
    _mapView  = [MapViewManager ShowMapViewInController:self]; //要放在调用 [super viewWillAppear:animated] 之前，切换多次地图后，会造成无法放大缩小
    [[MWPreference sharedInstance] setValue:PREF_MAP_TMC_SHOW_OPTION Value:YES]; //全程概览界面都显示路径TMC,根据路径判断是否显示事件
    
	[super viewWillAppear:animated];
    _forbidSwapBuffer = NO;
    [self.navigationController setNavigationBarHidden:YES];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.userInteractionEnabled = YES;
    [MWRouteCalculate setDelegate:self];    //设置路径演算delegate
    if(_timerCountDown != nil)
    {
        [_buttonBeginNavi setTitle:[NSString stringWithFormat:@"%@(9)",STR(@"Route_PointBeginNavi", Localize_RouteOverview)] forState:UIControlStateNormal];
    }
    //设置放大缩小比例尺按钮
    [self setZoomButtonsRespondStatus];
    [[MWMapOperator sharedInstance] MW_SaveInfoForCurrrentMapView];

    [MWMapAddIconOperator ClearMapIcon]; //有周边点，就取消之
    [[MWMapOperator sharedInstance] MW_ShowMapView:_mapViewType WithParma1:0 WithParma2:0 WithParma3:0];//刷图显示
}
// Called when the view has been fully transitioned onto the screen. Default does nothing

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}
// Called when the view is dismissed, covered or otherwise hidden. Default does nothing

-(void)viewWillDisappear:(BOOL)animated
{
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [[MWMapOperator sharedInstance] MW_GoToCCP];
//    });
    [MWRouteCalculate setDelegate:nil];    //设置路径演算delegate
    [self stopTimecount];
    [[MWPreference sharedInstance] setValue:PREF_SHOW_MAP_GRAY_BKGND Value:NO];
    _mapView.delegate = nil;
    [self hideLoadingViewWithAnimated:NO];
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
    _mapView = [MapViewManager ShowMapViewInController:self];
    [self.view sendSubviewToBack:_mapView];
    [_mapView setRecognizeSwitchOn:EVENT_NONE];
    
    //放大缩小按钮
    _buttonEnlargeMap = [self buttonInCondition:ROUTEPLANNING_BUTTON_ENLARGE];
    _buttonNarrowMap = [self buttonInCondition:ROUTEPLANNING_BUTTON_NARROW];
    UILongPressGestureRecognizer *longPress =[[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(ZoomInLongPressed:)]autorelease];
	longPress.minimumPressDuration =0.2;
	[_buttonEnlargeMap addGestureRecognizer:longPress];
	[_buttonEnlargeMap addTarget:self action:@selector(decFun:) forControlEvents:UIControlEventTouchUpInside];
    
    longPress =[[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(ZoomOutLongPressed:)]autorelease];
	longPress.minimumPressDuration =0.2;
	[_buttonNarrowMap addGestureRecognizer:longPress];
	[_buttonNarrowMap addTarget:self action:@selector(incFun:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_buttonEnlargeMap];
    [self.view addSubview:_buttonNarrowMap];
    //GPS-比例尺
	_labelMeter =  [self buttonInCondition:56] ;
    [_labelMeter.titleLabel setFont:[UIFont systemFontOfSize:10]];
	[self.view addSubview:_labelMeter];
    
    [_labelMeter setTitle:[[MWMapOperator sharedInstance] GetCurrentScale]
                 forState:UIControlStateNormal];
    [self.view addSubview:_labelMeter];
    [self loadLabelMeterTitleColor];
    [self reloadEnlargeAndNarrowImage];
    
    //躲避拥堵显示
    [self initAvoidLineTips]; //位置在按钮初始化前
    //天气
    _buttonWeather = [self createButtonWithTitle:nil
                                     normalImage:@"mainWeather.png"
                                   heightedImage:@"mainWeatherPress.png"
                                             tag:BUTTON_LIST_WEATHER];
    _buttonWeather.hidden =  NO ;
    [self.view addSubview:_buttonWeather];


    
    _detailViewController = [[RouteDetailViewController alloc]init];
    [self.view addSubview:_detailViewController];
    _detailViewController.hidden = YES;
    __block RoutePlanningAndDetailViewController *blockSelf = self;
    //避让
    _detailViewController.avoidCell = ^(ManeuverInfo *inf)
    {
        [blockSelf avoidWithInfo:inf];
    };
    //进入节点
    _detailViewController.selectCell = ^(NSArray *info,NSIndexPath *indexPath){
        [blockSelf pushToPoint:info withIndex:indexPath];
    };
     //开始导航
    _buttonBeginNavi = [self buttonInCondition:ROUTEPLANNING_BUTTON_BEGIN];
    UIImage *beginImage = IMAGE(@"RouteNaviButtonImage.png", IMAGEPATH_TYPE_1);
    [_buttonBeginNavi setImage:beginImage forState:UIControlStateNormal];
    [_buttonBeginNavi setTitleColor:GETSKINCOLOR(@"POINaviGationColor")
                           forState:UIControlStateNormal];
    [self.view addSubview:_buttonBeginNavi];
    
    //模拟导航
    _buttonSimuNavi = [self buttonInCondition:ROUTEPLANNING_BUTTON_SIMU];
    UIImage *SimuImage = IMAGE(@"Route_SimuNavi.png", IMAGEPATH_TYPE_1);
    [_buttonSimuNavi setImage:SimuImage forState:UIControlStateNormal];
    [_buttonSimuNavi setTitleColor:GETSKINCOLOR(ROUTE_LABEL_COLOR)
                          forState:UIControlStateNormal];
    [self.view addSubview:_buttonSimuNavi];
    [_buttonSimuNavi setTitle:STR(@"Route_SimuNavi", Localize_RouteOverview)
                     forState:UIControlStateNormal];
    
    //路线详情
    _buttonDetailList = [self buttonInCondition:ROUTEPLANNING_BUTTON_LIST];
    UIImage *detailImage = IMAGE(@"PlanningDetail.png", IMAGEPATH_TYPE_1);
    [_buttonDetailList setImage:detailImage forState:UIControlStateNormal];
    [_buttonDetailList setTitleColor:GETSKINCOLOR(ROUTE_LABEL_COLOR)
                            forState:UIControlStateNormal];
    [self.view addSubview:_buttonDetailList];
    [_buttonDetailList setTitle:STR(@"RoutePointview_RouteDetail", Localize_RouteOverview)
                       forState:UIControlStateNormal];

    //滚动视图初始化
    [self  initScrollView];
    //按钮数据数组初始化
    _arrayDetailButton = [[NSMutableArray alloc]initWithCapacity:0];
    [self setRouteGuidButton];
    
    [self setDayAndNightStyle];
    
    popPoiInfo = [[GDPopPOI alloc] initWithType:ViewPOIType_Traffic];
    popPoiInfo.delegate = self;
    popPoiInfo.topView = self.view;
    [popPoiInfo setHidden:YES];
    

}


/***
 * @name    根据不同的tag创建button
 * @param   condition:button的tag
 * @author  by bazinga
 ***/
- (UIButton *)buttonInCondition:(NSInteger)condition
{
    UIButton *button;
	NSString *titleT;
	NSString *normalImage;
	NSString *highlightedImage;
    CGFloat strechParamX = 0;
    CGFloat strechParamy = 0;
    IMAGEPATHTYPE type = IMAGEPATH_TYPE_1;
    
    switch (condition) {
        case ROUTEPLANNING_BUTTON_ENLARGE://放大
        {
            normalImage = @"mainEnlargeMap.png";
            highlightedImage = @"mainEnlargeMapPress.png";
            type = IMAGEPATH_TYPE_2;
            
            titleT = nil;
        }
            break;
        case ROUTEPLANNING_BUTTON_NARROW://缩小
        {
            normalImage = @"mainNarrow.png";
            highlightedImage = @"mainNarrowPress.png";
            type = IMAGEPATH_TYPE_2;
            titleT = nil;
        }
            break;
        case 56:// 比例尺
		{
			titleT = nil;
			normalImage = @"mainScaleIcon.png";
			highlightedImage = nil;
		}
			break;
        case ROUTEPLANNING_BUTTON_BEGIN://开始导航
        {
            titleT = STR(@"Route_PointBeginNavi", Localize_RouteOverview);
            normalImage = @"RoutePlanningNavi.png";
            highlightedImage = @"RouteButtonPress.png";
            strechParamX = 5;
            strechParamy = 24;
        }
            break;
        case ROUTEPLANNING_BUTTON_SIMU://模拟导航
        {
            titleT = STR(@"Route_SimuNavi", Localize_RouteOverview);
            normalImage = @"RoutePlanningNavi.png";
            highlightedImage = @"RouteButtonPress.png";
            strechParamX = 5;
            strechParamy = 24;
        }
            break;
        case ROUTEPLANNING_BUTTON_LIST://路线详情
        {
            titleT = STR(@"Route_SimuNavi", Localize_RouteOverview);
            normalImage = @"RoutePlanningDetail.png";
            highlightedImage = @"RouteButtonPress.png";
            strechParamX = 4.0f;
            strechParamy = 24.0f;
        }
            break;
        default:
        {
            normalImage = nil;
            highlightedImage = nil;
            titleT = nil;
        }
            break;
    }
    
    button = [self createButtonWithTitle:titleT normalImage:normalImage heightedImage:highlightedImage tag:condition strechParamX:strechParamX strechParamY:strechParamy];
	titleT = nil;
	normalImage = nil;
	highlightedImage = nil;
	return button;
}
//按钮点击事件
- (void)buttonAction:(id)sender
{
    [self stopTimecount];
	switch (((UIButton *)sender).tag)
    {
        case ROUTEPLANNING_BUTTON_BEGIN:
        {
            NSLog(@"ROUTEOVERVIEW_BUTTON_BEGIN");
            [self beginNavigation:nil];
        }
            break;
        case ROUTEPLANNING_BUTTON_SIMU:
        {
            NSLog(@"ROUTEOVERVIEW_BUTTON_SIMU");
            [self simuNaviPress:nil];
        }
            break;
        case ROUTEPLANNING_BUTTON_LIST:
        {
            NSLog(@"路线详情按钮点击");
            [self routeDetailPress:nil];
        }
            break;
        case BUTTON_LIST_WEATHER:
        {
            [self enterWeather];
        }
            break;
        case ROUTEPLANNING_BUTTON_AVOID:
        {
            [self avoid];
        }
            break;
        default:
        {
        }
            break;
    }
}


#pragma mark - ---  控件坐标修改  ---
//调整控件竖屏坐标和图片
-(void)changePortraitControlFrameWithImage
{
    [_mapView setmyFrame:CGRectMake(0.0f, 0.0f, MAIN_POR_WIDTH,MAIN_POR_HEIGHT)];
    [[MWPreference sharedInstance] setValue:PREF_DISPLAY_ORIENTATION Value:1];
    [self setEnlargeAndNarrowFrame];
    [_navigationBar setFrame:CGRectMake(0.0, 0.0, SCREENWIDTH, 44.0 + DIFFENT_STATUS_HEIGHT)];
    float mainHeight = MAIN_POR_HEIGHT;
    float bottomButtonWidth = MAIN_POR_WIDTH / 3;
    float bottomButtonHeight = isiPhone ?  55.0f : 74.0f;
    float navigationHeight = _navigationBar.frame.size.height;
    if(isiPhone)
    {
        [_buttonSimuNavi setFrame:CGRectMake(0, mainHeight - bottomButtonHeight,
                                             bottomButtonWidth, bottomButtonHeight)];
        [_buttonBeginNavi setFrame:CGRectMake(bottomButtonWidth,  mainHeight - bottomButtonHeight,
                                              bottomButtonWidth, bottomButtonHeight)];
        [_buttonDetailList setFrame:CGRectMake(2*bottomButtonWidth, mainHeight - bottomButtonHeight,
                                               bottomButtonWidth, bottomButtonHeight)];
        _buttonBeginNavi.titleLabel.font = [UIFont boldSystemFontOfSize:15.0f];
        _buttonSimuNavi.titleLabel.font = [UIFont systemFontOfSize:15.0f];
        _buttonDetailList.titleLabel.font = [UIFont systemFontOfSize:15.0f];
        _buttonBeginNavi.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        _buttonBeginNavi.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        
        [_buttonWeather setFrame: CGRectMake(0, 0, 40, 40)];
        _buttonWeather.center = CGPointMake(MAIN_POR_WIDTH - BUTTON_BOUNDARY, 31 + navigationHeight);
    }
    else
    {
        [_buttonSimuNavi setFrame:CGRectMake(0, mainHeight - bottomButtonHeight,
                                             bottomButtonWidth, bottomButtonHeight)];
        [_buttonBeginNavi setFrame:CGRectMake(bottomButtonWidth,  mainHeight - bottomButtonHeight,
                                              bottomButtonWidth, bottomButtonHeight)];
        [_buttonDetailList setFrame:CGRectMake(2*bottomButtonWidth, mainHeight - bottomButtonHeight,
                                               bottomButtonWidth, bottomButtonHeight)];
        _buttonBeginNavi.titleLabel.font = [UIFont boldSystemFontOfSize:20.0f];
        _buttonSimuNavi.titleLabel.font = [UIFont systemFontOfSize:20.0f];
        _buttonDetailList.titleLabel.font = [UIFont systemFontOfSize:20.0f];
        _buttonBeginNavi.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        _buttonBeginNavi.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        
        [_buttonWeather setFrame: CGRectMake(0, 0, 60, 60)];
        _buttonWeather.center = CGPointMake(MAIN_POR_WIDTH - BUTTON_BOUNDARY, 30 + 11.0f+ navigationHeight);
    }
    [_detailViewController changePortraitControlFrameWithImage];
    [self  reloadButtonBackgroundImage];
    //放在最后
    [self setRouteDetailButtonFrame];
    if (popPoiInfo)
    {//poi点详细信息弹出框
        
        [popPoiInfo setHidden:YES];
    }
    [self setAvoidFrame];
}

//调整控件横屏坐标和图片
-(void)changeLandscapeControlFrameWithImage
{
    [_mapView setmyFrame:CGRectMake(0.0f, 0.0f, MAIN_LAND_WIDTH, MAIN_LAND_HEIGHT)];
    [[MWPreference sharedInstance] setValue:PREF_DISPLAY_ORIENTATION Value:0];
    [self setEnlargeAndNarrowFrame];
    [_navigationBar setFrame:CGRectMake(0, 0, MAIN_LAND_WIDTH, (isiPhone ?  32.0f : 44.0f) + DIFFENT_STATUS_HEIGHT)];
    float mainHeight = MAIN_LAND_HEIGHT;
    float navigationHeight = _navigationBar.frame.size.height;
    if (isiPhone)
    {
        float beginWidth = ROUTE_BEGINBUTTON_WIDTH;
        [_buttonBeginNavi setFrame:CGRectMake(MAIN_LAND_WIDTH - beginWidth,
                                             mainHeight - ROUTE_BOTTOM_BUTTON_HEIGHT,
                                             beginWidth,
                                              ROUTE_BOTTOM_BUTTON_HEIGHT)];
        NSLog(@"%lf,%lf,%lf",MAIN_LAND_WIDTH,beginWidth,ROUTE_BOTTOM_BUTTON_WIDTH);
        [_buttonSimuNavi setFrame:CGRectMake(MAIN_LAND_WIDTH - 2 * beginWidth,
                                            mainHeight - ROUTE_BOTTOM_BUTTON_HEIGHT,
                                            beginWidth,
                                             ROUTE_BOTTOM_BUTTON_HEIGHT/2 + 2)];
        [_buttonDetailList setFrame:CGRectMake(_buttonSimuNavi.frame.origin.x,
                                              _buttonSimuNavi.frame.origin.y + _buttonSimuNavi.frame.size.height,
                                              beginWidth,
                                               ROUTE_BOTTOM_BUTTON_HEIGHT/2 - 2)];
        _buttonSimuNavi.titleEdgeInsets = UIEdgeInsetsMake(3,0,0,0);
        _buttonSimuNavi.imageEdgeInsets = UIEdgeInsetsMake(3,0,0,0);


//        UIEdgeInsets insets = {top, left, bottom, right};
        _buttonBeginNavi.titleLabel.font = [UIFont boldSystemFontOfSize:15.0f];
        _buttonSimuNavi.titleLabel.font = [UIFont systemFontOfSize:15.0f];
        _buttonDetailList.titleLabel.font = [UIFont systemFontOfSize:15.0f];
        _buttonBeginNavi.titleLabel.lineBreakMode = NSLineBreakByClipping;
        CGSize imageSize = _buttonBeginNavi.imageView.image.size;
        _buttonBeginNavi.imageEdgeInsets = UIEdgeInsetsMake(-12,  39.0f , 0, 0);
        _buttonBeginNavi.titleEdgeInsets = UIEdgeInsetsMake(10, -imageSize.width, -imageSize.height, 0);
        

        [_buttonWeather setFrame: CGRectMake(0, 0, 40, 40)];
        _buttonWeather.center = CGPointMake(MAIN_LAND_WIDTH - BUTTON_BOUNDARY, 25.0f + navigationHeight);
    }
    else
    {
        float beginWidth = 92.0f;
        [_buttonBeginNavi setFrame:CGRectMake(MAIN_LAND_WIDTH - beginWidth,
                                              mainHeight - ROUTE_BOTTOM_BUTTON_HEIGHT,
                                              beginWidth,
                                              ROUTE_BOTTOM_BUTTON_HEIGHT)];
        NSLog(@"%lf,%lf,%lf",MAIN_LAND_WIDTH,beginWidth,ROUTE_BOTTOM_BUTTON_WIDTH);
        float simuWidth  = MAIN_LAND_WIDTH - beginWidth - ROUTE_BOTTOM_BUTTON_WIDTH;
        [_buttonSimuNavi setFrame:CGRectMake(ROUTE_BOTTOM_BUTTON_WIDTH,
                                             mainHeight - ROUTE_BOTTOM_BUTTON_HEIGHT,
                                             simuWidth,
                                             ROUTE_BOTTOM_BUTTON_HEIGHT/2 + 2)];
        [_buttonDetailList setFrame:CGRectMake(_buttonSimuNavi.frame.origin.x,
                                               _buttonSimuNavi.frame.origin.y + _buttonSimuNavi.frame.size.height,
                                               simuWidth,
                                               ROUTE_BOTTOM_BUTTON_HEIGHT/2 - 2)];
        _buttonSimuNavi.titleEdgeInsets = UIEdgeInsetsMake(3,0,0,0);
        _buttonSimuNavi.imageEdgeInsets = UIEdgeInsetsMake(3,0,0,0);
        if(fontType == 2)
        {
            _buttonSimuNavi.imageEdgeInsets = UIEdgeInsetsMake(3,-10,0,0);
            _buttonDetailList.imageEdgeInsets = UIEdgeInsetsMake(0,-20,0,0);
        }
        //        UIEdgeInsets insets = {top, left, bottom, right};
        _buttonBeginNavi.titleLabel.font = [UIFont boldSystemFontOfSize:17];
        _buttonSimuNavi.titleLabel.font = [UIFont systemFontOfSize:17.0f];
        _buttonDetailList.titleLabel.font = [UIFont systemFontOfSize:17.0f];
        _buttonBeginNavi.titleLabel.lineBreakMode = NSLineBreakByClipping;
        CGSize imageSize = _buttonBeginNavi.imageView.image.size;
        _buttonBeginNavi.imageEdgeInsets = UIEdgeInsetsMake(-20, 30.0f, 0, 0);
        _buttonBeginNavi.titleEdgeInsets = UIEdgeInsetsMake(20, -imageSize.width, -imageSize.height, 0);
        
        [_buttonWeather setFrame: CGRectMake(0, 0, 60, 60)];
        _buttonWeather.center = CGPointMake(MAIN_LAND_WIDTH - BUTTON_BOUNDARY, 30 + 11.0f+ navigationHeight);
    }
    [_detailViewController changeLandscapeControlFrameWithImage];
    [self  reloadButtonBackgroundImage];
    if (popPoiInfo)
    {//poi点详细信息弹出框
        
        [popPoiInfo setHidden:YES];
    }
    //放在最后
    [self setRouteDetailButtonFrame];
    [self setAvoidFrame];
}

/*!
  @brief    重新加载按钮的背景图片
  @param
  @author   by bazinga
  */
- (void) reloadButtonBackgroundImage
{
    if(Interface_Flag == 0)
    {
        [_buttonBeginNavi setBackgroundImage:[self getImageWithName:@"RoutePlanningNavi.png"]
                                    forState:UIControlStateNormal];
        [_buttonBeginNavi setBackgroundImage:[self getImageWithName:@"RouteButtonPress.png"]
                                    forState:UIControlStateHighlighted];
        [_buttonSimuNavi setBackgroundImage:[self getImageWithName:@"RoutePlanningNavi.png"]
                                   forState:UIControlStateNormal];
        [_buttonSimuNavi setBackgroundImage:[self getImageWithName:@"RouteButtonPress.png"]
                                   forState:UIControlStateHighlighted];
        [_buttonDetailList setBackgroundImage:[self getImageWithName:@"RoutePlanningDetail.png"]
                                     forState:UIControlStateNormal];
        [_buttonDetailList setBackgroundImage:[self getImageWithName:@"RouteButtonPress.png"]
                                     forState:UIControlStateHighlighted];
    }
    else
    {
        [_buttonBeginNavi setBackgroundImage:[self getImageWithName:@"RouteBeginNaviHeng.png"]
                                    forState:UIControlStateNormal];
        [_buttonBeginNavi setBackgroundImage:[self getImageWithName:@"RouteButtonPressHeng.png"]
                                    forState:UIControlStateHighlighted];
        [_buttonSimuNavi setBackgroundImage:[self getImageWithName:@"RouteBeginSimulHeng.png"]
                                   forState:UIControlStateNormal];
        [_buttonSimuNavi setBackgroundImage:[self getImageWithName:@"RouteButtonPressHeng.png"]
                                   forState:UIControlStateHighlighted];
        [_buttonDetailList setBackgroundImage:[self getImageWithName:@"RouteBeginDetailHeng.png"]
                                     forState:UIControlStateNormal];
        [_buttonDetailList setBackgroundImage:[self getImageWithName:@"RouteButtonPress.png"]
                                     forState:UIControlStateHighlighted];
    }
}

- (UIImage *) getImageWithName:(NSString *) name
{
    UIImage *tempIamge = IMAGE(name, IMAGEPATH_TYPE_1);
    UIImage *image = [tempIamge stretchableImageWithLeftCapWidth:tempIamge.size.width/ 2
                                                                        topCapHeight:tempIamge.size.height/ 2];
    return image;
}

//改变控件文本
-(void)changeControlText
{
    
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self changeControlFrame];
    [self stopTimecount];
    
}

- (void) changeControlFrame
{
    [[MWMapOperator sharedInstance] MW_ShowMapView:_mapViewType WithParma1:0 WithParma2:0 WithParma3:0];
}

#pragma mark -
#pragma mark control action

#pragma mark -
#pragma mark logic relate
-	(void)landscapeLogic
{
    
    
}
-	(void)portraitLogic
{
    
    
}

#pragma mark -
#pragma mark notification
-(void)notificationReceived:(NSNotification*) notification
{
    if ( self.navigationController.topViewController != self)
    {
        return;
    }
    
    if ([notification.name isEqual:NOTIFY_SHOWMAP])
	{
        if (!_forbidSwapBuffer) //禁止刷图,解决界面切换时地图会闪来闪去的问题
        {
            [_mapView swapBuffers];
        }
        [self setZoomButtonsRespondStatus];
        if (popPoiInfo)
        {//poi点详细信息弹出框
            
            [popPoiInfo movePOIViewWithPoint];
        }
	}
    if ([notification.name isEqual:NOTIFY_UPDATE_VIEWINFO]) {
        [self viewInfoInCondition:0];
    }
    if ([notification.name isEqual:UIApplicationDidBecomeActiveNotification])
    {
        
        if (_gpsFlag != 1) {
            
            [[MWMapOperator sharedInstance] MW_ShowMapView:_mapViewType WithParma1:0 WithParma2:0 WithParma3:0];
        }
        
    }
    if ([notification.name isEqual:UIApplicationDidEnterBackgroundNotification]) {
        [[MWPreference sharedInstance] setValue:PREF_SHOW_MAP_GRAY_BKGND Value:NO];
    }
}

//更新主界面上——更多，微享的new图标的显示
- (void)handleUIUpdate:(NSNotification *)result
{
    switch ([[result object] intValue]) {
        case UIUpdate_MapDayNightModeChange:
        {
            [self setDayAndNightStyle];
        }
            break;
        case UIUpdate_TMC:
        {
            if (self.navigationController.visibleViewController != self)    //modify by gzm for 可见视图不为本身时，不进行演算 at 2014-7-29
            {
                return;
            }
           
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideLoadingViewWithAnimated:NO];
            });

            [[MWPreference sharedInstance]  setValue:PREF_REALTIME_TRAFFIC Value:[MWEngineSwitch isTMCOn]];
            
            NSNumber *resultNumber = [result.userInfo objectForKey:NOTIFY_USERINFO_TMC_OPEN];   //实时交通开启成功，才重新计算路径
            if(resultNumber  && [resultNumber boolValue] &&  _isClickOpenTMC)//点击躲避拥堵按钮，才进行路径盐酸
            {
                [MWRouteCalculate StartRouteCalculation:GROU_CAL_MULTI];
            }
             _isClickOpenTMC = NO;
        }
            break;
        default:
            break;
    }
    
    
}

//设置白天黑夜图片
- (void) setDayAndNightStyle
{
    [self buttonWeatherImage];
    [self loadLabelMeterTitleColor];
    [self reloadEnlargeAndNarrowImage];
}

/***
 * @name    天气按钮设置白天黑夜，躲避拥堵设置
 * @param
 * @author  by bazinga
 ***/
- (void) buttonWeatherImage
{
    [_buttonWeather setBackgroundImage:IMAGE(@"mainWeather.png", IMAGEPATH_TYPE_2) forState:UIControlStateNormal];
    [_buttonWeather setBackgroundImage:IMAGE(@"mainWeatherPress.png", IMAGEPATH_TYPE_2) forState:UIControlStateHighlighted];
}

- (void) loadLabelMeterTitleColor
{
    if([[MWPreference sharedInstance] getValue:PREF_DAYNIGHTMODE] == 1)
    {
        [_labelMeter setTitleColor:GETSKINCOLOR(MAIN_NIGHT_METER_COLOR) forState:UIControlStateNormal];
    }
    else
    {
        [_labelMeter setTitleColor:GETSKINCOLOR(MAIN_DAY_METER_COLOR) forState:UIControlStateNormal];
    }
    
}

#pragma mark -
#pragma mark ---  按钮事件  ---
/*!
  @brief    返回按钮
  @param
  @author   by bazinga
  */
- (void)backPress:(id)sender
{
    if(_detailViewController.hidden == NO)
    {
        return;
    }

    //返回---路线规划
    [MobClick event:UM_EVENTID_ROUTE_PLANNING_VIEW_COUNT label:UM_LABEL_ROUTE_PLANNING_VIEW_BACK];
    if(_isDeleteRoute)
    {
        _forbidSwapBuffer = YES; //禁止刷图,解决界面切换时地图会闪来闪去的问题
        [MWRouteGuide GuidanceOperateWithMainID:1 GuideHandle:NULL];
    }
    else
    {
        [MWRouteGuide GuidanceOperateWithMainID:0 GuideHandle:NULL]; //modify by gzm for 解决躲避拥堵后，路径句柄发生变化，重新进入规划界面崩溃 at 2014-11-12
    }
    [self.navigationController popViewControllerAnimated:_isAnimate];  
    if (_timerCountDown != nil)
    {
        [_timerCountDown invalidate];
        _timerCountDown = nil;
    }
    if([ANParamValue sharedInstance].isRequestParking != 2)
    {
        [ANParamValue sharedInstance].isRequestParking = 1;
    }
//    if(_isDeleteRoute)
//    {
//        [[MWMapOperator sharedInstance] MW_ShowMapView:GMAP_VIEW_TYPE_MAIN WithParma1:0 WithParma2:0 WithParma3:0];
//    }
}

/*!
  @brief    添加途经点
  @param
  @author   by bazinga
  */

- (void)addWayPoint:(id)sender
{
    if(_detailViewController.hidden == NO)
    {
        return;
    }

    
    NSMutableArray * array = [MWJourneyPoint GetJourneyPointArray];
    Plugin_POI * enterPoi  = [[Plugin_POI alloc]init];
    NSMutableDictionary * dic = [[NSMutableDictionary alloc]init];
    [dic setObject:@"0" forKey:POI_TYPE];
    [dic setValue:array forKey:POI_Array];
    [dic setObject:@"2" forKey:POI_WhereGo];
    [dic setObject:self.navigationController forKey:POI_NAVIGATIONCONTROLLER];
    [enterPoi enter:dic];
    [enterPoi release];
    [dic release];
}

/*!
  @brief    开始导航
  @param
  @author   by bazinga
  */
- (void)beginNavigation:(id)sender {
    
    [[ANOperateMethod sharedInstance] GMD_PlayGPS];
    
    //友盟导航距离统计
    int distance = [[MWRouteGuide GetPathStatisticInfoWithMainID:4 GuideHandel:GNULL] intValue];
    
    [UMengStatistics naviDistanceCount:distance];
    //导航---路线规划
    [MobClick event:UM_EVENTID_ROUTE_PLANNING_VIEW_COUNT label:UM_LABEL_ROUTE_PLANNING_VIEW_Navi];
    if (_timerCountDown != nil)
    {
        [_timerCountDown invalidate];
        _timerCountDown = nil;
    }
    
	[[MWMapOperator sharedInstance] MW_SetMapOperateType:2];
    [self sumRoutePlane];
    _forbidSwapBuffer = YES;   //禁止刷图,解决界面切换时地图会闪来闪去的问题
    [self.navigationController popToRootViewControllerAnimated:NO];
    
    if([ANParamValue sharedInstance].isRequestParking != 2)
    {
        [ANParamValue sharedInstance].isRequestParking = 1;
    }
}


/***
 * @name    模拟导航
 * @param   @sender —— 控件
 * @author  by bazinga
 ***/
- (void)simuNaviPress:(id)sender {
    //    模拟导航---路线规划
    [MobClick event:UM_EVENTID_ROUTE_PLANNING_VIEW_COUNT label:UM_LABEL_ROUTE_PLANNING_VIEW_Demo];
    if (_timerCountDown != nil)
    {
        [_timerCountDown invalidate];
        _timerCountDown = nil;
    }
    [[MWMapOperator sharedInstance] MW_SetMapOperateType:1];
    _forbidSwapBuffer = YES;   //禁止刷图,解决界面切换时地图会闪来闪去的问题
	[self.navigationController popToRootViewControllerAnimated:NO];
}

/*!
  @brief    路线详情
  @param
  @author   by bazinga
  */
- (void)routeDetailPress:(id)sender
{
    _detailViewController.hidden = !_detailViewController.hidden;
    if(!_detailViewController.hidden)
    {
        [self reloadDetailData];
    }
}

- (void) reloadDetailData
{
    ManeuverInfoList *infoList = [MWRouteGuide GetManeuverTextList:NULL];
    NSArray *array = infoList.pManeuverText;
    
    _detailViewController.arrayListData = array;
    [_detailViewController reloadData];
}

- (void) avoid
{
    if([[ANDataSource sharedInstance] isNetConnecting] == NO)
    {
        GDAlertView *alertView=[[GDAlertView alloc] initWithTitle:nil andMessage:STR(@"Account_NetError",Localize_Account)];
        [alertView addButtonWithTitle:STR(@"POI_OK", Localize_POI) type:GDAlertViewButtonTypeDefault handler:^(GDAlertView *alertView){
            NSLog(@"木有网络~你看不到。");
        }];
        [alertView show];
        [alertView release];
    }
    else
    {
    
        
        GROUTETMCOPTION tmcOption = GROUTE_TMC_OPTION_ALL;
        GDBL_SetParam(G_ROUTE_TMC_OPTION, &tmcOption); /*所有规划原则，开启TMC参与路径演算*/
    
        _isClickOpenTMC = YES;
        [MobClick event:UM_UM_EVENTID_ToavoidcongestionCount_COUNT label:UM_LABEL_Toavoidcongestion];
        GCARINFO carInfo = {0};
        GDBL_GetCarInfo(&carInfo);
    
        if ( [MWAdminCode checkIsExistDataWithCoord:carInfo.Coord] == 0) {
            [self MyalertView:STR(@"Main_NoDataForCity", Localize_Main)
                   canceltext:STR(@"Universal_ok", Localize_Universal)
                    othertext:nil
                     alerttag:ALERT_NONE];
            _isClickOpenTMC = NO;
            return;
        }
    
        if(![MWEngineSwitch isTMCOn])
        {
            if([[ANParamValue sharedInstance] isTMCRequest])
            {
                [MWEngineSwitch CloseTMC];
                _isClickOpenTMC = NO;
            }
            else
            {
                GSTATUS res = [MWEngineSwitch OpenTMCWithTip:YES];
                if (res == GD_ERR_OK)
                {
                    [[MWPreference sharedInstance] setValue:PREF_MAP_TMC_SHOW_OPTION Value:YES]; //全程概览界面都显示路径TMC,根据路径判断是否显示事件
                    [self showLoadingViewInView:STR(@"Universal_loading", Localize_Universal) view:self.view];
                }
            }
        }
        else
        {
            [MWRouteCalculate StartRouteCalculation:GROU_CAL_MULTI];
            _isClickOpenTMC = NO;
        }
    }
}


- (void)MyalertView:(NSString *)titletext canceltext:(NSString *)mycanceltext othertext:(NSString *)myothertext alerttag:(int)mytag
{
    if(myothertext != nil)
    {
        [self createAlertViewWithTitle:nil
                               message:titletext
                     cancelButtonTitle:mycanceltext
                     otherButtonTitles:[NSArray arrayWithObject:myothertext]
                                   tag:mytag];
    }
    else
    {
        [self createAlertViewWithTitle:nil
                               message:titletext
                     cancelButtonTitle:mycanceltext
                     otherButtonTitles:nil
                                   tag:mytag];
    }
}



- (void) pushToPoint:(NSArray *)array withIndex:(NSIndexPath *) index
{
    NSMutableArray *arrayMainRoadInfo = [NSMutableArray arrayWithCapacity:0];
    int sum = 0;
    for (int section = 0; section < array.count; section++)
    {
        ManeuverInfo *info = [array objectAtIndex:section];
        if(info.nNumberOfSubManeuver == 0)
        {

            [arrayMainRoadInfo addObject:info];
            
            if(section < index.section)
            {
                sum++;
            }

        }
        else
        {
            
            for (int row = 0; row < info.pstSubManeuverText.count; row++)
            {
                ManeuverInfo *tempInfo = [info.pstSubManeuverText objectAtIndex:row];

                [arrayMainRoadInfo addObject:tempInfo];

            }
            if(section < index.section)
            {
                sum += info.pstSubManeuverText.count;
            }
            else if(section == index.section)
            {
                sum += index.row - 1;
            }
        }
    }
    
    RoutePointViewController *viewController = [[RoutePointViewController alloc]initWithArry:arrayMainRoadInfo
                                                                                   withIndex:sum];
    [self.navigationController pushViewController:viewController animated:YES];
    viewController.pointType = FROM_DETAILVIEW;
    [viewController release];
}


#pragma mark - ---  放大缩小所有的代码~  ---
- (void)viewInfoInCondition:(NSInteger)condition {
    
	switch (condition)
	{
		case 0:
		{
			//获取当前比例尺
            
            [_labelMeter setTitle:[[MWMapOperator sharedInstance] GetCurrentScale]
                         forState:UIControlStateNormal];
            if ([_labelMeter.titleLabel.text isEqualToString:@"15m"])
            {
                _buttonEnlargeMap.alpha = ALPHA_HIDEN;
                _buttonNarrowMap.alpha = ALPHA_APEAR;
                
            }
            else if ([_labelMeter.titleLabel.text  isEqualToString:@"500km"])
            {
                _buttonEnlargeMap.alpha = ALPHA_APEAR;
                _buttonNarrowMap.alpha = ALPHA_HIDEN;
            }
            else {
                _buttonEnlargeMap.alpha = ALPHA_APEAR;
                _buttonNarrowMap.alpha = ALPHA_APEAR;
            }
            
        }
			break;
			
		default:
			break;
	}
}

- (void) enterWeather
{
    [MobClick event:UM_EVENTID_WayWeather_Count label:UM_LABEL_WayWeather_WayWeather];
    Plugin_CarService *pluginStore = [[Plugin_CarService alloc]init];
    NSDictionary *dic=  @{PLUGIN_CARSERVICE_CONTROLLER: self.navigationController,
                          PLUGIN_CARSERVICE_WEBURL: WEATHER_ALLLOAD_URL,
                          PLUGIN_CARSERVICE_WEBTITLE:@"",
                          PLUGIN_CARSERVICE_ISBROWSER :[NSNumber numberWithBool:NO],
                          };
    
    [pluginStore enter:dic];
    [pluginStore release];
}

/*!
  @brief    设置放大缩小坐标/比例次
  @param
  @author   by bazinga
  */
- (void) setEnlargeAndNarrowFrame
{
  
    if(Interface_Flag == 0)
    {
        float mainHegiht = MAIN_POR_HEIGHT;
        if(isiPhone)
        {
            //放大，缩小
            [_labelMeter setFrame:CGRectMake(0.0f, 0.0f, 36.0f, 12.0f)];
            [_labelMeter setCenter:CGPointMake(MAIN_POR_WIDTH - BUTTON_BOUNDARY,
                                               mainHegiht - 128.0f - _labelMeter.frame.size.height / 2 - 12.0f)];
            
            [_buttonNarrowMap setFrame:CGRectMake(0.0f, 0.0f, 40.0f, 42.0f)];
            [_buttonNarrowMap setCenter:CGPointMake(MAIN_POR_WIDTH - BUTTON_BOUNDARY,
                                                    _labelMeter.frame.origin.y - 3.0f - _buttonNarrowMap.frame.size.height / 2)];
            
            [_buttonEnlargeMap setFrame:CGRectMake(0.0f, 0.0f, 40.0f, 42.0f)];
            [_buttonEnlargeMap setCenter:CGPointMake(MAIN_POR_WIDTH - BUTTON_BOUNDARY,
                                                     _buttonNarrowMap.center.y -_buttonEnlargeMap.frame.size.height  )];
        }
        else
        {
            //放大，缩小
            [_buttonEnlargeMap setFrame:CGRectMake(0.0f, 0.0f, 60.0f, 63.0f)];
            [_buttonEnlargeMap setCenter:CGPointMake(MAIN_POR_WIDTH - BUTTON_BOUNDARY, mainHegiht-311.0f - 45.0f )];
            
            [_buttonNarrowMap setFrame:CGRectMake(0.0f, 0.0f, 60.0f, 63.0f)];
            
            if([[UIScreen mainScreen] scale] == 2)
            {
                [_buttonNarrowMap setCenter:CGPointMake(MAIN_POR_WIDTH - BUTTON_BOUNDARY, mainHegiht-248.0f- 45.0f)];
            }
            else
            {
                [_buttonNarrowMap setCenter:CGPointMake(MAIN_POR_WIDTH - BUTTON_BOUNDARY, mainHegiht-249.0f- 45.0f)];
            }
            [_labelMeter setFrame:CGRectMake(0.0f, 0.0f, 50.0f, 20.0f)];
            [_labelMeter setCenter:CGPointMake(MAIN_POR_WIDTH - BUTTON_BOUNDARY, mainHegiht- 200.0f- 45.0f)];
            _labelMeter.titleLabel.font = [UIFont systemFontOfSize:13];
        }
    }
    else
    {
        CGFloat enlargeAndNarrowWidth = 40.0f;
        CGFloat enlargeAndNarrowHeght = 42.0f;
        CGFloat rightButtonDis = MAIN_LAND_WIDTH - BUTTON_BOUNDARY;
        CGFloat mainHeight = MAIN_LAND_HEIGHT;
        if(isiPhone)
        {
            
            //放大，缩小
            [_labelMeter setFrame:CGRectMake(0.0f, 0.0f, 36.0f, 12.0f)];
            [_labelMeter setCenter:CGPointMake(rightButtonDis,
                                               mainHeight - 80.0f - _labelMeter.frame.size.height / 2 - 30.0f)];
            
            [_buttonNarrowMap setFrame:CGRectMake(0.0f, 0.0f, enlargeAndNarrowWidth, enlargeAndNarrowHeght)];
            [_buttonNarrowMap setCenter:CGPointMake(rightButtonDis,
                                                    _labelMeter.frame.origin.y - 3.0f - _buttonNarrowMap.frame.size.height / 2)];
            
            [_buttonEnlargeMap setFrame:CGRectMake(0.0f, 0.0f, enlargeAndNarrowWidth, enlargeAndNarrowHeght)];
            [_buttonEnlargeMap setCenter:CGPointMake(rightButtonDis,
                                                     _buttonNarrowMap.center.y -_buttonEnlargeMap.frame.size.height  )];
        }
        else
        {
            //放大，缩小
            [_buttonEnlargeMap setFrame:CGRectMake(0.0f, 0.0f, 60.0f, 63.0f)];
            [_buttonEnlargeMap setCenter:CGPointMake(MAIN_LAND_WIDTH - BUTTON_BOUNDARY, mainHeight - 237  - 45.0f )];
            
            [_buttonNarrowMap setFrame:CGRectMake(0.0f, 0.0f, 60.0f, 63.0f)];
            [_buttonNarrowMap setCenter:CGPointMake(MAIN_LAND_WIDTH - BUTTON_BOUNDARY, mainHeight - 174.0f - 45.0f)];
            
            [_labelMeter setFrame:CGRectMake(0.0f, 0.0f, 50.0f, 20.0f)];
            [_labelMeter setCenter:CGPointMake(MAIN_LAND_WIDTH - BUTTON_BOUNDARY, mainHeight - 130.0f  - 45.0f)];
            _labelMeter.titleLabel.font = [UIFont systemFontOfSize:13];
        }
    }
}

/*!
  @brief    重载放大缩小图片
  @param
  @author   by bazinga
  */
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
        [_buttonEnlargeMap setBackgroundImage:IMAGE(@"mainEnlargeMap.png", IMAGEPATH_TYPE_2) forState:UIControlStateNormal];
        [_buttonEnlargeMap setBackgroundImage:IMAGE(@"mainEnlargeMapPress.png", IMAGEPATH_TYPE_2) forState:UIControlStateHighlighted];
        [_buttonNarrowMap setBackgroundImage:IMAGE(@"mainNarrow.png", IMAGEPATH_TYPE_2) forState:UIControlStateNormal];
        [_buttonNarrowMap setBackgroundImage:IMAGE(@"mainNarrowPress.png", IMAGEPATH_TYPE_2) forState:UIControlStateHighlighted];
    }
}


- (void)ZoomInLongPressed:(UILongPressGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan)
	{
        _isLongPress = YES;
		_timerInc = [NSTimer scheduledTimerWithTimeInterval:0.2f
                                                     target:self
                                                   selector:@selector(decFun:)
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
        _isLongPress = YES;
		_timerDec = [NSTimer scheduledTimerWithTimeInterval:0.2f
                                                     target:self
                                                   selector:@selector(incFun:)
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

- (void)incFun:(NSTimer *)timer {
    if (_isLongPress)
    {
        _isLongPress = NO;
        return;
    }
    [self stopTimecount];
    
    GZOOMLEVEL nScale = [self setZoomButtonsRespondStatus];
    if (nScale==ZOOM_500_KM)
    {
        if (_timerDec != nil)
        {
            [_timerDec invalidate];
            _timerDec = nil;
        }
        return;
    }
	[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_TOUCH object:[NSNumber numberWithBool:NO]];
    [[MWMapOperator sharedInstance] MW_ZoomMapView:_mapViewType ZoomFlag:GSETMAPVIEW_LEVEL_OUT ZoomLevel:0];
}

- (void)decFun:(NSTimer *)timer {
    if (_isLongPress)
    {
        _isLongPress = NO;
        return;
    }
    [self stopTimecount];
    GZOOMLEVEL nScale = [self setZoomButtonsRespondStatus];
    if (nScale == ZOOM_15_M)
    {
        
        if (_timerInc != nil)
        {
            [_timerInc invalidate];
            _timerInc = nil;
        }
        return;
    }
	[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_TOUCH object:[NSNumber numberWithBool:NO]];
    [[MWMapOperator sharedInstance] MW_ZoomMapView:_mapViewType ZoomFlag:GSETMAPVIEW_LEVEL_IN ZoomLevel:0];
}

- (void)Stop_Idec:(id)sender {
	
	NSLog(@"Stop_Idec");
	UIButton *button = (UIButton *)sender;
	if (button.tag==ROUTEPLANNING_BUTTON_ENLARGE)
	{
		if (_timerInc != nil) {
            [_timerInc invalidate];
            _timerInc = nil;
        }
	}
	else if (button.tag==ROUTEPLANNING_BUTTON_NARROW)
	{
        if (_timerDec != nil) {
            [_timerDec invalidate];
            _timerDec = nil;
        }
	}
}



/***
 * @name    地图的比例尺
 * @param
 * @author  by bazinga
 ***/
- (GZOOMLEVEL)setZoomButtonsRespondStatus
{
    GZOOMLEVEL nScale;
    nScale = [[MWMapOperator sharedInstance] GetMapScaleLevelWithType:_mapViewType];
    
    if (nScale ==ZOOM_15_M)
    {
        _buttonEnlargeMap.alpha = ALPHA_HIDEN;
        _buttonNarrowMap.alpha = ALPHA_APEAR;
    }
    else if (nScale ==ZOOM_500_KM)
    {
        _buttonEnlargeMap.alpha = ALPHA_APEAR;
        _buttonNarrowMap.alpha = ALPHA_HIDEN;
    }
    else
    {
        _buttonEnlargeMap.alpha = ALPHA_APEAR;
        _buttonNarrowMap.alpha = ALPHA_APEAR;
    }
    //获取当前比例尺
    
    [_labelMeter setTitle:[[MWMapOperator sharedInstance] GetCurrentScale]
                 forState:UIControlStateNormal];
    return nScale;
}


#pragma  mark - ---  规划原则按钮设计  ---

/*!
  @brief    调用 这个函数，知道下一个#pragma
  @param
  @author   by bazinga
  */
- (void) setRouteGuidButton
{

    NSMutableArray *listArray = [NSMutableArray arrayWithCapacity:0];
    GHGUIDEROUTE routeList[4] = {0};
    int count = 0;
    [MWRouteGuide GetGuideRouteList:routeList count:4 returnCount:&count];
    
    if (count > 0)
    {
        //如果有三个，就对后两个进行排序
//        if(count == 3)
//        {
//            GPATHSTATISTICLIST *ppStatInfoList = NULL;
//            GSTATUS res = GDBL_GetPathStatisticInfo(GNULL,Gtrue, Gtrue, &ppStatInfoList);
//            if(res == GD_ERR_OK && ppStatInfoList->pPathStat[1].nTime > ppStatInfoList->pPathStat[2].nTime)
//            {
//                if(_arrayIndex .count >= 3)
//                {
//                    [_arrayIndex replaceObjectAtIndex:1 withObject:[NSNumber numberWithInt:2]];
//                    [_arrayIndex replaceObjectAtIndex:2 withObject:[NSNumber numberWithInt:1]];
//                }
//            }
//        }


        for (int i = 0; i < count; i++)
        {
//            if (i == 3)
//            {
//                continue;
//            }
            if(i == 0)
            {
                // 判断是否成功
                GGUIDEROUTEINFO stGuideRouteInfo = {0};
                GSTATUS nStatus = [MWRouteGuide GetGuideRouteInfo:routeList[i] routeInfo:&stGuideRouteInfo];
                if(nStatus == GD_ERR_OK)
                {
                    self.isAvoid = (stGuideRouteInfo.bUseTMC == Gtrue);
                }
                
                if(stGuideRouteInfo.bUseTMC == Gtrue)
                {
                    [self isUsedAvoid:YES];
                }
            }
            
            RouteDetailButtonData *data = [self getDataWithIndex:[[_arrayIndex objectAtIndex:i] intValue]];
            data.indexButton = i;
            data.indexTotal = count;
            NSArray *arrayControl = @[STR(@"Main_recommend", Localize_Main),
                                      STR(@"Main_high", Localize_Main),
                                      STR(@"Main_economy", Localize_Main),
                                      STR(@"Main_short", Localize_Main)];
            NSString *stringArray  = @"";
            NSArray *array  = [MWRouteCalculate GetComposeOptions:routeList[i]];
            for (int i = 0 ; i < array.count; i++)
            {
                int value = [(NSNumber *)[array objectAtIndex:i] intValue];
                if(i != 0)
                {
                    stringArray = [stringArray stringByAppendingString:@"/"];
                }
                switch (value) {
                    case 0:
                    {
                        stringArray = [stringArray stringByAppendingString:[arrayControl objectAtIndex:0]];
                    }
                        break;
                    case 1:
                    {
                        stringArray = [stringArray stringByAppendingString:[arrayControl objectAtIndex:1]];
                    }
                        break;
                    case 2:
                    {
                        stringArray = [stringArray stringByAppendingString:[arrayControl objectAtIndex:2]];
                    }
                        break;
                    case 3:
                    {
                        stringArray = [stringArray stringByAppendingString:[arrayControl objectAtIndex:3]];
                    }
                        break;
                    default:
                        break;
                }
            }
            data.stringType = stringArray;
            
            [listArray addObject:data];
        }
        [self setRouteDetailButton:listArray];
    }
    //默认选中第一条路径线
    [MWRouteGuide ChangeGuideRoute:routeList[0]];
    _pageControl.currentPage = 0;
    [_scrollerView setContentOffset:CGPointMake(_scrollerView.frame.size.width * _pageControl.currentPage,
                                                _scrollerView.contentOffset.y)];
}

/*!
  @brief    根据
  @param
  @author   by bazinga
  */
- (RouteDetailButtonData *) getDataWithIndex:(int) index
{
    RouteDetailButtonData *data = [[RouteDetailButtonData alloc]init];
    data.stringLength = [MWRouteGuide GetPathStatisticInfoWithMainID:1 index:index];
    data.stringTime = [MWRouteGuide GetPathStatisticInfoWithMainID:4 index:index];
    data.stringTrafficeNum =  [MWRouteGuide GetPathStatisticInfoWithMainID:2 index:index];
    data.stringTollNum =    [MWRouteGuide GetPathStatisticInfoWithMainID:0 index:index];
    data.buttonTag = index;
    data.routeChose = index;
    if(index == 0)
    {
        data.isTuiJian = YES;
        data.isAvoid = self.isAvoid;
    }
    return [data autorelease];
}

/*!
  @brief    设置显示按钮数组
  @param    listArray : RouteDetailButtonData 对象数组
  @author   by bazinga
  */
- (void) setRouteDetailButton:(NSArray *)listArray
{
    if(_arrayDetailButton.count > 0)
    {
        for (int i = 0 ; i < _arrayDetailButton.count; i++)
        {
            RouteDetailButton *button = [_arrayDetailButton objectAtIndex:i];
            [button removeFromSuperview];
        }
        [_arrayDetailButton removeAllObjects];
    }
    __block RoutePlanningAndDetailViewController *blockSelf = self;
    for(int i = 0; i < listArray.count; i++)
    {
        RouteDetailButton *button = [[RouteDetailButton alloc] initWithData:[listArray objectAtIndex:i]];
        button.NextButtonPress = ^(){
            [blockSelf NextButtonPress];
        };
        button.PreButtonPress = ^(){
            [blockSelf PreButtonPress];
        };
        [_scrollerView addSubview:button];
        [_arrayDetailButton addObject:button];
        [button release];
    }
    [self setRouteDetailButtonFrame];
}

- (void) PreButtonPress
{
    [_scrollerView setContentOffset:CGPointMake(((_pageControl.currentPage - 1) < 0 ? 0 : (_pageControl.currentPage - 1) ) * _scrollerView.frame.size.width, 0)
                           animated:YES];
    
}
- (void) NextButtonPress
{
    [_scrollerView setContentOffset:CGPointMake(((_pageControl.currentPage + 1) * _scrollerView.frame.size.width > _scrollerView.contentSize.width ? _pageControl.currentPage * _scrollerView.frame.size.width : (_pageControl.currentPage + 1) * _scrollerView.frame.size.width),
                                                0)
                           animated:YES];
}

/*!
  @brief    设置路线的按钮坐标
  @param
  @author   by bazinga
  */
- (void) setRouteDetailButtonFrame
{
    float width = 0;
    float height = 0;
    float y = 0;
    if(isiPhone)
    {
        if(Interface_Flag == 0)
        {
            width = MAIN_POR_WIDTH ;
            y = _buttonBeginNavi.frame.origin.y;
        }
        else
        {
            width =  (MAIN_LAND_WIDTH - ROUTE_BEGINBUTTON_WIDTH * 2);
            y = MAIN_LAND_HEIGHT;
        }
        height = ROUTE_BOTTOM_BUTTON_HEIGHT;
    }
    else
    {
        if(Interface_Flag == 0)
        {
            width = MAIN_POR_WIDTH ;
            y = _buttonBeginNavi.frame.origin.y;
        }
        else
        {
            width =  (ROUTE_BOTTOM_BUTTON_WIDTH);
            y = MAIN_LAND_HEIGHT;
        }
        height = ROUTE_BOTTOM_BUTTON_HEIGHT;
    }
    
    for (int i = 0 ; i < _arrayDetailButton.count; i ++)
    {
        [[_arrayDetailButton objectAtIndex:i] setFrame:CGRectMake(i * width,
                                                                  0,
                                                                  width,
                                                                  height)];
    }
    
    [_scrollerView setFrame:CGRectMake(0, y - height, width, height)];
    [_scrollerView setContentSize:CGSizeMake(width * _arrayDetailButton.count, height)];
    [_scrollerView setContentOffset:CGPointMake(_scrollerView.frame.size.width * _pageControl.currentPage,
                                                _scrollerView.contentOffset.y)];
    [_pageControl setFrame:CGRectMake(0,  y - 14.0f, width, 14.0f )];
    _pageControl.numberOfPages = _arrayDetailButton.count;
}

- (void) choseRoute:(int) index
{

    [self stopTimecount];
    GHGUIDEROUTE routeList[4] = {0};
    int count = 0;
    [MWRouteGuide GetGuideRouteList:routeList count:4 returnCount:&count];
    if (index <= count -1)
    {
        [MWRouteGuide ChangeGuideRoute:routeList[index]];
    }
    
    [[MWMapOperator sharedInstance] MW_ShowMapView:_mapViewType WithParma1:0 WithParma2:0 WithParma3:0];
    [self setZoomButtonsRespondStatus];
    
    if(_detailViewController.hidden == NO)
    {
        [self reloadDetailData];
    }
    [_scrollerView setContentOffset:CGPointMake(index * _scrollerView.frame.size.width, 0)];
    _pageControl.currentPage = index;
}

#pragma mark -
#pragma mark  ---  RouteCalDelegate  ----

-(void)RouteCalResult:(GSTATUS)result guideType:(long)guideType calType:(GCALROUTETYPE)calType
{
    if (calType == GROU_CAL_SINGLE_ROUTE)
    {
        if (result == GD_ERR_OK)
        {
            _guideRouteHandle = (GHGUIDEROUTE)guideType;//路径操作句柄
            // 判断是否成功
            GGUIDEROUTEINFO stGuideRouteInfo = {0};
            GSTATUS nStatus = [MWRouteGuide GetGuideRouteInfo:_guideRouteHandle routeInfo:&stGuideRouteInfo];
            if (stGuideRouteInfo.bHasAvoidRoad==FALSE && nStatus == GD_ERR_OK)
            {
                [MWRouteDetour deleteUnselectHandlerAfterDetour]; //避让后删除未选中的句柄
                nStatus = [MWRouteGuide  AddGuideRoute:_guideRouteHandle];//添加到路线管理列表
                nStatus = GDBL_ChangeGuideRoute(_guideRouteHandle); //高亮避让后路线
                NSLog(@"避让");
                RouteDetourViewController *detourViewController = [[RouteDetourViewController alloc] initWithHandle:_guideRouteHandle];
                detourViewController.isDlgFromRoadList = YES;
                if(_isEvent)
                {
                    NSString *detail = @"";
                    NSString *roadName = [NSString chinaFontStringWithCString:_eventInfo-> szRoadName];
                    if (!roadName || [roadName length] == 0) {
                        GMAPCENTERINFO centerInfo = {0};
                        [[MWMapOperator sharedInstance] MW_GetMapViewCenterInfo:GMAP_VIEW_TYPE_MAIN mapCenterInfo:&centerInfo];
                        
                        roadName = [NSString chinaFontStringWithCString:centerInfo.szRoadName];
                        if (!roadName || [roadName length] == 0) {
                            roadName = STR(@"Main_unNameRoad", Localize_Main);
                        }
                    }
                    NSString *disFromCar;
                    NSString *streamType;
                    NSString *impactRange;
                    NSString *disFromCar_Num = nil;
                    NSString *impactRange_Num = nil;
                    
                    //车辆距事件，交通流距离
                    
                    float fDistance = _eventInfo->nDisToCar;
                    if (fDistance == 0) {
                        GCOORD start = {0};
                        GCOORD des = {0};
                        GCARINFO carInfo = {0};
                        GDBL_GetCarInfo(&carInfo);
                        start.x = carInfo.Coord.x;
                        start.y = carInfo.Coord.y;
                        
                        des.x = _eventInfo->stPosition.x;
                        des.y = _eventInfo->stPosition.y;
                        fDistance = [MWEngineTools CalcDistanceFrom:start To:des];
                    }
                    if (fDistance>1000) {
                        fDistance = fDistance/1000;
                        disFromCar = [NSString stringWithFormat:@"%.2f%@", fDistance,STR(@"Universal_KM", Localize_Universal)];
                        disFromCar_Num = [NSString stringWithFormat:@"%.2f", fDistance];
                    }else{
                        disFromCar = [NSString stringWithFormat:@"%.f%@", fDistance,STR(@"Universal_M", Localize_Universal)];
                        disFromCar_Num = [NSString stringWithFormat:@"%.f", fDistance];
                    }
                    
                    //交通流类型
                    int type = _eventInfo->nEventID > 20 ? ((_eventInfo->nEventID >> 16) & 0Xff) : _eventInfo->nEventID;
                    
                    if (type == 2 || type == 3) {
                        streamType = STR(@"TMC_slow", Localize_TMC);
                    }
                    else if (type == 4 || type == 5)
                    {
                        streamType = STR(@"TMC_congest", Localize_TMC);
                    }
                    else if (type == 33)
                    {
                        streamType = STR(@"TMC_accident", Localize_TMC);
                    }
                    else if (type == 34)
                    {
                        streamType = STR(@"TMC_underConstruction", Localize_TMC);
                    }
                    else if (type == 35)
                    {
                        streamType = STR(@"TMC_trafficControl", Localize_TMC);
                    }
                    else if (type == 36)
                    {
                        streamType = STR(@"TMC_roadBarrier", Localize_TMC);
                    }
                    else if (type == 37)
                    {
                        streamType = STR(@"TMC_events", Localize_TMC);
                    }
                    else if (type == 38)
                    {
                        streamType = STR(@"TMC_disaster", Localize_TMC);
                    }
                    else if (type == 39)
                    {
                        streamType = STR(@"TMC_badWeather", Localize_TMC);
                    }
                    else{
                        
                        [POICommon showAutoHideAlertView:STR(@"Route_roadNotDetour",Localize_RouteOverview) ];
                        
                        return;
                    }
                    
                    //影响范围
                    
                    float fRange = _eventInfo-> nLength;
                    if (fRange>1000)
                    {
                        fRange = fRange/1000;
                        impactRange = [NSString stringWithFormat:@"%.2f%@", fRange,STR(@"Universal_KM", Localize_Universal)];
                        impactRange_Num = [NSString stringWithFormat:@"%.2f", fRange];
                    }
                    else
                    {
                        impactRange = [NSString stringWithFormat:@"%.f%@", fRange,STR(@"Universal_M", Localize_Universal)];
                        impactRange_Num = [NSString stringWithFormat:@"%.f", fRange];
                    }
                    if (type > 20)
                    {
                        detail = [NSString stringWithFormat:STR(@"TMC_eventInfo", Localize_TMC),disFromCar,roadName,streamType];
                    }
                    else
                    {
                        detail = [NSString stringWithFormat:STR(@"TMC_trafficInfo", Localize_TMC),disFromCar,roadName,streamType,   impactRange];
                    }
                    
                    [detourViewController setStringTrafficInfo:detail distance:disFromCar_Num range:impactRange_Num];
                    [detourViewController setTrafficeImage:type];
                    _isEvent = NO;
                }
                
                //modify by gzm for 避让前释放除主视图和避让视图之外的视图，防止newpad内存警告，退出程序 at 2014-8-05
                NSArray *array = [self.navigationController viewControllers];
                NSArray *pushArray = [[NSArray alloc] initWithObjects:[array objectAtIndex:0],detourViewController, nil];
                [self.navigationController setViewControllers:pushArray animated:NO];
                [pushArray release];
                //modify by gzm for 避让前释放除主视图和避让视图之外的视图，防止newpad内存警告，退出程序 at 2014-8-05
                [detourViewController release];
            }
            else
            {
                [MWRouteGuide DelGuideRoute:_guideRouteHandle];  //不包含避让道路，需要删除避让路径句柄
                [POICommon showAutoHideAlertView:STR(@"Route_roadNotDetour",Localize_RouteOverview) ];
                
            }
        }
        else
        {
            [POICommon showAutoHideAlertView:STR(@"Route_roadNotDetour",Localize_RouteOverview) ];
        }
    }

    else
    {
        if (guideType == 0)
        {
            if (result == GD_ERR_OK)
            {
                if (_gpsFlag== 1 && _timerCountDown == nil) {
                    _iTimeCount = 9;
                    _timerCountDown = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(StartNavigation:) userInfo:nil repeats:YES];
                    [_timerCountDown fire];
                }
                _gpsFlag = 0;
                [[MWMapOperator sharedInstance] MW_ShowMapView:_mapViewType WithParma1:0 WithParma2:0 WithParma3:0];
            }
            else
            {
                [self stopTimecount];
                [self createAlertViewWithTitle:nil
                                       message:STR(@"RouteOverview_FailRoute",Localize_RouteOverview)
                             cancelButtonTitle:STR(@"RouteOverview_Back", Localize_RouteOverview)
                             otherButtonTitles:nil
                                           tag:200];
            }
        }
        if (guideType == 1)
        {
            if (result == GD_ERR_OK) {
                [[MWMapOperator sharedInstance] MW_ShowMapView:_mapViewType WithParma1:0 WithParma2:0 WithParma3:0];
                [[MWMapOperator sharedInstance] MW_SaveInfoForCurrrentMapView];
                [self setRouteGuidButton];
            }
            else
            {
                [self stopTimecount];
                [self createAlertViewWithTitle:nil
                                       message:STR(@"RouteOverview_FailRoute",Localize_RouteOverview)
                             cancelButtonTitle:STR(@"RouteOverview_Back", Localize_RouteOverview)
                             otherButtonTitles:nil
                                           tag:200];
            }
            
        }
    }
}

-(void)mapView:(PaintingView *)mapView GestureRecognizer:(UIGestureRecognizer *)recognizer gestureType:(RECOGNIZETYPE)gesturetype  withParam:(int)param
{
    [self stopTimecount];
    [popPoiInfo setHidden:YES];
    switch (gesturetype) {
            
        case EVENT_TAP_SINGLE:
        {
            CGPoint mPoint = [recognizer locationInView:recognizer.view];
            int iconTouchNumber = 0;
            int routeTouchNumber = -1;
            
            [MWRouteGuide guideRouteAndIconTouch:_mapViewType TouchPoint:mPoint
                                        Elements:&_eventInfo
                                     EventNumber:&iconTouchNumber
                                TouchRouteNumber:&routeTouchNumber];
            if (iconTouchNumber > 0)
            {
                int lon,lat;
                
                lon = _eventInfo->stPosition.x;
                lat = _eventInfo->stPosition.y;
                
                [self showPopPoi:lon  Lat:lat];
            }
            if (routeTouchNumber >= 0)
            {
                NSLog(@"%d",routeTouchNumber);
                if(_arrayIndex.count > routeTouchNumber )
                {
                    [self choseRoute:[[_arrayIndex objectAtIndex:routeTouchNumber] intValue]];
                }
            }
            
        }
            break;
        default:
            break;
    }
}

- (void) showPopPoi:(int)lon Lat:(int)lat
{
    if (_eventInfo->nEventID == 0) {
        return;
    }
    _isEvent = YES;
    MWPoi *tempPoi = [[MWPoi alloc] init];
    
    //道路名字
    NSString *roadName = [NSString chinaFontStringWithCString:_eventInfo-> szRoadName];
    if (!roadName || [roadName length] == 0) {
        GMAPCENTERINFO centerInfo = {0};
        [[MWMapOperator sharedInstance] MW_GetMapViewCenterInfo:_mapViewType mapCenterInfo:&centerInfo];
        
        roadName = [NSString chinaFontStringWithCString:centerInfo.szRoadName];
        if (!roadName || [roadName length] == 0) {
            roadName = STR(@"Main_unNameRoad", Localize_Main);
        }
    }
    NSString *disFromCar;
    NSString *streamType;
    NSString *impactRange;
    
    //车辆距事件，交通流距离
    
    float fDistance = _eventInfo->nDisToCar;
    if (fDistance == 0) {
        GCOORD start = {0};
        GCOORD des = {0};
        GCARINFO carInfo = {0};
        GDBL_GetCarInfo(&carInfo);
        start.x = carInfo.Coord.x;
        start.y = carInfo.Coord.y;
        
        des.x = _eventInfo->stPosition.x;
        des.y = _eventInfo->stPosition.y;
        fDistance=   [MWEngineTools CalcDistanceFrom:start  To:des];
    }
    if (fDistance>1000) {
        fDistance = fDistance/1000;
        disFromCar = [NSString stringWithFormat:@"%.2f%@", fDistance,STR(@"Universal_KM", Localize_Universal)];
    }else{
        disFromCar = [NSString stringWithFormat:@"%.f%@", fDistance,STR(@"Universal_M", Localize_Universal)];
    }
    
    //交通流类型
    int type = _eventInfo->nEventID > 20 ? ((_eventInfo->nEventID >> 16) & 0Xff) : _eventInfo->nEventID;
    
    if (type == 2 || type == 3) {
        streamType = STR(@"TMC_slow", Localize_TMC);
    }
    else if (type == 4 || type == 5)
    {
        streamType = STR(@"TMC_congest", Localize_TMC);
    }
    else if (type == 33)
    {
        streamType = STR(@"TMC_accident", Localize_TMC);
    }
    else if (type == 34)
    {
        streamType = STR(@"TMC_underConstruction", Localize_TMC);
    }
    else if (type == 35)
    {
        streamType = STR(@"TMC_trafficControl", Localize_TMC);
    }
    else if (type == 36)
    {
        streamType = STR(@"TMC_roadBarrier", Localize_TMC);
    }
    else if (type == 37)
    {
        streamType = STR(@"TMC_events", Localize_TMC);
    }
    else if (type == 38)
    {
        streamType = STR(@"TMC_disaster", Localize_TMC);
    }
    else if (type == 39)
    {
        streamType = STR(@"TMC_badWeather", Localize_TMC);
    }
    else{
        [tempPoi release];
        return;
    }
    
    tempPoi.szName = streamType;
    //影响范围
    
    float fRange = _eventInfo-> nLength;
    if (fRange>1000) {
        fRange = fRange/1000;
        impactRange = [NSString stringWithFormat:@"%.2f%@", fRange,STR(@"Universal_KM", Localize_Universal)];
    }else{
        impactRange = [NSString stringWithFormat:@"%.f%@", fRange,STR(@"Universal_M", Localize_Universal)];
    }
    if (type > 20)
    {
        tempPoi.szAddr = [NSString stringWithFormat:STR(@"TMC_eventInfo", Localize_TMC),disFromCar,roadName,streamType];
    }
    else
    {
        tempPoi.szAddr = [NSString stringWithFormat:STR(@"TMC_trafficInfo", Localize_TMC),disFromCar,roadName,streamType,impactRange];
    }
    tempPoi.szTown = disFromCar;
    //    tempPoi.szAddr = [NSString stringWithFormat:STR(@"TMC_trafficInfo", Localize_TMC),disFromCar,roadName,streamType,impactRange];
    tempPoi.usNodeId = type;
    tempPoi.longitude = lon;
    tempPoi.latitude = lat;
    [popPoiInfo setHidden:YES];
    [popPoiInfo setHidden:NO];
    [popPoiInfo  setStringAtPos:tempPoi withMapType:_mapViewType];
    [popPoiInfo startAnimate:0.3];
    
    [tempPoi release];
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self stopTimecount];
}



#pragma mark - ---  辅助函数  ---
- (void) stopTimecount
{
    [_buttonBeginNavi setTitle:[NSString stringWithFormat:@"%@",STR(@"Route_PointBeginNavi", Localize_RouteOverview)] forState:UIControlStateNormal];
    if(_timerCountDown)
    {
        [_timerCountDown invalidate];
        _timerCountDown = nil;
    }
}


//开始导航 --- 计时器到了，自动开始导航
- (void)StartNavigation:(NSTimer *)timer
{
	if (self.navigationController.topViewController != self)
	{
		return;
	}
	if (_iTimeCount==0)
	{
		[timer invalidate];
        timer = nil;
		[self beginNavigation:nil];
	}
	else
	{
        [_buttonBeginNavi setTitle:[NSString stringWithFormat:@"%@(%d)",STR(@"Route_PointBeginNavi", Localize_RouteOverview),_iTimeCount] forState:UIControlStateNormal];
    }
	_iTimeCount--;
}

- (void) setIsDeleteRoute:(BOOL)isDeleteRoute
{
    _isDeleteRoute = isDeleteRoute;
    _isCountPlane = isDeleteRoute;
}

#pragma mark- 弹出框按钮响应
- (void)GDPopViewTaped:(id)sender POI:(MWPoi *)poi
{
    
    UIButton *button=(UIButton*)sender;
    switch (button.tag) {
        case ViewPOIButtonType_avoidRoute:
        {
            GDBL_ClearDetourRoad();
            GSTATUS res = [MWRouteDetour AddAvoidEventInfo:_eventInfo];
            if (GD_ERR_OK == res)
            {
                [MWRouteCalculate StartRouteCalculation:GROU_CAL_SINGLE_ROUTE];
            }
            else
            {
                [POICommon showAutoHideAlertView:STR(@"Route_roadNotDetour",Localize_RouteOverview) ];
            }

        }
            break;
            
        default:
            break;
    }
}

/*!
  @brief    避让界面
  @param
  @author   by bazinga
  */
- (void) avoidWithInfo:(ManeuverInfo *)info
{
    GDBL_ClearDetourRoad();
    GSTATUS res = GD_ERR_FAILED;
    if(info.nNumberOfSubManeuver > 0)
    {
        res = [MWRouteDetour AddAvoidMainRoad:NULL
                                      eOption:GDETOUR_OPTION_ONCE
                                      nNodeNo:info.nID];
    }
    else
    {

        res = [MWRouteDetour AddDetourRoad:info.detourRoadInfo];

    }
    if(_maneuverInfo)
    {
        [_maneuverInfo release];
        _maneuverInfo = nil;
    }
    _maneuverInfo = [info retain];
    if (GD_ERR_OK == res)
    {
        res = [MWRouteCalculate StartRouteCalculation:GROU_CAL_SINGLE_ROUTE];
        if(GD_ERR_OK != res)
        {
            [POICommon showAutoHideAlertView:STR(@"Route_roadNotDetour",Localize_RouteOverview) ];
        }
    }
    else
    {
        [POICommon showAutoHideAlertView:STR(@"Route_roadNotDetour",Localize_RouteOverview) ];
        
    }
}


#pragma mark ---  统计  ---
/***
 * @name    路线规划原则统计
 * @param
 * @author  by bazinga
 ***/
- (void) sumRoutePlane
{
    if(_isCountPlane)
    {
        
        int index;
        GDBL_GetParam(G_ROUTE_OPTION, &index);
        switch (index) {
#pragma mark ---  看要统计什么东西  ---
                break;
            default:
                break;
        }
    }
    
    
}

#pragma  mark - ---  第二版 —— 躲避拥堵提示  ---
//UIImage *_imageViewAvoidAll;
//UILabel *_labelTipsText;
//UIButton *_buttonOpenAvoid;
- (void) initAvoidLineTips
{
    _imageViewAvoidAll = [[UIImageView alloc]init];
    _imageViewAvoidAll.backgroundColor = RGBACOLOR(187.0f, 224.0f, 248.0f, 0.9f);
    _imageViewAvoidAll.userInteractionEnabled = YES;
    [self.view addSubview:_imageViewAvoidAll];
    [_imageViewAvoidAll release];
    GGUIDEROUTECITYINFO *gudiCityInfo = {0};
    [MWRouteGuide GetGuideRouteCityInfo:GGUIDEROUTE_TYPE_ALL citiInfo:&gudiCityInfo];
    int num = gudiCityInfo->nNumberOfList;
    //途经城市大于1 或者 当前城市无 TMC 信息，就隐藏
    
    //当路径线只有一条并且为最短路径，则隐藏提示框
    GHGUIDEROUTE routeList[4] = {0};
    int count = 0;
    [MWRouteGuide GetGuideRouteList:routeList count:4 returnCount:&count];
    BOOL isShort = NO;
    if(count == 1)
    {
        NSArray *array = [MWRouteCalculate GetComposeOptions:routeList[0]];
        if(array.count == 1 && [[array objectAtIndex:0] integerValue] == 3)
        {
            isShort = YES;
        }
    }
    NSLog(@"%d",[MWJourneyPoint getJourneyPointWithID:0].lAdminCode);
    MWPoi *poi = [MWJourneyPoint getJourneyPointWithID:0];
    int adCode = 0;
    adCode = poi.lAdminCode;
    //如果 为 0，就通过经纬度获取 admincode
    if(adCode == 0)
    {
        GCOORD rd = {0};
        rd.x = poi.longitude;
        rd.y = poi.latitude;
        adCode = [MWAdminCode GetAdminCode:rd];
    }
    if(num > 1
       || ![MWAdminCode isTmcCityWith:adCode]
       || isShort)
    {
        _imageViewAvoidAll.hidden = YES;
    }
    
    
    
    _labelTipsText = [[UILabel alloc]init];
    _labelTipsText.backgroundColor = [UIColor clearColor];
    _labelTipsText.textColor = RGBCOLOR(34.0f, 113.0f, 167.0f);
    _labelTipsText.font = [UIFont systemFontOfSize:isiPhone ?  12.0f: 18.0f];
    _labelTipsText.textAlignment = NSTextAlignmentCenter;
    [_imageViewAvoidAll addSubview:_labelTipsText];
    [_labelTipsText release];
    
    _buttonOpenAvoid =  [UnderLineButton buttonWithType:UIButtonTypeCustom];
    _buttonOpenAvoid.tag = ROUTEPLANNING_BUTTON_AVOID;
    _buttonOpenAvoid.backgroundColor = [UIColor clearColor];
    _buttonOpenAvoid.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [_buttonOpenAvoid setTitleColor:RGBCOLOR(0.0f, 105.0f, 219.0f)
                           forState:UIControlStateNormal];
    _buttonOpenAvoid.titleLabel.font = [UIFont systemFontOfSize:isiPhone ? 12.0f:18.0f];
    _buttonOpenAvoid.hidden = YES;//默认隐藏
    [_buttonOpenAvoid addTarget:self
                         action:@selector(buttonOpenAvoidPress:)
               forControlEvents:UIControlStateHighlighted];
    [_buttonOpenAvoid setTitle:STR(@"Route_OpenAvoid", Localize_RouteOverview)
                      forState:UIControlStateNormal];
    [_imageViewAvoidAll addSubview:_buttonOpenAvoid];
    
//    [contentString release];
    
    [self isUsedAvoid:NO];
}

/*!
  @brief    打开躲避拥堵，算路
  @param
  @author   by bazinga
  */
- (void) buttonOpenAvoidPress:(id) sender
{

    [self buttonAction:sender];
}



- (void) isUsedAvoid:(BOOL) usedAvoid
{
    _buttonOpenAvoid.hidden = usedAvoid;

    [self setLableTipsText];
    [self setAvoidFrame];
}


- (void) setLableTipsText
{
    if(_buttonOpenAvoid.hidden)
    {
        _labelTipsText.text = STR(@"Route_AvoidTipsUsed", Localize_RouteOverview);
    }
    else
    {
        _labelTipsText.text = STR(@"Route_NoAvoidTips", Localize_RouteOverview);
    }
}

- (void) setAvoidFrame
{
    if(_buttonOpenAvoid.hidden == YES)
    {
        _labelTipsText.textAlignment = NSTextAlignmentCenter;
    }
    else
    {
        _labelTipsText.textAlignment = NSTextAlignmentRight;
    }
    if(Interface_Flag == 0)
    {
        float imageViewAllHeight = isiPhone ?  30.0f : 45.0f;
        float imageViewAllY =  _buttonBeginNavi.frame.origin.y - ROUTE_BOTTOM_BUTTON_HEIGHT - imageViewAllHeight + 3.0f;
        
        [_imageViewAvoidAll setFrame:CGRectMake(0, imageViewAllY,MAIN_POR_WIDTH, imageViewAllHeight)];
    }
    else
    {
        float imageViewAllHeight = isiPhone ?  30.0f : 45.0f;
        float imageViewAllY =  MAIN_LAND_HEIGHT - ROUTE_BOTTOM_BUTTON_HEIGHT - imageViewAllHeight + 3.0f;

        [_imageViewAvoidAll setFrame:CGRectMake(0, imageViewAllY, MAIN_LAND_WIDTH,imageViewAllHeight)];
    }
    
    if(_buttonOpenAvoid.hidden == YES)
    {
        [_labelTipsText setFrame:CGRectMake(0,
                                            0,
                                            _imageViewAvoidAll.frame.size.width,
                                            _imageViewAvoidAll.frame.size.height)];
    }
    else
    {
        CGSize labelTipsTextSize = [_labelTipsText.text
                                    sizeWithFont:_labelTipsText.font];
        CGSize openAvoidTextSize = [_buttonOpenAvoid.titleLabel.text
                                    sizeWithFont:_buttonOpenAvoid.titleLabel.font];
        
        float labelTipsWidth = (Interface_Flag == 0  ? MAIN_POR_WIDTH : MAIN_LAND_WIDTH) / 2 + labelTipsTextSize.width/2 - openAvoidTextSize.width / 2;
        
        [_labelTipsText setFrame:CGRectMake(0,
                                            0,
                                            labelTipsWidth,
                                            _imageViewAvoidAll.frame.size.height)];
        [_buttonOpenAvoid setFrame:CGRectMake(labelTipsWidth,
                                              0,
                                              _imageViewAvoidAll.frame.size.width - labelTipsWidth,
                                              _imageViewAvoidAll.frame.size.height)];
    }

    [_buttonOpenAvoid setNeedsDisplay];
}

/*!
  @brief    初始化滚动数据
  @param
  @author   by bazinga
  */
- (void) initScrollView
{
    _scrollerView = [[UIScrollView alloc]init];
    _scrollerView.showsHorizontalScrollIndicator = NO;
    _scrollerView.showsVerticalScrollIndicator = NO;
    _scrollerView.pagingEnabled = YES;
    _scrollerView.delegate = self;
    _scrollerView.bounces = NO;
    [self.view addSubview:_scrollerView];
    
    _pageControl = [[CustomPageControl alloc] init];
    _pageControl.backgroundColor = [UIColor clearColor];
    _pageControl.hidesForSinglePage = YES;
    _pageControl.userInteractionEnabled = NO;
    _pageControl.numberOfPages = 0;     //几个小点
    [self.view addSubview:_pageControl];


    [_scrollerView release];
    [_pageControl release];
}

//滑动
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
   [self scrollViewDidEndScrollingWithScroll:scrollView];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [self scrollViewDidEndScrollingWithScroll:scrollView];
}

- (void) scrollViewDidEndScrollingWithScroll:(UIScrollView *)scrollView
{
    int index = fabs(scrollView.contentOffset.x) / scrollView.frame.size.width;   //当前是第几个视图
    _pageControl.currentPage = index;
    [self choseRoute:index];
}


@end

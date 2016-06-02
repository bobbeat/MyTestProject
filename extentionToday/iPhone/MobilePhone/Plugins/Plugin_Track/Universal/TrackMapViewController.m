//
//  TrackMapViewController.m
//  AutoNavi
//
//  Created by gaozhimin on 13-9-13.
//
//

#import "TrackMapViewController.h"
#import "PaintingView.h"
#import "MWPreference.h"
#import "MWMapOperator.h"
#import "MWDefine.h"
#import "ANParamValue.h"
#import "MainDefine.h"

@interface TrackMapViewController ()<PaintingViewDelegate>
{
    PaintingView* _paintingView;
    UIButton *_buttonNarrowMap,*_buttonEnlargeMap; //缩小，放大 比例尺按钮
    UIButton *_buttonBackCar;       //回车位按钮
    
    UIButton *_buttonSwitchTripDirect;          //指南针方向按钮
    BOOL bLongPressed; //是否长按放大，缩小
    NSTimer *inc_timer, *dec_timer;
    UIButton *_labelMeter;      //大小按钮下的地图比例尺大小图片
    UIButton *_currentLoadName;  //当前道路名
    
    GMAPVIEWMODE _mapMode ;
}

@end

@implementation TrackMapViewController

#pragma mark -
#pragma mark viewcontroller
- (id)init
{
	self = [super init];
	if (self)
	{
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationReceived:) name:NOTIFY_SHOWMAP object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleUIUpdate:) name:NOTIFY_HandleUIUpdate object:nil];
        _mapMode = GMAPVIEW_MODE_NORTH;
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
    
    self.title = STR(@"TrackMapView", Localize_Track);
    self.navigationItem.leftBarButtonItem = LEFTBARBUTTONITEM(nil, @selector(GoBack:));
    
    [[MWPreference sharedInstance]setValue:PREF_MAPSHOWCURSOR Value:0];
    
}
// Called when the view is about to made visible. Default does nothing
- (void)viewWillAppear:(BOOL)animated
{
    _paintingView = [MapViewManager ShowMapViewInController:self]; //要放在调用 [super viewWillAppear:animated] 之前，切换多次地图后，会造成无法放大缩小
	[super viewWillAppear:animated];
    
    GMAPVIEWINFO mapViewInfo = {0};
    
    if([[MWMapOperator sharedInstance] MW_GetMapViewInfo:GMAP_VIEW_TYPE_MAIN MapViewInfo:&mapViewInfo] == GD_ERR_OK)
    {
        if(mapViewInfo.eMapMode != _mapMode)
        {
            _mapMode = mapViewInfo.eMapMode;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

                [[MWMapOperator sharedInstance]  MW_SetMapViewMode:GMAP_VIEW_TYPE_MAIN Type:0 MapMode:GMAPVIEW_MODE_NORTH];
            });
        }
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
    BOOL isTrackLoad = [MWTrack TrackOperationWithID:10 Index:0];
    if (isTrackLoad)
    {
        [MWTrack TrackOperationWithID:9 Index:0];
    }
    

    [super viewWillDisappear:animated];
}

// Called after the view was dismissed, covered or otherwise hidden. Default does nothing
-(void)viewDidDisappear:(BOOL)animated;
{
    [[MWMapOperator sharedInstance] MW_GoToCCP];
    [[MWPreference sharedInstance]setValue:PREF_MAPSHOWCURSOR Value:1];
    if(_mapMode != GMAPVIEW_MODE_NORTH)
    {
        [[MWMapOperator sharedInstance]  MW_SetMapViewMode:GMAP_VIEW_TYPE_MAIN Type:0 MapMode:_mapMode];
    }
    [super viewDidDisappear:animated];
}

#pragma mark -
#pragma mark control related
//初始化控件
-(void) initControl
{
    _paintingView = [MapViewManager ShowMapViewInController:self];
    
    //放大，缩小
    bLongPressed = NO;
    
	_buttonEnlargeMap = [[self ANbuttonInCondition:BUTTON_ENLARGEMAP] retain];
    UILongPressGestureRecognizer *longPress =[[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(ZoomInLongPressed:)]autorelease];
	longPress.minimumPressDuration =0.2;
	[_buttonEnlargeMap addGestureRecognizer:longPress];
	[_buttonEnlargeMap addTarget:self action:@selector(decFun:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_buttonEnlargeMap];[_buttonEnlargeMap release];
    
    _buttonNarrowMap = [[self ANbuttonInCondition:BUTTON_NARROWMAP] retain];
    longPress =[[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(ZoomOutLongPressed:)]autorelease];
	longPress.minimumPressDuration =0.2;
	[_buttonNarrowMap addGestureRecognizer:longPress];
	[_buttonNarrowMap addTarget:self action:@selector(incFun:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_buttonNarrowMap];[_buttonNarrowMap release];
    
    //GPS-比例尺
	_labelMeter =  [[self buttonInCondition:56] retain];
    [_labelMeter.titleLabel setFont:[UIFont systemFontOfSize:10]];
	[self.view addSubview:_labelMeter];[_labelMeter release];
    [_labelMeter setTitleColor:GETSKINCOLOR(MAIN_DAY_METER_COLOR) forState:UIControlStateNormal];
    if([[MWPreference sharedInstance] getValue:PREF_DAYNIGHTMODE] == 1)
    {
        [_labelMeter setTitleColor:GETSKINCOLOR(MAIN_NIGHT_METER_COLOR) forState:UIControlStateNormal];
    }
    else
    {
        [_labelMeter setTitleColor:GETSKINCOLOR(MAIN_DAY_METER_COLOR) forState:UIControlStateNormal];
    }
    _buttonBackCar = [self buttonInCondition:BUTTON_BACK_CAR];
	[self.view addSubview:_buttonBackCar];
    
    //地图模式切换
	_buttonSwitchTripDirect = [[self buttonInCondition:BUTTON_SET_VIEWMODE] retain];
	[self.view addSubview:_buttonSwitchTripDirect];[_buttonSwitchTripDirect release];
    
    _currentLoadName = [self createButtonWithTitle:nil normalImage:@"trackCurrentRoadName.png" heightedImage:nil tag:0 strechParamX:8 strechParamY:21];
    [self.view addSubview:_currentLoadName];
    [_currentLoadName setTitleColor:TEXTCOLOR forState:UIControlStateNormal];
}

//调整控件竖屏坐标和图片
-(void)changePortraitControlFrameWithImage
{
    CGSize size = self.view.bounds.size;
    [_paintingView setmyFrame:self.view.bounds];
    [[MWPreference sharedInstance] setValue:PREF_DISPLAY_ORIENTATION Value:1];
    int topOffSet = 44;
    if (isPad)
    {
        //指南针方向
        CGAffineTransform at =CGAffineTransformMakeRotation(0);//设置Frame前，先将角度旋转为0度，要不会发生变形
        [_buttonSwitchTripDirect setTransform:at];
        [_buttonSwitchTripDirect setFrame:CGRectMake(0.0f,0.0f,60.0f, 60.0)];
        [_buttonSwitchTripDirect setCenter:CGPointMake(38.0f, 122.0f - 44.0f - 30.0f)];
        
        //放大，缩小
        [_buttonEnlargeMap setFrame:CGRectMake(0.0f, 0.0f, 60.0f, 63.0f)];
        [_buttonEnlargeMap setCenter:CGPointMake(APPWIDTH-37.5f, APPHEIGHT-213.0f)];
        if([[UIScreen mainScreen] scale] == 2)
        {
            [_buttonNarrowMap setFrame:CGRectMake(0,0, 60.0f, 63.0f)];
            [_buttonNarrowMap setCenter:CGPointMake(APPWIDTH-37.5f, APPHEIGHT-150.0f)];
        }
        else
        {
            [_buttonNarrowMap setFrame:CGRectMake(_buttonEnlargeMap.frame.origin.x,_buttonEnlargeMap.frame.origin.y + 62.0f , 60.0f, 63.0f)];
        }
        
        [_labelMeter setFrame:CGRectMake(0.0f, 0.0f, 50.0f, 20.0f)];
        [_labelMeter setCenter:CGPointMake(APPWIDTH-37.5f, APPHEIGHT-106.5f)];
        _labelMeter.titleLabel.font = [UIFont systemFontOfSize:13];
        
        //回车位
        [_buttonBackCar setFrame:CGRectMake(0.0f, 0.0f, 60.0f, 60.0f)];
        [_buttonBackCar setCenter:CGPointMake(38.0f,APPHEIGHT - 147.5f)];
        
        //底栏按钮坐标设置 //导航，常用，附近，设置
        [_currentLoadName setFrame:CGRectMake(0, 0, 308.0f, 48.0f)];
        [_currentLoadName setCenter:CGPointMake(size.width / 2, size.height - 27)];
    }
    else
    {
        //指南针方向
        CGAffineTransform at =CGAffineTransformMakeRotation(0);//设置Frame前，先将角度旋转为0度，要不会发生变形
        [_buttonSwitchTripDirect setTransform:at];
        [_buttonSwitchTripDirect setFrame:CGRectMake(0.0f,0.0f,40.0f, 40.0f)];
        [_buttonSwitchTripDirect setCenter:CGPointMake(25.5, 76.5f - topOffSet)];
        
        

        //放大，缩小
        [_buttonEnlargeMap setFrame:CGRectMake(0.0f, 0.0f, 40.0f, 42.0f)];
        [_buttonEnlargeMap setCenter:CGPointMake(APPWIDTH-26.0f, APPHEIGHT-140.0f - topOffSet)];
        
        [_buttonNarrowMap setFrame:CGRectMake(0.0f, 0.0f, 40.0f, 42.0f)];
        [_buttonNarrowMap setCenter:CGPointMake(APPWIDTH-26.0f, APPHEIGHT-98.0f - topOffSet)];
        
        [_labelMeter setFrame:CGRectMake(0.0f, 0.0f, 36.0f, 12.0f)];
        [_labelMeter setCenter:CGPointMake(APPWIDTH-26.0f, APPHEIGHT-68.0f - topOffSet)];
        
        //回车位
        [_buttonBackCar setFrame:CGRectMake(0.0f, 0.0f, 40.0f, 40.0f)];
        [_buttonBackCar setCenter:CGPointMake(25.5,APPHEIGHT - 97.0f - topOffSet)];
        
        //底栏按钮坐标设置 //导航，常用，附近，设置
        [_currentLoadName setFrame:CGRectMake(0, 0, 308.0f, 48.0f)];
        [_currentLoadName setCenter:CGPointMake(size.width / 2, size.height - 27)];
    }

    [[MWMapOperator sharedInstance] MW_ShowMapView:GMAP_VIEW_TYPE_MAIN WithParma1:0 WithParma2:0 WithParma3:0];
    [self reloadEnlargeAndNarrowImage];
}

//调整控件横屏坐标和图片
-(void)changeLandscapeControlFrameWithImage
{
    CGSize size = self.view.bounds.size;
    [_paintingView setmyFrame:self.view.bounds];
    [[MWPreference sharedInstance] setValue:PREF_DISPLAY_ORIENTATION Value:0];
    int topOffSet = 44;
    if (isPad)
    {
        //指南针方向
        
        //指南针方向
        CGAffineTransform at =CGAffineTransformMakeRotation(0);//设置Frame前，先将角度旋转为0度，要不会发生变形
        [_buttonSwitchTripDirect setTransform:at];
        [_buttonSwitchTripDirect setFrame:CGRectMake(0.0f,0.0f,60.0f, 60.0)];
        [_buttonSwitchTripDirect setCenter:CGPointMake(38.0f, 122.0f - 44.0f-30.0f)];
        
        //放大，缩小
        [_buttonEnlargeMap setFrame:CGRectMake(0.0f, 0.0f, 60.0f, 63.0f)];
        [_buttonEnlargeMap setCenter:CGPointMake(APPHEIGHT-37.5f, CONTENTHEIGHT_H-213.0f)];
        if([[UIScreen mainScreen] scale] == 2)
        {
            [_buttonNarrowMap setFrame:CGRectMake(0,0, 60.0f, 63.0f)];
            [_buttonNarrowMap setCenter:CGPointMake(APPHEIGHT-37.5f, CONTENTHEIGHT_H-150.0f)];
        }
        else
        {
            [_buttonNarrowMap setFrame:CGRectMake(_buttonEnlargeMap.frame.origin.x,
                                                  _buttonEnlargeMap.frame.origin.y + 62.0f ,
                                                  60.0f,
                                                  63.0f)];
        }
        
        [_labelMeter setFrame:CGRectMake(0.0f, 0.0f, 50.0f, 20.0f)];
        [_labelMeter setCenter:CGPointMake(APPHEIGHT-37.5f, CONTENTHEIGHT_H-106.5f- 6.0f)];
        _labelMeter.titleLabel.font = [UIFont systemFontOfSize:13];
        
        //回车位
        [_buttonBackCar setFrame:CGRectMake(0.0f, 0.0f, 60.0f, 60.0f)];
        [_buttonBackCar setCenter:CGPointMake(38.0f,CONTENTHEIGHT_H - 147.5f )];
        
        
        //底栏按钮坐标设置
        [_currentLoadName setFrame:CGRectMake(0, 0, 423.0f, 48.0f)];
        [_currentLoadName setCenter:CGPointMake(size.width / 2, size.height - 27.0f)];
    }
    else
    {
        topOffSet = 32;
        //指南针方向
        CGAffineTransform at =CGAffineTransformMakeRotation(0);
        [_buttonSwitchTripDirect setTransform:at];
        [_buttonSwitchTripDirect setFrame:CGRectMake(0.0f,0.0f,40.0f, 40.0f)];
        [_buttonSwitchTripDirect setCenter:CGPointMake(26.0f, 78.5f - topOffSet)];
        CGFloat enlargeAndNarrowWidth = 40.0f;
        CGFloat enlargeToNarrow = 6.0f;
        CGFloat buttonBoundary = size.width - BUTTON_BOUNDARY;

        [_buttonNarrowMap setFrame:CGRectMake(0.0f, 0.0f, enlargeAndNarrowWidth, enlargeAndNarrowWidth)];
        [_buttonNarrowMap setCenter:CGPointMake(buttonBoundary,
                                                 size.height - 27.0f)];
        
        [_buttonEnlargeMap setFrame:CGRectMake(0.0f, 0.0f, enlargeAndNarrowWidth, enlargeAndNarrowWidth)];
        [_buttonEnlargeMap setCenter:CGPointMake(APPHEIGHT - _buttonNarrowMap.frame.size.width - 2 * enlargeToNarrow - _buttonEnlargeMap.frame.size.width / 2,
                                                  size.height - 27.0f)];
        
        [_labelMeter setFrame:CGRectMake(0.0f, 0.0f, 36.0f, 12.0f)];
        [_labelMeter setCenter:CGPointMake(buttonBoundary,
                                           _buttonNarrowMap.frame.origin.y - enlargeToNarrow - _labelMeter.frame.size.height / 2)];
        _labelMeter.titleLabel.font = [UIFont systemFontOfSize:10.0f];
        
        //回车位
        [_buttonBackCar setFrame:CGRectMake(0.0f, 0.0f, 40.0f, 40.0f)];
        [_buttonBackCar setCenter:CGPointMake(BUTTON_BOUNDARY,  size.height - 27.0f)];

        
        //底栏按钮坐标设置 480 - 104 = 376
        [_currentLoadName setFrame:CGRectMake(0, 0, APPHEIGHT - 200.0f, 48.0f)];
        [_currentLoadName setCenter:CGPointMake(size.width / 2, size.height - 27.0f)];
    }
    
    [[MWMapOperator sharedInstance] MW_ShowMapView:GMAP_VIEW_TYPE_MAIN WithParma1:0 WithParma2:0 WithParma3:0];
    [self reloadEnlargeAndNarrowImage];
}

//改变控件文本
-(void)changeControlText
{
    
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
    
    UIImage *image = IMAGE(@"mainBackCar.png", IMAGEPATH_TYPE_2);
    UIImage *imagePress =IMAGE(@"mainBackCarPress.png", IMAGEPATH_TYPE_2);
    if(Interface_Flag == 1 && isiPhone)
    {
        UIImage *tempImage = IMAGE(@"mainBackCarLand.png", IMAGEPATH_TYPE_2);
        UIImage *tempImagePress = IMAGE(@"mainBackCarLandPress.png", IMAGEPATH_TYPE_2);
        image =  tempImage== nil ?  image :  tempImage;
        imagePress = tempImagePress == nil ? imagePress : tempImagePress;
    }
    
    [_buttonBackCar setBackgroundImage:image forState:UIControlStateNormal];
    [_buttonBackCar setBackgroundImage:imagePress forState:UIControlStateHighlighted];
}
#pragma mark -
#pragma mark control action

- (void)buttonAction:(UIButton *)button
{
    switch (button.tag)
    {

        case BUTTON_BACK_CAR:
        {
            [self Action_GoToCCP];
        }
            break;
            
        default:
            break;
    }
}

//回车位
- (void)Action_GoToCCP
{
    if ([[ANParamValue sharedInstance] isMove])
    {
        [[MWMapOperator sharedInstance] MW_GoToCCP];
    }
}

- (void)GoBack:(id)sender
{
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark logic relate
-	(void)landscapeLogic
{
    
    
}
-	(void)portraitLogic
{
    
    
}

//自定义button初始化
- (ANButton *)ANbuttonInCondition:(NSInteger)condition {
	
	ANButton *ANbutton;
	
	NSString *title;
	NSString *imageTopName;
	UIImage *image;
	UIImage *imagePressed;
	CGFloat textOffsetValue = 13.0f;
    switch (condition)
    {
            
        case BUTTON_ENLARGEMAP://放大
        {
            title = nil;
            imageTopName = nil;
            image = IMAGE(@"mainEnlargeMap.png", IMAGEPATH_TYPE_2);
            imagePressed = IMAGE(@"mainEnlargeMapPress.png", IMAGEPATH_TYPE_2);
            
            
        }
            break;
        case BUTTON_NARROWMAP://缩小
        {
            title = nil;
            imageTopName = nil;
            image = IMAGE(@"mainNarrow.png", IMAGEPATH_TYPE_2);
            imagePressed = IMAGE(@"mainNarrowPress.png", IMAGEPATH_TYPE_2);
            
        }
            break;
        
        default:
            break;
    }
	
	UIImage *imageTop = IMAGE(imageTopName, IMAGEPATH_TYPE_1) ;
	ANbutton = [self createANButtonWithTitle:title image:image imagePressed:imagePressed imageTop:imageTop tag:condition textOffsetValue:textOffsetValue];
	
	title = nil;
	imageTopName = nil;
	image = nil;
	imagePressed = nil;
	imageTop = nil;
	
	return ANbutton;
}

//button初始化
- (UIButton *)buttonInCondition:(NSInteger)condition {
	
	UIButton *button;
	NSString *titleT;
	NSString *normalImage;
	NSString *heightedImage;
	IMAGEPATHTYPE imageType = IMAGEPATH_TYPE_1;
	switch (condition)
	{
		case BUTTON_SET_VIEWMODE:
		{//地图模式切换
			titleT = nil;
            normalImage = @"mainDirect.png";
            heightedImage = @"mainDirect.png";
            //			int caseValue = [[MWPreference sharedInstance] getValue:PREF_MAPVIEWMODE];
            //			switch (caseValue)
            //			{
            //				case GMAPVIEW_MODE_NORTH:
            //					normalImage = @"view_fun-V.png";
            //					break;
            //
            //				case GMAPVIEW_MODE_CAR:
            //					normalImage = @"car_north_1.png";
            //					break;
            //
            //				case GMAPVIEW_MODE_3D:
            //					normalImage = @"3D_1.png";
            //					break;
            //			}
		}
			break;
        case BUTTON_GUIDEPOST://高速路牌
		{
			titleT = nil;
			normalImage = @"showGuidePost.png";
			heightedImage = nil;
		}
			break;
        case BUTTON_ZOOMDIS:
		{//放大路口距离
			titleT = nil;
			normalImage = @"zoomDis.png";
			heightedImage = nil;
		}
			break;
        case BUTTON_ZOOMROADNAME:
		{//放大路口道路名
			titleT = nil;
			normalImage = @"zoomRoadName.png";
			heightedImage = nil;
		}
			break;
			
		case BUTTON_STOPNAVI:
		{
			titleT = nil;
			normalImage = @"mainNaviDelButton.png";
			heightedImage = @"mainNaviDelButtonPress.png";
		}
			break;
        case BUTTON_LIST_MENU:
        {
            titleT = nil;
			normalImage = @"mainNaviListButton.png";
			heightedImage = @"mainNaviListButtonPress.png";
        }
            break;
			
		case BUTTON_DRIVECOMPUTER:
		{
			titleT = nil;
			normalImage = nil;
			heightedImage = nil;
		}
			break;
        case BUTTON_NEXTROADNAME://下个路口名
		{
			titleT = nil;
			normalImage = nil;
			heightedImage = nil;
		}
			break;
        case 56:// 比例尺
		{
			titleT = nil;
			normalImage = @"mainScaleIcon.png";
			heightedImage = nil;
		}
			break;
        case  BUTTON_MODE_SWITCH:
        {
            titleT = nil;
            normalImage = @"mainChangeMode.png";
            heightedImage = nil;
        }
            break;
        case BUTTON_BACK_CAR:
        {
            titleT = nil;
            normalImage = @"mainBackCar.png";
            heightedImage = @"mainBackCarPress.png";
            imageType = IMAGEPATH_TYPE_2;
        }
            break;
        case BUTTON_GET_POIINFO:
        {
            titleT = nil;
            normalImage = nil;
            heightedImage = nil;
        }
            break;
		default:
        {
            NSLog(@"");
        }
            break;
	}
	
	button = [self createButtonWithTitle:titleT normalImage:normalImage heightedImage:heightedImage tag:condition withImageType:imageType];
	titleT = nil;
	normalImage = nil;
	heightedImage = nil;
	return button;
}
//控件信息显示控制
- (void)viewInfoInCondition:(NSInteger)condition {
    
	switch (condition)
	{
		case 0:
		{
			//获取当前比例尺
            
            [_currentLoadName setTitle:[[MWMapOperator sharedInstance] GetCurrentRoadName:GMAP_VIEW_TYPE_MAIN] forState:UIControlStateNormal];
			[_labelMeter setTitle:[[MWMapOperator sharedInstance] GetCurrentScale] forState:UIControlStateNormal];
            
//            if ([[MWPreference sharedInstance] getValue:PREF_MAPVIEWMODE] == MAP_3D) {
//                int DScale = [[MWMapOperator sharedInstance] GMD_Get3DScale];
//                
//                if (DScale == 90)
//                {
//                    _buttonEnlargeMap.alpha = ALPHA_HIDEN;
//                    _buttonNarrowMap.alpha = ALPHA_APEAR;
//                    
//                }
//                else if ((Interface_Flag == 0 && DScale == 20) || (Interface_Flag == 1 && DScale == 10) )
//                {
//                    _buttonEnlargeMap.alpha = ALPHA_APEAR;
//                    _buttonNarrowMap.alpha = ALPHA_HIDEN;
//                }
//                else {
//                    _buttonEnlargeMap.alpha = ALPHA_APEAR;
//                    _buttonNarrowMap.alpha = ALPHA_APEAR;
//                }
//                
//            }
//            else {
//                
                if ([_labelMeter.titleLabel.text isEqualToString:@"15m"])
                {
                    _buttonEnlargeMap.alpha = ALPHA_HIDEN;
                    _buttonNarrowMap.alpha = ALPHA_APEAR;
                    
                }
                else if ([_labelMeter.titleLabel.text isEqualToString:@"500km"])
                {
                    _buttonEnlargeMap.alpha = ALPHA_APEAR;
                    _buttonNarrowMap.alpha = ALPHA_HIDEN;
                }
                else {
                    _buttonEnlargeMap.alpha = ALPHA_APEAR;
                    _buttonNarrowMap.alpha = ALPHA_APEAR;
                }
                
//            }
        }
    }
    [self setSwitchTripDirect];
}
#pragma mark -
#pragma mark =====放大，缩小=====
- (void)ZoomInLongPressed:(UILongPressGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan)
	{
        bLongPressed = YES;
		inc_timer = [NSTimer scheduledTimerWithTimeInterval:0.2f
                                                     target:self
                                                   selector:@selector(decFun:)
                                                   userInfo:nil
                                                    repeats:YES];
        [inc_timer fire];
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
        bLongPressed = YES;
		dec_timer = [NSTimer scheduledTimerWithTimeInterval:0.2f
                                                     target:self
                                                   selector:@selector(incFun:)
                                                   userInfo:nil
                                                    repeats:YES];
        [dec_timer fire];
	}
	else if (recognizer.state == UIGestureRecognizerStateChanged)
	{
        
	}else 	if (recognizer.state == UIGestureRecognizerStateEnded)
	{
        [self Stop_Idec:_buttonNarrowMap];
	}
}

- (void)decFun:(NSTimer *)timer
{
    if (bLongPressed)
    {
        bLongPressed = NO;
        return;
    }
//    if ([[MWPreference sharedInstance] getValue:PREF_MAPVIEWMODE] == MAP_3D) {
//        int DScale = [[MWMapOperator sharedInstance] GMD_Get3DScale];
//        if (DScale == 90)
//        {
//            if (inc_timer != nil) {
//                [inc_timer invalidate];
//                inc_timer = nil;
//            }
//            return;
//        }
//    }
//    else {
        if ([_labelMeter.titleLabel.text isEqualToString:@"15m"])
        {
            if (inc_timer != nil) {
                [inc_timer invalidate];
                inc_timer = nil;
            }
            return;
        }
//    }
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_TOUCH object:[NSNumber numberWithBool:NO]];
    [[MWMapOperator sharedInstance] MW_ZoomMapView:GMAP_VIEW_TYPE_MAIN ZoomFlag:GSETMAPVIEW_LEVEL_IN ZoomLevel:0];
}


- (void)incFun:(NSTimer *)timer
{
    
    if (bLongPressed)
    {
        bLongPressed = NO;
        return;
    }
//    if ([[MWPreference sharedInstance] getValue:PREF_MAPVIEWMODE] == MAP_3D) {
//        int DScale = [[MWMapOperator sharedInstance] GMD_Get3DScale];
//        if ((Interface_Flag == 0 && DScale == 20) || (Interface_Flag == 1 && DScale == 10))
//        {
//            if (dec_timer != nil) {
//                [dec_timer invalidate];
//                dec_timer = nil;
//            }
//            return;
//        }
//    }
//    else {
//        
        if ([_labelMeter.titleLabel.text isEqualToString:@"500km"])
        {
            if (dec_timer != nil) {
                [dec_timer invalidate];
                dec_timer = nil;
            }
            return;
        }
//    }
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_TOUCH object:[NSNumber numberWithBool:NO]];
    
    [[MWMapOperator sharedInstance] MW_ZoomMapView:GMAP_VIEW_TYPE_MAIN ZoomFlag:GSETMAPVIEW_LEVEL_OUT ZoomLevel:0];
}


- (void)Stop_Idec:(id)sender {
	
	NSLog(@"Stop_Idec");
	UIButton *button = (UIButton *)sender;
	if (button.tag==BUTTON_ENLARGEMAP)
	{
		if (inc_timer != nil) {
            [inc_timer invalidate];
            inc_timer = nil;
        }
	}
	else if (button.tag==BUTTON_NARROWMAP)
	{
        if (dec_timer != nil) {
            [dec_timer invalidate];
            dec_timer = nil;
        }
	}
}

#pragma mark -
#pragma mark notification
-(void)notificationReceived:(NSNotification*) notification
{

	if ([notification.name isEqual:NOTIFY_SHOWMAP])
	{
        [_paintingView swapBuffers];
	}
      

    [self viewInfoInCondition:0];

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

-(void) setSwitchTripDirect
{
    // NSLog(@"dis=%f,%f",provalue,pathDistance);
    //获取当前地图模式
    [_buttonSwitchTripDirect setBackgroundImage:IMAGE(@"mainDirect.png", IMAGEPATH_TYPE_2) forState:UIControlStateNormal];
    [_buttonSwitchTripDirect setBackgroundImage:IMAGE(@"mainDirect.png", IMAGEPATH_TYPE_2) forState:UIControlStateHighlighted];
    
    CGFloat angle = (M_PI / 180.0) * [[MWMapOperator sharedInstance] GetCarDirection:GMAP_VIEW_TYPE_MAIN];
    NSLog(@"%f",angle);
    CGAffineTransform at =CGAffineTransformMakeRotation(angle);
    [_buttonSwitchTripDirect setTransform:at];
    
}

//设置白天黑夜图片
- (void) setDayAndNightStyle
{
    
    [self setSwitchTripDirect];
    
    [_buttonEnlargeMap setBackgroundImage:IMAGE(@"mainEnlargeMap.png", IMAGEPATH_TYPE_2) forState:UIControlStateNormal];
    [_buttonEnlargeMap setBackgroundImage:IMAGE(@"mainEnlargeMapPress.png", IMAGEPATH_TYPE_2) forState:UIControlStateHighlighted];
    
    [_buttonNarrowMap setBackgroundImage:IMAGE(@"mainNarrow.png", IMAGEPATH_TYPE_2) forState:UIControlStateNormal];
    [_buttonNarrowMap setBackgroundImage:IMAGE(@"mainNarrowPress.png", IMAGEPATH_TYPE_2) forState:UIControlStateHighlighted];
}


@end

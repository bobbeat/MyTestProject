//
//  RoutePointViewController.m
//  AutoNavi
//
//  Created by jiangshu.fu on 13-8-21.
//
//

#import "RoutePointViewController.h"
#import "ANOperateMethod.h"
#import "ANParamValue.h"
#import "MWMapOperator.h"
#import "QLoadingView.h"
#import "BottomButton.h"
#import "GDPopPOI.h"
#import "RouteDetourViewController.h"
#import "CustomRoadInfo.h"
#import "CycleScrollView.h"
#import "MainDefine.h"

#pragma mark ---  节点查看顶部的黑色条条  ---
@interface RoutePointTopView : UIView

@property (nonatomic, retain)  UIImageView *imageViewLabels;     //前方道路和道路名的背景图
@property (nonatomic, retain)  UILabel *labelQianfang;          //前方道路四个大字
@property (nonatomic, retain) UILabel *labelEnter;              //“进入” label
@property (nonatomic, retain)  MoveTextLable *labelInfo;              //道路信息名称
@property (nonatomic, retain)  UIImageView *imageViewRight;      //右侧小箭头

@property (nonatomic, retain)  UIImageView *imageViewDirectAndDistance; //转向箭头和距离
@property (nonatomic, retain)  UIImageView *direImageView;              //转向箭头的图片
@property (nonatomic, retain)  UILabel *labelDistance;                  //距离下一个路口的距离
@property (nonatomic, retain)  UIImageView *imageViewLeft;      //左侧小箭头

@end

@implementation RoutePointTopView

@synthesize labelQianfang = _labelQianfang;
@synthesize direImageView = _direImageView;
@synthesize labelEnter = _labelEnter;
@synthesize labelDistance = _labelDistance;
@synthesize labelInfo = _labelInfo;
@synthesize imageViewDirectAndDistance = _imageViewDirectAndDistance;
@synthesize imageViewLabels = _imageViewLabels;
@synthesize imageViewLeft = _imageViewLeft;
@synthesize imageViewRight = _imageViewRight;

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        self.backgroundColor = GETSKINCOLOR(MAIN_LABEL_CLEARBACK_COLOR);
        self.autoresizesSubviews = YES;
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
        _imageViewLabels = [[UIImageView alloc]init];
        _labelQianfang = [[UILabel alloc] init];
        _labelEnter = [[UILabel alloc]init];
        _labelEnter.textColor = [UIColor grayColor];
        _labelEnter.backgroundColor = GETSKINCOLOR(MAIN_LABEL_CLEARBACK_COLOR);
        _direImageView = [[UIImageView alloc]init];
        _labelDistance = [[UILabel alloc]init];
        _labelInfo = [[MoveTextLable alloc] init];
        _labelInfo.textAlignment = NSTextAlignmentCenter;
        _labelInfo.textColor = GETSKINCOLOR(MAIN_NEXTLROAD_COLOR);
        _labelQianfang.font = [UIFont systemFontOfSize:15];
        _labelQianfang.textColor = [UIColor grayColor];
        _labelQianfang.backgroundColor = GETSKINCOLOR(MAIN_LABEL_CLEARBACK_COLOR);
        _labelQianfang.textAlignment = NSTextAlignmentLeft;
        _imageViewDirectAndDistance = [[UIImageView alloc]init];
        _imageViewRight = [[UIImageView alloc]init];
        _imageViewLeft = [[UIImageView alloc]init];
        
        [self addSubview:_imageViewLabels];
        [_imageViewLabels addSubview:_labelQianfang];
        [_imageViewLabels addSubview:_labelEnter];
        [_imageViewLabels addSubview:_labelInfo];
        [_imageViewLabels addSubview:_imageViewRight];
        
        [self addSubview:_imageViewDirectAndDistance];
        [_imageViewDirectAndDistance addSubview:_direImageView];
        [_imageViewDirectAndDistance addSubview:_labelDistance];
        [_imageViewDirectAndDistance addSubview:_imageViewLeft];
        
        _imageViewLabels.backgroundColor = GETSKINCOLOR(ROUTE_BLACK_TOP_BAR_COLOR);
        _imageViewDirectAndDistance.backgroundColor = GETSKINCOLOR(ROUTE_BLACK_TOP_BAR_COLOR);
        
        [_imageViewLabels release];
        [_labelQianfang release];
        [_labelEnter release];
        [_labelInfo release];
        [_imageViewDirectAndDistance release];
        [_direImageView release];
        [_labelDistance release];
        [_imageViewLeft release];
        [_imageViewRight release];
        
        
    }
    return self;
}


@end

#pragma mark ---  节点查看视图  ---

@interface RoutePointViewController ()<RouteCalDelegate>
{
    RoutePointTopView *_firstView;
    RoutePointTopView *_secondView;
    RoutePointTopView *_thirdView;
}

@end

@implementation RoutePointViewController

//可点击按钮的tag
typedef enum ROUTEPLANNING_BUTTON_TYPE
{
    ROUTEPLANNING_BUTTON_BEGIN = 17,   //开始导航
    ROUTEPLANNING_BUTTON_ADDTEMP,      //添加途经点
    ROUTEPLANNING_BUTTON_SIMU,         //模拟导航
    ROUTEPLANNING_BUTTON_DELETE,       //删除路线
    ROUTEPLANNING_BUTTON_COMPARE,      //对比路线
    ROUTEPLANNING_BUTTON_RECOMMEND,    //推荐路线
    ROUTEPLANNING_BUTTON_ECONOMY,      //经济路线
    ROUTEPLANNING_BUTTON_SHORT,        //最短路线
    ROUTEPLANNING_BUTTON_HIGH,         //最快路线
    ROUTEPLANNING_BUTTON_SHARE,        //微享按钮
    ROUTEPLANNING_BUTTON_RECOVER,      //返回地图的中心点
    ROUTEPLANNING_BUTTON_ENLARGE,      //放大
    ROUTEPLANNING_BUTTON_NARROW,       //缩小
    ROUTEPLANNING_BUTTON_LIST,          //路线详情

}ROUTEPLANNING_BUTTON_TYPE;

#define PRE_AND_NEXT_HEIGHT (isiPhone ? (110.0f + DIFFENT_STATUS_HEIGHT): (143.0f + DIFFENT_STATUS_HEIGHT))

@synthesize pointType = _pointType;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _isAppear = NO;
    }
    return self;
}


#pragma mark -
#pragma mark viewcontroller ,

- (id) init
{
    self = [super init];
    if(self)
    {
        _isAppear = NO;
    }
    return self;
}

- (id)initWithArry:(NSArray *)arrayRoadInfo withIndex:(int)index;
{
	self = [self init];
	if (self)
	{
		_arrayInfo = [[NSArray alloc]initWithArray:arrayRoadInfo];
        _index = index;
        _indexNumber = ((ManeuverInfo *)[arrayRoadInfo objectAtIndex:index]).nID;
        self.pointType = FROM_MAINVIEW;
        
       //初始化需要用到的对象
        count = 0;
        _timer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(addTime) userInfo:nil repeats:YES];
        [_timer fire];
        
        //底栏
        _imageViewNaviBottomBG = [[UIImageView alloc]init];
        _imageViewNaviBottomBG.backgroundColor = GETSKINCOLOR(ROUTE_BLACK_TOP_BAR_COLOR);;
        [self.view addSubview:_imageViewNaviBottomBG];
        [_imageViewNaviBottomBG release];
        _imageViewNaviBottomBG.userInteractionEnabled = YES;
        //从详情页面进入
        _buttonback = [UIButton buttonWithType:UIButtonTypeCustom];
        [_buttonback setImage:IMAGE(@"SimuStopBack.png", IMAGEPATH_TYPE_1) forState:UIControlStateNormal];
        _buttonback.imageEdgeInsets = UIEdgeInsetsMake((_buttonback.frame.size.height - _buttonback.imageView.image.size.height) / 2,
                                                       (_buttonback.frame.size.width - _buttonback.imageView.image.size.width) / 2,
                                                       (_buttonback.frame.size.height - _buttonback.imageView.image.size.height) / 2,
                                                       (_buttonback.frame.size.width - _buttonback.imageView.image.size.width) / 2);
        [_buttonback addTarget:self  action:@selector(backToDetail) forControlEvents:UIControlEventTouchUpInside];
        [_imageViewNaviBottomBG addSubview:_buttonback];
        
        _buttonBegin = [BottomButton buttonWithType:UIButtonTypeCustom];
        [_buttonBegin setTitle:STR(@"Route_PointBeginNavi", Localize_RouteOverview) forState:UIControlStateNormal];
        [_buttonBegin addTarget:self action:@selector(beginNavi) forControlEvents:UIControlEventTouchUpInside];
        [_buttonBegin setTitleColor:GETSKINCOLOR(ROUTE_POINT_BUTTON_COLOR) forState:UIControlStateNormal];
        [_buttonBegin setTitleColor:GETSKINCOLOR(ROUTE_POINT_BUTTON_CLICK_COLOR) forState:UIControlStateHighlighted];
        _buttonBegin.titleLabel.textAlignment = NSTextAlignmentCenter;
        [_imageViewNaviBottomBG addSubview:_buttonBegin];
        
        _buttonContinue = [BottomButton buttonWithType:UIButtonTypeCustom];
        [_buttonContinue setTitle:STR(@"Route_PointContinueNavi", Localize_RouteOverview) forState:UIControlStateNormal];
        [_buttonContinue setTitleColor:GETSKINCOLOR(ROUTE_POINT_BUTTON_COLOR) forState:UIControlStateNormal];
        [_buttonContinue setTitleColor:GETSKINCOLOR(ROUTE_POINT_BUTTON_CLICK_COLOR) forState:UIControlStateHighlighted];
        _buttonContinue.titleLabel.font = [UIFont systemFontOfSize:15];
        _buttonContinue.titleLabel.textAlignment = NSTextAlignmentCenter;
        [_buttonContinue addTarget:self action:@selector(continueNavi) forControlEvents:UIControlEventTouchUpInside];
        [_imageViewNaviBottomBG addSubview:_buttonContinue];
        _isCanclick = NO;//默认为 false
	}
	return self;
}


- (void)dealloc
{
    if(_timer)
    {
        [_timer invalidate];
        _timer = nil;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    //    [_poiTool release];
    CRELEASE(_arrayInfo);
    if (popPoiInfo) {
        [popPoiInfo release];
        popPoiInfo = nil;
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

    
    self.title = STR(@"RoutePointview_RouteTitle",Localize_RouteOverview);
    self.navigationItem.leftBarButtonItem = LEFTBARBUTTONITEM(STR(@"RoutePointview_RouteDetail",Localize_RouteOverview), @selector(GoBack:));
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationReceived:) name:NOTIFY_SHOWMAP object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationReceived:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationReceived:) name:NOTIFY_UPDATE_VIEWINFO object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleUIUpdate:) name:NOTIFY_HandleUIUpdate object:nil];
    
    [self initControl];
    if([[MWPreference sharedInstance] getValue:PREF_DAYNIGHTMODE] == 1)
    {
        [_labelMeter setTitleColor:GETSKINCOLOR(MAIN_NIGHT_METER_COLOR) forState:UIControlStateNormal];
    }
    else
    {
        [_labelMeter setTitleColor:GETSKINCOLOR(MAIN_DAY_METER_COLOR) forState:UIControlStateNormal];
    }
    
    self.pointType = _pointType;
    
    popPoiInfo = [[GDPopPOI alloc] initWithType:ViewPOIType_Traffic];
    popPoiInfo.delegate = self;
    popPoiInfo.topView = self.view;
    [popPoiInfo setHidden:YES];

}
// Called when the view is about to made visible. Default does nothing
- (void)viewWillAppear:(BOOL)animated
{
    drawingView  = [MapViewManager ShowMapViewInController:self]; //要放在调用 [super viewWillAppear:animated] 之前，切换多次地图后，会造成无法放大缩小
    [drawingView setRecognizeSwitchOn:EVENT_NONE];
    
	[super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    

    double delayInSeconds = 0.1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self viewCrossWithID:_indexNumber withAnimate:NO];
    });
    
    
    [MWRouteCalculate setDelegate:self];
}
// Called when the view has been fully transitioned onto the screen. Default does nothing

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _isAppear = YES;

    
}
// Called when the view is dismissed, covered or otherwise hidden. Default does nothing

-(void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self ];

     drawingView.delegate = nil;
    [MWRouteCalculate setDelegate:nil];
    [[MWMapOperator sharedInstance] MW_GoToCCP];
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
    drawingView  = [MapViewManager ShowMapViewInController:self];
    [drawingView setRecognizeSwitchOn:EVENT_NONE];
    NSMutableArray *arrayPage = [[NSMutableArray alloc] init];
    NSLog(@"for pre");
        NSLog(@"for after");
    
    _firstView = [[RoutePointTopView alloc] initWithFrame:CGRectMake(0, 0,
                                                                     self.view.frame.size.width,
                                                                     PRE_AND_NEXT_HEIGHT)];
    _secondView = [[RoutePointTopView alloc] initWithFrame:CGRectMake(0, 0,
                                                                      self.view.frame.size.width,
                                                                      PRE_AND_NEXT_HEIGHT)];
    _thirdView = [[RoutePointTopView alloc] initWithFrame:CGRectMake(0, 0,
                                                                     self.view.frame.size.width,
                                                                     PRE_AND_NEXT_HEIGHT)];
    int indexTwo = -1;
    [self setViewFrame:_firstView];
    [self setViewFrame:_secondView];
    [self setViewFrame:_thirdView];
    _cycleScrollView = [[CycleScrollView alloc]initWithFrame:CGRectMake(0, 0,
                                                                        self.view.frame.size.width,
                                                                        PRE_AND_NEXT_HEIGHT )
                                               withFirstView:_firstView
                                              withSecondView:_secondView
                                               withThirdView:_thirdView
                                                   withIndex:indexTwo];
    
    _cycleScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    if(_arrayInfo.count >= 3)   //节点数量大于等于3个
    {
        //index 在数组范围内
        if(_index > 0 && _index + 1 < _arrayInfo.count)
        {
            [self setTopViewByIndex:(_index - 1) withView:_firstView];
            [self setTopViewByIndex:(_index) withView:_secondView];
            [self setTopViewByIndex:(_index + 1) withView:_thirdView];
        }
        else if(_index == 0)    //index 是第一个节点
        {
            [self setTopViewByIndex:_index  withView:_firstView];
            [self setTopViewByIndex:_index + 1 withView:_secondView];
            [self setTopViewByIndex:_index + 2 withView:_thirdView];
            [_cycleScrollView scrollToFirst];
        }
        else if(_index + 1 == _arrayInfo.count) //index 是最后一个节点
        {
            [self setTopViewByIndex:_index - 2  withView:_firstView];
            [self setTopViewByIndex:_index - 1 withView:_secondView];
            [self setTopViewByIndex:_index withView:_thirdView];
            [_cycleScrollView ScrollToEnd];

        }
    }
    else if (_arrayInfo.count == 2) //节点数量等于2
    {
        if(_index == 0)
        {
            [self setTopViewByIndex:_index  withView:_firstView];
            [self setTopViewByIndex:_index + 1  withView:_secondView];
            [self setTopViewByIndex:_index  withView:_thirdView];
            _thirdView.tag = -1;
            indexTwo = 0;
            
        }
        else
        {
            [self setTopViewByIndex:_index - 1  withView:_firstView];
            [self setTopViewByIndex:_index withView:_secondView];
            [self setTopViewByIndex:_index  withView:_thirdView];
            _thirdView.tag = -1;
            indexTwo = 1;
        }
        [_cycleScrollView setIndex:indexTwo];
        if(indexTwo == 0)
        {
            [_cycleScrollView scrollToFirst];
        }
    }
    else    //小于两个节点，你逗我玩，起点终点就两个节点了 
    {
        _cycleScrollView.hidden = YES;
    }
    
    
    
    _cycleScrollView.delegate = self;
    [_firstView release];
    [_secondView release];
    [_thirdView release];
    _cycleScrollView.backgroundColor = GETSKINCOLOR(MAIN_LABEL_CLEARBACK_COLOR);

    [self.view addSubview:_cycleScrollView];
    [_cycleScrollView release];
    
    
    
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
    
    _buttonReal = [self createButtonWithTitle:nil
                                  normalImage:@"mainRealTraffic.png"
                                heightedImage:@"mainRealTrafficPress.png"
                                          tag:BUTTON_REAL_BUTTON
                                withImageType:IMAGEPATH_TYPE_2];
    
    [self.view addSubview:_buttonReal];
    _buttonReal.hidden = NO;
    
    
    //地图模式切换
	_buttonSwitchTripDirect = [self buttonInCondition:BUTTON_SET_VIEWMODE];
    [self.view addSubview:_buttonSwitchTripDirect];
    
    //GPS-比例尺
	_labelMeter =  [self buttonInCondition:56] ;
    [_labelMeter.titleLabel setFont:[UIFont systemFontOfSize:10]];
    [_labelMeter setTitleColor:GETSKINCOLOR(MAIN_DAY_METER_COLOR) forState:UIControlStateNormal];
    [self.view addSubview:_labelMeter];
    [arrayPage release];
}

- (void) setPointType:(RoutePointType)pointType
{
    if(pointType == FROM_DETAILVIEW)
    {
        if(_timer)
        {
            [_timer invalidate];
            _timer = nil;
        }
        _buttonContinue.hidden = YES;
        _buttonback.hidden = NO;
        _buttonBegin.hidden = NO;
    }
    else
    {
        _buttonContinue.hidden = NO;
        _buttonback.hidden = YES;
        _buttonBegin.hidden = YES;
    }
}


#pragma  mark ---  设置顶栏的界面显示  ---

- (void) setViewFrame:(RoutePointTopView *)view
{
    float englishHeight = fontType == 2 ? (isiPhone ? 5:5) : 0 ;
    if(isiPhone)
    {
        if(Interface_Flag == 0)
        {
            view.labelInfo.font = [UIFont boldSystemFontOfSize:24.0f];
            view.labelQianfang.font = [UIFont boldSystemFontOfSize:23.0f];
            view.labelQianfang.textAlignment = NSTextAlignmentRight;
            view.labelEnter.font = [UIFont systemFontOfSize:15.0f];
            CGSize enterSize = [view.labelEnter.text sizeWithFont:view.labelEnter.font];
            CGSize nextRoadSize = [view.labelInfo.text sizeWithFont:view.labelInfo.font];
            //导航顶部的半透明条
            [view.imageViewLabels setFrame:CGRectMake(0, 0, MAIN_POR_WIDTH - 103, 85 + DIFFENT_STATUS_HEIGHT)];
            [view.imageViewLabels setCenter:CGPointMake((MAIN_POR_WIDTH - 103)/ 2 + 103,
                                                       view.imageViewLabels.frame.size.height / 2 )];
            [view.labelEnter setFrame:CGRectMake(0, 0, enterSize.width + 2, enterSize.height + 2)];
            
            [view.labelQianfang setFrame:CGRectMake(0.0f, DIFFENT_STATUS_HEIGHT + 15, APPWIDTH - 103 - 37.0f, 26 + englishHeight)];
            float maxNextRoadWidth = view.imageViewLabels.frame.size.width - 37.0f - view.labelEnter.frame.size.width - 20.0f;
            nextRoadSize.width = (nextRoadSize.width > maxNextRoadWidth) ? maxNextRoadWidth : nextRoadSize.width;
            [view.labelInfo setFrame:CGRectMake(view.imageViewLabels.frame.size.width - nextRoadSize.width - 37.0f,
                                                42.0f + DIFFENT_STATUS_HEIGHT,
                                                nextRoadSize.width,
                                                25  + englishHeight)];
            float enterY = view.labelInfo.frame.origin.x - 10.0f - view.labelEnter.frame.size.width/2;
            [view.labelEnter setCenter:CGPointMake(enterY, DIFFENT_STATUS_HEIGHT + 56.0f + englishHeight)];
            
            [view.imageViewDirectAndDistance setFrame:CGRectMake(0.0f, 0.0f, 103.0f, 85 + DIFFENT_STATUS_HEIGHT)];
            [view.labelDistance setFrame:CGRectMake(0.0f, 59.0f + DIFFENT_STATUS_HEIGHT, 103.0f, 26.0f)];
            view.labelDistance.font = [UIFont boldSystemFontOfSize:20.0f];
            [view.direImageView setFrame:CGRectMake(0.0f, 0.0f, 61.0f,61.0f)];
            [view.direImageView setCenter:CGPointMake(103.0f/2 ,
                                                     view.direImageView.frame.size.height/2+ DIFFENT_STATUS_HEIGHT)];
            
            [view.imageViewRight setFrame:CGRectMake(0, 0, 5, 10)];
            [view.imageViewRight setCenter:CGPointMake(view.imageViewLabels.frame.size.width - 7, view.imageViewLabels.frame.size.height / 2)];
            [view.imageViewLeft setFrame:CGRectMake(0, 0, 5, 10)];
            [view.imageViewLeft setCenter:CGPointMake(7, view.imageViewLabels.frame.size.height / 2)];
        }
        else
        {
            view.labelInfo.font = [UIFont boldSystemFontOfSize:24.0f];
            view.labelQianfang.font = [UIFont boldSystemFontOfSize:23.0f];
            view.labelQianfang.textAlignment = NSTextAlignmentRight;
            view.labelEnter.font = [UIFont systemFontOfSize:15.0f];
            CGSize enterSize = [ view.labelEnter.text sizeWithFont:view.labelEnter.font];
            CGSize nextRoadSize = [view.labelInfo.text sizeWithFont:view.labelInfo.font];
            //导航顶部的半透明条
            [view.imageViewLabels setFrame:CGRectMake(0, 0, MAIN_LAND_WIDTH - 103, 43.0f + DIFFENT_STATUS_HEIGHT)];
            [view.imageViewLabels setCenter:CGPointMake((MAIN_LAND_WIDTH - 103)/ 2 + 103, view.imageViewLabels.frame.size.height / 2)];
            
            float nextRoadWidth = (nextRoadSize.width > (view.imageViewLabels.frame.size.width/ 2 - 37.0f)) ?(view.imageViewLabels.frame.size.width/ 2 - 37.0f): nextRoadSize.width;
            [view.labelInfo setFrame:CGRectMake(view.imageViewLabels.frame.size.width - 37.0f - nextRoadWidth,
                                                7.0f + DIFFENT_STATUS_HEIGHT,
                                                nextRoadWidth,
                                                nextRoadSize.height + englishHeight)];
            [view.labelEnter setFrame:CGRectMake(0, 0, enterSize.width + 2, enterSize.height + 2)];
            [view.labelEnter setCenter:CGPointMake(view.labelInfo.frame.origin.x - view.labelEnter.frame.size.width + 8,
                                               25.0f + DIFFENT_STATUS_HEIGHT)];
            
            [view.labelQianfang setFrame:CGRectMake(0.0f, DIFFENT_STATUS_HEIGHT + 10.0f, view.labelEnter.frame.origin.x - 8, 26.0f + englishHeight)];
            
            [view.imageViewDirectAndDistance setFrame:CGRectMake(0.0f, 0.0f, 103.0f, 86.0f + DIFFENT_STATUS_HEIGHT)];
            [view.labelDistance setFrame:CGRectMake(0.0f, 60.0f + DIFFENT_STATUS_HEIGHT, 103.0f, 26.0f)];
            view.labelDistance.font = [UIFont boldSystemFontOfSize:20.0f];
            [view.direImageView setFrame:CGRectMake(0.0f, 0.0f, 61.0f,61.0f)];
            [view.direImageView setCenter:CGPointMake(103.0f/2, 61.0f/2 + DIFFENT_STATUS_HEIGHT)];
            [view.imageViewLeft setFrame:CGRectMake(0, 0, 5, 10)];
            [view.imageViewLeft setCenter:CGPointMake(7, view.imageViewLabels.frame.size.height / 2)];
            [view.imageViewRight setFrame:CGRectMake(0, 0, 5, 10)];
            [view.imageViewRight setCenter:CGPointMake(view.imageViewLabels.frame.size.width - 7, view.imageViewLabels.frame.size.height / 2)];
        }
    }
    else
    {
        if(Interface_Flag == 0)
        {
            view.labelInfo.font = [UIFont boldSystemFontOfSize:45.0f];
            view.labelQianfang.font = [UIFont systemFontOfSize:43.0f];
            view.labelQianfang.textAlignment = NSTextAlignmentRight;
            view.labelEnter.font = [UIFont systemFontOfSize:23.0f];
            CGSize enterSize = [view.labelEnter.text sizeWithFont:view.labelEnter.font];
            CGSize nextRoadSize = [view.labelInfo.text sizeWithFont:view.labelInfo.font];
            //导航顶部的半透明条
            [view.imageViewLabels setFrame:CGRectMake(0, 0, MAIN_POR_WIDTH - 134.0f, 143.0f + DIFFENT_STATUS_HEIGHT)];
            [view.imageViewLabels setCenter:CGPointMake((MAIN_POR_WIDTH - 134.0f)/ 2 + 134.0f,
                                                       view.imageViewLabels.frame.size.height / 2 )];
            
            [view.labelEnter setFrame:CGRectMake(0, 0, enterSize.width + 2, enterSize.height + 2)];
            
            [view.labelQianfang setFrame:CGRectMake(0.0f, DIFFENT_STATUS_HEIGHT + 20, APPWIDTH - 134.0f - 100.0f, 45.0f + englishHeight)];
            
            float maxWidth =  view.imageViewLabels.frame.size.width  - 100.0f - view.labelEnter.frame.size.width - 25.0f;
            nextRoadSize.width = (nextRoadSize.width > maxWidth) ? (maxWidth) : nextRoadSize.width;
            [view.labelInfo setFrame:CGRectMake(view.imageViewLabels.frame.size.width - nextRoadSize.width - 100.0f,
                                                68.0f + DIFFENT_STATUS_HEIGHT,
                                                nextRoadSize.width,
                                                nextRoadSize.height + 4 + englishHeight)];
            float enterY = view.labelInfo.frame.origin.x - view.labelEnter.frame.size.width / 2 - 25.0f;
            [view.labelEnter setCenter:CGPointMake(enterY, DIFFENT_STATUS_HEIGHT + 110.0f)];
            
            [view.imageViewDirectAndDistance setFrame:CGRectMake(0.0f, 0.0f, 134.0f, 143.0f + DIFFENT_STATUS_HEIGHT)];
            [view.labelDistance setFrame:CGRectMake(0.0f, 112.0f+ DIFFENT_STATUS_HEIGHT, 112.0f, 31.0f)];
            view.labelDistance.font = [UIFont boldSystemFontOfSize:24.0f];
            [view.direImageView setFrame:CGRectMake(0.0f, 0.0f, 112.0f,112.0f)];
            [view.direImageView setCenter:CGPointMake(134.0f/2, 112.0f/2+ DIFFENT_STATUS_HEIGHT)];
            
            [view.imageViewRight setFrame:CGRectMake(0.0f, 0.0f, 7.0f, 14.0f)];
            [view.imageViewRight setCenter:CGPointMake(view.imageViewLabels.frame.size.width - 25.0f,view.imageViewLabels.frame.size.height / 2 )];
            [view.imageViewLeft setFrame:CGRectMake(0, 0, 7, 14)];
            [view.imageViewLeft setCenter:CGPointMake(7, view.imageViewLabels.frame.size.height / 2)];
            
        }
        else
        {
            view.labelInfo.font = [UIFont boldSystemFontOfSize:42.0f];
            view.labelQianfang.font = [UIFont systemFontOfSize:35.0f];
            view.labelQianfang.textAlignment = NSTextAlignmentLeft;
            view.labelEnter.font = [UIFont systemFontOfSize:23.0f];
            CGSize nextRoadSize = [view.labelInfo.text sizeWithFont:view.labelInfo.font];
            CGSize enterSize = [view.labelEnter.text sizeWithFont:view.labelEnter.font];
            
            //导航顶部的半透明条
            [view.imageViewLabels setFrame:CGRectMake(0, 0, MAIN_LAND_WIDTH - 134.0f, 81.0f + DIFFENT_STATUS_HEIGHT)];
            [view.imageViewLabels setCenter:CGPointMake((MAIN_LAND_WIDTH - 134.0f)/ 2 + 134.0f, view.imageViewLabels.frame.size.height / 2)];
            [view.labelInfo setFrame:CGRectMake(view.imageViewLabels.frame.size.width - 540.0f,
                                                20.0f+ DIFFENT_STATUS_HEIGHT,
                                                540.0f - 100.0f,
                                                nextRoadSize.height + 3 + englishHeight)];
            [view.labelQianfang setFrame:CGRectMake(25.0f, 7.0f+ DIFFENT_STATUS_HEIGHT, 280.0f, 37.0f + englishHeight)];
            [view.labelEnter setFrame:CGRectMake(0, 0, enterSize.width + 2, enterSize.height + 2)];
            [view.labelEnter setCenter:CGPointMake(view.labelInfo.frame.origin.x - view.labelEnter.frame.size.width,
                                               57.0f + DIFFENT_STATUS_HEIGHT)];
            
            [view.imageViewDirectAndDistance setFrame:CGRectMake(0.0f, 0.0f, 134.0f, 143.0f + DIFFENT_STATUS_HEIGHT)];
            [view.labelDistance setFrame:CGRectMake(0.0f, 112.0f+ DIFFENT_STATUS_HEIGHT, 112.0f, 31.0f)];
            view.labelDistance.font = [UIFont boldSystemFontOfSize:24.0f];
            [view.direImageView  setFrame:CGRectMake(0.0f, 0.0f, 112.0f,112.0f)];
            [view.direImageView  setCenter:CGPointMake(134.0f/2, 112.0f/2+ DIFFENT_STATUS_HEIGHT)];
            [view.imageViewRight setFrame:CGRectMake(0.0f, 0.0f, 7.0f, 14.0f)];
            [view.imageViewRight setCenter:CGPointMake(view.imageViewLabels.frame.size.width - 25.0f,view.imageViewLabels.frame.size.height / 2 )];
            [view.imageViewLeft setFrame:CGRectMake(0, 0, 7, 14)];
            [view.imageViewLeft setCenter:CGPointMake(7, view.imageViewLabels.frame.size.height / 2)];
        }
        
    }
}

- (void) setTopViewByIndex:(int) index withView:(RoutePointTopView *)view
{
    view.tag = index;
    int  j = index;
    view.imageViewLeft.hidden = NO;
    view.imageViewRight.hidden = NO;
    view.labelEnter.hidden = NO;
    view.labelQianfang.hidden = NO;
    view.labelEnter.text = STR(@"Main_Enter", Localize_Main);
    if(j == 0)
    {
//        view.labelQianfang.text = STR(@"Main_routeBegin", Localize_Main);
        view.imageViewLeft.hidden = YES;
    }
    else if (j == _arrayInfo.count - 1)
    {
//        view.labelQianfang.text = STR(@"Main_routeEnd", Localize_Main);
        view.imageViewRight.hidden = YES;
        view.labelEnter.hidden = YES;
        view.labelQianfang.hidden = YES;
        view.labelEnter.text = @"";
    }
    else
    {
//        view.labelQianfang.text = STR(@"Mian_forward", Localize_Main);
    }
    
    
    view.labelDistance.backgroundColor = GETSKINCOLOR(HUD_LABEL_CLEAR_BACK_COLOR);
        view.labelDistance.textColor = GETSKINCOLOR(LEFTROAD_LABEL_COLOR);
    
    view.labelDistance.textAlignment = UITextAlignmentCenter;
    view.labelDistance.adjustsFontSizeToFitWidth = YES;
    
    view.labelInfo.textColor = GETSKINCOLOR(MAIN_NEXTLROAD_COLOR);
    
    view.labelInfo.textAlignment = NSTextAlignmentCenter;
    view.labelInfo.autoresizesSubviews = YES;
    view.labelInfo.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    view.labelInfo.backgroundColor = GETSKINCOLOR(HUD_LABEL_CLEAR_BACK_COLOR);
    if(index < _arrayInfo.count )
    {
        ManeuverInfo *mainRoadInfo = (ManeuverInfo*)[_arrayInfo objectAtIndex:index ];
        // 转向图片
        int nPicID = mainRoadInfo.unTurnID;
        view.direImageView.image = [MWRouteGuide GetTurnIconWithID:nPicID flag:1];
        view.labelDistance.text = [mainRoadInfo getNextDisString];
        view.labelQianfang.text = mainRoadInfo.currentLoadName;
        view.labelInfo.text = mainRoadInfo.nextLoadName;
        
        if(index == _arrayInfo.count - 1)
        {
            view.labelInfo.text = mainRoadInfo.szDescription;
        }
    }

    
    view.imageViewRight.image = IMAGE(@"shareRightArrow.png", IMAGEPATH_TYPE_1);
    view.imageViewLeft.image = IMAGE(@"shareLeftArrow.png", IMAGEPATH_TYPE_1);
    [self setViewFrame:view];
}

#pragma mark -
#pragma mark ---  cycleDelegate  ---

- (void) scrollToNext
{
    if(_thirdView.tag + 1 < _arrayInfo.count)
    {
        [self setTopViewByIndex:_firstView.tag + 1 withView:_firstView];
        [self setTopViewByIndex:_secondView.tag + 1 withView:_secondView];
        [self setTopViewByIndex:_thirdView.tag + 1 withView:_thirdView];
        
        [self scrollerToIndex:_secondView.tag ];
        [_cycleScrollView setScrollViewCenter];
    }
    else if(_thirdView.tag + 1 == _arrayInfo.count)
    {
        [self scrollerToIndex:_thirdView.tag ];
    }
}

- (void) scrollToPre
{
    if(_firstView.tag - 1 >= 0)
    {
        [self setTopViewByIndex:_firstView.tag - 1 withView:_firstView];
        [self setTopViewByIndex:_secondView.tag - 1 withView:_secondView];
        [self setTopViewByIndex:_thirdView.tag - 1 withView:_thirdView];
        
        [self scrollerToIndex:_secondView.tag ];
        [_cycleScrollView setScrollViewCenter];
    }
    else if (_firstView.tag  == 0) {
        [self scrollerToIndex:_firstView.tag ];
    }
}

- (void) scrollToEqual
{
    [self scrollerToIndex:_secondView.tag ];
    [_cycleScrollView setScrollViewCenter];
}

- (void) scrollToIndex:(int)index
{
    [self scrollerToIndex:index];
}

- (void) scrollerToIndex:(int) index
{
    if(index < _arrayInfo.count)
    {

        int tempIndex = _indexNumber;
        _indexNumber =  ((ManeuverInfo *)[_arrayInfo objectAtIndex:index]).nID;
        [self viewCrossWithID:_indexNumber withAnimate:(tempIndex == _indexNumber)];
        [self viewInfoInCondition:0];
        if(_timer)
        {
            [_timer invalidate];
            _timer = nil;
        }
    }
}



- (void) addTime
{
    count++;
    if(count == 8)
    {
        if(_timer)
        {
            [_timer invalidate];
            _timer = nil;
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(_timer)
    {
        [_timer invalidate];
        _timer = nil;
    }
    [super touchesBegan:touches withEvent:event];
}

- (void) backToDetail
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) beginNavi
{
    [[MWMapOperator sharedInstance] MW_SetMapOperateType:2];

	[self.navigationController popToRootViewControllerAnimated:NO];
}

- (void) continueNavi
{
    
//    CATransition *animation = [CATransition animation];
//    [animation setDuration:0.5f];
//    [animation setSubtype:kCATransitionReveal];
//    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
//    
//    [self.navigationController.view.layer addAnimation:animation forKey:nil];

	[self.navigationController popToRootViewControllerAnimated:NO];
}





//
- (void) setCommonFrame
{
    if (Interface_Flag == 0)
    {
        if(isiPhone)
        {
            //指南针方向
            CGAffineTransform at =CGAffineTransformMakeRotation(0);//设置Frame前，先将角度旋转为0度，要不会发生变形
            [_buttonSwitchTripDirect setTransform:at];
            [_buttonSwitchTripDirect setFrame:CGRectMake(0.0f,0.0f,40.0f, 40.0f)];
            [_buttonSwitchTripDirect setCenter:CGPointMake(BUTTON_BOUNDARY, 85 + DIFFENT_STATUS_HEIGHT + 8 + 20.0f)];
            
            //实时交通（坐上红绿灯）管理按钮
            [self buttonRealInitImage];
            [_buttonReal setFrame: CGRectMake(0, 0, 40, 40)];
            _buttonReal.center = CGPointMake(APPWIDTH - BUTTON_BOUNDARY, 85 + DIFFENT_STATUS_HEIGHT + 8 + 20.0f);
            
            //底栏
            [_imageViewNaviBottomBG setFrame:CGRectMake(0, 0, MAIN_POR_WIDTH, 44)];
            [_imageViewNaviBottomBG setCenter:CGPointMake(MAIN_POR_WIDTH / 2,
                                                      MAIN_POR_HEIGHT - _imageViewNaviBottomBG.frame.size.height / 2)];
            
            UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:_imageViewNaviBottomBG.bounds byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(0, 0)];
            CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
            maskLayer.frame = _imageViewNaviBottomBG.bounds;
            maskLayer.path = maskPath.CGPath;
            _imageViewNaviBottomBG.layer.mask = maskLayer;
            [maskLayer release];
            
            _buttonback.frame = CGRectMake(0, 0, 55.0f, 44.0f);
            
            _buttonBegin.frame = CGRectMake(0, 0, 215, 38);
            _buttonBegin.center = CGPointMake(_imageViewNaviBottomBG.frame.size.width / 2,
                                          _imageViewNaviBottomBG.frame.size.height / 2);
            _buttonBegin.titleLabel.font = [UIFont systemFontOfSize:15.0f];
        
            _buttonContinue.frame = CGRectMake(0, 0,
                                               _imageViewNaviBottomBG.frame.size.width,
                                               _imageViewNaviBottomBG.frame.size.height);
            _buttonContinue.titleLabel.font = [UIFont systemFontOfSize:15.0f];
            
            //放大，缩小
            [_buttonNarrowMap setFrame:CGRectMake(0.0f, 0.0f, 40.0f, 42.0f)];
            [_buttonNarrowMap setCenter:CGPointMake(APPWIDTH-BUTTON_BOUNDARY,  MAIN_POR_HEIGHT-100.0f)];
            
            [_buttonEnlargeMap setFrame:CGRectMake(0.0f, 0.0f, 40.0f, 42.0f)];
            [_buttonEnlargeMap setCenter:CGPointMake(MAIN_POR_WIDTH-BUTTON_BOUNDARY, _buttonNarrowMap.center.y - _buttonEnlargeMap.frame.size.height)];
          
            [_labelMeter setFrame:CGRectMake(0.0f, 0.0f, 36.0f, 12.0f)];
            [_labelMeter setCenter:CGPointMake(APPWIDTH-BUTTON_BOUNDARY, MAIN_POR_HEIGHT-60.0f)];
        }
        else
        {
            //指南针方向
            CGAffineTransform at =CGAffineTransformMakeRotation(0);//设置Frame前，先将角度旋转为0度，要不会发生变形
            [_buttonSwitchTripDirect setTransform:at];
            [_buttonSwitchTripDirect setFrame:CGRectMake(0.0f,0.0f,60.0f, 60.0)];
            [_buttonSwitchTripDirect setCenter:CGPointMake(BUTTON_BOUNDARY,  143.0f + DIFFENT_STATUS_HEIGHT + 11 + 30.0f)];
            
            //实时交通（坐上红绿灯）管理按钮
            [self buttonRealInitImage];
            [_buttonReal setFrame: CGRectMake(0, 0, 60.0f, 60.0f)];
            _buttonReal.center = CGPointMake(MAIN_POR_WIDTH - BUTTON_BOUNDARY, 143.0f + DIFFENT_STATUS_HEIGHT + 11.0f + 30.0f);
            
            //放大，缩小
            [_buttonEnlargeMap setFrame:CGRectMake(0.0f, 0.0f, 60.0f, 63.0f)];
            [_buttonEnlargeMap setCenter:CGPointMake(MAIN_POR_WIDTH-BUTTON_BOUNDARY, MAIN_POR_HEIGHT-212.0f)];
            
            [_buttonNarrowMap setFrame:CGRectMake(0.0f, 0.0f, 60.0f, 63.0f)];
            if([[UIScreen mainScreen] scale] == 2)
            {
                [_buttonNarrowMap setCenter:CGPointMake(MAIN_POR_WIDTH-BUTTON_BOUNDARY, MAIN_POR_HEIGHT-149.0f)];
            }
            else
            {
                [_buttonNarrowMap setCenter:CGPointMake(MAIN_POR_WIDTH-BUTTON_BOUNDARY, MAIN_POR_HEIGHT-150.0f)];
            }
            
            [_labelMeter setFrame:CGRectMake(0.0f, 0.0f, 50.0f, 20.0f)];
            [_labelMeter setCenter:CGPointMake(MAIN_POR_WIDTH-BUTTON_BOUNDARY, MAIN_POR_HEIGHT-106.5f)];
            _labelMeter.titleLabel.font = [UIFont systemFontOfSize:13];
            
            //底栏
            [_imageViewNaviBottomBG setFrame:CGRectMake(0, 0, MAIN_POR_WIDTH, 65.0f)];
            [_imageViewNaviBottomBG setCenter:CGPointMake(MAIN_POR_WIDTH / 2,
                                                          MAIN_POR_HEIGHT - _imageViewNaviBottomBG.frame.size.height / 2)];
            _buttonback.frame = CGRectMake(0, 0, 100.0f, 65.0f);
            _buttonback.imageEdgeInsets = UIEdgeInsetsMake((_buttonback.frame.size.height - _buttonback.imageView.image.size.height) / 2,
                                                           (_buttonback.frame.size.width - _buttonback.imageView.image.size.width) / 2,
                                                           (_buttonback.frame.size.height - _buttonback.imageView.image.size.height) / 2,
                                                           (_buttonback.frame.size.width - _buttonback.imageView.image.size.width) / 2);
            
            _buttonBegin.frame = CGRectMake(0, 0, 555.0f, 60.0f);
            _buttonBegin.center = CGPointMake(_imageViewNaviBottomBG.frame.size.width / 2,
                                              _imageViewNaviBottomBG.frame.size.height / 2);
            _buttonBegin.titleLabel.font = [UIFont systemFontOfSize:22.0f];
            
            _buttonContinue.frame = CGRectMake(0, 0, 555.0f, 60.0f);
            _buttonContinue.center = CGPointMake(_imageViewNaviBottomBG.frame.size.width / 2,
                                                 _imageViewNaviBottomBG.frame.size.height / 2);
            _buttonContinue.titleLabel.font = [UIFont systemFontOfSize:22.0f];
        }
    }
    else
    {
        if(isiPhone)
        {
            //放大，缩小
            CGFloat enlargeToNarrow = 6.0f;
            //放大，缩小
            CGFloat enlargeAndNarrowWidth = 40.0f;
            CGFloat buttonBoundary = MAIN_LAND_WIDTH - BUTTON_BOUNDARY;
            [_buttonNarrowMap setFrame:CGRectMake(0.0f, 0.0f, enlargeAndNarrowWidth, enlargeAndNarrowWidth)];
            [_buttonNarrowMap setCenter:CGPointMake(buttonBoundary,
                                                    MAIN_LAND_HEIGHT - BOTTOM_DIS_HEIGHT)];
            
            [_buttonEnlargeMap setFrame:CGRectMake(0.0f, 0.0f, enlargeAndNarrowWidth, enlargeAndNarrowWidth)];
            [_buttonEnlargeMap setCenter:CGPointMake(MAIN_LAND_WIDTH - _buttonNarrowMap.frame.size.width - 2 * enlargeToNarrow - _buttonEnlargeMap.frame.size.width / 2,
                                                     MAIN_LAND_HEIGHT - BOTTOM_DIS_HEIGHT)];
            
            [_labelMeter setFrame:CGRectMake(0.0f, 0.0f, 36.0f, 12.0f)];
            [_labelMeter setCenter:CGPointMake(buttonBoundary,
                                               _buttonNarrowMap.frame.origin.y - enlargeToNarrow - _labelMeter.frame.size.height / 2)];
            _labelMeter.titleLabel.font = [UIFont systemFontOfSize:10.0f];
            
            //指南针方向
            CGAffineTransform at =CGAffineTransformMakeRotation(0);
            [_buttonSwitchTripDirect setTransform:at];
            [_buttonSwitchTripDirect setFrame:CGRectMake(0.0f,0.0f,40.0f, 40.0f)];
            [_buttonSwitchTripDirect setCenter:CGPointMake(BUTTON_BOUNDARY,86.0f + DIFFENT_STATUS_HEIGHT + 8 + 20.0f)];
            //实时交通
            [self buttonRealInitImage];
            [_buttonReal setFrame: CGRectMake(0, 0, 40, 40)];
            [_buttonReal setCenter:CGPointMake(MAIN_LAND_WIDTH-BUTTON_BOUNDARY, 43.0f + DIFFENT_STATUS_HEIGHT + 16 + 20.0f)];
            
            
            //底栏
            [_imageViewNaviBottomBG setFrame:CGRectMake(0,0, MAIN_LAND_WIDTH - 200, enlargeAndNarrowWidth)];
            [_imageViewNaviBottomBG setCenter:CGPointMake(MAIN_LAND_WIDTH / 2, MAIN_LAND_HEIGHT - BOTTOM_DIS_HEIGHT)];
            
            UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:_imageViewNaviBottomBG.bounds byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(5, 5)];
            CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
            maskLayer.frame = _imageViewNaviBottomBG.bounds;
            maskLayer.path = maskPath.CGPath;
            _imageViewNaviBottomBG.layer.mask = maskLayer;
            [maskLayer release];
            
            _buttonback.frame = CGRectMake(0, 0, 55.0f, enlargeAndNarrowWidth);
            _buttonBegin.frame = CGRectMake(0, 0,
                                            _imageViewNaviBottomBG.frame.size.width - _buttonback.frame.size.width * 2, 38);
            _buttonBegin.center = CGPointMake(_imageViewNaviBottomBG.frame.size.width/2,
                                              _imageViewNaviBottomBG.frame.size.height / 2);
            _buttonBegin.titleLabel.font = [UIFont systemFontOfSize:15.0f];
            
            _buttonContinue.frame = CGRectMake(0, 0, _imageViewNaviBottomBG.frame.size.width, _imageViewNaviBottomBG.frame.size.height);
            _buttonContinue.center = CGPointMake(_imageViewNaviBottomBG.frame.size.width / 2,
                                              _imageViewNaviBottomBG.frame.size.height / 2);
            _buttonContinue.titleLabel.font = [UIFont systemFontOfSize:15.0f];
        }
        else
        {
            //指南针方向
            CGAffineTransform at =CGAffineTransformMakeRotation(0);//设置Frame前，先将角度旋转为0度，要不会发生变形
            [_buttonSwitchTripDirect setTransform:at];
            [_buttonSwitchTripDirect setFrame:CGRectMake(0.0f,0.0f,60.0f, 60.0)];
            [_buttonSwitchTripDirect setCenter:CGPointMake(38.0f,  143.0f + DIFFENT_STATUS_HEIGHT + 18 + 30)];
            
            //实时交通（坐上红绿灯）管理按钮
            [self buttonRealInitImage];
            [_buttonReal setFrame: CGRectMake(0, 0, 60.0f, 60.0f)];
            _buttonReal.center = CGPointMake(MAIN_LAND_WIDTH-BUTTON_BOUNDARY, 81.0f + DIFFENT_STATUS_HEIGHT + 18 + 30);
            
            //放大，缩小
            [_buttonEnlargeMap setFrame:CGRectMake(0.0f, 0.0f, 60.0f, 63.0f)];
            [_buttonEnlargeMap setCenter:CGPointMake(MAIN_LAND_WIDTH-BUTTON_BOUNDARY, MAIN_LAND_HEIGHT-213.0f)];
            if([[UIScreen mainScreen] scale] == 2)
            {
                [_buttonNarrowMap setFrame:CGRectMake(0,0, 60.0f, 63.0f)];
                [_buttonNarrowMap setCenter:CGPointMake(MAIN_LAND_WIDTH-BUTTON_BOUNDARY, MAIN_LAND_HEIGHT-150.0f)];
            }
            else
            {
                [_buttonNarrowMap setFrame:CGRectMake(_buttonEnlargeMap.frame.origin.x,
                                                      _buttonEnlargeMap.frame.origin.y + 62.0f ,
                                                      60.0f,
                                                      63.0f)];
            }
            
            [_labelMeter setFrame:CGRectMake(0.0f, 0.0f, 50.0f, 20.0f)];
            [_labelMeter setCenter:CGPointMake(MAIN_LAND_WIDTH-BUTTON_BOUNDARY, MAIN_LAND_HEIGHT-106.5f)];
            _labelMeter.titleLabel.font = [UIFont systemFontOfSize:13];
            
            //底栏
            [_imageViewNaviBottomBG setFrame:CGRectMake(0, 0, MAIN_LAND_WIDTH, 65.0f)];
            [_imageViewNaviBottomBG setCenter:CGPointMake(MAIN_LAND_WIDTH / 2,
                                                          MAIN_LAND_HEIGHT - _imageViewNaviBottomBG.frame.size.height / 2)];
            _buttonback.frame = CGRectMake(0, 0, 100.0f, 65.0f);
            _buttonback.imageEdgeInsets = UIEdgeInsetsMake((_buttonback.frame.size.height - _buttonback.imageView.image.size.height) / 2,
                                                           (_buttonback.frame.size.width - _buttonback.imageView.image.size.width) / 2,
                                                           (_buttonback.frame.size.height - _buttonback.imageView.image.size.height) / 2,
                                                           (_buttonback.frame.size.width - _buttonback.imageView.image.size.width) / 2);
            
            _buttonBegin.frame = CGRectMake(0, 0, 811.0f, 60.0f);
            _buttonBegin.center = CGPointMake(_imageViewNaviBottomBG.frame.size.width / 2,
                                              _imageViewNaviBottomBG.frame.size.height / 2);
            _buttonBegin.titleLabel.font = [UIFont systemFontOfSize:22.0f];
            
            _buttonContinue.frame = CGRectMake(0, 0, 811.0f, 60.0f);
            _buttonContinue.center = CGPointMake(_imageViewNaviBottomBG.frame.size.width / 2,
                                                 _imageViewNaviBottomBG.frame.size.height / 2);
            _buttonContinue.titleLabel.font = [UIFont systemFontOfSize:22.0f];

        }

    }

    
}


//调整控件竖屏坐标和图片
-(void)changePortraitControlFrameWithImage
{
    [_cycleScrollView setFrame:CGRectMake(0, 0,
                                          MAIN_POR_WIDTH,
                                          PRE_AND_NEXT_HEIGHT)];
    [drawingView setmyFrame:CGRectMake(0.0, 0.0, SCREENWIDTH, SCREENHEIGHT)];
    [[MWPreference sharedInstance] setValue:PREF_DISPLAY_ORIENTATION Value:1];
    if(_isAppear) //IOSA-12911 && IOSA-12984
    {
        [[MWMapOperator sharedInstance] MW_ShowMapView:GMAP_VIEW_TYPE_MANEUVER_POINT WithParma1:0 WithParma2:0 WithParma3:0];
    }
    [self viewCrossWithID:_indexNumber withAnimate:NO];
    [self setCommonFrame];
    [popPoiInfo setHidden:YES];
    

    [self setViewFrame:_firstView];
    [self setViewFrame:_secondView];
    [self setViewFrame:_thirdView];
    [self reloadEnlargeAndNarrowImage];
}

//调整控件横屏坐标和图片
-(void)changeLandscapeControlFrameWithImage
{
    [_cycleScrollView setFrame:CGRectMake(0, 0,
                                          MAIN_LAND_WIDTH,
                                          PRE_AND_NEXT_HEIGHT)];
    [drawingView setmyFrame:CGRectMake(0.0, 0.0, SCREENHEIGHT, SCREENWIDTH)];
    [[MWPreference sharedInstance] setValue:PREF_DISPLAY_ORIENTATION Value:0];
    if(_isAppear) //IOSA-12911 && IOSA-12984
    {
        [[MWMapOperator sharedInstance] MW_ShowMapView:GMAP_VIEW_TYPE_MANEUVER_POINT WithParma1:0 WithParma2:0 WithParma3:0];
    }
    [self viewCrossWithID:_indexNumber withAnimate:NO];
    [self setCommonFrame];
    [popPoiInfo setHidden:YES];

    [self setViewFrame:_firstView];
    [self setViewFrame:_secondView];
    [self setViewFrame:_thirdView];
    [self reloadEnlargeAndNarrowImage];
}

//改变控件文本
-(void)changeControlText
{
    
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
    IMAGEPATHTYPE type = IMAGEPATH_TYPE_1;
    switch (condition) {
    
        case ROUTEPLANNING_BUTTON_ADDTEMP://添加途经点
        {
            titleT = STR(@"RouteOverview_AddTemp", Localize_RouteOverview);
            normalImage = @"browseView_bottomBar_button_1.png";
            highlightedImage = @"browseView_bottomBar_button_2.png";
        }
            break;
            
        case ROUTEPLANNING_BUTTON_SIMU://模拟导航
        {
            titleT = STR(@"RouteOverview_Simu", Localize_RouteOverview);
            normalImage = @"browseView_bottomBar_button_1.png";
            highlightedImage = @"browseView_bottomBar_button_2.png";
        }
            break;
        case ROUTEPLANNING_BUTTON_DELETE://删除
        {
            titleT = STR(@"RouteOverview_Delete", Localize_RouteOverview);
            normalImage = @"browseView_bottomBar_button_1.png";
            highlightedImage = @"browseView_bottomBar_button_2.png";
        }
            break;
        case ROUTEPLANNING_BUTTON_COMPARE://对比
        {
            titleT = STR(@"RouteOverview_Compare", Localize_RouteOverview);
            normalImage = @"browseView_bottomBar_button_1.png";
            highlightedImage = @"browseView_bottomBar_button_2.png";
        }
            break;
        case ROUTEPLANNING_BUTTON_RECOMMEND://推荐
        {
            titleT = STR(@"RouteOverview_Recommend", Localize_RouteOverview);
            normalImage = @"browseView_bottomBar_button_1.png";
            highlightedImage = @"browseView_bottomBar_button_2.png";
        }
            break;
        case ROUTEPLANNING_BUTTON_ECONOMY://经济
        {
            titleT = STR(@"RouteOverview_Economy", Localize_RouteOverview);
            normalImage = @"browseView_bottomBar_button_1.png";
            highlightedImage = @"browseView_bottomBar_button_2.png";
        }
            break;
        case ROUTEPLANNING_BUTTON_SHORT://最短
        {
            titleT = STR(@"RouteOverview_Short", Localize_RouteOverview);
            normalImage = @"browseView_bottomBar_button_1.png";
            highlightedImage = @"browseView_bottomBar_button_2.png";
        }
            break;
        case ROUTEPLANNING_BUTTON_HIGH://高速
        {
            titleT = STR(@"RouteOverview_High", Localize_RouteOverview);
            normalImage = @"browseView_bottomBar_button_1.png";
            highlightedImage = @"browseView_bottomBar_button_2.png";
        }
            break;
        case ROUTEPLANNING_BUTTON_SHARE://分享
        {
            normalImage = nil;
            highlightedImage = nil;
            titleT = nil;
        }
            break;
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
        case BUTTON_SET_VIEWMODE:
		{//地图模式切换
			titleT = nil;
            normalImage = @"mainDirect.png";
            highlightedImage = @"mainDirect.png";
            type = IMAGEPATH_TYPE_2;
        }
			break;
        case 56:// 比例尺
		{
			titleT = nil;
			normalImage = @"mainScaleIcon.png";
			highlightedImage = nil;
		}
			break;
        case ROUTEPLANNING_BUTTON_LIST:
        {
            normalImage = nil;
            highlightedImage = nil;
            titleT = nil;
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
    
    button = [self createButtonWithTitle:titleT normalImage:normalImage heightedImage:highlightedImage tag:condition withImageType:type];
	titleT = nil;
	normalImage = nil;
	highlightedImage = nil;
	return button;
}

//按钮点击事件
- (void)buttonAction:(id)sender {
    
	switch (((UIButton *)sender).tag) {
        case BUTTON_REAL_BUTTON:
        {
            [self Real_Traffic_Action];
        }
            break;
        default:
        {
        }
            break;
    }
}

//实时路况
-(void)Real_Traffic_Action
{
    

    if(_timer)
    {
        [_timer invalidate];
        _timer = nil;
    }
    if ( [MWAdminCode checkIsExistDataWithAdmincode:0] == 0) {
        
        [self createAlertViewWithTitle:STR(@"Main_NoDataForCity", Localize_Main)  message:nil cancelButtonTitle:STR(@"Universal_ok", Localize_Universal)otherButtonTitles:nil tag:ALERT_NONE];
        return;
    }
    if([MWEngineSwitch isTMCOn])
    {
        [MWEngineSwitch CloseTMC];
    }
    else
    {
        if([[ANParamValue sharedInstance] isTMCRequest])
        {
            [MWEngineSwitch CloseTMC];
        }
        else
        {
            
            [MWEngineSwitch OpenTMCWithTip:YES];
            
        }
    }
    [self buttonRealInitImage];
}



#pragma mark -
#pragma mark control action

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
//更新主界面上——更多，微享的new图标的显示
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
        case UIUpdate_TMC:
        {
            [[MWPreference sharedInstance]  setValue:PREF_REALTIME_TRAFFIC Value:[MWEngineSwitch isTMCOn]];
            [self buttonRealInitImage];
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
            
            // NSLog(@"dis=%f,%f",provalue,pathDistance);
			//获取当前地图模式
     
            [_buttonSwitchTripDirect setBackgroundImage:IMAGE(@"mainDirect.png", IMAGEPATH_TYPE_2) forState:UIControlStateNormal];
            [_buttonSwitchTripDirect setBackgroundImage:IMAGE(@"mainDirect.png", IMAGEPATH_TYPE_2) forState:UIControlStateHighlighted];
                
            CGFloat angle = (M_PI / 180.0) * [[MWMapOperator sharedInstance] GetCarDirection:GMAP_VIEW_TYPE_MANEUVER_POINT];
            NSLog(@"%f",angle);
            CGAffineTransform at =CGAffineTransformMakeRotation(angle);
            [_buttonSwitchTripDirect setTransform:at];
        }
			break;
			
		default:
			break;
	}
}

/***
 * @name    实时交通按钮图片修改
 * @param
 * @author  by bazinga
 ***/
- (void) buttonRealInitImage
{
    //实时交通（坐上红绿灯）管理按钮
    if([MWEngineSwitch isTMCOn])
    {
        [_buttonReal setBackgroundImage:IMAGE(@"mainRealTraffic.png", IMAGEPATH_TYPE_2) forState:UIControlStateNormal];
        [_buttonReal setBackgroundImage:IMAGE(@"mainRealTrafficPress.png", IMAGEPATH_TYPE_2) forState:UIControlStateHighlighted];
        
    }
    else
    {
        [_buttonReal setBackgroundImage:IMAGE(@"mainRealTrafficDisnable.png", IMAGEPATH_TYPE_2) forState:UIControlStateNormal];
        [_buttonReal setBackgroundImage:IMAGE(@"mainRealTrafficDisnablePress.png", IMAGEPATH_TYPE_2) forState:UIControlStateHighlighted];
    }
    [self viewCrossWithID:_indexNumber withAnimate:NO];
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
		[drawingView swapBuffers];
        NSArray *array = [notification object];
        if(array.count == 2)
        {
            if([[array objectAtIndex:0] intValue] == GMAP_VIEW_TYPE_MANEUVER_POINT)
            {
                if([[array objectAtIndex:1] intValue] == GD_ERR_OP_END)
                {
                    NSLog(@"动画结束");
                    _isCanclick = YES;
                }
            }
        }
	}
    if ([notification.name isEqual:NOTIFY_UPDATE_VIEWINFO]) {
        [self viewInfoInCondition:0];
    }
}


#pragma mark   NSTimer *m_timerInc, *m_timerDec;


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
    if (_isCanclick == NO)
    {
        return ;
    }
    if (_isLongPress)
    {
        _isLongPress = NO;
        return;
    }
    if(_timer)
    {
        [_timer invalidate];
        _timer = nil;
    }

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
    [[MWMapOperator sharedInstance] MW_ZoomMapView:GMAP_VIEW_TYPE_MANEUVER_POINT ZoomFlag:GSETMAPVIEW_LEVEL_OUT ZoomLevel:0];
}

- (void)decFun:(NSTimer *)timer {
    if (_isCanclick == NO)
    {
        return ;
    }
    if (_isLongPress)
    {
        _isLongPress = NO;
        return;
    }
    if(_timer)
    {
        [_timer invalidate];
        _timer = nil;
    }
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
    [[MWMapOperator sharedInstance] MW_ZoomMapView:GMAP_VIEW_TYPE_MANEUVER_POINT ZoomFlag:GSETMAPVIEW_LEVEL_IN ZoomLevel:0];
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
    
    nScale = [[MWMapOperator sharedInstance] GetMapScaleLevelWithType:GMAP_VIEW_TYPE_MANEUVER_POINT];
    
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
    return nScale;
}



-(void)mapView:(PaintingView *)mapView GestureRecognizer:(UIGestureRecognizer *)recognizer gestureType:(RECOGNIZETYPE)gesturetype  withParam:(int)param
{
    [popPoiInfo setHidden:YES];
    switch (gesturetype) {
            
        case EVENT_TAP_SINGLE:
        {
            CGPoint mPoint = [recognizer locationInView:recognizer.view];
            int iconTouchNumber = 0;
            int routeTouchNumber = -1;
            
            [MWRouteGuide guideRouteAndIconTouch:GMAP_VIEW_TYPE_MANEUVER_POINT TouchPoint:mPoint
                                                                Elements:&_eventInfo
                                                             EventNumber:&iconTouchNumber
                                                        TouchRouteNumber:&routeTouchNumber];
            if (iconTouchNumber > 0)
            {
                int type = _eventInfo->nEventID > 20 ? ((_eventInfo->nEventID >> 16) & 0Xff) : _eventInfo->nEventID;
                int lon,lat;
                GCOORD coord = {0};
                if (type > 20) {
                    
                    GFCOORD scrCoord = {0};
                    scrCoord.x = mPoint.x*[ANParamValue sharedInstance].scaleFactor;
                    scrCoord.y = mPoint.y*[ANParamValue sharedInstance].scaleFactor;
                    coord = [MWEngineTools ScrToGeo:scrCoord];
                    lon = coord.x;
                    lat = coord.y;
                }
                else{
                    lon = _eventInfo->stPosition.x;
                    lat = _eventInfo->stPosition.y;
                }
                [self showPopPoi:lon  Lat:lat];

                
                //                NSLog(@"avoid==%@,%@",avoidString,[NSString chinaFontStringWithCString:_eventInfo-> szRoadName]);
                
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
    MWPoi *tempPoi = [[MWPoi alloc] init];
    
    //道路名字
    NSString *roadName = [NSString chinaFontStringWithCString:_eventInfo-> szRoadName];
    if (!roadName || [roadName length] == 0) {
        GMAPCENTERINFO centerInfo = {0};
        [[MWMapOperator sharedInstance] MW_GetMapViewCenterInfo:GMAP_VIEW_TYPE_MANEUVER_POINT mapCenterInfo:&centerInfo];
        
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
    [popPoiInfo  setStringAtPos:tempPoi withMapType:GMAP_VIEW_TYPE_MANEUVER_POINT];
    [popPoiInfo startAnimate:0.3];
    
    [tempPoi release];
}

- (void)GDPopViewTaped:(id)sender POI:(MWPoi *)poi
{
    if(((UIButton *)sender).tag == ViewPOIButtonType_avoidRoute)
    {
        GDBL_ClearDetourRoad();//删除所有避让内容
        GSTATUS res = [MWRouteDetour AddAvoidEventInfo:_eventInfo];
        if (GD_ERR_OK == res)
        {
            _avoidFlag = YES;
            [MWRouteCalculate StartRouteCalculation:GROU_CAL_SINGLE_ROUTE];
        }
        else
        {
            [POICommon showAutoHideAlertView:STR(@"Route_roadNotDetour",Localize_RouteOverview) ];
            
        }
    }
}

-(void) setSwitchTripDirect
{
    [_buttonSwitchTripDirect setBackgroundImage:IMAGE(@"mainDirect.png", IMAGEPATH_TYPE_2) forState:UIControlStateNormal];
    [_buttonSwitchTripDirect setBackgroundImage:IMAGE(@"mainDirect.png", IMAGEPATH_TYPE_2) forState:UIControlStateHighlighted];
    
    CGFloat angle = (M_PI / 180.0) * [[MWMapOperator sharedInstance] GetCarDirection:GMAP_VIEW_TYPE_MANEUVER_POINT];
    NSLog(@"%f",angle);
    CGAffineTransform at =CGAffineTransformMakeRotation(angle);
    [_buttonSwitchTripDirect setTransform:at];
}

//设置白天黑夜图片
- (void) setDayAndNightStyle
{
    
    [self setSwitchTripDirect];
    [self buttonRealInitImage];
    
    [self reloadEnlargeAndNarrowImage];
}

- (void) reloadEnlargeAndNarrowImage
{
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

#pragma mark -
#pragma mark routeCalDelegate

- (void)RouteCalResult:(GSTATUS)result guideType:(long)guideType calType:(GCALROUTETYPE)calType
{
    if (calType == GROU_CAL_SINGLE_ROUTE) {
        if (result == GD_ERR_OK) {
            guideRouteHandle = (GHGUIDEROUTE)guideType;//路径操作句柄
            if (_avoidFlag)
            {
                _avoidFlag = NO;
                // 判断是否成功
                GGUIDEROUTEINFO stGuideRouteInfo = {0};
                GSTATUS nStatus = [MWRouteGuide GetGuideRouteInfo:guideRouteHandle routeInfo:&stGuideRouteInfo];
                if (stGuideRouteInfo.bHasAvoidRoad==FALSE)
                {
                    //                _isSuccessDetour = TRUE;
                    nStatus = [MWRouteGuide AddGuideRoute:guideRouteHandle];//添加到路线管理列表
                    
                    
                    NSLog(@"避让");
                    RouteDetourViewController *detourViewController = [[RouteDetourViewController alloc] initWithHandle:guideRouteHandle];
                    detourViewController.isDlgFromRoadList = YES;
                    
                    [self.navigationController pushViewController:detourViewController animated:NO];
                    
                    //道路名字
                    NSString *detail = @"";
                    
                    NSString *roadName = [NSString chinaFontStringWithCString:_eventInfo-> szRoadName];
                    if (!roadName || [roadName length] == 0) {
                        GMAPCENTERINFO centerInfo = {0};
                        [[MWMapOperator sharedInstance] MW_GetMapViewCenterInfo:GMAP_VIEW_TYPE_MANEUVER_POINT mapCenterInfo:&centerInfo];
                        
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
                        fDistance=   [MWEngineTools CalcDistanceFrom:start  To:des];
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
                    }else{
                        impactRange = [NSString stringWithFormat:@"%.f%@", fRange,STR(@"Universal_M", Localize_Universal)];
                        impactRange_Num = [NSString stringWithFormat:@"%.f", fRange];
                    }
                    if (type > 20)
                    {
                        detail = [NSString stringWithFormat:STR(@"TMC_eventInfo", Localize_TMC),disFromCar,roadName,streamType];
                    }
                    else
                    {
                        detail = [NSString stringWithFormat:STR(@"TMC_trafficInfo", Localize_TMC),disFromCar,roadName,streamType,impactRange];
                    }
                    
                    [detourViewController setStringTrafficInfo:detail distance:disFromCar_Num range:impactRange_Num];
                    [detourViewController setTrafficeImage:type];
                    
                    [detourViewController release];
                }
                else
                {
                    [POICommon showAutoHideAlertView:STR(@"Route_roadNotDetour",Localize_RouteOverview) ];
                    
                }
                return;
            }
            [MWRouteGuide AddGuideRoute:guideRouteHandle];//添加到路线管理列表
            [MWRouteGuide StartGuide:guideRouteHandle];
            [[MWMapOperator sharedInstance] MW_ShowMapView:GMAP_VIEW_TYPE_WHOLE WithParma1:0 WithParma2:0 WithParma3:0];
        }
        else
        {
            
            [self createAlertViewWithTitle:STR(@"RouteOverview_FailRoute",Localize_RouteOverview)
                                   message:nil
                         cancelButtonTitle:STR(@"RouteOverview_Back", Localize_RouteOverview)
                         otherButtonTitles:nil
                                       tag:200];
        }
    }
}

#pragma mark - --- 辅助函数 ---
/*!
  @brief    根据 id，查看路口图
  @param
  @author   by bazinga
  */
- (void) viewCrossWithID:(int)crossId withAnimate:(BOOL)animate
{
    _isCanclick = animate;
    [MWMapOperator ViewCrossWithID:crossId];
   
}

@end

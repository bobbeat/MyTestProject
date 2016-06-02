//
//  ViewPOIController.m
//  AutoNavi
//
//  Created by huang longfeng on 12-5-3.
//  Copyright (c) 2012年 autonavi. All rights reserved.
//

#import "ViewPOIController.h"
#import "ANParamValue.h"
#import "ANOperateMethod.h"

#import "QLoadingView.h"
#import "MWMapOperator.h"
#import "MWMapAddIconOperator.h"
#import "MWSearchResult.h"
#import "GDPopPOI.h"
#import "POIDataCache.h"
#import "PluginStrategy.h"
#import "POICommon.h"
#import "POIDetailViewController.h"
#import "POIShowObject.h"
#import "POICellButtonEvent.h"
#import "UMengEventDefine.h"
#import "POIOtherErrorViewController.h"
#import "POIAnErrorViewController.h"
@interface ViewPOIController()<MWMapPoiAddIconDelegate,GDPopPOIDelegate,POIShowObjectDelegate>
{
    MWMapAddIconOperator *mapAddIcon;
    GDPopPOI *popPoi;
    int startIndex;
    int count;
    POIShowObject *showObject;
    POICellButtonEvent *cellEvent;
    BOOL isNearBy;                      //判断是否进入周边
    BOOL isShowPoi;                     //判断是否要进行poi搜索
    BOOL isOperate;                     //判断是否操作
    
}
@property (nonatomic) MWPoi *currentPoi;
@end

@implementation ViewPOIController
@synthesize delegate;
@synthesize noAnimating;
@synthesize aroundFlag;

//

- (id)initWithIndex:(int)index ViewFlag:(int)flag POI:(NSArray *)viewPOI
{
    return  [self initWithIndex:index ViewFlag:flag POI:viewPOI withTitle:@""];
}
- (id)initWithIndex:(int)index ViewFlag:(int)flag POI:(NSArray *)viewPOI withTitle:(NSString*)title
{
    self = [super init];
    if (self) {
        
        viewIndex = index;
        viewFlag = flag;
        poiList=[[NSMutableArray alloc] initWithArray:viewPOI];
        if (poiList.count>0) {
           self.currentPoi=[poiList objectAtIndex:viewIndex];
        }
        self.titleString =title;
    }
    return self;

}

-(void)rightBtnEvent:(id)object
{
    MWPoi * poi=[popPoi getPopPOIData];
    if (viewFlag==INTO_TYPE_ADD_FeedBack_Point) {
        POIOtherErrorViewController * errot =[[ POIOtherErrorViewController alloc]init];
        errot.type = 2007;
        errot.poi = poi?poi:nil;
        NSMutableArray * array= [NSMutableArray array];
        NSMutableArray * ctl_array = [[NSMutableArray alloc] init];
        [ctl_array addObjectsFromArray:self.navigationController.viewControllers];
        if ([ctl_array count] >0)
        {
            [ctl_array removeLastObject];
            [ctl_array addObject:errot];
            
        }
        for (id arr in ctl_array)
         {
            if ([arr isKindOfClass:[self class]]||[arr isKindOfClass:[errot class]] )
            {
                
            }else
            {
                [array addObject:arr];
            }

        }
        [array addObject:errot];
        [self.navigationController setViewControllers:array animated:NO];
        [errot release];
        [ctl_array release];

        return;
        
    }
    if (viewFlag>=INTO_TYPE_ADD_THROUGH_POINT)
    {
        
    }
    switch (viewFlag) {
        case INTO_TYPE_ADD_THROUGH_POINT:
        {
            [MobClick event:UM_EVENTID_ADD_WAY_POINT_COUNT label:UM_LABEL_ADD_FROM_SEARCH];
        }
            break;
        case INTO_TYPE_ADD_THROUGH_POINT_FROM_FAV:
        {
            [MobClick event:UM_EVENTID_ADD_WAY_POINT_COUNT label:UM_LABEL_ADD_FROM_FAV];
        }
            break;
        case INTO_TYPE_ADD_THROUGH_POINT_FROM_HISTORY:
        {
            [MobClick event:UM_EVENTID_ADD_WAY_POINT_COUNT label:UM_LABEL_ADD_FROM_HISTORY];
        }
            break;
        case INTO_TYPE_ADD_THROUGH_POINT_FROM_MAPMARK:
        {
            [MobClick event:UM_EVENTID_ADD_WAY_POINT_COUNT label:UM_LABEL_ADD_FROM_MAP_MARK];
        }
            break;
            
        default:
            break;
    }
    [cellEvent addButtonEvent:poi];
}
-(void)leftBtnEvent:(id)object
{
    //CRELEASE(mapAddIcon);
    //[[MWMapOperator sharedInstance] MW_GoToCCP];
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(listenNotification:) name:NOTIFY_SHOWMAP object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleUIUpdate:) name:NOTIFY_HandleUIUpdate object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(listenNotification:) name:NOTIFY_UPDATE_VIEWINFO object:nil];
    _firstIn = YES;
    self.title=self.titleString;
    
    _mapView = [MapViewManager ShowMapViewInController:self];
    
    self.navigationItem.leftBarButtonItem=LEFTBARBUTTONITEM(@"", @selector(leftBtnEvent:));
    
    MWPoi *poi=nil;
    if (poiList.count>0) {
       poi=[poiList objectAtIndex:viewIndex];
    }
    else
    {

    }
    ViewPOIType viewType;
    if (viewFlag>=INTO_TYPE_ADD_THROUGH_POINT)
    {
        self.navigationItem.rightBarButtonItem=RIGHTBARBUTTONITEM(STR(@"POI_Add", Localize_POI),@selector(rightBtnEvent:));
        viewType=ViewPOIType_Normal;
        //检索得时候设置家和公司
        if (viewFlag==INTO_TYPE_ADD_FAV)
        {
            NSString * str = [POIDataCache sharedInstance].isSetHomeAddress?@"POI_SetCompanyAddress":@"POI_SetHomeAddress";
            self.title=STR(str, Localize_POI);
        }
        //检索的时候添加起点
        else if (viewFlag == INTO_TYPE_ADD_THROUGH_START)
        {
            self.title =  STR(@"Main_setStart", Localize_Main);
        }
        //检索的时候添加途经点
        else if(viewFlag ==INTO_TYPE_ADD_THROUGH_POINT)
        {
            self.title=STR(@"POI_addWayPoint", Localize_POI);
        }
        //检索的时候添加终点
        else if (viewFlag == INTO_TYPE_ADD_THROUGH_END)
        {
            self.title = STR(@"Main_setDestination", Localize_Main);
        }
        
        //地图选点进来 设置家和公司
        else if (viewFlag ==INTO_TYPE_ADD_FAVANDCHOOSEMAP)
        {
            NSString * str = [POIDataCache sharedInstance].isSetHomeAddress?@"POI_SetCompanyAddress":@"POI_SetHomeAddress";
            self.title=STR(str, Localize_POI);
            [self.navigationItem.rightBarButtonItem setEnabled:NO];
        }
        //地图选点添加起点
        else if (viewFlag ==INFO_TYPE_ADD_THROUGH_POINT_FROM_START)
        {
            self.title =  STR(@"Main_setStart", Localize_Main);
            [self.navigationItem.rightBarButtonItem setEnabled:NO];
        }
        //地图选点添加途经点
        if (viewFlag==INTO_TYPE_ADD_THROUGH_POINT_FROM_MAPMARK) {
            self.title=STR(@"POI_addWayPoint", Localize_POI);
            [self.navigationItem.rightBarButtonItem setEnabled:NO];
        }
        //地图选点添加终点
        else if (viewFlag == INFO_TYPE_ADD_THROUGH_POINT_FROM_END)
        {
            self.title = STR(@"Main_setDestination", Localize_Main);
            [self.navigationItem.rightBarButtonItem setEnabled:NO];
        }
        //地图选点用户反馈添加点
        else if(viewFlag == INTO_TYPE_ADD_FeedBack_Point)
        {
            self.title = STR(@"TS_PosLoc", Localize_UserFeedback);
            [self.navigationItem.rightBarButtonItem setEnabled:NO];
        }
    }
    else if(viewFlag==INTO_TYPE_SELECT_POINT)
    {
        viewType= ViewPOIType_SelectPOI;
    }
    else
    {
        viewType=ViewPOIType_Detail;
    }
    if (viewFlag==INTO_TYPE_NORMAL) {
        self.title=STR(@"POI_SearchPOITitle",Localize_POI);
    }
    else if (viewFlag==INTO_TYPE_SELECT_POINT)
    {
        self.title=STR(@"POI_SelectPointsInMap", Localize_POI);
    }
    else if (viewFlag == INTO_TYPE_CUSTOM_TITLE)
    {
        self.title = self.titleString;
    }
    popPoi=[[GDPopPOI alloc] initWithType:viewType];//设置家
    popPoi.topView = self.view;
    popPoi.delegate=self;
    if (poi) {
        curPOI.Coord.x = poi.longitude;
        curPOI.Coord.y = poi.latitude;
        curPOI.lNaviLon = poi.lNaviLon;
        curPOI.lNaviLat = poi.lNaviLat;
        curPOI.lCategoryID = poi.lCategoryID;
    }
    
	[self initControl];
    showObject=[[POIShowObject alloc] initwithPopPoi:popPoi withCenter:curPOI.Coord];
    showObject.poiType=viewType;
    showObject.delegate=self;
    cellEvent=[[POICellButtonEvent alloc] init];
}

-(NSMutableArray*)getShowPoiArray:(int)index
{
    int i=0; count=poiList.count;
    NSMutableArray *arr=[NSMutableArray arrayWithCapacity:0];
    for (int j=i ;j<i+count;j++) {
        MWPoi *poi = poiList[j];
         MWMapPoi *addIcon=[[MWMapPoi alloc] init] ;
        [POICommon copyWMPoiValutToSubclass:poi withPoiSubclass:addIcon];
        [arr addObject:addIcon];
        [addIcon release];
    }
    return arr;
}

-(void)initControl
{
	//地图
	//地图模式切换
	buttonSwitchMapMode = [[self buttonInCondition:10] retain];
    buttonSwitchMapMode.enabled=NO;
    [buttonSwitchMapMode setBackgroundImage:IMAGE(@"mainDirect.png",IMAGEPATH_TYPE_2) forState:UIControlStateDisabled];
	[self.view addSubview:buttonSwitchMapMode];[buttonSwitchMapMode release];
    //
	label_meter =  [[self buttonInCondition:11] retain];
    [label_meter.titleLabel setFont:[UIFont systemFontOfSize:isPad?kSize3 :10]];
	[self.view addSubview:label_meter];[label_meter release];
    [label_meter setTitleColor:GETSKINCOLOR(MAIN_DAY_METER_COLOR) forState:UIControlStateNormal];
	//收藏，微享，实时交通，搜索
    label_meter.titleLabel.font = [UIFont systemFontOfSize:10.0f];
    if([[MWPreference sharedInstance] getValue:PREF_DAYNIGHTMODE] == 1)
    {
        [label_meter setTitleColor:GETSKINCOLOR(MAIN_NIGHT_METER_COLOR) forState:UIControlStateNormal];
    }
    else
    {
        [label_meter setTitleColor:GETSKINCOLOR(MAIN_DAY_METER_COLOR) forState:UIControlStateNormal];
    }
	
        
    //放大，缩小
    bLongPressed = NO;
	buttonINC = [UIButton buttonWithType:UIButtonTypeCustom];
    UILongPressGestureRecognizer *longPress =[[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(ZoomInLongPressed:)]autorelease];
	longPress.minimumPressDuration =0.2;
	[buttonINC addGestureRecognizer:longPress];
	[buttonINC addTarget:self action:@selector(incFun:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:buttonINC];
    buttonINC.tag=21;
    buttonINC.showsTouchWhenHighlighted = YES;
    
    buttonDEC = [UIButton buttonWithType:UIButtonTypeCustom];
    longPress =[[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(ZoomOutLongPressed:)]autorelease];
	longPress.minimumPressDuration =0.2;
	[buttonDEC addGestureRecognizer:longPress];
	[buttonDEC addTarget:self action:@selector(decFun:) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:buttonDEC];
    buttonDEC.showsTouchWhenHighlighted = YES;
	buttonDEC.tag=22;
	//比例尺选择
    [buttonINC setBackgroundImage:IMAGE(@"mainEnlargeMap.png",IMAGEPATH_TYPE_2) forState:UIControlStateNormal];
    [buttonINC setBackgroundImage:IMAGE(@"mainEnlargeMapPress.png",IMAGEPATH_TYPE_2)  forState:UIControlStateHighlighted];
    [buttonINC setBackgroundImage:IMAGE(@"mainEnlargeMapDisable.png", IMAGEPATH_TYPE_2) forState:UIControlStateDisabled];
    
    [buttonDEC setBackgroundImage:IMAGE(@"mainNarrow.png",IMAGEPATH_TYPE_2)  forState:UIControlStateNormal];
    [buttonDEC setBackgroundImage:IMAGE(@"mainNarrowPress.png",IMAGEPATH_TYPE_2)  forState:UIControlStateHighlighted];
    [buttonDEC setBackgroundImage:IMAGE(@"mainNarrowDisable.png", IMAGEPATH_TYPE_2) forState:UIControlStateDisabled];

}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    if(isNearBy==NO)
    {
        [[MWMapOperator sharedInstance] MW_GoToCCP];
    }
    _mapView.delegate=nil;  //不能放在dealoc中，要不会出现poi图标点击不了的情况
    [super viewWillDisappear:animated];
}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated
{
    cellEvent.viewController=self;
    _mapView = [MapViewManager ShowMapViewInController:self]; //要放在调用 [super viewWillAppear:animated] 之前，切换多次地图后，会造成无法放大缩小
	[super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
  
    ViewPOIType viewType;
    if (viewFlag==INTO_TYPE_ADD_FAV) {
        viewType=ViewPOIType_Normal;
    }
    else if(viewFlag>=INTO_TYPE_ADD_THROUGH_POINT)
    {
        viewType=ViewPOIType_Normal;
    }
    else if(viewFlag==INTO_TYPE_SELECT_POINT)
    {
        viewType= ViewPOIType_SelectPOI;
    }
    else
    {
        viewType=ViewPOIType_Detail;
    }
    
    NSMutableArray *arr = nil;
    arr=[self getShowPoiArray:viewIndex];
    if (!mapAddIcon) {
        NSString *poiImageName=@"layer_redPoi.png";
//        GMAPVIEWINFO mapObjectInfo = {0};
//        [[MWMapOperator sharedInstance] MW_GetMapViewInfo:GMAP_VIEW_TYPE_MAIN MapViewInfo:&mapObjectInfo];
//        if(mapObjectInfo.eMapMode == GMAPVIEW_MODE_3D) {
//            poiImageName=@"layer_3DPoi.png";
//        }
        mapAddIcon = [[MWMapAddIconOperator alloc] initWith:[NSDictionary dictionaryWithObject:arr forKey:poiImageName] inView:_mapView delegate:self];
    }
    else{
        [mapAddIcon freshPoiDic:[NSDictionary dictionaryWithObject:arr forKey:@"layer_redPoi.png"]];
    }
    
//    [self ChangePOI];
    MWPoi *poi=[popPoi getPopPOIData];
    [popPoi setPopPOIType:viewType];
    if (poi) {
        if (poi.szName.length==0) {
            poi=self.currentPoi;
        }
        else
        {
            self.currentPoi=poi;
        }
        
        if (viewType==ViewPOIType_Detail) {
            popPoi.favoriteState=[MWPoiOperator isCollect:poi];
        }
        if (poi!=nil) {
            [popPoi setStringAtPos:poi withMapType:GMAP_VIEW_TYPE_MAIN];
            [popPoi setHidden:NO];
//          [popPoi movePOIViewWithPoint];
        }
    }
   
    
  
	[self MoveMap];
    
    double delayInSeconds = 0.4;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [[MWMapOperator sharedInstance] MW_ShowMapView:GMAP_VIEW_TYPE_MAIN WithParma1:0 WithParma2:0 WithParma3:0];
    });
    
    
    if (poiList.count>0) {
    }
    else
    {
        if(_firstIn)
        {
            [[MWMapOperator sharedInstance] MW_GoToCCP];
            _firstIn =NO;
        }
        
    }
    
    isNearBy=NO;

}

- (void)listenNotification:(NSNotification *)notification {
	
    if([notification.name isEqual:NOTIFY_UPDATE_VIEWINFO])
    {
        GDBL_CloseZoomView();
    }

	if ([notification.name isEqual:NOTIFY_SHOWMAP]&& self.navigationController.topViewController == self)
	{
        
        [_mapView swapBuffers];
        [self ChangePOI];
		[self viewInfoInCondition:0];

        if ((NSFoundationVersionNumber >= NSFoundationVersionNumber_iPhoneOS_3_2) &&(GDBL_CheckRecognizeType(EVENT_PINCH) || GDBL_CheckRecognizeType(EVENT_PAN) ||  GDBL_CheckRecognizeType(EVENT_PAN_MOVE) ||GDBL_CheckRecognizeType(EVENT_ROTATE)))
        {
            BOOL isSearchPOi=NO;
            if (GDBL_CheckRecognizeType(EVENT_PINCH)||GDBL_CheckRecognizeType(EVENT_TAP_DOUBLE)||GDBL_CheckRecognizeType(EVENT_DOUBLE_FINGER_TAP)) {
                isSearchPOi=NO;
            }
            else if(GDBL_CheckRecognizeType(EVENT_PAN)||GDBL_CheckRecognizeType(EVENT_PAN_MOVE))
            {
                [popPoi setHidden:YES];
                isSearchPOi=YES;
            }
            
            isShowPoi=isSearchPOi;
            if (m_delayShowButton)
            {
                [m_delayShowButton invalidate];
                m_delayShowButton = nil;
            }
            m_delayShowButton = [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(delayShowButton:) userInfo:nil repeats:NO];
            
        }
	}
}

#pragma mark PaintingViewDelagate
-(void)mapView:(PaintingView *)mapView GestureRecognizer:(UIGestureRecognizer *)recognizer gestureType:(RECOGNIZETYPE)gesturetype  withParam:(int)param
{
    
    switch (gesturetype) {
        case EVENT_PAN:
        {
            [popPoi setHidden:YES];
        }
        break;
  
        case EVENT_LONGPRESS:
        {
            if (recognizer.state == UIGestureRecognizerStateBegan)
            {
//                if ([ANParamValue sharedInstance].isPath) {
//                    return;
//                }
                if ([[MWPreference sharedInstance] getValue:PREF_AUTO_GETPOIINFO]) {
                    return;
                }
                [popPoi setHidden:YES];
                CGPoint myPoint = [recognizer locationInView:recognizer.view];
                GFCOORD scrCoord = {0};
                scrCoord.x = myPoint.x*[ANParamValue sharedInstance].scaleFactor;
                scrCoord.y = myPoint.y*[ANParamValue sharedInstance].scaleFactor;
                GCOORD coord = [MWEngineTools ScrToGeo:scrCoord];
                showObject.popPoi = popPoi;
                showObject.coord = coord;
                [showObject show];
            }
            else if (recognizer.state == UIGestureRecognizerStateChanged)
            {
                
            }
            else if (recognizer.state == UIGestureRecognizerStateEnded)
            {
                
            }
        }
            break;
        case EVENT_TAP_SINGLE:
        {
            CGPoint myPoint = [recognizer locationInView:recognizer.view];
            MWPoi *hitPoi = [MWMapOperator getMapPoiByHitPoint:myPoint];
            if (hitPoi)
            {
                [popPoi setStringAtPos:hitPoi withMapType:GMAP_VIEW_TYPE_MAIN];
                [popPoi startAnimate:0.3];
                [popPoi setHidden:NO];
                [self.navigationItem.rightBarButtonItem setEnabled:YES];
                return;
            }
            
            [popPoi setHidden:YES];
        }
            break;
        default:
            break;
    }
    
}

-(void)dealloc
{

    CRELEASE(mapAddIcon);
    [[MWMapOperator sharedInstance] MW_GoToCCP];
    CLOG_DEALLOC(self);
    popPoi.delegate=nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    showObject.delegate=nil;
    CRELEASE(showObject);
    CRELEASE(popPoi);
    CRELEASE(poiList);
    CRELEASE(cellEvent);
    self.titleString=nil;
    if (m_delayShowButton)
    {
        [m_delayShowButton invalidate];
        m_delayShowButton = nil;
    }
	[super dealloc];
}
//设置横竖屏

- (void)changePortraitControlFrameWithImage {
	
    [_mapView setmyFrame:CGRectMake(0.0, 0.0, SCREENWIDTH, SCREENHEIGHT)];
    [[MWPreference sharedInstance] setValue:PREF_DISPLAY_ORIENTATION Value:1];

    CGAffineTransform at =CGAffineTransformMakeRotation(0);//设置Frame前，先将角度旋转为0度，要不会发生变形
    [buttonSwitchMapMode setTransform:at];
	[buttonSwitchMapMode setFrame:CGRectMake(0.0f,0.0f,40.0f, 40.0f)];
	[buttonSwitchMapMode setCenter:CGPointMake(25.5, 76.5-44.0f)];
    //放大，缩小
    
    [buttonINC setFrame:CGRectMake(0.0f, 0.0f, 40.0f, 42.0f)];
    [buttonINC setCenter:CGPointMake(APPWIDTH-26.0f, APPHEIGHT-140.0f)];
    
    [buttonDEC setFrame:CGRectMake(0.0f, 0.0f, 40.0f, 42.0f)];
    [buttonDEC setCenter:CGPointMake(APPWIDTH-26.0f, APPHEIGHT-98.0f)];
    
    [label_meter setFrame:CGRectMake(0.0f, 0.0f, 36.0f, 12.0f)];
    [label_meter setCenter:CGPointMake(APPWIDTH-26.0f, APPHEIGHT-68.0f)];
    if (isPad) {
        [buttonINC setFrame:CGRectMake(0.0f, 0.0f, 60, 63)];
        [buttonINC setCenter:CGPointMake(APPWIDTH-36.0f, (1596-55)/2.0f - 11)];
        
        [buttonDEC setFrame:CGRectMake(0.0f, 0.0f, 60, 63)];
        [buttonDEC setCenter:CGPointMake(APPWIDTH-36.0f, (1706-55)/2.0f - 3)];
        
        [label_meter setFrame:CGRectMake(0.0f, 0.0f, 50, 20.0f)];
        [label_meter setCenter:CGPointMake(APPWIDTH-36.0f, (1785-50)/2.0f)];
        
        //指南针方向
        CGAffineTransform at =CGAffineTransformMakeRotation(0);//设置Frame前，先将角度旋转为0度，要不会发生变形
        [buttonSwitchMapMode setTransform:at];
        [buttonSwitchMapMode setFrame:CGRectMake(0.0f,0.0f,60.0f, 60.0)];
        [buttonSwitchMapMode setCenter:CGPointMake(38.0f, 122.0f - 44.0f - 30.0f)];

    }
    

    [self reloadEnlargeAndNarrowImage];
}
//横屏
- (void)changeLandscapeControlFrameWithImage {
    [_mapView setmyFrame:CGRectMake(0.0, 0.0, SCREENHEIGHT, SCREENWIDTH)];
    [[MWPreference sharedInstance] setValue:PREF_DISPLAY_ORIENTATION Value:0];
	
   	
    //#pragma mark 地图模式切换,高德微享,迅飞语音
    CGAffineTransform at =CGAffineTransformMakeRotation(0);
    [buttonSwitchMapMode setTransform:at];
	[buttonSwitchMapMode setFrame:CGRectMake(0.0f,0.0f,40.0f, 40.0f)];
	[buttonSwitchMapMode setCenter:CGPointMake(25.5, 76.5f-44)];
    
    [buttonINC setFrame:CGRectMake(0.0f, 0.0f, 42.0f, 40)];
    [buttonINC setCenter:CGPointMake(APPHEIGHT - 36.0f - buttonINC.frame.size.width, CONTENTHEIGHT_H-15.0f - buttonINC.frame.size.height / 2)];
    [buttonDEC setFrame:CGRectMake(0.0f, 0.0f, 42.0f, 40)];
    [buttonDEC setCenter:CGPointMake(APPHEIGHT - 36.0f,  CONTENTHEIGHT_H-15.0f - buttonINC.frame.size.height / 2)];
    [label_meter setFrame:CGRectMake(0.0f, 0.0f, 36.0f, 12.0f)];
    [label_meter setCenter:CGPointMake(APPHEIGHT - 36.0f, buttonINC.frame.origin.y  - 6.0f - label_meter.frame.size.height / 2)];

    if (isPad) {
        [buttonINC setFrame:CGRectMake(0.0f, 0.0f, 60, 63)];
        [buttonDEC setFrame:CGRectMake(0.0f, 0.0f, 60, 63)];
        [label_meter setFrame:CGRectMake(0.0f, 0.0f, 56, 24.0f)];
        [buttonINC setCenter:CGPointMake(APPHEIGHT - 36.0f, (1161-55)/2.0f-8)];
        if([[UIScreen mainScreen] scale] == 2)
        {
            [buttonDEC setCenter:CGPointMake(APPHEIGHT - 36.0f,(1271-55)/2.0f)];
        }
        else
        {
            [buttonDEC setCenter:CGPointMake(APPHEIGHT - 36.0f,(1271-55)/2.0f - 1)];
        }
        
        
        [label_meter setCenter:CGPointMake(APPHEIGHT - 36.0f, (1350-55)/2.0f)];
        
        //指南针方向
        CGAffineTransform at =CGAffineTransformMakeRotation(0);//设置Frame前，先将角度旋转为0度，要不会发生变形
        [buttonSwitchMapMode setTransform:at];
        [buttonSwitchMapMode setFrame:CGRectMake(0.0f,0.0f,60.0f, 60.0)];
        [buttonSwitchMapMode setCenter:CGPointMake(38.0f, 122.0f - 44.0f-30.0f)];


  	}

    [self reloadEnlargeAndNarrowImage];
}

- (void) reloadEnlargeAndNarrowImage
{
    //竖屏状态或者是iPad都不用横屏的图片
    if(Interface_Flag == 0 || !isiPhone)
    {
        [buttonINC setBackgroundImage:IMAGE(@"mainEnlargeMap.png", IMAGEPATH_TYPE_2) forState:UIControlStateNormal];
        [buttonINC setBackgroundImage:IMAGE(@"mainEnlargeMapPress.png", IMAGEPATH_TYPE_2) forState:UIControlStateHighlighted];
        [buttonDEC setBackgroundImage:IMAGE(@"mainNarrow.png", IMAGEPATH_TYPE_2) forState:UIControlStateNormal];
        [buttonDEC setBackgroundImage:IMAGE(@"mainNarrowPress.png", IMAGEPATH_TYPE_2) forState:UIControlStateHighlighted];
    }
    else
    {
        [buttonINC setBackgroundImage:IMAGE(@"mainEnlargeMapLandscape.png", IMAGEPATH_TYPE_2) forState:UIControlStateNormal];
        [buttonINC setBackgroundImage:IMAGE(@"mainEnlargeMapPressLandscape.png", IMAGEPATH_TYPE_2) forState:UIControlStateHighlighted];
        [buttonDEC setBackgroundImage:IMAGE(@"mainNarrowLandscape.png", IMAGEPATH_TYPE_2) forState:UIControlStateNormal];
        [buttonDEC setBackgroundImage:IMAGE(@"mainNarrowPressLandscape.png", IMAGEPATH_TYPE_2) forState:UIControlStateHighlighted];
    }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [[MWMapOperator sharedInstance] MW_ShowMapView:GMAP_VIEW_TYPE_MAIN WithParma1:0 WithParma2:0 WithParma3:0];
}




-(void)delayShowButton:(id)sender
{
    if (m_delayShowButton)
    {
        [m_delayShowButton invalidate];
        m_delayShowButton = nil;
    }
     [self.view sendSubviewToBack:_mapView];
    
//    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    if (isShowPoi) {
        if ([[MWPreference sharedInstance] getValue:PREF_AUTO_GETPOIINFO]) {//移图后显示poi详情
            [popPoi setHidden:YES];
            GMAPCENTERINFO mapCenter = {0};
            GHMAPVIEW phMapView;
            GDBL_GetMapViewHandle(GMAP_VIEW_TYPE_MAIN, &phMapView);
            GDBL_GetMapViewCenterInfo(phMapView, &mapCenter);
            showObject.coord = mapCenter.CenterCoord;
            [showObject show];
            
        }
    }
   
}
- (void)panRecongnizer:(UIPanGestureRecognizer *)recognizer 
{
    //手势干扰按钮按键
    if (inc_timer != nil) {
        [inc_timer invalidate];
        inc_timer = nil;
    }
    if (dec_timer != nil) {
        [dec_timer invalidate];
        dec_timer = nil;
    }
    if (recognizer.state == 2)
    {

    }
    if(recognizer.state == 3)
    {
        isShowPoi=NO;
        [self performSelector:@selector(delayShowButton:) withObject:@(0) afterDelay:0.5f];
    }
}



#pragma mark - 画标签
-(void)ChangePOI
{
    if (self.currentPoi) {
        [popPoi movePOIViewWithPoint];
    }
    
}

#pragma mark - action
//更新主界面上——更多，微享的new图标的显示
- (void)handleUIUpdate:(NSNotification *)result
{
    switch ([[result object] intValue]) {
        case UIUpdate_MapDayNightModeChange:
        {
            int type = [[result.userInfo objectForKey:@"dayNightMode"]integerValue];
            if(type == 0)
            {
                [label_meter setTitleColor:GETSKINCOLOR(MAIN_DAY_METER_COLOR)  forState:UIControlStateNormal];
            }
            else
            {
                [label_meter setTitleColor:GETSKINCOLOR(MAIN_NIGHT_METER_COLOR) forState:UIControlStateNormal];
            }
            [self setDayAndNightStyle];
        }
            break;
        case UIUpdate_TMC:
        {
            [[MWPreference sharedInstance]  setValue:PREF_REALTIME_TRAFFIC Value:[MWEngineSwitch isTMCOn]];
            
        }
            break;
        default:
            break;
    }
    
}

-(void) setSwitchTripDirect
{
    [buttonSwitchMapMode setBackgroundImage:IMAGE(@"mainDirect.png", IMAGEPATH_TYPE_2) forState:UIControlStateNormal];
    CGFloat angle;

    angle = (M_PI / 180.0) *[[MWMapOperator sharedInstance] GetCarDirection:GMAP_VIEW_TYPE_MAIN];
    
    CGAffineTransform at =CGAffineTransformMakeRotation(angle);
    [buttonSwitchMapMode setTransform:at];
}

//设置白天黑夜图片
- (void) setDayAndNightStyle
{
    
    [self setSwitchTripDirect];
    [buttonINC setBackgroundImage:IMAGE(@"mainEnlargeMap.png", IMAGEPATH_TYPE_2) forState:UIControlStateNormal];
    [buttonINC setBackgroundImage:IMAGE(@"mainEnlargeMapPress.png", IMAGEPATH_TYPE_2) forState:UIControlStateHighlighted];
    
    [buttonDEC setBackgroundImage:IMAGE(@"mainNarrow.png", IMAGEPATH_TYPE_2) forState:UIControlStateNormal];
    [buttonDEC setBackgroundImage:IMAGE(@"mainNarrowPress.png", IMAGEPATH_TYPE_2) forState:UIControlStateHighlighted];
}

//实时路况
#pragma mark - button fun
- (UIButton *)buttonInCondition:(NSInteger)condition {
	
	UIButton *button;
	
	NSString *normalImage;

	switch (condition) 
	{
		case 10:
		{//地图模式切换

            normalImage=@"mainDirect.png";
		}
        case 11:// 比例尺
		{
			normalImage = @"mainScaleIcon.png";
		}
			break;
		default:
			break;
	}
	
    button=[UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage:IMAGE(normalImage,IMAGEPATH_TYPE_2) forState:UIControlStateNormal];
    [button setBackgroundImage:IMAGE(normalImage,IMAGEPATH_TYPE_2) forState:UIControlStateHighlighted];
    [self.view addSubview:button];
    button.tag=condition;
//    [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (UILabel *)labelInCondition:(NSInteger)condition {
	
	UILabel *label;
	
	NSString *text;
	CGFloat size;
	UITextAlignment textAlignment;
	
	switch (condition) 
	{
		case 0:
		{
			text = @"1k";
			textAlignment = UITextAlignmentCenter;  
			size = 15.0f;
		}
			break;
			
		default:
			break;
	}
	
	label = [self createLabelWithText:text fontSize:size textAlignment:textAlignment];
	
	text = nil;
	
	return label;
}
- (void)viewInfoInCondition:(NSInteger)condition {
	
	switch (condition) 
	{
		case 0:
		{
			//获取当前比例尺
			[label_meter setTitle:[[MWMapOperator sharedInstance] GetCurrentScale] forState:UIControlStateNormal];
            if ([[MWPreference sharedInstance] getValue:PREF_MAPVIEWMODE] == MAP_3D) {
                int DScale = [[MWMapOperator sharedInstance] GMD_Get3DScale];
                
                if (DScale == 90) 
                {
                    buttonINC.alpha = 0.4;
                    buttonDEC.alpha = 1.0;
                }
                else if ((Interface_Flag == 0 && DScale == 20) || (Interface_Flag == 1 && DScale == 10))
                {
                    buttonINC.alpha = 1.0;
                    buttonDEC.alpha = 0.4;

                }
                else {
                    buttonINC.alpha = 1.0;
                    buttonDEC.alpha = 1.0;

                }
            }
            else {
                if ([label_meter.titleLabel.text isEqualToString:@"15m"])
                {
                    buttonINC.alpha = 0.4;
                    buttonDEC.alpha = 1.0;
                    
                }
                else if ([label_meter.titleLabel.text isEqualToString:@"500km"])
                {
                    buttonINC.alpha = 1.0;
                    buttonDEC.alpha = 0.4;

                }
                else {
                    buttonINC.alpha = 1.0;
                    buttonDEC.alpha = 1.0;

                }
            }
            
            [self setSwitchTripDirect];
            
           
            }
			break;
			
		default:
			break;
	}
}



- (void)buttonAction:(id)sender {

	switch (((UIButton *)sender).tag)
	{

    }
}

//移图响应函数
-(void)MoveMap
{
    if (self.currentPoi) {
        GMOVEMAP moveMap;
        moveMap.eOP = MOVEMAP_OP_GEO_DIRECT;
        curPOI.Coord.x=self.currentPoi.longitude;
        curPOI.Coord.y=self.currentPoi.latitude;
        moveMap.deltaCoord = curPOI.Coord;
        [[MWMapOperator sharedInstance] MW_MoveMapView:GMAP_VIEW_TYPE_MAIN TypeAndCoord:&moveMap];
    }
}

- (void)ZoomInLongPressed:(UILongPressGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan)
	{
        bLongPressed = YES;
		inc_timer = [NSTimer scheduledTimerWithTimeInterval:0.2f
                                                      target:self
                                                    selector:@selector(incFun:)
                                                    userInfo:nil
                                                     repeats:YES];
        [inc_timer fire];
	}
	else if (recognizer.state == UIGestureRecognizerStateChanged)
	{
        
	}else 	if (recognizer.state == UIGestureRecognizerStateEnded)
	{
        [self Stop_Idec:buttonINC];
	}
    
}

- (void)ZoomOutLongPressed:(UILongPressGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan)
	{
        bLongPressed = YES;
		dec_timer = [NSTimer scheduledTimerWithTimeInterval:0.2f
                                                      target:self
                                                    selector:@selector(decFun:)
                                                    userInfo:nil
                                                     repeats:YES];
        [dec_timer fire];
	}
	else if (recognizer.state == UIGestureRecognizerStateChanged)
	{
        
	}else 	if (recognizer.state == UIGestureRecognizerStateEnded)
	{
        [self Stop_Idec:buttonDEC];
	}
}

- (void)incFun:(NSTimer *)timer {
	
	//NSLog(@"decFun");
    if (bLongPressed)
    {
        bLongPressed = NO;
        return;
    }
	if ([[MWPreference sharedInstance] getValue:PREF_MAPVIEWMODE] == MAP_3D) {
        int DScale = [[MWMapOperator sharedInstance] GMD_Get3DScale];
        if (DScale == 90) 
        {
            if (inc_timer != nil) {
                [inc_timer invalidate];
                inc_timer = nil;
            }
            return;
        }
    }
    else {
        if ([label_meter.titleLabel.text isEqualToString:@"15m"])
        {
            if (inc_timer != nil) {
                [inc_timer invalidate];
                inc_timer = nil;
            }
            return;
        }
    }

	[[MWMapOperator sharedInstance] MW_ZoomMapView:GMAP_VIEW_TYPE_MAIN ZoomFlag:GSETMAPVIEW_LEVEL_IN ZoomLevel:0];
}


- (void)decFun:(NSTimer *)timer {
	
	//NSLog(@"incFun");
    if (bLongPressed)
    {
        bLongPressed = NO;
        return;
    }
	if ([[MWPreference sharedInstance] getValue:PREF_MAPVIEWMODE] == MAP_3D) {
        int DScale = [[MWMapOperator sharedInstance] GMD_Get3DScale];
        if ((Interface_Flag == 0 && DScale == 20) || (Interface_Flag == 1 && DScale == 10)) 
        {
            if (dec_timer != nil) {
                [dec_timer invalidate];
                dec_timer = nil;
            }
            return;
        }
    }
    else {
        if ([label_meter.titleLabel.text isEqualToString:@"500km"])
        {
            if (dec_timer != nil) {
                [dec_timer invalidate];
                dec_timer = nil;
            }
            return;
        }
    }
	[[MWMapOperator sharedInstance] MW_ZoomMapView:GMAP_VIEW_TYPE_MAIN ZoomFlag:GSETMAPVIEW_LEVEL_OUT ZoomLevel:0];
}


- (void)Stop_Idec:(id)sender {
	
	//NSLog(@"Stop_Idec");
	UIButton *button = (UIButton *)sender;
	if (button.tag==21) 
	{
		if (inc_timer != nil) {
            [inc_timer invalidate];
            inc_timer = nil;
        }
	}
	else if (button.tag==22) 
	{
        if (dec_timer != nil) {
            [dec_timer invalidate];
            dec_timer = nil;
        }
	}
}




#pragma mark -
#pragma mark Touch

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

	switch ([touches count])
	{
		case 1:
		{
			[self dispatchFirstTouchAtPoint:[[[touches allObjects] objectAtIndex:0] locationInView:self.view] secondTouchAtPoint:CGPointMake(0.0, 0.0)];
		}
			break;
			
		default:
			break;
	}
//    if (m_delayShowButton)
//    {
//        [m_delayShowButton invalidate];
//        m_delayShowButton = nil;
//    }
    isOperate=YES;
    [showObject cancel];
//    [popPoi setHidden:YES];
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
		
		GMOVEMAP moveMap;
        moveMap.eOP = MOVEMAP_OP_DRAG;
        moveMap.deltaCoord.x = -dX;
        moveMap.deltaCoord.y = -dY;
		[[MWMapOperator sharedInstance] MW_MoveMapView:GMAP_VIEW_TYPE_MAIN TypeAndCoord:&moveMap];
	}
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
      [showObject cancel];
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
		
}
#pragma mark POIShowObjectDelegate
- (void) afterSuccessSearch
{
    self.currentPoi=[popPoi getPopPOIData];
    //返回成功都设置为可以添加
    [self.navigationItem.rightBarButtonItem setEnabled:YES];
}
- (void) afterFailSearch
{
    //返回失败都设置为 不可点击
    [self.navigationItem.rightBarButtonItem setEnabled:NO];
}

#pragma mark MWMapAddIconOperationDelegate
- (void)tapMapPoiIconnWith:(MWMapPoi *)mapPoi
{
    [popPoi setHidden:YES];
    self.currentPoi=mapPoi;
    
    if (m_delayShowButton)
    {
        [m_delayShowButton invalidate];
        m_delayShowButton = nil;
    }
    popPoi.topView = self.view;
    [showObject showPOI:mapPoi];
}

#pragma mark -
#pragma mark GDPopPOIDelegate

- (void)GDPopViewTaped:(id)sender POI:(MWPoi *)poi
{
    [popPoi setHidden:NO];
    UIButton *button=(UIButton*)sender;
    switch (button.tag) {
        case ViewPOIButtonType_collect:
        {
            BOOL isSuccess;
            if ([poi isMemberOfClass:[MWFavoritePoi class]]) {
               isSuccess= [MWPoiOperator reverseCollectPoi:(MWFavoritePoi*)poi];
                NSLog(@"isSuccess =%i",isSuccess);
                if (isSuccess) {
                    popPoi.favoriteState=!popPoi.favoriteState;
                }
                
            }
            else if([poi isMemberOfClass:[MWSmartEyesItem class]])
            {
                MWSmartEyesItem *smartEyesItem=(MWSmartEyesItem*)poi;
               
                MWFavoritePoi *favoritePoi=[[MWFavoritePoi alloc] init];
                favoritePoi.eCategory=GFAVORITE_CATEGORY_DEFAULT;
                favoritePoi.eIconID=GFAVORITE_ICON_DEFAULT;
                favoritePoi.longitude=smartEyesItem.longitude;
                favoritePoi.latitude=smartEyesItem.latitude;
                favoritePoi.lAdminCode=smartEyesItem.lAdminCode;
                favoritePoi.lCategoryID=smartEyesItem.lCategoryID;
                favoritePoi.szName=smartEyesItem.szName;
                favoritePoi.szAddr=smartEyesItem.szAddr;
                favoritePoi.szTel=smartEyesItem.szTel;
                favoritePoi.szTown=smartEyesItem.szTown;
               isSuccess = [MWPoiOperator reverseCollectPoi:favoritePoi];
                if (isSuccess) {
                      popPoi.favoriteState=!popPoi.favoriteState;
                }
                [favoritePoi release];
            
            }
            else
            {
                MWFavoritePoi *favoritePoi=[[MWFavoritePoi alloc] init];
                [POICommon copyWMPoiValutToSubclass:poi withPoiSubclass:favoritePoi];
                
                favoritePoi.eCategory=GFAVORITE_CATEGORY_DEFAULT;
                favoritePoi.eIconID=GFAVORITE_ICON_DEFAULT;
                isSuccess =[MWPoiOperator reverseCollectPoi:favoritePoi];
                if (isSuccess) {
                    popPoi.favoriteState=!popPoi.favoriteState;
                }
                [favoritePoi release];
                
            }
            if (isSuccess) {
                
            
            if(popPoi.favoriteState == 0)
            {
                [QLoadingView showAlertWithoutClick:STR(@"Main_collectCancel", Localize_Main) ShowTime:1.0];
            }
            else
            {
                [QLoadingView showAlertWithoutClick:STR(@"Main_colloectOK", Localize_Main) ShowTime:1.0];
            }
            }

        }
            break;
        case ViewPOIButtonType_setStart:
        {
            
        }
            break;
        case ViewPOIButtonType_setDes:
        {
           
            [MobClick event:UM_EVENTID_NAVI_COUNT label:UM_LABEL_NAVI_FROM_POI];
            [cellEvent naviButtonEvent:poi withAnimate:NO];
        }
            break;
        case ViewPOIButtonType_around:
        {
            if ( [MWAdminCode checkIsExistDataWithAdmincode:0] == 0) {
                GDAlertView *alertView = [[[GDAlertView alloc] initWithTitle:nil andMessage:STR(@"POI_AlreadyNoData",Localize_POI)] autorelease];
                [alertView addButtonWithTitle:STR(@"POI_OK",Localize_POI) type:GDAlertViewButtonTypeCancel handler:nil];
                [alertView show];
                return;
            }
            if (viewFlag==INTO_TYPE_NEARBY) {
                GDAlertView *alertView=[[[GDAlertView alloc] initWithTitle:nil andMessage:STR(@"POI_AlreadyInNeary",Localize_POI)] autorelease];
                [alertView show];
            }
            else
            {
                isNearBy=YES;
                [[PluginStrategy sharedInstance] allocModuleWithName:@"Plugin_POI" withObject:@{POI_NAVIGATIONCONTROLLER:self.navigationController,POI_TYPE:@(1)}];
            }
            
        }
            break;

            case ViewPOIButtonType_more:
        {
            POIDetailViewController *detailViewContoller=[[POIDetailViewController alloc] initWithPOI:poi];
            [self.navigationController pushViewController:detailViewContoller animated:YES];
            [detailViewContoller  release];
        }
            break;
            case ViewPOIButtonType_selectPOISetDes:
        {
            [MobClick event:UM_EVENTID_NAVI_COUNT label:UM_LABEL_NAVI_FROM_MAP_MARK];
             [cellEvent naviButtonEvent:poi withAnimate:NO];
        }
            break;
            
        default:
            break;
    }
}
@end

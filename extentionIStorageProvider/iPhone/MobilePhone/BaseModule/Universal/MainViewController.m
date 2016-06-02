
//  MainViewController.m
//  AutoNavi
//
//  Created by longfeng.huang on 12-3-26.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "PaintingView.h"
#import "ANParamValue.h"
#import "ANOperateMethod.h"//地图常用操作接口
#import "MainViewController.h"
#import "GDActionSheet.h"
//#import "RouteSearchTypeView.h"
#import "PluginStrategy.h"
#import "LXActivity.h"
#import "Plugin_POI.h"
#import "POIDetailViewController.h"
#import "ANDataSource.h"
#import "Plugin_DataVerifyDelegate.h"
#import "CityDownLoadModule.h"
#import "DefineNotificationParam.h"
#import "CheckMapDataObject.h"
#import "MWTTS.h"
#import "RouteDetourViewController.h"
#import "ParkingInfoAlertView.h"
#import "POICommon.h"
#import "UMengEventDefine.h"
// 实时交通
#import "CustomBtn.h"
#import "CustomRealTimeTraffic.h"
#import "Plugin_Dialect.h"
#import "GDBL_Account.h"
#import "Plugin_Account_Utility.h"
#import "QLoadingView.h"
#import "Plugin_Account_Globall.h"
#import "Plugin_Account.h"
#import "UIImage+Category.h"
#import "HudViewController.h"
#import "launchRequest.h"
#import "AccountNotify.h"
#import "AppDelegate_iPhone.h"
#import "MWMapOperator.h"
#import "MWPoiOperator.h"
#import "MWApp.h"
#import "Plugin_Share.h"
#import "RoutePlanningAndDetailViewController.h"
#import "BottomMenuBar.h"
#import "Plugin_Setting.h"
#import "GDAlertView.h"
#import "GDBL_UserBehaviorCountNew.h"
#import "MWDefine.h"
#import "GDPopPOI.h"
#import "DMDataDownloadManagerViewController.h"
#import "ProgressBar.h"
#import "MWAccountOperator.h"
#import "POIVoiceSearch.h"
#import "GDMenu.h"
#import "RoutePointViewController.h"
#import "BottomButton.h"
#import "WarningViewController.h"
#import "PluginStrategy.h"
#import "MWMapAddIconOperator.h"
#import "Plugin_Share.h"
#import "VCCustomNavigationBar.h"
#import "POIDesParkObj.h"
#import "POIShowObject.h"
#import "GDSkinColor.h"
#import "Plugin_CarService.h"
#import "MWSkinDownloadManager.h"
#import "plugin-cdm-Task.h"
#import "MileRecordDataControl.h"
#import "NewRedPointData.h"
#import "DrivingTrackDetailViewController.h"
#import "DringTracksManage.h"
#import "SoundGuideView.h"

#import "RouteDetailButton.h"
#import "MainDefine.h"
#import "MainCarModeView.h"
#import "MainBottomMenuObject.h"
#import "MainLargeAndNarrowObject.h"
#import "MainCruiseTopObject.h"
#import "MainNaviTopObject.h"
#import "MainNaviBottomObject.h"
#import "MainSimBottomObject.h"
#import "MainOtherObject.h"
#import "MainOverSpeed.h"


#define NEW_WIDTH   36
#define NEW_HIGHT   34
//右侧滑出栏缩小的比例
#define SIDE_RIGHT_CHANGE 0.95f
//推出的侧边栏占界面的比例 0 - 1
#define RIGHT_VIEW_PERCENT 0.5f

static BOOL routeResult = NO;
static int timerCount = 0;//定时器计数

static BOOL isEnterNewView = NO;//是否进入开机新功能查看
//底栏的各种状态
#define  BOTTM_COMMON_TAG           17  //正常低栏状态
#define  BOTTOM_SIMU_TAG            18
#define  BOTTOM_PARKING             19  //目的地停车场





@interface MainViewController ()<RouteCalDelegate,UIDocumentPickerDelegate,UIDocumentMenuDelegate>

- (void)dispatchFirstTouchAtPoint:(CGPoint)firstTouchPoint secondTouchAtPoint:(CGPoint)touchPoint;

- (void)viewInCondition:(NSInteger)condition;
- (void)viewInfoInCondition:(NSInteger)condition;

- (UILabel *)labelInCondition:(NSInteger)condition;

- (UIButton *)buttonInCondition:(NSInteger)condition;
- (ANButton *)ANbuttonInCondition:(NSInteger)condition;

-(void)initControl;
- (void)changeViewFrameWithID:(NSInteger)ID;
-(void)invalidPosition;
-(void)buttonShowStatus:(int)status;

-(void)delayNav:(id)sender;


@end


@implementation MainViewController
#pragma mark -
#pragma mark =====funtion=====
- (void)JudgmentRetainDay
{
    if (m_accountInfo.m_retaiDay > 0)
    {
        if ([m_accountInfo.m_tel_95190 length] == 11)
        {
        }
        else
        {
            [[Plugin_Account_Utility shareInstance] UIAlertFormWithErrorType:ERROR_NOT_BOUND Delegate:self Tag:ALERT_95190_NOBOUND];
        }

    }
    else
    {
        [self MyalertView:STR(@"Main_outOfTheTime", Localize_Main)        //您的智驾一键呼功能已到期,请前往购买该服务
               canceltext:STR(@"Universal_cancel", Localize_Universal)              //取消
                othertext:STR(@"Universal_ok", Localize_Universal)                  //确定
                 alerttag:ALERT_BUY_95190];
    }
    
    
}

-(void)delaySimNav:(id)sender
{
    [MWRouteDemo StartDemo];
}

-(void)delayNav:(id)sender
{
    [MWRouteGuide GuidanceOperateWithMainID:0 GuideHandle:guideRouteHandle];
    [self setSwitchTripDirectFrame];
    
}

- (void)ContinueNavi //续航
{
    long lon;
    long lat;
    GMAPCENTERINFO mapinfo = {0};
    GHMAPVIEW phMapView;
    GDBL_GetMapViewHandle(GMAP_VIEW_TYPE_MAIN, &phMapView);
    GDBL_GetMapViewCenterInfo(phMapView, &mapinfo);
    
    lon = mapinfo.CenterCoord.x;
    lat = mapinfo.CenterCoord.y;
    if ([[MWMapOperator sharedInstance] GMD_GetCurDrawMapViewTypeWithLon:lon Lat:lat] == 0)
    {
        return;
    }
    if ( [[MWMapOperator sharedInstance] mapOperate] != 22)
    {
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%s",route_path]])
        {
            double delayInSeconds = 0.1;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                           {
                               [self MyalertView:STR(@"Main_continueSailing",Localize_Main)  //续航
                                      canceltext:STR(@"Universal_cancel", Localize_Universal)          //取消
                                       othertext:STR(@"Universal_ok", Localize_Universal)              //确定
                                        alerttag:ALERT_LIFT ];
                           });
            
        }
    }
}

#pragma mark -
#pragma mark =====System=====
- (id)init {
	
    self = [super init];
    if (self)
	{
        self.title = STR(@"Main_backMap", Localize_Main);//返回地图

    }
    return self;
}

- (void)dealloc {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [palellerRoadArray release];
    CRELEASE(_mainBottomMenuObject);
    CRELEASE(_mainNaviTopObject);
    [_poiVoiceSearch release];
    [_arrayCityCodeToDownload release];
    if (poiDetail) {
        poiDetail.delegate = nil;
        [poiDetail release];
        poiDetail = nil;
    }
    if(_mapAddIcon)
    {
        [_mapAddIcon release];
        _mapAddIcon = nil;
    }
    if(poiShowObject)
    {
        [poiShowObject release];
        poiShowObject = nil;
    }
    [super dealloc];
    
}


- (void)viewDidLoad {
    
    [super viewDidLoad];
    _isFromLoginInView = NO;
    _mapType = GMAP_VIEW_TYPE_MAIN;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(listenNotification:) name:NOTIFY_SHOWMAP object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(listenNotification:) name:NOTIFY_UPDATE_VIEWINFO object:nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(EnterForegroundNotification:) name:UIApplicationWillEnterForegroundNotification object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(poilistenNotification:) name:NOTIFY_POISEARCH object: nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(PalellerRoadNotification:) name:NOTIFY_PARALLEL_NOTIFY object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleUIUpdate:) name:NOTIFY_HandleUIUpdate object:nil];
    
    _arrayCityCodeToDownload = [[NSMutableArray alloc]initWithCapacity:0];
    [[ANOperateMethod sharedInstance] GMD_BackUp];
    [[ANOperateMethod sharedInstance] GMD_CreatRelatedFolder];
    
    [AccountNotify SharedInstance];
    
    [MapViewManager ShowMapViewInController:self];
    
    _backUpView = NULL;
    
    [MWGPS StartUpWithDelegate:self];
    [self initControl];/*得放在解压zip文件之前执行*/
    
	provalue = 0.0f;
    
    //刷新导航条的背景色
    [(VCCustomNavigationBar*)self.navigationController.navigationBar refeshBackground];
    [MWDayNight SetDayNightModeCallback];

}

- (void)viewWillDisappear:(BOOL)animated
{
    [ANParamValue sharedInstance].isMainViewController = NO;
    _mapView.delegate = nil;
    [MWRouteCalculate setDelegate:nil];    //设置路径演算delegate
    if(_bOverView)
    {
        [self closeAllSeeWithAnimated:NO];
    }
    //隐藏没数据提醒
    [self hideNoDataTips];
    [super viewWillDisappear:animated];
}


-(void)viewDidAppear:(BOOL)animated
{
    
	[super viewDidAppear:animated];

    
    if (![[ANParamValue sharedInstance] isInit])
    {
        return;
    }
   	if ([[MWMapOperator sharedInstance] mapOperate] == 6) {
    }
	if ([[ANParamValue sharedInstance] isInit])
	{
	    [[MWMapOperator sharedInstance] MW_SetMapOperateType:0];
	}
    
    _mapView.delegate = self;
}


- (void)viewWillAppear:(BOOL)animated {
     _mapView  = [MapViewManager ShowMapViewInController:self];
	[super viewWillAppear:animated];
   
    if (isEngineInit)  //引擎初始化才能调用该接口
    {
        [[MWPreference sharedInstance] setValue:PREF_MAP_TMC_SHOW_OPTION Value:NO]; //主地图界面都显示城市TMC,根据路径判断是否显示事件
    }
    [GDAlertView shouldAutorotate:YES];
    
    [MWRouteCalculate setDelegate:self];    //设置路径演算delegate
    [ANParamValue sharedInstance].isMainViewController = YES;
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    
	if (![[ANParamValue sharedInstance] isInit])
    {
        [[MWMapOperator sharedInstance] MW_SetMapOperateType:0];
        return;
    }
    if(![ANParamValue sharedInstance].isPath )
    {
        [self parkingTimeEnd];
        [MWMapAddIconOperator ClearMapIcon];
        [ANParamValue sharedInstance].isRequestParking = 1;
    }

    [self ViewAppearDelayMethod];
        
    //刷新红点显示
    [self redRequestSuccess];
    //头像修改
    [_mainCruiseTopSearch reloadFaceImage];
    
    //有路径，非模拟导航，搜索停车场信息
    //目的地停车场发送消息
    [self requestParking];
}



- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if ( self.navigationController.visibleViewController != self)
    {
        return;
    }
    if (YES ==[[ANParamValue sharedInstance] isInit])
    {
        if(toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
        {
            [self changeLandscapeControlFrameWithImage];
        }
        else if(toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
        {
            [self changePortraitControlFrameWithImage];
        }
        [[MWMapOperator sharedInstance] MW_ShowMapView:_mapType WithParma1:0 WithParma2:0 WithParma3:0];
        [self viewInCondition:[[ANParamValue sharedInstance] GMD_GetViewConditon]];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if ( self.navigationController.topViewController != self)
    {
        return NO;
    }
    if (interfaceOrientation == UIDeviceOrientationUnknown)
    {
        return NO;
    }
    if (!OrientationSwitch)
    {
        return (Orientation == interfaceOrientation);
    }
    
	return  YES;
}
- (void)viewDidUnload
{
    // Release any retained subviews of the main view.不包含self.view
    [super viewDidUnload];
    
    //处理一些内存和资源问题。
}
- (void)didReceiveMemoryWarning
{
    if (isEngineInit)
    {
        int value = 0;
        GDBL_GetParam(G_BACKGROUND_MODE, &value);
        if (!value)     //后台模拟不删除引擎缓存
        {
            GSTATUS res = [MWEngineInit DestroyView]; //内存警告时，释放引擎缓存
            if (res ==  GD_ERR_OK)
            {
                [MWEngineInit CreateView];
            }
        }
       
    }
    [super didReceiveMemoryWarning];
    NSLog(@"mainViewReceiveMemoryWarning");
}
- (void)ViewAppearDelayMethod
{
    
    _mapView.delegate = self;
    /**改变地图视图的父视图，并判断是否由新功能查看界面中退出**/

    static BOOL firstAppear = YES;
    if (firstAppear)
    {
        if ([[Plugin_Account getAccountInfoWith:1] intValue] != 0) //进入导航是已登录的状态则＋1
        {
            [MobClick event:UM_EVENTID_PersonalCenter_COUNT label:UM_LABEL_LoginState];
        }
        firstAppear = NO;
        [[MWApp sharedInstance] executeLogicAfterWarningViewAndNewFunction:self];
        //是否开启实时交通——根据上一次的保存结果，默认开启或不开启实时交通
        if([[MWPreference sharedInstance] getValue:PREF_REALTIME_TRAFFIC])
        {
            
            [MWEngineSwitch OpenTMCWithTip:YES];
        }
        //设置显示无数据区域提醒
        [self setButtonTipsView:[CheckMapDataObject CheckMapData]];
        
        [self skinCheck];//皮肤检测，若不为默认皮肤，且皮肤状态不为完成，则改变为默认皮肤
    }
    
    
    if ([[ANParamValue sharedInstance] isPath] )
    {
        [[CustomRealTimeTraffic sharedInstance] updateCurrentTrafficInfo];
    }
    
    if([[ANParamValue sharedInstance] isNavi]){
        [_mapView  setRecognizeSwitchOn:EVENT_PINCH | EVENT_SWIP | EVENT_TAP_DOUBLE | EVENT_DOUBLE_FINGER_TAP];
    }else{
        [_mapView setRecognizeSwitchOn:EVENT_NONE];
    }
	
	timerCount = 0;
    
    if (YES==[[ANParamValue sharedInstance] isPath] && ([MWRouteGuide GetGuideFlags]& G_GUIDE_FLAGS_CROSSZOOM) == G_GUIDE_FLAGS_CROSSZOOM) //放大路口
    {
        _buttonZoomDis.hidden = YES;
        _buttonZommRoadName.hidden = YES;
        if(_viewStatueBar)
        {
            _viewStatueBar.hidden = YES;
        }
        GDBL_CloseZoomView();//隐藏放大路口
    }
    

    
    // #24269 这个bug修复 没有路径，就隐藏者两个东西
    if([[ANParamValue sharedInstance] isPath] == NO)
    {
        _buttonZoomDis.hidden = YES;
        _buttonZommRoadName.hidden = YES;
        if(_viewStatueBar)
        {
            _viewStatueBar.hidden = YES;
        }
    }
    
    if(![ANParamValue sharedInstance].isMove)
    {
        if(poiDetail)
        {
            [poiDetail setHidden:YES];
        }
    }
    if(poiDetail && ![poiDetail getHidden])
    {
        [poiDetail setFavorite];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_TOUCH object:[NSNumber numberWithBool:NO]];
    if ([[MWMapOperator sharedInstance] mapOperate] != 3)  //解决全程概览回来，全程概览会闪一下主地图问题
    {
        [[MWMapOperator sharedInstance] MW_ShowMapView:_mapType WithParma1:0 WithParma2:0 WithParma3:0];
    }
	switch ([[MWMapOperator sharedInstance] mapOperate])
	{
            
        case 1://模拟导航
		{
			[self Action_simulatorNavi_Start];
        }
			break;
		case 2://开始导航
		{
            [self delayNav:nil];
//            [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(delayNav:) userInfo:nil repeats:NO];
		}
			break;
			
		case 3://通过微享编码启动导航
		{
			[self Action_setDes];
		}
            break;
		case 4://轨迹回放
		{
            
			
		}
			break;
        case 5://查图下设终点（需要传入点类型，和名称，一般在搜索－查图－设终点才需要调用此接口）
		{
            
		}
			break;
		case 7://途经点
		{
			[self Action_setPassBy];
		}
			break;
            
        case 9://查图下设途经点（需要传入点类型，和名称，一般在搜索－查图－设终点才需要调用此接口）
		{
			
		}
			break;
		case 10://避让
		{
            [MWRouteGuide StopGuide:Gfalse];
            [MWRouteGuide ClearGuideRoute];
			[MWRouteCalculate StartRouteCalculation:GROU_CAL_SINGLE_ROUTE];
		}
			break;
        case 11://多途径点确认路线
		{
            
            [MWRouteCalculate StartRouteCalculation:GROU_CAL_SINGLE_ROUTE];
            
		}
			break;
            
		case ProcessType_SetDes://第三方软件传仅为度设置终点
		{
            GPOI tmp = [ANParamValue sharedInstance].thirdPartDesPOI;
            
			GPOI poi = {0};
            poi.Coord.x = tmp.Coord.x;
            poi.Coord.y = tmp.Coord.y;
            GcharMemcpy(poi.szName, tmp.szName,GMAX_POI_NAME_LEN+1);
            
            [MWRouteCalculate setDesWithPoi:poi poiType:GJOURNEY_GOAL calType:GROU_CAL_MULTI];
		}
			break;
			
		case ProcessType_SmsMoveMap://短信移图
		{
            _mapType = GMAP_VIEW_TYPE_MAIN;
            [[MWMapOperator sharedInstance]MW_ShowMapView:_mapType WithParma1:0 WithParma2:0 WithParma3:0];
            GCOORD tmp = [ANParamValue sharedInstance].smsCoord;
			GMOVEMAP moveMap;
            moveMap.eOP = MOVEMAP_OP_GEO_DIRECT;
            moveMap.deltaCoord.x= tmp.x;
            moveMap.deltaCoord.y = tmp.y;
            [[MWMapOperator sharedInstance] MW_MoveMapView:GMAP_VIEW_TYPE_MAIN TypeAndCoord:&moveMap];
            
            [poiDetail setHidden:YES];
            GMAPCENTERINFO mapCenter = {0};
            GHMAPVIEW phMapView;
            GDBL_GetMapViewHandle(GMAP_VIEW_TYPE_MAIN, &phMapView);
            GDBL_GetMapViewCenterInfo(phMapView, &mapCenter);
            
            if([[ANParamValue sharedInstance]isPath])
            {
                timerCount = 0;
                poiShowObject.poiType  = ViewPOIType_passBy;
            }
            else
            {
                poiShowObject.poiType  = ViewPOIType_Detail;
            }
            
            poiShowObject.popPoi = poiDetail;
            poiShowObject.coord = mapCenter.CenterCoord;
            [poiShowObject show];
            

            
		}
			break;
        case 22:////导航未开启，routing启动导航处理
		{
            
		}
			break;
            // 接收推送通知，进入消息盒子界面
        case ProcessType_MessageBox://消息盒子和客户反馈信息推送
        {
            [Plugin_Share enterBoxWith:self.navigationController];
            [[MWMapOperator sharedInstance] MW_SetMapOperateType:0];
            return;
        }
            break;
		default:
			break;
	}
	
	if ([[ANParamValue sharedInstance] isInit])
	{
		if ([[MWMapOperator sharedInstance] mapOperate] == 6 || [[MWMapOperator sharedInstance] mapOperate] == 22)
        {
            //不做处理
		}
        else
        {
            [[MWMapOperator sharedInstance] MW_SetMapOperateType:0];
        }
	}
	
	[self viewInCondition:55];//按钮字体显示
    [self viewInCondition:84];//比例尺按钮隐藏
    [self.view sendSubviewToBack:_mapView];
    [self viewInfoInCondition:0];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    if(!_mainCarModeView.hidden)
    {
        [_mainCarModeView hideModeSwitch];
    }
    [self setModeMapImage];
    [self reloadAllSeeButtonImage];
}

#pragma mark -
#pragma mark =====控件创建－初始化=====
//控件创建
-(void)initControl
{
    _isPianyi = NO;
    _isParking = NO;
    _isParkingCal = NO;
    _isEnterViewMapParking = NO;
    //放大路口－距离下一路口距离
    _buttonZoomDis = [[self buttonInCondition:BUTTON_ZOOMDIS] retain];
    [_buttonZoomDis setBackgroundColor:GETSKINCOLOR(ROUTE_BLACK_TOP_BAR_COLOR)];
    [_buttonZoomDis setTitleColor:GETSKINCOLOR(MAIN_ZOOMDIS_COLOR) forState:UIControlStateNormal];
    _buttonZoomDis.titleLabel.font = [UIFont boldSystemFontOfSize:24.0];
	[self.view addSubview:_buttonZoomDis];[_buttonZoomDis release];_buttonZoomDis.hidden = YES;
    UIImage *tempImage = IMAGE(@"zoomDisDiv.png", IMAGEPATH_TYPE_1);
    _imageViewZoomDiv = [[UIImageView alloc]initWithImage:[tempImage stretchableImageWithLeftCapWidth:tempImage.size.width / 2
                                                                                                  topCapHeight:tempImage.size.height / 2]];
    [_buttonZoomDis addSubview:_imageViewZoomDiv];
    [_imageViewZoomDiv release];
    
    //放大路口－下一路口道路名
    _buttonZommRoadName = [[self buttonInCondition:BUTTON_ZOOMROADNAME] retain];
    [_buttonZommRoadName setBackgroundColor:GETSKINCOLOR(ROUTE_BLACK_TOP_BAR_COLOR)];
    _buttonZommRoadName.titleLabel.font = [UIFont boldSystemFontOfSize:20.0];
	[self.view addSubview:_buttonZommRoadName];[_buttonZommRoadName release];_buttonZommRoadName.hidden = YES;
    UIImage *buttonZoomNormal = IMAGE(@"zoomRoadName.png", IMAGEPATH_TYPE_1) ;
    _buttonZommRoadName.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    UIImage *stretchableButton = [buttonZoomNormal stretchableImageWithLeftCapWidth:0 topCapHeight:0];
    [_buttonZommRoadName setBackgroundImage:stretchableButton forState:UIControlStateNormal];
    
    [self viewInCondition:53];//功能new

    [self viewInCondition:0];
	
	[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(fireTimer:) userInfo:nil repeats:YES];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(listenNotification:) name:NOTIFY_VIEWCONDITION object:nil];
	
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(listenNotification:) name:NOTIFY_INVALIDPOSITION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(listenNotification:) name:UIApplicationDidBecomeActiveNotification object:nil];
   
    //目的地停车场
    _arrayParking = nil;

    //点击车位获取poi点信息
    _buttonGetPOIInfo = [[self buttonInCondition:BUTTON_GET_POIINFO] retain];
    if (isPad) {
        [_buttonGetPOIInfo setFrame:CGRectMake(0.0, 0.0, 70.0, 70.0)];
    }
    else{
        [_buttonGetPOIInfo setFrame:CGRectMake(0.0, 0.0, 50.0, 50.0)];
    }
    [self.view addSubview:_buttonGetPOIInfo];[_buttonGetPOIInfo release];_buttonGetPOIInfo.hidden = YES;
    //poi详情弹出框
    poiDetail = [[GDPopPOI alloc] initWithType:ViewPOIType_Detail];
    poiDetail.delegate = self;
    poiDetail.topView = self.view;
    [poiDetail setHidden:YES];
    
    
    _poiVoiceSearch = [[POIVoiceSearch alloc] initWithViewController:self] ;
    
    _progressBar = [[ProgressBar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 5)];
    
    [self.view addSubview:_progressBar];

    [self addSimuBar];
    
    if([[MWPreference sharedInstance] getValue:PREF_DAYNIGHTMODE] == 1)
    {
        [self setDayAndNightTextColor:1];
    }
    else
    {
        [self setDayAndNightTextColor:0];
    }
    poiShowObject = [[POIShowObject alloc] init];
    poiShowObject.delegate = self;
    
    //判断开机提示是否关闭志林语音的提示框
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSNumber *number = [ud objectForKey:USERDEFAULT_LinZhiLingTips];
    if(number == nil)
    {
        number = [NSNumber numberWithBool:YES];
        [ud setObject:number forKey:USERDEFAULT_LinZhiLingTips];
    }
    if([number boolValue])
    {
        if([[MWPreference sharedInstance] getValue:PREF_SWITCHEDVOICE] == 1)    //只有在开启志玲欢迎语的情况下，才弹出框
        {
            _soundGuidView= [[SoundGuideView alloc]initHiddenRect:CGRectMake(0, 0, 0, 0)];
            [self.view addSubview:_soundGuidView];
            [_soundGuidView release];
            __block MainViewController *tempViewController = self;
            _soundGuidView.clickContinue = ^(id sender)
            {
                [tempViewController setHiddenSoundView];
            };
            _soundGuidView.clickClose = ^(id sender)
            {
                [tempViewController setHiddenSoundView];
            };
        }
    }
    else
    {
        _soundGuidView = nil;
    }
    
    if((float)NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1)
    {
        //出现放大路口，在 iOS 7上，添加状态栏的透明黑色底
        _viewStatueBar = [[UIView alloc]init];
        _viewStatueBar.hidden = YES;
        _viewStatueBar.backgroundColor = GETSKINCOLOR(ROUTE_BLACK_TOP_BAR_COLOR);
        [self.view addSubview:_viewStatueBar];
        [_viewStatueBar release];
    }
    else
    {
        _viewStatueBar = nil;
    }
    
    //无数据区域提醒框
    _buttonTipsNoData = [UIButton buttonWithType:UIButtonTypeCustom];
    _buttonTipsNoData.titleLabel.numberOfLines = 0;
    _buttonTipsNoData.titleLabel.textAlignment = NSTextAlignmentLeft;
    _buttonTipsNoData.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    UIImage *tipsNormalImage = IMAGE(@"Main_tipsButtonBac.png", IMAGEPATH_TYPE_2);
    UIImage *tipsHighlightedImage = IMAGE(@"Main_tipsButtonBacPress.png", IMAGEPATH_TYPE_2);
    [_buttonTipsNoData setBackgroundImage:[tipsNormalImage stretchableImageWithLeftCapWidth:tipsNormalImage.size.width /2
                                                                                topCapHeight:tipsNormalImage.size.height/2]
                                 forState:UIControlStateNormal];
    [_buttonTipsNoData setBackgroundImage:[tipsHighlightedImage stretchableImageWithLeftCapWidth:tipsHighlightedImage.size.width /2
                                                                                    topCapHeight:tipsHighlightedImage.size.height/2]
                                 forState:UIControlStateHighlighted];
    [_buttonTipsNoData addTarget:self  action:@selector(Action_ButtonTips:)
                forControlEvents:UIControlEventTouchUpInside];
    _buttonTipsNoData.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    _buttonTipsNoData.titleEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    [_buttonTipsNoData setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
    
    _colorLabelTipsNoData = [[ColorLable alloc]initWithFrame:CGRectZero ColorArray:@[RGBCOLOR(190.0f, 44.0f, 50.0f)]];
    _colorLabelTipsNoData.numberOfLines = 0;
    _colorLabelTipsNoData.textAlignment = NSTextAlignmentLeft;
    _colorLabelTipsNoData.lineBreakMode = NSLineBreakByCharWrapping;
    _colorLabelTipsNoData.textColor = [UIColor blackColor];
    _colorLabelTipsNoData.font = [UIFont systemFontOfSize:14.0f];
    _colorLabelTipsNoData.backgroundColor = [UIColor clearColor];
    [_buttonTipsNoData addSubview:_colorLabelTipsNoData];
    [self.view addSubview:_buttonTipsNoData];
    
    _labelTipsOnSea = [[UILabel alloc]init];
    _labelTipsOnSea.font = [UIFont boldSystemFontOfSize:16.0f];
    _labelTipsOnSea.text = STR(@"Main_MapNoData", Localize_Main);
    _labelTipsOnSea.textColor = [UIColor blackColor];
    _labelTipsOnSea.backgroundColor = [UIColor whiteColor];
    
    _labelTipsOnSea.clipsToBounds = YES;
    _labelTipsOnSea.layer.cornerRadius = 6.0f;
    
    _labelTipsOnSea.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_labelTipsOnSea];
    [self hideNoDataTips];
    
    
    //底栏菜单按钮
     __block MainViewController *blockViewController = self;
    
    _mainBottomMenuObject = [[MainBottomMenuObject alloc]init];
    [self.view addSubview:_mainBottomMenuObject.bottomMenuBar];
    _mainBottomMenuObject.bottomMenuClick = ^(id sender){
        [blockViewController button:nil clickedWithTag:((UIButton *)sender).tag];
    };
    
    //放大缩小按钮
    _mainLargeAndNarrowObject = [[MainLargeAndNarrowObject alloc] initWithMapType:GMAP_VIEW_TYPE_MAIN];
    [self.view addSubview:_mainLargeAndNarrowObject.buttonEnlarge];
    [self.view addSubview:_mainLargeAndNarrowObject.buttonNarrow];
    [self.view addSubview:_mainLargeAndNarrowObject.buttonMeter];
    _mainLargeAndNarrowObject.mainButtonClick = ^(id sender){
        [blockViewController button:nil clickedWithTag:-1];//只是为了把 timeCount 设置为0
    };
    
    //巡航状态下，顶部栏
    _mainCruiseTopSearch = [[MainCruiseTopObject alloc] init];
    [self.view addSubview:_mainCruiseTopSearch.imageTopSearch];
    _mainCruiseTopSearch.mainButtonClick = ^(id sender){
        [blockViewController button:nil clickedWithTag:((UIButton *)sender).tag];
    };
    
    //导航和模拟导航的顶部栏
    _mainNaviTopObject = [[MainNaviTopObject alloc]init];
    [self.view addSubview:_mainNaviTopObject.imageDirectAndDistance];
    [self.view addSubview:_mainNaviTopObject.imageViewNaviTopBG];
    _mainNaviTopObject.handleTap = ^(UITapGestureRecognizer *tap){
        [blockViewController handleTapFrom:tap];
    };
    _mainNaviTopObject.handleSwipe = ^(UISwipeGestureRecognizer *swip){
        [blockViewController handleSwipeFrom:swip];
    };
    
    //导航的底部栏
    _mainNaviBottomObject = [[MainNaviBottomObject alloc] init];
    [self.view addSubview:_mainNaviBottomObject.imageViewNaviBottomBG];
    [self.view addSubview:_mainNaviBottomObject.overSpeedBack];
    _mainNaviBottomObject.mainButtonClick =  ^(id sender){
        [blockViewController button:nil clickedWithTag:((UIButton *)sender).tag];
    };
    
    _mainSimBottomObject = [[MainSimBottomObject alloc]init];
    [self.view addSubview:_mainSimBottomObject.viewSimuBG];
    _mainSimBottomObject.mainButtonClick = ^(id sender){
        [blockViewController button:nil clickedWithTag:((UIButton *)sender).tag];
    };
    
    //一些7788的按钮
    _mainOtherObject = [[MainOtherObject alloc] initWithView:self.view];
    _mainOtherObject.buttonClick = ^(id sender){
        [blockViewController button:nil clickedWithTag:((UIButton *)sender).tag];
    };
    [_mainOtherObject setRealHidden:NO];
    [_mainOtherObject setCancelNearbyHidden:YES];
    
    //地图模式切换
    _mainCarModeView = [[MainCarModeView alloc] initWithFrame:CGRectMake(0, 0, 0, 0) withAnimateCenter:CGPointMake(0, 0) withSizeButton:CGSizeZero];
    _mainCarModeView.mainCarModeClick = ^(id sender){
        [blockViewController carModeViewClick:((UIButton *)sender).tag];
    };
    [self.view addSubview:_mainCarModeView];
    [_mainCarModeView release];
    _mainCarModeView.hidden = YES;
    
    _buttonModeChange = [self buttonInCondition:BUTTON_MODE_SWITCH];
    [self.view addSubview:_buttonModeChange];

}



- (void) setHiddenSoundView
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSNumber *number = [ud objectForKey:USERDEFAULT_LinZhiLingTips];
    if(number)
    {
        number = [NSNumber numberWithBool:NO];
        [ud setObject:number forKey:USERDEFAULT_LinZhiLingTips];
    }
   
    _soundGuidView.hidden = YES;
    [_soundGuidView removeFromSuperview];
    _soundGuidView = nil;
}

#pragma mark - ---  无数据提示框  ---
/*!
  @brief    晃动视图
  @param
  @author   by bazinga
  */
- (void)shakeAnimationForView:(UIView *) view
{
    
    // 获取到当前的View
    
    CALayer *viewLayer = view.layer;
    
    // 获取当前View的位置
    CGPoint position = viewLayer.position;
    // 移动的两个终点位置
    CGPoint x = CGPointMake(position.x + 3, position.y);
    CGPoint y = CGPointMake(position.x - 3, position.y);
    // 设置动画
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    // 设置运动形式
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
    // 设置开始位置
    [animation setFromValue:[NSValue valueWithCGPoint:x]];
    // 设置结束位置
    [animation setToValue:[NSValue valueWithCGPoint:y]];
    // 设置自动反转
    [animation setAutoreverses:YES];
    // 设置时间
    [animation setDuration:0.3];
    // 设置次数
    [animation setRepeatCount:6.0f];
    // 添加上动画
    [viewLayer addAnimation:animation forKey:nil];
}

/*!
  @brief    无数据的按钮显示隐藏
  @param    -1:海 0:无数据区域 1:有数据
  @author   by bazinga
  */

typedef enum DATA_TYPE{
    DATA_HAS = 1,
    DATA_NO_IN_CITY = 0,
    DATA_NO_IN_SEA = -1,
}TipsType;

/*!
  @brief    无数据的按钮显示隐藏
  @param    type —— 移图到的地方数据类型
  @author   by bazinga
  */
- (void) setButtonTipsView:(TipsType)type
{
    if(type == DATA_HAS)
    {
        //隐藏 _buttonTipsNoData
        _buttonTipsNoData.hidden = YES;
        _labelTipsOnSea.hidden = YES;
    }
    else if(type == DATA_NO_IN_CITY)
    {
        [_arrayCityCodeToDownload removeAllObjects];
        
        GMAPCENTERINFO mapCenter = {0};
        GHMAPVIEW phMapView;
        GDBL_GetMapViewHandle(GMAP_VIEW_TYPE_MAIN, &phMapView);
        GDBL_GetMapViewCenterInfo(phMapView, &mapCenter);
        GCOORD pcoord ={0};
        pcoord.x = mapCenter.CenterCoord.x;
        pcoord.y = mapCenter.CenterCoord.y;
        NSArray *admincodes = [MWAdminCode GetAdminCodeArray:pcoord];
        NSLog(@"返回了%d个城市",admincodes.count);
        NSString *cityString  = @"";
        int countCity = 0;
        for (int i = 0 ; i < admincodes.count; i++)
        {
            int admincode = [[admincodes objectAtIndex:i] intValue];
            //如果是台湾省的数据，则不显示提示框
            if( (int)(admincode / 10000) == 71 || admincode == 0)
            {
                if(admincodes.count == 1)
                {
                     //在海里，在台湾，隐藏_buttonTipsNoData，中间弹出框
                     _buttonTipsNoData.hidden = YES;
                     _labelTipsOnSea.hidden = NO;
                     [self.view bringSubviewToFront:_labelTipsOnSea];
                     [self reloadButtonTipsFrame];
                    return ;
                }
                continue ;
            }
            countCity ++;
            if(countCity  <  3)
            {
                MWAreaInfo *info = [MWAdminCode GetCurAdareaWith:admincode];
                if (info.bHasData)
                {
                    //如果，就减回去
                    countCity--;
                    //继续循环
                    continue;
                }
                //组装城市显示数据
                cityString = [cityString stringByAppendingString:[NSString stringWithFormat:@"%@%@",
                                                                  countCity == 1 ? @"":@"，",
                                                                  [info.szCityName isEqualToString:@""] ? info.szProvName:info.szCityName]];
            }
            
            //添加传递到下载界面的数组数据，只传递可以下载，过滤海和台湾
            [_arrayCityCodeToDownload addObject:[admincodes objectAtIndex:i]];

        }
        //判断个数是否大于2个
        NSString *tipsTitle = @"";
        if(countCity < 3)
        {
            tipsTitle = [NSString stringWithFormat:STR(@"Main_MapNoDataInCity",Localize_Main),cityString];
        }
        else
        {
            tipsTitle = [NSString stringWithFormat:STR(@"Main_MapNoDataMoreInCity",Localize_Main),cityString,countCity];
        }
        
        [_buttonTipsNoData setTitle:tipsTitle
                           forState:UIControlStateNormal];
        _colorLabelTipsNoData.text = tipsTitle;
        [_colorLabelTipsNoData setColorText:cityString,nil];
        //展现 _buttonTipsNoData，无数据，提示下载数据
        _buttonTipsNoData.hidden = NO;
        _labelTipsOnSea.hidden = YES;
        [self.view bringSubviewToFront:_buttonTipsNoData];
        [self reloadButtonTipsFrame];
        [self shakeAnimationForView:_buttonTipsNoData];
        

    }
    else
    {
        //在海里，隐藏_buttonTipsNoData，中间弹出框
        _buttonTipsNoData.hidden = YES;
        _labelTipsOnSea.hidden = NO;
        [self.view bringSubviewToFront:_labelTipsOnSea];
        [self reloadButtonTipsFrame];

    }
}

/*!
  @brief    隐藏提示框函数
  @param
  @author   by bazinga
  */
- (void) hideNoDataTips
{
    [_buttonTipsNoData.layer removeAllAnimations];
    _buttonTipsNoData.hidden = YES;
    _labelTipsOnSea.hidden = YES;
}

/*!
  @brief    无数据程序按钮点击响应函数
  @param
  @author   by bazinga
  */
- (void) Action_ButtonTips:(UIButton *)sender
{
    if(_arrayCityCodeToDownload.count != 0)
    {
        CityDownLoadModule *tempCityDown = [[CityDownLoadModule alloc]init];
        id<ModuleDelegate> module = tempCityDown;
        NSDictionary * param; NSMutableDictionary * dic = [NSMutableDictionary dictionary];
        [dic setObject:_arrayCityCodeToDownload forKey:@"city"];
        param = [[NSDictionary alloc] initWithObjectsAndKeys:self.navigationController,@"controller",@"assignDownData",@"parma",dic,@"cityAdmincode",nil];
        [module enter:param];
        [param release];
        [tempCityDown release];
    }
}

- (void)addSimuBar
{
    _simPlayOrPause = 0;
    
}


//button初始化
- (UIButton *)buttonInCondition:(NSInteger)condition {
	
	UIButton *button;
	NSString *titleT  = nil;
	NSString *normalImage = nil;
	NSString *heightedImage = nil;
    IMAGEPATHTYPE type = IMAGEPATH_TYPE_1;
	
	switch (condition)
	{
		case BUTTON_SET_VIEWMODE:
		{//地图模式切换
			titleT = nil;
            normalImage = @"mainDirect.png";
            heightedImage = @"mainDirect.png";
            type = IMAGEPATH_TYPE_2;
		}
			break;
        case BUTTON_GUIDEPOST://高速路牌
		{
			titleT = nil;
			normalImage = @"MainShowGuidePost.png";
			heightedImage = nil;
		}
			break;
        case BUTTON_ZOOMDIS:
		{//放大路口距离
			titleT = nil;
			normalImage = nil;
			heightedImage = nil;
		}
			break;
        case BUTTON_ZOOMROADNAME:
		{//放大路口道路名
			titleT = nil;
			normalImage = nil;
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
            type = IMAGEPATH_TYPE_2;
        }
            break;
        case BUTTON_BACK_CAR:
        {
            titleT = nil;
            normalImage = @"mainBackCar.png";
            heightedImage = @"mainBackCarPress.png";
            type = IMAGEPATH_TYPE_2;
        }
            break;
        case BUTTON_GET_POIINFO:
        {
            titleT = nil;
            normalImage = nil;
            heightedImage = nil;
        }
            break;
        case BUTTON_CANCEL_NEARBY:
        {
            normalImage = @"Route_cancelDetour.png";
            heightedImage = @"Route_cancelDetourPress.png";
            titleT = STR(@"Main_cancelNearby", Localize_Main);
            type = IMAGEPATH_TYPE_2;
        }
            break;
        case BUTTON_ALLSEE:
        {
            normalImage = @"main_AllSee.png";
            heightedImage = @"main_AllSeePress.png";
            titleT = STR(@"全览.", Localize_Main);
            type = IMAGEPATH_TYPE_2;
        }
            break;
		default:
        {
            NSLog(@"");
        }
            break;
            
	}
	
	button = [self createButtonWithTitle:titleT normalImage:normalImage heightedImage:heightedImage tag:condition withImageType:type];
	titleT = nil;
	normalImage = nil;
	heightedImage = nil;
	return button;
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
	
	UIImage *imageTop = IMAGE(imageTopName, IMAGEPATH_TYPE_1);
	ANbutton = [self createANButtonWithTitle:title image:image imagePressed:imagePressed imageTop:imageTop tag:condition textOffsetValue:textOffsetValue];
	
	title = nil;
	imageTopName = nil;
	image = nil;
	imagePressed = nil;
	imageTop = nil;
	
	return ANbutton;
}
//label初始化
- (UILabel *)labelInCondition:(NSInteger)condition {
	
	UILabel *label;
	
	NSString *text;
	CGFloat size;
	UITextAlignment textAlignment;
	
	switch (condition)
	{
		case 2:
		{
			text = @"0km";
			textAlignment = UITextAlignmentCenter;
			size = 17.0f;
		}
			break;
			
		case 3:
		{
			text = @"0km";
			textAlignment = UITextAlignmentCenter;
			size = 14.0f;
		}
			break;
			
		case 4:
		{
			text = @"";
			textAlignment = UITextAlignmentCenter;
			size = 14.0f;
		}
			break;
		case 5:
		{
            text = STR(@"Main_unNameRoad", Localize_Main);//未命名道路
            textAlignment = UITextAlignmentCenter;
			size = 20.0f;
		}
			break;
            
		default:
			break;
	}
	
	if (condition == 5)
    {
        label = [[[MoveTextLable alloc] initLabelWithText:text fontSize:size textAlignment:textAlignment] autorelease];
    }
	else
    {
        label = [self createLabelWithText:text fontSize:size textAlignment:textAlignment];
    }
	text = nil;
	return label;
}

#pragma mark - ---  停车场修改版  ---
/***
 * @name    设置停车场的数据
 * @param
 * @author  by bazinga
 ***/
- (void) setParkingData:(NSArray *) arrayParking
{
    
    if(_arrayParking)
    {
        [_arrayParking removeAllObjects];
        [_arrayParking release];
        _arrayParking = nil;
    }
    if(arrayParking == nil || arrayParking.count == 0 || ![ANParamValue sharedInstance].isPath)
    {
        return ;
    }
    
    _arrayParking = [[NSMutableArray alloc] init];
    for (int i = 0; i < 5 && i < arrayParking.count; i++) {
        [_arrayParking addObject:[arrayParking objectAtIndex:i]];
    }
    //显示停车场的 POI 点
    [self selectViewMapWithArray:_arrayParking withIndex:index];
}

-(void)selectViewMapWithArray:(NSArray *)array withIndex:(int)index
{
    if(array == nil)
    {
        
    }
    else
    {
        NSMutableArray *arr=[NSMutableArray arrayWithCapacity:0];
        for (int j=0 ;j<array.count;j++) {
            MWPoi *poi = array[j];
            MWMapPoi *addIcon=[[[MWMapPoi alloc] init] autorelease];
            [POICommon copyWMPoiValutToSubclass:poi withPoiSubclass:addIcon];
            [arr addObject:addIcon];
        }
        
        if(_mapAddIcon==nil)
        {
            _mapAddIcon = [[MWMapAddIconOperator alloc] initWith:[NSDictionary dictionaryWithObject:arr forKey:@"parkingPoi.png"] inView:_mapView delegate:self];
        }
        [_mapAddIcon SetIconPosition:Position_Bottom];
        [_mapAddIcon freshPoiDic:[NSDictionary dictionaryWithObject:arr forKey:@"parkingPoi.png"]];
        [poiDetail setPopPOIType:ViewPOIType_SelectPOI];
        
        MWPoi *showPOI = nil;
        if (index < array.count)
        {
            showPOI = [array objectAtIndex:index];
        }
        if(_mapType == GMAP_VIEW_TYPE_MAIN)
        {
            [poiDetail setStringAtPos:showPOI withMapType:GMAP_VIEW_TYPE_MAIN];
            [poiDetail setHidden: NO];
        }
        
        
        timerCount = 0;
    }
    if(self.navigationController.topViewController == self)
    {
        [[MWMapOperator sharedInstance]MW_ShowMapView:_mapType WithParma1:0 WithParma2:0 WithParma3:0];
    }
    
}

- (void) parkingTimeEnd
{

    if(_arrayParking)
    {
        [_arrayParking removeAllObjects];
        [_arrayParking release];
        _arrayParking = nil;
    }
}

#pragma mark -
#pragma mark =====界面显示控制=====
//控件显示－隐藏控制
- (void)viewInCondition:(NSInteger)condition {
	
	switch (condition)
	{
		case HMI_NOMOVE_NOPATH_NOHIDDEN_NONAVI://无移图无路径无隐藏无模拟导航
		{
			[self viewInCondition:HMI_NOMOVE];
			[self viewInCondition:HMI_NOHIDDEN];
			[self viewInCondition:HMI_NONAVI];
            parallelFlag = NO;
            [self viewInCondition:HMI_NOPATH];
			
		}
			break;
			
		case HMI_YEMOVE_NOPATH_NOHIDDEN_NONAVI://有移图无路径无隐藏无模拟导航
		{
			[self viewInCondition:HMI_YEMOVE];
            [self viewInCondition:HMI_NOPATH];
            
			[self viewInCondition:HMI_NONAVI];
			
		}
			break;
			
		case HMI_NOMOVE_YEPATH_NOHIDDEN_NONAVI://无移图有路径无隐藏无模拟导航
		{
			[self viewInCondition:HMI_NOMOVE];
            [self viewInCondition:HMI_YEPATH];
			[self viewInCondition:HMI_NOHIDDEN];
            
			[self viewInCondition:HMI_NONAVI];
		}
			break;
			
		case HMI_NOMOVE_NOPATH_YEHIDDEN_NONAVI://无移图无路径有隐藏无模拟导航
		{
			[self viewInCondition:HMI_NOMOVE];
			[self viewInCondition:HMI_NOPATH];
			[self viewInCondition:HMI_YEHIDDEN];
			[self viewInCondition:HMI_NONAVI];

			if (Interface_Flag==0)
			{
				[self changeViewFrameWithID:0];
			}
			else
			{
				[self changeViewFrameWithID:1];
            }
		}
			break;
			
		case HMI_YEMOVE_YEPATH_NOHIDDEN_NONAVI://有移图有路径无隐藏无模拟导航
		{
			[self viewInCondition:HMI_YEMOVE];
            [self viewInCondition:HMI_YEMOVE_YEPATH];
            
			[self viewInCondition:HMI_NONAVI];
		}
			break;
		case HMI_YEMOVE_NOPATH_YEHIDDEN_NONAVI://有移图无路径有隐藏无模拟导航
		{
			[self viewInCondition:HMI_YEMOVE];
			[self viewInCondition:HMI_NOPATH];
			[self viewInCondition:HMI_YEHIDDEN];
			[self viewInCondition:HMI_NONAVI];
		}
			break;
            
		case HMI_NOMOVE_YEPATH_YEHIDDEN_NONAVI://无移图有路径有隐藏无模拟导航
		{
			[self viewInCondition:HMI_NOMOVE];
            [self viewInCondition:HMI_YEPATH];
			[self viewInCondition:HMI_YEHIDDEN];
			[self viewInCondition:HMI_NONAVI];
		}
			break;
		case HMI_NOMOVE_YEPATH_NOHIDDEN_YENAVI://无移图有路径无隐藏有模拟导航
		{
			[self viewInCondition:HMI_NOMOVE];
			[self viewInCondition:HMI_YEPATH];
			[self viewInCondition:HMI_NOHIDDEN];
			[self viewInCondition:HMI_YENAVI];
		}
			break;
            
		case HMI_YEMOVE_YEPATH_YEHIDDEN_NONAVI://有移图有路径有隐藏无模拟导航
		{
			[self viewInCondition:HMI_YEMOVE];
			[self viewInCondition:HMI_YEMOVE_YEPATH];
			[self viewInCondition:HMI_YEHIDDEN];
			[self viewInCondition:HMI_NONAVI];
		}
			break;
            
		case HMI_NOMOVE_YEPATH_YEHIDDEN_YENAVI://无移图有路径有隐藏有模拟导航
		{
			[self viewInCondition:HMI_NOMOVE];
			[self viewInCondition:HMI_YEPATH];
			[self viewInCondition:HMI_YENAVI];
            [self viewInCondition:HMI_YEHIDDEN];
		}
			break;
		case HMI_YEMOVE_YEPATH_YEHIDDEN_YENAVI://有移图有路径有隐藏有模拟导航
		{
			[self viewInCondition:HMI_YEMOVE];
			[self viewInCondition:HMI_YEPATH];
			[self viewInCondition:HMI_YEMOVE_YEPATH];
			
		}
			break;
			
        case HMI_YEMOVE://(有移图)
		{
            
            //            buttonVerCollect.hidden = NO;
			if (Interface_Flag == 0) {
                [self changeViewFrameWithID:0];
			}
			else {
                [self changeViewFrameWithID:1];
			}
			
		}
			break;
			
		case HMI_VIEWPOI://(POI查图)
		{
			
			
		}
			break;
            
        case HMI_SET_BUTTON_TITLE://主界面按钮字体显示
		{
            [_mainBottomMenuObject reloadBottomText];
            [_mainCarModeView reloadText];
            [_mainCruiseTopSearch reloadText];
            [_mainOtherObject reloadText];
            [_mainNaviTopObject setQianfangText:STR(@"Mian_forward", Localize_Main)];
            [_mainNaviTopObject setEnterText:STR(@"Main_Enter", Localize_Main)];
            _labelTipsOnSea.text = STR(@"Main_MapNoData", Localize_Main);
		}
			break;
            
		case HMI_YEPATH://(有路径)
		{
            [_mainNaviTopObject setViewHidden:NO];
            
            [_mainNaviBottomObject setViewHidden:NO];
            [self  nextRoadLableHidden:NO];

            [_mainCruiseTopSearch setTopHidden:YES];
            [_mainOtherObject setSwitchTripDirectHidden:YES];
            _progressBar.hidden = NO;
            [self setOverSpeedCofing];
		}
			break;
		case HMI_NOPATH://(没有路径)
		{
            [_mainNaviTopObject setViewHidden:YES];
            [_mainOtherObject setSwitchTripDirectHidden:NO];
            [_mainOtherObject setParallelRoadHidden:YES];
            [_mainNaviBottomObject setViewHidden:YES];
              _progressBar.hidden = YES;
            [_mainCruiseTopSearch setTopHidden:NO];
            [self  nextRoadLableHidden:YES];
            [self setOverSpeedCofing];
		}
			break;
		case HMI_YEMOVE_YEPATH://(有路径移图)
		{
            [_mainOtherObject setSwitchTripDirectHidden:YES];
            [_mainNaviTopObject setViewHidden:NO];
            
			if (Interface_Flag == 0) {
				
				[self changeViewFrameWithID:0];
			}
			else {
				
				[self changeViewFrameWithID:1];
			}
		}
			break;
			
		case HMI_NOHIDDEN://显示按钮
		{
			_buttonZoomDis.hidden = YES;
            _buttonZommRoadName.hidden = YES;
            if(_viewStatueBar)
            {
                _viewStatueBar.hidden = YES;
            }
			if (Interface_Flag == 0) {
				
				[self changeViewFrameWithID:0];
			}
			else {
                
				[self changeViewFrameWithID:1];
			}
            
		}
			break;
			
		case HMI_YEHIDDEN://隐藏按钮
		{
            if(![ANParamValue sharedInstance].isMove)
            {
                if (Interface_Flag==0)
                {
                    [self changeViewFrameWithID:0];
                }
                else
                {
                    [self changeViewFrameWithID:1];
                }
                
                
                
                if (YES==[[ANParamValue sharedInstance] isPath]&&
                    [[CustomRealTimeTraffic sharedInstance] getHaveTrafficInfo]&&
                    ![[ANParamValue sharedInstance] isNavi])
                {
                    //                    m_btnHaveTraffic.hidden = NO;
                }
            }
		}
			break;
			
		case HMI_NONAVI://(不在模拟导航)
		{
            if([[ANParamValue sharedInstance] isPath])
            {
                [_mainNaviBottomObject setViewHidden:NO];
                [_mainOtherObject setAllSeeHidden:NO];
                _progressBar.hidden = NO;
            }
            [_mainSimBottomObject setViewHidden:YES];
                
            if([ANParamValue sharedInstance].isPath)
            {
                if (
                    ([MWRouteGuide GetGuideFlags]&G_GUIDE_FLAGS_CROSSZOOM) == G_GUIDE_FLAGS_CROSSZOOM
                    ||([MWRouteGuide GetGuideFlags] == G_GUIDE_FLAGS_GUIDEPOST && [_mainOtherObject GetGuidePostHidden]))
                {
                    [_mainOtherObject setRealHidden:YES];
                }
                else
                {
                    [_mainOtherObject setRealHidden:NO];
                }
            }
            else
            {
                [_mainOtherObject setRealHidden:NO];
            }
		}
			break;
        case HMI_YENAVI://(模拟导航)
		{
            [_mainSimBottomObject setViewHidden:NO];
            [_mainOtherObject setAllSeeHidden:YES];
            [_mainNaviBottomObject setViewHidden:YES];
            _progressBar.hidden = NO;
            [_mainOtherObject  setRealHidden:YES];
		}
			break;
        case HMI_HIDDEN_SCALEVIEW://隐藏比例尺选择按钮
        {
            GpsClickFlag = NO;
        }
            break;
        case HMI_ZOOMVIEW://导航－出现放大路口
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_TOUCH object:[NSNumber numberWithBool:YES]];
            
            if (isiPhone) {
                [self.view bringSubviewToFront:_mapView];
                [self.view bringSubviewToFront:_buttonZommRoadName];
                [self.view bringSubviewToFront:_buttonZoomDis];
                
                
                _buttonZoomDis.hidden = NO;
                _buttonZommRoadName.hidden = NO;
                if(_viewStatueBar)
                {
                    _viewStatueBar.hidden = NO;
                    [self.view bringSubviewToFront:_viewStatueBar];
                }
            }
            else
            {
                _buttonZoomDis.hidden = YES;
                _buttonZommRoadName.hidden = YES;
                [_mainOtherObject setRealHidden:YES];
                if(_viewStatueBar)
                {
                    _viewStatueBar.hidden = YES;
                }
                _buttonModeChange.hidden = _mainCarModeView.hidden;
                if (_bOverView == YES)  //如果是在全览状态，无条件隐藏按钮
                {
                    _buttonModeChange.hidden = YES;
                }
            }
            
            GZOOMVIEWINFO zoominfo = {0};
            [MWRouteGuide GetCurrentZoomViewInfo:&zoominfo];
            GZOOMVIEWTYPE eViewType = zoominfo.eViewType;
            [_buttonZoomDis setTitle:[MWRouteGuide GetManeuverInfoWithMainID:12] forState:UIControlStateNormal];
            [_buttonZommRoadName setTitle:[MWRouteGuide GetManeuverInfoWithMainID:10] forState:UIControlStateNormal];
            
            CGFloat zoomHeight = 35.0f;
            if (Interface_Flag == 0) {
                [_buttonZoomDis setFrame:CGRectMake(0.0f, 0.0f+ DIFFENT_STATUS_HEIGHT, 88.0f, zoomHeight )];
                [_buttonZommRoadName setFrame:CGRectMake(88.0f, 0.0f+ DIFFENT_STATUS_HEIGHT, MAIN_POR_WIDTH-88.0, zoomHeight)];
                
            }
            else if(Interface_Flag == 1){
                if (eViewType == G_ZOOM_VIEW_TYPE_REAL)
                {// 实景图
                    [_buttonZoomDis setFrame:CGRectMake(0.0f,
                                                        0.0f+ DIFFENT_STATUS_HEIGHT,
                                                        88.0f,
                                                        zoomHeight)];
                    [_buttonZommRoadName setFrame:CGRectMake(88.0f,
                                                             0.0f+ DIFFENT_STATUS_HEIGHT,
                                                             MAIN_LAND_WIDTH-88.0,
                                                             zoomHeight)];
                    if(isiPhone)
                    {
                        parallelFlag = NO;
                    }
                }
                else
                {
                    [_buttonZoomDis setFrame:CGRectMake(MAIN_LAND_WIDTH/2.0,
                                                        0.0f+ DIFFENT_STATUS_HEIGHT,
                                                        88.0f,
                                                        zoomHeight)];
                    [_buttonZommRoadName setFrame:CGRectMake(MAIN_LAND_WIDTH/2.0+88.0,
                                                             0.0f+ DIFFENT_STATUS_HEIGHT,
                                                             MAIN_LAND_WIDTH/2.0-88.0,
                                                             zoomHeight)];
                    
                }
            }
            
            [_imageViewZoomDiv setFrame:CGRectMake(_buttonZoomDis.frame.size.width - _imageViewZoomDiv.image.size.width,
                                                  0,
                                                  _imageViewZoomDiv.image.size.width,
                                                   _buttonZoomDis.frame.size.height )];
        }
            break;
        case HMI_GUIDEPOST://导航－出现高速路牌
        {
            
            [self.view sendSubviewToBack:_mapView];
            
            if ([[MWPreference sharedInstance] getValue:PREF_MAP_SHOW_GUIDEPOST] == NO)
            {
                [_mainOtherObject setGuidePostHidden:NO];
            }
            else
            {
                  [_mainOtherObject setGuidePostHidden:YES];
            }
            _buttonZoomDis.hidden = YES;
            _buttonZommRoadName.hidden = YES;
            if(_viewStatueBar)
            {
                _viewStatueBar.hidden = YES;
            }
            if (Interface_Flag==0)
            {
                [self changeViewFrameWithID:0];
            }
            else
            {
                [self changeViewFrameWithID:1];
            }
        }
            break;
        case HMI_NAVI_NORMALVIEW://导航恢复按钮状态
        {
            NSLog(@"导航恢复按钮状态");
            [self.view sendSubviewToBack:_mapView];
            
            [_mainOtherObject setGuidePostHidden:YES];
            _buttonZoomDis.hidden      = YES;
            _buttonZommRoadName.hidden = YES;
            if(_viewStatueBar)
            {
                _viewStatueBar.hidden = YES;
            }
            
            if (Interface_Flag==0)
            {
                [self changeViewFrameWithID:0];
            }
            else
            {
                [self changeViewFrameWithID:1];
            }

        }
            break;
		default:
			break;
	}
}
//控件信息显示控制
- (void)viewInfoInCondition:(NSInteger)condition {

	switch (condition)
	{
		case 0:
		{
            
            if (YES==[[ANParamValue sharedInstance] isPath] && [[ANParamValue sharedInstance] isMove] == NO) //导航出现放大路口和高速路牌处理
            {
                
                if (([MWRouteGuide GetGuideFlags]&G_GUIDE_FLAGS_CROSSZOOM) == G_GUIDE_FLAGS_CROSSZOOM && ![_mainLargeAndNarrowObject isTimerRunning]) {
                    [self viewInCondition:85];//出现放大路口
                    gestureFlag = NO;
                }
                else if([MWRouteGuide GetGuideFlags] == G_GUIDE_FLAGS_GUIDEPOST ) {
                    [self viewInCondition:86];//出现高速路牌
                    gestureFlag = NO;
                }
                
                else if(gestureFlag == NO){
                    gestureFlag = YES;
                    [self viewInCondition:87];//恢复状态
                }
            }
            
            
            [self SetManeuverInfo];
           
			//获取当前比例尺
			[_mainLargeAndNarrowObject setMeterString:[[MWMapOperator sharedInstance] GetCurrentScale]];

            [self setSwitchTripDirect];
            //poi详情
            if ([ANParamValue sharedInstance].isMove || [ANParamValue sharedInstance].isPath)
            {
                _buttonGetPOIInfo.hidden = YES;
            }
            else
            {
                _buttonGetPOIInfo.hidden = NO;
            }
            
		}
			break;
			
		default:
			break;
	}
    
    if([[ANParamValue sharedInstance] isPath])
    {
        [_mainBottomMenuObject setBottomMenuBarHidden:YES];
    }
    else
    {
         [_mainBottomMenuObject setBottomMenuBarHidden:NO];
    }
    if(_isParking)
    {
        [_mainOtherObject setCancelNearbyHidden:YES];
    }
    else
    {
        [_mainOtherObject setCancelNearbyHidden:![MWMapAddIconOperator ExistIconInMap:_mapAddIcon]];
    }
    [_mainOtherObject reloadText];
    [self setModeMapImage];
    
}

- (void)SetManeuverInfo
{
    
    if ([ANParamValue sharedInstance].isPath)
    {
            
        NSString *currentRoadName;
        NSString *nextRoadName;
        NSString *nextDistandfe;
        NSString *totalDistandeAndTime = @"";
        NSString *totalDistance = @"";
        NSString *totalTime = @"";
        UIImage *directImage;
        
        [self GetManeuverInfoCurrentRoadName:&currentRoadName NextRoadName:&nextRoadName NextDistance:&nextDistandfe DirectImage:&directImage TotalDistanceAndTime:&totalDistandeAndTime TotalDistance:&totalDistance TotalTime:&totalTime];
        
        //下一路口道路名
        [_mainNaviTopObject setNextRoadText:[NSString stringWithFormat:@"%@",nextRoadName]];
        [_mainNaviTopObject setQianfangText:[NSString stringWithFormat:@"%@",currentRoadName]];
        [_mainNaviTopObject reloadFrame];
        //路口转向图标
        if (directImage) {
            [_mainNaviTopObject setImageDirect:directImage];
        }
        
        //获取离下个路口的距离
        [_mainNaviTopObject setLeftText:nextDistandfe];
        
        //总距离／总耗时
        if (![ANParamValue sharedInstance].isNavi) {

            GGPSINFO pGpsInfo = {0};
            GDBL_GetGPSInfo(&pGpsInfo);
            NSString *speed = @"";
            speed = [NSString stringWithFormat:@"%dkm/h\n%@",pGpsInfo.nSpeed  ,STR(@"Main_CarSpeed", Localize_Main)];
            NSString *tempDistance = [NSString stringWithFormat:@"%@\n%@",totalDistance,STR(@"Main_CarDistance", Localize_Main)];
            NSString *tempTime = [NSString stringWithFormat:@"%@\n%@",totalTime,STR(@"Main_CarTime", Localize_Main)];
            [_mainNaviBottomObject setRoadInfoText:speed
                                         distances:tempDistance
                                              time:tempTime];
        }
        [self reloadRealTraffic];
    }
    
}

- (void)GetManeuverInfoCurrentRoadName:(NSString **)curRoadName
                              NextRoadName:(NSString **)nextRoadName
                              NextDistance:(NSString **)nextDistance
                               DirectImage:(UIImage  **)directImage
                      TotalDistanceAndTime:(NSString **)distanceAndTime
                         TotalDistance:(NSString **)totalDistance
                             TotalTime:(NSString **)totalTime
{
    NSString  *_curRoadName = @"";
    NSString  *_nextRoadName = @"";
    NSString  *_nextDistance = @"";
    
    *curRoadName = @"";
    *nextRoadName = @"";
    *nextDistance = @"";
    *directImage = nil;
    *distanceAndTime = @"";
    
    if (![ANParamValue sharedInstance].isPath)
    {
        
        return;
    }
    GMANEUVERINFO *ManeuverInfo = NULL;
    GSTATUS res = [MWRouteGuide GetManeuverInfo:&ManeuverInfo];
    //if (GD_ERR_OK == res && pManeuverInfo != NULL)
    {
//        //获取当前道路名
//        if ([ANParamValue sharedInstance].isMove) {
//            *curRoadName = [_curRoadName stringByAppendingString:[[MWMapOperator sharedInstance] GetCurrentRoadName:GMAP_VIEW_TYPE_MAIN]] ? [_curRoadName stringByAppendingString:[[MWMapOperator sharedInstance] GetCurrentRoadName:GMAP_VIEW_TYPE_MAIN]] : @"";
//            
//        }
//        else{
        if (GD_ERR_OK == res)
        {
            *curRoadName = [_curRoadName stringByAppendingString:[NSString chinaFontStringWithCString:ManeuverInfo->szCurRoadName]] ? [_curRoadName stringByAppendingString:[NSString chinaFontStringWithCString:ManeuverInfo->szCurRoadName]] : @"";
        }
        
//        }
        
        
        if (GD_ERR_OK == res)
        {
            *nextRoadName = [_nextRoadName stringByAppendingString:[NSString chinaFontStringWithCString:ManeuverInfo->szNextRoadName]] ? [_nextRoadName stringByAppendingString:[NSString chinaFontStringWithCString:ManeuverInfo->szNextRoadName]] : @"";
            
            if (ManeuverInfo->nNextDis > 1000)
            {
                *nextDistance = [_nextDistance stringByAppendingString:[NSString stringWithFormat:@"%0.1f%@",(ManeuverInfo->nNextDis/1000.0),STR(@"Universal_KM", Localize_Universal)]] ? [_nextDistance stringByAppendingString:[NSString stringWithFormat:@"%0.1f%@",(ManeuverInfo->nNextDis/1000.0),STR(@"Universal_KM", Localize_Universal)]] : @"";
            }
            else
            {
                *nextDistance = [_nextDistance stringByAppendingString:[NSString stringWithFormat:@"%d%@",ManeuverInfo->nNextDis,STR(@"Universal_M", Localize_Universal)]] ? [_nextDistance stringByAppendingString:[NSString stringWithFormat:@"%d%@",ManeuverInfo->nNextDis,STR(@"Universal_M", Localize_Universal)]] : @"";
            }
            
            int dis = ManeuverInfo->nTotalRemainDis;
            if (dis > 1000)
            {
                if (dis > 1000000) {
                    *totalDistance  = [NSString stringWithFormat:@"%0.0f%@",(dis/1000.0),STR(@"Universal_KM", Localize_Universal)];
                }
                else {
                    *totalDistance  = [NSString stringWithFormat:@"%0.1f%@",(dis/1000.0),STR(@"Universal_KM", Localize_Universal)];
                }
                
            }
            else
            {
                *totalDistance  = [NSString stringWithFormat:@"%d%@",ManeuverInfo->nTotalRemainDis,STR(@"Universal_M", Localize_Universal)];
            }
            
            int time = ManeuverInfo->nTotalArrivalTime;
            NSUInteger hour = (time/60);
            NSUInteger minute = (time%60);
            if (hour >0)
            {
                if (0 == minute || hour >= 10) {//如果分钟为0或者小时大于等于100，则不显示分钟
                    *totalTime = [NSString stringWithFormat:@"%d%@",hour,STR(@"Universal_hour", Localize_Universal)];
                }
                else{
                    *totalTime = [NSString stringWithFormat:@"%d%@%d%@",hour,STR(@"Universal_hour", Localize_Universal),minute,STR(@"Universal_min", Localize_Universal)];
                }
            }
            else
            {
                *totalTime = [NSString stringWithFormat:@"%d%@",minute,STR(@"Universal_min", Localize_Universal)];
            }
            *distanceAndTime = [NSString stringWithFormat:@"%@%@  %@%@",STR(@"Main_roadLeft", Localize_Main),*totalDistance ,
                                STR(@"Main_roadPredict", Localize_Main),*totalTime];
            
            
            
            static int turnID = 0;
            
            if (turnID != ManeuverInfo->nTurnID) {//add for hlf for 判断id不一样才去获取，降低cpu消耗
                *directImage = [MWRouteGuide GetTurnIconWithID:ManeuverInfo->nTurnID flag:1];
            }
            else{
                *directImage = nil;
            }
            turnID = ManeuverInfo->nTurnID;
        }
    }
    
}

- (void) setModeMapImage
{
    if(!isiPhone)
    {
        if (([MWRouteGuide GetGuideFlags]& G_GUIDE_FLAGS_CROSSZOOM) == G_GUIDE_FLAGS_CROSSZOOM)
        {
            [_mainOtherObject setGuidePostIsTop:NO];
        }
        else
        {
            [_mainOtherObject setGuidePostIsTop:YES];
            if(!_mainCarModeView.hidden)
            {
                [self.view bringSubviewToFront:_mainCarModeView];
                [self.view bringSubviewToFront:_buttonModeChange];
            }
        }
    }
    if (YES==[[ANParamValue sharedInstance] isPath]
        &&(([MWRouteGuide GetGuideFlags]& G_GUIDE_FLAGS_CROSSZOOM) == G_GUIDE_FLAGS_CROSSZOOM
           || ([MWRouteGuide GetGuideFlags] == G_GUIDE_FLAGS_GUIDEPOST && [_mainOtherObject GetGuidePostHidden]))
        ) //放大路口
    {
        _buttonModeChange.hidden = _mainCarModeView.hidden;
        if (_bOverView == YES)  //如果是在全览状态，无条件隐藏按钮
        {
            _buttonModeChange.hidden = YES;
        }
        [_mainOtherObject setRealHidden:YES];

    }
    else
    {
        _buttonModeChange.hidden = NO;
        if (_bOverView == YES)  //如果是在全览状态，无条件隐藏按钮
        {
            _buttonModeChange.hidden = YES;
        }
        if(![[ANParamValue sharedInstance] isNavi])
        {
            [_mainOtherObject setRealHidden:NO];
        }
        if(_mapType == GMAP_VIEW_TYPE_MAIN)
        {
            _buttonModeChange.enabled = YES;
        }
    }
    if(_mainCarModeView.hidden)
    {
        //设置右上角地图视角的图片
        GMAPVIEWINFO mapObjectInfo = {0};
        [[MWMapOperator sharedInstance] MW_GetMapViewInfo:GMAP_VIEW_TYPE_MAIN MapViewInfo:&mapObjectInfo];
        
        NSString *imagestring = [NSString stringWithFormat:@"main_AngelBtn%d.png",mapObjectInfo.eMapMode];
        NSString *imagePressString = [NSString stringWithFormat:@"main_AngelBtnPress%d.png",mapObjectInfo.eMapMode];
        [_buttonModeChange setBackgroundImage:IMAGE(imagestring, IMAGEPATH_TYPE_2) forState:UIControlStateNormal];
        [_buttonModeChange setBackgroundImage:IMAGE(imagePressString, IMAGEPATH_TYPE_2) forState:UIControlStateHighlighted];
        [self switchModeButtonCenter];
    }
    
}


//设置一些地图方向图片朝向
- (void) setSwitchTripDirect
{
    CGFloat angle = (M_PI / 180.0) *[[MWMapOperator sharedInstance] GetCarDirection:GMAP_VIEW_TYPE_MAIN];
    CGAffineTransform at =CGAffineTransformMakeRotation(angle);
    [_mainOtherObject setSwitchTransform:at];
}


//控件横竖屏，显示，隐藏控制
- (void)changeViewFrameWithID:(NSInteger)ID {
	
	if (0==ID) //竖屏
	{
        //		if (NO == [buttonCommonUse isHidden] || NO == [buttonBackCar isHidden]) //非屏保
        if([_mainBottomMenuObject.bottomMenuBar isHidden] == NO)
		{
			
            [self setNaviFrame];
            [self setSimuFrame];
            [_mainOtherObject setParallelRoadHidden:YES];
		}
        else if(YES == [_mainBottomMenuObject.bottomMenuBar isHidden])
		{
            [_mainOtherObject setParallelRoadHidden:!parallelFlag];
			[self setNaviFrame];
            [self setSimuFrame];
			
		}
	}
	else //横屏
	{
        //		if (NO == [buttonCommonUse isHidden] || NO == [buttonBackCar isHidden]) //非屏保
        if(NO == [_mainBottomMenuObject.bottomMenuBar isHidden])
		{
			[self setNaviFrame];
            [self setSimuFrame];
			
		}
        //		else if(YES == [buttonCommonUse isHidden] && YES == [buttonBackCar isHidden])//屏保
        else if (YES == [_mainBottomMenuObject.bottomMenuBar isHidden])
		{
			if (![[ANParamValue sharedInstance] isSafe]) {//非屏保，按钮正常显示

                [_mainOtherObject setParallelRoadHidden:YES];
				
			}
			else //屏保，隐藏按钮
            {
                [_mainOtherObject setParallelRoadHidden:!parallelFlag];
			}
            [self setNaviFrame];
            [self setSimuFrame];
            
            
			
		}
	}
    
    
}





- (void) setBottomButtonFrame
{
    [_mainBottomMenuObject setRealBottomButtonFrame];
    if(_soundGuidView)
    {
        //设置菜单栏的坐标
        NSMutableArray *bottomMenuArray = [_mainBottomMenuObject.bottomMenuBar getButtonArray];
        BottomButton * tempbutton = (BottomButton *)[bottomMenuArray lastObject];
        CGRect guidRect = CGRectMake( _mainBottomMenuObject.bottomMenuBar.frame.origin.x + tempbutton.frame.origin.x,
                                     _mainBottomMenuObject.bottomMenuBar.frame.origin.y ,
                                     tempbutton.frame.size.width ,
                                     tempbutton.frame.size.height);
        if(Interface_Flag == 0)
        {
            [_soundGuidView setFrame:CGRectMake(0, 0, MAIN_POR_WIDTH, MAIN_POR_HEIGHT)];
        }
        else
        {
            [_soundGuidView setFrame:CGRectMake(0, 0, MAIN_LAND_WIDTH, MAIN_LAND_HEIGHT)];
        }
        [_soundGuidView setHiddenFrame:guidRect];
        [self.view bringSubviewToFront:_soundGuidView];
    }
}




- (GOVERVIEWPARAMS)getOverViewParams
{
    float scale = [[UIScreen mainScreen] scale];  //modify by gzm for 传入的为屏幕分辨率，并非屏幕的大小 at 2014-7-28
    GOVERVIEWPARAMS params = {0};
    params.euType = GTRANSFORM_VIEW_ROUTE;
    GRECT front = {0};
    front.left = 2 * BUTTON_BOUNDARY * scale;
    front.top = (CONFIG_NAVI_TOP_DIRE_HEIGHT + 20 )* scale;
    front.bottom = (_mapView.bounds.size.height - CONFIG_NAVI_BOTTOM_HEIGHT - 20) * scale ;
    front.right = (_mapView.bounds.size.width  - 2 * BUTTON_BOUNDARY)* scale;
    params.stFrontRect = front;
    front.left = 0;
    front.top = 0;
    front.right = _mapView.bounds.size.width * scale  ;
    front.bottom = _mapView.bounds.size.height * scale;
    params.stBackRect = front;
    params.bWhole = Gtrue;
    GMAPVIEWINFO mapObjectInfo = {0};
    [[MWMapOperator sharedInstance] MW_GetMapViewInfo:GMAP_VIEW_TYPE_MAIN MapViewInfo:&mapObjectInfo];
    params.euMode =  GMAPVIEW_MODE_NORTH;//( mapObjectInfo.eMapMode == GMAPVIEW_MODE_3D ? GMAPVIEW_MODE_CAR : mapObjectInfo.eMapMode);
    
    return params;
}

//全览点击
- (void) Action_AllSeePress
{
    if(_bOverView == NO)
    {
        [self openAllSee];
    }
    else
    {
        [self closeAllSeeWithAnimated:YES];
    }

}

/*!
  @brief    打开全览
  @param
  @author   by bazinga
  */
- (void)openAllSee
{
    GHMAPVIEW phMapView;
    GDBL_GetMapViewHandle(GMAP_VIEW_TYPE_MAIN, &phMapView);
    GOVERVIEWPARAMS params = [self getOverViewParams];;
    GSTATUS res = [MWMapOperator ViewToOverView:phMapView pstParams:&params hBackupView:&_backUpView];
    if (res == GD_ERR_OK)
    {
        _bOverView = YES;
    }
    [self reloadAllSeeButtonImage];
    [poiDetail setHidden:YES];
//    _buttonModeChange.hidden =  YES;  //开启全览，地图视角调节按钮隐藏
}


/*!
  @brief    关闭全览
  @param    animated   是否需要动画
  @author   by bazinga
  */
- (void) closeAllSeeWithAnimated:(BOOL)animated
{
    if (_bOverView)
    {
        if (animated == NO)
        {
            int value = 0;
            GDBL_SetParam(G_MAP_SHOW_ANIMATED, &value);
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                int oldValue = 1;
                GDBL_SetParam(G_MAP_SHOW_ANIMATED, &oldValue);
            });
        }
        GHMAPVIEW phMapView;
        GDBL_GetMapViewHandle(GMAP_VIEW_TYPE_MAIN, &phMapView);
        GSTATUS res = [MWMapOperator RecoveryView:&_backUpView hView:phMapView]; //备份句柄_backUpView不能置为空，否则会崩溃
        if (res == GD_ERR_OK)
        {
            _bOverView = NO;
        }
        [self reloadAllSeeButtonImage];
        [poiDetail setHidden:YES];
        
        _buttonModeChange.hidden = NO;  //关闭全览，地图视角调节按钮显示
    }
}

//重载全览的图片
- (void) reloadAllSeeButtonImage
{
    [_mainOtherObject relaodAllSeeImage:_bOverView];
}

/*!
  @brief    重载放大缩小的图片
  @param
  @author   by bazinga
  */
- (void) reloadEnlargeAndNarrowImage
{
    [_mainLargeAndNarrowObject reloadImage];
}



/*!
  @brief
  @param
  @author   by bazinga
  */
- (void) reloadCancelDetourImage
{
    if([[MWPreference sharedInstance] getValue:PREF_DAYNIGHTMODE] == 1)
    {
        [self setDayAndNightTextColor:1];
    }
    else
    {
        [self setDayAndNightTextColor:0];
    }
    [_mainOtherObject reloadCancelNearByImage];
}

- (void)setGetPOIInfoButtonFrame
{
    if (![ANParamValue sharedInstance].isMove)
    {
        //modify by gzm for 根据车标位置改变按钮位置，这里需要延迟0.5秒，要不获取的位置会有偏差。 at 2014-7-23
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
        {
           GMAPVIEW pMapview = {0};
            GDBL_GetMapView(&pMapview);
            [[MWMapOperator sharedInstance]MW_ShowMapView:pMapview.eViewType WithParma1:0 WithParma2:0 WithParma3:0];
            GCARINFO pCarInfo = {0};
            GDBL_GetCarInfo(&pCarInfo);
            GFCOORD carScreenPoint = [MWEngineTools GeoToScr:pCarInfo.Coord];
            if (carScreenPoint.x >0 && carScreenPoint.y > 0)
            {
                [_buttonGetPOIInfo setCenter:CGPointMake(carScreenPoint.x, carScreenPoint.y)];
            }
        });
        
    }
}


//竖屏
- (void)changePortraitControlFrameWithImage
{
    if (![[ANParamValue sharedInstance] isInit])
    {
        return;
    }
    
    if (_bOverView) //add by gzm for 处于全览界面时，翻转屏幕，得先返回原先视图，再调用翻转接口，最后在加载全览视图，要不然会失真 at 2014-7-28
    {
        _bCanNotSwapBuffer = YES;
        int value = 0;
        GDBL_SetParam(G_MAP_SHOW_ANIMATED, &value); //add by gzm for 因为全览视图的进入和返回存在动画，所以得先关闭动画 at 2014-7-28
        
        GHMAPVIEW phMapView;
        GDBL_GetMapViewHandle(GMAP_VIEW_TYPE_MAIN, &phMapView);
        [MWMapOperator RecoveryView:&_backUpView hView:phMapView]; //备份句柄_backUpView不能置为空，否则会崩溃
        [_mapView setmyFrame:CGRectMake(0.0, 0.0, SCREENWIDTH, SCREENHEIGHT)];
        [[MWPreference sharedInstance] setValue:PREF_DISPLAY_ORIENTATION Value:1];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            _bCanNotSwapBuffer = NO;
            GHMAPVIEW phMapView;
            GOVERVIEWPARAMS params = [self getOverViewParams];
            GDBL_GetMapViewHandle(GMAP_VIEW_TYPE_MAIN, &phMapView);
            [MWMapOperator ViewToOverView:phMapView pstParams:&params hBackupView:&_backUpView];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                int oldValue = 1;
                GDBL_SetParam(G_MAP_SHOW_ANIMATED, &oldValue);
            });
        });
       
    }
    else
    {
        [_mapView setmyFrame:CGRectMake(0.0, 0.0, SCREENWIDTH, SCREENHEIGHT)];
        [[MWPreference sharedInstance] setValue:PREF_DISPLAY_ORIENTATION Value:1];
    }
    
    _reloadSwitchFrame = YES;
    [self changeViewFrameWithID:0];
    
    [self setMainViewFrame];
}

//横屏
- (void)changeLandscapeControlFrameWithImage
{
    if (![[ANParamValue sharedInstance] isInit])
    {
        return;
    }
    
    if (_bOverView) //add by gzm for 处于全览界面时，翻转屏幕，得先返回原先视图，再调用翻转接口，最后在加载全览视图，要不然会失真 at 2014-7-28
    {
        _bCanNotSwapBuffer = YES;
        int value = 0;
        GDBL_SetParam(G_MAP_SHOW_ANIMATED, &value); //add by gzm for 因为全览视图的进入和返回存在动画，所以得先关闭动画 at 2014-7-28
        
        GHMAPVIEW phMapView;
        GDBL_GetMapViewHandle(GMAP_VIEW_TYPE_MAIN, &phMapView);
        [MWMapOperator RecoveryView:&_backUpView hView:phMapView]; //备份句柄_backUpView不能置为空，否则会崩溃
        [_mapView setmyFrame:CGRectMake(0.0, 0.0, SCREENHEIGHT, SCREENWIDTH)];
        [[MWPreference sharedInstance] setValue:PREF_DISPLAY_ORIENTATION Value:0];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            _bCanNotSwapBuffer = NO;
            GHMAPVIEW phMapView;
            GOVERVIEWPARAMS params = [self getOverViewParams];
            GDBL_GetMapViewHandle(GMAP_VIEW_TYPE_MAIN, &phMapView);
            [MWMapOperator ViewToOverView:phMapView pstParams:&params hBackupView:&_backUpView];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                int oldValue = 1;
                GDBL_SetParam(G_MAP_SHOW_ANIMATED, &oldValue);
            });
        });
    }
    else
    {
        [_mapView setmyFrame:CGRectMake(0.0, 0.0, SCREENHEIGHT, SCREENWIDTH)];
        [[MWPreference sharedInstance] setValue:PREF_DISPLAY_ORIENTATION Value:0];
    }
    
    _reloadSwitchFrame = YES;
    [self changeViewFrameWithID:1];
    
    [self setMainViewFrame];
}
//移图完后显示按钮
-(void)delayShowButton:(id)sender
{
    if (moveMapTimer != nil)
    {
        [moveMapTimer invalidate];
        moveMapTimer = nil;
    }
    //设置显示无数据区域提醒
    [self setButtonTipsView:[CheckMapDataObject CheckMapData]];
    gestureFlag = NO;
    [self.view sendSubviewToBack:_mapView];
    
    int value = 1;
    GDBL_SetParam(G_GUIDE_SHOWLANES, &value); //modify by gzm for 移图后显示车道信息,设置后需要重现刷图显示 at 2014-10-23
    [[MWMapOperator sharedInstance] MW_ShowMapView:GMAP_VIEW_TYPE_MAIN WithParma1:0 WithParma2:0 WithParma3:0];
}

- (void)delayShowPopPOI:(id)sender
{
    if(_mapType == GMAP_VIEW_TYPE_MAIN)
    {
    if (popPOITimer != nil)
    {
        [popPOITimer invalidate];
        popPOITimer = nil;
    }
    if ([[MWPreference sharedInstance] getValue:PREF_AUTO_GETPOIINFO]) {//移图后显示poi详情
        
        [poiDetail setHidden:YES];
        GMAPCENTERINFO mapCenter = {0};
        GHMAPVIEW phMapView;
        GDBL_GetMapViewHandle(GMAP_VIEW_TYPE_MAIN, &phMapView);
        GDBL_GetMapViewCenterInfo(phMapView, &mapCenter);
        GCARINFO carInfo = {0};
        GDBL_GetCarInfo(&carInfo);
        //显示的逻辑—— 没有路径 || 有路径的情况下，要是本地路径并且不是在网络地图视图下
        if(![[ANParamValue sharedInstance] isPath] || ([[ANParamValue sharedInstance] isPath]))
        {
            //显示逻辑 —— 是网络地图  ||  不是网络地图，车位经纬度不等于地图中心点经纬度
            if((carInfo.Coord.x != mapCenter.CenterCoord.x || carInfo.Coord.y != mapCenter.CenterCoord.y))
            {
                poiShowObject.popPoi = poiDetail;
                poiShowObject.coord = mapCenter.CenterCoord;
                if([ANParamValue sharedInstance].isPath)
                {
                    poiShowObject.poiType  = ViewPOIType_passBy;
                }
                else
                {
                    poiShowObject.poiType  = ViewPOIType_Detail;
                }
    
                if( [CheckMapDataObject CheckMapData]  == 1) //有数据才去显示 popPoi
                {
                    [poiShowObject show];
                }
            }
        }
        
    }
    }
    
}

//定时器控制按钮的显示：8秒隐藏菜单栏
- (void)fireTimer:(NSTimer *)timer {
	//白天黑夜监测
    [MWDayNight SetDayNightModeCallback];
    //实时交通语音播报
    [[ANOperateMethod sharedInstance] GMD_TrafficPlaySound];
    
	if (self.navigationController.topViewController!=self)
	{
		timerCount = 0;
		return;
	}
	timerCount++;
    
	if (10==timerCount)
	{
        if(_bOverView)
        {
            [self closeAllSeeWithAnimated:YES];
        }
        if ([[ANParamValue sharedInstance] isPath] && [[ANParamValue sharedInstance] isMove])
        {
            [[MWMapOperator sharedInstance] MW_GoToCCP];
            //解决有路径情况下，回车位出现放大路口和导航界面按钮重合
            [self viewInfoInCondition:0];
            [self setButtonTipsView:[CheckMapDataObject CheckMapData]];
        }
        if ([[ANParamValue sharedInstance] isPath] )
        {
            [poiDetail setHidden:YES];
        }
        //        [GDMenu dismissMenu];
		[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_TOUCH object:[NSNumber numberWithBool:YES]];
        
	}
    
}

- (void)nextRoadLableHidden:(BOOL)sign
{
    [_mainNaviTopObject setNextRoadHidden:sign];
}
//更新主界面上——更多，微享的new图标的显示
- (void)handleUIUpdate:(NSNotification *)result
{
    switch ([[result object] intValue]) {
        case UIUpdate_MapDayNightModeChange:
        {
            [self setDayAndNightStyle];
            [self setDayAndNightTextColor: [[result.userInfo objectForKey:@"dayNightMode"]integerValue]];
        }
            break;
        case UIUpdate_SkinTypeChange://地图皮肤类型修改
        {
            //[self setControlImageByType: [[result.userInfo objectForKey:CONFIG_SKIN_ID]integerValue]];
        }
            break;
        case UIUpdate_TMC:
        {
            [[MWPreference sharedInstance]  setValue:PREF_REALTIME_TRAFFIC Value:[MWEngineSwitch isTMCOn]];
            [self buttonRealInitImage];
            [[CustomRealTimeTraffic sharedInstance] updateCurrentTrafficInfo];
        }
            break;
        case UIUpdate_MessageMoveMap:
        {
            _mapType = GMAP_VIEW_TYPE_MAIN;
            [[MWMapOperator sharedInstance]MW_ShowMapView:_mapType WithParma1:0 WithParma2:0 WithParma3:0];
            [poiDetail setHidden:YES];
            //移图后显示poi详情
            
            if([[ANParamValue sharedInstance]isPath])
            {
                timerCount = 0;
                poiShowObject.poiType  = ViewPOIType_passBy;
                
            }
            else
            {
                poiShowObject.poiType  = ViewPOIType_Detail;
            }
            GMAPCENTERINFO mapCenter = {0};
            GHMAPVIEW phMapView;
            GDBL_GetMapViewHandle(GMAP_VIEW_TYPE_MAIN, &phMapView);
            GDBL_GetMapViewCenterInfo(phMapView, &mapCenter);
            
            poiShowObject.popPoi = poiDetail;
            poiShowObject.coord = mapCenter.CenterCoord;
            [poiShowObject show];
            NSLog(@"SHOW OBJECT");
            
            //设置显示无数据区域提醒
            //短信，网页分享移图，添加判断是否有数据
            //add by bazinga @2014.08.21
            [self setButtonTipsView:[CheckMapDataObject CheckMapData]];
            
        }
            break;
        case UIUpdate_SkinNew:
        {
//            if([[GDNewJudge sharedInstance] isAppearNewWithType:NEW_JUDGE_SKIN_TYPE])
//            {
//                [[MWPreference sharedInstance] setValue:PREF_IS_FIRSTENTERSKIN Value:1];
//            }
            
            if([ANParamValue sharedInstance].GMD_isMoreNew)
            {
                [_mainBottomMenuObject setSettingNewHidden:NO];
            }
            else
            {
                [_mainBottomMenuObject setSettingNewHidden:YES];
            }
            
        }
            break;
//        case UIUpdate_CarNew:
//        {
//            _imageViewNewCar.hidden = ![[GDNewJudge sharedInstance]isAppearNewWithType:NEW_JUDGE_CAR_TYPE];
//        }
            break;
        case UIUpdate_DialectViewProgredd:
        {
            
            Plugin_Dialect *tempPlugin = [[Plugin_Dialect alloc] init];
            id<ModuleDelegate> object= tempPlugin;
            NSDictionary *param=[NSDictionary dictionaryWithObject:self.navigationController forKey:@"controller"];
            [object enter:param];
            [tempPlugin release];
            
        }
            break;
        case UIUpdate_SimNaviStop:
        {
            GDBL_CloseZoomView();
            
            double delayInSeconds = 0.5;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [[MWMapOperator sharedInstance] MW_ShowMapView:_mapType WithParma1:0 WithParma2:0 WithParma3:0];
            });
            [_mainSimBottomObject setSimPlayImage:YES];
            _simPlayOrPause = -2;
        }
            break;
        case UIUpdata_CarDistanceThreeKM://目的地停车场
        {
            
            if([POICommon isEqualToCompanyAndHome:[MWJourneyPoint getJourneyPointWithID:6]])
            {
                return ;
            }
            
            Plugin_POI *pluginPoi = [[Plugin_POI alloc] init];
            NSDictionary *dic=@{POI_TYPE:@(9),
                                POI_DELEGATE:self,
                                };
            [pluginPoi enter:dic];
            [pluginPoi release];
           
        }
            break;
        case UIUpdata_RedPointUpdate:   //红点请求
        {
            [self redRequestSuccess];
        }
            break;
            
        case UIUpdata_DrivingTrack:
        {
            if ([[MWPreference sharedInstance] getValue:PREF_AUTODRIVINGTRACK]) {
                
                NSString *alertString = [[NSUserDefaults standardUserDefaults] objectForKey:USERDEFAULT_AlertViewScoreOnce];
                if (!alertString) {
                    
                    [[NSUserDefaults standardUserDefaults] setValue:@"click" forKey:USERDEFAULT_AlertViewScoreOnce];
                    
                    GDAlertView *alertView = [[GDAlertView alloc] initWithTitle:nil andMessage:STR(@"DrivingTrack_alertViewScore", Localize_DrivingTrack)];
                    
                    [alertView show];
                    [alertView release];
                    
                }
                
                return;
            }
            
            DrivingInfo *info = [result.userInfo objectForKey:@"drivingTrackInfo"];
            DrivingTrackDetailViewController *viewControll = [[DrivingTrackDetailViewController alloc] init];
            [viewControll setValueWithDrivingTrack:info];
            [self.navigationController pushViewController:viewControll animated:YES];
            [viewControll release];
            
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
    [_mainOtherObject relaodRealIamge];
}

/*!
  @brief 检测皮肤是否完整，皮肤类型不为默认，如果在皮肤列表获取不到当前皮肤类型对应的皮肤任务，或者对应的皮肤任务的状态不为完成，则把当前的皮肤类型设置未默认的
  @return
  */
- (void) skinCheck
{
    if (0 != [[MWPreference sharedInstance] getValue:PREF_SKINTYPE]) {
            [[MWPreference sharedInstance] setValue:PREF_SKINTYPE Value:0];
            [[MWApp sharedInstance] loadSkin];
            [(VCCustomNavigationBar*)self.navigationController.navigationBar refeshBackground];
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_HandleUIUpdate object:[NSNumber numberWithInt:UIUpdate_SkinTypeChange] userInfo:@{CONFIG_SKIN_ID: [NSNumber numberWithInt:[[MWPreference sharedInstance] getValue:PREF_SKINTYPE]] }];
    }
}

#pragma mark -
#pragma mark =====按钮响应=====


- (void)buttonAction:(id)sender
{
	UIButton *button = (UIButton *)sender;
	[self button:button clickedWithTag:button.tag];
}

- (void)button:(UIButton *)button clickedWithTag:(NSInteger)tag {
	
    timerCount = 0;
    // 关闭弹出的微享按钮
    if (tag!=BUTTON_WESHARE && tag != BUTTON_COMMON) {
        [self viewInCondition:HMI_HIDDEN_SCALEVIEW];
    }
    //    //关闭详情弹出框
    //    if (poiDetail) {
    //        [poiDetail setHidden:YES];
    //    }
    if (tag != 1) {
        if (!(YES==[[ANParamValue sharedInstance] isPath] && ([MWRouteGuide GetGuideFlags]& G_GUIDE_FLAGS_CROSSZOOM) == G_GUIDE_FLAGS_CROSSZOOM) || ([MWRouteGuide GetGuideFlags] == G_GUIDE_FLAGS_GUIDEPOST))
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_TOUCH object:[NSNumber numberWithBool:NO]];//屏幕点击消息
        }
    }
    
	switch (tag)
	{
        
		case BUTTON_GOTOCCP://回车位
        case BUTTON_MAP_BAR_GO_CAR_POSITON:
        case BUTTON_BACK_CAR:
		{
            [self Action_GoToCCP];
		}
			break;
			
		case BUTTON_VER_COLLECTPOI://竖屏收藏当前点
		{
            [self Action_saveFavPOI];
            
		}
			break;
		case BUTTON_SET_VIEWMODE://切换视图模式
		{

		}
            break;
        case BUTTON_GUIDEPOST://高速路牌
        {
            [self Action_guidePost];
        }
            break;
		case BUTTON_SET_PARALLELROAD://平行道路切换
		{
            [self Action_parallelRoad];
		}
			break;
			
        case BUTTON_DRIVECOMPUTER://行车电脑
		{
			
		}
			break;
        case BUTTON_PARALLELROAD://平行道路
		{
			[self PalellerRoadActionSheet];
			
		}
			break;
        case BUTTON_STOPNAVI://是否停止导航
		{
            [self Action_stopNavi];
		}
			break;
		case BUTTON_COMMON://常用
		{
			[self Action_common];
		}
			break;
		case BUTTON_MORE://更多
		{
			[self Action_more];
		}
			break;
		case BUTTON_SEARCH://搜索
		{
            [self Action_pushSearchView];
		}
			break;
            
        case BUTTON_NEARBY:
        {
            [self Action_pushNearByView];
        }
            break;
		case BUTTON_COLLECTPOI://收藏当前点
		{
			[self Action_collectCurPOI];
		}
			break;
		case BUTTON_SET_DES://设终点
		{
            [self Action_setDes];
		}
			break;
		case BUTTON_SET_START://设起点
		{
            [self Action_setStart];
		}
			break;
		case BUTTON_SET_PASSBY://设途经点
		{
            [self Action_setPassBy];
		}
			break;
        case BUTTON_REAL_BUTTON :
        {
            [self Real_Traffic_Action];
            NSLog(@"BUTTON_REAL_BUTTON");
        }
            break;
        case BUTTON_TOP_SEARCH :
		{
            [self Action_topSearch];
            NSLog(@"BUTTON_TOP_SEARCH");
        }
            break;
        case BUTTON_TOP_FACEBUTTON:
        {
            [self topFacePress];
        }
            break;
        case BUTTON_MODE_SWITCH:
        {
            [self.view bringSubviewToFront:_mainCarModeView];
            [self.view bringSubviewToFront:_buttonModeChange];
            [_mainCarModeView showHideModeSwitch];
        }
            break;
        case BUTTON_GET_POIINFO://获取车位poi信息
        {
            if ((![poiDetail getHidden] && [[ANParamValue sharedInstance] isPath])
                || _mapType != GMAP_VIEW_TYPE_MAIN) {
                return;
            }
            GCARINFO carInfo = {0};
            GDBL_GetCarInfo(&carInfo);
            poiShowObject.poiType  = ViewPOIType_Detail;
            poiShowObject.popPoi = poiDetail;
            poiShowObject.coord = carInfo.Coord;
            [poiShowObject show];
            _buttonGetPOIInfo.hidden = YES;
        }
            break;
        case BUTTON_SEARCH_SOUND:
        {
            [_poiVoiceSearch startVoiceSearch];
        }
            break;
        case BUTTON_LIST_MENU:
        {
            int mode=[[MWPreference sharedInstance] getValue:PREF_MUTE];
            NSString *muteString = (mode == 1 ? STR(@"Main_CloseMute", Localize_Main):STR(@"Main_OpenMute", Localize_Main));
            NSString *muteImageString = (mode == 1 ? @"Main_CancelMute" :@"Main_Mute");
            NSArray* arrayTitle= @[STR(@"Main_naviSetting", Localize_Main),
                                   STR(@"Main_nearbySearch", Localize_Main),
                                   STR(@"Main_routePlanning", Localize_Main),
                                   STR(@"Main_addEye", Localize_Main),
                                   STR(@"Main_addWayPoint", Localize_Main),
                                   muteString,
                                   STR(@"Main_close",Localize_Main)];
            
            NSArray* arrayImage =@[@"Main_NaviSetting",
                                   @"Main_SearchAlong",
                                   @"Main_RoutePlanning",
                                   @"Main_AddCamer",
                                   @"Main_AddWayPoint",
                                   muteImageString,
                                   @"Main_SettingCancel"];
            
            [SociallShareManage ShowViewWithDelegate:self andWithImage:arrayImage andWithTitle:arrayTitle];
            
        }
            break;
        case BUTTON_HUD:
        {
            [self Action_pushDriveComptureView];
        }
            break;
        case BUTTON_CANCEL_NEARBY:
        {
            [self Action_cancelNearBy];
        }
            break;
        case BUTTON_ALLSEE:
        {
            [self Action_AllSeePress];
        }
            break;
        case BUTTON_SIMULATOR_STOP:
        {
            [self Action_simulatorNavi_Stop];
        }
            break;
        case BUTTON_SIMULATOR_SLOW:
        {
            [self selectSimuSpeed];
        }
            break;
        case BUTTON_SIMULATOR_PAUSE:
        {
            [self Action_simulatorNavi_Pause_Continue];
        }
            break;
        default:
			break;
	}
}

/*
 "Share_Sms"="SMS";
 "Share_Friend"="Friends";
 "Share_Moments"="Moments";
 "Share_Sina"="Sina";
 */
/*
 0 导航设置 
 1 沿途搜索
 2 路线规划
 3 添加摄像头
 4 添加途经点
 5 关闭导航语音
 */
- (void)didClickOnImageIndex:(NSInteger )didSelect
{
    switch (didSelect) {
        case 0:
        {
            [self naviSetting];
        }
            break;
        case 1:
        {
            [self Action_pushAroundView];
        }
            break;
        case 2:
        {
            [self Action_pushBrowseView];
        }
            break;
        case 3:
        {
            [self Action_addEye];
        }
            break;
        case 4:
        {
            [self addWayPoint];
        }
            break;
        case 5:
        {
            [self mute];
        }
            break;
        default:
            break;
    }
}

- (void) mute
{
    int mode=[[MWPreference sharedInstance] getValue:PREF_MUTE];
    BOOL isOn = !(mode == 1 ? YES:NO);
    
    if(isOn)
    {
        [MobClick event:UM_EVENTID_NaviMenuBar_COUNT label:UM_LABEL_NaviMenuBar_OpenSound];
        [QLoadingView showImage:IMAGE(@"Main_MuteCloseTip.png", IMAGEPATH_TYPE_1)
                           info:STR(@"Main_CloseMuteTip", Localize_Main)
                       autoHide: YES];
        [[MWPreference sharedInstance] setValue:PREF_MUTE Value:1];
        [[MWPreference sharedInstance] setValue:PREF_SPEAKTRAFFIC Value:1];
        [[MWPreference sharedInstance] setValue:PREF_SPEAK_SAFETY Value:1];
        [[MWPreference sharedInstance] setValue:PREF_SWITCHEDVOICE Value:1];
        
    }
    else
    {
        [MobClick event:UM_EVENTID_NaviMenuBar_COUNT label:UM_LABEL_NaviMenuBar_CloseSound];
        [QLoadingView showImage:IMAGE(@"Main_MuteTip.png", IMAGEPATH_TYPE_1)
                           info:STR(@"Main_OpenMuteTip", Localize_Main)
                       autoHide: YES];
        [[MWPreference sharedInstance] setValue:PREF_MUTE Value:0];
        [[MWPreference sharedInstance] setValue:PREF_SPEAKTRAFFIC Value:0];
        [[MWPreference sharedInstance] setValue:PREF_SPEAK_SAFETY Value:0];
        [[MWPreference sharedInstance] setValue:PREF_SWITCHEDVOICE Value:0];
    }
}

/*!
  @brief    视图选择按钮函数
  @param
  @author   by bazinga
  */
- (void)carModeViewClick:(int) tag
{
    if(tag == BUTTON_HUD)
    {
        [self button:nil clickedWithTag:BUTTON_HUD];
    }
    //车位按钮位置
    [self setGetPOIInfoButtonFrame];
    
    //设置右上角地图视角的图片
    GMAPVIEWINFO mapObjectInfo = {0};
    [[MWMapOperator sharedInstance] MW_GetMapViewInfo:GMAP_VIEW_TYPE_MAIN MapViewInfo:&mapObjectInfo];
    NSString *imagestring = [NSString stringWithFormat:@"main_AngelBtn%d.png",mapObjectInfo.eMapMode];
    NSString *imagePressString = [NSString stringWithFormat:@"main_AngelBtnPress%d.png",mapObjectInfo.eMapMode];
    [_buttonModeChange setBackgroundImage:IMAGE(imagestring, IMAGEPATH_TYPE_2) forState:UIControlStateNormal];
    [_buttonModeChange setBackgroundImage:IMAGE(imagePressString, IMAGEPATH_TYPE_2) forState:UIControlStateHighlighted];
}



//添加途经点
- (void) addWayPoint
{
    //    添加途经点---导航菜单栏
    [MobClick event:UM_EVENTID_NaviMenuBar_COUNT label:UM_LABEL_NaviMenuBar_AddViaPoint];
    if(![[ANParamValue sharedInstance] isPath])
    {
        return ;
    }
    NSMutableArray * array = [MWJourneyPoint GetJourneyPointArray];
    if ([[ANParamValue sharedInstance] isMove] == YES)
    {
        GMAPCENTERINFO mapCenter = {0};
        GHMAPVIEW phMapView;
        GDBL_GetMapViewHandle(GMAP_VIEW_TYPE_MAIN, &phMapView);
        GDBL_GetMapViewCenterInfo(phMapView, &mapCenter);
        
        //如果车位和地图中心是同一点，也认为是没有移图
        //add by bazinga @2014.8.8
        GCARINFO pCarInfo = {0};
        GDBL_GetCarInfo(&pCarInfo);
        if(pCarInfo.Coord.x == mapCenter.CenterCoord.x && pCarInfo.Coord.y == mapCenter.CenterCoord.y)
        {
            Plugin_POI * enterPoi  = [[Plugin_POI alloc]init];
            NSMutableDictionary * dic = [[NSMutableDictionary alloc]init];
            [dic setObject:@"0" forKey:POI_TYPE];
            [dic setObject:array forKey:POI_Array];
            [dic setObject:@"2" forKey:POI_WhereGo];
            [dic setObject:self.navigationController forKey:POI_NAVIGATIONCONTROLLER];
            [enterPoi enter:dic];
            [enterPoi release];
            [dic release];
            return ;
        }
        
        if (array.count>=7) {
            [self createAlertViewWithTitle:nil
                                   message:STR(@"Route_mostFive", Localize_RouteOverview)
                         cancelButtonTitle:STR(@"Main_back", Localize_Main)
                         otherButtonTitles:nil
                                       tag:EVENT_NONE];
        }
        else
        {
            MWPoi *tempPoi = [[MWPoi alloc]init];
            if([ANParamValue sharedInstance].isMove)
            {
                tempPoi.longitude = mapCenter.CenterCoord.x;
                tempPoi.latitude = mapCenter.CenterCoord.y;
                tempPoi.szName =  [[NSString chinaFontStringWithCString:mapCenter.szRoadName] isEqualToString:@""] ? STR(@"Main_unNameRoad", Localize_Main) : [NSString chinaFontStringWithCString:mapCenter.szRoadName];
            }
            else
            {
                tempPoi.longitude = 0;
                tempPoi.latitude = 0;
                tempPoi.szName =  STR(@"Route_enterTempPoint", Localize_RouteOverview);
            }
            [array insertObject:tempPoi atIndex:array.count-1];
            Plugin_POI * enterPoi  = [[Plugin_POI alloc]init];
            NSMutableDictionary * dic = [[NSMutableDictionary alloc]init];
            [dic setObject:@"0" forKey:POI_TYPE];
            [dic setObject:array forKey:POI_Array];
            [dic setObject:@"3" forKey:POI_WhereGo];
            [dic setObject:self.navigationController forKey:POI_NAVIGATIONCONTROLLER];
            [enterPoi enter:dic];
            [enterPoi release];
            [dic release];
            [tempPoi release];
        }
        
    }
    else
    {
   
        Plugin_POI * enterPoi  = [[Plugin_POI alloc]init];
        NSMutableDictionary * dic = [[NSMutableDictionary alloc]init];
        [dic setObject:@"0" forKey:POI_TYPE];
        [dic setObject:array forKey:POI_Array];
        [dic setObject:@"2" forKey:POI_WhereGo];
        [dic setObject:self.navigationController forKey:POI_NAVIGATIONCONTROLLER];
        [enterPoi enter:dic];
        [enterPoi release];
        [dic release];
    }
}


//取消周边点
- (void)Action_cancelNearBy
{
    [_mainOtherObject setCancelNearbyHidden:YES];
    [poiDetail setHidden:YES];
    [MWMapAddIconOperator ClearMapIcon];
    [[MWMapOperator sharedInstance] MW_ShowMapView:_mapType WithParma1:0 WithParma2:0 WithParma3:0];
}

//收藏当前点
- (void)Action_collectCurPOI
{

    if ( [MWAdminCode checkIsExistDataWithAdmincode:0] == 0) {
        [self MyalertView:STR(@"Main_NoDataPerformed", Localize_Main)
               canceltext:STR(@"Universal_ok", Localize_Universal)
                othertext:nil
                 alerttag:ALERT_NONE];
        return;
    }
    
    collectPOIFlag = YES;
    
}

//周边
- (void)Action_pushAroundView
{
    
    //    周边查询---导航菜单栏
    //    [MobClick event:UM_EVENTID_NaviMenuBar_COUNT label:UM_LABEL_NaviMenuBar_NearBy];
    //    [MobClick event:UM_EVENTID_NEARBY_COUNT label:UM_LABEL_NEARBY_FROM_NAVI_TOOL_BAR];
    //    Plugin_POI *pluginPoi = [[Plugin_POI alloc] init];
    //    NSDictionary *dic=@{POI_NAVIGATIONCONTROLLER:self.navigationController,
    //                        POI_TYPE:@(1),
    //                        POI_ISBACKSUPERVIEWCONTROLLER:@(1),
    //                        POI_DELEGATE:self,
    //                        POI_VIEWCONTROLLER:self};
    //    [pluginPoi enter:dic];
    //    [pluginPoi release];
    
    GDAlertView *alertView = [[[GDAlertView alloc] initWithTitle:nil andMessage:STR(@"Main_searchAlongRoute", Localize_Main)] autorelease];
    //加油站
    [alertView addButtonWithTitle:STR(@"Setting_POITypeFuel", Localize_Setting)
                             type:GDAlertViewButtonTypeBlack
                          handler:^(GDAlertView *alertView){
                              [MobClick event:UM_EVENTID_WayAround_Count label:UM_LABEL_WayAround_GasStation ];
                              [self routeAlongSearchWithType:10000];
                          }];
    //餐饮美食
    [alertView addButtonWithTitle:STR(@"Setting_POITypeCatering", Localize_Setting)
                             type:GDAlertViewButtonTypeBlack
                          handler:^(GDAlertView *alertView){
                              [MobClick event:UM_EVENTID_WayAround_Count label:UM_LABEL_WayAround_Food ];
                              [self routeAlongSearchWithType:40000];
                          }];
    //酒店住宿
    [alertView addButtonWithTitle:STR(@"Setting_POITypeHotel", Localize_Setting)
                             type:GDAlertViewButtonTypeBlack
                          handler:^(GDAlertView *alertView){
                              [MobClick event:UM_EVENTID_WayAround_Count label:UM_LABEL_WayAround_ScenicSpot  ];
                              [self routeAlongSearchWithType:50000];
                          }];
    //风景名胜
    [alertView addButtonWithTitle:STR(@"Setting_POITypeScenicSpots", Localize_Setting)
                             type:GDAlertViewButtonTypeBlack
                          handler:^(GDAlertView *alertView){
                              [MobClick event:UM_EVENTID_WayAround_Count label:UM_LABEL_WayAround_Toilet ];
                              [self routeAlongSearchWithType:70000];
                          }];
    //公共厕所
    [alertView addButtonWithTitle:STR(@"Setting_POITypeToilet", Localize_Setting)
                             type:GDAlertViewButtonTypeBlack
                          handler:^(GDAlertView *alertView){
                              [MobClick event:UM_EVENTID_WayAround_Count label:UM_LABEL_WayAround_Hotel];
                              [self routeAlongSearchWithType:150400];
                          }];
    
    [alertView addButtonWithTitle:STR(@"Main_back", Localize_Main) type:GDAlertViewButtonTypeCancel handler:nil];
    [alertView show];
}

- (void) routeAlongSearchWithType:(int) type
{
    [MobClick event:UM_EVENTID_NaviMenuBar_COUNT label:UM_LABEL_NaviMenuBar_NearBy];
    [MobClick event:UM_EVENTID_NEARBY_COUNT label:UM_LABEL_NEARBY_FROM_NAVI_TOOL_BAR];
    [QLoadingView showLoadingView:STR(@"Universal_loading", Localize_Universal) view:(UIWindow *)self.view];
    Plugin_POI *pluginPoi = [[Plugin_POI alloc] init];
    NSDictionary *dic=@{POI_TYPE:@(8),
                        POI_DELEGATE:self,
                        POI_CategoryID:[NSNumber numberWithInt:type]
                        };
    [pluginPoi enter:dic];
    [pluginPoi release];
}

//附近
- (void) Action_pushNearByView
{
    
    Plugin_POI *pluginPoi = [[Plugin_POI alloc] init];
    NSDictionary *dic=@{POI_NAVIGATIONCONTROLLER:self.navigationController,POI_TYPE:@(2)};
    [pluginPoi enter:dic];
    [pluginPoi release];
}
//搜索
- (void)Action_topSearch
{
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.5f];
    [animation setSubtype:kCATransitionReveal];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    
    Plugin_POI *pluginPoi = [[Plugin_POI alloc] init];
    NSDictionary *dic=@{POI_NAVIGATIONCONTROLLER:self.navigationController,POI_TYPE:@(3)};
    [pluginPoi enter:dic];
    [pluginPoi release];
    [self.navigationController.view.layer addAnimation:animation forKey:nil];
    
}
//添加电子眼
- (void)Action_addEye
{
    //    添加电子眼---导航菜单栏
    [MobClick event:UM_EVENTID_NaviMenuBar_COUNT label:UM_LABEL_NaviMenuBar_AddCamera];
    if(![[ANParamValue sharedInstance] isPath])
    {
        return ;
    }
    GMAPCENTERINFO mapinfo = {0};
    [[MWMapOperator sharedInstance] MW_GetMapViewCenterInfo:GMAP_VIEW_TYPE_MAIN mapCenterInfo:&mapinfo];
    self.navigationController.navigationBarHidden = NO;
    MWSmartEyesItem *eyesItem = [[MWSmartEyesItem alloc] init];
    eyesItem.longitude = mapinfo.CenterCoord.x;
    eyesItem.latitude = mapinfo.CenterCoord.y;
    eyesItem.szName =  [NSString chinaFontStringWithCString:mapinfo.szRoadName];
    Plugin_POI *pluginPoi = [[Plugin_POI alloc] init];
    NSDictionary *dic=@{POI_NAVIGATIONCONTROLLER:self.navigationController,
                        POI_TYPE:@(4),
                        POI_DATA:@{@"camera":eyesItem} };
    [pluginPoi enter:dic];
    [pluginPoi release];
    [eyesItem release];
    
}


//更多
- (void)Action_more
{
    Plugin_Setting *tempPlugin = [[Plugin_Setting alloc] init];
    id<ModuleDelegate> object= tempPlugin;
    NSDictionary *param=[NSDictionary dictionaryWithObject:self.navigationController forKey:@"controller"];
    [object enter:param];
    [tempPlugin release];
}

//导航设置
- (void)naviSetting
{
    //    导航设置---导航菜单栏
    [MobClick event:UM_EVENTID_NaviMenuBar_COUNT label:UM_LABEL_NaviMenuBar_NaviSet];
    if(![[ANParamValue sharedInstance] isPath])
    {
        return ;
    }
    self.navigationController.navigationBarHidden = NO;
    Plugin_Setting *tempPlugin = [[Plugin_Setting alloc] init];
    id<ModuleDelegate> object= tempPlugin;
    NSDictionary *param=[NSDictionary dictionaryWithObjectsAndKeys:self.navigationController,@"controller" ,
                         [NSNumber numberWithInt:1],@"controllertype", nil];
    [object enter:param];
    [tempPlugin release];
}
//常用
- (void)Action_common
{
    //服务---主地图界面
    [MobClick event:UM_EVENTID_SERVICE_COUNT label:UM_EVENTID_SERVICE_COUNT];
    Plugin_CarService *pluginStore = [[Plugin_CarService alloc]init];
    NSArray *dic= @[self.navigationController];
    [pluginStore enter:dic];
    [pluginStore release];
    
//    [[GDNewJudge sharedInstance] setHiddenNewByKey:NEW_JUDGE_CAR_TYPE];
}

//停止导航
- (void)Action_stopNavi
{
     [MobClick event:UM_EVENTID_NaviMenuBar_COUNT label:UM_LABEL_NaviMenuBar_FinishNavi];
    if ([[ANParamValue sharedInstance] isNavi])
    {
        return;
    }
    if ([[ANParamValue sharedInstance] isPath] && (NO==[[ANParamValue sharedInstance] isNavi]))
    {
        [self MyalertView:STR(@"Main_isStopNavi", Localize_Main)
               canceltext:STR(@"Universal_cancel", Localize_Universal)
                othertext:STR(@"Universal_ok", Localize_Universal)
         
                 alerttag:ALERT_STOPSIMULATOR];
    }
    [poiDetail setHidden:YES];

}

//导航菜单栏进入结束导航
- (void) Action_stopNaviByMenu
{
    //    结束导航---导航菜单栏
    [MobClick event:UM_EVENTID_NaviMenuBar_COUNT label:UM_LABEL_NaviMenuBar_FinishNavi];
    [self Action_stopNavi];
}
//进入HUD
- (void)Action_pushDriveComptureView
{
    [_mainCarModeView hideModeSwitch];
    if ([[ANParamValue sharedInstance] isNavi])
    {
        return ;
    }
    
    [[ANParamValue sharedInstance] setIsHud: YES];
    HudViewController *ctl = [[HudViewController alloc] init];
    [self.navigationController pushViewController:ctl animated:YES];
    [ctl release];
    
}
//平行道路切换
- (void)Action_parallelRoad
{
    if ( [MWAdminCode checkIsExistDataWithAdmincode:0] == 0 )
    {
        CityDownLoadModule *tempCityDownModule = [[CityDownLoadModule alloc]init];
        id<ModuleDelegate> module = tempCityDownModule;
        NSDictionary *param;
        int Admin_code;
        Admin_code = [MWAdminCode GetCurAdminCode];
        NSMutableArray *cityArray = [[NSMutableArray alloc] init];
        [cityArray addObject:[NSNumber numberWithInt:Admin_code]];
        NSDictionary *cityAdmin = [[NSDictionary alloc] initWithObjectsAndKeys:cityArray,@"city",nil,@"province", nil];
        [cityArray release];
        param  = [[NSDictionary alloc] initWithObjectsAndKeys:self.navigationController,@"controller",@"assignDownData",@"parma",cityAdmin,@"cityAdmincode",nil];
        [module enter:param];
        [cityAdmin release];
        [param release];
        [tempCityDownModule release];
        return;
    }
    if (parallelFlag == YES &&   [_mainOtherObject getParallelRoadHidden] == NO)
    {
        [self PalellerRoadActionSheet];
    }
}
//高速路牌
- (void)Action_guidePost
{
    [[MWPreference sharedInstance] setValue:PREF_MAP_SHOW_GUIDEPOST Value:YES];
    [_mainOtherObject setGuidePostHidden:YES];
    [[MWMapOperator sharedInstance] MW_ShowMapView:_mapType WithParma1:0 WithParma2:0 WithParma3:0];
}

//回车位

-(void)openDocumentIn {
    NSString * filePath =
    [[NSBundle mainBundle]
     pathForResource:@"Hud_Direction" ofType:@"png"];
    UIDocumentInteractionController *documentController = [UIDocumentInteractionController
     interactionControllerWithURL:[NSURL fileURLWithPath:filePath]];
    documentController.delegate = self;
    [documentController retain];
    documentController.UTI = @"com.adobe.pdf";
    [documentController presentOpenInMenuFromRect:CGRectZero
                                           inView:self.view
                                         animated:YES];
}

-(void)documentInteractionController:(UIDocumentInteractionController *)controller
       willBeginSendingToApplication:(NSString *)application {
     NSString *a = @"";
}

-(void)documentInteractionController:(UIDocumentInteractionController *)controller
          didEndSendingToApplication:(NSString *)application {
     NSString *a = @"";
}

-(void)documentInteractionControllerDidDismissOpenInMenu:
(UIDocumentInteractionController *)controller {
     NSString *a = @"";
}

- (void)documentMenu:(UIDocumentMenuViewController *)documentMenu didPickDocumentPicker:(UIDocumentPickerViewController *)documentPicker
{
    NSString *a = @"";
    documentPicker.delegate  = self;
    [self presentViewController:documentPicker animated:NO completion:nil];
}
- (void)documentMenuWasCancelled:(UIDocumentMenuViewController *)documentMenu
{
    NSString *a = @"";
}

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentAtURL:(NSURL *)url
{
    NSData *data = [NSData dataWithContentsOfURL:url];
    NSError *error = nil;
    NSString *str = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
    NSString *a = url.path;
}

- (void)Action_GoToCCP
{
    UIDocumentMenuViewController *testctl = [[UIDocumentMenuViewController alloc] initWithDocumentTypes:@[@"public.content"] inMode:UIDocumentPickerModeOpen];
    testctl.delegate = self;
    [self presentViewController:testctl animated:NO completion:nil];
    [testctl release];
    return;
    
//    NSString * filePath =
//    [[NSBundle mainBundle]
//     pathForResource:@"Hud_Direction" ofType:@"png"];
//    NSURL *url = [NSURL URLWithString:filePath];
//    UIDocumentPickerViewController *testctl = [[UIDocumentPickerViewController alloc] initWithURL:url inMode:UIDocumentPickerModeMoveToService];
//    testctl.delegate = self;
//    [self presentViewController:testctl animated:NO completion:nil];
//    [testctl release];
//    return;
    
//    UIDocumentPickerViewController *documentPicker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:@[@"public.content"]
//                                                                                                            inMode:UIDocumentPickerModeImport];
//    documentPicker.delegate = self;
//    documentPicker.modalPresentationStyle = UIModalPresentationFormSheet;
//    [self presentViewController:documentPicker animated:YES completion:nil];
    
    
    return;
    
    [MWMapOperator correctMapRotating];   //modify by gzm for 北首上，回车位时，恢复地图旋转角度 at 2014-10-17
    
    BOOL isCurrentSafe = NO;
    if ([[ANParamValue sharedInstance] isSafe]) {
        isCurrentSafe = YES;
    }
    
    [[MWMapOperator sharedInstance] MW_GoToCCP];
    
    if (isCurrentSafe == YES) {
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_TOUCH object:[NSNumber numberWithBool:YES]];
    }
    
    [poiDetail setHidden:YES];
    timerCount = 4;
    //解决有路径情况下，回车位出现放大路口和导航界面按钮重合
    [self viewInfoInCondition:0];
    
    [[MWMapOperator sharedInstance] MW_ShowMapView:GMAP_VIEW_TYPE_MAIN WithParma1:0 WithParma2:0 WithParma3:0];
    _mapType = GMAP_VIEW_TYPE_MAIN;
    [self reloadAllSeeButtonImage];
    [self setGetPOIInfoButtonFrame];
    [self setButtonTipsView:[CheckMapDataObject CheckMapData]];
}
//进入搜索页面
- (void)Action_pushSearchView
{
    Plugin_POI *pluginPoi = [[Plugin_POI alloc] init];
    NSDictionary *dic=@{POI_NAVIGATIONCONTROLLER:self.navigationController,POI_TYPE:@(0),POI_DATA:@{POI_DATA_FROMMAINCONTROLLER:@(1)}};
    [pluginPoi enter:dic];
    [pluginPoi release];
}

- (void) pushPlanningAndDetailViewControllerDeleteRoute:(BOOL) deleteRoute withAnimated:(BOOL)animate
{
    float afterTime = 0.0f;
    if(_bOverView)
    {
        [self closeAllSeeWithAnimated:NO];
        afterTime = 0.1f;

    }
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(afterTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [[MWMapOperator sharedInstance] MW_GoToCCP];
        RoutePlanningAndDetailViewController *browseViewController = [[RoutePlanningAndDetailViewController alloc] initWithDeleteRoute:deleteRoute];
        browseViewController.isAnimate = animate;
        [self.navigationController pushViewController:browseViewController animated:NO];
        [browseViewController release];
    });

}

//进入全程概览
- (void)Action_pushBrowseView
{
    //    路线规划---导航菜单栏
    [MobClick event:UM_EVENTID_NaviMenuBar_COUNT label:UM_LABEL_NaviMenuBar_RoutePlanRule];
    if (NO==[[ANParamValue sharedInstance] isPath] || [[ANParamValue sharedInstance] isNavi])
    {
        return;
    }
    [self pushPlanningAndDetailViewControllerDeleteRoute:NO withAnimated:NO];
}

- (void)Action_pushBrowseViewDeleteRoute
{
    if (NO==[[ANParamValue sharedInstance] isPath] || [[ANParamValue sharedInstance] isNavi])
    {
        return;
    }
    [self pushPlanningAndDetailViewControllerDeleteRoute:YES withAnimated:NO];
}



- (void) ProgressBarEnd
{
    if (!routeResult && !_isPianyi)
    {
        [self MyalertView:STR(@"Main_failCalc", Localize_Main) canceltext:STR(@"Universal_back", Localize_Universal) othertext:nil alerttag:ALERT_NONE];
    }
    else
    {
        if (!_isPianyi)
        {
            [self Action_pushBrowseViewDeleteRoute];
        }
        else if(_isParkingCal)
        {
            _isParkingCal = NO;
            [MWRouteGuide StartGuide:NULL]; //modify by gzm for 目的地停车场算完路径，需要startguide，开始导航 at 2014-7-31
        }
    }
    [MWMapAddIconOperator ClearMapIcon];  //路径演算成功与否都得删除沿途搜索小红点，产品定义
    if([ANParamValue sharedInstance].isRequestParking != 2) //如果不是停车场的，就重算路径
    {
        [ANParamValue sharedInstance].isRequestParking = 1;
        //如果是偏航，则重新请求目的地停车场
        [self requestParking];
    }
    
    
    routeResult = NO;
    _isPianyi = NO;
    
}

-(void)invalidPosition
{
    [self MyalertView:STR(@"Main_PointToFar", Localize_Main) canceltext:nil othertext:STR(@"Universal_ok", Localize_Universal) alerttag:ALERT_NONE ];
}

- (void) topFacePress
{
    [_mainCruiseTopSearch hiddenFaceNew];
    [MobClick  event:UM_EVENTID_PersonalCenter_COUNT label:UM_LABEL_PersonalCenterCount];

    Plugin_Account *account = [[Plugin_Account alloc] init];
    [account enter:@{@"navigationController":self,@"loginType":@(2),@"bBack":@(0)}];
    [account release];
}

#pragma mark -
#pragma mark =====设起点，终点，途经点=====
//设起点
- (void)Action_setStart
{
    if ( [MWAdminCode checkIsExistDataWithAdmincode:0] == 0)
    {
        [self MyalertView:STR(@"Main_NoDataForCity", Localize_Main)
               canceltext:STR(@"Universal_ok", Localize_Universal)
                othertext:nil
                 alerttag:ALERT_NONE];
        return;
    }
    [MWRouteCalculate SetStartingPoint];
}
//设终点
- (void)Action_setDes
{
    if ( [MWAdminCode checkIsExistDataWithAdmincode:0] == 0)
    {
        [self MyalertView:STR(@"Main_NoDataForCity", Localize_Main)
               canceltext:STR(@"Universal_ok", Localize_Universal)
                othertext:nil
                 alerttag:ALERT_NONE];
        return;
    }
    
    if ([MWEngineTools CalculateDistance] < 150)
    {
        [QLoadingView showAlertWithoutClick:STR(@"Main_distanceTooShort", Localize_Main) ShowTime:2.0];
        return;
    }
    GMAPCENTERINFO mapinfo = {0};
    [[MWMapOperator sharedInstance] MW_GetMapViewCenterInfo:GMAP_VIEW_TYPE_MAIN mapCenterInfo:&mapinfo];
    
    GPOI PointInfo = {0};
    PointInfo.Coord = mapinfo.CenterCoord;
    GcharMemcpy(PointInfo.szName, mapinfo.szRoadName,GMAX_POI_NAME_LEN+1);
    
    [self Action_setDesWith:PointInfo poiType:GJOURNEY_GOAL];
}


//设途经点
- (void)Action_setPassBy
{
    if ([[ANParamValue sharedInstance] isPath] == NO)
    {
        return;
    }
    if ( [MWAdminCode checkIsExistDataWithAdmincode:0] == 0) {
        [self MyalertView:STR(@"Main_NoDataForCity", Localize_Main)
               canceltext:STR(@"Universal_ok", Localize_Universal)
                othertext:nil
                 alerttag:ALERT_NONE];
        return;
    }
    GMAPCENTERINFO mapinfo = {0};
    [[MWMapOperator sharedInstance] MW_GetMapViewCenterInfo:GMAP_VIEW_TYPE_MAIN mapCenterInfo:&mapinfo];
    
    GPOI PointInfo = {0};
    PointInfo.Coord = mapinfo.CenterCoord;
    GcharMemcpy(PointInfo.szName, mapinfo.szRoadName,GMAX_POI_NAME_LEN+1);
    
    [self Action_setDesWith:PointInfo poiType:GJOURNEY_VIA1];
}

//路径演算
- (void)Action_setDesWith:(GPOI)gpoi poiType:(GJOURNEYPOINTTYPE)type
{
    if (&gpoi == NULL)
    {
        return;
    }
    [MWRouteCalculate setDesWithPoi:gpoi poiType:type calType:GROU_CAL_MULTI];
}

- (void)RouteCalResult:(GSTATUS)result guideType:(long)guideType calType:(GCALROUTETYPE)calType
{
    if (YES==[[ANParamValue sharedInstance] isPath] && ([MWRouteGuide GetGuideFlags]& G_GUIDE_FLAGS_CROSSZOOM) == G_GUIDE_FLAGS_CROSSZOOM)//路径演算，关闭放大路口
    {
        GDBL_CloseZoomView();
        [self viewInCondition:87];
        [[MWMapOperator sharedInstance]MW_ShowMapView:_mapType WithParma1:0 WithParma2:0 WithParma3:0];
    }
    
    
    if (calType == GROU_CAL_MULTI)
    {
        if (result == GD_ERR_OK)
        {
            
            routeResult = YES;
            [self ProgressBarEnd];
            [[CustomRealTimeTraffic sharedInstance] updateCurrentTrafficInfo];
        }
        else if(result == GD_ERR_TOO_NEAR || result == GD_ERR_NO_DATA || result == GD_ERR_NO_ROUTE)
        {
            //返回太近的参数，不需要弹出框，内部已经弹了太近的提示，无数据和无路线也不需要提示
            [MWMapAddIconOperator ClearMapIcon];  //路径演算成功与否都得删除沿途搜索小红点，产品定义
        }
        else
        {
            routeResult = NO;
             [self ProgressBarEnd];
            //演算失败删除旧路线
            if([[ANParamValue sharedInstance] isPath])
            {
                [MWRouteGuide GuidanceOperateWithMainID:1 GuideHandle:NULL];
                [self setSwitchTripDirectFrame];
                _mapType =  GMAP_VIEW_TYPE_MAIN;
                [[MWMapOperator sharedInstance]MW_ShowMapView:_mapType WithParma1:0 WithParma2:0 WithParma3:0];
                [self reloadAllSeeButtonImage];
            }
        }
    }
    if (guideType == 2 || guideType == 7) //modify by gzm for 偏航重算,切换平行道路 2：偏航重算 7：切换平行道路 at 2014-7-23
    {
        if (result == GD_ERR_OK)
        {
            // 判断是否时路径重新计算
            routeResult = YES;
            _isPianyi = YES;
            [self ProgressBarEnd];
            GCARINFO carInfo = {0};
            GDBL_GetCarInfo(&carInfo);
            GPOI poiInfo = {0};
            poiInfo.Coord.x = carInfo.Coord.x;
            poiInfo.Coord.y = carInfo.Coord.y;
            GcharMemcpy(poiInfo.szName, carInfo.szRoadName, GMAX_POI_NAME_LEN+1);
            MWPoi *mwpoi = [MWPoi getMWPoiWithGpoi:poiInfo];
            [MWJourneyPoint AddJourneyPointWith:mwpoi type:GJOURNEY_START option:0];
            [ANParamValue sharedInstance].palellerRoadPOI = poiInfo;
            
            if ([[ANParamValue sharedInstance] isPath] )//实时交通语音播报，偏移重算后刷新实时交通
            {
                [[CustomRealTimeTraffic sharedInstance] updateCurrentTrafficInfo];
            }
        }
        else
        {
            routeResult = NO;
            [self ProgressBarEnd];
        }
        
    }
    else if(calType == GROU_CAL_SINGLE_ROUTE)
    {
        if (result == GD_ERR_OK)
        {
            //路径演算成功
            guideRouteHandle = (GHGUIDEROUTE)guideType;//路径操作句柄
            if (_avoidFlag)
            {
                _avoidFlag = NO;
                [self detourDeal:guideRouteHandle];
            }
            else
            {
                [MWRouteGuide AddGuideRoute:guideRouteHandle];//添加到路线管理列表
                [MWRouteGuide StartGuide:guideRouteHandle];
                if (_bContinueRoute) //是否为续航的路径演算
                {
                    //modify by gzm for 只在续航中调用 at 2014-10-20
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [[MWPreference sharedInstance] setValue:PREF_MAP_TMC_SHOW_OPTION Value:NO]; //解决续航时，事件显示仅在道路上
                    });
                    
                    _bContinueRoute = NO;
                    [MWRouteGuide GuidanceOperateWithMainID:0 GuideHandle:guideRouteHandle];
                    [self setSwitchTripDirectFrame];
                    [self requestParking];
                }
                else
                {
                    routeResult = YES;
                     [self ProgressBarEnd];
                }
                [[CustomRealTimeTraffic sharedInstance] updateCurrentTrafficInfo];
            }
        }
        else
        {
            routeResult = NO;
             [self ProgressBarEnd];
            
            //演算失败删除旧路线
            if([[ANParamValue sharedInstance] isPath])
            {
                [MWRouteGuide GuidanceOperateWithMainID:1 GuideHandle:NULL];
                [self setSwitchTripDirectFrame];
                _mapType =  GMAP_VIEW_TYPE_MAIN;
                [[MWMapOperator sharedInstance]MW_ShowMapView:_mapType WithParma1:0 WithParma2:0 WithParma3:0];
                [self reloadAllSeeButtonImage];
            }
        }
    }
}

- (void)detourDeal:(GHGUIDEROUTE)routeHandle
{
    // 判断是否成功
    GGUIDEROUTEINFO stGuideRouteInfo = {0};
    GSTATUS nStatus = [MWRouteGuide GetGuideRouteInfo:routeHandle routeInfo:&stGuideRouteInfo];
    if (GD_ERR_OK == nStatus && stGuideRouteInfo.bHasAvoidRoad == FALSE)
    {
        //                _isSuccessDetour = TRUE;
        nStatus = [MWRouteGuide AddGuideRoute:guideRouteHandle];//添加到路线管理列表
        nStatus = GDBL_ChangeGuideRoute(guideRouteHandle); //高亮避让后路线
       
        NSLog(@"避让");
        RouteDetourViewController *detourViewController = [[RouteDetourViewController alloc] initWithHandle:routeHandle];
        detourViewController.isDlgFromRoadList = YES;
        
        [self.navigationController pushViewController:detourViewController animated:NO];
        
        //道路名字
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
}

#pragma mark -
#pragma mark =====通知=====
- (void)listenNotification:(NSNotification *)notification
{

    if ([notification.name isEqual:NOTIFY_UPDATE_VIEWINFO]) {
        [self viewInfoInCondition:0];
    }
    if ([[ANParamValue sharedInstance] isHud] == YES)
    {
        [[ANOperateMethod sharedInstance] GMD_PassInfoToHud];
    }
    if ( self.navigationController.topViewController != self || [ANParamValue sharedInstance].beFirstNewFun == 1 || messageShareFlag)
    {
        return;
    }
	if ([notification.name isEqual:NOTIFY_SHOWMAP])
	{
        if (!isEnterNewView && !_bCanNotSwapBuffer && _mapView)
        {
            [_mapView swapBuffers];
        }
        
        if([[ANParamValue sharedInstance] isPath] == NO
           && _bottomParking.hidden == NO)
        {
            [self parkingTimeEnd];
            [ANParamValue sharedInstance].isRequestParking  = 1;
        }
        
        if ((NSFoundationVersionNumber >= NSFoundationVersionNumber_iPhoneOS_3_2) &&(GDBL_CheckRecognizeType(EVENT_PINCH) || GDBL_CheckRecognizeType(EVENT_PAN) ||  GDBL_CheckRecognizeType(EVENT_PAN_MOVE) ||GDBL_CheckRecognizeType(EVENT_ROTATE)))
        {
            timerCount = 0;
            gestureFlag = YES;
            if (moveMapTimer != nil)
            {
                [moveMapTimer invalidate];
                moveMapTimer = nil;
            }
            [self.view bringSubviewToFront:_mapView];
            
            int value = 0;
            GDBL_SetParam(G_GUIDE_SHOWLANES, &value); //modify by gzm for 移图隐藏车道信息 at 2014-10-23
            
            moveMapTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(delayShowButton:) userInfo:nil repeats:NO];
            if(_mapType == GMAP_VIEW_TYPE_MAIN)
            {
                if (popPOITimer != nil)
                {
                    [popPOITimer invalidate];
                    popPOITimer = nil;
                }
                popPOITimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(delayShowPopPOI:) userInfo:nil repeats:NO];
            }
        }
    
        if (poiDetail && ![poiDetail getHidden])
        {//poi点详细信息弹出框
            
            [poiDetail movePOIViewWithPoint];
        }
		return;
	}
	
	if ([notification.name isEqual:NOTIFY_VIEWCONDITION])
	{
		[self viewInCondition:[[ANParamValue sharedInstance] GMD_GetViewConditon]];
        
		if ([[notification.userInfo objectForKey:@"ISHV"] isEqualToString:@"YHV"])
        {
			if (Interface_Flag==0)
			{
				[self changeViewFrameWithID:0];
			}
			else
			{
				[self changeViewFrameWithID:1];
            }
        }
        if ([[notification.userInfo objectForKey:@"ISHV"] isEqualToString:@"YHV_1"])
        {
			if (Interface_Flag==0)
			{
				[self changeViewFrameWithID:0];
			}
			else
			{
				[self changeViewFrameWithID:1];
            }
            [self viewInCondition:87];
        }
	}
    if ([notification.name isEqual:NOTIFY_INVALIDPOSITION])
    {
        if (((DefineNotificationParam *)notification.object).flag == 1)
        {
            [self invalidPosition];
        }
    }
    if ([notification.name isEqual:UIApplicationDidBecomeActiveNotification])
    {
        
        //更新主界面上控件位置
        if (YES ==[[ANParamValue sharedInstance] isInit])
        {
            if (Interface_Flag == 0)
            {
                [self changePortraitControlFrameWithImage];
            }
            else if(Interface_Flag == 1)
            {
                [self changeLandscapeControlFrameWithImage];
            }
        }
    }
    
}

- (void)EnterForegroundNotification:(NSNotification *)notification
{
    NSLog(@"%d",[[UIApplication sharedApplication] applicationState]);
    if (self.navigationController.topViewController != self) {
        return;
    }
    [[MWMapOperator sharedInstance] MW_ShowMapView:_mapType WithParma1:0 WithParma2:0 WithParma3:0];
    return;
}

- (void)routeListenNotification:(NSNotification *)notification {
	
	
   
}

-(void)doWhenPoiListNotification:(NSNotification *)notification
{
	if ( self.navigationController.topViewController == self)
	{
		
        switch (((DefineNotificationParam *)notification.object).flag)
        {
         
                
            default:
			{
				
			}
                break;
        }
    }
}

- (void)poilistenNotification:(NSNotification *)notification
{
    [self performSelectorOnMainThread:@selector(doWhenPoiListNotification:) withObject:notification waitUntilDone:YES];
}

- (void)ShowMapDelay
{
    // 为该方法添加判断，避免进入全程概览地图绘制错误
    if (self.navigationController.topViewController == self) {
        [[MWMapOperator sharedInstance] MW_ShowMapView:_mapType WithParma1:0 WithParma2:0 WithParma3:0];
        
    }
}

-(void)enterCityDataDownloadModule:(NSNotification *)downState
{
	int tmp = [[downState object] intValue];
    CityDownLoadModule *tmpObject = [[CityDownLoadModule alloc] init];
	id<ModuleDelegate> module = tmpObject;
	NSDictionary *param;
	if (tmp  == 0)
	{
		param  = [[NSDictionary alloc] initWithObjectsAndKeys:self.navigationController,@"controller",@"NoData",@"parma",nil];
	}
	else if(tmp ==1)
	{
		param  = [[NSDictionary alloc] initWithObjectsAndKeys:self.navigationController,@"controller",@"HasData",@"parma",nil];
	}
    
    else{
        param  = [[NSDictionary alloc] initWithObjectsAndKeys:self.navigationController,@"controller",@"updateAllData",@"parma",nil];
    }
	[module enter:param];
	[param release];
	[tmpObject release];
}

- (void)PalellerRoadNotification:(NSNotification *)notification {
    
    if ( self.navigationController.topViewController != self)
    {
        return;
    }
    //add by gzm for 无路径情况下主辅路切换按钮不显示 at 2014.8.1
    long isPath = 0;
    GDBL_GetParam(G_GUIDE_STATUS, &isPath);
    if (isPath == 0) {
        [_mainOtherObject setParallelRoadHidden:YES];
        parallelFlag = NO;
        return;
    }
    NSArray *result = [notification object];
    if ([[result objectAtIndex:0] intValue] == 1) {//有平行道路
        palellerRoadArray = [MWRouteCalculate GetCarParallelRoads];
        if ([palellerRoadArray count] > 0) {
            [_mainOtherObject setParallelRoadHidden:NO];
            parallelFlag = YES;
        }
        
    }
    else if([[result objectAtIndex:0] intValue] == 0){//无平行道路
        [_mainOtherObject setParallelRoadHidden:YES];
        parallelFlag = NO;
    }
}

#pragma mark -
#pragma mark =添加到摄像头，地址铺，设为家，公司，回家，回公司，打开关闭轨迹纪录，实时路况=
//添加到地址铺
-(void)Action_saveFavPOI
{
    GSTATUS res;
    
    if(res == GD_ERR_OK) {
        [QLoadingView showAlertWithoutClick:STR(@"Universal_hadCollect", Localize_Universal) ShowTime:2.0];
    }
    else if(res == GD_ERR_DUPLICATE_DATA)
    {
        [QLoadingView showAlertWithoutClick:STR(@"Universal_youHadCollect", Localize_Universal) ShowTime:2.0];
        
    }
    else
    {
        [QLoadingView showAlertWithoutClick:STR(@"Universal_failCollect", Localize_Universal) ShowTime:2.0];
    }
    [[MWMapOperator sharedInstance] MW_ShowMapView:_mapType WithParma1:0 WithParma2:0 WithParma3:0];
}

//实时路况
-(void)Real_Traffic_Action
{
    
    if ( [MWAdminCode checkIsExistDataWithAdmincode:0] == 0) {
        [self MyalertView:STR(@"Main_NoDataForCity", Localize_Main)
               canceltext:STR(@"Universal_ok", Localize_Universal)
                othertext:nil
                 alerttag:ALERT_NONE];
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
#pragma mark GPS委托

-(void)GPSSuccess:(GGPSINFOEX )gpsInfo newLocation:(CLLocation *)newLocation oldLocation:(CLLocation *)oldLocation
{
    dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{//耗时的工作放到其他线程里面
        
        [[ANOperateMethod sharedInstance] GMD_MileageCalculateWithNewLocation:newLocation oldLocation:oldLocation];//里程计算
        [[DringTracksManage sharedInstance] drivingTrackCalculateWithNewLocation:newLocation oldLocation:oldLocation andType:TrackCountType_Normal];
    });
    
    
    GCOORD tmpValue;
    tmpValue.x = gpsInfo.lLon;//保存定位点
    tmpValue.y = gpsInfo.lLat;//保存定位点
    [ANParamValue sharedInstance].curGPSCoord = tmpValue;
    
    static int static_isCheckMapData = 51;
    if(static_isCheckMapData > 0)
    {
        [self setButtonTipsView:[CheckMapDataObject CheckMapData]];
        static_isCheckMapData--;
    }
    
    //如果速度大于10km/h,则开启pcd
//    GGPSINFO pGpsInfo1 = {0};
//    GDBL_GetGPSInfo(&pGpsInfo1);
//    if (pGpsInfo1.nSpeed > 10) {
//        int value = 1;
//        GDBL_SetParam(G_FUNCTION_SUPPORT_PCD, &value);
//    }
}
-(void)GPSFail:(NSError *)error
{
    if(error.code == 360 && self.navigationController.visibleViewController == self)
    {
        static int j = 0;
        if (0 == j) {
            j++;
            [self MyalertView:STR(@"Main_overGPS", Localize_Main) canceltext:STR(@"Universal_ok", Localize_Universal) othertext:nil alerttag:ALERT_NONE];
        }
        
    }
    else
    {
        
        if (error.code == 41)//容错处理
        {
            
            if (self.navigationController.topViewController == self)
            {
                [[MWMapOperator sharedInstance] MW_ShowMapView:_mapType WithParma1:0 WithParma2:0 WithParma3:0];
            }
            return;
        }
        static int i = 0;
        if (i == 0/* && (self.navigationController.visibleViewController == self)*/)
        {
            i++;
            [self MyalertView:STR(@"Main_OpenGPS", Localize_Main) canceltext:STR(@"Universal_ok", Localize_Universal) othertext:nil alerttag:ALERT_NONE];
            
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
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	timerCount = 0;
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_TOUCH object:[NSNumber numberWithBool:NO]];
	switch (alertView.tag)
	{
		case ALERT_ANTONAVI_SEARVICES:
		{
			switch (buttonIndex)
			{
					
				case 0:
				{
					
				}
					break;
					
                default:
					break;
			}
		}
			break;
        case ALERT_LIFT://续航
		{
			switch (buttonIndex)
			{
					
				case 0:
				{
                    if ([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%s",route_path]])
                    {
                        [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%s",route_path] error:nil];
                        
                    }
                    [MWRouteDetour ClearDetourRoad];
				}
					break;
					
				case 1:
				{
                    [self.navigationController popToRootViewControllerAnimated:NO];//add by hlf for 主界面同时弹出续航提示框和地图数据升级提示框，如果用户点击升级地图进入下载页面，再点击续航，需返回主界面，要不回到主界面，界面显示会异常 at 2014.08.07
                    
                    BOOL res;
                    _reloadSwitchFrame = YES;
                    
                    NSString *str_path = [NSString stringWithUTF8String:route_path];
                    res = [MWRouteGuide LoadGuideRoute:str_path];
                    if (res == GD_ERR_OK)
                    {
                        _bContinueRoute = YES;
                        [MWRouteCalculate StartRouteCalculation:GROU_CAL_SINGLE_ROUTE];
                    }

				}
					break;
                default:
					break;
			}
		}
			break;
        case ALERT_NONE://不需要操作，设置为此值
		{
			
		}
			break;
			
		case ALERT_SET_HOME://还未设置家地址
		{
			[alertView dismissWithClickedButtonIndex:1 animated:NO];
        }
			break;
			
		case ALERT_SET_COMPANY://还未设置公司地址
		{
			[alertView dismissWithClickedButtonIndex:1 animated:NO];
        }
			break;
			
		case ALERT_RESET_HOME://重新设置家地址
		{
			
			switch (buttonIndex)
			{
				case 0:
				{
					
				}
					break;
				case 1:
				{
					
				}
					break;
                    
				default:
					break;
			}
		}
			break;
		case ALERT_RESET_COMPANY://重新设置公司地址
		{
			
			switch (buttonIndex)
			{
				case 0:
				{
					
				}
					break;
				case 1:
				{
					
				}
					break;
					
				default:
					break;
			}
		}
			break;
            
            
        case ALERT_STOPSIMULATOR:
		{
            switch (buttonIndex)
			{
                case 0:
                {
                    [self viewInfoInCondition:0];
                }
                    break;
				case 1://停止
				{

                    
                    [self Action_cancelNearBy];
                    _reloadSwitchFrame = YES;   //停止导航，重新设置指南针按钮方向
                    if(_bOverView) //如果存在全览，则删除路径线
                    {
                        [self closeAllSeeWithAnimated:YES];
                    }

					[MWRouteGuide GuidanceOperateWithMainID:1 GuideHandle:NULL];
                    
                    [GDMenu dismissMenu];//add by hlf for 同时点击gdmenu和停止导航按钮。点击停止，gdmenu还显示的问题。2013.12.15
                    [self setSwitchTripDirectFrame];
                    [self parkingTimeEnd];
                    [ANParamValue sharedInstance].isRequestParking = 1;
                    [self reloadAllSeeButtonImage];
                    //隐藏无数据提醒框
                    [self setButtonTipsView:[CheckMapDataObject CheckMapData]];
				}
					break;
					
				default:
					break;
			}
            
        }
			break;
            
        case ALERT_FIRST_START:
        {
            if(buttonIndex == 0)
            {
                /*
                 SetUpView *SetUpView_Controller = [[SetUpView alloc] initWithStyle:UITableViewStyleGrouped];
                 [[self navigationController] pushViewController:SetUpView_Controller animated:YES];
                 [SetUpView_Controller release];
                 */
            }
        }
            break;
		default:
			break;
	}
}
//主辅路切换
-(void)PalellerRoadActionSheet
{
    static int palallerID = 0;
    palellerRoadArray = [MWRouteCalculate GetCarParallelRoads];
    if ([palellerRoadArray count] > 0 )
    {
        if (palallerID < [palellerRoadArray count]) {
            plugin_PoiNode *item  = [palellerRoadArray objectAtIndex:palallerID];
            GOBJECTID objectid = item.stPoiId;
            GSTATUS res = [MWRouteCalculate ChangeCarRoad:&objectid];
            if (res != GD_ERR_OK)
            {
                [_mainOtherObject setParallelRoadHidden:YES];
                parallelFlag = NO;
            }
        }
        else {
            palallerID = 0;
            plugin_PoiNode *item  = [palellerRoadArray objectAtIndex:palallerID];
            GOBJECTID objectid = item.stPoiId;
            GSTATUS res = [MWRouteCalculate ChangeCarRoad:&objectid];
            if (res != GD_ERR_OK)
            {
                [_mainOtherObject setParallelRoadHidden:YES];
                parallelFlag = NO;
            }
        }
        palallerID ++;
    }
}


- (void)dismiss_Alart:(id)sender {
	
	UIButton *b = (UIButton *)sender;
	UIAlertView *Alert = (UIAlertView *)b.tag;
	[Alert dismissWithClickedButtonIndex:0 animated:YES];
}
#pragma mark 短信分享委托
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
	
    switch (result)
    {
        case MessageComposeResultSent:
            break;
			
        case MessageComposeResultFailed:
            break;
			
        default:
            break;
    }
	messageShareFlag = NO;
    [controller dismissModalViewControllerAnimated:YES];
}

#pragma mark =========================================================
#pragma mark Touch
#pragma mark =========================================================


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (poiDetail && ![poiDetail getHidden]) {
        [poiDetail setHidden:YES];
    }
	[self viewInCondition:84];
    if (YES==[[ANParamValue sharedInstance] isPath] &&
        ([MWRouteGuide GetGuideFlags]& G_GUIDE_FLAGS_CROSSZOOM) == G_GUIDE_FLAGS_CROSSZOOM) //放大路口
    {
        GDBL_CloseZoomView();//隐藏放大路口
        [self viewInCondition:87];
        [[MWMapOperator sharedInstance] MW_ShowMapView:_mapType WithParma1:0 WithParma2:0 WithParma3:0];

        
    }
    if ([MWRouteGuide GetGuideFlags] == G_GUIDE_FLAGS_GUIDEPOST)
    {//高速路牌
        [[MWPreference sharedInstance] setValue:PREF_MAP_SHOW_GUIDEPOST Value:NO];//隐藏高速路牌
        [[MWMapOperator sharedInstance] MW_ShowMapView:_mapType WithParma1:0 WithParma2:0 WithParma3:0];
        [_mainOtherObject setGuidePostHidden:NO];
    }
    else{
        [_mainOtherObject setGuidePostHidden:YES];
    }
	timerCount = 0;
    
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
    [poiShowObject cancel];
	[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_TOUCH object:[NSNumber numberWithBool:NO]];
}


- (void)dispatchFirstTouchAtPoint:(CGPoint)firstTouchPoint secondTouchAtPoint:(CGPoint)touchPoint {
	
	if (YES==[[ANParamValue sharedInstance] isNavi])
	{
		return;
	}
	
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
		NSLog(@"%d %d",dX,dY);
        GMOVEMAP moveMap;
        moveMap.eOP = MOVEMAP_OP_DRAG;
        moveMap.deltaCoord.x = -dX;
        moveMap.deltaCoord.y = -dY;
		[[MWMapOperator sharedInstance] MW_MoveMapView:GMAP_VIEW_TYPE_MAIN TypeAndCoord:&moveMap];
	}
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	
	timerCount = 0;
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


#pragma mark- 弹出框按钮响应
- (void)GDPopViewTaped:(id)sender POI:(MWPoi *)poi
{
    
    UIButton *button=(UIButton*)sender;
    switch (button.tag) {
        case ViewPOIButtonType_collect:
        {
            BOOL isSuccess;
            if ([poi isMemberOfClass:[MWFavoritePoi class]]) {
                isSuccess= [MWPoiOperator reverseCollectPoi:(MWFavoritePoi*)poi];
                NSLog(@"isSuccess =%i",isSuccess);
                if (isSuccess) {
                    poiDetail.favoriteState=!poiDetail.favoriteState;
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
                    poiDetail.favoriteState=!poiDetail.favoriteState;
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
                    poiDetail.favoriteState=!poiDetail.favoriteState;
                }
                [favoritePoi release];
                
                
            }
            if (isSuccess) {
                if(poiDetail.favoriteState == 0)
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
            
        case ViewPOIButtonType_setDes:
        {
            [MobClick event:UM_EVENTID_NAVI_COUNT label:UM_LABEL_NAVI_FROM_POI_DETAIL];
            GPOI mPOI = {0};
            mPOI.lCategoryID = poi.lCategoryID;
            mPOI.lNaviLon = poi.lNaviLon;
            mPOI.lNaviLat = poi.lNaviLat;
            GcharMemcpy(mPOI.szName, NSStringToGchar(poi.szName), GMAX_POI_NAME_LEN+1);
           //modify by wws for 解决移图设置终点 历史目的地没有地址 at 2017-7-31
            GcharMemcpy(mPOI.szAddr, NSStringToGchar(poi.szAddr), GMAX_POI_ADDR_LEN+1);
            mPOI.lAdminCode = poi.lAdminCode;
            
            mPOI.Coord.x = poi.longitude;
            mPOI.Coord.y = poi.latitude;
            if ([MWEngineTools CalculateDistance] < 150)
            {
                [QLoadingView showAlertWithoutClick:STR(@"Main_distanceTooShort", Localize_Main) ShowTime:2.0];
                return;
            }
             [self Action_setDesWith:mPOI poiType:GJOURNEY_GOAL];
            
        }
            break;
        case ViewPOIButtonType_selectPOISetDes:
        case ViewPOIButtonType_desAroundSetDes:
        {
            _isParkingCal = YES;
            [MobClick event:UM_EVENTID_NAVI_COUNT label:UM_LABEL_NAVI_FROM_POI_DETAIL];
            _isPianyi = YES;
            
            NSMutableArray * array = [MWJourneyPoint GetJourneyPointArray];
            [array replaceObjectAtIndex:(array.count - 1) withObject:poi];

            //modify by gzm for 使用车位经纬度作为起点 at 2014-9-23
            GCARINFO pCarInfo = {0};
            GSTATUS res = [[MWMapOperator sharedInstance] GMD_GetCarInfo:&pCarInfo];
            if (res == GD_ERR_OK)
            {
                MWPoi *startpoi = [array caObjectsAtIndex:0];
                startpoi.longitude = pCarInfo.Coord.x;
                startpoi.latitude = pCarInfo.Coord.y;
                startpoi.lNaviLon = 0;
                startpoi.lNaviLat = 0;
            }
            //modify by gzm for 使用车位经纬度作为起点 at 2014-9-23
            
            [MWRouteCalculate wayPointCalcRoute:array bResetCarPosition:NO];
            
            [self parkingTimeEnd];
            [ANParamValue sharedInstance].isRequestParking = 2;
            [self Action_GoToCCP];
            [MWMapAddIconOperator ClearMapIcon];
            [[MWMapOperator sharedInstance] MW_ShowMapView:_mapType WithParma1:0 WithParma2:0 WithParma3:0];
        }
            break;
        case ViewPOIButtonType_around:
        {

            if ( [MWAdminCode checkIsExistDataWithAdmincode:0] == 0) {
                GDAlertView *alertView = [[[GDAlertView alloc] initWithTitle:nil andMessage:STR(@"Main_NoDataForCity", Localize_Main)] autorelease];
                [alertView addButtonWithTitle:STR(@"Universal_ok", Localize_Universal) type:GDAlertViewButtonTypeCancel handler:nil];
                [alertView show];
                return;
            }
            [[PluginStrategy sharedInstance] allocModuleWithName:@"Plugin_POI" withObject:@{POI_NAVIGATIONCONTROLLER:self.navigationController,POI_TYPE:@(1)}];
            
            
        }
            break;
        case ViewPOIButtonType_more:
        {
            POIDetailViewController *detailViewController = [[POIDetailViewController alloc] initWithPOI:poi];
            [self.navigationController pushViewController:detailViewController animated:YES];
            [detailViewController release];
            
        }
            break;
        case ViewPOIButtonType_passBy:
        {
            if([[ANParamValue sharedInstance] isPath])
            {
                NSMutableArray * array = [MWJourneyPoint GetJourneyPointArray];
                if (array.count>=7) {
                    [self createAlertViewWithTitle:nil
                                           message:STR(@"Route_mostFive", Localize_RouteOverview)
                                 cancelButtonTitle:STR(@"Main_back", Localize_Main)
                                 otherButtonTitles:nil
                                               tag:EVENT_NONE];
                }else
                {
                    [array insertObject:poi atIndex:array.count-1];
                    Plugin_POI * enterPoi  = [[Plugin_POI alloc]init];
                    NSMutableDictionary * dic = [[NSMutableDictionary alloc]init];
                    [dic setObject:@"0" forKey:POI_TYPE];
                    [dic setObject:array forKey:POI_Array];
                    [dic setObject:@"3" forKey:POI_WhereGo];
                    [dic setObject:self.navigationController forKey:POI_NAVIGATIONCONTROLLER];
                    [enterPoi enter:dic];
                    [enterPoi release];
                    [dic release];
                }
            }
        }
            break;
        case ViewPOIButtonType_avoidRoute:
        {
            //add by gzm for 避让前先恢复全览视图至主视图，防止进入避让界面异常 at 2014-7-28
            [self closeAllSeeWithAnimated:NO];
            GDBL_ClearDetourRoad();
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
            break;
            
        default:
            break;
    }
}

- (void) showPopPoi:(NSString *)avoidString Lon:(int)lon Lat:(int)lat
{
    if (_eventInfo->nEventID == 0) {
        return;
    }
    
    
    MWPoi *tempPoi = [[MWPoi alloc] init];
    tempPoi.szAddr = avoidString;
    NSString *streamType;
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
    NSString  *disFromCar = @"";
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
    }else{
        disFromCar = [NSString stringWithFormat:@"%.f%@", fDistance,STR(@"Universal_M", Localize_Universal)];
    }
    
    tempPoi.szName = streamType;
    tempPoi.szTown = disFromCar;
    tempPoi.usNodeId = type;
    tempPoi.longitude = lon;
    tempPoi.latitude = lat;
    
    [poiDetail setPopPOIType:ViewPOIType_Traffic];
    [poiDetail  setStringAtPos:tempPoi withMapType:_mapType];
    [poiDetail startAnimate:0.3];
    [poiDetail setHidden:NO];
    [tempPoi release];
}

-(void) RouteYaw
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    if([ud objectForKey:USERDEFAULT_LoaclRecalculationRoute])
    {
        [ud setObject:[NSNumber numberWithInt:0] forKey:USERDEFAULT_LoaclRecalculationRoute];
    }
    int routeRecalCount = [[ud objectForKey:USERDEFAULT_LoaclRecalculationRoute] intValue];
    routeRecalCount++;
    [ud setObject:[NSNumber numberWithInt:routeRecalCount] forKey:USERDEFAULT_LoaclRecalculationRoute];
    
    //统计驾驶轨迹偏航次数
    GCARINFO carInfo = {0};
    [[MWMapOperator sharedInstance] GMD_GetCarInfo:&carInfo];
    
    [[DringTracksManage sharedInstance] addYawInfoWithLon:carInfo.Coord.x Lat:carInfo.Coord.y];
}

#pragma mark PaintingViewDelagate
-(void)mapView:(PaintingView *)mapView GestureRecognizer:(UIGestureRecognizer *)recognizer gestureType:(RECOGNIZETYPE)gesturetype  withParam:(int)param
{
    
    switch (gesturetype) {
        case EVENT_PINCH:
        {
            [MobClick event:UM_EVENTID_ZOOM_COUNT label:UM_LABEL_ZOOM_FROM_GESTURE];
            int isPath = 0;
            GDBL_GetParam(G_GUIDE_STATUS, &isPath);
        }
            break;
        case EVENT_TAP_DOUBLE:
        {
            [MobClick event:UM_EVENTID_ZOOM_COUNT label:UM_LABEL_ZOOM_FROM_GESTURE];
            int isPath = 0;
            GDBL_GetParam(G_GUIDE_STATUS, &isPath);
            
        }
            break;
        case EVENT_DOUBLE_FINGER_TAP:
        {
            [MobClick event:UM_EVENTID_ZOOM_COUNT label:UM_LABEL_ZOOM_FROM_GESTURE];
            int isPath = 0;
            GDBL_GetParam(G_GUIDE_STATUS, &isPath);
        }
            break;
        case EVENT_LONGPRESS:
        {
            if (recognizer.state == UIGestureRecognizerStateBegan)
            {
                if ([[MWPreference sharedInstance] getValue:PREF_AUTO_GETPOIINFO]) {
                    return;
                }
                if((![[ANParamValue sharedInstance] isPath]
                   || ([[ANParamValue sharedInstance] isPath]))
                   && _mapType == GMAP_VIEW_TYPE_MAIN)
                {
                    [poiDetail setHidden:YES];
                    
                    CGPoint myPoint = [recognizer locationInView:recognizer.view];
                    
                    GFCOORD scrCoord = {0};
                    scrCoord.x = myPoint.x*[ANParamValue sharedInstance].scaleFactor;
                    scrCoord.y = myPoint.y*[ANParamValue sharedInstance].scaleFactor;
                    GCOORD gcoord = [MWEngineTools ScrToGeo:scrCoord];

                    if([ANParamValue sharedInstance].isPath)
                    {
                        timerCount = 0;
                        poiShowObject.poiType  = ViewPOIType_passBy;
                    }
                    else
                    {
                        poiShowObject.poiType  = ViewPOIType_Detail;
                    }
                    
                    poiShowObject.popPoi = poiDetail;
                    poiShowObject.coord = gcoord;
                    [poiShowObject show];
                }
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
            //add by gzm for 无移图，无路径下，点击地图，需将车位按钮显示 at 2014-7-26
            if (!([ANParamValue sharedInstance].isMove || [ANParamValue sharedInstance].isPath))
            {
                _buttonGetPOIInfo.hidden = NO;
            }
            //add by gzm for 无移图，无路径下，点击地图，需将车位按钮显示 at 2014-7-26
            
            [poiDetail setHidden:YES];
            if (popPOITimer != nil)
            {
                [popPOITimer invalidate];
                popPOITimer = nil;
                return;
            }
            if ([poiDetail getShowState])
            {
                return;
            }
            //点击事件图标
            if(![[ANParamValue sharedInstance] isNavi])
            {
                CGPoint mPoint = [recognizer locationInView:recognizer.view];
                int iconTouchNumber = 0;
                int routeTouchNumber = -1;
                
                NSString *avoidString = [MWRouteGuide guideRouteAndIconTouch:GMAP_VIEW_TYPE_MAIN TouchPoint:mPoint
                                                                                            Elements:&_eventInfo
                                                                                         EventNumber:&iconTouchNumber
                                                                                    TouchRouteNumber:&routeTouchNumber];
                if (iconTouchNumber > 0)
                {
                    int lon,lat;
                    lon = _eventInfo->stPosition.x;
                    lat = _eventInfo->stPosition.y;
                    
                    timerCount = 0;
                    [self showPopPoi:avoidString Lon:lon Lat:lat];
                    return;
                }
                MWPoi *hitPoi = [MWMapOperator getMapPoiByHitPoint:mPoint];
                if (hitPoi)
                {
                    if([ANParamValue sharedInstance].isPath)
                    {
                        [poiDetail setPopPOIType:ViewPOIType_passBy];
                    }
                    else
                    {
                        [poiDetail setPopPOIType:ViewPOIType_Detail];
                    }
                    [poiDetail setStringAtPos:hitPoi withMapType:_mapType];
                    [poiDetail startAnimate:0.3];
                    [poiDetail setHidden:NO];
                    return;
                }
            }
           
            
        }
            break;
        default:
            break;
    }
    
}

//左右滑动手势
-(void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer{
    int index = 0;
    NSMutableArray *listArray = [NSMutableArray arrayWithCapacity:0];
    GHGUIDEROUTE routeList[4] = {0};
    int count = 0;
    GSTATUS nStatus = [MWRouteGuide GetGuideRouteList:routeList count:4 returnCount:&count];

    if(nStatus == GD_ERR_OK)
    {
        ManeuverInfoList *list = [MWRouteGuide GetManeuverTextList:routeList[0]];
        NSArray *arrayList = list.pManeuverText;
        for (int i = 0 ; i < arrayList.count; i++)
        {
            ManeuverInfo *info = ((ManeuverInfo *)[ arrayList objectAtIndex:i]);
            if((info.eFlag & 0x04))
            {
                index = ((listArray.count - 1) > -1 ) ? listArray.count - 1 : 0;
                //如果是主要道路，则先进行++，才是当前的
                index ++;
            }
            if(info.nNumberOfSubManeuver > 0)
            {
                for (int j = 0 ; j < info.nNumberOfSubManeuver; j++)
                {
                    ManeuverInfo *info1 = ((ManeuverInfo *)[info.pstSubManeuverText objectAtIndex:j]);
                    [listArray addObject:info1];
                    NSLog(@"info1 : %@ # %@",info1.currentLoadName,info1.nextLoadName);
                    if((info1.eFlag & 0x04))
                    {
                        index = listArray.count - 1;
                    }
                }
            }
            else
            {
                [listArray addObject:info];
                NSLog(@"info : %@ # %@",info.currentLoadName,info.nextLoadName);
            }

        }
    }
    else
    {
        return;
    }
    
    
    if(![[ANParamValue sharedInstance] isNavi])
    {
        if(recognizer.direction==UISwipeGestureRecognizerDirectionLeft)
        {
            index++;
            if(index >=  listArray.count || index < 0)
            {
                index = listArray.count - 1;
            }
            NSLog(@"swipe left");
            RoutePointViewController *viewController = [[RoutePointViewController alloc]initWithArry:listArray withIndex:index];
            [self.navigationController pushViewController:viewController animated:NO];
            viewController.pointType = FROM_MAINVIEW;
            [viewController release];
            //执行程序
            
        }
        
        if(recognizer.direction==UISwipeGestureRecognizerDirectionRight)
        {
            if(index - 1 < 0 || index >= listArray.count)
            {
                index = 0;
            }
            else
            {
                index--;
            }
            NSLog(@"swipe right");
            //
            //                CATransition *transition = [CATransition animation];
            //
            //                transition.duration = 0.5f;
            //
            //                transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
            //
            //                transition.type = @"push";
            //                //@"cube" @"moveIn" @"reveal" @"fade"(default) @"pageCurl" @"pageUnCurl" @"suckEffect" @"rippleEffect" @"oglFlip" @“twist”
            //
            //                transition.subtype = kCATransitionFromLeft;
            //                [self.navigationController.view.layer addAnimation:transition forKey:nil];
            
            RoutePointViewController *viewController = [[RoutePointViewController alloc]initWithArry:listArray
                                                                                           withIndex:index];
            [self.navigationController pushViewController:viewController animated:NO];
            viewController.pointType = FROM_MAINVIEW;
            [viewController release];
            //执行程序
            
        }
    }

}
//点击手势
- (void)handleTapFrom:(UITapGestureRecognizer *)tap
{
    if(![[ANParamValue sharedInstance] isNavi])
    {
        [self pushPlanningAndDetailViewControllerDeleteRoute:NO withAnimated:NO];
    }
}

#pragma mark -
#pragma ---  模拟导航  ---
//开始模拟导航
- (void)Action_simulatorNavi_Start
{
//    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(delaySimNav:) userInfo:nil repeats:NO];
    [self delaySimNav:nil];
    [_mapView  setRecognizeSwitchOn:EVENT_PINCH | EVENT_SWIP | EVENT_TAP_DOUBLE | EVENT_DOUBLE_FINGER_TAP];
    _simPlayOrPause = 0;
    [_mainSimBottomObject setSimPlayImage:NO];
    [self buttonShowStatus:0];//用于控制模拟导航加速和减速的灰化
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_TOUCH object:[NSNumber numberWithBool:NO]];
    [self Action_cancelNearBy];
}
//停止模拟导航
- (void)Action_simulatorNavi_Stop
{
    GSTATUS res = [MWRouteDemo StopDemo];
    if (res == GD_ERR_OK)
    {
        [MWRouteGuide StartGuide:NULL];  //结束模拟导航时，需要调用开始导航
    }
    [_mapView setRecognizeSwitchOn:EVENT_NONE];
    _simPlayOrPause = -2;
    [_mainSimBottomObject setSimPlayImage:NO];
    if([ANParamValue sharedInstance].isRequestParking  != 2)
    {
        [ANParamValue sharedInstance].isRequestParking = 1;
    }
    [self requestParking];
    
    [self OverSpeedHidden:YES];
}
//模拟导航－暂停－继续
- (void)Action_simulatorNavi_Pause_Continue
{
    GSTATUS res ;
    if (_simPlayOrPause == 1 || _simPlayOrPause == -2)
    {
        if(_simPlayOrPause == -2)
        {
            res = [MWRouteDemo StartDemo];
        }
        else
        {
            res = [MWRouteDemo ContinueDemo];
        }
        if (GD_ERR_OK != res)
        {
            return;
        }
        [_mainSimBottomObject setSimPlayImage:NO];
        [self viewInCondition:87];
        _simPlayOrPause = 0;
    }
    else
    {
        res = [MWRouteDemo PauseDemo];
        if (GD_ERR_OK != res)
        {
            return;
        }
        [_mainSimBottomObject setSimPlayImage:YES];
        _simPlayOrPause = 1;
    }
}

- (void)Action_simuSpeedLow
{
    int speed = SIM_LOW_SPEED;
    [[MWPreference sharedInstance] setValue:PREF_DEMOMODE Value:0];
    [[MWPreference sharedInstance] setValue:PREF_DEMO_SPEED Value:speed];
    [_mainSimBottomObject setSelectTitle:STR(@"Main_low", Localize_Main) ];
}

- (void)Action_simuSpeedNormal
{
    int speed = SIM_MID_SPEED;
    [[MWPreference sharedInstance] setValue:PREF_DEMOMODE Value:0];
    [[MWPreference sharedInstance] setValue:PREF_DEMO_SPEED Value:speed];
     [_mainSimBottomObject setSelectTitle:STR(@"Main_normal", Localize_Main) ];
}

- (void)Action_simuSpeedHight
{
    int speed = SIM_HIGH_SPEED;
    [[MWPreference sharedInstance] setValue:PREF_DEMOMODE Value:0];
    [[MWPreference sharedInstance] setValue:PREF_DEMO_SPEED Value:speed];
    [_mainSimBottomObject setSelectTitle:STR(@"Main_hight", Localize_Main) ];
}

- (void) Action_simuSpeedJump
{
     [[MWPreference sharedInstance] setValue:PREF_DEMOMODE Value:1];
     [_mainSimBottomObject setSelectTitle:STR(@"Main_jump", Localize_Main) ];
}


-(void)buttonShowStatus:(int)status
{
    switch (status)
    {
        case 0://用于控制模拟导航加速和减速的灰化
        {
            int eDemoSpeed = 0;
            eDemoSpeed = [[MWPreference sharedInstance] getValue:PREF_DEMO_SPEED];
        }
            break;
            
        default:
            break;
    }
}



- (void) selectSimuSpeed
{
    UIImage *imageLOW,*imageNormal,*imageHIGH,*imageJUMP;
    int demoType = 0;
    demoType = [[MWPreference sharedInstance] getValue:PREF_DEMOMODE];
    int eDemoSpeed = 0;
    eDemoSpeed = [[MWPreference sharedInstance] getValue:PREF_DEMO_SPEED];
    if(demoType == 0)
    {
        if (eDemoSpeed == SIM_LOW_SPEED) {
            imageLOW = IMAGE(@"mainSimuSpeed2.png", IMAGEPATH_TYPE_1);
            imageNormal = IMAGE(@"mainSimuSpeed1.png", IMAGEPATH_TYPE_1);
            imageHIGH = IMAGE(@"mainSimuSpeed1.png", IMAGEPATH_TYPE_1);
            imageJUMP = IMAGE(@"mainSimuSpeed1.png", IMAGEPATH_TYPE_1);
            [_mainSimBottomObject setSelectTitle:STR(@"Main_low", Localize_Main)];
        }
        else if(eDemoSpeed == SIM_MID_SPEED)
        {
            imageLOW = IMAGE(@"mainSimuSpeed1.png", IMAGEPATH_TYPE_1);
            imageNormal = IMAGE(@"mainSimuSpeed2.png", IMAGEPATH_TYPE_1);
            imageHIGH = IMAGE(@"mainSimuSpeed1.png", IMAGEPATH_TYPE_1);
            imageJUMP = IMAGE(@"mainSimuSpeed1.png", IMAGEPATH_TYPE_1);
            [_mainSimBottomObject setSelectTitle:STR(@"Main_normal", Localize_Main)];
            
        }
        else
        {
            imageLOW = IMAGE(@"mainSimuSpeed1.png", IMAGEPATH_TYPE_1);
            imageNormal = IMAGE(@"mainSimuSpeed1.png", IMAGEPATH_TYPE_1);
            imageHIGH = IMAGE(@"mainSimuSpeed2.png", IMAGEPATH_TYPE_1);
            imageJUMP = IMAGE(@"mainSimuSpeed1.png", IMAGEPATH_TYPE_1);
            [_mainSimBottomObject setSelectTitle:STR(@"Main_hight", Localize_Main)];
        }
    }
    else
    {
        imageLOW = IMAGE(@"mainSimuSpeed1.png", IMAGEPATH_TYPE_1);
        imageNormal = IMAGE(@"mainSimuSpeed1.png", IMAGEPATH_TYPE_1);
        imageHIGH = IMAGE(@"mainSimuSpeed1.png", IMAGEPATH_TYPE_1);
        imageJUMP = IMAGE(@"mainSimuSpeed2.png", IMAGEPATH_TYPE_1);
        [_mainSimBottomObject setSelectTitle:STR(@"Main_jump", Localize_Main)];
    }
    NSArray *menuItems =  @[ [GDMenuItem menuItem:STR(@"Main_low", Localize_Main) image:imageLOW
                                           target:self action:@selector(Action_simuSpeedLow)],//"低速"
                             [GDMenuItem menuItem:STR(@"Main_normal", Localize_Main) image:imageNormal
                                           target:self  action:@selector(Action_simuSpeedNormal)],//"中速"
                             [GDMenuItem menuItem:STR(@"Main_hight", Localize_Main) image:imageHIGH
                                           target:self  action:@selector(Action_simuSpeedHight)],//"高速“
                             [GDMenuItem menuItem:STR(@"Main_jump", Localize_Main) image:imageJUMP
                                           target:self  action:@selector(Action_simuSpeedJump)],//"跳跃“
                             ];

    CGRect rect = CGRectMake(_mainSimBottomObject.getSelectRect.origin.x + _mainSimBottomObject.viewSimuBG.frame.origin.x,
                             _mainSimBottomObject.viewSimuBG.frame.origin.y,
                             _mainSimBottomObject.getSelectRect.size.width,
                             _mainSimBottomObject.getSelectRect.size.height);
    [GDMenu showMenuInView:self.view  fromRect:rect  menuItems:menuItems backgroundType:GDMenuViewBackgroundTypeBlack];
}

#pragma mark -
#pragma mark ---  白天和黑夜的界面资源切换  ---
//设置白天黑夜图片
- (void) setDayAndNightStyle
{
    [_mainCruiseTopSearch reloadImage];
    [self setSwitchTripDirect];
    [self buttonRealInitImage];
    [self setModeMapImage];

    [self reloadCancelDetourImage];
    
    [_mainOtherObject reloadImage];
    
    [self reloadEnlargeAndNarrowImage];
    
    [self reloadAllSeeButtonImage];
    
    [_mainBottomMenuObject reloadBottomBarButtonImage];
    //添加刷图，不然地图不会自动变色
    [[MWMapOperator sharedInstance] MW_ShowMapView:_mapType WithParma1:0 WithParma2:0 WithParma3:0];
}

//设置白天和黑夜的字体颜色 0 - 白天， 1 - 黑夜
-(void) setDayAndNightTextColor :(int) type
{
    [_mainBottomMenuObject reloadBottomBarButtonTextColor:type];
    [_mainLargeAndNarrowObject reloadTextColor:type];
    [_mainCruiseTopSearch reloadTextColor:type];
    [_mainOtherObject reloadTextColor:type];
}

#pragma mark -
#pragma mark ---  POISelectPOIDelegate  ---
-(void)selectPoiWithArray:(NSArray *)array withIndex:(int)index
{
    _isParking = NO;
    [QLoadingView hideWithAnimated:NO];
    if(array == nil)
    {
        GDAlertView *alertView = [[GDAlertView alloc]initWithTitle:nil
                                                        andMessage:STR(@"POI_NoSearchResult", Localize_POI)];
        [alertView addButtonWithTitle:STR(@"Universal_ok", Localize_Universal) type:GDAlertViewButtonTypeCancel handler:nil];
        [alertView show];
    }
    else
    {
        
        NSMutableArray *arr=[NSMutableArray arrayWithCapacity:0];
        for (int j=0 ;j<array.count;j++) {
            MWPoi *poi = array[j];
            MWMapPoi *addIcon=[[[MWMapPoi alloc] init] autorelease];
            [POICommon copyWMPoiValutToSubclass:poi withPoiSubclass:addIcon];
            [arr addObject:addIcon];
        }
        
        if(_mapAddIcon==nil)
        {
            _mapAddIcon = [[MWMapAddIconOperator alloc] initWith:[NSDictionary dictionaryWithObject:arr forKey:@"layer_redPoi.png"] inView:_mapView delegate:self];
        }
        [_mapAddIcon SetIconPosition:Position_Center];
        [_mapAddIcon freshPoiDic:[NSDictionary dictionaryWithObject:arr forKey:@"layer_redPoi.png"]];
        //        [poiDetail setPopPOIType:ViewPOIType_passBy];
        //        [poiDetail setStringAtPos:[array objectAtIndex:index] withMapType:GMAP_VIEW_TYPE_MAIN];
        //        [poiDetail setHidden: NO];
        [poiDetail setHidden:YES];
        //刷图显示沿途周边显示的点
        [[MWMapOperator sharedInstance] MW_ShowMapView:_mapType WithParma1:0 WithParma2:0 WithParma3:0];
        
        [_mainOtherObject setCancelNearbyHidden:NO];
        [_mainOtherObject reloadText];
        
        timerCount = 0;
    }
    
}

-(void)PoiDesParkingStopArray:(NSArray *)array
{
    
    _isParking = YES;
    if(array != nil && array.count > 0)
    {
        if(array.count > 5)
        {
            [self setParkingData:[NSArray arrayWithObjects:[array objectAtIndex:0],
                                  [array objectAtIndex:1],[array objectAtIndex:2],[array objectAtIndex:3],[array objectAtIndex:4], nil]];
        }
        else
        {
            [self setParkingData:array];
        }
    }
}

-(void)tapMapPoiIconnWith:(MWMapPoi *)mapPoi
{
    if (mapPoi.szAddr && [mapPoi.szAddr length] == 0) {
        
        NSString *cityName = [MWAdminCode GetCityNameWithAdminCode:mapPoi.lAdminCode];
        if (!cityName || [cityName length] == 0) {
            cityName = @"";
        }
        MWAreaInfo * info = [MWAdminCode GetCurAdareaWith:mapPoi.lAdminCode];
        
        NSString *townName =info.szTownName;
        if (!townName || [townName length] == 0) {
            townName = @"";
        }
        mapPoi.szAddr = [NSString stringWithFormat:@"%@%@",cityName,townName];
    }
    if (popPOITimer != nil)
    {
        [popPOITimer invalidate];
        popPOITimer = nil;
        return;
    }
    if ([poiDetail getShowState])
        return;
    if(_isParking)
    {
        [poiDetail setPopPOIType:ViewPOIType_desAround];
    }
    else
    {
        [poiDetail setPopPOIType:ViewPOIType_passBy];
    }
    if(_mapType == GMAP_VIEW_TYPE_MAIN)
    {
        [poiDetail setStringAtPos:mapPoi withMapType:GMAP_VIEW_TYPE_MAIN];

        __block id weakPOP = poiDetail;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakPOP startAnimate:0.5f];
            [weakPOP setHidden: NO];
        });
    }
    timerCount = 0;
}

#pragma mark -
#pragma mark ---  poishowObject delegate  ---
- (void) afterSuccessSearch
{
    _buttonGetPOIInfo.hidden = YES;
}

- (void) afterFailSearch
{
    _buttonGetPOIInfo.hidden = YES;
}


-(void)loginPrompt:(NSString*)message
{
    
    GDAlertView *alertView=[[[GDAlertView alloc] initWithTitle:nil andMessage:message] autorelease];
    [alertView addButtonWithTitle:STR(@"Setting_NO", Localize_Setting) type:GDAlertViewButtonTypeCancel handler:nil];
    
    __block PluginStrategy *strategy=[PluginStrategy sharedInstance];
    [alertView addButtonWithTitle:STR(@"Setting_YES", Localize_Setting) type:GDAlertViewButtonTypeCancel handler:^(GDAlertView *alertView){
        [strategy allocModuleWithName:@"Plugin_Account" withObject:@{@"navigationController":self,@"loginType":@(10),@"bBack":@(1)}];
        _isFromLoginInView = YES;
    }];
    [alertView show];
    
}



#pragma  mark - ---  红点设置  ---


- (void) redRequestSuccess
{
    
    BOOL servicesRed = ([[NewRedPointData sharedInstance] getValueByType:RED_TYPE_RECOMMEND]
                        || [[NewRedPointData sharedInstance] getValueByType:RED_TYPE_NO_RECOMMEND]);
    [_mainBottomMenuObject setCarNewHidden:!servicesRed];
    NSLog(@"************************ servicesRed = %d",servicesRed);
}

#pragma mark - ---  辅助函数  ---
/*!
  @brief    重载路径线颜色设置
  @param
  @author   by bazinga
  */
- (void) reloadRealTraffic
{
    if([[ANParamValue sharedInstance] isPath])
    {
        _progressBar.arrayInfo = [[MWMapOperator sharedInstance] GMD_GetGuideRouteColorContent];
        [_progressBar setNeedsDisplay];
    }
}
/*!
  @brief    请求停车场信息
  @param
  @author   by bazinga
  */
- (void) requestParking
{
    NSLog(@"requestParking : -----------------  %d",[ANParamValue sharedInstance].isRequestParking);
    if (![[ANParamValue sharedInstance] isNavi]
        && [[ANParamValue sharedInstance] isPath]
        && [[MWPreference sharedInstance] getValue:PREF_PARKINGINFO] == 1
        && [ANParamValue sharedInstance].isRequestParking == 1)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_HandleUIUpdate object:[NSNumber numberWithInt:UIUpdata_CarDistanceThreeKM] userInfo:nil];
        [ANParamValue sharedInstance].isRequestParking = 0;
    }
}




#pragma  mark ---  坐标设置  ---
/*!
  @brief    重新加载提示框坐标
  @param
  @author   by bazinga
  */
- (void) reloadButtonTipsFrame
{
    _labelTipsOnSea.frame = CGRectMake(0, 0, 280.0f, 70.0f);
    [_labelTipsOnSea setCenter:self.view.center];
    
    float mainWidth = Interface_Flag == 0 ? MAIN_POR_WIDTH : MAIN_LAND_WIDTH;
    float width = mainWidth - 2 * (CONFIG_BUTTON_SAPCE + CONFIG_BUTTON_NORMAL_WIDTH / 2) * 2;
    float top = 12.0f;
    float left = 21.0f;
    
    _buttonTipsNoData.titleLabel.font = [UIFont systemFontOfSize:(isiPhone ? 14.0f : 21.0f)];
    _colorLabelTipsNoData.font = [UIFont systemFontOfSize:(isiPhone ? 14.0f : 21.0f)];
    CGSize labelSize = [_buttonTipsNoData.titleLabel.text sizeWithFont:_buttonTipsNoData.titleLabel.font constrainedToSize:CGSizeMake(width - 2 * left, 300.0f)];
    
    [_buttonTipsNoData.layer removeAllAnimations];
    _buttonTipsNoData.frame = CGRectMake(0, 0, width, labelSize.height + top * 2);
    _colorLabelTipsNoData.frame = CGRectMake(21,0,
                                             _buttonTipsNoData.frame.size.width - 42.0f,
                                             _buttonTipsNoData.frame.size.height);
    CGFloat realY = ([[ANParamValue sharedInstance]isPath ] == NO ? CONFIG_CRUISE_TOP_HEIGHT : CONFIG_NAVI_TOP_NAME_HEIGHT) + CONFIG_BUTTON_SAPCE;
    _buttonTipsNoData.center = CGPointMake(mainWidth / 2,
                                          realY + _buttonTipsNoData.frame.size.height / 2 - 1);
    _buttonTipsNoData.titleEdgeInsets = UIEdgeInsetsMake(top, left, top, left);
    
}


- (void) setMainViewFrame
{
    //导航界面
    [self setNaviFrame];
    //模拟导航按键
    [self setSimuFrame];
    //巡航状态
    [self setCruiseFrame];
    //车位按钮位置
    [self setGetPOIInfoButtonFrame];
    
#pragma - 新的界面坐标设置 -
    
    //视图选择按钮坐标设置
    [self reloadMainCarViewFrame];
}

/***
 * @name    导航界面
 * @param
 * @author  by bazinga
 ***/
- (void) setNaviFrame
{
    [_mainNaviTopObject reloadFrame];
    [_mainNaviBottomObject reloadFrame];
    if(Interface_Flag == 0)
    {
        [_progressBar setFrame:CGRectMake(0, 0, MAIN_POR_WIDTH, CONFIG_HISTOGRAM_HEIGHT)];
        [_progressBar setCenter:CGPointMake(MAIN_POR_WIDTH / 2,
                                            MAIN_POR_HEIGHT - CONFIG_NAVI_BOTTOM_HEIGHT - CONFIG_HISTOGRAM_HEIGHT/ 2)];
    }
    else
    {
        if(isiPhone)  //横屏
        {
            CGFloat width = MAIN_LAND_WIDTH - 4 * CONFIG_BUTTON_NORMAL_WIDTH - 6 * CONFIG_BUTTON_SAPCE;
            [_progressBar setFrame:CGRectMake(0, 0, width, CONFIG_HISTOGRAM_HEIGHT)];
            
            [_progressBar setCenter:CGPointMake(MAIN_LAND_WIDTH/2,
                                                MAIN_LAND_HEIGHT - CONFIG_BUTTON_SAPCE - CONFIG_NAVI_BOTTOM_HEIGHT - CONFIG_HISTOGRAM_HEIGHT / 2 - 1)];
            
        }
        else//ipad横屏
        {
            //进度条
            [_progressBar setFrame:CGRectMake(0, 0, MAIN_LAND_WIDTH, CONFIG_HISTOGRAM_HEIGHT)];
            [_progressBar setCenter:CGPointMake(MAIN_LAND_WIDTH/2,
                                                MAIN_LAND_HEIGHT - CONFIG_NAVI_BOTTOM_HEIGHT - CONFIG_HISTOGRAM_HEIGHT/ 2)];
        }
    }
    
    [self reloadCancelDetourImage];
    [self setSwitchTripDirectFrame];
    if([ANParamValue sharedInstance].isPath && ![ANParamValue sharedInstance].isNavi)
    {
        CGRect rect =   [_mainNaviBottomObject getListFrame];
        rect.origin.y = _mainNaviBottomObject.imageViewNaviBottomBG.frame.origin.y;
        rect.origin.x = _mainNaviBottomObject.imageViewNaviBottomBG.frame.origin.x  + rect.origin.x;

        NSLog(@"%@",NSStringFromCGRect(rect));
        [GDMenu AutoSetUpFrameInView:self.view fromRect:rect];
    }
    
    if(_viewStatueBar)
    {
        _viewStatueBar.frame = CGRectMake(0, 0, (Interface_Flag == 0 ? MAIN_POR_WIDTH : MAIN_LAND_WIDTH), 20.0f);
    }
}

//设这巡航地图界面的控件坐标
- (void) setCruiseFrame
{
    //放在最前面，不可修改
    [self setBottomButtonFrame];
    [_mainOtherObject reloadImage];
    [self reloadEnlargeAndNarrowImage];

    [_mainCruiseTopSearch setTopFrame:CGRectMake(0,
                                                 0,
                                                 Interface_Flag == 0 ? MAIN_POR_WIDTH : MAIN_LAND_WIDTH,
                                                 CONFIG_CRUISE_TOP_HEIGHT)];
    [self buttonRealInitImage];
    //    _imageViewNewCar.hidden = ![[GDNewJudge sharedInstance]isAppearNewWithType:NEW_JUDGE_CAR_TYPE];
    [_mainBottomMenuObject setSettingNewHidden:![ANParamValue sharedInstance].GMD_isMoreNew];
    //指南针的方向--顺序不能更改，下列几个函数
    [self setSwitchTripDirectFrame];
    //按照顺序，设置位置~~~
    [self reloadButtonTipsFrame];
    [self reloadEnlargeAndNarrowImage];
    //地图视角模式改变
    [self switchModeButtonCenter];
}


#pragma mark --- 指南针的方向  ---
- (void) setSwitchTripDirectFrame
{
    [self reloadEnlargeFrame];
    if([[ANParamValue sharedInstance] isPath])
    {
        [_mainOtherObject setAllSeeHidden: [[ANParamValue sharedInstance] isNavi]];
    }
    else
    {
        [_mainOtherObject setAllSeeHidden:YES];
    }
    [_mainOtherObject reloadFrame];
    [self switchModeButtonCenter];
}




- (void) reloadEnlargeFrame
{
    [_mainLargeAndNarrowObject reloadControlFrame];
}

- (void) switchModeButtonCenter
{
    CGFloat rightHeight  = 0;
    CGFloat leftHeight = 0;
    
    if([[ANParamValue sharedInstance] isPath] == NO) //巡航
    {
        rightHeight = CONFIG_CRUISE_TOP_HEIGHT;
        leftHeight = CONFIG_NAVI_TOP_NAME_HEIGHT;
    }
    else //导航
    {
        rightHeight = CONFIG_NAVI_TOP_NAME_HEIGHT;
        leftHeight = CONFIG_NAVI_TOP_DIRE_HEIGHT;
    }
    [_buttonModeChange setFrame:CGRectMake(0, 0, CONFIG_BUTTON_NORMAL_WIDTH, CONFIG_BUTTON_NORMAL_WIDTH)];

    [_buttonModeChange setCenter:CGPointMake(CONFIG_CENTER_RIGHT,
                                       rightHeight + 2 * CONFIG_BUTTON_SAPCE + CONFIG_BUTTON_NORMAL_WIDTH * 1.5f)];
    //视图选择按钮坐标设置
    [self reloadMainCarViewFrame];
}



- (void) setSimuFrame
{
    [_mainSimBottomObject reloadFrame];
    
    int eDemoSpeed = 0;
    eDemoSpeed = [[MWPreference sharedInstance] getValue:PREF_DEMO_SPEED];
    if([[MWPreference sharedInstance] getValue:PREF_DEMOMODE] == 0)
    {
        if (eDemoSpeed == SIM_LOW_SPEED)
        {
            [_mainSimBottomObject setSelectTitle:STR(@"Main_low", Localize_Main)];
            
        }
        else if(eDemoSpeed == SIM_MID_SPEED)
        {
            [_mainSimBottomObject setSelectTitle:STR(@"Main_normal", Localize_Main)];
        }
        else
        {
            [_mainSimBottomObject setSelectTitle:STR(@"Main_hight", Localize_Main)];
        }
    }
    else
    {
        [_mainSimBottomObject setSelectTitle:STR(@"Main_jump", Localize_Main)];
    }
    if([[ANParamValue sharedInstance]isNavi])
    {
        CGRect rect = _mainSimBottomObject.getSelectRect;
        rect.origin.y = _mainSimBottomObject.viewSimuBG.frame.origin.y;
        rect.origin.x = _mainSimBottomObject.viewSimuBG.frame.origin.x  + rect.origin.x;
        NSLog(@"ISNAVI");
        [GDMenu AutoSetUpFrameInView:self.view fromRect:rect];
    }
}

/*!
  @brief    重新加载选择视图界面的坐标
  @param
  @author   by bazinga
  */
- (void) reloadMainCarViewFrame
{
    CGPoint animatePoint = CGPointMake(_buttonModeChange.center.x,
                                       _buttonModeChange.center.y);
    if(Interface_Flag == 0)
    {
        [_mainCarModeView setFrame:CGRectMake(0, 0, MAIN_POR_WIDTH, MAIN_POR_HEIGHT)
                 withAnimateCenter:animatePoint
                   withSizeButton:_buttonModeChange.frame.size];
    }
    else
    {
        [_mainCarModeView setFrame:CGRectMake(0, 0, MAIN_LAND_WIDTH, MAIN_LAND_HEIGHT)
                 withAnimateCenter:animatePoint
                   withSizeButton:_buttonModeChange.frame.size];
    }
}


/*!
  @brief    添加超速观察
  @param
  @author   by bazinga
  */
- (void) AddOverSpeedCallBack
{
    __block MainViewController *blockController = self;
    [MainOverSpeed SharedInstance].changeHidden = ^(BOOL hidden){
        NSLog(@"%d",hidden);
        [blockController OverSpeedHidden:hidden];
    };
    
    [MainOverSpeed SharedInstance].changeSpeed = ^(int speed){
        NSLog(@"%d",speed);
        [blockController OverSpeedNum:speed];
    };
}

/*!
  @brief    设置速度
  @param
  @author   by bazinga
  */
- (void) OverSpeedNum:(int) speed
{
    if([[ANParamValue sharedInstance] isPath])
    {
        [_mainNaviBottomObject setSpeed:speed];
        GGPSINFO pGpsInfo = {0};
        GDBL_GetGPSInfo(&pGpsInfo);
        
        [_mainNaviBottomObject isOverSpeed:speed == 0 ? NO : pGpsInfo.nSpeed > speed];
    }
}

/*!
  @brief    设置是否隐藏
  @param
  @author   by bazinga
  */
- (void) OverSpeedHidden:(BOOL) hidden
{
    if([[ANParamValue sharedInstance] isPath])
    {
        [_mainNaviBottomObject setSpeedHidden:hidden];
    }
    else
    {
        [_mainNaviBottomObject setSpeedHidden:YES];
    }

}

/*!
  @brief    设置有路径与没路径的图面配置
  @param
  @author   by bazinga
  */
- (void) setOverSpeedCofing
{
    int value = 0;
    if([[ANParamValue sharedInstance] isPath])
    {
        //有路径，除了限速摄像头外，都显示
        value = GSAFE_HINT_CAMERA | GSAFE_HINT_NO_SPEED_LIMIT | GSAFE_HINT_DANGERWARN;
    }
    else
    {
        //没路径，都显示
        value = GSAFE_HINT_ALL;
        [self OverSpeedHidden:YES];
    }

    GDBL_SetParam(G_SAFE_HINT_OPTION, &value);
}


@end

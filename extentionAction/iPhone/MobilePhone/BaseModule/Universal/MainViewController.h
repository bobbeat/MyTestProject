//	主视图控制器
//  MainViewController.h
//  AutoNavi
//
//  Created by GHY on 12-3-26.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#define GD_MAIN_VIEW_CTL_IPHONE

#import <UIKit/UIKit.h>
#import "PaintingView.h"
#import "ANViewController.h"
#import "MoveTextLable.h"
#import "ColorLable.h"
#import "CustomBtn.h"
#import "NetKit.h"
#import <MessageUI/MessageUI.h>
#import "ProgressBar.h"
#import "POIRouteCalculation.h"


@protocol GDPopPOIDelegate;
@protocol PaintingViewDelegate;
@protocol POISelectPOIDelegate;
@protocol MWMapPoiAddIconDelegate;
@protocol POIShowObjectDelegate;
@protocol LXActivityDelegate;

@class AccountInfo;
@class BottomMenuBar;
@class GDPopPOI;
@class POIVoiceSearch;
@class BottomButton;
@class WarningViewController;
@class MWMapAddIconOperator;
@class POIShowObject;
@class SoundGuideView;
@class MainCarModeView;
@class MainBottomMenuObject;
@class MainLargeAndNarrowObject;
@class MainCruiseTopObject;
@class MainNaviTopObject;
@class MainNaviBottomObject;
@class MainSimBottomObject;
@class MainOtherObject;


@interface MainViewController : ANViewController <PaintingViewDelegate,UIAccelerometerDelegate,MyCLControllerDelegate,NetReqToViewCtrDelegate,MFMessageComposeViewControllerDelegate,UIGestureRecognizerDelegate,UISearchBarDelegate,GDPopPOIDelegate,POISelectPOIDelegate,MWMapPoiAddIconDelegate,POIShowObjectDelegate,LXActivityDelegate>
{
    PaintingView *_mapView;
    GMAPVIEWTYPE _mapType;
    GHMAPVIEW _backUpView;
    WarningViewController *_imageViewTips;       //启动背景图  用户提示条款
    /***
     * 修改后
     ***/
    NSString *GDRoadName;               //道路名


    NSTimer *moveMapTimer;
	NSTimer *popPOITimer;
    
	
	BOOL trackReplay;
	BOOL collectPOIFlag;    //收藏当前点标志
    BOOL microShareFlag;    //微享标签标志
	BOOL GpsClickFlag;      //gps点击标志
	float pathDistance;
	float provalue;
    BOOL isTmcLoading;
    BOOL messageShareFlag;
    BOOL gestureFlag;
    BOOL parallelFlag;//是否有平行道路
    BOOL _avoidFlag;
    NSMutableArray *palellerRoadArray;
    
    // 实时交通
    BOOL          m_bShowBtnRtcInfo;         // 是否显示实时交通详情按钮
    GHGUIDEROUTE guideRouteHandle;
    
    plugin_PoiNode *m_poiNode; //95190下发poi信息点
    
    AccountInfo *m_accountInfo;
    
    GDPopPOI *poiDetail;
    ProgressBar *_progressBar;          //进度条
    GEVENTINFO *_eventInfo;
    POIVoiceSearch *_poiVoiceSearch ;       //语音搜索
    POIRouteCalculation *route;
    
    int      _simPlayOrPause;           //0 : 继续导航  1 ：暂停导航 -2：导航停止，=

    MWMapAddIconOperator *_mapAddIcon;
    

    BOOL _isPianyi;      //是否是偏移重算
    
    BOOL _isSureRealON; //实时交通是否真实开启
    
    UIImageView *_divingView;
    
    POIShowObject *poiShowObject;       //弹出框的弹出控制
    
    //目的地停车场
    BottomMenuBar *_bottomParking;
    NSMutableArray *_arrayParking;  //目的地停车场的数据
    BOOL _isParking;
    BOOL _isEnterViewMapParking;
    NSTimer *_timerParking;
    NSTimer *_timerTTS;
    BOOL _isParkingCal;             //是否为目的地停车场演算
    
    SoundGuideView *_soundGuidView;
    
    BOOL _isFromLoginInView;//是否从登陆界面回来
    BOOL _bContinueRoute; //是否为续航的路径演算
    
    BOOL _reloadSwitchFrame;
    BOOL _bOverView;        //是否为全览界面
    BOOL _bCanNotSwapBuffer;        //不能刷图,用于全览界面横竖屏翻转过程，不能刷图。
    
    //无数据区域提醒
    UIButton *_buttonTipsNoData;    //无数据区域提醒。
    ColorLable *_colorLabelTipsNoData;  //无数据染色问题
    UIButton *_buttonGetPOIInfo;           //车位按钮
    
    UIButton *_buttonZoomDis,*_buttonZommRoadName;    //放大路口按钮，放大路口上边的道路名
    UIImageView *_imageViewZoomDiv;                   //距离和道路名之间的分割线
    UIView *_viewStatueBar;                           //ios 7上设置介个显示
    
    UILabel *_labelTipsOnSea;       //在海中~~~
    NSMutableArray *_arrayCityCodeToDownload;//传递下载的数据
    
    UIButton * _buttonModeChange;           //地图视图模式切换（北首上，车首上，3D）
    
    MainCarModeView *_mainCarModeView;      //视图选择弹出框
    
    MainBottomMenuObject *_mainBottomMenuObject;        //低栏菜单的对象
    
    MainLargeAndNarrowObject *_mainLargeAndNarrowObject;        //放大缩小对象
    
    MainCruiseTopObject *_mainCruiseTopSearch;      //顶部搜索栏
    
    MainNaviTopObject *_mainNaviTopObject;      //导航顶部显示栏
    
    MainNaviBottomObject *_mainNaviBottomObject;        //导航底部显示对象
    
    MainSimBottomObject *_mainSimBottomObject;          //模拟导航底部显示对象
    
    MainOtherObject *_mainOtherObject;                  //一些其他的按钮
}

- (void)MyalertView:(NSString *)titletext canceltext:(NSString *)mycanceltext othertext:(NSString *)myothertext alerttag:(int)mytag;

//控件显示－隐藏控制
- (void)viewInCondition:(NSInteger)condition;

//停止模拟导航
- (void)Action_simulatorNavi_Stop;
/*!
  @brief    添加超速观察
  @param
  @author   by bazinga
  */
- (void) AddOverSpeedCallBack;
@end

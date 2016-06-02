//
//  RoutePlanningAndDetailViewController.h
//  AutoNavi
//
//  Created by jiangshu-fu on 14-7-18.
//
//

#import "ANViewController.h"

@class PaintingView;
@class GDPopPOI;
@class BottomButton;
@class RouteDetailViewController;
@class UnderLineButton;
@class CustomPageControl;

@protocol GDPopPOIDelegate;
@protocol PaintingViewDelegate;
@protocol RouteCalDelegate;





@interface RoutePlanningAndDetailViewController : ANViewController<GDPopPOIDelegate,PaintingViewDelegate,RouteCalDelegate,UIScrollViewDelegate>
{
    //导航条
    UINavigationBar *_navigationBar;
    GHGUIDEROUTE *_guideRouteHandle;
    PaintingView *_mapView;     //地图
    GMAPVIEWTYPE _mapViewType; //地图模式
    GHGUIDEROUTE guideRouteHandle;//引导路径操作的句柄
    //导航计时器
    NSTimer *_timerCountDown;   //计时器，10S 倒计时后自动进入导航
    NSInteger _iTimeCount;      //计时，还剩余多少秒进入导航
    
    NSInteger _routeChose;      //选择的路线规划原则
    BOOL _isCountPlane;     //是否统计规划原则次数
    
    //是否长按放大缩小按钮
    BOOL _isLongPress;
    NSTimer *_timerInc,*_timerDec; //放大缩小的计时器
    //放大，缩小
    UIButton *_buttonEnlargeMap,*_buttonNarrowMap;
    UIButton *_labelMeter;      //大小按钮下的地图比例尺大小图片
    //开始导航，模拟导航，路线详情
    UIButton *_buttonBeginNavi;
    UIButton *_buttonSimuNavi;
    UIButton *_buttonDetailList;
    //沿途城市天气
    UIButton *_buttonWeather;
    //不同的规划路线，
    NSMutableArray *_arrayDetailButton;
    //detailListViewController
    RouteDetailViewController *_detailViewController;
    ManeuverInfo *_maneuverInfo;
    
    
    GEVENTINFO *_eventInfo ;
    GDPopPOI *popPoiInfo;
    
    BOOL _isEvent;
    BOOL _forbidSwapBuffer;  //禁止刷图,解决界面切换时地图会闪来闪去的问题
    //是否是点击按钮，进行 tmc 的参与路径盐酸，YES : tmc回调，演算路径 NO： tmc 回调不演算路径  默认为 NO
    BOOL _isClickOpenTMC;
    
    //数组的索引。 默认为 0，1，2， 如果需要排序，根据排序来对应这三条路线
    NSMutableArray *_arrayIndex;
    
//#pragma mark ---  已使用 躲避拥堵 界面  ---
//    UIImageView *_imageViewAll;     //整体背景界面
//    UIImageView *_imageViewRight;   //打钩图片
//    UILabel *_labelUsed;            //已使用 —— 三个字
//    UILabel *_labelAvoidCon;        //躲避拥堵 —— 四个字
//    
#pragma  mark ---  躲避拥堵 横线  ---
    UIImageView *_imageViewAvoidAll;
    UILabel *_labelTipsText;
    UnderLineButton *_buttonOpenAvoid;
    
#pragma  mark - ---  滚动  ---
    UIScrollView *_scrollerView;
    CustomPageControl *_pageControl;
}

/*!
  @brief    初始化函数
  @param
  @author   by bazinga
  */
- (id) initWithDeleteRoute:(BOOL) deleteRoute;

@property (nonatomic, assign) BOOL isDeleteRoute;   //点击返回按钮，是否删除路径
@property (nonatomic, assign) BOOL isAnimate;       //点击返回是否有动画效果。
@property (nonatomic, assign) int   gpsFlag;        //处理routing
@property (nonatomic, assign) BOOL isAvoid;         //是否躲避拥堵加入路线计算
@end

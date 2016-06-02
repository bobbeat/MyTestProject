//
//  RoutePointViewController.h
//  AutoNavi
//
//  Created by jiangshu.fu on 13-8-21.
//
//

#import "ANViewController.h"
#import "PaintingView.h"

typedef enum RoutePointType
{
    FROM_MAINVIEW,
    FROM_DETAILVIEW,
}RoutePointType;

@protocol GDPopPOIDelegate;
@protocol CycleScollViewDelegate;
@class BottomButton;
@class GDPopPOI;
@class CycleScrollView;
@interface RoutePointViewController : ANViewController <PaintingViewDelegate,CycleScollViewDelegate,GDPopPOIDelegate>
{
	PaintingView *drawingView;
    
//    PreAndNextView *_preAndNextView;
    CycleScrollView *_cycleScrollView;
    NSArray *_arrayInfo;
    int _index;
    int _indexNumber;
    int _indexInRoadList;
    
    //放大，缩小
    UIButton *_buttonEnlargeMap,*_buttonNarrowMap;
    UIButton * _buttonReal;                     //实时交通显示灯按钮
    UIButton *_buttonSwitchTripDirect;          //指南针方向按钮
    UIButton *_labelMeter;      //大小按钮下的地图比例尺大小图片
    BOOL isTmcLoading;
    //是否长按放大缩小按钮
    BOOL _isLongPress;
    NSTimer *_timerInc,*_timerDec;
    
//    UIImageView *_imageViewNaviTopBG;       //顶部的底
    
    UIImageView *_imageViewNaviBottomBG;    //底部的底
    UIButton *_buttonback;      //停止导航按钮
    BottomButton *_buttonBegin;     //开始导航
    BottomButton *_buttonContinue;  //继续导航
    
    NSTimer *_timer;
    int count ;
    
    GEVENTINFO *_eventInfo ;
    GDPopPOI *popPoiInfo;
    GHGUIDEROUTE *guideRouteHandle;    //引导路径句柄
    BOOL _avoidFlag;
    BOOL _isCanclick;   //是否可以点击按钮
    
    BOOL _isAppear; //是否已经显示界面
}

@property (nonatomic, assign) RoutePointType pointType;

- (id)initWithArry:(NSArray *)arrayRoadInfo withIndex:(int)index;

@end

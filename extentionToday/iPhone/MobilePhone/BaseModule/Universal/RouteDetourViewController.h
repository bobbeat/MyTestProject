//
//  RouteDetourViewController.h
//  AutoNavi
//
//  Created by jiangshu.fu on 13-8-22.
//
//

#import "ANViewController.h"
#import "PaintingView.h"
#import "ANParamValue.h"
#import "CustomBtn.h"

@class ColorLable;

@interface RouteDetourViewController : ANViewController<PaintingViewDelegate>
{
    PaintingView* _mapView; //地图面板
    
    UIView *_viewTrafficeInfo; //交通信息详情面板
    
    UIButton *_buttonEnlargeMap;    //放大按钮
    UIButton *_buttonNarrowMap;     //缩小按钮
    
    NSTimer *_timerInc,*_timerDec; //放大缩小长按间隔时间
    
    
    
    BOOL *_isNeedRecover;           //是否需要显示地图中心
    
    GHGUIDEROUTE *_guideRouteHandle;    //引导路径句柄
    
    UIButton *_buttonFailDetour;    //避让失败
    
    
    GMAPVIEWTYPE _MapViewType;    // 显示的地图类型，成功下GMAP_VIEW_TYPE_MULTI_DIFF，失败下GMAP_VIEW_TYPE_WHOLE
    
    BOOL _isLonePressed;        //是否长按放大，缩小
//     BOOL _isDlgFromRoadList;    //0 从trafficInfomapVc进入，需要避让道路；1 从路线详情进入，已经避让
    
    GDETOURROADINFO *_detourRoadInfo;   //原有避让信息
    int  _numCountOfDetourRoad;         //总计避让条数
    
    
    UIImageView *_imageViewNaviTopBG;       //顶部的底
//    UIImageView *_buttonTrafficEvent;    //交通事件图标
    ColorLable *_colorLabel;
    
    UIImageView *_imageViewNaviBottomBG;    //底部的底
    UIButton *_buttonBeforDetour;   //避让前
    UILabel *_labelBeforDetour;
    UILabel *_labelBeforDistance;
    UILabel *_labelBeforToll;
    
    UIButton *_buttonAfterDetour;   //避让后
    UILabel *_labelAfterDetour;
    UILabel *_labelAfterDistance;
    UILabel *_labelAfterToll;

    
    UIButton *_labelMeter;      //大小按钮下的地图比例尺大小图片
    
    
     BOOL _forbidSwapBuffer;  //禁止刷图,解决界面切换时地图会闪来闪去的问题
}
@property (nonatomic, assign) BOOL isDlgFromRoadList; //0 从trafficInfomapVc进入，需要避让道路；1 从路线详情进入，已经避让
@property (nonatomic, assign) BOOL isSuccessDetour;     //是否避让成功
@property (nonatomic, assign) BOOL hasEvent;            //是否有交通事件
@property (nonatomic, copy) NSString *stringTrafficInfo;



- (id) initWithHandle:(GHGUIDEROUTE *)handle;
// 真的避让问题
-(void) SaveOriginalDetourRoadInfo;
-(void) RecoverTheOriginalDetourRoadInfo;
- (void) setTrafficeImage:(int) typeID;
- (void) setStringTrafficInfo:(NSString *)stringTrafficInfo distance:(NSString *)distance range:(NSString *)range;
@end

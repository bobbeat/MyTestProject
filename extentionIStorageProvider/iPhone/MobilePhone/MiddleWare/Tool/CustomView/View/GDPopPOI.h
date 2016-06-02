//
//  GDMenu.h
//  AutoNavi
//
//  Created by huang longfeng on 13-8-29.
//
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

typedef enum ViewPOIType{
    ViewPOIType_Normal,    //一般状态查看poi，只显示名称，地址，距离
    ViewPOIType_Detail,    //查看poi详细信息，显示名称，地址，距离，设起点，设终点，周边，更多
    ViewPOIType_Common,    //添加常用点显示poi，显示名称，地址，距离，备注，保存，取消
    ViewPOIType_Traffic,   //点击交通流，或事件图标弹出框，显示事件图标，类型，事件详情，关闭，避让此路段
    ViewPOIType_passBy,    //有路径周边查看poi点，显示poi名，和设置途径点
    ViewPOIType_TrafficNoArrow, //路线详情界面点击交通流，或事件图标弹出框，显示事件图标，类型，事件详情，关闭，避让此路段
    ViewPOIType_SelectPOI,  //地图选点
    ViewPOIType_desAround,  //目的地周边，显示名称，地址，距离终点，设为终点
}ViewPOIType;

typedef enum ViewPOIButtonType{
    ViewPOIButtonType_collect   = 0,
    ViewPOIButtonType_setStart,
    ViewPOIButtonType_setDes,
    ViewPOIButtonType_around,
    ViewPOIButtonType_more,
    ViewPOIButtonType_sina,
    ViewPOIButtonType_weixin,
    ViewPOIButtonType_friend,
    ViewPOIButtonType_call,
    ViewPOIButtonType_save,
    ViewPOIButtonType_cancel,
    ViewPOIButtonType_close,
    ViewPOIButtonType_avoidRoute,
    ViewPOIButtonType_passBy,
    ViewPOIButtonType_selectPOISetDes,
    ViewPOIButtonType_desAroundSetDes,
    
}ViewPOIButtonType;

@class MWPoi;

@protocol GDPopPOIDelegate <NSObject>

- (void)GDPopViewTaped:(id)sender POI:(MWPoi *)poi;

@end

@class GDPopView;

@interface GDPopPOI : NSObject <UITextFieldDelegate>{
    
}

@property (assign) id topView;
@property (assign) id<GDPopPOIDelegate> delegate;
@property(nonatomic,setter = setFavoriteState:) BOOL favoriteState;
@property(nonatomic,assign) BOOL         isShow;

- (id)initWithType:(ViewPOIType)viewType;
- (void)setHidden:(BOOL)isHidden;
- (void)setStringAtPos:(MWPoi *)poiItem withMapType:(GMAPVIEWTYPE)mapViewType;
- (void)startAnimate:(NSTimeInterval)ti;
- (void)moreButtonClick;
- (BOOL)getHidden;
- (void)movePOIViewWithPoint;
- (void)movePOIViewWithCenter:(CGPoint)center;
- (void)setPopPOIType:(ViewPOIType)viewType;
- (void)setViewFrame;
- (void)setFavorite;
- (MWPoi *)getPopPOIData;
- (BOOL)getShowState;
@end

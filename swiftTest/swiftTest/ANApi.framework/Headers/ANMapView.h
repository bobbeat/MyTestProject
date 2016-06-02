//
//  ANMapView+AddOn2.h
//  ProjectDemoOnlyCode
//
//  Created by autonavi\wang.weiyang on 14-12-16.
//  Copyright (c) 2014年 liyuhang. All rights reserved.
//
#import <CoreLocation/CoreLocation.h>
#import "ANMapShowOption.h"
#import "ANMapShowTypeDef.h"
@class ANMapInfo;
@class ANUserLocation;
@class ANAnnotationView;
@class ANPoi;
@class ANRoute;
@class ANTrafficFlow;
@class ANMapView;
@protocol ANAnnotation;

#pragma mark -
#pragma mark 定义

/**
 * 信息优先显示
 */
typedef NS_OPTIONS(NSUInteger, ANPOIDisplayPriority) {
    ANPOIDisplayPriorityAuto         = 0,       ///< 自动
    ANPOIDisplayPriorityGas          = 1 << 0,  ///< 加油站
    ANPOIDisplayPriority4S           = 1 << 1,  ///< 汽车4S
    ANPOIDisplayPriorityCatering     = 1 << 2,  ///< 餐饮
    ANPOIDisplayPriorityMarket       = 1 << 3,  ///< 商场
    ANPOIDisplayPrioritySupermarket  = 1 << 4,  ///< 超市
    ANPOIDisplayPriorityGym          = 1 << 5,  ///< 运动馆
    ANPOIDisplayPriorityGolf         = 1 << 6,  ///< 高尔夫
    ANPOIDisplayPriorityKTV          = 1 << 7,  ///< KTV
    ANPOIDisplayPriorityCinema       = 1 << 8,  ///< 电影院
    ANPOIDisplayPriorityHospital     = 1 << 9,  ///< 医院
    ANPOIDisplayPriorityHotel        = 1 << 10, ///< 酒店
    ANPOIDisplayPriorityFeatureSpot  = 1 << 11, ///< 景点
    ANPOIDisplayPrioritySchool       = 1 << 12, ///< 学校
    ANPOIDisplayPriorityParking      = 1 << 13, ///< 停车场
    ANPOIDisplayPriorityBank         = 1 << 14, ///< 银行
    ANPOIDisplayPriorityToilet       = 1 << 15, ///< 厕所
    
} ;

/**
 *  跟随模式
 */
typedef NS_ENUM(NSUInteger, ANUserTrackingMode) {
//    ANUserTrackingModeNone = 0,             ///< 普通定位模式
    ANUserTrackingModeFollow = 0,               ///< 北首上跟随模式
    ANUserTrackingModeFollowWithHeading,        ///< 车首上跟随模式
};


/**
 *  横屏竖屏
 */
typedef NS_ENUM(NSUInteger, ANMapOrientation)
{
    ANMapOrientationPortrait = 0,                  ///< 竖屏
    ANMapOrientationLandscape = 1,                 ///< 横屏
};

#pragma mark -
#pragma mark 协议

/**
 *  地图控件协议
 */
@protocol ANMapViewProtocol <NSObject>

@optional

///**
// *  显示区域将要变化
// *
// *  @param mapView  地图
// *  @param animated 是否有动画
// */
//- (void)mapView:(ANMapView *)mapView regionWillChangeAnimated:(BOOL)animated;
//
///**
// *  显示区域已经变化
// *
// *  @param mapView  地图
// *  @param animated 是否有动画
// */
//- (void)mapView:(ANMapView *)mapView regionDidChangeAnimated:(BOOL)animated;
//
///**
// *  将要开始渲染地图
// *
// *  @param mapView 地图
// */
//- (void)mapViewWillStartRenderingMap:(ANMapView *)mapView;
//
///**
// *  完成渲染地图
// *
// *  @param mapView       地图
// *  @param fullyRendered 是否全地图渲染
// */
//- (void)mapViewDidFinishRenderingMap:(ANMapView *)mapView fullyRendered:(BOOL)fullyRendered ;
//
///**
// *  通过标注自定义显示视图
// *
// *  @param mapView    地图
// *  @param annotation 标注
// *
// *  @return 自定义标注视图
// */
//- (ANAnnotationView *)mapView:(ANMapView *)mapView viewForAnnotation:(id <ANAnnotation>)annotation;
//
/////**
//// *  完成添加标注
//// *
//// *  @param mapView 地图
//// *  @param views   被添加的标注视图
//// */
////- (void)mapView:(ANMapView *)mapView didAddAnnotationViews:(NSArray *)views;
//
/**
 *  选中标注视图
 *
 *  @param mapView   地图
 *  @param anotation 被选中的标注视图
 */
- (void)mapView:(ANMapView *)mapView didSelectAnnotationView:(id<ANAnnotation>)anotation;

/**
 *  反选标注视图
 *
 *  @param mapView   地图
 *  @param anotation 反选的标注视图
 */
- (void)mapView:(ANMapView *)mapView didDeselectAnnotationView:(id<ANAnnotation>)anotation;
//
///**
// *  开始定位用户
// *
// *  @param mapView 地图
// */
//- (void)mapViewWillStartLocatingUser:(ANMapView *)mapView;
//
///**
// *  停止定位用户
// *
// *  @param mapView 地图
// */
//- (void)mapViewDidStopLocatingUser:(ANMapView *)mapView;
//
///**
// *  更新用户位置信息
// *
// *  @param mapView      地图
// *  @param userLocation 用户位置信息
// */
//- (void)mapView:(ANMapView *)mapView didUpdateUserLocation:(ANUserLocation *)userLocation;
//
///**
// *  更新用户位置信息失败
// *
// *  @param mapView 地图
// *  @param error   错误
// */
//- (void)mapView:(ANMapView *)mapView didFailToLocateUserWithError:(NSError *)error;
//
///**
// *  更改地图跟随模式
// *
// *  @param mapView  地图
// *  @param mode     跟随模式
// *  @param animated 是否有动画
// */
//- (void)mapView:(ANMapView *)mapView didChangeUserTrackingMode:(ANUserTrackingMode)mode animated:(BOOL)animated;
//
///**
// *  poi点被点击
// *
// *  @param mapView 地图
// *  @param poi     poi信息
// */
//- (void)mapView:(ANMapView *)mapView didTapPoi:(ANPoi *)poi;
//
///**
// *  地图被单击事件
// *
// *  @param mapView    地图
// *  @param coordinate 被点击位置的经纬度
// */
//- (void)mapView:(ANMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate;
//
///**
// *  地图长按事件
// *
// *  @param mapView    地图
// *  @param coordinate 被长按点的经纬度
// */
//- (void)mapview:(ANMapView *)mapView didLongPressAtCoordinate:(CLLocationCoordinate2D)coordinate;
//
/**
 *  交通开关状态更新
 *
 *  @param mapView 地图
 *  @param status  状态
 */
-(void)mapView:(ANMapView *)mapView trafficStatusUpdate:(int)status;

/**
 *  交通流更新
 *
 *  @param mapView     地图
 *  @param trafficFlow 交通流
 */
-(void)mapView:(ANMapView *)mapView trafficFlowUpdated:(ANTrafficFlow *)trafficFlow;

/**
 *  交通事件更新
 *
 *  @param mapView          地图
 *  @param trafficIncidents 交通事件
 */
-(void)mapView:(ANMapView *)mapView trafficIncidentUpdated:(NSArray *)trafficIncidents;

/**
 *  交通事件选择
 *
 *  @param mapView          地图
 *  @param trafficIncidents 交通事件
 */
-(void)mapView:(ANMapView *)mapView didSelectTrafficIncident:(NSArray *)trafficIncidents;

@end

#pragma mark -
#pragma mark 地图对象

@interface ANMapView : UIView

/**
 *  协议
 */
@property (assign, nonatomic) id<ANMapViewProtocol> delegate;

/**
 *  在地图即将显示调用
 */
-(void)viewWillAppear;

/**
 *  在地图即将隐藏调用
 */
-(void)viewWillDisappear;

/**
 *  在地图即将隐藏调用
 */
@property (assign, nonatomic) ANMapOrientation mapOrientation;

#pragma mark -
#pragma mark 基本信息

/**
 *  地图基本显示信息，控制显示地图区域
 */
@property (strong, nonatomic, readonly, getter=getMapInfo) ANMapInfo *mapInfo;

/**
 *  设置地图基本信息，控制显示地图区域
 *
 *  @param mapInfo  地图信息
 *  @param animated 是否带上动画
 */
- (void)setMapInfo:(ANMapInfo *)mapInfo animated:(BOOL)animated;

#pragma mark -
#pragma mark 关于地图显示

/**
 *  显示地图
 *
 *  @param showOption 显示参数
 *  @param error      错误信息
 *
 *  @return 是否成功
 */
- (BOOL)showMapViewWithOption:(ANMapShowOption*)showOption error:(NSError **)error;

/**
 *  强制刷新一次地图视图
 *
 *  @return 是否成功
 */
- (BOOL)refreshMapView;

#pragma mark -
#pragma mark 转换

///**
// *  将屏幕坐标转换为经纬度
// *
// *  @param coordinate 经纬度
// *  @param view       要转换的视图
// *
// *  @return 屏幕坐标
// */
//- (CGPoint)convertCoordinate:(CLLocationCoordinate2D)coordinate toPointToView:(UIView *)view;
//
///**
// *  将经纬度转换为屏幕坐标
// *
// *  @param point 屏幕坐标
// *  @param view  要转换的视图
// *
// *  @return 经纬度
// */
//- (CLLocationCoordinate2D)convertPoint:(CGPoint)point toCoordinateFromView:(UIView *)view;

#pragma mark -
#pragma mark 手势

/**
 *  支持操作的手势类型
 */
@property (nonatomic) ANGestureOperation enabledGestureOperation;

///**
// *  部分手势操作是否以两指为中心，如捏合和缩放
// */
//@property(nonatomic, getter=isUpdateWithGestureCenter) BOOL updateWithGestureCenter;

#pragma mark -
#pragma mark 控件
/**
 *  是否显示默认控件
 */
@property (nonatomic) BOOL showDefaultControlls;
///**
// *  是否显示poi
// */
//@property (nonatomic) BOOL showsPointsOfInterest;

///**
// *  显示poi的优先级
// */
//@property (nonatomic) ANPOIDisplayPriority poiDisplayPriority;

///**
// *  是否显示建筑
// */
//@property (nonatomic) BOOL showsBuildings;

#pragma mark -
#pragma mark 用户位置信息

///**
// *  显示用户位置
// */
//@property (nonatomic) BOOL showsUserLocation;

/**
 *  用户位置
 */
@property (nonatomic, readonly) ANUserLocation *userLocation;

/**
 *  用户位置是否可见
 */
@property (nonatomic, readonly, getter=isUserLocationVisible) BOOL userLocationVisible;

/**
 *  用户跟随模式
 */
@property (nonatomic, assign) ANUserTrackingMode userTrackingMode;

/**
 *  回到车位
 */
- (void)moveToUserLocation;

/**
 *  设置用户跟随模式
 *
 *  @param mode     跟随模式
 *  @param animated 是否有动画
 */
- (void)setUserTrackingMode:(ANUserTrackingMode)mode animated:(BOOL)animated;

@end

#pragma mark -
#pragma mark 标注
@interface ANMapView (Annotation)
/**
 *  添加单个标注
 *
 *  @param annotation 标注
 */
- (void)addAnnotation:(id <ANAnnotation>)annotation;

/**
 *  批量添加标注
 *
 *  @param annotations 标注列表
 */
- (void)addAnnotations:(NSArray *)annotations;

/**
 *  移除单个标注
 *
 *  @param annotation 标注
 */
- (void)removeAnnotation:(id <ANAnnotation>)annotation;

/**
 *  批量移除标注
 *
 *  @param annotations 标注列表
 */
- (void)removeAnnotations:(NSArray *)annotations;

/**
 *  标注列表
 */
@property (nonatomic, readonly, getter=getAnnotations) NSArray *annotations;

///**
// *  获取标注的视图
// *
// *  @param annotation 标注
// *
// *  @return 标注视图
// */
//- (ANAnnotationView *)viewForAnnotation:(id <ANAnnotation>)annotation;
//
///**
// *  根据id获取可冲用的标注视图
// *
// *  @param identifier id
// *
// *  @return 标注视图
// */
//- (ANAnnotationView *)dequeueReusableAnnotationViewWithIdentifier:(NSString *)identifier;

/**
 *  选中标注
 *
 *  @param annotation 标注
 *  @param animated   是否有动画
 */
- (void)selectAnnotation:(id <ANAnnotation>)annotation animated:(BOOL)animated;

/**
 *  取消选中标注
 *
 *  @param annotation 标注
 *  @param animated   是否有动画
 */
- (void)deselectAnnotation:(id <ANAnnotation>)annotation animated:(BOOL)animated;
//
///**
// *  被选中的标注
// */
//@property (strong, nonatomic, readonly) NSArray *selectedAnnotations;
//
///**
// *  显示标注，如果可见区域显示不下，则将地图放大到可以显示所有标注的大小
// *
// *  @param annotations 标注列表
// *  @param animated    是否有动画
// */
//- (void)showAnnotations:(NSArray *)annotations animated:(BOOL)animated;

@end

#pragma mark -
#pragma mark 路线

@interface ANMapView (Route)

/**
 *  导航线路列表
 */
@property (strong, nonatomic, readonly) NSArray *routes;

/**
 *  显示导航线路
 *
 *  @param routes 导航线路
 */
- (void)showRoutes:(NSArray *)routes;

/**
 *  移除导航线路
 */
- (void)clearRoutes;

/**
 *  选择导航线路
 *
 *  @param route 导航线路
 */
- (void)selectRoute:(ANRoute *)route;

@end

#pragma mark -
#pragma mark 交通

@interface ANMapView (Traffic)

/**
 *  是否支持实时交通
 */
@property (nonatomic) BOOL showTraffic;

/**
 *  是否显示实时交通流，要求打开实时交通
 */
@property (nonatomic) BOOL showTrafficFlow;

/**
 *  是否显示实时交通事件，要求打开实时交通
 */
@property (nonatomic) BOOL showTrafficIncidents;

@end

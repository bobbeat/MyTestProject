//
//  ANMapShowTypeDef.h
//  ProjectDemoOnlyCode
//
//  Created by yuhang on 14-11-6.
//  Copyright (c) 2014年 liyuhang. All rights reserved.
//

#ifndef ProjectDemoOnlyCode_ANMapShowTypeDef_h
#define ProjectDemoOnlyCode_ANMapShowTypeDef_h

/**
 * @brief: 地图显示的类型，默认情况下，显示主地图单路线，如有需要显示特殊内容，可以调用showMap显示其它类型地图
 */
typedef NS_ENUM(NSUInteger, ANMapViewType)
{
    //
    ANMAP_VIEW_TYPE_MAIN = 0,        ///< 主地图单路线
    ANMAP_VIEW_TYPE_WHOLE,           ///< 单路线全程概览
    ANMAP_VIEW_TYPE_MULTI,           ///< 主地图多路线
    ANMAP_VIEW_TYPE_MULTIWHOLE,      ///< 多路线全程概览
    ANMAP_VIEW_TYPE_POI,             ///< 查看POI
    ANMAP_VIEW_TYPE_SP,              ///< 查看SP码点
    ANMAP_VIEW_TYPE_MANEUVER_POINT,  ///< 查看引导机动点
    ANMAP_VIEW_TYPE_ROUTE_TMC,       ///< 路径TMC概览
    ANMAP_VIEW_TYPE_MULTI_DIFF,      ///< 多路线不同处概览
    ANMAP_VIEW_TYPE_JOURNEYPOINTS,   ///< 查看行程点在同一图层
    ANMAP_VIEW_TYPE_BUS_OVERVIEW,    ///< 公交全程概览
    ANMAP_VIEW_TYPE_NETROU_OVERVIEW, ///< 网路路径全程概览
    ANMAP_VIEW_TYPE_CROSSZOOM,       ///< 路口放大图
    ANMAP_VIEW_TYPE_MODEL_DEMO,      ///< 3D建筑演示
    ANMAP_VIEW_TYPE_JOURNEY_DEMO,    ///< 3D路线演示
    ANMAP_VIEW_MAX                   ///< 其他
};


/**
 * @brief: 地图比例尺缩放
 */
typedef NS_ENUM(NSUInteger, ANMapViewLevelOperate)
{
    ANSETMAPVIEW_LEVEL_IN  = 0,             ///< 放大比例尺
    ANSETMAPVIEW_LEVEL_OUT = 1,             ///< 缩小比例尺
    ANSETMAPVIEW_LEVEL_ANY = 2,             ///< 缩放到任意比例尺
    ANSETMAPVIEW_LEVEL_STEPLESS_IN  = 3,    ///< 无级放大
    ANSETMAPVIEW_LEVEL_STEPLESS_OUT  = 4,   ///< 无级缩小
    ANSETMAPVIEW_LEVEL_STEPLESS_STOP  = 5,  ///< 停止无级缩放
};

/**
 * @brief: 地图比例级别枚举类型
 */
typedef NS_ENUM(NSUInteger, ANMapViewLevel)
{
    ANZOOM_500_KM = 0,                      ///< 500km
    ANZOOM_200_KM = 1,                      ///< 200km
    ANZOOM_LEVEL_CHINA = ANZOOM_200_KM,		///< 全国层
    ANZOOM_100_KM = 2,                      ///< 100km
    ANZOOM_50_KM = 3,						///< 50km
    ANZOOM_20_KM = 4,						///< 20km
    ANZOOM_10_KM = 5,						///< 10km
    ANZOOM_LEVEL_PROVINCE = ANZOOM_10_KM,	///< 全省层km
    ANZOOM_5_KM = 6,						///< 5km
    ANZOOM_LEVEL_CITY = ANZOOM_5_KM,		///< 全市层km
    ANZOOM_2_KM = 7,						///< 2km
    ANZOOM_1_KM = 8,						///< 1km
    ANZOOM_500_M = 9,						///< 500m
    ANZOOM_200_M = 10,                      ///< 200m
    ANZOOM_100_M = 11,                      ///< 100m
    ANZOOM_50_M = 12,						///< 50m
    ANZOOM_LEVEL_STREET = ANZOOM_50_M,		///< 街区层
    ANZOOM_25_M = 13,						///< 25m
    ANZOOM_15_M = 14,						///< 15m
    ANZOOM_MAX = 15                         ///< 比例级别最大值
};




/**
 * @brief: 地图视图模式切换
 */
typedef NS_ENUM(NSUInteger, ANMapViewModeOperate)
{
    ANSETMAPVIEW_MODE_NEXT = 0,         ///< 切到下个模式
    ANSETMAPVIEW_MODE_PRE  = 1,         ///< 切到上个模式
    ANSETMAPVIEW_MODE_ANY  = 2,         ///< 切到任意模式（有3d模式）
    ANSETMAPVIEW_MODE_ANY_NO3D  = 3,    ///< 切到任意模式（无3d模式）执行此种模式需要设置G_MAP_IS2MODE为Gtrue，设置之后就只支持该模式的切换不再支持前面三种模式
};


/**
 * @brief: 地图视图模式
 */
typedef NS_ENUM(NSUInteger, ANMapViewMode)
{
    //
    ANMAPVIEW_MODE_NORTH = 0,       ///< 北向模式
    ANMAPVIEW_MODE_CAR   = 1,       ///< 车向模式
    ANMAPVIEW_MODE_3D    = 2,       ///< 3D模式
};


/**
 * 手势事件结构体
 * 用于存储(ios平台)使用的手势类型信息,可包含多个
 */

typedef NS_ENUM(NSUInteger, ANGestureOperation)
{
    //
    ANGestureOperationNone                      =0,                 ///< 取消所有手势
    ANGestureOperationZoom                      =1<<0,              ///< 两指捏合缩放地图
    ANGestureOperationDeceleratingAfterScroll   =1<<1,              ///< 拖拽移动地图减速效果
    ANGestureOperationScroll                    =1<<2,              ///< 拖拽移动地图
    ANGestureOperationTilt                      =1<<3,              ///< 两指上下移动倾斜地图
    ANGestureOperationRotate                    =1<<4,              ///< 两指旋转旋转地图
    RecongnizerTypeSingleTap                =1<<5,              ///<单指单击(目前无操作，但是有其它手势效果时会将手势结束)
    RecongnizerTypeDoubleTap                =1<<6,              ///<单指双击 放大1级
    RecongnizerTypeTwoFingerSingleTap       =1<<7,              ///<双指单击 缩小1级
    RecongnizerTypeTwoFingerDoubleTap       =1<<8,              ///<双指双击 缩小2级
    RecongnizerTypeLongPress                =1<<9,              ///<长按
    ANGestureOperationAll                      =0x0FFFFFFF ,       ///< 支持所有手势
};


/**
 * 相机类型
 */
typedef NS_ENUM(NSUInteger, ANCameraType)
{
    ANCameraType_Normal = 0,       ///< 主地图模式
    ANCameraType_Driver,           ///< 第一人称模式
    ANCameraType_max               ///< 其他
};

/**
 *  横屏竖屏
 */
typedef NS_ENUM(NSUInteger, HMI_DEVICE_INTERFACE)
{
    // 检索
    HMI_DEVICE_INTERFACE_V = 0,               ///< 竖屏
    HMI_DEVICE_INTERFACE_H = 1,               ///< 横屏
};

#endif

//
//  ANRouteHeader.h
//  ProjectDemoOnlyCode
//
//  Created by autonavi\wang.weiyang on 14-12-10.
//  Copyright (c) 2014年 liyuhang. All rights reserved.
//

#ifndef ProjectDemoOnlyCode_ANRouteHeader_h
#define ProjectDemoOnlyCode_ANRouteHeader_h

/**
 *  出行方式
 */
typedef NS_ENUM(NSInteger, ANNaviMode){
    /**
     *  驾车
     */
    ANNaviModeByCar    = 0,
    /**
     *  公交
     */
    ANNaviModeByBus    = 1,
    /**
     *  步行
     */
    ANNaviModeWalking  = 2,
};


/**
 * 路径规划方式
 */
typedef NS_OPTIONS(NSInteger, ANRouteCalculateRule)
{
    /**
     *  推荐路线
     */
    ANRouteCalculateRuleDefault       = 0,
    /**
     *  高速优先
     */
    ANRouteCalculateRuleHighWay       = 1<<0,
    /**
     *  经济路线
     */
    ANRouteCalculateRuleEconomical    = 1<<1,
    /**
     *  最短路线
     */
    ANRouteCalculateRuleShortest      = 1<<2,
};


/**
 *  路径演算类型
 */
typedef NS_ENUM(NSInteger, ANRouteCalculateType){
    /**
     *  单条路径演算
     */
    ANRouteCalculateTypeSingle			= 0,
    /**
     *   多条路径演算
     */
    ANRouteCalculateTypeMultiple		= 1,
    /**
     *  路径重演算
     */
    ANRouteCalculateTypeRecalculate		= 2,
    /**
     *  单条路径演算并返回路径句柄
     */
    ANRouteCalculateTypeSINGLE_ROUTE	= 3,
    /**
     *  单条网络路径演算
     */
    ANRouteCalculateTypeSingleNet		= 4,
    /**
     *  多条网络路径演算
     */
    ANRouteCalculateTypeMultipleNet		= 5,
    /**
     *  tmc参与路径规划
     */
     ANRouteCalculateTypeTMCRecalculate = 6,
    /**
     *  切换平行路
     */
    ANRouteCalculateTypeChangeCarRoad   = 7,
};


/**
 *  避让类型
 */
typedef NS_OPTIONS(NSInteger, ANRouteDetourType)
{
    /**
     *  默认
     */
    ANRouteDetourTypeDefault    = 0,
    /**
     *  渡口
     */
    ANRouteDetourTypeFerry      = 1<<0,
    /**
     *  隧道
     */
    ANRouteDetourTypeTunnel     = 1<<1,
    /**
     *  桥梁
     */
    ANRouteDetourTypeBridge     = 1<<2,
    /**
     *  高架桥
     */
    ANRouteDetourTypeViaduct    = 1<<3,
    /**
     *  高速路
     */
    ANRouteDetourTypeFreeway    = 1<<4,
    /**
     *  收费站
     */
    ANRouteDetourTypeTollgate   = 1<<5,
};


#endif

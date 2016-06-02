//
//  ANRoute.h
//  ProjectDemoOnlyCode
//
//  Created by autonavi\wang.weiyang on 14-12-3.
//  Copyright (c) 2014年 liyuhang. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ANRoutePoint;
#import "ANRouteHeader.h"

/**
 *  路线对象
 */
@interface ANRoute : NSObject

/**
 *  路线编号
 */
@property (nonatomic, readonly) long routeId;

/**
 *  路线句柄
 */
@property (nonatomic) GHGUIDEROUTE routeHandle;

/**
 *  行程点数组，由一个个的ANRoutePoint对象构成
 */
@property (strong, nonatomic) NSMutableArray *journeyPoints;

/**
 *  路段数组，由一个个的ANRouteStep对象构成
 */
@property (strong, nonatomic, getter=getRouteSteps) NSMutableArray *routeSteps;

/**
 *  路径规划原则
 */
@property (nonatomic) ANRouteCalculateRule calculateRule;

/**
 *  是否设置避让
 */
@property (nonatomic) BOOL isDetourEnabled;

/**
 *  计算时是否考虑交通流量
 */
@property (nonatomic) BOOL isTMSCalculationEnabled;

/**
 *  总预计事件
 */
@property (nonatomic) int totalArrivalTime;

/**
 *  总费用
 */
@property (nonatomic) int totalCharge;

/**
 *  总收费站数量
 */
@property (nonatomic) int totalTollGate;

/**
 *  总红绿灯数量
 */
@property (nonatomic) int totalTrafficLight;

/**
 *  总长度
 */
@property (nonatomic) int totalDistance;

/**
 *  总收费路段长度
 */
@property (nonatomic) int totalChargeDistance;

/**
 *  总环城路长度
 */
@property (nonatomic) int totalCircleDistance;

/**
 *  总高速长度
 */
@property (nonatomic) int totalHighwayDistance;

/**
 *  高级路段总长度
 */
@property (nonatomic) int totalHighLevelDistance;

/**
 *  中级路段总长度
 */
@property (nonatomic) int totalMidLevelDistance;

/**
 *  低级路段总长度
 */
@property (nonatomic) int totalLowLevelDistance;

/**
 *  获取路线详情
 */
- (NSMutableArray *)getRouteSteps;

@end



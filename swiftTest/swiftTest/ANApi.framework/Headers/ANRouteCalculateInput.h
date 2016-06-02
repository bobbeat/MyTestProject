//
//  ANRouteCalculateInput.h
//  ProjectDemoOnlyCode
//
//  Created by autonavi\wang.weiyang on 14-12-8.
//  Copyright (c) 2014年 liyuhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ANRoutePoint.h"
#import "ANRouteHeader.h"

/**
 *  路径计算参数类
 */
@interface ANRouteCalculateInput : NSObject

/**
 *  计算时是否考虑交通
 */
@property (nonatomic) BOOL calculateWithTraffic;

/**
 *  行程点数组，由一个个的ANRoutePoint对象构成
 */
@property (nonatomic,strong) NSMutableArray *journeyPoints;

/**
 *  路径规划方式 
 */
@property (nonatomic) ANRouteCalculateRule calculateRule;

/**
 *  避让类型
 */
@property (nonatomic) ANRouteDetourType detourType;

/**
 *  由ANDetourRoad对象组成的避让实体
 */
@property (nonatomic,strong) NSMutableArray *detourRoads;


@end

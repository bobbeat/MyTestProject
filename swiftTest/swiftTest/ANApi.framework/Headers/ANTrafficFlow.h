//
//  ANTrafficFlow.h
//  ProjectDemoOnlyCode
//
//  Created by autonavi\wang.weiyang on 14-12-3.
//  Copyright (c) 2014年 liyuhang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  交通流
 */
@interface ANTrafficFlow : NSObject

/**
 *  车位距离路径起点距离
 */
@property (nonatomic) int carDistanceFromStart;

/**
 *  车位所在记录索引
 */
@property (nonatomic) int carIndex;

/**
 *  目的地距离起点距离(记录索引、距离起点距离)
 */
@property (strong, nonatomic) NSMutableArray *destDistanceFromStart;

/**
 *  道路总距离
 */
@property (nonatomic) int totalDistance;

/**
 *  路线上交通流段信息
 */
@property (strong, nonatomic) NSMutableArray *trafficFlowSections;

@end

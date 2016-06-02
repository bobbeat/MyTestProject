//
//  ANGuideInfo.h
//  ProjectDemoOnlyCode
//
//  Created by autonavi\wang.weiyang on 14-12-8.
//  Copyright (c) 2014年 liyuhang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  当前导航信息
 */
@interface ANGuideInfo : NSObject

/**
 * 当前道路名
 */
@property (strong, nonatomic) NSString *currentRoadName;
/**
 * 下一道路名
 */
@property (strong, nonatomic) NSString *nextRoadName;
/**
 * 到达路口预计耗时（单位：分）
 */
@property (nonatomic) int timeToNextRoad;
/**
 * 到达路口距离（单位：米）
 */
@property (nonatomic) int distanceToNextRoad;
/**
 * 到达目的地预计耗时（单位：分
 */
@property (nonatomic) int timeToDestination;
/**
 * 到达目的地距离（单位：米）
 */
@property (nonatomic) int distanceToDestination;

@end

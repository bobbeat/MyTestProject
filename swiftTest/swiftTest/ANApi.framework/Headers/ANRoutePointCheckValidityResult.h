//
//  ANRoutePointCheckValidityResult.h
//  ProjectDemoOnlyCode
//
//  Created by autonavi\wang.weiyang on 12/24/14.
//  Copyright (c) 2014 liyuhang. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ANRoutePoint;

/**
 *  路径有效性校验
 */
@interface ANRoutePointCheckValidityResult : NSObject

/**
 *  状态编号
 */
@property (nonatomic) int statusCode;

/**
 *  行程点
 */
@property (strong, nonatomic) ANRoutePoint *routePoint;

@end

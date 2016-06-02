//
//  ANTrafficIncident.h
//  ProjectDemoOnlyCode
//
//  Created by autonavi\wang.weiyang on 14-12-3.
//  Copyright (c) 2014年 liyuhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

/**
 *  交通事件
 */
@interface ANTrafficIncident : NSObject

/**
 *  起始道路
 */
@property (nonatomic) NSString *beginRoad;

/**
 *  起始时间
 */
@property (nonatomic) NSDate *beginTime;

/**
 *  终点道路
 */
@property (nonatomic) NSString *endRoad;

/**
 *  终点时间
 */
@property (nonatomic) NSDate *endTime;

/**
 *  地点
 */
@property (nonatomic) NSString *place;

/**
 *  方向
 */
@property (nonatomic) int direction;

/**
 *  距离用户的位置
 */
@property (nonatomic) int distance;

/**
 *  位置经纬度
 */
@property (nonatomic) CLLocationCoordinate2D coordinate;

/**
 *  事件发生的长度
 */
@property (nonatomic) int length;

@end

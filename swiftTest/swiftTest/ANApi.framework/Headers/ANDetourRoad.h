//
//  ANDetourRoad.h
//  ProjectDemoOnlyCode
//
//  Created by cjb on 12/23/14.
//  Copyright (c) 2014 liyuhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

/**
 *  规避道路时长
 */
typedef NS_ENUM(NSInteger, ANDetourDuration){
    /**
     *  一次
     */
    ANDetourDurationOnce  = 0,
    /**
     *  今天
     */
    ANDetourDurationToday,
    /**
     *  一周
     */
    ANDetourDurationOneWeek,
    /**
     *  一个月
     */
    ANDetourDurationOneMonth,
    /**
     *  一年
     */
    ANDetourDurationOneYear,
    /**
     *  永久
     */
    ANDetourDurationForever,
    /**
     *  自定义时间段
     */
    ANDetourDurationCustomize
};

/**
 *  避让道路实体
 */
@interface ANDetourRoad : NSObject

/**
 *  道路ID
 */
@property (nonatomic) GOBJECTID roadId;

/**
 *  道路经纬度
 */
@property (nonatomic) CLLocationCoordinate2D coordinate;

/**
 *  道路名称
 */
@property (nonatomic, strong) NSString *name;

/**
 *  规避时常
 */
@property (nonatomic) ANDetourDuration detourDuration;

/**
 *  规避开始时间
 */
@property (nonatomic, strong) NSDate *startTime;

/**
 *  规避结束时间
 */
@property (nonatomic, strong) NSDate *endTime;


@end


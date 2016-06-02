//
//  ANRouteStep.h
//  ProjectDemoOnlyCode
//
//  Created by autonavi\wang.weiyang on 12/18/14.
//  Copyright (c) 2014 liyuhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "ANDetourable.h"


/**
 *  交通状况
 */
typedef NS_ENUM(NSInteger, ANTrafficStreamStatus)
{
    /**
     *  畅通
     */
    ANTrafficStreamFree			= 1,
    /**
     *  繁忙
     */
    ANTrafficStreamBusy			= 2,
    /**
     *  缓行
     */
    ANTrafficStreamSlow			= 3,
    /**
     *  拥堵
     */
    ANTrafficStreamCrowded		= 4,
    /**
     *  严重拥堵
     */
    ANTrafficStreamSevereCrowded	= 5,
    /**
     *  无数据(数据没有覆盖)
     */
    ANTrafficStreamUNCovered		= 6,
    /**
     *  无交通流状态数据
     */
    ANTrafficStreamNone			= 7,
};

/**
 *  引导道路属性标志位
 */
typedef NS_ENUM(NSInteger, ANGuideRoadFlag)
{
    /**
     *  交通灯
     */
    ANGuideRoadFlagTrafficLight = 1,
    /**
     *  收费站
     */
    ANGuideRoadFlagTollGate     = 2,
    /**
     *  当前车位所在路段
     */
    ANGuideRoadFlagCarPosition  = 3,
    /**
     *  未通过路段
     */
    ANGuideRoadFlagNotPassed    = 4,
};

/**
 *  路径分段
 */
@interface ANRouteStep : NSObject<ANDetourable>

//@property (nonatomic) int stepId;
//@property (nonatomic) CLLocationCoordinate2D coordinate;
//@property (nonatomic) int meshRoadId;
//@property (nonatomic) int nextArrivalTime;
//@property (nonatomic) int nextDistance;
//@property (nonatomic) int nextRoadName;
//@property (nonatomic) GOBJECTID objectId;
//@property (nonatomic) int remainingDistance;
//@property (nonatomic) int roadId;
//@property (nonatomic) int roadName;
//@property (nonatomic) int trafficFlowStatus;
//@property (nonatomic) int trafficIncidentId;
//@property (nonatomic) int turningId;


/**
 *  ID
 */
@property (nonatomic, assign) int guideRoadID;

/**
 *  转向ID
 */
@property (nonatomic, assign) int turnID;

/**
 *  转向名称
 */
@property (nonatomic, copy) NSString *turnName;

/**
 *  路口距离（单位：米）
 */
@property (nonatomic, assign) int nextDistance;

/**
 *  到达路口预计耗时（单位：分）
 */
@property (nonatomic, assign) int nextArrivalTime;

/**
 *  到达目的地距离（单位：米)
 */
@property (nonatomic, assign) int totalRemainDistance;

/**
 *  当前道路名
 */
@property (nonatomic, copy) NSString *currentRoadName;

/**
 *  下一道路名
 */
@property (nonatomic, copy) NSString *nextRoadName;

/**
 *  实时交通流状态
 */
@property (nonatomic, assign) ANTrafficStreamStatus trafficStreamStatus;

/**
 *  实时交通事件ID
 */
@property (nonatomic, assign) int trafficEventID;

/**
 *  道路ID
 */
@property (nonatomic, assign) int chinaRoadID;

/**
 *  道路属性标志位
 */
@property (nonatomic, assign) ANGuideRoadFlag guideRoadFlag;

/**
 *  车位到该路口距离
 */
@property (nonatomic, assign) int distanceFromCar;

/**
 *  经度
 */
@property (nonatomic, assign) long longtitude;

/**
 *  唯独
 */
@property (nonatomic, assign) long latitude;

/**
 *  道路等级
 */
@property (nonatomic, assign) int roadClass;


@end

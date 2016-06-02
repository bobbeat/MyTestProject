//
//  ANRoad.h
//  ProjectDemoOnlyCode
//
//  Created by autonavi\wang.weiyang on 14-12-3.
//  Copyright (c) 2014年 liyuhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

/**
 *  道路类型
 */
typedef NS_ENUM(NSInteger, ANRoadType){
    /**
     *  高速公路
     */
    ANRoadTypeHighWay        = 1,
    /**
     *  城市快速路
     */
    ANRoadTypeCityExpressway = 2,
    /**
     *  国道
     */
    ANRoadTypeNationalRoad   = 3,
    /**
     *  主要道路
     */
    ANRoadTypeMainRoad       = 4,
    /**
     *  省道
     */
    ANRoadTypeProvinceRoad   = 5,
    /**
     *  次要道路
     */
    ANRoadTypeMinorRoad      = 6,
    /**
     *  县道
     */
    ANRoadTypeCountyRoad     = 7,
    /**
     *  普通道路
     */
    ANRoadTypeNormalRoad     = 8,
    /**
     *  乡公路
     */
    ANRoadTypeCountryRoad    = 9,
    /**
     *  县乡内部路
     */
    ANRoadTypeInnerRoad      = 10,
    /**
     *  非导航道路
     */
    ANRoadTypeNoNaviRoad     = 11,
};

/**
 *  道路实体
 */
@interface ANRoad : NSObject

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
 *  道路类型
 */
@property (nonatomic) ANRoadType roadType;


@end


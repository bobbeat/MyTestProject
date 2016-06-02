//
//  ANJourneyDemo.h
//  ANApi
//
//  Created by autonavi\wang.weiyang on 14-10-20.
//  Copyright (c) 2014年 Autonavi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

/**
 *  路程demo类
 */
@interface ANJourneyDemo : NSObject

/**
 *  路程id
 */
@property (nonatomic) int journeyId;

/**
 *  名称
 */
@property (strong, nonatomic) NSString *name;

/**
 *  起点
 */
@property (nonatomic) CLLocationCoordinate2D start;

@end

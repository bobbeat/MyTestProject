//
//  ANUserLocation.h
//  ProjectDemoOnlyCode
//
//  Created by autonavi\wang.weiyang on 14-12-16.
//  Copyright (c) 2014年 liyuhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

/**
 *  用户信息类
 */
@interface ANUserLocation : NSObject

//@property (assign, nonatomic, getter=isUpdating) BOOL updating;
/**
 * 经纬度坐标
 */
@property (assign, nonatomic) CLLocationCoordinate2D location;
/**
 * 方向
 */
@property (assign, nonatomic) int bearing;
/**
 * 当前道路名
 */
@property (strong,nonatomic) NSString *roadName;

@end

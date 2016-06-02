//
//  ANMapInfo.h
//  ProjectDemoOnlyCode
//
//  Created by autonavi\wang.weiyang on 14-12-16.
//  Copyright (c) 2014年 liyuhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "ANMapShowTypeDef.h"

/**
 *  地图基本信息
 */
@interface ANMapInfo : NSObject

/**
 *  倾斜角度
 */
@property (nonatomic) int tilt;
/**
 *  当前显示区域中心经纬度
 */
@property (nonatomic) CLLocationCoordinate2D centerCoordinate;
/**
 *  缩放级别
 */
@property (nonatomic) ANMapViewLevel zoomLevel;
/**
 *  旋转角度
 */
@property (nonatomic) float bearing;

#pragma mark -
#pragma mark  显示的附加信息
/**
 *  缩放级别对应的数值（获取）
 */
@property (nonatomic, strong, getter=getZoomLevelValue) NSString* zoomLevelValue;
/**
 *  道路名称
 */
@property (nonatomic) NSString* roadName;
@end

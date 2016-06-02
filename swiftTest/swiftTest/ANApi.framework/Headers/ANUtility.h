//
//  ANUtility.h
//  ProjectDemoOnlyCode
//
//  Created by yuhang on 12/23/14.
//  Copyright (c) 2014 liyuhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
/**
 *  系统工具类
 */
@interface ANUtility : NSObject
{
    
}

/**
 *  将经纬度转换为屏幕坐标
 *
 *  @param coordinate 经纬度
 *  @param view       要转换的视图
 *
 *  @return 屏幕坐标
 */
+ (CGPoint)convertCoordinate:(CLLocationCoordinate2D)coordinate toPointToView:(UIView *)view;

/**
 * 将屏幕坐标转换为经纬度
 *
 *  @param point 屏幕坐标
 *  @param view  要转换的视图
 *
 *  @return 经纬度
 */
+ (CLLocationCoordinate2D)convertPoint:(CGPoint)point toCoordinateFromView:(UIView *)view;

/**
 *  将WGS地理坐标转换为高德地理坐标
 *
 *  @param coordinate 地理坐标
 *
 *  @return 高德坐标
 */
+ (CLLocationCoordinate2D)convertToGDCoordinate:(CLLocationCoordinate2D)coordinate;
@end

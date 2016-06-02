//
//  ANAnnotation.h
//  ProjectDemoOnlyCode
//
//  Created by autonavi\wang.weiyang on 14-12-16.
//  Copyright (c) 2014年 liyuhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

/**
 *  地图标注
 */
@protocol ANAnnotation <NSObject>

/**
 * 经纬度坐标
 */
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@optional
/**
 * 标题
 */
@property (nonatomic, strong)     NSString *title;
/**
 * 副标题
 */
@property (nonatomic, strong)     NSString *subtitle;
/**
 *显示的图片，默认使用红色圆点图片
 */
@property (nonatomic, strong)     UIImage* imageShow;             // nil下，显示默认的图片

@end

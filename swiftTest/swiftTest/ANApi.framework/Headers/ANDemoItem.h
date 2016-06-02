//
//  ANDemoItem.h
//  ANApi
//
//  Created by autonavi\wang.weiyang on 14-10-20.
//  Copyright (c) 2014年 Autonavi. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  demo明细
 */
@interface ANDemoItem : NSObject

/**
 *  旋转角度
 */
@property (nonatomic) int bearing;

/**
 *  名称
 */
@property (strong, nonatomic) NSString *name;

/**
 *  行政编号
 */
@property (strong, nonatomic) NSString *spCode;

/**
 *  倾斜角度
 */
@property (nonatomic) int tilt;

/**
 *  缩放级别
 */
@property (nonatomic) int zoomLevel;

@end

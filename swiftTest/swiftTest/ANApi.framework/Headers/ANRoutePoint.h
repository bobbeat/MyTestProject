//
//  ANRoutePoint.h
//  ProjectDemoOnlyCode
//
//  Created by autonavi\wang.weiyang on 14-12-4.
//  Copyright (c) 2014年 liyuhang. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ANRoad;
@class ANPoi;

/**
 *  路线点
 */
@interface ANRoutePoint : NSObject

/**
 *  poi
 */
@property (strong, nonatomic) ANPoi *poi;

/**
 *  进行checkValidity方法，有可能返回道路列表，如果要让用户选择道路列表中的某一条，选择完就要填写该字段，否则不要填写
 */
@property (strong, nonatomic) ANRoad *road;

@end







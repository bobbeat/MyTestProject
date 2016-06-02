//
//  ANRouteValidator.h
//  ANApi
//
//  Created by autonavi\wang.weiyang on 12/23/14.
//  Copyright (c) 2014 yuhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ANTypeDef.h"
@class ANPoi;
@class ANRoutePoint;
@class ANRoutePointCheckValidityResult;

/**
 *  行程点计算，到遇到一个poi可能存在多个道路时回调
 *
 *  @param  可选道路
 *
 *  @return 所选道路索引
 */
typedef int (^ANRoutePointCheckValidityBlock)(NSArray *);

@interface ANRoutePointValidator : NSObject

/**
*  校验该ANRoutePoint是否有效，如果有高速路跟快速路同时经过该ANRoutePoint就会在block的数组里显示
*
*  @param poi   poi信息
*  @param block 索引选择block
*
*  @return 校验结果
*/
+ (ANRoutePointCheckValidityResult *)checkValidity:(ANPoi *)poi withProcessBlock:(ANRoutePointCheckValidityBlock)block;

@end
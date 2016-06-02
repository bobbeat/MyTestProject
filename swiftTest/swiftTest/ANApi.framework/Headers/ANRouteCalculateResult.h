//
//  ANRouteSearchResult.h
//  ANApi
//
//  Created by autonavi\wang.weiyang on 14-12-8.
//  Copyright (c) 2014年 yuhang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  路径计算结果
 */
@interface ANRouteCalculateResult : NSObject

/**
 *  计算状态
 */
@property (nonatomic) int status;

/**
 *  计算结果路径
 */
@property (nonatomic) NSMutableArray *routes;


@end

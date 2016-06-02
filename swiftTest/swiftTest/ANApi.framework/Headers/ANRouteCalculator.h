//
//  ANRouteSearch.h
//  ANApi
//
//  Created by autonavi\wang.weiyang on 14-12-8.
//  Copyright (c) 2014年 yuhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ANRouteHeader.h"

@class ANRouteCalculateInput;
@class ANRouteCalculateResult;
@class ANRoutePoint;
@protocol ANRouteCalculateProtocol;

/**
 *  路线计算控制器
 */
@interface ANRouteCalculator : NSObject


/**
 *  路线计算协议
 */
@property (assign, nonatomic) id<ANRouteCalculateProtocol> delegate;

@property (strong, nonatomic) ANRouteCalculateInput *calculateInput;

/**
 *  开始路线记录，本方法的返回值只标记参数输入是否正确，不代表最终的计算结果
 *
 *  @param input 计算参数
 *  @param error 错误结果
 *
 *  @return 调用结果是否正确
 */
- (BOOL)startCalculate:(ANRouteCalculateInput *)input error:(NSError **)error;

//@property (nonatomic, readonly) BOOL isCalculating;

/**
 *  停止路径计算
 *
 *  @return 返回成功与否
 */
-(BOOL)stopCalculate;

@end

/**
 *  路线计算回调
 */
@protocol ANRouteCalculateProtocol <NSObject>

/**
 *  路径计算
 *
 *  @param calculator 计算调用参数
 *  @param result     计算结果
 *  @param error      错误信息
 */
-(void)routeCalculator:(ANRouteCalculator *)calculator finishCalculateWithResult:(ANRouteCalculateResult *)result error:(NSError *)error;


@end










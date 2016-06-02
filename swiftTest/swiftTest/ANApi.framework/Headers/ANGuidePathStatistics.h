//
//  ANPathStasticInfo.h
//  ProjectDemoOnlyCode
//
//  Created by yuhang on 14-11-6.
//  Copyright (c) 2014年 liyuhang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  导航路径信息
 */
@interface ANGuidePathStatistics : NSObject

@property (nonatomic, assign) int   remainDis;          ///< 道路剩余长度
@property (nonatomic, assign) int   remainChargeDis;    ///< 收费路段剩余长度
@property (nonatomic, assign) int   remainHighwayDis;   ///< 高速路段剩余长度
@property (nonatomic, assign) int   remainCircleDis;    ///< 环城路段剩余长度
@property (nonatomic, assign) int   remainHighDis;      ///< 高等路段剩余长度
@property (nonatomic, assign) int   remainMidDis;       ///< 中等路段剩余长度
@property (nonatomic, assign) int   remainLowDis;       ///< 低等路段剩余长度
@property (nonatomic, assign) int   remainCharge;       ///< 收费剩余额
@property (nonatomic, assign) int   remainTollGate;     ///< 收费站剩余个数
@property (nonatomic, assign) int   remainTrafficLight; ///< 红绿灯剩余个数
@property (nonatomic, assign) int   estimatedTime;      ///< 预计时间（单位：分）
@end


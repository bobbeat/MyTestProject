//
//  ANTrafficFlowItem.h
//  ProjectDemoOnlyCode
//
//  Created by autonavi\wang.weiyang on 14-12-4.
//  Copyright (c) 2014年 liyuhang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  交通流分段
 */
@interface ANTrafficFlowSection : NSObject

/**
 *  起始点索引
 */
@property (nonatomic) int startIndex;

/**
 *  结束点索引
 */
@property (nonatomic) int endIndex;

/**
 *  长度
 */
@property (nonatomic) int length;

/**
 *  延误事件
 */
@property (nonatomic) int delayTime;

/**
 *  距离路径起点的长度
 */
@property (nonatomic) int distanceFromStart;

/**
 *  交通流状态
 */
@property (nonatomic) int status;

/**
 *  道路名称以逗号隔开，不包含未命名道路
 */
@property (strong, nonatomic) NSString *roadNames;

@end

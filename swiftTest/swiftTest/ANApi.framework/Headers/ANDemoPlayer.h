//
//  ANDemoPlayer.h
//  ANApi
//
//  Created by autonavi\wang.weiyang on 14-10-20.
//  Copyright (c) 2014年 Autonavi. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ANDemoItem;

/**
 *  demo播放类
 */
@interface ANDemoPlayer : NSObject

/**
 *  创建DemoPlayer对象并设置好要播放的数据源
 *
 *  @param dataSource 要播放的数据源
 *
 *  @return DemoPlayer对象
 */
+ (ANDemoPlayer *)demoPlayerWith:(ANDemoItem *)dataSource;

/**
 *  暂停播放
 */
- (void)pause;

/**
 *  设置要播放的数据源
 *
 *  @param dataSource 要播放的数据源
 */
- (void)setDataSource:(ANDemoItem *)dataSource;

/**
 *  开始或继续播放
 */
- (void)start;

/**
 *  停止播放
 */
- (void)stop;


@end

//
//  DemoManager.h
//  ANApiSDK
//
//  Created by yang yi on 14-10-13.
//  Copyright (c) 2014年 Autonavi. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  demo管理类
 */
@interface ANDemoManager : NSObject

/**
 *  获取所有演示信息
 *
 *  @return 所有演示信息
 */
- (NSArray *)allDemos;

/**
 *  获取路线演示列表
 *
 *  @return 路线演示列表
 */
- (NSArray *)allJourneyDemos;

/**
 *  加载路线演示
 *
 *  @param nJourneyDemoId 路线id
 */
- (void)loadJourneyDemoWith:(int)nJourneyDemoId;

/**
 *  卸载路线演示
 */
- (void)unloadJourneyDemo;

@end

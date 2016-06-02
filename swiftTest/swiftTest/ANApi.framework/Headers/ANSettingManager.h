//
//  Settings.h
//  ANApiSDK
//
//  Created by yang yi on 14-10-13.
//  Copyright (c) 2014年 Autonavi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#ifdef MacroFoFramework
#import <ANApi/ANSettingHeader.h>
#import <ANApi/ANSettingNotificationProtocol.h>
#else
#import "ANSettingHeader.h"
#import "ANSettingNotificationProtocol.h"
#endif

/**
 *  设置管理器
 */
@interface ANSettingManager : NSObject

+ (ANSettingManager *)sharedInstance;

/**
 *  重置设置
 *
 *  @return 重置是否成功
 */
- (BOOL)reset;

/**
 *  保存设置
 *
 *  @return 保存是否成功
 */
- (BOOL)save;

/**
 *  获得指定的设置
 *
 *  @param type 设置类型
 *
 *  @return 返回值
 */
- (int)getValue:(ANSettingType)type;

/**
 *  为设置赋值
 *
 *  @param type  类型
 *  @param value 值
 */
- (void)setValue:(ANSettingType)type Value:(NSInteger)value;

/**
 *  添加一个对设置项的监听
 *
 *  @param observer 监听对象
 */
- (void) addSettingObserver:(id<ANSettingNotificationProtocol>)observer;

/**
 *  移除一个对设置项的监听
 *
 *  @param observer 监听对象
 */
- (void) removeSettingObserver:(id<ANSettingNotificationProtocol>)observer;

@end

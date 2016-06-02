//
//  ANSettingNotificationProtocol.h
//  ProjectDemoOnlyCode
//
//  Created by autonavi\wang.weiyang on 14-11-5.
//  Copyright (c) 2014年 liyuhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ANSettingHeader.h"

/**
 *  设置的值发生变化时的通知
 */
@protocol ANSettingNotificationProtocol <NSObject>

/**
 *  当设置的值发生变化时触发
 *
 *  @param type  设置类型
 *  @param value 变化后的值
 */
- (void)onSettingChanged:(ANSettingType)type value:(NSInteger)value;

@end

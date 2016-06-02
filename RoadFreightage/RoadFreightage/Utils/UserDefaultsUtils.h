//
//  UserDefaultsUtils.h
//  RoadFreightage
//
//  Created by yu.liao on 15/6/8.
//  Copyright (c) 2015年 WuKongSuYun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserDefaultsUtils : NSObject

+(void)saveValue:(id) value forKey:(NSString *)key;

+(id)valueWithKey:(NSString *)key;

+(BOOL)boolValueWithKey:(NSString *)key;

+(void)saveBoolValue:(BOOL)value withKey:(NSString *)key;

+(void)print;

@end

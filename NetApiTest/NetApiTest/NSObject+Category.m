//
//  NSObject+Category.m
//  RoadFreightage
//
//  Created by mac on 15/6/6.
//  Copyright (c) 2015年 WuKongSuYun. All rights reserved.
//

#import "NSObject+Category.h"
#import <objc/runtime.h>

@implementation NSObject (Category)

/*!
 @brief 获取对象所有数据及属性值
 @return 对象属性值字典
 */
- (NSDictionary *)getProperties
{
    NSMutableDictionary *props = [NSMutableDictionary dictionary];
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    for (i = 0; i<outCount; i++)
    {
        objc_property_t property = properties[i];
        const char* char_f =property_getName(property);
        NSString *propertyName = [NSString stringWithUTF8String:char_f];
        id propertyValue = [self valueForKey:(NSString *)propertyName];
        if (propertyValue) [props setObject:propertyValue forKey:propertyName];
    }
    free(properties);
    return props;
}

/*!
 @brief 设置对象所有数据及属性值
 @param 对象属性值字典
 */
- (void)setPropertiesWirh:(NSDictionary *)dic
{
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    for (i = 0; i<outCount; i++)
    {
        objc_property_t property = properties[i];
        const char* char_f =property_getName(property);
        NSString *propertyName = [NSString stringWithUTF8String:char_f];
        id propertyValue = [dic valueForKey:(NSString *)propertyName];
        if (propertyValue) [self setValue:propertyValue forKey:propertyName];
    }
    free(properties);
}

@end

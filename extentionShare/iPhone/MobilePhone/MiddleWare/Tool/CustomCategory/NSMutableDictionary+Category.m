//
//  NSMutableDictionary+Category.m
//  AutoNavi
//
//  Created by longfeng.huang on 14-5-9.
//
//

#import "NSMutableDictionary+Category.h"

@implementation NSMutableDictionary (Category)

/*!
  @brief 设置字典键值（参数object或者aKey为空都不设置）
  */
- (void)caSetObject:(id)object forKey:(id <NSCopying>)aKey
{
    if (object && aKey) {
        [self setObject:object forKey:aKey];
    }
}

@end

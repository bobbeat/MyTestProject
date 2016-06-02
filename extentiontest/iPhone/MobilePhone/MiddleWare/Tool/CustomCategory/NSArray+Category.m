//
//  NSArray+Category.m
//  AutoNavi
//
//  Created by longfeng.huang on 14-5-9.
//
//

#import "NSArray+Category.h"

@implementation NSArray (Category)

/*!
  @brief 获取数组的对应索引值（索引大于或等于数组个数则返回nil）
  */
- (id)caObjectsAtIndex:(NSUInteger)index
{
    if (index < [self count]) {
        
        return [self objectAtIndex:index];
    }
    
    return nil;
}

@end

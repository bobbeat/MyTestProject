//
//  NSArray+Category.h
//  AutoNavi
//
//  Created by longfeng.huang on 14-5-9.
//
//

#import <Foundation/Foundation.h>

@interface NSArray (Category)

/*!
  @brief 获取数组的对应索引值（索引大于或等于数组个数则返回nil）
  */
- (id)caObjectsAtIndex:(NSUInteger)index;

@end

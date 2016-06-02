//
//  NSObject+Category.h
//  RoadFreightage
//
//  Created by mac on 15/6/6.
//  Copyright (c) 2015年 WuKongSuYun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Category)

/*!
 @brief 获取对象所有数据及属性值
 @return 对象属性值字典
 */
- (NSDictionary *)getProperties;

/*!
 @brief 设置对象所有数据及属性值
 @param 对象属性值字典
 */
- (void)setPropertiesWirh:(NSDictionary *)dic;
@end

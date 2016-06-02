//
//  NSObject+Category.h
//  AutoNavi
//
//  Created by longfeng.huang on 14-7-26.
//
//

#import <Foundation/Foundation.h>

@interface NSObject (Category)

/*!
  @brief 将NSArray或者NSDictionary转化为NSData(utf-8)
  */
-(NSData*)JSONNSData;

/*!
  @brief 将NSData转化为NSArray或者NSDictionary
  */
- (id)JSONParse;

@end

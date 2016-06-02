//
//  NSObject+Category.m
//  AutoNavi
//
//  Created by longfeng.huang on 14-7-26.
//
//

#import "NSObject+Category.h"

@implementation NSObject (Category)

/*!
  @brief 将NSArray或者NSDictionary转化为NSData(utf-8)
  */
- (NSData*)JSONNSData
{
    if (!self) {
        return nil;
    }
    
    NSError* error = nil;
    id result = [NSJSONSerialization dataWithJSONObject:self
                                                options:NSJSONWritingPrettyPrinted error:&error];
    if (error != nil) return nil;
    
    
    return result;
}

/*!
  @brief 将NSData转化为NSArray或者NSDictionary
  */
- (id)JSONParse
{
    if (!self) {
        return nil;
    }
    
    NSError *error = nil;
    
    id result = [NSJSONSerialization JSONObjectWithData:(NSData *)self options:NSJSONReadingAllowFragments error:&error];
    
    if (error != nil) return nil;
    
    return result;
}

@end

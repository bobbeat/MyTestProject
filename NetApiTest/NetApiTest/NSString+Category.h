//
//  NSString+Category.h
//  AutoNavi
//
//  Created by GHY on 12-3-19.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString(Category)

- (NSString *) stringFromMD5;
+ (NSString*)getShaMd5With:(NSString *)str key:(NSString *)key;
//URL地址转义 与 反转义
- (NSString *)URLEncodedString;

- (NSString *)URLDecodedString;

@end

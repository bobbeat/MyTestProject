//
//  ThreeDes.h
//  LocaleTest
//
//  Created by huang on 14-1-14.
//  Copyright (c) 2014年 huang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ThreeDes : NSObject
// 加密方法
+ (NSString*)encrypt:(NSString*)plainText;

// 解密方法
+ (NSString*)decrypt:(NSString*)encryptText;
@end

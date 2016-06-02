//
//  UIDeviceHelper.h
//  CocoaHelpers
//
//  Created by Shaun Harrison on 12/11/08.
//  Copyright 2008 enormego. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIDevice (Helper)

/*
 * Available device memory in MB 
 */
+ (double)availableMemory ;

// 获取当前任务所占用的内存（单位：MB）
+ (double)usedMemory;

@end

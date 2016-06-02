//
//  MyClass.m
//  FrameWorkTest
//
//  Created by gaozhimin on 14-7-23.
//  Copyright (c) 2014年 autonavi. All rights reserved.
//

#import "MyClass.h"

static int *g_str = NULL;

@implementation MyClass

- (instancetype)init
{
    self = [super init];
    if (self) {
        g_str = malloc(sizeof(int));
        *g_str = 123;
    }
    return self;
}

- (void)PrintStr
{
    NSLog(@"%d",*g_str);
}

@end

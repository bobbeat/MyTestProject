//
//  diana.m
//  diana
//
//  Created by gaozhimin on 14-7-23.
//  Copyright (c) 2014年 autonavi. All rights reserved.
//

#import "diana.h"

int *g_str = NULL;

@implementation diana

- (instancetype)init
{
    self = [super init];
    if (self) {
        g_str = malloc(sizeof(int));
        *g_str = 456;
    }
    return self;
}

- (void)PrintStr
{
    NSLog(@"%d",*g_str);
}

@end

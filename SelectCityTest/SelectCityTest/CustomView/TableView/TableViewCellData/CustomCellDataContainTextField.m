//
//  CustomCellDataContainTextField.m
//  RoadFreightage
//
//  Created by yu.liao on 15/6/6.
//  Copyright (c) 2015年 WuKongSuYun. All rights reserved.
//

#import "CustomCellDataContainTextField.h"

@implementation CustomCellDataContainTextField

@synthesize cellFieldText;

- (instancetype)init
{
    self = [super init];
    if (self)
    {
       
    }
    return self;
}

- (NSString *)cellFieldText
{
    if (cellFieldText == nil) {
        return @"";
    }
    return cellFieldText;
}

@end

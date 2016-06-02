//
//  MileageData.m
//  objectToplist
//
//  Created by weihong.wang on 14-4-9.
//  Copyright (c) 2014年 wangweihong. All rights reserved.
//

#import "MileageData.h"

@implementation MileageData

- (void) encodeWithCoder: (NSCoder *)coder
{
    [coder encodeObject:self.userID forKey:@"userID"];
    [coder encodeObject:self.recordDate forKey:@"recordDate"];
    [coder encodeObject:self.totalMileage forKey:@"totalMileage"];
    [coder encodeObject:self.upTodayMileage forKey:@"upTodayMileage"];
    [coder encodeObject:self.weekMileage forKey:@"weekMileage"];
    [coder encodeObject:self.noUpTodayMileage forKey:@"noUpTodayMileage"];
}
- (id) initWithCoder: (NSCoder *)coder
{
    if (self = [super init])
    {
        self.userID = [coder decodeObjectForKey:@"userID"];
        self.recordDate = [coder decodeObjectForKey:@"recordDate"];
        self.totalMileage = [coder decodeObjectForKey:@"totalMileage"];
        self.upTodayMileage = [coder decodeObjectForKey:@"upTodayMileage"];
        self.weekMileage = [coder decodeObjectForKey:@"weekMileage"];
        self.noUpTodayMileage = [coder decodeObjectForKey:@"noUpTodayMileage"];
    }
    return self;
}
- (void)dealloc
{
    [_userID release];
    [_recordDate release];
    [_totalMileage release];
    [_upTodayMileage release];
    [_weekMileage release];
    [_noUpTodayMileage release];
    [super dealloc];
}

@end

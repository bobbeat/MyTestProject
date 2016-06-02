//
//  MWMileageList.m
//  AutoNavi
//
//  Created by longfeng.huang on 14-4-11.
//
//

#import "MWMileageList.h"

@implementation MWMileageList

@synthesize totalUserRanking,areaUserRanking;

- (void)dealloc
{
    if (totalUserRanking)
    {
        [totalUserRanking release];
        totalUserRanking = nil;
    }
    
    if (areaUserRanking)
    {
        [areaUserRanking release];
        areaUserRanking = nil;
    }
    
    [super dealloc];
}

@end


@implementation MWMileageUserDetail

@synthesize userName,total;

- (void)dealloc
{
    if (userName)
    {
        [userName release];
        userName = nil;
    }
    
    [super dealloc];
}

@end
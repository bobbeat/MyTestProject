//
//  plugin_PoiNode.m
//  AutoNavi
//
//  Created by huang longfeng on 12-4-19.
//  Copyright 2012 autonavi. All rights reserved.
//

#import "plugin_PoiNode.h"

@implementation SubCityItem :NSObject

@synthesize lAdminCode;
@synthesize szAdminName;
@synthesize szAdminSpell;
@synthesize lNumberOfSubAdarea;
@synthesize subcityItem;

- (void)dealloc
{
    if (szAdminName)
    {
        [szAdminName release];
        szAdminName = nil;
    }
    if (szAdminSpell)
    {
        [szAdminSpell release];
        szAdminSpell = nil;
    }
    if (subcityItem)
    {
        [subcityItem release];
        subcityItem = nil;
    }
    [super dealloc];
}
@end

@implementation Plugin_CityItem :NSObject




@synthesize lNumberOfAdarea;

@synthesize cityItem;

- (void)dealloc
{
    if (cityItem)
    {
        [cityItem release];
        cityItem = nil;
    }
    [super dealloc];
}

@end

@implementation plugin_PoiNode

@synthesize lLon;
@synthesize lLat;
@synthesize lCategoryID;
@synthesize lDistance;
@synthesize lMatchCode;
@synthesize lHilightFlag;
@synthesize lAdminCode;
@synthesize stPoiId;
@synthesize lNaviLon;
@synthesize lNaviLat;
@synthesize szName;
@synthesize szAddr;
@synthesize szTel;
@synthesize szTown;
@synthesize lPoiIndex;
@synthesize ucFlag;
@synthesize ucNodeType;
@synthesize usNodeId;

- (void)dealloc
{
    if (szName)
    {
        [szName release];
        szName = nil;
    }
    if (szAddr)
    {
        [szAddr release];
        szAddr = nil;
    }
    if (szTel)
    {
        [szTel release];
        szTel = nil;
    }
    if (szTown)
    {
        [szTown release];
        szTown = nil;
    }
    [super dealloc];
}

@end

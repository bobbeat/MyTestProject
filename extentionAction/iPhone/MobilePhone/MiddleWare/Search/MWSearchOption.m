//
//  MWSearchOption.m
//  AutoNavi
//
//  Created by gaozhimin on 13-7-29.
//
//

#import "MWSearchOption.h"

@implementation MWSearchOption

@synthesize aroundRange,keyWord,latitude,longitude,operatorType,routePoiTpe,sortType,stCatCode;

- (id)init
{
    self = [super init];
    if (self)
    {
        
    }
    return self;
}

- (void)dealloc
{
    self.keyWord = nil;
    [super dealloc];
}

@end

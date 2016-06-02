//
//  ANButton.m
//  AutoNavi
//
//  Created by GHY on 12-3-19.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "ANButton.h"


@implementation ANButton

@synthesize textOffsetValue;
@synthesize textRightsetValue;

- (id)init 
{
	self = [super init];
	textOffsetValue = 12.0f;
    textRightsetValue = 0.0;
	return self;
}


- (CGRect)titleRectForContentRect:(CGRect)contentRect
{
	contentRect.origin.y += textOffsetValue;
    contentRect.origin.x += textRightsetValue;
	return contentRect;
}


- (CGRect)imageRectForContentRect:(CGRect)contentRect
{
	return contentRect;
}


@end


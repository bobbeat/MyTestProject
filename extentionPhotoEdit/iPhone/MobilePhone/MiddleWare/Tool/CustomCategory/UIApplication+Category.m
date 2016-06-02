//
//  UIApplication+Category.m
//  AutoNavi
//
//  Created by GHY on 12-3-5.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "UIApplication+Category.h"


@implementation UIApplication(Category)


- (void)exitApplication
{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"exitApplication" object:nil];
}


@end

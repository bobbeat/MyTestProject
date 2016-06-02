//
//  person.m
//  cocotest
//
//  Created by gaozhimin on 14-10-9.
//  Copyright (c) 2014年 autonavi. All rights reserved.
//

#import "person.h"
#import <UIKit/UIKit.h>

@implementation person

- (void)run
{
    NSLog(@"let's run.");
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"The Second Alert" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"done", nil];
    [alert show];
}

@end

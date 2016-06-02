//
//  ViewController.m
//  testwork
//
//  Created by gaozhimin on 14-7-23.
//  Copyright (c) 2014年 autonavi. All rights reserved.
//

#import "ViewController.h"
#import "Test/MyClass.h"
#import "diana.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    diana *test1 = [[diana alloc] init];
    [test1 PrintStr];
    
    MyClass *test = [[MyClass alloc] init];
    [test PrintStr];
    
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.fireDate=[NSDate dateWithTimeIntervalSinceNow:5];
    notification.timeZone=[NSTimeZone defaultTimeZone];
    notification.alertBody=@"测试推送的快捷回复";
    notification.category = @"alert";
    [[UIApplication sharedApplication]  scheduleLocalNotification:notification];
    return;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

//
//  ViewController.m
//  framtest
//
//  Created by gaozhimin on 15/6/3.
//  Copyright (c) 2015年 autonavi. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    // Do any additional setup after loading the view, typically from a nib.
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
    [self.view addSubview:view];
    view.backgroundColor = [UIColor redColor];
    
    
    self.edgesForExtendedLayout=UIRectEdgeNone;
    self.extendedLayoutIncludesOpaqueBars=NO;
    self.automaticallyAdjustsScrollViewInsets=NO;
    
    [[UIApplication sharedApplication] ]
    view = [[UIView alloc] initWithFrame:CGRectMake(250, 0, 200, 200)];
    [self.view addSubview:view];
    view.backgroundColor = [UIColor blackColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate NS_AVAILABLE_IOS(6_0)
{
     NSLog(@"applicationFrame = %@ mainScreen = %@",NSStringFromCGRect([[UIScreen mainScreen] applicationFrame]),NSStringFromCGRect([[UIScreen mainScreen] bounds]));
    return YES;
}
- (NSUInteger)supportedInterfaceOrientations NS_AVAILABLE_IOS(6_0)

{
    NSLog(@"applicationFrame = %@ mainScreen = %@",NSStringFromCGRect([[UIScreen mainScreen] applicationFrame]),NSStringFromCGRect([[UIScreen mainScreen] bounds]));
    return UIInterfaceOrientationMaskAll;
}
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    NSLog(@"applicationFrame = %@ mainScreen = %@",NSStringFromCGRect([[UIScreen mainScreen] applicationFrame]),NSStringFromCGRect([[UIScreen mainScreen] bounds]));
}
@end

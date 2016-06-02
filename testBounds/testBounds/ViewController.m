//
//  ViewController.m
//  testBounds
//
//  Created by gaozhimin on 15/9/11.
//  Copyright (c) 2015年 autonavi. All rights reserved.
//

#import "ViewController.h"

#define AMAP_SCREEN_BOUNDS [UIScreen mainScreen].bounds
#define AMAP_SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define AMAP_SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

#define AMAP_APP_WIDTH  [UIScreen mainScreen].applicationFrame.size.width
#define AMAP_APP_HEIGHT [UIScreen mainScreen].applicationFrame.size.height


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    NSLog(@"toInterfaceOrientation = %d [UIScreen mainScreen].bounds = %@,[UIScreen mainScreen].applicationFrame = %@",toInterfaceOrientation,NSStringFromCGRect([UIScreen mainScreen].bounds),NSStringFromCGRect([UIScreen mainScreen].applicationFrame));
}

@end

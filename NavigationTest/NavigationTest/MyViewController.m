//
//  MyViewController.m
//  NavigationTest
//
//  Created by gaozhimin on 14-8-28.
//  Copyright (c) 2014年 autonavi. All rights reserved.
//

#import "MyViewController.h"

UIDeviceOrientation g_lastDeviceOriention = 0;  //未强制改变设备方向前的设备方向
UIDeviceOrientation g_normalDeviceOriention = 0;  //设备自然状态下选择的值

@interface MyViewController ()

@end

@implementation MyViewController

@synthesize supportInterface,forcedOrientations;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    UIInterfaceOrientation currentOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (self.supportInterface == Only_Portrait)
    {
        if (!(currentOrientation == UIInterfaceOrientationPortrait || currentOrientation == UIInterfaceOrientationPortraitUpsideDown)) {
            self.forcedOrientations = YES;
            [self ForcedDeviceOritation:UIDeviceOrientationPortrait];
        }
    }
    else if (self.supportInterface == Only_Landscape)
    {
        if (!(currentOrientation == UIInterfaceOrientationLandscapeLeft || currentOrientation == UIInterfaceOrientationLandscapeRight)) {
            self.forcedOrientations = YES;
            [self ForcedDeviceOritation:UIDeviceOrientationLandscapeLeft];
        }
    }
    else
    {
        if (g_normalDeviceOriention > 0)
        {
            [self ForcedDeviceOritation:g_normalDeviceOriention];
        }
    }
    NSLog(@"orientation = %d,currentOrientation = %d",orientation,currentOrientation);
}

//强制改变设备方向
- (void)ForcedDeviceOritation:(UIDeviceOrientation)oritation
{
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    g_lastDeviceOriention = orientation;
    g_normalDeviceOriention = 0;
    if([[UIDevice currentDevice]respondsToSelector:@selector(setOrientation:)]) {
        [[UIDevice currentDevice]performSelector:@selector(setOrientation:)
                                      withObject:(id)oritation];
    }
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

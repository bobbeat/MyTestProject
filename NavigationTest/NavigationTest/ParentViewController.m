//
//  ParentViewController.m
//  AutoNavi
//
//  Created by yu.liao on 12-8-22.
//
//

#import "ParentViewController.h"
#include <sys/sysctl.h>
#include <mach/mach.h>
#import "MyViewController.h"

@interface ParentViewController ()
{

}

@end

@implementation ParentViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(0, 10, 100, 50);
    button.center = CGPointMake(160, 100);
    [button setTitle:@"只支持竖屏" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    button.tag = Only_Portrait;
    [self.view addSubview:button];
    
    
    button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(0, 10, 100, 50);
    button.center = CGPointMake(160, 200);
    [button setTitle:@"只支持横屏" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    button.tag = Only_Landscape;
    [self.view addSubview:button];
    
    button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(0, 10, 100, 50);
    button.center = CGPointMake(160, 300);
    [button setTitle:@"都支持" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    button.tag = All_Interface;
    [self.view addSubview:button];
}

- (void)buttonPressed:(id)sender
{
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.fireDate=[NSDate dateWithTimeIntervalSinceNow:5];
    notification.timeZone=[NSTimeZone defaultTimeZone];
    notification.alertBody=@"测试推送的快捷回复";
    notification.category = @"alert";
    [[UIApplication sharedApplication]  scheduleLocalNotification:notification];
    return;
    
    UIButton *button = (UIButton *)sender;
    switch (button.tag)
    {
        case Only_Portrait:
        {
            MyViewController *ctl = [[MyViewController alloc] init];
            ctl.title = @"只支持竖屏";
            ctl.supportInterface = Only_Portrait;
            [self pushViewController:ctl animated:YES];
            [ctl release];
        }
            
            break;
        case Only_Landscape:
        {
            MyViewController *ctl = [[MyViewController alloc] init];
            ctl.title = @"只支持横屏";
            ctl.supportInterface = Only_Landscape;
            [self pushViewController:ctl animated:YES];
            [ctl release];
        }
            
            break;
        case All_Interface:
        {
            MyViewController *ctl = [[MyViewController alloc] init];
            ctl.title = @"都支持";
            ctl.supportInterface = All_Interface;
            [self pushViewController:ctl animated:YES];
            [ctl release];
        }
            
            break;
            
        default:
            break;
    }
}


- (void)replayGps:(UIButton *)button
{

}

- (void)getMemUsed:(NSTimer *)timer
{

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate
{
    MyViewController *myctl = (MyViewController *)[self topViewController];
    if (myctl.forcedOrientations)
    {
        return YES;
    }
    else
    {
        if (myctl.supportInterface == Only_Landscape)
        {
            UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
            if (orientation == UIDeviceOrientationPortrait || orientation == UIDeviceOrientationPortraitUpsideDown )
            {
                g_normalDeviceOriention = orientation;
                g_lastDeviceOriention = 0;
                return NO;
            }
        }
        else if (myctl.supportInterface == Only_Portrait)
        {
            UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
            if (orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight )
            {
                g_normalDeviceOriention = orientation;
                g_lastDeviceOriention = 0;
                return NO;
            }
        }
    }
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    __block MyViewController *myctl = (MyViewController *)[self topViewController];
    if (myctl.forcedOrientations)
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            myctl.forcedOrientations = NO;
        });
        return UIInterfaceOrientationMaskAll;
    }
    else
    {
        if (myctl.supportInterface == Only_Portrait)
        {
            return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
        }
        else if (myctl.supportInterface == Only_Landscape)
        {
            return UIInterfaceOrientationMaskLandscape;
        }
        else
        {
            return UIInterfaceOrientationMaskAll;
        }
    }
}

@end

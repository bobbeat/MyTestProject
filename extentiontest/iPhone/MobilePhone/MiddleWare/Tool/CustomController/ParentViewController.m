//
//  ParentViewController.m
//  AutoNavi
//
//  Created by yu.liao on 12-8-22.
//
//

#import "ParentViewController.h"
#import "ANParamValue.h"
#import "UIDeviceHelper.h"
#include <sys/sysctl.h>  
#include <mach/mach.h>
#import "GDBL_LaunchRequest.h"

@interface ParentViewController ()

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate
{
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationUnknown) {
        return YES;
    }
    if (!OrientationSwitch)
    {
        return NO;
    }
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationUnknown) {
        [[MWPreference sharedInstance] loadPreference];
    }
    

    return  UIInterfaceOrientationMaskAll;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
     [[GDBL_LaunchRequest sharedInstance] CheckImageViewDirection:size];
}


@end

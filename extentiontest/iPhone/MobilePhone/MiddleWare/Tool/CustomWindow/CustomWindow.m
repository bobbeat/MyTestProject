//
//  CustomWindow.m
//  AutoNavi
//
//  Created by gaozhimin on 14-3-15.
//
//

#import "CustomWindow.h"

@interface CamouflageViewController : UIViewController  //用于在加入UIWindow时，伪装加入一个contorller，能够使状态栏旋转

+ (void)CreatCamouflageViewControllerWithModal:(UIViewController *)viewController;
+ (void)dismissCamouflageViewController;

@end

@interface CamouflageViewController ()

@end

Class object_getClass(id object);

static CamouflageViewController *g_CamouflageViewController = nil;
static Class camouflage_oringin = Nil;

@implementation CamouflageViewController

+ (void)CreatCamouflageViewControllerWithModal:(UIViewController *)viewController
{
    g_CamouflageViewController = [[CamouflageViewController alloc] init];
    [viewController presentModalViewController:g_CamouflageViewController animated:NO];
    [g_CamouflageViewController release];
    
    camouflage_oringin = object_getClass(g_CamouflageViewController);
}

+ (void)dismissCamouflageViewController
{
    Class current = object_getClass(g_CamouflageViewController);
    if (current != camouflage_oringin)
    {
        camouflage_oringin = Nil;
        return;
    }
    if ([g_CamouflageViewController isKindOfClass:[UIViewController class]])
    {
        [g_CamouflageViewController dismissModalViewControllerAnimated:NO];
        g_CamouflageViewController = nil;
    }
}


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
    self.view.backgroundColor = [UIColor clearColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if (!OrientationSwitch)
    {
        return (Orientation == interfaceOrientation);
    }
	return  YES;
    
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
    
    if ([[ANParamValue sharedInstance] bSupportAutorate] == NO)
    {
        return  UIInterfaceOrientationMaskPortrait;
    }
    else{
        return  UIInterfaceOrientationMaskAll;
    }
}

@end

static UIWindow *g_customWindow = nil;

@implementation CustomWindow

+ (UIWindow *)existCustomWindow
{
    if (g_customWindow)
    {
        return g_customWindow;
    }
    return nil;
}

/*
 @param
 rootViewController     加入UIWindow中的rootViewController
 modalViewController    当前页面的Controller
 */
+ (void)CreatCustomWindowWithRootViewController:(UIViewController *)rootViewController ModalViewController:(UIViewController *)modalViewController
{
    if (g_customWindow)
    {
        [g_customWindow resignKeyWindow];
        [g_customWindow release];
        g_customWindow = nil;
    }
    [CamouflageViewController CreatCamouflageViewControllerWithModal:modalViewController];
    
    g_customWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    g_customWindow.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    g_customWindow.opaque = YES;
    g_customWindow.windowLevel = 1;
    g_customWindow.rootViewController = rootViewController;
    [g_customWindow makeKeyAndVisible];
}

+ (void)DestroyCustomWindow
{
    if (g_customWindow)
    {
        if (NSFoundationVersionNumber < NSFoundationVersionNumber_iOS_6_0)
        {
            g_customWindow.rootViewController = nil;
        }
        [g_customWindow resignKeyWindow];
        [g_customWindow release];
        g_customWindow = nil;
        if (NSFoundationVersionNumber < NSFoundationVersionNumber_iOS_6_0)
        {
            [[[UIApplication sharedApplication].windows objectAtIndex:0] makeKeyWindow];
        }
        
        [CamouflageViewController dismissCamouflageViewController];
    }
}

@end

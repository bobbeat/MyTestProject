//
//  AppDelegate_iPhone.m
//  AutoNavi
//
//  Created by GHY on 12-3-26.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate_iPhone.h"
#import "MPApp.h"
#import "MainViewController.h"
#import "WarningViewController.h"
#import "AppLaunchManager.h"

@implementation AppDelegate_iPhone

@synthesize window;
@synthesize navigationController;
@synthesize rootViewController;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    
    [[MPApp sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
    
    [[MPApp sharedInstance] launchImage:self.window];//modi by hlf for iPhone6 Plus横屏无闪屏，需要将此函数提到launchAppWith函数之前执行，避免interface获取不准确，进而导致不能控制iphone6plus横屏的闪屏状态
    
    [[AppLaunchManager SharedInstance] launchAppWith:self.window navigation:self.navigationController];
    [self.window makeKeyAndVisible];
   
    
    return YES;
}

- (void)test
{
    self.window.rootViewController = navigationController;
}

// Called when your app has been activated by the user selecting an action from a local notification.
// A nil action identifier indicates the default action.
// You should call the completion handler as soon as you've finished handling the action.
- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)notification completionHandler:(void(^)())completionHandler NS_AVAILABLE_IOS(8_0)
{
    NSString *s = identifier;
}

// Called when your app has been activated by the user selecting an action from a remote notification.
// A nil action identifier indicates the default action.
// You should call the completion handler as soon as you've finished handling the action.
- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler NS_AVAILABLE_IOS(8_0)
{
    NSString *s = identifier;
}

// Applications may reject specific types of extensions based on the extension point identifier.
// Constants representing common extension point identifiers are provided further down.
// If unimplemented, the default behavior is to allow the extension point identifier.
- (BOOL)application:(UIApplication *)application shouldAllowExtensionPointIdentifier:(NSString *)extensionPointIdentifier NS_AVAILABLE_IOS(8_0)
{
    NSString *s = extensionPointIdentifier;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    
    [[MPApp sharedInstance] applicationWillResignActive:application];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
   
    [[MPApp sharedInstance] applicationDidEnterBackground:application];
}


- (void)applicationWillEnterForeground:(UIApplication *)application{
    
     [[MPApp sharedInstance] applicationWillEnterForeground:application];
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
        
     [[MPApp sharedInstance] applicationDidBecomeActive:application];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken 
{
    [[MPApp sharedInstance] application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken ];
}
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error 
{
     [[MPApp sharedInstance] application:application didFailToRegisterForRemoteNotificationsWithError:error  ];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo 
{
    [[MPApp sharedInstance] application:application didReceiveRemoteNotification:userInfo];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
      [[MPApp sharedInstance] application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
    return YES;
}

#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    [[MPApp sharedInstance] applicationDidReceiveMemoryWarning:application];
}

- (void)dealloc {
	
    [window release];
	[rootViewController release];
	[navigationController release];
	
    [super dealloc];
}

- (UIViewController *)mainViewController {
	
	return navigationController;
}
@end

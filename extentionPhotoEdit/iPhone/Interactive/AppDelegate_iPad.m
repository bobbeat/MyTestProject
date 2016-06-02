//
//  AppDelegate_iPad.m
//  AutoNavi
//
//  Created by GHY on 12-3-26.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate_iPad.h"
#import "MPApp.h"


@implementation AppDelegate_iPad

@synthesize window;
@synthesize navigationController;
@synthesize rootViewController;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [[MPApp sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
    self.window.rootViewController = navigationController;
	[self.window makeKeyAndVisible];
    
    [[MPApp sharedInstance] launchImage:self.window];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    
    [[MPApp sharedInstance] applicationWillResignActive:application];

}


- (void)applicationDidEnterBackground:(UIApplication *)application {

    [[MPApp sharedInstance] applicationDidEnterBackground:application];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    
   [[MPApp sharedInstance] applicationWillEnterForeground:application];
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    [[MPApp sharedInstance] applicationDidBecomeActive:application];
    
}


- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
	
     [[MPApp sharedInstance] application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken ];
    
}
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    
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
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
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

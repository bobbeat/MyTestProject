//
//  MPApp.h
//  AutoNavi
//
//  Created by yu.liao on 13-5-23.
//
//

#import <Foundation/Foundation.h>

@class ANViewController;

@interface MPApp : NSObject
{
    UIBackgroundTaskIdentifier bgTaskId;
    UINavigationController *navigationController;
    ANViewController *rootViewController;
    
}


+ (MPApp *)sharedInstance;

- (void)launchImage:(UIWindow *)window;
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;

- (void)applicationDidBecomeActive:(UIApplication *)application;
- (void)applicationWillResignActive:(UIApplication *)application;
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation;

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application;

- (void)applicationDidEnterBackground:(UIApplication *)application;
- (void)applicationWillEnterForeground:(UIApplication *)application;

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error;

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo;
- (void)setMNavigationController:(UINavigationController *)m_navigationController;

@end

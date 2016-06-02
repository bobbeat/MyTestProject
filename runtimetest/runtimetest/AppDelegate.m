//
//  AppDelegate.m
//  runtimetest
//
//  Created by gaozhimin on 15/7/31.
//  Copyright (c) 2015年 autonavi. All rights reserved.
//

#import "AppDelegate.h"
#include<objc/runtime.h>
#import <objc/message.h>

extern void *createDataSource() ;

extern void *createDelegate() ;

extern id navController;

@interface AppDelegate ()<UITableViewDataSource>

@end

@implementation AppDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"test"];
    cell.textLabel.text = @"a";
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 100;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    SEL selector;
    Class windowClass = (Class)objc_getClass("UIWindow");
    void * windowInstance = class_createInstance(windowClass, 0);
    selector = sel_registerName("initWithFrame:");
    windowInstance = objc_msgSend(windowInstance, selector,CGRectMake(568, 320, 0, 0));

    Class TableViewController = (Class)objc_getClass("UITableViewController");
    void *tableViewController = class_createInstance(TableViewController, 0);
    selector = sel_registerName("initWithStyle:");
    tableViewController = objc_msgSend(tableViewController, selector,UITableViewStylePlain);
    selector = sel_registerName("tableView");
    UITableView *tableView = objc_msgSend(tableViewController,selector);
    
//    tableView.dataSource = self;
    selector = sel_registerName("setDataSource:");
    void* datasource = createDataSource();
    objc_msgSend(tableView, selector,datasource);
    
    selector = sel_registerName("setDelegate:");
    void* delegate = createDelegate();
    objc_msgSend(tableView, selector,delegate);
    
    Class NavController = (Class)objc_getClass("UINavigationController");
    navController = class_createInstance(NavController,0);
    selector = sel_registerName("initWithRootViewController:");
    objc_msgSend(navController, selector,tableViewController);
    
    Class viewController = (Class)objc_getClass("UIViewController");
    id controllerInstance = class_createInstance(viewController, 0);
    
    selector = sel_registerName("setRootViewController:");
    objc_msgSend(windowInstance, selector,navController);
    //Make Key and Visiable
    objc_msgSend(windowInstance,sel_registerName("makeKeyAndVisible"));
    
    void *view =objc_msgSend(controllerInstance,sel_registerName("view"));
    
    UIColor *testColor = [UIColor redColor];
    
    const char * temp = object_getClassName(view);
    
    selector = sel_registerName("setBackgroundColor:");
//    [myView setBackgroundColor:testColor];
        objc_msgSend(view,selector,testColor);
    return YES;
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end

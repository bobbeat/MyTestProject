//
//  main.m
//  runtimetest
//
//  Created by gaozhimin on 15/7/31.
//  Copyright (c) 2015年 autonavi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

#import <objc/runtime.h>
#import <objc/message.h>
#import <stdio.h>
//extern int UIApplicationMain (int argc,char *argv[],void *principalClassName,void *delegateClassName);


//struct Rect {
//    float x;
//    float y;
//    float width;
//    float height;
//};
//typedef struct Rect Rect;




id navController;
static int numberOfRows =100;



NSInteger tableView_numberOfRowsInSection(id self,SEL selector, void *tblview,int section) {
    return numberOfRows;
}

NSInteger tableView_numberOfSectionsInTableView(id self,SEL selector, void *tblview){
    return 1;
}

void *tableView_cellForRowAtIndexPath(void *receiver,struct objc_selector *selector, void *tblview,void *indexPath) {
    Class TableViewCell = (Class)objc_getClass("UITableViewCell");
    void *cell = class_createInstance(TableViewCell,0);
    objc_msgSend(cell, sel_registerName("init"));
    char buffer[7];
    int row = (int) objc_msgSend(indexPath, sel_registerName("row"));
    sprintf (buffer, "Row %d", row);
    Class myclass = objc_getClass("NSString");
    SEL selector1 = sel_registerName("stringWithUTF8String:");
    
    NSString *tamp = @"";
    void *labelText =objc_msgSend(myclass,selector1,buffer);
    
    void *outValue = NULL;
    Ivar var = object_getInstanceVariable(cell, "_textLabel", &outValue);
    void *islable = object_getIvar(cell, var);
    
    UILabel *lable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    lable.text = @"aa";
    lable.textColor = [UIColor redColor];
    object_setIvar(cell, var, lable);
//    void *label = objc_msgSend(cell, sel_registerName("textLable"));
//    selector1 = sel_registerName("setText:");
//    objc_msgSend(outValue,selector1 ,@"a");
//    UITableViewCell cell2;cell2.textLabel;
//    UITableView
    return cell;
}

void tableView_didSelectRowAtIndexPath(void *receiver,struct objc_selector *selector, void *tblview,void *indexPath) {
    Class ViewController = (Class)objc_getClass("UIViewController");
    void * vc = class_createInstance(ViewController,0);
    objc_msgSend(vc, sel_registerName("init"));
    char buffer[8];
    int row = (int) objc_msgSend(indexPath, sel_registerName("row"));
    sprintf (buffer, "Item %d", row);
//    void *label =objc_msgSend(objc_getClass("NSString"),sel_registerName("stringWithUTF8String:"),buffer);
    void *label = @"aaa";
//    objc_msgSend(vc, sel_registerName("setTitle:"),label);
    objc_msgSend(navController,sel_registerName("pushViewController:animated:"),vc,1);
}

void *createDataSource() {
    Class superclass = (Class)objc_getClass("NSObject");
    Class DataSource = objc_allocateClassPair(superclass,"DataSource1",0);
    BOOL sign = class_addMethod(DataSource,sel_registerName("tableView:numberOfRowsInSection:"), (IMP)tableView_numberOfRowsInSection,nil);
    BOOL sign1 = class_addMethod(DataSource,sel_registerName("numberOfSectionsInTableView:"), (IMP)tableView_numberOfSectionsInTableView,nil);
    BOOL sign2 = class_addMethod(DataSource,sel_registerName("tableView:cellForRowAtIndexPath:"), (IMP)tableView_cellForRowAtIndexPath,nil);
    objc_registerClassPair(DataSource);
    return class_createInstance(DataSource,0);
}

void * createDelegate() {
    Class superclass = (Class)objc_getClass("NSObject");
    Class DataSource = objc_allocateClassPair(superclass,"Delegate1",0);
    class_addMethod(DataSource,sel_registerName("tableView:didSelectRowAtIndexPath:"), (void(*))tableView_didSelectRowAtIndexPath,nil);
    objc_registerClassPair(DataSource);
    return class_createInstance(DataSource,0);
}



void applicationdidFinishLaunching(id self, SEL _cmd, void *application) {
    
    Class windowClass = (Class)objc_getClass("UIWindow");
    void * windowInstance = class_createInstance(windowClass, 0);
    SEL selector = sel_registerName("initWithFrame:");
    windowInstance = objc_msgSend(windowInstance, selector,CGRectMake(568, 320, 0, 0));
    
    
    //Create Table View
    Class TableViewController = (Class)objc_getClass("UITableViewController");
    void *tableViewController = class_createInstance(TableViewController, 0);
    selector = sel_registerName("init");
    tableViewController = objc_msgSend(tableViewController, selector);
    selector = sel_registerName("tableView");
    void *tableView = objc_msgSend(tableViewController,selector);
    selector = sel_registerName("setDataSource:");
    objc_msgSend(tableView, selector,createDataSource());
    
    selector = sel_registerName("setDelegate:");
    objc_msgSend(tableView, selector,createDelegate());
    
    Class NavController = (Class)objc_getClass("UINavigationController");
    navController = class_createInstance(NavController,0);
    selector = sel_registerName("initWithRootViewController:");
    objc_msgSend(navController, selector,tableViewController);
    
    Class viewController = (Class)objc_getClass("UIViewController");
    id controllerInstance = class_createInstance(viewController, 0);
    
    selector = sel_registerName("setRootViewController:");
    objc_msgSend(windowInstance, selector,navController);
    //Make Key and Visiable
    selector = sel_registerName("makeKeyAndVisible");
    objc_msgSend(windowInstance,selector);
    
//    UIViewController *ctl = controllerInstance;
//    ctl.view.backgroundColor = [UIColor redColor];
    
    selector = sel_registerName("view");
    void *view =objc_msgSend(controllerInstance,selector);
    
    UIView *ctlView = view;
    ctlView.backgroundColor = [UIColor redColor];
    
//    UIColor *testColor = [UIColor greenColor];
////    const char * temp = object_getClassName(view);
//    selector = sel_registerName("setBackgroundColor:");
////    //    [myView setBackgroundColor:testColor];
//    objc_msgSend(view,selector,testColor);
    
}


//Create an class named "AppDelegate", and return it's name as an instance of class NSString
NSString *createAppDelegate() {
    Class appClass = objc_allocateClassPair((Class)objc_getClass("UIResponder"),"AppDelegate2",0);
    SEL selName = sel_registerName("application:didFinishLaunchingWithOptions:");
    BOOL sign = class_addMethod(appClass, selName, (IMP)applicationdidFinishLaunching,nil);
    BOOL sign1 = class_respondsToSelector(appClass, selName);
    id instance = class_createInstance(appClass, 0);
    objc_registerClassPair(appClass);
    return @"AppDelegate";
}

@interface AppDelegate1 : UIResponder <UIApplicationDelegate>



@end

@implementation AppDelegate1

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    Class windowClass = (Class)objc_getClass("UIWindow");
    void * windowInstance = class_createInstance(windowClass, 0);
    SEL selector = sel_registerName("initWithFrame:");
    windowInstance = objc_msgSend(windowInstance, selector,CGRectMake(568, 320, 0, 0));
    
    Class viewController = (Class)objc_getClass("UIViewController");
    id controllerInstance = class_createInstance(viewController, 0);
    
    selector = sel_registerName("setRootViewController:");
    objc_msgSend(windowInstance, selector,controllerInstance);
    //Make Key and Visiable
    objc_msgSend(windowInstance,sel_registerName("makeKeyAndVisible"));
    
    void *view =objc_msgSend(controllerInstance,sel_registerName("view"));
    
    UIColor *testColor = [UIColor redColor];
    
    const char * temp = object_getClassName(view);
    
    selector = sel_registerName("setBackgroundColor:");
    //    [myView setBackgroundColor:testColor];
    objc_msgSend(view,selector,testColor);return YES;
    
    //Create Table View
    Class TableViewController = (Class)objc_getClass("UITableViewController");
    void *tableViewController = class_createInstance(TableViewController, 0);
    objc_msgSend(tableViewController, sel_registerName("init"));
    void *tableView = objc_msgSend(tableViewController,sel_registerName("tableView"));
    objc_msgSend(tableView, sel_registerName("setDataSource:"),createDataSource());
    objc_msgSend(tableView, sel_registerName("setDelegate:"),createDelegate());
    
    viewController = (Class)objc_getClass("UIViewController");
    controllerInstance = class_createInstance(viewController, 0);
    
    
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:controllerInstance];
    
    navController = navi;
//    Class NavController = (Class)objc_getClass("UINavigationController");
//    navController = class_createInstance(NavController,0);
//    selector = sel_registerName("initWithRootViewController:");
//    sign = class_respondsToMethod(NavController,selector);
//
//    objc_msgSend(navController,selector,controllerInstance);
    
    //Add Table View To Window
    
    UIViewController *ctl2 = [[UIViewController alloc] init];
    ctl2.view.backgroundColor = [UIColor redColor];
    selector = sel_registerName("setRootViewController:");
    BOOL responsesign = class_respondsToMethod(windowClass,selector);
    objc_msgSend(windowInstance, selector,ctl2);
    objc_msgSend(windowInstance,sel_registerName("makeKeyAndVisible"));
    
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


int main(int argc, char * argv[]) {
    @autoreleasepool {
        return UIApplicationMain(argc, argv,0,createAppDelegate());
    }
}

//
//  AppDelegate.h
//  NavigationTest
//
//  Created by gaozhimin on 14-8-28.
//  Copyright (c) 2014年 autonavi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : NSObject <UIApplicationDelegate>
{
    UIWindow *window;
	UINavigationController *navigationController;
    
}
@property (nonatomic,retain) IBOutlet UINavigationController *navigationController;
@property (nonatomic, retain) IBOutlet UIWindow *window;
@end
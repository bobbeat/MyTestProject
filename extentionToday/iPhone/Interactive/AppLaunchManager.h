//
//  AppLaunchManager.h
//  AutoNavi
//
//  Created by gaozhimin on 14-9-18.
//
//

#import <Foundation/Foundation.h>

@interface AppLaunchManager : NSObject

+ (instancetype)SharedInstance;

- (void)launchAppWith:(UIWindow *)window navigation:(UINavigationController *)navigation;

@end

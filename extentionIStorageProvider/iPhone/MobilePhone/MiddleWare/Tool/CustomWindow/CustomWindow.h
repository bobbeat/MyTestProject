//
//  CustomWindow.h
//  AutoNavi
//
//  Created by gaozhimin on 14-3-15.
//
//

#import <UIKit/UIKit.h>

@interface CustomWindow : UIWindow


+ (UIWindow *)existCustomWindow;


/*
 @param
 rootViewController     加入UIWindow中的rootViewController
 modalViewController    当前页面的Controller
 */

+ (void)CreatCustomWindowWithRootViewController:(UIViewController *)rootViewController ModalViewController:(UIViewController *)modalViewController;

+ (void)DestroyCustomWindow;

@end

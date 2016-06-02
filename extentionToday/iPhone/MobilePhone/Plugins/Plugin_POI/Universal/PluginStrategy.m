//
//  PluginStrategy.m
//  AutoNavi
//
//  Created by huang on 13-9-2.
//
//

#import "PluginStrategy.h"

@implementation PluginStrategy
+(PluginStrategy*)sharedInstance
{
    static PluginStrategy *startegy=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        startegy=[[PluginStrategy alloc] init];
    });
    return startegy;
}

-(void)allocModuleWithName:(NSString*)moduleName withObject:(NSObject*)object
{
    id<ModuleDelegate> delegate=(id<ModuleDelegate>)[PluginFactory allocModuleWithName:moduleName];
    [delegate enter:object];
}
//创建ViewController
-(void)allocViewControllerWithName:(NSString*)viewControllerName withType:(int)type withViewController:(UIViewController*)controller
{
    UIViewController *viewController=[PluginFactory allocViewControllerWithName:viewControllerName];
    if (type==0) {
        //解决导航条会闪一下
        controller.navigationController.navigationBarHidden = NO;
        [controller.navigationController pushViewController:viewController animated:YES];
    }
    else
    {
        [controller presentModalViewController:viewController animated:YES];
    }
}
@end

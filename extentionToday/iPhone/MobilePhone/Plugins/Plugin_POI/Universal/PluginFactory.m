//
//  PluginFactory.m
//  AutoNavi
//
//  Created by huang on 13-9-2.
//
//

#import "PluginFactory.h"
#import "POIDefine.h"
#import "UINavigationBar+SetBackground.h"
#import "VCCustomNavigationBar.h"
@implementation PluginFactory
//+(PluginFactory*)sharedInstance
//{
//    static PluginFactory *factory=nil;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        factory=[[PluginFactory alloc] init];
//    });
//    return factory;
//}
+(id<ModuleDelegate>)allocModuleWithName:(NSString*)moduleName
{
    id<ModuleDelegate> moduleDelegate;
    CALLOC_WITH_NAME(moduleName, moduleDelegate);
    return [(id)moduleDelegate autorelease];
}
//创建ViewController
+(UIViewController*)allocViewControllerWithName:(NSString*)viewControllerName
{
    UIViewController *viewController=nil;
    CALLOC_WITH_NAME(viewControllerName, viewController);
    return [viewController autorelease];
}
+(UINavigationController*)allocNavigationController:(NSString*)viewControllerName
{
   UINavigationController *naviController = [PluginFactory allocNavigationController];
    [naviController setViewControllers:@[[PluginFactory allocViewControllerWithName:viewControllerName]]];
    return naviController;
}

+(UINavigationController*)allocNavigationController
{
    UINavigationController *naviContoller=nil;
    if ([UINavigationController instancesRespondToSelector:@selector(initWithNavigationBarClass:toolbarClass:)]) {
        naviContoller=[[UINavigationController alloc] initWithNavigationBarClass:[VCCustomNavigationBar class] toolbarClass:[UIToolbar class]];
        [(VCCustomNavigationBar*)naviContoller.navigationBar setIsRotate:NO];
    }
    else{
        naviContoller=[[UINavigationController alloc] init];
        [naviContoller.navigationBar setBackgroundImage:IMAGE(@"navigatorBarBg.png",IMAGEPATH_TYPE_1)];
    }
    return [naviContoller autorelease];

}
@end

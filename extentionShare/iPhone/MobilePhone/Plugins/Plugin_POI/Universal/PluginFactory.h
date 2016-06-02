//
//  PluginFactory.h
//  AutoNavi
//
//  Created by huang on 13-9-2.
//
//

#import <Foundation/Foundation.h>
#import "ModuleDelegate.h"
@interface PluginFactory : NSObject
//+(PluginFactory*)sharedInstance;
//创建模块
+(id<ModuleDelegate>)allocModuleWithName:(NSString*)moduleName;
//创建ViewController
+(UIViewController*)allocViewControllerWithName:(NSString*)viewControllerName;
+(UINavigationController*)allocNavigationController:(NSString*)viewControllerName;
+(UINavigationController*)allocNavigationController;
@end

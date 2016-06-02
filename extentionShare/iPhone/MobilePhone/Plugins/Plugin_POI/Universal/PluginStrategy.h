//
//  PluginStrategy.h
//  AutoNavi
//
//  Created by huang on 13-9-2.
//
//

#import <Foundation/Foundation.h>
#import "PluginFactory.h"

@interface PluginStrategy : NSObject
+(PluginStrategy*)sharedInstance;
-(void)allocModuleWithName:(NSString*)moduleName withObject:(NSObject*)object;
//创建ViewController
//type 0表示pushViewController 1表示presentModalViewController
-(void)allocViewControllerWithName:(NSString*)viewControllerName withType:(int)type withViewController:(UIViewController*)controller;
@end

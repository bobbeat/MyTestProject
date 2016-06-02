//
//  Plugin_Setting.m
//  AutoNavi
//
//  Created by huang on 13-8-15.
//
//

#import "Plugin_Setting.h"
#import "SettingSettingViewControllerTempViewController.h"
#import "PluginStrategy.h"
#import "SettingNavigationViewController.h"
#import "SettingNewVersionIntroduceViewController.h"
@implementation Plugin_Setting

/*!
  @brief 相应模块调用该方法进入该模块
  @param param: NSDictionary 包含        key                 value
                                        controller      --    上一级导航页面    当type为新功能介绍的时候传UIViewController
                                        controllertype   0:设置界面  1：导航设置 2新功能介绍
                                
  @return 0失败;1成功
  */
-(int) enter:(NSObject *)param
{
    if([param isKindOfClass:[NSDictionary class]])
    {
             int type=[[(NSDictionary *)param objectForKey:@"controllertype"] intValue];
        if ([[(NSDictionary *)param objectForKey:@"controller"] isKindOfClass:[UINavigationController class]])
        {
            UINavigationController *navigation=[(NSDictionary *)param objectForKey:@"controller"];
            navigation.navigationBarHidden=NO;/*为了解决ios7下，导航栏会闪一下的问题*/
       
            if (type == 0)
            {
                SettingSettingViewControllerTempViewController *moreTabBar=[[SettingSettingViewControllerTempViewController alloc] init];
                [navigation pushViewController:moreTabBar animated:YES];
                [moreTabBar release];
            }
            else if (type == 1)
            {
                SettingNavigationViewController *resetViewController=[[SettingNavigationViewController alloc] init];
                [navigation pushViewController:resetViewController animated:YES];
                [resetViewController release];
            }
            
            return YES;
        }
        else if ([[(NSDictionary *)param objectForKey:@"controller"] isKindOfClass:[UIViewController class]])
        {
            if(type==2)
            {

                UIViewController *viewController=(UIViewController*)[(NSDictionary *)param objectForKey:@"controller"] ;
                SettingNewVersionIntroduceViewController *newVersion=[[SettingNewVersionIntroduceViewController alloc] init];
                [viewController presentModalViewController:newVersion animated:NO];
                [newVersion release];
            }

        }
    }
    return NO;
    
}
-(NSString*)viewControllerName
{
    return @"SettingSettingViewControllerTempViewController";
}
// 导航模块调用该方法离开子模块（一般情况下，子模块是调用backToNavi回到导航主模块）
// 返回值：0失败；1成功
-(int) leave
{
    return 0;
}

// 导航模块调用该方法终止子模块（在导航模块因某种原因而需要退出程序，而此时子模块可能还处于执行中，此时导航模块将调用该方法）
// 返回值：0失败；1成功
-(int) exit
{
    return 0;
}


@end

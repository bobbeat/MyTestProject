//
//  Plugin_Main.m
//  AutoNavi
//
//  Created by jiangshu.fu on 13-9-20.
//
//

#import "Plugin_Main.h"
#import "RoutePlanningAndDetailViewController.h"

@implementation Plugin_Main

/*!
  @brief 相应模块调用该方法进入该模块
  @param param: NSDictionary 包含        key                 value
 backNaviTitle   --   导航栏返按钮回标题
 controller      --   上一级导航页面
  @return 0失败;1成功
  */
-(int) enter:(NSObject *)param
{
    if([param isKindOfClass:[NSDictionary class]])
    {
        if ([[(NSDictionary *)param objectForKey:@"parma"] isEqualToString:@"RoutePlanningAndDetailViewController"] ) {
            RoutePlanningAndDetailViewController *controller = [[RoutePlanningAndDetailViewController alloc] init];
//            NSArray *array = [NSArray arrayWithObjects:[((UINavigationController *)[(NSDictionary *)param objectForKey:@"controller"]).viewControllers objectAtIndex:0], controller,nil];
//            [[(NSDictionary *)param objectForKey:@"controller"]setViewControllers:array animated:NO];
            controller.isAnimate = [[(NSDictionary *)param objectForKey:@"animate"] boolValue];
            [[(NSDictionary *)param objectForKey:@"controller"] pushViewController:controller animated:controller.isAnimate];
            [controller release];
            return YES;
        }
    }
    return NO;
}


-(NSString *)viewControllerName
{
    return [[RoutePlanningAndDetailViewController class] description];
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

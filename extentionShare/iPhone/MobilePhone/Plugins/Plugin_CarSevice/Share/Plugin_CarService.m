//
//  Plugin_CarService.m
//  AutoNavi
//
//  Created by gaozhimin on 13-8-15.
//
//

#import "Plugin_CarService.h"
#import "CarServiceViewController.h"
#import "HtmlFiveViewController.h"

@implementation Plugin_CarService

/*!
  @brief 相应模块调用该方法进入该模块
  @param param: NSArray 包含
 navigationController   -- 加载视图的UINavigationController
 
  @param param: NSDictionary
 
 
  @return 0失败;1成功
  */
-(int) enter:(NSObject *)param
{
    if ([param isKindOfClass:[NSArray class]])
    {
        NSArray* values=(NSArray*)param;
        
        if ([values count] > 0 && [[values objectAtIndex:0] isKindOfClass:[UINavigationController class]])
        {
            UINavigationController* navigation =(UINavigationController*)[values objectAtIndex:0];
            CarServiceViewController *ctl = [[CarServiceViewController alloc] init];
            [navigation presentModalViewController:ctl animated:YES];
            [ctl release];
            return 1;
        }
    }
    else if([param isKindOfClass:[NSDictionary class]])
    {
        if([((NSDictionary *)param) count] == 4
           && [[(NSDictionary *)param objectForKey:PLUGIN_CARSERVICE_CONTROLLER] isKindOfClass:[UIViewController class]])
        {
            //无完整数据时模块入口
            HtmlFiveViewController *ctl = [[HtmlFiveViewController alloc]
                                                    initWithWebUrl:[(NSDictionary *)param objectForKey:PLUGIN_CARSERVICE_WEBURL]
                                                    withTitle:[(NSDictionary *)param objectForKey:PLUGIN_CARSERVICE_WEBTITLE]
                                                    withBrowser:[[(NSDictionary *)param objectForKey:PLUGIN_CARSERVICE_ISBROWSER] boolValue]];
            
            [[(NSDictionary *)param objectForKey:@"controller"] presentModalViewController:ctl animated:YES];
            [ctl release];
            return YES;
        }
    }

    return 0;
}

- (NSString *)viewControllerName
{
    return [[CarServiceViewController class] description];
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

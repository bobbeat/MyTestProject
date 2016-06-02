//
//  Plugin_DrivingTrack.m
//  AutoNavi
//
//  Created by longfeng.huang on 14-6-15.
//
//

#import "Plugin_DrivingTrack.h"
#import "DrivingTrackDetailViewController.h"
#import "DrivingTrackMapDetailViewController.h"

@implementation Plugin_DrivingTrack

/*!
  @brief 相应模块调用该方法进入该模块
  @param param: NSDictionary 包含        key                 value
 controller      --    上一级导航页面    当type为新功能介绍的时候传UIViewController
 controllertype
 
  @return 0失败;1成功
  */
-(int)enter:(NSObject *)param
{
    if([param isKindOfClass:[NSDictionary class]])
    {
        int type=[[(NSDictionary *)param objectForKey:@"controllertype"] intValue];
        
        if ([[(NSDictionary *)param objectForKey:@"controller"] isKindOfClass:[UIViewController class]])
        {
            UINavigationController *navigationController=(UIViewController*)[(NSDictionary *)param objectForKey:@"controller"] ;
            
            if (type == 1)
            {
               
                
            }
            else if (type == 2)
            {
                
            }
            
        }
    }
    return NO;
    
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

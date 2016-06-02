//
//  Plugin_Track.m
//  AutoNavi
//
//  Created by jiangshu.fu on 13-8-14.
//
//

#import "Plugin_Track.h"
#import "TrackManageViewController.h"

@implementation Plugin_Track

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
        if([((NSDictionary *)param) count] == 2
           && [[(NSDictionary *)param objectForKey:@"controller"] isKindOfClass:[UINavigationController class]])
        {
            //无完整数据时模块入口
            NSString *backNaviTitle = [(NSDictionary *)param objectForKey:@"backNaviTitle"];
    
            TrackManageViewController *trackManage = [[TrackManageViewController alloc] initWithbackNaviTitle:backNaviTitle];
            [[(NSDictionary *)param objectForKey:@"controller"] pushViewController:trackManage animated:YES];
            [trackManage release];
            return YES;
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
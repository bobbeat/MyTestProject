//
//  Plugin_UserFeedBack.h
//  AutoNavi
//
//  Created by weisheng on 14-6-11.
//
//

#import <Foundation/Foundation.h>

@interface Plugin_UserFeedBack : NSObject
/*!
  @brief 相应模块调用该方法进入该模块
  @param param: NSDictionary 包含        key                 value
 controller      --    上一级导航页面    当type为新功能介绍的时候传UIViewController
 controllertype  1->用户反馈 2->POI点报错
 
  @return 0失败;1成功
  */
-(int)enter:(NSObject *)param;
@end

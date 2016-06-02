//
//  Plugin_Account.h
//  AutoNavi
//
//  Created by gaozhimin on 13-5-10.
//
//

#import <Foundation/Foundation.h>
#import "ModuleDelegate.h"
#import "CustomWindow.h"

@interface Plugin_Account : NSObject<ModuleDelegate>

/*
    @brief 获取帐号信息 根据 index
  index     说明              返回值类型
    0:   获取用户登陆状态      NSNumber  注：此判断与用户id无关
    1:   获取用户登陆状态      NSNumber  注：此判断与用户id有关，不存在用户id，将会把登陆状态置为未登录
    2:   获取用户ID           NSString
    3:   获取用户名           NSString
    4:   获取圆形图片          UIImage    未登录返回默认图片 登陆返回登陆图片
    5:   获取用户sid令牌       NSString    
 */
+ (id)getAccountInfoWith:(int)index;

@end

//
//  LoginStorage.h
//  RoadFreightage
//
//  Created by yu.liao on 15/6/8.
//  Copyright (c) 2015年 WuKongSuYun. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LoginResponse;

@interface LoginStorage : NSObject

/*!
 @brief 保存用户数据至本地
 @param data        用户数据
 */
+ (void)saveUserData:(LoginResponse *)data;

/*!
 @brief 获取用户数据
 @return   用户数据
 */
+ (LoginResponse *)getUserData;

/*!
 @brief 删除本地用户数据
 */
+ (void)deleteLocalUserData;

/*!
 @brief 获取用户登陆状态
 */
+ (BOOL)getUserLoginStatus;

@end

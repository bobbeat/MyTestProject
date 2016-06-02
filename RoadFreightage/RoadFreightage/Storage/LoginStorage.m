//
//  LoginStorage.m
//  RoadFreightage
//
//  Created by yu.liao on 15/6/8.
//  Copyright (c) 2015年 WuKongSuYun. All rights reserved.
//

#import "LoginStorage.h"
#import "Constants.h"
#import "SYNetObj.h"
#import "NSObject+Category.h"

#define LocalUserDataPath [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/accountinfo.dat"]

@implementation LoginStorage

/*!
 @brief 保存用户数据至本地
 @param data        用户数据
 */
+ (void)saveUserData:(LoginResponse *)data
{
    NSDictionary *userDic = [data getProperties];
    
    NSMutableData *dataForSave = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:dataForSave];
    [archiver encodeObject:userDic forKey:@"Some Key Value"];
    [archiver finishEncoding];
    BOOL sign = [dataForSave writeToFile:LocalUserDataPath atomically:YES];
    if (sign) {
        NSLog(@"保存用户数据成功 路径= %@",LocalUserDataPath);
    }
}

/*!
 @brief 获取用户数据
 @return   用户数据
 */
+ (LoginResponse *)getUserData
{
    LoginResponse *response = [[LoginResponse alloc] init];
    
    NSData *data = [[NSMutableData alloc] initWithContentsOfFile:LocalUserDataPath];
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSDictionary *userDic = [unarchiver decodeObjectForKey:@"Some Key Value"];
    [unarchiver finishDecoding];
    [response setPropertiesWirh:userDic];
    return response;
}
/*!
 @brief 删除本地用户数据
 */
+ (void)deleteLocalUserData
{
    NSError *error = nil;
    [[NSFileManager defaultManager] removeItemAtPath:LocalUserDataPath error:&error];
}

/*!
 @brief 获取用户登陆状态
 */
+ (BOOL)getUserLoginStatus
{
    return [[NSFileManager defaultManager] fileExistsAtPath:LocalUserDataPath];
}

@end

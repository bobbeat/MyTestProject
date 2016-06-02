//
//  ZJNetObj.m
//  SuYun
//
//  Created by yu.liao on 15/5/15.
//  Copyright (c) 2015年 yu.liao. All rights reserved.
//

#import "ZJNetObj.h"
#include <sys/time.h>
#pragma mark - ZJRequest

@implementation ZJRequest

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.sid = nil;
        self.userid = 0;
        self.usertype = nil;
        self.platform = @"IOS";
        
        unsigned long long t;
        struct timeval tv_begin;
        gettimeofday(&tv_begin, NULL);
        t = (unsigned long long)1000000 * (tv_begin.tv_sec) + tv_begin.tv_usec;
        unsigned long long uTickCount = (unsigned long long)(t / 1000);
        unsigned long long time = uTickCount;
        self.time = [NSString stringWithFormat:@"%llu",time];
    }
    return self;
}

@end

@implementation ZJResponse

- (instancetype)init
{
    self = [super init];
    if (self) {

    }
    return self;
}

@end

@implementation UserInfoObject
- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}


@end

#pragma mark - RegitsterRequest

@implementation RegitsterRequest
- (instancetype)init
{
    self = [super init];
    if (self) {

    }
    return self;
}


@end

@implementation RegitsterResponse


@end

#pragma mark - GetUserInfoRequest

@implementation GetUserInfoRequest
- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}


@end

@implementation GetUserInfoResponse


@end

#pragma mark - UpdateUserInfoRequest

@implementation UpdateUserInfoRequest
- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}


@end

@implementation UpdateUserInfoResponse


@end

#pragma mark - AddCarInfoRequest

@implementation AddCarInfoRequest
- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}


@end

@implementation AddCarInfoResponse


@end

#pragma mark -UpdateCarInfoRequest

@implementation UpdateCarInfoRequest
- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}


@end

@implementation UpdateCarInfoResponse


@end

#pragma mark - GetCarInfoRequest

@implementation GetCarInfoRequest
- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}


@end

@implementation GetCarInfoResponse


@end

#pragma mark - LoginRequest

@implementation LoginRequest

- (instancetype)init
{
    self = [super init];
    if (self) {
        
       
    }
    return self;
}

@end

@implementation LoginResponse

- (instancetype)init
{
    self = [super init];
    if (self) {

    }
    return self;
}

@end

#pragma mark - GetCityInfoRequest

@implementation GetCityInfoRequest

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

@end

@implementation CityInfoObject



@end

@implementation GetCityInfoResponse

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.cityInfoArray = [NSMutableArray array];
    }
    return self;
}

@end

#pragma mark - GetTaskResRequest

/*!
 @brief 获取资源
 */
@implementation GetTaskResRequest


@end

@implementation GetTaskResResponse


@end

#pragma mark - GetUserResRequest
/*!
 @brief 获取用户资源接口
 */
@implementation GetUserResRequest

@end

@implementation GetUserResResponse


@end

#pragma mark - GetTaskDetailRequest

/*!
 @brief 获取任务详情
 */
@implementation GetTaskDetailRequest


@end

@implementation GetTaskDetailResponse
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.cityInfoArray = [NSMutableArray array];
    }
    return self;
}


@end

#pragma mark - GetUserTaskInfoRequest

/*!
 @brief 获取用户任务信息
 */
@implementation GetUserTaskInfoRequest

@end

@implementation GetUserTaskInfoResponse

@end

#pragma mark - ApplyTaskRequest

/*!
 @brief 申请任务接口
 */
@implementation ApplyTaskRequest 


@end

@implementation ApplyTaskResponse


@end

#pragma mark - LogoutRequest

@implementation LogoutRequest

- (instancetype)init
{
    self = [super init];
    if (self) {

    }
    return self;
}

@end

@implementation LogoutResponse

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

@end

#pragma mark - VerifyCodeRequest

@implementation VerifyCodeRequest

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.phone = nil;
    }
    return self;
}


@end

@implementation VerifyCodeResponse

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.reserve = nil;
    }
    return self;
}

@end

#pragma mark - UploadImageRequest

@implementation UploadImageRequest

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}


@end

@implementation UploadImageResponse

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}


@end



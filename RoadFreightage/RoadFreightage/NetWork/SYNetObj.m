//
//  SYNetObj.m
//  SuYun
//
//  Created by yu.liao on 15/5/15.
//  Copyright (c) 2015年 yu.liao. All rights reserved.
//

#import "SYNetObj.h"

#pragma mark - SYRequest

@implementation SYRequest

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.sid = nil;
        self.userid = 0;
        self.usertype = nil;
        self.platform = @"IOS";
    }
    return self;
}

@end

@implementation SYResponse

- (instancetype)init
{
    self = [super init];
    if (self) {

    }
    return self;
}

@end

#pragma mark - LoginRequest

@implementation LoginRequest

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.phone = nil;
        self.code = nil;
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

#pragma mark - DriverReportStatusRequest

@implementation DriverReportStatusRequest

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}


@end

@implementation DriverReportStatusResponse

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.reserve = nil;
    }
    return self;
}


@end

#pragma mark - DriverAuthRequest

@implementation DriverAuthRequest

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}


@end

@implementation DriverAuthResponse

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

@end

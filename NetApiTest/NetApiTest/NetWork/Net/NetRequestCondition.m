//
//  NetRequestCondition.m
//  SuYun
//
//  Created by yu.liao on 15/5/19.
//  Copyright (c) 2015年 yu.liao. All rights reserved.
//

#import "NetRequestCondition.h"

@implementation NetRequestCondition

+ (instancetype)requestCondition
{
    NetRequestCondition *condition = [[NetRequestCondition alloc] init];
    return condition ;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.urlParams = nil;
        self.baceURL = nil;
        self.bodyData = nil;
        self.httpHeaderFieldParams = nil;
        self.httpMethod = nil;
        self.requestID = 0;
        self.timeout = 0;
    }
    return self;
}


@end

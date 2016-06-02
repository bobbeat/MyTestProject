//
//  NetBaseRequestCondition.m
//  AutoNavi
//
//  Created by gaozhimin on 13-7-25.
//
//

#import "NetBaseRequestCondition.h"

@implementation NetBaseRequestCondition

@synthesize urlParams,baceURL,requestType,bodyData,httpHeaderFieldParams,httpMethod,timeout;

+ (id)requestCondition
{
    NetBaseRequestCondition *condition = [[NetBaseRequestCondition alloc] init];
    return [condition autorelease];
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
        self.requestType = 0;
        self.timeout = 0;
    }
    return self;
}

- (void)dealloc
{
    if (urlParams)
    {
        [urlParams release];
        urlParams = nil;
    }
    if (baceURL)
    {
        [baceURL release];
        baceURL = nil;
    }
    if (bodyData)
    {
        [bodyData release];
        bodyData = nil;
    }
    if (httpHeaderFieldParams)
    {
        [httpHeaderFieldParams release];
        httpHeaderFieldParams = nil;
    }
    if (httpMethod)
    {
        [httpMethod release];
        httpMethod = nil;
    }
    [super dealloc];
}

@end

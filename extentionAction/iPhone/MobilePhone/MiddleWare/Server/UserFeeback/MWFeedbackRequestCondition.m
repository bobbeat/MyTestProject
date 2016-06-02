//
//  AWFeedbackRequestCondition.m
//  AutoNavi
//
//  Created by gaozhimin on 13-7-25.
//
//

#import "MWFeedbackRequestCondition.h"

@implementation MWFeedbackBaseCondition


@synthesize errorDesc,qq,tel;

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)dealloc
{
    self.errorDesc = nil;
    self.qq = nil;
    self.tel = nil;
    [super dealloc];
}

@end

@implementation MWFeedbackDataCondition

@synthesize dataType,cityName,cityCode,errorType,name;
- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)dealloc
{
    self.cityCode = nil;
    self.cityName = nil;
    self.errorType = nil;
    self.name = nil;
    [super dealloc];
}

@end

@implementation MWFeedbackFunctionCondition
@synthesize pic,questionType;

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)dealloc
{
    self.pic = nil;
    [super dealloc];
}
@end

@implementation MWFeedbackAdviceCondition
@synthesize pic;

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)dealloc
{
    self.pic = nil;
    [super dealloc];
}
@end


@implementation MWFeedbackQueryListCondition

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}
@end

@implementation MWFeedbackQueryDetailCondition
@synthesize answerId,funcType;

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)dealloc
{
    self.answerId = nil;
    [super dealloc];
}
@end

@implementation MWFeedbackDeleteOneCondition
@synthesize answerId;

- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)dealloc
{
    self.answerId = nil;
    [super dealloc];
}
@end

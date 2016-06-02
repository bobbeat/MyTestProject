//
//  MWVoice.m
//  AutoNavi
//
//  Created by gaozhimin on 13-7-31.
//
//

#import "MWVoiceResult.h"

@implementation MWVoiceOption

@synthesize resultType,latitude,longitude,lAdminCode;

- (id)init
{
    self = [super init];
    if (self)
    {
        self.resultType = 0;
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

@end

@implementation MWVoiceResult

@synthesize contentArray,keyArray,cmdid,cmdtxt,nNumberOfItem,voiceDataType;

- (id)init
{
    self = [super init];
    if (self)
    {
        
    }
    return self;
}

- (void)dealloc
{
    self.contentArray = nil;
    self.keyArray = nil;
    self.cmdtxt = nil;
    [super dealloc];
}
@end

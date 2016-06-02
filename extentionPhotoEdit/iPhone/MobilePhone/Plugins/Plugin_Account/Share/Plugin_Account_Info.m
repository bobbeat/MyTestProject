//
//  Plugin_Account_Info.m
//  AutoNavi
//
//  Created by gaozhimin on 12-12-18.
//
//

#import "Plugin_Account_Info.h"
#import "Plugin_Account_Globall.h"
#import "ANParamValue.h"


Plugin_Account_Info *g_GloballInstance = nil;

@implementation Plugin_Account_Info

@synthesize m_kAccount;
@synthesize m_PASSWORD;
@synthesize m_TOKEN_ID;
@synthesize m_USER_NAME;
@synthesize m_UUID;
@synthesize m_head;
@synthesize m_nickName,m_weiboUUID,m_tpusername;

+ (id)SharedGloballInstance
{
    if (g_GloballInstance == nil)
    {
        g_GloballInstance = [[Plugin_Account_Info alloc] init];
    }
    return g_GloballInstance;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        self.m_kAccount = @"";
        self.m_PASSWORD = @"";
        self.m_TOKEN_ID = @"";
        self.m_USER_NAME = @"";
        self.m_UUID = @"";
        self.m_nickName = @"";
        self.m_head =  IMAGE(@"non_head.png", IMAGEPATH_TYPE_1);
        self.m_weiboUUID = @"";
        self.m_tpusername = @"";
    }
    return self;
}

- (void)dealloc
{
    if (m_head)
    {
        [m_head release];
        m_head = nil;
    }
    [m_kAccount release];
    [m_PASSWORD release];
    [m_TOKEN_ID release];
    [m_USER_NAME release];
    [m_UUID release];
    [super dealloc];
}

@end
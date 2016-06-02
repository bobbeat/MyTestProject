//
//  MWAccountDealData.m
//  AutoNavi
//
//  Created by gaozhimin on 13-9-8.
//
//

#import "MWAccountDealData.h"
#import "MWAccountParseData.h"
#import "GDBL_Account.h"
#import "MWHistoryRoute.h"
#import "DringTracksManage.h"

static NSMutableSet *g_dealDelegateSet = nil;
Class object_getClass(id object);

@interface MWAccountDealData()
{
    id<NetReqToViewCtrDelegate> _delegate;
    RequestType _requestType;
}

@property (nonatomic,assign) RequestType requestType;
@property (nonatomic,assign) id<NetReqToViewCtrDelegate> delegate;
@property (nonatomic,assign) Class originalClass;

@end

@implementation MWAccountDealData

@synthesize delegate = _delegate,requestType = _requestType,originalClass;

- (id)init
{
    if (self = [super init])
    {
       
    }
    return self;
}

- (void)dealloc
{
    self.originalClass = nil;
    self.delegate = nil;
    [super dealloc];
}

/**
 *  创建请求监听对象，处理请求结果
 *
 *	@param	type	请求类型
 *	@param	delegate	委托回调
 *
 *	@return	成功将返回监听对象，失败则返回nil，表示该请求已在进行
 */
+ (id)createDealingWith:(RequestType)type delegate:(id<NetReqToViewCtrDelegate>)delegate
{
    if (g_dealDelegateSet == nil)
    {
        g_dealDelegateSet = [[NSMutableSet alloc] init];
    }

    MWAccountDealData *deal = [[MWAccountDealData alloc] init];    //在回调中释放
    deal.requestType = type;
    deal.delegate = delegate;
    deal.originalClass = object_getClass(delegate);
    [g_dealDelegateSet addObject:deal];
    [deal release];
    return deal;
}

/**
 *	删除所有监听
 */
+ (void)clearAllDealing
{
    if (g_dealDelegateSet)
    {
        [g_dealDelegateSet removeAllObjects];
    }
}

/**
 *	删除某类请求
 *
 *	@param	type	请求类型
 */
+ (void)deletaDealingWith:(RequestType)type
{
    NSMutableSet  *temp = [[NSMutableSet alloc] init];
    for (MWAccountDealData *deal in g_dealDelegateSet)
    {
        if (deal.requestType == type)
        {
            [temp addObject:deal];
        }
    }
    [g_dealDelegateSet minusSet:temp];
    [temp release];
}
#pragma mark - private method



#pragma mark - request data handle

- (void)handleResponseData:(NSData *)data withRequestType:(RequestType) type
{
    NSDictionary *result = [MWAccountParseData GetOperationResultByData:data];
    if (type == REQ_LOGIN)
    {
        GDBL_setAccountUserID([result objectForKey:@"userid"]);
    }
    else if (type == REQ_THIRD_LOGIN)
    {
        GDBL_setAccountUserID([result objectForKey:@"tpuserid"]);
        if ([[result objectForKey:@"tpuserid"] length] > 0 && [[result objectForKey:@"userid"] intValue] > 0 )  //第三方帐号绑定高德帐号
        {
            //modify by gzm for 改变驾驶记录和历史路线的userid at 2014-11-7
            NSString *oldid = [result objectForKey:@"tpuserid"];
            NSString *newid = [result objectForKey:@"userid"];
            [[MWHistoryRoute sharedInstance] MW_ReNameGuideRouteUserIDWithUserID:oldid NewUserID:newid];
            [[DringTracksManage sharedInstance] reNamedrivingTrackUserIDWithUserID:oldid NewUserID:newid];
        }
    }
    else if(type == REQ_GET_HEAD)
    {
        Class currentClass = object_getClass(self.delegate);
        if (currentClass == self.originalClass)
        {
            
            if (_delegate && [_delegate respondsToSelector:@selector(requestToViewCtrWithRequestType:didFinishLoadingWithResult:)])
            {
                [_delegate requestToViewCtrWithRequestType:type didFinishLoadingWithResult:data];
            }
        }
        else
        {
            NSLog(@"delegate dealloc");
        }
        return;
    }
    // 如果delegate没有被释放
    Class currentClass = object_getClass(self.delegate);
    if (currentClass == self.originalClass)
    {
        
        if (_delegate && [_delegate respondsToSelector:@selector(requestToViewCtrWithRequestType:didFinishLoadingWithResult:)])
        {
            [_delegate requestToViewCtrWithRequestType:type didFinishLoadingWithResult:result];
        }
    }
    else
    {
        NSLog(@"delegate dealloc");
    }
}

- (id)errorWithCode:(NSInteger)code userInfo:(NSDictionary *)userInfo
{
    return [NSError errorWithDomain:nil code:code userInfo:userInfo];
}
- (void)failedWithError:(NSError *)error withRequestType:(RequestType) type
{
    Class currentClass = object_getClass(self.delegate);
    if (currentClass == self.originalClass)
    {
        // 如果delegate没有被释放
        if (_delegate && [_delegate respondsToSelector:@selector(requestToViewCtrWithRequestType:didFailWithError:)])
        {
            [_delegate requestToViewCtrWithRequestType:type didFailWithError:error];
        }
    }
    else
    {
        NSLog(@"delegate dealloc");
    }
}

#pragma mark - NetRequestExtDelegate

- (void)request:(NetRequestExt *)request didFinishLoadingWithData:(NSData *)data
{
    [self handleResponseData:data withRequestType:request.requestCondition.requestType];
    for (id deal in g_dealDelegateSet)
    {
        if (self == deal)
        {
            [g_dealDelegateSet removeObject:self];; //释放本身
            break;
        }
    }
}

- (void)request:(NetRequestExt *)request didFailWithError:(NSError *)error
{
    [self failedWithError:error withRequestType:request.requestCondition.requestType];
    for (id deal in g_dealDelegateSet)
    {
        if (self == deal)
        {
            [g_dealDelegateSet removeObject:self];; //释放本身
            break;
        }
    }
}
@end

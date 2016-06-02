//
//  MWNetSearchListener.m
//  AutoNavi
//
//  Created by gaozhimin on 14-2-25.
//
//

#import "MWNetSearchListener.h"
#import "XMLDictionary.h"
#import "zlib.h"

static NSMutableSet *g_netSearchDelegateSet = nil;
Class object_getClass(id object);

@interface MWNetSearchListener()
{
    id<NetReqToViewCtrDelegate> _delegate;
    RequestType _requestType;
}

@property (nonatomic,assign) RequestType requestType;
@property (nonatomic,assign) id<NetReqToViewCtrDelegate> delegate;
@property (nonatomic,assign) Class originalClass;

@end

@implementation MWNetSearchListener

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
+ (id)createListenerWith:(RequestType)type delegate:(id<NetReqToViewCtrDelegate>)delegate
{
    if (g_netSearchDelegateSet == nil)
    {
        g_netSearchDelegateSet = [[NSMutableSet alloc] init];
    }
    
    MWNetSearchListener *deal = [[MWNetSearchListener alloc] init];    //在回调中释放
    deal.requestType = type;
    deal.delegate = delegate;
    deal.originalClass = object_getClass(delegate);
    [g_netSearchDelegateSet addObject:deal];
    [deal release];
    return deal;
}

/**
 *	删除所有监听
 */
+ (void)clearAllListener
{
    if (g_netSearchDelegateSet)
    {
        for (MWNetSearchListener *deal in g_netSearchDelegateSet)
        {
            deal.delegate = nil;
        }
        [g_netSearchDelegateSet removeAllObjects];
    }
}

/**
 *	删除某类请求
 *
 *	@param	type	请求类型
 */
+ (void)deleteListenerWith:(RequestType)type
{
    NSMutableSet  *temp = [[NSMutableSet alloc] init];
    for (MWNetSearchListener *deal in g_netSearchDelegateSet)
    {
        if (deal.requestType == type)
        {
            deal.delegate = nil;
            [temp addObject:deal];
        }
    }
    [g_netSearchDelegateSet minusSet:temp];
    [temp release];
}
#pragma mark - private method

-(NSData *)uncompressZippedData:(NSData *)compressedData
{
    
    if ([compressedData length] == 0) return compressedData;
    
    unsigned full_length = [compressedData length];
    
    unsigned half_length = [compressedData length] / 2;
    NSMutableData *decompressed = [NSMutableData dataWithLength: full_length + half_length];
    BOOL done = NO;
    int status;
    z_stream strm;
    strm.next_in = (Bytef *)[compressedData bytes];
    strm.avail_in = [compressedData length];
    strm.total_out = 0;
    strm.zalloc = Z_NULL;
    strm.zfree = Z_NULL;
    if (inflateInit2(&strm, (15+32)) != Z_OK) return nil;
    while (!done) {
        // Make sure we have enough room and reset the lengths.
        if (strm.total_out >= [decompressed length]) {
            [decompressed increaseLengthBy: half_length];
        }
        strm.next_out = [decompressed mutableBytes] + strm.total_out;
        strm.avail_out = [decompressed length] - strm.total_out;
        // Inflate another chunk.
        status = inflate (&strm, Z_SYNC_FLUSH);
        if (status == Z_STREAM_END) {
            done = YES;
        } else if (status != Z_OK) {
            break;
        }
        
    }
    if (inflateEnd (&strm) != Z_OK) return nil;
    // Set real length.
    if (done) {
        [decompressed setLength: strm.total_out];
        return [NSData dataWithData: decompressed];
    } else {
        return nil;
    }  
}


#pragma mark - request data handle

- (void)handleResponseData:(NSData *)data withRequestType:(RequestType) type
{
    NSLog(@"%@",[[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease]);
    NSDictionary * result = nil;
    if (type == REQ_NET_SEARCH_ARROUND_LINE)
    {
        NSLog(@"%@",[[[NSString alloc] initWithData:[self uncompressZippedData:data]  encoding:NSUTF8StringEncoding] autorelease]);
        result = [NSDictionary dictionaryWithXMLData:[self uncompressZippedData:data]];
    }
    else
    {
        NSLog(@"%@",[[[NSString alloc] initWithData:data  encoding:NSUTF8StringEncoding] autorelease]);
        result = [NSDictionary dictionaryWithXMLData:data];
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
    
    for (id deal in g_netSearchDelegateSet)
    {
        if (self == deal)
        {
            [g_netSearchDelegateSet removeObject:self];; //释放本身
            break;
        }
    }
    
}

- (void)request:(NetRequestExt *)request didFailWithError:(NSError *)error
{
    [self failedWithError:error withRequestType:request.requestCondition.requestType];
    
    for (id deal in g_netSearchDelegateSet)
    {
        if (self == deal)
        {
            [g_netSearchDelegateSet removeObject:self];; //释放本身
            break;
        }
    }
}
@end

//
//  NetOperation.m
//  AutoNavi
//
//  Created by gaozhimin on 13-7-24.
//
//

#import "NetOperation.h"
#import "NetRequestExtDelegate.h"
#import "NetConstant.h"
Class object_getClass(id object);

@interface NetOperation()

@property (nonatomic,assign) Class originalClass;

@end

@implementation NetOperation

#define kSYNRequestTimeOutInterval 10.0

@synthesize requestCondition = _requestCondition;
@synthesize delegate = _delegate;
@synthesize originalClass;
#pragma mark - public method

+ (NetOperation *)synRequestWithCondition:(NetBaseRequestCondition *)condition delegate:(id<NetSynRequestExtDelegate>)delegate
{
    NetOperation *operation = [[NetOperation alloc] init];
    operation.requestCondition = condition;
    operation.delegate = delegate;
    operation.originalClass = object_getClass(delegate);
    return [operation autorelease];
}

+ (NSString *)serializeURL:(NSString *)baseURL params:(NSDictionary *)params httpMethod:(NSString *)httpMethod
{
    NSURL* parsedURL = [NSURL URLWithString:baseURL];
    NSString* queryPrefix;
    if (params) {
        queryPrefix = parsedURL.query ? @"" : @"?";
    }
    else {
        queryPrefix = @"";
    }
    
    NSMutableArray* pairs = [NSMutableArray array];
    for (NSString* key in [params keyEnumerator])
    {
        if (([[params objectForKey:key] isKindOfClass:[UIImage class]])
            ||([[params objectForKey:key] isKindOfClass:[NSData class]]))
        {
            if ([httpMethod isEqualToString:@"GET"])
            {
                NSLog(@"can not use GET to upload a file");
            }
            continue;
        }
       
        NSString *postString=@"";
        NSString *value=[params objectForKey:key];
        postString=[postString stringByAppendingFormat:@"%@=%@",key,value];
        postString = [postString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        [pairs addObject:postString];
    }
    NSString* query = [pairs componentsJoinedByString:@"&"];
    
    return [NSString stringWithFormat:@"%@%@%@", baseURL, queryPrefix, query];
}

- (void)dealloc
{
    if (_requestCondition)
    {
        [_requestCondition release];
        _requestCondition = nil;
    }
    
    [super dealloc];
}

#pragma mark - private method

- (void)setHttpHeadWithRequest:(NSMutableURLRequest *)request params:(NSDictionary *)params
{
    if ([params count] > 0)
    {
        for (NSString *key in [params allKeys])
        {
            [request setValue:[params objectForKey:key]  forHTTPHeaderField:key];
        }
    }
}

- (void)handleResponseData:(NSData *)data
{
    Class currentClass = object_getClass(self.delegate);
    if (currentClass == self.originalClass)
    {
        if (_delegate && [_delegate respondsToSelector:@selector(synRequest:didFinishLoadingWithData:)])
        {
            [_delegate synRequest:self didFinishLoadingWithData:data];
        }
    }
    
}

- (void)failedWithError:(NSError *)error
{
    Class currentClass = object_getClass(self.delegate);
    if (currentClass == self.originalClass)
    {
        if (_delegate &&[_delegate respondsToSelector:@selector(synRequest:didFailWithError:)])
        {
            [_delegate synRequest:self didFailWithError:error];
        }
    }
}

- (void)main
{
    @autoreleasepool
    {
        if (self.isCancelled)
        {
            return;
        }
        
        NSString* urlString = [[self class] serializeURL:_requestCondition.baceURL params:_requestCondition.urlParams httpMethod:_requestCondition.httpMethod];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:_requestCondition.timeout?_requestCondition.timeout:kSYNRequestTimeOutInterval];  //若设置超时时间，则使用超时时间，否则为默认10s
        
        if ([_requestCondition.httpMethod isEqualToString: @"POST"])
        {
            [request setHTTPBody:_requestCondition.bodyData];
        }
        
        if (_requestCondition.httpHeaderFieldParams)
        {
            [self setHttpHeadWithRequest:request params:_requestCondition.httpHeaderFieldParams];
        }
        
        NSURLResponse *response = nil;
        NSError *error = nil;
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        
        
        if (self.isCancelled)
        {
            return;
        }
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if ((httpResponse.statusCode / 100) != 2)
        {

            [self performSelectorOnMainThread:@selector(failedWithError:) withObject:[NSError errorWithDomain:KNetResponseErrorDomain code:httpResponse.statusCode userInfo:nil] waitUntilDone:NO];
            return;
        }

        
        if (data)
        {
            [self performSelectorOnMainThread:@selector(handleResponseData:) withObject:data waitUntilDone:NO];
        }
        else
        {
            [self performSelectorOnMainThread:@selector(failedWithError:) withObject:error waitUntilDone:NO];
        }
    }
    
    
}

@end

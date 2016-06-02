//
//  NetRequest.m
//  SuYun
//
//  Created by yu.liao on 15/5/19.
//  Copyright (c) 2015年 yu.liao. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "NetRequest.h"
#import "Net.h"
#import "NetRequestCondition.h"

#define NetErrorDomain   @"NetErrorDomain"

#define NetErrorFailingStatusCodeKey @"NetErrorFailingStatusCodeKey"

#define kASYNRequestTimeOutInterval      12.0//异步超时时间

Class object_getClass(id object);

@interface Net (NetRequest)

- (void)requestDidFinish:(NetRequest *)request;

@end

@interface NetRequest ()

@property (nonatomic,assign) Class originalClass;

@end

@implementation NetRequest

@synthesize requestCondition = _requestCondition;
@synthesize delegate = _delegate;
@synthesize originalClass;



#pragma mark - NetRequest Private Methods

- (void)appendUTF8Body:(NSMutableData *)body dataString:(NSString *)dataString
{
    [body appendData:[dataString dataUsingEncoding:NSUTF8StringEncoding]];
}

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

- (void)handleResponseData:(NSData *)data
{
    Class currentClass = object_getClass(self.delegate);
    if (currentClass == self.originalClass)
    {
        if (_delegate && [_delegate respondsToSelector:@selector(request:didFinishLoadingWithData:)])
        {
            [_delegate request:self didFinishLoadingWithData:data];
        }
    }
    
}

- (void)failedWithError:(NSError *)error
{
    Class currentClass = object_getClass(self.delegate);
    if (currentClass == self.originalClass)
    {
        if (_delegate && [_delegate respondsToSelector:@selector(request:didFailWithError:)])
        {
            
            [_delegate request:self didFailWithError:[self parseError:error]];
        }
    }
}

- (NSError *)parseError:(NSError *) error
{
    NSError *tmpError;
    switch (error.code) {
        case NSURLErrorUnknown:
            tmpError = [NSError errorWithDomain:NetErrorDomain code:NetErrorUnknown userInfo:@{NSLocalizedDescriptionKey:@"未知错误"}];
            break;
        case NSURLErrorBadURL:
            tmpError = [NSError errorWithDomain:NetErrorDomain code:NetErrorBadURL userInfo:@{NSLocalizedDescriptionKey:@"URL异常"}];
            break;
        case NSURLErrorTimedOut:
            tmpError = [NSError errorWithDomain:NetErrorDomain code:NetErrorTimeOut userInfo:@{NSLocalizedDescriptionKey:@"网络连接超时"}];
            break;
        case NSURLErrorCannotFindHost:
            tmpError = [NSError errorWithDomain:NetErrorDomain code:NetErrorCannotFindHost userInfo:@{NSLocalizedDescriptionKey:@"找不到主机"}];
            break;
        case NSURLErrorCannotConnectToHost:
            tmpError = [NSError errorWithDomain:NetErrorDomain code:NetErrorCannotConnectToHost userInfo:@{NSLocalizedDescriptionKey:@"服务器连接失败"}];
            break;
        case NSURLErrorNotConnectedToInternet:
            tmpError = [NSError errorWithDomain:NetErrorDomain code:NetErrorNotConnectedToInternet userInfo:@{NSLocalizedDescriptionKey:@"网络连接异常"}];
            break;
        case NetErrorInvalidResponse:
        {
            tmpError = [NSError errorWithDomain:NetErrorDomain code:NetErrorInvalidResponse userInfo:@{NSLocalizedDescriptionKey:@"网络请求服务响应错误",NetErrorFailingStatusCodeKey:[error.userInfo objectForKey:NetErrorFailingStatusCodeKey]}];
        }
            break;
        default:
             tmpError = [NSError errorWithDomain:NetErrorDomain code:NetErrorUnknown userInfo:error.userInfo];
            break;
    }

    return tmpError;
}

#pragma mark - NetRequest Public Methods

+ (NetRequest *)requestWithCondition:(NetRequestCondition *)condition delegate:(id<NetRequestDelegate>)delegate
{
    
    NetRequest *request = [[NetRequest alloc] init];
    
    request.requestCondition = condition;
    request.delegate = delegate;
    request.originalClass = object_getClass(delegate);
    return request;
}

- (void)connect
{
    NSString* urlString = [[self class] serializeURL:_requestCondition.baceURL params:_requestCondition.urlParams httpMethod:_requestCondition.httpMethod];
    NSLog(@"\r\n%s: Requesttype = %d,url = %@\r\n",__func__,_requestCondition.requestID,urlString);
    NSMutableURLRequest* request =
    [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]
                            cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                        timeoutInterval:_requestCondition.timeout?_requestCondition.timeout:kASYNRequestTimeOutInterval];//若设置超时时间，则使用超时时间，否则为默认12s
    
    if (_requestCondition.httpHeaderFieldParams)
    {
        [self setHttpHeadWithRequest:request params:_requestCondition.httpHeaderFieldParams];
    }
    else
    {
        [request setValue:@"text/html" forHTTPHeaderField:@"Content-Type"];
    }
    
    if ([_requestCondition.httpMethod isEqualToString: @"POST"])
    {
        NSLog(@"\r\n%s: Requesttype = %d,bodyData = %@\r\n",__func__,_requestCondition.requestID,[[NSString alloc] initWithData:_requestCondition.bodyData encoding:NSUTF8StringEncoding]);
        [request setHTTPBody:_requestCondition.bodyData];
        [request setHTTPMethod:@"POST"];
    }
    else
    {
        [request setHTTPMethod:@"GET"];
    }
    
    connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
}

- (void)disconnect
{
    responseData = nil;
    
    [connection cancel];
     connection = nil;
    
}

#pragma mark - NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)theConnection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    NSLog(@"\r\n%s: %@\r\n",__func__,[httpResponse allHeaderFields]);
    
    if ((httpResponse.statusCode / 100) != 2)
    {
         NSLog(@"%s:statusCode= %d",__func__,(int)httpResponse.statusCode);
        [connection cancel];
       
        connection = nil;
        
        [self failedWithError:[NSError errorWithDomain:NetErrorDomain code:NetErrorInvalidResponse userInfo:@{NetErrorFailingStatusCodeKey:[NSString stringWithFormat:@"%d",(int)httpResponse.statusCode]}]];
        [[Net sharedInstance] requestDidFinish:self];
    }
    else
    {
        responseData = [[NSMutableData alloc] init];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [responseData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse
{
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)theConnection
{
    NSLog(@"\r\n%s: Requesttype = %d,Finish = %@\r\n",__func__,_requestCondition.requestID,[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);
    
    [self handleResponseData:responseData];
    
    responseData = nil;
    
    [connection cancel];
    connection = nil;
    
    [[Net sharedInstance] requestDidFinish:self];
}

- (void)connection:(NSURLConnection *)theConnection didFailWithError:(NSError *)error
{
    NSLog(@"\r\n%s:%@\r\n",__func__,error);
    [self failedWithError:error];
    
    responseData = nil;
    
    [connection cancel];
    connection = nil;
    
    [[Net sharedInstance] requestDidFinish:self];
}

@end

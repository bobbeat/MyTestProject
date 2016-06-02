//
//  NetRequestExt.m
//  AutoNavi
//
//  Created by yu.liao on 13-5-14.
//
//

#import "NetRequestExt.h"
#import "NetExt.h"
#import "NetRequestExtDelegate.h"

#define kASYNRequestTimeOutInterval      12.0//异步超时时间
Class object_getClass(id object);

@interface NetExt (NetRequestExt)

- (void)requestDidFinish:(NetRequestExt *)request;

@end

@interface NetRequestExt ()

@property (nonatomic,assign) Class originalClass;

@end

@interface NetRequestExt (Private)

- (void)appendUTF8Body:(NSMutableData *)body dataString:(NSString *)dataString;
- (NSMutableData *)postBodyHasRawData:(BOOL*)hasRawData;

- (void)handleResponseData:(NSData *)data;

- (void)failedWithError:(NSError *)error;



@end

@implementation NetRequestExt

@synthesize requestCondition = _requestCondition;
@synthesize delegate = _delegate;
@synthesize originalClass;

#pragma mark - NetRequestExt Life Circle

- (void)dealloc
{
    
    if (responseData != nil)
    {
        [responseData release];
        responseData = nil;
    }
    
    if (connection != nil)
    {
        [connection cancel];
        [connection release], connection = nil;
    }
    if (_requestCondition)
    {
        [_requestCondition release];
        _requestCondition = nil;
    }
    [super dealloc];
}

#pragma mark - NetRequestExt Private Methods

- (void)appendUTF8Body:(NSMutableData *)body dataString:(NSString *)dataString
{
    [body appendData:[dataString dataUsingEncoding:NSUTF8StringEncoding]];
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
            [_delegate request:self didFailWithError:error];
        }
    }
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

#pragma mark - NetRequestExt Public Methods

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
        
//        NSString* escaped_value = (NSString *)CFURLCreateStringByAddingPercentEscapes(
//                                                                                      NULL, /* allocator */
//                                                                                      (CFStringRef)[params objectForKey:key],
//                                                                                      NULL, /* charactersToLeaveUnescaped */
//                                                                                      (CFStringRef)@"!*'();:@&=+$,/?%#[]",
//                                                                                      kCFStringEncodingUTF8);
        NSString *postString=@"";
        NSString *value=[params objectForKey:key];
        postString=[postString stringByAppendingFormat:@"%@=%@",key,value];
        postString = [postString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        [pairs addObject:postString];
       // [escaped_value release];
    }
    NSString* query = [pairs componentsJoinedByString:@"&"];
    
    return [NSString stringWithFormat:@"%@%@%@", baseURL, queryPrefix, query];
}

+ (NetRequestExt *)requestWithCondition:(NetBaseRequestCondition *)condition delegate:(id<NetRequestExtDelegate>)delegate
{
    
    NetRequestExt *request = [[[NetRequestExt alloc] init] autorelease];
    
    request.requestCondition = condition;
    request.delegate = delegate;
    request.originalClass = object_getClass(delegate);
    return request;
}

- (void)connect
{
    NSString* urlString = [[self class] serializeURL:_requestCondition.baceURL params:_requestCondition.urlParams httpMethod:_requestCondition.httpMethod];
    NSLog(@"---------Net Request Requesttype = %d,url = %@",_requestCondition.requestType,urlString);
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
    [responseData release];
	responseData = nil;
    
    [connection cancel];
    [connection release], connection = nil;
    
}

#pragma mark - NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)theConnection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    NSLog(@"-------Net Response = %@",[httpResponse allHeaderFields]);
    
    if ((httpResponse.statusCode / 100) != 2)
    {
        [connection cancel];
        [connection release];
         connection = nil;
        
        [self failedWithError:[NSError errorWithDomain:KNetResponseErrorDomain code:httpResponse.statusCode userInfo:nil]];
         [[NetExt sharedInstance] requestDidFinish:self];
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
    NSLog(@"---utf8---Net DidFinish Requesttype = %d,content = %@",_requestCondition.requestType,[[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] autorelease]);
    
	[self handleResponseData:responseData];
    
	[responseData release];
	responseData = nil;
    
    [connection cancel];
	[connection release];
	connection = nil;
    
    [[NetExt sharedInstance] requestDidFinish:self];
}

- (void)connection:(NSURLConnection *)theConnection didFailWithError:(NSError *)error
{
     NSLog(@"--------Net Error = %@",[error localizedDescription]);
	[self failedWithError:error];
	
	[responseData release];
	responseData = nil;
    
    [connection cancel];
	[connection release];
	connection = nil;
    
    [[NetExt sharedInstance] requestDidFinish:self];
}

@end




//
//  gpi_networkConnect.m
//  AutoNavi
//
//  Created by gaozhimin on 13-10-16.
//
//

#import "gpi_networkConnect.h"
#import "network.h"


@implementation gpi_networkCondition

@synthesize nLen,nTaskID,nTimeOut,pszData,pszUrl,httpMethod,pstHeader;

- (void)dealloc
{
    self.pstHeader = nil;
    self.pszUrl = nil;
    self.pszData = nil;
    self.httpMethod = nil;
    [super dealloc];
}

@end

@interface gpi_networkConnect()
{
    pGPINetRecvDataCallback _pCallbackFunc;
}

@end

@implementation gpi_networkConnect
@synthesize networkCondition,target,selector,gpiHttpResponse;

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
    self.networkCondition = nil;
    self.gpiHttpResponse = nil;
    [super dealloc];
}

+ (gpi_networkConnect *)requestWithCondition:(gpi_networkCondition *)condition target:(id)target selector:(SEL)selector
{
    
    gpi_networkConnect *request = [[[gpi_networkConnect alloc] init] autorelease];
    
    request.networkCondition = condition;
    request.target = target;
    request.selector = selector;
    
    return request;
}

- (void)connect
{
    if (![networkCondition.pszUrl hasPrefix:@"http://"])
    {
        networkCondition.pszUrl = [NSString stringWithFormat:@"http://%@",networkCondition.pszUrl];
    }
    NSMutableURLRequest* request =
    [NSMutableURLRequest requestWithURL:[NSURL URLWithString:networkCondition.pszUrl]
                            cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                        timeoutInterval:networkCondition.nTimeOut];
    if ([networkCondition.pstHeader length] > 0)
    {
        NSArray *hearderArray = [networkCondition.pstHeader componentsSeparatedByString:@"\r\n"];
        for (int i = 0; i < [hearderArray count]; i ++)
        {
            NSArray *temp = [[hearderArray objectAtIndex:i] componentsSeparatedByString:@":"];
            if ([temp count] == 2)
            {
                [request setValue:[temp objectAtIndex:0]  forHTTPHeaderField:[temp objectAtIndex:1]];
            }
        }
    }
    if ([networkCondition.httpMethod isEqualToString: @"POST"])
    {
        [request setHTTPBody:networkCondition.pszData];
        [request setHTTPMethod:@"POST"];
    }
    else
    {
        [request setHTTPMethod:@"GET"];
    }
    
    if ([NSThread isMainThread])
    {
        connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
        if (connection == nil)
        {
            NSLog(@"无效请求");
        }
    }
    else
    {
        [self performSelectorOnMainThread:@selector(ConectPerformInMain:) withObject:request waitUntilDone:YES];
    }
}

- (void)ConectPerformInMain:(NSMutableURLRequest *)request
{
    connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
    if (connection == nil)
    {
        NSLog(@"无效请求");
    }
}

- (void)disconnect
{
    [connection cancel];
    [connection release], connection = nil;
    
    [responseData release];
	responseData = nil;
}

- (void)GPI_NetSetResultCallback:(void*)pCallbackFunc
{
    _pCallbackFunc = pCallbackFunc;
}

#pragma mark - NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)theConnection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    self.gpiHttpResponse = httpResponse;
    
    if ((httpResponse.statusCode / 100) != 2)
    {
        [connection cancel];
        [connection release];
        connection = nil;
        NSString *str = @"";
        for (id key in [self.gpiHttpResponse allHeaderFields])
        {
            str = [str stringByAppendingFormat:@"%@:%@\r\n",key,[[self.gpiHttpResponse allHeaderFields] objectForKey:key]];
        }
        if (_pCallbackFunc)
        {
            _pCallbackFunc(NULL,0,TRANS_RESULT_FAIL,networkCondition.nTaskID,(char *)[str UTF8String]);
        }
        return;
    }
    else
    {
        responseData = [[NSMutableData alloc] init];
    }
    
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (_pCallbackFunc)
    {
//        NSLog(@"%@",[[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease]);
        Gint32 datalenth = [data length];
        Gint8 *data_int8 = malloc((datalenth + 1) * sizeof(Gint8));
        if (data_int8)
        {
            memset(data_int8, 0, (datalenth + 1) * sizeof(Gint8));
            memcpy(data_int8, [data bytes],  (datalenth) * sizeof(Gint8));
            _pCallbackFunc(data_int8,datalenth,14,networkCondition.nTaskID,NULL);
            free(data_int8);
        }
    }
    if (responseData)
    {
        [responseData appendData:data];
    }
	
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
				  willCacheResponse:(NSCachedURLResponse*)cachedResponse
{
	return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)theConnection
{
    NSString *str = @"";
    for (id key in [self.gpiHttpResponse allHeaderFields])
    {
        str = [str stringByAppendingFormat:@"%@:%@\r\n",key,[[self.gpiHttpResponse allHeaderFields] objectForKey:key]];
    }
    if (_pCallbackFunc)
    {
        if (responseData)
        {
            Gint32 datalenth = [responseData length];
            Gint8 *data = malloc((datalenth + 1) * sizeof(Gint8));
            if (data)
            {
                memset(data, 0, (datalenth + 1) * sizeof(Gint8));
                memcpy(data, [responseData bytes],  (datalenth) * sizeof(Gint8));
                _pCallbackFunc(data,datalenth,TRANS_RESULT_SUCCESS,networkCondition.nTaskID,(char *)[str UTF8String]);
                free(data);
            }
        }
        
    }

    if (responseData)
    {
        [responseData release];
        responseData = nil;
    }
    [connection cancel];
	[connection release];
	connection = nil;
    
    if ([target respondsToSelector:selector])
    {
        [target performSelector:selector withObject:[NSString stringWithFormat:@"%d",networkCondition.nTaskID]];
    }
}

- (void)connection:(NSURLConnection *)theConnection didFailWithError:(NSError *)error
{
    if ([error code] == NSURLErrorTimedOut)
    {
        printf("NSURLErrorTimedOut...........:\n");
        if (_pCallbackFunc)
        {
            _pCallbackFunc(NULL,0,TRANS_RESULT_TIMEOUT,networkCondition.nTaskID,NULL);
        }
    }
    else
    {
        NSLog(@"didFailWithError:");
        if (_pCallbackFunc)
        {
            _pCallbackFunc(NULL,0,TRANS_RESULT_FAIL,networkCondition.nTaskID,NULL);
        }
    }
   
	if (responseData)
    {
        [responseData release];
        responseData = nil;
    }
    
    [connection cancel];
	[connection release];
	connection = nil;
    
    if ([target respondsToSelector:selector])
    {
        [target performSelector:selector withObject:[NSString stringWithFormat:@"%d",networkCondition.nTaskID]];
    }
    
    
}


@end

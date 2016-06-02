//
//  NetExt.m
//  AutoNavi
//
//  Created by yu.liao on 13-5-14.
//
//

#import "NetExt.h"
#import "JSONKit.h"
#import <CommonCrypto/CommonDigest.h>

static NetExt *instance = nil;

@interface NetExt()

+ (void)releaseInstance;

@end

@implementation NetExt

- (id) init {
	self = [super init];
	if (self != nil)
    {
         requests = [[NSMutableSet alloc] init];
	}
	return self;
}

+(NetExt *)sharedInstance
{
    if (instance == nil)
    {
        instance = [[NetExt alloc] init];
    }
    return instance;
}

+(void)releaseInstance
{
    if (instance != nil)
    {
        [instance release];
        instance = nil;
    }
}

- (void)dealloc
{
    if (requests)
    {
        [requests release];
        requests = nil;
    }
    
    if (m_operationQueue)
    {
        [m_operationQueue release];
        m_operationQueue = nil;
    }
    [super dealloc];
}


#pragma mark - Private methods

- (void)requestDidFinish:(NetRequestExt *)_request
{
    @synchronized(requests)
    {
        [requests removeObject:_request];
    }
}

#pragma mark - syn request

- (NetOperation *)synRequestWithCondition:(NetBaseRequestCondition *)condition delegate:(id<NetSynRequestExtDelegate>)delegate
{
    if (m_operationQueue == nil)
    {
        m_operationQueue = [[NSOperationQueue alloc] init];
        [m_operationQueue setMaxConcurrentOperationCount:NSOperationQueueDefaultMaxConcurrentOperationCount];
    }
    
    NetOperation *operation = [NetOperation synRequestWithCondition:condition delegate:delegate];
    [m_operationQueue addOperation:operation];
    
    return operation;
}

//取消对应类型的同步请求
- (void)cancelOperationWithType:(RequestType)requestType
{
    for (NetOperation *operation in [m_operationQueue operations])
    {
        if (operation.requestCondition.requestType == requestType)
        {
            [operation cancel];
            operation.delegate = nil;
        }
    }
}
//取消所有的同步请求
- (void)cancelAllOperation
{
    [m_operationQueue cancelAllOperations];
    for (NetOperation *operation in [m_operationQueue operations])
    {
        operation.delegate = nil;
    }
}

#pragma mark - asyn request
- (NetRequestExt*)requestWithCondition:(NetBaseRequestCondition *)condition delegate:(id<NetRequestExtDelegate>)delegate
{
    @synchronized(requests)
    {
        NetRequestExt *_request = [NetRequestExt requestWithCondition:condition delegate:delegate];
        [requests addObject:_request];
        [_request connect];
        return _request;
    }
    return nil;
}

- (void)Net_CancelRequestWithType:(RequestType)requestType
{
    @synchronized(requests)
    {
        NetRequestExt *temp = nil;
        for (NetRequestExt *request in requests)
        {
            if (request.requestCondition.requestType == requestType)
            {
                [request  disconnect];
                request.delegate = nil;
                temp = request;
                break;
            }
        }
        if (temp)
        {
            [requests removeObject:temp];
        }
    }
}

- (void)cancelAllRequests
{
    @synchronized(requests)
    {
        for (NetRequestExt *request in requests)
        {
            [request  disconnect];
            request.delegate = nil;
        }
        [requests removeAllObjects];
    }
   
}
#pragma mark - Utility
//base64转码
static const char encodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
- (NSString *)base64Encoding:(NSData *)temp
{
	if ([temp length] == 0)
		return @"";
    char *characters = malloc((([temp length] + 2) / 3) * 4);
	if (characters == NULL)
		return nil;
	NSUInteger length = 0;
	NSUInteger i = 0;
	while (i < [temp length])
	{
		char buffer[3] = {0,0,0};
		short bufferLength = 0;
		while (bufferLength < 3 && i < [temp length])
			buffer[bufferLength++] = ((char *)[temp bytes])[i++];
		characters[length++] = encodingTable[(buffer[0] & 0xFC) >> 2];
		characters[length++] = encodingTable[((buffer[0] & 0x03) << 4) | ((buffer[1] & 0xF0) >> 4)];
		if (bufferLength > 1)
			characters[length++] = encodingTable[((buffer[1] & 0x0F) << 2) | ((buffer[2] & 0xC0) >> 6)];
		else characters[length++] = '=';
		if (bufferLength > 2)
			characters[length++] = encodingTable[buffer[2] & 0x3F];
		else characters[length++] = '=';
	}
	return [[[NSString alloc] initWithBytesNoCopy:characters length:length encoding:NSUTF8StringEncoding freeWhenDone:YES] autorelease];
}

//字典转化为json数据
- (NSData *)DictionaryToJSON:(NSMutableDictionary *)dictionary ImageEncode:(ImageEncode)imageEncode
{
    NSData *body = [NSData data];
    NSString *picString = nil;
    NSData   *imageData = nil;
    id imageKey = nil;
    
    for (id key in dictionary)
    {
        NSObject *dataParam = [dictionary valueForKey:key];
            
        if ([dataParam isKindOfClass:[UIImage class]])
        {
            imageKey = key;
            if (IE_Base64 == imageEncode) {
                NSData* imageData = UIImagePNGRepresentation((UIImage *)dataParam);
                picString = [self base64Encoding:imageData];//将图片通过base64编码转化为nsstring
                
                
            }
            else {
                imageData = UIImagePNGRepresentation((UIImage *)dataParam);
                
            }
                
        }
            
    }
    if (imageKey) {
        if (IE_Base64 == imageEncode)
        {
            if (picString)
            {
                [dictionary setObject:picString forKey:imageKey];
            }
        }
        else {
            if (imageData)
            {
                [dictionary setObject:imageData forKey:imageKey];
            }
        }
    }
    
    NSString *jsonStr = [dictionary JSONRepresentation]; //将字典转化为json
    NSLog(@"json=%@",jsonStr);
    body = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    return body;
}

- (void)appendUTF8Body:(NSMutableData *)body dataString:(NSString *)dataString
{
    [body appendData:[dataString dataUsingEncoding:NSUTF8StringEncoding]];
}

//图片或者数据的组装
- (NSMutableData *)postBodyData:(NSMutableDictionary *)dictionary
{
    NSString *bodyPrefixString = [NSString stringWithFormat:@"--%@\r\n", kNetRequestStringBoundary];
    NSString *bodySuffixString = [NSString stringWithFormat:@"\r\n--%@--\r\n", kNetRequestStringBoundary];
    
    NSMutableDictionary *dataDictionary = [NSMutableDictionary dictionary];
    
    NSMutableData *body = [NSMutableData data];
    
    [self appendUTF8Body:body dataString:bodyPrefixString];
    
    for (id key in [dictionary keyEnumerator])
    {
        if (([[dictionary objectForKey:key] isKindOfClass:[UIImage class]]) || ([[dictionary objectForKey:key] isKindOfClass:[NSData class]]))
        {
            [dataDictionary setObject:[dictionary objectForKey:key] forKey:key];
            continue;
        }
        
        [self appendUTF8Body:body dataString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n%@\r\n", key, [dictionary objectForKey:key]]];
        [self appendUTF8Body:body dataString:bodyPrefixString];
    }
    
    if ([dataDictionary count] > 0)
    {
        for (id key in dataDictionary)
        {
            NSObject *dataParam = [dataDictionary objectForKey:key];
            
            if ([dataParam isKindOfClass:[UIImage class]])
            {
                NSData* imageData = UIImagePNGRepresentation((UIImage *)dataParam);
                [self appendUTF8Body:body dataString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"file.png\"\r\n",key]];
                [self appendUTF8Body:body dataString:[NSString stringWithFormat:@"Content-Type: image/png\r\nContent-Transfer-Encoding: binary\r\n\r\n"]];
                [body appendData:imageData];
            }
            else if ([dataParam isKindOfClass:[NSData class]])
            {
                [self appendUTF8Body:body dataString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"file\"\r\n", key]];
                [self appendUTF8Body:body dataString:[NSString stringWithFormat:@"Content-Type: content/unknown\r\nContent-Transfer-Encoding: binary\r\n\r\n"]];
                [body appendData:(NSData*)dataParam];
            }
            [self appendUTF8Body:body dataString:bodySuffixString];
        }
    }
    
    return body;
}


@end

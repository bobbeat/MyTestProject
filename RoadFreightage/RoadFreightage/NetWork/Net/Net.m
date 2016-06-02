//
//  Net.m
//  SuYun
//
//  Created by yu.liao on 15/5/19.
//  Copyright (c) 2015年 yu.liao. All rights reserved.
//

#import "Net.h"
#import "NetRequest.h"
#import "NetRequestCondition.h"
#import  <UIKit/UIKit.h>


static Net *instance = nil;

@interface Net()

+ (void)releaseInstance;

@end

@implementation Net

- (id) init {
    self = [super init];
    if (self != nil)
    {
        requests = [[NSMutableSet alloc] init];
    }
    return self;
}

+(Net *)sharedInstance
{
    if (instance == nil)
    {
        instance = [[Net alloc] init];
    }
    return instance;
}

+(void)releaseInstance
{
    if (instance != nil)
    {
        instance = nil;
    }
}

- (void)dealloc
{
    if (requests)
    {
        requests = nil;
    }
    
}


#pragma mark - Private methods

- (void)requestDidFinish:(NetRequest *)_request
{
    @synchronized(requests)
    {
        [requests removeObject:_request];
    }
}

#pragma mark - Public methods
- (NetRequest*)requestWithCondition:(NetRequestCondition *)condition delegate:(id<NetRequestDelegate>)delegate
{
    @synchronized(requests)
    {
        NetRequest *request = [NetRequest requestWithCondition:condition delegate:delegate];
        [requests addObject:request];
        [request connect];
        return request;
    }
    return nil;
}

- (void)cancelRequestWithType:(NSInteger)requestType
{
    @synchronized(requests)
    {
        NetRequest *temp = nil;
        for (NetRequest *request in requests)
        {
            if (request.requestCondition.requestID == requestType)
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
        for (NetRequest *request in requests)
        {
            [request  disconnect];
            request.delegate = nil;
        }
        [requests removeAllObjects];
    }
    
}
@end

@implementation  NSString (Base64Encoding)

static const char encodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
+ (NSString *)base64Encoding:(NSData *)data
{
    if ([data length] == 0)
        return @"";
    char *characters = malloc((([data length] + 2) / 3) * 4);
    if (characters == NULL)
        return nil;
    NSUInteger length = 0;
    NSUInteger i = 0;
    while (i < [data length])
    {
        char buffer[3] = {0,0,0};
        short bufferLength = 0;
        while (bufferLength < 3 && i < [data length])
            buffer[bufferLength++] = ((char *)[data bytes])[i++];
        characters[length++] = encodingTable[(buffer[0] & 0xFC) >> 2];
        characters[length++] = encodingTable[((buffer[0] & 0x03) << 4) | ((buffer[1] & 0xF0) >> 4)];
        if (bufferLength > 1)
            characters[length++] = encodingTable[((buffer[1] & 0x0F) << 2) | ((buffer[2] & 0xC0) >> 6)];
        else characters[length++] = '=';
        if (bufferLength > 2)
            characters[length++] = encodingTable[buffer[2] & 0x3F];
        else characters[length++] = '=';
    }
    return [[NSString alloc] initWithBytesNoCopy:characters length:length encoding:NSUTF8StringEncoding freeWhenDone:YES];
}

@end

NSString *const netRequestStringBoundary = @"----------httppost123--";//分隔符

@implementation NSMutableData (PostBodyHasRawData)

+ (void)appendUTF8Body:(NSMutableData *)body dataString:(NSString *)dataString
{
    [body appendData:[dataString dataUsingEncoding:NSUTF8StringEncoding]];
}

+ (NSMutableData *)postBodyHasRawData:(NSMutableDictionary *)dictionary
{
    NSString *bodyPrefixString = [NSString stringWithFormat:@"--%@\r\n", netRequestStringBoundary];
    NSString *bodySuffixString = [NSString stringWithFormat:@"\r\n--%@--\r\n", netRequestStringBoundary];
    
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


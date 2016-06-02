//
//  NetRequestExt.h
//  AutoNavi
//
//  Created by yu.liao on 13-5-14.
//
//

#import <Foundation/Foundation.h>
#import "NetTypedef.h"
#import "NetBaseRequestCondition.h"

@protocol NetRequestExtDelegate;

@interface NetRequestExt : NSObject <NSURLConnectionDelegate>
{
    NSURLConnection                 *connection;
    NSMutableData                   *responseData;
    NetBaseRequestCondition         *_requestCondition;
    id<NetRequestExtDelegate>       _delegate;
}

@property (nonatomic, assign) id<NetRequestExtDelegate>       delegate;
@property (nonatomic, retain) NetBaseRequestCondition         *requestCondition;

+ (NetRequestExt *)requestWithCondition:(NetBaseRequestCondition *)condition delegate:(id<NetRequestExtDelegate>)delegate;

+ (NSString *)serializeURL:(NSString *)baseURL params:(NSDictionary *)params httpMethod:(NSString *)httpMethod;

- (void)connect;
- (void)disconnect;

@end


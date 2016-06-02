//
//  gpi_networkConnect.h
//  AutoNavi
//
//  Created by gaozhimin on 13-10-16.
//
//

#import <Foundation/Foundation.h>

@interface gpi_networkCondition : NSObject

@property(nonatomic,copy) NSString *pszUrl;
@property(nonatomic,copy) NSString *pstHeader;
@property(nonatomic,copy) NSString *httpMethod;
@property(nonatomic,retain) NSData *pszData;
@property(nonatomic,assign) int nLen;
@property(nonatomic,assign) int nTimeOut;
@property(nonatomic,assign) int nTaskID;

@end

@interface gpi_networkConnect : NSObject<NSURLConnectionDelegate>
{
    NSURLConnection                 *connection;
    NSMutableData                   *responseData;
    gpi_networkCondition *networkCondition;
    id target;
    SEL selector;
}

+ (gpi_networkConnect *)requestWithCondition:(gpi_networkCondition *)condition target:(id)target selector:(SEL)selector;
- (void)GPI_NetSetResultCallback:(void*)pCallbackFunc;

@property(nonatomic,retain) gpi_networkCondition *networkCondition;
@property(nonatomic,assign) id target;
@property(nonatomic,assign) SEL selector;
@property(nonatomic,retain) NSHTTPURLResponse *gpiHttpResponse;
- (void)connect;
- (void)disconnect;

@end

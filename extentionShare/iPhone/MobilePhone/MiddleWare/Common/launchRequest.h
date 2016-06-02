//
//  launchRequest.h
//  AutoNavi
//
//  Created by huang longfeng on 13-5-24.
//
//

#import <Foundation/Foundation.h>
#import "NetKit.h"



@protocol NetReqToViewCtrDelegate;

@interface launchRequest : NSObject <NetReqToViewCtrDelegate>
{
 
}

+ (launchRequest *)shareInstance;

- (void)launchRequest;
//软件版本升级检测
- (void)softWareVersionUpdateRequest;
- (void)UploadTokenToAutonavi:(NSString *)token;
// 软件升级测试接口
- (void)UpdateAppRequest;

@end

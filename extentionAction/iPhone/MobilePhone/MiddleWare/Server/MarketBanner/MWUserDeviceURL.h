//
//  MWUserDeviceProtocol.h
//  AutoNavi
//
//  Created by jiangshu-fu on 14-5-8.
//
//

#import <Foundation/Foundation.h>




@interface MWUserDeviceURL : NSObject

/***
 * @name    获取上传设备信息的url
 * @param   基础URL
 * @author  by bazinga
 ***/
+ (NSURL *) userDeviceInfoURL:(NSString *)baseUrl;

@end

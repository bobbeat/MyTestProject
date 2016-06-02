//  应用程序数据
//  ANDataSource.h
//  AutoNavi
//
//  Created by GHY on 12-3-31.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ANDataSource : NSObject 
{

}



#pragma mark 单例
+ (ANDataSource *)sharedInstance;


#pragma mark 获取当前网络类型
- (int)isNetConnecting;

#pragma mark 获取开机启动默认图片
- (UIImage *)GMD_GetDefaultImage;

#pragma mark 获取开机启动蒙版图片
+ (UIImage *)GMD_GetDefaultBottomImage;

#pragma mark 从document目录中获取指定URL
+ (NSString *)getURLFromDocument:(NSString *)name;

#pragma mark 获取北京后台字体类型
- (int)getNetFontType;

#pragma mark 获取服务器请求时间
- (NSString *)getNetProcessTime;

#pragma mark 获取基础资源版本号
+ (NSString *)getNaviVersion;


@end

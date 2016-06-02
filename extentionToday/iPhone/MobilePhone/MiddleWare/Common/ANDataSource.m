//
//  ANDataSource.m
//  AutoNavi
//
//  获取数据
//
//  Created by GHY on 12-3-31.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//


#import "UIDevice+Category.h"

#import "ANDataSource.h"

#import "ANReachability.h"

#import "XMLDictionary.h"

static ANDataSource *sharedANDataSource = nil;


@implementation ANDataSource


#pragma mark 单例=============================================================================

#pragma mark 单例
+ (ANDataSource *)sharedInstance {
	
	if (nil==sharedANDataSource)
	{
		sharedANDataSource = [[ANDataSource alloc] init];
	}
	return sharedANDataSource;
}

#pragma mark 初始化(外面不需调用)
- (id)init {
	
	self = [super init];
	if (self)
	{
		
	}
	return self;
}



#pragma mark 获取开机启动默认图片
- (UIImage *)GMD_GetDefaultImage
{
    UIImage *defaultImage = nil;
    
    if ([UIDevice currentResolution] == UIDevice_iPhone6PlusHiRes)
    {
        defaultImage = [UIImage imageNamed:@"DefaultTop-736h.jpg"];
    }
    else if ([UIDevice currentResolution] == UIDevice_iPhone6HiRes) {
        defaultImage = [UIImage imageNamed:@"DefaultTop-667h.jpg"];
    }
    else if ([UIDevice currentResolution] == UIDevice_iPhoneTallerHiRes) {
        defaultImage = [UIImage imageNamed:@"DefaultTop-568h.png"];
    }
    else{
        defaultImage = [UIImage imageNamed:@"DefaultTop.png"];
    }
    
    return defaultImage;
}

#pragma mark 获取开机启动蒙版图片
+ (UIImage *)GMD_GetDefaultBottomImage
{
    UIImage *defaultImage = nil;
    
    if ([UIDevice currentResolution] == UIDevice_iPhone6PlusHiRes)
    {
        defaultImage = [UIImage imageNamed:@"DefaultBottom-736h.png"];
    }
    else if ([UIDevice currentResolution] == UIDevice_iPhone6HiRes) {
        defaultImage = [UIImage imageNamed:@"DefaultBottom-667h.png"];
    }
    else{
        defaultImage = [UIImage imageNamed:@"DefaultBottom.png"];
    }
    
    
    return defaultImage;
}

#pragma mark 获取当前网络类型
- (int)isNetConnecting
{
	ANReachability *r = [ANReachability reachabilityForInternetConnection];
    switch ([r currentReachabilityStatus]) {
        case NotReachable:
            // 没有网络连接
            return 0;
            break;
        case ReachableViaWWAN:
            // 使用3G网络
            return 1;
            break;
        case ReachableViaWiFi:
            // 使用WiFi网络
            return 2;
            break;
    }
}

#pragma mark 获取北京后台字体类型
- (int)getNetFontType
{
    int language = 0;
    
    if (fontType == 0) {
        language = 0;
    }
    else if (fontType == 1)
    {
        language = 2;
    }
    else if (fontType == 2)
    {
        language = 1;
    }
    
    return language;
}

#pragma mark 获取服务器请求时间
- (NSString *)getNetProcessTime
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYYMMddhhmmss"];
    NSString *dateString = [formatter stringFromDate:[NSDate date]];
    [formatter release];
    
    return dateString;
}

#pragma mark 获取基础资源版本号
+ (NSString *)getNaviVersion
{
    NSError *error = nil;
    
    NSString *versionString =  [NSString stringWithContentsOfFile:NaviResVersion_PATH encoding:NSUTF8StringEncoding error:&error];
    
    if (error) {
        return @"";
    }
    
    return versionString;
    
}

#pragma mark 从document目录中获取指定URL
+ (NSString *)getURLFromDocument:(NSString *)name
{
    static NSDictionary *dic_url = nil;
    if (dic_url == nil)
    {
        if ([[NSFileManager defaultManager] fileExistsAtPath:ServiceSwitchFile_PATH])
        {
            NSData *data = [NSData dataWithContentsOfFile:ServiceSwitchFile_PATH];
            dic_url = [[NSDictionary dictionaryWithXMLData:data] retain];
        }
    }
   
    if (dic_url)
    {
        NSArray *array = [[dic_url objectForKey:@"info"] objectForKey:@"item"];
        if ([array isKindOfClass:[NSArray class]])
        {
            for (int i = 0; i < [array count]; i++)
            {
                NSDictionary *dic = [array objectAtIndex:i];
                if ([name isEqualToString:[dic objectForKey:@"name"]])
                {
                    return [dic objectForKey:@"url"];
                }
            }
        }
    }
    return nil;
}



@end

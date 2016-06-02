//
//  ANApiSDK.h
//  ANApiSDK
//
//  Created by yang yi on 14-10-11.
//  Copyright (c) 2014年 Autonavi. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef MacroFoFramework
    #import <ANApi/ANTypeDef.h>
#else
    #import "ANTypeDef.h"
#endif

/**
 *  sdk模块
 */
@interface ANApiSDK : NSObject

+ (ANApiSDK *)sharedInstance;


/*!
 @brief API 版本号.
 */
@property (nonatomic, readonly) NSString *SDKVersion;

/**Porperty
 * @Property: 是否初始化成功;
 * @brief:
 */

@property (nonatomic, readonly) BOOL        isInitSuc;


/**
 *  启动API.
 *  NSString *domain = @"com.iqidi.MyApplication.ErrorDomain";
 *  NSString *desc = NSLocalizedString(@"Unable to…", @"");
 *  NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : desc };
 *  NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : desc };
 *
 *  NSError *error = [NSError errorWithDomain:domain
 *  code:-101
 *  userInfo:userInfo];
 *
 *  @param error 错误信息
 *
 *  @return 是否成功
 */
- (BOOL)startupWithError:(NSError**)error;


/**
 *  停止API
 *
 *  @return 是否成功
 */
- (BOOL)shutdown;

#pragma mark -
#pragma mark 初始化前需要先检查基础资源

/**
 *  是否有基础资源
 *
 *  @return 返回有无
 */
- (BOOL)isAppHasNecessaryResource;


/**
 *  是否有资源更新
 */
- (void)isServerHasUpdateForResource:(void (^)(BOOL isHasUpdate)) blockForCheckingUpdate;


/**
 *  下载最新的资源
 *
 *  @param blockForDownloadingResource 下载过程中的状况
 */
- (void)downloadLastVersionOfResource:(ResourceManagerBlock) blockForDownloadingResource;


/**
 *  最新资源版本号
 *
 *  @return 返回最新资源版本号
 */
- (NSString *)versionOfResource;

@end

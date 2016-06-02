//
//  ANResourceManager.h
//  ProjectDemoOnlyCode
//
//  Created by liyuhang on 14-11-5.
//  Copyright (c) 2014年 liyuhang. All rights reserved.
//

/**
 * 1 检测是否有资源文件夹
 * 2 检测服务器是否有版本可以进行更新（#define VersionResource @"1.0000.0001"），前两位相同，后一位升序，才能更新
 * 3 下载最新的资源
 */

#import <Foundation/Foundation.h>

#ifdef MacroFoFramework
    #import <ANApi/ANTypeDef.h>
#else
    #import "ANTypeDef.h"
#endif


@interface ANResourceManager : NSObject

#pragma mark
#pragma mark 单例
+ (instancetype)shareInstance;
+ (void)releaseInstance;


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




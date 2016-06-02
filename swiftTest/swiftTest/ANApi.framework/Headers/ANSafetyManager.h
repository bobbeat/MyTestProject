//
//  SafetyManager.h
//  ANApiSDK
//
//  Created by yang yi on 14-10-13.
//  Copyright (c) 2014年 Autonavi. All rights reserved.
//

#import <Foundation/Foundation.h>


#ifdef MacroFoFramework
#import <ANApi/ANSafetyInfo.h>
#import <ANApi/IMSafetyManageProtocol.h>
#else
#import "IMSafetyManageProtocol.h"
#import "ANSafetyInfo.h"
#endif
#import <CoreLocation/CoreLocation.h>

/**
 *  电子眼管理类
 */
@interface ANSafetyManager : NSObject

+ (ANSafetyManager *)sharedInstance;

/**
 *  清空指定类型的安全信息
 *
 *  @param category 指定的安全信息类型
 *
 *  @return 失败返回false
 */
- (BOOL)removeSafetyByCategory:(ANSafetyCategory)category;

/**
 *  是否存在指定经纬度的安全信息
 *
 *  @param coordinate 指定的经纬度
 *
 *  @return 不存在时返回false
 */
- (BOOL)exists:(CLLocationCoordinate2D)coordinate;

/**
 *  按指定安全信息类型获取安全信息列表
 *
 *  @param category 指定的安全信息类型
 *
 *  @return 指定类型的安全信息列表，不存在时返回EMPTY_LIST
 */
- (NSArray *)safetyArrayWithCategory:(ANSafetyCategory)category;

/**
 *  删除指定的安全信息列表
 *
 *  @param array 指定要删除安全信息列表
 *
 *  @return 失败时返回false
 */
- (BOOL)removeObjectsInArray:(NSArray*)array;

/**
 *  删除指定的安全信息
 *
 *  @param safeInfo 指定的安全信息
 *
 *  @return 失败时返回false
 */
- (BOOL)removeObject:(ANSafetyInfo*)safeInfo;

/**
 *  删除安全信息
 *
 *  @param category   指定的安全信息类型
 *  @param coordinate 指定的经纬度
 *
 *  @return 失败时返回false
 */
- (BOOL)removeSafetyByCategory:(ANSafetyCategory)category atCoordinate:(CLLocationCoordinate2D)coordinate;


/**
 *  保存安全信息
 *
 *  @param safeInfo 要保存的安全信息
 *
 *  @return 更新后的安全信息，失败时返回null
 */
- (ANSafetyInfo *)save:(ANSafetyInfo *)safeInfo;


@end

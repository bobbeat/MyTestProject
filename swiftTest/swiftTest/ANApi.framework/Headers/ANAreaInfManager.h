//
//  ANAreaInfManager.h
//  ProjectDemoOnlyCode
//
//  Created by yuhang on 14-11-7.
//  Copyright (c) 2014年 liyuhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>


#ifdef MacroFoFramework
    #import <ANApi/ANAreaInfo.h>
    #import <ANApi/ANTypeDef.h>
#else
    #import "ANAreaInfo.h"
    #import "ANTypeDef.h"
#endif

/**
 *  行政区域管理器
 */
@interface ANAreaInfManager : NSObject
{
    
}

/**fun
 * @brief 单例
 * @return
 */
+ (instancetype)shareInstance;

+ (void)releaseInstance;

/**fun
 * @brief   获取完整的行政区域信息
 * @return  成功 NSArray, 失败 nil
 */
- (NSArray<ANAreaInfo> *)getCompleteAdminInfo;

/**
 *  设置当前行政区域
 *
 *  @param adminCode 行政编码
 *  @param error     错误信息
 *
 *  @return 处理结果
 */
- (BOOL)setCurrentAdmin:(NSUInteger)adminCode error:(NSError **)error;

/**fun
 * @brief   获取当前行政区域信息
 * @return  行政编码
 */
- (NSUInteger)getCurrentAdminCode;

/**
 *  根据经纬度获取行政编码
 *
 *  @param location 经纬度
 *
 *  @return 行政编码
 */
- (NSUInteger)getAdminCodeFromPosition:(CLLocationCoordinate2D)location;

/**
 *  根据行政编码获取行政区域信息
 *
 *  @param adminCode 行政编码
 *
 *  @return 区域信息
 */
- (ANAreaInfo *)getAreaInfoFromAdminCode:(NSUInteger)adminCode;



@end

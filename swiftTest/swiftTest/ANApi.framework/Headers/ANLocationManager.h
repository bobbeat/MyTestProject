//
//  ANLocationManager.h
//  ProjectDemoOnlyCode
//
//  Created by yuhang on 14-11-10.
//  Copyright (c) 2014年 liyuhang. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef MacroFoFramework
    #import <ANApi/ANGpsInfo.h>
#else
    #import "ANGpsInfo.h"
#endif

@protocol ANLocationDelegate <NSObject>

-(void)GPSSuccess:(double)locationAccuracy GPSInfo:(ANGpsInfo* )gpsInfo;
-(void)GPSFail:(NSError *)error;

@end



/**
 *  位置管理器
 */
@interface ANLocationManager : NSObject
{
    
}
@property (nonatomic, assign) id<ANLocationDelegate> locationDelegate;
/**fun
 * @brief: 单例
 * @return:
 */
+ (instancetype)sharedInstance;

/**fun
 * @brief: 开启 关闭位置更新
 * @return:
 */
-(void)startUpdateLocation;
-(void)stopUpdateLocation;

/**fun
 * @brief: 开启 关闭方向更新
 * @return:
 */
-(void)startUpdateHeading;
-(void)stopUpdateHeading;


@end

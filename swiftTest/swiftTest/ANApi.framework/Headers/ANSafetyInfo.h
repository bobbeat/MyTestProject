//
//  ANSafetyInfo.h
//  ANApi
//
//  Created by autonavi\wang.weiyang on 14-10-16.
//  Copyright (c) 2014年 Autonavi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ANSafetyHeader.h"
#import <CoreLocation/CoreLocation.h>

/**
 * 安全信息
 */
@interface ANSafetyInfo : NSObject

/**
 *  初始化类
 *
 *  @param safeInfo 安全信息
 *
 *  @return 自身实例
 */
- (instancetype)initWithSafetyInfo:(ANSafetyInfo *)safeInfo;

- (instancetype)initWithName:(NSString *)name coordinate:(CLLocationCoordinate2D)coordinate adminCode:(int)adminCode category:(ANSafetyCategory)category speed:(int)speed;

- (instancetype)initWithId:(int)safetyId name:(NSString *)name coordinate:(CLLocationCoordinate2D)coordinate adminCode:(int)adminCode category:(ANSafetyCategory)category speed:(int)speed;

/**
 *  行政区域编号
 */
@property(nonatomic) int adminCode;

/**
 *  安全信息id
 */
@property(nonatomic) long safetyId;

/**
 *  安全信息类别
 */
@property(nonatomic) ANSafetyCategory category;

/**
 *  名称
 */
@property(strong, nonatomic) NSString *name;

/**
 *  经纬度
 */
@property(assign, nonatomic) CLLocationCoordinate2D coordinate;

/**
 *  速度
 */
@property(nonatomic) int speed;

@end

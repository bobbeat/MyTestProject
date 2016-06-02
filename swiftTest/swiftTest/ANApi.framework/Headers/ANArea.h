//
//  ANArea.h
//  ProjectDemoOnlyCode
//
//  Created by chenjie on 14-11-5.
//  Copyright (c) 2014年 liyuhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <CoreLocation/CoreLocation.h>

/**
 *  行政区域
 */
@interface ANArea : NSObject

/**
 *  获得所有行政区域
 *
 *  @return 行政区域列表
 */
+(NSArray *)allAreas;
/**
 *  获得网络待选行政区域列表
 *
 *  @return 行政区域列表
 */
+(NSArray *)allNetCandidateAreas;
/**
 *  根据经纬度获得行政区域
 *
 *  @param coordinate 经纬度
 *
 *  @return 行政区域
 */
+(ANArea *)areaFromCoordinate:(CLLocationCoordinate2D)coordinate;
/**
 *  行政区域编号
 */
@property (nonatomic) int areaId;
/**
 *  名称
 */
@property (strong, nonatomic) NSString *name;
/**
 *  英文首字母
 */
@property (strong, nonatomic) NSString *spell;
/**
 *  明细id
 */
@property (nonatomic) int detailId;
/**
 *  二级区域数量
 */
@property (nonatomic) int numberOfSubAreas;
/**
 *  二级区域列表
 */
@property (strong, nonatomic) NSArray *subAreas;
/**
 *  中心经纬度
 */
@property (nonatomic) CLLocationCoordinate2D centerCoordinate;
/**
 *  地图数据是否存在
 */
@property (nonatomic) BOOL isMapDataExist;
/**
 *  电话
 */
@property (strong, nonatomic) NSString *tel;
/**
 *  省
 */
@property (strong, nonatomic) NSString *province;
/**
 *  城市
 */
@property (strong, nonatomic) NSString *city;
/**
 *  地区
 */
@property (strong, nonatomic) NSString *district;

@end
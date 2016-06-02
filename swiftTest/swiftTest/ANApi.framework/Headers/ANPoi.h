//
//  ANPoi.h
//  ANApi
//
//  Created by chenjie on 14-10-21.
//  Copyright (c) 2014年 Autonavi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#ifdef MacroFoFramework
#import <ANApi/ANPoiCategory.h>
#else
#import "ANPoiCategory.h"
#endif

/**
 *  POI对象，point of interest
 */
@interface ANPoi : NSObject

/**
*  名称
*/
@property (nonatomic,copy) NSString *name;

/**
 *  类别
 */
@property (nonatomic,copy) ANPoiCategory *category;

/**
 *  经纬度
 */
@property (nonatomic) CLLocationCoordinate2D coordinate;

/**
 *  导航经纬度
 */
@property (nonatomic) CLLocationCoordinate2D naviCoordinate;

/**
 *  距参考点的距离
 */
@property (nonatomic,assign) int distance;

/**
 *  匹配度，表示关键字匹配程度
 */
@property (nonatomic,assign) int matchDegree;

/**
 *  地址
 */
@property (nonatomic,copy) NSString *address;

/**
 *  电话
 */
@property (nonatomic,copy) NSString *tel;

/**
 *  POI唯一ID
 */
@property (nonatomic,assign) GOBJECTID poiId;

/**
 *  类别编码，参见POI类别编码表
 */
@property (nonatomic,assign) int categoryId;

/**
 *  行政编码，参见行政区域编码表
 */
@property (nonatomic,assign) int areaId;

/**
 *  匹配高亮显示，从低位到高位匹配名称字段，最多32位
 */
@property (nonatomic,assign) int highlightFlag;

/**
 *  POI索引，内部使用
 */
@property (nonatomic,assign) int poiIndex;

/**
 *  bit0:出入口；bit1:楼宇；bit2:亲属关系；bit3:用户POI；
 */
@property (nonatomic,assign) int flag;

/**
 *  保留(行程点：0表示未达到、1表示已到达)
 */
@property (nonatomic,assign) int reserved;

/**
 *  优先级别
 */
@property (nonatomic,assign) int priority;

@end



//
//  ANPoiSearchOption.h
//  ProjectDemoOnlyCode
//
//  Created by autonavi\wang.weiyang on 14-12-11.
//  Copyright (c) 2014年 liyuhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
@class ANPoiCategory;
@class ANRoute;
@class ANPoiSearchByNameOption;
@class ANPoiSearchByCategoryOption;
@class ANPoiSearchByTelOption;
@class ANPoiSearchAroundOption;
@class ANPoiSearchByAddressOption;
@class ANPoiSearchByRouteOption;
@class ANPoiSearchByCrossingOption;
@class ANPoiSearchByHouseNoOption;

@class ANPoiSearchByRoadNameOption;

/**
 *  poi查询类别
 */
typedef NS_ENUM(NSInteger, ANPoiSearchType) {
    ANPoiSearchTypeName = 0,    ///<按姓名
    ANPoiSearchTypeCategory,    ///<按类别
    ANPoiSearchTypeTel,         ///<按电话
    ANPoiSearchTypeAround,      ///<按周边
    ANPoiSearchTypeAddress,     ///<按地址
    ANPoiSearchTypeRoutePoi,    ///<按路线搜索
    ANPoiSearchTypeCrossing,    ///<交叉路口
    ANPoiSearchTypeHouseNo,     ///<按房址
    ANPoiSearchTypeRoadName,    ///<按道路名
};

/**
 *  按路线查询类别
 */
typedef NS_ENUM(NSInteger, ANPoiSearchRoutePoiType) {
    ANPoiSearchRoutePoiTypeStart = 0,       ///< 起点
    ANPoiSearchRoutePoiTypeUserLocation,    ///< 当前位置
    ANPoiSearchRoutePoiTypeAll,             ///< 全部
};

/**
 *  poi排序方式
 */
typedef NS_ENUM(NSInteger, ANPoiSearchSortType) {
    ANPoiSearchSortTypeNone = 0,  ///< 无排序
    ANPoiSearchSortTypeDistance   ///< 按距离升序
};

/**
 *  查询类别基类
 */
@interface ANPoiSearchOption : NSObject{
@protected
    ANPoiSearchType _searchType;
    int _areaId;
}

/**
 *  查询类型
 */
@property (nonatomic, readonly) ANPoiSearchType searchType;

/**
 *  行政区域编号
 */
@property (nonatomic, readonly) int areaId;

/**
 *  排序方式
 */
@property (nonatomic) ANPoiSearchSortType sortType;

/**
 *  页码
 */
@property (nonatomic) int pageIndex;

/**
 *  页大小
 */
@property (nonatomic) int pageSize;

@end

#pragma mark -
#pragma mark 按关键字搜索参数类

/**
 *  最近搜索参数类
 */
@interface ANPoiSearchNearestOption : ANPoiSearchOption

+ (ANPoiSearchNearestOption *)poiSearchNearestOption:(CLLocationCoordinate2D)coordinate areaId:(int)areaId;

/**
 *  经纬度
 */
@property (nonatomic) CLLocationCoordinate2D coordinate;

@end

#pragma mark -
#pragma mark 按关键字搜索参数类

/**
 *  按名称搜索参数类
 */
@interface ANPoiSearchByNameOption : ANPoiSearchOption

/**
 *  按名称搜索
 *
 *  @param keyword 关键字
 *  @param areaId  行政区域ID
 *
 *  @return 查询参数
 */
+ (ANPoiSearchByNameOption *)poiSearchByNameOption:(NSString *)keyword areaId:(int)areaId;

/**
 *  poi类别
 */
@property (nonatomic) ANPoiCategory *poiCategory;

/**
*  关键字
 */
@property (strong, nonatomic) NSString *keyWord;

@end

#pragma mark -
#pragma mark 按类别搜索参数类

/**
 *  按类别搜索参数类
 */
@interface ANPoiSearchByCategoryOption : ANPoiSearchOption

/**
 *  按类别搜索
 *
 *  @param poiCategory 类别
 *  @param areaId      行政区域ID
 *
 *  @return 查询参数
 */
+ (ANPoiSearchByCategoryOption *)poiSearchByCategoryOption:(ANPoiCategory *)poiCategory areaId:(int)areaId;

/**
 *  poi类别
 */
@property (nonatomic) ANPoiCategory *poiCategory;

/**
 *  关键字
 */
@property (strong, nonatomic) NSString *keyWord;

@end

#pragma mark -
#pragma mark 按电话搜索参数类

/**
 *  按电话搜索参数类
 */
@interface ANPoiSearchByTelOption : ANPoiSearchOption

/**
 *  按电话搜索
 *
 *  @param keyword 关键字
 *  @param areaId  行政区域ID
 *
 *  @return 查询参数
 */
+ (ANPoiSearchByTelOption *)poiSearchByTelOption:(NSString *)keyword areaId:(int)areaId;

/**
 *  poi类别
 */
@property (nonatomic) ANPoiCategory *poiCategory;

/**
 *  关键字
 */
@property (strong, nonatomic) NSString *keyWord;

@end

#pragma mark -
#pragma mark 搜索周边参数类

/**
 *  周边搜索参数类
 */
@interface ANPoiSearchAroundOption : ANPoiSearchOption

/**
 *  周边搜索
 *
 *  @param coordinate 经纬度
 *  @param radius     范围
 *  @param areaId     行政区域ID
 *
 *  @return 查询参数
 */
+ (ANPoiSearchAroundOption *)poiSearchAroundOption:(CLLocationCoordinate2D)coordinate radius:(int)radius  areaId:(int)areaId;

/**
 *  poi类别
 */
@property (nonatomic) ANPoiCategory *poiCategory;

/**
 *  经纬度
 */
@property (nonatomic) CLLocationCoordinate2D coordinate;

/**
 *  范围
 */
@property (nonatomic) int radius;

@end

#pragma mark -
#pragma mark 按地址搜索参数类

/**
 *  按地址搜索参数类
 */
@interface ANPoiSearchByAddressOption : ANPoiSearchOption

/**
 *  按地址搜索
 *
 *  @param keyword 关键字
 *  @param areaId  行政区域ID
 *
 *  @return 查询参数
 */
+ (ANPoiSearchByAddressOption *)poiSearchByAddressOption:(NSString *)keyword areaId:(int)areaId;

/**
 *  poi类别
 */
@property (nonatomic) ANPoiCategory *poiCategory;

/**
 *  关键字
 */
@property (strong, nonatomic) NSString *keyWord;

@end

#pragma mark -
#pragma mark 按线路搜索参数类

/**
 *  按路线搜索参数类
 */
@interface ANPoiSearchByRouteOption : ANPoiSearchOption

/**
*  按路线搜索
*
*  @param route        路线
*  @param routePoiType 搜索类型
*  @param areaId       行政区域ID
*
*  @return 查询参数
*/
+ (ANPoiSearchByRouteOption *)poiSearchByRouteOption:(ANRoute *)route routePoiType:(ANPoiSearchRoutePoiType)routePoiType areaId:(int)areaId;

/**
 *  poi类别
 */
@property (nonatomic) ANPoiCategory *poiCategory;

/**
 *  线路
 */
@property (strong, nonatomic) ANRoute *route;

/**
 *  搜索类型
 */
@property (nonatomic) ANPoiSearchRoutePoiType routePoiType;

@end

#pragma mark -
#pragma mark 按十字路口搜索参数类

/**
 *  按十字路口搜索参数类
 */
@interface ANPoiSearchByCrossingOption : ANPoiSearchOption

/**
 *  按十字路口搜索
 *
 *  @param keyword 关键字
 *  @param areaId  行政区域ID
 *
 *  @return 查询参数
 */
+ (ANPoiSearchByCrossingOption *)poiSearchByCrossingOption:(NSString *)keyword areaId:(int)areaId;

/**
 *  poi类别
 */
@property (nonatomic) ANPoiCategory *poiCategory;

/**
 *  关键字
 */
@property (strong, nonatomic) NSString *keyWord;

@end

#pragma mark -
#pragma mark 按房址搜索参数类

/**
 *  按房址搜索参数类
 */
@interface ANPoiSearchByHouseNoOption : ANPoiSearchOption

/**
 *  按房址名称搜索
 *
 *  @param keyword 关键字
 *  @param areaId  行政区域ID
 *
 *  @return 查询参数
 */
+ (ANPoiSearchByHouseNoOption *)poiSearchByHouseNoOption:(NSString *)keyword areaId:(int)areaId;

/**
 *  poi类别
 */
@property (nonatomic) ANPoiCategory *poiCategory;

/**
 *  关键字
 */
@property (strong, nonatomic) NSString *keyWord;

@end

#pragma mark -
#pragma mark 按道路名称搜索参数类

/**
 *  按道路名称搜索参数类
 */
@interface ANPoiSearchByRoadNameOption : ANPoiSearchOption

/**
 *  按道路名称搜索
 *
 *  @param keyword 关键字
 *  @param areaId  行政区域ID
 *
 *  @return 查询参数
 */
+ (ANPoiSearchByRoadNameOption *)poiSearchByRoadNameOption:(NSString *)keyword areaId:(int)areaId;

/**
 *  poi类别
 */
@property (nonatomic) ANPoiCategory *poiCategory;

/**
 *  关键字
 */
@property (strong, nonatomic) NSString *keyWord;

@end

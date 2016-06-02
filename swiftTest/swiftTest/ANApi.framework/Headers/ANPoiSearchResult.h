//
//  ANPoiSearchResult.h
//  ProjectDemoOnlyCode
//
//  Created by autonavi\wang.weiyang on 14-12-11.
//  Copyright (c) 2014年 liyuhang. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  poi查询结果状态
 */
typedef NS_ENUM(NSUInteger, ANPoiSearchResultStatus) {
    ANPoiSearchResultStatusSuccess = 0, ///< 成功
    ANPoiSearchResultStatusNoResult, ///< 无数据
    ANPoiSearchResultStatusResultInOtherCities, ///< 其他城市有信息，可在cities对象中获得
    ANPoiSearchResultStatusFailed, ///< 失败
};

/**
 *  poi查询结果
 */
@interface ANPoiSearchResult : NSObject

/**
 *  poi查询状态
 */
@property (nonatomic) ANPoiSearchResultStatus status;
/**
 *  页码
 */
@property (nonatomic) int pageIndex;
/**
 *  页大小
 */
@property (nonatomic) int pageSize;
/**
 *  总页数
 */
@property (nonatomic) int totalPageCount;
/**
 *  总纪录数
 */
@property (nonatomic) int totalItemCount;
/**
 *  poi列表
 */
@property (strong, nonatomic) NSArray *pois;
/**
 *  城市信息
 */
@property (strong, nonatomic) NSArray *cities;

@end

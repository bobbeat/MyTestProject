//
//  ANPoiSearcher.h
//  ProjectDemoOnlyCode
//
//  Created by autonavi\wang.weiyang on 14-12-11.
//  Copyright (c) 2014年 liyuhang. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol ANPoiSearchProtocol;
@class ANPoiSearchOption;
@class ANPoiSearchResult;

/**
 *  poi查询
 */
@interface ANPoiSearcher : NSObject

/**
 *  查询协议
 */
@property (assign, nonatomic) id<ANPoiSearchProtocol> delegate;
/**
 *  查询条件
 */
@property (strong, nonatomic, readonly) ANPoiSearchOption *option;
/**
 *  开始查询
 *
 *  @param option 查询条件
 *
 *  @return 是否成功
 */
- (BOOL)startSearch:(ANPoiSearchOption *)option;
/**
 *  开始网络查询
 *
 *  @param option 查询条件
 *
 *  @return 是否成功
 */
- (BOOL)startCloudSearch:(ANPoiSearchOption *)option;
/**
 *  停止查询
 *
 *  @return 是否成功
 */
- (BOOL)stopSearch;
/**
 *  是否正在查询
 */
@property (nonatomic, readonly) BOOL isSearching;

@end
/**
 *  查询协议
 */
@protocol ANPoiSearchProtocol <NSObject>
/**
 *  查询返回值
 *
 *  @param poiSearcher 查询对象
 *  @param result      查询结果
 *  @param error       错误信息
 */
- (void)poiSearcher:(ANPoiSearcher *)poiSearcher finishSearchWithResult:(ANPoiSearchResult *)result error:(NSError *)error;

@end
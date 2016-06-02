//
//  ANPoiCategory.h
//  ANApi
//
//  Created by chenjie on 14-10-21.
//  Copyright (c) 2014年 Autonavi. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 @brief  POI类别信息结构
 * 用于存储POI类别信息
 */
@interface ANPoiCategory : NSObject

/*!
 @brief 类别编号，参见POI类别编码表
 */
@property (nonatomic,copy) NSString* name;

/*!
 @brief 子类别 存储 MWPoiCategory 对象
 */
@property (nonatomic,strong) NSArray *subCategory;



/*!
 @brief 类别索引，通过类别索引来获取子类信息
 */

@property (nonatomic,assign) NSUInteger  categoryIndex;
/*!
 @brief 类别编号个数
 */

@property (nonatomic,assign) NSUInteger  categoryIDNum;

/*!
 @brief 类别编号数组，参见POI类别编码表
 */
@property (nonatomic,strong) NSMutableArray  *categoryIDArray;

/*!
 @brief 子类个数
 */
@property (nonatomic,assign) int numberOfSubCategory;

/*!
 @brief 保留
 */
@property (nonatomic,assign) int reserved;

/*!
 @brief 使用次数
 */
@property (nonatomic, assign) int useCount;

/*!
 @brief 图片名称
 */
@property (nonatomic, copy) NSString *imageName;

/*!
 @brief 高亮图片名称
 */
@property (nonatomic, copy) NSString *highLightImageName;

/*!
 @brief category索引
 */
@property (nonatomic, assign) int categorySortIndex;

/**
 *  获得所有类目
 *
 *  @return 类目列表
 */
+ (NSArray *)allPoiCategories;

@end

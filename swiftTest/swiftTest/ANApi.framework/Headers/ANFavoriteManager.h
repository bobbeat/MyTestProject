//
//  ANFavoriteManager.h
//  ANApiSDK
//
//  Created by yang yi on 14-10-13.
//  Copyright (c) 2014年 Autonavi. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef MacroFoFramework
#import <ANApi/ANTypeDef.h>
#import <ANApi/ANFavoritePoi.h>
#else
#import "ANTypeDef.h"
#import "ANFavoritePoi.h"
#endif

@class ANPoi;
@class ANFavoritePoi;

/**
 *  收藏夹管理
 */
@interface ANFavoriteManager : NSObject

+ (ANFavoriteManager *)sharedInstance;

/**
 *  收藏指定条件兴趣点
 *
 *  @param favoritePoi POI收藏条件
 *
 *  @return 成功返回AN_ERR_OK，失败返回相应错误码
 */
-(ANErrStatus)collectPoiWith:(ANFavoritePoi *)favoritePoi;

/**
 *  清空所有收藏
 *
 *  @return 成功返回AN_ERR_OK，失败返回相应错误码
 */
-(ANErrStatus)clearFavorite;

/**
 *  清空收藏夹兴趣点
 *
 *  @param eCategory poi的类型
 *
 *  @return 成功返回AN_ERR_OK，失败返回相应错误码
 */
-(ANErrStatus)clearFavoriteWith:(ANFAVORITECATEGORY)eCategory;

/**
 *  编辑已收藏的兴趣点
 *
 *  @param favoritePoi 编辑后的兴趣点  注：（无需设置Date，Time两个参数）
 *
 *  @return 成功返回AN_ERR_OK，失败返回相应错误码
 */
-(ANErrStatus)editeFavoritePoiWith:(ANFavoritePoi *)favoritePoi;

/**
 *  获取已收藏的兴趣点列表
 *
 *  @param eCategory  收藏的兴趣点类别GFAVORITECATEGORY，用于标识要获取的收藏夹类别。
 *
 *  @return 成功返回NSArray*，失败返回nil
 */
-(NSArray*)getPoiListWith:(ANFAVORITECATEGORY)eCategory;

/**
 *  删除收藏夹poi(参数为索引值)
 *
 *  @param eCategory 需要删除的类别
 *  @param index 收藏的兴趣点的索引 (即 ANFavoritePoi 类中的 nIndex)
 *
 *  @return 成功返回AN_ERR_OK，失败返回相应错误码
 */
-(ANErrStatus)deleteFavoriteWith:(ANFAVORITECATEGORY)eCategory index:(int)index;

/**
 *  判断该点是否收藏
 *
 *  @param favoritePoi 要收藏的点
 *
 *  @return 成功返回AN_ERR_OK，失败返回相应错误码
 */
-(BOOL)isCollect:(ANPoi *)favoritePoi;

/**
 *	若该点已收藏，则取消收藏该点，若未收藏则收藏该点
 *
 *	@param	favoritePoi	要收藏的点
 *
 *	@return	收成功返回AN_ERR_OK，失败返回相应错误码
 */
-(BOOL)reverseCollectPoi:(ANFavoritePoi *)favoritePoi;

@end

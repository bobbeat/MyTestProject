//
//  ANFavoritePoi.h
//  ANApi
//
//  Created by chenjie on 14-10-21.
//  Copyright (c) 2014年 Autonavi. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef MacroFoFramework
#import <ANApi/ANPoi.h>
#else
#import "ANPoi.h"
#endif

/**
 * 收藏兴趣点类别枚举类型
 * 可以组合
 */
typedef NS_ENUM(NSUInteger, ANFAVORITECATEGORY)
{
    ANFAVORITE_CATEGORY_DEFAULT         = 0x00000001,   ///< 默认
    ANFAVORITE_CATEGORY_HOME            = 0x00000002,   ///< 我家
    ANFAVORITE_CATEGORY_COMPANY         = 0x00000004,   ///< 公司
    ANFAVORITE_CATEGORY_SIGHT           = 0x00000008,   ///< 景点
    ANFAVORITE_CATEGORY_FRIEND          = 0x00000010,   ///< 朋友
    ANFAVORITE_CATEGORY_CUSTOMER        = 0x00000020,   ///< 客户
    ANFAVORITE_CATEGORY_ENTERTAINMENT   = 0x00000040,   ///< 娱乐
    ANFAVORITE_CATEGORY_HISTORY         = 0x00000080,   ///< 历史目的地
    ANFAVORITE_CATEGORY_ALL             = 0x000000ff,   ///< 所有类别
    ANFAVORITE_CATEGORY_MAX             = 0x00000100    ///< 其他
};

/**
 * 收藏兴趣点显示图标类别枚举类型
 *
 */
typedef NS_ENUM(NSUInteger,ANFAVORITEICON)
{
    ANFAVORITE_ICON_DEFAULT = 1,    ///< 默认
    ANFAVORITE_ICON_HOME,	 		///< 我家
    ANFAVORITE_ICON_COMPANY,        ///< 公司
    ANFAVORITE_ICON_FRIEND,	 		///< 朋友
    ANFAVORITE_ICON_DINING,	 		///< 饮食
    ANFAVORITE_ICON_LEISURE,        ///< 休闲
    ANFAVORITE_ICON_SHOPPING,		///< 购物
    ANFAVORITE_ICON_WORK,			///< 工作
    ANFAVORITE_ICON_SIGHT,	 		///< 景点
    ANFAVORITE_ICON_CUSTOMER,		///< 客户
    ANFAVORITE_ICON_ENTERTAINMENT,	///< 娱乐
    ANFAVORITE_ICON_HISTORY,        ///< 历史目的地
    ANFAVORITE_ICON_MAX				///< 收藏兴趣点显示图标类别枚举类型最大值 
};

#pragma mark - ANFavoritePoi
/*!
  @brief 地址簿，历史目的地的兴趣点类
  */
@interface ANFavoritePoi : ANPoi


/*!
  @brief 0为历史目的地，1为历史搜索
  */
@property (nonatomic, assign) int historyType;

/*!
  @brief 收藏兴时间，包括年月日时分秒
  */
@property (nonatomic, assign) long long saveTime;

/*!
  @brief 兴趣点的索引，可用于删除兴趣点
  */
@property (nonatomic,assign) int index;

/*!
  @brief 收藏兴趣点类别枚举类型
  */
@property (nonatomic,assign) ANFAVORITECATEGORY category;


/*!
  @brief 收藏兴趣点显示图标类别枚举类型
  */
@property (nonatomic,assign) ANFAVORITEICON iconID;

/*!
  @brief POI修改操作: 0(无操作)、1(添加)、2(删除)、3(更新)  此变量用于 同步收藏夹
  */
@property (nonatomic,assign) int		actionType;

@end

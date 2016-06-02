//
//  MWFavorite.h
//  AutoNavi
//
//  Created by gaozhimin on 13-7-30.
//
//

#import "MWSearchResult.h"

/*!
  @brief 地址簿，历史目的地的兴趣点类
  @see GFAVORITECATEGORY
  */
@interface MWFavoritePoi : MWPoi


/*!
  @brief 兴趣点的索引，可用于删除兴趣点
  */
@property (nonatomic,assign) int nIndex;

/*!
  @brief 收藏兴趣点类别枚举类型
  @see GFAVORITECATEGORY
  */
@property (nonatomic,assign) GFAVORITECATEGORY eCategory;


/*!
  @brief 收藏兴趣点显示图标类别枚举类型
  @see GFAVORITECATEGORY
  */
@property (nonatomic,assign) GFAVORITEICON eIconID;

/*!
  @brief 收藏的日期
  @see GDATE
  */
@property (nonatomic,assign) GDATE				Date;

/*!
  @brief 收藏的时间
  @see GTIME
  */
@property (nonatomic,assign) GTIME				Time;

@end

/*!
  @brief 获取地址簿，历史目的地的信息类
  @see GFAVORITECATEGORY
  */
@interface MWFavorite : NSObject

/*!
  @brief 上次服务器同步数据日期
  @see GDATE
  */
@property (nonatomic,assign) GDATE				Date;

/*!
  @brief 上次服务器同步数据时间
  @see GTIME
  */
@property (nonatomic,assign) GTIME				Time;

/*!
  @brief 上次与服务器同步的用户id
  */
@property (nonatomic,copy) NSString*			userId;

/*!
  @brief 服务器下发，所有poi的标识，这里的标识用经纬度 用逗号隔开 如（经度,纬度,经度,纬度,经度,纬度）  注：服务器下发解析中使用
  */
@property (nonatomic,copy) NSString*			allIdentify;

/*!
  @brief 收藏夹兴趣点个数
  */
@property (nonatomic,assign) int				nNumberOfItem;

/*!
  @brief 收藏夹兴趣点 
  @see MWFavoritePoi
  */
@property (nonatomic,retain) NSMutableArray			*pFavoritePOIArray;
@end

/*!
  @brief 上传，下载兴趣点条件类
  @see GFAVORITECATEGORY
  */
@interface MWFavoriteOption : NSObject

/*!
  @brief 收藏夹兴趣点个数
  */
@property (nonatomic,assign) GFAVORITECATEGORY				eCategory;

@end


/*!
  @brief 此类用于解析
  */
@interface MWFavXMLParser : NSObject <NSXMLParserDelegate>
{
@private
	NSMutableString *currentProperty;
	MWFavoritePoi *itemNode;
}

- (BOOL)parser:(NSData *)data;

/*!
  @brief 收藏夹，历史目的地
  */
@property (nonatomic,retain) MWFavorite		*favorite;

@end

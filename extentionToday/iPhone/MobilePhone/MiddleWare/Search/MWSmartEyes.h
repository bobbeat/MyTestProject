//
//  MWSmartEyes.h
//  AutoNavi
//
//  Created by gaozhimin on 13-7-30.
//
//

#import <Foundation/Foundation.h>
#import "MWSearchResult.h"

/***************************************!
  @brief 电子眼信息类
  **************************************/
@interface MWSmartEyesItem : MWPoi

/*!
  @brief 索引
  */
@property (nonatomic,assign) int			nIndex;

/*!
  @brief 索引
  */
@property (nonatomic,assign) Gint32          nId;        /**< 用户电子眼ID */

/*!
  @brief 安全信息类别
  */
@property (nonatomic,assign) GSAFECATEGORY			eCategory;

/*!
  @brief 限速值
  */
@property (nonatomic,assign) int			nSpeed;

/*!
  @brief 电子眼角度（东0，逆向）
  */
@property (nonatomic,assign) int			nAngle;


/*!
  @brief 添加的日期
  */
@property (nonatomic,assign) GDATE			Date;

/*!
  @brief 添加的时间
  */
@property (nonatomic,assign) GTIME			Time;

@end

/*******************************!
  @brief 用户自定义电子眼信息列表类
  *******************************/
@interface MWSmartEyes : NSObject

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
  @brief 服务器下发，所有poi的标识，这里的标识用经纬度 用逗号隔开 如（经度,纬度,经度,纬度,经度,纬度）  注：服务器下发解析中使用
  */
@property (nonatomic,copy) NSString*			allIdentify;

/*!
  @brief 上次与服务器同步的用户名
  */
@property (nonatomic,copy) NSString*			userId;

/*!
  @brief 用户自定义电子眼个数
  */
@property (nonatomic,assign) int			nNumberOfItem;

/*!
  @brief 用户自定义电子眼   储存 MWSmartEyesItem 对象
  */
@property (nonatomic,retain) NSMutableArray*			smartEyesArray;

@end

/*!
  @brief 上传，下载兴趣点条件类
  @see GFAVORITECATEGORY
  */
@interface MWSmartEyesOption : NSObject


/*!
  @brief 安全信息类别
  */
@property (nonatomic,assign) GSAFECATEGORY			eCategory;


/*!
  @brief 高德用户名   必填
  */
@property (nonatomic,copy) NSString			*userName;

/*!
  @brief 高德用户密码   必填
  */
@property (nonatomic,copy) NSString			*password;

@end

/*!
  @brief 此类用于解析
  */
@interface MWSmartEyesXMLParser : NSObject <NSXMLParserDelegate>
{
@private
	NSMutableString *currentProperty;
	MWSmartEyesItem *itemNode;
}

- (BOOL)parser:(NSData *)data;

/*!
  @brief 收藏夹，历史目的地
  */
@property (nonatomic,readonly) MWSmartEyes		*smartEyes;

@end



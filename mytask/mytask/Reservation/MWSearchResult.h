//
//  MWSearchResult.h
//  AutoNavi
//
//  Created by gaozhimin on 13-7-29.
//
//

#import <Foundation/Foundation.h>

@interface MWPoi : NSObject

/*!
  @brief 经度坐标
  */
@property (nonatomic,assign) long longitude;

/*!
  @brief 纬度坐标
  */
@property (nonatomic,assign) long latitude;

/*!
  @brief 类别编码，参见POI类别编码表
  */
@property (nonatomic,assign) int lCategoryID;

/*!
  @brief 距参考点的距离
  */
@property (nonatomic,assign) int lDistance;

/*!
  @brief 匹配度，表示关键字匹配程度
  */
@property (nonatomic,assign) int lMatchCode;

/*!
  @brief 匹配高亮显示，从低位到高位匹配名称字段，最多32位
  */
@property (nonatomic,assign) int lHilightFlag;

/*!
  @brief 行政编码，参见行政区域编码表
  */
@property (nonatomic,assign) int lAdminCode;


/*!
  @brief 导航经度坐标, 与longitude差值
  */
@property (nonatomic,assign) int lNaviLat;


/*!
  @brief 导航纬度坐标, 与latitude差值
  */
@property (nonatomic,assign) int lNaviLon;

/*!
  @brief 名称
  */
@property (nonatomic,copy) NSString * szName;

/*!
  @brief 地址
  */
@property (nonatomic,copy) NSString * szAddr;

/*!
  @brief 电话
  */
@property (nonatomic,copy) NSString * szTel;

/*!
  @brief 电话
  */
@property (nonatomic,copy) NSString * szTown;

/*!
  @brief POI索引，内部使用
  */
@property (nonatomic,assign) int lPoiIndex;

/*!
  @brief bit0:出入口；bit1:楼宇；bit2:亲属关系；bit3:用户POI；
  */

@property (nonatomic,assign) int ucFlag;

/*!
  @brief 保留(行程点：0表示未达到、1表示已到达)
  */
@property (nonatomic,assign) int Reserved;

/*!
  @brief 交叉节点ID
  */
@property (nonatomic,assign) int usNodeId;

/*!
  @brief poi唯一id（这个是由服务器端生成）
  */
@property (nonatomic,copy) NSString* netPoiId;

/*!
  @brief 与该poi绑定的帐号id
  */
@property (nonatomic,copy) NSString* accountId;

/*!
  @brief POI修改操作: 0(无操作)、1(添加)、2(删除)、3(更新)  此变量用于 同步收藏夹
  */
@property (nonatomic,assign) int		actionType;

@end


/*!
 @brief POI检索结果结构体
 * 用于存储POI检索结果
 */
@interface MWSearchResult : NSObject

/*!
 @brief 总的个数
 */
@property (nonatomic,assign) int numberOfTotalItem;

/*!
 @brief 获取的第一个索引
 */
@property (nonatomic,assign) int index;

/*!
 @brief 获取的POI个数
 */
@property (nonatomic,assign) int numberOfItemGet;

/*!
 @brief 保留
 */
@property (nonatomic,assign) int reserved;

/*!
 @brief 返回的MWPoi对象的序列
 */
@property (nonatomic,retain) NSArray *pois;

@end

/*!
 @brief  POI类别列表结构
 * 用于存储POI类别信息
 */
@interface MWPoiCategoryList : NSObject

/*!
 @brief 类别个数
 */
@property (nonatomic,assign) int lNumberOfCategory;

/*!
 @brief 类别信息 存储 MWPoiCategory 对象
 */
@property (nonatomic,retain) NSArray *pCategoryArray;

@end

/*!
 @brief  POI类别信息结构
 * 用于存储POI类别信息
 */
@interface MWPoiCategory : NSObject

/*!
 @brief 类别编号个数
 */

@property (nonatomic,assign) int  nCategoryIDNum;

/*!
 @brief 类别编号数组，参见POI类别编码表
 */
@property (nonatomic,retain) NSMutableArray  *pnCategoryID;

/*!
 @brief 子类个数
 */
@property (nonatomic,assign) int nNumberOfSubCategory;

/*!
 @brief 保留
 */
@property (nonatomic,assign) int Reserved;

/*!
 @brief 类别编号，参见POI类别编码表
 */
@property (nonatomic,copy) NSString* szName;

/*!
 @brief 子类别 存储 MWPoiCategory 对象
 */
@property (nonatomic,retain) NSArray *pSubCategoryArray;

@end



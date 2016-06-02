//
//  MWRouteDetour.h
//  AutoNavi
//
//  Created by gaozhimin on 14-5-7.
//
//

#import <Foundation/Foundation.h>

/*!
  @brief 避让模块
  */

@interface MWRouteDetour : NSObject

/**
 **********************************************************************
 \brief 添加避让道路
 \details 添加避让道路，保存到避让文件中。
 \param[in]  pstDetourRoad 避让道路信息
 \retval	GD_ERR_OK 成功
 \retval	GD_ERR_INVALID_PARAM	参数无效
 \retval	GD_ERR_NO_DATA 无相关数据
 \retval	GD_ERR_FAILED	操作失败
 \remarks
 \since 6.0
 \see GDBL_GetDetourRoadList
 **********************************************************************/
+ (GSTATUS)AddDetourRoad:(GDETOURROADINFO *)pstDetourRoad;

/**
 **********************************************************************
 \brief 编辑避让道路
 \details 编辑避让道路，保存到避让文件中。
 \param[in]  pstDetourRoad 避让道路
 \retval	GD_ERR_OK 成功
 \retval	GD_ERR_INVALID_PARAM	参数无效
 \retval	GD_ERR_NO_DATA 无相关数据
 \retval	GD_ERR_FAILED	操作失败
 \remarks
 \since 6.0
 \see GDBL_GetDetourRoadList
 **********************************************************************/
+ (GSTATUS)EditDetourRoad:(GDETOURROADINFO *)pDetourRoad;

/**
 **********************************************************************
 \brief 删除指定避让道路
 \details 删除指定避让道路，保存到避让文件中。
 \param[in]  pnIndex 避让道路索引数组
 \param[in]  count 索引数组大小
 \retval	GD_ERR_OK 成功
 \retval	GD_ERR_FAILED	操作失败
 \remarks
 \since 6.0
 \see GDBL_GetDetourRoadList
 **********************************************************************/
+ (GSTATUS)DelDetourRoad:(Gint32 *)pnIndex count:(Gint32)count;

/**
 **********************************************************************
 \brief 删除所有避让道路
 \details 删除所有避让道路，保存到避让文件中。
 \retval	GD_ERR_OK 成功
 \retval	GD_ERR_FAILED	操作失败
 \remarks
 \since 6.0
 \see GDBL_GetDetourRoadList
 **********************************************************************/
+ (GSTATUS)ClearDetourRoad;

/**
 **********************************************************************
 \brief 获取避让道路列表
 \details 获取当前保存的避让道路列表。
 \param[out]  ppstDetourRoadList 避让道路列表
 \retval	GD_ERR_OK 成功
 \retval	GD_ERR_NO_MEMORY	内存不足
 \retval	GD_ERR_NO_DATA 无相关数据
 \remarks
 \since 6.0
 \see GDBL_AddDetourRoad GDBL_EditDetourRoad GDBL_DelDetourRoad GDBL_ClearDetourRoad
 **********************************************************************/
+ (GSTATUS)GetDetourRoadList:(GDETOURROADLIST **)ppstDetourRoadList;

/**
 **********************************************************************
 \brief 判断道路是否已被避让
 \details 判断道路是否已被避让,必过道路返回值成功但不避让。
 \param[in]  stObjectId 对象ID
 \param[out]  pbDetoured 是否避让结果
 \retval	GD_ERR_OK 成功
 \retval	GD_ERR_INVALID_PARAM	参数无效
 \retval	GD_ERR_FAILED	操作失败
 \remarks
 \since 6.0
 \see
 **********************************************************************/
+ (GSTATUS)IsDetoured:(GOBJECTID *)pstObjectId bDetoured:(Gbool *)pbDetoured;

/**
 **********************************************************************
 \brief 更新云端避让文件
 \details 更新云端避让文件
 \param[in]  szFullPathFileName 为GNULL时，清空缓存。为非GNULL时，避让文件全路径
 \retval	GD_ERR_OK 成功
 \retval	GD_ERR_INVALID_PARAM 正在路径计算
 \retval	GD_ERR_FAILED	操作失败
 \remarks
 \since 6.0
 \see
 **********************************************************************/
+ (GSTATUS)UpdateCloudAvoidInfo:(NSString *)szFullPathFileName;

/**********************************************************************
 \brief 增加避让TMC事件信息
 \details 该函数用于增加避让TMC事件信息
 \param[in]  pEventInfo        要避让的TMC事件信息
 \retval	GD_ERR_OK	成功
 \retval	GD_ERR_FAILED	失败
 \retval	GD_ERR_INVALID_PARAM	参数无效
 \retval	GD_ERR_NOT_SUPPORT	不支持该功能
 \remarks
 - 返回GD_ERR_NOT_SUPPORT 是无网络造成的
 \since 6.1
 \see
 **********************************************************************/
+ (GSTATUS)AddAvoidEventInfo:(GEVENTINFO *)pstEventInfo;

/**
 **********************************************************************
 \brief     同步6.x本地和云端避让文件
 \details   同步6.x本地和云端避让文件
 \param[in] szFullPathFileName 云端避让文件全路径
 \retval    GD_ERR_OK        成功
 \retval    GD_ERR_FAILED    失败
 \remarks
 1.szFullPathFileName:GNULL不升级云端避让文件
 2.szFullPathFileName:具体路径，升级云端避让文件
 2.本地避让文件也在这个接口进行默认同步。
 \since 7.0
 \see
 **********************************************************************/
+ (GSTATUS)UpgradeAvoidFile:(NSString *)szFullPathFileName;

/**
 **********************************************************************
 \brief 添加主要道路避让
 \details 该函数用于添加主要道路避让。
 \param[in] hGuideRoute 引导句柄
 \param[in] eOption 避让
 \param[in] nNodeNo 节点id
 \retval	GD_ERR_OK           成功
 \retval GD_ERR_NO_ROUTE     没有引导路径
 \remarks
 \since 6.0
 \see
 **********************************************************************/
+ (GSTATUS)AddAvoidMainRoad:(GHGUIDEROUTE)hGuideRoute eOption:(GDETOUROPTION)eOption nNodeNo:(Gint32)nNodeNo;

/**
 **********************************************************************
 \brief     用于获取本地避让道路的所在城市及数据版本
 \details   用于获取本地避让道路的所在城市及数据版本
 \param[in]  szFileName      文件路径
 \param[out] ppCityInfos     城市信息
 \param[out] pnNumberOfCity  个数
 \retval    GD_ERR_OK        成功
 \retval    GD_ERR_FAILED    失败
 \remarks
 -1.避让文件目录需要传绝对路径
 \since 7.1
 \see
 **********************************************************************/
+ (GSTATUS)GetDetourRoadCityInfo:(Gchar *)szFileName ppCityInfos:(GDETOURROADCITYINFO **)ppCityInfos pnNumberOfCity:(Gint32 *)pnNumberOfCity;
#pragma mark -
#pragma mark 以下接口包含逻辑

#pragma mark 避让道路(参数为索引值)
/**********************************************************************
 * 函数名称: MW_DetourRoadWithID
 * 功能描述: 避让道路
 * 参    数:[IN] index:避让道路索引值
 * 返 回 值: 成功返回YES, 失败返回NO
 * 其它说明:
 **********************************************************************/
+ (GSTATUS)DetourRoadWithID:(NSInteger)index;
/**********************************************************************
 * 函数名称: HaveDetour
 * 功能描述: 判断是否有规避道路
 * 参    数:
 * 返 回 值: YES 有, NO 无
 * 其它说明:
 **********************************************************************/
+ (BOOL)HaveDetour;
/**********************************************************************
 * 函数名称: MW_DetourRoadIdFrom
 * 功能描述: 避让指定范围内的道路id
 * 参    数:
 * 返 回 值: 成功返回YES, 失败返回NO
 * 其它说明:
 **********************************************************************/
- (BOOL)DetourRoadIdFrom:(NSInteger)nStart to:(NSInteger)nEnd;

/**
 **********************************************************************
 \brief 避让后删除未选中路径句柄
 *****************************/
+ (void)deleteUnselectHandlerAfterDetour;
@end

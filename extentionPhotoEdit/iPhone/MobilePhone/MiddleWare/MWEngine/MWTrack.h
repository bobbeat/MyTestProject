//
//  MWTrack.h
//  AutoNavi
//
//  Created by gaozhimin on 14-5-7.
//
//

#import <Foundation/Foundation.h>

/*!
  @brief 行车轨迹模块
  */

@interface MWTrack : NSObject

/**
 **********************************************************************
 \brief 获取轨迹列表信息
 \details 该函数用于获取轨迹列表信息
 \param[out]	ppTrackList 用于返回系统轨迹列表
 \retval GD_ERR_OK 操作成功
 \retval GD_ERR_NO_DATA 无相关数据
 **********************************************************************/
+(GSTATUS)GetTrackList:(GTRACKINFOLIST **)ppTrackList;

/**
 **********************************************************************
 \brief 删除一定个数轨迹
 \details 该函数用于删除一定个数的轨迹信息
 \param[in]	pIndex 轨迹索引数组
 \param[in]	count 索引个数
 只要成功删除一条，该接口均返回GD_ERR_OK。
 **********************************************************************/
+(GSTATUS)DelTrack:(Gint32 *)pIndex count:(Gint32)count;

/**
 **********************************************************************
 \brief 清空轨迹文件
 \details 该函数用于清空轨迹文件
 \retval GD_ERR_OK 操作成功
 \retval GD_ERR_FAILED 操作失败
 \retval GD_ERR_NO_DATA 无相关数据
 **********************************************************************/
+(GSTATUS)ClearTrack;

/**
 **********************************************************************
 \brief 编辑轨迹文件
 \details 该函数用于清空轨迹文件
 \param[in]	pTrackInfo 标识编辑后的轨迹信息
 \retval GD_ERR_OK 操作成功
 \retval GD_ERR_FAILED 操作失败
 \retval GD_ERR_INVALID_PARAM 参数无效
 \remarks
 1、	对于轨迹信息的编辑，nIndex字段必须不能编辑，该值只用作内部处理。
 2、	名称字段无需带路径和扩展名。
 \since 7.0
 \see
 **********************************************************************/
+(GSTATUS)EditTrack:(GTRACKINFO *)pTrackInfo;

/**
 **********************************************************************
 \brief 加载指定轨迹
 \details 该函数用于加载指定轨迹
 \param[in]	szFileName 轨迹文件名
 \retval GD_ERR_OK 操作成功
 \retval GD_ERR_FAILED 操作失败
 \retval GD_ERR_INVALID_PARAM 参数无效
 \remarks
 \since 7.0
 \see
 **********************************************************************/
+(GSTATUS)LoadTrack:(Gchar *)szFileName;

/**
 **********************************************************************
 \brief 卸载指定的轨迹
 \details 该函数用于卸载指定的轨迹
 \param[in]	szFileName 轨迹文件名
 \retval GD_ERR_OK 操作成功
 \retval GD_ERR_FAILED 操作失败
 \retval GD_ERR_INVALID_PARAM 参数无效
 \remarks
 \since 7.0
 \see
 **********************************************************************/
+(GSTATUS)UnloadTrack:(Gchar *)szFileName;

/**
 **********************************************************************
 \brief 开始回放指定轨迹
 \details 该函数用于开始回放指定轨迹
 \param[in]	szFileName 轨迹文件名
 \retval GD_ERR_OK 操作成功
 \retval GD_ERR_FAILED 操作失败
 \retval GD_ERR_INVALID_PARAM 参数无效
 \remarks
 \since 7.0
 \see
 **********************************************************************/
+(GSTATUS)StartTrackReplay:(Gchar *)szFileName;

/**
 **********************************************************************
 \brief 暂停轨迹回放
 \details 该函数用于暂停轨迹回放
 \retval GD_ERR_OK 操作成功
 \retval GD_ERR_NOT_START 没有调用前序接口
 \remarks
 \since 7.0
 \see
 **********************************************************************/
+(GSTATUS)PauseTrackReplay;

/**
 **********************************************************************
 \brief 继续轨迹回放
 \details 该函数用于继续轨迹回放
 \retval GD_ERR_OK 操作成功
 \retval GD_ERR_NOT_START 没有调用前序接口
 \remarks
 \since 7.0
 \see 
 **********************************************************************/	
+(GSTATUS)ContinueTrackReplay;

/**
 **********************************************************************
 \brief 停止轨迹回放
 \details 该函数用于停止轨迹回放
 \retval GD_ERR_OK 操作成功
 \retval GD_ERR_FAILED 操作失败
 \retval GD_ERR_NOT_START 没有调用前序接口
 \remarks
 \since 7.0
 \see 
 **********************************************************************/	
+(GSTATUS)StopTrackReplay;

/**
 **********************************************************************
 \brief 判断指定的轨迹文件是否已加载
 \details 该函数用于判断指定的轨迹文件是否已加载
 \param[in]	szFileName 轨迹文件名
 \param[in]	bLoaded Gtrue-已加载  Gfalse-未加载
 \retval	GD_ERR_OK 成功
 \retval	异常返回 GSTATUS 对应出错码
 \remarks
 **********************************************************************/
+ (GSTATUS)TrackIsLoaded:(Gchar *)szFileName bLoad:(Gbool *)bLoaded;

/**
 **********************************************************************
 \brief 设置轨迹线信息
 \details 该函数用于设置轨迹线信息
 \param[in]	pTrackLineInfo 轨迹线信息对象
 \param[in]	nNum 轨迹线信息对象个数
 \param[in]	stRect 最小矩形框
 \retval GD_ERR_OK 操作成功
 \retval GD_ERR_FAILED 操作失败
 \retval GD_ERR_NOT_START 没有调用前序接口
 \remarks
 \since 7.0
 \see
 **********************************************************************/
+ (GSTATUS)SetTrackLineInfo:(GTRACKLINEINFO *)pTrackLineInfo nNUm:(Gint32)nNum rect:(GRECT)stRect;

/**
 **********************************************************************
 \brief     升级轨迹文件
 \details   升级轨迹文件
 \param[in] szFileName 轨迹文件名称
 \retval    GD_OK 成功
 \retval    GD_FAILED 失败
 \remarks
 -接口一次只支持升级一个轨迹文件，如果有多个轨迹文件需要HMI调用多次
 \since 7.0
 \see
 **********************************************************************/
+ (GSTATUS)UpgradeTrackFile:(Gchar*) szFileName;

#pragma mark - 
#pragma mark 以下接口包含逻辑

/**********************************************************************
 * 函数名称: GetTrackList
 * 功能描述: 获取轨迹列表
 * 参    数:
 * 返 回 值: 轨迹列表
 * 其它说明:
 **********************************************************************/
+ (NSArray *)GetTrackList;

/**********************************************************************
 * 函数名称: TrackOperationWithID
 * 功能描述: 轨迹操作（设置，删除，清空，轨迹回放，加载轨迹，编辑轨迹，停止轨迹回放，卸载轨迹，判断是否加载）
 * 参    数:[IN]ID:操作类型 index:轨迹索引
 * 返 回 值: 成功返回YES,失败返回NO
 * 其它说明:
 **********************************************************************/
+ (id)TrackOperationWithID:(NSInteger)ID Index:(NSInteger)index;
@end

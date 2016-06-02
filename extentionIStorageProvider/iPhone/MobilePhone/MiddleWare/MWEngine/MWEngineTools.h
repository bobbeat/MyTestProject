//
//  MWEngineTools.h
//  AutoNavi
//
//  Created by gaozhimin on 14-5-7.
//
//

#import <Foundation/Foundation.h>

/*!
  @brief 引擎工具（包含 获取和比较引擎及地图版本，sp编码、经纬度、屏幕坐标转换，两点距离计算） 模块
  */

@interface MWEngineTools : NSObject

/**
 **********************************************************************
 \brief 获取引擎内核版本
 \details 该函数用于获取引擎内核版本
 \retval	成功引擎内核版本字符串，失败返回@""
 **********************************************************************/
+ (NSString *)GetEngineVersion;

/**
 **********************************************************************
 \brief 获取引擎内核版本 没有带V
 \details 该函数用于获取引擎内核版本
 \retval	成功引擎内核版本字符串，失败返回@""
 **********************************************************************/
+ (NSString *)GetEngineVersionNoV;

/**
 **********************************************************************
 \brief 获取地图数据版本
 \details 该函数用于获取地图数据版本
 \retval	成功地图数据版本字符串，失败返回@""
 **********************************************************************/
+ (NSString *)GetMapVersion;

/**
 **********************************************************************
 \brief 获取地图数据版本 没有带V
 \details 该函数用于获取地图数据版本
 \retval	成功地图数据版本字符串，失败返回@""
 **********************************************************************/
+ (NSString *)GetMapVersionNoV;

/**
 **********************************************************************
 \brief 获取城市数据版本
 \details 获取城市数据版本
 \retval	成功地图数据版本字符串，失败返回@""
 **********************************************************************/
+ (NSString *)GetMapCityVersion:(Gint32)admincode;
/**
 **********************************************************************
 \brief 获取城市数据版本
 \details 获取城市数据版本
 \retval	成功地图数据版本字符串，失败返回@""
 **********************************************************************/
+ (NSString *)GetMapCityVersionNoV:(Gint32)admincode;

/**
**********************************************************************
 \brief 比较地图数据版本
 \details 该函数用于比较地图数据版本
 \param[in] pMap1Version 地图版本信息
 \param[in] pMap2Version 地图版本信息
 \param[out] pResult 比较结果
 \retval	GD_ERR_OK	成功
 \retval	GD_ERR_INVALID_PARAM	参数无效
**********************************************************************/
+ (GSTATUS)MapMapVerCompare:(NSString *)pMap1Version map2:(NSString *)pMap2Version result:(GVERCHECKRESULT*)pResult;

/**
 **********************************************************************
 \brief 经纬坐标转SP编码
 \details 该函数用于将经纬度坐标转换为SP编码
 \param[in] pCoord 经纬度坐标
 \retval	成功返回SP编码字符串 失败返回@""
 **********************************************************************/
+ (NSString *)GeoCoordToSP: (GCOORD *)pCoord;

/**
 **********************************************************************
 \brief SP编码转经纬坐标
 \details 该函数用于将SP编码转换为经纬度坐标
 \param[in] szSP SP编码
 \retval	pCoord 经纬度坐标 失败返回（0，0）
 **********************************************************************/
+ (GCOORD)SPToGeoCoord: (NSString *)szSP;

/**
 **********************************************************************
 \brief 当前视图类型的屏幕坐标转经纬坐标
 \details 该函数用于当前视图类型的屏幕坐标转经纬坐标
 \param[in] pScrCoord 屏幕坐标
 \retval	pGeoCoord 成功经纬度坐标 失败返回（0,0）
 **********************************************************************/
+ (GCOORD)ScrToGeo:(GFCOORD)pScrCoord;

/**
 **********************************************************************
 \brief 当前视图类型的经纬坐标转屏幕坐标
 \details 该函数用于当前视图类型的经纬坐标转屏幕坐标
 \param[in] pScrCoord 经纬坐标
 \retval	pGeoCoord 成功屏幕坐标 失败返回（-1,-1）
 **********************************************************************/
+ (GFCOORD)GeoToScr:(GCOORD)pGeoCoord;

/**
 **********************************************************************
 \brief 将WGS地理坐标转换为高德地理坐标
 \details 该函数用于将WGS地理坐标转换为高德地理坐标
 \param[in] pwgsCoord WGS地理坐标
 \retval	pgdCoord 成功高德地理坐标 失败返回（0，0）
 **********************************************************************/
+ (GCOORD)WGSToGDCoord:(GCOORD)pwgsCoord;

/**
 **********************************************************************
 \brief 计算两点间的距离
 \details 该函数用于计算经纬度坐标系中两点间的距离
 \param[in] pGeoCoordFrom 起点经纬度坐标
 \param[in] pGeoCoordTo 终点经纬度坐标
 \retval	pDistance 距离（单位：米） 失败返回 -1
 \see
 **********************************************************************/
+ (Gint32)CalcDistanceFrom:(GCOORD)geoFrom To:(GCOORD)geoTo;

/**
 **********************************************************************
 \brief 计算车位地图中心点间的距离
 \details 计算车位地图中心点间的距离
 \retval	pDistance 距离（单位：米） 失败返回 -1
 \see
 **********************************************************************/
+ (Gint32)CalculateDistance;
/**
 **********************************************************************
 \brief     获取审图号
 \details   计算车位地图中心点间的距离
 \retval	NSString 审图号 失败返回  nil
 \see
 **********************************************************************/
+ (NSString *)GetReadDataCheckNumber;

/**
 **********************************************************************
 \brief 准备开始更新城市数据
 \details 该函数用于通知所有的模块当前程序要开始更新城市数据
 \param[in] pstAdcode 要更新数据的城市编码
 \param[in] eDbType 要更新数据的数据类型
 \retval	GD_ERR_OK	成功
 \retval	GD_ERR_FAILED	失败
 \since 7.1
 \see
 **********************************************************************/
+ (GSTATUS)PrepareUpdateCityDB:(GADMINCODE*)pstAdcode type:(enumDBTYPE)eDbType;

/**
 **********************************************************************
 \brief 完成更新城市数据
 \details 该函数用于通知所有的模块当前程序更新城市数据完成
 \param[in] pstAdcode 更新数据的城市编码
 \param[in] eDbType 更新数据的数据类型
 \retval	GD_ERR_OK	成功
 \retval	GD_ERR_FAILED	失败
 \since 7.1
 \see
 **********************************************************************/
+ (GSTATUS)UpdateCityDBFinished:(GADMINCODE*) pstAdcode type:(enumDBTYPE)eDbType;

/**
 **********************************************************************
 \brief 删除城市数据
 \details 该函数用于删除指定城市数据
 \param[in] pstAdcode 更新数据的城市编码
 \param[in] eDbType 更新数据的数据类型
 \retval	GD_ERR_OK	成功
 \retval	GD_ERR_FAILED	失败
 \since 7.1
 \see
 **********************************************************************/
+ (GSTATUS)DeleteCityDB:(GADMINCODE*)pstAdcode type:(enumDBTYPE)eDbType;

/**
 **********************************************************************
 \brief 更新数据之前先判断模块是否处于繁忙
 \details 该函数用于更新数据之前先判断模块是否处于繁忙
 \param[out] bBusy 处于繁忙状态 不能进行数据更新
 \retval	GD_ERR_OK	成功
 \retval	GD_ERR_FAILED	失败
 \since 7.1
 \see
 **********************************************************************/
+ (GSTATUS)IsAllModulesBusy:(Gbool*)bBusy;

/**
 **********************************************************************
 \brief 基础资源数据包完整性检测
 \details 该函数用于基础资源数据包完整性检测
 \param[in/out]	pbOK 是否完整
 \retval	GD_ERR_OK 成功
 \retval	GD_ERR_NO_DATA 文件不存在
 \retval	GD_ERR_INVALID_PARAM 参数错误
 \remarks
 \since 7.0
 \see
 **********************************************************************/
+ (GSTATUS)CheckResource:(Gbool *)pbOK;

/**
 **********************************************************************
 \brief 检查指定行政区域的数据完整性
 \details 该函数用于检查指定行政区域的数据完整性
 \param[in]	pstAdCode 指定的行政区编码
 \param[in/out]	pbOK 是否完整
 \retval	GD_ERR_OK 成功
 \retval	GD_ERR_NO_DATA 文件不存在
 \retval	GD_ERR_INVALID_PARAM 参数错误
 \remarks
 pstAdcode->euRegionCode == 0：表示获取全局版本，必须执行一次
 pstAdcode->euRegionCode > 0 && pstAdcode->nAdCode == 0：表示获取指定国家的基础版本
 pstAdcode->euRegionCode > 0 && pstAdcode->nAdCode > 0：表示获取指定行政区域(城市)的版本
 \since 7.0
 \see
 **********************************************************************/
+ (GSTATUS)CheckAdareaData:(GADMINCODE *)pstAdCode bOk:(Gbool *)pbOK;

@end

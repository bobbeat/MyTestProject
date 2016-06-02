//
//  MWAdminCode.h
//  AutoNavi
//
//  Created by gaozhimin on 14-6-9.
//
//

#import <Foundation/Foundation.h>


/*!
 @brief  行政区域列表结构体
 * 用于存储行政区域
 */
@interface MWAreaList : NSObject

/*!
 @brief 类别个数
 */
@property (nonatomic,assign) int lNumberOfAdarea;

/*!
 @brief 行政区域 存储 MWArea 对象
 */
@property (nonatomic,retain) NSMutableArray *pAdareaArray;

@end

/*!
 @brief  行政区域结构体
 * 用于存储行政区域编码、名称、简拼及其子行政区信息
 */
@interface MWArea : NSObject

/*!
 @brief 行政区域编码，参见行政区域编码表
 */
@property (nonatomic,assign) int lAdminCode;
/*!
 @brief 下级行政区域个数
 */
@property (nonatomic,assign) int lNumberOfSubAdarea;

/*!
 @brief 行政区域名称首拼
 */
@property (nonatomic,copy) NSString* szAdminSpell;

/*!
 @brief 行政区域名称
 */
@property (nonatomic,copy) NSString* szAdminName;

/*!
 @brief 下级行政区域信息 存储 MWPoiCategory 对象
 */
@property (nonatomic,retain) NSMutableArray *pSubAdareaArray;

/*!
 @brief 自身对象所在的数组
 */
@property (nonatomic,assign) NSArray *CurrentArray;

/*!
 @brief 自身对象的上一级数组 
 */
@property (nonatomic,assign) NSArray *superArray;
/*!
 @brief  递归将GADAREA转化成MWArea
 @param  area, 将要转化的GADAREA
 @return 转化后的 MWArea。
 */
+(MWArea *)recursiveForArea:(GADAREA)area;

@end

/*!
 @brief  单个行政区域详细信息结构体 用于存储行政区域的省、市、区名称 @see GADAREAINFOEX
 */
@interface MWAreaInfo : NSObject

/*!
 @brief 行政区域编码，参见行政区域编码表
 */
@property (nonatomic,assign) Gint32	lAdminCode;

/*!
 @brief 行政编码对应的省名称
 */
@property (nonatomic,copy) NSString*	szProvName;

/*!
 @brief 行政编码对应的市名称
 */
@property (nonatomic,copy) NSString*	szCityName;

/*!
 @brief 行政编码对应的区名称
 */
@property (nonatomic,copy) NSString*	szTownName;

/*!
 @brief 电话区号
 */
@property (nonatomic,assign) Gint32	nTel;

/*!
 @brief 行政中心经纬度坐标
 */
@property (nonatomic,assign) GCOORD	coorCenter;

/*!
 @brief 当前是否存在数据
 */
@property (nonatomic,assign) Gbool	bHasData;

/*!
 @brief 数据包大小
 */
@property (nonatomic,assign) Guint32	nNumberOfBytes;

@end


/*!
  @brief 行政区域（包含 获取行政区域列表，设置当前行政区域，获取行政区域信息等） 模块
  */

@interface MWAdminCode : NSObject

/**
 **********************************************************************
 \brief 获取行政区域列表
 \details 实现获取指定行政区域编码的行政区域及其下级行政区域信息列表。
 \param[in]	euAdareaDataFlag	行政区域数据存在标识
 \param[in]	nAdminCode			行政编码
 \retval	ppstAdareaList		行政区域信息列表
 \remarks
 如果参数lAdminCode等于0，则表示获取当前地图数据所覆盖的行政区域信息，
 包括各行政区域的下级行政区域信息。
 **********************************************************************/
+ (MWAreaList *)GetAdareaListFlag:(GADAREADATAFLAG)euAdareaDataFlag admincode:(Gint32)lAdminCode;

/**
 **********************************************************************
 \brief 设置当前检索行政区域
 \details 设置当前检索行政区域，完成相关检索数据初始化。
 \param[out]	nAdminCode		行政编码
 \retval	GD_ERR_OK 成功
 \remarks
 \since 6.0
 \see GDBL_GetCurAdarea
 **********************************************************************/
+ (GSTATUS)SetCurAdarea:(Gint32)lAdminCode;

/**
 **********************************************************************
 \brief 获取当前行政区域详细信息结构体
 \details 获取当前行政区域详细信息结构体
 \retval	MWAreaInfo类型 行政区域详细信息结构体
 **********************************************************************/
+ (MWAreaInfo *)GetCurAdarea;

/**
 **********************************************************************
 \brief 获取行政区域信息
 \details 获取指定行政区域编码对应的省、市、区名称等信息。
 \param[in]	nAdminCode		行政编码
 \retval	MWAreaInfo类型 行政区域详细信息结构体
 \remarks
 1、	如果lAdminCode指定到省一级，则市、区名称为空；如果lAdminCode指定到市一
 级，则区名称为空。如果lAdminCode等于0，则省、市、区名称为空，具体区域不确定。
 2、	数据包大小，只针对分市版数据。
 \since 6.0
 \see
 **********************************************************************/
+ (MWAreaInfo *)GetCurAdareaWith:(Gint32)lAdminCode;

/**
 **********************************************************************
 \brief 获取地图中心点行政区域编码
 \details 获取地图中心点行政区域编码
 \retval	pnAdminCode 行政编码 失败返回0
 \remarks
 如果经纬度坐标属于中国范围，但未被划归到具体的行政区域，则返回0。
 \since 6.0
 \see
 **********************************************************************/
+ (Gint32)GetCurAdminCode;

/**
 **********************************************************************
 \brief 获取指定经纬坐标所属行政区域编码
 \details 获取指定经纬坐标所属行政区域编码
 \param[in] pCoord 经纬度坐标
 \retval	 行政编码 失败返回0
 \remarks
 如果经纬度坐标属于中国范围，但未被划归到具体的行政区域，则返回0。
 \since 6.0
 \see
 **********************************************************************/
+ (Gint32)GetAdminCode:(GCOORD)pCoord;

/**
 **********************************************************************
 \brief 获取指定经纬坐标所属行政区域编码
 \details 获取指定经纬坐标所属行政区域编码
 \param[in] pCoord 经纬度坐标
 \retval	NSArray 行政编码数组
 **********************************************************************/
+ (NSArray *)GetAdminCodeArray:(GCOORD)pCoord;

/**
 **********************************************************************
 \brief 获取指定数据、区域数据状态
 \details 该函数用于获取指定数据、区域数据的状态
 \param[in] pstAdCode 指定的行政区域编码
 \param[out] bHasData Gtrue 有数据, Gfalse 无数据
 \retval	GD_ERR_OK	成功
 \retval	GD_ERR_INVALID_PARAM	参数无效
 \remark
 - pstAdCode->euRegionCode == 0：表示获取全局版本，
 - pstAdCode->euRegionCode > 0 && pstAdCode->nAdCode == 0：表示获取指定国家的基础版本
 - pstAdCode->euRegionCode > 0 && pstAdCode->nAdCode > 0：表示获取指定行政区域(城市)的版本
 **********************************************************************/
+ (GSTATUS)GetAdareaDataStatus:(GADMINCODE *)pstAdCode bHasData:(Gbool *)bHasData;

/**
 **********************************************************************
 \brief 获取行政区域列表
 \details 实现获取指定行政区域编码的行政区域及其下级行政区域信息列表(实际存在数据)
 \param[in]	pstAdCode			行政编码
 \param[out]	ppstAdareaList		行政区域信息列表
 \retval	GD_ERR_OK 成功
 \retval	GD_ERR_INVALID_PARAM	参数无效
 \retval	GD_ERR_NO_MEMORY	内存不足
 \retval	GD_ERR_NO_DATA	无相关数据
 \remarks
 如果参数lAdminCode等于0，则表示获取当前地图数据所覆盖的行政区域信息，
 包括各行政区域的下级行政区域信息。
 \since 6.0
 \see
 **********************************************************************/
+ (GSTATUS)GetAdareaWithDataList:(GADMINCODE *)pstAdCode list:(GADAREALIST **)ppstAdareaList;


/*
 **********************************************************************
 \brief 获取数据目录列表
 \details 获取城市数据目录列表
 \param[in] pstAdCode 指定的行政区域编码
 \param[in] nMaxCnt 最大目录缓存个数
 \param[out] pstDirList 目录缓存
 \retval	GD_ERR_OK 成功
 \retval	GD_ERR_FAILED 操作失败
 \retval	GD_ERR_INVALID_PARAM 参数无效
 \remark
 - pstAdCode->euRegionCode == 0：表示获取全局版本，
 - pstAdCode->euRegionCode > 0 && pstAdCode->nAdCode == 0：表示获取指定国家的基础版本
 - pstAdCode->euRegionCode > 0 && pstAdCode->nAdCode > 0：表示获取指定行政区域(城市)的版本
 \since
 ********************************************************************* */
+ (GSTATUS)GetAdareaDirList:(GADMINCODE *)pstAdCode nMaxCnt:(Gint32)nMaxCnt list:(GDATADIRINFO*)pstDirList;

/**
 **********************************************************************
 \brief 判断指定行政区域是否有数据
 \details 判断指定行政区域是否有数据
 \param[in] 	admincode 行政编码，为0时表示获取地图中心点的区域是否有数据
 \remarks 存在数据返回YES 无数据为NO
 **********************************************************************/
+(BOOL)checkIsExistDataWithAdmincode:(Gint32)admincode;

/**
 **********************************************************************
 \brief 判断指定经纬度是否有数据
 \details 判断指定经纬度是否有数据
 \param[in] 	coord 经纬度
 \remarks 存在数据返回YES 无数据为NO
 **********************************************************************/
+(BOOL)checkIsExistDataWithCoord:(GCOORD)coord;

/**
 **********************************************************************
 \brief 获取指定经纬度的城市级行政编码 (下载地图选项)
 \details 获取指定经纬坐标所属行政区域编码
 \param[in] lon : 经度   lat : 纬度
 \retval	 行政编码 失败返回0
 \remarks
 如果经纬度坐标属于中国范围，但未被划归到具体的行政区域，则返回0。
 \since 6.0
 \see
 **********************************************************************/
+(NSString *)GetCityAdminCode:(long)lon Lat:(long)lat;

/**
 **********************************************************************
 \brief 获取城市行政编码（对直辖市的行政编码作处理）
 **********************************************************************/
+ (int)GetCityAdminCodeWithAdminCode:(int)nAdminCode;


/**
 **********************************************************************
 \brief 拨打电话(根据经纬度获取区号)
 **********************************************************************/
+ (void)telephoneCall:(NSString *)telephone Lon:(int)lon Lat:(int)lat;

/**
 **********************************************************************
 \brief 获取当前区域名称
 **********************************************************************/
+ (NSString *)GetAdareaName;

/**
 **********************************************************************
 \brief 获取指定行政编码的城市名
 **********************************************************************/
+ (NSString *)GetCityNameWithAdminCode:(int)nAdminCode;

/**
 **********************************************************************
 \brief 检测传入行政编码是否有TMC数据
 **********************************************************************/
+ (BOOL)isTmcCityWith:(int)nAdminCode;
@end

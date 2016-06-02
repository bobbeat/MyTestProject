/* ***************************************************
 * Copyright(c) Xiamen AutoNavi Company. Ltd.
 * All Rights Reserved.
 *
 * File: GDBL_Interface.h
 * Purpose: GDBL对外接口
 *
 * Author: zhicheng.chen
 *
 *
 * Version: 7.0
 * Date: 22-May-2013 15:08:06
 * Update: Create
 *
 *************************************************** */
#ifndef GDBL_INTERFACE_H__
#define GDBL_INTERFACE_H__

#ifdef __cplusplus
extern "C" {
#endif
    /*********************************************************************/
    
#include "GDBL_typedef.h"
#include "GDBL_InterfaceEx.h"
    
#if (defined (WIN32) || defined (_WIN32) || defined(PLATFORM_WIN8) || defined(PLATFORM_WINPHONE))
#ifdef  GNAVISRV_EXPORTS
#define GDBL_API_CALL		__declspec(dllexport)
#else
#define GDBL_API_CALL		__declspec(dllimport)
#endif
#elif defined(PLATFORM_TIZEN) || defined(PLATFORM_ANDROID)
#ifdef  GNAVISRV_EXPORTS
#define GDBL_API_CALL			__attribute__ ((visibility ("default")))
#else
#define GDBL_API_CALL			/* extern */
#endif
#else
#define GDBL_API_CALL			/* extern */
#endif
    
#define MAX_PATH						260
    /***********************************************************************/
    /* 消息ID定义                                                           */
    /************************************************************************/
#define WM_USER                         0x0400	/**< 用户自定义WM消息值 */
    
#define WM_GETMAPVIEW		WM_USER + 1			/**< 更新地图画面 */
    /*
     * WM_ROUTE_CALC_DONE:
     * wParam: 0 - 单路径计算
     *		  1 - 多路径计算
     *		  2 - 偏航重算
     *         3 - 本网融合
     *         6 - tmc参与路径重算
     * lParam: GSTATUS错误码(GD_ERR_OK, GD_ERR_OP_CANCELED, ...)
     */
#define WM_ROUTE_CALCULATE	WM_USER + 2			/**< 路径消息ID */
    
    /*
     * WM_UPDATEFAVORITE:
     * lParam: GSTATUS错误码(GD_ERR_OK, GD_ERR_OP_CANCELED, ...)
     */
#define	WM_UPDATEFAVORITE	WM_USER + 3			/**< 更新收藏夹 */
    
    
    /*
     * WM_GETPOIDATA:
     * wParam: 0 - 搜索POI
     *		  1 - 最近的POI点
     *		  2 - 网络检索候选城市列表
     *		  3 - 网络POI检索结果
     *		  4 - 检索过程中的中间结果
     * lParam: GSTATUS错误码(GD_ERR_OK, GD_ERR_OP_CANCELED, ...)
     */
#define WM_GETPOIDATA		WM_USER + 4			/**< 更新POI */
    
    /*
     * WM_TRACKREPLAY:
     * wParam:
     * lParam: GSTATUS错误码(GD_ERR_OK, GD_ERR_OP_CANCELED, ...)
     */
#define WM_TRACKREPLAY		WM_USER + 5			/**< 轨迹回放 */
    
    /*
     * WM_PARALLEL_NOTIFY:
     * wParam: 1 - 平行道路出现通知
     0 - 平行道路通知解除
     * lParam: GSTATUS错误码(GD_ERR_OK, GD_ERR_OP_CANCELED, ...)
     */
#define WM_PARALLEL_NOTIFY		WM_USER + 6			/**< 平行道路 */
    
    /*
     * WM_BUS_NOTIFY:
     * wParam: 0 - 公交换乘通知
     1 - 公交路线查询通知
     * lParam: GSTATUS错误码(GD_ERR_OK, GD_ERR_OP_CANCELED, ...)
     */
#define WM_BUS_NOTIFY		WM_USER + 7			/**< 公交 */
    
    /*
     * WM_GPSREPLAY:
     * wParam:
     * lParam: GSTATUS错误码(GD_ERR_OK, GD_ERR_OP_CANCELED, ...)
     */
#define WM_GPSREPLAY		WM_USER + 8			/**< GPS信号回放 */
    
    /*
     * WM_UGCSYNC:
     * wParam:
     * lParam: GSTATUS错误码(GD_ERR_OK, GD_ERR_OP_CANCELED, GD_ERR_OP_END...)
     */
#define WM_UGCSYNC		WM_USER + 9			/**< UGC同步回馈 */
    
    /*
     * WM_ROUTE_CALCULATE2:
     * wParam: 返回的引导路径(GHGUIDEROUTE结构)
     * lParam: GSTATUS错误码(GD_ERR_OK, GD_ERR_OP_CANCELED, ...)
     */
#define WM_ROUTE_CALCULATE2	WM_USER + 10		/**< 返回引导路径的消息ID */
    
    /*
     * WM_GETMCCPOIDATA
     * wParam:
     * lParam: GSTATUS错误码(GD_ERR_OK, GD_ERR_OP_CANCELED, ...)
     */
#define WM_GETMCCPOIDATA	WM_USER + 11		/**< 更新MCC数据 */
    
    /*
     * WM_REACH_DESTINATION_NOTIFY
     * wParam:
     * lParam: GSTATUS错误码(GD_ERR_OK, GD_ERR_OP_CANCELED, ...)
     */
#define WM_REACH_DESTINATION_NOTIFY	WM_USER + 12		/**< 模拟导航、导航到达目的地的消息 */
    
    
    /*
     * WM_TMCUPDATE:
     * wParam:GNET_TASK:	GDNET_TMC_TASK_LOGON	实时交通登入
     *					GDNET_TMC_TASK_REFLUSH	实时交通刷新
     * lParam: GSTATUS错误码(GD_ERR_OK, GD_ERR_OP_CANCELED, ...)
     * 由HMI层接受消息后对TMC进行更新
     */
#define WM_TMCUPDATE	WM_USER + 13			/* 更新TMC */
    
    /*
     * WM_NETMAP_TASK:
     * wParam:
     * lParam: GSTATUS错误码(GD_ERR_OK, GD_ERR_OP_CANCELED, ...)
     * 由HMI层接受消息后对网络地图下载进行更新
     */
#define WM_NETMAP_TASK	WM_USER + 14			/* 更新地图 */
    
    /*
     * WM_AUTOMODE_CHANGE:
     * wParam:
     * lParam:
     * 模式切换为自动时，模式变更通知消息
     */
#define WM_AUTOMODE_CHANGE	WM_USER + 15		/* 模式变更通知消息 */
    
    /*
     * WM_TRAFFICBOARD:
     * wParam:	GNET_TASK:	GDNET_MTR_TASK_USERBOARDLIST	交通情报板列表
     *						GDNET_MTR_TASK_USERBOARDDATA	交通情报板图片
     * lParam:	GNET_STATUS 消息状态
     * 由HMI层接受消息后可进行获取交通情报板列表或交通情报板数据(图片)
     */
#define WM_TRAFFICBOARD	WM_USER + 16			/* 交通情报板消息 */
    
    
    /*
     * WM_WEATHER:
     * 由HMI层接受消息后对获取天气概要信息进行处理
     * wParam: GNET_TASK		网络任务信号
     * lParam: GNET_STATUS	错误码
     */
#define WM_WEATHER		WM_USER + 17			/* 天气信息消息 */
    
    /*
     * WM_TIR:
     * 由HMI层接受消息后对获取事件上报概要信息进行处理
     * wParam: GNET_TASK		网络任务信号
     * lParam: GNET_STATUS	错误码
     */
#define WM_TIR		WM_USER + 18			/* 事件上报信息消息 */
    
    
    
    /** \addtogroup main_api_group
     \{ */
    
    /**
     **********************************************************************
     \brief 启动GDBL服务
     \details 该函数用于启动GDBL服务
     \param[in] Wnd HMI窗口句柄
     \retval	GD_ERR_OK	成功
     \retval	GD_ERR_INVALID_PARAM	参数无效
     \retval	GD_ERR_NO_DATA	无相关数据
     \retval	GD_ERR_INVALID_USER 非法用户
     \remarks
     - 负责启动所有模块
     \since 6.0
     \see GDBL_Cleanup
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_Startup (Guint32 Wnd);
    
    /**
     **********************************************************************
     \brief 卸载GDBL服务
     \details 该函数用于卸载GDBL服务
     \retval	GD_ERR_OK	成功
     \retval	GD_ERR_NO_DATA	无相关数据
     \retval	GD_ERR_FAILED 失败
     \remarks
     - 卸载所有模块服务
     \since 6.0
     \see GDBL_Startup
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_Cleanup (void);
    
    /**
     **********************************************************************
     \brief 设置运行程序的当前路径
     \details 该函数用于设置运行程序的当前路径
     \param[in] pzAppPath 缓冲区
     \param[in] nSize 缓冲区大小
     \retval	程序当前路径
     \remarks
     \since 7.0
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_SetAppPath(Gchar *pzAppPath, Gint32 nSize);
    
    /**
     **********************************************************************
     \brief 创建视图
     \details 该函数用于创建视图
     \retval	GD_ERR_OK	成功
     \retval	GD_ERR_FAILED	失败
     \remarks
     - 在所有的模块启动之后，启动绘图模块GGI，必须在GDBL_Startup之后调用
     \since 6.0
     \see GDBL_DestroyView
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_CreateView(void);
    
    /**
     **********************************************************************
     \brief 销毁视图
     \details 该函数用于销毁视图
     \retval	GD_ERR_OK	成功
     \retval	GD_ERR_FAILED	失败
     \remarks
     - 在所有的模块卸载之前卸载绘图模块GGI，必须在GDBL_Cleanup之前调用
     \since 6.0
     \see GDBL_CreateView
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_DestroyView(void);
    
    /**
     **********************************************************************
     \brief 获取版本信息
     \details 该函数用于获取版本信息
     \param[in] pVerParam 版本信息输入参数
     \param[out] pVersion 版本信息
     \retval	GD_ERR_OK	成功
     \retval	GD_ERR_FAILED	失败
     \retval	GD_ERR_INVALID_PARAM	参数无效
     \retval	GD_ERR_NO_DATA	无相关数据
     \remarks
     对于数据版本的信息，即可以指定数据路径，也可以不指定，当不指定时，
     获取的时初始化所使用的路径。
     \since 7.0
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_GetVersion (
                                           GVERSIONPARAM *pVerParam,
                                           GVERSION *pVersion
                                           );
    
    /**
     **********************************************************************
     \brief 获取当前数据库支持的语言种类
     \details
     \param[in]  eRegionCode国家或地区代码
     \param[out] peLanguageIds语言ID缓冲区
     \param[out] pNumberOfIds实际支持的语言个数
     \retval	GD_ERR_OK	成功
     \retval	GD_ERR_FAILED	失败
     \retval	GD_ERR_INVALID_PARAM	参数无效
     \remarks
     可以通过GDBL_GetCountryAreaCode获取指定点，所在国家或地区代码。
     \since 7.0
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_GetSupportedLanguages(
                                                     enumREGION_CODE eRegionCode,
                                                     GLANGUAGE **ppeLanguageIds,
                                                     Gint32 *pNumberOfIds);
    
    /**
     **********************************************************************
     \brief 引擎地图兼容性比较
     \details 该函数用于比较引擎地图的兼容性
     \param[in] pEngineVersion 引擎版本信息
     \param[in] pMapVersion 地图版本信息
     \param[in] pResult 比较结果
     \param[out] pResult 比较结果
     \retval	GD_ERR_OK	成功
     \retval	GD_ERR_INVALID_PARAM	参数无效
     \since 6.0
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_EngineMapVerCompare (
                                                    GVERSION *pEngineVersion,
                                                    GVERSION *pMapVersion,
                                                    GVERCHECKRESULT *pResult
                                                    );
    
    /**
     **********************************************************************
     \brief 地图版本比较
     \details 该函数用于地图版本之间的比较
     \param[in] pMap1Version 地图版本信息
     \param[in] pMap2Version 地图版本信息
     \param[in] pResult 比较结果
     \param[out] pResult 比较结果
     \retval	GD_ERR_OK	成功
     \retval	GD_ERR_INVALID_PARAM	参数无效
     \since 6.0
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_MapMapVerCompare (
                                                 GVERSION *pMap1Version,
                                                 GVERSION *pMap2Version,
                                                 GVERCHECKRESULT *pResult
                                                 );
    
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
    GDBL_API_CALL GSTATUS GDBL_PrepareUpdateCityDB(GADMINCODE* pstAdcode, enumDBTYPE eDbType);
    
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
    GDBL_API_CALL GSTATUS GDBL_UpdateCityDBFinished(GADMINCODE* pstAdcode, enumDBTYPE eDbType);
    
    /**
     **********************************************************************
     \brief 删除城市数据
     \details 该函数用于删除指定城市数据
     \param[in] pstAdcode 更新数据的城市编码
     \retval	GD_ERR_OK	成功
     \retval	GD_ERR_FAILED	失败
     \since 7.1
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_DeleteCityDB(GADMINCODE* pstAdcode);
    
    /**
     **********************************************************************
     \brief 经纬坐标转SP编码
     \details 该函数用于将经纬度坐标转换为SP编码
     \param[in] pCoord 经纬度坐标
     \param[in] szSP SP编码
     \param[out] szSP SP编码
     \retval	GD_ERR_OK	成功
     \retval	GD_ERR_INVALID_PARAM	参数无效
     \since 6.0
     \see GDBL_SPToGeoCoord
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_GeoCoordToSP (
                                             GCOORD *pCoord,
                                             Gchar* szSP
                                             );
    
    /**
     **********************************************************************
     \brief SP编码转经纬坐标
     \details 该函数用于将SP编码转换为经纬度坐标
     \param[in] szSP SP编码
     \param[in] pCoord 经纬度坐标
     \param[out] pCoord 经纬度坐标
     \retval	GD_ERR_OK	成功
     \retval	GD_ERR_INVALID_PARAM	参数无效
     \since 6.0
     \see GDBL_GeoCoordToSP
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_SPToGeoCoord (
                                             Gchar* szSP,
                                             GCOORD *pCoord
                                             );
    
    /**
     **********************************************************************
     \brief 屏幕坐标与经纬坐标相互转换
     \details 该函数用于屏幕坐标与经纬度坐标之间的转换
     \param[in] hMapView 视图句柄
     \param[in] eCoordConvert 转换标志
     \param[in] pScrCoord 屏幕坐标
     \param[in] pGeoCoord 经纬度坐标
     \param[out] pGeoCoord 经纬度坐标，eCoordConvert 为 GCC_SCR_TO_GEO
     \param[out] pScrCoord 屏幕坐标，eCoordConvert 为 GCC_GEO_TO_SCR
     \retval	GD_ERR_OK	成功
     \retval	GD_ERR_INVALID_PARAM	参数无效
     \since 6.0
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_CoordConvert (
                                             GHMAPVIEW hMapView,
                                             GCOORDCONVERT eCoordConvert,
                                             GFCOORD *pScrCoord,
                                             GCOORD *pGeoCoord
                                             );
    
    /**
     **********************************************************************
     \brief 将WGS地理坐标转换为高德地理坐标
     \details 该函数用于将WGS地理坐标转换为高德地理坐标
     \param[in] pwgsCoord WGS地理坐标
     \param[in] pgdCoord 高德地理坐标
     \param[out] pgdCoord 高德地理坐标
     \retval	GD_ERR_OK	成功
     \retval	GD_ERR_INVALID_PARAM	参数无效
     \since 6.0
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_WGSToGDCoord (
                                             GCOORD *pwgsCoord,
                                             GCOORD *pgdCoord
                                             );
    
    /**
     **********************************************************************
     \brief 计算两点间的距离
     \details 该函数用于计算经纬度坐标系中两点间的距离
     \param[in] pGeoCoordFrom 起点经纬度坐标
     \param[in] pGeoCoordTo 终点经纬度坐标
     \param[in] pDistance 距离（单位：米）
     \param[out] pDistance 距离（单位：米）
     \retval	GD_ERR_OK	成功
     \retval	GD_ERR_INVALID_PARAM	参数无效
     \since 6.0
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_CalcDistance (
                                             GCOORD *pGeoCoordFrom,
                                             GCOORD *pGeoCoordTo,
                                             Gint32 *pDistance
                                             );
    
    /**
     **********************************************************************
     \brief 线裁剪转换函数
     \details 该函数用于线的裁剪转换
     \param[in] pGeoCoord 待裁剪转换的经纬度坐标数组
     \param[in] nNumberOfGeoCoord pGeoCoord坐标个数
     \param[out] ppScrCoord 裁剪转换后的屏幕坐标数组，内存内部负责
     \param[out] ppNumberOfScrCoord 裁剪后每条线的坐标个数，内存内部负责
     \param[out] pCount 裁剪后线条数
     \retval	GD_ERR_OK	成功
     \retval	GD_ERR_INVALID_PARAM	参数无效
     \since 6.0
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_LineClipConvert (
                                                GPOINT *pGeoCoord,
                                                Gint32 nNumberOfGeoCoord,
                                                GFPOINT **ppScrCoord,
                                                Gint32 **ppNumberOfScrCoord,
                                                Gint32 *pCount
                                                );
    
    /**
     **********************************************************************
     \brief 设置日夜模式判断回调接口
     \details 该函数为设置昼夜模式判断回调函数
     \param[in] DayNightModeCallback 回调函数指针
     \retval	GD_ERR_OK	成功
     \retval	GD_ERR_INVALID_PARAM	参数无效
     \remarks
     - 1、该回调函数只在日夜模式为自动时才会被调用，即该接口提供了
     在日夜模式为自动时，判断当前是白天还是黑夜的方法。
     - 2、如果不设置该接口，则系统使用默认的方式进行判断，即根据当
     前系统时间和配置中指定的昼夜切换时间判断。
     - 3、DayNightModeCallback返回Gtrue表示白天，Gfalse表示黑夜。
     \since 6.0
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_SetDayNightModeCallback (
                                                        Gbool (*DayNightModeCallback)(void)
                                                        );
    /**
     **********************************************************************
     \brief 根据经纬度获取国家或地区代码
     \details 该函数用于根据经纬度获取国家或地区代码
     \param[in] nLon经度坐标
     \param[in] nLat纬度坐标
     \param[out] peCountryAreaCode 国家或地区代码
     \retval	GD_ERR_OK	成功
     \retval	GD_ERR_INVALID_PARAM	参数无效
     \since 6.0
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_GetCountryAreaCode (
                                                   Gint32 nLon,
                                                   Gint32 nLat,
                                                   enumREGION_CODE *peCountryAreaCode
                                                   );
    
    /**
     **********************************************************************
     \brief 获取图片资源
     \details 该函数用于获取图片数据资源
     \param[in] pImageParam 图片类型、ID、标识
     \param[out] ppBitmap 图片
     \retval	GD_ERR_OK	成功
     \retval	GD_ERR_INVALID_PARAM	参数无效
     \remarks
     - 1、输入参数中的ID和标识，依赖图片类型。参见如下描述：
     eImageType				nImageID				nFlag
     G_IMAGE_TYPE_TURN      转向图标id               0小图标/1大图标
     G_IMAGE_TYPE_TOUR                               无效
     G_IMAGE_TYPE_2DCAR                              车标索引（0～4）共5张
     G_IMAGE_TYPE_3DCAR                              车标索引（0～4）共5张
     - 2、6.0原有获取图片接口删除，统一使用该接口。
     \since 7.0
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_GetImage (
                                         GIMAGEPARAM *pImageParam,
                                         GBITMAP  **ppBitmap
                                         );
    
    /**
     **********************************************************************
     \brief 获取POI图片大小
     \details 该函数用于获取获取POI图片大小
     \param[out]	ppOutImagePixs 图片信息
     \param[out]	pnNum POI图片组数
     \retval	GD_ERR_FAILED 失败
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_INVALID_PARAM 非法参数
     \remarks
     \since 7.0
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_GetLogoImagePixs(GIMAGEPIX **ppOutImagePixs, Gint32 *pnNum);
    
    /**
     **********************************************************************
     \brief 将当前视图转换为全程概览视图
     \details 该函数用于将当前视图转换为全程概览视图
     \param[in] hView 视图句柄
     \param[in] pstParams 全程概览结构信息
     \param[out] hBackupView 返回备份的视图句柄
     \retval	GD_ERR_OK	成功
     \retval	GD_ERR_INVALID_PARAM	参数有误
     \retval	GD_ERR_FAILED	失败
     \remarks 视图句柄目前只支持主地图
     \since 7.0
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_ViewToOverView(GHMAPVIEW hView, GOVERVIEWPARAMS *pstParams, GHMAPVIEW *hBackupView);
    
    /**
     **********************************************************************
     \brief 将全程概览视图恢复为原有视图
     \details 该函数用于将全程概览视图恢复为原有视图
     \param[in/out] hBackupView 备份的视图句柄
     \param[in] hView 恢复的视图句柄
     \retval	GD_ERR_OK	成功
     \retval	GD_ERR_FAILED	失败
     \remarks 视图句柄目前只支持主地图
     \since 7.0
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_RecoveryView(GHMAPVIEW* hBackupView, GHMAPVIEW hView);
    
    /**
     **********************************************************************
     \brief 设置外部开辟的图片缓存
     \details 该函数用于设置外部开辟的图片缓存
     \param[in]  pstBitmap 外部开辟的图片缓存，其中pdata图像数据内存也由外部开辟
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_FAILED 失败
     \remarks
     \since 7.0
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_SetBitmapBuffer(GBITMAP *pstBitmap);
    
    /* main_api_group end */
    /** \} */
    
    /** \addtogroup map_api_group
     \{ */
    
    /* Map */
    /**
     **********************************************************************
     \brief BL层接口,获取地图视图数据
     \details 该函数用于获取地图视图数据
     \param[out] pMapview 存放地图视图数据
     \retval	GD_ERR_OK	成功
     \retval	GD_ERR_INVALID_PARAM	参数无效
     \retval	GD_ERR_NO_DATA	无相关数据
     \since 6.0
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_GetMapView (
                                           GMAPVIEW *pMapview
                                           );
    
    /**
     **********************************************************************
     \brief GL版本将显存打到内存中
     \details 该函数用于GL版本将显存打到内存中
     \param[in]  pstRect 矩形框
     \retval	GD_ERR_OK 返回成功
     \retval	GD_ERR_INVALID_PARAM 参数错误
     \remarks
     \since 7.0
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_GetPixel(GRECT *pstRect);
    
    /**
     **********************************************************************
     \brief 获取各个视图的移图状态
     \details 该函数用于获取各个视图的移图状态
     \param[in]	hMapView 地图视图句柄
     \param[out]	pMoveMap 是否移图
     \retval	GD_ERR_INVALID_PARAM 参数无效
     \retval	GD_ERR_OK 成功
     \remarks
     \since 7.0
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_GetMoveMapStatus(GHMAPVIEW hMapView, Gbool *pMoveMap);
    
    /**
     **********************************************************************
     \brief BL层接口,回车位
     \details 该函数用于让地图视图回到车位所在视图
     \retval	GD_ERR_OK	成功
     \retval	GD_ERR_FAILED	参数无效
     \since 6.0
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_GoToCCP ( void );
    
    /**
     **********************************************************************
     \brief 按照经纬设置车位
     \details 该函数用于按照经纬设置车位
     \param[in] hMapView 视图句柄
     \param[in] pCarPos	车位坐标
     \param[in] nAngle	车位角度
     \retval	GD_ERR_OK	成功
     \retval	GD_ERR_INVALID_PARAM	参数无效
     \since 6.0
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_AdjustCar (
                                          GHMAPVIEW hMapView,
                                          GCOORD *pCarPos,
                                          Gint32 nAngle
                                          );
    
    /**
     **********************************************************************
     \brief 获取色盘列表
     \details 该函数用于获取色盘列表信息
     \param[in] bDayPalette 是否获取日色盘 (Gtrue 获取日色盘，Gfalse 获取夜色盘)
     \param[out] ppPaletteList 色盘列表
     \retval	GD_ERR_OK	成功
     \retval	GD_ERR_INVALID_PARAM	参数无效
     \since 6.0
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_GetPaletteList (
                                               Gbool bDayPalette,
                                               GPALETTELIST **ppPaletteList
                                               );
    
    /**
     **********************************************************************
     \brief 设置色盘中各元素的颜色值
     \details 该函数用于设置色盘中各元素的颜色值
     \param[in] nColorIndex 色盘颜色索引值
     \param[in] nTypeIndex 色盘颜色类型
     \param[in] pstRGBA    要设置的色盘颜色值
     \param[in] bAll		  所有比例尺同色
     \retval	GD_ERR_OK	成功
     \retval	GD_ERR_INVALID_PARAM	参数无效
     \since 6.0
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_SetRGBA(Gint32 nColorIndex, Gint32 nTypeIndex, GRGBA* pstRGBA, Gbool bAll);
    
    /**
     **********************************************************************
     \brief 设置色盘中线的宽度
     \details 该函数用于设置色盘中线的宽度
     \param[in] nLineIndex 线宽索引
     \param[in] nTypeIndex 色盘类型
     \param[in] nLineWidth 要设置的色盘宽度值
     \param[in] bAll		  所有比例尺同色
     \retval	GD_ERR_OK	成功
     \retval	GD_ERR_INVALID_PARAM	参数无效
     \since 6.0
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_SetLineWidth(Gint32 nLineIndex, Gint32 nTypeIndex, Gint32 nLineWidth, Gbool bAll);
    
    /**
     **********************************************************************
     \brief 获取车标处与车标平行道路
     \details 该函数用于获取在车标处与车标平行的道路
     \param[out] ppCarParallelRoads 车标处与车标同向平行道路
     \param[out] nNumberOfCarParallelRoad 道路条数
     \retval	GD_ERR_OK	成功
     \retval	GD_ERR_INVALID_PARAM	参数无效
     \retval	GD_ERR_NO_DATA	无相关数据
     \remarks
     - 1、	该接口只用于实际导航，模拟状态或非引导状态均无效。
     - 2、	GNaviServer自动监控当前是否存在平行道路，若有则发送通知给HMI，
     (WM_PARALLEL_NOTIFY)HMI随即调用该接口获取平行道路信息。
     - 3、	在第二步如需将车位切换到其他平行道路，则需调用GDBL_ChangeCarRoad接口。
     \since 6.0
     \see GDBL_ChangeCarRoad
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_GetCarParallelRoads (
                                                    GCARPARALLELROAD **ppCarParallelRoads,
                                                    Guint32 *nNumberOfCarParallelRoad
                                                    );
    
    /**
     **********************************************************************
     \brief 将车标切换到其平行道路上
     \details 该函数用于将车标切换到其平行道路上
     \param[in] pObjectId 平行道路ID
     \retval	GD_ERR_OK	成功
     \retval	GD_ERR_INVALID_PARAM	参数无效
     \since 6.0
     \see GDBL_GetCarParallelRoads
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_ChangeCarRoad (
                                              GOBJECTID *pObjectId
                                              );
    
    /**
     **********************************************************************
     \brief 获取当前车位信息（位置、角度等）
     \details 该函数用于获取当前车位信息
     \param[out] pCarInfo 车位信息
     \retval	GD_ERR_OK	成功
     \retval	GD_ERR_INVALID_PARAM	参数无效
     \retval	GD_ERR_NO_DATA	无相关数据
     \since 6.0
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_GetCarInfo (
                                           GCARINFO *pCarInfo
                                           );
    
    /**
     **********************************************************************
     \brief 获取指定地图视图句柄
     \details 该函数用于获取指定的地图视图句柄
     \param[in] eViewType 枚举GMAPVIEWTYPE类型，用于指定视图类型
     \param[out] phMapView 地图视图句柄
     \retval	GD_ERR_OK	成功
     \retval	GD_ERR_INVALID_PARAM	参数无效
     \retval	GD_ERR_NO_DATA	无相关数据
     \remarks
     - 地图视图句柄是用来管理地图视图的，使用该句柄可以进行地图
     视图的缩放、移图、模式切换等操作。
     \since 6.0
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_GetMapViewHandle (
                                                 GMAPVIEWTYPE eViewType,
                                                 GHMAPVIEW *phMapView
                                                 );
    
    /**
     **********************************************************************
     \brief 获取地图视图信息
     \details 该函数用于获取地图视图信息
     \param[in] hMapView 地图视图句柄
     \param[out] pMapObjectInfo 地图视图数据
     \retval	GD_ERR_OK	成功
     \retval	GD_ERR_INVALID_PARAM	参数无效
     \retval	GD_ERR_NO_DATA	无相关数据
     \since 6.0
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_GetMapViewInfo (
                                               GHMAPVIEW hMapView,
                                               GMAPVIEWINFO *pMapViewInfo
                                               );
    
    /**
     **********************************************************************
     \brief 缩放地图视图
     \details 该函数用于缩放地图视图,内部进行刷图，而且开启定时器用于动态缩放
     \param[in] hMapView 地图视图句柄
     \param[in] euSetMapLevel 缩放标识，参见GSETMAPVIEWLEVEL
     \param[in] eLevel 比例级别，当euLevel为GSETMAPVIEW_LEVEL_ANY时才有意义，参见euLevel参数
     \retval	GD_ERR_OK	成功
     \retval	GD_ERR_INVALID_PARAM	参数无效
     \since 6.0
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_ZoomMapView (
                                            GHMAPVIEW hMapView,
                                            GSETMAPVIEWLEVEL euSetMapLevel,
                                            GZOOMLEVEL eLevel
                                            );
    
    /**
     **********************************************************************
     \brief 缩放地图视图
     \details 该函数用于缩放地图视图，立即放大缩小到相应的比例尺不进行刷图
     \param[in] hMapView 地图视图句柄
     \param[in] nFlag 缩放标识，-1缩小一个比例级别，0缩放到eLevel比例级别，1放大一个比例级别
     \param[in] eLevel 比例级别，当nFlag为0时才有意义，参见nFlag参数
     \retval	GD_ERR_OK	成功
     \retval	GD_ERR_INVALID_PARAM	参数无效
     \since 6.0
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_ZoomMapViewEx(
                                             GHMAPVIEW hMapView,
                                             Gint32 nFlag,
                                             GZOOMLEVEL eLevel);
    
    /**
     **********************************************************************
     \brief 设置建筑的高度比例
     \details 该函数用于设置建筑的高度比例
     \param[in]	hMapView 视图句柄
     \param[in]	fRaiseRate 拔高高度的比率
     \retval	GD_ERR_OK 成功
     \retval	异常返回 GSTATUS 对应出错码
     \remarks
     \since 7.0
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_SetBuildingRaiseRate(GHMAPVIEW hMapView, Gfloat32 fRaiseRate);
    
    /**
     **********************************************************************
     \brief 漫游地图视图
     \details 该函数用于地图视图的漫游功能
     \param[in] hMapView 地图视图句柄
     \param[in] pMoveMap 结构体GMOVEMAP指针，用于标识当前移图操作类型和相关参数
     \retval	GD_ERR_OK	成功
     \retval	GD_ERR_INVALID_PARAM	参数无效
     \since 6.0
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_MoveMapView (
                                            GHMAPVIEW hMapView,
                                            GMOVEMAP *pMoveMap
                                            );
    
    /**
     **********************************************************************
     \brief 旋转地图视图
     \details 该函数用于地图视图的旋转
     \param[in] hMapView 地图视图句柄
     \param[in] fDeltaAngle 角度值，可以为负值
     \retval	GD_ERR_OK	成功
     \retval	GD_ERR_INVALID_PARAM	参数无效
     \since 6.0
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_RotateMapView(GHMAPVIEW hMapView, Gfloat32 fDeltaAngle);
    
    /**
     **********************************************************************
     \brief 调节地图仰角
     \details 该函数用于提高地图仰角
     \param[in] hMapView 地图视图句柄
     \param[in] fPitchAngle 仰角值，可以为负值
     \retval	GD_ERR_OK	成功
     \retval	GD_ERR_INVALID_PARAM	参数无效
     \since 6.0
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_AdjustMapViewElevation(GHMAPVIEW hMapView, Gfloat32 fPitchAngle);
    
    /**
     **********************************************************************
     \brief 切换地图视图模式
     \details 实现地图视图模式的切换
     \param[in] hMapView 地图视图句柄
     \param[in] euSetMapViewMode 模式标识，参见GSETMAPVIEWMODE
     \param[in] eMapViewMode 视图模式，当nFlag为0时才有意义，参见nFlag参数说明
     \retval	GD_ERR_OK	成功
     \retval	GD_ERR_INVALID_PARAM	参数无效
     \since 6.0
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_SetMapViewMode (
                                               GHMAPVIEW hMapView,
                                               GSETMAPVIEWMODE euSetMapViewMode,
                                               GMAPVIEWMODE eMapViewMode
                                               );
    
    /**
     **********************************************************************
     \brief 设置绘制地图的回调函数
     \details 该函数用于地图绘制之后或之后的回调函数
     \param[in] pDrawMapCB 地图绘制的回调函数
     \retval	GD_ERR_OK	成功
     \retval	GD_ERR_INVALID_PARAM	参数无效
     \since 7.0
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_SetDrawMapCB(GDRAWMAPCB pDrawMapCB);
    
    /**
     **********************************************************************
     \brief 设置操作地图的回调函数
     \details 该函数用于地图操作之前或之后的回调函数
     \param[in] pControlMapCB 地图操作的回调函数
     \retval	GD_ERR_OK	成功
     \retval	GD_ERR_INVALID_PARAM	参数无效
     \since 7.0
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_SetControlMapCB(GCONTROLMAPCB pControlMapCB);
    
    /**
     **********************************************************************
     \brief 查看指定地图
     \details 该函数用于查看指定地图视图
     \param[in] eViewType 视图类型
     \param[in] nParam1, nParam2, nParam3 扩展参数，参见说明
     \retval	GD_ERR_OK	成功
     \retval	GD_ERR_INVALID_PARAM	参数无效
     \remarks
     - 1、	该接口可以完全取代GDBL_ViewMap。后续只对该接口进行功能扩充。
     - 2、	视图类型与参数对应表：
     序号   | 功能               eViewType	                    nParam1                    nParam2            nParam3
     1	   | 单路线主地图	    GMAP_VIEW_TYPE_MAIN	          | N/A                        N/A                N/A
     2	   | 单路线全程概览	    GMAP_VIEW_TYPE_WHOLE	      | N/A                        N/A                N/A
     3	   | 多路线主地图	    GMAP_VIEW_TYPE_MULTI	      | N/A                        N/A                N/A
     4	   | 多路线全程概览	    GMAP_VIEW_TYPE_MULTIWHOLE	  | N/A                        N/A                N/A
     5	   | 查看POI	        GMAP_VIEW_TYPE_POI	          | GPOI* pPOI	               Gbool bAutoAdjust  N/A
     6	   | 查看SP码点	        GMAP_VIEW_TYPE_SP	          | Gchar* szSPCode	           Gbool bAutoAdjust  N/A
     7	   | 查看引导机动点	    GMAP_VIEW_TYPE_MANEUVER_POINT | GGUIDEROADINFO中的nID字段  Gbool bRotateMap   N/A
     8	   | 路径TMC概览	    GMAP_VIEW_TYPE_ROUTE_TMC      | GGUIDEROADTMCLIST数组序号  N/A                N/A
     9	   | 多路线不同处概览	GMAP_VIEW_TYPE_MULTI_DIFF     | -1 : 所有不同
     10	   | 查看多个点在同一图层	GMAP_VIEW_TYPE_JOURNEYPOINTS | N/A                     N/A                N/A
     - 3、GMAP_VIEW_TYPE_MANEUVER_POINT视图中的第二个参数只有在G_MAP_SHOW_ANIMATED设置为Gtrue有用
     \since 6.0
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_ShowMapView (
                                            GMAPVIEWTYPE eViewType,
                                            Gint32 nParam1,
                                            Gint32 nParam2,
                                            Gint32 nParam3
                                            );
    
    /**
     **********************************************************************
     \brief 实现地图绘制
     \details 刷新一次地图视图, 由ui主动调用
     \param[in] hMapView 地图视口句柄(主地图、全程概览、路口详情、多路径、多路径全程概览等)
     \param[in] eViewType 地图视图类型
     \retval	GD_ERR_OK	成功
     \retval	GD_ERR_INVALID_PARAM	参数无效
     \remarks
     设置G_MAP_SHOWMAPVIEW_ACTIVE为TRUE之后，由ui主动刷图，内部不再进行刷图，
     hMapView 为当前的视口，获取句柄之后再传入，如果获取失败则直接传GNULL，eViewType 为相应的视图类型
     \since 7.0
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_ShowMapViewEx(
                                             GHMAPVIEW hMapView,
                                             GMAPVIEWTYPE eViewType
                                             );
    
    /**
     **********************************************************************
     \brief 强制刷新一次地图视图
     \details 该函数用于强制刷新一次地图视图
     \param[in] hMapView 视图句柄
     \retval	GD_ERR_OK	成功
     \retval	GD_ERR_INVALID_PARAM	参数无效
     \since 6.0
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_RefreshMapView (
                                               GHMAPVIEW hMapView
                                               );
    
    /**
     **********************************************************************
     \brief 获取地图中心信息
     \details 该函数用于获取地图视图中心位置
     \param[in] hMapView 视图句柄
     \param[out] pMapCenterInfo 视图中心信息
     \retval	GD_ERR_OK	成功
     \retval	GD_ERR_INVALID_PARAM	参数无效
     \since 6.0
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_GetMapViewCenterInfo (
                                                     GHMAPVIEW hMapView,
                                                     GMAPCENTERINFO *pMapCenterInfo
                                                     );
    
    /**
     **********************************************************************
     \brief 判定是否全国路网数据是否可用
     \details 该函数用于判断全国路网数据是否可用
     \param[in] szDataPath 全国路网数据路径
     \param[out] bAvailable 全国路网路据是否可用
     \retval	GD_ERR_OK	成功
     \retval	GD_ERR_INVALID_PARAM	参数无效
     \since 6.0
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_IsGlobalDataAvailable (
                                                      Gchar*szDataPath,
                                                      Gbool* bAvailable
                                                      );
    
    /**
     **********************************************************************
     \brief 设置地图显示POI的显示优先级
     \details 该函数用于设置地图显示POI的显示优先级
     \param[in] pPriority  地图显示POI的优先级结构指针
     \param[in] nNum  地图显示POI的优先级结构指针个数
     \retval	GD_ERR_OK	成功
     \retval	GD_ERR_INVALID_PARAM	参数无效
     \remarks
     - 标致类别：31301、21202；雪铁龙类别：31300、21200
     \since 6.0
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_SetDisplayPoiPriority (
                                                      GDISPLAYPOIPRIORITY* pPriority,
                                                      Gint32 nNum
                                                      );
    
    /**
     **********************************************************************
     \brief 获取放大路口对象数据
     \details 该函数用于获取放大路口对象数据
     \param[out] ppZoomObject  放大路口中，点线路径线等信息
     \retval	GD_ERR_OK	成功
     \retval	GD_ERR_INVALID_PARAM	参数无效
     \since 6.1
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_GetZoomViewObject(
                                                 GZOOMOBJECT **ppZoomObject
                                                 );
    
    /**
     **********************************************************************
     \brief 设置15m比例尺下,地图的屏幕范围与经纬度范围之比
     \details 该函数用于设置15m比例尺下,地图的屏幕范围与经纬度范围之比
     \param[in]	euScaleRate 枚举索引
     \param[in]	nPPI_X 屏幕分辨率，当枚举为GSCALERATE_PPI_DPI、GSCALERATE_PPI_SIZE需传入
     \param[in]	nPPI_Y 屏幕分辨率，当枚举为GSCALERATE_PPI_DPI、GSCALERATE_PPI_SIZE需传入
     \param[in]	nScreenSize 屏幕尺寸，当枚举为GSCALERATE_SIZE_DPI、GSCALERATE_PPI_SIZE需传入
     \param[in]	nDPI 像素密度，当枚举为GSCALERATE_SIZE_DPI、GSCALERATE_PPI_DPI需传入
     \retval	GD_ERR_OK 成功
     \retval	异常返回 GSTATUS 对应出错码
     \remarks
     \since 7.0/
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_SetScaleRate(GSCALERATE euScaleRate, Gint32 nPPI_X, Gint32 nPPI_Y, Gfloat32 nScreenSize, Gint32 nDPI);
    
    /**
     **********************************************************************
     \brief 获取车道线信息
     \details 该函数用于获取车道线信息
     \param[in]	nLen BUF长度
     \param[out]	pBuffer 车道信息BUF
     \retval	GD_ERR_OK 成功
     \retval	异常返回 GSTATUS 对应出错码
     \remarks
     \since 7.0
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_GetCarLanes(Gint16 *pBuffer, Gint32 nLen);
    
    /**
     **********************************************************************
     \brief 根据网络提供的对象ID信息通知引擎
     \details 该函数用于根据网络提供的对象
     \param[IN] eNetUpdateEvent  网络提供的对象类型信息
     \retval	成功返回GD_ERR_OK，异常情况返回 GSTATUS 对应出错码
     \remarks
     \since 7.0
     \see GDBL_RemoveNetMapData
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_NotifyMeshUpdated(GNETUPDATEEVENT eNetUpdateEvent);
    
    /**
     **********************************************************************
     \brief 删除网络下载地图数据
     \details 该函数用于删除网络下载地图数据
     \retval	成功返回GD_ERR_OK，异常情况返回 GSTATUS 对应出错码
     \remarks
     \since 7.0
     \see GDBL_NotifyMeshUpdated
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_RemoveNetMapData(void);
    
    /**
     **********************************************************************
     \brief 获取指定点最近的道路信息
     \details
     \param[in]  pt指定点坐标
     \param[out] pRoadInfo道路信息
     \retval GD_ERR_OK       成功
     \retval GD_ERR_FAILED   失败
     \remarks
     捕捉半径<= 5km
     \since 6.1
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_GetRoadInfoByCoord (
                                                   GCOORD *pt,
                                                   GROADINFO *pRoadInfo
                                                   );
    
    /**
     **********************************************************************
     \brief 选择任意地图元素
     \details 该函数用于选择任意地图元素
     \param[in]  pSelectParam        输入参数：视图类型、位置、命令
     \param[out] pElements           元素缓冲区
     \param[out] pNumberOfElements   实际返回的元素个数
     \retval	GD_ERR_OK	成功
     \retval	GD_ERR_FAILED	失败
     \retval	GD_ERR_INVALID_PARAM	参数无效
     \remarks
     -1.     命令                      返回值
     - GSELECT_CMD_ROUTE              路径句柄数组
     - GSELECT_CMD_EVENT              GEVENTINFO 数组
     - GSELECT_CMD_POINT              GPOI 数组
     -2.路径选择点击误差范围20pixels
     -3.GSELECT_CMD_TrafficBoard 类型, pElements 返回静态情报板ID,
     -4.GSELECT_CMD_TIR 类型, pElements 返回事件上报信息
     - pNumberOfElements返回动态情报板取消标志,1,表示 成功取消, 0 表示取消失败
     \since 6.1
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_SelectElementsByHit(GSELECTPARAM *pSelectParam, void **pElements, Gint32 *pNumberOfElements);
    
    /* map_api_group end */
    /** \} */
    
    /** \addtogroup prishow_api_group
     \{ */
    
    /* 优先显示 */
    /**
     **********************************************************************
     \brief 获取优先显示类别列表
     \details 该函数用于获取优先显示POI类别列表。
     \param[out] ppPriCategoryList 用于返回优先显示POI类别列表
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_INVALID_PARAM	参数无效
     \retval	GD_ERR_FAILED	操作失败，暂无具体错误码
     \remarks
     - 优先显示POI类别列表的内存由内部分配，数据在函数的下一次调用后被覆盖掉
     \since 6.0
     \see GDBL_SetPriorityCategory
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_GetPriorityCategoryList (
                                                        GPRIORITYCATEGORYLIST **ppPriCategoryList
                                                        );
    
    /**
     **********************************************************************
     \brief 设置优先显示类别
     \details 该函数用于设置优先显示POI类别。
     \param[in] pIndex 待设置优先显示POI索引数组
     \param[in] nNumberOfIndex 待设置优先显示POI索引数组成员个数
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_INVALID_PARAM	参数无效
     \remarks
     - 该接口设置的类别将会被优先显示，而其他的则不被优先显示，即使之前设置过其为优先显示。
     - 该接口会自动清除pIndex以外的类别优先显示状态。
     - 如nNumberOfIndex等于0，则系统进行自动判定显示规则。
     \since 6.0
     \see GDMID_GetPriorityCategoryList
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_SetPriorityCategory (
                                                    Gint32 *pIndex,
                                                    Gint32 nNumberOfIndex
                                                    );
    
    /* prishow_api_group end */
    /** \} */
    
    /** \addtogroup poi_api_group
     \{ */
    
    /* POI */
    /**
     **********************************************************************
     \brief 获取类别列表
     \details 获取POI指定类编码的类别及其子类信息。
     \param[in]  nCategoryIndex 类别索引
     \param[out] ppstCategoryList POI类别信息列表
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_NO_MEMORY 内存不足
     \retval	GD_ERR_NO_DATA 无相关数据
     \remarks
     nCategoryIndex为0表示主类别
     \since 6.0
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_GetPOICategoryList (
                                                   Gint32 nCategoryIndex,
                                                   GPOICATEGORYLIST **ppCategoryList
                                                   );
    
    /**
     **********************************************************************
     \brief 获取行政区域列表
     \details 实现获取指定行政区域编码的行政区域信息列表。
     \param[in]	euAdareaDataFlag	行政区域数据存在标识
     \param[in]	pstAdCode			行政编码
     \param[out]	ppstAdareaList		行政区域信息列表
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_INVALID_PARAM	参数无效
     \retval	GD_ERR_NO_MEMORY	内存不足
     \retval	GD_ERR_NO_DATA	无相关数据
     \remarks
     1、如果参数lAdminCode等于0，则表示获取当前地图数据所覆盖的行政区域信息，
     包括各行政区域的下级行政区域信息。
     2、如果euAdareaDataFlag等于ADAREA_DATA_EXIST,则必须为pstAdCode->euRegionCode指定枚举值
     \since 6.0
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_GetAdareaList (
                                              GADAREADATAFLAG euAdareaDataFlag,
                                              GADMINCODE *pstAdCode,
                                              GADAREALIST **ppAdareaList
                                              );
    
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
    GDBL_API_CALL GSTATUS GDBL_GetAdareaWithDataList (
                                                      GADMINCODE *pstAdCode,
                                                      GADAREALIST **ppstAdareaList
                                                      );
    
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
    GDBL_API_CALL GSTATUS GDBL_SetCurAdarea (
                                             Gint32 lAdminCode
                                             );
    
    /**
     **********************************************************************
     \brief 获取当前检索行政区域
     \details 获取当前POI检索库中行政区域。
     \param[out]	pstAdareaInfoEx 用于返回当前POI检索库中的行政区域信息
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_INVALID_PARAM	参数无效
     \retval	GD_ERR_NO_MEMORY	内存不足
     \retval	GD_ERR_NO_DATA	无相关数据
     \remarks
     \since 6.0
     \see GDBL_SetCurAdarea
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_GetCurAdarea (
                                             GADAREAINFOEX *pAdareaInfoEx
                                             );
    
    /**
     **********************************************************************
     \brief 获取行政编码
     \details 获取指定经纬坐标所属行政区域编码，或者指定电话区号的行政编码。
     \param[in] pstCoordTel 电话区号或者经纬度坐标
     \param[in] nMaxCnt 行政编码缓存最大个数,当pstCoordTel为坐标时才有意义，参见pstCoordTel参数
     \param[out] pstAdCode 行政编码
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_INVALID_PARAM	参数无效
     \retval	GD_ERR_NO_DATA	无相关数据
     \remarks
     1、pstCoordTel为经纬度坐标时，当获取不到详细行政编码时获取概要行政编码(目前最多20个)，获取到详细行政编码只有一个,
     当nMaxCnt == 0时只获取详细行政编码,当nMaxCnt > 0时返回概要行政编码列表。
     2、pstCoordTel为电话区号时，返回1个详细行政编码
     \since 6.0
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_GetAdminCode (
                                             GCOORDTEL *pCoordTel,
                                             Gint32 nMaxCnt,
                                             GADMINCODE *pstAdCode
                                             );
    
    /**
     **********************************************************************
     \brief 获取行政区域信息
     \details 获取指定行政区域编码对应的省、市、区名称等信息。
     \param[in]	pstAdCode		行政编码
     \param[out]	pstAdareaInfoEx 省、市、区名称等信息
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_INVALID_PARAM	参数无效
     \retval	GD_ERR_NO_MEMORY	内存不足
     \retval	GD_ERR_NO_DATA	无相关数据
     \remarks
     1、	如果lAdminCode指定到省一级，则市、区名称为空；如果lAdminCode指定到市一
     级，则区名称为空。如果lAdminCode等于0，则省、市、区名称为空，具体区域不确定。
     2、	数据包大小，只针对分市版数据。
     \since 6.0
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_GetAdareaInfoEx (
                                                GADMINCODE *pstAdCode,
                                                GADAREAINFOEX *pAdareaInfoEx
                                                );
    
    /**
     **********************************************************************
     \brief 获取行政区域信息(中文)
     \details 获取指定行政区域编码对应的省、市、区名称等信息。
     \param[in]	pstAdCode		上级行政编码
     \param[out]	pstAdareaInfoEx 省、市名称
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_INVALID_PARAM	参数无效
     \retval	GD_ERR_NO_MEMORY	内存不足
     \retval	GD_ERR_NO_DATA	无相关数据
     \remarks
     1、只覆盖省、市2级。
     2、只返回中文简体。
     \since 6.0
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_GetAdareaInfoExChn (
                                                   GADMINCODE *pstAdCode,
                                                   GADAREAINFOEX *pAdareaInfoEx
                                                   );
    
    /**
     **********************************************************************
     \brief 获取候选字(词)列表
     \details 根据指定条件获取相应的候选字(中文字)、词(英语单词)列表。
     \param[in] pstCandidateCondition 包含搜索类型和KeyWord
     \param[out] ppstCandidateList 候选字、词列表
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_INVALID_PARAM	参数无效
     \retval	GD_ERR_NO_MEMORY	内存不足
     \retval	GD_ERR_NO_DATA	无相关数据
     \remarks
     - 最大候选字（词）个数不超过MAX_CANDIDATE_NUM。
     - 候选字（词）限定在当前设置的行政区域所包含的数据，可以通过GDBL_SetCurAdarea
     改变当前行政区域的设置。当联想候选字（词）类型为CANDIDATE_ADAREA_NAME时，则不
     受当前行政区域的限制。
     - 输出参数根据当前引擎处于何种语言版本，返回不同语言版本的相关信息,目前支持英文,
     中文简体,中文繁体,(繁简共用一个返回)
     \since 6.0
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_GetCandidateList (
                                                 GCANDIDATECONDITION *pCandidateCondition,
                                                 GCANDIDATELIST **ppCandidateList
                                                 );
    
    /**
     **********************************************************************
     \brief 本地行政区域检索
     \details 在本地数据库中检索符合条件的行政区域。
     \param[in] pstSearchCondition	检索条件
     \param[out] ppstAdareaInfoList	行政区域列表
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_INVALID_PARAM	参数无效
     \retval	GD_ERR_NO_MEMORY	内存不足
     \retval	GD_ERR_NO_DATA	无相关数据
     \remarks
     由于行政区域信息较少，该接口直接返回结果，而不使用线程进行检索。
     \since 6.0
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_SearchAdareaInfo (
                                                 GSEARCHCONDITION *pSearchCondition,
                                                 GADAREAINFOLIST **ppAdareaInfoList
                                                 );
    
    /**
     **********************************************************************
     \brief 本地POI检索
     \details 在本地数据库中检索符合条件的POI。
     \param[in] pstSearchCondition 检索条件
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_INVALID_PARAM	参数无效
     \remarks
     通过该函数发出POI检索请求后，等待系统的更新检索结果和检索结束的
     通知WM_GETPOIDATA。通过GDBL_GetPOIResult函数可以获取检索结果。
     \since 6.0
     \see GDBL_AbortSearchPOI GDBL_GetPOIResult
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_StartSearchPOI (
                                               GSEARCHCONDITION *pSearchCondition
                                               );
    
    /**
     **********************************************************************
     \brief 注册POI检索心跳回调函数
     \details 该函数用于注册POI检索心跳回调函数
     \param[in]	fptrHeartbeat 回调函数地址
     \retval	GD_ERR_OK 成功
     \retval	异常返回 GSTATUS 对应出错码
     \remarks
     \since 7.0
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_RegisterPOIHeartbeat(THeartbeat fptrHeartbeat);
    
    /**
     **********************************************************************
     \brief 网络POI检索
     \details 使用网络后台检索符合条件的POI。
     \param[in] pstSearchCondition 搜索条件
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_INVALID_PARAM	参数无效
     \remarks
     通过该函数发出POI检索请求后，等待系统的更新检索结果和检索结束的
     通知WM_GETPOIDATA。通过GDBL_GetPOIResult函数可以获取检索结果。
     \since 6.0
     \see GDBL_GetNetCandidateAdareaList GDBL_GetPOIResult
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_StartSearchPOINet (
                                                  GSEARCHCONDITION *pSearchCondition
                                                  );
    
    /**
     **********************************************************************
     \brief 获取行政区域列表
     \details 获取网络关键字检索结果的候选行政区域列表。
     \param[out] ppstAdareaList 包含行政区域列表。
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_INVALID_PARAM	参数无效
     \remarks
     1、	网络POI检索，如果在指定城市没有，后台会返回有该POI的城
     市列表。用户可以选择有的城市，获取相关POI信息。
     2、	发出POI检索请求后，等待系统WM_GETPOIDATA通知，并调用该
     接口获取城市列表。
     \since 6.0
     \see GDBL_StartSearchPOINet
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_GetNetCandidateAdareaList (
                                                          GADAREALIST **ppAdareaList
                                                          );
    
    /**
     **********************************************************************
     \brief 中止POI检索
     \details 该接口用于中止POI检索过程。
     \retval	GD_ERR_OK 成功
     \remarks
     - 在POI检索过程中，可以随时调用该接口告知中止检索过程。
     - 该函数返回时POI检索过程并不一定结束，只是进行通知结束。
     \since 6.0
     \see GDBL_StartSearchPOI
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_AbortSearchPOI(void);
    
    /**
     **********************************************************************
     \brief 获取POI检索结果
     \details 根据需要获取相应的POI个数。
     \param[in] pstInput 请求第一索引和需要的个数
     \param[out] ppstResult返回得到的POI个数
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_INVALID_PARAM	参数无效
     \retval	GD_ERR_NO_MEMORY	内存不足
     \retval	GD_ERR_NO_DATA	无相关数据
     \remarks
     等待GDBL_StartSearchPOI成功后通知上层调用该函数
     \since 6.0
     \see GDBL_StartSearchPOI
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_GetPOIResult (
                                             GETPOIINPUT *pInput,
                                             GPOIRESULT **pResult
                                             );
    
    /**
     **********************************************************************
     \brief 获取距离指定点最近的POI信息
     \details 检索POI数据库，获取指定点最近的POI信息。
     \param[in] pstCoord 经纬坐标
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_INVALID_PARAM	参数无效
     \remarks
     该接口请求获取距离指定点最近的POI信息，该过程在线程中进行，当获取到结果
     后，通过(WM_GETPOIDATA, 1, GD_ERR_**)通知上层，上层则通过调用GDBL_GetNearestPOI
     函数获取结果。
     \since 6.0
     \see GDBL_GetNearestPOI
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_RequestNearestPOI (
                                                  GCOORD* pstCoord
                                                  );
    
    /**
     **********************************************************************
     \brief 获取最近点POI信息
     \details 获取指定点最近的POI信息。
     \param[in/out] pNearestPOI保存当前点最近的POI点
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_INVALID_PARAM	参数无效
     \retval	GD_ERR_NO_DATA	无相关数据
     \remarks
     先调用GDBL_RequestNearestPOI，等待通知后再调用该函数
     \since 6.0
     \see GDBL_RequestNearestPOI
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_GetNearestPOI (
                                              GPOI *pNearestPOI
                                              );
    
    /**
     **********************************************************************
     \brief 获取出入口信息
     \details 当某个POI包含出入口信息时，即ucFlag的<e出入口/>被置1时，可以用此接口获取。
     如【颐和园】的各出入口信息。
     \param[in] pstPOI POI信息
     \param[out] ppstGateInfo POI出入口信息
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_INVALID_PARAM	参数无效
     \retval	GD_ERR_NO_MEMORY	内存不足
     \retval	GD_ERR_NO_DATA	无相关数据
     \remarks
     在调用该函数成功后，如果不再使用该出入口信息时，需调用GDBL_FreePOIGateInfo
     函数释放相关内存，避免内存泄露
     \since 6.0
     \see GDBL_FreePOIGateInfo
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_GetPOIGateInfo (
                                               GPOI *pPOI,
                                               GPOIGATEINFO **ppGateInfo
                                               );
    
    /**
     **********************************************************************
     \brief 释放出入口信息
     \details 该函数用于释放POI的出入口信息。
     \param[in] ppstGateInfo	POI出入口信息
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_INVALID_PARAM	参数无效
     \remarks
     在调用GDBL_GetPOIGateInfo函数成功后，如果不再使用该出入口信息时，
     需调用该函数释放相关内存，避免内存泄露
     \since 6.0
     \see GDBL_GetPOIGateInfo
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_FreePOIGateInfo (
                                                GPOIGATEINFO **ppGateInfo
                                                );
    
    /**
     **********************************************************************
     \brief 获取指定POI包含的楼宇信息
     \details 当某个POI包含楼宇信息时，即ucFlag的<em>楼宇</em>被置1时，可以用此接口获取。
     \param[in] pstPOI POI信息
     \param[out] ppstSettAreaInfo 楼宇及其内部POI信息
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_INVALID_PARAM	参数无效
     \retval	GD_ERR_NO_MEMORY	内存不足
     \retval	GD_ERR_NO_DATA	无相关数据
     \remarks
     在调用该函数成功后，如果不再使用该楼宇信息时，需调用GDBL_FreeSettAreaInfo
     函数释放相关内存，避免内存泄露。
     \since 6.0
     \see GDBL_FreeSettAreaInfo
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_GetSettAreaInfo (
                                                GPOI *pPOI,
                                                GSETTAREAINFO **ppSettAreaInfo
                                                );
    
    /**
     **********************************************************************
     \brief 释放楼宇信息
     \details 该函数用于释放楼宇信息。
     \param[in] ppstSettAreaInfo 楼宇及其内部POI信息
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_INVALID_PARAM	参数无效
     \remarks
     在调用GDBL_GetSettAreaInfo函数成功后，如果不再使用该楼宇信息
     时，需调用该函数释放相关内存，避免内存泄露
     \since 6.0
     \see GDBL_GetSettAreaInfo
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_FreeSettAreaInfo (
                                                 GSETTAREAINFO **ppSettAreaInfo
                                                 );
    
    /**
     **********************************************************************
     \brief 获取指定POI关联的POI信息
     \details 当某个POI有关联的POI信息时，即ucFlag的亲属关系被置1时，可以用此接口获取。
     \param[in] pstPOI				POI信息
     \param[out] ppstRelationshipPOI 具有亲属关系的POI信息
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_INVALID_PARAM	参数无效
     \retval	GD_ERR_NO_MEMORY	内存不足
     \retval	GD_ERR_NO_DATA	无相关数据
     \remarks
     在调用该函数成功后，如果不再使用该亲属关系POI信息时，需调
     用GDBL_FreeRelationshipPOI函数释放相关内存，避免内存泄露
     \since 6.0
     \see GDBL_FreeRelationshipPOI
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_GetRelationshipPOI (
                                                   GPOI	*pPOI,
                                                   GRELATIONSHIPPOILIST **ppRelationshipPOI
                                                   );
    
    /**
     **********************************************************************
     \brief 释放关联关系的POI信息
     \details 获取某个POI关联的POI信息后，需调用此接口释放相关数据。
     \param[in] ppstRelationshipPOI	包含具有亲属关系的POI信息
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_INVALID_PARAM	参数无效
     \remarks
     在调用GDBL_GetRelationshipPOI函数成功后，如果不再使用该亲属
     关系POI信息时，需调用该函数释放相关内存，避免内存泄露
     \since 6.0
     \see GDBL_GetRelationshipPOI
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_FreeRelationshipPOI (
                                                    GRELATIONSHIPPOILIST **ppRelationshipPOI
                                                    );
    
    /**
     **********************************************************************
     \brief 获取指定数据、区域数据状态
     \details 该函数用于获取指定数据、区域数据的状态
     \param[in] pzDataPath 数据路径
     \param[in] pstAdCode 指定的行政区域编码
     \param[out] bHasData Gtrue 有数据, Gfalse 无数据
     \retval	GD_ERR_OK	成功
     \retval	GD_ERR_INVALID_PARAM	参数无效
     \remark
     - pstAdCode->euRegionCode == 0：表示获取全局版本，
     - pstAdCode->euRegionCode > 0 && pstAdCode->nAdCode == 0：表示获取指定国家的基础版本
     - pstAdCode->euRegionCode > 0 && pstAdCode->nAdCode > 0：表示获取指定行政区域(城市)的版本
     \since 6.0
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_GetAdareaDataStatus (
                                                    Gchar* pzDataPath,
                                                    GADMINCODE *pstAdCode,
                                                    Gbool *bHasData
                                                    );
    
    /**
     **********************************************************************
     \brief 更新数据状态
     \details 对于分省市数据，用户操作这些数据时，如删除、增加需通知引擎。
     \param[in] pstAdCode 行政编码
     \param[in] bAdd Gtrue增加该行政区域数据，Gfalse删除该行政区域数据
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_FAILED	操作失败
     \remarks
     - pstAdCode->euRegionCode == 0：表示获取全局版本，
     - pstAdCode->euRegionCode > 0 && pstAdCode->nAdCode == 0：表示获取指定国家的基础版本
     - pstAdCode->euRegionCode > 0 && pstAdCode->nAdCode > 0：表示获取指定行政区域(城市)的版本
     设置区域数据状态对全国、分省、分城市三种数据有效
     \since 6.0
     \see GDBL_GetDataStatus
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_SetAdareaDataStatus (
                                                    GADMINCODE *pstAdCode,
                                                    Gbool bAdd
                                                    );
    
    /*
     **********************************************************************
     \brief 获取数据目录列表
     \details 获取城市数据目录列表
     \param[in] pzDataPath 数据路径
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
    GDBL_API_CALL GSTATUS GDBL_GetAdareaDirList(Gchar* pzDataPath, GADMINCODE *pstAdCode, Gint32 nMaxCnt, GDATADIRINFO* pstDirList);
    
    /* poi_api_group end */
    /** \} */
    
    /** \addtogroup journey_api_group
     \{ */
    
    /* Journey */
    
    /**
     **********************************************************************
     \brief 添加行程点
     \details 该函数用于添加行程起点、途经点、目的地。
     \param[in] eType				需要添加的行程点类型
     \param[in] pPOI					行程点信息
     \param[in] euROURule			行程点的路径规则
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_INVALID_PARAM 参数无效
     \retval	GD_ERR_NO_DATA 无相关数据
     \retval	GD_ERR_NO_MEMORY 内存不足
     \retval	GD_ERR_OP_CANCELED 操作取消
     \retval	GD_ERR_FAILED 操作失败，暂无具体错误码
     \remarks
     - 1.注意通常情况下，无需添加起点，起点采用当前车位。
     - 2.如果途经点1已存在，再向其中添加途经点1，
     则旧的行程点信息将被新的覆盖。添加其他行程点也将执行同样的操作。
     \since 6.0
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_AddJourneyPoint (
                                                GJOURNEYPOINTTYPE eType,
                                                GPOI  *pPOI,
                                                GROUTEOPTION euROURule
                                                );
    /**
     **********************************************************************
     \brief 设置添加行程点回调接口
     \details 该函数用于设置添加行程点时的回调通知。
     \param[in] lpfnNotifyCB	通知回调接口函数
     \param[in] lpVoid       回调函数用户参数，在调用回调函数时，传给回调函数。
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_INVALID_PARAM	参数无效
     \remarks
     - 1.当添加行程点时，若该行程点附近有多条道路供选择时，发送通知，
     并将附近多条道路信息返回给调用者，并由调用者决定选择那条道路。
     - 2.lpfnNotifyCB返回用户的选择索引号。
     \since 6.0
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_SetAddJourneyPointCB (
                                                     GJOURNEYNOTIFYCB lpfnNotifyCB,
                                                     void *lpVoid
                                                     );
    
    /**
     **********************************************************************
     \brief 删除行程点
     \details 该函数用于删除行程起点、途经点、目的地。
     \param[in] eType	行程点类型
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_INVALID_PARAM	参数无效
     \remarks
     - 当起点被删除后，下次行程路线规划时则起点会参考当前车位。
     \since 6.0
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_DelJourneyPoint (
                                                GJOURNEYPOINTTYPE eType
                                                );
    
    /**
     **********************************************************************
     \brief 清空行程点
     \details 该函数用于清空行程起点、途经点、目的地。
     \retval	GD_ERR_OK 成功
     \remarks
     \since 6.0
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_ClearJourneyPoint (void);
    
    /**
     **********************************************************************
     \brief 获取行程点
     \details 该函数用于获取行程点列表。
     \param[out] ppJourneyPoint  行程点列表
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_INVALID_PARAM	参数无效
     \remarks
     - 1.行程点个数固定为MAX_JOURNEY_POINT_NUM个。
     - 2.UI或者其他中间层接口可以通过相关的内存地址索引取得特定形成点信息.(内存由MID分配)
     \since 6.0
     \see GDBL_GetCurrentJourneyPoint
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_GetJourneyPoint (
                                                GPOI **ppJourneyPoint
                                                );
    
    /**
     **********************************************************************
     \brief 获取当前行程点
     \details 该函数用于获取引导路径行程点列表。
     \param[out] ppJourneyPoint  行程点列表
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_NO_DATA	无相关数据
     \retval	GD_ERR_FAILED	操作失败，暂无具体错误码
     \remarks
     - 1.行程点个数固定为MAX_JOURNEY_POINT_NUM个。
     - 2.获取当前引导路径上的行程点信息。
     \since 6.0
     \see GDBL_GetJourneyPoint
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_GetCurrentJourneyPoint (
                                                       GPOI **ppJourneyPoint
                                                       );
    
    /**
     **********************************************************************
     \brief 获取演示路线列表。
     \details 该函数用于获取演示路线列表。
     \param[out]  ppDemoJourneyList  演示行程列表
     \retval	GD_ERR_OK    成功
     \retval	GD_ERR_INVALID_PARAM	参数无效
     \retval	GD_ERR_NO_DATA	        没有相关数据
     \remarks
     - 数据来源于资源目录下routedemo.ini。
     \since 6.0
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_GetDemoJourneyList (
                                                   GDEMOJOURNEYLIST **ppDemoJourneyList
                                                   );
    
    /**
     **********************************************************************
     \brief 加载指定演示路线
     \details 该函数用于加载演示路线。
     \param[in]  nID  路线ID
     \retval	GD_ERR_OK    成功
     \retval	GD_ERR_INVALID_PARAM	参数无效
     \remarks
     - 该接口用于加载指定的演示路线，需要进行路径计算，耗时较长。
     \since 6.0
     \see GDBL_UnloadDemoJourney
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_LoadDemoJourney (
                                                Guint32 nID
                                                );
    
    /**
     **********************************************************************
     \brief 卸载演示路线
     \details 该函数用于卸载演示路线。
     \retval	GD_ERR_OK    成功
     \retval	GD_ERR_INVALID_PARAM	参数无效
     \remarks
     - 路线演示完毕后，需调用该接口将演示路线卸载。
     \since 6.0
     \see GDBL_LoadDemoJourney
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_UnloadDemoJourney(void);
    
    /* journey_api_group end */
    /** \} */
    
    /** \addtogroup route_api_group
     \{ */
    
    /* route */
    
    /**
     **********************************************************************
     \brief 注册路径计算心跳回调函数
     \details 该函数用于注册路径计算心跳回调函数
     \param[in]	lpfnHeartbeat 回调函数地址
     \retval	GD_ERR_OK 成功
     \retval	异常返回 GSTATUS 对应出错码
     \remarks
     \since 7.0
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_RegisterRouteHeartbeat(THeartbeat lpfnHeartbeat);
    
    /**
     **********************************************************************
     \brief 开始路径规划
     \details 该函数用于启动路径规划。
     \param[in]  euCalType 路径演算类型参考GCALROUTETYPE
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_FAILED 操作失败，暂无具体错误码
     \retval	GD_ERR_OP_CANCELED 用户取消            HMI调用了GDBL_AbortRouteCalculation取消算路
     \retval	GD_ERR_TOO_NEAR 行程点之间距离太近     添加的行程点中两两之间距离太近
     \retval	GD_ERR_TOO_FAR 目的地距离太远          起点、中途点、终点距离直线距离之和超过4500km
     \retval	GD_ERR_NO_DATA 数据缺失                没有本地数据或者起点缺失
     \retval	GD_ERR_NO_ROUTE 规划路径失败           算不了路
     \remarks
     \since 6.0
     \see GDBL_AbortRouteCalculation
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_StartRouteCalculation(GCALROUTETYPE euCalType);
    
    /**
     **********************************************************************
     \brief 中止路径规划
     \details 该函数用于中止路径规划。
     \retval	GD_ERR_OK 成功
     \remarks
     \since 6.0
     \see GDBL_AbortRouteCalculation
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_AbortRouteCalculation (void);
    
    /**
     **********************************************************************
     \brief 获取路径演算错误信息
     \details 该函数用于当路径演算失败后获取路径演算失败的错误信息.
     \param[in]  pRouteErrorInfo 错误信息
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_NO_MEMORY 内存不足
     \retval	GD_ERR_NO_DATA 无相关数据
     \remarks
     \since 6.0
     \see GDBL_StartRouteCalculation
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_GetRouteErrorInfo(GROUTEERRORINFO **pRouteErrorInfo);
    
    /**
     **********************************************************************
     \brief 设置TBT导航信息
     \details 该函数用于设置TBT的导航信息.
     \param[in]  pNaviItems 导航信息点指针
     \param[in]  nNumOfItems 导航信息点个数
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_FAILED 操作失败
     \retval	GD_ERR_INVALID_PARAM 参数无效
     \retval	GD_ERR_NO_MEMORY 内存不足
     \retval	GD_ERR_OP_CANCELED 操作取消
     \remarks
     \since 6.0
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_SetTBTNaviItems(GTBTNAVIINTEM *pNaviItems, Gint32 nNumOfItems);
    
    /* route_api_group end */
    /** \} */
    
    /** \addtogroup guide_api_group
     \{ */
    
    /* guidance */
    /**
     **********************************************************************
     \brief 添加引导路径
     \details 该函数用于添加一条引导路径到引导路径管理表。
     \param[in] hGuideRoute 引导路径句柄。
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_INVALID_PARAM 参数无效
     \retval	GD_ERR_FAILED 操作失败
     \remarks
     - 该接口不允许传空句柄
     \since 6.0
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_AddGuideRoute(
                                             GHGUIDEROUTE hGuideRoute
                                             );
    
    /**
     **********************************************************************
     \brief 移除引导路径
     \details 该函数用于从引导路径管理表中移除一条引导路径。
     \param[in] hGuideRoute 引导路径句柄。
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_INVALID_PARAM 参数无效
     \remarks
     - 1.移除操作并不做实际的删除引导路径。
     - 2.正在引导的引导路径不能移除。
     - 3.要移除正在引导的引导路径，必须先停止引导。
     \since 6.0
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_RemoveGuideRoute(
                                                GHGUIDEROUTE hGuideRoute
                                                );
    
    /**
     **********************************************************************
     \brief 删除引导路径
     \details 该函数用于从路径管理列表中删除一条引导路径。
     \param[in] hGuideRoute 引导路径句柄。
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_INVALID_PARAM 参数无效
     \retval	GD_ERR_FAILED 操作失败
     \remarks
     - 1.删除该条引导路径，同时从路径管理表中移除。
     - 2.删除后该条引导路径将不可再用。
     - 3.正在引导的引导路径不能删除。
     - 4.要删除正在引导的引导路径，必须先停止引导。
     \since 6.0
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_DelGuideRoute(
                                             GHGUIDEROUTE hGuideRoute
                                             );
    
    /**
     **********************************************************************
     \brief 清空引导路径
     \details 该函数用于清空引导路径管理表。
     \retval	GD_ERR_OK 成功
     \remarks
     - 1.清空操作是对引导路径管理表中的路径做删除操作。
     - 2.如果有引导路径正在引导，则该条引导路径不做删除。
     \since 6.0
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_ClearGuideRoute(void);
    
    /**
     **********************************************************************
     \brief 获取引导路径列表
     \details 该函数用于获取引导路径列表。
     \param[in] nCount        引导路径句柄缓冲区大小。
     \param[out] phGuideRoute 引导路径句柄缓冲区。
     \param[out] pNumberOfGuideRoute 实际获取的引导路径条数。
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_INVALID_PARAM 参数无效
     \remarks
     \since 6.0
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_GetGuideRouteList(
                                                 GHGUIDEROUTE *phGuideRoute,
                                                 Gint32 nCount,
                                                 Gint32 *pNumberOfGuideRoute
                                                 );
    
    /**
     **********************************************************************
     \brief 改变引导路径句柄
     \details 该函数用于改变引导路径句柄
     \param[in] hGuideRoute     路径句柄
     \retval	GD_ERR_OK 成功
     \remarks
     - 1.选择一条引导路径并不代表引导的就是这条路径。
     - 2.选择功能在多条路径时，选择一条后，可以高亮显示，以供查看。
     - 3.该接口不允许传空的句柄
     \since 6.0
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_ChangeGuideRoute(GHGUIDEROUTE hGuideRoute);
    
    /**
     **********************************************************************
     \brief 获取引导路径经过的城市信息
     \details 该函数用于获取引导路径所经过城市的相关信息。
     \param[in] eGuideRouteType        获取路径经过城市的信息类型
     \param[out] pGuideRouteCityInfo   返回的城市信息
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_NO_MEMORY 内存不足
     \retval	GD_ERR_FAILED 操作失败
     \remarks
     \since 6.0
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_GetGuideRouteCityInfo (
                                                      GGUIDEROUTETYPE eGuideRouteType,
                                                      GGUIDEROUTECITYINFO **pGuideRouteCityInfo
                                                      );
    
    /**
     **********************************************************************
     \brief 获取引导路径信息
     \details 该函数用于获取引导路径相关信息。
     \param[in] hGuideRoute        引导路径句柄
     \param[out] pGuideRouteInfo    引导路径信息
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_INVALID_PARAM 参数无效
     \retval	GD_ERR_FAILED 操作失败
     \remarks
     \since 6.0
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_GetGuideRouteInfo(
                                                 GHGUIDEROUTE hGuideRoute,
                                                 GGUIDEROUTEINFO *pGuideRouteInfo
                                                 );
    
    /**
     **********************************************************************
     \brief 启动引导
     \details 该函数用于启动驾驶引导。
     \param[in] hGuideRoute 引导路径句柄
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_NO_ROUTE	没有引导路径
     \remarks
     - 1.引导指定的路径，上一个路径引导将被自动停止。
     - 2.启动驾驶引导，生成引导路径信息。
     \since 6.0
     \see GDBL_StartGuidance
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_StartGuide(
                                          GHGUIDEROUTE hGuideRoute
                                          );
    
    /**
     **********************************************************************
     \brief 结束引导
     \details 该函数用于结束驾驶引导。
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_NO_ROUTE	没有引导路径
     \remarks
     - 1.bClearAllRoute：Gfalse 停止路径引导，不删除引导路径。
     - 2.bClearAllRoute：Gtrue  结束路径引导，清空引导路径列表。
     \since 6.0
     \see GDBL_StopGuidance
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_StopGuide(Gbool bClearAllRoute);
    
    /**
     **********************************************************************
     \brief 获取机动引导信息
     \details 该函数用于获取机动引导信息。
     \param[out] pManeuverInfo	机动引导信息
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_INVALID_PARAM	参数无效
     \remarks
     - 机动车信息内存由内部分配，每次调用均将上次内容替换。
     \since 6.0
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_GetManeuverInfo(
                                               GMANEUVERINFO **pManeuverInfo
                                               );
    
    /**
     **********************************************************************
     \brief 获取高速机动信息
     \details 该函数用于获取高速机动引导信息。
     \param[out] pManeuverInfo	高速机动信息
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_INVALID_PARAM	参数无效
     \retval	GD_ERR_NO_DATA	  当前无高速机动点信息
     \remarks
     - 1.机动车信息内存由内部分配，每次调用均将上次内容替换。
     - 2.只有当前车位在高速路上时，该接口才返回有数据。
     \since 6.0
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_GetHighwayManeuverInfo(
                                                      GHIGHWAYMANEUVERINFO **pManeuverInfo
                                                      );
    
    /**
     **********************************************************************
     \brief 获取多个机动车信息
     \details 该函数用于获取从当前车位处多个机动引导信息。
     \param[in] nNumberOfManeuversToGet	需要获取的机动信息个数
     \param[in] bAutoCheck	            是否自动判定获取的结束条件
     \param[out] pManeuverInfo	        用于获取当前机动点信息
     \param[out] pNumberOfManeuversGet	实际获取的机动信息个数
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_NO_ROUTE	没有引导路径
     \remarks
     - 1.获取的机动信息从当前车位开始。
     - 2.bAutoCheck为Gfalse时，无附加条件获取nNumberOfManeuversToGet个；
     为Gtrue时，GNaviServer自动判定结束条件，即只获取到距离近的路口机动信息。
     \since 6.0
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_GetMultiManeuverInfo(
                                                    GMANEUVERINFO *pManeuverInfo,
                                                    Guint32 nNumberOfManeuversToGet,
                                                    Gbool bAutoCheck,
                                                    Guint32 *pNumberOfManeuversGet
                                                    );
    
    /**
     **********************************************************************
     \brief 关闭放大路口
     \details 该函数用于主动关闭当前放大路口视图。
     \retval	GD_ERR_OK 成功
     \remarks
     - 1.只能关闭当前放大路口视图，下一个放大路口视图仍然会自动出现。
     \since 6.0
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_CloseZoomView( void );
    
    /**
     **********************************************************************
     \brief 主动播报引导语音
     \details 该函数用于主动触发一次引导语音播报。
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_NO_ROUTE	没有引导路径
     \remarks
     \since 6.0
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_SpeakNaviSound (void);
    
    /**
     **********************************************************************
     \brief 重播引导语音
     \details 该函数用于重复最近一次引导语音播报。
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_NO_ROUTE	没有引导路径
     \remarks
     \since 6.0
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_RepeatNaviSound (void);
    
    /**
     **********************************************************************
     \brief  获取路径列表
     \details 该函数用于获取引导道路列表。
     \param[in] hGuideRoute	引导路径句柄
     \param[in] bGetAllRoad	是否获取每一条道路
     \param[out] pGuideRoadList	用于返回引导道路列表
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_NO_ROUTE   没有引导路径
     \retval	GD_ERR_NO_MEMORY  内存不足
     \remarks
     - 引导道路列表内存由内部开辟，每次调用均会替换上次数据。
     \since 6.0
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_GetGuideRoadList(
                                                GHGUIDEROUTE hGuideRoute,
                                                Gbool bGetAllRoad,
                                                GGUIDEROADLIST **ppGuideRoadList
                                                );
    
    /**
     **********************************************************************
     \brief  获取机动文本列表
     \details 该函数用于获取引导机动文本列表。
     \param[in]  hGuideRoute	引导路径句柄
     \param[out] pManeuverTextList	返回引导机动文本列表
     \param[out] pbMainRoad 返回Gtrue表示存在主要道路，返回Gfalse表示不存在主要道路
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_NO_ROUTE   没有引导路径
     \retval	GD_ERR_NO_MEMORY  内存不足
     \remarks
     - 描述文本起止标记定义（起始和终止标记相同且配对出现）
     当前道路名- [c]
     方位      - [a]
     距离值    - [d]
     转向语句  - [t]
     下一道路名- [n]
     如：沿[c]厦禾路[c]向[a]西北[a]方向，行驶...
     \since 6.0
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_GetManeuverTextList(
                                                   GHGUIDEROUTE hGuideRoute,
                                                   GMANEUVERTEXTLIST *pManeuverTextList,
                                                   Gbool *pbMainRoad
                                                   );
    
    /**
     **********************************************************************
     \brief  获取路径统计信息
     \details 该函数用于获取路径统计信息。
     \param[in] hGuideRoute	引导路径句柄
     \param[in] bWholeJourney Gtrue获取整个行程统计信息，Gfalse获取到下一个中途点
     \param[in] bMultiStat Gtrue获取多条路径统计信息，Gfalse获取当前选中的路径统计信息
     \param[out] ppStatInfoList	路径统计信息
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_NO_ROUTE   没有引导路径
     \remarks
     - 路径统计信息内存由内部开辟，每次调用均会替换上次数据。
     \since 6.0
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_GetPathStatisticInfo(
                                                    GHGUIDEROUTE hGuideRoute,
                                                    Gbool bWholeJourney,
                                                    Gbool bMultiStat,
                                                    GPATHSTATISTICLIST **ppStatInfoList
                                                    );
    
    /**
     **********************************************************************
     \brief  路径保存
     \details 该函数用于保存当前的引导路径到文件szFileName中。
     \param[in] hGuideRoute	路径句柄
     \param[in] szFileName	需要保存的文件名
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_NO_ROUTE   没有引导路径
     \retval	GD_ERR_TOO_NEAR   车位距终点不足20m
     \remarks
     - 文件路径一定要传绝对路径。
     - 起点中间层已经改为以当前车位为起点。
     - 如果车位距中途点不足20m，中间层会自动舍弃中途点
     \since 6.0
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_SaveGuideRoute(
                                              GHGUIDEROUTE hGuideRoute,
                                              Gchar *szFileName
                                              );
    
    /**
     **********************************************************************
     \brief  路径加载
     \details 该函数用于加载一条事先存储的引导路径行程点。
     \param[in]  szFileName	  需要加载的文件名
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_FAILED   操作失败
     \remarks
     - 文件名是绝对路径。
     - HMI调用该接口后，中间层不再进行路径演算，因此还需要调用路径演算接口进行进一步算路。
     - HMI调用路径演算可以自由决定算单路径、多路径、或者只返回路径句柄而不进行引导。
     \since 6.0
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_LoadGuideRoute(
                                              Gchar *szFileName
                                              );
    
    /**
     **********************************************************************
     \brief 获取引导状态标识
     \details 该函数用于获取当前引导的一些状态信息标识。
     \param[in]  pFlags	  引导状态标识
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_NO_ROUTE   没有引导路径
     \remarks
     \since 6.0
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_GetGuideFlags(
                                             GGUIDEFLAGS *pFlags
                                             );
    
    /**
     **********************************************************************
     \brief 获取目的地方向
     \details 该函数用于获取当前车位指向目的地的方向角度。
     \param[in] bNextWaypoint	  Gtrue下一个中途点作为计算参考对象，Gfalse最终目的地作为计算参考对象。
     \param[in] pAngle	 当前车位指向目的地的方向角度（正东0，逆时针）。
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_NO_ROUTE   没有引导路径
     \remarks
     \since 6.0
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_GetDestinationAngle(
                                                   Gbool bNextWaypoint,
                                                   Gint32 *pAngle
                                                   );
    
    /**
     **********************************************************************
     \brief 获取当前路口放大视图信息
     \details 该函数用于获取当前路口放大视图的信息。
     \param[out] pViewInfo 用于返回当前路口的放大路口信息。
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_NO_DATA   无相关数据
     \remarks
     \since 6.0
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_GetCurrentZoomViewInfo(
                                                      GZOOMVIEWINFO *pViewInfo
                                                      );
    
    /**
     **********************************************************************
     \brief 获取引导道路TMC列表
     \details 该函数用于获取引导道路TMC相关信息。
     \param[out] pList 引导道路TMC列表。
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_NO_DATA 没有相关数据
     \retval GD_ERR_NO_MEMORY 内存不足
     \retval GD_ERR_NO_ROUTE 没有引导路径
     \remarks
     \since 6.0
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_GetGuideRoadTMCList(
                                                   GGUIDEROADTMCLIST *pList
                                                   );
    
    /**
     **********************************************************************
     \brief 获取最近一个被跳过的途经点索引号
     \details 该函数用于获取最近一个被跳过的途经点索引号
     \param[out]	pnMissedIndex 途经点索引号
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_INVALID_PARAM 参数异常
     \retval	GD_ERR_FAILED        失败
     \remarks
     -用于获取最近一个被跳过的中途点。该接口只有在中途点被绕过后首次调用才返回正确值
     此后再调用该接口返回值都是0。如果HMI有其他地方需要使用到需要做备份。
     \since 7.0
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_GetLastMissedWaypoint(
                                                     Gint32 *pnMissedIndex
                                                     );
    
    /* guide_api_group end */
    /** \} */
    
    /** \addtogroup demo_api_group
     \{ */
    
    /* demo */
    /**
     **********************************************************************
     \brief 启动模拟导航
     \details 启动模拟导航。
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_RUNNING 正在进行
     \remarks
     \since 6.0
     \see GDBL_StopDemo
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_StartDemo (void);
    
    /**
     **********************************************************************
     \brief 暂停模拟导航
     \details 暂停模拟导航。
     \retval	GD_ERR_OK 成功
     \remarks
     \since 6.0
     \see GDBL_ContinueDemo
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_PauseDemo (void);
    
    /**
     **********************************************************************
     \brief 继续模拟导航
     \details 继续模拟导航。
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_FAILED	操作失败
     \remarks
     \since 6.0
     \see GDBL_PauseDemo
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_ContinueDemo (void);
    
    /**
     **********************************************************************
     \brief 停止模拟导航
     \details 停止模拟导航。
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_NOT_START	没有调用前序接口
     \remarks
     \since 6.0
     \see GDBL_StartDemo
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_StopDemo (void);
    
    /**
     **********************************************************************
     \brief 转换成NMEA格式
     \details 该函数用于将当前路径模拟的GPS点信息转换成NMEA格式，并存入指定文件中。
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_INVALID_PARAM	参数无效
     \retval	GD_ERR_FAILED	操作失败
     \remarks
     1、有路径的情况下，该接口才有效。
     2、当前处于非模拟状态。
     \since 6.0
     \see GDBL_StartDemo
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_GenerateNMEAByCurrentRoute(Gchar *szFileName);
    
    /* demo_api_group end */
    /** \} */
    
    /** \addtogroup favorite_api_group
     \{ */
    
    /* Favorite */
    /**
     **********************************************************************
     \brief 添加收藏夹兴趣点
     \details 该函数用于按指定的类别收藏兴趣点。
     \param[in]	eCategory	收藏的兴趣点类别
     \param[in]	eIconID		收藏点图面显示的图标ID
     \param[in]	pPOI		待收藏的兴趣点
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_INVALID_PARAM	参数无效
     \retval	GD_ERR_DUPLICATE_DATA	重复数据
     \remarks
     - 在添加兴趣点时，引擎按如下规则进行排重处理:
     1.名称一样;
     2.经纬坐标差绝对值小于100。
     - 添加重复的兴趣点，会影响已存在的兴趣点排列顺序。
     \since 6.0
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_AddFavorite(
                                           GFAVORITECATEGORY  eCategory,
                                           GFAVORITEICON eIconID,
                                           GPOI *pPOI
                                           );
    
    /**
     **********************************************************************
     \brief 删除收藏夹兴趣点
     \details 该函数用于根据索引删除一定个数的已收藏兴趣点。
     \param[in]	pIndex	待删除兴趣点索引数组
     \param[in]	nNumberOfIndex	待删除兴趣点索引数组成员个数
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_INVALID_PARAM	参数无效
     \remarks
     - 如果正在显示收藏夹兴趣点列表，当从列表删除收藏兴趣点后，需刷新列表。
     执行该操作后，GDBL发送列表更新通知给HMI，通知刷新列表数据。
     - 只要成功删除一条，该接口均返回GD_ERR_OK。
     \since 6.0
     \see GDBL_DelFavorite
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_DelFavoriteByIndex(
                                                  Gint32  *pIndex,
                                                  Gint32  nNumberOfIndex
                                                  );
    
    /**
     **********************************************************************
     \brief 删除收藏夹兴趣点
     \details 该函数用于删除一个已收藏的兴趣点
     \param[in]	pFavoritePOI	用于标识需删除的兴趣点
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_INVALID_PARAM	参数无效
     \remarks
     \since 7.0
     \see GDBL_DelFavoriteByIndex
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_DelFavorite(GFAVORITEPOI* pFavoritePOI);
    
    /**
     **********************************************************************
     \brief 编辑收藏夹兴趣点。
     \details 该函数用于编辑一个已收藏的兴趣点。
     \param[in]	pFavoritePOI	用于标识已编辑的兴趣点
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_INVALID_PARAM	参数无效
     \remarks
     - 对于兴趣点的编辑，nIndex字段必须不能编辑，该值只用作内部处理。
     Date和Time字段无需编辑，系统内部根据当前时间自动填充。
     - 该操作会影响该兴趣点的排列顺序。
     \since 6.0
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_EditFavorite(
                                            GFAVORITEPOI *pFavoritePOI
                                            );
    
    /**
     **********************************************************************
     \brief  获取收藏夹兴趣点。
     \details 该函数用于获取某类别的收藏夹兴趣点列表。
     \param[in]	eCategory	用于标识要获取的收藏夹类别
     \param[out]	ppFavoritePOIList	用于返回收藏夹兴趣点列表
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_INVALID_PARAM	参数无效
     \retval GD_ERR_NO_MEMORY  内存不足
     \remarks
     - 收藏夹列表的内存由内部分配, 该数据在函数的下一次调用后被覆盖掉
     - eCategory可以组合，以便获取多个类别数据
     \since 6.0
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_GetFavoriteList(
                                               GFAVORITECATEGORY  eCategory,
                                               GFAVORITEPOILIST  **ppFavoritePOIList
                                               );
    
    /**
     **********************************************************************
     \brief 清空收藏夹兴趣点。
     \details 该函数用于清空指定类别的收藏夹。
     \param[in]	eCategory	用于标识要清空的收藏夹类别
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_INVALID_PARAM	参数无效
     \remarks
     - eCategory可以组合，以便清空多个类别数据
     \since 6.0
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_ClearFavorite(
                                             GFAVORITECATEGORY  eCategory
                                             );
    
    /**
     **********************************************************************
     \brief 判断一个点是否已被收藏
     \details 判断一个点是否已经在指定的类别中被收藏
     \param[in]  eCategory收藏夹类别
     \param[in]  pPOI点信息
     \param[out] pbFavorited用于标识是否已被收藏
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_INVALID_PARAM	参数无效
     \remarks
     \since 6.1
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_IsFavorited(
                                           GFAVORITECATEGORY eCategory,
                                           GPOI *pPOI,
                                           Gbool *pbFavorited
                                           );
    /**
     **********************************************************************
     \brief 获取收藏夹容量。
     \details 该函数用于获取收藏夹容量状态。
     \param[in]	ppFavoriteStatus	用于返回收藏夹容量状态
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_NO_DATA	没有数据
     \remarks
     - 收藏夹容量的内存由内部分配, 该数据在本函数的下一次调用后被覆盖掉
     \since 6.0
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_GetFavoriteStatus(
                                                 GFAVORITESTATUS  **ppFavoriteStatus
                                                 );
    
    /**
     **********************************************************************
     \brief	 升级收藏夹文件
     \details 升级收藏夹文件
     \retval  GD_OK 成功
     \retval  GD_FAILED 失败
     \remarks
     - 6.1和7.1的收藏夹名称不一样，升级完后需要上层进行删除操作
     \since 7.0
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_UpgradeFavoriteFiles(void);
    
    /* favorite_api_group end */
    /** \} */
    
    /** \addtogroup track_api_group
     \{ */
    
    /* Track */
    /**
     **********************************************************************
     \brief 获取轨迹列表信息
     \details 该函数用于获取轨迹列表信息
     \param[out]	ppTrackList 用于返回系统轨迹列表
     \retval GD_ERR_OK 操作成功
     \retval GD_ERR_NO_DATA 无相关数据
     \remarks
     \since 7.0
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_GetTrackList(
                                            GTRACKINFOLIST **ppTrackList
                                            );
    
    /**
     **********************************************************************
     \brief 删除一定个数轨迹
     \details 该函数用于删除一定个数的轨迹信息
     \param[in]	pIndex 轨迹索引数组
     \param[in]	nNumberOfIndex 索引个数
     \retval GD_ERR_OK 操作成功
     \retval GD_ERR_FAILED 操作失败
     \retval GD_ERR_INVALID_PARAM 参数无效
     \remarks
     只要成功删除一条，该接口均返回GD_ERR_OK。
     \since 7.0
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_DelTrack(
                                        Gint32  *pIndex,
                                        Gint32  nNumberOfIndex
                                        );
    
    /**
     **********************************************************************
     \brief 清空轨迹文件
     \details 该函数用于清空轨迹文件
     \retval GD_ERR_OK 操作成功
     \retval GD_ERR_FAILED 操作失败
     \retval GD_ERR_NO_DATA 无相关数据
     \remarks
     \since 7.0
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_ClearTrack(void);
    
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
    GDBL_API_CALL GSTATUS GDBL_EditTrack(
                                         GTRACKINFO *pTrackInfo
                                         );
    
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
    GDBL_API_CALL GSTATUS GDBL_LoadTrack(
                                         Gchar *szFileName
                                         );
    
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
    GDBL_API_CALL GSTATUS GDBL_UnloadTrack(
                                           Gchar *szFileName
                                           );
    
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
    GDBL_API_CALL GSTATUS GDBL_StartTrackReplay (
                                                 Gchar *szFileName
                                                 );
    
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
    GDBL_API_CALL GSTATUS GDBL_PauseTrackReplay (void);
    
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
    GDBL_API_CALL GSTATUS GDBL_ContinueTrackReplay (void);
    
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
    GDBL_API_CALL GSTATUS GDBL_StopTrackReplay (void);
    
    /**
     **********************************************************************
     \brief 判断指定的轨迹文件是否已加载
     \details 该函数用于判断指定的轨迹文件是否已加载
     \param[in]	szFileName 轨迹文件名
     \param[in]	bLoaded Gtrue-已加载  Gfalse-未加载
     \retval	GD_ERR_OK 成功
     \retval	异常返回 GSTATUS 对应出错码
     \remarks
     \since 7.0
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_TrackIsLoaded(Gchar *szFileName, Gbool *bLoaded);
    
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
    GDBL_API_CALL GSTATUS GDBL_SetTrackLineInfo(GTRACKLINEINFO *pTrackLineInfo, Gint32 nNum, GRECT stRect);
    
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
    GDBL_API_CALL GSTATUS GDBL_UpgradeTrackFile(Gchar* szFileName);
    
    /* track_api_group end */
    /** \} */
    
    /** \addtogroup detour_api_group
     \{ */
    
    /* Detour */
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
    GDBL_API_CALL GSTATUS GDBL_AddDetourRoad(
                                             GDETOURROADINFO *pstDetourRoad
                                             );
    
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
    GDBL_API_CALL GSTATUS GDBL_EditDetourRoad(
                                              GDETOURROADINFO *pDetourRoad
                                              );
    
    /**
     **********************************************************************
     \brief 删除指定避让道路
     \details 删除指定避让道路，保存到避让文件中。
     \param[in]  pnIndex 避让道路索引数组
     \param[in]  nNumberOfIndex 索引数组大小
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_FAILED	操作失败
     \remarks
     \since 6.0
     \see GDBL_GetDetourRoadList
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_DelDetourRoad(
                                             Gint32  *pnIndex,
                                             Gint32  nNumberOfIndex
                                             );
    
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
    GDBL_API_CALL GSTATUS GDBL_ClearDetourRoad(void);
    
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
    GDBL_API_CALL GSTATUS GDBL_GetDetourRoadList(
                                                 GDETOURROADLIST **ppstDetourRoadList
                                                 );
    
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
    GDBL_API_CALL GSTATUS GDBL_IsDetoured(
                                          GOBJECTID* pstObjectId,
                                          Gbool *pbDetoured
                                          );
    
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
    GDBL_API_CALL GSTATUS GDBL_UpdateCloudAvoidInfo(Gchar *szFullPathFileName);
    
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
    GDBL_API_CALL GSTATUS GDBL_UpgradeAvoidFile(Gchar *szFullPathFileName);
    
    /* detour_api_group end */
    /** \} */
    
    /** \addtogroup reg_api_group
     \{ */
    
    /* 注册 */
    /**
     **********************************************************************
     \brief 设置自定义UUID
     \details 该函数用于设置自定义的UUID
     \param[in] szDeviceID 自定义UUID
     \retval	GD_ERR_OK	成功
     \retval	GD_ERR_INVALID_PARAM	参数无效
     \retval	GD_ERR_FAILED	失败
     \since 6.0
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_SetCustomUUID (Gchar *szDeviceID);
    
    /**
     **********************************************************************
     \brief 设置自定义UUID
     \details 该函数用于设置自定义的UUID（无格式）
     \param[in] szDeviceID 自定义UUID
     \retval	GD_ERR_OK	成功
     \retval	GD_ERR_INVALID_PARAM	参数无效
     \retval	GD_ERR_FAILED	失败
     \remarks
     - 不进行格式化.
     \since 6.0
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_SetCustomUUIDNoFormat (Gchar *szDeviceID);
    
    /**
     **********************************************************************
     \brief 判断当前用户是否已注册
     \details 该函数用于判断当前用户是否已注册
     \retval	GD_ERR_OK	成功
     \retval	GD_ERR_INVALID_PARAM	参数无效
     \retval	GD_ERR_NO_DATA	无相关数据
     \remarks
     - 1、	系统内部有预置部分设备ID的获取方式，当不满足时，可以使用该接口设置设备ID。
     - 2、	该接口须在GDBL_IsValidateUser前调用。
     \since 6.0
     \see GDBL_Register
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_IsValidateUser (void);
    
    /**
     **********************************************************************
     \brief 获取注册用安装码
     \details 该函数用于获取注册用安装码
     \param[in] szSN 序列号
     \param[in] iBufSize 缓冲区大小
     \param[out] szInstallCode 安装码
     \retval	GD_ERR_OK	成功
     \retval	GD_ERR_INVALID_PARAM	参数无效
     \since 6.0
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_GetInstallCode (
                                               Gchar *szSN,
                                               Gchar *szInstallCode,
                                               Gint32 iBufSize
                                               );
    
    /**
     **********************************************************************
     \brief 注册激活码
     \details 该函数用于注册激活码
     \param[in] szLoginCode 激活码
     \retval	GD_ERR_OK	成功
     \retval	GD_ERR_INVALID_PARAM	参数无效
     \since 6.0
     \see GDBL_IsValidateUser GDBL_GetRegisterInfo
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_Register (
                                         Gchar *szLoginCode
                                         );
    
    /**
     **********************************************************************
     \brief 获取注册信息
     \details 该函数用于获取注册信息
     \param[in] szSerialNo 序列号缓冲区
     \param[in] iSizeOfSerialNo 序列号缓冲区大小
     \param[in] szInstallCode 安装码缓冲区
     \param[in] iSizeOfInstallCode 安装码缓冲区大小
     \retval	GD_ERR_OK	成功
     \retval	GD_ERR_INVALID_PARAM	参数无效
     \retval	GD_ERR_FAILED	失败
     \since 6.0
     \see GDBL_Register
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_GetRegisterInfo (
                                                Gchar *szSerialNo,
                                                Gint32 iSizeOfSerialNo,
                                                Gchar *szInstallCode,
                                                Gint32 iSizeOfInstallCode
                                                );
    
    /* reg_api_group end */
    /** \} */
    
    /** \addtogroup cfg_api_group
     \{ */
    
    /* 设置 */
    /**
     **********************************************************************
     \brief 参数设置
     \details 该函数用于设置系统参数
     \param[in] euCFGType 参数类型GPARAM枚举值，用于指定要设置的参数
     \param[in] pValue 参数值缓冲区
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_NOT_SUPPORT 不支持该功能
     \retval	GD_ERR_INVALID_PARAM 参数无效
     \remarks
     
     \since 6.0
     \see GDBL_GetParam
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_SetParam (
                                         GPARAM euCFGType,
                                         void* pValue
                                         );
    
    /**
     **********************************************************************
     \brief 获取系统参数
     \details 该函数用于获取系统参数。
     \param[in]  euCFGType 参数类型GPARAM枚举值，用于指定要设置的参数
     \param[out] pValue 参数值缓冲区
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_INVALID_PARAM 参数无效
     \remarks
     
     \since 6.0
     \see GDBL_SetParam
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_GetParam (
                                         GPARAM euCFGType,
                                         void* pValue
                                         );
    
    /**
     **********************************************************************
     \brief 主动保存用户配置到文件中
     \details 该函数用于主动保存用户配置到文件中。
     \retval	GD_ERR_OK 成功
     \remarks
     \since 6.0
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_SaveUserConfig (void);
    
    /* cfg_api_group end */
    /** \} */
    
    /** \addtogroup tts_api_group
     \{ */
    
    /**
     **********************************************************************
     \brief TTS播报
     \details 该函数用于TTS播报文本。
     \param[in]	pText		播报内容
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_INVALID_PARAM	参数无效
     \remarks
     \since 6.0
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_TTSSpeak (
                                         Gchar *pText
                                         );
    
    /**
     **********************************************************************
     \brief 切换TTS播报角色
     \details 该函数用于切换TTS播报角色。
     \param[in]	eRole		指定TTS播报角色
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_INVALID_PARAM	参数无效
     \remarks
     \since 6.0
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_TTSChangeRole (
                                              GTTSROLE eRole
                                              );
    
    /**
     **********************************************************************
     \brief 注册播报回调函数
     \details 该函数用于注册播报回调函数。
     \param[in]	eType		  回调类型
     \param[in]	TTSCallback   回调接口地址
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_INVALID_PARAM	参数无效
     \remarks
     \since 6.0
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_RegisterTTSCallback (
                                                    GTTSCALLBACKTYPE eType,
                                                    Guint32 (*TTSCallback)(void)
                                                    );
    
    /**
     **********************************************************************
     \brief 停止播报
     \details 该函数用于停止当前的TTS播报。
     \param[in]	eType		  回调类型
     \param[in]	TTSCallback   回调接口地址
     \retval	GD_ERR_OK 成功
     \remarks
     \since 6.0
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_StopTTSSpeak (void);
    
    /* tts_api_group end */
    /** \} */
    
    /** \addtogroup hw_api_group
     \{ */
    
    /**
     **********************************************************************
     \brief 手写识别
     \details 该函数用于手写识别功能，手写相应字并输入，然后获取匹配的候选字。
     \param[in]	pstParam 输入参数
     \param[out]	pCandidate 识别结果
     \retval	GD_ERR_OK 成功
     \remarks
     参数
     1.GHWINPUT	*pstParam	 输入差数
     GHWFLAG	eFlag;					 识别参数
     Gint16	nMaxNumberOfCandidate;	 期望的识别候选字个数(最大数为10)
     Gint16	nNumberOfStrokePoint;	 笔画轨迹点个数
     GSCOORD	*pStokePoint;			 笔画轨迹点坐标（单位：像素，应用层开辟空间）
     2.GHWCANDIDATE *pCandidate 识别结果
     Guint16	nNumberOfCandidate;		 输出识别后的候选字个数
     Guint16	*pstCandidate;			 候选字缓冲(应用层开辟空间)
     说明
     1.候选字缓冲由应用层开辟空间，至少容纳下nMaxNumberOfCandidate个字
     2.GHW_CHARSET_CHINESE GHW_CHARSET_ENGLISH GHW_CHARSET_NUMBER GHW_CHARSET_PUNCTUATION
     这四个字符集可任意组合，至少选一
     3.GHW_OUTPUT_DEFAULT GHW_OUTPUT_SIMPLE GHW_OUTPUT_TRADITIONAL
     三个输出方式必先一
     4.GHW_OUTPUT_LOWERCASE GHW_OUTPUT_UPPERCASE
     限定大小写字母，在GHW_CHARSET_ENGLISH设置的情况下可选其一
     \since 7.0
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_HWRecognize (
                                            GHWINPUT *pParam,
                                            GHWCANDIDATE *pCandidate
                                            );
    
    /**
     **********************************************************************
     \brief 获取候选汉字列表
     \details 该函数用于获取候选汉字列表。
     \param[in]	pzKeyword 关键字
     \param[out]	ppstCandidateList 候选字列表
     \retval	GD_ERR_OK 操作成功
     \retval	GD_ERR_FAILED	操作失败
     \remarks
     \since 7.0
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_GetIMCandidateList (
                                                   Gchar *szKeyword,
                                                   GCANDIDATELIST **ppCandidateList
                                                   );
    
    /**
     **********************************************************************
     \brief 设置输入法
     \details 该函数用于设置输入法模式。
     \param[in]	euMode 输入法模式
     \retval	GD_ERR_OK 操作成功
     \remarks
     \since 7.0
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_SetIMMode (
                                          GIMMODE eMode
                                          );
    
    /**
     **********************************************************************
     \brief 获取当前输入法模式
     \details 该函数用于获取当前输入法模式。
     \param[out]	pIMMode 输入法模式
     \retval	GD_ERR_OK 操作成功
     \remarks
     \since 7.0
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_GetIMMode (
                                          GIMMODE *pIMMode
                                          );
    
    /**
     **********************************************************************
     \brief 设置当前输入法语言
     \details 设置当前输入法语言。
     \param[in] euLanguage	 语言
     \retval	返回错误码
     \remarks
     \since 6.0
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_SetIMLanguage(GIMLANGUAGE euLanguage);
    
    /**
     **********************************************************************
     \brief 获取当前输入法联想字词
     \details 该函数用于获取当前输入法联想字词。
     \param[in]	nIndex	 索引
     \param[out]	ppstCandidateList 联想的字词
     \retval	GD_ERR_OK 操作成功
     \retval	GD_ERR_FAILED 操作失败
     \remarks
     当前输入法包括手写、拼音、笔画等
     \since 7.0
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_GetAssociateCandidateList (
                                                          Gint32 nIndex,
                                                          GCANDIDATELIST **ppCandidateList
                                                          );
    
    /* hw_api_group end */
    /** \} */
    
    /** \addtogroup loc_api_group
     \{ */
    
    /* gps */
    /**
     **********************************************************************
     \brief 获取GPS信息
     \details 获取当前GPS基本信息。
     \param[out]  pGpsInfo 结构体GGPSINFO指针，用于返回GPS基本信息
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_FAILED	操作失败
     \remarks
     \since 6.0
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_GetGPSInfo (
                                           GGPSINFO *pGpsInfo
                                           );
    
    /**
     **********************************************************************
     \brief 获取卫星信息
     \details 获取当前卫星基本信息。
     \param[in]  pSatellite 结构体GSATELLITEINFO指针，用于返回卫星基本信息
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_FAILED	操作失败
     \remarks
     \since 6.0
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_GetSatelliteInfo (
                                                 GSATELLITEINFO *pSatellite
                                                 );
    
    /**
     **********************************************************************
     \brief 控制O2功能
     \details 控制O2功能来进行坐标转换。
     \param[in]  bEnable Gtrue开启O2，Gfalse关闭O2
     \retval	GD_ERR_OK 成功
     \remarks
     \since 6.0
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_EnableO2 (
                                         Gbool bEnable
                                         );
    
    /**
     **********************************************************************
     \brief 设置定位信号数据
     \details 设置定位信号数据来进行定位。
     \param[in]  eLocDataType 数据类型
     \param[in]  pLocData 信号数据
     \param[in]  nSize 数据包大小
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_INVALID_PARAM	参数无效
     \retval	GD_ERR_NO_MEMORY	内存不足
     \remarks
     \since 6.0
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_SetLocData (
                                           GLOCDATATYPE eLocDataType,
                                           void *pLocData,
                                           Gint32 nSize
                                           );
    
    /* loc_api_group end */
    /** \} */
    
    /** \addtogroup 3dshow_api_group
     \{ */
    
    /* model demo */
    /**
     **********************************************************************
     \brief 获取演示模型列表
     \details 该函数用于获取演示模型列表。
     \param[out] ppstDemoModelList 结构体GDEMOMODELLIST指针的指针，用于返回演示模型列表信息
     \param[out] pnNumberOfList 演示模式列表个数
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_FAILED 操作失败
     \retval	GD_ERR_NO_DATA 无相关数据
     \remarks
     - 演示模型按城市组织，一个城市的演示模型作为一个单独的列表。该接口获取所有城市的演示模型，故存在多个列表。
     \since 6.0
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_GetDemoModelList (
                                                 GDEMOMODELLIST **ppstDemoModelList,
                                                 Guint32 *pnNumberOfList
                                                 );
    
    /**
     **********************************************************************
     \brief 启动模型演示
     \details 该函数用于开始模型演示。
     \param[in] pstDemoModelInfo 结构体GDEMOMODELINFO指针，用于表示要演示的模型
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_NO_DATA 无相关数据
     \retval GD_ERR_RUNNING 正在进行
     \remarks
     \since 6.0
     \see GDBL_PauseModelDemo GDBL_ContinueModelDemo GDBL_StopModelDemo
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_StartModelDemo (
                                               GDEMOMODELINFO *pstDemoModelInfo
                                               );
    
    /**
     **********************************************************************
     \brief 暂停模型演示
     \details 该函数用于暂停模型演示。
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_NOT_START 没有调用前序接口
     \remarks
     \since 6.0
     \see GDBL_StartModelDemo GDBL_ContinueModelDemo
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_PauseModelDemo (void);
    
    /**
     **********************************************************************
     \brief 继续模型演示
     \details 该函数用于继续模型演示。
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_NOT_START 没有调用前序接口
     \remarks
     \since 6.0
     \see GDBL_StartModelDemo GDBL_PauseModelDemo
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_ContinueModelDemo (void);
    
    /**
     **********************************************************************
     \brief 结束模型演示
     \details 该函数用于结束模型演示。
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_NOT_START 没有调用前序接口
     \remarks
     \since 6.0
     \see GDBL_StartModelDemo 
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_StopModelDemo (void);
    
    /* 3dshow_api_group end */
    /** \} */
    
    /** \addtogroup travel_api_group
     \{ */
    
    /* 旅游专题 */
    /**
     **********************************************************************
     \brief 获取类别列表
     \details 获取旅游专题POI的类别及子类信息。
     \param[in] nCategoryID 类别ID
     \param[out] ppCategoryList 类别列表
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_NO_DATA	无相关数据
     \remarks
     \since 6.0
     \see
     **********************************************************************/	
    GDBL_API_CALL GSTATUS GDBL_GetTPOICategoryList (
                                                    Gint32 lCategoryID,
                                                    GTPOICATEGORYLIST **ppCategoryList
                                                    );
    
    /**
     **********************************************************************
     \brief 获取等级列表
     \details 获取酒店或景点等级列表。
     \param[in] nCategoryID 类别ID
     \param[out] ppLevelList 等级列表
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_INVALID_PARAM	参数无效
     \retval	GD_ERR_NO_DATA	无相关数据
     \remarks
     \since 6.0
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_GetTPOILevelList (
                                                 Gint32 lCategoryID,
                                                 GTPOICATEGORYLIST **ppLevelList
                                                 );
    
    /**
     **********************************************************************
     \brief 获取旅游专题覆盖行政区域列表
     \details 获取指定行政区域对应的旅游专题覆盖行政区域列表。
     \param[in] nAdminCode 行政编码
     \param[out] ppAdareaList 行政区域列表
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_NO_DATA	无相关数据
     \remarks
     \since 6.0
     \see
     **********************************************************************/	
    GDBL_API_CALL GSTATUS GDBL_GetTAdareaList (
                                               Gint32 lAdminCode,
                                               GADAREALIST **ppAdareaList
                                               );
    
    /**
     **********************************************************************
     \brief 获取旅游专题相关简介
     \details 获取旅游专题符合条件的相关简介。
     \param[in] pstCondition 简介条件
     \param[out] ppTIntroduction 简介信息
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_INVALID_PARAM	参数无效
     \retval	GD_ERR_NO_DATA	无相关数据
     \remarks
     \since 6.0
     \see
     **********************************************************************/	
    GDBL_API_CALL GSTATUS GDBL_GetTIntroduction (
                                                 GTINTRODUCTIONINPUT *pCondition,
                                                 GTINTRODUCTION **ppTIntroduction
                                                 );
    
    /**
     **********************************************************************
     \brief 检索旅游专题POI
     \details 检索旅游专题符合条件的POI列表。
     \param[in] pstSearchCondition 检索条件
     \param[out] ppTPOIList 旅游专题POI列表
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_NO_DATA	无相关数据
     \remarks
     \since 6.0
     \see
     **********************************************************************/	
    GDBL_API_CALL GSTATUS GDBL_SearchTPOI (
                                           GTSEARCHCONDITION *pSearchCondition,
                                           GTPOILIST **ppTPOIList
                                           );
    
    /**
     **********************************************************************
     \brief 检索旅游路线
     \details 检索符合条件的旅游路线。
     \param[in] pstSearchCondition 检索条件
     \param[out] ppTRouteList 旅游路线列表
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_NO_DATA	无相关数据
     \remarks
     \since 6.0
     \see
     **********************************************************************/	
    GDBL_API_CALL GSTATUS GDBL_SearchTRoute (
                                             GTSEARCHCONDITION *pSearchCondition,
                                             GTROUTELIST **ppTRouteList
                                             );
    
    /**
     **********************************************************************
     \brief 设置旅游专题数据路径
     \details 设置旅游专题数据路径，并指定图片资源类型。
     \param[in] pzTDataPath 旅游专题数据路径
     \param[in] euTResID 图片资源类型
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_INVALID_PARAM	参数无效
     \retval	GD_ERR_FAILED	操作失败
     \remarks
     1.同一份旅游专题数据包中，可能包含多套图片资源。
     2.euTResID对应不同的分辨率。
     3.如果pzTDataPath为空，则关闭该功能，即引擎不再跟原有的数据有关联。
     4.系统会在该路径的基础上再追加tourdata目录。即该路径应该为
     tourdata目录的上一级路径
     \since 6.0
     \see
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_SetTDataPath (
                                             Gchar *szTDataPath,
                                             GTRES eTResID
                                             );
    
    /* travel_api_group end */
    /** \} */
    
    /** \addtogroup bus_api_group
     \{ */
    
    /* 公交 */
    /**
     **********************************************************************
     \brief 网络公交检索
     \details 网络查询符合条件的公交乘车方案。
     \param[in] pstSearchCondition 查询的起点、终点以及乘车规则信息		
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_INVALID_PARAM	参数无效
     \remarks
     该接口用于从网络获取从起点到终点的公交乘车方案，HMI等待接受获取
     成功通知WM_BUS_NOTIFY，并通过GDBL_GetByBusScheme获取最终乘车方案
     \since 6.0
     \see GDBL_GetByBusScheme
     **********************************************************************/	
    GDBL_API_CALL GSTATUS GDBL_ByBusRequestNet (
                                                GBYBUSCONDITION *pCondition
                                                );
    
    /**
     **********************************************************************
     \brief 获取乘车方案结果
     \details 获取网络的公交乘车方案。
     \param[out]	ppstScheme 乘车方案
     \param[out]	punNumberOfSchemes 乘车方案个数
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_INVALID_PARAM	参数无效
     \retval	GD_ERR_NO_DATA	无相关数据
     \remarks
     该接口用于从网络获取从起点到终点的公交乘车方案，HMI等待接受获取
     成功通知WM_BUS_NOTIFY，并通过GDBL_GetByBusScheme获取最终乘车方案
     \since 6.0
     \see GDBL_ByBusRequestNet
     **********************************************************************/	
    GDBL_API_CALL GSTATUS GDBL_GetByBusScheme (
                                               GBYBUSSCHEME **ppScheme,
                                               Guint32 *pNumberOfSchemes
                                               );
    
    /**
     **********************************************************************
     \brief 查看公交乘车方案
     \details 查看公交乘车方案并绘制。
     \param[in]	nID 乘车方案ID，来源于结构体GBYBUSSCHEME的nID字段
     \param[in]	bShow 显示标识
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_FAILED	操作失败
     \remarks
     \since 6.0
     \see
     **********************************************************************/	
    GDBL_API_CALL GSTATUS GDBL_ViewByBusScheme (
                                                Guint32 nID,
                                                Gbool bShow
                                                );
    
    /**
     **********************************************************************
     \brief 全程概览公交乘车方案
     \details 全程概览指定ID的公交乘车方案。
     \param[in]	nID 乘车方案ID，来源于结构体GBYBUSSCHEME的nID字段
     \param[in]	pstRect 视图矩形框
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_NO_DATA	无相关数据
     \remarks
     1、	该接口传入的公交方案索引为获取索引值。
     2、 公交方案全程概览图面宽度不大于主地图宽度
     3、 公交方案全程概览图面高度不大于主地图高度
     \since 6.0
     \see
     **********************************************************************/	
    GDBL_API_CALL GSTATUS GDBL_ByBusSchemeOverview (
                                                    Guint32 nID,
                                                    GRECT *pstRect
                                                    );
    
    /**
     **********************************************************************
     \brief 查看指定公交站点
     \details 查看指定站点信息的公交站点。
     \param[in]	pstBusStation 站点信息
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_INVALID_PARAM	参数无效
     \remarks
     1、	该接口传入的坐标为屏幕坐标。
     2、	查询距离该点一定范围内的公交路线上的站点。
     3、	如果找到站点，则在地图上显示名称。
     4、	如果该点已经显示，则关闭显示。
     5、	一次最多只显示一个。
     6、	只有在地图查看公交路线时，才有效。
     \since 6.0
     \see
     **********************************************************************/	
    GDBL_API_CALL GSTATUS GDBL_ViewBusStation (
                                               GBUSSTATION *pBusStation
                                               );
    
    /**
     **********************************************************************
     \brief 查看指定公交站点
     \details 查看指定屏幕坐标的公交站点。
     \param[in]	stCoord 屏幕坐标
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_INVALID_PARAM	参数无效
     \retval	GD_ERR_FAILED	操作失败
     \remarks
     1、	该接口传入的坐标为屏幕坐标。
     2、	查询距离该点一定范围内的公交路线上的站点。
     3、	如果找到站点，则在地图上显示名称。
     4、	如果该点已经显示，则关闭显示。
     5、	一次最多只显示一个。
     6、	只有在地图查看公交路线时，才有效。
     \since 6.0
     \see
     **********************************************************************/	
    GDBL_API_CALL GSTATUS GDBL_ViewNearBusStation (
                                                   GCOORD* pstCoord
                                                   );
    
    /* bus_api_group end */
    /** \} */
    
    /** \addtogroup safe_api_group
     \{ */
    
    /**
     **********************************************************************
     \brief 设置获取安全驾驶信息回调函数
     \details 该函数用于设置获取安全驾驶信息回调函数
     \param[in]	pSafeInfoCB 获取安全驾驶信息回调函数
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_INVALID_PARAM 参数无效
     \remarks
     \since 7.0
     \see 
     **********************************************************************/	
    GDBL_API_CALL GSTATUS GDBL_SetSafeInfoCallback(PSAFEINFOCALLBACK pSafeInfoCB);
    
    /* safe_api_group end */
    /** \} */
    
    /** \addtogroup usafe_api_group
     \{ */
    
    /*=================== USA 用户安全驾驶 Start =================*/
    /**
     **********************************************************************
     \brief 添加用户电子眼
     \details 该函数用于添加用户电子眼信息。
     \param[in]  pSafeInfo 结构体GUSERSAFEINFO指针，用于标识待添加的用户电子眼
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_FAILED 操作失败
     \retval	GD_ERR_INVALID_PARAM 参数无效
     \retval GD_ERR_DUPLICATE_DATA 重复数据
     \remarks
     在添加用户电子眼时，nIndex字段忽略
     \since 6.0
     \see GDBL_SetUserSafePath
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_AddUserSafeInfo(
                                               GUSERSAFEINFO  *pUserSafeInfo
                                               );
    
    /**
     **********************************************************************
     \brief 删除用户电子眼
     \details 该函数用于根据索引删除一定个数的已添加用户电子眼。
     \param[in]  pIndex 待删除用户电子眼索引数组，用户电子眼索引由结构体GUSERSAFEINFO成员nIndex获得
     \param[in]  nNumberOfIndex 待删除用户电子眼索引数组成员个数
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_FAILED 操作失败
     \retval	GD_ERR_INVALID_PARAM 参数无效
     \remarks
     1、如果正在显示用户电子眼列表，当从列表删除用户电子眼后，需刷新列表。
     2、只要成功删除一条，该接口均返回GD_ERR_OK。
     \since 6.0
     \see GDBL_AddUserSafeInfo
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_DelUserSafeInfo(
                                               Gint32  *pIndex,
                                               Gint32  nNumberOfIndex
                                               );
    
    /**
     **********************************************************************
     \brief 编辑用户电子眼
     \details 该函数用于编辑一个已添加的用户电子眼。
     \param[in]  pSafeInfo 结构体GUSERSAFEINFO指针，用于标识已编辑的用户电子眼
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_INVALID_PARAM 参数无效
     \retval	GD_ERR_FAILED 操作失败
     \remarks
     - 对于用户电子眼的编辑，nIndex字段必须不能编辑，该值只用作内部处理。Date和Time字段无需编辑，
     系统内部根据当前时间自动填充。该操作会影响该兴趣点的排列顺序。
     \since 6.0
     \see GDBL_AddUserSafeInfo
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_EditUserSafeInfo(
                                                GUSERSAFEINFO *pUserSafeInfo
                                                );
    
    /**
     **********************************************************************
     \brief 获取用户电子眼
     \details 该函数用于获取指定类别用户电子眼信息。
     \param[in]  eCategory 用户电子眼GSAFECATEGOTY类别，用于标识要获取的用户电子眼类别
     \param[out]  ppSafeInfoList 结构体GUSERSAFEINFOLIST指针的指针，用于返回用户电子眼列表
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_INVALID_PARAM 参数无效
     \retval	GD_ERR_NO_DATA 无相关数据
     \retval	GD_ERR_NO_MEMORY 内存不足
     \retval	GD_ERR_FAILED 操作失败
     \remarks
     \since 6.0
     \see GDBL_AddUserSafeInfo GDBL_ClearUserSafeInfo GDBL_DelUserSafeInfo GDBL_EditUserSafeInfo
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_GetUserSafeInfoList(
                                                   GSAFECATEGORY	eSafeCategory,
                                                   GUSERSAFEINFOLIST  **ppUserSafeInfoList
                                                   );
    
    /**
     **********************************************************************
     \brief 清空用户电子眼
     \details 该函数用于清空指定类别的用户电子眼。
     \param[in]  eCategory 用户电子眼GSAFECATEGOTY类别，用于标识要清空的用户电子眼类别
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_INVALID_PARAM 参数无效
     \retval	GD_ERR_FAILED 操作失败
     \remarks
     \since 6.0
     \see GDBL_AddUserSafeInfo GDBL_GetUserSafeInfoList
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_ClearUserSafeInfo(
                                                 GSAFECATEGORY	eSafeCategory
                                                 );
    
    /**
     **********************************************************************
     \brief 设置用户电子眼数据路径
     \details 该函数用于设置用户电子眼数据路径。
     \param[in]  szUserSafePath 用户电子眼数据完整路径
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_INVALID_PARAM 参数无效
     \retval	GD_ERR_FAILED 操作失败
     \remarks
     \since 6.0
     \see GDBL_GetUserSafeInfoList
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_SetUserSafePath (
                                                Gchar *szUserSafePath
                                                );
    
    /**
     **********************************************************************
     \brief 保存数据到文件里
     \details 更新用户安全驾驶内存修改到文件。
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_FAILED 操作失败
     \remarks
     \since 6.0
     \see GDBL_GetUserSafeInfoList, GDMID_AddUserSafeInfo, GDMID_DelUserSafeInfo
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_FlushFileUserSafe(void);
    
    /**
     **********************************************************************
     \brief 根据详细的安全驾驶信息删除自定义安全驾驶信息
     \details 该函数用于根据详细的安全驾驶信息删除自定义安全驾驶信息
     \param[in]  pstUSAInfo 安全驾驶信息
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_INVALID_PARAM 参数无效
     \retval	GD_ERR_FAILED 操作失败
     \remarks
     \since 6.0
     \see 
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_DelUserSafeInfoByDetail(GUSERSAFEINFO *pstSafeInfo);
    
    /**
     **********************************************************************
     \brief 设置获取自定义安全驾驶信息回调函数
     \details 该函数用于设置获取自定义安全驾驶信息回调函数
     \param[in]	pUserSafeInfoCB 获取自定义安全驾驶信息回调函数
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_INVALID_PARAM 参数无效
     \remarks
     \since 7.0
     \see 
     **********************************************************************/	
    GDBL_API_CALL GSTATUS GDBL_SetUserSafeInfoCallback(PUSERSAFEINFOCALLBACK pUserSafeInfoCB);
    
    /* usafe_api_group end */
    /** \} */
    
    /** \addtogroup ugc_api_group
     \{ */
    
    /*=================== USA 用户安全驾驶 End =================*/
    
    /* 用户图层 */
    /**
     **********************************************************************
     \brief 添加用户图层点
     \details 添加用户图层点并存储。
     \param[in] pUPOI 用户图层点		
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_INVALID_PARAM	参数无效
     \retval	GD_ERR_FAILED	操作失败
     \remarks
     \since 6.0
     \see
     **********************************************************************/	
    GDBL_API_CALL GSTATUS GDBL_AddUPOI(
                                       GUPOI *pUPOI
                                       );
    
    /**
     **********************************************************************
     \brief 删除用户图层点
     \details 删除一定个数的已添加用户图层点；
     \param[in] pnIndex 待删除数据索引数组
     \param[in] nNumberOfIndex 待删除数据索引数组成员个数
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_INVALID_PARAM	参数无效
     \retval	GD_ERR_FAILED	操作失败
     \remarks
     1、如果正在显示用户图层，当从列表删除用户图层点后，需刷新列表。
     2、只要成功删除一条，该接口均返回GD_ERR_OK
     \since 6.0
     \see
     **********************************************************************/	
    GDBL_API_CALL GSTATUS GDBL_DelUPOI(
                                       Gint32 *pIndex,
                                       Gint32 nNumberOfIndex
                                       );
    
    /**
     **********************************************************************
     \brief 编辑用户图层点
     \details 编辑一个已添加的用户图层点。
     \param[in] pstUPOI 用户图层点
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_INVALID_PARAM	参数无效
     \remarks
     对于用户图层点的编辑，nIndex字段必须不能编辑，该值只用作内
     部处理。nTimestamp字段无需编辑，系统内部根据当前时间自动填充
     \since 6.0
     \see
     **********************************************************************/	
    GDBL_API_CALL GSTATUS GDBL_EditUPOI(
                                        GUPOI *pUPOI
                                        );
    
    /**
     **********************************************************************
     \brief 清空用户图层数据
     \details 清空已添加的用户图层数据。
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_FAILED	操作失败
     \remarks
     \since 6.0
     \see
     **********************************************************************/	
    GDBL_API_CALL GSTATUS GDBL_ClearUPOI(void);
    
    /**
     **********************************************************************
     \brief 检索用户图层
     \details 检索指定条件的用户图层。
     \param[in] pstSearchCondition 检索条件
     \param[out] ppstUPOIList 用户图层列表
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_INVALID_PARAM	参数无效
     \retval	GD_ERR_NO_DATA	无相关数据
     \remarks
     检索条件pSearchCondition为null，则表示获取所有用户图层数据
     \since 6.0
     \see
     **********************************************************************/	
    GDBL_API_CALL GSTATUS GDBL_SearchUPOI(
                                          GUSEARCHCONDITION *pSearchCondition,
                                          GUPOILIST **ppUPOIList
                                          );
    
    /**
     **********************************************************************
     \brief 获取用户图层行政区域列表
     \details 获取用户图层行政区域列表及其子列信息。
     \param[out] ppstAdareaList 行政区域列表
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_NO_MEMORY	内存不足
     \retval	GD_ERR_NO_DATA	无相关数据
     \remarks
     \since 6.0
     \see
     **********************************************************************/	
    GDBL_API_CALL GSTATUS GDBL_GetUPOIAdareaList(
                                                 GADAREALIST **ppAdareaList
                                                 );
    
    /**
     **********************************************************************
     \brief 数据同步
     \details 将本地用户图层数据和网络后台同步。
     \param[in] bUpdate 是否强制同步
     \retval	GD_ERR_OK 成功
     \remarks
     \since 6.0
     \see
     **********************************************************************/	
    GDBL_API_CALL GSTATUS GDBL_SyncUPOI(
                                        Gbool bUpdate
                                        );
    
    /* ugc_api_group end */
    /** \} */
    
    /** \addtogroup mcc_api_group
     \{ */
    
    /**
     **********************************************************************
     \brief 车厂定制内容检索
     \details 开始搜索指定条件的车厂定制内容。
     \param[in]  pstSearchCond 搜索关键字
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_INVALID_PARAM	参数无效
     \remarks
     \since 6.0
     \see 
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_StartSearchMccPOI(GSEARCHCONDITION* pstSearchCond);
    
    /**
     **********************************************************************
     \brief 设置数据路径
     \details 设置车厂定制内容的数据路径
     \param[in]  szMccPOIPath 数据路径
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_FAILED	操作失败
     \remarks
     \since 6.0
     \see 
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_SetMccDataPath(const Gchar* szMccPOIPath);
    
    /**
     **********************************************************************
     \brief 获取MCC检索结果
     \details 根据需要获取相应的POI个数。
     \param[in] pstInput 请求第一索引和需要的个数		
     \param[out] ppstResult返回得到的POI个数
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_INVALID_PARAM	参数无效
     \retval	GD_ERR_NO_MEMORY	内存不足
     \retval	GD_ERR_NO_DATA	无相关数据
     \remarks
     等待GDBL_StartSearchMccPOI成功后通知上层调用该函数
     \since 6.0
     \see GDBL_StartSearchPOI
     **********************************************************************/	
    GDBL_API_CALL GSTATUS GDBL_GetMccResult(const GETPOIINPUT *pstInput,GPOIRESULT **pstResult);
    
    /* mcc_api_group end */
    /** \} */
    
    /** \addtogroup diag_api_group
     \{ */
    
    /* diagnose */
    /**
     **********************************************************************
     \brief Dump当前屏幕
     \details 该函数用于dump当前屏幕内容。
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_FAILED	操作失败
     \remarks
     - Dump的图像以bmp文件格式保持在当前程序目录下的snapshot目录中，并以当前系统时间命名。
     \since 6.0
     \see 
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_SnapshotScreen(void);
    
    /**
     **********************************************************************
     \brief Dump串口NMEA数据
     \details 该函数用于dump串口NMEA数据到文件。
     \param[in]	bDump	是否dump
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_FAILED	操作失败
     \remarks
     - 1.Dump的数据保存在以nmea为扩展名，并以系统时间命名的文件中，文件保存在当前程序目录下的gps目录中。如20120329134530.nmea。
     - 2.Dump串口数据的同时，会同步dump引擎定位模块的相关信息，该信息同样保存在当前程序目录下的gps目录中，以当前系统时间命名，并以loc为扩展名。如20120329134530.loc。
     - 3.GPS信号回放中，GDBL_DumpNMEA接口不再起效。参见GPS信号回放。
     \since 6.0
     \see 
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_DumpNMEA(Gbool bDump);
    
    /**
     **********************************************************************
     \brief 显示原始GPS点位置。
     \details 该函数用于显示原始GPS点坐标位置。
     \param[in]	bShow	是否dump
     \retval	GD_ERR_OK 成功
     \remarks
     \since 6.0
     \see 
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_ShowOriginalGPS(Gbool bShow);
    
    /**
     **********************************************************************
     \brief 动GPS信号回放
     \details 该函数用于加载一条GPS信号进行回放。
     \param[in]	szFileName	GPS信号文件名
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_INVALID_PARAM	参数无效
     \remarks
     - 1.GPS信号文件中的内容直接为NMEA数据，参见GDBL_DumpNMEA生成的GPS信号文件。
     - 2.GPS信号回放结束系统发送消息通知HMI。
     - 3.停止GPS信号回放后，才将信号源切换到原来的。
     - 4.GPS信号回放中，GDBL_DumpNMEA接口不再起效。
     \since 6.0
     \see 
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_StartGPSReplay (
                                               Gchar *szFileName
                                               );
    
    /**
     **********************************************************************
     \brief 暂停GPS信号回放
     \details 该函数用于暂停GPS信号回放。
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_INVALID_PARAM	参数无效
     \retval	GD_ERR_NO_START	        没有进行前序操作
     \remarks
     \since 6.0
     \see 
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_PauseGPSReplay (void);
    
    /**
     **********************************************************************
     \brief 继续GPS信号回放
     \details 该函数用于继续GPS信号回放。
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_INVALID_PARAM	参数无效
     \retval	GD_ERR_NO_START	        没有进行前序操作
     \remarks
     \since 6.0
     \see 
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_ContinueGPSReplay (void);
    
    /**
     **********************************************************************
     \brief 结束GPS回放。
     \details 该函数用于结束GPS回放。
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_INVALID_PARAM	参数无效
     \retval	GD_ERR_NO_START	        没有进行前序操作
     \remarks
     \since 6.0
     \see 
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_StopGPSReplay (void);
    
    /**
     **********************************************************************
     \brief 获取注册配置
     \details 该函数用于获取注册配置信息。
     \param[in/out]	pRegCfg		行政编码
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_INVALID_PARAM	参数无效
     \remarks
     \since 6.0
     \see 
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_GetRegisterConfig(GREGCONFIG *pRegCfg);
    
    /* diag_api_group end */
    /** \} */
    
    /** \addtogroup tmc_api_group
     \{ */
    
    /* 实时交通-BL层接口-TMC  START */
    /**
     /**********************************************************************
     \brief 由HMI层定义获取图片的回调
     \details 由HMI层定义获取图片的回调
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_NOT_SUPPORT 不支持该功能
     \remarks
     \since 6.2
     \see 
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_SetGetUserElementCB(GETELEMENT pfnGetElement);
    /**
     **********************************************************************
     \brief 设置定位位置精度
     \details 该函数用于绘制位置精度的圆圈
     \param[in]	clrSide: 边颜色
     \param[in]	clrFill: 内部颜色
     \param[in]	fRadius: 半径
     \param[in]	nCount: 范围圈个数
     \retval	GD_ERR_OK	成功
     \retval	GD_ERR_NOT_SUPPORT	不支持
     \since 6.1
     \see 
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_SetPositioningAccuracy(PGRGBA pclrSide, PGRGBA pclrFill, Gfloat32 fRadius, Gint32 nCount);
    
    /**
     **********************************************************************
     \brief 在图面上过滤TMC事件
     \details 该函数用于在图面上过滤TMC事件
     \param[in]	pEvent 事件ID指针
     \param[in]	nNumOfEvent 事件个数
     \param[in]	bOnRoute 是否只显示路径线上的事件
     \retval	GD_ERR_OK	        成功
     \retval	GD_ERR_NO_MEMORY	内存不足
     \retval	GD_ERR_NOT_SUPPORT	不支持该功能
     \remarks
     - 如果pEvent == GNULL 或者 nNumOfEvent <= 0 表示不过滤事件，全部显示
     - 如果 bOnRoute == TRUE并且指定事件ID则表示只显示路径上面的指定的ID, 
     - 如果bOnRoute == TRUE并且不指定ID则表示显示路径上的所有事件
     - 设置过滤，调用GDBL_GetEventInfo获取的事件为过滤的事件
     - 返回GD_ERR_NOT_SUPPORT 是无网络造成的
     \since 7.0
     \see 
     **********************************************************************/	
    GDBL_API_CALL GSTATUS GDBL_FilterTMCEvent(Gint32 *pEvent, Gint32 nNumOfEvent, Gbool bOnRoute);
    
    /**********************************************************************
     \brief 获取事件信息
     \details 该函数用于获取事件信息
     \param[out] pEventInfo        事件信息
     \param[out] nEventCount       事件个数
     \retval	GD_ERR_OK	成功
     \retval	GD_ERR_FAILED	失败
     \retval	GD_ERR_INVALID_PARAM	参数无效
     \retval	GD_ERR_NOT_SUPPORT	不支持该功能
     \remarks
     - 返回GD_ERR_NOT_SUPPORT 是无网络造成的
     \since 6.1
     \see 
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_GetEventInfo(GEVENTINFO **pEventInfo, Gint32 *nEventCount);
    
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
    GDBL_API_CALL GSTATUS GDBL_AddAvoidEventInfo(GEVENTINFO *pstEventInfo);
    
    /**
     **********************************************************************
     \brief 上传FCD信息 
     \details 该函数用于上传FCD信息 
     \param[out]	pstFCDInfo 要获取的FCD数据内存
     \retval	GD_ERR_OK 成功
     \retval	GD_ERR_INVALID_PARAM 参数无效
     \retval GD_ERR_NOT_SUPPORT 不支持该功能
     \remarks
     \since 7.0
     \see 
     **********************************************************************/	
    GDBL_API_CALL GSTATUS GDBL_GetFCDInfo(GFCDINFO *pstFCDInfo);
    
    /* 实时交通-BL层接口-TMC  END */
    
    /*********************************************************************/
    
    /* TFB 交通情报板 - S */
    /**
     **********************************************************************
     \brief 请求交通情报板列表信息
     \details 该函数用于请求交通情报板列表信息
     \param[in] nAdcode 行政编码
     \retval	GD_ERR_OK 成功
     \remarks
     \since 7.0
     \see 
     **********************************************************************/	
    GDBL_API_CALL GSTATUS GDBL_ReqTrafficBoardList(Gint32 nAdcode);
    
    /**
     **********************************************************************
     \brief 获取交通情报板列表
     \details 该函数用于获取交通情报板列表
     \param[out] ppstTrafficBoardList 情报板列表数据
     \retval	GD_ERR_OK 成功
     \remarks
     \since 7.0
     \see 
     **********************************************************************/	
    GDBL_API_CALL GSTATUS GDBL_GetTrafficBoardList(GTRAFFICBOARDLIST **ppstTrafficBoardList);
    
    /**
     **********************************************************************
     \brief 请求交通情报板列表的情报板数据
     \details 该函数用于请求交通情报板列表的情报板数据
     \param[in] nTrafficBoardID 情报板ID
     \retval	GD_ERR_OK 成功
     \remarks
     \since 7.0
     \see 
     **********************************************************************/	
    GDBL_API_CALL GSTATUS GDBL_ReqBoardStatusInfo(Gint32 nTrafficBoardID);
    
    /**
     **********************************************************************
     \brief 获取交通情报板列表的情报板数据
     \details 该函数用于获取交通情报板列表的情报板数据
     \param[out] ppstBoardStatusInfo 情报板数据
     \retval	GD_ERR_OK 成功
     \remarks
     \since 7.0
     \see 
     **********************************************************************/	
    GDBL_API_CALL GSTATUS GDBL_GetBoardStatusInfo(GBOARDSTATUSINFO **ppstBoardStatusInfo);
    
    /**
     **********************************************************************
     \brief 设置用户请求交通情报板图片的大小
     \details 该函数用于设置用户请求交通情报板图片的大小
     \param[in] pstBoardPictrueSize 要请求图片的大小
     \retval	GD_ERR_OK 成功
     \remarks
     \since 7.0
     \see 
     **********************************************************************/	
    GDBL_API_CALL GSTATUS GDBL_SetBoardPictrueSize(GSIZE *pstBoardPictrueSize);
    
    /* TFB 交通情报板 - S */
    
    /* 天气功能-S */
    
    /**********************************************************************
     \brief 获取天气概要信息请求
     \details 该函数用来获取天气概要信息请求
     \param [in]	pstWeatherSummaryReq	天气概要信息请求
     \retval GD_ERR_INVALID_PARAM  参数无效
     \retval GD_ERR_OUT_OF_RANGE  超出范围
     \retval GD_ERR_OK 操作成功
     \retval GD_ERR_FAILED 操作失败
     \remarks
     \since 6.0
     \see 
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_ReqWeatherInfoSummary(GWEATHERINFOSUMMARYREQ *pstWeatherSummaryReq);
    
    /**********************************************************************
     \brief 获取天气信息请求
     \details 该函数用来获取天气信息请求
     \param[in]	pstWeatherInfoReq	天气信息请求 
     \retval GD_ERR_OK 操作成功
     \retval GD_ERR_FAILED 操作失败
     \retval GD_ERR_INVALID_PARAM  参数无效
     \remarks
     \since 6.0
     \see 
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_ReqWeatherInfo(GWEATHERINFOREQ *pstWeatherInfoReq);
    
    /**********************************************************************
     \brief 获取天气概要信息
     \details 该函数用来获取天气概要信息 
     \param[out]	pstWTHSummaryResult	天气概要信息
     \retval GD_ERR_OK 操作成功
     \retval GD_ERR_FAILED 操作失败
     \retval GD_ERR_INVALID_PARAM  参数无效
     \retval GD_ERR_NO_MEMORY 内存不足
     \remarks
     \since 6.0
     \see 
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_GetWeatherSummaryResult(GWEATHERINFOSUMMARYRESULT **pstWTHSummaryResult);
    
    /**********************************************************************
     \brief 获取天气信息
     \details 该函数用来获取获取天气信息
     \param[out]	pstWeatherInfoResult	天气信息
     \retval GD_ERR_OK 操作成功
     \retval GD_ERR_FAILED 操作失败
     \retval GD_ERR_INVALID_PARAM  参数无效
     \remarks
     \since 6.0
     \see 
     **********************************************************************/
    GDBL_API_CALL GSTATUS GDBL_GetWeatherInfoResult(GWEATHERINFORESULT **pstWeatherInfoResult);
    /* 天气功能-E */
    
    
    /* 事件上报-BL层接口-TIR  END */
    
    /*********************************************************************/
    
    /* TFB 事件上报 - S */
    /**
     **********************************************************************
     
     /**
     **********************************************************************
     \brief 请求交通情事件上报信息
     \details 该函数用于请求交通情事件上报信息
     \param[in] pstReqEvent 请求结构
     \retval	GD_ERR_OK 成功
     \remarks
     \since 7.0
     \see 
     **********************************************************************/	
    GDBL_API_CALL GSTATUS GDBL_QueryTrafficEvent(GTIRGETTRAFFICEVENTREQ *pstReqEvent);
    
    /**
     **********************************************************************
     \brief 请求交通情事件上报信息
     \details 该函数用于请求交通情事件上报信息
     \param[in] pstTirUserTrafficUploadReq 上报信息结构体
     \retval	GD_ERR_OK 成功
     \remarks
     \since 7.0
     \see 
     **********************************************************************/	
    GDBL_API_CALL GSTATUS GDBL_UserTrafficUpload(GTIRUSERTRAFFICUPLOADREQ *pstTirUserTrafficUploadReq);
    
    /* 事件上报-E */
    
    /* tmc_api_group end */
    /** \} */
    
#ifdef __cplusplus
}
#endif

#endif 

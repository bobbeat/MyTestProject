/**
 * Version:
 * Author: wenyuan.xu
 * Purpose:网络相关接口
 * Date: 2013/08/13
 * Update: Create
 **/

#ifndef GPI_NETWORK_H__
#define GPI_NETWORK_H__

#include "gtypes.h"
#include "gpimacro.h"

#ifdef __cplusplus
extern "C"
{
#endif
    
    /**
     \defgroup gpi_data_structures_group GPI Data Structures
     \{
     */
    
#define 	TRANS_RESULT_FAIL							0 		/**< 下载失败 */
#define 	TRANS_RESULT_SUCCESS						1 		/**< 成功 */
#define 	TRANS_RESULT_STOP							2 		/**< 中途停止(用户中断) */
#define		TRANS_RESULT_TIMEOUT						5		/**< 总超时时间 */
    
    /** \} */
    
    /** \addtogroup platform_api_network_group
     \{ */
	
    /**
     **********************************************************************
     \brief 初始化
     \details 该函数用于程序初始化
     \retval	Gtrue 成功
     \retval	Gfalse 失败
     \remarks
     调用方式：同步（阻塞）
     基本功能必须实现
     \since 7.0
     \see
     **********************************************************************/
    GPI_API_CALL Gbool GPI_NetInit();
    
    /**
     **********************************************************************
     \brief 逆初始化
     \details 该函数用于程序退出前优先调用
     \retval	Gtrue 成功
     \retval	Gfalse 失败
     \remarks
     调用方式：同步（阻塞）
     基本功能必须实现
     \since 7.0
     \see
     **********************************************************************/
    GPI_API_CALL Gbool GPI_NetUnInit();
    
    /**
     **********************************************************************
     \brief 下载函数回调函数指针
     \details 该函数用于下载完成将通过该指针返回服务端下发的数据,
     并实时获取当前网络层的下载状态、下载进度
     \param[in]	pData 数据指针
     \param[in]	nDataLen 数据长度
     \param[in]	nStatus 结果状态码
     TRANS_RESULT_FAIL		0//出错
     TRANS_RESULT_SUCCESS	1//成功
     TRANS_RESULT_STOP		2//中途停止(用户中断)
     TRANS_RESULT_TIMEOUT	5//超时（总的超时）
     //以下状态码为可选（暂时没用）
     TRANS_PROCESS_TIMEOUT	10//超时(底层接口的超时，如send,recv等）
     TRANS_PROCESS_FAIL		11//出错（底层接口出错，如send,recv等）
     TRANS_PROCESS_CONNECT	12//连接服务器成功
     TRANS_PROCESS_SEND		13//发送请求数据成功
     TRANS_PROCESS_RECV		14//接收一个数据段成功(每recv一段数据就
     返回一次，实时获取下载进度）
     TRANS_PROCESS_FINISH	15//下载结束
     \param[in]	nTaskID 当前任务ID
     \param[in]	pstHeader 可选参数，HTTP头句柄
     \retval	GD_ERR_OK 成功
     \retval	异常返回 GSTATUS 对应出错码
     \remarks
     基本功能必须实现
     \since 7.0
     \see
     **********************************************************************/
    typedef	 void (*pGPINetRecvDataCallback)(
    Gint8* pData,
    Gint32 nDataLen,
    Gint32 nStatus,
    Guint32	nTaskID,
    void* pstHeader
    );
    
    /**
     **********************************************************************
     \brief 设置下载结果回调函数
     \details 该函数用于设置下载结果回调函数
     \param[in]	pCallbackFunc 函数指针，用于通知上层获取数据
     \remarks
     程序初始化时调用
     调用方式：同步（阻塞）
     基本功能必须实现
     \since 7.0
     \see
     **********************************************************************/
    GPI_API_CALL
    void GPI_NetSetResultCallback(pGPINetRecvDataCallback pCallbackFunc);
    
    /**
     **********************************************************************
     \brief 暂停TaskID对应的下载任务
     \details 该函数用于暂停TaskID对应的下载任务
     \param[in]	nTaskID 任务ID
     \param[in]	bSync 是否同步标识
     Gtrue:同步模式,等待TaskID对应的下载线程结束才返回
     Gfalse:异步模式，发送消息通知TaskID对应的下载线程后，立即返回
     \retval	Gtrue 成功
     \retval	Gfalse 失败
     \remarks
     调用方式：同步（阻塞）/异步（非阻塞）
     基本功能必须实现
     \since 7.0
     \see
     **********************************************************************/
    GPI_API_CALL Gbool GPI_NetStopRequest(Gint32 nTaskID, Gbool bSync);
    
    /**
     **********************************************************************
     \brief UDP下载(异步）
     \details 该函数用于UDP下载(异步）
     \param[in]	pszUrl 服务器端URL
     \param[in]	pszData 请求数据
     \param[in]	nLen 数据长度
     \param[in]	nTimeOut 获取数据超时时间，单位“秒”
     \param[in]	nTaskID 任务ID
     \retval	Gtrue 成功
     \retval	Gfalse 失败
     \remarks
     调用方式：异步（非阻塞）
     1:	启动UDP下载，该函数内创建一个独立的线程，用于下载数据，服务器返回的数据通过
     函数指针pGPINetRecvDataCallback回传
     2：部分项目中使用
     \since 7.0
     \see
     **********************************************************************/
    GPI_API_CALL Gbool GPI_NetUdpRequest(Gint8* pszUrl,
                                         Gint8* pszData,
                                         Gint32 nLen,
                                         Gint32 nTimeOut,
                                         Gint32 nTaskID);
    
    /**
     **********************************************************************
     \brief 从句柄pstHeader中读取HTTP头部信息 （同步）
     \details 该函数用于从句柄pstHeader中读取HTTP头部信息 （同步）
     \param[in]	pstHeader HTTP头句柄
     \param[in]	pszName 头域 (如："Accept-Encoding")
     \param[out]	pszValue 根据pszName读取指定头域内容(如:"gzip,deflate")
     \retval	Gtrue 成功
     \retval	Gfalse 失败
     \remarks
     调用方式：同步（阻塞）
     部分项目中使用
     \since 7.0
     \see
     **********************************************************************/
    GPI_API_CALL Gbool GPI_NetGetHttpHeaders(void* pstHeader,
                                             Gint8* pszName,
                                             Gint8* pszValue
                                             );
    
    /**
     **********************************************************************
     \brief 从句柄pstHeader中读取HTTP头部信息状态码字段
     \details 该函数用于从句柄pstHeader中读取HTTP头部信息状态码字段
     \param[in]	pstHeader HTTP头句柄
     \param[out]	pszDestInfo 状态码的描述信息（预留,缺省为NULL）
     \retval	0: 获取失败
     \retval	>0:服务端回传的状态码
     （如：200 OK
     401 Unauthorized
     403 Forbidden
     404 Not Found
     500 Internal Server Error
     501 Not Implemented
     502 Bad Gateway
     503 Service Unavailable
     504 Gateway Timeout）
     \remarks
     调用方式：同步（阻塞）
     部分项目中使用
     \since 7.0
     \see
     **********************************************************************/
    GPI_API_CALL Gint32 GPI_NetGetHttpHeaderStatusCode(void* pstHeader ,
                                                       Gint8* pszDestInfo);
    
    /**
     **********************************************************************
     \brief 最基本的 HTTP GET方式下载(异步）
     \details 该函数用于最基本的 HTTP GET方式下载(异步）
     \param[in]	pszUrl 服务器端地址(如:
     http://trafficinfo.tinfochina.com:80/trafficplat/logonservice?provider=hxmsx)
     \param[in]	nTimeout 超时时间,单位“秒”
     \param[in]	nTaskID 任务ID
     \param[in]	pstHeader （可选）“\r\n”为分割的HTTP头信息,针对部分服务器对HTTP头部有特殊要求,如：Content-Type: text/html;charset=UTF-8\r\n
     \param[in]	pExt1 unused 扩展指针1，预留
     \retval	Gtrue 成功
     \retval	Gfalse 失败
     \remarks
     调用方式：异步（非阻塞）
     1:	启动HTTP GET下载，该函数创建一个独立的线程，用于下载数据，服务器
     返回的数据通过函数指针pGPINetRecvDataCallback回传
     2：基本功能，涉及到HTTP协议的项目必须实现。
     \since 7.0
     \see
     **********************************************************************/
    GPI_API_CALL Gbool GPI_NetHttpRequestGET(Gint8* pszUrl,
                                             Gint32 nTimeout,
                                             Gint32 nTaskID,
                                             Gint8* pstHeader,
                                             void* pExt1);
    
    /**
     **********************************************************************
     \brief 最基本的 HTTP POST方式下载(异步）
     \details 该函数用于最基本的 HTTP POST方式下载(异步）
     \param[in]	pszUrl 服务器端地址
     \param[in]	pRequest 请求数据
     \param[in]	nReqLen 数据长度
     \param[in]	nTimeout 超时时间（单位“秒”）
     \param[in]	nTaskID 任务ID
     \param[in]	pstHeader （可选）“\r\n”为分割的HTTP头信息,针对部分服务器对HTTP头部有特殊要求,如：Content-Type: text/html;charset=UTF-8\r\n
     \param[in]	pExt1 unused 扩展指针1，预留
     \retval	Gtrue 成功
     \retval	Gfalse 失败
     \remarks
     调用方式：异步（非阻塞）
     1: 启动HTTP POST方式下载，该函数创建一个独立的线程，用于下载数据，服务器
     返回的数据通过函数指针 pGPINetRecvDataCallback 回传，并将param5返回。
     2：基本功能，涉及到HTTP协议的项目必须实现。
     \since 7.0
     \see 
     **********************************************************************/	
    GPI_API_CALL Gbool GPI_NetHttpRequestPOST(Gint8* pszUrl, 
                                              Gint8* pRequest, 
                                              Gint32 nReqLen, 
                                              Gint32 nTimeout, 
                                              Gint32 nTaskID, 
                                              Gint8* pstHeader, 	
                                              void* pExt1);
    
    /**
     **********************************************************************
     \brief 获取网络状态
     \details 该函数用于获取网络状态
     \retval	NET_STATUS_UNKNOWN		-1	网络状态未知
     \retval	NET_STATUS_UNAVAILABLE  0	网络不可用
     \retval	NET_STATUS_AVAILABLE	1	网络可用
     \retval	NET_STATUS_SLOW			2	网络可用：低速（EDGE,GPRS,CDMA2000等）
     \retval	NET_STATUS_FAST			3	网络可用：高速（LAN/WIFI/3G/4G等）
     \remarks
     调用方式：同步（阻塞）
     下载前调用
     \since 7.0
     \see 
     **********************************************************************/	
    GPI_API_CALL Gint32 GPI_NetGetDevStatus();
    
    
    /* below this line DO NOT add anything */
    /** \} */
    
    
#ifdef __cplusplus
}
#endif
#endif

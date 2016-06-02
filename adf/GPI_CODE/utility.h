/* ***************************************************
 * Copyright(c) Xiamen AutoNavi Company. Ltd.
 * All Rights Reserved.
 *
 * File: utility.h
 * Purpose:实用功能对外接口
 *
 * Author: zhicheng.chen
 *
 *
 * Version: 7.0
 * Date: 12-Jul-2013 18:00:06
 * Update: Create
 *
 *************************************************** */
#ifndef UTILITY_H__
#define UTILITY_H__


#ifdef __cplusplus
extern "C"
{
#endif
    
#include "gtypes.h"
#include "gpimacro.h"
    
    /** \addtogroup platform_api_utility_group
     \{ */
    
    /**
     **********************************************************************
     \brief 获取设备id
     \details 该函数用于获取设备的ID
     \param[out] pn8DeviceID		设备id缓冲区
     \remarks
     - PC上直接固定为12345678
     \since 6.0
     \see
     **********************************************************************/
    GPI_API_CALL void GPI_GetDeviceID(Gint8 *pn8DeviceID);
    
    /**
     **********************************************************************
     \brief 获取UUID
     \details 获取设备的唯一识别码
     \param[out] pn8UUID ID缓冲区
     \remarks
     - PC上直接固定为12345678
     \since 6.0
     \see
     **********************************************************************/
    GPI_API_CALL void GPI_GetUUID(Gint8 *pn8UUID);
    
    /**
     **********************************************************************
     \brief 获取SD卡ID
     \details 该函数用于获取SD卡的ID
     \param[out] pn8SDCardID	SD卡ID缓冲区
     \remarks
     - PC上直接固定为12345678
     \since 6.0
     \see
     **********************************************************************/
    GPI_API_CALL void GPI_GetSDCardID(Gint8 *pn8SDCardID);
    
    /**
     **********************************************************************
     \brief 设置窗口句柄
     \details 保存窗口句柄到全局变量中。
     \param[in] hWnd	 窗口句柄
     \remarks
     - BL层启动，调用此接口，保存窗口句柄
     \since 6.0
     \see
     **********************************************************************/
    GPI_API_CALL void GPI_SetWndHandle(Guint32 hWnd);
    
    /**
     **********************************************************************
     \brief 截屏
     \details 以bmp文件格式保存当前操作界面。
     \param[in] pzFileName 文件名
     \param[in] nWidth 横竖屏的宽度
     \param[in] nHeight 横竖屏的高度
     \retval	Gtrue	保存成功
     \retval	Gfalse	保存失败
     \remarks
     - 1.调用windows平台接口，实现截屏。
     - 2.文件以bmp格式保持在当前目录下的snapshot中，以当前系统时间命名。
     \since 6.0
     \see DIG_SnapshotScreen
     **********************************************************************/
    GPI_API_CALL Gbool GPI_SnapScreen(const Gchar *pzFileName);
    
    /**
     **********************************************************************
     \brief 获取server模块路径
     \details 调用平台相关接口获取运行程序的当前路径。
     \param[in] nSize 缓冲区大小
     \param[out] szAppPath 缓冲区
     \retval	szAppPath server模块路径
     \remarks
     - 调用windows平台接口，实现路径获取。
     \since 6.0
     \see DIG_SnapshotScreen DIG_DumpNMEA LOC_Create
     **********************************************************************/
    GPI_API_CALL Gchar* GPI_GetAppPath(Gchar* szAppPath, Gint32 nSize);
    
    /* below this line DO NOT add anything */
    /** \} */
    
#ifdef __cplusplus
}
#endif
#endif


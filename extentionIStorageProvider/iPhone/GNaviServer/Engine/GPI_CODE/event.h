/* ***************************************************
 * Copyright(c) Xiamen AutoNavi Company. Ltd.
 * All Rights Reserved.
 *
 * File: evnet.h
 * Purpose:事件对外接口
 *
 * Author: zhicheng.chen
 *
 *
 * Version: 7.0
 * Date: 12-Jul-2013 18:00:06
 * Update: Create
 *
 *************************************************** */
#ifndef EVENT_H_
#define EVENT_H_

#ifdef __cplusplus
extern "C"
{
#endif
#include "gtypes.h"
#include "gpimacro.h"
    
    /** \addtogroup platform_api_event_group
     \{ */
    
    /**
     *********************************************************************
     \brief 创建事件
     \details 该函数调用平台相关接口创建事件。
     \retval  事件句柄
     \remarks
     \since 7.0
     \see
     **********************************************************************/
    GPI_API_CALL void* GPI_CreateSemaphore();
    
    /**
     *********************************************************************
     \brief 删除事件
     \details 该函数调用平台相关接口删除事件。
     \param[in] hHandle 事件句柄
     \remarks
     \since 7.0
     \see
     **********************************************************************/
    GPI_API_CALL void GPI_DestroySemaphore(void* hHandle);
    
    /**
     *********************************************************************
     \brief 等待事件
     \details 该函数调用平台相关接口等待事件触发。
     \param[in]  *pHandles      事件句柄指针
     \param[in]  nNumOfHandles  事件个数
     \remarks 0 表示无限等待
     \since 7.0
     \see
     **********************************************************************/
    GPI_API_CALL Gbool GPI_WaitForSemaphore(void* hHandle, Gint32 nLimitMillis);
    
    /**
     *********************************************************************
     \brief 触发事件
     \details 该函数调用平台相关接口触发事件。
     \param[in]  hHandle      事件句柄指针
     \remarks
     \since 7.0
     \see
     **********************************************************************/
    GPI_API_CALL void GPI_TriggerSemaphore(void* hHandle);
    
    /**
     *********************************************************************
     \brief 事件重置
     \details 该函数调用平台相关接口设置事件为无效信号。
     \param[in]  hHandle      事件句柄指针
     \remarks
     \since 7.0
     \see
     **********************************************************************/
    GPI_API_CALL void GPI_ResetSemaphore(void* hHandle);
    
    /* below this line DO NOT add anything */
    /** \} */
    
#ifdef __cplusplus
}
#endif
#endif

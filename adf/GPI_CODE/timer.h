/* ***************************************************
 * Copyright(c) Xiamen AutoNavi Company. Ltd.
 * All Rights Reserved.
 *
 * File: timer.h
 * Purpose:定时器对外接口
 *
 * Author: zhicheng.chen
 *
 *
 * Version: 7.0
 * Date: 12-Jul-2013 18:00:06
 * Update: Create
 *
 *************************************************** */
#ifndef TIMER_H__
#define TIMER_H__

#ifdef __cplusplus
extern "C"
{
#endif
#include "gtypes.h"
#include "gpimacro.h"
    
    /**
     \defgroup gpi_data_structures_group GPI Data Structures
     \{
     */
    
    /* 定时器回调函数指针定义 */
    typedef void (*GTIMERPROC)(Guint32 uTickCount);
    
    /**
     * 定时器数据结构
     *
     */
    typedef struct tagGTIMERDATA
    {
        GTIMERPROC fptrTimerFunc;				/**< 定时器回调函数指针 */
    } GTIMERDATA;
    
    /** \} */
    
    /** \addtogroup platform_api_timer_group
     \{ */
    
    /**
     **********************************************************************
     \brief 设置创建定时器回调函数
     \details 设置创建定时器回调函数
     \param[in] pCB 回调函数
     \remarks
     \since 7.0
     \see
     **********************************************************************/
    GPI_API_CALL void GPI_SetCreateTimerCB(void *pCB);
    
    /**
     **********************************************************************
     \brief 设置销毁定时器回调函数
     \details 设置销毁定时器回调函数
     \param[in] pCB 回调函数
     \remarks
     \since 7.0
     \see
     **********************************************************************/
    GPI_API_CALL void GPI_SetDestroyTimerCB(void *pCB);
    
    /**
     **********************************************************************
     \brief 创建定时器
     \details 根据传入的时间间隔、定时器回调接口，创建新的定时器，返回定时器ID。
     \param[in] nElapse 时间间隔
     \param[in] fptrTimerFunc 定时器回调函数
     \retval	idEvent	定时器ID
     \remarks
     - 最多只能设定50个定时器
     \since 6.0
     \see TimerProc
     **********************************************************************/
    GPI_API_CALL Gint32 GPI_CreateTimer(Gint32 nElapse, GTIMERPROC fptrTimerFunc);
    
    /**
     **********************************************************************
     \brief 销毁定时器
     \details 根据定时器ID，销毁定时器。
     \param[in] idEvent 定时器ID
     \remarks 
     - idEvent为GPI_CreateTimer返回值。
     \since 6.0
     \see GPI_CreateTimer
     **********************************************************************/
    GPI_API_CALL void GPI_DestroyTimer(Gint32 idEvent);
    
    /* below this line DO NOT add anything */
    /** \} */
    
#ifdef __cplusplus
}
#endif
#endif

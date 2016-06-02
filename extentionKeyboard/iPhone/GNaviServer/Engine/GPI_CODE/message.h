/* ***************************************************
 * Copyright(c) Xiamen AutoNavi Company. Ltd.
 * All Rights Reserved.
 *
 * File: message.h
 * Purpose:消息对外接口
 *
 * Author: zhicheng.chen
 *
 *
 * Version: 7.0
 * Date: 12-Jul-2013 18:00:06
 * Update: Create
 *
 *************************************************** */
#ifndef MESSAGE_H__
#define MESSAGE_H__


#ifdef __cplusplus
extern "C"
{
#endif
    
#include "gtypes.h"
#include "gpimacro.h"
    
    /** \addtogroup platform_api_message_group
     \{ */
    
    /**
     *********************************************************************
     \brief 设置消息回调函数
     \details 该函数设置消息回调函数
     \param[in] pCB	回调函数
     \remarks
     \since 7.0
     \see
     **********************************************************************/
    GPI_API_CALL void GPI_SetMessageCB(void *pCB);
    
    /**
     *********************************************************************
     \brief 消息发送
     \details 该函数调用平台相关接口实现消息发送。
     \param[in] uMsg	消息ID
     \param[in] wp	 消息参数高位
     \param[in] lp	 消息参数低位
     \remarks
     \since 7.0
     \see
     **********************************************************************/
    GPI_API_CALL void GPI_PostMessage(Gint32 uMsg, void* wp, void* lp);
    
    /* below this line DO NOT add anything */
    /** \} */
    
#ifdef __cplusplus
}
#endif
#endif

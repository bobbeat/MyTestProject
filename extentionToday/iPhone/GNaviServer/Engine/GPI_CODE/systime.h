/* ***************************************************
 * Copyright(c) Xiamen AutoNavi Company. Ltd.
 * All Rights Reserved.
 *
 * File: systime.h
 * Purpose:时间对外接口
 *
 * Author: zhicheng.chen
 *
 *
 * Version: 7.0
 * Date: 12-Jul-2013 18:00:06
 * Update: Create
 *
 *************************************************** */

#ifndef SYSTIME_H__
#define SYSTIME_H__

#ifdef __cplusplus
extern "C"
{
#endif
#include "gtypes.h"
#include "gpimacro.h"
    
    /** \addtogroup platform_api_systime_group
     \{ */
    
    /**
     **********************************************************************
     \brief sleep指定毫秒数
     \details 传入参数，做延时用。
     \param[in] uMilliseconds 毫秒数
     \remarks
     - 调用windows平台接口，实现延时。
     \since 6.0
     \see
     **********************************************************************/
    GPI_API_CALL void GPI_Sleep(Guint32 uMilliseconds);
    
    /* below this line DO NOT add anything */
    /** \} */
    
#ifdef __cplusplus
}
#endif
#endif

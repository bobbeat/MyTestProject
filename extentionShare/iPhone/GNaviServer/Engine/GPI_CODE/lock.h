/* ***************************************************
 * Copyright(c) Xiamen AutoNavi Company. Ltd.
 * All Rights Reserved.
 *
 * File: lock.h
 * Purpose:锁对外接口
 *
 * Author: zhicheng.chen
 *
 *
 * Version: 7.0
 * Date: 12-Jul-2013 18:00:06
 * Update: Create
 *
 *************************************************** */

#ifndef LOCK_H__
#define LOCK_H__

#ifdef __cplusplus
extern "C"
{
#endif
#include "gtypes.h"
#include "gpimacro.h"
    
    /** \addtogroup platform_api_lock_group
     \{ */
    
    /**
     **********************************************************************
     \brief 创建锁
     \details 该函数用传入锁名称，调用锁类构造函数，创建新锁。
     \param[in]	pszName	锁名称
     \retval 返回锁类对象
     \remarks
     - 创建锁时，需要调用此接口进行创建。锁需要调用者进行保存。
     \since 7.0
     \see
     **********************************************************************/
    GPI_API_CALL void* GPI_CreateLock(void);
    
    /**
     **********************************************************************
     \brief 删除锁
     \details 该函数用于传入锁类对象，释放创建锁类对象时开辟的内存空间。
     \param[in]	lockObj	锁类型
     \remarks
     \since 7.0
     \see
     **********************************************************************/
    GPI_API_CALL void GPI_DestroyLock(void* pLock);
    
    /**
     **********************************************************************
     \brief 加锁
     \details 该函数用于加锁。
     \param[in]	lockObj	指向锁类的指针
     \remarks
     - 在需要加锁的地方调用此函数，需要跟GPI_UnLock配对使用。
     \since 7.0
     \see GPI_UnLock
     **********************************************************************/
    GPI_API_CALL void GPI_Lock(void* lockObj);
    
    /**
     **********************************************************************
     \brief 解锁
     \details 该函数用于解锁。
     \param[in]	lockObj	指向锁类的指针
     \remarks
     - 需要解锁的地方调用此函数，需要跟GPI_UnLock配对使用。
     \since 7.0
     \see GPI_Lock
     **********************************************************************/
    GPI_API_CALL void GPI_UnLock(void* lockObj);
    
    /* below this line DO NOT add anything */
    /** \} */
    
#ifdef __cplusplus
}
#endif
#endif

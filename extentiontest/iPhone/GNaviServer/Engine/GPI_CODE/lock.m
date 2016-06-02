//
//  lock.mm
//  AutoNavi
//
//  Created by gaozhimin on 13-10-14.
//
//


#include <pthread.h>
#include "lock.h"
#include <stdlib.h>
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
void* GPI_CreateLock()
{
	void * ret = GNULL;
	ret = (void *)malloc(sizeof(pthread_mutex_t));
	if(ret)
	{
		if(pthread_mutex_init((pthread_mutex_t *)ret, NULL) != 0)
		{
			GPI_DestroyLock(ret);
			ret = NULL;
		}
	}
	return ret;
}

/**
 **********************************************************************
 \brief 删除锁
 \details 该函数用于传入锁类对象，释放创建锁类对象时开辟的内存空间。
 \param[in]	lockObj	锁类型
 \remarks
 \since 7.0
 \see
 **********************************************************************/
void GPI_DestroyLock(void* pLock)
{
	pthread_mutex_t *mutex = (pthread_mutex_t *)pLock;
	if(mutex == NULL)
		return ;
	pthread_mutex_destroy((pthread_mutex_t *)mutex);
	free(mutex);
	mutex = NULL;
}

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
void GPI_Lock(void* lockObj)
{
	pthread_mutex_t *mutex = (pthread_mutex_t *)lockObj;
	if(!mutex)
		return;
    
	pthread_mutex_lock((pthread_mutex_t *)mutex);
}

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
void GPI_UnLock(void* lockObj)
{
	pthread_mutex_t *mutex = (pthread_mutex_t *)lockObj;
	if(!mutex)
		return ;
    
	pthread_mutex_unlock((pthread_mutex_t *)mutex);
}
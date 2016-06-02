//
//  thread.mm
//  AutoNavi
//
//  Created by gaozhimin on 13-10-14.
//
//

#include <pthread.h>
#include <semaphore.h>
#include "thread.h"
#include <stdlib.h>

typedef struct tagGDTHREADHANDLE
{
    pthread_t thread;
    sem_t sem;
}GDTHREADHANDLE;

static int thread_value = SEM_VALUE_MAX/2;

/**
 **********************************************************************
 \brief 创建线程
 \details 该函数利用对传入的线程执行函数地址及线程参数创建一个线程。
 \param[in] szThreadName		线程名称
 \retval 线程句柄
 \remarks
 \since 7.0
 \see
 **********************************************************************/
void* GPI_CreateThread(THREADPROCFUNC threadProcFunc, void *pParam)
{
    GDTHREADHANDLE *handle = (GDTHREADHANDLE*)malloc(sizeof(GDTHREADHANDLE));
    if (threadProcFunc)
    {
        NSLog(@"threadProcFunc");
    }
    else
    {
        return 0;
    }
    if(pthread_create(&(handle->thread), NULL, threadProcFunc, pParam))
    {
        return 0;
    }
    NSArray *array = [NSHomeDirectory() componentsSeparatedByString:@"-"];
    NSString *name = @"";
    if ([array count] > 0)
    {
        name = [array lastObject];
    }
    const char *inName = [[NSString stringWithFormat:@"2%d%@",thread_value++,name] UTF8String];
    sem_t *lpSem = sem_open( inName, O_CREAT, 0644, 0);
    if( lpSem == SEM_FAILED )
    {
		return 0;
    }
    
    return (void*)handle;
}

/**
 **********************************************************************
 \brief 退出线程
 \details 该函数根据传入的线程句柄退出相应的线程。
 \param[in] hThread	线程句柄
 \remarks
 \since 7.0
 \see
 **********************************************************************/
void GPI_DestroyThread(void* hThread)
{
    
    if(!hThread)
        return;
    GDTHREADHANDLE *handle = (GDTHREADHANDLE*)hThread;
    if(sem_destroy (&(handle->sem)))
        return;
	void *ret;
    pthread_join(handle->thread,&ret);
    
    handle->thread = 0;
    free((void*)hThread);
    hThread = 0;
    
   
    return;
}

/**
 **********************************************************************
 \brief 挂起线程
 \details 该函数用于挂起传入的线程句柄的相应线程。
 \param[in] szThreadName		线程名称
 \remarks
 \since 7.0
 \see
 **********************************************************************/
void GPI_SuspendThread(void* hThread)
{
    if(!hThread)
        return;
    GDTHREADHANDLE *handle = (GDTHREADHANDLE*)hThread;
    
    if(sem_wait (&(handle->sem)))
        return;
    return;
}

/**
 **********************************************************************
 \brief 恢复线程
 \details 该函数用于恢复执行传入的线程句柄的相应线程。
 \param[in] szThreadName		线程名称
 \remarks
 \since 7.0
 \see
 **********************************************************************/
void GPI_ResumeThread(void* hThread)
{
    if(!hThread)
        return;
    GDTHREADHANDLE *handle = (GDTHREADHANDLE*)hThread;
    if(sem_post (&(handle->sem)))
        return;
    return;
}

/**
 **********************************************************************
 \brief 设置线程优先级
 \details 该函数用于设置传入的线程句柄的相应线程的优先级。
 \param[in] hThread		线程句柄
 \param[in] euPriority	线程优先级
 \remarks
 \since 7.0
 \see
 **********************************************************************/
void GPI_SetThreadPriority(void* hThread, enumTHREADPRIORITY euPriority)
{
    if(!hThread)
        return;
    GDTHREADHANDLE *handle = (GDTHREADHANDLE*)hThread;
    
    Gint32 nPriorityValue = 0;
    Gbool bFlag = Gtrue;		/*  «∑Ò”––ß”≈œ»º∂ */
	switch (euPriority)
	{
        case eTHREAD_PRIORITY_NORMAL:
        {
            nPriorityValue = 0;
        }
            break;
        case eTHREAD_PRIORITY_ABOVE_NORMAL:
        {
            nPriorityValue = 1;
        }
            break;
        case eTHREAD_PRIORITY_HIGHEST:
        {
            nPriorityValue = 2;
        }
            break;
        case eTHREAD_PRIORITY_BELOW_NORMAL:
        {
            nPriorityValue = -1;
        }
            break;
        case eTHREAD_PRIORITY_LOWEST:
        {
            nPriorityValue = -2;
        }
            break;
        default:
        {/* ∆‰À˚ */
            bFlag = Gfalse;
        }
            break;
	}
	if (bFlag == Gtrue)
	{
        struct sched_param sched = {0};
        int threadType = SCHED_OTHER;
        pthread_getschedparam(handle->thread,&threadType,&sched);
        
        sched.sched_priority = nPriorityValue;
        pthread_setschedparam( handle->thread,threadType,&sched );
	}
    
   
}


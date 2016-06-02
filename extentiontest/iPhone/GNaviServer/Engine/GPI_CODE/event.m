//
//  event.m
//  AutoNavi
//
//  Created by gaozhimin on 13-10-14.
//
//

#import "event.h"

#include <semaphore.h>
#include "event.h"
#include <stdio.h>
#include <stdlib.h>

static int event_value = 1;
/**
 *********************************************************************
 \brief 创建事件
 \details 该函数调用平台相关接口创建事件。
 \retval  事件句柄
 \remarks
 \since 7.0
 \see
 **********************************************************************/
void* GPI_CreateSemaphore()
{
	sem_t* lpSem = NULL;
    
    NSArray *array = [NSHomeDirectory() componentsSeparatedByString:@"-"];
    NSString *name = @"";
    if ([array count] > 0)
    {
        name = [array lastObject];
    }
    const char *inName = [[NSString stringWithFormat:@"1%d%@",event_value++,name] UTF8String];
    lpSem = sem_open( inName, O_CREAT, 0644, 0);
    //
    if( lpSem == SEM_FAILED )
    {
		return 0;
    }

	return (void*)lpSem;
}

/**
 *********************************************************************
 \brief 删除事件
 \details 该函数调用平台相关接口删除事件。
 \param[in] hHandle 事件句柄
 \remarks
 \since 7.0
 \see
 **********************************************************************/
void GPI_DestroySemaphore(void* hHandle)
{
	bool ret = false;
	sem_t* lpSem = (sem_t*)hHandle;
	if(lpSem==NULL)
		return ;
	ret = (sem_destroy((sem_t*)lpSem)==0);
	lpSem = NULL;
}

/**
 *********************************************************************
 \brief 等待事件
 \details 该函数调用平台相关接口等待事件触发。
 \param[in]  *pHandles      事件句柄指针
 \param[in]  nNumOfHandles  事件个数
 \remarks
 \since 7.0
 \see
 **********************************************************************/
Gbool GPI_WaitForSemaphore(void* hHandle, Gint32 nLimitMillis)
{
	Gbool bRet = Gfalse;
	sem_t* lpSem = (sem_t*)hHandle;
	if(lpSem==NULL)
		return Gfalse;
	bRet = (Gbool)(sem_wait((sem_t*)lpSem)==0);
	return bRet;
}

/**
 *********************************************************************
 \brief 触发事件
 \details 该函数调用平台相关接口触发事件。
 \param[in]  hHandle      事件句柄指针
 \remarks
 \since 7.0
 \see
 **********************************************************************/
void GPI_TriggerSemaphore(void* hHandle)
{
	sem_t* lpSem = (sem_t*)hHandle;
	if(lpSem==NULL)
		return ;
	sem_post((sem_t*)lpSem);
}

/**
 *********************************************************************
 \brief 事件重置
 \details 该函数调用平台相关接口设置事件为无效信号。
 \param[in]  hHandle      事件句柄指针
 \remarks
 \since 7.0
 \see
 **********************************************************************/
void GPI_ResetSemaphore(void* hHandle)
{
    
}
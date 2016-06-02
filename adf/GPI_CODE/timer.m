//
//  timer.mm
//  AutoNavi
//
//  Created by gaozhimin on 13-10-14.
//
//
#include "timer.h"
#include <stdio.h>
#include <signal.h>
#include <time.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>

extern int	gettimeofday(struct timeval * __restrict, void * __restrict);

@interface GPI_TIMER : NSObject
{
    GTIMERPROC _fptrTimerFunc;
    NSTimer *_timer;
}

- (void)createTimerWithInterval:(NSTimeInterval)ti func:(GTIMERPROC)func;
- (void)destroyTimer;


- (void)timerMethod:(NSTimer *)timer;

@end

@implementation GPI_TIMER

- (id)init
{
    self = [super init];
    if (self)
    {
        _fptrTimerFunc = NULL;
    }
    return self;
}

- (void)dealloc
{
    if (_timer)
    {
        [_timer invalidate];
        _timer = nil;
    }
    [super dealloc];
}

- (void)createTimerWithInterval:(NSTimeInterval)ti func:(GTIMERPROC)func;
{
    _fptrTimerFunc = func;
    _timer = [NSTimer scheduledTimerWithTimeInterval:ti target:self selector:@selector(timerMethod:) userInfo:nil repeats:YES];

}

- (void)DlayCreateTimer:(NSNumber *)ti
{
    
   }

- (void)destroyTimer
{
    if (_timer)
    {
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)timerMethod:(NSTimer *)timer
{
//    if (UIApplicationStateBackground == [[UIApplication sharedApplication] applicationState] || UIApplicationStateInactive == [[UIApplication sharedApplication] applicationState]) {
//        return;
//    }
    if (_fptrTimerFunc)
    {
        Guint64 t;
        struct timeval tv_begin;
        gettimeofday(&tv_begin, NULL);
        t = (Guint64)1000000 * (tv_begin.tv_sec) + tv_begin.tv_usec;
        Guint32 uTickCount = (Guint32)(t / 1000);
        _fptrTimerFunc(uTickCount);
    }
}


@end

#define MAX_TIMER 50
static NSMutableDictionary *g_TimerDic = nil;
static int  m_TimerCount = 0;

void GPI_SetCreateTimerCB(void *pCB)
{
	
}
void GPI_SetDestroyTimerCB(void *pCB)
{
	
}


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
Gint32 GPI_CreateTimer(Gint32 nElapse, GTIMERPROC fptrTimerFunc)
{
//    NSLog(@"GPI_CreateTimer");
    if (!g_TimerDic)
    {
        g_TimerDic = [[NSMutableDictionary alloc] init];
    }
	if(m_TimerCount>=MAX_TIMER)
	{
		return 0;
	}
	int i=0;
	for( i=0;i<MAX_TIMER;i++)
	{
		if(![g_TimerDic objectForKey:[NSString stringWithFormat:@"%d",i]])
		{
			break;
		}
	}
    
    GPI_TIMER *timer = [[GPI_TIMER alloc] init];
    [timer createTimerWithInterval:(float)nElapse/1000.0 func:fptrTimerFunc];
    [g_TimerDic setObject:timer forKey:[NSString stringWithFormat:@"%d",i]];
    [timer release];
	m_TimerCount++;
    
    NSLog(@"GPI_CreateTimer %d",i+1);
    return i+1;
}

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
void GPI_DestroyTimer(Gint32 idEvent)
{
    NSLog(@"GPI_DestroyTimer %d",idEvent);
    GPI_TIMER *timer = [g_TimerDic objectForKey:[NSString stringWithFormat:@"%d",idEvent-1]];
    if(g_TimerDic && timer)
    {
		[timer destroyTimer];
        [g_TimerDic removeObjectForKey:[NSString stringWithFormat:@"%d",idEvent-1]];
		m_TimerCount--;
    }
}

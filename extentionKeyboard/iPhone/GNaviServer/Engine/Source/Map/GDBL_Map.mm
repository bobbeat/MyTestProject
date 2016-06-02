//
//  GDBL_Map.m
//  GNaviServer_iPhone
//
//  Created by yang yi on 12-2-22.
//  Copyright 2012 autonavi.com. All rights reserved.
//

/********************************************************************
 功能描述: 实现地图视图显示、操作功能GDBL对外接口
 
 修改历史:
 日  期    作  者  说明
 2011/12/02	陈其义	创建
 *********************************************************************/
#import "GDBL_Interface.h"
#import <stdlib.h>
#import "GDBL_Map.h"
#import "GDBL_typedefEx.h"
#import "GDBL_InterfaceEx.h"

#define RECOGNIZE_MODE 0
#define ANTI_SLIDE_VELOCITY 700
#define MAP_FLINGTIMEOUT	30		//地图滑动的时间间隔

/***********定时器变量*************/
Gint32 g_timerFling = 0;        //甩动地图定时器
/***********定时器变量*************/

Gint32 g_iDemoFlag = 0;


RECOGNIZETYPE	g_nRecognizeType= EVENT_NONE;
Gint32	g_fling_velocity_x;					//甩动X轴速度
Gint32	g_fling_velocity_y;					//甩动Y轴速度

Gint32	g_nAdjustRet;						//每次调节仰角返回值

Gfloat64	g_rotate_angle = 0.0f;				//每次旋转的角度值
Gint32	g_nRotateVelocity= 0;				//旋转的速度

Gbool	g_bRotateFlag = Gfalse;
Gbool	g_bRotateBoundFlag =Gfalse;

//
Gint32 g_nZoomCount = 0;					//地图缩放计数器
Gint32 g_nZoomFlag;							//地图缩放标志(0放大，1缩小)
Gint32 g_nMoveCount = 0;					//移图计数器
Gint32 g_nModeCount = 0;					//地图模式切换计数器
Gint32 g_nMapScaleLevel = 0;				//保存获取到的地图比例尺
Gint32 g_nMapMode = 0;						//保存获取到的地图模式
Gint32 g_nChangeFlag = 0;					//模拟导航是否被暂停标志(主要是用于控制查看POI时是否要暂停模拟导航)
Gint32 g_nPreviewFlag = 0;					//模拟导航是否被强制暂停标志(主要用于在全程概览时是否暂停模拟导航)
//Gint32 g_nCurScaleLevel = 0;				//地图当前比例尺
Gint32 g_nZoomToValue = 0;					//缩放至指定比例尺与当前地图比例尺之间的差值
Gint32 g_nZoomTo = 0;						//g_nZoomToValue与插入帧数的商值
Gint32 g_nZoomLevel = 0;					//缩放至指定的比例尺值
Gint32 g_nViewPoi = 0;						//是否查看POI的标志
Gint32 g_nZoomToFlag = 0;					//是否正在进行缩放至指定比例尺
Gbool g_bZoomFlag = Gfalse;					//是否正在缩放地图
Gbool g_bMulPreView = Gfalse;				//地图是否进入多路径全程概览
Gbool g_bDemoFlag = Gfalse;					//标记地图是否处于模拟导航或导航状态
//extern GCriticalSection g_lockOfGuide;
/* 表示当前操作的视图模式句柄,暂时只能支持一个视图模式句柄 */
GHMAPVIEW g_hMapView = GNULL;/* 动态效果使用 */
GZOOMLEVEL g_eZoomLevel = ZOOM_500_KM;  /* 动态效果使用,要缩放到具体的比例尺 */

Gint32	g_nScaleTotal =0;
Gint32	g_nScaleCount=0;					//地图无极缩放计数器
Gint32	g_nScaleFlag;						//地图无极缩放标志(0放大，1缩小)

Gint32	g_nViewMode =MODE_NORTH;

Gint32 g_nMapViewType;
extern Gbool g_bCreateViewSuccess;
static Gint32 g_mapType = 0;
static Gint32 g_voicePlayType = 0;
@implementation GDBL_Map




/**********************************************************************
 * 函数名称: GDBL_FlingMap
 * 功能描述: 甩动地图
 * 输入参数: iVelocityX X轴速度
 *          iVelocityY Y轴速度
 * 输出参数:
 * 返 回 值：成功返回GD_ERR_OK ,异常情况返回 GSTATUS 对应出错码
 * 其它说明:
 * 修改日期          版本号     修改人     修改内容
 * ---------------------------------------------------------------------
 * 2012/05/08        1.0      杨毅
 **********************************************************************/
GSTATUS GDBL_FlingMap(Gint32 iVelocityX, Gint32 iVelocityY)
{
    GMAPVIEW pMapview;
    GDBL_GetMapView(&pMapview);
    GSTATUS gRet = GD_ERR_OK;
	if (gRet ==GD_ERR_OK && GMAP_VIEW_TYPE_MAIN == pMapview.eViewType)
    {
        Gbool bDnyFlag;
        GDBL_GetParam(G_MAP_SHOW_ANIMATED, &bDnyFlag);
        if (bDnyFlag == Gfalse)
        {
            return GD_ERR_OK;
        }
        else
        {
            
            if (g_nRecognizeType!=EVENT_NONE&&g_nRecognizeType!=EVENT_PAN_MOVE)
            {
                StopAllRecognizeEventEx(EVENT_PAN_MOVE);
                return GD_ERR_FAILED;
            }
            
            if (g_fling_velocity_x!=0||g_fling_velocity_y!=0)
            {
                if (iVelocityX*g_fling_velocity_x<0||iVelocityY*g_fling_velocity_y<0)
                {//反向移动
                    //			GDBL_StopFling();
                    g_fling_velocity_x = iVelocityX;
                    g_fling_velocity_y = iVelocityY;
                }else {
                    g_fling_velocity_x+=iVelocityX;			//甩动X轴速度
                    g_fling_velocity_y+=iVelocityY;			//甩动Y轴速度
                    
                }
                return GD_ERR_OK;
            }
            g_fling_velocity_x+=iVelocityX;			//甩动X轴速度
            g_fling_velocity_y+=iVelocityY;			//甩动Y轴速度
            g_timerFling = GPI_CreateTimer(MAP_FLINGTIMEOUT, MapFlingTimerProc);
            if (g_timerFling)
            {
                g_bZoomFlag = Gtrue;
                return GD_ERR_OK;
            }
            else
            {
                return GD_ERR_NO_DATA;
            }
            return GD_ERR_OK;
        }
        
    }
    else
    {
        GDBL_StopAllRecognizeEvent();
        gRet = GD_ERR_NO_DATA;
    }
    return gRet;
}


/**********************************************************************
 * 函数名称: GDBL_StopFling
 * 功能描述: 停止甩动地图（手指再次点击或其他必须停止甩动情况下调用）
 * 输入参数:
 * 输出参数:
 * 返 回 值：成功返回GD_ERR_OK ,异常情况返回 GSTATUS 对应出错码
 * 其它说明:
 * 修改日期          版本号     修改人     修改内容
 * ---------------------------------------------------------------------
 * 2012/05/08        1.0      杨毅
 **********************************************************************/
GSTATUS GDBL_StopFling(Gbool bShowBuffer)
{
    GMAPVIEW pMapview;
    GDBL_GetMapView(&pMapview);
    GSTATUS gRet = GD_ERR_OK;
	if (gRet ==GD_ERR_OK && GMAP_VIEW_TYPE_MAIN == pMapview.eViewType)
    {
        Gbool bDnyFlag;
        GDBL_GetParam(G_MAP_SHOW_ANIMATED, &bDnyFlag);
        if (bDnyFlag == Gfalse)
        {
            return GD_ERR_OK;
        }
        else
        {
            g_fling_velocity_x =0;
            g_fling_velocity_y =0;
            GPI_DestroyTimer(g_timerFling);
            g_timerFling = 0;
            g_nRecognizeType = EVENT_NONE;
            return GD_ERR_OK;
        }
    }
    else
    {
        gRet = GD_ERR_NO_DATA;
    }
    return gRet;
}


/**********************************************************************
 * 函数名称: MapFlingTimerProc
 * 功能描述: 甩动地图用定时器
 * 输入参数:
 * 输出参数:
 * 返 回 值:
 * 其它说明:
 * 修改日期			版本号		修改人		修改内容
 * ---------------------------------------------------------------------
 * 2011/05/08        1.0			杨毅
 **********************************************************************/
void MapFlingTimerProc(Guint32 uTickCount)
{
	
	if (abs(g_fling_velocity_x) <= 0 && abs(g_fling_velocity_y) <= 0) {
		return;
	}
	int dirX = 0;
	int dirY = 0;
	int antiX = 0;
	int antiY = 0;
	
	if (g_fling_velocity_x != 0) {
		dirX = g_fling_velocity_x > 0 ? 1 : -1;
	}
	if (g_fling_velocity_y != 0) {
		dirY = g_fling_velocity_y > 0 ? 1 : -1;
	}
	
	Gint32 m_absVx = abs(g_fling_velocity_x);
	Gint32 m_absVy = abs(g_fling_velocity_y);
	
	//根据合速度计算X、Y轴的速度减小量（ANTI_SLIDE_VELOCITY为固定的合速度减小量）
	double scale = ANTI_SLIDE_VELOCITY
	/ sqrt((double)(m_absVx * m_absVx + m_absVy * m_absVy));
	//sqrt 注意数值溢出
    
	if (scale<0) {
		scale = 0.01;
	}
    
	int dx = g_fling_velocity_x/100;
	int dy = g_fling_velocity_y/100;
	//按偏移量移动地图，调用相应的Server接口
	int max = abs(dx)>abs(dy)?abs(dx):abs(dy);
	dx *=max/(max>20?10.0:4.0);
	dy *=max/(max>20?10.0:4.0);
	
	GMOVEMAP stMoveMap;
	memset(&stMoveMap,0,sizeof(GMOVEMAP));
	stMoveMap.eOP =MOVEMAP_OP_DRAG;
	
	stMoveMap.deltaCoord.x=-dx;
	stMoveMap.deltaCoord.y=-dy;
    
    GMAPVIEW pMapview;
    GSTATUS res = GDBL_GetMapView(&pMapview);
    if (res == GD_ERR_OK)
    {
        GHMAPVIEW hMapView = NULL;
        GDBL_GetMapViewHandle(pMapview.eViewType, &hMapView);
        GDBL_MoveMapView(hMapView,&stMoveMap);
    }
	
	antiX = g_fling_velocity_x -(int) (g_fling_velocity_x * scale);
	antiY = g_fling_velocity_y -(int) (g_fling_velocity_y * scale);
	
	
	if (antiX*dx > 0) {
		g_fling_velocity_x = antiX;
	} else {
		g_fling_velocity_x = 0;
	}
	if (antiY*dy > 0) {
		g_fling_velocity_y = antiY;
	} else {
		g_fling_velocity_y = 0;
	}
	
	if (abs(g_fling_velocity_x) <= 100 && abs(g_fling_velocity_y) <= 100) {
		//甩动结束，停止定时器
		g_fling_velocity_x =0;
		g_fling_velocity_y =0;
		GPI_DestroyTimer(g_timerFling);
        g_timerFling = 0;
		g_nRecognizeType = EVENT_NONE;
        g_bZoomFlag = Gfalse;
	}
}

/**********************************************************************
 * 函数名称: GDBL_CheckRecognizeType
 * 功能描述: 比较新的手势与当前手势是否相符合
 * 输入参数: RECOGNIZETYPE compareRecoginzeType
 * 输出参数:
 * 返 回 值：相符合返回Gtrue ,否则返回 Gfalse 对应出错码
 * 其它说明:
 * 修改日期          版本号     修改人     修改内容
 * ---------------------------------------------------------------------
 * 2012/06/05        1.0      杨毅
 **********************************************************************/
Gbool GDBL_CheckRecognizeType(RECOGNIZETYPE compareRecoginzeType)
{
	return (g_nRecognizeType ==compareRecoginzeType)?Gtrue:Gfalse;
}

/**********************************************************************
 * 函数名称: GDBL_SetRecognizeEvent
 * 功能描述: 设置新的手势操作事件
 * 输入参数: RECOGNIZETYPE newRecognizeType
 *			Gbool	isStopAllEvent
 * 输出参数:
 * 返 回 值：成功返回GD_ERR_OK ,异常情况返回 GSTATUS 对应出错码
 * 其它说明:
 * 修改日期          版本号     修改人     修改内容
 * ---------------------------------------------------------------------
 * 2012/06/05        1.0      杨毅
 **********************************************************************/
GSTATUS GDBL_SetRecognizeEvent(RECOGNIZETYPE newRecognizeType,Gbool isStopAllEvent)
{
	if (isStopAllEvent== Gtrue)
	{
		StopAllRecognizeEventEx(EVENT_NONE);
	}
	g_nRecognizeType = newRecognizeType;
	return GD_ERR_OK;
}

/**********************************************************************
 * 函数名称: GDBL_StopAllRecognizeEvent
 * 功能描述: 停止所有手势操作事件
 * 输入参数:
 * 输出参数:
 * 返 回 值：成功返回GD_ERR_OK ,异常情况返回 GSTATUS 对应出错码
 * 其它说明:
 * 修改日期          版本号     修改人     修改内容
 * ---------------------------------------------------------------------
 * 2012/06/05        1.0      杨毅
 **********************************************************************/
GSTATUS GDBL_StopAllRecognizeEvent()
{
	return StopAllRecognizeEventEx(EVENT_NONE);
}

/**********************************************************************
 * 函数名称: StopAllRecognizeEventEx
 * 功能描述: 停止所有手势操作事件,除了特手势,EVENT_NONE则结束所有
 * 输入参数: RECOGNIZETYPE exceptType
 * 输出参数:
 * 返 回 值：成功返回GD_ERR_OK ,异常情况返回 GSTATUS 对应出错码
 * 其它说明:
 * 修改日期          版本号     修改人     修改内容
 * ---------------------------------------------------------------------
 * 2012/06/05        1.0      杨毅
 **********************************************************************/
GSTATUS StopAllRecognizeEventEx(RECOGNIZETYPE exceptType)
{
    GSTATUS gRet = GD_ERR_OK;
    GMAPVIEW hMapView;
    gRet = GDBL_GetMapView(&hMapView);
	if (gRet == GD_ERR_OK && GMAP_VIEW_TYPE_MAIN == hMapView.eViewType)
    {
        if (exceptType!=EVENT_PINCH)
        {
            //            GDBL_ScaleEnd();
        }
        if (exceptType!=EVENT_PAN_MOVE)
        {
			GDBL_StopFling(Gfalse);
        }
        if (exceptType!=EVENT_SWIP)
        {
            //			GDBL_StopAdjustElevation(Gfalse);
        }
        if (exceptType!=EVENT_ROTATE)
        {
            //			GDBL_StopRotate(Gfalse);
        }
        
        g_nRecognizeType = exceptType;
        if (exceptType!=EVENT_NONE) {
            //            MAP_ShowMap(0);
        }
        
    }
    else
    {
        g_nRecognizeType = exceptType;
        gRet =GD_ERR_OK;
    }
    return gRet;
}

@end

//
//  MWMapOperator.m
//  AutoNavi
//
//  Created by yu.liao on 13-7-29.
//
//

#import "MWMapOperator.h"
#import "ProgressBar.h"

static MWMapOperator *instance = nil;

@implementation MWMapOperator
@synthesize mapOperate;

+(MWMapOperator*)sharedInstance
{
    @synchronized(self)
    {
        if (instance == nil) {
            instance = [[self alloc] init];
        }
    }
    return instance;
}

+(void)releaseInstance
{
    @synchronized(self)
    {
        if (instance != nil)
        {
            [instance release];
            instance = nil;
        }
    }
}

- (id)init
{
    self = [super init];
    if(self!=nil)
    {
        
    }
	
    return self;
}
#pragma mark 查看指定地图
/**********************************************************************
 * 函数名称: MW_ShowMapView
 * 功能描述: 查看指定地图
 * 参    数: [IN] eViewType 视图类型
 *			[IN] Param1, Param2, Param3 扩展参数，参见说明。
 * 返 回 值: 成功返回GD_ERR_OK, 失败返回对应出错码
 * 其它说明: 1、	该接口可以完全取代GDBL_ViewMap。后续只对该接口进行功能扩充。
 *			2、	视图类型与参数对应表：
 *			序号   | 功能               eViewType	                    nParam1                    nParam2            nParam3
 *			1	   | 单路线主地图	    GMAP_VIEW_TYPE_MAIN	          | N/A                        N/A                N/A
 *			2	   | 单路线全程概览	    GMAP_VIEW_TYPE_WHOLE	      | N/A                        N/A                N/A
 *			3	   | 多路线主地图	    GMAP_VIEW_TYPE_MULTI	      | N/A                        N/A                N/A
 *			4	   | 多路线全程概览	    GMAP_VIEW_TYPE_MULTIWHOLE	  | N/A                        N/A                N/A
 *			5	   | 查看POI	        GMAP_VIEW_TYPE_POI	          | GPOI* pPOI	               Gbool bAutoAdjust  N/A
 *			6	   | 查看SP码点	        GMAP_VIEW_TYPE_SP	          | Gchar* szSPCode	           Gbool bAutoAdjust  N/A
 *			7	   | 查看引导机动点	    GMAP_VIEW_TYPE_MANEUVER_POINT | GGUIDEROADINFO中的nID字段  N/A                N/A
 *			8	   | 路径TMC概览	    GMAP_VIEW_TYPE_ROUTE_TMC      | GGUIDEROADTMCLIST数组序号  N/A                N/A
 *			9	   | 多路线不同处概览	GMAP_VIEW_TYPE_MULTI_DIFF     | -1 : 所有不同              N/A                N/A
 **********************************************************************/
-(int)MW_ShowMapView:(GMAPVIEWTYPE)eViewType WithParma1:(Gint32)param1 WithParma2:(Gint32)param2 WithParma3:(Gint32)param3
{
    GSTATUS res = GDBL_ShowMapView(eViewType,param1,param2,param3);
    return res;
    
}

#pragma mark 强制刷新一次地图视图
/**********************************************************************
 * 函数名称: MW_RefreshMapView
 * 功能描述: 强制刷新一次地图视图
 * 参    数:
 * 返 回 值: 成功返回GD_ERR_OK, 失败返回对应出错码
 * 其它说明:
 **********************************************************************/
-(int)MW_RefreshMapView:(GMAPVIEWTYPE)mapViewType
{
    GSTATUS res;
    GHMAPVIEW mapHandle;
    res = GDBL_GetMapViewHandle(mapViewType,&mapHandle);
    if (GD_ERR_OK == res) {
        return GDBL_RefreshMapView(mapHandle);
    }
    return res;
    
}

#pragma mark 缩放地图 2D
/**********************************************************************
 * 函数名称: MW_ZoomMapView
 * 功能描述: 缩放地图视图
 * 参    数: [IN] mapHandle 地图视图句柄
 *			[IN] flag 缩放标识，@see GSETMAPVIEWLEVEL
 *			[IN] level 比例级别，当nFlag为0时才有意义，参见nFlag参数。
 * 返 回 值: 成功返回GD_ERR_OK, 失败返回对应出错码
 **********************************************************************/
-(int)MW_ZoomMapView:(GMAPVIEWTYPE)eViewMap ZoomFlag:(GSETMAPVIEWLEVEL)flag ZoomLevel:(GZOOMLEVEL)level
{
    GHMAPVIEW handleForMap;
    GMAPVIEW typeForMap;
    GDBL_GetMapView(&typeForMap);
    
    GDBL_GetMapViewHandle(typeForMap.eViewType, &handleForMap);
    GMAPVIEWINFO stMapObjectInfo;
	GDBL_GetMapViewInfo(handleForMap, &stMapObjectInfo);
    
    GSTATUS res;
    GHMAPVIEW mapHandle;
    res = GDBL_GetMapViewHandle(eViewMap,&mapHandle);
    if (GD_ERR_OK == res) {
        
        int i =  GDBL_ZoomMapView(mapHandle,flag,level);
        return i;
    }
    return res;
    return 0;
    
}

#pragma mark 移图
/**********************************************************************
 * 函数名称: MW_MoveMapView
 * 功能描述: 移图
 * 参    数: [IN] mapHandle 地图视图句柄
 *			[IN] typeCoord 结构体GMOVEMAP指针，用于标识当前移图操作类型和相关参数。
 * 返 回 值: 成功返回GD_ERR_OK, 失败返回对应出错码
 * 其它说明:
 **********************************************************************/
-(int)MW_MoveMapView:(GMAPVIEWTYPE)eViewMap TypeAndCoord:(GMOVEMAP *)typeCoord
{
    GSTATUS res;
    GHMAPVIEW mapHandle;
    res = GDBL_GetMapViewHandle(eViewMap,&mapHandle);
    if (GD_ERR_OK == res) {
        res = GDBL_MoveMapView(mapHandle,typeCoord);
        if (GD_ERR_OK == res) {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_MOVEMAP object:nil];
        }
        
    }
    return res;
}

#pragma mark 移图(长按地图界面显示点详细信息面板时，面板位置改变时，移动地图)
/**********************************************************************
 * 函数名称: MW_moveMapWithMapType
 * 功能描述: 移图(长按地图界面显示点详细信息面板时，面板位置改变时，移动地图)
 * 参    数: [IN] mapType 视图结构体类型
 *			[IN] flag 面板移动类型
            [IN] point 查看的poi屏幕坐标
 * 返 回 值: 成功返回GD_ERR_OK, 失败返回对应出错码
 * 其它说明:
 **********************************************************************/
- (int)MW_moveMapWithMapType:(GMAPVIEWTYPE)mapType Flag:(int)flag Point:(CGPoint)point
{
    static int u = 0;
    static int lon = 0;
    static int lat = 0;
    if (u == 0) {
        GMAPCENTERINFO mapinfo = {0};
        [[MWMapOperator sharedInstance] MW_GetMapViewCenterInfo:GMAP_VIEW_TYPE_MAIN mapCenterInfo:&mapinfo];
        lon = mapinfo.CenterCoord.x;
        lat = mapinfo.CenterCoord.y;
        u ++;
    }
    GCOORD tmp;
    
    GCOORD geoCoord = {0};
    geoCoord.x = lon;
    geoCoord.y = lat;
    GFCOORD coord_temp = [MWEngineTools GeoToScr:geoCoord];
    tmp.x = coord_temp.x;
    tmp.y = coord_temp.y;
    
    point.x = tmp.x;
    point.y = tmp.y;

    
    switch (flag) {
        case 0://面板向上，遮盖一小部分
        {
            
            if (point.y > 340.0) {
                int dX = point.x - SCREENWIDTH/2.0;
                int dY = point.y - SCREENHEIGHT/2.0;
                GMOVEMAP moveMap;
                moveMap.eOP = MOVEMAP_OP_DRAG;
                moveMap.deltaCoord.x = dX*[ANParamValue sharedInstance].scaleFactor;
                moveMap.deltaCoord.y = dY*[ANParamValue sharedInstance].scaleFactor;
                [[MWMapOperator sharedInstance] MW_MoveMapView:GMAP_VIEW_TYPE_MAIN TypeAndCoord:&moveMap];
            }

        }
            break;
        case 1://面板向上，遮盖一大部分
        {
            if (point.x == 0 || point.x > SCREENWIDTH || point.y == 0 || point.y > 150.0) {
                int dX = point.x - SCREENWIDTH/2.0;
                int dY = point.y - 80.0;
                GMOVEMAP moveMap;
                moveMap.eOP = MOVEMAP_OP_DRAG;
                moveMap.deltaCoord.x = dX*[ANParamValue sharedInstance].scaleFactor;
                moveMap.deltaCoord.y = dY*[ANParamValue sharedInstance].scaleFactor;
                [[MWMapOperator sharedInstance] MW_MoveMapView:GMAP_VIEW_TYPE_MAIN TypeAndCoord:&moveMap];
            }
        }
            break;
        case 2://面板向下，遮盖一小部分
        {
            int dX = point.x - SCREENWIDTH/2.0;
            int dY = point.y - SCREENHEIGHT/2.0;
            GMOVEMAP moveMap;
            moveMap.eOP = MOVEMAP_OP_DRAG;
            moveMap.deltaCoord.x = dX*[ANParamValue sharedInstance].scaleFactor;
            moveMap.deltaCoord.y = dY*[ANParamValue sharedInstance].scaleFactor;
            [[MWMapOperator sharedInstance] MW_MoveMapView:GMAP_VIEW_TYPE_MAIN TypeAndCoord:&moveMap];
        }
            break;
        
        default:
            break;
    }
    return 1;
}

#pragma mark 旋转地图
/**********************************************************************
 * 函数名称: MW_RotateMapView
 * 功能描述: 旋转地图视图
 * 参    数: [IN] mapHandle 地图视图句柄
 *			[IN] bAbsolute 是否为绝对角度值，Gtrue表示xa、ya、za为绝对角度值，否则为相对角度值。
 *			[IN] xAngle、yAngle、zAngle 角度值，可以为负值。
 * 返 回 值: 成功返回GD_ERR_OK, 失败返回对应出错码
 * 其它说明:
 **********************************************************************/
-(int)MW_RotateMapView:(GMAPVIEWTYPE)eViewMap bAbsolute:(Gbool)bAbsolute WithX:(Gfloat32)xAngle WithY:(Gfloat32)yAngle WithZ:(Gfloat32)zAngle
{
    GSTATUS res;
    GHMAPVIEW mapHandle;
    res = GDBL_GetMapViewHandle(eViewMap,&mapHandle);
    if (GD_ERR_OK == res) {
        return GDBL_RotateMapView(mapHandle,zAngle);
    }
    return res;
    
}

#pragma mark 调整车位
/**********************************************************************
 * 函数名称: MW_AdjustCar
 * 功能描述: 调整车位
 * 参    数: [IN] eViewMap 地图类型
 *			[IN] coord 经纬度
 *			[IN] angle 车位角度
 * 返 回 值: 成功返回GD_ERR_OK, 失败返回对应出错码
 * 其它说明:
 **********************************************************************/
-(int)MW_AdjustCar:(GMAPVIEWTYPE)eViewMap Gcoord:(GCOORD)coord Angle:(Gint32)angle
{
    GHMAPVIEW phMapView;
    GDBL_GetMapViewHandle(eViewMap,&phMapView);
    GSTATUS res = GDBL_AdjustCar(phMapView,&coord,angle);
    return res;
}

#pragma mark 切换地图视图模式
/**********************************************************************
 * 函数名称: MW_SetMapViewMode
 * 功能描述: 切换地图视图模式
 * 参    数: [IN] mapHandle 地图视图句柄
 *			[IN] type 模式标识，-1前一个模式，0切换到eMapViewMode模式，1下一个模式。
 *			[IN] mapMode 视图模式，当type为0时才有意义，参见type参数说明。
 * 返 回 值: 成功返回GD_ERR_OK, 失败返回对应出错码
 * 其它说明:
 **********************************************************************/
-(int)MW_SetMapViewMode:(GMAPVIEWTYPE)eViewMap Type:(Gint32)type MapMode:(GMAPVIEWMODE)mapMode
{
    GSTATUS res;
    GHMAPVIEW mapHandle;
    res = GDBL_GetMapViewHandle(eViewMap,&mapHandle);
    if (GD_ERR_OK == res) {
        
        int value = 0;
        GDBL_SetParam(G_MAP_SHOW_ANIMATED, &value);
        double delayInSeconds = 0.5;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            int value = 1;
            GDBL_SetParam(G_MAP_SHOW_ANIMATED, &value);
        });
        
        if (mapMode == GMAPVIEW_MODE_3D)
        {
            GMAPVIEWINFO pMapViewInfo = {0};
            GDBL_GetMapViewInfo(mapHandle, &pMapViewInfo);
            GDBL_AdjustMapViewElevation(mapHandle, pMapViewInfo.fMinPitchAngle - 90);
        }
        else
        {
            GDBL_AdjustMapViewElevation(mapHandle, 90.0);
            res = GDBL_SetMapViewMode(mapHandle,GSETMAPVIEW_MODE_ANY_NO3D,mapMode); //无3D模式
        }
        //产品设计，2/3D融合，有路径下需要保存用户选择的视图模式
        int isPath = 0;
        GDBL_GetParam(G_GUIDE_STATUS, &isPath);
        if (isPath == 1) {
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:mapMode] forKey:USERDEFAULT_NaviMapMode];
        }
        
    }
    return res;
    
}

#pragma mark 重置地图视图
/**********************************************************************
 * 函数名称: MW_ResetMapView
 * 功能描述: 重置地图视图
 * 参    数: [IN] mapHandle 地图视图句柄
 *			[IN] mapFlag 需要重置的参数，参见GMAPVIEWFLAG枚举类型。
 * 返 回 值: 成功返回GD_ERR_OK, 失败返回对应出错码
 * 其它说明:
 **********************************************************************/
-(int)MW_ResetMapView:(GMAPVIEWTYPE)eViewMap MapFlag:(GMAPVIEWFLAG)mapFlag
{
    GSTATUS res;
    GHMAPVIEW mapHandle;
    res = GDBL_GetMapViewHandle(eViewMap,&mapHandle);
    if (GD_ERR_OK == res) {
//        return GDBL_ResetMapView(mapHandle,mapFlag);
    }
    return res;
}

#pragma mark 设置地图操作类型
/**********************************************************************
 * 函数名称: MW_SetMapOperateType
 * 功能描述: 设置地图操作类型
 * 参    数: [IN] type 地图操作类型
 * 返 回 值: 成功返回GD_ERR_OK, 失败返回对应出错码
 * 其它说明:
 **********************************************************************/
- (void)MW_SetMapOperateType:(NSInteger)type {
	
	mapOperate = type;
}


#pragma mark 设置地图竖屏区域
/**********************************************************************
 * 函数名称: MW_SetMapViewVRect
 * 功能描述: 设置地图竖屏区域
 * 参    数: [IN] V_Rect 竖屏区域
 * 返 回 值: 
 * 其它说明:
 **********************************************************************/
- (void)MW_SetMapViewVRect:(CGRect)V_Rect
{
    GRECT V_MAP_VIEW_RECT;
	V_MAP_VIEW_RECT.left= (Gint32)V_Rect.origin.x;
	V_MAP_VIEW_RECT.top = (Gint32)V_Rect.origin.y;
	V_MAP_VIEW_RECT.right = (Gint32)((V_Rect.size.width + V_Rect.origin.x)*[ANParamValue sharedInstance].scaleFactor-1);
	V_MAP_VIEW_RECT.bottom= (Gint32)((V_Rect.size.height + V_Rect.origin.y)*[ANParamValue sharedInstance].scaleFactor-1);
	GDBL_SetParam(G_V_MAP_VIEW_RECT, &V_MAP_VIEW_RECT);
    
}

#pragma mark 设置地图横屏区域
/**********************************************************************
 * 函数名称: MW_SetMapViewHRect
 * 功能描述: 设置地图横屏区域
 * 参    数: [IN] H_Rect 横屏区域
 * 返 回 值: 
 * 其它说明:
 **********************************************************************/
- (void)MW_SetMapViewHRect:(CGRect)H_Rect
{
    GRECT H_MAP_VIEW_RECT;
	H_MAP_VIEW_RECT.left= (Gint32)H_Rect.origin.x;
	H_MAP_VIEW_RECT.top = (Gint32)H_Rect.origin.y;
	H_MAP_VIEW_RECT.right = (Gint32)((H_Rect.size.width + H_Rect.origin.x)*[ANParamValue sharedInstance].scaleFactor-1);
	H_MAP_VIEW_RECT.bottom= (Gint32)((H_Rect.size.height + H_Rect.origin.y)*[ANParamValue sharedInstance].scaleFactor-1);
	GDBL_SetParam(G_H_MAP_VIEW_RECT, &H_MAP_VIEW_RECT);
    
}

#pragma mark 回车位
/**********************************************************************
 * 函数名称: MW_GoToCCP
 * 功能描述: 回车位
 * 参    数:
 * 返 回 值: 
 * 其它说明:
 **********************************************************************/
- (void)MW_GoToCCP
{
    if (![[ANParamValue sharedInstance] isInit])
    {
        return;
    }
    GSTATUS res;
    res = GDBL_GoToCCP();
    if (GD_ERR_OK==res)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_GOTOCPP object:nil];
    }
}

#pragma mark 获取地图句柄
/**********************************************************************
 * 函数名称: MW_GetMapViewHandle
 * 功能描述: 获取指定地图视图句柄
 * 参    数: [IN] eViewType 枚举GMAPVIEWTYPE类型，用于指定视图类型。
 *			[OUT] mapHandle 地图视图句柄
 * 返 回 值: 成功返回GD_ERR_OK, 失败返回对应出错码
 * 其它说明: 1、地图视图句柄是用来管理地图视图的，使用该句柄可以进行地图
 *			视图的缩放、移图、模式切换等操作。
 **********************************************************************/
-(int)MW_GetMapViewHandle:(GMAPVIEWTYPE)eViewMap MapHandle:(GHMAPVIEW *)mapHandle
{
    return GDBL_GetMapViewHandle(eViewMap,mapHandle);
}

#pragma mark 获取当前地图信息(地图类型,地图中心,地图模式,地图角度,地图仰角,对应的比例数值,比例级别)
/**********************************************************************
 * 函数名称: MW_GetMapViewInfo
 * 功能描述: 获取当前地图信息(地图类型,地图中心,地图模式,地图角度,地图仰角,对应的比例数值,比例级别)
 * 参    数: [IN] eViewType 枚举GMAPVIEWTYPE类型，用于指定视图类型。
 *			[OUT] mapViewInfo 当前地图信息
 * 返 回 值: 成功返回GD_ERR_OK, 失败返回对应出错码
 * 其它说明: 
 **********************************************************************/
-(int)MW_GetMapViewInfo:(GMAPVIEWTYPE)eViewMap MapViewInfo:(GMAPVIEWINFO *)mapViewInfo
{
    GSTATUS res;
    GHMAPVIEW mapHandle;
    res = GDBL_GetMapViewHandle(eViewMap,&mapHandle);
    if (GD_ERR_OK == res) {
        res = GDBL_GetMapViewInfo(mapHandle,mapViewInfo);
        if (mapViewInfo->fPitchAngle != 90)
        {
            mapViewInfo->eMapMode = GMAPVIEW_MODE_3D;
        }
        return res;
    }
    return res;
}

#pragma mark 缓存当前地图信息
/**********************************************************************
 * 函数名称: MW_SaveInfoForCurrrentMapView
 * 功能描述: 缓存当前地图信息
 * 参    数: 
 * 返 回 值: 
 * 其它说明:
 **********************************************************************/
- (void)MW_SaveInfoForCurrrentMapView
{
    GMAPVIEW typeForMap;
    GHMAPVIEW handleForMap = NULL;
    GSTATUS nStatus;
    nStatus = GDBL_GetMapView(&typeForMap);
    nStatus = GDBL_GetMapViewHandle(typeForMap.eViewType, &handleForMap);
    nStatus = GDBL_GetMapViewInfo(handleForMap, &m_stMapViewInfo);
}

#pragma mark 对比缓存的地图信息判断是否有移图
/**********************************************************************
 * 函数名称: MW_CheckIfChangeOnMapViewInfo
 * 功能描述: 判断是否有移图
 * 参    数:
 * 返 回 值: YES:有移图 NO:无移图
 * 其它说明: 对比缓存的地图信息判断是否有移图
 **********************************************************************/
- (BOOL)MW_CheckIfChangeOnMapViewInfo
{
    GMAPVIEW typeForMap;
    GHMAPVIEW handleForMap;
    GSTATUS nStatus;
    GMAPVIEWINFO stMapViewInfo={0};
    nStatus = GDBL_GetMapView(&typeForMap);
    nStatus = GDBL_GetMapViewHandle(typeForMap.eViewType, &handleForMap);
    nStatus = GDBL_GetMapViewInfo(handleForMap, &stMapViewInfo);
    if (nStatus==GD_ERR_OK) {
        if (stMapViewInfo.MapCenter.x!=m_stMapViewInfo.MapCenter.x||stMapViewInfo.eScaleLevel!=m_stMapViewInfo.eScaleLevel||stMapViewInfo.MapCenter.y!=m_stMapViewInfo.MapCenter.y) {
            return YES;
        }
    }
    return NO;
}

#pragma mark 获取地图中心点信息
/**********************************************************************
 * 函数名称: MW_GetMapViewCenterInfo
 * 功能描述: 获取地图中心点信息
 * 参    数: [IN] eViewType 枚举GMAPVIEWTYPE类型，用于指定视图类型。
 *			[OUT] pMapCenterInfo 当前地图中心点信息
 * 返 回 值: 成功返回GD_ERR_OK, 失败返回对应出错码
 * 其它说明:
 **********************************************************************/
-(int)MW_GetMapViewCenterInfo:(GMAPVIEWTYPE)eViewMap mapCenterInfo:(GMAPCENTERINFO *)pMapCenterInfo
{
    GSTATUS res;
    GHMAPVIEW mapHandle;
    res = GDBL_GetMapViewHandle(eViewMap,&mapHandle);
    if (GD_ERR_OK == res) {
        return GDBL_GetMapViewCenterInfo(mapHandle,pMapCenterInfo);
    }
    return res;
}

#pragma mark 缩放到指定级别比例尺
/**********************************************************************
 * 函数名称: MW_ZoomTo
 * 功能描述: 缩放到指定级别比例尺
 * 参    数: [IN] level 比例尺级别
            [IN] animated 是否有动画
 * 返 回 值: 
 * 其它说明:
 **********************************************************************/
-(void)MW_ZoomTo:(GZOOMLEVEL)level Animated:(BOOL)animated
{
    if (animated) {
        GMAPVIEW pMapview;
        GDBL_GetMapView(&pMapview);
        GHMAPVIEW phMapView;
        GDBL_GetMapViewHandle(pMapview.eViewType, &phMapView);
        GDBL_ZoomMapView(phMapView, GSETMAPVIEW_LEVEL_ANY, level);
    }
    else
    {
        int value = 0;
        GDBL_SetParam(G_MAP_SHOW_ANIMATED, &value);
        double delayInSeconds = 0.5;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            int value = 1;
            GDBL_SetParam(G_MAP_SHOW_ANIMATED, &value);
        });
        
        GMAPVIEW pMapview;
        GDBL_GetMapView(&pMapview);
        GHMAPVIEW phMapView;
        GDBL_GetMapViewHandle(pMapview.eViewType, &phMapView);
        GDBL_ZoomMapView(phMapView, GSETMAPVIEW_LEVEL_ANY, level);
    }
	
}



#pragma mark 获取当前车位信息
/**********************************************************************
 * 函数名称: GMD_GetCarInfo
 * 功能描述: 获取当前车位信息
 * 参    数: GCARINFO
 * 返 回 值: GD_ERR_OK:获取成功   else —— 获取失败
 * 其它说明:
 **********************************************************************/
- (GSTATUS)GMD_GetCarInfo:(GCARINFO *)carInfo
{
    GSTATUS res = GD_ERR_FAILED;
    
    res = GDBL_GetCarInfo(carInfo);
    
    return res;
}

#pragma mark 获取当前引导路径路径引导颜色数组
/**********************************************************************
 * 函数名称: GMD_GetGuideRouteColorContent
 * 功能描述: 获取当前引导路径路径引导颜色数组
 * 参    数:
 * 返 回 值: 引导颜色数组
 * 其它说明:
 **********************************************************************/
- (NSMutableArray *)GMD_GetGuideRouteColorContent
{
    int totalDistance = 0;
    float percent = 0.0;
    float tmpPercent = 0.0;
    NSMutableArray *colorArray = [[NSMutableArray alloc] init];
    
    if ([MWEngineSwitch isTMCOn])
    {
        GGUIDEROADTMCLIST pList = {0};
        GSTATUS nStatus = GDBL_GetGuideRoadTMCList(&pList);
        
        if (nStatus==GD_ERR_OK) {
            totalDistance = pList.nTotalDis;
            if (totalDistance<0) {
                return nil;
            }
            //走过的
            tmpPercent = pList.nCarDisFromStart/(totalDistance*1.0f);
            percent = percent + tmpPercent;
            
            ProgressInfo *colorInfo = [[ProgressInfo alloc] init];
            colorInfo.percent = tmpPercent;
            colorInfo.status = CompleteStatus;
            [colorArray addObject:colorInfo];
            [colorInfo release];
            //未走过的
            for (int i=0; i<pList.nNumberOfItem; i++)
            {
                int itemDisFromStart = pList.pItem[i].nDisFromStart;
                int itemDis = pList.pItem[i].nDis;
                int itemCarDisFromStart = pList.nCarDisFromStart;
                int itemState = pList.pItem[i].eTrafficStream;
                int state = 0;
                
                if (itemState == 1)
                {
                    state = UnblockedStatus;
                }
                else if (itemState == 2 || itemState == 3)
                {
                    state = SlowlyStaus;
                }
                else if (itemState == 4 || itemState == 5)
                {
                    state = StopStatus;
                }
                else
                {
                    state = UnfinishStatus;
                }
                
                //车位到起点的距离大于该点到起点的距离的项抛弃
                if (itemDisFromStart+itemDis < itemCarDisFromStart )
                {
                    continue;
                }
                else if (itemDisFromStart > itemCarDisFromStart)
                {
                    tmpPercent = itemDis/(totalDistance*1.0f);
                    percent = percent + tmpPercent;
                    
                    ProgressInfo *colorInfo = [[ProgressInfo alloc] init];
                    colorInfo.percent = tmpPercent;
                    colorInfo.status = state;
                    [colorArray addObject:colorInfo];
                    [colorInfo release];
                }
                else
                {
                    tmpPercent = (itemDisFromStart + itemDis - itemCarDisFromStart)/(totalDistance*1.0f);
                    percent = percent + tmpPercent;
                    
                    ProgressInfo *colorInfo = [[ProgressInfo alloc] init];
                    colorInfo.percent = tmpPercent;
                    colorInfo.status = state;
                    [colorArray addObject:colorInfo];
                    [colorInfo release];
                    
                }
                
            }
            
            if (percent < 1) {
                ProgressInfo *colorInfo = [[ProgressInfo alloc] init];
                colorInfo.percent = 1.0 - percent;
                colorInfo.status = UnblockedStatus;
                [colorArray addObject:colorInfo];
                [colorInfo release];
            }
            
        }
        
    }
    else{
        totalDistance = [[MWRouteGuide GetPathStatisticInfoWithMainID:4 GuideHandel:GNULL] intValue];
        unsigned int unCompleteDistance = [[MWRouteGuide GetManeuverInfoWithMainID:11] intValue];
        unsigned int completeDistance = totalDistance - unCompleteDistance;
        
        ProgressInfo *colorInfo = [[ProgressInfo alloc] init];
        colorInfo.percent = completeDistance/(totalDistance*1.0f);
        colorInfo.status = CompleteStatus;
        [colorArray addObject:colorInfo];
        [colorInfo release];
        
        ProgressInfo *colorInfo1 = [[ProgressInfo alloc] init];
        colorInfo1.percent = 1.0 - colorInfo.percent ;
        colorInfo1.status = UnfinishStatus;
        [colorArray addObject:colorInfo1];
        [colorInfo1 release];
    }
    
    return [colorArray autorelease];
    
}

#pragma mark 根据经纬度获取当前绘制地图类型：0－离线地图 1－在线地图 ，判断比例尺
-(int)GMD_GetCurDrawMapViewTypeWithLon:(long)lon Lat:(long)lat
{

    GCOORD pcoord ={0};
    pcoord.x = lon;
    pcoord.y = lat;
    int sign = [MWAdminCode checkIsExistDataWithCoord:pcoord];
    return sign;
}


#pragma mark 获取3D仰角
-(int)GMD_Get3DScale
{
    GZOOMLEVEL pValue;
	GDBL_GetParam(G_MAP_ELEVATION, &pValue);
    return pValue;
}

/**********************************************************************
 * 函数名称: GMD_GetCurrentRoadName
 * 功能描述: 获取当前道路名
 * 参    数:mapViewType 视图类型
 * 返 回 值:道路名
 * 其它说明:
 **********************************************************************/
- (NSString *)GetCurrentRoadName:(GMAPVIEWTYPE)mapViewType
{
    NSMutableString *viewTitle = [[NSMutableString alloc] init];
	
	GMAPCENTERINFO mapinfo = {0};
    
    [[MWMapOperator sharedInstance] MW_GetMapViewCenterInfo:mapViewType mapCenterInfo:&mapinfo];
	
	[viewTitle appendString:[NSString chinaFontStringWithCString:mapinfo.szRoadName]];
	if(viewTitle.length == 0)
    {
        [viewTitle appendString:[NSMutableString stringWithFormat:@"%@",STR(@"Main_unNameRoad", Localize_Main)]] ;
    }
	return [viewTitle autorelease];
}

/**********************************************************************
 * 函数名称: GetCarDirection
 * 功能描述: 获取地图角度
 * 参    数:mapViewType 视图类型
 * 返 回 值:地图角度
 * 其它说明:
 **********************************************************************/
- (int)GetCarDirection:(GMAPVIEWTYPE)mapViewType
{
    GMAPVIEWINFO mapViewInfo = {0};
    
    [[MWMapOperator sharedInstance] MW_GetMapViewInfo:mapViewType MapViewInfo:&mapViewInfo];
    
    return (360 - mapViewInfo.fMapAngle);
}

/**********************************************************************
 * 函数名称: GetMapScaleLevelWithType
 * 功能描述: 获取当前的比例尺状态
 * 参    数:mapViewType 视图类型
 * 返 回 值:比例尺状态
 * 其它说明:
 **********************************************************************/
-(GZOOMLEVEL)GetMapScaleLevelWithType:(GMAPVIEWTYPE) nMapViewType
{
    GHMAPVIEW hMapView;
    GMAPVIEWINFO stMapObjectInfo = {0};
    GZOOMLEVEL nScaleLevel=ZOOM_200_KM;
    // 地图句柄
    GSTATUS nStatus = [[MWMapOperator sharedInstance] MW_GetMapViewHandle:nMapViewType MapHandle:&hMapView];
    // 地图信息
    if (nStatus == GD_ERR_OK)
    {
        nStatus = GDBL_GetMapViewInfo(hMapView, &stMapObjectInfo);
    }
    if (nStatus == GD_ERR_OK)
    {
        // 比例尺
        nScaleLevel = stMapObjectInfo.eScaleLevel;
    }
    return nScaleLevel;
}



/**********************************************************************
 * 函数名称: GetCurrentScale
 * 功能描述: 获取当前的比例尺字符串 带单位（km or m）
 * 返 回 值: 比例尺字符串
 * 其它说明:
 **********************************************************************/
- (NSString *)GetCurrentScale
{
    GMAPVIEW pMapview;
    GDBL_GetMapView(&pMapview);
	return [self GetScaleWith:pMapview.ZoomLevel];
}

- (NSString *)GetScaleWith:(GZOOMLEVEL)pValue
{
    NSString *CurrentScale;
	switch (pValue)
	{
		case 0:
		{
			CurrentScale = @"500km";
		}
			break;
			
		case 1:
		{
			CurrentScale = @"200km";
		}
			break;
			
		case 2:
		{
			CurrentScale = @"100km";
		}
			break;
			
		case 3:
		{
			CurrentScale = @"50km";
		}
			break;
			
		case 4:
		{
			CurrentScale = @"20km";
		}
			break;
			
		case 5:
		{
			CurrentScale = @"10km";
		}
			break;
			
		case 6:
		{
			CurrentScale = @"5km";
		}
			break;
			
		case 7:
		{
			CurrentScale = @"2km";
		}
			break;
			
		case 8:
		{
			CurrentScale = @"1km";
		}
			break;
			
		case 9:
		{
			CurrentScale = @"500m";
		}
			break;
			
		case 10:
		{
			CurrentScale = @"200m";
		}
			break;
			
		case 11:
		{
			CurrentScale = @"100m";
		}
			break;
        case 12:
		{
			CurrentScale = @"50m";
		}
			break;
        case 13:
		{
			CurrentScale = @"25m";
		}
			break;
        case 14:
		{
			CurrentScale = @"15m";
		}
			break;
		default:
            CurrentScale = @"25m";
			break;
	}
	
	return CurrentScale;
}
#pragma mark 查看路口(参数为索引值)
/**********************************************************************
 * 函数名称: MW_ViewCrossWithID
 * 功能描述: 查看路口(参数为索引值)
 * 参    数:
 * 返 回 值:
 * 其它说明:
 **********************************************************************/
+ (void)ViewCrossWithID:(int)ID {
	
	GDBL_ShowMapView(GMAP_VIEW_TYPE_MANEUVER_POINT, ID, Gtrue, 0);
}

/**
 **********************************************************************
 \brief 将当前视图转换为全程概览视图
 \details 该函数用于将当前视图转换为全程概览视图
 \param[in] hView 视图句柄
 \param[in] pstParams 全程概览结构信息
 \param[out] hBackupView 返回备份的视图句柄
 \retval	GD_ERR_OK	成功
 \retval	GD_ERR_INVALID_PARAM	参数有误
 \retval	GD_ERR_FAILED	失败
 \remarks 视图句柄目前只支持主地图
 \since 7.0
 \see
 **********************************************************************/
static int g_autoZoomValue = 0;
+ (GSTATUS)ViewToOverView:(GHMAPVIEW)hView pstParams:(GOVERVIEWPARAMS *)pstParams hBackupView:(GHMAPVIEW *)hBackupView
{
    GSTATUS res = GDBL_ViewToOverView(hView, pstParams, hBackupView);
    if (res == GD_ERR_OK)
    {
        g_autoZoomValue = [[MWPreference sharedInstance] getValue:PREF_AUTOZOOM];  //记录目前自动缩放的开关状态，恢复全览时重新设置该值
        [[MWPreference sharedInstance] setValue:PREF_AUTOZOOM Value:0];     //切换到全览要关闭自动缩放
    }
    return res;
}

/**
 **********************************************************************
 \brief 将全程概览视图恢复为原有视图
 \details 该函数用于将全程概览视图恢复为原有视图
 \param[in/out] hBackupView 备份的视图句柄
 \param[in] hView 恢复的视图句柄
 \retval	GD_ERR_OK	成功
 \retval	GD_ERR_FAILED	失败
 \remarks 视图句柄目前只支持主地图
 \since 7.0
 \see
 **********************************************************************/
+ (GSTATUS)RecoveryView:(GHMAPVIEW*)hBackupView hView:(GHMAPVIEW)hView
{
    GSTATUS res = GDBL_RecoveryView(hBackupView, hView);
    if (res == GD_ERR_OK)
    {
        [[MWPreference sharedInstance] setValue:PREF_AUTOZOOM Value:g_autoZoomValue];//modify by gzm for 恢复全览根据自动缩放是否开启，而恢复自动缩放 at 2014-10-17
    }
    return res;
}

/**
 **********************************************************************
 \brief 设置建筑的高度比例
 \details 该函数用于设置建筑的高度比例
 \param[in]	hMapView 视图句柄
 \param[in]	fRaiseRate 拔高高度的比率
 \retval	GD_ERR_OK 成功
 \retval	异常返回 GSTATUS 对应出错码
 \remarks
 \since 7.0
 \see
 **********************************************************************/
+ (GSTATUS)SetBuildingRaiseRate:(float)raiseRate
{
    //modify by gzm for 无路径下，建筑恢复 at 2014-7-30
    GHMAPVIEW phMapView = {0};
    GSTATUS res = GDBL_GetMapViewHandle(GMAP_VIEW_TYPE_MAIN, &phMapView);
    if (res == GD_ERR_OK)
    {
        int value = 0;
        GDBL_SetParam(G_MAP_SHOW_ANIMATED, &value);
        res = GDBL_SetBuildingRaiseRate(phMapView, raiseRate);
        double delayInSeconds = 0.5;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            int value = 1;
            GDBL_SetParam(G_MAP_SHOW_ANIMATED, &value);
        });
    }
    return res;
}

#pragma mark -
#pragma mark 获取图面点击poi信息
/**
 **********************************************************************
 \brief 获取图面点击poi信息
 \details 该函数用于获取图面点击poi信息
 \param[in]	point 点击的屏幕坐标 注：高清需要*2
 \retval	MWPoi	成功
 \retval	nil	无poi信息
 \remarks
 \since 6.1
 \see
 **********************************************************************/
+ (MWPoi *)getMapPoiByHitPoint:(CGPoint)point
{
    GMAPVIEW pMapview = {0};
    GSTATUS res = GDBL_GetMapView(&pMapview);
    if (res == GD_ERR_OK)
    {
        GSELECTPARAM param = {0};
        int poiCount = 0;
        param.eViewType = pMapview.eViewType;
        param.pos.x = point.x * [ANParamValue sharedInstance].scaleFactor;
        param.pos.y = point.y * [ANParamValue sharedInstance].scaleFactor;
        //点击poi图标返回信息
        param.eCmd = GSELECT_CMD_POINT;
        
        GPOI *poiList = GNULL;
        GDBL_SelectElementsByHit(&param, (void **)&poiList,&poiCount);
        if (poiCount >= 1)
        {
            MWPoi *poi = [MWPoi getMWPoiWithGpoi:poiList[0]];
            return poi;
        }
    }
    return nil;
}

/**
 **********************************************************************
 \brief 矫正地图选择角度，只有在地图模式为北首上时有效
 **********************************************************************/
+ (void)correctMapRotating
{
    GMAPVIEWINFO mapViewInfo = {0};
    GMAPVIEW pMapview = {0};
    GDBL_GetMapView(&pMapview);
    [[MWMapOperator sharedInstance] MW_GetMapViewInfo:pMapview.eViewType MapViewInfo:&mapViewInfo];
    
    GHMAPVIEW phMapView;
    GDBL_GetMapViewHandle(pMapview.eViewType, &phMapView);
    if (mapViewInfo.eMapMode == GMAPVIEW_MODE_NORTH)
    {
        GDBL_RotateMapView(phMapView, -pMapview.Angle);
    }
}
@end

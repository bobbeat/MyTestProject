//
//  MWMapOperator.h
//  AutoNavi
//
//  地图操作相关接口
//
//  Created by yu.liao on 13-7-29.
//
//

#import <Foundation/Foundation.h>

@interface MWMapOperator : NSObject
{
    GMAPVIEWINFO m_stMapViewInfo;       // 地图视图信息
    
}

@property (nonatomic, assign, readonly) NSInteger mapOperate;//返回主地图该做的操作类型(1:模拟导航 2:导航 3:查图界面设终点 4:轨迹回放 5:查图设终点－需传入poi类型，名称 7:途经点 8:点的详情界面设终点(主要为了保存点的名称) 10:路径规划原则改变和道路避让 11:多途径点确认路线 20:微享编码启动导航设终点的情况下的移图 21：微享编码启动导航移图 22:导航未开启routing调用导航默认点击接受按钮)

+(MWMapOperator *)sharedInstance;
+(void)releaseInstance;

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
-(int)MW_ShowMapView:(GMAPVIEWTYPE)eViewType WithParma1:(Gint32)param1 WithParma2:(Gint32)param2 WithParma3:(Gint32)param3;

/**********************************************************************
 * 函数名称: MW_RefreshMapView
 * 功能描述: 强制刷新一次地图视图
 * 参    数:
 * 返 回 值: 成功返回GD_ERR_OK, 失败返回对应出错码
 * 其它说明:
 **********************************************************************/
-(int)MW_RefreshMapView:(GMAPVIEWTYPE)mapViewType;

/**********************************************************************
 * 函数名称: MW_ZoomMapView
 * 功能描述: 缩放地图视图
 * 参    数: [IN] mapHandle 地图视图句柄
 *			[IN] flag 缩放标识，@see GSETMAPVIEWLEVEL
 *			[IN] level 比例级别，当nFlag为0时才有意义，参见nFlag参数。
 * 返 回 值: 成功返回GD_ERR_OK, 失败返回对应出错码
 **********************************************************************/
-(int)MW_ZoomMapView:(GMAPVIEWTYPE)eViewMap ZoomFlag:(GSETMAPVIEWLEVEL)flag ZoomLevel:(GZOOMLEVEL)level;

/**********************************************************************
 * 函数名称: MW_MoveMapView
 * 功能描述: 移图
 * 参    数: [IN] mapHandle 地图视图句柄
 *			[IN] typeCoord 结构体GMOVEMAP指针，用于标识当前移图操作类型和相关参数。
 * 返 回 值: 成功返回GD_ERR_OK, 失败返回对应出错码
 * 其它说明:
 **********************************************************************/
-(int)MW_MoveMapView:(GMAPVIEWTYPE)eViewMap TypeAndCoord:(GMOVEMAP *)typeCoord;

/**********************************************************************
 * 函数名称: MW_moveMapWithMapType
 * 功能描述: 移图(长按地图界面显示点详细信息面板时，面板位置改变时，移动地图)
 * 参    数: [IN] mapType 视图结构体类型
 *			[IN] flag 面板移动类型
 [IN] point 查看的poi屏幕坐标
 * 返 回 值: 成功返回GD_ERR_OK, 失败返回对应出错码
 * 其它说明:
 **********************************************************************/
- (int)MW_moveMapWithMapType:(GMAPVIEWTYPE)mapType Flag:(int)flag Point:(CGPoint)point;

/**********************************************************************
 * 函数名称: MW_RotateMapView
 * 功能描述: 旋转地图视图
 * 参    数: [IN] mapHandle 地图视图句柄
 *			[IN] bAbsolute 是否为绝对角度值，Gtrue表示xa、ya、za为绝对角度值，否则为相对角度值。
 *			[IN] xAngle、yAngle、zAngle 角度值，可以为负值。
 * 返 回 值: 成功返回GD_ERR_OK, 失败返回对应出错码
 * 其它说明:
 **********************************************************************/
-(int)MW_RotateMapView:(GMAPVIEWTYPE)eViewMap bAbsolute:(Gbool)bAbsolute WithX:(Gfloat32)xAngle WithY:(Gfloat32)yAngle WithZ:(Gfloat32)zAngle;

/**********************************************************************
 * 函数名称: MW_AdjustCar
 * 功能描述: 调整车位
 * 参    数: [IN] eViewMap 地图类型
 *			[IN] coord 经纬度
 *			[IN] angle 车位角度
 * 返 回 值: 成功返回GD_ERR_OK, 失败返回对应出错码
 * 其它说明:
 **********************************************************************/
-(int)MW_AdjustCar:(GMAPVIEWTYPE)eViewMap Gcoord:(GCOORD)coord Angle:(Gint32)angle;

/**********************************************************************
 * 函数名称: MW_SetMapViewMode
 * 功能描述: 切换地图视图模式
 * 参    数: [IN] mapHandle 地图视图句柄
 *			[IN] type 模式标识，-1前一个模式，0切换到eMapViewMode模式，1下一个模式。
 *			[IN] mapMode 视图模式，当type为0时才有意义，参见type参数说明。
 * 返 回 值: 成功返回GD_ERR_OK, 失败返回对应出错码
 * 其它说明:
 **********************************************************************/
-(int)MW_SetMapViewMode:(GMAPVIEWTYPE)eViewMap Type:(Gint32)type MapMode:(GMAPVIEWMODE)mapMode;

/**********************************************************************
 * 函数名称: MW_ResetMapView
 * 功能描述: 重置地图视图
 * 参    数: [IN] mapHandle 地图视图句柄
 *			[IN] mapFlag 需要重置的参数，参见GMAPVIEWFLAG枚举类型。
 * 返 回 值: 成功返回GD_ERR_OK, 失败返回对应出错码
 * 其它说明:
 **********************************************************************/
-(int)MW_ResetMapView:(GMAPVIEWTYPE)eViewMap MapFlag:(GMAPVIEWFLAG)mapFlag;

/**********************************************************************
 * 函数名称: MW_SetMapOperateType
 * 功能描述: 设置地图操作类型
 * 参    数: [IN] type 地图操作类型
 * 返 回 值: 成功返回GD_ERR_OK, 失败返回对应出错码
 * 其它说明:
 **********************************************************************/
- (void)MW_SetMapOperateType:(NSInteger)type;


/**********************************************************************
 * 函数名称: MW_SetMapViewVRect
 * 功能描述: 设置地图竖屏区域
 * 参    数: [IN] V_Rect 竖屏区域
 * 返 回 值:
 * 其它说明:
 **********************************************************************/
- (void)MW_SetMapViewVRect:(CGRect)V_Rect;

/**********************************************************************
 * 函数名称: MW_SetMapViewHRect
 * 功能描述: 设置地图横屏区域
 * 参    数: [IN] H_Rect 横屏区域
 * 返 回 值:
 * 其它说明:
 **********************************************************************/
- (void)MW_SetMapViewHRect:(CGRect)H_Rect;

/**********************************************************************
 * 函数名称: MW_GoToCCP
 * 功能描述: 回车位
 * 参    数:
 * 返 回 值:
 * 其它说明:
 **********************************************************************/
- (void)MW_GoToCCP;

/**********************************************************************
 * 函数名称: MW_GetMapViewHandle
 * 功能描述: 获取指定地图视图句柄
 * 参    数: [IN] eViewType 枚举GMAPVIEWTYPE类型，用于指定视图类型。
 *			[OUT] mapHandle 地图视图句柄
 * 返 回 值: 成功返回GD_ERR_OK, 失败返回对应出错码
 * 其它说明: 1、地图视图句柄是用来管理地图视图的，使用该句柄可以进行地图
 *			视图的缩放、移图、模式切换等操作。
 **********************************************************************/
-(int)MW_GetMapViewHandle:(GMAPVIEWTYPE)eViewMap MapHandle:(GHMAPVIEW *)mapHandle;

/**********************************************************************
 * 函数名称: MW_GetMapViewInfo
 * 功能描述: 获取当前地图信息(地图类型,地图中心,地图模式,地图角度,地图仰角,对应的比例数值,比例级别)
 * 参    数: [IN] eViewType 枚举GMAPVIEWTYPE类型，用于指定视图类型。
 *			[OUT] mapViewInfo 当前地图信息
 * 返 回 值: 成功返回GD_ERR_OK, 失败返回对应出错码
 * 其它说明:
 **********************************************************************/
-(int)MW_GetMapViewInfo:(GMAPVIEWTYPE)eViewMap MapViewInfo:(GMAPVIEWINFO *)mapViewInfo;

/**********************************************************************
 * 函数名称: MW_SaveInfoForCurrrentMapView
 * 功能描述: 缓存当前地图信息
 * 参    数:
 * 返 回 值:
 * 其它说明:
 **********************************************************************/
- (void)MW_SaveInfoForCurrrentMapView;

/**********************************************************************
 * 函数名称: MW_CheckIfChangeOnMapViewInfo
 * 功能描述: 判断是否有移图
 * 参    数:
 * 返 回 值: YES:有移图 NO:无移图
 * 其它说明: 对比缓存的地图信息判断是否有移图
 **********************************************************************/
- (BOOL)MW_CheckIfChangeOnMapViewInfo;

/**********************************************************************
 * 函数名称: MW_GetMapViewCenterInfo
 * 功能描述: 获取地图中心点信息
 * 参    数: [IN] eViewType 枚举GMAPVIEWTYPE类型，用于指定视图类型。
 *			[OUT] pMapCenterInfo 当前地图中心点信息
 * 返 回 值: 成功返回GD_ERR_OK, 失败返回对应出错码
 * 其它说明:
 **********************************************************************/
-(int)MW_GetMapViewCenterInfo:(GMAPVIEWTYPE)eViewMap mapCenterInfo:(GMAPCENTERINFO *)pMapCenterInfo;

/**********************************************************************
 * 函数名称: MW_ZoomTo
 * 功能描述: 缩放到指定级别比例尺
 * 参    数: [IN] level 比例尺级别
 [IN] animated 是否有动画
 * 返 回 值:
 * 其它说明:
 **********************************************************************/
-(void)MW_ZoomTo:(GZOOMLEVEL)level Animated:(BOOL)animated;


/**********************************************************************
 * 函数名称: GMD_GetCarInfo
 * 功能描述: 获取当前车位信息
 * 参    数: GCARINFO
 * 返 回 值: GD_ERR_OK:获取成功   else —— 获取失败
 * 其它说明:
 **********************************************************************/
- (GSTATUS)GMD_GetCarInfo:(GCARINFO *)carInfo;

#pragma mark 获取当前引导路径路径引导颜色数组
/**********************************************************************
 * 函数名称: GMD_GetGuideRouteColorContent
 * 功能描述: 获取当前引导路径路径引导颜色数组
 * 参    数:
 * 返 回 值: 引导颜色数组
 * 其它说明:
 **********************************************************************/
- (NSMutableArray *)GMD_GetGuideRouteColorContent;

/**********************************************************************
 * 函数名称: GMD_GetCurDrawMapViewTypeWithLon
 * 功能描述: 根据经纬度获取当前绘制地图类型
 * 参    数: lon:经度  lat:纬度
 * 返 回 值: 0－离线地图 1－在线地图 ，判断比例尺
 * 其它说明:
 **********************************************************************/
-(int)GMD_GetCurDrawMapViewTypeWithLon:(long)lon Lat:(long)lat;


/**********************************************************************
 * 函数名称: GMD_Get3DScale
 * 功能描述: 获取3D仰角
 * 参    数: 
 * 返 回 值:int:仰角
 * 其它说明:
 **********************************************************************/
-(int)GMD_Get3DScale;

/**********************************************************************
 * 函数名称: GMD_GetCurrentRoadName
 * 功能描述: 获取当前道路名
 * 参    数:mapViewType 视图类型
 * 返 回 值:道路名
 * 其它说明:
 **********************************************************************/
- (NSString *)GetCurrentRoadName:(GMAPVIEWTYPE)mapViewType;

/**********************************************************************
 * 函数名称: GetCarDirection
 * 功能描述: 获取地图角度
 * 参    数:mapViewType 视图类型
 * 返 回 值:地图角度
 * 其它说明:
 **********************************************************************/
- (int)GetCarDirection:(GMAPVIEWTYPE)mapViewType;

/**********************************************************************
 * 函数名称: GetMapScaleLevelWithType
 * 功能描述: 获取当前的比例尺状态
 * 参    数:mapViewType 视图类型
 * 返 回 值:比例尺状态
 * 其它说明:
 **********************************************************************/
-(GZOOMLEVEL)GetMapScaleLevelWithType:(GMAPVIEWTYPE) nMapViewType;

/**********************************************************************
 * 函数名称: GetCurrentScale
 * 功能描述: 获取当前的比例尺字符串 带单位（km or m）
 * 返 回 值: 比例尺字符串
 * 其它说明:
 **********************************************************************/
- (NSString *)GetCurrentScale;

- (NSString *)GetScaleWith:(GZOOMLEVEL)pValue;
#pragma mark 查看路口(参数为索引值)
/**********************************************************************
 * 函数名称: MW_ViewCrossWithID
 * 功能描述: 查看路口(参数为索引值)
 * 参    数:
 * 返 回 值:
 * 其它说明:
 **********************************************************************/
+ (void)ViewCrossWithID:(int)ID;

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
+ (GSTATUS)ViewToOverView:(GHMAPVIEW)hView pstParams:(GOVERVIEWPARAMS *)pstParams hBackupView:(GHMAPVIEW *)hBackupView;

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
+ (GSTATUS)RecoveryView:(GHMAPVIEW*)hBackupView hView:(GHMAPVIEW)hView;

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
+ (GSTATUS)SetBuildingRaiseRate:(float)raiseRate;

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
+ (MWPoi *)getMapPoiByHitPoint:(CGPoint)point;


/**
 **********************************************************************
 \brief 矫正地图选择角度，只有在地图模式为北首上时有效
 **********************************************************************/
+ (void)correctMapRotating;
@end

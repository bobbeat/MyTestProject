//
//  MWRouteCalculate.h
//  AutoNavi
//
//  Created by gaozhimin on 14-5-20.
//
//

#import <Foundation/Foundation.h>

/*
 * @brief 路径演算回调
 * @param  result: GSTATUS错误码(GD_ERR_OK, GD_ERR_OP_CANCELED, ...)
 * @param  guideType: 0 - 单路径计算
 *		  1 - 多路径计算
 *		  2 - 偏航重算
 *          或者为 ghGuideRoute: 返回的引导路径(GHGUIDEROUTE结构)
 */
@protocol RouteCalDelegate <NSObject>

- (void)RouteCalResult:(GSTATUS)result guideType:(long)guideType calType:(GCALROUTETYPE)calType;

@end

@interface MWRouteCalculate : NSObject
{
    BOOL                 isSelected;
}

@property (nonatomic, assign) GJOURNEYPOINTTYPE m_journeyType; //当前添加点的类型
@property (nonatomic,assign) BOOL isSelected;

+ (instancetype)SharedInstance;

/*
 * @brief 是否提示确实城市
 * @param isTip YES提示 NO不提示 注：设置为no后只单次有效
 */
+ (void)setIsTipMissingCity:(BOOL)isTip;

/*
 * @brief 设置终点或者途径点
 * @param poi 设置的poi点
 * @param poiType 演算类型 @see GJOURNEYPOINTTYPE
 * @param calType 演算类型 @see GCALROUTETYPE
 */
+ (BOOL)setDesWithPoi:(GPOI)poi poiType:(GJOURNEYPOINTTYPE)poiType calType:(GCALROUTETYPE)calType;


/*
 * @brief 设置演算Delegate
 * @param Delegate
 */
+ (void)setDelegate:(id<RouteCalDelegate>)delegate;

/*
 * @brief 回公司
 */
+ (BOOL)GoCompany;
/*
 * @brief 回家
 */
+ (BOOL)GoHome;

/**
 **********************************************************************
 \brief 将车标切换到其平行道路上
 \details 该函数用于将车标切换到其平行道路上
 \param[in] pObjectId 平行道路ID
 \retval	GD_ERR_OK	成功
 \retval	GD_ERR_INVALID_PARAM	参数无效
 \since 6.0
 \see GDBL_GetCarParallelRoads
 **********************************************************************/
+ (GSTATUS)ChangeCarRoad:(GOBJECTID *)pObjectId;

/**
 **********************************************************************
 \brief 获取平行道路
 **********************************************************************/
+ (NSMutableArray *)GetCarParallelRoads;

/**********************************************************************
 * 函数名称: startRouteCalculation
 * 功能描述: 启动路径规划
 * 返 回 值: 成功返回GD_ERR_OK, 失败返回对应出错码
 **********************************************************************/
+ (GSTATUS)StartRouteCalculation:(GCALROUTETYPE)euCalType;

/**********************************************************************
 * 函数名称: MW_wayPointCalcRoute
 * 功能描述: 设终点(多途径点)
 * 参    数: pointArray 行程点数组
 * 返 回 值:
 * 其它说明:
 **********************************************************************/
+ (GSTATUS) wayPointCalcRoute:(NSMutableArray *)pointArray bResetCarPosition:(BOOL)bResetCarPosition;

/**********************************************************************
 * 函数名称: SetStartingPoint
 * 功能描述: 设起点（以当前地图中心点为起点）
 * 参    数:
 * 返 回 值:
 * 其它说明:
 **********************************************************************/
+ (void)SetStartingPoint;

/**********************************************************************
 * 函数名称: GetRoadOption
 * 功能描述: 获取路径句柄的规划原则
 * 参   数: hGuideRoute 传入的路径句柄
 **********************************************************************/
+ (GROUTEOPTION)GetRoadOption:(GHGUIDEROUTE)hGuideRoute;

/**********************************************************************
 * 函数名称: GetComposeOptions
 * 功能描述: 获取路径句柄的所有规划原则
 * 参   数: hGuideRoute 传入的路径句柄
 **********************************************************************/
+ (NSArray *)GetComposeOptions:(GHGUIDEROUTE)hGuideRoute;

/*
 * @brief 设置选择的道路句柄，即StartGuide前调用，用于修改existRouteHandler
 */
+ (void)SetExistRouteGuideHandler;
@end

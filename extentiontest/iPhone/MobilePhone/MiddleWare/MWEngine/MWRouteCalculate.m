//
//  MWRouteCalculate.m
//  AutoNavi
//
//  Created by gaozhimin on 14-5-20.
//
//

#import "MWRouteCalculate.h"
#import "MWPoiOperator.h"
#import "DefineNotificationParam.h"
#import "GDProgressObject.h"
#import "CheckMapDataObject.h"
#import "QLoadingView.h"
#import "MWTTS.h"

Class object_getClass(id object);

Gint32 GetJunyPointRoadInfo(GROADINFO *pRoadInfo, Gint32 nNumberOfRoadInfo, void *lpVoid);

#define RouteCal_MaxRouteCount 4

static int existRouteHandler = 0;  //最低位表示，推荐，依次为：高速，经济，最短
static GHGUIDEROUTE existRouteHandlerList[RouteCal_MaxRouteCount] = {0};  //依次为：推荐,高速，经济，最短

static BOOL g_isTipMissingCity = YES;

static NSMutableDictionary *g_composeOptionsDic = nil;

@interface MWRouteCalculate()
{
    int                  _alertRouteChoeseCount;    //弹出选择道路框的个数
@public
    GCALROUTETYPE     _calRouteType;                       //路径演算类型
}

@property (nonatomic,assign) BOOL isSelectedNormal;
@property (nonatomic,assign) BOOL isChooseRoad;
@property (nonatomic,assign) id<RouteCalDelegate> delegate;           //路径演算block
@property (nonatomic,assign) Class originalClass;

@end

@implementation MWRouteCalculate

@synthesize m_journeyType,isSelected,isSelectedNormal,isChooseRoad,delegate,originalClass;

+ (instancetype)SharedInstance
{
    static BOOL RouteSetPointCB = NO; //是否已成功设置引擎回调函数
    if (!RouteSetPointCB)
    {
        if (isEngineInit) //引擎是否已初始化，初始化后才能调用GDBL函数,防止崩溃
        {
            RouteSetPointCB = YES;
            GDBL_SetAddJourneyPointCB(GetJunyPointRoadInfo,NULL);
        }
    }
    
    static MWRouteCalculate *routeCalculate = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        routeCalculate = [[MWRouteCalculate alloc] init];
    });
    return routeCalculate;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(routeListenNotification:) name:NOTIFY_STARTTODEMO object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(routeListenNotification:) name:NOTIFY_STARTTODEMO2 object:nil];
        isSelected = YES;
        g_composeOptionsDic = [[NSMutableDictionary alloc] init];
    }
    return self;
}

-(void)dealloc
{
    CRELEASE(g_composeOptionsDic);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

#pragma mark -
#pragma mark - public method

/*
 * @brief 是否提示确实城市
 * @param isTip YES提示 NO不提示 注：设置为no后只单次有效
 */
+ (void)setIsTipMissingCity:(BOOL)isTip
{
    g_isTipMissingCity = isTip;
}

/*
 * @brief 设置终点或者途径点
 * @param poi 设置的poi点
 * @param poiType 演算类型 @see GJOURNEYPOINTTYPE
 * @param calType 演算类型 @see GCALROUTETYPE
 */
+ (BOOL)setDesWithPoi:(GPOI)poi poiType:(GJOURNEYPOINTTYPE)poiType calType:(GCALROUTETYPE)calType;
{
    return [[MWRouteCalculate SharedInstance] CalRouteWithPoi:poi poiType:poiType calType:calType bClearJourney:YES];
}

/*
 * @brief 设置演算Delegate
 * @param Delegate
 */
+ (void)setDelegate:(id<RouteCalDelegate>)delegate
{
    [MWRouteCalculate SharedInstance].delegate = delegate;
    [MWRouteCalculate SharedInstance].originalClass = object_getClass(delegate);
}

/*
 * @brief 回公司
 */
+ (BOOL)GoCompany
{
    GFAVORITEPOILIST  *ppFavoritePOIList = {0};
	
	GSTATUS res;
	res = GDBL_GetFavoriteList(GFAVORITE_CATEGORY_COMPANY, &ppFavoritePOIList);
	if (res!=0)
	{
		return NO;
	}
    [MWRouteCalculate setDesWithPoi:ppFavoritePOIList->pFavoritePOI[0].Poi poiType:GJOURNEY_GOAL calType:GROU_CAL_MULTI];
    return YES;
}
/*
 * @brief 回家
 */
+ (BOOL)GoHome
{
    GFAVORITEPOILIST  *ppFavoritePOIList = {0};
	
	GSTATUS res;
	res = GDBL_GetFavoriteList(GFAVORITE_CATEGORY_HOME, &ppFavoritePOIList);
	if (res!=0)
	{
		return NO;
	}
    [MWRouteCalculate setDesWithPoi:ppFavoritePOIList->pFavoritePOI[0].Poi poiType:GJOURNEY_GOAL calType:GROU_CAL_MULTI];
    return YES;
}

/**
 **********************************************************************
 \brief 将车标切换到其平行道路上
 \details 该函数用于将车标切换到其平行道路上
 \param[in] pObjectId 平行道路ID
 \retval	GD_ERR_OK	成功
 \retval	GD_ERR_INVALID_PARAM	参数无效
 **********************************************************************/
+ (GSTATUS)ChangeCarRoad:(GOBJECTID *)pObjectId
{
    GSTATUS res = GDBL_ChangeCarRoad(pObjectId);
    if (res == GD_ERR_OK)
    {
        [MWRouteCalculate AddRouteCalView]; //添加转圈的界面
    }
    return res;
}


/**
 **********************************************************************
 \brief 获取平行道路
 **********************************************************************/
+ (NSMutableArray *)GetCarParallelRoads
{
    NSMutableArray *ParaleRoadArray = [[NSMutableArray alloc] init];
    GCARPARALLELROAD *ppCarParallelRoads;
    Guint32 nNumberOfCarParallelRoad = 0;
    GSTATUS res = GDBL_GetCarParallelRoads(&ppCarParallelRoads,&nNumberOfCarParallelRoad);
    if (res == GD_ERR_OK)
    {
        for (int i=0; i<nNumberOfCarParallelRoad; i++)
        {
            plugin_PoiNode *node = [[plugin_PoiNode alloc] init];
            
            node.stPoiId = ppCarParallelRoads[i].stObjectId;
            if (StrlenWithGchar(ppCarParallelRoads[i].szRoadName))
            {
                node.szName = GcharToNSString(ppCarParallelRoads[i].szRoadName);
            }
            else
            {
                node.szName = STR(@"Main_unNameRoad", Localize_Main);
            }
            
            [ParaleRoadArray addObject:node];[node release];
        }
        
    }
    return [ParaleRoadArray autorelease];
}

/**********************************************************************
 * 函数名称: startRouteCalculation
 * 功能描述: 启动路径规划
 * 返 回 值: 成功返回GD_ERR_OK, 失败返回对应出错码
 **********************************************************************/
+ (GSTATUS)StartRouteCalculation:(GCALROUTETYPE)euCalType
{
    [MWRouteCalculate SharedInstance]->_calRouteType = euCalType;
    GSTATUS res = GDBL_StartRouteCalculation(euCalType);
    if (res == GD_ERR_OK)
    {
        [MWRouteCalculate AddRouteCalView]; //添加转圈的界面
    }
    return res;
}

/**********************************************************************
 * 函数名称: GetRoadOption
 * 功能描述: 获取路径句柄的规划原则
 * 参   数: hGuideRoute 传入的路径句柄
 **********************************************************************/
+ (GROUTEOPTION)GetRoadOption:(GHGUIDEROUTE)hGuideRoute
{
    GROUTEOPTION routeOption = GROUTE_OPTION_RECOMMAND;
    if (hGuideRoute == NULL)
    {
        return routeOption;
    }
    GHGUIDEROUTE guideRoute[4] = {0};
    int routeCount = 0;
    [MWRouteGuide GetGuideRouteList:guideRoute count:4 returnCount:&routeCount];
    
    
    for (int i = 0; i < routeCount; i++)
    {
        if (hGuideRoute == guideRoute[i])
        {
            int sign = 0;
            for (int j = 0; j < 4; j++)
            {
                if (j != 0)
                {
                    routeOption ++;
                }
                if ((existRouteHandler & (0x01 << j)))
                {
                    if (sign == i)
                    {
                        break;
                    }
                    sign ++;
                }
            }
            break;
        }
    }
    return routeOption;
}

/**********************************************************************
 * 函数名称: GetComposeOptions
 * 功能描述: 获取路径句柄的所有规划原则
 * 参   数: hGuideRoute 传入的路径句柄
 **********************************************************************/
+ (NSArray *)GetComposeOptions:(GHGUIDEROUTE)hGuideRoute
{
    GROUTEOPTION routeOption = GROUTE_OPTION_RECOMMAND;
    if (hGuideRoute == NULL)
    {
        return [NSArray arrayWithObject:[NSNumber numberWithInt:routeOption]];
    }
    
    NSNumber *number = [NSNumber numberWithInt:hGuideRoute];
    NSArray *array = [g_composeOptionsDic objectForKey:number];
    if (array)
    {
        return array;
    }
    else
    {
        GROUTEOPTION option = [MWRouteCalculate GetRoadOption:hGuideRoute];
        return [NSArray arrayWithObject:[NSNumber numberWithInt:option]];
    }
}

#pragma mark -
#pragma mark 以下下接口包含逻辑
#pragma mark 添加转圈，路径计算中
+ (void)AddRouteCalView
{
    [GDProgressObject ShowProgressWith:STR(@"Route_CalcProgress", Localize_RouteOverview)];
}

#pragma mark 设终点（多途径点）
/**********************************************************************
 * 函数名称: MW_wayPointCalcRoute
 * 功能描述: 设终点(多途径点)
 * 参    数: pointArray 行程点数组
 * 返 回 值:
 * 其它说明:
 **********************************************************************/
+ (GSTATUS) wayPointCalcRoute:(NSMutableArray *)pointArray bResetCarPosition:(BOOL)bResetCarPosition
{
    int arrayCount = pointArray ? pointArray.count : 0;
    for (int i = 0 ; i < arrayCount ; i++) {
        MWPoi *tmpPOI = [pointArray objectAtIndex:i];
        for (int j = i+1; j < arrayCount ; j++) {
            MWPoi *_tmpPOI = [pointArray objectAtIndex:j];
            if (tmpPOI.longitude == _tmpPOI.longitude && tmpPOI.latitude == _tmpPOI.latitude && _tmpPOI.longitude != 0 && _tmpPOI.latitude != 0 && !((arrayCount > 2) && (i == 0) && (j == arrayCount - 1))) {
                [POICommon showAutoHideAlertView:STR(@"Route_calcFail", Localize_RouteOverview)];
                return GD_ERR_INVALID_PARAM;
            }
        }
    }
    if (!pointArray || pointArray.count == 0) {
        return GD_ERR_INVALID_PARAM;
    }
    NSMutableArray *_arrayTableData = [NSMutableArray arrayWithArray:pointArray];
    //没有输入起点
    if(((MWPoi *)[_arrayTableData objectAtIndex:0]).latitude == 0
       && ((MWPoi *)[_arrayTableData objectAtIndex:0]).longitude == 0)
    {
        GDAlertView *alertView=[[[GDAlertView alloc] initWithTitle:nil andMessage:STR(@"Main_inputStart", Localize_Main)] autorelease];
        [alertView addButtonWithTitle:STR(@"Universal_ok", Localize_Universal) type:GDAlertViewButtonTypeCancel handler:nil];
        [alertView show];
        
        return GD_ERR_INVALID_PARAM;
    }
    //没有输入终点
    if(((MWPoi *)[_arrayTableData lastObject]).latitude == 0
       && ((MWPoi *)[_arrayTableData lastObject]).longitude == 0)
    {
        GDAlertView *alertView=[[[GDAlertView alloc] initWithTitle:nil andMessage:STR(@"Main_inputDes", Localize_Main)] autorelease];
        [alertView addButtonWithTitle:STR(@"Universal_ok", Localize_Universal) type:GDAlertViewButtonTypeCancel handler:nil];
        [alertView show];
        return GD_ERR_INVALID_PARAM;
    }
    //每次计算前，删除所有的点
    GSTATUS sign = GD_ERR_OK;  //用于记录起点，途经点是否有数据
    GDBL_ClearJourneyPoint();
    GSTATUS res;
    GPOI PointInfo = {0};
    
    [MWPoiOperator MWPoiToGPoi:((MWPoi *)[_arrayTableData objectAtIndex:0]) GPoi:&PointInfo];
    
    //设起点
    MWPoi *mwpoi = [MWPoi getMWPoiWithGpoi:PointInfo];
    res = [MWJourneyPoint AddJourneyPointWith:mwpoi type:GJOURNEY_START option:0];
    if(res == GD_ERR_OK && bResetCarPosition)  //是否重新设置车位，在已有路径情况下若重新设置车位，车标会先偏离路线
    {
        [[MWMapOperator sharedInstance] MW_AdjustCar:GMAP_VIEW_TYPE_MAIN Gcoord:PointInfo.Coord Angle:0];
    }
    else if (res == GD_ERR_NO_DATA)
    {
        sign = GD_ERR_NO_DATA;
    }

    
    //添加途径点
    for (int i = 1 ; i < _arrayTableData.count-1; i++) {
        if(((MWPoi *)[_arrayTableData objectAtIndex:i]).latitude != 0
           && ((MWPoi *)[_arrayTableData objectAtIndex:i]).longitude != 0)
        {
            GPOI wayPointInfo = {0};
            
            [MWPoiOperator MWPoiToGPoi:((MWPoi *)[_arrayTableData objectAtIndex:i]) GPoi:&wayPointInfo];
            
            //设途经点
            MWPoi *mwpoi = [MWPoi getMWPoiWithGpoi:wayPointInfo];
            res = [MWJourneyPoint AddJourneyPointWith:mwpoi type:i option:0];
            if(res == GD_ERR_OK)
            {
                NSLog(@"----------途经点***%d***路径添加成功",i);
            }
            else if (res == GD_ERR_NO_DATA)
            {
                sign = GD_ERR_NO_DATA;
            }
        }
    }
    //设终点
    if (sign == GD_ERR_NO_DATA) //如果起点途经点无数据，直接获取缺失城市列表
    {
        MWPoi *mwpoi = (MWPoi *)[_arrayTableData lastObject];
        [MWJourneyPoint AddJourneyPointWith:mwpoi type:GJOURNEY_GOAL option:0];
        [[MWRouteCalculate SharedInstance] Dealresult:sign guideType:0 calType:GROU_CAL_MULTI];
    }
    else
    {
    GPOI desPointInfo = {0};
    [MWPoiOperator MWPoiToGPoi:((MWPoi *)[_arrayTableData lastObject]) GPoi:&desPointInfo];
    [[MWRouteCalculate SharedInstance] CalRouteWithPoi:desPointInfo poiType:GJOURNEY_GOAL calType:GROU_CAL_MULTI bClearJourney:NO];
    }
    
    return GD_ERR_OK;
    
}

#pragma mark 设起点（以当前地图中心点为起点）
/**********************************************************************
 * 函数名称: SetStartingPoint
 * 功能描述: 设起点（以当前地图中心点为起点）
 * 参    数:
 * 返 回 值:
 * 其它说明:
 **********************************************************************/
+ (void)SetStartingPoint
{
    
    //获取地图中心信息
    GMAPCENTERINFO mapinfo = {0};
    [[MWMapOperator sharedInstance] MW_GetMapViewCenterInfo:GMAP_VIEW_TYPE_MAIN mapCenterInfo:&mapinfo];
    
    GDBL_ClearJourneyPoint();
    GPOI PointInfo = {0};
    PointInfo.Coord = mapinfo.CenterCoord;
    
    GSTATUS res;
    MWPoi *mwpoi = [MWPoi getMWPoiWithGpoi:PointInfo];
    res = [MWJourneyPoint AddJourneyPointWith:mwpoi type:GJOURNEY_START option:0];
    if (GD_ERR_OK==res)
    {
        if ([[ANParamValue sharedInstance] isPath])
        {
            GSTATUS res;
            res = [MWRouteGuide StopGuide:Gfalse];
            if (GD_ERR_OK==res)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_STOPGUIDANCE object:nil];
            }
        }
        [[MWMapOperator sharedInstance] MW_AdjustCar:GMAP_VIEW_TYPE_MAIN Gcoord:mapinfo.CenterCoord Angle:0];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_BEGINPOINT object:nil];
    }
    else
    {
        DefineNotificationParam *msg = [[DefineNotificationParam alloc] init];
        msg.flag = 1;
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_INVALIDPOSITION object:msg];
        [msg release];
    }
}


/*
 * @brief 设置选择的道路句柄，即StartGuide前调用，用于修改existRouteHandler
 */

+ (void)SetExistRouteGuideHandler
{
    GROUTEOPTION option = [MWRouteCalculate GetRoadOption:[MWRouteGuide getCurrentRouteHandler]];
    existRouteHandler = existRouteHandler & (0x01 << option);
}

#pragma mark -
#pragma mark - private method

- (void)missingCityCancelHandler:(MWPoi*)poi
{
    GPOI gpoi = {0};
    [MWPoi MWPoiToGPoi:poi GPoi:&gpoi];
    [MWPoiOperator collectPoiWith:GFAVORITE_CATEGORY_HISTORY icon:GFAVORITE_ICON_HISTORY poi:gpoi];
    if (isSelected )
    {
        [MWRouteGuide StopGuide:Gfalse];//每次设终点计算前都删除旧路线
        GDBL_ClearDetourRoad();//删除所有避让内容
        GSTATUS res = [MWRouteCalculate StartRouteCalculation:_calRouteType];
        if (res != GD_ERR_OK)
        {
            [self Dealresult:res guideType:0 calType:GROU_CAL_MULTI];
        }
    }
}
/*
 * @brief 设置终点或者途径点
 * @param poi 设置的poi点
 * @param poiType 演算类型 @see GJOURNEYPOINTTYPE
 * @param calType 演算类型 @see GCALROUTETYPE
 */
- (BOOL)CalRouteWithPoi:(GPOI)poi poiType:(GJOURNEYPOINTTYPE)poiType calType:(GCALROUTETYPE)calType bClearJourney:(BOOL)bClearJourney;
{
    _calRouteType = calType;
    m_journeyType = poiType;
    
    //add by gzm for 设终点时，需清空行程点 at 2014-7-23
    if (poiType == GJOURNEY_GOAL && bClearJourney)
    {
        [MWJourneyPoint ClearJourneyPoint];
        
        //modify by gzm for 设置途经点时不要判断终点距离小于150 at 2014-8-04
        MWPoi *startPoi = [MWJourneyPoint getJourneyPointWithID:0];
        MWPoi *mwpoi = [MWPoi getMWPoiWithGpoi:poi];
        GCOORD coordStart = {0};
        if (startPoi.longitude == 0 && startPoi.latitude == 0) //若无起点行程点，则获取车位点。
        {
            GCARINFO pCarInfo = {0};
            GDBL_GetCarInfo(&pCarInfo);
            coordStart = pCarInfo.Coord;
        }
        else
        {
            coordStart.x = startPoi.longitude;
            coordStart.y = startPoi.latitude;
        }
        
        GCOORD endStart = {0};
        endStart.x = mwpoi.longitude;
        endStart.y = mwpoi.latitude;
        if ([MWEngineTools CalcDistanceFrom:coordStart To:endStart] < 150)
        {
            [self Dealresult:GD_ERR_TOO_NEAR guideType:0 calType:_calRouteType];
            return NO;
        }
        //modify by gzm for 设置途经点时不要判断终点距离小于150 at 2014-8-04
    }
    //add by gzm for 设终点时，需清空行程点 at 2014-7-23
    MWPoi *mwpoi = [MWPoi getMWPoiWithGpoi:poi];

    GSTATUS res = [MWJourneyPoint AddJourneyPointWith:mwpoi type:poiType option:0];
    if (res == GD_ERR_OK)
    {
        NSArray *missingArray = [MWRouteGuide GetRouteErrorInfo];
        long missingCount = [missingArray count];
        if (missingCount > 0)
        {
            [CheckMapDataObject setNotFitcal:YES];
            int *missingCityAdmincode = malloc(sizeof(int) * missingCount);
            for (int i = 0; i < missingCount; i++)
            {
                MWAreaInfo *info = [missingArray objectAtIndex:i];
                missingCityAdmincode[i] = info.lAdminCode;
            }
            __block MWRouteCalculate *weakself = self;
            [CheckMapDataObject TipTheMissingCity:missingCityAdmincode missingCount:missingCount bRoute:YES cancelHandler:^(GDAlertView *alertView) {
                [weakself missingCityCancelHandler:mwpoi];
            }];
            if (missingCityAdmincode)
            {
                free(missingCityAdmincode);
            }
        }
        else
        {
            [MWPoiOperator collectPoiWith:GFAVORITE_CATEGORY_HISTORY icon:GFAVORITE_ICON_HISTORY poi:poi];
            if (isSelected )
            {
                [MWRouteGuide StopGuide:Gfalse];//每次设终点计算前都删除旧路线
                GDBL_ClearDetourRoad();//删除所有避让内容
                res = [MWRouteCalculate StartRouteCalculation:_calRouteType];
                if (res != GD_ERR_OK)
                {
                    [self Dealresult:res guideType:0 calType:GROU_CAL_MULTI];
                    return NO;
                }
            }
        }
    }
    else if (res == GD_ERR_NO_DATA)  //添加终点失败，无需调用演算接口，直接获取缺失城市列表
    {
        if (isSelected )
        {
            [self Dealresult:res guideType:0 calType:GROU_CAL_MULTI];
            return NO;
        }
    }
    else
    {//路线演算失败
        [self Dealresult:GD_ERR_FAILED guideType:0 calType:_calRouteType];
        return NO;
    }
    return YES;

}

- (void)Dealresult:(GSTATUS)res guideType:(long)guideType calType:(GCALROUTETYPE)calType
{
    if (res == GD_ERR_NO_DATA || res == GD_ERR_NO_ROUTE)  //提示缺失城市
    {
        NSArray *missingArray = [MWRouteGuide GetRouteErrorInfo];
        int missingCount = (int)[missingArray count];
        if (missingCount > 0 && g_isTipMissingCity)
        {
            int *missingCityAdmincode = malloc(sizeof(int) * missingCount);
            for (int i = 0; i < missingCount; i++)
            {
                MWAreaInfo *info = [missingArray objectAtIndex:i];
                missingCityAdmincode[i] = info.lAdminCode;
            }
            [CheckMapDataObject TipTheMissingCity:missingCityAdmincode missingCount:missingCount bRoute:YES cancelHandler:nil];
            if (missingCityAdmincode)
            {
                free(missingCityAdmincode);
            }
        }
        else
        {
            g_isTipMissingCity = YES;
            res = GD_ERR_FAILED;  //若是获取不到缺失城市，则提示演算失败
        }
    }
    else if (res == GD_ERR_TOO_NEAR) //距离太近
    {
        [QLoadingView showAlertWithoutClick:STR(@"Main_distanceTooShort", Localize_Main) ShowTime:2.0];
    }
    
    Class currentClass = object_getClass(self.delegate);
    if (currentClass == self.originalClass)
    {
        if ([delegate respondsToSelector:@selector(RouteCalResult:guideType:calType:)])
        {
            [delegate RouteCalResult:res guideType:guideType calType:calType];
        }
    }
    else
    {
        NSLog(@"delegate dealloc");
    }
}
#pragma mark -
#pragma mark notify method

- (void)routeListenNotification:(NSNotification *)notification
{
    NSArray* param = nil;
    param = notification.object;
    if ([notification.name isEqualToString:NOTIFY_STARTTODEMO2] || [notification.name isEqualToString:NOTIFY_STARTTODEMO])
    {
        [GDProgressObject HideenProgress];
        GSTATUS res = [[param objectAtIndex:1] intValue];
        long handlerType = [[param objectAtIndex:0] longValue];
        if (res == GD_ERR_IN_PROCESS) //偏航会返回该值，需要return，不执行下面步骤，否则会偏航失败。
        {
            return;
        }
        
        [g_composeOptionsDic removeAllObjects]; //每次演算路径都删除了 对应的路径句柄的规划原则
        
        if (handlerType == 2 || handlerType == 7)
        {
            _calRouteType = (int)handlerType;
        }
        if (_calRouteType == GROU_CAL_MULTI && res == GD_ERR_OK)
        {
            [self DealRouteHandler];
        }
        else if (_calRouteType == GROU_CAL_SINGLE_ROUTE && res == GD_ERR_OK)
        {
            GGUIDEROUTEINFO info = {0};
            [MWRouteGuide GetGuideRouteInfo:(GHGUIDEROUTE)handlerType routeInfo:&info];
            GROUTEOPTION option = info.nRule[GJOURNEY_GOAL];
            existRouteHandler = 0x01 << option;  //单路径演算下的类型
        }
        
        if (res == GD_ERR_NO_DATA || res == GD_ERR_NO_ROUTE)  //提示缺失城市
        {
            if (handlerType == 2) //偏移重算不成功时需要停止引导，删除行程点，避让信息
            {
                [MWRouteGuide StopGuide:Gfalse];
                [MWJourneyPoint ClearJourneyPoint];
                [MWRouteDetour ClearDetourRoad];
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_STOPGUIDANCE object:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_SHOWMAP object:param]; //刷一帧图，删除路径线
            }
            [self Dealresult:res guideType:handlerType calType:_calRouteType];
        }
        else
        {
            if (res != GD_ERR_OK && handlerType == 2) //偏移重算不成功时需要停止引导，删除行程点，避让信息
            {
                [MWRouteGuide StopGuide:Gfalse];
                [MWJourneyPoint ClearJourneyPoint];
                [MWRouteDetour ClearDetourRoad];
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_STOPGUIDANCE object:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_SHOWMAP object:param]; //刷一帧图，删除路径线
            }
            else
            {
                if ((handlerType == 2 || handlerType == 7) && res == GD_ERR_OK)
                {
                    [MWRouteGuide clearRouteHandler]; //modify by gzm for 偏航时和主辅路切换，都清空待添加的路径句柄 at 2014-11-7
                    if (handlerType == 2) //modify by gzm for 偏航时提示偏航重算 at 2014-10-27
                    {
                        [[MWTTS SharedInstance] playSoundWithString:STR(@"Main_ReCalc", Localize_Main) priority:TTSPRIORITY_LOW];
                    }
                    GDBL_StartGuide(NULL); //偏航重算和主辅路切换之后重新需要调用开始引导
                }
            }
            [self Dealresult:res guideType:handlerType calType:_calRouteType];
        }
    }
}

/*道路排重处理*/
- (void)DealRouteHandler
{
    GPATHSTATISTICLIST *staticlist = NULL;
    [MWRouteGuide GetPathStatisticInfo:NULL whole:Gtrue multi:Gtrue list:&staticlist];
    
    existRouteHandler = 0x0000000f;   //表示四条路径都存在 最后四位二进制数，为1时表示路径存在
    GHGUIDEROUTE routeList[4] = {0};
    int totalRouteCount = 0;
    [MWRouteGuide GetGuideRouteList:routeList count:4 returnCount:&totalRouteCount];
    GGUIDEROADLIST *ppGuideRoadList = NULL;
    if (totalRouteCount == 4)
    {
        GCOORD *coord_array[4] = {0};
        int     coord_count[4] = {0};
        for (int i = 0; i < totalRouteCount; i++)  //复制经纬度
        {
            [MWRouteGuide GetGuideRoadList:routeList[i] allRoad:Gfalse list:&ppGuideRoadList];
            coord_array[i] = malloc(sizeof(GCOORD) * ppGuideRoadList->nNumberOfRoad);
            coord_count[i] = ppGuideRoadList->nNumberOfRoad;
            GCOORD *temp_coord = coord_array[i];
            for (int j = 0; j < ppGuideRoadList->nNumberOfRoad; j++)
            {
                GGUIDEROADINFO pGuideRoadInfo = ppGuideRoadList->pGuideRoadInfo[j];
                temp_coord[j].x = pGuideRoadInfo.lLon;
                temp_coord[j].y = pGuideRoadInfo.lLat;
            }
        }
        
        for (int i = 0; i < totalRouteCount; i++) //计算重复道路
        {
            unsigned int temp = 0x01<<i;
            BOOL sign = !(existRouteHandler & temp);
            if (sign)
            {
                continue;
            }
            GCOORD *coord1 = coord_array[i];
            for (int j = i+1; j < totalRouteCount; j++)
            {
                GCOORD *coord2 = coord_array[j];
                int minCount = coord_count[i] < coord_count[j] ? coord_count[i] : coord_count[j];
                BOOL sign = YES;
                for (int k = 0; k < minCount; k++)
                {
                    if (![self judgeCoordEqual:coord1[k] coord2:coord2[k]])
                    {
                        sign = NO;
                        break;
                    }
                }
                if (sign)
                {
                    temp = 0xffffffff;
                    temp = temp ^ (0x00000001<<j);
                    existRouteHandler = existRouteHandler & temp;
                }
            }
        }
        for (int i = 0; i < 4; i++)
        {
            if (coord_array[i])
            {
                free(coord_array[i]);
            }
        }
    }
    NSLog(@"existRouteHandler : %x",existRouteHandler);
    
    NSMutableArray *temp = nil;
    for (int i = 0; i < totalRouteCount; i++)  //删除标志位为0的路径
    {
        BOOL sign = existRouteHandler & (0x01<<i);
        if (!sign)
        {
            [MWRouteGuide DelGuideRoute:routeList[i]];
            existRouteHandlerList[i] = GNULL;
        }
        else
        {
            existRouteHandlerList[i] = routeList[i];
            temp = [NSMutableArray array];
            [temp addObject:[NSNumber numberWithInt:i]];
            for (int j = i+1; j < totalRouteCount; j++)
            {
                sign = existRouteHandler & (0x01<<j);
                if (!sign) {
                    [temp addObject:[NSNumber numberWithInt:j]];
                }
                else
                {
                    break;
                }
            }
            [g_composeOptionsDic setObject:temp forKey:[NSNumber numberWithInt:routeList[i]]];
            
        }
    }
    [MWRouteGuide GetGuideRouteList:routeList count:4 returnCount:&totalRouteCount];
    NSLog(@"remain route count : %d",totalRouteCount);
}

- (BOOL)judgeCoordEqual:(GCOORD)coord1 coord2:(GCOORD)coord2
{
    if (coord1.x == coord2.x && coord1.y == coord2.y) {
        return YES;
    }
    return NO;
}

- (BOOL)judgeGuideRouteEqual:(GPATHSTATISTICINFO)route1 route2:(GPATHSTATISTICINFO)route2
{
    if (route1.nTime == route2.nTime &&
        route1.nTotalDis == route2.nTotalDis &&
        route1.nTotalChargeDis == route2.nTotalChargeDis &&
        route1.nTotalHighwayDis == route2.nTotalHighwayDis &&
        route1.nTotalCircleDis == route2.nTotalCircleDis &&
        route1.nTotalHighDis == route2.nTotalHighDis &&
        route1.nTotalMidDis == route2.nTotalMidDis &&
        route1.nTotalLowDis == route2.nTotalLowDis &&
        route1.nTotalCharge == route2.nTotalCharge &&
        route1.nTotalTollGate == route2.nTotalTollGate &&
        route1.nTotalTrafficLight == route2.nTotalTrafficLight)
    {
        return YES;
    }
    return NO;
}
#pragma mark -
#pragma mark 添加行程点时的回调
/**********************************************************************
 * 函数名称: ChooseJunyPoint
 * 功能描述: 是否设置在高架桥上提示
 * 参    数:
 * 返 回 值:
 * 其它说明:
 **********************************************************************/
- (void)ChooseJunyPoint:(GJOURNEYPOINTTYPE)pointType
{
    GDAlertView *alertView = nil;
    if (pointType == GJOURNEY_GOAL)
    {
        alertView =[[[GDAlertView alloc] initWithTitle:nil andMessage:STR(@"Universal_fastRoadAlert", Localize_Universal)] autorelease];
    }
    else
    {
        alertView =[[[GDAlertView alloc] initWithTitle:nil andMessage:[NSString stringWithFormat:STR(@"Universal_passbyRoadAlert",Localize_Universal),pointType]] autorelease];
    }
    _alertRouteChoeseCount++;
    
    [alertView addButtonWithTitle:STR(@"Universal_no", Localize_Universal) type:GDAlertViewButtonTypeCancel handler:^(GDAlertView *alertView)
     {
         _alertRouteChoeseCount--;
         isSelectedNormal = YES;
         isChooseRoad = YES;
         
         MWPoi *poi = [MWJourneyPoint getJourneyPointWithID:pointType];
         [MWJourneyPoint AddJourneyPointWith:poi type:pointType option:0];
         if (_alertRouteChoeseCount == 0)
         {
             isSelected = YES;
             [MWRouteGuide StopGuide:Gfalse];//每次设终点计算前都删除旧路线
             GDBL_ClearDetourRoad();//删除所有避让内容
             GSTATUS res = [MWRouteCalculate StartRouteCalculation:_calRouteType];
             if (res != GD_ERR_OK)
             {
                 [self Dealresult:res guideType:0 calType:GROU_CAL_MULTI];
             }
         }
         
     }];
    [alertView addButtonWithTitle:STR(@"Universal_yes", Localize_Universal) type:GDAlertViewButtonTypeDefault handler:^(GDAlertView *alertView){
        
        _alertRouteChoeseCount--;
        isSelectedNormal = NO;
        isChooseRoad = YES;
        
        MWPoi *poi = [MWJourneyPoint getJourneyPointWithID:pointType];
        [MWJourneyPoint AddJourneyPointWith:poi type:pointType option:0];
        if (_alertRouteChoeseCount == 0)
        {
            isSelected = YES;
            [MWRouteGuide StopGuide:Gfalse];//每次设终点计算前都删除旧路线
            GDBL_ClearDetourRoad();//删除所有避让内容
            GSTATUS res = [MWRouteCalculate StartRouteCalculation:_calRouteType];
            if (res != GD_ERR_OK)
            {
                [self Dealresult:res guideType:0 calType:GROU_CAL_MULTI];
            }
        }
    }];
    [alertView show];
    
}


/**********************************************************************
 * 函数名称: GetJunyPointRoadInfo
 * 功能描述: 添加行程点时的回调
 * 参    数: pRoadInfo：道路信息 nNumberOfRoadInfo:道路信息条数
 * 返 回 值:
 * 其它说明:
 **********************************************************************/
Gint32 GetJunyPointRoadInfo(GROADINFO *pRoadInfo, Gint32 nNumberOfRoadInfo, void *lpVoid)
{
    MWRouteCalculate *routeCalculate = (MWRouteCalculate *)[MWRouteCalculate SharedInstance];
    if (routeCalculate.m_journeyType == GJOURNEY_MAX || routeCalculate.m_journeyType == GJOURNEY_START || nNumberOfRoadInfo == 0)
    {
        return 0;
    }
    
    BOOL isExistNormal = NO;
    BOOL isEXistHigh = NO;
    int high = -1;
    int normal = -1;
    int returnIndex = 0;  //默认返回距离最短的一条绑定道路
    for (int i = 0; i < nNumberOfRoadInfo; i++)
    {
        GROADINFO tempRoadInfo = pRoadInfo[i];
        if (tempRoadInfo.nDistance <= 70) //指定点到该道路的垂直距离小于70m时，才做是否弹出告诉判断
        {
            if (tempRoadInfo.nRoadType == 1 || tempRoadInfo.nRoadType == 2) //1：高速道路 2：城市快速路
            {
                if (high == -1)
                {
                    isEXistHigh = YES;
                    high = i;
                }
            }
            else
            {
                if (normal == -1)
                {
                    isExistNormal = YES;
                    normal = i;
                }
            }
        }
        
        if (isExistNormal && isEXistHigh)
        {
            if (!routeCalculate.isChooseRoad)  //是否弹出了高速路选择框
            {
                routeCalculate.isSelected = NO;
                [routeCalculate ChooseJunyPoint:routeCalculate.m_journeyType];
            }
            else
            {
                routeCalculate.isChooseRoad = NO;
                if (!routeCalculate.isSelectedNormal)  //是否选择了高速路
                {
                    returnIndex = high;
                }
                else
                {
                    returnIndex = normal;
                }
            }
            break;
        }
    }
    return returnIndex;
}
@end

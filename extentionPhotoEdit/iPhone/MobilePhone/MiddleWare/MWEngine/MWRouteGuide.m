//
//  MWRouteDetail.m
//  AutoNavi
//
//  Created by gaozhimin on 14-5-7.
//
//

#import "MWRouteGuide.h"
#import "MWMapOperator.h"
#import "CustomRoadInfo.h"
#import "CustomRealTimeTraffic.h"
#import "MWTTS.h"
#import "MWDialectDownloadManage.h"
#import "DringTracksManage.h"
#import "MWMapAddIconOperator.h"
#import "NSString+Category.h"
#import "load_bmp.h"

static GHGUIDEROUTE g_currentGuidRouteAfterChange = NULL; //GDBL_ChangeGuideRoute后需要记录换了哪条路线
static GHGUIDEROUTE g_currentRouteList[4] = {0};

@implementation MWRouteGuide

/**
 **********************************************************************
 \brief 添加引导路径
 \details 该函数用于添加一条引导路径到引导路径管理表。
 \param[in] hGuideRoute 引导路径句柄。
 \retval	GD_ERR_OK 成功
 \retval	GD_ERR_INVALID_PARAM 参数无效
 \retval	GD_ERR_FAILED 操作失败
 \remarks
 - 该接口不允许传空句柄
 \since 6.0
 \see
 **********************************************************************/
+ (GSTATUS)AddGuideRoute:(GHGUIDEROUTE) hGuideRoute
{
    return GDBL_AddGuideRoute(hGuideRoute);
}

/**
 **********************************************************************
 \brief 移除引导路径
 \details 该函数用于从引导路径管理表中移除一条引导路径。
 \param[in] hGuideRoute 引导路径句柄。
 \retval	GD_ERR_OK 成功
 \retval	GD_ERR_INVALID_PARAM 参数无效
 \remarks
 - 1.移除操作并不做实际的删除引导路径。
 - 2.正在引导的引导路径不能移除。
 - 3.要移除正在引导的引导路径，必须先停止引导。
 \since 6.0
 \see
 **********************************************************************/
+ (GSTATUS)RemoveGuideRoute:(GHGUIDEROUTE)hGuideRoute
{
    return GDBL_RemoveGuideRoute(hGuideRoute);
}

/**
 **********************************************************************
 \brief 删除引导路径
 \details 该函数用于从路径管理列表中删除一条引导路径。
 \param[in] hGuideRoute 引导路径句柄。
 \retval	GD_ERR_OK 成功
 \retval	GD_ERR_INVALID_PARAM 参数无效
 \retval	GD_ERR_FAILED 操作失败
 \remarks
 - 1.删除该条引导路径，同时从路径管理表中移除。
 - 2.删除后该条引导路径将不可再用。
 - 3.正在引导的引导路径不能删除。
 - 4.要删除正在引导的引导路径，必须先停止引导。
 \since 6.0
 \see
 **********************************************************************/
+ (GSTATUS)DelGuideRoute:(GHGUIDEROUTE) hGuideRoute
{
    return GDBL_DelGuideRoute(hGuideRoute);
}

/**
 **********************************************************************
 \brief 清空引导路径
 \details 该函数用于清空引导路径管理表。
 \retval	GD_ERR_OK 成功
 \remarks
 - 1.清空操作是对引导路径管理表中的路径做删除操作。
 - 2.如果有引导路径正在引导，则该条引导路径不做删除。
 \since 6.0
 \see
 **********************************************************************/
+ (GSTATUS)ClearGuideRoute
{
    return GDBL_ClearGuideRoute();
}

/**
 **********************************************************************
 \brief 获取引导路径列表
 \details 该函数用于获取引导路径列表。
 \param[in] nCount        引导路径句柄缓冲区大小。
 \param[out] phGuideRoute 引导路径句柄缓冲区。
 \param[out] realCount    实际获取的引导路径条数。
 \retval	GD_ERR_OK 成功
 \retval	GD_ERR_INVALID_PARAM 参数无效
 \remarks
 \since 6.0
 \see
 **********************************************************************/
+ (GSTATUS)GetGuideRouteList:(GHGUIDEROUTE *)phGuideRoute count:(Gint32)nCount returnCount:(Gint32 *)returnCount
{
    return GDBL_GetGuideRouteList(phGuideRoute, nCount, returnCount);
}

/**
 **********************************************************************
 \brief 改变引导路径句柄
 \details 该函数用于改变引导路径句柄
 \param[in] hGuideRoute     路径句柄
 \retval	GD_ERR_OK 成功
 \remarks
 - 1.选择一条引导路径并不代表引导的就是这条路径。
 - 2.选择功能在多条路径时，选择一条后，可以高亮显示，以供查看。
 - 3.该接口不允许传空的句柄
 \since 6.0
 \see
 **********************************************************************/
+ (GSTATUS)ChangeGuideRoute:(GHGUIDEROUTE) hGuideRoute
{
    GROUTEOPTION option = [MWRouteCalculate GetRoadOption:hGuideRoute]; //获取选择的路径类型，推荐，高速，经济，最短
    GDBL_SetParam(G_ROUTE_OPTION, &option); //保存路径规划原则，确定续航时的路径一样
    GSTATUS res = GDBL_ChangeGuideRoute(hGuideRoute);
    if (res == GD_ERR_OK)
    {
        g_currentGuidRouteAfterChange = hGuideRoute;
    }
    return res;
}

/**
 **********************************************************************
 \brief 获取引导路径经过的城市信息
 \details 该函数用于获取引导路径所经过城市的相关信息。
 \param[in] eGuideRouteType        获取路径经过城市的信息类型
 \param[out] pGuideRouteCityInfo   返回的城市信息
 \retval	GD_ERR_OK 成功
 \retval	GD_ERR_NO_MEMORY 内存不足
 \retval	GD_ERR_FAILED 操作失败
 \remarks
 \since 6.0
 \see
 **********************************************************************/
+ (GSTATUS)GetGuideRouteCityInfo:(GGUIDEROUTETYPE)eGuideRouteType citiInfo:(GGUIDEROUTECITYINFO **)pGuideRouteCityInfo
{
    return GDBL_GetGuideRouteCityInfo(NULL,eGuideRouteType, eADALEVEL_CITY, pGuideRouteCityInfo);
}

/**
 **********************************************************************
 \brief 获取引导路径信息
 \details 该函数用于获取引导路径相关信息。
 \param[in] hGuideRoute        引导路径句柄
 \param[out] pGuideRouteInfo    引导路径信息
 \retval	GD_ERR_OK 成功
 \retval	GD_ERR_INVALID_PARAM 参数无效
 \retval	GD_ERR_FAILED 操作失败
 \remarks
 \since 6.0
 \see
 **********************************************************************/
+ (GSTATUS)GetGuideRouteInfo:(GHGUIDEROUTE)hGuideRoute routeInfo:(GGUIDEROUTEINFO *)pGuideRouteInfo
{
    return GDBL_GetGuideRouteInfo(hGuideRoute, pGuideRouteInfo);
}

/**
 **********************************************************************
 \brief 启动引导
 \details 该函数用于启动驾驶引导。
 \param[in] hGuideRoute 引导路径句柄
 \retval	GD_ERR_OK 成功
 \retval	GD_ERR_NO_ROUTE	没有引导路径
 \remarks
 - 1.引导指定的路径，上一个路径引导将被自动停止。
 - 2.启动驾驶引导，生成引导路径信息。
 \since 6.0
 \see GDBL_StartGuidance
 **********************************************************************/
+ (GSTATUS)StartGuide:(GHGUIDEROUTE)hGuideRoute
{
    [MWRouteCalculate SetExistRouteGuideHandler]; //修改
    [MWMapOperator SetBuildingRaiseRate:0.0];   //设置建筑物压低
    NSNumber *mapMode = [[NSUserDefaults standardUserDefaults] objectForKey:USERDEFAULT_NaviMapMode];
    if (mapMode)
    {
        [[MWMapOperator sharedInstance] MW_SetMapViewMode:GMAP_VIEW_TYPE_MAIN Type:0 MapMode:[mapMode intValue]]; //导航开始，使用用户上次保存的模式
    }
    else
    {
        [[MWMapOperator sharedInstance] MW_SetMapViewMode:GMAP_VIEW_TYPE_MAIN Type:0 MapMode:GMAPVIEW_MODE_CAR]; //导航开始，默认设置为车首3D模式
        [[MWMapOperator sharedInstance] MW_SetMapViewMode:GMAP_VIEW_TYPE_MAIN Type:0 MapMode:GMAPVIEW_MODE_3D];  //导航开始，默认设置为车首3D模式
    }
    
    //modify by gzm for startguide前先remove路径句柄 at 2014-10-17
    int returnCount = 0;
    memset(g_currentRouteList, 0, sizeof(GHGUIDEROUTE)*4); //获取路径句柄时，先清空旧句柄
    [MWRouteGuide GetGuideRouteList:g_currentRouteList count:4 returnCount:&returnCount];
    for (int i = 0; i < returnCount; i++)
    {
        if (hGuideRoute != g_currentRouteList[i])
        {
            GSTATUS res = [MWRouteGuide RemoveGuideRoute:g_currentRouteList[i]];
            if (res == GD_ERR_OK)
            {
                NSLog(@"remove成功！");
            }
        }
        
    }
    //modify by gzm for startguide前先remove路径句柄 at 2014-10-17
    
    int status = 0;
    status = GDBL_StartGuide(hGuideRoute);
    NSString *str_path = [NSString stringWithUTF8String:route_path];
    GSTATUS res = [MWRouteGuide SaveGuideRoute:GNULL name:str_path]; //保存路线
    if (res == GD_ERR_OK)
    {
        NSLog(@"保存路线成功！");
    }
    [[MWHistoryRoute sharedInstance] SaveHistoryRoute];//HMI保存历史路线
    [[MWPreference sharedInstance] setValue:PREF_MAP_TMC_SHOW_OPTION Value:NO]; //开始导航后只显示路径线上事件
    
    //modify by gzm for 导航下才开启自动缩放，所以在删除路径和开始导航时候要重新设置 at 2014-11-12
    int autoZoomValue = [[MWPreference sharedInstance] getValue:PREF_AUTOZOOM];
    [[MWPreference sharedInstance] setValue:PREF_AUTOZOOM Value:autoZoomValue];
    return status;
}

/**
 **********************************************************************
 \brief 结束引导
 \details 该函数用于结束驾驶引导。
 \retval	GD_ERR_OK 成功
 \retval	GD_ERR_NO_ROUTE	没有引导路径
 \remarks
 - 1.bClearAllRoute：Gfalse 停止路径引导，不删除引导路径。
 - 2.bClearAllRoute：Gtrue  结束路径引导，清空引导路径列表。
 \since 6.0
 \see GDBL_StopGuidance
 **********************************************************************/
+ (GSTATUS)StopGuide:(Gbool)bClearAllRoute
{
    memset(g_currentRouteList, 0, sizeof(GHGUIDEROUTE)*4);
    //删除路径，就删除 TMC 参与路径计算
    GROUTETMCOPTION tmcOption = GROUTE_TMC_OPTION_NONE;
    GDBL_SetParam(G_ROUTE_TMC_OPTION, &tmcOption); /*所有规划原则，开启TMC参与路径演算*/
        
    g_currentGuidRouteAfterChange = NULL;
    [MWMapOperator SetBuildingRaiseRate:1.0]; //设置建筑物恢复

    GSTATUS res = GDBL_StopGuide(bClearAllRoute);
    if (res == GD_ERR_OK)
    {
        //modify by gzm for 导航下才开启自动缩放，所以在删除路径和开始导航时候要重新设置 at 2014-11-12
        int autoZoomValue = [[MWPreference sharedInstance] getValue:PREF_AUTOZOOM];
        [[MWPreference sharedInstance] setValue:PREF_AUTOZOOM Value:autoZoomValue];
        
        [[MWPreference sharedInstance] setValue:PREF_MAP_TMC_SHOW_OPTION Value:NO]; //主地图界面都显示城市TMC,根据路径判断是否显示事件
        if ([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%s",route_path]]) //存在续航文件直接删除文件
        {
            [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%s",route_path] error:nil];
        }
    }
    return res;
}

/**
 **********************************************************************
 \brief 获取机动引导信息
 \details 该函数用于获取机动引导信息。
 \param[out] pManeuverInfo	机动引导信息
 \retval	GD_ERR_OK 成功
 \retval	GD_ERR_INVALID_PARAM	参数无效
 \remarks
 - 机动车信息内存由内部分配，每次调用均将上次内容替换。
 \since 6.0
 \see
 **********************************************************************/
+ (GSTATUS)GetManeuverInfo:(GMANEUVERINFO **)pManeuverInfo
{
    return GDBL_GetManeuverInfo(pManeuverInfo);
}

/**
 **********************************************************************
 \brief 获取高速机动信息
 \details 该函数用于获取高速机动引导信息。
 \param[out] pManeuverInfo	高速机动信息
 \retval	GD_ERR_OK 成功
 \retval	GD_ERR_INVALID_PARAM	参数无效
 \retval	GD_ERR_NO_DATA	  当前无高速机动点信息
 \remarks
 - 1.机动车信息内存由内部分配，每次调用均将上次内容替换。
 - 2.只有当前车位在高速路上时，该接口才返回有数据。
 \since 6.0
 \see
 **********************************************************************/
+ (GSTATUS)GetHighwayManeuverInfo:(GHIGHWAYMANEUVERINFO **)pManeuverInfo
{
    return GDBL_GetHighwayManeuverInfo(pManeuverInfo);
}

/**
 **********************************************************************
 \brief 获取多个机动车信息
 \details 该函数用于获取从当前车位处多个机动引导信息。
 \param[in] nNumberOfManeuversToGet	需要获取的机动信息个数
 \param[in] bAutoCheck	            是否自动判定获取的结束条件
 \param[out] pManeuverInfo	        用于获取当前机动点信息
 \param[out] pNumberOfManeuversGet	实际获取的机动信息个数
 \retval	GD_ERR_OK 成功
 \retval	GD_ERR_NO_ROUTE	没有引导路径
 \remarks
 - 1.获取的机动信息从当前车位开始。
 - 2.bAutoCheck为Gfalse时，无附加条件获取nNumberOfManeuversToGet个；
 为Gtrue时，GNaviServer自动判定结束条件，即只获取到距离近的路口机动信息。
 \since 6.0
 \see
 **********************************************************************/
+ (GSTATUS)GetMultiManeuverInfo:(GMANEUVERINFO *)pManeuverInfo getCount:(Guint32)nNumberOfManeuversToGet autoCheck:(Gbool)bAutoCheck
                   realGetCount:(Guint32 *)pNumberOfManeuversGet
{
    return GDBL_GetMultiManeuverInfo(pManeuverInfo, nNumberOfManeuversToGet, bAutoCheck, pNumberOfManeuversGet);
}

/**
 **********************************************************************
 \brief 关闭放大路口
 \details 该函数用于主动关闭当前放大路口视图。
 \retval	GD_ERR_OK 成功
 \remarks
 - 1.只能关闭当前放大路口视图，下一个放大路口视图仍然会自动出现。
 \since 6.0
 \see
 **********************************************************************/
+ (GSTATUS)CloseZoomView
{
    return GDBL_CloseZoomView();
}

/**
 **********************************************************************
 \brief 主动播报引导语音
 \details 该函数用于主动触发一次引导语音播报。
 \retval	GD_ERR_OK 成功
 \retval	GD_ERR_NO_ROUTE	没有引导路径
 \remarks
 \since 6.0
 \see
 **********************************************************************/
+ (GSTATUS)SpeakNaviSound
{
    return GDBL_SpeakNaviSound();
}

/**
 **********************************************************************
 \brief 重播引导语音
 \details 该函数用于重复最近一次引导语音播报。
 \retval	GD_ERR_OK 成功
 \retval	GD_ERR_NO_ROUTE	没有引导路径
 \remarks
 \since 6.0
 \see
 **********************************************************************/
+ (GSTATUS)RepeatNaviSound
{
    return GDBL_SpeakNaviSound();
}

/**
 **********************************************************************
 \brief  获取路径列表
 \details 该函数用于获取引导道路列表。
 \param[in] hGuideRoute	引导路径句柄
 \param[in] bGetAllRoad	是否获取每一条道路
 \param[out] pGuideRoadList	用于返回引导道路列表
 \retval	GD_ERR_OK 成功
 \retval	GD_ERR_NO_ROUTE   没有引导路径
 \retval	GD_ERR_NO_MEMORY  内存不足
 \remarks
 - 引导道路列表内存由内部开辟，每次调用均会替换上次数据。
 \since 6.0
 \see
 **********************************************************************/
+ (GSTATUS)GetGuideRoadList:(GHGUIDEROUTE)hGuideRoute allRoad:(Gbool) bGetAllRoad list:(GGUIDEROADLIST **)ppGuideRoadList
{
    return GDBL_GetGuideRoadList(hGuideRoute, bGetAllRoad, ppGuideRoadList);
}

/**
 **********************************************************************
 \brief  获取机动文本列表
 \details 该函数用于获取引导机动文本列表。
 \param[in]  hGuideRoute	引导路径句柄
 \param[out] pManeuverTextList	返回引导机动文本列表
 \param[out] pbMainRoad 返回Gtrue表示存在主要道路，返回Gfalse表示不存在主要道路
 \retval	GD_ERR_OK 成功
 \retval	GD_ERR_NO_ROUTE   没有引导路径
 \retval	GD_ERR_NO_MEMORY  内存不足
 \remarks
 - 描述文本起止标记定义（起始和终止标记相同且配对出现）
 当前道路名- [c]
 方位      - [a]
 距离值    - [d]
 转向语句  - [t]
 下一道路名- [n]
 如：沿[c]厦禾路[c]向[a]西北[a]方向，行驶...
 \since 6.0
 \see
 **********************************************************************/
+ (GSTATUS)GetManeuverTextList:(GHGUIDEROUTE) hGuideRoute list:(GMANEUVERTEXTLIST *)pManeuverTextList bMainRoad:(Gbool *)pbMainRoad
{
    return GDBL_GetManeuverTextList(hGuideRoute, pManeuverTextList, pbMainRoad);
}

/**
 **********************************************************************
 \brief  获取路径统计信息
 \details 该函数用于获取路径统计信息。
 \param[in] hGuideRoute	引导路径句柄
 \param[in] bWholeJourney Gtrue获取整个行程统计信息，Gfalse获取到下一个中途点
 \param[in] bMultiStat Gtrue获取多条路径统计信息，Gfalse获取当前选中的路径统计信息
 \param[out] ppStatInfoList	路径统计信息
 \retval	GD_ERR_OK 成功
 \retval	GD_ERR_NO_ROUTE   没有引导路径
 \remarks
 - 路径统计信息内存由内部开辟，每次调用均会替换上次数据。
 \since 6.0
 \see
 **********************************************************************/
+ (GSTATUS)GetPathStatisticInfo:(GHGUIDEROUTE) hGuideRoute whole:(Gbool)bWholeJourney multi:(Gbool)bMultiStat list:(GPATHSTATISTICLIST **)ppStatInfoList
{
    return GDBL_GetPathStatisticInfo(hGuideRoute, bWholeJourney, bMultiStat, ppStatInfoList);
}

/**
 **********************************************************************
 \brief  路径保存
 \details 该函数用于保存当前的引导路径到文件szFileName中。
 \param[in] hGuideRoute	路径句柄
 \param[in] szFileName	需要保存的文件名
 \retval	GD_ERR_OK 成功
 \retval	GD_ERR_NO_ROUTE   没有引导路径
 \retval	GD_ERR_TOO_NEAR   车位距终点不足20m
 \remarks
 - 文件路径一定要传绝对路径。
 - 起点中间层已经改为以当前车位为起点。
 - 如果车位距中途点不足20m，中间层会自动舍弃中途点
 \since 6.0
 \see
 **********************************************************************/
+ (GSTATUS)SaveGuideRoute:(GHGUIDEROUTE)hGuideRoute name:(NSString *)szFileName
{
    return GDBL_SaveGuideRoute(hGuideRoute, NSStringToGchar(szFileName));
}

/**
 **********************************************************************
 \brief  路径加载
 \details 该函数用于加载一条事先存储的引导路径行程点。
 \param[in]  szFileName	  需要加载的文件名
 \retval	GD_ERR_OK 成功
 \retval	GD_ERR_FAILED   操作失败
 \remarks
 - 文件名是绝对路径。
 - HMI调用该接口后，中间层不再进行路径演算，因此还需要调用路径演算接口进行进一步算路。
 - HMI调用路径演算可以自由决定算单路径、多路径、或者只返回路径句柄而不进行引导。
 \since 6.0
 \see
 **********************************************************************/
+ (GSTATUS)LoadGuideRoute:(NSString *)szFileName
{
    Gint32 nRule[GJOURNEY_MAX] = {0};
    return GDBL_LoadGuideRoute(NSStringToGchar(szFileName),nRule);
}

/**
 **********************************************************************
 \brief 获取引导状态标识
 \details 该函数用于获取当前引导的一些状态信息标识。
 \retval  引导状态标识 (G_GUIDE_FLAGS_CROSSZOOM:路口放大 G_GUIDE_FLAGS_GUIDEPOST:高速路牌 G_GUIDE_FLAGS_SIGNPOST:蓝色看板)
 **********************************************************************/
+ (GGUIDEFLAGS)GetGuideFlags
{
    GGUIDEFLAGS pFlags;
    GSTATUS flag = GDBL_GetGuideFlags(&pFlags);
    if (flag == 0)
    {
        return pFlags;
    }
    else
    {
        return 0;
    }
}

/**
 **********************************************************************
 \brief 获取目的地方向
 \details 该函数用于获取当前车位指向目的地的方向角度。
 \param[in] bNextWaypoint	  Gtrue下一个中途点作为计算参考对象，Gfalse最终目的地作为计算参考对象。
 \param[in] pAngle	 当前车位指向目的地的方向角度（正东0，逆时针）。
 \retval	GD_ERR_OK 成功
 \retval	GD_ERR_NO_ROUTE   没有引导路径
 \remarks
 \since 6.0
 \see
 **********************************************************************/
+ (GSTATUS)GetDestinationAngle:(Gbool)bNextWaypoint angle:(Gint32 *)pAngle
{
    return GDBL_GetDestinationAngle(bNextWaypoint, pAngle);
}

/**
 **********************************************************************
 \brief 获取当前路口放大视图信息
 \details 该函数用于获取当前路口放大视图的信息。
 \param[out] pViewInfo 用于返回当前路口的放大路口信息。
 \retval	GD_ERR_OK 成功
 \retval	GD_ERR_NO_DATA   无相关数据
 \remarks
 \since 6.0
 \see
 **********************************************************************/
+ (GSTATUS)GetCurrentZoomViewInfo:(GZOOMVIEWINFO *)pViewInfo
{
    return GDBL_GetCurrentZoomViewInfo(pViewInfo);
}

/**
 **********************************************************************
 \brief 获取引导道路TMC列表
 \details 该函数用于获取引导道路TMC相关信息。
 \param[out] pList 引导道路TMC列表。
 \retval	GD_ERR_OK 成功
 \retval	GD_ERR_NO_DATA 没有相关数据
 \retval GD_ERR_NO_MEMORY 内存不足
 \retval GD_ERR_NO_ROUTE 没有引导路径
 \remarks
 \since 6.0
 \see
 **********************************************************************/
+ (GSTATUS)GetGuideRoadTMCList:(GGUIDEROADTMCLIST *)pList
{
    return GDBL_GetGuideRoadTMCList(pList);
}

/**
 **********************************************************************
 \brief 获取最近一个被跳过的途经点索引号
 \details 该函数用于获取最近一个被跳过的途经点索引号
 \param[out]	pnMissedIndex 途经点索引号
 \retval	GD_ERR_OK 成功
 \retval	GD_ERR_INVALID_PARAM 参数异常
 \retval	GD_ERR_FAILED        失败
 \remarks
 -用于获取最近一个被跳过的中途点。该接口只有在中途点被绕过后首次调用才返回正确值
 此后再调用该接口返回值都是0。如果HMI有其他地方需要使用到需要做备份。
 \since 7.0
 \see
 **********************************************************************/
+ (GSTATUS)GetLastMissedWaypoint:(Gint32 *)pnMissedIndex
{
    return GDBL_GetLastMissedWaypoint(pnMissedIndex);
}

/**
 **********************************************************************
 \brief 获取当前车位对应道路id的道路属性
 \details 该函数用于获取当前车位对应道路id的道路属性
 \param[out] pstRoadAttr     道路属性
 \retval	GD_ERR_OK 成功
 \retval	GD_ERR_FAILED 失败
 \remarks
 -1.引导状态的行车线有推荐的状态，如果需要获取车位所在路段的行车线，调用GDMID_GetCarLanes。
 -2.该接口涉及到对文件的访问，考虑到效率问题只有当RoadID改变才需要调用。
 -3.为了提高灵活性，mid不对最近一次获取的道路属性进行备份。
 -4.行车线给出的是数组，需要HMI自行判断有多少个（不为0代表的是有效的行车线）
 \since 7.0
 \see
 **********************************************************************/
+ (GSTATUS)GetCarRoadAttr:(GROADATTR *)pstRoadAttr
{
    GCARINFO pCarInfo = {0};
    GSTATUS res = GDBL_GetCarInfo(&pCarInfo);
    if (res == GD_ERR_OK)
    {
        GOBJECTID pstRoadID = pCarInfo.stRoadId;
        res = GDBL_GetRoadAttr(&pstRoadID, pCarInfo.nRoadDir, pstRoadAttr);
    }
    return res;
}

#pragma mark -
#pragma mark 以下接口包含逻辑
/**
 **********************************************************************
 \brief 多路线概览点击路线切换高亮,点击图标返回事件，交通流信息,参数number大于0表示点击了图标，touchNumber为－1说明未点击到路径，否则返回相应的路径规划原则
 **********************************************************************/
+ (NSString *)guideRouteAndIconTouch:(GMAPVIEWTYPE)mapViewType TouchPoint:(CGPoint)touchPoint Elements:(GEVENTINFO **)elements EventNumber:(int *)number TouchRouteNumber:(int *)touchNumber
{
    if ([[MWPreference sharedInstance] getValue:PREF_MAPVIEWMODE] == MAP_3D) {
        *touchNumber = -1;
        *number = 0;
        return nil;
    }
    
    NSString *avoidString = @"";
    GHGUIDEROUTE *guideroute = NULL;
    GGUIDEROUTEINFO stGuideRouteInfo = {0};
    Gint32 routeTouchnumber = 0;
    Gint32 iconTouchNumber = 0;
    GSELECTPARAM param = {0};
    
    param.eViewType = mapViewType;
    param.pos.x = touchPoint.x * [ANParamValue sharedInstance].scaleFactor;
    param.pos.y = touchPoint.y * [ANParamValue sharedInstance].scaleFactor;
    
    //点击图标返回信息
    param.eCmd = GSELECT_CMD_EVENT;
    
    GEVENTINFO *eventInfo = {0};
    GDBL_SelectElementsByHit(&param, (void **)&eventInfo,&iconTouchNumber);
    if (iconTouchNumber > 0) {
        *elements = eventInfo;
        NSString *disFromCar;
        NSString *streamType;
        NSString *impactRange;
        //道路名字
        NSString *roadName = [NSString chinaFontStringWithCString:eventInfo->szRoadName];
        
        //车辆距事件，交通流距离
        
        float fDistance = eventInfo->nDisToCar;
        if (fDistance>1000) {
            fDistance = fDistance/1000;
            disFromCar = [NSString stringWithFormat:@"%.2f%@", fDistance,STR(@"Universal_KM", Localize_Universal)];
        }else{
            disFromCar = [NSString stringWithFormat:@"%.f%@", fDistance,STR(@"Universal_M", Localize_Universal)];
        }
        
        //交通流类型
        int eventID = eventInfo->nEventID > 20 ? ((eventInfo->nEventID >> 16) & 0Xff) : eventInfo->nEventID;
        if (eventID == 2 || eventID == 3) {
            streamType = [NSString stringWithFormat:@"%@" ,STR(@"TMC_slow", Localize_TMC)];
        }
        else if(eventID == 4 || eventID == 5)
        {
            streamType = [NSString stringWithFormat:@"%@" ,STR(@"TMC_congest", Localize_TMC)];
        }
        else if(eventID == 33)
        {
            streamType = [NSString stringWithFormat:@"%@" ,STR(@"TMC_accident", Localize_TMC)];
        }
        else if(eventID == 34)
        {
            streamType = [NSString stringWithFormat:@"%@" ,STR(@"TMC_underConstruction", Localize_TMC)];
        }
        else if(eventID == 35)
        {
            streamType = [NSString stringWithFormat:@"%@" ,STR(@"TMC_trafficControl", Localize_TMC)];
        }
        else if(eventID == 36)
        {
            streamType = [NSString stringWithFormat:@"%@" ,STR(@"TMC_roadBarrier", Localize_TMC)];
        }
        else if(eventID == 37)
        {
            streamType = [NSString stringWithFormat:@"%@" ,STR(@"TMC_events", Localize_TMC)];
        }
        else if(eventID == 38)
        {
            streamType = [NSString stringWithFormat:@"%@" ,STR(@"TMC_disaster", Localize_TMC)];
        }
        else if(eventID == 39)
        {
            streamType = [NSString stringWithFormat:@"%@" ,STR(@"TMC_badWeather", Localize_TMC)];
        }
        else{
            streamType = @"";
        }
        //影响范围
        
        float fRange = eventInfo->nLength;
        if (fRange>1000) {
            fRange = fRange/1000;
            impactRange = [NSString stringWithFormat:@"%.2f%@", fRange,STR(@"Universal_KM", Localize_Universal)];
        }else{
            impactRange = [NSString stringWithFormat:@"%.f%@", fRange,STR(@"Universal_M", Localize_Universal)];
        }
        
        avoidString = [NSString stringWithFormat:STR(@"TMC_trafficInfo", Localize_TMC),disFromCar,roadName,streamType,impactRange];
        
        NSLog(@"event==%@,ID=%d",avoidString,eventID);
        
        *number = iconTouchNumber;
        return avoidString;
    }
    
    param.eCmd = GSELECT_CMD_ROUTE;
    //点击路线切换
    GDBL_SelectElementsByHit(&param, (void **)&guideroute,&routeTouchnumber);
    
    
    if (routeTouchnumber > 0)  //目前路径最多只有三条
    {
        BOOL sign = NO; //是否选择过路径
        int chooseRouteId = 0;      //当前选择的道路id
        int nextChooseRouteId = 0; //下一个该选择的道路id
        for (int i = 0; i < routeTouchnumber; i++)
        {
            if (guideroute[i] == g_currentGuidRouteAfterChange)
            {
                sign = YES;
                chooseRouteId = i;
                break;
            }
        }
        if (routeTouchnumber == 1) //如果只有一条路径
        {
            nextChooseRouteId = 0;
        }
        else
        {
            if (sign == YES)
            {
                if (chooseRouteId == routeTouchnumber - 1) //如果选择了最后一条
                {
                    nextChooseRouteId = 0;
                }
                else
                {
                    nextChooseRouteId = chooseRouteId+1;
                }
            }
            else
            {
                nextChooseRouteId = 1;
            }
        }
        
        *touchNumber = 0;   //默认选择的是第0调
        
        GHGUIDEROUTE routeList[4] = {0};
        int totalRouteCount = 0;
        [MWRouteGuide GetGuideRouteList:routeList count:4 returnCount:&totalRouteCount];
        for (int i = 0; i < totalRouteCount; i++)  //遍历路径句柄列表，选中的下一路径在列表中的位置
        {
            if (routeList[i] == guideroute[nextChooseRouteId])
            {
                *touchNumber = i;
                break;
            }
        }
        
    }
    else{
        
        *touchNumber = -1;
    }
    
    *number = iconTouchNumber;
    return avoidString;
}


/**
 **********************************************************************
 \brief 获取机动引导信息
 \details 获取机动引导信息
 \param[in]	mainID 0:当前道路名 1:路口距离 2:剩余距离 3:剩余时间 10下路口名称 11：剩余距离 12：出现放大路口时获取距离下一路口的距离
 \retval	相关信息
 **********************************************************************/
+ (NSString *)GetManeuverInfoWithMainID:(int)mainID
{
    if (![ANParamValue sharedInstance].isPath) {
        return nil;
    }
    GMANEUVERINFO* pManeuverInfo = NULL;
	GSTATUS res = GDBL_GetManeuverInfo(&pManeuverInfo);
	if (res != GD_ERR_OK)
    {
        return nil;
    }
    NSMutableString *maneuverInfo = [[NSMutableString alloc] init];
	switch (mainID)
	{
		case 0://当前道路名
		{
            if ([ANParamValue sharedInstance].isMove) {
                [maneuverInfo appendString:[[MWMapOperator sharedInstance] GetCurrentRoadName:GMAP_VIEW_TYPE_MAIN]];
            }
            else{
                if (pManeuverInfo != NULL) {
                    [maneuverInfo appendString:[NSString chinaFontStringWithCString:pManeuverInfo->szCurRoadName]];
                }
                
            }
            
		}
			break;
		case 1:// 路口距离（单位：米）
		{
            if (res == GD_ERR_OK)
            {
                if (pManeuverInfo->nNextDis > 1000)
                {
                    [maneuverInfo appendString:[NSString stringWithFormat:@"%0.1f%@",(pManeuverInfo->nNextDis/1000.0),STR(@"Universal_KM", Localize_Universal)]];
                }
                else
                {
                    [maneuverInfo appendString:[NSString stringWithFormat:@"%d%@",pManeuverInfo->nNextDis,STR(@"Universal_M", Localize_Universal)]];
                }
            }
            else{
                [maneuverInfo appendString:@""];
            }
			
		}
			break;
		case 2://剩余距离(带单位)
		{
            if (res == GD_ERR_OK)
            {
                int dis = pManeuverInfo->nTotalRemainDis;
                if (dis > 1000)
                {
                    if (dis > 1000000) {
                        [maneuverInfo appendString:[NSString stringWithFormat:@"%0.0f%@",(dis/1000.0),STR(@"Universal_KM", Localize_Universal)]];
                    }
                    else {
                        [maneuverInfo appendString:[NSString stringWithFormat:@"%0.1f%@",(dis/1000.0),STR(@"Universal_KM", Localize_Universal)]];
                    }
                    
                }
                else
                {
                    [maneuverInfo appendString:[NSString stringWithFormat:@"%d%@",pManeuverInfo->nTotalRemainDis,STR(@"Universal_M", Localize_Universal)]];
                }
            }
            else{
                [maneuverInfo appendString:@""];
            }
            
		}
			break;
		case 3://剩余时间
		{
            if (res == GD_ERR_OK) {
                int time = pManeuverInfo->nTotalArrivalTime;
                
                NSUInteger hour = (time/60);
                NSUInteger minute = (time%60);
                if (hour >0)
                {
                    if (0 == minute) {//如果分钟为0，则不显示分钟
                        [maneuverInfo appendString:[NSString stringWithFormat:@"%d%@",hour,STR(@"Universal_hour", Localize_Universal)]];
                    }
                    else{
                        [maneuverInfo appendString:[NSString stringWithFormat:@"%d%@%d%@",hour,STR(@"Universal_hour", Localize_Universal),minute,STR(@"Universal_min", Localize_Universal)]];
                    }
                }
                else
                {
                    [maneuverInfo appendString:[NSString stringWithFormat:@"%d%@",minute,STR(@"Universal_min", Localize_Universal)]];
                }
            }
            else {
                [maneuverInfo appendString:@""];
            }
		}
			break;
		case 10://下个道路名称
		{
            if (res == GD_ERR_OK) {
                [maneuverInfo appendString:[NSString chinaFontStringWithCString:pManeuverInfo->szNextRoadName]];
            }
            else {
                [maneuverInfo appendString:@""];
            }
            
		}
			break;
        case 11://剩余距离
		{
            if (res == GD_ERR_OK) {
                [maneuverInfo appendString:[NSString stringWithFormat:@"%d",pManeuverInfo->nTotalRemainDis]];
            }
            else {
                [maneuverInfo appendString:@""];
            }
            
		}
			break;
        case 12://出现放大路口时获取距离下一路口的距离
        {
            GZOOMVIEWINFO zoominfo = {0};
            [MWRouteGuide GetCurrentZoomViewInfo:&zoominfo];
            int tmpDistance = zoominfo.nNextDis;
            if (tmpDistance > 1000)
            {
                [maneuverInfo appendString:[NSString stringWithFormat:@"%0.1f%@",(tmpDistance/1000.0),STR(@"Universal_KM", Localize_Universal)]];
            }
            else
            {
                [maneuverInfo appendString:[NSString stringWithFormat:@"%d%@",tmpDistance,STR(@"Universal_M", Localize_Universal)]];
            }
        }
            break;
            
		default:
			break;
	}
    
	return [maneuverInfo autorelease];
}


/**
 **********************************************************************
 \brief 单路线－获取路线信息
 \details 单路线－获取路线信息
 \retval	相关信息
 **********************************************************************/
+ (NSString *)GetPathStatisticInfoWithMainID:(int)mainID GuideHandel:(GHGUIDEROUTE)tmpGuideRouteHandle{
	
	NSString *pathStatisticInfo = @"";
    
    GPATHSTATISTICLIST *ppStatInfoList = NULL;
	if (GD_ERR_OK == GDBL_GetPathStatisticInfo(tmpGuideRouteHandle,Gtrue, Gfalse, &ppStatInfoList))
	{
		switch (mainID)
		{
			case 0:// 收费站
			{
				pathStatisticInfo = [NSString stringWithFormat:@"%d",ppStatInfoList->pPathStat->nTotalTollGate];
			}
				break;
				
			case 1:// 总距离(带单位)
			{
                
                int dis = ppStatInfoList->pPathStat->nTotalDis;
                if (dis > 1000)
                {
                    if (dis > 1000000) {
                        pathStatisticInfo = [NSString stringWithFormat:@"%0.0f%@",(dis/1000.0),STR(@"Universal_KM", Localize_Universal)];
                    }
                    else {
                        pathStatisticInfo = [NSString stringWithFormat:@"%0.1f%@",(dis/1000.0),STR(@"Universal_KM", Localize_Universal)];
                    }
                    
                }
                else
                {
                    pathStatisticInfo= [NSString stringWithFormat:@"%d%@",dis,STR(@"Universal_M", Localize_Universal)];
                }
			}
				break;
				
			case 2://耗时(带单位)
			{
                int time = ppStatInfoList->pPathStat->nTime;
                
                NSUInteger hour = (time/60);
                NSUInteger minute = (time%60);
                if (hour >0)
                {
                    if (0 == minute) {//分钟为0，则不显示分钟
                        pathStatisticInfo = [NSString stringWithFormat:@"%d%@",hour,STR(@"Universal_hour", Localize_Universal)];
                    }
                    else{
                        pathStatisticInfo = [NSString stringWithFormat:@"%d%@%d%@",hour,STR(@"Universal_hour", Localize_Universal),minute,STR(@"Universal_min", Localize_Universal)];
                    }
                    
                }
                else
                {
                    pathStatisticInfo = [NSString stringWithFormat:@"%d%@",minute,STR(@"Universal_min", Localize_Universal)];
                }
                
			}
				break;
			case 3://耗时
			{
                pathStatisticInfo = [NSString stringWithFormat:@"%d",ppStatInfoList->pPathStat->nTime];
				
			}
				break;
			case 4://总距离
			{
				pathStatisticInfo = [NSString stringWithFormat:@"%d",ppStatInfoList->pPathStat->nTotalDis];
			}
				break;
            case 5://收费总额
            {
                pathStatisticInfo = [NSString stringWithFormat:@"%d",ppStatInfoList->pPathStat->nTotalCharge];
            }
                break;
				
			default:
			{
				
                pathStatisticInfo = STR(@"Universal_unknown", Localize_Universal);
				
			}
				break;
		}
		
	}
	else
	{
		pathStatisticInfo = STR(@"Universal_unknown", Localize_Universal);
	}
	
	return pathStatisticInfo;
}

/**
 **********************************************************************
 \brief 多路线－获取路线信息 0：收费站 1：总距离 2：红绿灯个数 3：总耗时
 \details 多路线－获取路线信息
 \retval	相关信息
 **********************************************************************/
+ (NSString *)GetPathStatisticInfoWithMainID:(int)mainID index:(int)index{
	
	NSString *pathStatisticInfo;
	
    GPATHSTATISTICLIST *ppStatInfoList = NULL;
    GSTATUS res = GDBL_GetPathStatisticInfo(GNULL,Gtrue, Gtrue, &ppStatInfoList);
	if (GD_ERR_OK == res)
	{
        
        if(index >= ppStatInfoList->nNumberOfStat)
        {
            {
                pathStatisticInfo = STR(@"Universal_unknown", Localize_Universal);
                
            }
            return pathStatisticInfo;
        }
		switch (mainID)
		{
			case 0:// 收费站
			{
				pathStatisticInfo = [NSString stringWithFormat:@"%d",ppStatInfoList->pPathStat[index].nTotalTollGate];
			}
				break;
				
			case 1:// 总距离
			{
                if (ppStatInfoList->pPathStat[index].nTotalDis > 1000)
                {
                    pathStatisticInfo = [NSString stringWithFormat:@"%0.1f%@",(ppStatInfoList->pPathStat[index].nTotalDis/1000.0),STR(@"Universal_KM", Localize_Universal)];
                }
                else
                {
                    pathStatisticInfo = [NSString stringWithFormat:@"%d%@",ppStatInfoList->pPathStat[index].nTotalDis,STR(@"Universal_M", Localize_Universal)];
                }
				
			}
				break;
			case 2://红绿灯个数
			{
                NSUInteger lightCount = ppStatInfoList->pPathStat[index].nTotalTrafficLight;
                pathStatisticInfo = [NSString stringWithFormat:@"%d",lightCount];
			}
				break;
            case 3://耗时
			{
				
                NSUInteger hour = (ppStatInfoList->pPathStat[index].nTime/60);
                NSUInteger minute = (ppStatInfoList->pPathStat[index].nTime%60);
                if (hour >0)
                {
                    if (0 == minute) {//如果分钟为0，则不显示分钟
                        pathStatisticInfo = [NSString stringWithFormat:@"%d%@",hour,STR(@"Universal_hour", Localize_Universal)];
                    }
                    else{
                        pathStatisticInfo = [NSString stringWithFormat:@"%d%@%d%@",hour,STR(@"Universal_hour", Localize_Universal),minute,STR(@"Universal_min", Localize_Universal)];
                    }
                    
                    
                }
                else
                {
                    pathStatisticInfo = [NSString stringWithFormat:@"%d%@",minute,STR(@"Universal_min", Localize_Universal)];
                }
                
				
			}
				break;
            case 4://耗时 英文版
			{
				
                NSUInteger hour = (ppStatInfoList->pPathStat[index].nTime/60);
                NSUInteger minute = (ppStatInfoList->pPathStat[index].nTime%60);
                if (hour >0)
                {
                    if (0 == minute) {//如果分钟为0，则不显示分钟
                        pathStatisticInfo = [NSString stringWithFormat:@"%d %@",hour,@"h"];
                    }
                    else{
                        pathStatisticInfo = [NSString stringWithFormat:@"%d %@ %d %@",hour,@"h",minute,@"min"];
                    }
                    
                    
                }
                else
                {
                    pathStatisticInfo = [NSString stringWithFormat:@"%d %@",minute,@"min"];
                }
                
				
			}
				break;
			default:
			{
				pathStatisticInfo = STR(@"Universal_unknown", Localize_Universal);
				
			}
				break;
		}
	}
	else
	{
		pathStatisticInfo = STR(@"Universal_unknown", Localize_Universal);
	}
	
	return pathStatisticInfo;
}

/**
 **********************************************************************
 \brief 获取主要道路列表
 \details 获取主要道路列表
 \retval	数组 元素为 MainRoadInfo 对象
 **********************************************************************/
+ (NSArray *)GetMainGuideRoadList
{
    // Traffic status 4 (free, slow, crounded, nodata)
    float fFree=0.0, fSlow=0.0, fCrounded=0.0, fNoData=0.0;
    int nCarPosition = 0;
    //
	NSMutableArray *RoadListInfo = [[NSMutableArray alloc] init];
	
    GGUIDEROADLIST *ppGuideRoadList = NULL;
	GSTATUS res = GDBL_GetGuideRoadList(NULL,Gfalse, &ppGuideRoadList);
    if (GD_ERR_OK == res) {
        for (int i=0; i<ppGuideRoadList->nNumberOfRoad; i++) {
            if(ppGuideRoadList->pGuideRoadInfo[i].eFlag&0x04)
            {
                nCarPosition =  ppGuideRoadList->nNumberOfRoad-1-i;
            }
        }
        
        int nTotalDistance = 0;
        MainRoadInfo* mainRoadInfo;
        for (int i = 0; i < ppGuideRoadList->nNumberOfRoad; i++)
        {
            // 道路方向
            int nDirectID = ppGuideRoadList->pGuideRoadInfo[i].unTurnID;
            // 道路距离
            NSString* szDistance;
            nTotalDistance+=ppGuideRoadList->pGuideRoadInfo[i].nNextDis;
            if (ppGuideRoadList->pGuideRoadInfo[i].nNextDis < 1000)
            {
                szDistance = [NSString stringWithFormat:@"%d%@",ppGuideRoadList->pGuideRoadInfo[i].nNextDis,STR(@"Universal_M", Localize_Universal)];
            }
            else
            {
                szDistance = [NSString stringWithFormat:@"%.1f%@",(ppGuideRoadList->pGuideRoadInfo[i].nNextDis)/1000.0,STR(@"Universal_KM", Localize_Universal)];
            }
            // 当前道路名称
            NSString* szRoadName = GcharToNSString(ppGuideRoadList->pGuideRoadInfo[i].pzCurRoadName);
            
            
            // 下一道路名称
            NSString *szNextRoadName = GcharToNSString(ppGuideRoadList->pGuideRoadInfo[i].pzNextRoadName);
            
            
            // 道路交通情况        // UI层只定义4个情况 1 畅通；2,3 缓行；4,5拥堵；6,7无数据
            int nTrafficStatus = 4;
            if ([MWEngineSwitch isTMCOn]&&[[MWPreference sharedInstance] getValue:PREF_TRAFFICMESSAGE])
            {
                if (ppGuideRoadList->pGuideRoadInfo[i].eTrafficStream<=1) {
                    nTrafficStatus = 1;
                    fFree+=ppGuideRoadList->pGuideRoadInfo[i].nNextDis;
                }else if(ppGuideRoadList->pGuideRoadInfo[i].eTrafficStream<=3) {
                    nTrafficStatus = 2;
                    fSlow+=ppGuideRoadList->pGuideRoadInfo[i].nNextDis;
                }else if(ppGuideRoadList->pGuideRoadInfo[i].eTrafficStream<=5) {
                    nTrafficStatus = 3;
                    fCrounded+=ppGuideRoadList->pGuideRoadInfo[i].nNextDis;
                }else{
                    fNoData+=ppGuideRoadList->pGuideRoadInfo[i].nNextDis;
                }
            }
            NSLog(@"交通流：%d",nTrafficStatus);
            // 新建
            mainRoadInfo = [[MainRoadInfo alloc]init];
            mainRoadInfo.psnDirectID = nDirectID;
            mainRoadInfo.psnTrafficStatus = nTrafficStatus;
            mainRoadInfo.psszDistance = szDistance;
            mainRoadInfo.psszRoadName = szRoadName;
            mainRoadInfo.psszNextRoadName = szNextRoadName;
            mainRoadInfo.psnIndexInRoadList = i;
            
            // 车位是否在道路上
            if (ppGuideRoadList->nNumberOfRoad-1-i==nCarPosition) {
                
                mainRoadInfo.psbCarOnTheRoad = TRUE;
            }
            //事件状态
            GEVENTINFO *pEventInfo = {0};
            Gint32 nEventCount = 0;
            
            res = GDBL_FilterTMCEvent(GNULL,0,TRUE);//设置事件过滤
            res = GDBL_GetEventInfo(&pEventInfo, &nEventCount);//获取过滤后的所有事件
            if (GD_ERR_OK == res) {
                for (int j = 0; j < nEventCount; j++) {
                    if (pEventInfo[j].stObjectId.unMeshID == ppGuideRoadList->pGuideRoadInfo[i].stObjectId.unMeshID && pEventInfo[j].stObjectId.u16AdareaID == ppGuideRoadList->pGuideRoadInfo[i].stObjectId.u16AdareaID) {
                        
                        //道路名字
                        NSString *roadName = [NSString chinaFontStringWithCString:pEventInfo[j]. szRoadName];
                        NSString *disFromCar;
                        NSString *streamType;
                        NSString *impactRange;
                        
                        //车辆距事件，交通流距离
                        
                        float fDistance = pEventInfo[j].nDisToCar;
                        if (fDistance>1000) {
                            fDistance = fDistance/1000;
                            disFromCar = [NSString stringWithFormat:@"%.2f%@", fDistance,STR(@"Universal_KM", Localize_Universal)];
                        }else{
                            disFromCar = [NSString stringWithFormat:@"%.f%@", fDistance,STR(@"Universal_M", Localize_Universal)];
                        }
                        
                        //交通流类型
                        int type = pEventInfo[j].nEventID > 20 ? ((pEventInfo[j].nEventID >> 16) & 0Xff) : pEventInfo[j].nEventID;
                        if (type == 2 || type == 3) {
                            streamType = STR(@"TMC_slow", Localize_TMC);
                        }
                        else if (type == 4 || type == 5)
                        {
                            streamType = STR(@"TMC_congest", Localize_TMC);
                        }
                        else if (type == 33)
                        {
                            streamType = STR(@"TMC_accident", Localize_TMC);
                        }
                        else if (type == 34)
                        {
                            streamType = STR(@"TMC_underConstruction", Localize_TMC);
                        }
                        else if (type == 35)
                        {
                            streamType = STR(@"TMC_trafficControl", Localize_TMC);
                        }
                        else if (type == 36)
                        {
                            streamType = STR(@"TMC_roadBarrier", Localize_TMC);
                        }
                        else if (type == 37)
                        {
                            streamType = STR(@"TMC_events", Localize_TMC);
                        }
                        else if (type == 38)
                        {
                            streamType = STR(@"TMC_disaster", Localize_TMC);
                        }
                        else if (type == 39)
                        {
                            streamType = STR(@"TMC_badWeather", Localize_TMC);
                        }
                        else{
                            streamType = @"";
                        }
                        
                        //影响范围
                        
                        float fRange = pEventInfo[j]. nLength;
                        if (fRange>1000) {
                            fRange = fRange/1000;
                            impactRange = [NSString stringWithFormat:@"%.2f%@", fRange,STR(@"Universal_KM", Localize_Universal)];
                        }else{
                            impactRange = [NSString stringWithFormat:@"%.f%@", fRange,STR(@"Universal_M", Localize_Universal)];
                        }
                        mainRoadInfo.psszEventName = streamType;
                        mainRoadInfo.psnEventState = type;
                        mainRoadInfo.psbEvent = TRUE;
                        if (type > 20) {
                            mainRoadInfo.psszEventDetail = [NSString stringWithFormat:STR(@"TMC_eventInfo", Localize_TMC),disFromCar,roadName,streamType];
                        }
                        else{
                            mainRoadInfo.psszEventDetail = [NSString stringWithFormat:STR(@"TMC_trafficInfo", Localize_TMC),disFromCar,roadName,streamType,impactRange];
                        }
                        NSLog(@"detail==%@",mainRoadInfo.psszEventDetail);
                        break;
                        
                    }
                    mainRoadInfo.psbEvent = FALSE;
                }
            }
            
            [RoadListInfo addObject:mainRoadInfo];
            [mainRoadInfo release];
            
        }
        
        
        /*
         1 calculate the persentage of the traffic status
         */
        float ftotal = fNoData+fFree+fSlow+fCrounded;
        [CustomRealTimeTraffic sharedInstance].psfFreeStatus = fFree/ftotal;
        [CustomRealTimeTraffic sharedInstance].psfSlowStatus = fSlow/ftotal;
        [CustomRealTimeTraffic sharedInstance].psfHeavyStatus = fCrounded/ftotal;
        return RoadListInfo;
        
    }
	return nil;
    
}

/**
 **********************************************************************
 \brief 获取车位所在道路索引
 \details 获取车位所在道路索引
 \retval 道路索引
 **********************************************************************/
+ (int)GetCarOnRoadIndex
{
    GGUIDEROADLIST *ppGuideRoadList;
    GSTATUS res = GDBL_GetGuideRoadList(NULL,Gfalse, &ppGuideRoadList);
    if (GD_ERR_OK == res) {
        for (int i=0; i<ppGuideRoadList->nNumberOfRoad; i++) {
            if(ppGuideRoadList->pGuideRoadInfo[i].eFlag&0x04)
            {
                return i;
            }
        }
    }
    return 0;
    
}

#pragma mark 获取当前车位的道路id
/**********************************************************************
 * 函数名称: GetRoadIDCarPositon
 * 功能描述: 获取当前车位的道路id
 * 参    数:
 * 返 回 值: 道路id
 * 其它说明:
 **********************************************************************/
+ (int) GetRoadIDCarPositon
{
    GGUIDEROADLIST *ppGuideRoadList;
    GSTATUS nStatus = GDBL_GetGuideRoadList(NULL,TRUE, &ppGuideRoadList);
    if (nStatus == GD_ERR_OK) {
        for (int i=0; i<ppGuideRoadList->nNumberOfRoad; i++) {
            if(ppGuideRoadList->pGuideRoadInfo[i].eFlag&0x04)
            {
                return  ppGuideRoadList->nNumberOfRoad-1-i;
            }
        }
    }
    return 0;
}

#pragma mark 获取路线详情列表(参数为路线的信息类型:0-转向ID 1-下路口距离和路口名称 2-转向ID图片 3-下路口距离 4-路口名称 5-路口ID 6-交通信息情况)
/**********************************************************************
 * 函数名称: MW_GetGuideRoadListInfoWithID
 * 功能描述: 获取路线详情列表
 * 参    数:[IN] ID:信息类别 0-转向ID 1-下路口距离和路口名称 2-转向ID图片 3-下路口距离 4-路口名称 5-路口ID 6-交通信息情况
 * 返 回 值: 返回相对应的数组信息
 * 其它说明:
 **********************************************************************/
+ (NSArray *)GetGuideRoadListInfoWithID:(NSInteger)ID {
    
	NSMutableArray *RoadListInfo = [[NSMutableArray alloc] init];
	
    GGUIDEROADLIST *ppGuideRoadList = NULL;
	GSTATUS res = GDBL_GetGuideRoadList(NULL,Gfalse, &ppGuideRoadList);
	
    if (res != GD_ERR_OK)
    {
        [RoadListInfo release];
        return nil;
    }
    
	switch (ID)
	{
		case 0://转向ID
		{
			for (int i=0; i<ppGuideRoadList->nNumberOfRoad; i++)
			{
				[RoadListInfo addObject:[NSString stringWithFormat:@"%d",ppGuideRoadList->pGuideRoadInfo[i].unTurnID]];
			}
		}
			break;
			
		case 1://下路口距离和路口名称
		{
			for (int i=0; i<ppGuideRoadList->nNumberOfRoad; i++)
			{
				NSString *tmp = [NSString chinaFontStringWithCString:ppGuideRoadList->pGuideRoadInfo[i].pzCurRoadName];
				if ((ppGuideRoadList->pGuideRoadInfo[i].nNextDis)<1000)
				{
					[RoadListInfo addObject:[NSString stringWithFormat:@"%6dm      %@",(ppGuideRoadList->pGuideRoadInfo[i].nNextDis),tmp]];
				}
				else
				{
                    [RoadListInfo addObject:[NSString stringWithFormat:@"%.2fkm      %@",(ppGuideRoadList->pGuideRoadInfo[i].nNextDis)/1000.0,tmp]];
                }
            }
		}
			break;
			
		case 2://转向ID图片
		{
			for (int i=0; i<ppGuideRoadList->nNumberOfRoad; i++)
			{
				[RoadListInfo addObject:[MWRouteGuide GetTurnIconWithID:ppGuideRoadList->pGuideRoadInfo[i].unTurnID flag:1]];
			}
		}
			break;
			
		case 3://下路口距离
		{
			for (int i=0; i<ppGuideRoadList->nNumberOfRoad; i++)
			{
				if (ppGuideRoadList->pGuideRoadInfo[i].nNextDis < 1000)
				{
					[RoadListInfo addObject:[NSString stringWithFormat:@"%dm",ppGuideRoadList->pGuideRoadInfo[i].nNextDis]];
				}
				else
				{
					[RoadListInfo addObject:[NSString stringWithFormat:@"%.2fkm",(ppGuideRoadList->pGuideRoadInfo[i].nNextDis)/1000.0]];
				}
			}
		}
			break;
			
		case 4://路口名称
		{
			for (int i=0; i<ppGuideRoadList->nNumberOfRoad; i++)
			{
				NSString *tmp = [NSString chinaFontStringWithCString:ppGuideRoadList->pGuideRoadInfo[i].pzCurRoadName];
				[RoadListInfo addObject:[NSString stringWithFormat:@"%@",tmp]];
			}
		}
			break;
        case 5://路口ID
        {
            for (int i=0; i<ppGuideRoadList->nNumberOfRoad; i++)
			{
				[RoadListInfo addObject:[NSNumber numberWithInt:ppGuideRoadList->pGuideRoadInfo[i].nID]];
                NSLog(@"%d",ppGuideRoadList->pGuideRoadInfo[i].nID);
			}
        }
        case 6://交通信息情况
        {
            for (int i=0; i<ppGuideRoadList->nNumberOfRoad; i++) {
                int nTrafficStatus = 0;
                // UI层只定义4个情况 1 畅通；2,3 缓行；4,5拥堵；6,7无数据
                if (ppGuideRoadList->pGuideRoadInfo[i].eTrafficStream<=1) {
                    nTrafficStatus = 1;
                }else if(ppGuideRoadList->pGuideRoadInfo[i].eTrafficStream<=3) {
                    nTrafficStatus = 2;
                }else if(ppGuideRoadList->pGuideRoadInfo[i].eTrafficStream<=5) {
                    nTrafficStatus = 3;
                }else{
                    nTrafficStatus = 4;
                }
                [RoadListInfo addObject:[NSNumber numberWithInt:nTrafficStatus]];
                //
                NSLog(@"%d",ppGuideRoadList->pGuideRoadInfo[i].nID);
            }
        }
            break;
		default:
			break;
	}
	
	return [RoadListInfo autorelease];
}

#pragma mark 获取转向ID的图片(参数为转向ID)
/**********************************************************************
 * 函数名称: MW_GetTurnIconWithID
 * 功能描述: 获取转向ID的图片(参数为转向ID)
 * 参    数:
 * 返 回 值: 图片
 * 其它说明:
 **********************************************************************/
+ (UIImage *)GetTurnIconWithID:(NSInteger)ID flag:(NSInteger)nflag
{
    
	GBITMAP *ppBitmap;
    GIMAGEPARAM pImageParam = {0};
    
    pImageParam.eImageType = G_IMAGE_TYPE_TURN;
    pImageParam.nFlag = nflag;
    pImageParam.nImageID = ID;
    
	GSTATUS res =  GDBL_GetImage(&pImageParam, &ppBitmap);
	if(GD_ERR_OK != res || ppBitmap->pData == NULL || ppBitmap->pAlpha == NULL)
    {
        return nil;
    }
    
    char *argb = (char *)Convert565_888(ppBitmap->pData, ppBitmap->nWidth , ppBitmap->nHeight, ppBitmap->pAlpha);
    
	int bitsPerComponent = 8;
	int bitsPerPixel = 32;
	int bytesPerRow = ppBitmap->nWidth * 4;
	CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
	CGBitmapInfo bitmapInfo = kCGImageAlphaLast;
	CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
	
	CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, argb, ppBitmap->nWidth*ppBitmap->nHeight, releaseRgba);
    CGImageRef   imageRef = CGImageCreate(ppBitmap->nWidth, ppBitmap->nHeight, bitsPerComponent, bitsPerPixel, bytesPerRow,  colorSpaceRef, bitmapInfo, provider, NULL, true, renderingIntent);
	// then make the uiimage from that
	UIImage *myImage = [UIImage imageWithCGImage:imageRef];
    
	CGImageRelease(imageRef);
    CGColorSpaceRelease(colorSpaceRef);
    CGDataProviderRelease(provider);
    //free(argb);
    GDBL_UnLoadImage(&pImageParam, ppBitmap);//modify by gzm for 调用GDBL_GetImage接口获取图片信息，引擎将不再对图片进行缓存和生成纹理，由调用者对图片进行管理。最后需调用GDBL_UnLoadImage来进行释放图片内存，否则将会导致内存泄露的问题。 at 2014-10-31
	return myImage;
}

/**********************************************************************
 * 函数名称: releaseRgba
 * 功能描述: 释放内存
 * 参    数:
 * 返 回 值:
 * 其它说明:
 **********************************************************************/
void releaseRgba(void *info, const void *data, size_t size)
{
    free((void*)data);
}

#pragma mark 导航操作(参数mainID:0:开始导航,1:停止导航)
/**********************************************************************
 * 函数名称: GuidanceOperateWithMainID
 * 功能描述: 导航操作(参数mainID:0:开始导航,1:停止导航)
 * 参    数: mainID：0:开始导航,1:停止导航 guideHandle:句柄
 * 返 回 值:
 * 其它说明:
 **********************************************************************/
+ (void)GuidanceOperateWithMainID:(NSInteger)mainID GuideHandle:(GHGUIDEROUTE)guideHandle
{
    
	switch (mainID)
	{
		case 0:
		{
            GSTATUS res;
            res = [MWRouteGuide StartGuide:NULL];
            if (GD_ERR_OK==res)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_STARTGUIDANCE object:nil];
            }
            [[MWMapOperator sharedInstance] MW_GoToCCP];
		}
			break;
			
		case 1:
		{
            
            //停止导航，可以继续请求停车场信息
            [ANParamValue sharedInstance].isRequestParking =1;
            
            [[DringTracksManage sharedInstance] drivingTrackCalculateWithNewLocation:nil oldLocation:nil andType:TrackCountType_End];//轨迹计算结束
            
            //删除路线清空周边图面小红点
            MWMapAddIconOperator *_mapAddIcon =  [[MWMapAddIconOperator alloc] init];
            
            [_mapAddIcon freshPoiDic:nil];
            [_mapAddIcon release];
            
            GSTATUS res;
            res = [MWRouteGuide StopGuide:Gfalse];
            GDBL_ClearDetourRoad();//删除所有避让内容
            
            GDBL_ClearJourneyPoint();
            if (GD_ERR_OK==res)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_STOPGUIDANCE object:nil];
            }
            [[MWMapOperator sharedInstance] MW_GoToCCP];
            if (UIApplicationStateBackground == [[UIApplication sharedApplication] applicationState] || UIApplicationStateInactive == [[UIApplication sharedApplication] applicationState]) {//进入后台删除路径改变定位精度
                [MWGPS backgroundLocationHandle];
            }
        }
			break;
			
		default:
			break;
	}
    
}

/**
 **********************************************************************
 \brief  获取机动文本列表
 \details 该函数用于获取引导机动文本列表。
 \param[in]  hGuideRoute	引导路径句柄
 \retval	ManeuverInfoList  机动文本列表
 \remarks
 - 描述文本起止标记定义（起始和终止标记相同且配对出现）
 当前道路名- [c]
 方位      - [a]
 距离值    - [d]
 转向语句  - [t]
 下一道路名- [n]
 如：沿[c]厦禾路[c]向[a]西北[a]方向，行驶...
 **********************************************************************/
+(ManeuverInfoList *)GetManeuverTextList:(GHGUIDEROUTE)hGuideRoute
{
    ManeuverInfoList *list = [[ManeuverInfoList alloc] init];
    
    GMANEUVERTEXTLIST glist = {0};
    Gbool bMainRoad = Gfalse;
    GSTATUS res = [MWRouteGuide GetManeuverTextList:hGuideRoute list:&glist bMainRoad:&bMainRoad];
    if (res == GD_ERR_OK)
    {
        GEVENTINFO *pEventInfo = NULL;
        int EventCount = 0;

        res = GDBL_GetEventInfo(&pEventInfo, &EventCount);
        list.nNumberOfManeuver = glist.nNumberOfManeuver;
        NSMutableArray *array = [NSMutableArray array];
        for (int i = 0; i < glist.nNumberOfManeuver; i++)
        {
            GMANEUVERTEXT text = glist.pManeuverText[i];
            ManeuverInfo *info = [MWRouteGuide RecursiveGetInfoWith:text eventList:pEventInfo eventCount:EventCount];
            if (info)
            {
                [array addObject:info];
            }
        }
        list.pManeuverText = [NSArray arrayWithArray:array];
        [MWRouteGuide GetMainRoadNameAndNextRoadName:list];
    }
    
    return [list autorelease];
}

/*
 * @brief 组装主要道路的当前道路名和下一道路名
 */

+ (void)GetMainRoadNameAndNextRoadName:(ManeuverInfoList *)list
{
    if (list == nil)
    {
        return;
    }
    for (int i = 0; i < list.nNumberOfManeuver; i++) //获取主要道路名
    {
        ManeuverInfo *mainRoadInfo = [list.pManeuverText caObjectsAtIndex:i];
        if ([mainRoadInfo.currentLoadName isEqualToString:STR(@"Main_unNameRoad", Localize_Main)])
        {
            mainRoadInfo.currentLoadName = mainRoadInfo.szDescription;
            if ([mainRoadInfo.currentLoadName length] > 0)  //从***出发，***便是当前道路名
            {
                NSRange range = [mainRoadInfo.currentLoadName rangeOfString:@"出发"];
                if (range.length > 0)
                {
                    mainRoadInfo.currentLoadName = [mainRoadInfo.currentLoadName CutFromNSString:@"从" Tostring:@"出发"];
                }
                range = [mainRoadInfo.currentLoadName rangeOfString:@"沿道路"];
                if (range.length > 0)
                {
                    mainRoadInfo.currentLoadName = @"";
                }
            }
        }
    }
    
    for (int i = 0; i < list.nNumberOfManeuver; i++)
    {
        ManeuverInfo *mainRoadInfo = [list.pManeuverText caObjectsAtIndex:i];
        if (mainRoadInfo.nNumberOfSubManeuver > 0)
        {
            for (int j = 0; j < mainRoadInfo.nNumberOfSubManeuver; j++)
            {
                ManeuverInfo *subRoadInfo = [mainRoadInfo.pstSubManeuverText caObjectsAtIndex:j];
                if ([subRoadInfo.currentLoadName isEqualToString:STR(@"Main_unNameRoad", Localize_Main)]) //如果当前道路名等于未知道路，则获取上一个子节点的下一道路名
                {
                    if (j > 0)
                    {
                        ManeuverInfo *last_subRoadInfo = [mainRoadInfo.pstSubManeuverText caObjectsAtIndex:j - 1];
                        subRoadInfo.currentLoadName = last_subRoadInfo.nextLoadName;
                    }
                }
                if ([subRoadInfo.nextLoadName isEqualToString:STR(@"Main_unNameRoad", Localize_Main)]) //如果下一道路名等于未知道路，则获取下一个子节点的当前道路名或者下一主要道路名
                {
                    if (j < mainRoadInfo.nNumberOfSubManeuver - 1)
                    {
                        ManeuverInfo *next_subRoadInfo = [mainRoadInfo.pstSubManeuverText caObjectsAtIndex:j + 1];
                        subRoadInfo.nextLoadName = next_subRoadInfo.currentLoadName;
                    }
                    else
                    {
                        ManeuverInfo *next_mainRoadInfo = [list.pManeuverText caObjectsAtIndex:i+1];
                        subRoadInfo.nextLoadName = next_mainRoadInfo.currentLoadName;
                    }
                }
            }
            ManeuverInfo *subRoadInfo = [mainRoadInfo.pstSubManeuverText caObjectsAtIndex:0];
            mainRoadInfo.nextLoadName = subRoadInfo.currentLoadName;
            mainRoadInfo.unTurnID = subRoadInfo.unTurnID;  //主要道路存在子道路下，主道路的转向图标使用第一个子道路转向图标
            if (i == list.nNumberOfManeuver - 2)  //倒数第二个终点的转向图标设置为直行
            {
                NSMutableArray *array = [NSMutableArray array];
                [array addObjectsFromArray:mainRoadInfo.pstSubManeuverText];
                if ([array count] == 1)
                {
                    mainRoadInfo.unTurnID = 17;
                }
                if ([array count] > 0)
                {
                    [array removeObjectAtIndex:[array count] - 1];
                    mainRoadInfo.pstSubManeuverText = [NSArray arrayWithArray:array];
                    mainRoadInfo.nNumberOfSubManeuver =  mainRoadInfo.nNumberOfSubManeuver - 1;
                }
            }
        }
        
    }
}

/*
 当前道路名- [c]
 方位      - [a]
 距离值    - [d]
 转向语句  - [t]
 下一道路名- [n]
 */
+ (ManeuverInfo *)RecursiveGetInfoWith:(GMANEUVERTEXT)ginfo eventList:(GEVENTINFO *)eventList eventCount:(int)eventCount
{
    if (&ginfo == NULL)
    {
        return nil;
    }
    ManeuverInfo *info = [[ManeuverInfo alloc] init];
    info.Coord = ginfo.Coord;
    info.stObjectId = ginfo.stObjectId;
    info.nID = ginfo.nID;
    info.unTurnID = ginfo.unTurnID;
    info.nNextDis = ginfo.nNextDis;
    info.nNextArrivalTime = ginfo.nNextArrivalTime;
    info.nTotalRemainDis = ginfo.nTotalRemainDis;
    info.nTrafficLightNum = ginfo.nTrafficLightNum;
    info.eTrafficStream = ginfo.eTrafficStream;
    info.nTrafficEventID = ginfo.nTrafficEventID;
    info.eFlag = ginfo.eFlag;
    info.nDisFromCar = ginfo.nDisFromCar;
    info.szDescription = GcharToNSString(ginfo.szDescription);
    info.currentLoadName = [info.szDescription CutFromNSString:@"c]" Tostring:@"[c"];
    info.nextLoadName = [info.szDescription CutFromNSString:@"n]" Tostring:@"[n"];
    info.szDescription = [info.szDescription stringByReplacingOccurrencesOfString:@"[c]" withString:@""]; //去除多余字符
    info.szDescription = [info.szDescription stringByReplacingOccurrencesOfString:@"[a]" withString:@""]; //去除多余字符
    info.szDescription = [info.szDescription stringByReplacingOccurrencesOfString:@"[d]" withString:@""]; //去除多余字符
    info.szDescription = [info.szDescription stringByReplacingOccurrencesOfString:@"[t]" withString:@""]; //去除多余字符
    info.szDescription = [info.szDescription stringByReplacingOccurrencesOfString:@"[n]" withString:@""]; //去除多余字符
    GDETOURROADINFO detourRoadInfo = [MWRouteGuide getDetourRoadWith:info]; //获取避让道路结构体
    info.detourRoadInfo = malloc(sizeof(GDETOURROADINFO));
    memcpy(info.detourRoadInfo, &detourRoadInfo, sizeof(GDETOURROADINFO));
    if (ginfo.nTrafficObjIdNum > 0 && eventCount > 0 && eventList != NULL)     //获取事件信息
    {
        info.pstGeventInfo = malloc(sizeof(GEVENTINFO) * ginfo.nTrafficObjIdNum);
        for (int i = 0; i < ginfo.nTrafficObjIdNum; i++)
        {
            for (int j = 0; j < eventCount; j++)
            {
                GEVENTINFO tempEvent = eventList[j];
                if ([MWRouteGuide stObjectIdIsEqual:tempEvent.stObjectId objectId2:ginfo.pstTrafficObjId[i]])
                {
                    memcpy(&info.pstGeventInfo[i], &tempEvent, sizeof(GEVENTINFO));
                }
            }
        }
    }
    
    NSMutableArray *array = [NSMutableArray array];
    info.nNumberOfSubManeuver = ginfo.nNumberOfSubManeuver;
    for (int i = 0; i < ginfo.nNumberOfSubManeuver; i++)
    {
        GMANEUVERTEXT text = ginfo.pstSubManeuverText[i];
        ManeuverInfo *info = [MWRouteGuide RecursiveGetInfoWith:text eventList:eventList eventCount:eventCount];
        /*!
          @param isSonPoint -- 添加是否是子节点标志
          @add   by bazinga
          */
        info.isSonPoint = YES;
        if (info)
        {
            [array addObject:info];
        }
    }
    info.pstSubManeuverText = array;
    return [info autorelease];
}

+ (BOOL)stObjectIdIsEqual:(GOBJECTID)objectId1 objectId2:(GOBJECTID)objectId2
{
    if (objectId1.u16AdareaID == objectId2.u16AdareaID &&
        objectId1.u8LayerID == objectId2.u8LayerID &&
        objectId1.u8Rev == objectId2.u8Rev &&
        objectId1.unMeshID == objectId2.unMeshID &&
        objectId1.unObjectID == objectId2.unObjectID &&
        objectId1.unRev == objectId2.unRev) {
        return YES;
    }
    return NO;
}


+ (GDETOURROADINFO)getDetourRoadWith:(ManeuverInfo *)info
{
    
    // 时间
    NSDate *dateStartTime = [[NSDate alloc] init];
    NSDate *dateEndTime = [[NSDate alloc] initWithTimeIntervalSinceNow:86400];// 一天24*60*60
    NSCalendar *chineseCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSUInteger CalendarFlags = NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit|NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit;
    NSDateComponents* dcpStartTime = [chineseCalendar components:CalendarFlags fromDate:dateStartTime];
    NSDateComponents* dcpEndTime = [chineseCalendar components:CalendarFlags fromDate:dateEndTime];
    [dateStartTime release];
    [dateEndTime release];
    [chineseCalendar release];
    //
	GDETOURROADINFO pDetourRoad = {0};
    
	pDetourRoad.eOption = GDETOUR_OPTION_FOREVER;
    pDetourRoad.stObjectId = info.stObjectId;
    pDetourRoad.Coord = info.Coord;
    GcharMemcpy(pDetourRoad.szRoadName, NSStringToGchar(info.currentLoadName), GMAX_POI_NAME_LEN+1);
    // 开始时间
    pDetourRoad.StartTime.date.day = [dcpStartTime day];
    pDetourRoad.StartTime.date.month = [dcpStartTime month];
    pDetourRoad.StartTime.date.year = [dcpStartTime year];
    pDetourRoad.StartTime.time.hour = [dcpStartTime hour];
    pDetourRoad.StartTime.time.minute = [dcpStartTime minute];
    pDetourRoad.StartTime.time.second = [dcpStartTime second];
    // 结束时间
    pDetourRoad.EndTime.date.day = [dcpEndTime day];
    pDetourRoad.EndTime.date.month = [dcpEndTime month];
    pDetourRoad.EndTime.date.year = [dcpEndTime year];
    pDetourRoad.EndTime.time.hour = [dcpEndTime hour];
    pDetourRoad.EndTime.time.minute = [dcpEndTime minute];
    pDetourRoad.EndTime.time.second = [dcpEndTime second];
    
    return pDetourRoad;
}

#pragma mark -
#pragma mark 路径演算失败（无数据），获取缺失城市信息
/**
 **********************************************************************
 \brief 获取路径演算缺失城市列表
 \retval	缺失城市列表 数组里面的对象为MWAreaInfo
 **********************************************************************/
+ (NSArray *)GetRouteErrorInfo
{
    NSMutableArray *array = [NSMutableArray array];
    GROUTEERRORINFO *pRouteErrorInfo = NULL;
    GSTATUS res = GDBL_GetRouteErrorInfo(&pRouteErrorInfo);
    if (res == GD_ERR_OK)
    {
        for (int i = 0; i < pRouteErrorInfo->nNumberOfList; i++)
        {
            if (pRouteErrorInfo->pAdminCodeList[i] != 0)  //返回的行政编码列表中的行政编码不能为0
            {
                MWAreaInfo *info = [MWAdminCode GetCurAdareaWith:pRouteErrorInfo->pAdminCodeList[i]];
                if (info)
                {
                    [array addObject:info];
                }
            }
        }
    }
    return [NSArray arrayWithArray:array];
}

#pragma mark -
#pragma mark 播报全程概览语音
/**
 **********************************************************************
 \brief 播报全程概览语音
 \retval	播报全程概览语音
 **********************************************************************/
+ (void)PlayWholeRouteSound
{
    //进入全程概览播报：路径规划完成全程xxx公里/米预计需要XX分钟/小时
    NSString *ttsString = [NSString stringWithFormat:STR(@"Route_ttsPlayRoute", Localize_RouteOverview),
                           [MWRouteGuide GetPathStatisticInfoWithMainID:1 index:0],
                           [MWRouteGuide GetPathStatisticInfoWithMainID:3 index:0]];
    [[MWTTS SharedInstance] playSoundWithString:ttsString priority:TTSPRIORITY_INTERRUPTSELF];
}

/**
 **********************************************************************
 \brief 返回当前引导句柄
 \retval	返回当前引导句柄
 *****************************/
 + (GHGUIDEROUTE)getCurrentRouteHandler
{
    GHGUIDEROUTE routeList[4] = {0};
    int returnCount = 0;
    [MWRouteGuide GetGuideRouteList:routeList count:4 returnCount:&returnCount];
    if(returnCount == 1)
    {
        return routeList[0];
    }
    else if(returnCount > 1)
    {
        if (g_currentGuidRouteAfterChange == NULL)
        {
            return routeList[0];
        }
        else
        {
            return g_currentGuidRouteAfterChange;
        }
    }
    return NULL;
}

/**
 **********************************************************************
 \brief 重新添加remove的路径句柄
 *****************************/
+ (void)readdRouteHandler
{
    for (int i = 0; i < 4; i++)
    {
        if (g_currentRouteList[i] != GNULL)
        {
            [MWRouteGuide AddGuideRoute:g_currentRouteList[i]];
        }
    }
}

/**
 **********************************************************************
 \brief 清空路径句柄
 *****************************/
+ (void)clearRouteHandler
{
    memset(g_currentRouteList, 0, sizeof(GHGUIDEROUTE)*4);
}
 
@end

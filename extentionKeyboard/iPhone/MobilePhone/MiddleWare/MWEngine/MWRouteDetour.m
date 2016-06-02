//
//  MWRouteDetour.m
//  AutoNavi
//
//  Created by gaozhimin on 14-5-7.
//
//

#import "MWRouteDetour.h"

@implementation MWRouteDetour

/**
 **********************************************************************
 \brief 添加避让道路
 \details 添加避让道路，保存到避让文件中。
 \param[in]  pstDetourRoad 避让道路信息
 \retval	GD_ERR_OK 成功
 \retval	GD_ERR_INVALID_PARAM	参数无效
 \retval	GD_ERR_NO_DATA 无相关数据
 \retval	GD_ERR_FAILED	操作失败
 \remarks
 \since 6.0
 \see GDBL_GetDetourRoadList
 **********************************************************************/
+ (GSTATUS)AddDetourRoad:(GDETOURROADINFO *)pstDetourRoad
{
    return GDBL_AddDetourRoad(pstDetourRoad);
}

/**
 **********************************************************************
 \brief 编辑避让道路
 \details 编辑避让道路，保存到避让文件中。
 \param[in]  pstDetourRoad 避让道路
 \retval	GD_ERR_OK 成功
 \retval	GD_ERR_INVALID_PARAM	参数无效
 \retval	GD_ERR_NO_DATA 无相关数据
 \retval	GD_ERR_FAILED	操作失败
 \remarks
 \since 6.0
 \see GDBL_GetDetourRoadList
 **********************************************************************/
+ (GSTATUS)EditDetourRoad:(GDETOURROADINFO *)pDetourRoad
{
    return GDBL_EditDetourRoad(pDetourRoad);
}

/**
 **********************************************************************
 \brief 删除指定避让道路
 \details 删除指定避让道路，保存到避让文件中。
 \param[in]  pnIndex 避让道路索引数组
 \param[in]  count 索引数组大小
 \retval	GD_ERR_OK 成功
 \retval	GD_ERR_FAILED	操作失败
 \remarks
 \since 6.0
 \see GDBL_GetDetourRoadList
 **********************************************************************/
+ (GSTATUS)DelDetourRoad:(Gint32 *)pnIndex count:(Gint32)count
{
    return GDBL_DelDetourRoad(pnIndex, count);
}

/**
 **********************************************************************
 \brief 删除所有避让道路
 \details 删除所有避让道路，保存到避让文件中。
 \retval	GD_ERR_OK 成功
 \retval	GD_ERR_FAILED	操作失败
 \remarks
 \since 6.0
 \see GDBL_GetDetourRoadList
 **********************************************************************/
+ (GSTATUS)ClearDetourRoad
{
    return GDBL_ClearDetourRoad();
}

/**
 **********************************************************************
 \brief 获取避让道路列表
 \details 获取当前保存的避让道路列表。
 \param[out]  ppstDetourRoadList 避让道路列表
 \retval	GD_ERR_OK 成功
 \retval	GD_ERR_NO_MEMORY	内存不足
 \retval	GD_ERR_NO_DATA 无相关数据
 \remarks
 \since 6.0
 \see GDBL_AddDetourRoad GDBL_EditDetourRoad GDBL_DelDetourRoad GDBL_ClearDetourRoad
 **********************************************************************/
+ (GSTATUS)GetDetourRoadList:(GDETOURROADLIST **)ppstDetourRoadList
{
    return GDBL_GetDetourRoadList(ppstDetourRoadList);
}

/**
 **********************************************************************
 \brief 判断道路是否已被避让
 \details 判断道路是否已被避让,必过道路返回值成功但不避让。
 \param[in]  stObjectId 对象ID
 \param[out]  pbDetoured 是否避让结果
 \retval	GD_ERR_OK 成功
 \retval	GD_ERR_INVALID_PARAM	参数无效
 \retval	GD_ERR_FAILED	操作失败
 \remarks
 \since 6.0
 \see
 **********************************************************************/
+ (GSTATUS)IsDetoured:(GOBJECTID *)pstObjectId bDetoured:(Gbool *)pbDetoured
{
    return GDBL_IsDetoured(pstObjectId, pbDetoured);
}

/**
 **********************************************************************
 \brief 更新云端避让文件
 \details 更新云端避让文件
 \param[in]  szFullPathFileName 为GNULL时，清空缓存。为非GNULL时，避让文件全路径
 \retval	GD_ERR_OK 成功
 \retval	GD_ERR_INVALID_PARAM 正在路径计算
 \retval	GD_ERR_FAILED	操作失败
 \remarks
 \since 6.0
 \see
 **********************************************************************/
+ (GSTATUS)UpdateCloudAvoidInfo:(NSString *)szFullPathFileName
{
    if ([szFullPathFileName length] == 0)
    {
        return GD_ERR_FAILED;
    }
    return GDBL_UpdateCloudAvoidInfo(NSStringToGchar(szFullPathFileName));
}

/**********************************************************************
 \brief 增加避让TMC事件信息
 \details 该函数用于增加避让TMC事件信息
 \param[in]  pEventInfo        要避让的TMC事件信息
 \retval	GD_ERR_OK	成功
 \retval	GD_ERR_FAILED	失败
 \retval	GD_ERR_INVALID_PARAM	参数无效
 \retval	GD_ERR_NOT_SUPPORT	不支持该功能
 \remarks
 - 返回GD_ERR_NOT_SUPPORT 是无网络造成的
 \since 6.1
 \see
 **********************************************************************/
+ (GSTATUS)AddAvoidEventInfo:(GEVENTINFO *)pstEventInfo
{
    return GDBL_AddAvoidEventInfo(pstEventInfo);
}

/**
 **********************************************************************
 \brief     同步6.x本地和云端避让文件
 \details   同步6.x本地和云端避让文件
 \param[in] szFullPathFileName 云端避让文件全路径
 \retval    GD_ERR_OK        成功
 \retval    GD_ERR_FAILED    失败
 \remarks
 1.szFullPathFileName:GNULL不升级云端避让文件
 2.szFullPathFileName:具体路径，升级云端避让文件
 2.本地避让文件也在这个接口进行默认同步。
 \since 7.0
 \see
 **********************************************************************/
+ (GSTATUS)UpgradeAvoidFile:(NSString *)szFullPathFileName
{
    if ([szFullPathFileName length] == 0)
    {
        return GD_ERR_FAILED;
    }
    return GDBL_UpgradeAvoidFile(NSStringToGchar(szFullPathFileName));
}

/**
 **********************************************************************
 \brief 添加主要道路避让
 \details 该函数用于添加主要道路避让。
 \param[in] hGuideRoute 引导句柄
 \param[in] eOption 避让
 \param[in] nNodeNo 节点id
 \retval	GD_ERR_OK           成功
 \retval GD_ERR_NO_ROUTE     没有引导路径
 \remarks
 \since 6.0
 \see
 **********************************************************************/
+ (GSTATUS)AddAvoidMainRoad:(GHGUIDEROUTE)hGuideRoute eOption:(GDETOUROPTION)eOption nNodeNo:(Gint32)nNodeNo
{
    return GDBL_AddAvoidMainRoad(hGuideRoute, eOption, nNodeNo);
}

/**
 **********************************************************************
 \brief     用于获取本地避让道路的所在城市及数据版本
 \details   用于获取本地避让道路的所在城市及数据版本
 \param[in]  szFileName      文件路径
 \param[out] ppCityInfos     城市信息
 \param[out] pnNumberOfCity  个数
 \retval    GD_ERR_OK        成功
 \retval    GD_ERR_FAILED    失败
 \remarks
 -1.避让文件目录需要传绝对路径
 \since 7.1
 \see
 **********************************************************************/
+ (GSTATUS)GetDetourRoadCityInfo:(Gchar *)szFileName ppCityInfos:(GDETOURROADCITYINFO **)ppCityInfos pnNumberOfCity:(Gint32 *)pnNumberOfCity
{
    return GDBL_GetDetourRoadCityInfo(szFileName, ppCityInfos, pnNumberOfCity);
}
#pragma mark -
#pragma mark 以下接口包含逻辑

#pragma mark 避让道路(参数为索引值)
/**********************************************************************
 * 函数名称: MW_DetourRoadWithID
 * 功能描述: 避让道路
 * 参    数:[IN] index:避让道路索引值
 * 返 回 值: 成功返回YES, 失败返回NO
 * 其它说明:
 **********************************************************************/
+ (GSTATUS)DetourRoadWithID:(NSInteger)index
{
    
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
    GGUIDEROADLIST *ppGuideRoadList = NULL;
    GDBL_GetGuideRoadList(NULL,Gfalse, &ppGuideRoadList);
    
	pDetourRoad.eOption = GDETOUR_OPTION_FOREVER;
	pDetourRoad.stObjectId = ppGuideRoadList->pGuideRoadInfo[index].stObjectId;
	GcharMemcpy(pDetourRoad.szRoadName, ppGuideRoadList->pGuideRoadInfo[index].pzCurRoadName, GMAX_ROAD_NAME_LEN+1);
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
    
    GSTATUS nStatus = GDBL_AddDetourRoad(&pDetourRoad);
    return nStatus;
    
}

/**********************************************************************
 * 函数名称: HaveDetour
 * 功能描述: 判断是否有规避道路
 * 参    数:
 * 返 回 值: YES 有, NO 无
 * 其它说明:
 **********************************************************************/
+ (BOOL)HaveDetour
{
    GDETOURROADLIST* pDetourRoadList=nil;
    GDBL_GetDetourRoadList(&pDetourRoadList);
    if (pDetourRoadList!=nil) {
        if (pDetourRoadList->nNumberOfDetourRoad>0) {
            return YES;
        }
    }
    return NO;
}

#pragma mark 避让指定范围内的道路id
/**********************************************************************
 * 函数名称: MW_DetourRoadIdFrom
 * 功能描述: 避让指定范围内的道路id
 * 参    数:
 * 返 回 值: 成功返回YES, 失败返回NO
 * 其它说明:
 **********************************************************************/
- (BOOL)DetourRoadIdFrom:(NSInteger)nStart to:(NSInteger)nEnd
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
    GGUIDEROADLIST *ppGuideRoadList = NULL;
    GDBL_GetGuideRoadList(NULL,TRUE, &ppGuideRoadList);
    GSTATUS nStatus = FALSE;
    // 添加判断，避免造成个数不对
    for (int i=0;i<=ppGuideRoadList->nNumberOfRoad-1;i++) {
        // 查看道路ID是否在start和end之间
        if (ppGuideRoadList->pGuideRoadInfo[i].nID>nEnd||ppGuideRoadList->pGuideRoadInfo[i].nID<nStart) {
            continue;
        }
        //
        GDETOURROADINFO pDetourRoad;
        pDetourRoad.eOption = GDETOUR_OPTION_TODAY;
        pDetourRoad.stObjectId = ppGuideRoadList->pGuideRoadInfo[i].stObjectId;
        GcharMemcpy(pDetourRoad.szRoadName, ppGuideRoadList->pGuideRoadInfo[i].pzCurRoadName, GMAX_ROAD_NAME_LEN+1);
        // 开始时间
        pDetourRoad.StartTime.date.day = (char)[dcpStartTime day];
        pDetourRoad.StartTime.date.month = (char)[dcpStartTime month];
        pDetourRoad.StartTime.date.year = (unsigned)[dcpStartTime year];
        pDetourRoad.StartTime.time.hour = (char)[dcpStartTime hour];
        pDetourRoad.StartTime.time.minute = (char)[dcpStartTime minute];
        pDetourRoad.StartTime.time.second = (char)[dcpStartTime second];
        // 结束时间
        pDetourRoad.EndTime.date.day = (char)[dcpEndTime day];
        pDetourRoad.EndTime.date.month = (char)[dcpEndTime month];
        pDetourRoad.EndTime.date.year = (unsigned)[dcpEndTime year];
        pDetourRoad.EndTime.time.hour = (char)[dcpEndTime hour];
        pDetourRoad.EndTime.time.minute = (char)[dcpEndTime minute];
        pDetourRoad.EndTime.time.second = (char)[dcpEndTime second];
        
        nStatus = GDBL_AddDetourRoad(&pDetourRoad);
    }
    if (nStatus!=GD_ERR_OK) {
        return FALSE;
    }
    return TRUE;
    
}

/**
 **********************************************************************
 \brief 避让后删除未选中路径句柄
 *****************************/
+ (void)deleteUnselectHandlerAfterDetour
{
    GHGUIDEROUTE routeList[6] = {0};
    int returnCount = 0;
    [MWRouteGuide GetGuideRouteList:routeList count:6 returnCount:&returnCount];
    for (int i = 0; i < returnCount - 1; i++)
    {
        [MWRouteGuide DelGuideRoute:routeList[i]];
    }
}
@end

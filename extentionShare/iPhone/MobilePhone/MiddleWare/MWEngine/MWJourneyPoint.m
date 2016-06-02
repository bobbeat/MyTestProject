//
//  MWJourneyPoint.m
//  AutoNavi
//
//  Created by gaozhimin on 14-6-9.
//
//

#import "MWJourneyPoint.h"

@implementation MWJourneyPoint

/**
 **********************************************************************
 \brief 添加行程点
 \details 该函数用于添加行程起点、途经点、目的地。
 \param[in] eType				需要添加的行程点类型
 \param[in] pPOI					行程点信息
 \param[in] euROURule			行程点的路径规则
 \retval	GD_ERR_OK 成功
 \retval	GD_ERR_INVALID_PARAM 参数无效
 \retval	GD_ERR_NO_DATA 无相关数据
 \retval	GD_ERR_NO_MEMORY 内存不足
 \retval	GD_ERR_OP_CANCELED 操作取消
 \retval	GD_ERR_FAILED 操作失败，暂无具体错误码
 \remarks
 - 1.注意通常情况下，无需添加起点，起点采用当前车位。
 - 2.如果途经点1已存在，再向其中添加途经点1，
 则旧的行程点信息将被新的覆盖。添加其他行程点也将执行同样的操作。
 \since 6.0
 \see
 **********************************************************************/
+ (GSTATUS)AddJourneyPointWith:(MWPoi*)poi type:(GJOURNEYPOINTTYPE)type option:(GROUTEOPTION)rule
{
    [MWRouteCalculate  SharedInstance].m_journeyType = type;    //用于判断是否弹出选择高速路
    GPOI gpoi = {0};
    [MWPoi MWPoiToGPoi:poi GPoi:&gpoi];
    return GDBL_AddJourneyPoint(type, &gpoi, rule);
}

/**
 **********************************************************************
 \brief 设置添加行程点回调接口
 \details 该函数用于设置添加行程点时的回调通知。
 \param[in] lpfnNotifyCB	通知回调接口函数
 \param[in] lpVoid       回调函数用户参数，在调用回调函数时，传给回调函数。
 \retval	GD_ERR_OK 成功
 \retval	GD_ERR_INVALID_PARAM	参数无效
 \remarks
 - 1.当添加行程点时，若该行程点附近有多条道路供选择时，发送通知，
 并将附近多条道路信息返回给调用者，并由调用者决定选择那条道路。
 - 2.lpfnNotifyCB返回用户的选择索引号。
 \since 6.0
 \see
 **********************************************************************/
+ (GSTATUS)SetJourneyCallBack:(GJOURNEYNOTIFYCB)lpfnNotifyCB lpvoid:(void *)lpVoid
{
    return GDBL_SetAddJourneyPointCB(lpfnNotifyCB, lpVoid);
}

/**
 **********************************************************************
 \brief 删除行程点
 \details 该函数用于删除行程起点、途经点、目的地。
 \param[in] eType	行程点类型
 \retval	GD_ERR_OK 成功
 \retval	GD_ERR_INVALID_PARAM	参数无效
 \remarks
 - 当起点被删除后，下次行程路线规划时则起点会参考当前车位。
 \since 6.0
 \see
 **********************************************************************/
+ (GSTATUS)DelJourneyPoint:(GJOURNEYPOINTTYPE)eType
{
    return GDBL_DelJourneyPoint(eType);
}

/**
 **********************************************************************
 \brief 清空行程点
 \details 该函数用于清空行程起点、途经点、目的地。
 \retval	GD_ERR_OK 成功
 \remarks
 \since 6.0
 \see
 **********************************************************************/
+ (GSTATUS)ClearJourneyPoint
{
    return GDBL_ClearJourneyPoint();
}

/**
 **********************************************************************
 \brief 获取行程点
 \details 该函数用于获取行程点列表。
 \param[out] ppJourneyPoint  行程点列表
 \retval	GD_ERR_OK 成功
 \retval	GD_ERR_INVALID_PARAM	参数无效
 \remarks
 - 1.行程点个数固定为MAX_JOURNEY_POINT_NUM个。
 - 2.UI或者其他中间层接口可以通过相关的内存地址索引取得特定形成点信息.(内存由MID分配)
 \since 6.0
 \see GDBL_GetCurrentJourneyPoint
 **********************************************************************/
+ (GSTATUS)GetJourneyPoint:(GPOI **)ppJourneyPoint
{
    return GDBL_GetJourneyPoint(ppJourneyPoint);
}

/**
 **********************************************************************
 \brief 获取当前行程点
 \details 该函数用于获取引导路径行程点列表。
 \param[out] ppJourneyPoint  行程点列表
 \retval	GD_ERR_OK 成功
 \retval	GD_ERR_NO_DATA	无相关数据
 \retval	GD_ERR_FAILED	操作失败，暂无具体错误码
 \remarks
 - 1.行程点个数固定为MAX_JOURNEY_POINT_NUM个。
 - 2.获取当前引导路径上的行程点信息。
 \since 6.0
 \see GDBL_GetJourneyPoint
 **********************************************************************/
+ (GSTATUS)GetCurrentJourneyPoint:(GPOI **)ppJourneyPoint
{
    return GDBL_GetCurrentJourneyPoint(ppJourneyPoint);
}

/**
 **********************************************************************
 \brief 获取演示路线列表。
 \details 该函数用于获取演示路线列表。
 \param[out]  ppDemoJourneyList  演示行程列表
 \retval	GD_ERR_OK    成功
 \retval	GD_ERR_INVALID_PARAM	参数无效
 \retval	GD_ERR_NO_DATA	        没有相关数据
 \remarks
 - 数据来源于资源目录下routedemo.ini。
 \since 6.0
 \see
 **********************************************************************/
+ (GSTATUS)GetDemoJourneyList:(GDEMOJOURNEYLIST **)ppDemoJourneyList
{
    return GDBL_GetDemoJourneyList(ppDemoJourneyList);
}

/**
 **********************************************************************
 \brief 加载指定演示路线
 \details 该函数用于加载演示路线。
 \param[in]  nID  路线ID
 \retval	GD_ERR_OK    成功
 \retval	GD_ERR_INVALID_PARAM	参数无效
 \remarks
 - 该接口用于加载指定的演示路线，需要进行路径计算，耗时较长。
 \since 6.0
 \see GDBL_UnloadDemoJourney
 **********************************************************************/
+ (GSTATUS)LoadDemoJourney:(Guint32)nID
{
    return GDBL_LoadDemoJourney(nID);
}

/**
 **********************************************************************
 \brief 卸载演示路线
 \details 该函数用于卸载演示路线。
 \retval	GD_ERR_OK    成功
 \retval	GD_ERR_INVALID_PARAM	参数无效
 \remarks
 - 路线演示完毕后，需调用该接口将演示路线卸载。
 \since 6.0
 \see GDBL_LoadDemoJourney
 **********************************************************************/
+ (GSTATUS)UnloadDemoJourney
{
    return GDBL_UnloadDemoJourney();
}

#pragma mark -
#pragma mark 以下方法包含逻辑

/**
 **********************************************************************
 \brief 获取行程点数组信息
 \details 获取行程点数组信息
 **********************************************************************/
+ (NSMutableArray *)GetJourneyPointArray
{
    NSMutableArray *journeyPointArray = [[NSMutableArray alloc] init];
    if ([ANParamValue sharedInstance].isPath) {
        GPOI *ppJourneyPoint = {0};
        [MWJourneyPoint GetCurrentJourneyPoint:&ppJourneyPoint];  //只有这个接口才能判断途经点是否已经走过
        if ((ppJourneyPoint[0].Coord.x == 0 || ppJourneyPoint[0].Coord.y == 0))
        {
            
            GPOI tmpPOI = [ANParamValue sharedInstance].palellerRoadPOI;
            if (tmpPOI.Coord.x == 0 || tmpPOI.Coord.y == 0) {
                GCARINFO carInfo = {0};
                GDBL_GetCarInfo(&carInfo);
                tmpPOI.Coord.x = carInfo.Coord.x;
                tmpPOI.Coord.y = carInfo.Coord.y;
                GcharMemcpy(tmpPOI.szName, carInfo.szRoadName, GMAX_POI_NAME_LEN+1);
            }
            MWPoi *node = [[MWPoi alloc] init];
            
            node.longitude = tmpPOI.Coord.x;
            node.latitude = tmpPOI.Coord.y;
            node.lCategoryID = tmpPOI.lCategoryID;
            node.lDistance = tmpPOI.lDistance;
            node.lMatchCode = tmpPOI.lMatchCode;
            node.lHilightFlag = tmpPOI.lHilightFlag;
            node.lAdminCode = tmpPOI.lAdminCode;
            node.stPoiId = tmpPOI.stPoiId;
            node.lNaviLon = tmpPOI.lNaviLon;
            node.lNaviLat = tmpPOI.lNaviLat;
            if ([[NSString chinaFontStringWithCString:tmpPOI.szName] length] == 0)
            {
                node.szName = STR(@"Main_unNameRoad", @"Main");
            }
            else{
                node.szName = [NSString chinaFontStringWithCString:tmpPOI.szName];
            }
            
            node.szAddr = [NSString chinaFontStringWithCString:tmpPOI.szAddr];
            node.szTel = [NSString chinaFontStringWithCString:tmpPOI.szTel];
            node.lPoiIndex = tmpPOI.lPoiIndex;
            node.ucFlag = tmpPOI.ucFlag;
            //            node.usNodeId = tmpPOI.usNodeId;
            
            [journeyPointArray addObject:node];
            [node release];
            
        }
        
        for (int i = 0; i < 7; i++) {
            if (ppJourneyPoint[i].Reserved == 0|| i == 0) //(行程点：0表示未达到、1表示已到达) */
            {
                if (ppJourneyPoint[i].Coord.x != 0 || ppJourneyPoint[i].Coord.y != 0) {
                    
                    MWPoi *node = [[MWPoi alloc] init];
                    
                    node.longitude = ppJourneyPoint[i].Coord.x;
                    node.latitude = ppJourneyPoint[i].Coord.y;
                    node.lCategoryID = ppJourneyPoint[i].lCategoryID;
                    node.lDistance = ppJourneyPoint[i].lDistance;
                    node.lMatchCode = ppJourneyPoint[i].lMatchCode;
                    node.lHilightFlag = ppJourneyPoint[i].lHilightFlag;
                    node.lAdminCode = ppJourneyPoint[i].lAdminCode;
                    node.stPoiId = ppJourneyPoint[i].stPoiId;
                    node.lNaviLon = ppJourneyPoint[i].lNaviLon;
                    node.lNaviLat = ppJourneyPoint[i].lNaviLat;
                    node.szName = [NSString chinaFontStringWithCString:ppJourneyPoint[i].szName];
                    node.szAddr = [NSString chinaFontStringWithCString:ppJourneyPoint[i].szAddr];
                    node.szTel = [NSString chinaFontStringWithCString:ppJourneyPoint[i].szTel];
                    node.lPoiIndex = ppJourneyPoint[i].lPoiIndex;
                    node.ucFlag = ppJourneyPoint[i].ucFlag;
                    node.Reserved = ppJourneyPoint[i].Reserved;
                    
                    [journeyPointArray addObject:node];
                    [node release];
                }
            }
        }
    }
    return [journeyPointArray autorelease];
}

/**********************************************************************
 * 函数名称: GetJourneyPointWithID
 * 功能描述: 获取行程点(参数:0:起点6:终点)
 * 参    数:
 * 返 回 值: plugin_PoiNode类型行程点
 * 其它说明:
 **********************************************************************/
+ (plugin_PoiNode *)GetJourneyPointWithID:(NSInteger)ID {
	
	plugin_PoiNode *node = [[plugin_PoiNode alloc] init];
	
	GPOI *ppJourneyPoint;
	GDBL_GetJourneyPoint(&ppJourneyPoint);
	
	node.lLon = ppJourneyPoint[ID].Coord.x;
	node.lLat = ppJourneyPoint[ID].Coord.y;
	node.lCategoryID = ppJourneyPoint[ID].lCategoryID;
	node.lDistance = ppJourneyPoint[ID].lDistance;
	node.lMatchCode = ppJourneyPoint[ID].lMatchCode;
	node.lHilightFlag = ppJourneyPoint[ID].lHilightFlag;
	node.lAdminCode = ppJourneyPoint[ID].lAdminCode;
	node.stPoiId = ppJourneyPoint[ID].stPoiId;
	node.lNaviLon = ppJourneyPoint[ID].lNaviLon;
	node.lNaviLat = ppJourneyPoint[ID].lNaviLat;
	node.szName = [NSString chinaFontStringWithCString:ppJourneyPoint[ID].szName];
	node.szAddr = [NSString chinaFontStringWithCString:ppJourneyPoint[ID].szAddr];
	node.szTel = [NSString chinaFontStringWithCString:ppJourneyPoint[ID].szTel];
	node.lPoiIndex = ppJourneyPoint[ID].lPoiIndex;
	node.ucFlag = ppJourneyPoint[ID].ucFlag;
	node.ucNodeType = ppJourneyPoint[ID].Reserved;
	
	return [node autorelease];
}

/**********************************************************************
 * 函数名称: MW_GetJourneyPointWithID
 * 功能描述: 获取行程点(参数:0:起点6:终点)
 * 参    数:
 * 返 回 值: plugin_PoiNode类型行程点
 * 其它说明:
 **********************************************************************/
+ (MWPoi *)getJourneyPointWithID:(NSInteger)ID {
	
	MWPoi *poi = [[MWPoi alloc] init];
	
	GPOI *ppJourneyPoint;
	GDBL_GetJourneyPoint(&ppJourneyPoint);
	
	poi.longitude = ppJourneyPoint[ID].Coord.x;
	poi.latitude = ppJourneyPoint[ID].Coord.y;
	poi.lCategoryID = ppJourneyPoint[ID].lCategoryID;
	poi.lDistance = ppJourneyPoint[ID].lDistance;
	poi.lMatchCode = ppJourneyPoint[ID].lMatchCode;
	poi.lHilightFlag = ppJourneyPoint[ID].lHilightFlag;
	poi.lAdminCode = ppJourneyPoint[ID].lAdminCode;
    poi.stPoiId = ppJourneyPoint[ID].stPoiId;
	poi.lNaviLat = ppJourneyPoint[ID].lNaviLat;
	poi.lNaviLon = ppJourneyPoint[ID].lNaviLon;
	poi.szName = [NSString chinaFontStringWithCString:ppJourneyPoint[ID].szName];
	poi.szAddr = [NSString chinaFontStringWithCString:ppJourneyPoint[ID].szAddr];
	poi.szTel = [NSString chinaFontStringWithCString:ppJourneyPoint[ID].szTel];
	poi.lPoiIndex = ppJourneyPoint[ID].lPoiIndex;
	poi.ucFlag = ppJourneyPoint[ID].ucFlag;
	poi.Reserved = ppJourneyPoint[ID].Reserved;
	
	return [poi autorelease];
}

@end

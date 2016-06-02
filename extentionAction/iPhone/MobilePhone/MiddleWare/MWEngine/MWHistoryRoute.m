//
//  MWHistoryRoute.m
//  AutoNavi
//
//  Created by gaozhimin on 14-7-12.
//
//

#import "MWHistoryRoute.h"
#import "DringTracksManage.h"

@interface MWHistoryRoute()
{
    NSMutableArray       *routeArray;      //路线保存数组
}

@end

@implementation MWHistoryRoute

static MWHistoryRoute *instance = nil;

+(MWHistoryRoute*)sharedInstance
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
    if(self)
    {
        routeArray = [[NSMutableArray alloc] init];
        [self restoreRoute];
    }
	
    return self;
}

/*!
  @brief 把routeArray中的所有任务信息保存到文件系统，一般是在退出程序时调用
  @return 成功返回 YES 失败返回 NO
  */
-(BOOL)storeRoute
{
    /*
     1、序列化整个routeArray
     */
    
	NSString *Path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	NSString *filename = [Path stringByAppendingPathComponent:routeSavePath];
	if (![NSKeyedArchiver archiveRootObject:routeArray toFile:filename]){
		return NO;
	}
	else {
		return YES;
	}
    
}

/*!
  @brief 从文件系统还原通过save保存的所有任务信息，一般是在进入程序时调用，该方法调用将把routeArray中的所有任务更新为最后一次调用save保存的任务
  @return 成功返回 YES 失败返回 NO
  */
-(BOOL)restoreRoute
{
    /*
     1、反序列化各个Task对象，构建处carOwnerTaskList
     2、遍历carOwnerTaskList，把task.delegate = self;
     */
	
	NSString *Path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	NSString *filename = [Path stringByAppendingPathComponent:routeSavePath];
	NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithFile:filename];
	[routeArray removeAllObjects];
	[routeArray addObjectsFromArray:array];
    
	return YES;
	
}



#pragma mark 加载引导路径

/**********************************************************************
 * 函数名称: MW_GetGuideRouteList
 * 功能描述: 该函数用于获取收藏的路径线的信息
 * 参    数:
 *           [OUT]  路径列表
 *
 * 返 回 值:
 * 其它说明:
 * 修改日期			版本号		修改人		修改内容
 * ---------------------------------------------------------------------
 **********************************************************************/
- (NSMutableArray *)MW_GetGuideRouteList
{
    return routeArray;
}

/**********************************************************************
 * 函数名称: MW_GetUserGuideRouteList
 * 功能描述: 该函数用于获取指定用户收藏的路径线的信息
 * 参    数:
 *           [OUT]  用户路径列表
 *
 * 返 回 值:
 * 其它说明:
 * 修改日期			版本号		修改人		修改内容
 * ---------------------------------------------------------------------
 **********************************************************************/
- (NSMutableArray *)MW_GetUserGuideRouteList
{
    [[DringTracksManage sharedInstance] historyModifyAccount];
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    for (MWPathPOI *poi in routeArray) {
        if ([poi.userID isEqualToString:UserID_Account] && poi.operate != 3) {
            [array addObject:poi];
        }
    }
    
    return [array autorelease];
}

/**********************************************************************
 * 函数名称: MW_GetSyncUserGuideRouteList
 * 功能描述: 该函数用于获取指定用户收藏的路径线的信息
 * 参    数:
 *           [OUT]  用户路径列表
 *
 * 返 回 值:
 * 其它说明:
 * 修改日期			版本号		修改人		修改内容
 * ---------------------------------------------------------------------
 **********************************************************************/
- (NSMutableArray *)MW_GetSyncUserGuideRouteList
{
    [[DringTracksManage sharedInstance] historyModifyAccount];
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    for (MWPathPOI *poi in routeArray) {
        if ([poi.userID isEqualToString:UserID_Account]) {
            [array addObject:poi];
        }
    }
    
    return [array autorelease];
}


/**********************************************************************
 * 函数名称: MW_RemoveGuideRouteWithIndex
 * 功能描述: 该函数用于删除收藏的路径线
 * 参    数:  [IN]   索引
 *           [OUT]  YES 删除成功 NO 删除失败
 *
 * 返 回 值:
 * 其它说明:
 * 修改日期			版本号		修改人		修改内容
 * ---------------------------------------------------------------------
 **********************************************************************/
- (BOOL)MW_RemoveGuideRouteWithTime:(NSString *)time
{
    int count = routeArray.count;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMddHHmmss"];
    NSString *operateTime = [formatter stringFromDate:[NSDate date]];
    
    
    for (int i = 0; i < count; i ++) {
        MWPathPOI *path = [routeArray caObjectsAtIndex:i];
        if ([time isEqualToString:path.operateTime]) {
            path.operate = 3;
            path.operateTime = operateTime;
        }
    }
    
    [formatter release];
    
    [self storeRoute];
    
    return YES;
}

/**********************************************************************
 * 函数名称: MW_RemoveAllGuideRoute
 * 功能描述: 该函数用于删除所有收藏的路径线，标志为值为3
 * 参    数:
 *           [OUT]  YES 删除成功 NO 删除失败
 *
 * 返 回 值:
 * 其它说明:
 * 修改日期			版本号		修改人		修改内容
 * ---------------------------------------------------------------------
 **********************************************************************/
- (BOOL)MW_RemoveAllGuideRoute
{
    int count = routeArray.count;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMddHHmmss"];
    NSString *operateTime = [formatter stringFromDate:[NSDate date]];
    
    for (int i = 0; i < count ; i++) {
        
        MWPathPOI *path = [routeArray caObjectsAtIndex:i];
        path.operate = 3;
        path.operateTime = operateTime;
    }
    
    [formatter release];
    
    [self storeRoute];
    
    return YES;
}

/**********************************************************************
 * 函数名称: MW_RemoveDiskAllGuideRoute
 * 功能描述: 该函数用于删除所有收藏的路径线,全部删除，不做标记
 * 参    数:
 *           [OUT]  YES 删除成功 NO 删除失败
 *
 * 返 回 值:
 * 其它说明:
 * 修改日期			版本号		修改人		修改内容
 * ---------------------------------------------------------------------
 **********************************************************************/
- (BOOL)MW_RemoveDiskAllGuideRoute
{
    
    [routeArray removeAllObjects];
    
    [self storeRoute];
    
    return YES;
}

/**********************************************************************
 * 函数名称: MW_AddGuideRouteWithPathPOI
 * 功能描述: 该函数用于添加历史路线
 * 参    数:
 *
 *
 * 返 回 值:
 * 其它说明:
 * 修改日期			版本号		修改人		修改内容
 * ---------------------------------------------------------------------
 **********************************************************************/
- (void)MW_AddGuideRouteWithPathPOI:(MWPathPOI *)pathPOI
{
    if (!pathPOI) {
        return;
    }
    
    if (routeArray.count > 199) {
        [routeArray removeLastObject];
    }
    
    [routeArray addObject:pathPOI];
    
}

/**********************************************************************
 * 函数名称: MW_ReNameGuideRouteUserIDWithUserID
 * 功能描述:复制一份新的数据到newUserID
 * 参    数:reNameUserID 要复制的用户id
 *          newUserID  复制后的用户id
 *
 * 返 回 值:
 * 其它说明:
 * 修改日期			版本号		修改人		修改内容
 * ---------------------------------------------------------------------
 **********************************************************************/
- (BOOL)MW_ReNameGuideRouteUserIDWithUserID:(NSString *)reNameUserID NewUserID:(NSString *)newUserID
{
    if (!reNameUserID || !newUserID || ![reNameUserID isKindOfClass:[NSString class]] || ![newUserID isKindOfClass:[NSString class]]) {
        return NO;
    }
    
    int count = routeArray.count;
    
    NSMutableArray *addarray = [NSMutableArray array];
    
    for (int i = 0; i < count; i ++) {
        
        MWPathPOI *path = [routeArray caObjectsAtIndex:i];
        if (path.operate != 3 && [path.userID isEqualToString:reNameUserID])
        {
            MWPathPOI *path = [routeArray caObjectsAtIndex:i];
            MWPathPOI *addItem = [[MWPathPOI alloc] init];
            addItem.userID = newUserID;
            addItem.operate = 1;
            addItem.name = path.name;
            addItem.operateTime = path.operateTime;
            addItem.rule = path.rule;
            addItem.waypointCount = path.waypointCount;
            addItem.poiArray = path.poiArray;
            int isExist = [self MW_IsRouteExist:addItem];
            if (isExist == -1)
            {
                [addarray addObject:addItem];
            }
            [addItem release];
        }
    }
    [routeArray addObjectsFromArray:addarray];
    [self storeRoute];
    return YES;
}

#pragma mark 保存引导路线
/**********************************************************************
 * 函数名称: SaveGuideRoute
 * 功能描述: 该函数用于保存历史路线。
 * 返 回 值: 成功返回YES, 失败返回NO
 * 其它说明:
 **********************************************************************/
- (GSTATUS)SaveHistoryRoute
{
    GSTATUS res = GD_ERR_FAILED;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMddHHmmss"];
    NSString *operateTime = [formatter stringFromDate:[NSDate date]];
    [formatter release];
    
    int index;
    GDBL_GetParam(G_ROUTE_OPTION, &index);
    
    NSMutableArray *journeyArray = [[[NSMutableArray alloc] init] autorelease];
    GPOI *ppJourneyPoint = {0};
    res = GDBL_GetCurrentJourneyPoint(&ppJourneyPoint);
    if (GD_ERR_OK == res) {
        for (int i = 0; i < 7; i++) {
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
                
                [journeyArray addObject:node];
                [node release];
            }
        }
    }
    else{
        return res;
    }
    
    if (journeyArray.count < 2) {
        return res;
    }
    
    MWPathPOI *pathPOI = [[MWPathPOI alloc] init];
    pathPOI.userID = UserID_Account;
    pathPOI.operateTime = operateTime;
    pathPOI.rule = index;
    pathPOI.poiArray = journeyArray;
    pathPOI.waypointCount = journeyArray.count - 2;
    pathPOI.serviceID = @"";
    
    id obj = nil;
    
    int isExist = [self MW_IsRouteExist:pathPOI];
    
    if (isExist >= 0)
    {
        [routeArray removeObjectAtIndex:isExist];
        pathPOI.operate = 2;
    }
    else
    {
        
        pathPOI.operate = 1;
        
        if ( ([ANParamValue sharedInstance].isHistoryRouteClick > 0))//历史路线点击
        {
            if ([ANParamValue sharedInstance].isHistoryRouteClick <= routeArray.count)
            {
                obj = [routeArray objectAtIndex:([ANParamValue sharedInstance].isHistoryRouteClick - 1)];
                [obj retain];
                
                [routeArray removeObjectAtIndex:([ANParamValue sharedInstance].isHistoryRouteClick - 1)];
            }
        }
        
        
    }
    
    if (routeArray.count > 199)//超过200条，删除最旧的那条
    {
        [routeArray removeLastObject];
    }
    
    if ((isExist < 0) && ([ANParamValue sharedInstance].isHistoryRouteClick > 0))//历史路线点击处理
    {
        
        if (obj)
        {
            [routeArray insertObject:obj atIndex:0];
        }
    }
    else
    {
        [routeArray insertObject:pathPOI atIndex:0];
    }
    
    
    if ([ANParamValue sharedInstance].isHistoryRouteClick > 0)
    {
        [ANParamValue sharedInstance].isHistoryRouteClick = 0;
    }
    
    if (obj) {
        [obj release];
        obj = nil;
    }
    
    [pathPOI release];
    
    [self storeRoute];
    
    return res;
}

/*!
  @brief 判断路径是否已经保存
  @return 路径已存在返回相对应的索引，否则返回－1
  */
- (int)MW_IsRouteExist:(MWPathPOI *)pathPOI
{
    int index = -1;
    
    if (!pathPOI)
    {
        return index;
    }
    
    int pathCount = routeArray.count;
    
    for (int i = 0; i < pathCount; i++)
    {
        
        MWPathPOI *tmpPathPOI = [routeArray objectAtIndex:i];
        
        int pathPOICount = pathPOI.poiArray.count;
        
        if (tmpPathPOI.poiArray.count != pathPOICount || ![tmpPathPOI.userID isEqualToString:pathPOI.userID])//modify by gzm for 路径是否相同需要加入账户id判断 at 2014-11-13
        {
            continue;
        }
        
        BOOL isSame = YES;
        
        for (int j = 0; j < pathPOICount; j++)
        {
            MWPoi *tmpPOI = [tmpPathPOI.poiArray objectAtIndex:j];
            MWPoi *mPathPOI = [pathPOI.poiArray objectAtIndex:j];
            
            if (tmpPOI.longitude != mPathPOI.longitude || tmpPOI.latitude != mPathPOI.latitude || ![tmpPOI.szName isEqualToString:mPathPOI.szName])
            {
                isSame = NO;
                break;
            }
        }
        
        if (isSame) {
            index = i;
            break;
            
        }
    }
    
    return index;
}

@end

//
//  MWEngineTools.m
//  AutoNavi
//
//  Created by gaozhimin on 14-5-7.
//
//

#import "MWEngineTools.h"
#import "MWMapOperator.h"

@implementation MWEngineTools

/**
 **********************************************************************
 \brief 获取引擎内核版本
 \details 该函数用于获取引擎内核版本
 \retval	成功引擎内核版本字符串，失败返回空
 **********************************************************************/
+ (NSString *)GetEngineVersion
{
    GVERSIONPARAM pVerParam = {0};
    pVerParam.eVersionID = GVERSION_ID_NAVI_CORE;
    GVERSION pVersion = {0};
    GSTATUS res = GDBL_GetVersion(&pVerParam,&pVersion);
    if (res == GD_ERR_OK)
    {
        return GcharToNSString(pVersion.szVersion);
    }
    return @"";
}

/**
 **********************************************************************
 \brief 获取引擎内核版本 没有带V
 \details 该函数用于获取引擎内核版本
 \retval	成功引擎内核版本字符串，失败返回@""
 **********************************************************************/
+ (NSString *)GetEngineVersionNoV
{
    NSString *tmp = [NSString stringWithFormat:@"%@",[MWEngineTools GetEngineVersion]];
    NSString *stringt = @"V";
    NSRange range = [tmp rangeOfString:stringt];
    NSString *version;
    if (range.length != 0)
    {
        version = [tmp substringFromIndex:range.location+2];
        
    }
    else {
        version = @"";
    }
    return version;
}
/**
 **********************************************************************
 \brief 获取地图数据版本
 \details 该函数用于获取地图数据版本
 \retval	成功地图数据版本字符串，失败返回空
 **********************************************************************/
+ (NSString *)GetMapVersion
{
    GVERSIONPARAM pVerParam = {0};
    pVerParam.eVersionID = GVERSION_ID_DATA_GLOBAL;
    GVERSION pVersion = {0};
    GSTATUS res = GDBL_GetVersion(&pVerParam,&pVersion);
    if (res == GD_ERR_OK)
    {
        return GcharToNSString(pVersion.szVersion);
    }
    return @"";
}

/**
 **********************************************************************
 \brief 获取地图数据版本 没有带V
 \details 该函数用于获取地图数据版本
 \retval	成功地图数据版本字符串，失败返回@""
 **********************************************************************/
+ (NSString *)GetMapVersionNoV
{
    NSString *tmp = [NSString stringWithFormat:@"%@",[MWEngineTools GetMapVersion]];
    NSString *stringt = @"V";
    NSRange range = [tmp rangeOfString:stringt];
    NSString *version;
    if (range.length != 0)
    {
        version = [tmp substringFromIndex:range.location+2];
        
    }
    else {
        version = @"";
    }
    return version;
}

/**
 **********************************************************************
 \brief 获取城市数据版本
 \details 获取城市数据版本
 \retval	成功地图数据版本字符串，失败返回@""
 **********************************************************************/
+ (NSString *)GetMapCityVersion:(Gint32)admincode
{
    GVERSIONPARAM pVerParam = {0};
    pVerParam.eVersionID = GVERSION_ID_DATA_CITY;
    pVerParam.stAdcode.euRegionCode = eREGION_CODE_CHN;
    pVerParam.stAdcode.nAdCode = admincode;
    GcharMemcpy(pVerParam.szPath, NSStringToGchar(Map_Data_Path), GMAX_PATH);
    GVERSION pVersion = {0};
    GSTATUS res = GDBL_GetVersion(&pVerParam,&pVersion);
    if (res == GD_ERR_OK)
    {
        return GcharToNSString(pVersion.szVersion);
    }
    return @"";
}

/**
 **********************************************************************
 \brief 获取城市数据版本(不带V)
 \details 获取城市数据版本
 \retval	成功地图数据版本字符串，失败返回@""
 **********************************************************************/
+ (NSString *)GetMapCityVersionNoV:(Gint32)admincode
{
    GVERSIONPARAM pVerParam = {0};
    pVerParam.eVersionID = GVERSION_ID_DATA_CITY;
    pVerParam.stAdcode.euRegionCode = eREGION_CODE_CHN;
    pVerParam.stAdcode.nAdCode = admincode;
    GcharMemcpy(pVerParam.szPath, NSStringToGchar(Map_Data_Path), GMAX_PATH);
    GVERSION pVersion = {0};
    GSTATUS res = GDBL_GetVersion(&pVerParam,&pVersion);
    if (res == GD_ERR_OK)
    {
        NSString *stringt = @"V";
        NSRange range = [GcharToNSString(pVersion.szVersion) rangeOfString:stringt];
        NSString *version;
        if (range.length != 0)
        {
            version = [GcharToNSString(pVersion.szVersion) substringFromIndex:range.location+2];
            
        }
        else {
            version = @"";
        }
        return version;
    }
    return @"";
}
/**
 **********************************************************************
 \brief 比较地图数据版本
 \details 该函数用于比较地图数据版本
 \param[in] pMap1Version 地图版本信息
 \param[in] pMap2Version 地图版本信息
 \param[out] pResult 比较结果
 \retval	GD_ERR_OK	成功
 \retval	GD_ERR_INVALID_PARAM	参数无效
 **********************************************************************/
+ (GSTATUS)MapMapVerCompare:(NSString *)pMap1Version map2:(NSString *)pMap2Version result:(GVERCHECKRESULT*)pResult
{
    GVERSION map1 ={0};
    GVERSION map2 = {0};
    
    NSArray *array = [pMap1Version componentsSeparatedByString:@"."];
    NSArray *array_first;
    
    GcharMemcpy(map1.szVersion, NSStringToGchar(pMap1Version), GMAX_VERSION_LEN+1);
    if (array && [array count] > 3) {
        array_first = [[array objectAtIndex:0] componentsSeparatedByString:@" "];
        map1.nData1 = [[array_first objectAtIndex:1] intValue];
        map1.nData2 = [[array objectAtIndex:1] intValue];
        map1.nData3 = [[array objectAtIndex:2] intValue];
        map1.nData4 = [[array objectAtIndex:3] intValue];
    }
    
    array = [pMap2Version componentsSeparatedByString:@"."];
    GcharMemcpy(map2.szVersion, NSStringToGchar(pMap2Version), GMAX_VERSION_LEN+1);
    if (array && [array count] > 3) {
        array_first = [[array objectAtIndex:0] componentsSeparatedByString:@" "];
        map2.nData1 = [[array_first objectAtIndex:1] intValue];
        map2.nData2 = [[array objectAtIndex:1] intValue];
        map2.nData3 = [[array objectAtIndex:2] intValue];
        map2.nData4 = [[array objectAtIndex:3] intValue];
    }
    
    GSTATUS res = GDBL_MapMapVerCompare(&map1, &map2, pResult);
    return res;
}

/**
 **********************************************************************
 \brief 经纬坐标转SP编码
 \details 该函数用于将经纬度坐标转换为SP编码
 \param[in] pCoord 经纬度坐标
 \retval	成功返回SP编码字符串 失败返回@""
 **********************************************************************/
+ (NSString *)GeoCoordToSP: (GCOORD *)pCoord
{
    // 获得 SP 编码
    Gchar szSP[256] = {0};
    //转换经纬坐标到SP编码
    GSTATUS res = GDBL_GeoCoordToSP(pCoord, szSP);
    if (res == GD_ERR_OK)
    {
        return GcharToNSString(szSP);
    }
    return @"";
}

/**
 **********************************************************************
 \brief SP编码转经纬坐标
 \details 该函数用于将SP编码转换为经纬度坐标
 \param[in] szSP SP编码
 \retval	pCoord 经纬度坐标 失败返回（0，0）
 **********************************************************************/
+ (GCOORD)SPToGeoCoord: (NSString *)szSP
{
    GCOORD coord = {0};
    GSTATUS res;
	res = GDBL_SPToGeoCoord(NSStringToGchar(szSP), &coord);
    return coord;
}

/**
 **********************************************************************
 \brief 当前视图类型的屏幕坐标转经纬坐标
 \details 该函数用于当前视图类型的屏幕坐标转经纬坐标
 \param[in] pScrCoord 屏幕坐标
 \retval	pGeoCoord 成功经纬度坐标 失败返回（0,0）
 **********************************************************************/
+ (GCOORD)ScrToGeo:(GFCOORD)pScrCoord
{
    GCOORD coord = {0};
    GMAPVIEW pMapview = {0};
    GDBL_GetMapView(&pMapview);
    GHMAPVIEW mapHandle;
    GSTATUS res = GDBL_GetMapViewHandle(pMapview.eViewType,&mapHandle);
    if (res == GD_ERR_OK)
    {
        GDBL_CoordConvert(mapHandle,GCC_SCR_TO_GEO,&pScrCoord, &coord);
    }
    return coord;
}

/**
 **********************************************************************
 \brief 当前视图类型的经纬坐标转屏幕坐标
 \details 该函数用于当前视图类型的经纬坐标转屏幕坐标
 \param[in] pScrCoord 经纬坐标
 \retval	pGeoCoord 成功屏幕坐标 失败返回（-1,-1）
 **********************************************************************/
+ (GFCOORD)GeoToScr:(GCOORD)pGeoCoord
{
    GFCOORD pScrCoord = {0};
    GMAPVIEW pMapview = {0};
    GDBL_GetMapView(&pMapview);
    GHMAPVIEW mapHandle;
    GSTATUS res = GDBL_GetMapViewHandle(pMapview.eViewType,&mapHandle);
    if (res == GD_ERR_OK)
    {
        GDBL_CoordConvert(mapHandle,GCC_GEO_TO_SCR,&pScrCoord, &pGeoCoord);
    }
    int scaleFactor = 1;
    if ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)])
    {
        scaleFactor = (int)[[UIScreen mainScreen] scale];
    }
    pScrCoord.x = pScrCoord.x/scaleFactor;
    pScrCoord.y = pScrCoord.y/scaleFactor;
    return pScrCoord;
}

/**
 **********************************************************************
 \brief 将WGS地理坐标转换为高德地理坐标
 \details 该函数用于将WGS地理坐标转换为高德地理坐标
 \param[in] pwgsCoord WGS地理坐标
 \retval	pgdCoord 成功高德地理坐标 失败返回（0，0）
 **********************************************************************/
+ (GCOORD)WGSToGDCoord:(GCOORD)pwgsCoord
{
    GCOORD coord = {0};
    GDBL_WGSToGDCoord(&pwgsCoord, &coord);
    return coord;
}

/**
 **********************************************************************
 \brief 计算两点间的距离
 \details 该函数用于计算经纬度坐标系中两点间的距离
 \param[in] pGeoCoordFrom 起点经纬度坐标
 \param[in] pGeoCoordTo 终点经纬度坐标
 \retval	pDistance 距离（单位：米） 失败返回 -1
 \see
 **********************************************************************/
+ (Gint32)CalcDistanceFrom:(GCOORD)geoFrom To:(GCOORD)geoTo
{
    Gint32 distance = -1;
    GDBL_CalcDistance(&geoFrom, &geoTo, &distance);
    return distance;
}


/**
 **********************************************************************
 \brief 计算车位地图中心点间的距离
 \details 计算车位地图中心点间的距离
 \retval	pDistance 距离（单位：米） 失败返回 -1
 \see
 **********************************************************************/
+ (Gint32)CalculateDistance
{
    GCARINFO pCarInfo;
    GDBL_GetCarInfo(&pCarInfo);
    //获取地图中心信息
    GMAPCENTERINFO mapinfo = {0};
    [[MWMapOperator sharedInstance] MW_GetMapViewCenterInfo:GMAP_VIEW_TYPE_MAIN mapCenterInfo:&mapinfo];
    return [MWEngineTools CalcDistanceFrom:mapinfo.CenterCoord To:pCarInfo.Coord];
}

#pragma mark 获取审图号
/**
 **********************************************************************
 \brief     获取审图号
 \details   计算车位地图中心点间的距离
 \retval	NSString 审图号 失败返回  nil
 \see
 **********************************************************************/
+ (NSString *)GetReadDataCheckNumber
{
    //接70注释代码
    NSString *mapVersion = nil;
    FILE *fp1 = nil;
    char temp_str[256] = {0};
    long nSizeOfFile = 0;
    
    // 文件名
    //    if ([mapDataManage getMapDataType] == 2)
    {
        fp1 = fopen(mapVersion_path,"rb");
        if (NULL!=fp1) {
            fseek(fp1,0,SEEK_END);
            nSizeOfFile = ftell(fp1);
            fseek(fp1, 0, SEEK_SET);
        }
    }
    //    else if ([mapDataManage getMapDataType] == 1)
    //    {
    //        fp1 = navi_fopen(gpsPath[gpsIndexCount-1],"rb");
    //        if(fp1 != NULL)
    //        {
    //            nSizeOfFile = gpsSize[gpsIndexCount-1];
    //        }
    //    }
    // 读取数据
    if(fp1 != NULL)
    {
        // 根据文件大小判断1 只有中文(就版本);2有中 繁 英;
        if (256 > nSizeOfFile)
        {
            fread(temp_str,256,1,fp1);
            NSString *name = CSTRING_TO_NSSTRING(temp_str);
            mapVersion = [NSString stringWithFormat:@"%@",name];
            fclose(fp1);
        }
        else
        {
            // 过滤文件头
            char temp_str_oneLine[256] = {0};
            switch (fontType)
            {
                case 1:
                {
                    for (int i=0; i<6; i++) {
                        fgets(temp_str_oneLine, 256, fp1);
                    }
                }
                    break;
                    
                case 2:
                {
                    for (int i=0; i<12; i++) {
                        fgets(temp_str_oneLine, 256, fp1);
                    }
                }
                    break;
            }
            //读取正确得五行数据
            for (int i=0; i<5; i++) {
                memset(temp_str_oneLine, 0, 256);
                fgets(temp_str_oneLine, 256, fp1);
                memcpy(temp_str+strlen(temp_str), temp_str_oneLine, strlen(temp_str_oneLine));
            }
            //
            NSString *name = CSTRING_TO_NSSTRING(temp_str);
            mapVersion = [NSString stringWithFormat:@"%@",name];
            fclose(fp1);
        }
    }
    return mapVersion;
}


/**
 **********************************************************************
 \brief 准备开始更新城市数据
 \details 该函数用于通知所有的模块当前程序要开始更新城市数据
 \param[in] pstAdcode 要更新数据的城市编码
 \param[in] eDbType 要更新数据的数据类型
 \retval	GD_ERR_OK	成功
 \retval	GD_ERR_FAILED	失败
 \since 7.1
 \see
 **********************************************************************/
+ (GSTATUS)PrepareUpdateCityDB:(GADMINCODE*)pstAdcode type:(enumDBTYPE)eDbType
{
    return GDBL_PrepareUpdateCityDB(pstAdcode, eDbType);
}

/**
 **********************************************************************
 \brief 完成更新城市数据
 \details 该函数用于通知所有的模块当前程序更新城市数据完成
 \param[in] pstAdcode 更新数据的城市编码
 \param[in] eDbType 更新数据的数据类型
 \retval	GD_ERR_OK	成功
 \retval	GD_ERR_FAILED	失败
 \since 7.1
 \see
 **********************************************************************/
+ (GSTATUS)UpdateCityDBFinished:(GADMINCODE*) pstAdcode type:(enumDBTYPE)eDbType
{
    return GDBL_UpdateCityDBFinished(pstAdcode, eDbType);
}

/**
 **********************************************************************
 \brief 删除城市数据
 \details 该函数用于删除指定城市数据
 \param[in] pstAdcode 更新数据的城市编码
 \param[in] eDbType 更新数据的数据类型
 \retval	GD_ERR_OK	成功
 \retval	GD_ERR_FAILED	失败
 \since 7.1
 \see
 **********************************************************************/
+ (GSTATUS)DeleteCityDB:(GADMINCODE*)pstAdcode type:(enumDBTYPE)eDbType
{
    return GDBL_DeleteCityDB(pstAdcode, eDbType);
}

/**
 **********************************************************************
 \brief 更新数据之前先判断模块是否处于繁忙
 \details 该函数用于更新数据之前先判断模块是否处于繁忙
 \param[out] bBusy 处于繁忙状态 不能进行数据更新
 \retval	GD_ERR_OK	成功
 \retval	GD_ERR_FAILED	失败
 \since 7.1
 \see
 **********************************************************************/
+ (GSTATUS)IsAllModulesBusy:(Gbool*)bBusy
{
    return GDBL_IsAllModulesBusy(bBusy);
}

/**
 **********************************************************************
 \brief 基础资源数据包完整性检测
 \details 该函数用于基础资源数据包完整性检测
 \param[in/out]	pbOK 是否完整
 \retval	GD_ERR_OK 成功
 \retval	GD_ERR_NO_DATA 文件不存在
 \retval	GD_ERR_INVALID_PARAM 参数错误
 \remarks
 \since 7.0
 \see
 **********************************************************************/
+ (GSTATUS)CheckResource:(Gbool *)pbOK
{
    NSString *path  = [NSString stringWithUTF8String:g_data_path];
    return GDBL_CheckResource(NSStringToGchar(path), pbOK);
}

/**
 **********************************************************************
 \brief 检查指定行政区域的数据完整性
 \details 该函数用于检查指定行政区域的数据完整性
 \param[in]	pstAdCode 指定的行政区编码
 \param[in/out]	pbOK 是否完整
 \retval	GD_ERR_OK 成功
 \retval	GD_ERR_NO_DATA 文件不存在
 \retval	GD_ERR_INVALID_PARAM 参数错误
 \remarks
 pstAdcode->euRegionCode == 0：表示获取全局版本，必须执行一次
 pstAdcode->euRegionCode > 0 && pstAdcode->nAdCode == 0：表示获取指定国家的基础版本
 pstAdcode->euRegionCode > 0 && pstAdcode->nAdCode > 0：表示获取指定行政区域(城市)的版本
 \since 7.0
 \see
 **********************************************************************/
+ (GSTATUS)CheckAdareaData:(GADMINCODE *)pstAdCode bOk:(Gbool *)pbOK
{
    return GDBL_CheckAdareaData(NSStringToGchar(Map_Data_Path), pstAdCode, pbOK);
}

@end

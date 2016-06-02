//
//  MWAdminCode.m
//  AutoNavi
//
//  Created by gaozhimin on 14-6-9.
//
//

#import "MWAdminCode.h"

@implementation MWAreaList

@synthesize lNumberOfAdarea,pAdareaArray;

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.pAdareaArray = [NSMutableArray array];
    }
    return self;
}

- (void)dealloc
{
    self.pAdareaArray = nil;
    [super dealloc];
}

@end

@interface MWArea()
{
    
}

@property (nonatomic,assign) GADAREADATAFLAG areaDataFlag;
@property (nonatomic,assign) BOOL bGetSubArray;  //是否已获取过子数组

@end

@implementation MWArea

@synthesize lAdminCode,lNumberOfSubAdarea,pSubAdareaArray,szAdminName,szAdminSpell,CurrentArray,superArray,areaDataFlag,bGetSubArray;

- (instancetype)init
{
    self = [super init];
    if (self) {
        bGetSubArray = NO;
        self.pSubAdareaArray = [NSMutableArray array];
    }
    return self;
}

- (void)dealloc
{
    self.pSubAdareaArray = nil;
    self.szAdminSpell = nil;
    self.szAdminName = nil;
    [super dealloc];
}

- (NSArray *)pSubAdareaArray
{
    if (!bGetSubArray)
    {
        bGetSubArray = YES;
        GADAREALIST *ppAdareaList = NULL;
        GADMINCODE pstAdCode = {0};
        pstAdCode.euRegionCode = eREGION_CODE_CHN;
        pstAdCode.nAdCode = self.lAdminCode;
        GSTATUS res = GDBL_GetAdareaList(self.areaDataFlag,&pstAdCode,&ppAdareaList);
        if (res == GD_ERR_OK && self.lAdminCode != 0 && ppAdareaList->lNumberOfAdarea > 1)
        {
            int areaCount = ppAdareaList->lNumberOfAdarea;
            for (int i = 0; i < areaCount; i++)
            {
                GADAREA temp = ppAdareaList->pAdarea[i];
                MWArea *area = [MWArea changeForArea:temp];
                [self.pSubAdareaArray addObject:area];
                if (area.lAdminCode == self.lAdminCode)
                {
                    area.bGetSubArray = YES;
                }
                area.CurrentArray = self.pSubAdareaArray;
                area.superArray = self.CurrentArray;
                area.areaDataFlag = self.areaDataFlag;
            }
        }
    }
    return pSubAdareaArray;
}

/*!
 @brief  递归将GADAREA转化成MWArea
 @param  area, 将要转化的GADAREA
 @return 转化后的 MWArea。
 */
+(MWArea *)changeForArea:(GADAREA)area
{
    if (&area == NULL)
    {
        return nil;
    }
    MWArea  *mwarea = [[MWArea alloc] init];
    mwarea.lAdminCode = area.lAdminCode;
    mwarea.szAdminName = GcharToNSString(area.szAdminName);
    mwarea.szAdminSpell = GcharToNSString(area.szAdminSpell);
    mwarea.lNumberOfSubAdarea = area.lNumberOfSubAdarea;
    return [mwarea autorelease];
}
/*!
 @brief  递归将GADAREA转化成MWArea
 @param  area, 将要转化的GADAREA
 @return 转化后的 MWArea。
 */
+(MWArea *)recursiveForArea:(GADAREA)area flag:(GADAREADATAFLAG)flag
{
    if (&area == NULL)
    {
        return nil;
    }
    MWArea  *mwarea = [[MWArea alloc] init];
    mwarea.lAdminCode = area.lAdminCode;
    mwarea.szAdminName = GcharToNSString(area.szAdminName);
    mwarea.szAdminSpell = GcharToNSString(area.szAdminSpell);
    mwarea.lNumberOfSubAdarea = area.lNumberOfSubAdarea;
    
    GADAREALIST *ppAdareaList = NULL;
    GADMINCODE pstAdCode = {0};
    pstAdCode.euRegionCode = eREGION_CODE_CHN;
    pstAdCode.nAdCode = area.lAdminCode;
    GSTATUS res = GDBL_GetAdareaList(flag,&pstAdCode,&ppAdareaList);
    if (res == GD_ERR_OK && area.lAdminCode != 0 && ppAdareaList->lNumberOfAdarea > 1)
    {
        int areaCount = ppAdareaList->lNumberOfAdarea;
        NSMutableArray *array = [[NSMutableArray alloc] init];
        for (int i = 0; i < areaCount; i++)
        {
            GDBL_GetAdareaList(flag,&pstAdCode,&ppAdareaList);
            GADAREA temp = ppAdareaList->pAdarea[i];
            MWArea *recursive = nil;
            if (area.lAdminCode == temp.lAdminCode)
            {
                recursive = [[MWArea alloc] init];
                recursive.lAdminCode = temp.lAdminCode;
                recursive.szAdminName = GcharToNSString(temp.szAdminName);
                recursive.szAdminSpell = GcharToNSString(temp.szAdminSpell);
                recursive.lNumberOfSubAdarea = temp.lNumberOfSubAdarea;
                [array addObject:recursive];
                [recursive release];
            }
            else
            {
                recursive = [self recursiveForArea:temp flag:flag];
                [array addObject:recursive];
            }
            
        }
        mwarea.pSubAdareaArray = array;
        [array release];
    }
    return [mwarea autorelease];
}
@end

@implementation MWAreaInfo

@synthesize lAdminCode,bHasData,coorCenter,nNumberOfBytes,nTel,szCityName,szProvName,szTownName;

- (void)dealloc
{
    self.szTownName = nil;
    self.szProvName = nil;
    self.szCityName = nil;
    [super dealloc];
}

- (NSString *)szTownName
{
    if (szTownName == nil)
    {
        return @"";
    }
    return szTownName;
}

- (NSString *)szProvName
{
    if (szProvName == nil)
    {
        return @"";
    }
    return szProvName;
}

- (NSString *)szCityName
{
    if (szCityName == nil)
    {
        return @"";
    }
    return szCityName;
}
/*!
 @brief  递归将GADAREAINFOEX转化成MWAreaInfo
 @param  gAreaInfo, 将要转化的GADAREAINFOEX
 @return 转化后的 MWAreaInfo。
 */
+ (MWAreaInfo *)changeAreaInfo:(GADAREAINFOEX)gAreaInfo
{
    if (&gAreaInfo == NULL)
    {
        return nil;
    }
    MWAreaInfo  *mwarea = [[[MWAreaInfo alloc] init] autorelease];
    mwarea.szCityName = GcharToNSString(gAreaInfo.szCityName);
    mwarea.szProvName = GcharToNSString(gAreaInfo.szProvName);
    mwarea.szTownName = GcharToNSString(gAreaInfo.szTownName);
    mwarea.bHasData = gAreaInfo.bHasData;
    mwarea.lAdminCode = gAreaInfo.lAdminCode;
    mwarea.coorCenter = gAreaInfo.coorCenter;
    mwarea.nTel = gAreaInfo.nTel;
    return mwarea;
}
@end

@implementation MWAdminCode


/**
 **********************************************************************
 \brief 获取行政区域列表
 \details 实现获取指定行政区域编码的行政区域及其下级行政区域信息列表。
 \param[in]	euAdareaDataFlag	行政区域数据存在标识
 \param[in]	nAdminCode			行政编码
 \retval	ppstAdareaList		行政区域信息列表
 \remarks
 如果参数lAdminCode等于0，则表示获取当前地图数据所覆盖的行政区域信息，
 包括各行政区域的下级行政区域信息。
 **********************************************************************/
+ (MWAreaList *)GetAdareaListFlag:(GADAREADATAFLAG)euAdareaDataFlag admincode:(Gint32)lAdminCode
{
    MWAreaList *list = [[[MWAreaList alloc] init] autorelease];
    GADAREALIST *ppAdareaList = NULL;
    GADMINCODE pstAdCode = {0};
    pstAdCode.euRegionCode = eREGION_CODE_CHN;
    pstAdCode.nAdCode = lAdminCode;
    GSTATUS res = GDBL_GetAdareaList(euAdareaDataFlag,&pstAdCode,&ppAdareaList);
    
    if (res == GD_ERR_OK && ppAdareaList->lNumberOfAdarea != 0 && ppAdareaList->pAdarea != NULL)
    {
        list.lNumberOfAdarea = ppAdareaList->lNumberOfAdarea;
        int areaCount = ppAdareaList->lNumberOfAdarea;

        for (int i = 0; i< areaCount; i++)
        {
            GADAREA area = ppAdareaList->pAdarea[i];
            MWArea *mwArea = [MWArea changeForArea:area];
            if (!([mwArea.szAdminName isEqualToString:@"台湾省"] || [mwArea.szAdminName isEqualToString:@"台灣省"] || [mwArea.szAdminName isEqualToString:@"Taiwan"])) //add by gzm for 特殊处理：因为目前不支持台湾数据，台湾省不加入行政区域列表 at 2014-7-28
            {
                [list.pAdareaArray addObject:mwArea];
            }
            
            mwArea.CurrentArray = list.pAdareaArray;
            mwArea.superArray = nil;
            mwArea.areaDataFlag = euAdareaDataFlag;
        }
    }
    return list;
}

/**
 **********************************************************************
 \brief 设置当前检索行政区域
 \details 设置当前检索行政区域，完成相关检索数据初始化。
 \param[out]	nAdminCode		行政编码
 \retval	GD_ERR_OK 成功
 \remarks
 \since 6.0
 \see GDBL_GetCurAdarea
 **********************************************************************/
+ (GSTATUS)SetCurAdarea:(Gint32)lAdminCode
{
    return GDBL_SetCurAdarea(lAdminCode);
}

/**
 **********************************************************************
 \brief 获取当前行政区域详细信息结构体
 \details 获取当前行政区域详细信息结构体
 \retval	MWAreaInfo类型 行政区域详细信息结构体
 **********************************************************************/
+ (MWAreaInfo *)GetCurAdarea
{
    GADAREAINFOEX pAdareaInfoEx = {0};
    GSTATUS res = GDBL_GetCurAdarea(&pAdareaInfoEx);
    if (res == GD_ERR_OK)
    {
        return [[[MWAreaInfo changeAreaInfo:pAdareaInfoEx] retain] autorelease];
    }
    return nil;
}

/**
 **********************************************************************
 \brief 获取行政区域信息
 \details 获取指定行政区域编码对应的省、市、区名称等信息。
 \param[in]	nAdminCode		行政编码
 \retval	MWAreaInfo类型 行政区域详细信息结构体
 \remarks
 1、	如果lAdminCode指定到省一级，则市、区名称为空；如果lAdminCode指定到市一
 级，则区名称为空。如果lAdminCode等于0，则省、市、区名称为空，具体区域不确定。
 2、	数据包大小，只针对分市版数据。
 \since 6.0
 \see
 **********************************************************************/
+ (MWAreaInfo *)GetCurAdareaWith:(Gint32)lAdminCode
{
    GADAREAINFOEX pAdareaInfoEx = {0};
    GADMINCODE admincode_temp = {0};
    admincode_temp.euRegionCode = eREGION_CODE_CHN;
    admincode_temp.nAdCode = lAdminCode;
    GSTATUS res = GDBL_GetAdareaInfoEx (&admincode_temp,&pAdareaInfoEx);
    if (res == GD_ERR_OK)
    {
        return [[[MWAreaInfo changeAreaInfo:pAdareaInfoEx] retain] autorelease];
    }
    return nil;
}

/**
 **********************************************************************
 \brief 获取地图中心点行政区域编码
 \details 获取地图中心点行政区域编码
 \retval	pnAdminCode 行政编码 失败返回0
 \remarks
 如果经纬度坐标属于中国范围，但未被划归到具体的行政区域，则返回0。
 \since 6.0
 \see
 **********************************************************************/
+ (Gint32)GetCurAdminCode
{
    GCOORD coord = {-1,-1};
	return [MWAdminCode GetAdminCode:coord];
}

/**
 **********************************************************************
 \brief 获取指定经纬坐标所属行政区域编码
 \details 获取指定经纬坐标所属行政区域编码
 \param[in] pCoord 经纬度坐标
 \retval	pnAdminCode 行政编码 失败返回0
 \remarks
 如果经纬度坐标属于中国范围，但未被划归到具体的行政区域，则返回0。
 \since 6.0
 \see
 **********************************************************************/
+ (Gint32)GetAdminCode:(GCOORD)pCoord
{
	GCOORDTEL coordTel = {0};
    coordTel.euAdCodeLevel = ADAREA_TYPE_CITY;
	coordTel.eFlag = COORDTEL_TYPE_COORD;
	coordTel.u.Coord.x = pCoord.x;
	coordTel.u.Coord.y = pCoord.y;
	GADMINCODE *pstAdCode = NULL;
    int getCount = 0;
	GSTATUS res = GDBL_GetAdminCode(&coordTel,&getCount,&pstAdCode);
    if (res == GD_ERR_OK && getCount > 0)
    {
        return pstAdCode[0].nAdCode;
    }
	return 0;
}

/**
 **********************************************************************
 \brief 获取指定经纬坐标所属行政区域编码
 \details 获取指定经纬坐标所属行政区域编码
 \param[in] pCoord 经纬度坐标
 \retval	NSArray 行政编码数组
 **********************************************************************/
+ (NSArray *)GetAdminCodeArray:(GCOORD)pCoord
{
    NSMutableArray *array = [NSMutableArray array];
	GCOORDTEL coordTel = {0};
    coordTel.euAdCodeLevel = ADAREA_TYPE_CITY;
	coordTel.eFlag = COORDTEL_TYPE_COORD;
	coordTel.u.Coord.x = pCoord.x;
	coordTel.u.Coord.y = pCoord.y;
	GADMINCODE *pstAdCode = NULL;
    int getCount = 0;
	GSTATUS res = GDBL_GetAdminCode(&coordTel,&getCount,&pstAdCode);
    if (res == GD_ERR_OK)
    {
        for (int i = 0; i < getCount; i++)
        {
            [array addObject:[NSNumber numberWithInt:pstAdCode[i].nAdCode]];
        }
    }
	return array;
}


/**
 **********************************************************************
 \brief 获取指定数据、区域数据状态
 \details 该函数用于获取指定数据、区域数据的状态
 \param[in] pstAdCode 指定的行政区域编码
 \param[out] bHasData Gtrue 有数据, Gfalse 无数据
 \retval	GD_ERR_OK	成功
 \retval	GD_ERR_INVALID_PARAM	参数无效
 \remark
 - pstAdCode->euRegionCode == 0：表示获取全局版本，
 - pstAdCode->euRegionCode > 0 && pstAdCode->nAdCode == 0：表示获取指定国家的基础版本
 - pstAdCode->euRegionCode > 0 && pstAdCode->nAdCode > 0：表示获取指定行政区域(城市)的版本
 **********************************************************************/
+ (GSTATUS)GetAdareaDataStatus:(GADMINCODE *)pstAdCode bHasData:(Gbool *)bHasData
{
    GSTATUS res = GDBL_GetAdareaDataStatus(NSStringToGchar(Map_Data_Path), pstAdCode, bHasData);
    return res;
}

/**
 **********************************************************************
 \brief 获取行政区域列表
 \details 实现获取指定行政区域编码的行政区域及其下级行政区域信息列表(实际存在数据)
 \param[in]	pstAdCode			行政编码
 \param[out]	ppstAdareaList		行政区域信息列表
 \retval	GD_ERR_OK 成功
 \retval	GD_ERR_INVALID_PARAM	参数无效
 \retval	GD_ERR_NO_MEMORY	内存不足
 \retval	GD_ERR_NO_DATA	无相关数据
 \remarks
 如果参数lAdminCode等于0，则表示获取当前地图数据所覆盖的行政区域信息，
 包括各行政区域的下级行政区域信息。
 \since 6.0
 \see
 **********************************************************************/
+ (GSTATUS)GetAdareaWithDataList:(GADMINCODE *)pstAdCode list:(GADAREALIST **)ppstAdareaList
{
    GSTATUS res = GDBL_GetAdareaWithDataList(pstAdCode, ppstAdareaList);
    return res;
}


/*
 **********************************************************************
 \brief 获取数据目录列表
 \details 获取城市数据目录列表
 \param[in] pstAdCode 指定的行政区域编码
 \param[in] nMaxCnt 最大目录缓存个数
 \param[out] pstDirList 目录缓存
 \retval	GD_ERR_OK 成功
 \retval	GD_ERR_FAILED 操作失败
 \retval	GD_ERR_INVALID_PARAM 参数无效
 \remark
 - pstAdCode->euRegionCode == 0：表示获取全局版本，
 - pstAdCode->euRegionCode > 0 && pstAdCode->nAdCode == 0：表示获取指定国家的基础版本
 - pstAdCode->euRegionCode > 0 && pstAdCode->nAdCode > 0：表示获取指定行政区域(城市)的版本
 \since
 ********************************************************************* */
+ (GSTATUS)GetAdareaDirList:(GADMINCODE *)pstAdCode nMaxCnt:(Gint32)nMaxCnt list:(GDATADIRINFO*)pstDirList
{
    GSTATUS res = GDBL_GetAdareaDirList(NSStringToGchar(Map_Data_Path), pstAdCode, nMaxCnt, pstDirList);
    return res;
}

#pragma mark -
#pragma mark  以下函数包含逻辑

//获取指定经纬度的城市级行政编码
+(NSString *)GetCityAdminCode:(long)lon Lat:(long)lat
{
    NSString *cityAdminCode;
    GCOORD gcoord = {0};
    gcoord.x = lon;
    gcoord.y = lat;
    Gint32 adminCode = [MWAdminCode GetAdminCode:gcoord];
    MWAreaInfo *info = [MWAdminCode GetCurAdareaWith:adminCode];
    if ([info.szProvName length]> 0 )
    {
        if ((adminCode/10000 == 81)||(adminCode/10000 == 82)||(adminCode/10000 == 11)||(adminCode/10000 == 50)||(adminCode/10000 == 31)||(adminCode/10000 == 12))
        {
            cityAdminCode = [NSString stringWithFormat:@"%d",adminCode/10000*10000];
            return cityAdminCode;
        }
        else
        {
            if ([info.szCityName length]> 0) {
                cityAdminCode = [NSString stringWithFormat:@"%d",adminCode/100*100];
            }
            else{
                cityAdminCode = @"86";
            }
            return cityAdminCode;
        }
        
    }
    cityAdminCode = @"86";
    return cityAdminCode;
}

//获取城市行政编码（对直辖市的行政编码作处理）
+ (int)GetCityAdminCodeWithAdminCode:(int)nAdminCode
{
    int admincode = 0;
    if ((nAdminCode/10000 == 81)||(nAdminCode/10000 == 82)||(nAdminCode/10000 == 11)||(nAdminCode/10000 == 50)||(nAdminCode/10000 == 31)||(nAdminCode/10000 == 12))
    {
        admincode = nAdminCode/10000*10000;
    }
    else
    {
        
        admincode = nAdminCode/100*100;
    }
    return admincode;
}

/**
 **********************************************************************
 \brief 判断指定行政区域是否有数据
 \details 判断指定行政区域是否有数据
 \param[in] 	admincode 行政编码，为0时表示获取地图中心点的区域是否有数据
 \remarks 存在数据返回YES 无数据为NO
 **********************************************************************/
+(BOOL)checkIsExistDataWithAdmincode:(Gint32)admincode
{
    if (admincode == 0)
    {
        GCOORD coord = {-1,-1};
        return [MWAdminCode checkIsExistDataWithCoord:coord];
    }
	else
    {
        MWAreaInfo *info = [MWAdminCode GetCurAdareaWith:admincode];
        return info.bHasData;
    }
}

/**
 **********************************************************************
 \brief 判断指定经纬度是否有数据
 \details 判断指定经纬度是否有数据
 \param[in] 	coord 经纬度
 \remarks 存在数据返回YES 无数据为NO
 **********************************************************************/
+(BOOL)checkIsExistDataWithCoord:(GCOORD)coord
{
    NSArray *array = [MWAdminCode GetAdminCodeArray:coord];  //返回多个行政编码表示无数据
    if ([array count] >1)
    {
        return NO;
    }
    else if ([array count] == 0)
    {
        return NO;
    }
    else
    {
        int Admin_code = [[array caObjectsAtIndex:0] intValue];
        if (Admin_code == 0) //行政区域为0时，表示位置处于海，不需要提示。
        {
            return NO;
        }
        MWAreaInfo *info = [MWAdminCode GetCurAdareaWith:Admin_code];
        return info.bHasData;
    }
}

/**
 **********************************************************************
 \brief 拨打电话(根据经纬度获取区号)
 **********************************************************************/
+ (void)telephoneCall:(NSString *)telephone Lon:(int)lon Lat:(int)lat
{
    if(telephone && [telephone length] != 0)
    {
        
        NSRange range;
        NSString* dicStr = [telephone stringByReplacingOccurrencesOfString:@"、"  withString:@";"];
        range = [dicStr rangeOfString:@";"];
        int location = range.location;
        int lenght = range.length;
        if (lenght == 0)
        {
            location = dicStr.length;
        }
        NSURL *telURL = [NSURL URLWithString:[NSString stringWithFormat:@"telprompt://%@",[MWAdminCode getPhoneNumber:[dicStr substringToIndex:location] WithLon:lon Lat:lat]]];
        [[UIApplication sharedApplication] openURL:telURL];
        
    }
}

/**
 **********************************************************************
 \brief 获取当前区域名称
 **********************************************************************/
+ (NSString *)GetAdareaName
{
    
	NSMutableString *adAreaName = [[NSMutableString alloc] init];
    MWAreaInfo *areainfo = [MWAdminCode GetCurAdarea];
    if (areainfo)
    {
        [adAreaName appendString:areainfo.szTownName];
        if (0==[adAreaName length])
        {
            [adAreaName appendString:areainfo.szCityName];
            if (0==[adAreaName length])
            {
                [adAreaName appendString:areainfo.szProvName];
                if (0==[adAreaName length])
                {
                    [adAreaName appendString:STR(@"CityDownloadManage_Country", Localize_CityDownloadManage)];
                }
            }
        }
        return [adAreaName autorelease];
    }
	return STR(@"POI_Country", Localize_POI);
}

/**
 **********************************************************************
 \brief 组装电话区号
 **********************************************************************/
+ (NSString *)getPhoneNumber:(NSString *)tel_string WithLon:(int)lon Lat:(int)lat
{
	if( tel_string && [tel_string length] != 0)
	{
		if ([tel_string length] >=10)
		{
			return tel_string;
		}
		NSRange range;
		range = [tel_string rangeOfString:@"-"];
		if (range.length == 0 && [tel_string length] != 11)
		{
			range.location = 0;
            Gint32 plAdminCode;
            GADAREAINFOEX pAdareaInfoEx;
            GCOORD coord = {0};
            coord.x = lon;
            coord.y = lat;
            plAdminCode = [MWAdminCode GetAdminCode:coord];
            if (plAdminCode == 0) {
                return tel_string;
            }
            GADMINCODE admincode_temp = {0};
            admincode_temp.nAdCode = plAdminCode;
            admincode_temp.euRegionCode = eREGION_CODE_CHN;
            GSTATUS res = GDBL_GetAdareaInfoEx(&admincode_temp, &pAdareaInfoEx) ;
			if (res == GD_ERR_OK) {
                return [NSString stringWithFormat:@"0%d-%@",pAdareaInfoEx.nTel,tel_string];
            }
            else {
                return tel_string;
            }
		}
		else
		{
			return tel_string;
		}
		
	}
	else
	{
		return @"";
	}
}


/**
 **********************************************************************
 \brief 获取指定行政编码的城市名
 **********************************************************************/
+ (NSString *)GetCityNameWithAdminCode:(int)nAdminCode
{
    NSString *strCityName = @"";
    MWAreaInfo *info = [MWAdminCode GetCurAdareaWith:nAdminCode];
    
    if ((nAdminCode/10000 == 81)||(nAdminCode/10000 == 82)||(nAdminCode/10000 == 11)||(nAdminCode/10000 == 50)||(nAdminCode/10000 == 31)||(nAdminCode/10000 == 12))
    {
        if ([info.szProvName length] != 0)
        {
            strCityName = info.szProvName;
        }
    }
    else
    {
        strCityName = info.szCityName;
        
    }
    if (strCityName == nil)
    {
        return @"";
    }
    return strCityName;
}

/**
 **********************************************************************
 \brief 检测传入行政编码是否有TMC数据
 **********************************************************************/
+ (BOOL)isTmcCityWith:(int)nAdminCode
{
    if ((nAdminCode/10000 == 81)||(nAdminCode/10000 == 82)||(nAdminCode/10000 == 11)||(nAdminCode/10000 == 50)||(nAdminCode/10000 == 31)||(nAdminCode/10000 == 12))
    {
        nAdminCode = (nAdminCode / 10000) * 10000;
    }
    else
    {
        nAdminCode = (nAdminCode / 100) * 100;
    }
    NSMutableArray *array = [NSMutableArray arrayWithContentsOfFile:TmcCityPath];
    int oldCount = [array count];
    NSPredicate * thePredicate = [NSPredicate predicateWithFormat:@"NOT (SELF in %@)", [NSString stringWithFormat:@"%d",nAdminCode]];
    [array filterUsingPredicate:thePredicate];
    if (oldCount != [array count])
    {
        return YES;
    }
    return NO;
}
@end

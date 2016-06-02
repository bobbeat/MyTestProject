//
//  CustomRealTimeTraffic.m
//  AutoNavi
//
//  Created by liyuhang on 12-12-18.
//
//

#import "CustomRealTimeTraffic.h"
#import "GDBL_Interface.h"
#import "GDBL_typedef.h"
#import "NSString+Category.h"
#import "ANParamValue.h"
#import "MWPreference.h"

static CustomRealTimeTraffic *stCustomRealTimeTraffic;
@implementation CustomRealTimeTraffic
//
@synthesize psCurrentIndexForMove = m_nCurrentIndexForMove;
//
@synthesize psfFreeStatus = m_fFreeStatus;
@synthesize psfSlowStatus = m_fSlowStatus;
@synthesize psfHeavyStatus = m_fHeavyStatus;
@synthesize psfNoDataStatus = m_fNoDataStatus;
#pragma mark 单例
+ (CustomRealTimeTraffic*)sharedInstance {
	
	if (nil==stCustomRealTimeTraffic)
	{
		stCustomRealTimeTraffic = [[CustomRealTimeTraffic alloc] init];
	}
	return stCustomRealTimeTraffic;
}

// 路径是否有信息
-(BOOL) getHaveTrafficInfo
{
    // 显示的条件（1 有路径；2 设置开关为开；3 实时交通打开；4 数组是否有数据）
    BOOL bTMCStart = [MWEngineSwitch isTMCOn];
    BOOL bSetupOn = [[MWPreference sharedInstance] getValue:PREF_TRAFFICMESSAGE];
    BOOL bPath = [[ANParamValue sharedInstance] isPath];
    int n = [m_mArrayRtcInfo count];
    if (bTMCStart&&bSetupOn&&bPath&&n>0) {
    return TRUE;
}
    return NO;
}

-(void) dealloc
{
    [m_mArrayRtcInfo release];
    [m_mArrayForHalfWay release];
    [super dealloc];
}
#pragma mark 内部方法
-(int) getScaleByDistanceFromStart:(float) fDistance
{
    float fhectometre = fDistance/100.0f;
    float fScale;
    if (fhectometre<50) {
        fScale = fhectometre;                   // 100米一格
    } else if (fhectometre<250){
        fScale = 50+(fhectometre-50)/10;        // 1000米一格
    } else if (fhectometre<500){
        fScale = 70+(fhectometre-250)/25;        // 2500米一格
    } else if (fhectometre<1000){
        fScale = 80+(fhectometre-500)/50;        // 5000米一格
    } else{
        fScale = 90;
    }
    return  (int)fScale;
}

// 更新实时交通的信息，也就是更改类中保存的相应信息
-(void) updateCurrentTrafficInfo
{
    //是否初始化
    if (![[ANParamValue sharedInstance] isInit])
    {
        return;
        
    }
    GGUIDEROADTMCLIST pList = {0};
    GSTATUS nStatus = GDBL_GetGuideRoadTMCList(&pList);
    
    if (nStatus==GD_ERR_OK) {
        // 填充信息
        float fFreeDis = 0.0, fSlowDis= 0.0 ,fHeavyDis= 0.0;
        // 终点 车位信息
        m_fTotalDistance = pList.nTotalDis;
        if (m_fTotalDistance<0) {
            return;
        }
        m_nDestScale = [self getScaleByDistanceFromStart:m_fTotalDistance];
        m_fCarPosition = pList.nCarDisFromStart;
        m_nCarScale = [self getScaleByDistanceFromStart:m_fCarPosition];
        // 中途点休息
        if (m_mArrayForHalfWay) {
            [m_mArrayForHalfWay release];
        }
        m_mArrayForHalfWay = [[NSMutableArray alloc]init];
        for (int i=1; i<4;i++) {
            if (pList.nDestDisFromStart[i][1]>0) {
                [m_mArrayForHalfWay addObject:[NSNumber numberWithInt:pList.nDestDisFromStart[i][1]]];
            }
        }
        // 各个结点信息
        if (m_mArrayRtcInfo) {
            [m_mArrayRtcInfo release];
        }
        m_mArrayRtcInfo = [[NSMutableArray alloc]init];
        NSString* szRoadName[3] = {@"普通路", @"普通路", @"Surface road"};
        for (int i=0; i<pList.nNumberOfItem; i++) {
            // 车位到起点的距离大于该点到起点的距离的项抛弃
//            if (pList.pItem[i].nDisFromStart+pList.pItem[i].nDis<pList.nCarDisFromStart) {
//                continue;
//            }
            UIGuideRoadTmc* guideRoadTme = [[UIGuideRoadTmc alloc]init];
            guideRoadTme.psnDelayTime = pList.pItem[i].nDelayTime;
            guideRoadTme.psnDis = pList.pItem[i].nDis;
            guideRoadTme.psnDisFromStart = pList.pItem[i].nDisFromStart;
            guideRoadTme.psnEndIndex = pList.pItem[i].eIndex;
            guideRoadTme.psnNumberOfEvent = pList.pItem[i].nNumberOfEvent;
            guideRoadTme.psnStartIndex = pList.pItem[i].sIndex;
            guideRoadTme.psnTrafficStream = pList.pItem[i].eTrafficStream;
            guideRoadTme.psnDisFromCar = pList.pItem[i].nDisFromStart-pList.nCarDisFromStart;
            guideRoadTme.psnNumberOfEvent = pList.pItem[i].nNumberOfEvent;
            guideRoadTme.pspTrafficEvents = pList.pItem[i].pTrafficEvents;
           
            if (guideRoadTme.psnDisFromCar<0) {
                guideRoadTme.psnDisFromCar = 0;
            }
            // 没有数据时，普通路
            if (strlen(pList.pItem[i].szRoadNames)) {
            guideRoadTme.psszRoadNames = [NSString chinaFontStringWithCString:pList.pItem[i].szRoadNames];
            }else{
                guideRoadTme.psszRoadNames = szRoadName[fontType];
            }

            guideRoadTme.psnIndexInOriginalArray = i;
            //
            int nScale = [self getScaleByDistanceFromStart:pList.pItem[i].nDisFromStart];
            guideRoadTme.psnScaleFromStart = nScale;
            //	GTRAFFIC_STREAM_BUSY			= 0x02, 	/* 繁忙 *///	GTRAFFIC_STREAM_SLOW			= 0x03,		/* 缓行 */
            //	GTRAFFIC_STREAM_CROWDED			= 0x04,		/* 拥堵 *///	GTRAFFIC_STREAM_SEVERE_CROWDED	= 0x05,		/* 严重拥堵 */
            if (pList.pItem[i].eTrafficStream == 2||pList.pItem[i].eTrafficStream == 3) {
                guideRoadTme.psnTrafficStatus = 2;
                fSlowDis += guideRoadTme.psnDis;
            } else if(pList.pItem[i].eTrafficStream == 4||pList.pItem[i].eTrafficStream == 5) {
                guideRoadTme.psnTrafficStatus = 3;
                fHeavyDis += guideRoadTme.psnDis;
            }else if(pList.pItem[i].eTrafficStream == 1) {
                guideRoadTme.psnTrafficStatus = 1;
                fFreeDis += guideRoadTme.psnDis;
            }else{
                 guideRoadTme.psnTrafficStatus = 4;
            }
            // 只添加缓行何拥堵两种情况
            if (guideRoadTme.psnTrafficStatus == 2||guideRoadTme.psnTrafficStatus==3)
            {
                [m_mArrayRtcInfo addObject: guideRoadTme];
            }
            [guideRoadTme release];
        }
        // 计算4种情况的比例情况
        m_fFreeStatus = fFreeDis/m_fTotalDistance;
        m_fSlowStatus = fSlowDis/m_fTotalDistance;
        m_fHeavyStatus = fHeavyDis/m_fTotalDistance;
        m_fNoDataStatus = 1-m_fSlowStatus-m_fFreeStatus-m_fHeavyStatus;
    }
}


/*
 添加配合CustomSlider使用的函数
 */

// 1 获取包含交通信息的数组的个数；
-(int) RtcInfoArrayCount//
{
    return [m_mArrayRtcInfo count];
}
// 2 根据“数组索引值”获取交通信息组装字段，例：“前方2.6公里，建国门外大街 缓行 影响范围 284米”
- (NSString *)RtcSpecificInfo:(int)nArrayIndex
{
    NSString *trafficInfo = @"";
    if (nArrayIndex>=0&&nArrayIndex<[m_mArrayRtcInfo count]) {
        
        UIGuideRoadTmc* guideRoad = [m_mArrayRtcInfo objectAtIndex:nArrayIndex];
        if (guideRoad.psnTrafficStatus == 2 || guideRoad.psnTrafficStatus == 3) {
            //道路名字
            NSString *roadName = guideRoad.psszRoadNames;
            NSString *disFromCar = @"";
            NSString *streamType = @"";
            NSString *impactRange = @"";
            
            //车辆距事件，交通流距离
            
            float fDistance = guideRoad.psnDisFromCar;
            if (fDistance>1000) {
                fDistance = fDistance/1000;
                disFromCar = [NSString stringWithFormat:@"%.2f%@", fDistance,STR(@"Universal_KM", Localize_Universal)];
            }else{
                disFromCar = [NSString stringWithFormat:@"%.f%@", fDistance,STR(@"Universal_M", Localize_Universal)];
            }
            
            //交通流类型
            
            if (guideRoad.psnTrafficStatus == 2) {
                streamType = [NSString stringWithFormat:@"%@",STR(@"TMC_slow", Localize_TMC)];
            }
            else if (guideRoad.psnTrafficStatus == 3){
                streamType = [NSString stringWithFormat:@"%@",STR(@"TMC_congest", Localize_TMC)];
            }
            //影响范围
            
            float fRange = guideRoad.psnDis;
            if (fRange>1000) {
                fRange = fRange/1000;
                impactRange = [NSString stringWithFormat:@"%.2f%@", fRange,STR(@"Universal_KM", Localize_Universal)];
            }else{
                impactRange = [NSString stringWithFormat:@"%.f%@", fRange,STR(@"Universal_M", Localize_Universal)];
            }
            trafficInfo = [NSString stringWithFormat:STR(@"TMC_trafficInfo", Localize_TMC),disFromCar,roadName,streamType,impactRange];
        }
        
    }
    return trafficInfo;
}

// 4 根据“数组索引值”获取具体的交通信息－状态
-(int) RtcSpecificInfoStatus:(int) nArrayIndex
{
    int nReturn = 0;
    if (nArrayIndex>=0&&nArrayIndex<[m_mArrayRtcInfo count]) {
        UIGuideRoadTmc* guideRoad = [m_mArrayRtcInfo objectAtIndex:nArrayIndex];
        nReturn = guideRoad.psnTrafficStatus;
    }
    return nReturn;
}

// 6 根据“数组索引值”获取具体的交通信息－道路名字
-(NSString*) RtcSpecificInfoName:(int) nArrayIndex
{
    NSString* stName = nil;
    if (nArrayIndex>=0&&nArrayIndex<[m_mArrayRtcInfo count]) {
        UIGuideRoadTmc* guideRoad = [m_mArrayRtcInfo objectAtIndex:nArrayIndex];
        stName = guideRoad.psszRoadNames;
    }
    return stName;
}

/*
 1 根据索引值获得当前路径得时间＋延迟得时间
 */
-(NSString*)RtcTotalTimeOfRoute:(int)nArrayIndex
{
    NSString* szString = nil;
    NSUInteger nTimeOriginalRoute, nTimeDelay;
    /*
     Route info
     */
	GPATHSTATISTICLIST *ppStatInfoList;
	if (GD_ERR_OK == GDBL_GetPathStatisticInfo(NULL,Gtrue, Gfalse, &ppStatInfoList))
	{
       nTimeOriginalRoute = ppStatInfoList->pPathStat->nTime;
            
    }
    if (nArrayIndex>=0&&nArrayIndex<[m_mArrayRtcInfo count]) {
        UIGuideRoadTmc* guideRoad = [m_mArrayRtcInfo objectAtIndex:nArrayIndex];
        if (guideRoad.psnDelayTime<1) {
            guideRoad.psnDelayTime = 1;
        }
        nTimeDelay = guideRoad.psnDelayTime;
    }
    NSUInteger hour = ((nTimeOriginalRoute+nTimeDelay)/60);
    NSUInteger minute = ((nTimeOriginalRoute+nTimeDelay)%60);
    if (hour >0)
    {
        szString =[NSString stringWithFormat:@"%dh:%dm",hour,minute];
    }
    else
    {
        szString = [NSString stringWithFormat:@"%dmin",minute];
    }
    return szString;
}

-(int) RtcSpecificInfoDistanceFromCar:(int)nArrayIndex
{
    int nReturn = 0;
    if (nArrayIndex>=0&&nArrayIndex<[m_mArrayRtcInfo count]) {
        UIGuideRoadTmc* guideRoad = [m_mArrayRtcInfo objectAtIndex:nArrayIndex];
        nReturn = guideRoad.psnDisFromCar;
    }
    return nReturn;
}
/***********获取到起点距离 修改人 高志闽  日期 2013-5-25**********/
-(int) RtcSpecificInfoDistanceFromStart:(int)nArrayIndex
{
    int nReturn = 0;
    if (nArrayIndex>=0&&nArrayIndex<[m_mArrayRtcInfo count]) {
        UIGuideRoadTmc* guideRoad = [m_mArrayRtcInfo objectAtIndex:nArrayIndex];
        nReturn = guideRoad.psnDisFromStart;
    }
    return nReturn;
}

@end

@implementation UIGuideRoadTmc

@synthesize psnStartIndex = m_nStartIndex;
@synthesize psnEndIndex = m_nEndIndex;
@synthesize psnDisFromStart = m_nDisFromStart;
@synthesize psnDis = m_nDis;
@synthesize psszRoadNames = m_szRoadNames;
@synthesize psnNumberOfEvent = m_nNumberOfEvent;
@synthesize pspTrafficEvents = m_pTrafficEvents;
@synthesize psnTrafficStream = m_nTrafficStream;
@synthesize psnDelayTime = m_nDelayTime;
@synthesize psnScaleFromStart = m_nScaleFromStart;
@synthesize psnTrafficStatus = m_nTrafficStatus;
@synthesize psnIndexInOriginalArray = m_nIndexInOrigianArray;
@synthesize psnDisFromCar = m_nDisFromCar;
//
-(void)dealloc
{
    if (m_szRoadNames) {
        [m_szRoadNames release];
    }
    [super dealloc];

}
@end














//
//  RoadInfo.m
//  AutoNavi
//
//  Created by liyuhang on 13-1-16.
//
//

#import "CustomRoadInfo.h"

@implementation MainRoadInfo
@synthesize psszDistance = m_szDistance;
@synthesize psszRoadName = m_szRoadName;
@synthesize psszNextRoadName = m_szNextRoadName;
@synthesize psarraySubRoadInfo = m_arraySubRoadInfo;
@synthesize psnDirectID = m_nDirectID;
@synthesize psnCountOfSubRoadInfo = m_nCountOfSubRoadInfo;
@synthesize psnTrafficStatus = m_nTrafficStatus;
@synthesize psbCarOnTheRoad = m_bCarOnTheRoad;
@synthesize psbShowSubRoadInfo = m_bShowSubRoadInfo;
@synthesize psimgView = m_imgView;
@synthesize psnIndexInRoadList = m_nIndexInRoadList;
@synthesize psbSetDetour = m_bSetDetour;
@synthesize psbEvent = m_bEvent;
@synthesize psszEventDetail = m_szEventDetail;
@synthesize psnEventState = m_nEventState;
@synthesize psszEventName = m_szEventName;

-(void)dealloc
{
    if (m_szEventName) {
        [m_szEventName release];
        m_szEventName = nil;
    }
    if (m_szEventDetail) {
        [m_szEventDetail release];
        m_szEventDetail = nil;
    }

    if (m_szRoadName) {
        [m_szRoadName release];
        m_szRoadName = nil;
    }
    if (m_szNextRoadName) {
        [m_szNextRoadName release];
        m_szNextRoadName = nil;
    }
    if (m_arraySubRoadInfo) {
        [m_arraySubRoadInfo release];
        m_arraySubRoadInfo = nil;
    }
    if (m_imgView) {
        [m_imgView release];
        m_imgView = nil;
    }
    [super dealloc];
}
@end

@implementation SubRoadInfo
@synthesize psszDistance = m_szDistance;
@synthesize psszRoadName = m_szRoadName;
@synthesize psnDirectID = m_nDirectID;
@synthesize psnTrafficStatus = m_nTrafficStatus;
@synthesize psbCarOnTheRoad = m_bCarOnTheRoad;
@synthesize psnIndexInRoadList = m_nIndexInRoadList;
@synthesize psbSetDetour = m_bSetDetour;

-(void)dealloc
{
    if (m_szRoadName) {
        [m_szRoadName release];
        m_szRoadName = nil;
    }
    if (m_szDistance) {
        [m_szDistance release];
        m_szDistance = nil;
    }
    [super dealloc];
}
@end

@implementation ManeuverInfoList
@synthesize pManeuverText,nNumberOfManeuver;

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)dealloc
{
    self.pManeuverText = nil;
    [super dealloc];
}

@end

@implementation ManeuverInfo


@synthesize szDescription,pstSubManeuverText,eFlag,eTrafficStream,nDisFromCar,nID,nNextArrivalTime,nNextDis,nNumberOfSubManeuver,nTotalRemainDis,nTrafficEventID,stObjectId,unTurnID,nTrafficLightNum,currentLoadName,nextLoadName,isExtension,isSonPoint,nNumberOfEvents,pstGeventInfo,detourRoadInfo,Coord;

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.isExtension = NO;
        self.isSonPoint = NO;
    }
    return self;
}

- (void)dealloc
{
    if (detourRoadInfo)
    {
        free(detourRoadInfo);
    }
    if (pstGeventInfo)
    {
        free(pstGeventInfo);
    }
    self.currentLoadName = nil;
    self.nextLoadName = nil;
    self.pstSubManeuverText = nil;
    self.szDescription = nil;
    [super dealloc];
}


- (NSString *) getNextDisString
{
    NSString *stringDistance = @"";
    if(self.nNextDis <= 999)
    {
        stringDistance  = [NSString stringWithFormat:@"%d%@",self.nNextDis,STR(@"Universal_M", Localize_Universal)];
    }
    else
    {
        stringDistance  = [NSString stringWithFormat:@"%0.1f%@",self.nNextDis/1000.0f,STR(@"Universal_KM", Localize_Universal)];
    }
    return stringDistance;
}

- (NSString *)szDescription
{
    if (szDescription == nil)
    {
        return @"";
    }
    return szDescription;
}

- (NSString *)nextLoadName
{
    if ([nextLoadName length] == 0)
    {
        return STR(@"Main_unNameRoad", Localize_Main); //不存在下一道路名，则返回未知道路
    }
    return nextLoadName;
}

- (NSString *)currentLoadName
{
    if ([currentLoadName length] == 0)
    {
        return STR(@"Main_unNameRoad", Localize_Main); //不存在当前道路名，则返回未知道路
    }
    return currentLoadName;
}

@end
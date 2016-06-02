//
//  GDBL_UserBehaviorCountNew.m
//  AutoNavi
//
//  Created by jiangshu.fu on 13-5-27.
//
//

#import "GDBL_UserBehaviorCountNew.h"
#import "ANParamValue.h"
#import "ANDataSource.h"
#import "UMengEventDefine.h"

static GDBL_UserBehaviorCountNew *instance;


@implementation GDBL_UserBehaviorCountNew

@synthesize northUpViewSeconds_InPath,northUpViewSeconds,upViewSeconds_InPath,upViewSeconds,car3DViewSeconds_InPath,car3DViewSeconds,TMCTime;
@synthesize tempFirstStartUp,tempOpenNavigation,openNavigation;
#pragma mark ---  辅助函数  ---

-(BOOL) isPath
{
    int isPath = 0;
    GDBL_GetParam(G_GUIDE_STATUS, &isPath); //无路径下，才播报PCD
    return isPath;
}


+(GDBL_UserBehaviorCountNew *)shareInstance
{
    if (instance == nil) {
        instance  = [[GDBL_UserBehaviorCountNew alloc] init];
        [instance readData];
    }
    return instance;
}

#pragma mark ---  类函数  ---
-(id) init
{
    if(self = [super init]){
        tempFirstStartUp = [[NSString alloc] init];
        tempOpenNavigation = 0;
    }
    return self;
}

-(NSMutableArray *) newArroundArray :(int) count
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (int i = 0; i < count; i++) {
        NSNumber *number = [NSNumber numberWithInt:0];
        [array addObject:number];
    }
    return array;
}

-(void)dealloc
{
    [self saveData];
    
    if ( tempFirstStartUp != nil )
    {
        [tempFirstStartUp release];
        tempFirstStartUp = nil;
    }
    [super dealloc];
}

//读取数据
-(void)readData
{
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:UBCFile_Path];
    if(dic != nil)
    {
        NSNumber *openNavigationN = [dic objectForKey:@"openNavigation"];
        if(openNavigationN != nil)
        {
            self.openNavigation = [openNavigationN intValue];
        }

        NSNumber *northUpViewSeconds_InPathN = [dic objectForKey:@"northUpViewSeconds_InPath"];
        if(northUpViewSeconds_InPathN != nil)
        {
            self.northUpViewSeconds_InPath = [northUpViewSeconds_InPathN intValue];
        }
        NSNumber *northUpViewSecondsN = [dic objectForKey:@"northUpViewSeconds"];
        if(northUpViewSecondsN != nil)
        {
            self.northUpViewSeconds = [northUpViewSecondsN intValue];
        }
        
        NSNumber *upViewSeconds_InPathN = [dic objectForKey:@"upViewSeconds_InPath"];
        if(upViewSeconds_InPathN != nil)
        {
            self.upViewSeconds_InPath = [upViewSeconds_InPathN intValue];
        }
        NSNumber *upViewSecondsN = [dic objectForKey:@"upViewSeconds"];
        if(upViewSecondsN != nil)
        {
            self.upViewSeconds = [upViewSecondsN intValue];
        }
        
        NSNumber *car3DViewSeconds_InPathN = [dic objectForKey:@"car3DViewSeconds_InPath"];
        if(car3DViewSeconds_InPathN != nil)
        {
            self.car3DViewSeconds_InPath = [car3DViewSeconds_InPathN intValue];
        }
        NSNumber *car3DViewSecondsN = [dic objectForKey:@"car3DViewSeconds"];
        if(car3DViewSecondsN != nil)
        {
            self.car3DViewSeconds = [car3DViewSecondsN intValue];
        }
        
        
        NSNumber *TMCTimeN = [dic objectForKey:@"TMCTime"];
        if(TMCTimeN != nil)
        {
            self.TMCTime = [TMCTimeN intValue];
        }
    }
}

//保存数据
-(void)saveData
{
    if(self.tempOpenNavigation != 0)
    {
        self.openNavigation += self.tempOpenNavigation;
        self.tempOpenNavigation = 0;
        
    }
    NSDictionary * dic = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSNumber numberWithInt:self.openNavigation],@"openNavigation",
                          [NSNumber numberWithInt:self.northUpViewSeconds_InPath],@"northUpViewSeconds_InPath",
                          [NSNumber numberWithInt:self.northUpViewSeconds],@"northUpViewSeconds",
                          [NSNumber numberWithInt:self.upViewSeconds_InPath],@"upViewSeconds_InPath",
                          [NSNumber numberWithInt:self.upViewSeconds],@"upViewSeconds",
                          [NSNumber numberWithInt:self.car3DViewSeconds_InPath],@"car3DViewSeconds_InPath",
                          [NSNumber numberWithInt:self.car3DViewSeconds],@"car3DViewSeconds",
                          [NSNumber numberWithInt:self.TMCTime],@"TMCTime",
                          nil];

    [dic writeToFile:UBCFile_Path atomically:YES];
}

//复位
-(void)resetData
{
     self.openNavigation = 0;
    self.northUpViewSeconds_InPath = 0;
    self.northUpViewSeconds = 0;
    self.upViewSeconds_InPath = 0;
    self.upViewSeconds = 0;
    self.car3DViewSeconds_InPath = 0;
    self.car3DViewSeconds = 0;
    self.TMCTime = 0;
    // [self saveData];
}

#pragma mark ---  索引的数组下表变量添加  ----

//---  计时使用的中间变量  ---
//车的视角模式
static int UBnorthUpViewSeconds =0;
static int UBupViewSeconds = 0;
static int UBcar3DViewSeconds = 0;
//使用时长
static int UBDurationOfUseSeconds = 0;
static int UBDurationOfUseBackgroundSeconds = 0;

static int UBNetNaviSeconds_Path           = 0;
//static int UBNetCPCNaviSeconds_Path        = 0;
static int UBHorizontalScreenSeconds_Path  = 0;
static int UBVerticalScreenSeconds_Path    = 0;
static int UB_25_MapSeconds_Path   = 0;
static int UB_50_MapSeconds_Path   = 0;
static int UB_100_MapSeconds_Path  = 0;
static int UB_200_MapSeconds_Path  = 0;
static int UB_500_MapSeconds_Path  = 0;
static int UB_1k_MapSeconds_Path   = 0;
static int UB_2k_MapSeconds_Path   = 0;
static int UB_5k_MapSeconds_Path   = 0;
static int UB_10k_MapSeconds_Path  = 0;
static int UB_50k_MapSeconds_Path  = 0;
static int UB_200k_MapSeconds_Path = 0;
static int UB_500k_MapSeconds_Path = 0;
static int UBnorthUpViewSeconds_Path = 0;
static int UBupViewSeconds_Path = 0;
static int UBcar3DViewSeconds_Path = 0;
static int UBDurationOfUseSeconds_Path = 0;
static int UBDurationOfUseBackgroundSeconds_Path = 0;

//---  定时器定时调用的函数  ---
-(void) timeCountAction
{
    
    if([self isPath])
    {
        //车辆视图分别使用时长
        [self mapViewModePathAdd];
    }
    else
    {
        [self mapViewModeAdd];
    }
    [self TMCTimeTotal];
}

//---  定时器定时调用  ---
-(void)timeCount
{
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeCountAction) userInfo:nil repeats:YES];
}

#pragma mark ---  辅助函数  ---

//---  地图的三种视图模式的时间统计  ---
-(void) mapViewModePathAdd
{
    GMAPVIEWMODE eMapViewMode;
    GDBL_GetParam(G_MAP_VIEW_MODE, &eMapViewMode);
    switch (eMapViewMode) {
        case GMAPVIEW_MODE_NORTH:
        {
            UBnorthUpViewSeconds_Path++;
            if (UBnorthUpViewSeconds_Path >= 60) {
                self.northUpViewSeconds_InPath++;
                UBnorthUpViewSeconds_Path = 0;
            }
        }
            break;
        case GMAPVIEW_MODE_CAR:
        {
            UBupViewSeconds_Path++;
            if(UBupViewSeconds_Path >= 60){
                self.upViewSeconds_InPath++;
                UBupViewSeconds_Path = 0;
            }
        }
            break;
        case GMAPVIEW_MODE_3D:
        {
            UBcar3DViewSeconds_Path++;
            if(UBcar3DViewSeconds_Path >= 60)
            {
                self.car3DViewSeconds_InPath++;
                UBcar3DViewSeconds_Path = 0;
            }
        }
            break;
        default:
            break;
    }
}

-(void) mapViewModeAdd
{
    GMAPVIEWMODE eMapViewMode;
    GDBL_GetParam(G_MAP_VIEW_MODE, &eMapViewMode);
    switch (eMapViewMode) {
        case GMAPVIEW_MODE_NORTH:
        {
            UBnorthUpViewSeconds++;
            if (UBnorthUpViewSeconds >= 60) {
                self.northUpViewSeconds++;
                UBnorthUpViewSeconds = 0;
            }
        }
            break;
        case GMAPVIEW_MODE_CAR:
        {
            UBupViewSeconds++;
            if(UBupViewSeconds >= 60){
                self.upViewSeconds++;
                UBupViewSeconds = 0;
            }
        }
            break;
        case GMAPVIEW_MODE_3D:
        {
            UBcar3DViewSeconds++;
            if(UBcar3DViewSeconds >= 60)
            {
                self.car3DViewSeconds++;
                UBcar3DViewSeconds = 0;
            }
        }
            break;
        default:
            break;
    }
}

- (void) TMCTimeTotal
{
    if([MWEngineSwitch isTMCOn])
    {
        TMCTime++;
    }
}
@end

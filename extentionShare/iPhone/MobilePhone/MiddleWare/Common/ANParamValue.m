//
//  ANParamValue.m
//  AutoNavi
//
//  Created by GHY on 12-4-19.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "ANOperateMethod.h"
#import "ANParamValue.h"
#import "MWTTS.h"
#import  "GDBL_Account.h"
#import "MWMapAddIconOperator.h"
#import "plugin-cdm-TaskManager.h"
#import "NSString+Category.h"
#import "GDBL_DataVerify.h"
#import "MWPreference.h"
#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCall.h>
#import "UMengEventDefine.h"
#import "DringTracksManage.h"


static ANParamValue *sharedANParamValue = nil;
int isEngineInit = 0;      //引擎是否初始化成功:0失败  1成功

@implementation ANParamValue


@synthesize isInit,isMove,isPath,isSafe,isNavi,total_byte,current_byte,nSpeed,eCategory,FavEditFlag,searchMapInfo,addHistory,isDriveComputer,isHud,busEndingPoint,navEndingPoint,scaleFactor,isSelectCity,startCoord,desCoord,bSupportAutorate,beFirstNewFun,beFirstDown,isReq95190Des,isMainViewController,new_fun_flag,isTMCRequest,isParseFinish,smsCoord,thirdPartDesPOI,palellerRoadPOI,isWarningView,skinType,isStartUpNeedShowView,isRequestParking,isHistoryRouteClick;


#pragma mark 单例
+ (ANParamValue *)sharedInstance {
	
	if (nil==sharedANParamValue)
	{
		sharedANParamValue = [[ANParamValue alloc] init];
	}
	return sharedANParamValue;
}

- (id)init {
	
	self = [super init];
	if (self)
	{
        if ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)])
        {
            scaleFactor = (int)[[UIScreen mainScreen] scale];
        }
        else
        {
            scaleFactor = 1;
        }
		isMove = NO;
		isInit = NO;
		isSafe = NO;
		isPath = NO;
        isReq95190Des = 0;
        //默认开启网络功能后台开关


        self.isRequestParking = 1;

       
        addHistory = NO;
        isDriveComputer = NO;
        isMainViewController = YES;
        //默认皮肤的类型为0
        skinType = 0;
        
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(listenNotification:) name:NOTIFY_TOUCH object:nil];//主地图点击响应消息，点击后开始计时，时间到隐藏相应的按钮
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(listenNotification:) name:NOTIFY_MOVEMAP object:nil];//移图响应消息，主要用于回车位，设起点，设终点的按钮显示，隐藏
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(listenNotification:) name:NOTIFY_GOTOCPP object:nil];//回车位消息响应，显示隐藏相应的按钮
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(listenNotification:) name:NOTIFY_BEGINPOINT object:nil];//设起点消息响应，显示隐藏相应的按钮
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(listenNotification:) name:NOTIFY_ENDINGPOINT object:nil];//设终点消息响应，显示隐藏相应的按钮
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(listenNotification:) name:NOTIFY_STARTTODEMO object:nil];//模拟导航路线演算成功回调，
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(listenNotification:) name:NOTIFY_STARTTODEMO2 object:nil];//导航路线演算回调
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(listenNotification:) name:NOTIFY_STARTGUIDANCE object:nil];//开始路线演算
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(listenNotification:) name:NOTIFY_STOPGUIDANCE object:nil];//停止路线演算
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(listenNotification:) name:NOTIFY_INSIMULATION object:nil];//模拟导航中
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(listenNotification:) name:NOTIFY_EXSIMULATION object:nil];//退出模拟导航
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(listenNotification:) name:NOTIFY_NO_PATH object:nil];//退出模拟导航
	}
	return self;
}

#pragma mark 主界面状态监听
- (void)listenNotification:(NSNotification *)notification {
	
	NSString *notificationInfo;
	
	if ([notification.name isEqual:NOTIFY_TOUCH])
	{
		BOOL value = [(NSNumber *)[notification object] boolValue];
		isSafe = value;
		
		notificationInfo = @"NHV";
	}
    
	if ([notification.name isEqual:NOTIFY_MOVEMAP])
	{
		isMove = YES;
		notificationInfo = @"NHV";
	}
	
	if ([notification.name isEqual:NOTIFY_GOTOCPP])
	{
		isMove = NO;
		notificationInfo = @"NHV";
	}
    
	if ([notification.name isEqual:NOTIFY_STARTTODEMO] || [notification.name isEqual:NOTIFY_STARTTODEMO2])
	{
		NSArray *result = [notification object];
		if ([[result objectAtIndex:1] intValue] == 0)
		{
            isMove = NO;

            //友盟偏航次数统计上传
            if (([notification.name isEqual:NOTIFY_STARTTODEMO] && ([[result objectAtIndex:0] intValue] == 0)) || [notification.name isEqual:NOTIFY_STARTTODEMO2])
            {
                NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
                if([ud objectForKey:USERDEFAULT_LoaclRecalculationRoute])
                {
                    [ud setObject:[NSNumber numberWithInt:0] forKey:USERDEFAULT_LoaclRecalculationRoute];
                }
                
                int routeRecalCount = [[ud objectForKey:USERDEFAULT_LoaclRecalculationRoute] intValue];
               

                if (routeRecalCount > 0){
                    [UMengStatistics recalculationCount:routeRecalCount];
                    [ud setObject:[NSNumber numberWithInt:0] forKey:USERDEFAULT_LoaclRecalculationRoute];
                }
                
                if (!isPath)
                {
                    [[DringTracksManage sharedInstance] drivingTrackCalculateWithNewLocation:nil oldLocation:nil andType:TrackCountType_Start];
                }
                
            }
            
            if (([notification.name isEqual:NOTIFY_STARTTODEMO] && ([[result objectAtIndex:0] intValue] != 2 ) && ([[result objectAtIndex:0] intValue] != 7 )) || [notification.name isEqual:NOTIFY_STARTTODEMO2])
            {
                if (!isPath)
                {
                    [[DringTracksManage sharedInstance] drivingTrackCalculateWithNewLocation:nil oldLocation:nil andType:TrackCountType_Start];
                }
                
            }
            
            isPath = YES;
		}
		else
		{
			isPath = NO;
            isHistoryRouteClick = 0;
		}
        
		notificationInfo = @"YHV";
        return;
	}
    
	if ([notification.name isEqual:NOTIFY_STOPGUIDANCE])
	{
		isNavi = NO;
		isPath = NO;
		isMove = NO;
		notificationInfo = @"YHV_1";
	}
    
	if ([notification.name isEqual:NOTIFY_INSIMULATION])
	{
		isMove = NO;
		isNavi = YES;
		isPath = YES;
		notificationInfo = @"YHV";
	}
    
	if ([notification.name isEqual:NOTIFY_BEGINPOINT])
	{
		isPath = NO;
		isMove = NO;
		notificationInfo = @"YHV";
	}
	
	if ([notification.name isEqual:NOTIFY_EXSIMULATION])
	{
		isNavi = NO;
		isMove = NO;
		notificationInfo = @"NHV";
	}
	
	if ([notification.name isEqual:NOTIFY_STARTGUIDANCE])
	{
		isMove = NO;
		isNavi = NO;
		isPath = YES;
		      
//        int value = 1;
//        GDBL_SetParam(G_FUNCTION_SUPPORT_PCD, &value);
        
		notificationInfo = @"YHV";
	}
    
    if ([notification.name isEqual:NOTIFY_NO_PATH])
	{
		isPath = NO;
		
		notificationInfo = @"YHV";
	}
	[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_VIEWCONDITION object:nil userInfo:
	 [NSDictionary dictionaryWithObject:notificationInfo forKey:@"ISHV"]];notificationInfo = nil;
}

#pragma mark 获取主界面状态组合
- (int)GMD_GetViewConditon {
	
	return (isMove*1000 + isPath*100 + isSafe*10 +isNavi);
}


#pragma mark 主地图（更多按钮）new图标是否显示
- (BOOL) GMD_isMoreNew
{
    return NO;
}

@end

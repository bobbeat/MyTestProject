//
//  MWEngineSwitch.m
//  AutoNavi
//
//  Created by gaozhimin on 14-7-10.
//
//

#import "MWEngineSwitch.h"
#import "MWMapOperator.h"
#import "UMengStatistics.h"
#import "QLoadingView.h"
#import <AudioToolbox/AudioToolbox.h>

static BOOL g_bTipMessage = NO;

@implementation MWEngineSwitch

/**
 **********************************************************************
 \brief 开启实时交通
 \parm bTip 是否有提示
 \details 开启实时交通
 **********************************************************************/
+ (GSTATUS)OpenTMCWithTip:(BOOL)bTip
{
    g_bTipMessage = bTip;
    [MWEngineSwitch sharedInstance];
    int value = 1;
    GSTATUS res = GDBL_SetParam(G_MAP_SHOW_TMC, &value);
    if (res == GD_ERR_OK)
    {
        [ANParamValue sharedInstance].isTMCRequest = YES;
    }
    else
    {
        int value = 0;
        GDBL_SetParam(G_MAP_SHOW_TMC, &value);
        [QLoadingView showAlertWithoutClick:STR(@"Universal_CurrentCityNoData", Localize_Universal) ShowTime:2.0];
        return res;
    }
    [[MWPreference sharedInstance]  setValue:PREF_REALTIME_TRAFFIC Value:[MWEngineSwitch isTMCOn]];
    GMAPVIEW pMapview;
    GDBL_GetMapView(&pMapview);
    if (pMapview.eViewType != GMAP_VIEW_TYPE_MANEUVER_POINT) //节点详情查看，开启关闭tmc时不刷图。否则会回到车位
    {
        [[MWMapOperator sharedInstance] MW_ShowMapView:pMapview.eViewType WithParma1:0 WithParma2:0 WithParma3:0];
    }
    [UMengStatistics trafficTimeBucket];
    return GD_ERR_OK;
}


/**
 **********************************************************************
 \brief 开启实时交通
 \details 开启实时交通
 **********************************************************************/
+ (void)CloseTMC
{
    int value = 0;
    GSTATUS res = GDBL_SetParam(G_MAP_SHOW_TMC, &value);
    if (res == GD_ERR_OK)
    {
        [ANParamValue sharedInstance].isTMCRequest = NO;    //modify by gzm for 关闭实时交通，把正在请求TMC标志置为NO，防止开启不了TMC at 2014-7-29
    }
    GMAPVIEW pMapview;
    GDBL_GetMapView(&pMapview);
    if (pMapview.eViewType != GMAP_VIEW_TYPE_MANEUVER_POINT) //节点详情查看，开启关闭tmc时不刷图。否则会回到车位
    {
        [[MWMapOperator sharedInstance] MW_ShowMapView:pMapview.eViewType WithParma1:0 WithParma2:0 WithParma3:0];
    }
    [[MWPreference sharedInstance]  setValue:PREF_REALTIME_TRAFFIC Value:[MWEngineSwitch isTMCOn]];
    
}

/**
 **********************************************************************
 \brief TMC是否开启
 \details TMC是否开启
 **********************************************************************/
+ (BOOL)isTMCOn
{
    int value = 0;
    GDBL_GetParam(G_MAP_SHOW_TMC, &value);
    return value;
}

/**
 **********************************************************************
 \brief 切换色盘
 \details 切换色盘
 **********************************************************************/
+ (void)switchTheme:(double)x withy:(double)y  withz:(double)z
{
    UIWindow *window = [[UIApplication sharedApplication].windows objectAtIndex:0];
    UINavigationController *ctl = (UINavigationController *)[window rootViewController];
    if (ctl.topViewController !=ctl.visibleViewController || ![[MWPreference sharedInstance] getValue:PREF_SHAKETOCHANGETHEME] )
    {
		return;
	}
    if (fabs(x) > 1.5 || fabs(y) > 1.5 || fabs(z) > 1.5)
    {
		AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        
		GMAPDAYNIGHTMODE eMapDayNightMode = {0};
		GDBL_GetParam(G_MAP_DAYNIGHT_MODE, &eMapDayNightMode);
		if (eMapDayNightMode == GMAP_DAYNIGHT_MODE_DAY) {
			//设置白天色盘
			GPALETTE DayPalette = {0};
			GDBL_GetParam(G_DAY_PALETTE_INDEX,&DayPalette);
            GPALETTELIST *dayPalette;
            GDBL_GetPaletteList(Gtrue,&dayPalette);
			if (DayPalette.nPaletteID == dayPalette->nNumberOfPalette - 1) {
				DayPalette.nPaletteID = 0;
                GDBL_SetParam(G_NIGHT_PALETTE_INDEX,&DayPalette.nPaletteID);
				GDBL_SetParam(G_DAY_PALETTE_INDEX,&DayPalette.nPaletteID);
                
                
                
			}
			else {
				DayPalette.nPaletteID = DayPalette.nPaletteID + 1;
                GDBL_SetParam(G_NIGHT_PALETTE_INDEX,&DayPalette.nPaletteID);
				GDBL_SetParam(G_DAY_PALETTE_INDEX,&DayPalette.nPaletteID);
                
                
			}
		}
		else if(eMapDayNightMode == GMAP_DAYNIGHT_MODE_NIGHT){
			//设置夜晚色盘
			GPALETTE NightPalette = {0};
			GDBL_GetParam(G_NIGHT_PALETTE_INDEX,&NightPalette);
            GPALETTELIST *nightPalette;
            GDBL_GetPaletteList(Gfalse,&nightPalette);
			if (NightPalette.nPaletteID == nightPalette->nNumberOfPalette - 1) {
				NightPalette.nPaletteID = 0;
                GDBL_SetParam(G_DAY_PALETTE_INDEX,&NightPalette.nPaletteID);
				GDBL_SetParam(G_NIGHT_PALETTE_INDEX,&NightPalette.nPaletteID);
                
                
			}
			else {
				NightPalette.nPaletteID = NightPalette.nPaletteID +1;
                GDBL_SetParam(G_DAY_PALETTE_INDEX,&NightPalette.nPaletteID);
				GDBL_SetParam(G_NIGHT_PALETTE_INDEX,&NightPalette.nPaletteID);
                
                
			}
		}
		else if(eMapDayNightMode == GMAP_DAYNIGHT_MODE_AUTO){
            
            GMAPDAYNIGHTMODE dayNight = {0};
			GDBL_GetParam(G_AUTO_MODE_DAYNIGHT, &dayNight);
            if (dayNight == GMAP_DAYNIGHT_MODE_DAY) {
                //设置白天色盘
                GPALETTE DayPalette = {0};
                GDBL_GetParam(G_DAY_PALETTE_INDEX,&DayPalette);
                GPALETTELIST *dayPalette;
                GDBL_GetPaletteList(Gtrue,&dayPalette);
                if (DayPalette.nPaletteID == dayPalette->nNumberOfPalette - 1) {
                    DayPalette.nPaletteID = 0;
                    GDBL_SetParam(G_NIGHT_PALETTE_INDEX,&DayPalette.nPaletteID);
                    GDBL_SetParam(G_DAY_PALETTE_INDEX,&DayPalette.nPaletteID);
                    
                    
                }
                else {
                    DayPalette.nPaletteID = DayPalette.nPaletteID + 1;
                    GDBL_SetParam(G_NIGHT_PALETTE_INDEX,&DayPalette.nPaletteID);
                    GDBL_SetParam(G_DAY_PALETTE_INDEX,&DayPalette.nPaletteID);
                    
                    
                }
            }
            else if(dayNight == GMAP_DAYNIGHT_MODE_NIGHT)
            {
                //设置夜晚色盘
                GPALETTE NightPalette = {0};
                GDBL_GetParam(G_NIGHT_PALETTE_INDEX,&NightPalette);
                GPALETTELIST *nightPalette;
                GDBL_GetPaletteList(Gfalse,&nightPalette);
                if (NightPalette.nPaletteID == nightPalette->nNumberOfPalette - 1) {
                    NightPalette.nPaletteID = 0;
                    GDBL_SetParam(G_DAY_PALETTE_INDEX,&NightPalette.nPaletteID);
                    GDBL_SetParam(G_NIGHT_PALETTE_INDEX,&NightPalette.nPaletteID);
                    
                    
                }
                else {
                    NightPalette.nPaletteID = NightPalette.nPaletteID +1;
                    GDBL_SetParam(G_DAY_PALETTE_INDEX,&NightPalette.nPaletteID);
                    GDBL_SetParam(G_NIGHT_PALETTE_INDEX,&NightPalette.nPaletteID);
                    
                    
                }
            }
		}
        
        if([[MWPreference sharedInstance] getValue:PREF_MAPDAYNIGHTMODE] == GMAP_DAYNIGHT_MODE_AUTO)
        {
            [[MWPreference sharedInstance] setValue:PREF_MAPDAYNIGHTMODE Value:GMAP_DAYNIGHT_MODE_AUTO];
        }
        
		[[MWMapOperator sharedInstance] MW_ShowMapView:GMAP_VIEW_TYPE_MAIN WithParma1:0 WithParma2:0 WithParma3:0];
    }
}

/*
 * @brief: 关闭plainmapmode
 */
+(BOOL)ClosePlainMap
{
    if (NO == [[ANParamValue sharedInstance] isInit])
    {
        return NO;
    }
    Gbool status= Gtrue;
	GDBL_SetParam(G_MAP_SHOW_CURSOR, &status);
    Gbool showPlain = Gfalse;
    GDBL_SetParam(G_MAP_SHOW_PLAIN_MODE, &showPlain);
    return YES;
}
#pragma mark -
#pragma mark private method

/*
 * @brief: 初始化监听类
 */
+ (MWEngineSwitch *)sharedInstance
{
    static MWEngineSwitch *engineSwitch = nil;
    if (engineSwitch == nil)
    {
        engineSwitch = [[MWEngineSwitch alloc] init];
    }
    return engineSwitch;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotify:) name:NOTIFY_TMCUPDATE_NOTIFY object:nil];
    }
    return self;
}

#pragma mark -
#pragma mark notify method
- (void)receiveNotify:(NSNotification *)notify
{
    if ([[notify name] isEqualToString:NOTIFY_TMCUPDATE_NOTIFY])
    {
        //判断实时交通是否开启成功，默认是开启失败。
        NSString *keyString = NOTIFY_USERINFO_TMC_OPEN;
        NSMutableDictionary *userInfoIsSuccess = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]
                                                                                    forKey:keyString];
        if (g_bTipMessage)  //是否提示tmc显示不成功的信息
        {
            g_bTipMessage = NO;
            NSArray* param = [notify object];
            if ([param count] == 2)
            {
                GSTATUS res = [[param objectAtIndex:1] intValue];
                if (res == GD_ERR_OK || res == 10020) //10020为时间间隔太短
                {
                    //                GDBL_TMCUpdate();
                    [userInfoIsSuccess setObject:[NSNumber numberWithBool: YES] forKey:keyString];
                    [QLoadingView hideWithAnimated:NO];
                }
                else if (res == 10025) //该城市不支持实时交通
                {
                    int value = 0;
                    GDBL_SetParam(G_MAP_SHOW_TMC, &value);
                    [QLoadingView showAlertWithoutClick:STR(@"Universal_CurrentCityNoData", Localize_Universal) ShowTime:2.0];
                }
                else if (res == 1)   //无网络
                {
                    [QLoadingView showAlertWithoutClick:STR(@"Universal_tmc_networkError", Localize_Universal) ShowTime:2.0];
                    int value = 0;
                    GDBL_SetParam(G_MAP_SHOW_TMC, &value);
                }
                else if (res == 3)   //无网络超时
                {
                    [QLoadingView showAlertWithoutClick:STR(@"Universal_tmc_networkTimeout", Localize_Universal) ShowTime:2.0];
                    int value = 0;
                    GDBL_SetParam(G_MAP_SHOW_TMC, &value);
                }
                else if (res != 4)   //4为用户手动打断
                {
                    int value = 0;
                    GDBL_SetParam(G_MAP_SHOW_TMC, &value);
                    [QLoadingView showAlertWithoutClick:STR(@"Universal_TMCNetError", Localize_Universal) ShowTime:2.0];
                }
            }
        }
        [ANParamValue sharedInstance].isTMCRequest = NO;
        [[MWPreference sharedInstance]  setValue:PREF_REALTIME_TRAFFIC Value:[MWEngineSwitch isTMCOn]];
        GMAPVIEW pMapview;
        GDBL_GetMapView(&pMapview);
        [[MWMapOperator sharedInstance] MW_ShowMapView:pMapview.eViewType WithParma1:0 WithParma2:0 WithParma3:0];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_HandleUIUpdate object:[NSNumber numberWithInt:UIUpdate_TMC] userInfo:userInfoIsSuccess];
    }
    
}

@end

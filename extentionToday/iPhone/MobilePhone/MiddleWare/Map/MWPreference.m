//
//  MWPreference.m
//  AutoNavi
//
//  Created by yu.liao on 13-7-29.
//
//

#import "MWPreference.h"
#import "MWTTS.h"
#import "ANParamValue.h"
#import "ANOperateMethod.h"
#import "GDBL_DataVerify.h"
#import "MWMapOperator.h"
#import "MWSkinDownloadManager.h"
#import "MWDialectDownloadManage.h"
#import "GDCacheManager.h"
#import "MWCarOwnerServiceManage.h"
#import "MWCloudDetourManage.h"

static MWPreference* instance = nil;


@interface MWPreference()
{
}

@property (nonatomic,setter = setBackgroundNavi:) BOOL backgroundNavi;//后台导航开关

@end

@implementation MWPreference

@synthesize  mapVersion = _mapVersion, deviceToken = _deviceToken;

+(MWPreference*)sharedInstance
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
    if(self!=nil)
    {
        
    }
	
    return self;
}
#pragma mark -
#pragma mark public Method

-(BOOL)loadPreference
{
    static BOOL st_bReadData = FALSE;
    if(FALSE == st_bReadData)
    {
        st_bReadData = TRUE;
    }
    else if(TRUE == st_bReadData)
    {
        return YES;
    }
    //参数读取－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:preferenceFilePath]){
        
        [self readPreference];//读取参数
        
        if(fabs(SOFTVERSIONNUM-_softVersion)>0.01f)
        {
            [self preferenceHandle:HANDLE_UPDATE];//版本升级参数设置
            
        }
        [[MWTTS SharedInstance] SetTTSRole:_ttsRoleIndex];
    }
    else{
        [self preferenceHandle:HANDLE_INIT];//初始化
    }

    return YES;
}

-(BOOL)savePreference
{
    NSMutableDictionary *prefDic = [[NSMutableDictionary alloc] init];
    [prefDic setValue:[NSNumber numberWithFloat:_softVersion] forKey:@"_softVersion"];
    [prefDic setValue:[NSNumber numberWithBool:_startupWarning] forKey:@"_startupWarning"];
    [prefDic setValue:[NSNumber numberWithBool:_newFunIntroduce] forKey:@"_newFunIntroduce"];
    [prefDic setValue:[NSNumber numberWithBool:_shakeToChangeTheme] forKey:@"_shakeToChangeTheme"];
    [prefDic setValue:[NSNumber numberWithBool:_interfaceState] forKey:@"_interfaceState"];
    [prefDic setValue:[NSNumber numberWithBool:_parkingInfo] forKey:@"_parkingInfo"];
    [prefDic setValue:[NSNumber numberWithInt:_interfaceOrientation] forKey:@"_interfaceOrientation"];
    [prefDic setValue:[NSNumber numberWithBool:_mapDataUpdateReminder] forKey:@"_mapDataUpdateReminder"];
    [prefDic setValue:[NSNumber numberWithInt:_ttsRoleIndex] forKey:@"_ttsRoleIndex"];
    [prefDic setValue:[NSNumber numberWithInt:_UILanguage] forKey:@"_UILanguage"];
    [prefDic setValue:[NSNumber numberWithBool:_travelUpdate] forKey:@"_travelUpdate"];
    [prefDic setValue:[NSNumber numberWithBool:_setLanguageManually] forKey:@"_setLanguageManually"];
    [prefDic setValue:[NSNumber numberWithBool:_set95190] forKey:@"_set95190"];
    [prefDic setValue:[NSNumber numberWithBool:_speakTraffic] forKey:@"_speakTraffic"];
    [prefDic setValue:[NSNumber numberWithBool:_trafficMessage] forKey:@"_trafficMessage"];
    [prefDic setValue:[NSNumber numberWithInt:_PSCountOfUnread] forKey:@"_PSCountOfUnread"];
    [prefDic setValue:[NSNumber numberWithBool:_PSNewCustomerServicePrompt] forKey:@"_PSNewCustomerServicePrompt"];
    [prefDic setValue:[NSNumber numberWithBool:_trafficEvent] forKey:@"_trafficEvent"];
    [prefDic setValue:[NSNumber numberWithBool:_firstStart] forKey:@"_firstStart"];
    [prefDic setValue:[NSNumber numberWithBool:_backgroundDownload] forKey:@"_backgroundDownload"];
    [prefDic setValue:[NSNumber numberWithBool:_realTimeTraffic] forKey:@"_realTimeTraffic"];
    [prefDic setValue:[NSNumber numberWithBool:_HUDDisplayOrientation] forKey:@"_HUDDisplayOrientation"];
    [prefDic setValue:[NSNumber numberWithBool:_autoGetPOIInfo] forKey:@"_autoGetPOIInfo"];
    [prefDic setValue:[NSNumber numberWithBool:_isFirstEnterSkin] forKey:@"_isFirstEnterSkin"];
    [prefDic setValue:[NSNumber numberWithInt:_skinType] forKey:@"_skinType"];
    [prefDic setValue:self.deviceToken forKey:@"_deviceToken"];
    [prefDic setValue:self.mapVersion forKey:@"_mapVersion"];
    [prefDic setValue:[NSNumber numberWithBool:_isOldUser] forKey:@"_isOldUser"];
    [prefDic setValue:[NSNumber numberWithInt:_nextHightPraiseCount] forKey:@"_nextHightPraiseCount"];
    [prefDic setValue:[NSNumber numberWithBool:_switchedVoice] forKey:@"_switchedVoice"];
    [prefDic setValue:[NSNumber numberWithBool:_isPowerVoicePlay] forKey:@"_isPowerVoicePlay"];
    [prefDic setValue:[NSNumber numberWithInt:_powerVoiceID] forKey:@"_powerVoiceID"];
    [prefDic setValue:[NSNumber numberWithInt:_isLZLDialect] forKey:@"_isLZLDialect"];
    [prefDic setValue:[NSNumber numberWithBool:_searchType] forKey:@"_searchType"];
    [prefDic setValue:[NSNumber numberWithBool:_autoDrivingTrack] forKey:@"_autoDrivingTrack"];
    [prefDic setValue:[NSNumber numberWithBool:_backgroundNavi] forKey:@"_backgroundNavi"];
    [prefDic setValue:[NSNumber numberWithInt:_autoZoom] forKey:@"_autoZoom"];
    
    [prefDic writeToFile:preferenceFilePath atomically:YES];
    [prefDic release];
    return YES;
}

-(int)getValue:(PRETYPE)type
{
    int value = -1;
    switch (type)
	{
		case PREF_UILANGUAGE://获取地图语言模式
		{
            value = _UILanguage;
		}
			break;
		case PREF_FONTSIZE://获取地图字体大小
		{
			Gint32 MapFontSize;
			if (GD_ERR_OK == GDBL_GetParam(G_MAP_FONT_SIZE, &MapFontSize))
		    {
				if (MapFontSize == GMAP_FONT_SIZE_BIG)
                {
					value = 0;
                }
				else if (MapFontSize == GMAP_FONT_SIZE_NORMAL)
                {
					value = 1;
                }
				else if (MapFontSize == GMAP_FONT_SIZE_SMALL)
                {
					value = 2;
                }
				else
                {
					value = 1;
                }
				
			}
		}
			break;
			
		case PREF_MAPVIEWMODE://获取地图模式
		{
			GMAPVIEWMODE eMapViewMode;
			GDBL_GetParam(G_MAP_VIEW_MODE, &eMapViewMode);
			value = (int)eMapViewMode;
		}
			break;
			
		case PREF_POIDENSITY://获取地图详细度
		{
			GMAPPOIDENSITY eMapPoiDensity;
			GDBL_GetParam(G_MAP_POI_DENSITY, &eMapPoiDensity);
			value = (int)eMapPoiDensity;
		}
			break;
			
		case PREF_MAPDAYNIGHTMODE://获取昼夜模式
		{
			GMAPDAYNIGHTMODE eMapDayNightMode;
			GDBL_GetParam(G_MAP_DAYNIGHT_MODE, &eMapDayNightMode);
			value = (int)eMapDayNightMode;
		}
			break;
			
		case PREF_TTSROLEINDEX://获取语言选择
		{
            _ttsRoleIndex = [[MWTTS SharedInstance] GetTTSRole];
            value = _ttsRoleIndex;
		}
			break;
		case PREF_PROMPTOPTION://获取语音频率
		{
			GPROMPTOPTION ePromptOption;
			GDBL_GetParam(G_PROMPT_OPTION, &ePromptOption);
			value = (int)ePromptOption;
		}
			break;
		
		case PREF_MAPPOIPRIORITY://获取优先模式
		{
			
			GMAPPOIPRIORITY eMapPoiPriority;
			GDBL_GetParam(G_MAP_POI_PRIORITY, &eMapPoiPriority);
			value = (int)eMapPoiPriority;
		}
			break;
        case PREF_BACKGROUND_MODE://后台
        {
            GDBL_GetParam(G_BACKGROUND_MODE, &value);
        }
            break;
        case PREF_MAPSHOWCURSOR://移图游标
        {
            GDBL_GetParam(G_MAP_SHOW_CURSOR, &value);
        }
			break;
        case PREF_DEMO_SPEED://模拟导航速度
        {
            int eDemoSpeed = 0;
            GDBL_GetParam(G_DEMO_SPEED, &eDemoSpeed);
            value = eDemoSpeed;
        }
            break;
        case PREF_MAP_SHOW_GUIDEPOST://高速路牌显示
        {
            GDBL_GetParam(G_MAP_SHOW_GUIDEPOST, &value);
        }
            break;
        case PREF_SHOW_SAFETY_ICON://是否显示电子狗图标
        {
//            GDBL_GetParam(G_SHOW_SAFETY_ICON, &value);
        }
            break;
        case PREF_SHOW_MAP_GRAY_BKGND://实时交通显示灰色地图
        {
            GDBL_GetParam(G_SHOW_MAP_GRAY_BKGND, &value);
        }
            break;
        case PREF_MAP_TMC_SHOW_OPTION://控制是城市TMC还是路径线TMC
        {
            GDBL_GetParam(G_MAP_TMC_SHOW_OPTION, &value);
        }
            break;
		case PREF_ROUTE_OPTION:
		{//获取路径规划原则
            GROUTEOPTION routeRule;
            GDBL_GetParam(G_ROUTE_OPTION, &routeRule);
			value = routeRule;
		}
			break;
        case PREF_DISABLE_GPS://GPS开关
		{
            int bReceiveGPS;
            GDBL_GetParam(G_DISABLE_GPS, &bReceiveGPS);
			value = bReceiveGPS;
            if (value == 1)
            {
                value = 0;
            }
            else  if (value == 0)
            {
                value = 1;
            }
		}
			break;
		case PREF_TRACK_RECORD://自动记录轨迹开关
		{
            int useTrack;
            GDBL_GetParam(G_TRACK_RECORD, &useTrack);
			value = useTrack;
		}
			break;
		case PREF_MAP_CONTENT://街区图开关
		{
            int useStreet;
            GDBL_GetParam(G_MAP_CONTENT, &useStreet);
			value = useStreet;
		}
			break;
		case PREF_MUTE://语音提示开关
		{
            int bMute;
            GDBL_GetParam(G_MUTE , &bMute);
            value = bMute;
            if (value == 1)
            {
                value = 0;
            }
            else  if (value == 0)
            {
                value = 1;
            }
		}
			break;
        case PREF_DISABLE_ECOMPASS://电子罗盘开关
		{
            int e_compass = value;
            GDBL_GetParam(G_DISABLE_ECOMPASS, &e_compass);
            value = e_compass;
            if (value == 1)
            {
                value = 0;
            }
            else  if (value == 0)
            {
                value = 1;
            } 
		}
			break;
        case PREF_SPEAK_SAFETY://电子眼播报开关
        {
            //modify by gzm for 引擎中已没有电子眼播报开关，只能单独控制播报，包括GSAFESPEEDLIMITSPEAK，GSAFECAMERASPEAK GSAFEDANGERWARNSPEAK 三种类型摄像头 获取状态时只要获取一种即可以判断是否开启电子眼播报 at 2014-7-29
            int temp = 0;
            GDBL_GetParam(G_SAFETY_INFORMATION, &temp);
            GSAFESPEEDLIMITSPEAK limitSpeak = GSAFE_SPEEDLIMITSPEAK_ALL;
            GDBL_GetParam(G_SAFE_SPEEDLIMITSPEAK,&limitSpeak);
            if (limitSpeak == GSAFE_SPEEDLIMITSPEAK_ALL)
            {
                value = 1;
            }
            else
            {
                value = 0;
            }
        }
            break;
        case PREF_SHOW_TMCEVENT://事件图标开关
        {
            GDBL_GetParam(G_SHOW_TMCEVENT, &value);
        }
            break;
        case PREF_DAYNIGHTMODE:
        {
            GDBL_GetParam(G_AUTO_MODE_DAYNIGHT, &value);
        }
            break;
		case PREF_NEWFUNINTRODUCE://开机新功能是否已经查看标志
		{
			return _newFunIntroduce;
		}
			break;
		case PREF_SHAKETOCHANGETHEME://摇晃切换地图配色开关
		{
			return _shakeToChangeTheme;
		}
			break;
		case PREF_STARTUPWARNING://警告提示开关
		{
			return _startupWarning;
		}
			break;
		case PREF_INTERFACESTATE://横竖屏开关
		{
			return _interfaceState;
		}
			break;
        case PREF_PARKINGINFO://目的地停车场
        {
            return _parkingInfo;
        }
            break;
		case PREF_INTEFACEORIENTATION://界面方向
		{
			return _interfaceOrientation;
		}
			break;
        case PREF_TRAVELUPDATE://数据界面是否显示更新按钮
		{
			return _travelUpdate;
		}
			break;
        case PREF_SPEAKTRAFFIC://路况播报
        {
            return _speakTraffic;
        }
            break;
        case PREF_TRAFFICMESSAGE://路况信息条
        {
            return _trafficMessage;
        }
            break;
        case PREF_SET95190://是否开启95190
        {
            return _set95190;
        }
            break;
        case PREF_FIRSTSTART://第一次进入
        {
            
            return _firstStart;
            
        }
            break;
        case PREF_BACKGROUNDDOWNLOAD://后台下载开关
        {
            
            return _backgroundDownload;
            
        }
            break;
        case PREF_SETLANGUAGEMANUALLY://手动设置了导航语言
        {
            return _setLanguageManually;
        }
            break;
        case PREF_REALTIME_TRAFFIC://实时交通开关
        {
            return _realTimeTraffic;
        }
            break;
        case PREF_HUD_DISPLAYORIENTATION://HUD图面显示方向
        {
            return _HUDDisplayOrientation;
        }
            break;
        case PREF_AUTO_GETPOIINFO:
        {
            return _autoGetPOIInfo;
        }
            break;
        case PREF_IS_FIRSTENTERSKIN:    //是否进入了皮肤界面
        {
            return _isFirstEnterSkin;
        }
            break;
        case PREF_SKINTYPE:
        {
            return 0;//_skinType;
        }
            break;
        case PREF_SWITCHEDVOICE:
        {
            return _switchedVoice;
        }
            break;
        case PREF_IS_POWERVOICE_PLAY:
        {
            return _isPowerVoicePlay;
        }
            break;
        case PREF_POWERVOICEID:
        {
            return _powerVoiceID;
        }
            break;
        case PREF_IS_LZLDIALECT:
        {
            return _isLZLDialect;
        }
            break;
        case PREF_SEARCHTYPE:
        {
            return _searchType;
        }
            break;
        case PREF_AUTODRIVINGTRACK:
        {
            return _autoDrivingTrack;
        }
            break;
        case PREF_BACKGROUND_NAVI:
        {
            return _backgroundNavi;
        }
            break;
        case PREF_DEMOMODE:
        {
             GDBL_GetParam(G_DEMO_MODE, &value);
        }
            break;
        case PREF_AUTOZOOM:
        {
            return _autoZoom;
        }
            break;
		default:
			break;
	}
	
	return value;
}

-(int)setValue:(PRETYPE)type Value:(NSInteger)value
{
    switch (type)
	{
		case PREF_UILANGUAGE://UI保存当前的语言选项0简体1繁体2英文
        {
            _UILanguage = value;
            [ANOperateMethod sharedInstance].localizeType = value;
            // 设置地图语言模式
            GLANGUAGE nMapLanguage;//0简体1英文2繁体
            int nTTSLanguage;
            if (value==0) {//0简体
                nMapLanguage = 0;
                nTTSLanguage = 0;
                
                if ([self getValue:PREF_TTSROLEINDEX] == Role_Catherine || [self getValue:PREF_TTSROLEINDEX] == Role_John) {
                    [[MWTTS SharedInstance] SetTTSRole:Role_XIAOYAN];
                    [self setValue:PREF_IS_LZLDIALECT Value:0];
                }
                
			}
            else if(value==1)//1繁体
			{
                nMapLanguage = 2;
                nTTSLanguage = 1;
                if ([self getValue:PREF_TTSROLEINDEX] == Role_Catherine || [self getValue:PREF_TTSROLEINDEX] == Role_John) {
                    [[MWTTS SharedInstance] SetTTSRole:Role_XIAOYAN];
                    [self setValue:PREF_IS_LZLDIALECT Value:0];
                }
            }
            else
            {//2英文
                
                nMapLanguage = 1;
                nTTSLanguage = 2;
                if (!([self getValue:PREF_TTSROLEINDEX] == Role_Catherine || [self getValue:PREF_TTSROLEINDEX] == Role_John)) {
                    [[MWTTS SharedInstance] SetTTSRole:Role_Catherine];
                    [self setValue:PREF_IS_LZLDIALECT Value:0];
                }
                
            }
			GDBL_SetParam(G_LANGUAGE, &nMapLanguage);
		}
			break;
		case PREF_FONTSIZE://设置字体大小
		{
            
			GDBL_SetParam(G_MAP_FONT_SIZE, &value);
		}
			break;
		case PREF_MAPVIEWMODE://设置地图模式
		{
			GMAPVIEWMODE eMapViewMode = (GMAPVIEWMODE)value;
			GDBL_SetParam(G_MAP_VIEW_MODE, &eMapViewMode);
		}
			break;
		case PREF_POIDENSITY://设置地图详细度
		{
			GMAPPOIDENSITY eMapPoiDensity = (GMAPPOIDENSITY)value;
			GDBL_SetParam(G_MAP_POI_DENSITY, &eMapPoiDensity);
		}
			break;
		case PREF_MAPDAYNIGHTMODE://设置白天黑夜模式
		{
			GMAPDAYNIGHTMODE eMapDayNightMode = (GMAPDAYNIGHTMODE)value;
			GDBL_SetParam(G_MAP_DAYNIGHT_MODE, &eMapDayNightMode);
            if (eMapDayNightMode != GMAP_DAYNIGHT_MODE_AUTO) {//设置主界面白天黑夜ui
                [UIImage setImageDayNightMode:value];
            }
		}
			break;
		case PREF_TTSROLEINDEX://设置语音选择
		{
            [[MWTTS SharedInstance] SetTTSRole:(Role_Player)value];
            _ttsRoleIndex = value;
		}
			break;
		case PREF_PROMPTOPTION://设置语音提示频率
		{
			GPROMPTOPTION ePromptOption = (GPROMPTOPTION)value;
			GDBL_SetParam(G_PROMPT_OPTION, &ePromptOption);
		}
			break;
		
		case PREF_MAPPOIPRIORITY://设置信息优先显示
		{
			GMAPPOIPRIORITY eMapPoiPriority = (GMAPPOIPRIORITY)value;
			GDBL_SetParam(G_MAP_POI_PRIORITY, &eMapPoiPriority);
		}
			break;
        case PREF_BACKGROUND_MODE://后台
        {
            GDBL_SetParam(G_BACKGROUND_MODE, &value);
        }
            break;
        case PREF_MAPSHOWCURSOR://移图游标
        {
            GDBL_SetParam(G_MAP_SHOW_CURSOR, &value);
        }
			break;
        case PREF_DEMO_SPEED://模拟导航速度
        {
            GDBL_SetParam(G_DEMO_SPEED, &value);
        }
            break;
        case PREF_MAP_SHOW_GUIDEPOST://高速路牌显示
        {
            GDBL_SetParam(G_MAP_SHOW_GUIDEPOST, &value);
        }
            break;
        case PREF_SHOW_SAFETY_ICON://是否显示电子狗图标
        {
//            GDBL_SetParam(G_SHOW_SAFETY_ICON, &value);
        }
            break;
        case PREF_SHOW_MAP_GRAY_BKGND://实时交通显示灰色地图
        {
            GDBL_SetParam(G_SHOW_MAP_GRAY_BKGND, &value);
        }
            break;
        case PREF_MAP_TMC_SHOW_OPTION://控制是城市TMC还是路径线TMC
        {
            int isPath = 0;
            GDBL_GetParam(G_GUIDE_STATUS, &isPath);
            if (isPath == 1) {
                if (value == YES)  //只要显示路径TMC和路径事件
                {
                    value = 0x02 | 0x08;
                }
                else    //显示路径TMC、城市TMC和路径事件
                {
                    value = 0x01 | 0x02| 0x08;
                }
                GDBL_SetParam(G_MAP_TMC_SHOW_OPTION, &value);
            }
            else
            {
                value = 0x0f;
                GDBL_SetParam(G_MAP_TMC_SHOW_OPTION, &value);
            }
           
        }
            break;
		case PREF_ROUTE_OPTION://设置路径规划原则
		{
            GROUTEOPTION routeRule = value;
            GDBL_SetParam(G_ROUTE_OPTION, &routeRule);
		}
			break;
        case PREF_DISABLE_GPS://GPS开关
		{
            if (value == 1)
            {
                value = 0;
            }
            else if (value == 0)
            {
                value = 1;
            }
			int bReceiveGPS = value;
            GDBL_SetParam(G_DISABLE_GPS, &bReceiveGPS);
        }
			break;
		case PREF_TRACK_RECORD://自动记录轨迹开关
		{
            int useTrack = value;
            GDBL_SetParam(G_TRACK_RECORD, &useTrack);
		}
			break;
		case PREF_MAP_CONTENT://街区图开关
		{
            int useStreet = value;
            GDBL_SetParam(G_MAP_CONTENT, &useStreet);
		}
			break;
		case PREF_MUTE://语音提示开关
		{
            //路况播报
            _speakTraffic = value;
            //电子眼播报
            [self setValue:PREF_SPEAK_SAFETY Value:value];
            //开机语音

            _switchedVoice = value;
            if (value==0)
			{
				value = 1;
			}
			else if (value==1)
			{
			    value = 0;
            }
            int bMute = value;
            GDBL_SetParam(G_MUTE , &bMute);
		}
			break;
            
        
        case PREF_DISABLE_ECOMPASS://电子罗盘开关
		{
            if (value == 1)
            {
                value = 0;
                [MWGPS  HeadingStartup];
            }
            else if (value == 0)
            {
                value = 1;
                [MWGPS  HeadingCleanup];
            }
			int e_compass = value;
            GDBL_SetParam(G_DISABLE_ECOMPASS, &e_compass);
            
		}
			break;
        case PREF_SPEAK_SAFETY://电子眼播报开关
        {
            //modify by gzm for 引擎中已没有电子眼播报开关，只能单独控制播报，包括GSAFESPEEDLIMITSPEAK，GSAFECAMERASPEAK GSAFEDANGERWARNSPEAK 三种类型摄像头at 2014-7-29
            if (value == 1)
            {
                GSAFESPEEDLIMITSPEAK limitSpeak = GSAFE_SPEEDLIMITSPEAK_ALL;
                GDBL_SetParam(G_SAFE_SPEEDLIMITSPEAK,&limitSpeak);
                
                GSAFECAMERASPEAK cameraSpeak = GSAFE_CAMERASPEAK_ALL;
                GDBL_SetParam(G_SAFE_CAMERASPEAK, &cameraSpeak);
                
                GSAFEDANGERWARNSPEAK dangerWarnSpeak = GSAFE_DANGERWARNSPEAK_HIGHRISK;
                GDBL_SetParam(G_SAFE_DANGERWARNSPEAK, &dangerWarnSpeak);
            }
            else
            {
                GSAFESPEEDLIMITSPEAK limitSpeak = GSAFE_SPEEDLIMITSPEAK_CLOSE;
                GDBL_SetParam(G_SAFE_SPEEDLIMITSPEAK,&limitSpeak);
                
                GSAFECAMERASPEAK cameraSpeak = GSAFE_CAMERASPEAK_CLOSE;
                GDBL_SetParam(G_SAFE_CAMERASPEAK, &cameraSpeak);
                
                GSAFEDANGERWARNSPEAK dangerWarnSpeak = GSAFE_DANGERWARNSPEAK_CLOSE;
                GDBL_SetParam(G_SAFE_DANGERWARNSPEAK, &dangerWarnSpeak);
            }
            
        }
            break;
        case PREF_SHOW_TMCEVENT:
        {
            GDBL_SetParam(G_SHOW_TMCEVENT, &value);
        }
            break;
        case PREF_DISPLAY_ORIENTATION:
        {
            GDISPLAYORIENTATION Value;
            
            switch (value)
            {
                case 0:
                {
                    Value = G_DISPLAY_ORIENTATION_H;
                }
                    break;
                    
                case 1:
                {
                    Value = G_DISPLAY_ORIENTATION_V;
                }
                    break;
                    
                case 2:
                {
                    Value = G_DISPLAY_ORIENTATION_H;
                }
                    break;
                    
                case 3:
                {
                    Value = G_DISPLAY_ORIENTATION_V;
                }
                    break;
                    
                default:
                    break;
            }
            
            GDBL_SetParam(G_DISPLAY_ORIENTATION, &Value);
        }
            break;
		case PREF_NEWFUNINTRODUCE://开机新功能是否已经查看标志
		{
			_newFunIntroduce = value;
		}
			break;
		case PREF_SHAKETOCHANGETHEME://摇晃切换地图配色开关
		{
			_shakeToChangeTheme = value;
		}
			break;
		case PREF_STARTUPWARNING://警告提示开关
		{
			_startupWarning = value;
		}
			break;
		case PREF_INTERFACESTATE://横竖屏开关
		{
			_interfaceState  = value;
		}
			break;
        case PREF_PARKINGINFO://目的地停车场推送开关
		{
			_parkingInfo  = value;
		}
			break;
		case PREF_INTEFACEORIENTATION://界面方向
		{
			_interfaceOrientation  = value;
		}
			break;
        case PREF_TRAVELUPDATE://数据界面是否显示更新按钮
		{
			_travelUpdate = value;
		}
			break;
        case PREF_SPEAKTRAFFIC://路况播报
        {
            GDBL_SetParam(G_FUNCTION_SUPPORT_PCD, &value);
            _speakTraffic = value;
        }
            break;
        case PREF_TRAFFICMESSAGE://路况信息条
        {
            _trafficMessage = value;
        }
            break;
        case PREF_SET95190://是否开启95190
        {
            _set95190 = value;
        }
            break;
        case PREF_FIRSTSTART://第一次进入
        {
            if(value == 0)
            {
                _firstStart = NO;
            }
            else
            {
                _firstStart = YES;
            }
        }
            break;
        case PREF_BACKGROUNDDOWNLOAD://后台下载开关
        {
            if(value == 0)
            {
                _backgroundDownload = NO;
            }
            else
            {
                _backgroundDownload = YES;
            }
        }
            break;
        case PREF_SETLANGUAGEMANUALLY://手动设置了导航语言
        {
            _setLanguageManually = value;
        }
            break;
        case PREF_REALTIME_TRAFFIC://实时交通开关
        {
            _realTimeTraffic = value;
        }
            break;
        case PREF_HUD_DISPLAYORIENTATION://HUD 图面方向
        {
            _HUDDisplayOrientation = value;
        }
            break;
        case PREF_AUTO_GETPOIINFO:
        {
            _autoGetPOIInfo = value;
        }
            break;
        case PREF_IS_FIRSTENTERSKIN://第一次进入
        {
            if(value == 0)
            {
                _isFirstEnterSkin = NO;
            }
            else
            {
                _isFirstEnterSkin = YES;
            }
        }
            break;
        case PREF_SKINTYPE:
        {
            _skinType = value;
            
        }
            break;
        case PREF_SWITCHEDVOICE:
        {
            _switchedVoice = value;
        }
            break;
        case PREF_IS_POWERVOICE_PLAY:
        {
            _isPowerVoicePlay = value;
        }
            break;
        case PREF_POWERVOICEID:
        {
            _powerVoiceID = value;
        }
            break;
        case PREF_IS_LZLDIALECT:
        {
            _isLZLDialect = value;
        }
            break;
        case PREF_SEARCHTYPE:
        {
            _searchType = value;
        }
            break;
        case PREF_AUTODRIVINGTRACK:
        {
            _autoDrivingTrack = value;
        }
            break;
        case PREF_BACKGROUND_NAVI:
        {
            _backgroundNavi = value;
        }
            break;
        case PREF_DEMOMODE:
        {
            GDBL_SetParam(G_DEMO_MODE, &value);
        }
            break;
        case PREF_AUTOZOOM:
        {
            _autoZoom = value;
            int isPath = 0;
            GDBL_GetParam(G_GUIDE_STATUS, &isPath); //modify by gzm for 有路径下才开启自动缩放 at 2014-11-12
            if (isPath)  //
            {
                GDBL_SetParam(G_MAP_AUTOZOOM, &value);
                if (value == 1) {//如果开启自动缩放，则设置时间为8秒
                    
                    int time = 8000;
                    GDBL_SetParam(G_MAP_NEXTAUTOTIME, &time);
                }
            }
            else
            {
                value = 0;
                GDBL_SetParam(G_MAP_AUTOZOOM, &value);
            }
        }
            break;
		default:
			break;
	}
    return 0;
}

-(BOOL)reset
{
    [self preferenceHandle:HANDLE_RESET];
    return YES;
}


#pragma mark -
#pragma mark private


- (BOOL)readPreference
{
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:preferenceFilePath];
    if(dic != nil)
    {
        NSNumber *softVersion = [dic objectForKey:@"_softVersion"];
        if(softVersion)
            _softVersion = [softVersion floatValue];
        NSNumber *startupWarning = [dic objectForKey:@"_startupWarning"];
        if(startupWarning )
            _startupWarning = [startupWarning boolValue];
        NSNumber *newFunIntroduce = [dic objectForKey:@"_newFunIntroduce"];
        if(newFunIntroduce)
            _newFunIntroduce = [newFunIntroduce boolValue];
        NSNumber *shakeToChangeTheme = [dic objectForKey:@"_shakeToChangeTheme"];
        if(shakeToChangeTheme)
            _shakeToChangeTheme = [shakeToChangeTheme boolValue];
        NSNumber *interfaceState = [dic objectForKey:@"_interfaceState"];
        if(interfaceState)
            _interfaceState = [interfaceState boolValue];
        NSNumber *parkingState = [dic objectForKey:@"_parkingInfo"];
        if(parkingState)
        {
            _parkingInfo = [parkingState boolValue];
        }
        else
        {
            _parkingInfo = YES;
        }
        
        
        NSNumber *interfaceOrientation = [dic objectForKey:@"_interfaceOrientation"];
        if(interfaceOrientation)
            _interfaceOrientation = [interfaceOrientation intValue];
        
        NSNumber *mapDataUpdateReminder = [dic objectForKey:@"_mapDataUpdateReminder"];
        if(mapDataUpdateReminder)
            _mapDataUpdateReminder = [mapDataUpdateReminder boolValue];
        NSNumber *ttsRoleIndex = [dic objectForKey:@"_ttsRoleIndex"];
        if(ttsRoleIndex)
            _ttsRoleIndex = [ttsRoleIndex intValue];
        NSNumber *UILanguage = [dic objectForKey:@"_UILanguage"];
        if(UILanguage)
            _UILanguage = [UILanguage intValue];
        NSNumber *travelUpdate = [dic objectForKey:@"_travelUpdate"];
        if(travelUpdate)
            _travelUpdate = [travelUpdate boolValue];
        NSNumber *setLanguageManually = [dic objectForKey:@"_setLanguageManually"];
        if(setLanguageManually)
            _setLanguageManually = [setLanguageManually boolValue];
        NSNumber *set95190 = [dic objectForKey:@"_set95190"];
        if(set95190)
            _set95190 = [set95190 boolValue];
        NSNumber *tmpSpeakTraffic = [dic objectForKey:@"_speakTraffic"];
        if(tmpSpeakTraffic)
            [self setValue:PREF_SPEAKTRAFFIC Value:[tmpSpeakTraffic boolValue]];
        else
              [self setValue:PREF_SPEAKTRAFFIC Value:YES];
        NSNumber *trafficMessage = [dic objectForKey:@"_trafficMessage"];
        if(trafficMessage)
            _trafficMessage = [trafficMessage boolValue];
        else
            _trafficMessage = YES;
        NSNumber *PSCountOfUnread = [dic objectForKey:@"_PSCountOfUnread"];
        if(PSCountOfUnread)
            _PSCountOfUnread = [PSCountOfUnread intValue];
        NSNumber *PSNewCustomerServicePrompt = [dic objectForKey:@"_PSNewCustomerServicePrompt"];
        if(PSNewCustomerServicePrompt)
            _PSNewCustomerServicePrompt = [PSNewCustomerServicePrompt boolValue];
        NSNumber *trafficEvent = [dic objectForKey:@"_trafficEvent"];
        if(trafficEvent)
            _trafficEvent = [trafficEvent boolValue];
        else
            _trafficEvent = NO;
        
        NSNumber *firstStart = [dic objectForKey:@"_firstStart"];
        if(firstStart)
            _firstStart = [firstStart boolValue];
        NSNumber *backgroundDownload = [dic objectForKey:@"_backgroundDownload"];
        if(backgroundDownload)
            _backgroundDownload = [backgroundDownload boolValue];
        else
            _backgroundDownload = YES;
        NSNumber *realTimeTraffic = [dic objectForKey:@"_realTimeTraffic"];
        if(realTimeTraffic)
            _realTimeTraffic = [realTimeTraffic boolValue];
        
        NSNumber *HUDDisplayOrientation = [dic objectForKey:@"_HUDDisplayOrientation"];
        if(HUDDisplayOrientation)
            _HUDDisplayOrientation = [HUDDisplayOrientation boolValue];
        else
            _HUDDisplayOrientation = YES;
        
        NSNumber *autoGetPOIInfo = [dic objectForKey:@"_autoGetPOIInfo"];
        if(autoGetPOIInfo)
            _autoGetPOIInfo = [autoGetPOIInfo boolValue];
        else
            _autoGetPOIInfo = YES;
        
        self.deviceToken = [dic objectForKey:@"_deviceToken"];
        self.mapVersion = [dic objectForKey:@"_mapVersion"];

        NSNumber *isFirstEnterSkin = [dic objectForKey:@"_isFirstEnterSkin"];
        if(isFirstEnterSkin)
        {
            _isFirstEnterSkin = [isFirstEnterSkin boolValue];
        }
        else{
            _isFirstEnterSkin = YES;
        }
        
        NSNumber *skintype = [dic objectForKey:@"_skinType"];
        if(skintype)
        {
            _skinType = [skintype intValue];
            
        }
        
        NSNumber *isOldUser = [dic objectForKey:@"_isOldUser"];
        if(isOldUser)
        {
            _isOldUser = [isOldUser boolValue];
        }
        
        NSNumber *nextHightPraiseCount = [dic objectForKey:@"_nextHightPraiseCount"];
        if(nextHightPraiseCount)
        {
            _nextHightPraiseCount = [nextHightPraiseCount intValue];
        }
        
        NSNumber *switchedVoice = [dic objectForKey:@"_switchedVoice"];
        if(switchedVoice)
        {
            _switchedVoice = [switchedVoice boolValue];
        }
        else {
            _switchedVoice = YES;
        }
        
        NSNumber *isPowerVoicePlay = [dic objectForKey:@"_isPowerVoicePlay"];
        if(isPowerVoicePlay)
        {
            _isPowerVoicePlay = [isPowerVoicePlay boolValue];
        }
        
        NSNumber *powerVoiceID = [dic objectForKey:@"_powerVoiceID"];
        if(powerVoiceID)
        {
            _powerVoiceID = [powerVoiceID intValue];
        }
        
        NSNumber *isLZLDialect = [dic objectForKey:@"_isLZLDialect"];
        if(isLZLDialect)
        {
            _isLZLDialect = [isLZLDialect intValue];
        }
        
        NSNumber *searchType = [dic objectForKey:@"_searchType"];
        if(searchType)
        {
            _searchType = [searchType boolValue];
        }
        
        NSNumber *autoDrivingTrack = [dic objectForKey:@"_autoDrivingTrack"];
        if(autoDrivingTrack)
        {
            _autoDrivingTrack = [autoDrivingTrack boolValue];
        }
        
        NSNumber *backgroundNavi = [dic objectForKey:@"_backgroundNavi"];
        if(backgroundNavi)
        {
            _backgroundNavi = [backgroundNavi boolValue];
        }
        else {
            _backgroundNavi = YES;
        }
        
        NSNumber *autoZoom = [dic objectForKey:@"_autoZoom"];
        if(autoZoom)
        {
            _autoZoom = [autoZoom intValue];
        }
        else {
            _autoZoom = 1;
        }
        
    }
    return YES;
}

- (void)preferenceHandle:(PREF_HANDLETYPE)type
{
    switch (type) {
        case HANDLE_INIT://系统初始化(无配置文件时调用)
        {
            _softVersion = SOFTVERSIONNUM;
        
            [self setValue:PREF_STARTUPWARNING Value:YES];
            [self setValue:PREF_NEWFUNINTRODUCE Value:NO];
            [self setValue:PREF_SHAKETOCHANGETHEME Value:NO];
            [self setValue:PREF_INTERFACESTATE Value:1];
            [self setValue:PREF_PARKINGINFO Value:1];
            [self setValue:PREF_INTEFACEORIENTATION Value:YES];
            [self setValue:PREF_TTSROLEINDEX Value:Role_XIAOYAN];
            [self setValue:PREF_TRAVELUPDATE Value:NO];
            [self setValue:PREF_SETLANGUAGEMANUALLY Value:NO];
            [self setValue:PREF_SET95190 Value:NO];
            [self setValue:PREF_SPEAKTRAFFIC Value:YES];
            [self setValue:PREF_TRAFFICMESSAGE Value:YES];
            [self setValue:PREF_FIRSTSTART Value:YES];
            [self setValue:PREF_BACKGROUNDDOWNLOAD Value:YES];
            [self setValue:PREF_REALTIME_TRAFFIC Value:NO];
            [self setValue:PREF_HUD_DISPLAYORIENTATION Value:NO];
            [self setValue:PREF_AUTO_GETPOIINFO Value:YES];
            [self setValue:PREF_IS_FIRSTENTERSKIN Value:NO];
            [self setValue:PREF_SKINTYPE Value:0];
            [self setValue:PREF_SWITCHEDVOICE Value:YES];
            [self setValue:PREF_IS_POWERVOICE_PLAY Value:NO];
            [self setValue:PREF_POWERVOICEID Value:0];
            [self setValue:PREF_IS_LZLDIALECT Value:0];
            [self setValue:PREF_SEARCHTYPE Value:NO];
            [self setValue:PREF_AUTODRIVINGTRACK Value:NO];
            [self setValue:PREF_BACKGROUND_NAVI Value:YES];

            _autoZoom = 1;

           
        }
            break;
        case HANDLE_UPDATE://软件升级处理
        {
            //add by hlf for 由于9.0语音改为后台下载，因此9.0以前的版本升级上来语音设置为默认，9.0和9.0以后的版本继承上一版本的语音设置(需放在版本号赋值之前) at 2014.09.24
            if (_softVersion < 9.0f) {
                [[MWPreference sharedInstance] setValue:PREF_TTSROLEINDEX Value:0];
                [[MWPreference sharedInstance] setValue:PREF_IS_LZLDIALECT Value:0];
            }
            
            _softVersion = SOFTVERSIONNUM;
            self.deviceToken = @"";
            [self setValue:PREF_NEWFUNINTRODUCE Value:NO];
            [self setValue:PREF_FIRSTSTART Value:YES];
            [self setValue:PREF_IS_POWERVOICE_PLAY Value:NO];
            [self setValue:PREF_POWERVOICEID Value:0];

            
            // 打开新版本检测
            [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:USERDEFAULT_MWSoftWareUpdateReminderKey];
            
            //上传设备令牌参数重置
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:USERDEFAULT_MWUploadTokenAutoNaviSuccess];
            
            //删除未下载完成的皮肤
            [[MWSkinDownloadManager sharedInstance] removeTasksForStatus:TASK_STATUS_READY];
            [[MWSkinDownloadManager sharedInstance] removeTasksForStatus:TASK_STATUS_RUNNING];
            [[MWSkinDownloadManager sharedInstance] removeTasksForStatus:TASK_STATUS_BLOCK];
            
            //删除皮肤更新保存的皮肤版本号
            [[MWSkinDownloadManager sharedInstance].updateVersionDictionary removeAllObjects];
            
            
            //add by hlf for 8.5升级到9.0，方言后台切换，删除8.5版本未下载完成的任务
            [[MWDialectDownloadManage sharedInstance] removeTasksForStatus:TASK_STATUS_BLOCK];
            [[MWDialectDownloadManage sharedInstance] removeTasksForStatus:TASK_STATUS_RUNNING];
            [[MWDialectDownloadManage sharedInstance] removeTasksForStatus:TASK_STATUS_READY];

            //add by hlf for 升级版本时删除云端规避文件 (目前使用70引擎去读取60引擎生成的规避文件，会可能出现崩溃的情况)
            [[MWCloudDetourManage sharedInstance] removeAllTask];
            
            //清除缓存
            [[GDCacheManager globalCache] clearCache];
        
            
            //更新版本，更新new的提示
            //更新到新版本，删除的系统项，进行默认的设置
            [self toNewVersion];
        }
            break;
        case HANDLE_RESET://恢复出厂设置
        {
            
            [self setValue:PREF_STARTUPWARNING Value:YES];
            [self setValue:PREF_SHAKETOCHANGETHEME Value:NO];
            [self setValue:PREF_INTERFACESTATE Value:1];
            [self setValue:PREF_PARKINGINFO Value:1];
            [self setValue:PREF_INTEFACEORIENTATION Value:YES];
            [self setValue:PREF_TTSROLEINDEX Value:Role_XIAOYAN];
            [self setValue:PREF_UILANGUAGE Value:LANGUAGE_SIMPLE_CHINESE];
            [self setValue:PREF_TRAVELUPDATE Value:NO];
            [self setValue:PREF_SETLANGUAGEMANUALLY Value:NO];
            [self setValue:PREF_SET95190 Value:NO];
            [self setValue:PREF_SPEAKTRAFFIC Value:YES];
            [self setValue:PREF_TRAFFICMESSAGE Value:YES];
            [self setValue:PREF_BACKGROUNDDOWNLOAD Value:YES];
            [self setValue:PREF_REALTIME_TRAFFIC Value:NO];
            [self setValue:PREF_HUD_DISPLAYORIENTATION Value:NO];
            [self setValue:PREF_AUTO_GETPOIINFO Value:YES];
            [self setValue:PREF_DISABLE_GPS Value:YES];
            [self setValue:PREF_SKINTYPE Value:0];
            [self setValue:PREF_SWITCHEDVOICE Value:YES];
            [self setValue:PREF_IS_LZLDIALECT Value:0];
            [self setValue:PREF_SEARCHTYPE Value:NO];
            [self setValue:PREF_AUTODRIVINGTRACK Value:NO];
            [self setValue:PREF_BACKGROUND_NAVI Value:YES];
            
            [self setValue:PREF_FONTSIZE Value:GMAP_FONT_SIZE_NORMAL];
            [self setValue:PREF_MAPDAYNIGHTMODE Value:GMAP_DAYNIGHT_MODE_AUTO];
            [MWDayNight setDayNightSchemeWithIndex:0];//色盘恢复默认
            [self setValue:PREF_PROMPTOPTION Value:GPROMPT_OPTION_MUCH];
            [self setValue:PREF_MAPPOIPRIORITY Value:GMAP_POI_PRIORITY_AUTO];
            [self setValue:PREF_TRACK_RECORD Value:0];
            [self setValue:PREF_MAP_CONTENT Value:GMAP_CONTENT_GL_MIX];
            [self setValue:PREF_DISABLE_ECOMPASS Value:0];
            [self setValue:PREF_SPEAK_SAFETY Value:1];
            [self setValue:PREF_DEMOMODE Value:GDEMO_NAVIMODE_NORMAL];
            [self setValue:PREF_DEMO_SPEED Value:SIM_MID_SPEED];
            [self setValue:PREF_MUTE Value:1];
            [self setValue:PREF_MAPPOIPRIORITY Value:0];
            [self setValue:PREF_ROUTE_OPTION Value:0]; //路线规划原则设置为推荐
            [self setValue:PREF_AUTOZOOM Value:1];//导航时地图自动缩放默认开启
            
            if([MWEngineSwitch isTMCOn])//恢复出厂设置关闭实时交通
            {
                [MWEngineSwitch CloseTMC];
            }
            
            [[MWMapOperator sharedInstance]  MW_SetMapViewMode:GMAP_VIEW_TYPE_MAIN Type:0 MapMode:GMAPVIEW_MODE_NORTH];//恢复地图视图模式为北首上
            
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_HandleUIUpdate object:[NSNumber numberWithInt:UIUpdate_SkinTypeChange] userInfo:@{CONFIG_SKIN_ID: [NSNumber numberWithInt:[[MWPreference sharedInstance] getValue:PREF_SKINTYPE]] }];//恢复皮肤
            

            
            
        }
            break;
        default:
            break;
    }
}

-(void)setDeviceToken:(NSString *)deviceToken
{
    if (deviceToken != _deviceToken) {
        [_deviceToken release];
        _deviceToken = [deviceToken copy];
    }
    NSString *tmpID = @"";
    if (deviceToken) {
        tmpID = [NSString stringWithFormat:@"%@",deviceToken];
    }
    
   
}

/*!
  @brief    版本升级，删除的项目，设置为默认值
  @param
  @author   by bazinga
  */
- (void) toNewVersion
{
    /*界面方向*/
    [self setValue:PREF_INTERFACESTATE Value:YES];
    [self setValue:PREF_INTEFACEORIENTATION Value:YES];

    /*目的地停车场是否推送：0 关闭; 1 开启 */
    [self setValue:PREF_PARKINGINFO Value:1];
    /*后台下载: 0 关闭; 1 开启 */
    [self setValue:PREF_BACKGROUNDDOWNLOAD Value:1];
    /*GPS开关: 0 关闭; 1 开启 */
    [self setValue:PREF_DISABLE_GPS Value:1];
    
    //ipad 删除 A-Link
    if(isPad)
    {
        [[MWCarOwnerServiceManage sharedInstance] removeTaskId:@"com.carservice.alink"];
    }
}

@end

//
//  MWPreference.h
//  AutoNavi
//
//  添加需要保存的变量，设置引擎参数
//
//  Created by yu.liao on 13-7-29.
//  
//  添加变量时需添加以下几个地方:
//
//  1.添加变量后，在PREFTYPE枚举类型添加相对应的枚举类型
//  2.在savePreference函数保存变量
//  3.在readPreference函数读取变量
//  4.在setValue:(PRETYPE)type value:(NSInteger)value函数设置变量值
//  5.在getValue:(PRETYPE)type函数添加读取变量方法
//  6.在preferenceHandle:(PREF_HANDLETYPE)type函数设置变量在系统初始化，系统升级，系统还原，兼容旧版本相对应的值

#import <Foundation/Foundation.h>

typedef enum  PREFTYPE{
    //上层保存参数
    /*软件版本*/
    PREF_SOFVERSION,
    /*开机警告提示: 0 关闭; 1 开启*/
    PREF_STARTUPWARNING,
    /*新功能介绍: 0 关闭; 1 开启 */
    PREF_NEWFUNINTRODUCE,
    /*摇晃切换地图色盘: 0 关闭; 1 开启 */
    PREF_SHAKETOCHANGETHEME,
    /*横竖屏开关: 0 关闭; 1 开启 */
    PREF_INTERFACESTATE,
    /*目的地停车场是否推送：0 关闭; 1 开启 */
    PREF_PARKINGINFO,
    /*界面方向*/
    PREF_INTEFACEORIENTATION,
    /*语音播放角色索引*/
    PREF_TTSROLEINDEX,
    /*当前语言: 0 简体; 1 繁体; 2 英文 */
    PREF_UILANGUAGE,
    /*数据管理界面是否显示更新按钮: 0 关闭; 1 开启 */
    PREF_TRAVELUPDATE,
    /*手动设置了导航语言: 0 否; 1 是 */
    PREF_SETLANGUAGEMANUALLY,
    /*(废弃)是否开启95190: 0 关闭; 1 开启 */
    PREF_SET95190,
    /*路况播报: 0 关闭; 1 开启 */
    PREF_SPEAKTRAFFIC,
    /*路况信息条: 0 关闭; 1 开启 */
    PREF_TRAFFICMESSAGE,
    /*是否第一次进入程序: 0 否; 1 是 */
    PREF_FIRSTSTART,
    /*后台下载: 0 关闭; 1 开启 */
    PREF_BACKGROUNDDOWNLOAD,
    /*实时交通开关: 0 关闭; 1 开启 */
    PREF_REALTIME_TRAFFIC,
    /*HUD图面: 0 反向显示; 1 正向显示 */
    PREF_HUD_DISPLAYORIENTATION,
    /*自动获取poi详情: 0 关闭; 1 开启 */
    PREF_AUTO_GETPOIINFO,
    /*是否是第一次进入皮肤的view: 0 否; 1 是 */
    PREF_IS_FIRSTENTERSKIN,
    /*当前使用的皮肤类型 0：默认*/
    PREF_SKINTYPE,
    /*开机语音开关: 0 关闭; 1 开启 */
    PREF_SWITCHEDVOICE,
    /*开机下载语音播报: 0 未播报; 1 已播报 */
    PREF_IS_POWERVOICE_PLAY,
    /*开机下载语音ID*/
    PREF_POWERVOICEID,
    /*是否为林志玲语音: 0 否; 1 是 */
    PREF_IS_LZLDIALECT,
    /*优先使用搜索类型: 0 优先使用网络搜索; 1 优先使用本地搜索 */
    PREF_SEARCHTYPE,
    /*是否自动显示打分界面: 0 是; 1 否 */
    PREF_AUTODRIVINGTRACK,
    /*是否开启后台导航: 0 否; 1 是 */
    PREF_BACKGROUND_NAVI,
    
    
    //引擎参数
    
    /*字体大小: 0 小; 1 中; 2 大 */
    PREF_FONTSIZE,
    /*地图模式: 0 北首朝上; 1 车首朝上; 2 3D */
    PREF_MAPVIEWMODE,
    /*地图详细度: 0 详细; 1 正常; 2 简单 */
    PREF_POIDENSITY,
    /*白天黑夜模式: 0 白天; 1 黑夜; 2 自动 */
    PREF_MAPDAYNIGHTMODE,
    /*语音提示频率: 0 一般; 1 频繁 */
    PREF_PROMPTOPTION,
    /*信息优先显示: 0 自动; 1 加油站; 2 停车场; 4 餐饮; 8 住宿; 16 娱乐; 32 景点; 64 医疗*/
    PREF_MAPPOIPRIORITY,
    /*后台模式: 0 否; 1 是 */
    PREF_BACKGROUND_MODE,
    /*移图游标: 0 否; 1 是 */
    PREF_MAPSHOWCURSOR,
    /*模拟导航速度:  */
    PREF_DEMO_SPEED,
    /*高速路牌: 0 否; 1 是 */
    PREF_MAP_SHOW_GUIDEPOST,
    /*电子狗图标: 0 否; 1 是 */
    PREF_SHOW_SAFETY_ICON,
    /*实时交通显示灰色地图: 0 否; 1 是 */
    PREF_SHOW_MAP_GRAY_BKGND,
    /*控制是城市TMC还是路径线TMC: 0 城市TMC; 1 路径线TMC */
    PREF_MAP_TMC_SHOW_OPTION,
    /*路径规划原则: 0 推荐路线; 1 高速优先; 2 经济路线; 3 最短路线 4 walk; 5 linear */
    PREF_ROUTE_OPTION,
    /*GPS开关: 0 关闭; 1 开启 */
    PREF_DISABLE_GPS,
    /*自动记录轨迹: 0 关闭; 1 开启 */
    PREF_TRACK_RECORD,
    /*街区图: 0 无街区; 1 面状; 2 线状 */
    PREF_MAP_CONTENT,
    /*语音提示: 0 关闭; 1 开启 */
    PREF_MUTE,
    /*电子罗盘: 0 关闭; 1 开启 */
    PREF_DISABLE_ECOMPASS,
    /*引擎地图显示方向: 0 横屏; 1 竖屏 */
    PREF_DISPLAY_ORIENTATION,
    /*电子眼播报开关: 0 关闭; 1 开启*/
    PREF_SPEAK_SAFETY,
    /*事件图标显示开关: 0 关闭; 1 开启 */
    PREF_SHOW_TMCEVENT,
    /*地图白天黑夜: 0 白天; 1 黑夜 */
    PREF_DAYNIGHTMODE,
    /*模拟导航模式: 0 一般连续模拟模式; 1 跳跃模拟模式 */
    PREF_DEMOMODE,
    /*导航时地图是否自动缩放: 0 否; 1 是 */
    PREF_AUTOZOOM,
    PREF_MAX
    
}PRETYPE;

typedef enum PREF_HANDLETYPE {
    HANDLE_INIT,                         //系统初始化
    HANDLE_UPDATE,                       //系统升级
    HANDLE_RESET                        //系统还原
}PREF_HANDLETYPE;

//字体语言
typedef enum PREF_LANGUAGE {
	PREF_LANGUAGE_SIMPLE_CHINESE      = 0, //简体
    PREF_LANGUAGE_TRADITIONAL_CHINESE = 1, //繁体
	PREF_LANGUAGE_ENGLISH             = 2  //英语
	
} PREF_LANGUAGE;

@interface MWPreference : NSObject
{
@private
    float _softVersion;                         /*软件版本*/
    BOOL  _startupWarning;                      /*开机警告提示: 0 关闭; 1 开启*/
    BOOL  _newFunIntroduce;                     /*新功能介绍: 0 关闭; 1 开启 */
    BOOL  _shakeToChangeTheme;                  /*摇晃切换地图色盘: 0 关闭; 1 开启 */
    BOOL  _interfaceState;                      /*横竖屏开关: 0 关闭; 1 开启 */
    BOOL  _parkingInfo;                         /*目的地停车场推送： 0 关闭; 1 开启 */
    int   _interfaceOrientation;                /*界面方向*/
    BOOL  _mapDataUpdateReminder;               /*地图数据升级提醒开关标志: 0 关闭; 1 开启 */
    int   _ttsRoleIndex;                        /*语音播放角色索引*/
    int   _UILanguage;                          /*当前语言: 0 简体; 1 繁体; 2 英文 */
    BOOL  _travelUpdate;                        /*数据管理界面是否显示更新按钮: 0 关闭; 1 开启 */
    BOOL  _setLanguageManually;                 /*手动设置了导航语言: 0 否; 1 是 */
    BOOL  _set95190;                            /*是否开启95190: 0 关闭; 1 开启 */ 
    BOOL  _speakTraffic;                        /*路况播报: 0 关闭; 1 开启 */
    BOOL  _trafficMessage;                      /*路况信息条: 0 关闭; 1 开启 */
    int   _PSCountOfUnread;                     /*未读用户反馈回复*/
    BOOL  _PSNewCustomerServicePrompt;          /*新的客服提示: 0 无; 1 有 */
    BOOL  _trafficEvent;                        /*交通事件显示: 0 关闭; 1 开启 */
    BOOL  _firstStart;                          /*是否第一次进入程序: 0 否; 1 是 */
    BOOL  _backgroundDownload;                  /*后台数据下载: 0 关闭; 1 开启 */
    BOOL  _realTimeTraffic;                     /*实时交通开关: 0 关闭; 1 开启 */
    BOOL  _HUDDisplayOrientation;               /*HUD图面: 0 反向显示; 1 正向显示 */
    BOOL  _autoGetPOIInfo;                      /*自动获取poi详情: 0 关闭; 1 开启 */
    NSString *_mapVersion;                      /*地图数据版本*/
    NSString *_deviceToken;                     /*设备令牌*/
    BOOL  _isFirstEnterSkin;                    /*是否是第一次进入皮肤的view: 0 否; 1 是 */
    int   _skinType;                            /*当前使用皮肤的类型*/
    BOOL  _isOldUser;                           /*当前用户是老用户还是新用户（升级上来的用户既为老用户，第一次安装为新用户）: 0 新用户; 1 老用户 */
    int   _nextHightPraiseCount;                /*下次好评点击次数（用户点击“下次好评”两次后，不再弹出提醒）*/
    BOOL  _switchedVoice;                       /*开机语音开关: 0 关闭; 1 开启 */
    BOOL  _isPowerVoicePlay;                    /*开机下载语音播报: 0 未播报; 1 已播报 */
    int   _powerVoiceID;                        /*开机下载语音ID*/
    int   _isLZLDialect;                        /*是否为林志玲语音: 0 否; 1 是 */
    BOOL  _searchType;                          /*优先使用搜索类型: 0 优先使用网络搜索; 1 优先使用本地搜索 */
    BOOL  _autoDrivingTrack;                    /*是否自动显示打分界面: 0 是; 1 否 */
    BOOL  _backgroundNavi;                      /*是否开启后台导航: 0 否; 1 是 */
    int   _demoMode;                            /*模拟导航模式: 0 一般连续模拟模式; 1 跳跃模拟模式 */
    int   _autoZoom;                            /*导航时地图是否自动缩放: 0 否; 1 是 */
}

@property (nonatomic,copy) NSString *mapVersion;
@property (nonatomic,copy,setter = setDeviceToken:) NSString *deviceToken;

+(MWPreference *)sharedInstance;
+(void)releaseInstance;

/**********************************************************************
 * 函数名称: loadPreference
 * 功能描述: 读取参数
 * 输入参数:  
 * 输出参数:
 * 返 回 值: 成功返回YES, 失败返回NO
 **********************************************************************/
-(BOOL)loadPreference;

/**********************************************************************
 * 函数名称: savePreference
 * 功能描述: 保存参数
 * 输入参数:
 * 输出参数:
 * 返 回 值: 成功返回YES, 失败返回NO
 **********************************************************************/
-(BOOL)savePreference;

/**********************************************************************
 * 函数名称: getValue
 * 功能描述: 获取参数值
 * 输入参数: type:参数类型
 * 输出参数: 
 * 返 回 值: 对应类型参数值
 **********************************************************************/
-(int)getValue:(PRETYPE)type;

/**********************************************************************
 * 函数名称: setValue:(PRETYPE)type value:(NSInteger)value
 * 功能描述: 设置参数
 * 输入参数: type:参数类型 value:参数值
 * 输出参数: 
 * 返 回 值: 成功返回YES, 失败返回NO
 **********************************************************************/
-(int)setValue:(PRETYPE)type Value:(NSInteger)value;

/**********************************************************************
 * 函数名称: reset
 * 功能描述: 还原参数
 * 输入参数:
 * 输出参数:
 * 返 回 值: 成功返回YES, 失败返回NO
 **********************************************************************/
-(BOOL)reset;

@end

//
//  ANSettingHeader.h
//  ProjectDemoOnlyCode
//
//  Created by autonavi\wang.weiyang on 14-11-3.
//  Copyright (c) 2014年 liyuhang. All rights reserved.
//

#ifndef ProjectDemoOnlyCode_ANSettingHeader_h
#define ProjectDemoOnlyCode_ANSettingHeader_h

struct ANSettingProperty{
    int defaultValue;
    int readonly;       //0为假，1为真
    __unsafe_unretained NSString    *regex;
};
typedef struct ANSettingProperty ANSettingProperty;

static inline ANSettingProperty
ANSettingPropertyMake(int defaultValue, BOOL readonly, NSString *regex)
{
    ANSettingProperty property;
    property.defaultValue   = defaultValue;
    property.readonly       = readonly;
    property.regex          = regex;
    return property;
}

#define addSettingProperty(type, defaultValue, readonly, regex) do{\
ANSettingProperty property = ANSettingPropertyMake(defaultValue, readonly, regex);\
if (self.settingDefinesDic == nil) {\
self.settingDefinesDic = [[NSMutableDictionary alloc] init];\
}\
[self.settingDefinesDic setObject:[NSValue valueWithBytes:&property objCType:@encode(ANSettingProperty)] forKey:[NSString stringWithFormat:@"%d", type]];\
}while(0)

#define initSettingProperties do{\
addSettingProperty(ANSettingTypeSpeechRecognitionEnabled, 0, 0, @"^(0|1)$");\
addSettingProperty(ANSettingTypeTTSVoiceType, 0, 0, @"^(0|1|2|3|4|5|6|7)$");\
addSettingProperty(ANSettingTypeLanguage, 0, 0, @"^(0|1|2)$");\
addSettingProperty(ANSettingTypeTrafficAlertEnabled, 0, 0, @"^(0|1)$");\
addSettingProperty(ANSettingTypeNavigateInBackgroundEnabled, 0, 0, @"^(0|1)$");\
addSettingProperty(ANSettingTypeFontSize, -1, 0, @"^(0|1|2)$");\
addSettingProperty(ANSettingTypeMapViewMode, -1, 0, @"^(0|1|2)$");\
addSettingProperty(ANSettingTypePOIDensity, -1, 0, @"^(0|1|2)$");\
addSettingProperty(ANSettingTypeDayNightMode, -1, 0, @"^(0|1|2)$");\
addSettingProperty(ANSettingTypePromptFrequency, -1, 0, @"^(0|1)$");\
addSettingProperty(ANSettingTypePOIDisplayPriority, -1, 0, @"^(0|1|2|4|8|16|32|64|128|256|512|1024|2048|4096|8192|16384|32768)$");\
addSettingProperty(ANSettingTypeBackgroundModeEnabled, -1, 0, @"^(0|1)$");\
addSettingProperty(ANSettingTypeMapCursorEnabled, -1, 0, @"^(0|1)$");\
addSettingProperty(ANSettingTypeDemoSpeed, -1, 0, @"^(/d+)$");\
addSettingProperty(ANSettingTypeMapGuidePostEnabled, -1, 0, @"^(0|1)$");\
addSettingProperty(ANSettingTypeMapGrayBackgroundEnabled, -1, 0, @"^(0|1)$");\
addSettingProperty(ANSettingTypeMapTMCMode, -1, 0, @"^(1|2)$");\
addSettingProperty(ANSettingTypeRouteMode, -1, 0, @"^(0|1|2|3)$");\
addSettingProperty(ANSettingTypeGPSEnabled, -1, 0, @"^(0|1)$");\
addSettingProperty(ANSettingTypeTrackRecordEnabled, -1, 0, @"^(0|1)$");\
addSettingProperty(ANSettingTypeVoiceEnabled, -1, 0, @"^(0|1)$");\
addSettingProperty(ANSettingTypeECompassEnabled, -1, 0, @"^(0|1)$");\
addSettingProperty(ANSettingTypeSubwayLineEnabled, -1, 0, @"^(0|1)$");\
addSettingProperty(ANSettingTypeBuildingTextureEnabled, -1, 0, @"^(0|1)$");\
addSettingProperty(ANSettingTypeAutoZoomEnabled, -1, 0, @"^(0|1)$");\
addSettingProperty(ANSettingTypeDisplayOrientation, -1, 0, @"^(0|1)$");\
addSettingProperty(ANSettingTypeSafetyInformationEnabled, -1, 0, @"^(0|1)$");\
addSettingProperty(ANSettingTypeTMCStreamEventEnabled, -1, 0, @"^(0|1)$");\
addSettingProperty(ANSettingTypeTMCEventEnabled, -1, 0, @"^(0|1)$");\
addSettingProperty(ANSettingTypeDetourMode, -1, 0, @"^(0|1|2|4|8|16|32)$");\
addSettingProperty(ANSettingTypePerspective, -1, 0, @"^(0|1)$");\
addSettingProperty(ANSettingTypeSafetyCameraAlertEnabled, -1, 0, @"^(0|1)$");\
addSettingProperty(ANSettingTypeSafetySpeedLimitAlertEnabled, -1, 0, @"^(0|1)$");\
addSettingProperty(ANSettingTypeSafetyDangerWarningAlertEnabled, -1, 0, @"^(0|1)$");\
addSettingProperty(ANSettingTypeTMCEnabled, 0, 0, @"^(0|1)$");\
}while(0)

/**
 * 设置选项
 */
typedef NS_ENUM(NSUInteger, ANSettingType) {
    /**
     *  语音识别: 0 关闭; 1 开启
     */
    ANSettingTypeSpeechRecognitionEnabled           = 0x00000000,
    /**
     *  语音播放角色索引
     */
    ANSettingTypeTTSVoiceType                       = 0x00000001,
    /**
     *  当前语言: 0 简体; 2 繁体; 1 英文
     */
    ANSettingTypeLanguage                           = 0x00000002,
    /**
     *  路况播报: 0 关闭; 1 开启
     */
    ANSettingTypeTrafficAlertEnabled                = 0x00000003,
    /**
     *  后台导航开关: 0 关闭; 1 开启
     */
    ANSettingTypeNavigateInBackgroundEnabled        = 0x00000004,
    /**
     *  字体大小: 0 小; 1 中; 2 大
     */
    ANSettingTypeFontSize                           = 0x00000005,
    /**
     *  地图模式: 0 北首朝上; 1 车首朝上; 2 3D
     */
    ANSettingTypeMapViewMode                        = 0x00000006,
    /**
     *  地图详细度: 0 详细; 1 正常; 2 简单
     */
    ANSettingTypePOIDensity                         = 0x00000007,
    /**
     *  白天黑夜模式: 0 白天; 1 黑夜; 2 自动
     */
    ANSettingTypeDayNightMode                       = 0x00000008,
    /**
     *  语音提示频率: 0 一般; 1 频繁
     */
    ANSettingTypePromptFrequency                    = 0x00000009,
    /**
     *  信息优先显示:
     */
    ANSettingTypePOIDisplayPriority                 = 0x0000000a,
    /**
     *  后台模式: 0 否; 1 是
     */
    ANSettingTypeBackgroundModeEnabled              = 0x0000000b,
    /**
     *  移图游标: 0 否; 1 是
     */
    ANSettingTypeMapCursorEnabled                   = 0x0000000c,
    /**
     *  模拟导航速度
     */
    ANSettingTypeDemoSpeed                          = 0x0000000d,
    /**
     *  高速路牌: 0 否; 1 是
     */
    ANSettingTypeMapGuidePostEnabled                = 0x0000000e,
    /**
     *  实时交通显示灰色地图: 0 否; 1 是
     */
    ANSettingTypeMapGrayBackgroundEnabled           = 0x0000000f,
    /**
     *  控制是城市TMC还是路径TMC: 1 城市TMC; 2 路径TMC
     */
    ANSettingTypeMapTMCMode                         = 0x00000010,
    /**
     *  路径规划原则: 0 推荐路线; 1 高速优先; 2 经济路线; 3 最短路线
     */
    ANSettingTypeRouteMode                          = 0x00000011,
    /**
     *  GPS开关: 0 关闭; 1 开启
     */
    ANSettingTypeGPSEnabled                         = 0x00000012,
    /**
     *  自动记录轨迹: 0 关闭; 1 开启
     */
    ANSettingTypeTrackRecordEnabled                 = 0x00000013,
    /**
     *  语音提示: 0 关闭; 1 开启
     */
    ANSettingTypeVoiceEnabled                       = 0x00000014,
    /**
     *  电子罗盘: 0 关闭; 1 开启
     */
    ANSettingTypeECompassEnabled                    = 0x00000015,
    /**
     *  地铁路线: 0 关闭; 1 开启
     */
    ANSettingTypeSubwayLineEnabled                  = 0x00000016,
    /**
     *  建筑纹理: 0 关闭; 1 开启
     */
    ANSettingTypeBuildingTextureEnabled             = 0x00000017,
    /**
     *  自动缩放: 0 关闭; 1 开启
     */
    ANSettingTypeAutoZoomEnabled                    = 0x00000018,
    /**
     *  引擎地图显示方向: 0 横屏; 1 竖屏
     */
    ANSettingTypeDisplayOrientation                 = 0x00000019,
    /**
     *  电子眼播报开关: 0 关闭; 1 开启
     */
    ANSettingTypeSafetyInformationEnabled           = 0x0000001a,
    /**
     *  交通流事件显示开关: 0 关闭; 1 开启
     */
    ANSettingTypeTMCStreamEventEnabled              = 0x0000001b,
    /**
     *  事件图标显示开关: 0 关闭; 1 开启
     */
    ANSettingTypeTMCEventEnabled                    = 0x0000001c,
    /**
     *  路径相关避让类型 	0 默认,1 渡口,2 隧道,4 桥梁,8 高架, 16 高速, 32收费
     */
    ANSettingTypeDetourMode                         = 0x0000001d,
    /**
     *  导航视角: 默认 第一视角
     */
    ANSettingTypePerspective                        = 0x0000001e,
    /**
     *  摄像头告警
     */
    ANSettingTypeSafetyCameraAlertEnabled           = 0x0000001f,
    /**
     *  限速告警
     */
    ANSettingTypeSafetySpeedLimitAlertEnabled       = 0x00000020,
    /**
     *  危险告警
     */
    ANSettingTypeSafetyDangerWarningAlertEnabled    = 0x00000021,
    /**
     *  开启实时交通
     */
    ANSettingTypeTMCEnabled                         = 0x00000022
};

/**
 * 开关/值/显示
 */
typedef NS_ENUM(NSUInteger, ANSettingEnabled) {
    /**
     *  关闭/否/隐藏
     */
    ANSettingEnabledNo  = 0,
    /**
     *  开启/是/显示
     */
    ANSettingEnabledYes = 1
    
} ;

/**
 * 语言
 */
typedef NS_ENUM(NSUInteger, ANSettingLanguage) {
    /**
     *  简体
     */
    ANSettingLanguageSimplifiedChinese  = 0,
    /**
     *  英语
     */
    ANSettingLanguageEnglish            = 1,
    /**
     *  繁体
     */
    ANSettingLanguageTriditionalChinese = 2
    
} ;

/**
 * 语音类型
 */
typedef NS_ENUM(NSUInteger, ANSettingVoiceType) {
    /**
     *  国语女声
     */
    ANSettingVoiceTypePutonghuaFemale   = 0,
    /**
     *  国语男声
     */
    ANSettingVoiceTypePutonghuaMale     = 1,
    /**
     *  台湾普通话女声
     */
    ANSettingVoiceTypeTaiwaneseFemale   = 2,
    /**
     *  粤语女声
     */
    ANSettingVoiceTypeCantoneseFemale   = 3,
    /**
     *  东北话女声
     */
    ANSettingVoiceTypeDongbeiFemale     = 4,
    /**
     *  四川话女声
     */
    ANSettingVoiceTypeSichuanFemale     = 5,
    /**
     *  湖南话男声
     */
    ANSettingVoiceTypeHunanFemale       = 6,
    /**
     *  河南话男声
     */
    ANSettingVoiceTypeHenanFemale       = 7
} ;

/**
 * 字体大小
 */
typedef NS_ENUM(NSUInteger, ANSettingFontSize) {
    /**
     * 小
     */
    ANSettingFontSizeSmall  = 0,
    /**
     * 中
     */
    ANSettingFontSizeMedium = 1,
    /**
     * 大
     */
    ANSettingFontSizeLarge  = 2
    
} ;

/**
 * 地图模式
 */
typedef NS_ENUM(NSUInteger, ANSettingMapViewMode) {
    /**
     * 北首向上
     */
    ANSettingMapViewModeNorth   = 0,
    /**
     * 车首向上
     */
    ANSettingMapViewModeCar     = 1,
    /**
     * 3D
     */
    ANSettingMapViewModeCar3D   = 2
    
} ;

/**
 * 地图详细度
 */
typedef NS_ENUM(NSUInteger, ANSettingPOIDensity) {
    /**
     * 详细
     */
    ANSettingPOIDensityDetailed = 0,
    /**
     * 正常
     */
    ANSettingPOIDensityNormal   = 1,
    /**
     * 简单
     */
    ANSettingPOIDensitySimple   = 2
    
} ;

/**
 * 白天黑夜调节模式
 */
typedef NS_ENUM(NSUInteger, ANSettingDayNightMode) {
    /**
     *  白天
     */
    ANSettingDayNightModeDay    = 0,
    /**
     *  夜晚
     */
    ANSettingDayNightModeNight  = 1,
    /**
     *  自动
     */
    ANSettingDayNightModeAuto   = 2
};

/**
 * 语音提示频率
 */
typedef NS_ENUM(NSUInteger, ANSettingPromptFrequency) {
    /**
     * 一般
     */
    ANSettingPromptFrequencyNormal      = 0,
    /**
     * 频繁
     */
    ANSettingPromptFrequencyFrequent    = 1
    
} ;

/**
 * 信息优先显示
 */
typedef NS_OPTIONS(NSInteger, ANSettingPOIDisplayPriority) {
    /**
     *  自动
     */
    ANSettingPOIDisplayPriorityAuto         = 0,
    /**
     * 加油站
     */
    ANSettingPOIDisplayPriorityGas          = 1 << 0,
    /**
     * 汽车4S
     */
    ANSettingPOIDisplayPriority4S           = 1 << 1,
    /**
     * 餐饮
     */
    ANSettingPOIDisplayPriorityCatering     = 1 << 2,
    /**
     * 商场
     */
    ANSettingPOIDisplayPriorityMarkey       = 1 << 3,
    /**
     *  超市
     */
    ANSettingPOIDisplayPrioritySupermarket  = 1 << 4,
    /**
     *  运动馆
     */
    ANSettingPOIDisplayPriorityGym          = 1 << 5,
    /**
     *  高尔夫
     */
    ANSettingPOIDisplayPriorityGolf         = 1 << 6,
    /**
     *  KTV
     */
    ANSettingPOIDisplayPriorityKTV          = 1 << 7,
    /**
     *  电影院
     */
    ANSettingPOIDisplayPriorityCinema       = 1 << 8,
    /**
     *  医院
     */
    ANSettingPOIDisplayPriorityHospital     = 1 << 9,
    /**
     *  酒店
     */
    ANSettingPOIDisplayPriorityHotel        = 1 << 10,
    /**
     *  景点
     */
    ANSettingPOIDisplayPriorityFeatureSpot  = 1 << 11,
    /**
     *  学校
     */
    ANSettingPOIDisplayPrioritySchool       = 1 << 12,
    /**
     *  停车场
     */
    ANSettingPOIDisplayPriorityParking      = 1 << 13,
    /**
     *  银行
     */
    ANSettingPOIDisplayPriorityBank         = 1 << 14,
    /**
     *  厕所
     */
    ANSettingPOIDisplayPriorityToilet       = 1 << 15,
    
} ;

/**
 * 控制是城市TMC还是路径TMC
 */
typedef NS_ENUM(NSUInteger, ANSettingMapTMCMode) {
    /**
     * 城市TMC
     */
    ANSettingMapTMCModeCity     = 0,
    /**
     * 路径TMC
     */
    ANSettingMapTMCModeRoute    = 1
    
} ;

/**
 * 引擎地图显示方向
 */
typedef NS_ENUM(NSUInteger, ANSettingDisplayOrientation) {
    /**
     * 横向
     */
    ANSettingDisplayOrientationHorizontal   = 0,
    /**
     * 纵向
     */
    ANSettingDisplayOrientationVertical     = 1
} ;

/**
 * 避让类型
 */
typedef NS_OPTIONS(NSInteger, ANSettingDetourMode) {
    /**
     *  默认
     */
    ANSettingDetourModeDefault      = 0,
    /**
     *  渡口
     */
    ANSettingDetourModeFerry        = 1 << 0,
    /**
     *  隧道
     */
    ANSettingDetourModeTunnel       = 1 << 1,
    /**
     *  桥梁
     */
    ANSettingDetourModeBridge       = 1 << 2,
    /**
     *  高架
     */
    ANSettingDetourModeViaduct      = 1 << 3,
    /**
     *  高速
     */
    ANSettingDetourModeExpressWay   = 1 << 4,
    /**
     *  收费
     */
    ANSettingDetourModeTollStation  = 1 << 5
};

/**
 * 导航视角
 */
typedef NS_ENUM(NSUInteger, ANSettingPerspective) {
    /**
     *  默认
     */
    ANSettingPerspectiveDefault = 0,
    /**
     *  第一视角
     */
    ANSettingPerspectiveFirst   = 1
    
} ;

/**
 * 安全播报类别
 */
typedef NS_ENUM(NSUInteger, ANSettingSafetyAlertMode) {
    /**
     * 不播报
     */
    ANSettingSafetyAlertModeNone        = 0,
    /**
     * 全程播报
     */
    ANSettingSafetyAlertModeAllTheWay   = 2
    
} ;

#endif

//
//  UMengEventDefine.h
//  AutoNavi
//
//  Created by huang on 14-1-2.
//
//
#import "MobClick.h"
#import "UMengStatistics.h"
#ifndef AutoNavi_UMengEventDefine_h
#define AutoNavi_UMengEventDefine_h
/*************主地图****************/

#pragma mark -
#pragma mark 搜索的次数
/*
搜索的次数	SearchCount
搜索---地图上方	SearchFromMap
*/
#define UM_EVENTID_SEARCH_COUNT             @"SearchCount"
#define UM_LABEL_SEARCH_FROM_MAP            @"SearchFromMap"

#pragma mark -
#pragma mark 周边的次数
/*
 周边的次数	NearByCount	
 附近	NearByFromMain
 周边---地图上的信息面板中	NearByFromPOI
 周边---导航时工具栏	NearByFromNaviToolbar
*/
#define UM_EVENTID_NEARBY_COUNT             @"NearByCount"
#define UM_LABEL_NEARBY_FROM_MAIN           @"NearByFromMain"
#define UM_LABEL_NEARBY_FROM_POI            @"NearByFromPOI"
#define UM_LABEL_NEARBY_FROM_NAVI_TOOL_BAR  @"NearByFromNaviToolbar"

#pragma mark -
#pragma mark 服务的次数
/*
 服务---主地图界面 	ServiceCount
 */
#define UM_EVENTID_SERVICE_COUNT             @"ServiceCount"

#pragma mark -
#pragma mark 导航的次数
/*
 导航的次数	NaviCount	
 导航---搜索类表	NaviFromSearch
 导航---周边搜索类表	NaviFromNearBy
 导航---地图上的信息面板中	NaviFromPOI
 导航---POI详情面板中的设终点	NaviFromPOIDetail
 导航---地图选点	NaviFromMapMark
 导航---语音搜索类表	NaviFromVoice
*/
#define UM_EVENTID_NAVI_COUNT               @"NaviCount"
#define UM_LABEL_NAVI_FROM_SEARCH           @"NaviFromSearch"
#define UM_LABEL_NAVI_FROM_NEARBY           @"NaviFromNearBy"
#define UM_LABEL_NAVI_FROM_POI              @"NaviFromPOI"
#define UM_LABEL_NAVI_FROM_POI_DETAIL       @"NaviFromPOIDetail"
#define UM_LABEL_NAVI_FROM_MAP_MARK         @"NaviFromMapMark"
#define UM_LABEL_NAVI_FROM_VOICE            @"NaviFromVoice"

#pragma mark -
#pragma mark 放大缩小的次数
/*
 放大缩小的次数	ZoomCount	
 主地图界面放大缩小---点击按钮	ZoomFromTouch
 主地图界面放大缩小---手势缩放	ZoomFromGesture
*/
#define UM_EVENTID_ZOOM_COUNT               @"ZoomCount"
#define UM_LABEL_ZOOM_FROM_TOUCH            @"ZoomFromTouch"
#define UM_LABEL_ZOOM_FROM_GESTURE          @"ZoomFromGesture"

#pragma mark -
#pragma mark 实时交通开启的时间
/*
 实时交通开启的时间	TrafficTimeBucket
 时间点	0
 1
 2
 3
 4
 5
 6
 7
 8
 9
 10
 11
 12
 13
 14
 15
 16
 17
 18
 19
 20
 21
 22
 23
 */
#define UM_EVENTID_TRAFFIC_TIME_BUCKET      @"TrafficTimeBucket"
#define UM_LABEL_BUCKET_0                   @"0"
#define UM_LABEL_BUCKET_1                   @"1"
#define UM_LABEL_BUCKET_2                   @"2"
#define UM_LABEL_BUCKET_3                   @"3"
#define UM_LABEL_BUCKET_4                   @"4"
#define UM_LABEL_BUCKET_5                   @"5"
#define UM_LABEL_BUCKET_6                   @"6"
#define UM_LABEL_BUCKET_7                   @"7"
#define UM_LABEL_BUCKET_8                   @"8"
#define UM_LABEL_BUCKET_9                   @"9"
#define UM_LABEL_BUCKET_10                  @"10"
#define UM_LABEL_BUCKET_11                  @"11"
#define UM_LABEL_BUCKET_12                  @"12"
#define UM_LABEL_BUCKET_13                  @"13"
#define UM_LABEL_BUCKET_14                  @"14"
#define UM_LABEL_BUCKET_15                  @"15"
#define UM_LABEL_BUCKET_16                  @"16"
#define UM_LABEL_BUCKET_17                  @"17"
#define UM_LABEL_BUCKET_18                  @"18"
#define UM_LABEL_BUCKET_19                  @"19"
#define UM_LABEL_BUCKET_20                  @"20"
#define UM_LABEL_BUCKET_21                  @"21"
#define UM_LABEL_BUCKET_22                  @"22"
#define UM_LABEL_BUCKET_23                  @"23"

#pragma mark -
#pragma mark 添加中途点的次数
/*
添加中途点的次数	AddWayPointCount	
中途点---搜索	AddFromSearch
中途点---收藏夹	AddFromFav
中途点---地图选点	AddFromMapMark
中途点---历史目的地	AddFromHistory
 */
#define UM_EVENTID_ADD_WAY_POINT_COUNT      @"AddWayPointCount"
#define UM_LABEL_ADD_FROM_SEARCH            @"AddFromSearch"
#define UM_LABEL_ADD_FROM_FAV               @"AddFromFav"
#define UM_LABEL_ADD_FROM_MAP_MARK          @"AddFromMapMark"
#define UM_LABEL_ADD_FROM_HISTORY           @"AddFromHistory"

#pragma mark -
#pragma mark 路径规划原则的次数
/*
路径规划原则的次数	RoutePlanningCount	
规划原则---推荐	NaviDefault
规划原则---高速	NaviHighway
规划原则---经济	NaviEconomict
规划原则---最短	NaviShortest
 */
#define UM_EVENTID_ROUTE_PLANNING_COUNT     @"RoutePlanningCount"
#define UM_LABEL_NAVI_DEFAULT               @"NaviDefault"
#define UM_LABEL_NAVI_ECONOMIC              @"NaviEconomic"
#define UM_LABEL_NAVI_SHORTEST              @"NaviShortest"
#define UM_LABEL_NAVI_HIGHWAY               @"NaviHighway"


#pragma mark -
#pragma mark 导航各视图使用的时间+巡航各视图使用的时间
//导航视图使用时间跟巡航视图使用时间的label字段使用相用的宏
/*
导航各视图使用的时间	NaviViewTime	
导航视图----北首上	NorthUp
导航视图----车首上	Heading
导航视图----3D	3D
 */
#define UM_EVENTID_NAVI_VIEW_TIME           @"NaviViewTime"
//#define UM_LABEL_NORTH_UP                   @"NorthUp"
//#define UM_LABEL_HEADING                    @"Heading"
//#define UM_LABEL_3D                         @"3D"
/*
巡航各视图使用的时间	CruiseViewsTime	
巡航视图----北首上	NorthUp
巡航视图----车首上	Heading
巡航视图----3D	3D
 */
#define UM_EVENTID_CRUISE_VIEW_TIME         @"CruiseViewsTime"
#define UM_LABEL_NORTH_UP                   @"NorthUp"
#define UM_LABEL_HEADING                    @"Heading"
#define UM_LABEL_3D                         @"3D"

#pragma mark -
#pragma mark 点详情的使用情况
/*
 点详情的使用次数     POIDetailCount
 设为起点---点详情     SetStart
 设为终点---点详情     SetEnd
 设为家---点详情      SetHome
 设为公司---点详情     SetCompany
 收藏---点详情        Favorites
 致电---点详情        Phone
 分享短信---点详情     Message
 分享微博---点详情     Weibo
 分享微信---点详情     Weixin
 分享朋友圈---点详情	Friend
 */
#define UM_EVENTID_POI_DETAIL_COUNT    @"POIDetailCount"
#define UM_LABEL_POI_DETAIL_SET_START             @"SetStart"
#define UM_LABEL_POI_DETAIL_SET_END               @"SetEnd"
#define UM_LABEL_POI_DETAIL_SET_HOME              @"SetHome"
#define UM_LABEL_POI_DETAIL_SET_COMPANY           @"SetCompany"
#define UM_LABEL_POI_DETAIL_FAVORITES             @"Favorites"
#define UM_LABEL_POI_DETAIL_PHONE                 @"Phone"
#define UM_LABEL_POI_DETAIL_MESSAGE               @"Message"
#define UM_LABEL_POI_DETAIL_WEIBO                 @"Weibo"
#define UM_LABEL_POI_DETAIL_WEIXIN                @"Weixin"
#define UM_LABEL_POI_DETAIL_FRIEND                @"Friend"


/***************************主地图****************************/


/***************************导航****************************/
#pragma mark -
#pragma mark 导航时长分布
/*
导航时长分布	NaviTime	
本地数据巡航时长	LocalCruise
网络数据巡航时长	NetworkCruise
本地数据导航时长	LocalNavi
网络数据导航时长	NetworkNavi
 */
#define UM_EVENTID_NAVI_TIME                @"NaviTime"
#define UM_LABEL_LOCAL_CRUISE               @"LocalCruise"
#define UM_LABEL_NETWORK_CURISE             @"NetworkCruise"
#define UM_LABEL_LOCAL_NAVI                 @"LocalNavi"
#define UM_LABEL_NETWORK_NAVI               @"NetworkNavi"

#pragma mark -
#pragma mark 实时交通使用的时长
/*TrafficTime	实时交通使用的时长*/
#define UM_EVENTID_TRAFFIC_TIME             @"TrafficTime"

#pragma mark -
#pragma mark 车主服务
/*
车主服务	VehicleOwnerServicesCount	
点击人工导航的次数	ArtificialNavi
违章查询使用的次数	ViolationQueries
 */
#define UM_EVENTID_VEHICLE_OWNER_SERVICES_COUNT @"VehicleOwnerServicesCount"
#define UM_EVENTID_DOWNLOAD                 @"安装"
#define UM_EVENTID_REMOVE                   @"移除"
#define UM_EVENTID_UPDATE                   @"升级"
#define UM_EVENTID_USE                      @"点击"


#define UM_LABEL_ARTIFICIAL_NAVI            @"ArtificialNavi"
#define UM_LABEL_VIOLATION_QUERIES          @"ViolationQueries"

#pragma mark -
#pragma mark 主题
/*
主题	ThemesCount	
粉色皮肤下载的次数	PinkDownload
粉色皮肤更新的次数	PinkUpdate
粉色皮肤删除的次数	PinkDelete
马年皮肤下载的次数	HorseDownLoad
马年皮肤更新的次数	HorseUpdate
马年皮肤删除的次数	HorseDelete
 */
#define UM_EVENTID_THEMESCOUNT              @"ThemesCount"
#define UM_EVENTID_THEMESCOUNT_DOWNLOAD     @"下载"
#define UM_EVENTID_THEMESCOUNT_UPDATE       @"更新"
#define UM_EVENTID_THEMESCOUNT_DELETE       @"删除"



#define UM_LABEL_PINK_DOWNLOAD              @"PinkDownload"
#define UM_LABEL_PINK_UPDATE                @"PinkUpdate"
#define UM_LABEL_PINK_DELETE                @"PinkDelete"
#define UM_LABEL_HORSE_DOWNLOAD             @"HorseDownLoad"
#define UM_LABEL_HORSE_UPDATE               @"HorseUpdate"
#define UM_LABEL_HORSE_DELETE               @"HorseDelete"

#pragma mark -
#pragma mark 导航距离
/*
导航距离	NaviDistanceCount	
5公里以下     Below5Km
5-10公里     5Km-10Km
10-15公里	10Km-15Km
15-20公里	15Km-20Km
20-25公里	20Km-25Km
25公里以上	Above25Km
 */
#define UM_EVENTID_NAVI_DISTANCE_COUNT      @"NaviDistanceCount"
#define UM_LABEL_BELOW_5KM                  @"Below5Km"
#define UM_LABEL_5KM_10KM                   @"5Km-10Km"
#define UM_LABEL_10KM_15KM                  @"10Km-15Km"
#define UM_LABEL_15KM_20KM                  @"15Km-20Km"
#define UM_LABEL_20KM_25KM                  @"20Km-25Km"
#define UM_LABEL_ABOVE_25KM                 @"Above25Km"

#pragma mark -
#pragma mark 导航中偏航的次数
/*
导航中偏航的次数	RecalculationCount	
0   0
1	1
2	2
3	3
4	4
5	5
5次以上	Above5
 */
#define UM_EVENTID_RECALCULATION_COUNT      @"RecalculationCount"
#define UM_LABEL_RECALCULATION_0            @"0"
#define UM_LABEL_RECALCULATION_1            @"1"
#define UM_LABEL_RECALCULATION_2            @"2"
#define UM_LABEL_RECALCULATION_3            @"3"
#define UM_LABEL_RECALCULATION_4            @"4"
#define UM_LABEL_RECALCULATION_5            @"5"
#define UM_LABEL_RECALCULATION_ABOVE_5      @"Above5"

#pragma mark -
#pragma mark 路线规划界面的点击
/*
 路线规划界面的点击的次数	RoutePlanningViewCount
 返回---路线规划	    Back
 导航---路线规划	    Navi
 添加途经点---路线规划	Add
 模拟导航---路线规划	Demo
 路线详情---路线规划	RouteDetail
 设起点               NaviSetStart
 设终点               NaviSetEnd
 清空历史路线          ClearHistoryLine
 回家                 GoHome
 去公司               GoCompany
 
 立即启用---路线规划        RoutePathRightNow
 立即启用--网络连接失败的次数 NetErrorRightNow
 */
#define UM_EVENTID_ROUTE_PLANNING_VIEW_COUNT         @"RoutePlanningViewCount"
#define UM_LABEL_ROUTE_PLANNING_VIEW_BACK            @"Back"
#define UM_LABEL_ROUTE_PLANNING_VIEW_Navi            @"Navi"
#define UM_LABEL_ROUTE_PLANNING_VIEW_Add             @"Add"
#define UM_LABEL_ROUTE_PLANNING_VIEW_Demo            @"Demo"
#define UM_LABEL_ROUTE_PLANNING_VIEW_RouteDetail     @"RouteDetail"
#define UM_LABEL_NaviSetStart                      @"NaviSetStart"
#define UM_LABEL_NaviSetEnd                        @"NaviSetEnd"
#define UM_LABEL_ClearHistoryLine                  @"ClearHistoryLine"
#define UM_LABEL_GoHome                            @"GoHome"
#define UM_LABEL_GoCompany                         @"GoCompany"

#define UM_LABEL_RoutePathRightNow                 @"RoutePathRightNow"
#define UM_LABEL_NetErrorRightNow                  @"NetErrorRightNow"
#pragma mark -
#pragma mark 导航菜单栏的使用情况
/*
 导航菜单栏的使用的次数       NaviMenuBarCount
 结束导航---导航菜单栏       FinishNavi
 事件上报---导航菜单栏       ReportEvent
 周边查询---导航菜单栏       NearBy
 添加途经点---导航菜单栏     AddViaPoint
 导航设置---导航菜单栏       NaviSet
 路线规划---导航菜单栏       RoutePlanRule
 添加电子眼---导航菜单栏     AddCamera
 
 到达目的地自动结束导航次数   EndNaviGationCount
 */
#define UM_EVENTID_NaviMenuBar_COUNT            @"NaviMenuBarCount"
#define UM_LABEL_NaviMenuBar_FinishNavi         @"FinishNavi"
#define UM_LABEL_NaviMenuBar_NearBy             @"NearBy"
#define UM_LABEL_NaviMenuBar_AddViaPoint        @"AddViaPoint"
#define UM_LABEL_NaviMenuBar_NaviSet            @"NaviSet"
#define UM_LABEL_NaviMenuBar_RoutePlanRule      @"RoutePlanRule"
#define UM_LABEL_NaviMenuBar_AddCamera          @"AddCamera"
#define UM_LABEL_NaviMenuBar_EndNaviGationCount  @"EndNaviGationCount"
#define UM_LABEL_NaviMenuBar_OpenSound          @"OpenSoundCount"
#define UM_LABEL_NaviMenuBar_CloseSound         @"CloseSoundCount"


#pragma mark -
#pragma mark 周边的次数
/*
 周边的次数           AroundCount
 加油站---周边搜索     GasStation 
 停车场---周边搜索     Park
 餐饮美食---周边搜索	Food
 酒店住宿---周边搜索	Hotel
 商场购物---周边搜索	Shopping
 风景名胜---周边搜索	ScenicSpot
 交通服务---周边搜索	Traffic
 金融服务---周边搜索	Financial
 大厦楼宇---周边搜索	Building
 休闲娱乐---周边搜索	Entertainment
 公司企业---周边搜索	Company
 汽车服务---周边搜索	Car
 生活服务---周边搜索	Life
 医院药房---周边搜索	Hospital
 政府机关---周边搜索	Government

 */
#define UM_EVENTID_AROUND_COUNT             @"AroundCount"
#define UM_LABEL_AROUND_GasStation          @"GasStation"
#define UM_LABEL_AROUND_Park                @"Park"
#define UM_LABEL_AROUND_Food                @"Food"
#define UM_LABEL_AROUND_Hotel               @"Hotel"
#define UM_LABEL_AROUND_Shopping            @"Shopping"
#define UM_LABEL_AROUND_ScenicSpot          @"ScenicSpot"
#define UM_LABEL_AROUND_Traffic             @"Traffic"
#define UM_LABEL_AROUND_Financial           @"Financial"
#define UM_LABEL_AROUND_Building            @"Building"
#define UM_LABEL_AROUND_Entertainment       @"Entertainment"
#define UM_LABEL_AROUND_Company             @"Company"
#define UM_LABEL_AROUND_Car                 @"Car"
#define UM_LABEL_AROUND_Life                @"Life"
#define UM_LABEL_AROUND_Hospital            @"Hospital"
#define UM_LABEL_AROUND_Government          @"Government"

#pragma mark -
#pragma mark 沿途周边的次数

/*
 沿途周边的次数            WayAroundCount
 沿途周边---加油站         GasStation
 沿途周边---餐饮美食        Food
 沿途周边---风景名胜        ScenicSpot
 沿途周边---公共厕所        Toilet
 沿途周边---酒店住宿        Hotel
 */

#define UM_EVENTID_WayAround_Count             @"WayAroundCount"
#define UM_LABEL_WayAround_GasStation          @"GasStation"
#define UM_LABEL_WayAround_Food                @"Food"
#define UM_LABEL_WayAround_ScenicSpot          @"ScenicSpot"
#define UM_LABEL_WayAround_Toilet              @"Toilet"
#define UM_LABEL_WayAround_Hotel               @"Hotel"

#pragma mark -
#pragma mark 目的地停车场推送的次数

/*
 目的地停车场推送            ParkPushCount
 点击推送停车场的次数         PushPark
 点击就停这里的次数          ParkHere
 点击查看位置的次数          LookLocation
 */

#define UM_EVENTID_ParkPush_Count               @"ParkPushCount"
#define UM_LABEL_ParkPush_PushPark              @"PushPark"
#define UM_LABEL_ParkPush_ParkHere              @"ParkHere"
#define UM_LABEL_ParkPush_LookLocation          @"LookLocation"

#pragma mark -
#pragma mark 沿途天气的次数

/*
 沿途天气的次数            WayWeatherCount
 路线规划---沿途天气        WayWeather
 */

#define UM_EVENTID_WayWeather_Count             @"WayWeatherCount"
#define UM_LABEL_WayWeather_WayWeather          @"WayWeather"

/***************************导航****************************/


/***************************设置****************************/

#pragma mark -
#pragma mark 设置的点击量
/*
 设置点击的次数             SettingCount
 地图下载---设置            DownData
 主题---设置               Theme
 消息盒子---设置            Box
 关于高德导航---设置         About
 喜欢高德给高德好评---设置	  Rate
 意见反馈---设置            Feedback
 语音播报---设置            Voice
 地点优先显示---设置         Prioritize
 偏好设置---设置            Preferences
 收藏点---设置              Favorites
 历史目的地---设置           History
 电子眼---设置             Camera
 行车轨迹---设置            TrackRecording
 其他---设置               Other
 */
#define UM_EVENTID_SETTING_COUNT            @"SettingCount"
#define UM_LABEL_SETTING_DownData           @"DownData"
#define UM_LABEL_SETTING_Theme              @"Theme"
#define UM_LABEL_SETTING_Box                @"Box"
#define UM_LABEL_SETTING_About              @"About"
#define UM_LABEL_SETTING_Rate               @"Rate"
#define UM_LABEL_SETTING_Feedback           @"Feedback"
#define UM_LABEL_SETTING_Voice              @"Voice"
#define UM_LABEL_SETTING_Prioritize         @"Prioritize"
#define UM_LABEL_SETTING_Preferences        @"Preferences"
#define UM_LABEL_SETTING_Favorites          @"Favorites"
#define UM_LABEL_SETTING_History            @"History"
#define UM_LABEL_SETTING_Camera             @"Camera"
#define UM_LABEL_SETTING_TrackRecording     @"TrackRecording"
#define UM_LABEL_SETTING_Other              @"Other"



#pragma mark -
#pragma mark 同步点信息
/*
 同步点信息的次数             SyncPOICount
 收藏点---同步               Favorites
 历史目的地---同步            History
 电子眼---同步               Camera
 */
#define UM_EVENTID_SyncPOI_COUNT            @"SyncPOICount"
#define UM_LABEL_SyncPOI_Favorites          @"Favorites"
#define UM_LABEL_SyncPOI_History            @"History"
#define UM_LABEL_SyncPOI_Camera             @"Camera"


#pragma mark -
#pragma mark 偏好设置的情况
/*
 偏好设置的次数        PreferencesCount
 中文简体--语言设置	Hans
 中文繁体--语言设置	Hant
 英文--语言设置       English
 大---字体大小        LargeFont
 中---字体大小        MidFont
 小---字体大小        SmallFont
 白天---昼夜模式       LightMode
 黑夜---昼夜模式       NightMode
 自动---昼夜模式       AutoMode
 开---锁定屏幕        OpenLockRotation
 关---锁定屏幕        CloseLockRotation
 开---交通事件        OpenTrafficEvent
 开---街区详图        OpenBlock
 关---街区详图        CloseBlock
 开---电子罗盘车标     OpenCompass
 关---电子罗盘车标     CloseCompass
 开---自动获取点信息	 OpenAutoObtain
 关---自动获取点信息	 CloseAutoObtain
 开---摇晃切换色盘      OpenSwitchTheme
 关---摇晃切换色盘      CloseSwitchTheme
 开---后台导航         OpenBackgroundNavi
 关---后台导航         CloseBackgroundNavi
 开---后台下载         OpenBackgroundDown
 关---后台下载         CloseBackgroundDown
 开---GPS开关          OpenGPS
 关---GPS开关          CloseGPS
 */
#define UM_EVENTID_Preferences_COUNT                    @"PreferencesCount"
#define UM_LABEL_Preferences_Hans                       @"Hans"
#define UM_LABEL_Preferences_Hant                       @"Hant"
#define UM_LABEL_Preferences_English                    @"English"
#define UM_LABEL_Preferences_LargeFont                  @"LargeFont"
#define UM_LABEL_Preferences_MidFont                    @"MidFont"
#define UM_LABEL_Preferences_SmallFont                  @"SmallFont"
#define UM_LABEL_Preferences_LightMode                  @"LightMode"
#define UM_LABEL_Preferences_NightMode                  @"NightMode"
#define UM_LABEL_Preferences_AutoMode                   @"AutoMode"
#define UM_LABEL_Preferences_OpenLockRotation           @"OpenLockRotation"
#define UM_LABEL_Preferences_CloseLockRotation          @"CloseLockRotation"
#define UM_LABEL_Preferences_OpenTrafficEvent           @"OpenTrafficEvent"
#define UM_LABEL_Preferences_OpenBlock                  @"OpenBlock"
#define UM_LABEL_Preferences_CloseBlock                 @"CloseBlock"
#define UM_LABEL_Preferences_OpenCompass                @"OpenCompass"
#define UM_LABEL_Preferences_CloseCompass               @"CloseCompass"
#define UM_LABEL_Preferences_OpenAutoObtain             @"OpenAutoObtain"
#define UM_LABEL_Preferences_CloseAutoObtain            @"CloseAutoObtain"
#define UM_LABEL_Preferences_OpenSwitchTheme            @"OpenSwitchTheme"
#define UM_LABEL_Preferences_CloseSwitchTheme           @"CloseSwitchTheme"
#define UM_LABEL_Preferences_OpenBackgroundNavi         @"OpenBackgroundNavi"
#define UM_LABEL_Preferences_CloseBackgroundNavi        @"CloseBackgroundNavi"
#define UM_LABEL_Preferences_OpenBackgroundDown         @"OpenBackgroundDown"
#define UM_LABEL_Preferences_CloseBackgroundDown        @"CloseBackgroundDown"
#define UM_LABEL_Preferences_OpenGPS                    @"OpenGPS"
#define UM_LABEL_Preferences_CloseGPS                   @"CloseGPS"


#pragma mark -
#pragma mark 行驶里程的次数

/*
 行驶里程的次数              MileageCount
 设置---行驶里程的次数       SetMileage
 行驶里程---榜单            MileageList
 行驶里程---分享            MileageShare
 
 行驶里程---打分            MileageShareGrade
 行驶里程---分享到朋友圈     MileageShareFriend
 行驶里程---微信           MileageShareWeChat
 行驶里程---微博           MileageShareWeibo
 行驶里程---短信           MileageShareMessage
 行驶里程---打分详情        MileageShareGradeDetail
 */

#define UM_EVENTID_Mileage_Count               @"MileageCount"
#define UM_LABEL_Mileage_SetMileage            @"SetMileage"
#define UM_LABEL_Mileage_MileageList           @"MileageList"
#define UM_LABEL_Mileage_MileageShare          @"MileageShare"

#define UM_LABEL_Mileage_ShareGrade           @"MileageShareGrade"
#define UM_LABEL_Mileage_ShareFriend          @"MileageShareFriend"
#define UM_LABEL_Mileage_ShareWeChat          @"MileageShareWeChat"
#define UM_LABEL_Mileage_ShareWeibo           @"MileageShareWeibo"
#define UM_LABEL_Mileage_Message              @"MileageShareMessage"
#define UM_LABEL_Mileage_GradeDetail          @"MileageShareGradeDetail"
/***************************设置****************************/

#endif



#pragma mark -
#pragma mark 个人中心
/*
 点击个人中心的次数                  PersonalCenterCount
 点击每条驾驶轨迹的查看详情的次数       TrackDetailCount
 点击查看每条驾驶轨迹的次数          TrackViewCount
 点击进入驾驶轨迹列表的次数          TrackListCount
 点击进入驾驶轨迹中删除的次数         DeleteTrackCount
 点击进入驾驶轨迹中分享的次数         TrackShareCount
 点击进入收藏夹列表的次数           FavListCount
 点击进入我添加的摄像头列表的次数       CameraListCount
 点击进入历史目的地列表的次数         HistoryListCcount
 点击进入备份和同步列表的次数         BackupListCount
 点击同步收藏夹的次数             SynFavCount
 点击同步我添加的摄像头的次数     SynCameraCount
 点击同步历史目的地的次数           SynHistoryCount
 点击同步历史路线的次数            SynHistoryRoutCount
 点击同步驾驶记录的次数            SynTrackRecordCount
 点击一键同步的次数              SyncAllCount
 点击注销的次数                     LogoutCount
 
 用户已登录状态                    LoginState
 */
#define UM_EVENTID_PersonalCenter_COUNT            @"PersonalCenter"
#define UM_LABEL_PersonalCenterCount                @"PersonalCenterCount"
#define UM_LABEL_TrackDetailCount                   @"TrackDetailCount"
#define UM_LABEL_TrackViewCount                     @"TrackViewCount"
#define UM_LABEL_TrackListCount                     @"TrackListCount"
#define UM_LABEL_DeleteTrackCount                   @"DeleteTrackCount"
#define UM_LABEL_TrackShareCount                    @"TrackShareCount"
#define UM_LABEL_FavListCount                       @"FavListCount"
#define UM_LABEL_CameraListCount                    @"CameraListCount"
#define UM_LABEL_HistoryListCcount                  @"HistoryListCcount"
#define UM_LABEL_BackupListCount                    @"BackupListCount"
#define UM_LABEL_SynFavCount                        @"SynFavCount"
#define UM_LABEL_SynCameraCount                     @"SynCameraCount"
#define UM_LABEL_SynHistoryCount                    @"SynHistoryCount"
#define UM_LABEL_SynHistoryRoutCount                @"SynHistoryRoutCount"
#define UM_LABEL_SynTrackRecordCount                @"SynTrackRecordCount"
#define UM_LABEL_SyncAllCount                       @"SyncAllCount"
#define UM_LABEL_LogoutCount                        @"LogoutCount"

#define UM_LABEL_LoginState                         @"LoginState"

#pragma mark
#pragma mark 导航下视图按钮的点击次数
/*
 导航下视图按钮的点击次数            NaviViewCount
 导航下---3D       Navi_3D
 导航下---北首上    Navi_NorthOn
 导航下---车首上    Navi_CarOn
 */

#define UM_UM_EVENTID_NaviViewCount_COUNT @"NaviViewCount"
#define UM_LABEL_Navi_3D                  @"Navi_3D"
#define UM_LABEL_Navi_NorthOn             @"Navi_NorthOn"
#define UM_LABEL_Navi_CarOn               @"Navi_CarOn"


#pragma mark
#pragma mark 路线规划---躲避拥堵
/*
 路线规划---躲避拥堵        ToavoidcongestionCount
 躲避拥堵                 Toavoidcongestion
 */
#define UM_UM_EVENTID_ToavoidcongestionCount_COUNT @"ToavoidcongestionCount"
#define UM_LABEL_Toavoidcongestion                 @"Toavoidcongestion"
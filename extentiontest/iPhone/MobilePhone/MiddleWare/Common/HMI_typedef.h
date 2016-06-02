//
//  HMI_typedef.h
//  AutoNavi
//
//  Created by huang longfeng on 12_12_12.
//
//

#ifndef AutoNavi_HMI_typedef_h
#define AutoNavi_HMI_typedef_h

//设置系统参数
typedef enum HMI_PARAMTYPE {
	HMI_LANGUAGE                 =0,    //语言
	HMI_FONT_SIZE			     =1,    //字体大小
	HMI_MAP_MODE		         =2,	//地图模式
	HMI_MAP_DENSITY			     =3,	//地图详细度
	HMI_DAYNIGHT_MODE			 =4,	//白天黑夜模式
	HMI_SPEAKER		             =5,	//语音选择
	HMI_PROMPT	                 =6,	//语音提示频率
	HMI_WALK_MODE	             =7,	//出行方式
	HMI_POI_PRIORITY             =8,    //信息优先显示
    HMI_BACKGROUND_MODE          =10,   //后台模式
    HMI_MAP_SHOW_CURSOR          =11,   //移图游标
    HMI_DEMO_SPEED               =12,   //模拟导航速度
    HMI_SHOW_GUIDEPOST           =13,   //高速路牌显示
    HMI_SHOW_SAFETY_ICON         =14,   //电子狗图标
    HMI_SHOW_MAP_GRAY_BKGND      =15,   //实时交通地图显示灰色
    HMI_MAP_TMC_SHOW_OPTION      =16,   //控制是城市TMC还是路径线TMC
    HMI_INTERFACE_ORIENTATION    =20,   //横竖屏方向
    HMI_ROUTE_OPTION             =30,   //路径规划原则
    HMI_CTRIP_SWITCH             =500,  //携程服务开关
    HMI_VOICE_REC_SWITCH         =501,  //语音识别开关
    HMI_TXWEIBO_BIND             =502,  //腾迅微博绑定
    HMI_XLWEIBO_BIND             =503,  //新浪微博绑定
    HMI_TXWEIBO_SYNC             =504,  //腾迅微博同步到高德
    HMI_XLWEIBO_SYNC             =505,  //新浪微博同步到高德
    HMI_NEWFUN_VIEW              =506,  //功能里的新功能是否查看
    HMI_NEWFUN_FIRST             =507,  //开机新功能是否查看
    HMI_MAPUPGRADE_NEWIMG        =508,  //地图数据升级new图标显示标志
    HMI_UPGRADEDATA_REMINDER     =509,  //地图数据升级提醒开关标志
    HMI_GPS                      =510,  //gps开关
    HMI_TRACK_RECORD             =511,  //自动记录轨迹
    HMI_MAP_SHOW_BLOCK           =512,  //街区图开关
    HMI_VOICE_REMINDER           =513,  //语音提示开关
    HMI_SHAKE_CHANGE_COLOR       =514,  //摇晃地图配色开关
    HMI_ALERT_REMINDER           =515,  //警告提示开关
    HMI_3D_SHOW                  =516,  //3d显示开关
    HMI_ECOMPASS                 =517,  //电子罗盘开关
    HMI_INTERFACE_SWITCH         =518,  //横竖屏开关
    HMI_ORIENTATION              =519,  //界面方向
    HMI_BACKNAVI                 =521,  //后台导航
    HMI_TRAFFICEVENTS                   =522,  //交通事件显示
    HMI_GDPUSH                   =530,  //高德push标志
    HMI_POSITIONPUSH             =531,  //位置推送标志
    HMI_WESHARE_NEWIMG           =532,  //主界面微享new显示标志
    HMI_NEWIMG_CLICK             =533,  //功能按钮new点击标志
    HMI_LAYER_TRAVEL_NEWIMG_CIK  =534,  //图层旅游数据new点击标志
    HMI_DATAMAG_TRAVEL_NEWIMG_CIK=535,  //数据管理旅游数据new点击标志
    HMI_TRAVEL_UPDATE            =536,  //旅游数据界面是否显示更新按钮
    HMI_LAYER_FOOD               =600,  //餐饮图层
    HMI_LAYER_TRAVEL             =601,  //旅游图层
    HMI_CLIENT_UGC               =602,  //客户ugc
    HMI_LAYER_GOLF               =603,  //高尔夫球会
    HMI_SPEAKERTRAFFIC           =604,  //路况播报开关
    HMI_TRAFFICMESSAGE           =605,  //路况信息条
    HMI_95190                    =95190, //95190拨打
    HMI_isFirstStart            = 800, // 是否第一次进入程序
    HMI_isFirstEnterSetUpView   = 801, //是否第一次进入设置界面
    HMI_isBackDownload          = 900,  //是否进行后台下载
}HMI_PARAMTYPE;

typedef enum HMI_VIEWTYPE {
    HMI_NOMOVE_NOPATH_NOHIDDEN_NONAVI     =0,   //无移图无路径无隐藏无模拟导航
    HMI_YEMOVE_NOPATH_NOHIDDEN_NONAVI     =1000,//有移图无路径无隐藏无模拟导航
    HMI_NOMOVE_YEPATH_NOHIDDEN_NONAVI     =100, //无移图有路径无隐藏无模拟导航
    HMI_NOMOVE_NOPATH_YEHIDDEN_NONAVI     =10,  //无移图无路径有隐藏无模拟导航
    HMI_YEMOVE_YEPATH_NOHIDDEN_NONAVI     =1100,//有移图有路径无隐藏无模拟导航
    HMI_YEMOVE_NOPATH_YEHIDDEN_NONAVI     =1010,//有移图无路径有隐藏无模拟导航
    HMI_NOMOVE_YEPATH_YEHIDDEN_NONAVI     =110, //无移图有路径有隐藏无模拟导航
    HMI_NOMOVE_YEPATH_NOHIDDEN_YENAVI     =101, //无移图有路径无隐藏有模拟导航
    HMI_YEMOVE_YEPATH_YEHIDDEN_NONAVI     =1110,//有移图有路径有隐藏无模拟导航
    HMI_NOMOVE_YEPATH_YEHIDDEN_YENAVI     =111, //无移图有路径有隐藏有模拟导航
    HMI_YEMOVE_YEPATH_YEHIDDEN_YENAVI     =1111,//有移图有路径有隐藏有模拟导航
    HMI_NOMOVE                            =51,  //(没有移图)
    HMI_YEMOVE                            =50,  //(有移图)
    HMI_VIEWPOI                           =52,  //(POI查图)
    HMI_ISHIDDEN_NEWICON                  =53,  //功能按钮上的new图标显示与否
    HMI_ISHIDDEN_WESHARE_NEWICON          =54,  //微享按钮上的new图标显示与否
    HMI_SET_BUTTON_TITLE                  =55,  //主界面按钮字体显示
    HMI_YEPATH                            =60,  //有路径
    HMI_NOPATH                            =61,  //没有路径
    HMI_YEMOVE_YEPATH                     =62,  //有路径移图
    HMI_BUS_NOPATH                        =63,  //公交没路径
    HMI_BUS_YEPATH                        =64,  //公交有路径
    HMI_NOHIDDEN                          =71,  //显示按钮
    HMI_YEHIDDEN                          =70,  //隐藏按钮
    HMI_YENAVI                            =80,  //模拟导航
    HMI_NONAVI                            =81,  //不在模拟导航
    HMI_BUSVIEW                           =83,  //公交详情查看返回按钮显示
    HMI_HIDDEN_SCALEVIEW                  =84,  //隐藏比例尺选择按钮
    HMI_ZOOMVIEW                          =85,  //导航－出现放大路口
    HMI_GUIDEPOST                         =86,  //导航－出现高速路牌
    HMI_NAVI_NORMALVIEW                   =87   //导航恢复按钮状态
    
}HMI_VIEWTYPE;
//地图模式
typedef enum MAPTYPE {
    MAP_NORTHUP = 0, //北首朝上
    MAP_CARUP   = 1, //车首朝上
    MAP_3D      = 2  //3d
}MAPTYPE;

//字体语言
typedef enum LANGUAGE {
	LANGUAGE_SIMPLE_CHINESE      = 0, //简体
    LANGUAGE_TRADITIONAL_CHINESE = 1, //繁体
	LANGUAGE_ENGLISH             = 2  //英语
	
} LANGUAGE;

//语音
typedef enum SPEAKER {
	SPEAKER_XIAOYAN     = 0, //国语女声
    SPEAKER_XIAOFENG    = 1, //国语男声
	SPEAKER_XIAOLIN     = 2, //台湾普通话女声
	SPEAKER_XIAOMEI     = 3, //粤语女声
    SPEAKER_XIAOQIAN    = 4, //东北话女声
    SPEAKER_XIAORONG    = 5, //四川话女声
    SPEAKER_XIAOQIANG   = 6, //湖南话男声
    SPEAKER_XIAOKUN     = 7  //河南话男声
} SPEAKER;

//开关状态
typedef enum SWITCHTYPE {
	SWITCH_CLOSE    = 0,  //关闭
	SWITCH_OPEN     = 1   //打开
} SWITCHTYPE;

//出行方式
typedef enum NAVIMODE {
	NAVIMODE_CAR     = 0,   //驾车模式
	NAVIMODE_BUS     = 1    //公交模式
} NAVIMODE;

//搜索类别
typedef enum SEARCHPOITYPE{
    SEARCHPOITYPE_BY_INTELGENT_0   = 0,//智能搜索
    SEARCHPOITYPE_BY_ADDRESS_1     = 1,//门址搜索
    SEARCHPOITYPE_BY_CROSS_2       = 2,//交叉路口
    SEARCHPOITYPE_BY_NEARBY_3      = 3,//周边
    SEARCHPOITYPE_BY_CATEGARY_4    = 4,//周边类别
    SEARCHPOITYPE_BY_NET_KEYWORD_10 = 10,//关键字网络搜索
    SEARCHPOITYPE_BY_NET_ADDRESS_11 = 11,//道路名网络搜索
    SEARCHPOITYPE_BY_NET_CROSS_12  = 12,//十字路口网络搜索
    SEARCHPOITYPE_BY_NET_NEARBY_13  = 13,//周边网络搜索
}SEARCHPOITYPE;

typedef enum BUTTONTYPE {
    
    BUTTON_GOTOCCP            = 1,   //回车位
    BUTTON_VER_COLLECTPOI     = 2,   //竖屏收藏当前点
    BUTTON_SET_VIEWMODE       = 4,   //切换视图模式
    BUTTON_WESHARE            = 5,   //微享
    BUTTON_GUIDEPOST          = 24,  //高速路牌
    BUTTON_BUS_PREVIOUS       = 30,  //公交上一条
    BUTTON_BUS_NEXT           = 31,  //公交下一条
    BUTTON_BUS_TRANSFERPLAN   = 32,  //公交换乘方案
    BUTTON_BUS_DELETEROUTE    = 33,  //删除公交路线
    BUTTON_BUS_DETAIL         = 34,  //公交详情按钮
    BUTTON_ZOOMDIS            = 36,  //放大路口－距离下一路口距离
    BUTTON_ZOOMROADNAME       = 37,  //放大路口－下一路口道路名
    BUTTON_SET_PARALLELROAD   = 51,  //平行道路切换
    BUTTON_STOPNAVI           = 52,  //是否停止导航
    BUTTON_DRIVECOMPUTER      = 53,  //行车电脑
    BUTTON_NEXTROADNAME       = 54,  //下一路口道路名
    BUTTON_PARALLELROAD       = 55,  //平行道路

    BUTTON_MENUBACKGROUND     = 100, //主界面菜单背景
    BUTTON_COMMON             = 101, //常用
    BUTTON_MORE               = 102, //更多
    BUTTON_SEARCH             = 103, //搜索
    BUTTON_COLLECTPOI         = 105, //收藏当前点
    BUTTON_SIMULATOR_STOP     = 111, //停止轨迹回放或模拟导航
    BUTTON_SIMULATOR_SLOW     = 112, //模拟导航－减速
    BUTTON_SIMULATOR_PAUSE    = 113, //模拟导航－暂停－继续
    BUTTON_MOVEBACKGROUND     = 114, //移图菜单背景
    BUTTON_ENLARGEMAP         = 115, //放大
    BUTTON_MAP_BAR_GO_CAR_POSITON = 116, // 地图菜单栏回车位
    BUTTON_SET_DES            = 117, //设终点
    BUTTON_SET_PASSBY         = 118, //设途经点
    BUTTON_NARROWMAP          = 120, //缩小
    BUTTON_SIMULATOR_FAST     = 122, //模拟导航－加速
    BUTTON_SET_START          = 123, //设起点
    BUTTON_REALTRFFIC         = 124,  //实时交通详细信息
    BUTTON_HUD                = 211,  //HUD功能界面
    BUTTON_REAL_BUTTON        = 221,  //实时交通开启按钮
    BUTTON_TOP_SEARCH         = 222,  //顶部的搜索框
    BUTTON_TOP_FACEBUTTON     = 223,  //顶部的头像按钮
    BUTTON_MODE_SWITCH            = 1650, //地图模式切换按钮
    BUTTON_MODE_NORTH             = 1651, //北首上
    BUTTON_MODE_CAR               = 1652, //车首上
    BUTTON_MODE_3D                = 1653, //3D模式
    BUTTON_BACK_CAR               = 1654, //回车位
    BUTTON_GET_POIINFO            = 1656, //点击车位获取poi点信息
    BUTTON_SEARCH_SOUND           = 1657, //顶部栏的语音搜索按钮
    BUTTON_LIST_MENU         =  1658,     //列出菜单栏按钮
    BUTTON_NEARBY             = 1659,   //附近
    BUTTON_CANCEL_NEARBY    = 1660,     //取消周边
    BUTTON_LIST_WEATHER     = 1661,      //沿途天气
    BUTTON_ALLSEE             = 1662,  //全览按钮
}BUTTONTYPE;

typedef enum ALERTTYPE
{
    ALERT_ANTONAVI_SEARVICES  = 0,     //进入高德服务界面提示
    ALERT_LIFT                = 1,     //续航提示
    ALERT_BUS_DELETEROUTE     = 2,     //公交删除路径提示
    ALERT_STOPSIMULATOR       = 101,   //停止模拟导航提示
    ALERT_NONE                = 200,   //无操作
    ALERT_SET_HOME            = 201,   //设置家提示
    ALERT_SET_COMPANY         = 202,   //设置公司提示
    ALERT_RESET_HOME          = 203,   //重新设置家提示
    ALERT_RESET_COMPANY       = 204,   //重新设置公司提示
    ALERT_MESSAGEBOX_LOGON    = 301,   //微享消息盒子登陆高德帐号提示
    ALERT_95190               = 95190, //95190
    ALERT_CALL95190           = 3000,  //拨打95190
    ALERT_95190_NAVI          = 3001,  //95190信息导航
    ALERT_95190_LOGON         = 3002,  //帐号未登录提示
    ALERT_95190_NOBOUND       = 3003,  //95190未绑定提示
    ALERT_VERSION_UPDATE      = 3004,   //版本升级提示
    ALERT_BUY_95190           = 3005,  //购买95190
    ALERT_FIRST_START         = 4000,   //第一次进入程序
} ALERTTYPE;

typedef enum ACTIONSHEETTYPE {
    ACTIONSHEET_COMMON        = 0,     //常用：回家－回公司－收藏当前点－我的收藏－历史目的地
    ACTIONSHEET_COMMON_PATH   = 2,     //有路径－常用：回家－回公司－收藏当前点－我的收藏－历史目的地－路线管理
    ACTIONSHEET_ROUTE_MANAGEMENT = 4,  //路线管理：取消路线－开始模拟导航－全程概览－路线详情－多个途经点－路线规划原则
    ACTIONSHEET_SEARCHPOI     = 101    //多个途经点搜索poi设为起点终点途经点：去哪里－我的收藏－历史目的地
}ACTIONSHEETTYPE;

typedef enum HMI_UIUpdateType
{
   
    UIUpdate_MapDataDownloadFinish = 2, //地图数据下载完成
    UIUpdate_MapDataDownloadresignKeyboard = 3, //地图下载页面收缩键盘
    UIUpdate_MapDayNightModeChange = 4, //白天黑夜切换通知
    UIUpdate_TMC = 5, //实时交通
    UIUpdate_MessageMoveMap = 6,    //分享消息
    UIUpdate_MapDataDownloadUpdate = 7,   //地图数据下载更新处理
    UIUpdate_SkinTypeChange = 8 ,          //地图的皮肤数据修改
    UIUpdate_SkinNew = 9,                   //主地图界面
    UIUpdate_CarNew = 10,             //车主服务new的显示和隐藏
    UIUpdate_DialectViewProgredd = 11, //方言下载查看进度
    UIUpdate_SkinDownloadUpdate = 12, //皮肤下载更新
    UIUpdate_DialectDownloadUpdate = 13, //方言下载更新
    UIUpdate_SimNaviStop = 14,  //一次模拟导航结束
    UIUpdate_CarServiceDownloadFinish = 15, //车主服务下载完成
    UIUpdata_CarDistanceThreeKM = 16,   //距离终点剩余3km
//    UIUpdata_CarDistanceOverThreeKM = 17,   //距离终点超过3KM或者模拟导航或者到达目的地自动结束导航，隐藏目的地停车场
    UIUpdata_RedPointUpdate = 18,           //红点引导更新显示
    UIUpdata_DrivingTrack = 19,  //驾驶轨迹
    UIUpdate_MapDataChangeView = 20, //地图数据下载：下载管理和省市列表视图切换（隐藏省市列表视图导航栏右边的全部更新）
}HMI_UIUpdateType;


#endif

//
//  NetTypedef.h
//  AutoNavi
//
//  Created by yu.liao on 13-5-14.
//
//

#ifndef AutoNavi_NetTypedef_h
#define AutoNavi_NetTypedef_h

/**
 *  @brief 枚举定义
 */

#define KEY_MD5 @"Au@to&xm&Na*vi" //MD5加密密钥

typedef enum RequestType{
	RT_NORMAL                         = 0,
    RT_FeedBack_Data                  = 1, //用户信息反馈－数据问题
    RT_FeedBack_Funtion               = 2, //用户信息反馈－功能问题
    RT_FeedBack_Suggestion            = 3, //用户信息反馈－建议问题
    RT_FeedBack_QueryList             = 4, //用户信息反馈－查询回复列表
    RT_FeedBack_QueryDetail           = 5, //用户信息反馈－查询回复详情
    RT_FeedBack_Delete                = 6, //用户信息反馈－删除回复信息
    
    RT_GresourceCheck                 = 10,//Gresource后台对比
    RT_Log_Commit                     = 11,//ios 日志上传
    RT_SkinDownload                   = 12,//皮肤下载
    RT_SkinUpdate                     = 13,//皮肤更新
    RT_PowerVoiceRequest              = 14,//开机语音请求
    RT_PowerVoiceDownload             = 15,//开机语音下载
    RT_DialectRequest                 = 16,//林志玲语音请求
    
    RT_LaunchRequest_UBC              = 21,//用户行为统计上传
    RT_LaunchRequest_SoftWareUpdate   = 22,//软件升级检测
    RT_LaunchRequest_UserYawUpload    = 23,//用户偏航统计信息上传
    RT_Background_SwitchOnOff         = 24,//后台服务功能开关
    RT_Upload_Token_To_Autonavi       = 26,//上传token标志至Autonavi
    RT_DrivingTrackDownload           = 27,//驾驶轨迹文件下载
    RT_LaunchRequest_HandSoftWareUpdate = 29,//手动点击软件升级检测
    // 交通事件 上传
    RT_TRAFFIC_EVENT_VEHICLE_FAULT    = 30,//11010 故障车辆
    RT_TRAFFIC_EVENT_COLLISION        = 31,//11011 车祸
    RT_TRAFFIC_EVENT_ROAD_FAULT       = 32,//11012 路面障碍
    RT_TRAFFIC_EVENT_SOLW             = 33,//11020 缓慢
    RT_TRAFFIC_EVENT_CROWDING         = 34,//11021 拥堵
    RT_TRAFFIC_EVENT_HEAVY            = 35,//11022 阻塞
    RT_TRAFFIC_EVENT_CHECK            = 36,//11030 检查
    RT_TRAFFIC_EVENT_CONTROL          = 37,//11031 管制
    RT_TRAFFIC_EVENT_NONE             = 40,//没有选择类型
    RT_HistoryRouteSync               = 41,//历史路线同步
    // 交通事件 下传
    RT_TRAFFIC_EVEN_DOWNLOAD          = 50,// 下载数据
    RT_CarOwnerServiceRequest         = 51,//车主服务请求列表
    RT_CarOwnerServiceUnInstallRequest= 52,//车主服务未安装列表
    RT_CarOwnerServiceDetailRequest   = 53,//车主服务详情
    
    RT_MileageRequest                 = 54,//里程上传
    RT_MileageStartUpRequest          = 55,//里程开机上传
    RT_MileageURLRequest              = 56,//里程短地址url获取
    RT_RedPointURLRequest             = 57,//红点提醒
    RT_DrivingTrackSyncRequest        = 58,//驾驶记录同步
    RT_DrivingTrackShareRequest       = 59,//驾驶记录分享内容
    
    //account
	REQ_GET_AUTH_IMG	=60,
	REQ_REGIST          ,
	REQ_LOGIN			,
	REQ_LOGOUT			,
	REQ_UNBIND_TOKEN	,
	REQ_GET_PROFILE	    ,
	REQ_UPDATE_PROFILE  ,
	REQ_RESET_PWD		,
	REQ_SEND_PWD_EMAIL	,
    REQ_GET_CHECK_NUMBER	,
    REQ_BIND_PHONE_NUMBER	= 70,
    REQ_FREE_95190	,
    REQ_BIND_95190PHONE_NUMBER	,
    REQ_GET_95190PHONE_NUMBER	,
    REQ_GET_95190_DESTINATION	,
    REQ_GET_95190_STATUS	,
    REQ_BUY_95190_SERVICE	,
    REQ_ORDER_EN_CHECK	,
    REQ_PRE_CALL_95190	,
    REQ_GET_CURRENT95190_DES,
    REQ_GET_95190_TEXT	= 80,
    REQ_GET_95190_Button	,
    REQ_GET_EN_TEXT,
    REQ_CHECK_CODE,
    REQ_THIRD_LOGIN,
    REQ_UPDATE_PWD,
    REQ_GET_95190CHECK,
    REQ_OLD_USER_BIND_PHONE_NUMBER,
    REQ_UPLOAD_HEAD,
    REQ_CLEAR_95190PHONE_NUMBER,
    REQ_MODIFY_95190PHONE_NUMBER,
    REQ_GET_HEAD,
    REQ_LOGIN_STATUS,
    REQ_CHANGE_NICKNAME,
    //收藏夹
    REQ_UPLOAD_FAV  = 100 ,     //上传我的收藏
    REQ_DOWNLOAD_FAV,           //下载我的收藏
    REQ_UPLOAD_DES,             //上传我的历史目的地
    REQ_DOWNLOAD_DES,           //下载我的历史目的地
    REQ_UPLOAD_DSP,             //上传我的电子眼
    REQ_DOWNLOAD_DSP,           //下载我的电子眼
    REQ_UPLOAD_CON,             //上传我的联系人
    REQ_DOWNLOAD_CON,           //下载我的联系人
    REQ_SYN_FAV  ,              //同步我的收藏
    REQ_SYN_DES  ,              //同步我的历史目的地
    REQ_SYN_DSP,                //同步我的电子眼
    
    //实时交通
    REQ_TMC,
    
    REQ_SKIN_DATA,                  //获取地图的皮肤数据
    REQ_SKIN_NEW,                   //获取新增皮肤
    REQ_CAR_NEW,                    //获取新增服务
    
    //网络搜索
    REQ_NET_SEARCH_KERWORD,                   //网络关键字搜索
    REQ_NET_SEARCH_AROUND,                    //网络周边搜索
    REQ_NET_SEARCH_ARROUND_LINE,               //网络沿途周边
    REQ_NET_SEARCH_PARKSTOP,                  //目的地停车场
    //市场横幅的请求类型
    REQ_NET_MARKET_BANNER,
    REQ_USER_Feedback,//用户反馈
    REQ_USER_Feedback_POI,//POI报错
    REQ_GET_MapDataList,//获取地图数据列表
}RequestType;

typedef enum BodyType{
	BT_XML  = 0,
    BT_JSON = 1,
}BodyType;

typedef enum ImageEncode {
    IE_Normal = 0,
    IE_Base64 = 1,
}ImageEncode;


typedef enum {
	kLaunchRequestErrorCode_Background_SwitchOnOff      = 0,
} LaunchRequestErrorCode;


typedef enum _ERROR_FOR_TRAFFIC_EVENT_{
	mRequsetSettingError      = 100,
    mParsingError             = 101,
    mErrorFromServer          = 102,
} ERROR_FOR_TRAFFIC_EVENT;

typedef enum NETERROR{
	NetErrorUnknown                =0,  //未知错误
    NetErrorTimedOut               =1,  //网络连接超时
    NetErrorException              =2,  //网络连接错误
    NetErrorServerCrash            =3,  //服务器宕机(硬件问题)
    NetErrorServerAnalyseException =4,  //服务器返回的内容解析异常
    
    NetErrorNOTMCData              =5,  //无实时交通数据
    //皮肤资源和车主服务列表请求错误码
    NetErrotClientInvalid          =6,  //软件版本号不合法
    NetErrotDeviceInvalid          =7,  //设备类型不合法
    NetErrorFunctionClose          =8,  //该功能已关闭
    NetErrorParams_Miss            =9,  //缺少参数
    NetErrorLoadImageFail          =10, //加载图片错误
} NETERROR;

#endif

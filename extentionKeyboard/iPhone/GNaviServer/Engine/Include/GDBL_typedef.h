/*****************************************************
 * Copyright(c) Xiamen AutoNavi Company. Ltd.
 * All Rights Reserved.
 *
 * File: GDBL_typedef.h
 * Purpose: GDBL对外结构定义文件
 *
 * Author: zhicheng.chen
 *
 *
 * Version: 7.0
 * Date: 22-May-2013 15:08:06
 * Update: Create
 *
 *************************************************** */
#ifndef GDBL_TYPEDEF_H__
#define GDBL_TYPEDEF_H__

/**
 \addtogroup data_structures_group Data Structures
 \{
 */

#include "gnavtypes.h"

/**
 * 网络加载数据类型枚举
 */
typedef enum tagGNETUPDATEEVENT
{
    G_NET_UPDATEEVENT_MAP,		/**< 加载数据 */
    G_NET_UPDATEEVENT_TRAFFIC,	/**< 加载实时交通 */
    G_NET_UPDATEEVENT_BLOCK,	/**< 加载图块 */
}GNETUPDATEEVENT;

/* 宏定义 */
/* 字符串长度定义（单位：字符） */
#define	GMAX_TRACK_NAME_LEN		31	/**< 轨迹名称最大长度 */
#define	GMAX_BUS_NAME_LEN		63	/**< 公交名称最大长度 */

#define GMAX_MANEUVER_TEXT_LEN	120	/**< 机动信息文本最大长度 */
#define	GMAX_MDL_NAME_LEN		63	/**< 3D建筑模型演示名称长度 */

/* TFB 交通情报板 - S */
#define	GMAX_TRAFFICBOARD_DESCRIPTION_LEN	511	/**< 交通情报板内容的长度 */
/* TFB 交通情报板 - E */

/* 天气功能-S */
#define GMAX_WEATHER_INFO_NUM				5			/* 天气信息的天数 */
#define GMAX_WTHLIVEINDEX_CONTENT_LEN		63			/* 天气详情的生活指数内容字符长度 */
#define GMAX_WTHLIVEINDEX_DESCRIPTION_LEN	511			/* 天气详情的生活指数描述字符长度 */
#define GMAX_WTHLIVEINDEX_INFO_NUM			10			/* 天气详情的生活指数信息个数 */
#define GMAX_WTHDETAIL_CONTENT_LEN			63			/* 天气详情的内容字符长度 */
#define GMAX_WTHDSUMMARY_CONTENT_LEN		63			/* 天气概要的内容字符长度 */
/* 天气功能-E */

/* TIR 交通事件上报 - S */
#define GMAX_TIR_ADDRESS        255     /**< 交通事件上报的地址内容长度 */
#define GMAX_TIR_CONTENT        255     /**< 交通事件上报的发表内容最大长度 */
#define GMAX_TIR_USERNAME       31      /**<  交通事件上报的用户名称的最大长度  */
#define GMAX_TIR_TITLE          31      /**< 交通事件上报的标题ID的最大长度 */
#define GMAX_TIR_PICTURE        255     /**< 交通事件上报的图片最大长度 */
/* TIR 交通事件上报 - E */

/* TMC 实时交通 - S */
#define GMAX_TRAFFIC_DURATION_LEN 32
/* TMC 实时交通 - E */

/**
 * 错误码枚举类型
 * 定义错误码枚举值
 */
typedef enum tagGSTATUS {
    GD_ERR_OK						=0x00000000,		/**< 操作成功 */
    GD_ERR_INVALID_PARAM			=0x00000001,		/**< 参数无效 */
    GD_ERR_NO_MEMORY				=0x00000002,		/**< 内存不足 */
    GD_ERR_NO_DATA					=0x00000003,		/**< 无相关数据 */
    GD_ERR_VER_INCOMPATIBLE			=0x00000004,		/**< 版本不匹配 */
    GD_ERR_IN_PROCESS				=0x00000005,		/**< 正在处理 */
    GD_ERR_NO_ROUTE					=0x00000006,		/**< 没有引导路径 */
    GD_ERR_RUNNING					=0x00000007,		/**< 正在进行，如模拟导航已经在进行，没有结束又开始模拟。 */
    GD_ERR_DUPLICATE_DATA			=0x00000008,		/**< 重复数据 */
    GD_ERR_NOT_SUPPORT				=0x00000009,		/**< 不支持该功能 */
    GD_ERR_NOT_START				=0x0000000a,		/**< 没有调用前序接口 */
    GD_ERR_NO_GPS					=0x0000000b,		/**< 没有GPS信息 */
    GD_ERR_NO_SPACE					=0x0000000c,		/**< 没有足够的空间做添加操作 */
    GD_ERR_OUT_OF_RANGE				=0x0000000d,		/**< 超出范围 */
    GD_ERR_INVALID_USER				=0x0000000e,		/**< 未授权用户 */
    GD_ERR_OP_CANCELED				=0x0000000f,		/**< 操作取消 */
    GD_ERR_OP_END					=0x00000010,		/**< 操作完成 */
    GD_ERR_TOO_NEAR					=0x00000011,		/**< 起点终点距离太近，无法规划路径 */
    GD_ERR_TOO_FAR					=0x00000012,		/**< 距离太长，无法规划路径 */
    
    GD_ERR_BUS_BOTH_WALK_TOO_FAR	=0x00000013,		/**< 起点终点步行距离超过4km */
    GD_ERR_BUS_START_WALK_TOO_FAR	=0x00000014,		/**< 起点步行距离超过2km */
    GD_ERR_BUS_END_WALK_TOO_FAR		=0x00000015,		/**< 终点步行距离超过2km */
    
    GD_ERR_NETPOI_DECODEFAILED		=0x00000016,		/**< XML请求语句构造失败 */
    GD_ERR_NETPOI_IMPORTFAILED		=0x00000017,		/**< 注入数据失败 */
    GD_ERR_NETPOI_GETDATAFAILED		=0x00000018,		/**< 获取数据失败 */
    GD_ERR_NET_REQUESTFAILED		=0X00000019,		/**< 网络请求失败 */
    GD_ERR_NET_TIMEOUT				=0X0000001a,		/**< 网络超时 */
    GD_ERR_NET_FAILED				=0X0000001b,		/**< 网络错误 */
    GD_ERR_NET_SUGGESTION			=0X0000001c,		/**< 无搜索数据，但有推荐数据，可通过GDBL_GetNetCandidateAdareaList获取 */
    
    GD_ERR_ROUTE_CALCULATING        =0x0000001d,        /* 正在路径计算 */
    GD_ERR_FAILED					=0xffffffff,		/**< 操作失败，暂无具体错误码 */
} GSTATUS;

/**
 * 目录信息
 *
 */
typedef struct tagGDATADIRINFO {
    Gchar szDir[GMAX_PATH];				/**< 相对目录名称 */
} GDATADIRINFO;

/**
 * 图片资源枚举类型
 * 用于标示图片资源
 */
typedef enum  tagGIMAGETYPE {
    G_IMAGE_TYPE_TURN,					/**< 机动路口转向图标 */
    G_IMAGE_TYPE_TOUR,					/**< 旅游电子书图片   */
    G_IMAGE_TYPE_LANE,					/**< 车道图标         */
    G_IMAGE_TYPE_2DCAR,					/**< 2D车标           */
    G_IMAGE_TYPE_3DCAR,					/**< 3D车标           */
    G_IMAGE_TYPE_EVENT,                 /**< 交通事件图标     */
    G_IMAGE_TYPE_POI                    /**< 获取POI图标      */
} GIMAGETYPE;

/**
 * 对象ID信息
 */
typedef struct tagGOBJECTID
{
    Guint8 u8LayerID;	/**< 图层ID */
    Guint8 u8Rev;		/**< 保留字节对齐 */
    Guint16 u16AdareaID;/**< 行政区域ID */
    Guint32 unMeshID;	/**< 网格ID */
    Guint32 unObjectID;	/**< 对象ID */
    Guint32 unRev;		/** 保留字段(只对TA有效) */
}GOBJECTID,*PGOBJECTID;	/**< 对象信息 */

/**
 * 图片资源输入参数结构体
 * 用于表示获取图片资源输入参数
 */
typedef struct  tagGIMAGEPARAM {
    GIMAGETYPE	eImageType;				/**< 图片类型 */
    Guint32		nImageID;				/**< 图片ID   */
    Gint32		nFlag;					/**< 其他标识，具体说明见接口GDBL_GetImage */
    GOBJECTID  stImageID;              /**< 图标ID结构体，当eImageType为G_IMAGE_TYPE_POI时有效 */
} GIMAGEPARAM;

/* Map */
/**
 * 地图显示方向（横向、纵向）
 *
 */
typedef enum tagGDISPLAYORIENTATION{
    G_DISPLAY_ORIENTATION_H = 0,	/**< 横向显示 */
    G_DISPLAY_ORIENTATION_V = 1		/**< 纵向显示 */
} GDISPLAYORIENTATION;

/**
 * 地图视图模式
 *
 */
typedef enum tagGMAPVIEWMODE {
    GMAPVIEW_MODE_NORTH = 0,	/**< 北向模式 */
    GMAPVIEW_MODE_CAR   = 1,	/**< 车向模式 */
    GMAPVIEW_MODE_3D    = 2,	/**< 3D模式 */
} GMAPVIEWMODE;

/**
 * 自动缩放模式
 *
 */
typedef enum tagGAUTOZOOMMODE {
    GAUTOZOOMMODE_MODE_AUTO            = 0,	/**< 自动模式 */
    GAUTOZOOMMODE_MODE_SPEEDZOOM       = 1,	/**< 速度自动缩放模式 */
    GAUTOZOOMMODE_MODE_MANEUVERAUTO    = 2,	/**< 距离自动缩放模式 */
} GAUTOZOOMMODE;

/**
 * 地图视图模式切换
 *
 */
typedef enum tagGSETMAPVIEWMODE {
    GSETMAPVIEW_MODE_NEXT = 0,	/**< 切到下个模式 */
    GSETMAPVIEW_MODE_PRE  = 1,	/**< 切到上个模式 */
    GSETMAPVIEW_MODE_ANY  = 2,	/**< 切到任意模式（有3d模式） */
    GSETMAPVIEW_MODE_ANY_NO3D  = 3,/**< 切到任意模式（无3d模式）,
                                    执行此种模式需要设置G_MAP_IS2MODE为Gtrue，
                                    设置之后就只支持该模式的切换不再支持前面三种模式 */
} GSETMAPVIEWMODE;

/**
 * 地图比例尺缩放
 *
 */
typedef enum tagGSETMAPVIEWLEVEL {
    GSETMAPVIEW_LEVEL_IN  = 0,	/**< 放大比例尺 */
    GSETMAPVIEW_LEVEL_OUT = 1,	/**< 缩小比例尺 */
    GSETMAPVIEW_LEVEL_ANY = 2,	/**< 缩放到任意比例尺 */
    GSETMAPVIEW_LEVEL_STEPLESS_IN  = 3,/**< 无级放大 */
    GSETMAPVIEW_LEVEL_STEPLESS_OUT  = 4,/**< 无级缩小 */
    GSETMAPVIEW_LEVEL_STEPLESS_STOP  = 5,/**< 停止无级缩放 */
} GSETMAPVIEWLEVEL;

/**
 * 地图POI密集度
 *
 */
typedef enum tagGMAPPOIDENSITY {
    GMAP_POI_DENSITY_DETAIL = 0,	/**< 信息详细 */
    GMAP_POI_DENSITY_NORMAL = 1,	/**< 信息一般 */
    GMAP_POI_DENSITY_SIMPLE = 2		/**< 信息简要 */
} GMAPPOIDENSITY;

/**
 * 地图POI优先显示
 *
 */
typedef enum tagGMAPPOIPRIORITY {
    GMAP_POI_PRIORITY_AUTO          = 0x00000000,	/**< 自动 */
    GMAP_POI_PRIORITY_GAS           = 0x00000001,	/**< 加油站 */
    GMAP_POI_PRIORITY_AUTO_4S       = 0x00000002,   /**< 汽车4S */
    GMAP_POI_PRIORITY_CATERING      = 0x00000004,	/**< 餐饮 */
    GMAP_POI_PRIORITY_MARKET        = 0x00000008,	/**< 商场 */
    GMAP_POI_PRIORITY_SUPERMARKET   = 0x00000010,	/**< 超市 */
    GMAP_POI_PRIORITY_HALL          = 0x00000020,	/**< 运动馆 */
    GMAP_POI_PRIORITY_GOLF          = 0x00000040,	/**< 高尔夫 */
    GMAP_POI_PRIORITY_KTV           = 0x00000080,   /**< KTV */
    GMAP_POI_PRIORITY_CINEMA        = 0x00000100,   /** 电影院 */
    GMAP_POI_PRIORITY_HOSPITAL      = 0x00000200,   /**< 医院 */
    GMAP_POI_PRIORITY_HOTEL         = 0x00000400,   /**< 酒店 */
    GMAP_POI_PRIORITY_SCENIC_SPOTS  = 0x00000800,   /**< 景点 */
    GMAP_POI_PRIORITY_SCHOOL        = 0x00001000,   /**< 学校 */
    GMAP_POI_PRIORITY_PARKING       = 0x00002000,   /**< 停车场 */
    GMAP_POI_PRIORITY_BANK          = 0x00004000,   /**< 银行 */
    GMAP_POI_PRIORITY_TOILET        = 0x00008000    /**< 厕所 */
} GMAPPOIPRIORITY;

/**
 * 地图昼夜模式
 *
 */
typedef enum tagGMAPDAYNIGHTMODE {
    GMAP_DAYNIGHT_MODE_DAY   = 0,	/**< 昼模式 */
    GMAP_DAYNIGHT_MODE_NIGHT = 1,	/**< 夜模式 */
    GMAP_DAYNIGHT_MODE_AUTO  = 2	/**< 自动检测模式 */
} GMAPDAYNIGHTMODE;

/**
 * 地图显示字体大小
 *
 */
typedef enum tagGMAPFONTSIZE {
    GMAP_FONT_SIZE_SMALL  = 0,	/**< 小 */
    GMAP_FONT_SIZE_NORMAL = 1,	/**< 正常 */
    GMAP_FONT_SIZE_BIG    = 2	/**< 大 */
} GMAPFONTSIZE;

/**
 * 放大路口进度条布局(横屏、竖屏)
 *
 */
typedef enum tagGBARLAYOUT {
    GBAR_LAYOUT_V = 0,		/**< 纵屏 */
    GBAR_LAYOUT_H = 1		/**< 横屏 */
} GBARLAYOUT;

/**
 * 地图TMC显示规则（可按位或进行任意组合）
 *
 */
typedef enum tagGTMCSHOWOPTION {
    GMAP_TMC_SHOW_CITYSTREAM    = 0x01,	    /**< 仅显示城市TMC流 */
    GMAP_TMC_SHOW_ROUTESTREAM   = 0x02,		/**< 仅显示路径TMC流 */
    GMAP_TMC_SHOW_CITYEVENT     = 0x04,     /**< 仅显示城市事件 */
    GMAP_TMC_SHOW_ROUTEEVENT    = 0x08      /**< 仅显示路径事件 */
} GTMCSHOWOPTION;

/**
 * 地图显示街区开关
 *
 */
typedef enum tagGMAPCONTENT {
    GMAP_CONTENT_NOBLOCK        = 0,	/**< 无街区,2D模式 */
    GMAP_CONTENT_GDI_MIX		= 1,	/**< GDI混合模式 */
    GMAP_CONTENT_GL_MIX			= 2,	/**< OPENGL不带纹理混合模式 */
    GMAP_CONTENT_GL_TEXTURE_MIX = 3		/**< OPENGL带纹理混合模式 */
} GMAPCONTENT;

/**
 * 地图绘制之前或之后的枚举
 *
 */
typedef enum tagGDRAWMAP {
    GMAP_DRAWMAP_BEGIN         = 0,		/**< 绘图开始 */
    GMAP_DRAWMAP_END           = 1		/**< 绘图结束 */
} GDRAWMAP;

/**
 * 地图绘制的回调函数
 * 用于在地图绘制之前或地图绘制结束之后回调的函数
 *
 */
typedef void (*GDRAWMAPCB)(GDRAWMAP eDrawMap);

/**
 * 地图操作之前或之后的枚举
 *
 */
typedef enum tagGCONTROLMAP {
    GMAP_CONTROLMAP_BEGIN         = 0,		/**< 操作地图开始 */
    GMAP_CONTROLMAP_END           = 1		/**< 操作地图结束 */
} GCONTROLMAP;

/**
 * 地图操作的回调函数
 * 用于在地图操作之前或地图操作结束之后回调的函数
 *
 */
typedef void (*GCONTROLMAPCB)(GCONTROLMAP eControlMap);

/**
 * GPS语句格式
 *
 */
typedef enum tagGGPSFORMAT {
    GGPS_FORMAT_NMEA0813 = 0,	/**< NMEA格式 */
    GGPS_FORMAT_BIN      = 1,	/**< 二进制格式 */
    GGPS_FORMAT_HIPPO    = 2,	/**< HIPPO格式 */
} GGPSFORMAT;

/**
 * 车行、步行模式
 *
 */
typedef enum tagGNAVIMODE {
    GNAVI_MODE_CAR  = 0,	/**< 自驾模式 */
    GNAVI_MODE_WALK = 1,	/**< 步行模式 */
    GNAVI_MODE_BUS	= 2,	/**< 公交模式 */
} GNAVIMODE;

/**
 * 轨迹记录规则
 *
 */
typedef enum tagGTRACKRECORDOPTION {
    GTRACK_RECORD_OPTION_THICKNESS = 0,		/**< 频繁 */
    GTRACK_RECORD_OPTION_NORMAL    = 1,		/**< 普通 */
    GTRACK_RECORD_OPTION_THINNESS  = 2		/**< 简单 */
} GTRACKRECORDOPTION;

/**
 * 收藏夹显示类别选项
 *
 */
typedef enum tagGFAVORITESHOWOPTION {
    GFAVORITE_SHOW_DEFAULT		= 1,		/**< 默认 */
    GFAVORITE_SHOW_HOME			= 2,		/**< 家 */
    GFAVORITE_SHOW_COMPANY		= 4,		/**< 公司 */
    GFAVORITE_SHOW_SIGHT		= 8,		/**< 景点 */
    GFAVORITE_SHOW_FRIEND		= 16,		/**< 朋友 */
    GFAVORITE_SHOW_CUSTOMER		= 32,		/**< 客户 */
    GFAVORITE_SHOW_ENTERTAINMENT= 64,		/**< 娱乐 */
    GFAVORITE_SHOW_HISTORY		= 128,		/**< 历史目的地 */
    GFAVORITE_SHOW_ALL			= 255		/**< 所有 */
}GFAVORITESHOWOPTION;

/**
 * 区域播报级别：市、区
 *
 */
typedef enum tagGADMINSPEAKOPTION {
    GADMIN_SPEAK_OPTION_TOWN = 0,		/**< 区 */
    GADMIN_SPEAK_OPTION_CITY = 1		/**< 市 */
}GADMINSPEAKOPTION;

/**
 * 语音提示频率规则
 *
 */
typedef enum tagGPROMPTOPTION {
    GPROMPT_OPTION_LITTLE = 0,		/**< 简单 */
    GPROMPT_OPTION_MUCH   = 1		/**< 频繁 */
} GPROMPTOPTION;

/**
 * 全程概览风格
 *
 */
typedef enum tagGOVERVIEWOPTION {
    G_OVERVIEW_OPTION_BELOW = 0,	/**< 车头在下 */
    G_OVERVIEW_OPTION_NORTH = 1		/**< 正北 */
} GOVERVIEWOPTION;

/**
 * 避让道路类型
 *
 */
typedef enum tagGDETOURTYPE {
    GDETOUR_TYPE_DEFAULT = 0,		/**< 默认 */
    GDETOUR_TYPE_FERRY   = 1,		/**< 渡口 */
    GDETOUR_TYPE_TUNNEL  = 2,		/**< 隧道 */
    GDETOUR_TYPE_BRIDGE  = 4,		/**< 桥梁 */
    GDETOUR_TYPE_OVERHEAD= 8,		/**< 高架 */
    GDETOUR_TYPE_HIGHWAY = 16,		/**< 高速 */
    GDETOUR_TYPE_CHARGE  = 32		/**< 收费 */
} GDETOURTYPE;

/**
 * 路径规划规则
 *
 */
typedef enum tagGROUTEOPTION {
    GROUTE_OPTION_RECOMMAND = 0,	/**< 推荐 */
    GROUTE_OPTION_HIGHWAY   = 1,	/**< 高速优先 */
    GROUTE_OPTION_ECONOMY   = 2,	/**< 经济路线 */
    GROUTE_OPTION_SHORTEST  = 3,	/**< 最短路线 */
    GROUTE_OPTION_WALK      = 4,	/**< 步行路线 */
    GROUTE_OPTION_LINEAR    = 5		/**< 直线路线 */
} GROUTEOPTION;

/**
 * 多路线规划过滤，控制哪些规划原则无需规划
 * 可以组合，参数索引G_MULTI_ROUTE_FILTER
 */
typedef enum tagGMULTIROUTEFILTER {
    GMULTI_ROUTE_FILTER_NONE	  = 0,	/**< 不过滤   */
    GMULTI_ROUTE_FILTER_RECOMMAND = 1,	/**< 过滤推荐 */
    GMULTI_ROUTE_FILTER_HIGHWAY   = 2,	/**< 过滤高速 */
    GMULTI_ROUTE_FILTER_ECONOMY   = 4,	/**< 过滤经济 */
    GMULTI_ROUTE_FILTER_SHORTEST  = 8	/**< 过滤最短 */
} GMULTIROUTEFILTER;

/**
 * 路径规划TMC控制，控制哪些规划原则需要TMC参与
 * 可以组合，但总的受GROUTE_FLAG_TMC控制，参数索
 * 引G_ROUTE_TMC_OPTION
 */
typedef enum tagGROUTETMCOPTION {
    GROUTE_TMC_OPTION_NONE		= 0,	/**< 都不考虑TMC */
    GROUTE_TMC_OPTION_RECOMMAND = 1,	/**< 推荐+TMC    */
    GROUTE_TMC_OPTION_HIGHWAY   = 2,	/**< 高速+TMC    */
    GROUTE_TMC_OPTION_ECONOMY   = 4,	/**< 经济+TMC    */
    GROUTE_TMC_OPTION_SHORTEST  = 8,	/**< 最短+TMC    */
    GROUTE_TMC_OPTION_ALL		= 15,	/**< 都考虑TMC   */
} GROUTETMCOPTION;

/**
 * 路径规划标识
 *
 */
typedef enum tagGROUTEFLAG {
    GROUTE_FLAG_DEFAULT = 0,	/**< 不考虑其他因素 */
    GROUTE_FLAG_TMC     = 1		/**< 考虑TMC */
} GROUTEFLAG;

/**
 * 不同类型路径演算
 *
 */
typedef enum tagGCALROUTETYPE{
    GROU_CAL_SINGLE			= 0,		/**< 单条路径演算 */
    GROU_CAL_MULTI			= 1,		/**< 多条路径演算 */
    GROU_CAL_RECAL			= 2,		/**< 路径重演算 */
    GROU_CAL_SINGLE_ROUTE	= 3,		/**< 单条路径演算并返回路径句柄 */
    GROU_CAL_SINGLE_NET		= 4,		/**< 单条网络路径演算 */
    GROU_CAL_MULTI_NET		= 5,		/**< 多条网络路径演算 */
    GROU_CAL_TMCRECAL       = 6,        /**< tmc参与路径规划 */
    GROU_CAL_CHANGECARROAD  = 7,        /**< 切换平行路 */
}GCALROUTETYPE;

/**
 * 设备ID类型
 *
 */
typedef enum tagGDEVICEID {
    GDEVICE_ID_GUID = 0,	/**< GUID */
    GDEVICE_ID_UUID = 1,	/**< UUID */
    GDEVICE_ID_SD   = 2,	/**< SD */
    GDEVICE_ID_IMEI = 3		/**< IMEI */
} GDEVICEID;

/**
 * 注册配置类型
 *
 */
typedef struct tagGREGCONFIG {
    GREGMODE eRegMode;				/**< 注册模式         */
    GDEVICEID eDeviceIDType;		/**< 设备ID类型       */
} GREGCONFIG;

/**
 * 定位信号类型
 *
 */
typedef enum tagGLOCSIGNALTYPE {
    GLOC_SIGNAL_TYPE_GPS    = 0,	/**< 纯GPS */
    GLOC_SIGNAL_TYPE_DRGPS  = 1,	/**< 前端融合 */
    GLOC_SIGNAL_TYPE_SGPS   = 2,	/**< 前端融合多帧 */
    GLOC_SIGNAL_TYPE_JD4    = 10,	/**< 捷达 */
    GLOC_SIGNAL_TYPE_BKGL8  = 11,	/**< 别克GL8 */
    GLOC_SIGNAL_TYPE_GEELY	= 12,   /**< 吉利 */
    GLOC_SIGNAL_TYPE_AUDI	= 13,	/**< 奥迪 */
    GLOC_SIGNAL_TYPE_MCLAREN= 14,   /**< 迈凯轮 */
    GLOC_SIGNAL_TYPE_DZPOC	= 15,   /**< 大众POC */
    GLOC_SIGNAL_TYPE_RW     = 100,	/**< 荣威350 */
    GLOC_SIGNAL_TYPE_GC_CAN = 200	/**< 广汽CAN */
} GLOCSIGNALTYPE;

/**
 * 定位信号数据包类型
 *
 */
typedef enum tagGLOCDATATYPE {
    GLOC_DATA_TYPE_EMPTY,			/**< 空数据，无相关结构 */
    GLOC_DATA_TYPE_GPS_POS,			/**< 位置信息，相关结构GGPSPOS */
    GLOC_DATA_TYPE_GPS_RAW_NMEA,	/**< 原始的GPS数据，相关结构GGPSNMEA */
    GLOC_DATA_TYPE_GPS_AZI,			/**< 航向，相关结构GGPSAZI */
    GLOC_DATA_TYPE_GPS_SPD,			/**< 速度，相关结构GGPSSPD */
    GLOC_DATA_TYPE_GPS_SATANUM,		/**< 卫星数，相关结构GGPSSATANUM */
    GLOC_DATA_TYPE_GPS_ALT,			/**< 海拔高度，相关结构GGPSALT */
    GLOC_DATA_TYPE_GPS_DATE,		/**< 日期，相关结构GGPSDATE */
    GLOC_DATA_TYPE_GPS_DOP,			/**< 精度因子，相关结构GGPSDOP */
    GLOC_DATA_TYPE_GPS_STATUS,		/**< 是否有效，A/V，相关结构GGPSSTATUS */
    GLOC_DATA_TYPE_E_COMPASS,		/**< 电子罗盘，相关结构GECOMPASSDATA */
    GLOC_DATA_TYPE_ACCE3D,			/**< 3D加速计，相关结构GACCE3D */
    GLOC_DATA_TYPE_GPS_MODE,		/**< GPS状态模式，A=自主定位，D=差分，E=估算，N=数据无效，相关结构GGPSMODE */
    GLOC_DATA_TYPE_GYRO,			/**< 陀螺，相关结构GGYRO */
    GLOC_DATA_TYPE_PULSE,			/**< 脉冲值，相关结构GPULSE */
    GLOC_DATA_TYPE_GPS_MISTAKE,		/**< 误差范围，相关结构GGPSMISTAKE */
    GLOC_DATA_TYPE_GPS_SATASTD,		/**< 星历数据，相关结构GGPSSATASTD */
    GLOC_DATA_TYPE_TEMPERATURE,		/**< 陀螺温度，相关结构GTEMPERATURE */
    GLOC_DATA_TYPE_DR,				/**< 融合后的绝对位置，相关结构GDR */
    GLOC_DATA_TYPE_COUNT,			/**< 定位信号数据包总数 */
} GLOCDATATYPE;

/**
 * 陀螺信号类型
 *
 */
typedef enum tagGGYROTYPE {
    GGYRO_TYPE_100DEGREE		= 0,	/**< 百分之一度 */
    GGYRO_TYPE_VOLTAGE			= 1,	/**< 电压值 */
    GGYRO_TYPE_ANGULAR_SPEED	= 2		/**< 角速度值 */
} GGYROTYPE;

/**
 * 三轴定义
 *
 */
typedef enum tagGLOCTHREEAXISTYPE
{
    GLOC_THREEAXIS_TYPE_NULL	= 0,    /**< 空值 */
    GLOC_THREEAXIS_TYPE_YAW		= 1,    /**< 左右 */
    GLOC_THREEAXIS_TYPE_PITCH	= 2,    /**< 俯仰 */
    GLOC_THREEAXIS_TYPE_ROLL	= 4     /**< 倾斜 */
}GLOCTHREEAXISTYPE;

/**
 * GPS NMEA数据结构体类型
 * 对应枚举值类型GLOC_DATA_TYPE_GPS_RAW_NMEA
 */
typedef struct tagGGPSNMEA
{
    GLOCDATATYPE euDataType;				/**< 本结构体类型 */
    Gint8 szGps[128];						/**< 以$开头的NMEA字符串 */
    Guint32 nTickTime;						/**< 时间戳 */
} GGPSNMEA;

/**
 * GPS信号数据结构体类型
 * 对应枚举值类型GLOC_DATA_TYPE_GPS_POS
 */
typedef struct tagGGPSPOS
{
    GLOCDATATYPE euDataType;				/**< 本结构体类型 */
    Gint8 n8NS;								/**< 经度(N,S) */
    Gint8 n8EW;								/**< 维度(E,W) */
    GPOINT stPt;							/**< 加密后的经纬度  */
    GPOINT stPtS;							/**< 未加密的经纬度  */
    Guint32 unTickTime;						/**< 时间戳 */
} GGPSPOS;

/**
 * 航向数据结构体类型
 * 对应枚举值类型GLOC_DATA_TYPE_GPS_AZI
 */
typedef struct tagGGPSAZI
{
    GLOCDATATYPE euDataType;				/**< 本结构体类型 */
    Gfloat32 fAzi;							/**< 航向 */
    Guint32 nTickTime;						/**< 时间戳 */
} GGPSAZI;

/**
 * 速度数据结构体类型
 * 对应枚举值类型GLOC_DATA_TYPE_GPS_SPD
 */
typedef struct tagGGPSSPD
{
    GLOCDATATYPE euDataType;				/**< 本结构体类型 */
    Gfloat32 fSpd;							/**< 速度（公里/小时） */
    Guint32 nTickTime;						/**< 时间戳 */
} GGPSSPD;

/**
 * 卫星数数据结构体类型
 * 对应枚举值类型GLOC_DATA_TYPE_GPS_SATANUM
 */
typedef struct tagGGPSSATANUM
{
    GLOCDATATYPE euDataType;				/**< 本结构体类型 */
    Gint32 nNum;							/**< 定位计算用的卫星个数 */
    Guint32 nTickTime;						/**< 时间戳 */
} GGPSSATANUM;

/**
 * 海拔高度数据结构体类型
 * 对应枚举值类型GLOC_DATA_TYPE_GPS_ALT
 */
typedef struct tagGGPSALT
{
    GLOCDATATYPE euDataType;				/**< 本结构体类型 */
    Gfloat32 fAlt;							/**< 海拔高度(米） */
    Guint32 nTickTime;						/**< 时间戳 */
} GGPSALT;

/**
 * 日期数据结构体类型
 * 对应枚举值类型GLOC_DATA_TYPE_GPS_DATE
 */
typedef struct tagGGPSDATE
{
    GLOCDATATYPE euDataType;				/**< 本结构体类型 */
    Gint32 nYear;							/**< 年 */
    Gint32 nMonth;							/**< 月 */
    Gint32 nDay;							/**< 日 */
    Gint32 nHour;							/**< 时 */
    Gint32 nMinute;							/**< 分 */
    Gint32 nSecond;							/**< 秒 */
    Guint32 nTickTime;						/**< 时间戳 */
}GGPSDATE;

/**
 * 精度因子数据结构体类型
 * 对应枚举值类型GLOC_DATA_TYPE_GPS_DOP
 */
typedef struct tagGGPSDOP
{
    GLOCDATATYPE euDataType;				/**< 本结构体类型 */
    Gfloat32 fHDOP;							/**< 水平精度 */
    Gfloat32 fVDOP;							/**< 垂直精度 */
    Gfloat32 fPDOP;							/**< 平方精度 */
    Guint32 nTickTime;						/**< 时间戳 */
}GGPSDOP;

/**
 * 误差范围数据结构体类型
 * 对应枚举值类型GLOC_DATA_TYPE_GPS_MISTAKE
 */
typedef struct tagGGPSMISTAKE
{
    GLOCDATATYPE euDataType;				/**< 本结构体类型 */
    Gint32 nDistance;						/**< 距离（单位1/10米） */
    Guint32 nTickTime;						/**< 时间戳 */
}GGPSMISTAKE;

/**
 * 星历数据结构体类型
 * 对应枚举值类型GLOC_DATA_TYPE_GPS_SATASTD
 */
typedef struct tagGGPSSATASTD
{
    GLOCDATATYPE euDataType;				/**< 本结构体类型 */
    Gint16 nSataCnt;						/**< 可视卫星数 */
    Gint16 nSataId[12];						/**< 卫星编号 */
    Gint16 nLe[12];							/**< 水平仰角（0-90度） */
    Gint16 nAzi[12];						/**< 方位角（北零顺时针方向，0-360度） */
    Gint16 nDb[12];							/**< 信噪比（0-99dB） */
    Guint32 nTickTime;						/**< 时间戳 */
}GGPSSATASTD;

/**
 * 是否有效结构体类型
 * 对应枚举值类型GLOC_DATA_TYPE_GPS_STATUS
 */
typedef struct tagGGPSSTATUS
{
    GLOCDATATYPE euDataType;				/**< 本结构体类型 */
    Guint8 cStatus;							/**< 状态位，A/V */
    Guint32 nTickTime;						/**< 时间戳 */
}GGPSSTATUS;

/**
 * GPS状态模式结构体类型,A=自主定位，D=差分，E=估算，N=数据无效
 * 对应枚举值类型GLOC_DATA_TYPE_GPS_MODE
 */
typedef struct tagGGPSMODE
{
    GLOCDATATYPE euDataType;				/**< 本结构体类型 */
    Guint8 cMode;							/**< 'A','D','E','N' */
    Guint32 nTickTime;						/**< 时间戳 */
}GGPSMODE;

/**
 * 电子罗盘信号类型
 * 对应枚举值GLOC_DATA_TYPE_E_COMPASS
 */
typedef struct tagGECOMPASSDATA
{
    GLOCDATATYPE euDataType;		/**< 本结构体类型 */
    Gint8	n8DeviceAttitude;		/**< 1竖放头向上，2横放左向上，3竖放头向下，4横放右向上 */
    Gfloat32 fAzimuth;				/**< 角度(度） */
    Guint32	unTickTime;				/**< 时间戳 */
} GECOMPASSDATA;

/**
 * 陀螺温度结构体类型
 * 对应枚举值类型GLOC_DATA_TYPE_TEMPERATURE
 */
typedef struct tagGTEMPERATURE
{
    GLOCDATATYPE euDataType;				/**< 本结构体类型 */
    Gint32	nTemperature;					/**< 温度 */
    Guint32 nTickTime;						/**< 时间戳 */
}GTEMPERATURE;

/**
 * 3D加速计结构体类型
 * 对应枚举值类型GLOC_DATA_TYPE_ACCE3D
 */
typedef struct tagGACCE3D
{
    GLOCDATATYPE euDataType;				/**< 本结构体类型 */
    Gint32 nType;							/**< 类型 */
    Gint32 nCount;							/**< 个数 */
    GLOCTHREEAXISTYPE euAxis;				/**< 有效数据轴 */
    Gfloat32 fAcceYaw[4];					/**< Yaw */
    Gfloat32 fAccePitch[4];					/**< Pitch */
    Gfloat32 fAcceRoll[4];					/**< Roll */
    Gint32 nInterval;						/**< 间隔时间 */
    Guint32 unTickTime;						/**< 时间戳 */
}GACCE3D;

/**
 * 陀螺数据结构体类型
 * 对应枚举值GLOC_DATA_TYPE_GYRO
 */
typedef struct tagGGYRODATA
{
    GLOCDATATYPE euDataType;				/**< 本结构体类型 */
    Gint32 nType;							/**< 类型(0百分之一度，1电压，如2048，2Audi） */
    Gint32 nCount;							/**< 个数 */
    GLOCTHREEAXISTYPE euAxis;				/**< 有效数据轴 */
    Gint32 nValueYaw[4];					/**< 陀螺值Yaw */
    Gint32 nValuePitch[4];					/**< 陀螺值Pitch */
    Gint32 nValueRoll[4];					/**< 陀螺值Roll */
    Gint32 nTemperature;					/**< 温度 */
    Gint32 nInterval;						/**< 间隔时间 */
    Guint32 unTickTime;						/**< 时间戳 */
} GGYRODATA;

/**
 * 脉冲数据结构体类型
 * 对应枚举值GLOC_DATA_TYPE_PULSE
 */
typedef struct tagGPULSEDATA
{
    GLOCDATATYPE euDataType;				/**< 本结构体类型 */
    Gint32		nType;						/**< 类型（0脉冲个数，1速度值：1/100公里/小时，2距离：1/100米） */
    Gint32		nValue;						/**< 脉冲值 */
    Gint32		nInterval; 					/**< 每个脉冲时间间隔 */
    Guint32		unTickTime;					/**< 时间戳 */
} GPULSEDATA;

/**
 * 融合后的绝对位置结构体类型
 * 对应枚举值类型GLOC_DATA_TYPE_DR
 */
typedef struct tagGDR
{
    GLOCDATATYPE euDataType;				/**< 本结构体类型 */
    Gint32 lLon;							/**< 经度 */
    Gint32 lLat;							/**< 纬度 */
    Gint32 nAzi;							/**< 航向（1/100度） */
    Gint32 nAlt;							/**< 海拔（1/100米） */
    Gint32 nPosAcc;							/**< 位置误差（1/100米） */
    Gint32 nAziAcc;							/**< 航向误差（1/100度） */
    Gint32 nAltAcc;							/**< 海拔误差（1/100米） */
    Guint32 nTickTime;						/**< 时间戳 */
}GDR;

/**
 * 信号数据联合体
 *
 */
typedef union tagGSIGNDATA
{
    GLOCDATATYPE euDataType;			/**< 本结构体类型 */
    GGPSNMEA stGpsNmea;					/**< 原始GPS的NMEA数据 */
    GGPSPOS stGpsPos;					/**< GPS位置坐标 */
    GGPSAZI stGpsCourse;				/**< GPS航向 */
    GGPSSPD stGpsSpeed;					/**< GPS速度 */
    GGPSSATANUM stGpsSataNum;			/**< GPS卫星数 */
    GGPSALT stGpsAlt;					/**< GPS海拔 */
    GGPSDATE stGpsDateTime;				/**< GPS日期时间 */
    GGPSDOP stGpsDop;					/**< GPS的DOP值 */
    GGPSSTATUS stGpsStatus;				/**< GPS状态位 */
    GGPSMODE stGpsMode;					/**< GPS定位模式 */
    GECOMPASSDATA stECompass;			/**< 电子罗盘 */
    GGYRODATA stGyro;					/**< 陀螺数据 */
    GPULSEDATA stPulse;					/**< 脉冲数据 */
    GACCE3D stAcce3D;					/**< 3D加速度计 */
}  unionGSIGNDATA;

/**
 * 地图比例级别枚举类型
 *
 */
typedef enum tagGZOOMLEVEL {
    ZOOM_500_KM = 0,					/**< 500km */
    ZOOM_200_KM = 1,					/**< 200km */
    ZOOM_LEVEL_CHINA = ZOOM_200_KM,		/**< 全国层 */
    ZOOM_100_KM = 2,					/**< 100km */
    ZOOM_50_KM = 3,						/**< 50km */
    ZOOM_20_KM = 4,						/**< 20km */
    ZOOM_10_KM = 5,						/**< 10km */
    ZOOM_LEVEL_PROVINCE = ZOOM_10_KM,	/**< 全省层km */
    ZOOM_5_KM = 6,						/**< 5km */
    ZOOM_LEVEL_CITY = ZOOM_5_KM,		/**< 全市层km */
    ZOOM_2_KM = 7,						/**< 2km */
    ZOOM_1_KM = 8,						/**< 1km */
    ZOOM_500_M = 9,						/**< 500m */
    ZOOM_200_M = 10,					/**< 200m */
    ZOOM_100_M = 11,					/**< 100m */
    ZOOM_50_M = 12,						/**< 50m */
    ZOOM_LEVEL_STREET = ZOOM_50_M,		/**< 街区层 */
    ZOOM_25_M = 13,						/**< 25m */
    ZOOM_15_M = 14,						/**< 15m */
    ZOOM_MAX = 15						/**< 比例级别最大值 */
}GZOOMLEVEL;

/**
 * 程序窗口模式枚举类型
 * 用于表示程序架构是单窗口还是多窗口
 * 对应枚举值G_APP_WINDOW_MODE
 */
typedef enum tagGAPPWINDOWMODE {
    GAPP_WINDOW_MODE_SINGLE = 0, 	/**< 单窗口模式 */
    GAPP_WINDOW_MODE_MULTIPLE 		/**< 多窗口模式 */
} GAPPWINDOWMODE;

/**
 * 图形库类型枚举值
 *
 * 对应枚举值G_GRAPHICS_LIB
 */
typedef enum tagGGRAPHICSLIB {
    GGRAPHICS_LIB_GDI         = 0,	/**< 高德GDI */
    GGRAPHICS_LIB_OPENGLES1_0 = 1,	/**< OpenGL ES 1.0 */
    GGRAPHICS_LIB_OPENGLES2_0 = 2	/**< OpenGL ES 2.0 */
} GGRAPHICSLIB;

/**
 * 版本信息ID枚举
 * 用于标识何种版本信息
 */
typedef enum tagGVERSIONID {
    GVERSION_ID_NAVI_CORE, 		/**< 导航内核版本 */
    GVERSION_ID_DATA_GLOBAL, 	/**< 全球数据版本 */
    GVERSION_ID_DATA_NATION,	/**< 国家数据版本 */
    GVERSION_ID_DATA_CITY,		/**< 城市数据版本 */
    GVERSION_ID_RESOURCE,		/**< 导航资源版本 */
    GVERSION_ID_TTS,			/**< TTS版本 */
    GVERSION_ID_IM				/**< 输入法版本 */
} GVERSIONID;

/**
 * 版本信息参数结构体
 * 用于获取各种版本信息，依据不同版本标识填充不同字段,如下表。
 *	版本标识					国家编码	城市编码    数据类型	路径
 *	GVERSION_ID_NAVI_CORE
 *	GVERSION_ID_DATA_GLOBAL								   ○        ○
 *	GVERSION_ID_DATA_NATION		   ●					   ○	     ○
 *	GVERSION_ID_DATA_CITY		   ●		   ●		   ○	     ○
 *	GVERSION_ID_RESOURCE											 ●
 *	说明：●必选，○可选。
 */
typedef struct tagGVERSIONPARAM {
    GVERSIONID eVersionID; 		/**< 版本标识 */
    GADMINCODE stAdcode;		/**< 行政编码结构 */
    enumDBTYPE euDBType;		/**< 数据类型 */
    Gchar szPath[GMAX_PATH];	/**< 路径 */
} GVERSIONPARAM;

/**
 * 移图操作枚举类型
 *
 */
typedef enum tagGMOVEMAPOP {
    MOVEMAP_OP_CLICK = 0,		/**< 点击移图 */
    MOVEMAP_OP_SWIPE,			/**< 滑动移图 */
    MOVEMAP_OP_DRAG,			/**< 拖拽移图 */
    MOVEMAP_OP_MOVING,			/**< 连续移图 */
    MOVEMAP_OP_GEO_DIRECT,		/**< 直接以经纬度坐标移图 */
}GMOVEMAPOP;

/**
 * 鼠标状态
 *
 */
typedef enum tagGMOUSESTATUS {
    MOUSE_DOWN = 0,				/**< 鼠标下按 */
    MOUSE_UP,					/**< 鼠标弹起 */
    MOUSE_MOVE,					/**< 鼠标移动 */
}GMOUSESTATUS;

/**
 * 移图操作结构体类型
 *
 */
typedef struct tagGMOVEMAP {
    GMOVEMAPOP eOP;			/**< 操作类型 */
    GCOORD   deltaCoord;	/**< 相对于视图中心的位移量（单位：像素）eOP=MOVEMAP_OP_GEO_DIRECT为经纬度坐标 */
    GMOUSESTATUS euMouse;	/**< 鼠标状态 */
} GMOVEMAP;

/**
 * 视图结构体类型
 * 用于存储地图视图
 */
typedef struct tagGMAPVIEW {
    GMAPVIEWTYPE eViewType;			/**< 视图类型 */
    GFCOORD		Center; 			/**< 视图中心 */
    GZOOMLEVEL	ZoomLevel; 			/**< 视图比例级别 */
    Gfloat32 	Angle; 				/**< 视图角度 */
    GBITMAP		Bitmap;				/**< 视图画面 */
    Gint32		nScalePixels;		/**< 比例尺象素大小 */
} GMAPVIEW;

/**
 * 选择命令枚举类型
 *
 */
typedef enum tagGSELECTCMD {
    GSELECT_CMD_ROUTE = 0,		/**< 选择路径     */
    GSELECT_CMD_EVENT,			/**< 选择交通事件 */
    GSELECT_CMD_POINT,          /**<  选择POI */
    GSELECT_CMD_TrafficBoard,	/**<  选择交通情报板图标 */
    GSELECT_CMD_TIR             /* 选择事件上报 */
} GSELECTCMD;

/**
 * 点击选择结构体类型
 * 用于存储点击位置、视图类型
 */
typedef struct tagGSELECTPARAM {
    GMAPVIEWTYPE eViewType;		/**< 视图类型 */
    GCOORD	pos;				/**< 位置     */
    GSELECTCMD eCmd;			/**< 命令     */
} GSELECTPARAM;




/**
 * 色盘描述结构体类型
 * 用于存储色盘描述信息
 */
typedef struct tagGPALETTE {
    Guint32	nPaletteID;				/**< 色盘ID */
    Gchar	szPaletteName[32];		/**< 色盘名称 */
} GPALETTE;

/**
 * 色盘描述结构体类型
 * 用于存储色盘描述信息
 */
typedef struct tagGPALETTELIST {
    Guint32	nNumberOfPalette;		/**< 色盘个数 */
    GPALETTE *pPalette;				/**< 色盘 */
} GPALETTELIST;

/**
 * 地图中心信息结构体类型
 * 用于存储地图中心信息
 */
typedef struct tagGMAPCENTERINFO {
    GOBJECTID	stRoadId;			/**< 道路ID */
    GCOORD		CenterCoord;		/**< 中心经纬度坐标 */
    Gchar		szRoadName[GMAX_ROAD_NAME_LEN+1]; /**< 最近道路名称 */
} GMAPCENTERINFO;

/**
 * 车标处与其方向平行的道路结构体类型
 * 用于存储地图中心信息
 */
typedef struct tagGCARPARALLELROAD {
    GOBJECTID	stObjectId;							/**< 对象ID */
    Gchar		szRoadName[GMAX_ROAD_NAME_LEN+1];	/**< 道路名称 */
} GCARPARALLELROAD;

/**
 * 当前车位信息结构体类型
 * 用于存储当前车位信息
 */
typedef struct tagGCARINFO {
    GOBJECTID	stRoadId;	    /**< 道路ID */
    Gint32      nRoadDir;       /**< 道路走向 */
    GCOORD		Coord;			/**< 车位地理坐标 */
    Gint16		nAzimuth;		/**< 车位方位角 */
    Gint16		nID;			/**< 车位方位角所对应的车标ID */
    Gchar		szRoadName[GMAX_ROAD_NAME_LEN+1];	/**< 车位所在道路名称 */
} GCARINFO;

/**
 * 道路信息结构体类型
 * 用于存储道路信息
 */
typedef struct tagGROADINFO {
    GOBJECTID	stGObjectID;	/**< 对象ID */
    Gint32		nRoadType;		/**< 道路类型 */
    Gint32		nDistance;		/**< 指定点到该道路的垂直距离 */
    GCOORD		coord;			/**< 垂点坐标 */
    Gchar		szRoadName[GMAX_ROAD_NAME_LEN+1];	/**< 道路名称 */
    Gint32		Reserved1;		/**< 预留1 */
    Gint32		Reserved2;		/**< 预留2 */
} GROADINFO;


/**
 * 道路属性信息
 */
typedef struct tagGROADATTR
{
    GOBJECTID stRoadID;             /**< 道路ID */
    Gint32 nRoadLength;             /**< 道路长度 */
    Gchar szRoadName[GMAX_ROAD_NAME_LEN+1];/**< 道路名称 */
    Gint32 nLimitSpeed;             /**< 道路限速 */
    Gint32 nRoadClass;              /**< 道路等级 0无类型 1高速公路    2城市快速路    3国道 4主要道路    5省道 6次要道路
                                     7县道 8普通道路 9乡公路 10县乡内部路 11非导航道路 12步行导航 */
    Guint8 u8FromWay;    /**< 类型 [FROM_WAY,1:隔离道LinkDivised 2:内部道路LinkinCross 3:连接线JCT 4:圆环线RoundaboutCircle
                          5:服务区道路ServiceRoad 6:引路SlipRoad 7:辅路ServingRoad/SideRoad 8:连接线+引路Slip+JCT
                          9:出口ExitLink 10:入口EntranceLink  11:分流道TurnRightLineA 12:分流道TurnRightLineB
                          13:分流道TurnLeftLineA 14:分流道TurnLeftLineB 15:普通道路CommonLink
                          16:分流道TurnLeftAndRightLine 17:ServiceRoad+JCT(53)
                          18:ServiceRoad+SlipRoad(56) 19:ServiceRoad+SlipRoad+JCT(58)]*/
    Guint8 u8LinkType;    /**< 道路的类型 0普通道路 1轮渡线 2隧道 3桥 4高架路 5高速 6环路 */
    Guint16 u16Rev;    /**< 保留 */
    
    Gint32 nRoadWidth;              /**< 道路宽度 */
    GPOINT stptStart;                 /**< 道路起始坐标 */
    GPOINT stptEnd;                   /**< 道路终止坐标 */
    Gint16 n16Lanes[GMAX_LANE_LEN+1];/**< 车道信息 */
}GROADATTR,*PGROADATTR;	/**< 道路属性信息 */

/**
 * 地图视图句柄
 *
 */
typedef void*	GHMAPVIEW;

/**
 * 地图视图标识
 *
 */
typedef enum tagGMAPVIEWFLAG {
    GMAPVIEW_FLAG_CENTER		= 0x00000001,	/**< 地图中心 */
    GMAPVIEW_FLAG_SCALE_LEVEL	= 0x00000002, 	/**< 比例级别 */
    GMAPVIEW_FLAG_MODE			= 0x00000004, 	/**< 视图模式 */
    GMAPVIEW_FLAG_ANGLE			= 0x00000008, 	/**< 地图角度 */
    GMAPVIEW_FLAG_ALL			= 0xffffffff,	/**< 全部重置 */
} GMAPVIEWFLAG;

/**
 * 屏幕地图对象
 *
 */
typedef struct tagGMAPVIEWINFO {
    GMAPVIEWTYPE	eViewType;	/**< 视图类型 */
    GZOOMLEVEL		eScaleLevel;/**< 比例级别 */
    Gfloat32		fScaleValue;/**< 对应的比例数值 */
    Gfloat32		fPitchAngle;/**< 地图仰角 */
    Gfloat32		fMapAngle;	/**< 地图角度 */
    Gfloat32		fMinPitchAngle; /**< 最低仰角 */
    GMAPVIEWMODE	eMapMode;	/**< 地图模式 */
    GCAMERATYPE		emCameraType;/* 相机模式 */
    GCOORD			MapCenter;	/**< 地图中心 */
    Gbool			bRealCity;	/**< 是否是RealCity */
} GMAPVIEWINFO;

/**
 * 地图显示POI的显示等级
 *
 */
typedef enum tagGPOIDISPLAYLEVEL {
    GPOI_DISPLAYLEVEL_AUTO = 0  /**< 地图显示POI的显示等级：自动 */
} GPOIDISPLAYLEVEL;

/**
 * 地图显示POI的显示信息
 *
 */
typedef struct tagGDISPLAYPOIPRIORITY {
    GPOIDISPLAYLEVEL ePoiDisplayLevel;		/**< 地图显示POI的显示等级 */
    Gint32 nCategory;						/**< 地图显示POI类别 */
} GDISPLAYPOIPRIORITY;

/**
 * 道路名称标注
 *
 */
typedef enum tagGROADNAMELABEL {
    GROADNAME_LABEL_NOROTATE = 0,		/**< 道路名称不随道路旋转 */
    GROADNAME_LABEL_ROTATE = 1,			/**< 道路名称随道路旋转 */
    GROADNAME_LABEL_NOROTATE_MARK = 2,	/**< 道路名称不随道路旋转且带上小箭头指示 */
    GROADNAME_LABEL_NONE = 3,			/**< 不显示道路名称 */
    GROADNAME_LABEL_3DBODY = 4			/**< gl下3d道路名立体标注,gdi不支持 */
} GROADNAMELABEL;

/**
 * 图面POI标注
 *
 */
typedef enum tagGMAPPOILABEL {
    GMAPPOI_LABEL_NAME_ICON = 0,	/**< 图面POI名称图标都显示 */
    GMAPPOI_LABEL_NAME = 1,			/**< 图面POI名称显示 */
    GMAPPOI_LABEL_ICON = 2,			/**< 图面POI图标显示 */
    GMAPPOI_LABEL_NONE = 3			/**< 图面POI名称图标都不显示 */
} GMAPPOILABEL;

/* POI */
/**
 * 经纬坐标电话区号枚举类型
 *
 */
typedef enum tagGCOORDTELTYPE {
    COORDTEL_TYPE_TEL = 0,			/**< 电话区号 */
    COORDTEL_TYPE_COORD				/**< 经纬坐标 */
}GCOORDTELTYPE;

/**
 * 行政区域编码类型枚举
 *
 */
typedef enum tagGADAREATYPE{
    ADAREA_TYPE_COUNTRY = 0x00,		/**< 国家类型 */
    ADAREA_TYPE_PROVINCE = 0x01,	/**< 省类型 */
    ADAREA_TYPE_CITY = 0x03,		/**< 市类型 */
    ADAREA_TYPE_TOWN = 0x04,		/**< 区类型 */
}GADAREATYPE;

/**
 * 经纬坐标电话区号结构体
 *
 */
typedef struct tagGCOORDTEL {
    GCOORDTELTYPE	eFlag;			/**< 标识坐标或者区号有效 */
    GADAREATYPE		euAdCodeLevel;	/**< 行政区域编码类型 */
    union {
        GCOORD	Coord;				/**< 经纬坐标 */
        Gint32	lTelAreaCode;		/**< 电话区号 */
    }u;								/**< 联合体 */
}GCOORDTEL;

/**
 * POI类别信息结构体
 * 用于存储类别编号、名称及其子类信息
 */
typedef struct tagGPOICATEGORY{
    Gint32  nCategoryIDNum;				/**< 类别编号个数 */
    Gint32  *pnCategoryID;				/**< 类别编号数组，参见POI类别编码表 */
    Gint32  nCategoryIndex;				/**< 类别索引，通过类别索引来获取子类信息 */
    Gint16	Reserved;					/**< 保留 */
    Gchar	szName[GMAX_CAT_NAME_LEN+1];	/**< 类别名称 */
}GPOICATEGORY;

/**
 * POI类别列表结构体
 * 用于存储POI类别信息
 */
typedef struct tagGPOICATEGORYLIST{
    Gint32		lNumberOfCategory;	/**< 类别个数 */
    GPOICATEGORY	*pCategory;			/**< 类别信息 */
}GPOICATEGORYLIST;

/**
 * 行政区域数据存在标识枚举
 *
 */
typedef enum tagGADAREADATAFLAG{
    ADAREA_DATA_EXIST = 0,		/**< 存在数据的行政区域 */
    ADAREA_DATA_WHOLE,			/**< 全部区域，包括不存在数据的区域 */
}GADAREADATAFLAG;

/**
 * 行政区域信息结构体
 * 用于存储行政区域编码、名称、简拼
 */
typedef struct tagGADAREAINFO{
    Gint32	lAdminCode;							/**< 行政区域编码，参见行政区域编码表 */
    Gchar	szAdminName[GMAX_ADAREA_NAME_LEN+1];	/**< 行政区域名称 */
}GADAREAINFO;

/**
 * 行政区域信息列表结构体
 * 用于存储行政区域信息
 */
typedef struct tagGADAREAINFOLIST{
    Gint32		lNumberOfAdareaInfo;	/**< 行政区域信息个数 */
    GADAREAINFO	pAdareaInfo[1];			/**< 行政区域信息 */
}GADAREAINFOLIST;

/**
 * 单个行政区域详细信息结构体
 * 用于存储行政区域的省、市、区名称
 */
typedef struct tagGADAREAINFOEX{
    Gint32	lAdminCode;								/**< 行政区域编码，参见行政区域编码表 */
    Gchar	szProvName[GMAX_ADAREA_NAME_LEN+1];		/**< 行政编码对应的省名称 */
    Gchar	szCityName[GMAX_ADAREA_NAME_LEN+1];		/**< 行政编码对应的市名称 */
    Gchar	szTownName[GMAX_ADAREA_NAME_LEN+1];		/**< 行政编码对应的区名称 */
    Gint32	nTel;									/**< 电话区号 */
    GCOORD	coorCenter;								/**< 行政中心经纬度坐标 */
    Gbool	bHasData;								/**< 当前是否存在数据 */
}GADAREAINFOEX;

/**
 * 行政区域结构体
 * 用于存储行政区域编码、名称、简拼及其子行政区信息
 */
typedef struct tagGADAREA{
    Gint32	lAdminCode;							/**< 行政区域编码，参见行政区域编码表 */
    Gchar	szAdminName[GMAX_ADAREA_NAME_LEN+1];	/**< 行政区域名称 */
    Gchar	szAdminSpell[GMAX_ADAREA_NAME_LEN+1];	/**< 行政区域名称首拼 */
    Gint32	lNumberOfSubAdarea;					/**< 下级行政区域个数,网络推荐区域时为符合搜索条件的POI个数 */
    Gint32  nDetailID;                          /**详细信息ID*/
    struct tagGADAREA	*pSubAdarea;						/**< 下级行政区域信息 */
}GADAREA;

/**
 * 行政区域列表结构体
 * 用于存储行政区域
 */
typedef struct tagGADAREALIST{
    Gint32	 lNumberOfAdarea;		/**< 行政区域个数 */
    GADAREA	*pAdarea;				/**< 行政区域 */
}GADAREALIST;

/**
 * 联想候选字结构体
 * 用于存储联想候选字
 */
typedef struct tagGCANDIDATECHAR{
    Guint16	wCharCode;			/**< 候选字编码 */
    Gint16	Reserved;			/**< 保留 */
    Gint32	NumberOfPOI;		/**< 与候选字对应的POI记录条数 */
}GCANDIDATECHAR;

/**
 * 联想候选词结构体
 * 用于存储联想候选词
 */
typedef struct tagGCANDIDATEWORD{
    Gint8	Length;						/**< 词长度 */
    Gint8	Reserved1; 					/**< 保留 */
    Gint16	Reserved2; 					/**< 保留 */
    Gchar	szWord[GMAX_CANDIDATE_WORD_LEN+1];	/**< 词 */
}GCANDIDATEWORD;

/**
 * 联想候选类型枚举
 * 用于标识针对哪个字段进行联想
 */
typedef enum tagGCANDIDATETYPE{
    CANDIDATE_POI_NAME = 0,			/**< POI名称 */
    CANDIDATE_POI_SPELL,			/**< POI名称首拼 */
    CANDIDATE_ADAREA_NAME,			/**< 行政区域名称 */
    CANDIDATE_CROSS_NAME,			/**< 十字路口名称 */
    CANDIDATE_CROSS_SPELL,			/**< 十字路口首拼 */
    CANDIDATE_HOUSENO_NAME,			/**< 门址名称 */
    CANDIDATE_ROAD_NAME				/**< 道路名 */
}GCANDIDATETYPE;

/**
 * 联想候选条件结构体
 * 用于存储联想候选条件
 */
typedef struct tagGCANDIDATECONDITION{
    GCANDIDATETYPE	eCandidateType;			/**< 联想候选类型 */
    Gchar	szKeyword[GMAX_KEYWORD_LEN+1];	/**< 关键字（词） */
}GCANDIDATECONDITION;

/**
 * 联想候选字（词）列表结构体
 * 用于存储联想候选字（词）列表
 */
typedef struct tagGCANDIDATELIST{
    Guint16 NumberOfCandidate;				/**< 候选字（词）个数，最多不超过GMAX_CANDIDATE_NUM */
    Guint16	NumberOfPOI;					/**< 可能的POI个数 */
    union {
        GCANDIDATECHAR *pCandidateChar;		/**< 候选字 */
        GCANDIDATEWORD *pCandidateWord;		/**< 候选词 */
    }u;										/**< 联合体 */
    Guint8	Flag;							/**< 联合体标识：0候选字，1候选词 */
}GCANDIDATELIST;

/**
 * POI检索类型枚举类型
 * 用于标识POI检索类型
 */
typedef enum tagGSEARCHTYPE{
    GSEARCH_TYPE_NAME = 0,			/**< 名称检索 */
    GSEARCH_TYPE_CATEGORY,			/**< 类别检索 */
    GSEARCH_TYPE_TEL,				/**< 电话号码检索 */
    GSEARCH_TYPE_AROUND,			/**< 周边检索 */
    GSEARCH_TYPE_ADDRESS,			/**< 地址检索 */
    GSEARCH_TYPE_ROUTEPOI,			/**< 沿路径POI检索 */
    GSEARCH_TYPE_CROSS,				/**< 交叉路口检索 */
    GSEARCH_TYPE_HOUSENO,			/**< 门址检索 */
    GSEARCH_TYPE_ROADNAME,			/**< 道路名检索 */
    GSEARCH_TYPE_MAX				/**< POI检索类型最大值 */
}GSEARCHTYPE;

/**
 * 图幅道路ID结构体
 * 用于存储图幅ID和图幅内道路ID
 */
typedef struct tagGMESHROADID{
    GOBJECTID	stObjectId;		/**< 对象ID信息 */
}GMESHROADID;

/**
 * 沿路径POI搜索类型
 * 用于指定不同的沿路径搜索类型
 */
typedef enum tagGROUTEPOITYPE {
    GROUTEPOI_TYPE_STARTPOINT	= 0,	/**< 沿路径POI搜索类型:从起点开始一定范围之内 */
    GROUTEPOI_TYPE_CARPOS		= 1,    /**< 沿路径POI搜索类型:从车位开始一定范围之内 */
    GROUTEPOI_TYPE_ALL			= 2     /**< 沿路径POI搜索类型:整条路径 */
}GROUTEPOITYPE;

/**
 * POI类别编码组合结构体
 * 用于存储类别组合个数和类别组合ID
 * 多类别组合,每个类别包含多个ID,vnCatCodeCnt为每个类别的ID个数,vnCatCode为所有类别ID
 * 举例:搜索中国石化和咖啡厅全部两个类别,中国石化ID为:10101,咖啡厅全部ID为:50500;50501;50502;50503;50504
 * 则vnCatCodeCnt[0] = 1,vnCatCodeCnt[1] = 5;
 * vnCatCode[0] = 10101
 * vnCatCode[1] = 50500, vnCatCode[2] = 50501, vnCatCode[3] = 50502, vnCatCode[4] = 50503, vnCatCode[5] = 50504
 */
typedef struct tagGPOICATCODE{
    Gint32	vnCatCodeCnt[GMAX_POI_CAT_NUM];	/**< 类别编码组合个数 */
    Gint32	vnCatCode[GMAX_POI_CAT_NUM];	/**< 类别编码组合，参见POI类别编码表 */
}GPOICATCODE;

/**
 * POI检索条件结构体
 * 用于存储POI检索条件，依据不同检索类型填充不同字段,如下表。
 *	检索类型			类别编码	检索半径	经纬坐标	关键字	路径道路信息
 *	SEARCH_TYPE_NAME		○								●
 *	SEARCH_TYPE_CATEGORY	●								○
 *	SEARCH_TYPE_TEL			○								●
 *	SEARCH_TYPE_AROUND		○		●			●
 *	SEARCH_TYPE_ADDRESS		○								●
 *	SEARCH_TYPE_ROUTEPOI	○										●
 *	SEARCH_TYPE_SPELL										●
 *	说明：●必选，○可选。
 */
typedef struct tagGSEARCHCONDITION{
    GSEARCHTYPE	eSearchType;				/**< 检索类型 */
    GPOICATCODE	stCatCode;					/**< 类别编码组合 */
    Gint32   	lAroundRange;				/**< 周边检索半径，单位：米 */
    Gbool		bUsePoiIndex;				/**< 使用使用POI索引，通过道路名搜索门址，十字路口 */
    Gint32		nPoiIndex;					/**< POI索引值 */
    GCOORD		Coord;						/**< 经纬度坐标 */
    Gchar   	szKeyword[GMAX_KEYWORD_LEN+1];		/**< 关键字 */
    GROUTEPOITYPE eRoutePoiType;			/**< 指定沿路径POI搜索类型 */
}GSEARCHCONDITION;

/**
 * POI信息结构体
 * 用于存储POI信息
 */
typedef struct tagGPOI{
    GCOORD		Coord;			/**< 实际经纬度坐标 */
    Guint8		u8Priority;     /**< POI重要度[0-255], 值越大越靠前显示 */
    Gint32		lCategoryID;	/**< 类别编码，参见POI类别编码表 */
    Gint32		lDistance;		/**< 距参考点的距离 */
    Gint32		lMatchCode;		/**< 匹配度，表示关键字匹配程度 */
    Gint32		lHilightFlag;	/**< 匹配高亮显示，从低位到高位匹配名称字段，最多32位 */
    Gint32		lAdminCode;		/**< 行政编码，参见行政区域编码表 */
    GOBJECTID	stPoiId;			/**< POI唯一ID */
    Gint32		lNaviLon;		/**< 导航经度坐标*/
    Gint32		lNaviLat;		/**< 导航纬度坐标*/
    Gchar		szName[GMAX_POI_NAME_LEN+1];		/**< 名称 */
    Gchar		szAddr[GMAX_POI_ADDR_LEN+1];		/**< 地址 */
    Gchar		szTel[GMAX_POI_TEL_LEN+1];			/**< 电话 */
    Gint32 		lPoiIndex;         	/**< POI索引，内部使用 */
    Guint8		ucFlag;   			/**< bit0:出入口；bit1:楼宇；bit2:亲属关系；bit3:HouseNo标识；bit4:交叉路口标识 */
    Gint8		Reserved;			/**< 保留(行程点：0表示未达到、1表示已到达) */
}GPOI;

/**
 * 获取POI检索结果所需参数结构体
 *
 */
typedef struct tagGETPOIINPUT{
    Gint16	 	sIndex;					/**< 需要获取的第一个索引 */
    Gint16	 	sNumberOfItemToGet;		/**< 需要获取个数 */
}GETPOIINPUT;

/**
 * POI检索结果结构体
 * 用于存储POI检索结果
 */
typedef struct tagGPOIRESULT{
    Gint16	 	sNumberOfTotalItem;		/**< 总的个数 */
    Gint16	 	sIndex;					/**< 获取的第一个索引 */
    Gint16	 	sNumberOfItemGet;		/**< 获取的POI个数 */
    Gint16	 	Reserved;				/**< 保留 */
    GPOI		*pPOI;					/**< POI结果 */
}GPOIRESULT;

/**
 * POI出入口结构体
 * 用于存储POI出入口
 */
typedef enum tagGPOIGATETYPE{
    POI_GATE_TYPE_EXIT = 1,				/**< 出口 */
    POI_GATE_TYPE_ENTRANCE = 2,			/**< 入口 */
    POI_GATE_TYPE_EXIT_ENTRANCE = 3,	/**< 出入口 */
}GPOIGATETYPE;

/**
 * POI出入口结构体
 * 用于存储POI出入口
 */
typedef struct tagGPOIGATEITEM{
    GPOIGATETYPE	eGateType;	/**< 出入口类型 */
    Gint16		siX;			/**< 出入口横向坐标相对于出入口图片左上角（单位：像素） */
    Gint16		siY;			/**< 出入口纵向坐标相对于出入口图片左上角（单位：像素） */
    GCOORD	 	Coord;			/**< 出入口经纬度坐标 */
    Gchar		szGateName[GMAX_POI_NAME_LEN+1];	/**< 出入口名称 */
}GPOIGATEITEM;

/**
 * POI出入口信息结构体
 * 用于存储POI出入口和图片信息
 */
typedef struct tagGPOIGATEINFO{
    Gint32	 	lNumberOfItem;		/**< 出入口信息个数 */
    GPOIGATEITEM	*pGateItem;		/**< 出入口信息 */
    GBITMAP		*pGatePic;			/**< 出入口图片 */
}GPOIGATEINFO;

/**
 * 楼宇内部POI结构体
 * 用于存储楼宇内部POI
 */
typedef struct tagGSETTAREAINSIDEPOI{
    GCOORD	Coord;						/**< 楼宇内部POI经纬度坐标 */
    Gchar	szFloor[4];					/**< 楼宇内部POI所在楼层 */
    Gchar	szName[GMAX_POI_NAME_LEN+1];	/**< 楼宇内部POI名称 */
}GSETTAREAINSIDEPOI;

/**
 * 楼宇信息结构体
 * 用于存储楼宇信息及其内部POI信息
 */
typedef struct tagGSETTAREAINFO{
    Gint32	 	lSettAreaID;				/**< 楼宇ID */
    Gchar		szName[GMAX_POI_NAME_LEN+1];/**< 楼宇名称 */
    Gint32	 	lNumberOfInsidePOI;			/**< 楼宇内部PO个数 */
    GSETTAREAINSIDEPOI *pInsidePOI;			/**< 楼宇内部POI */
}GSETTAREAINFO;

/**
 * 亲属关系POI结构体
 * 用于存储亲属关系
 */
typedef struct tagGRELATIONSHIPPOI{
    GCOORD	Coord;							/**< POI经纬度坐标 */
    Gchar	szName[GMAX_POI_NAME_LEN+1];	/**< POI名称 */
}GRELATIONSHIPPOI;

/**
 * 具有亲属关系POI列表结构体
 * 用于存储亲属关系POI
 */
typedef struct tagGRELATIONSHIPPOILIST{
    Gint32	 	lNumberOfRelationshipPOI;		/**< 亲属关系POI个数 */
    GRELATIONSHIPPOI *pRelationshipPOI;			/**< 亲属关系POI */
}GRELATIONSHIPPOILIST;

/**
 * POI列表结构体
 *
 */
typedef struct tagGPOILIST{
    Gint32	 lNumberOfPoi;		/**< POI个数 */
    GPOI	*pPOI;				/**< POI */
}GPOILIST;

/* Journey */
/**
 * 添加行程点回调接口
 *
 */
typedef Gint32 (*GJOURNEYNOTIFYCB)(GROADINFO *pRoadInfo, Gint32 nNumberOfRoadInfo, void *lpVoid);

/**
 * 行程点枚举类型
 *
 */
typedef enum tagGJOURNEYPOINTTYPE {
    GJOURNEY_START = 0,	 	/**< 起点 */
    GJOURNEY_VIA1,	 		/**< 途经地1 */
    GJOURNEY_VIA2,	 		/**< 途经地2 */
    GJOURNEY_VIA3,	 		/**< 途经地3 */
    GJOURNEY_VIA4,	 		/**< 途经地4 */
    GJOURNEY_VIA5,	 		/**< 途经地5 */
    GJOURNEY_GOAL,	 		/**< 目的地 */
    GJOURNEY_MAX			/**< 行程点最大值 */
} GJOURNEYPOINTTYPE;

/* route */
/**
 * 路径演算错误信息
 *
 */
typedef struct tagGROUTEERRORINFO {
    Gint32 nNumberOfList;				/**< 行政编码列表个数 */
    Gint32* pAdminCodeList;				/**< 行政编码列表指针 */
} GROUTEERRORINFO;

/* guidance */
/**
 * 机动信息结构体类型
 *
 */
typedef struct tagGMANEUVERINFO {
    GOBJECTID	stGObjectID;		/**< 道路ID */
    Guint32		nTurnID;			/**< 转向ID  (nTurnID&0x7FFFFFFF) == 6表示终点 (nTurnID&0x7FFFFFFF) == 3表示到达途径点*/
    Gint32		nNextDis;			/**< 路口距离（单位：米） */
    Gint32		nNextArrivalTime; 	/**< 到达路口预计耗时（单位：分） */
    Gint32		nTotalRemainDis;	/**< 到达目的地距离（单位：米） */
    Gint32		nTotalArrivalTime;	/**< 到达目的地预计耗时（单位：分） */
    Gchar		szCurRoadName[GMAX_ROAD_NAME_LEN+1];	/**< 当前道路名 */
    Gchar		szNextRoadName[GMAX_ROAD_NAME_LEN+1];/**< 下一道路名 */
} GMANEUVERINFO;

/**
 * 引导路径经过的城市的相关信息
 *
 */
typedef struct tagGGUIDEROUTECITYINFO {
    Gint32 nNumberOfList;				/**< 行政编码列表个数 */
    Gint32* pAdminCodeList;				/**< 行政编码列表指针 */
    Gint32* pETA;                       /**< 到达该城市预计耗时（单位：分） */
} GGUIDEROUTECITYINFO;

/**
 * 实时交通流状态类型
 *
 */
typedef enum tagGTRAFFICSTREAM {
    GTRAFFIC_STREAM_FREE			= 0x01, 	/**< 畅通 */
    GTRAFFIC_STREAM_BUSY			= 0x02, 	/**< 繁忙 */
    GTRAFFIC_STREAM_SLOW			= 0x03,		/**< 缓行 */
    GTRAFFIC_STREAM_CROWDED			= 0x04,		/**< 拥堵 */
    GTRAFFIC_STREAM_SEVERE_CROWDED	= 0x05,		/**< 严重拥堵 */
    GTRAFFIC_STREAM_UNCOVERED		= 0x06, 	/**< 无数据(数据没有覆盖) */
    GTRAFFIC_STREAM_NONE			= 0x07		/**< 无交通流状态数据 */
} GTRAFFICSTREAM;

/**
 * TPEG圈模式
 *
 */
typedef enum tagGTPEGRINGMODE {
    GTPEG_RINGMODE_INNER		= 0,		/**< TPEG内圈 */
    GTPEG_RINGMODE_OUTER		= 1,		/**< TPEG外圈 */
    GTPEG_RINGMODE_WHOLECITY	= 2			/**< TPEG全城 */
} GTPEGRINGMODE;

/**
 * TMC数据来源模式
 *
 */
typedef enum tagGTMCMODE {
    GTMC_MODE_GD		= 0,			/**< TMC数据来源：高德 */
    GTMC_MODE_TPEG		= 1,			/**< TMC数据来源：TPEG模式 */
    GTMC_MODE_RTIC		= 2			    /**< TMC数据来源：世纪高通 */
} GTMCMODE;

/**
 * TMC语音提示类型
 *
 */
typedef enum tagGTMCPROMPTTYPE {
    GTMC_PROMPTTYPE_ALL	= 0,			/**< 所有语音都播报（TTS,叮咚声） */
    GTMC_PROMPTTYPE_WAV	= 1,			/**< 只播报Wav文件（叮咚声）*/
    GTMC_PROMPTTYPE_NONE= 2				/**< 都不播报 */
}GTMCPROMPTTYPE;

/**
 * TMC事件信息结构类型
 *
 */
typedef struct tagGEVENTINFO {
    GOBJECTID	stObjectId;									/**< 对象ID信息 */
    Gint32		nEventID;									/**< 事件ID */
    Guint32		nMsgID;										/**< 消息ID */
    GCOORD		stPosition;									/**< 事件位置 */
    Gint32		nDir;										/**< 车位到事件的角度 */
    Gchar		szRoadName[GMAX_ROAD_NAME_LEN+1];              /**< 事件所在道路名   */
    Gchar		szFromRoad[GMAX_ROAD_NAME_LEN+1];			    /**< 事件的起始交叉道路名  */
    Gchar		szToRoad[GMAX_ROAD_NAME_LEN+1];			    /**< 事件的终止交叉道路名  */
    Gchar       szDurationInfo[GMAX_TRAFFIC_DURATION_LEN+1]; /* 事件持续时间描述*/
    GDATETIME	stuStartTime;			                    /**< 事件发生时间 */
    GDATETIME	stuEndTime;				                    /**< 事件结束时间 （预留）*/
    Gint32		nLength;				                    /**< 事件影响的长度(米) */
    Gint32		nDisToCar;				                    /**< 距离车位距离，可能为负数, 路径上事件：车位到事件的路径距离，非路径上：车位到事件直线距离 */
} GEVENTINFO, *PGEVENTINFO;									/**< 事件信息结构类型 */

/**
 * 引导道路属性标志位
 *
 */
typedef enum tagGGUIDEROADFLAG {
    G_GUIDE_ROAD_FLAG_TRAFFIC_LIGHT	= 0x01,	/**< 交通灯 */
    G_GUIDE_ROAD_FLAG_TOLL_GATE		= 0x02,	/**< 收费站 */
    G_GUIDE_ROAD_FLAG_CAR			= 0x04,	/**< 当前车位所在路段 */
    G_GUIDE_ROAD_FLAG_NOTPASSED		= 0x20, /**< 未通过路段 */
} GGUIDEROADFLAG;

/**
 * 机动信息结构体类型
 *
 */
typedef struct tagGGUIDEROADINFO {
    Guint32		nID; 					/**< ID */
    Guint32		unTurnID;				/**< 转向ID */
    Gint32		nNextDis;				/**< 路口距离（单位：米） */
    Gint32		nNextArrivalTime; 		/**< 到达路口预计耗时（单位：分） */
    Gint32		nTotalRemainDis;		/**< 到达目的地距离（单位：米） */
    Gchar		*pzCurRoadName;	        /**< 当前道路名 */
    Gchar		*pzNextRoadName;        /**< 下一道路名 */
    GTRAFFICSTREAM	eTrafficStream;		/**< 实时交通流状态 */
    Guint32		nTrafficEventID;		/**< 实时交通事件ID */
    Guint32		nChinaRoadID;			/**< 道路ID */
    GGUIDEROADFLAG		eFlag;			/**< 道路属性标志位 */
    Guint32		nDisFromCar;			/**< 车位到该路口距离 */
    GOBJECTID	stObjectId;				/**< 对象ID信息 */
    Gint32      lLon;                   /**< 经度 */
    Gint32      lLat;                   /**< 纬度 */
    Gint32      nRoadClass;             /**< 道路等级*/
    Gint16      *pn16Lane;              /*车道 高两位(0.不可通行 1.可通行 2.推荐)*/
    Gint32      nLaneNum;               /* 车道个数 */
} GGUIDEROADINFO;

/**
 * 机动信息结构体类型
 *
 */
typedef struct tagGGUIDEROADLIST {
    Guint32		nNumberOfRoad;			/**< 道路条数 */
    GGUIDEROADINFO *pGuideRoadInfo;		/**< 道路信息 */
} GGUIDEROADLIST;

/**
 * 机动信息结构体类型
 *
 */
typedef struct tagGMANEUVERTEXT {
    GOBJECTID	stObjectId;				/**< 对象ID信息 */
    Guint32		nID; 					/**< ID */
    Guint32		unTurnID;				/**< 转向ID */
    Gint32		nNextDis;				/**< 路口距离（单位：米） */
    Gint32		nNextArrivalTime; 		/**< 到达路口预计耗时（单位：分） */
    Gint32		nTotalRemainDis;		/**< 到达目的地距离（单位：米） */
    Gint32      nTrafficLightNum;       /**< 交通灯数目 */
    GTRAFFICSTREAM	eTrafficStream;		/**< 实时交通状态 */
    Guint32		nTrafficEventID;		/**< 实时交通事件ID */
    GOBJECTID   *pstTrafficObjId;       /**< 事件对象ID */
    Gint32      nTrafficObjIdNum;       /**< 事件对象个数 */
    GGUIDEROADFLAG		eFlag;			/**< 道路属性标志位 */
    Gint32		nDisFromCar;			/**< 车位到该路口距离 */
    Gchar		szDescription[GMAX_MANEUVER_TEXT_LEN+1];		/**< 机动信息描述 */
    Guint32		nNumberOfSubManeuver;	/**< 个数 */
    GCOORD		Coord;					/**< 经纬度信息 */
    struct tagGMANEUVERTEXT *pstSubManeuverText;		/**< 机动文本信息 */
} GMANEUVERTEXT;

/**
 * 机动文本信息结构体类型
 *
 */
typedef struct tagGMANEUVERTEXTLIST {
    Guint32		nNumberOfManeuver;		/**< 个数 */
    GMANEUVERTEXT	*pManeuverText;		/**< 机动文本信息 */
} GMANEUVERTEXTLIST;

/**
 * 路径统计信息结构体类型
 *
 */
typedef struct tagGPATHSTATISTICINFO {
    Guint32		nTotalDis;				/**< 道路总长度 */
    Guint32		nTotalChargeDis;		/**< 收费路段总长度 */
    Guint32		nTotalHighwayDis;		/**< 高速路段总长度 */
    Guint32		nTotalCircleDis;		/**< 环城路段总长度 */
    Guint32		nTotalHighDis;			/**< 高等路段总长度 */
    Guint32		nTotalMidDis;			/**< 中等路段总长度 */
    Guint32		nTotalLowDis;			/**< 低等路段总长度 */
    Guint32		nTotalCharge;			/**< 收费总额 */
    Guint32		nTotalTollGate;			/**< 收费站总个数 */
    Guint32		nTotalTrafficLight;		/**< 红绿灯总个数 */
    
    Guint32		nRemainDis;				/**< 道路剩余长度 */
    Guint32		nRemainChargeDis;		/**< 收费路段剩余长度 */
    Guint32		nRemainHighwayDis;		/**< 高速路段剩余长度 */
    Guint32		nRemainCircleDis;		/**< 环城路段剩余长度 */
    Guint32		nRemainHighDis;			/**< 高等路段剩余长度 */
    Guint32		nRemainMidDis;			/**< 中等路段剩余长度 */
    Guint32		nRemainLowDis;			/**< 低等路段剩余长度 */
    Guint32		nRemainCharge;			/**< 收费剩余额 */
    Guint32		nRemainTollGate;		/**< 收费站剩余个数 */
    Guint32		nRemainTrafficLight;	/**< 红绿灯剩余个数 */
    
    Guint32		nTime;					/**< 预计时间（单位：分） */
} GPATHSTATISTICINFO;

/**
 * 路径统计信息列表结构体类型
 *
 */
typedef struct tagGPATHSTATISTICLIST {
    Guint32		nNumberOfStat;			/**< 统计信息个数 */
    GPATHSTATISTICINFO *pPathStat;		/**< 统计信息 */
} GPATHSTATISTICLIST;

/**
 * 引导状态枚举类型
 *
 */
typedef enum tagGGUIDEFLAGS {
    G_GUIDE_FLAGS_CROSSZOOM = 0x01,			/**< 路口放大 */
    G_GUIDE_FLAGS_GUIDEPOST = 0x02,			/**< 高速路牌 */
    G_GUIDE_FLAGS_SIGNPOST  = 0x04,			/**< 蓝色看板 */
} GGUIDEFLAGS;

/**
 * 高速路牌种类枚举类型
 *
 */
typedef enum tagGGUIDEPOSTOPTION {
    G_GUIDEPOST_OPTION_NONE	= 0x00,			/**< 无 */
    G_GUIDEPOST_OPTION_SA	= 0x01,			/**< 高速服务区 */
    G_GUIDEPOST_OPTION_EXIT	= 0x02,			/**< 高速出口 */
    G_GUIDEPOST_OPTION_ENTRY= 0x04,			/**< 高速入口 */
    G_GUIDEPOST_OPTION_ALL	= 0x07			/**< 所有 */
} GGUIDEPOSTOPTION;

/**
 * 高速服务区类型
 *
 */
typedef struct tagGSERVICEAREA {
    Gint32		nDis;			/**< 距离（单位：米） */
    Gint32		nArrivalTime; 	/**< 到达预计耗时（单位：分） */
    GSERVICEAREAFLAG eSAFlag;	/**< 服务区服务类型 */
    Gchar		szName[GMAX_POI_NAME_LEN+1];	/**< 服务区名称 */
} GSERVICEAREA;

/**
 * 高速机动信息结构体类型
 *
 */
typedef struct tagGHIGHWAYMANEUVERINFO {
    GOBJECTID	stGObjectID	;		/**< 道路ID  */
    Gint32		nTurnID;			/**< 转向ID */
    Gint32		nNextDis;			/**< 路口距离（单位：米） */
    Gint32		nNextArrivalTime; 	/**< 到达路口预计耗时（单位：分） */
    Gint32		nExitDis;			/**< 高速出口距离（单位：米） */
    Gint32		nExitTime;			/**< 到达高速出口预计耗时（单位：分） */
    Gint32		nTotalRemainDis;	/**< 到达目的地距离（单位：米） */
    Gint32		nTotalArrivalTime;	/**< 到达目的地预计耗时（单位：分） */
    Gchar		szCurRoadName[GMAX_ROAD_NAME_LEN+1];	/**< 当前道路名 */
    Gchar		szNextRoadName[GMAX_ROAD_NAME_LEN+1];/**< 下一道路名 */
    Gchar       szHighWayName[GMAX_ROAD_NAME_LEN+1]; /* 高速出口道路名 */
    Gint32		nServiceAreaNum;	/**< 服务区个数 */
    GSERVICEAREA *pServiceAreas;	/**< 服务区 */
} GHIGHWAYMANEUVERINFO;

/**
 * 放大路口种类枚举类型
 *
 */
typedef enum tagGZOOMVIEWTYPE {
    G_ZOOM_VIEW_TYPE_VECTOR	= 0,			/**< 矢量放大路口 */
    G_ZOOM_VIEW_TYPE_BITMAP,				/**< 位图放大路口 */
    G_ZOOM_VIEW_TYPE_REAL					/**< 实景放大路口 */
} GZOOMVIEWTYPE;

/**
 * 放大路口类型枚举类型
 *
 */
typedef struct tagGZOOMVIEWINFO {
    GZOOMVIEWTYPE eViewType;		/**< 放大路口类型 */
    Gint32		nTurnID;			/**< 转向ID */
    Gint32		nNextDis;			/**< 路口距离（单位：米） */
} GZOOMVIEWINFO;

/**
 * 引导路径句柄
 *
 */
typedef void*	GHGUIDEROUTE;

/**
 * 引导路径信息结构体
 *
 */
typedef struct tagGGUIDEROUTEINFO {
    Gint32		nRule[GJOURNEY_MAX];/**< 规划原则数组（每个行程点都可以对应一种规划原则） */
    Gbool		bHasAvoidRoad;		/**< 是否包含避让道路，即避让失败。 */
    Gbool bUseTMC;          /* 是否有TMC参与 */
    GDATETIME stTime;          /* 在该时刻进行规划 */
} GGUIDEROUTEINFO;

/**
 * 引导道路TMC信息结构体
 * 以交通流状态为依据合并相关道路
 */
typedef struct tagGGUIDEROADTMC {
    Gint32 sIndex;			/**< 起始索引号			*/
    Gint32 eIndex;			/**< 结束索引号			*/
    Gint32 nDisFromStart;	/**< 距离路径起点的距离	*/
    Gint32 nDis;			/**< 此段长度				*/
    Gchar *szRoadNames;		/**< 道路名称以逗号隔开，不包含未命名道路 */
    Gint32 nNumberOfEvent;	/**< 事件个数				*/
    Gint32 *pTrafficEvents;	/**< 事件ID和距起点的距离	*/
    Gint32 eTrafficStream;	/**< 流状态				*/
    Gint32 nDelayTime;		/**< 延迟时间				*/
} GGUIDEROADTMC;

/**
 * 引导道路TMC列表信息结构体
 *
 */
typedef struct tagGGUIDEROADTMCLIST {
    Gint32 nTotalDis;		/**< 道路总距离			*/
    Gint32 nCarIndex;		/**< 车位所在记录索引		*/
    Gint32 nCarDisFromStart;/**< 车位距离路径起点距离	*/
    Gint32 nDestDisFromStart[GMAX_JOURNEY_POINT_NUM][2]; /**< 目的地距离起点距离(记录索引、距离起点距离) */
    Gint32 nNumberOfItem;	/**< 记录个数				*/
    GGUIDEROADTMC *pItem; 	/**< 记录信息				*/
} GGUIDEROADTMCLIST;

/* Favorite */

/**
 * 收藏兴趣点显示图标类别枚举类型
 *
 */
typedef enum tagGFAVORITEICON{
    GFAVORITE_ICON_DEFAULT = 1,		/**< 默认 */
    GFAVORITE_ICON_HOME,	 		/**< 我家 */
    GFAVORITE_ICON_COMPANY,	 		/**< 公司 */
    GFAVORITE_ICON_FRIEND,	 		/**< 朋友 */
    GFAVORITE_ICON_DINING,	 		/**< 饮食 */
    GFAVORITE_ICON_LEISURE,			/**< 休闲 */
    GFAVORITE_ICON_SHOPPING,		/**< 购物 */
    GFAVORITE_ICON_WORK,			/**< 工作 */
    GFAVORITE_ICON_SIGHT,	 		/**< 景点 */
    GFAVORITE_ICON_CUSTOMER,		/**< 客户 */
    GFAVORITE_ICON_ENTERTAINMENT,	/**< 娱乐 */
    GFAVORITE_ICON_HISTORY,			/**< 历史目的地 */
    GFAVORITE_ICON_MAX				/**< 收藏兴趣点显示图标类别枚举类型最大值 */
} GFAVORITEICON;

/**
 * 收藏夹兴趣点结构体类型
 *
 */
typedef struct tagGFAVORITEPOI {
    Gint32				nIndex;		/**< 索引 */
    GFAVORITECATEGORY	eCategory;	/**< 收藏夹类别 */
    GFAVORITEICON		eIconID;	/**< 收藏点显示图标 */
    GPOI				Poi; 		/**< 收藏夹兴趣点 */
    GDATE				Date;		/**< 收藏的日期 */
    GTIME				Time;		/**< 收藏的时间 */
} GFAVORITEPOI;

/**
 * 收藏夹兴趣点列表结构体类型
 *
 */
typedef struct tagGFAVORITEPOILIST {
    Gint32			nNumberOfItem;		/**< 收藏夹兴趣点个数 */
    GFAVORITEPOI	*pFavoritePOI; 		/**< 收藏夹兴趣点 */
} GFAVORITEPOILIST;

/**
 * 容量状态结构体类型
 *
 */
typedef struct tagGSPACESTATUS{
    Gint32			nTotalSpace;		/**< 总容量（单位：个） */
    Gint32			nAvailSpace;		/**< 可用容量（单位：个） */
} GSPACESTATUS;

/**
 * 收藏夹容量状态结构体类型
 *
 */
typedef struct tagGFAVORITESTATUS{
    GSPACESTATUS			TotalStatus;			/**< 收藏夹总空间状态 */
    GSPACESTATUS			Status[GFAVORITE_CATEGORY_MAX];	/**< 各类别空间状态 */
} GFAVORITESTATUS;

/* track */
/**
 * 轨迹信息结构体类型
 *
 */
typedef struct tagGTRACKINFO{
    Gint32 nIndex;		/**< 索引 */
    Gbool bLoaded;		/**< 是否已被载入内存 */
    Gchar szTrackName[GMAX_TRACK_NAME_LEN+1];	/**< 轨迹文件名（不带路径和扩展名） */
} GTRACKINFO;

/**
 * 轨迹信息结构体类型
 *
 */
typedef struct tagGTRACKINFOLIST{
    Guint32		nNumberOfTrack;	/**< 轨迹条数 */
    GTRACKINFO	*pTrackInfo;	/**< 轨迹信息 */
} GTRACKINFOLIST;

/**
 * 轨迹线信息结构体类型
 *
 */
typedef struct tagGTRACKLINEINFO{
    GPOINT      *pCoord;    /*点数组*/
    Gint32      nNum;       /*点个数*/
    Gint32      nLineWide;  /*线宽度*/
    Gint32      nLineSideWide;  /*边线宽度*/
    GRGBA		clrSide;    /*边线颜色*/
    GRGBA       clrFill;    /*线颜色*/
} GTRACKLINEINFO, *PGTRACKLINEINFO;

/**< Detour */
/**
 * 避让道路选项枚举类型
 *
 */
typedef enum tagGDETOUROPTION{
    GDETOUR_OPTION_ONCE = 0,		/**< 一次有效 */
    GDETOUR_OPTION_TODAY, 			/**< 今天有效 */
    GDETOUR_OPTION_ONE_WEEK, 		/**< 一周有效 */
    GDETOUR_OPTION_ONE_MONTH, 		/**< 一个月有效 */
    GDETOUR_OPTION_ONE_YEAR, 		/**< 一年有效 */
    GDETOUR_OPTION_FOREVER, 		/**< 永久有效 */
    GDETOUR_OPTION_CUSTOMIZE		/**< 自定义时间段 */
} GDETOUROPTION;

/**
 * 避让道路信息结构体类型
 *
 */
typedef struct tagGDETOURROADINFO{
    GOBJECTID	stObjectId;		/**< 对象ID信息 */
    Gint32	 nIndex;			/**< 索引 */
    GCOORD	 Coord;				/**< 避让道路坐标 */
    GDETOUROPTION eOption;		/**< 避让选项 */
    GDATETIME	StartTime; 		/**< 避让起始时间 */
    GDATETIME	EndTime; 		/**< 避让结束时间 */
    Gchar	szRoadName[GMAX_ROAD_NAME_LEN+1]; 		/**< 道路名称 */
} GDETOURROADINFO;

/**
 * 避让道路信息列表结构体类型
 *
 */
typedef struct tagGDETOURROADLIST{
    Guint32	 nNumberOfDetourRoad;		/**< 避让道路条数 */
    GDETOURROADINFO	 *pDetourRoad;		/**< 避让道路信息 */
} GDETOURROADLIST;

/**
 * 避让道路城市信息
 *
 */
typedef struct tagGDETOURROADCITYINFO{
    GADMINCODE stAdcode;
    GVERSION stVersion;
} GDETOURROADCITYINFO;

/* TTS */
/**
 * TTS播报者角色枚举类型
 *
 */
typedef enum tagGTTSROLE {
    GTTS_ROLE_DEFAULT_MAN = 0,	/**< 普通话男 */
    GTTS_ROLE_DEFAULT_WOMAN,	/**< 普通话女 */
    GTTS_ROLE_CANTONESE_MAN,	/**< 广东话男 */
    GTTS_ROLE_CANTONESE_WOMAN,	/**< 广东话女 */
    GTTS_ROLE_DONGBEI_MAN,		/**< 东北话男 */
    GTTS_ROLE_DONGBEI_WOMAN,	/**< 东北话女 */
    GTTS_ROLE_SICHUAN_MAN,		/**< 四川话男 */
    GTTS_ROLE_SICHUAN_WOMAN,	/**< 四川话女 */
    GTTS_ROLE_TAIWAN_MAN,		/**< 台湾话男 */
    GTTS_ROLE_TAIWAN_WOMAN,		/**< 台湾话女 */
    GTTS_ROLE_HUNAN_MAN,		/**< 湖南男声 */
    GTTS_ROLE_HENAN_MAN,		/**< 河南男声 */
    GTTS_ROLE_ENGLISH_MAN,		/**< 英文男 */
    GTTS_ROLE_ENGLISH_WOMAN,	/**< 英文女 */
    GTTS_ROLE_CHILD				/**< 普通话儿童 */
} GTTSROLE;

/**
 * TTS播报回调枚举类型
 *
 */
typedef enum tagGTTSCALLBACKTYPE {
    GTTS_CALLBACK_BEFORE_PLAY = 1,	/**< 播报前回调 */
    GTTS_CALLBACK_AFTER_PLAY  = 2,	/**< 播报后回调 */
} GTTSCALLBACKTYPE;

/* 手写 */
/**
 * 识别参数枚举类型
 *
 */
typedef enum tagGHWFLAG {
    GHW_CHARSET_CHINESE		= 0x0001,	/**< 中文字符集 */
    GHW_CHARSET_ENGLISH		= 0x0002,	/**< 英文字符集 */
    GHW_CHARSET_NUMBER		= 0x0004,	/**< 数字字符集 */
    GHW_CHARSET_PUNCTUATION	= 0x0008,	/**< 标点符号字符集 */
    GHW_OUTPUT_DEFAULT		= 0x0010,	/**< 默认输出，即不做任何转换 */
    GHW_OUTPUT_SIMPLE		= 0x0020,	/**< 输出简体中文 */
    GHW_OUTPUT_TRADITIONAL	= 0x0040,	/**< 输出繁体中文 */
    GHW_OUTPUT_LOWERCASE	= 0x0080,	/**< 输出小写字符 */
    GHW_OUTPUT_UPPERCASE	= 0x0100,	/**< 输出大写字符 */
} GHWFLAG;

/**
 * 识别手势枚举类型
 *
 */
typedef enum tagGHWGESTURE {
    GHW_GESTURE_BACKSPACE	= 0x0008,	/**< 回删 */
    GHW_GESTURE_TAB			= 0x0009,	/**< 制表符 */
    GHW_GESTURE_RETURN		= 0x000D,	/**< 回车 */
    GHW_GESTURE_SPACE		= 0x0020,	/**< 空格 */
} GHWGESTURE;

/**
 * 手写识别输入参数结构体类型
 *
 */
typedef struct tagGHWINPUT {
    GHWFLAG	eFlag;					/**< 识别参数 */
    Gint16	nMaxNumberOfCandidate;	/**< 期望的识别候选字个数 */
    Gint16	nNumberOfStrokePoint;	/**< 笔画轨迹点个数 */
    GSCOORD	*pStokePoint;			/**< 笔画轨迹点坐标（单位：像素） */
} GHWINPUT;

/**
 * 手写识别输出结构体类型
 *
 */
typedef struct tagGHWCANDIDATE {
    Guint16	nNumberOfCandidate;		/**< 候选字个数 */
    Guint16	*pCandidate;			/**< 候选字 */
} GHWCANDIDATE;

/**
 * 输入法枚举类型
 *
 */
typedef enum tagGIMMODE {
    GIM_MODE_PY		= 0,		/**< 拼音 */
    GIM_MODE_BH,				/**< 笔画 */
    GIM_MODE_WB,				/**< 五笔 */
    GIM_MODE_EN,				/**< 英文 */
    GIM_MODE_HW,				/**< 手写 */
} GIMMODE;

/**
 * 输入法语言枚举类型
 *
 */
typedef enum tagGIMLANGUAGE
{
    GIM_LANGUAGE_SIMPLE_CHINESE	  = 0,		/**< 简体中文 */
    GIM_LANGUAGE_ENGLISH,					/**< 英文 */
    GIM_LANGUAGE_TRADITIONAL_CHINESE,		/**< 繁体中文 */
} GIMLANGUAGE;

/**
 * GPS基本信息结构体类型
 *
 */
typedef struct tagGGPSINFO {
    GDATE 		date;		/**< 日期 */
    GTIME 		time;		/**< 时间 */
    Gint8		nValid;		/**< 有效? 0无效，1有效。 */
    Gint8		nNumberOfSatellite;		/**< 卫星颗数 */
    Gint8		nMode;		/**< 模式：0GPS，1惯导 */
    Gint8		Reserved;	/**< 预留 */
    Gint32		nSpeed;		/**< 速度 */
    Gint32		nAzimuth;	/**< 方位角度 */
    Gint32		nAltitude;	/**< 海拔 */
} GGPSINFO, *PGGPSINFO;		/**< GPS基本信息结构体 */

/**
 * MID 层用的 GPS基本信息结构体类型
 *
 */
typedef struct tagGGPSINFOEX {
    Gint32	lLon;		/**< 经度 */
    Gint32	lLat;		/**< 纬度 */
    Gint8	cStatus;	/**< A：有效，V：无效 */
    Gint8	cLongitude;	/**< E表示东经，W表示西经 */
    Gint8	cLatitude;	/**< N表示北纬，S表示南纬 */
    Gint8	cYear;		/**< 年 */
    Gint8	cMonth;		/**< 月 */
    Gint8	cDay;		/**< 日 */
    Gint8	cHour;		/**< 时 */
    Gint8	cMinute;	/**< 分 */
    Gint8	cSecond;	/**< 秒 */
    Gint8	cSatelliteNum;	/**< 卫星颗数 */
    Gint8	cMode;			/**< GPS模式 */
    Gfloat64	dSpeed;		/**< 速度 */
    Gfloat64	dAzimuth;	/**< 方位角 */
    Gfloat64	dHDOP;		/**< 水平精度定位因子 */
    Gfloat64	dAltitude;	/**< 海拔 */
} GGPSINFOEX;

/**
 * 卫星状态结构体类型
 *
 */
typedef struct tagGSATELLITE {
    Gint32	nID;		 /**< 卫星ID */
    Gint32	nInFix;		 /**< 用于定位 */
    Gint32	nElevation;	 /**< 仰角 */
    Gint32	nAzimuth;	 /**< 方位角 */
    Gint32	nSNR;		 /**< 信噪比 */
} GSATELLITE;

#define MAX_SATELLITE	12	/**< 最大卫星个数 */

/**
 * 卫星状态结构体类型
 *
 */
typedef struct tagGSATELLITEINFO {
    Gint32		nNumberOfInView;			/**< 可视卫星颗数 */
    GSATELLITE	sat[MAX_SATELLITE];			/**< 卫星信息 */
} GSATELLITEINFO;

/**
 * 放大路口图模式
 *
 */
typedef enum tagGZOOMVIEWMODE {
    GZOOM_VIEW_MODE_REAL	= 0,			/**< 实景图 */
    GZOOM_VIEW_MODE_VECTOR	= 1				/**< 矢量图 */
} GZOOMVIEWMODE;

/**
 * 参数
 *
 */
typedef enum tagGPARAM {
    /*  */
    G_DISPLAY_ORIENTATION		= 0x0000,		/**< 地图窗口方向（横屏、竖屏） */
    G_LANGUAGE					= 0x0001,		/**< 描述地图数据语言状态：中文简体、中文繁体、英文。对于语言的设置，要求放置在GDBL_CreateView函数之后 */
    G_BACKGROUND_MODE			= 0x0002,		/**< 背景模式 */
    G_GPS_FORMAT				= 0x0003,		/**< GPS语句格式 */
    G_DISABLE_BLGPS				= 0x0004,		/**< 禁用BL读取串口数据 */
    G_MAPPATH_STRING            = 0x0005,		/**< 地图路径字符串 */
    G_POIPATH_STRING            = 0x0006,		/**< POI路径字符串 */
    G_NETPATH_STRING                = 0x0007,       /**< 网络缓存路径字符串 */
    
    /* map rect horizontal */
    G_H_MAP_VIEW_RECT			= 0x0100,		/**< 地图窗口位置、尺寸（横屏） */
    G_H_OVERVIEW_FRGND_RECT		= 0x0101,		/**< 全程前景窗口位置、尺寸（横屏） */
    G_H_ZOOM_VIEW_RECT			= 0x0102,		/**< 放大窗口位置、尺寸（横屏-矢量） */
    G_H_ZOOM_VIEW_BITMAP_RECT	= 0x0103,		/**< 放大窗口位置、尺寸（横屏-位图） */
    G_H_ZOOM_VIEW_REAL_RECT		= 0x0104,		/**< 放大窗口位置、尺寸（横屏-实景）*/
    G_H_GUIDEPOST_VIEW_RECT		= 0x0105,		/**< 高速提示牌位置、尺寸（横屏） */
    G_H_SIGNPOST_VIEW_RECT		= 0x0106,		/**< 看板位置、尺寸（横屏） */
    G_H_OVERVIEW_BKGND_RECT		= 0x0107,		/**< 全程背景窗口位置、尺寸（横屏） */
    
    /* map rect vertical */
    G_V_MAP_VIEW_RECT			= 0x0200,		/**< 地图窗口位置、尺寸（竖屏） */
    G_V_OVERVIEW_FRGND_RECT		= 0x0201,		/**< 全程前景窗口位置、尺寸（竖屏） */
    G_V_ZOOM_VIEW_RECT			= 0x0202,		/**< 放大窗口位置、尺寸（竖屏-矢量） */
    G_V_ZOOM_VIEW_BITMAP_RECT	= 0x0203,		/**< 放大窗口位置、尺寸（竖屏-位图） */
    G_V_ZOOM_VIEW_REAL_RECT		= 0x0204,		/**< 放大窗口位置、尺寸（竖屏-实景） */
    G_V_GUIDEPOST_VIEW_RECT		= 0x0205,		/**< 高速提示牌位置、尺寸（竖屏） */
    G_V_SIGNPOST_VIEW_RECT		= 0x0206,		/**< 看板位置、尺寸（竖屏） */
    G_V_OVERVIEW_BKGND_RECT		= 0x0207,		/**< 全程背景窗口位置、尺寸（竖屏） */
    
    /* car position on screen horizontal / vertical */
    G_H_MAP_CAR_POSITION			= 0x0300,	/**< 车标中心位置（横屏） */
    G_H_MAP_CAR_POSITION_ZOOM		= 0x0301,	/**< 车标中心位置（横屏）（放大窗口出现时） */
    G_H_MAP_CAR_POSITION_GUIDEPOST	= 0x0302,	/**< 车标中心位置（横屏）（高速路牌出现时） */
    G_V_MAP_CAR_POSITION			= 0x0303,	/**< 车标中心位置（竖屏） */
    G_V_MAP_CAR_POSITION_ZOOM		= 0x0304,	/**< 车标中心位置（竖屏）（放大窗口出现时） */
    G_V_MAP_CAR_POSITION_GUIDEPOST	= 0x0305,	/**< 车标中心位置（竖屏）（高速路牌出现时） */
    G_H_MAP_CAR_POSITION_SIGNPOST	= 0x0306,	/**< 车标中心位置（横屏）（蓝色看板出现时） */
    G_V_MAP_CAR_POSITION_SIGNPOST	= 0x0307,	/**< 车标中心位置（竖屏）（蓝色看板出现时） */
    
    /* map display */
    G_MAP_VIEW_MODE				= 0x0400,		/**< 地图视图模式：正北、车手、3D */
    G_MAP_ANGLE					= 0x0401,		/**< 地图相对于正北的旋转角度 */
    G_MAP_ELEVATION				= 0x0402,		/**< 地图相对于地平线的仰角 */
    G_MAP_SCALE_LEVEL_2D		= 0x0403,		/**< 地图比例级别2D */
    G_MAP_SCALE_LEVEL_3D		= 0x0404,		/**< 地图比例级别3D */
    G_MAP_FONT_SIZE				= 0x0405,		/**< 地图字体大小 */
    G_MAP_POI_DENSITY			= 0x0406,		/**< 地图POI点疏密级别 */
    G_MAP_POI_PRIORITY			= 0x0407,		/**< 地图POI点显示优先级 */
    G_MAP_SHOW_DETOUR			= 0x0408,		/**< 地图显示避让道路开关 */
    G_MAP_CONTENT				= 0x0409,		/**< 地图显示内容 */
    G_MAP_PIP_MODE				= 0x040a,		/**< pip模式 */
    G_MAP_MOVE_MODE				= 0x040b,		/**< 地图移动方式：点击、拖动） */
    G_MAP_SHOW_SIGNPOST			= 0x040c,		/**< 看板显示开关 */
    G_MAP_SHOW_GUIDEPOST		= 0x040d,		/**< 高速路牌显示开关 */
    G_MAP_SHOW_ANIMATED			= 0x040e,		/**< 动画控制开关 */
    G_MAP_ICON_SIZE				= 0x040f,		/**< 图标大小 */
    G_MAP_SHOW_ALL_MULTI_ROUTE	= 0x0410,		/**< 多路线显示控制 */
    G_MAP_SHOW_BUILDING_ROOF_TEX	= 0x0412,	/**< 显示建筑物纹理 */
    G_MAP_SHOW_CURSOR			= 0x0413,		/**< 显示光标 */
    G_MAP_SHOW_ZOOM_VIEW		= 0x0414,		/**< 显示放大路口视图 */
    G_MAP_SHOW_ORIGIN_CAR		= 0x0415,		/**< 原始车位显示开关 */
    G_HILIGHT_CURRENT_ROAD		= 0x0416,		/**< 高亮当前道路显示开关 */
    G_MAP_SHOW_PLAIN_MODE		= 0x0417,		/**< 地图显示简单模式 */
    G_SHOW_MAP_GRAY_BKGND		= 0x0418,		/**< 地图背景灰化 */
    G_ROADNAME_LABEL			= 0x0419,		/**< 地图道路名称标注 */
    G_MAPPOI_LABEL				= 0x0420,		/**< 地图POI标注 */
    G_MAP_FONT_STROKE			= 0x0421,		/**< 文字是否勾边 */
    
    /* palette */
    G_MAP_DAYNIGHT_MODE			= 0x0500,		/**< 地图日夜模式 */
    G_DAY_PALETTE_INDEX			= 0x0501,		/**< 系统当前使用的日色盘 */
    G_NIGHT_PALETTE_INDEX		= 0x0502,		/**< 系统当前使用的夜色盘 */
    G_DAY_TO_NIGHT_TIME			= 0x0503,		/**< 白天到晚上切换时间点 */
    G_NIGHT_TO_DAY_TIME			= 0x0504,		/**< 晚上到白天切换时间点 */
    G_AUTO_MODE_DAYNIGHT		= 0x0505,		/**< 自动模式下色盘状态 */
    
    /* tmc */
    G_MAP_SHOW_TMC				= 0x0600,		/**< 地图TMC显示开关 */
    G_MAP_TMC_SHOW_OPTION		= 0x0601,		/**< 地图TMC显示规则，取值参见GTMCSHOWOPTION */
    G_UPDATE_TMC_INTERVAL		= 0x0602,		/**< 地图TMC更新频率 */
    G_TMC_SID					= 0x0603,		/**< TMC后台登录SID */
    G_TPEG_RINGMODE				= 0x0604,		/**< TPEG内圈、外圈、全城模式 */
    G_TPEG_INNERRING_RADIUS		= 0x0605,		/**< TPEG内圈半径 */
    G_TPEG_OUTERRING_RADIUS		= 0x0606,		/**< TPEG外圈半径 */
    G_TMC_EVENT_HIGHWAYLIMIT	= 0x0607,		/**< TMC事件在引导路径上高速、快速路上的播报距离 */
    G_TMC_EVENT_NORMALWAYLIMIT	= 0x0608,		/**< TMC事件在引导路径上普通路上的播报距离 */
    G_TMC_EVENT_HIGHWAYRADIUS	= 0x0609,		/**< TMC事件在高速、快速路上的播报半径 */
    G_TMC_EVENT_NORMALWAYRADIUS = 0x0610,		/**< TMC事件在普通路上的播报半径 */
    G_TMC_MODE					= 0x0611,		/**< TMC数据来源模式 */
    G_TMC_PROMPTTYPE			= 0x0612,		/**< TMC语音提示设置 */
    G_TMC_ROADWIDTH_LIMIT		= 0x0613,		/**< TMC道路宽度过滤 */
    
    /* speed limit */
    G_HIGHWAY_LIMIT				= 0x0700,		/**< 高速路超速警告阀值 */
    G_NORMALWAY_LIMIT			= 0x0701,		/**< 普通路超速警告阀值 */
    G_OVERSPEED					= 0x0702,		/**< 超速警告开关 */
    
    /* demo */
    G_DEMO_STATUS				= 0x0800,		/**< 模拟导航状态 */
    G_DEMO_SPEED				= 0x0801,		/**< 模拟导航速度 7.0引擎支持40～200(Km/h) 放大路口会强制把速速设置为40km/h 其中速度为3为跳跃模式 */
    G_DEMO_FRAME				= 0x0802,		/**< 模拟导航每秒刷图的帧数 */
    G_DEMO_MODE                 = 0x0803,       /**< 模拟导航模式 分为跳跃模式和连续模式 */
    
    /* track */
    G_MAP_SHOW_TRACK			= 0x0900,		/**< 地图显示轨迹开关 */
    G_TRACK_RECORD				= 0x0901,		/**< 轨迹记录开关 */
    G_TRACK_RECORD_OPTION		= 0x0902,		/**< 轨迹记录规则：稀疏、一般、稠密 */
    G_HISTORY_MAX				= 0x0903,		/**< 历史目的地最大个数 */
    G_FAVORITE_MAX				= 0x0904,		/**< 收藏夹单个类别最大个数 */
    G_FAVORITE_SHOW_OPTION		= 0x0905,		/**< 收藏夹显示类别选项 */
    G_TRACK_DURATION            = 0x0906,       /**< 轨迹回放时间间隔 */
    
    /* guide */
    G_GUIDE_STATUS				= 0x0a00,		/**< 引导状态 */
    G_SHOW_ZOOM_VIEW			= 0x0a01,		/**< 引导显示放大路口开关 */
    G_MAP_SHOW_PASSROUTE		= 0x0a02,		/**< 地图显示已过路径线 */
    G_GUIDEPOST_OPTION			= 0x0a03,		/**< 高速路牌类别 */
    G_PROMPT_OPTION				= 0x0a04,		/**< 语音提示频率规则 */
    G_SPEAK_GUIDANCE			= 0x0a05,		/**< 引导语音开关 */
    G_SPEAK_DEVIATE				= 0x0a06,		/**< 偏航提示开关 */
    G_ZOOM_DIS_HIGHWAY			= 0x0a07,		/**< 放大路口开启距离（高速） */
    G_ZOOM_DIS_FASTWAY			= 0x0a08,		/**< 放大路口开启距离（快速） */
    G_ZOOM_DIS_OTHERWAY			= 0x0a09,		/**< 放大路口开启距离（其他） */
    G_COMBINE_DIS				= 0x0a0a,		/**< 连续语音合并提示距离(单位：米) */
    G_DST_CHECK_DIS				= 0x0a0b,		/**< 目的地到达检测距离(单位：米) */
    G_OVERVIEW_OPTION			= 0x0a0c,		/**< 全程概览视图风格：起点强制在下方或不强制 */
    G_DEVIATE_INTELLIGENT_DETOUR= 0x0a0d,		/**< 偏航智能规避开关 */
    G_ZOOM_VIEW_MODE			= 0x0a0e,		/**< 放大路口模式：0-优先实景图，1-强制矢量图 */
    G_GUIDE_MULTIROUTE_SHINE    = 0x0a0f,       /**< 多路径全程概览路径线闪烁的开关 */
    G_GUIDE_FOOTPOINT_STYLE     = 0x0a10,       /**< 绘制路径线垂线样式 */
    G_VIEWMANEUVERPOINT_FRAME   = 0x0a11,       /**< 路口详情动画效果帧数 */
    G_GUIDE_SHOWLANES           = 0x0a12,       /**< 是否显示车道信息 0-不显示车道 1-显示车道 */
    G_GUIDE_SHOWMAINROADFRAME   = 0x0a13,       /**< 是否显示主要道路名称框 0-不显示 1-显示 该参数默认打开 */
    
    /* route */
    G_DETOUR_TYPE				= 0x0b00,		/**< 绕行道路类型 */
    G_ROUTE_OPTION				= 0x0b01,		/**< 路径规划规则：推荐、高速、经济、最短 */
    G_ROUTE_FLAG				= 0x0b02,		/**< 路径规划标识 */
    G_MULTI_ROUTE_FILTER		= 0x0b03,		/**< 多路线规划过滤 */
    G_ROUTE_TMC_OPTION			= 0x0b04,		/**< 路径规划TMC控制 */
    G_ROUTE_TMC_RECALCULATE     = 0x0b05,       /**< TMC是否参与路径重算 */
    
    /* tts */
    G_SPEAKER_OPTION			= 0x0c00,		/**< TTS播报角色、方言 */
    
    /* welcome */
    G_WARM_PROMPT				= 0x0d00,		/**< 开机敬告 */
    G_SALUTATORY				= 0x0d01,		/**< 欢迎辞 */
    G_WELCOME_IMAGE				= 0x0d02,		/**< 欢迎图片 */
    
    /* volume */
    G_MUTE						= 0x0e00,		/**< 静音 */
    G_VOLUME					= 0x0e01,		/**< 音量 */
    G_CLICK_SOUND				= 0x0e02,		/**< 按钮点击声开关 */
    G_CONTROL_TTS_VOLUME		= 0x0e03,		/**< 音量控制开关 */
    G_SPEAK_ADMIN				= 0x0e04,		/**< 区域提示开关 */
    G_ADMIN_SPEAK_OPTION		= 0x0e05,		/**< 区域播报选项 */
    G_PCD_BROADCAST             = 0x0e06,       /**< PCD播报开关 */
    
    /* safe */
    G_SAFETY_INFORMATION		= 0x0f00,		/**< 设置安全驾驶总开关 */
    G_SAFE_DANGERWARNPART1		= 0x0f01,		/**< 设置母库安全驾驶高危险警示级别类型1：参数默认值可由取值范围内的值进行“或”运算得出 */
    G_SAFE_DANGERWARNPART2		= 0x0f02,		/**< 设置母库安全驾驶高危险警示级别类型2：参数默认值可由取值范围内的值进行“或”运算得出 */
    G_SAFE_SPEEDLIMITSPEAK		= 0x0f03,		/**< 设置限速路牌播报类型（参数值参见：GSAFESPEEDLIMITSPEAK） */
    G_SAFE_CAMERASPEAK			= 0x0f04,		/**< 设置摄像头播报类型（参数值参见：GSAFECAMERASPEAK） */
    G_SAFE_DANGERWARNSPEAK		= 0x0f05,		/**< 设置危险警示播报类型（参数值参见：GSAFEDANGERWARNSPEAK） */
    G_SAFE_SPEAK_DIS_CAMERA		= 0x0f09,		/**< 设置摄像头播报距离 */
    G_SAFE_SPEAK_DIS_LIMIT		= 0x0f0a,		/**< 设置限速播报距离 */
    G_SAFE_SPEAK_DIS_WARN		= 0x0f0b,		/**< 设置危险区域播报距离 */
    G_SPEAK_ACCURACY_SAFETY		= 0x0f0c,		/**< 设置安全驾驶精确播报开关 */
    G_SAFE_HINT_OPTION          = 0x0f0d,       /**< 设置安全驾驶信息提示图标显示选项（参数值参见：GSAFEHINTOPTION） */
    G_SAFE_SPEEDLIMITSPEAK_OPTION = 0x0f0e,     /**< 设置限速路牌播报形式（参数值参见：GSAFESPEEDLIMITSPEAKOPTION） */
    G_SAFE_CAMERASPEAK_OPTION     = 0x0f0f,     /**< 设置摄像头播报形式（参数值参见：GSAFECAMERASPEAKOPTION） */
    G_SAFE_DANGERWARNSPEAK_OPTION = 0x0f10,     /**< 设置危险警示播报形式（参数值参见：GSAFEDANGERWARNSPEAKOPTION） */
    /* vehicle mounted */
    G_VEHICLE_MOUNTED			= 0x1000,		/**< 车载模式开关 */
    
    /* reserved */
    G_LOC_SIGNAL_TYPE			= 0x1100,		/**< 定位信号类型 */
    G_DISABLE_ECOMPASS			= 0x1101,		/**< 禁用电子罗盘 */
    G_DISABLE_GPS				= 0x1102,		/**< 禁用GPS定位 */
    G_RECORD_PGL				= 0x1103,		/**< PGL日志纪录开关 */
    G_AROUND_SEARCH_RADIUS		= 0x1104,		/**< 周边检索半径（单位：公里） */
    G_NAVI_MODE					= 0x1105,		/**< 导航模式 */
    G_GYRO_TYPE					= 0x1106,		/**< 陀螺信号类型 */
    G_CAR_IMAGE_INDEX			= 0x1107,		/**< 车标资源 */
    G_APP_WINDOW_MODE			= 0x1108,		/**< 窗口模式 */
    G_GRAPHICS_LIB				= 0x1109,		/**< 图形库 */
    G_LOC_FRAME					= 0x110A,		/**< 定位时的刷图帧数 */
    G_FCD_UPLOAD				= 0x110B,		/**< FCD上传开关 */
    G_FCD_COLLECTLIMIT			= 0x110C,		/**< FCD收集点信息的时间间隔 */
    G_BARLAYOUT_H				= 0x110D,		/**< 放大路口进度条布局(横屏) */
    G_BARLAYOUT_V				= 0x110E,		/**< 放大路口进度条布局(竖屏) */
    G_MAP_ANTIALIAS				= 0x110F,		/**< 地图渲染效果（针对GDI） */
    
    G_SHOW_METRO				= 0x1110,		/**< 控制地图是否显示地铁的开关 */
    G_BUILDING_DEPRESS			= 0x1111,       /**< 3D建筑物压低开关 */
    G_SHOW_ECOMPASS				= 0x1112,       /**< 显示电子罗盘开关 */
    G_SHOW_TMCSTREAMEVENT		= 0x1113,       /**< 显示实时交通流事件 */
    G_SHOW_TMCEVENT				= 0x1114,       /**< 显示实时交通事件 */
    G_RESERVED_26                = 0x1115,       /**< 显示实时交通流事件 */
    G_MAP_ZOOMMODE				= 0x1116,		/**< 地图缩放模式 */
    
    
    G_H_TRAFFICBOARD_VIEW_RECT	= 0x1117,       /**< 自动交通情报板位置、尺寸（横屏） */
    G_V_TRAFFICBOARD_VIEW_RECT	= 0x1118,       /**< 自动交通情报板位置、尺寸（竖屏） */
    G_TFB_PICTURE_DISAPPEARRANGE= 0x1119,       /**< 自动交通情报板消失的参考距离 */
    G_TFB_PICTURE_SHOWTIME      = 0x1120,       /**< 自动交通情报板显示时长 */
    G_TFB_SAMPLINGFREQUENCY		= 0x1121,		/**< GPS采样发送频率 */
    G_H_MAP_CAR_POSITION_TRAFFICBOARD	= 0x1122,/**< 车标中心位置（横屏）（交通情报板出现时） */
    G_V_MAP_CAR_POSITION_TRAFFICBOARD	= 0x1123,/**< 车标中心位置（竖屏）（交通情报板出现时） */
    G_SHOW_TRAFFICBOARD			= 0x1124,		/**< 交通情报板开关 */
    G_ANGLE_VIEW				= 0x1125,		/**< RealCity视角模式 */
    
    /* 功能支持 */
    G_FUNCTION_SUPPORT_PCD				= 0x4000,/**< PCD功能 */
    G_FUNCTION_SUPPORT_BUILDING_MARK	= 0x4001,/**< 楼宇编号功能 */
    G_FUNCTION_SUPPORT_SEARCH_USER_DB	= 0x4002,/**< 用户数据参与POI检索 */
    G_FUNCTION_SUPPORT_UGC				= 0x4003,/**< 用户图层UGC */
    G_FUNCTION_SUPPORT_TFB				= 0x4004,/**< 是否开启交通情报板功能 */
    G_FUNCTION_SUPPORT_NETMAP           = 0x4005,/**< 是否支持网络地图功能 */
    
    /* 是否启动自动缩放功能 */
    G_MAP_AUTOZOOM			= 0x5003,			/**< 自动缩放 */
    G_MAP_NEXTAUTOTIME		= 0x5004,			/**< 自动缩放时间间隔 (单位：毫秒)*/
    G_MAP_AUTOZOOMMODE		= 0x5005,		/**< 自动缩放模式 */
    
    /* POI */
    G_POI_HTMUSED = 0x6001,						/**< 港澳台数据使用标志 */
    
    /* MAP */
    G_MAP_IS2MODE = 0x7001,						/**< 是否只有两种地图模式 */
    G_MAP_CARMODEL = 0x7002,					/**< 是否在不同仰角下都使用车模 */
    G_MAP_SHOWMAPVIEW_ACTIVE = 0x7003,			/**< 是否由外部主动刷图 */
    G_MAP_SHOWTMCONROAD = 0x7004,				/**< 控制tmc流是否显示在道路上 */
    G_MAP_ASHING_MULTIROUTE = 0x7005,			/**< 多路径时是否灰化未选中 */
    G_MAP_25DMARK_SIZE	= 0x7006,				/**< 25d图标大小 */
} GPARAM;

/* model demo */
/**
 * 演示模型基本信息结构体类型
 *
 */
typedef struct tagGDEMOMODELINFO {
    Gchar		szModelName[GMAX_MDL_NAME_LEN+1];	/**< 模型名称 */
    Gchar		szSPCode[16];		/**< 模型坐标编码 */
    Gint32		nScaleLevel;		/**< 模型视图比例长度 */
    Gint32		nElevation;			/**< 模型仰角 */
    Gint32		nRadius;			/**< 模型半径 */
} GDEMOMODELINFO;

/**
 * 演示模型列表结构体类型
 *
 */
typedef struct tagGDEMOMODELLIST {
    Gchar		szAdminName[GMAX_ADAREA_NAME_LEN+1];	/**< 行政区域名称 */
    Guint32		nNumberOfDemoModel; /**< 演示模型个数 */
    GDEMOMODELINFO	*pDemoModel; 	/**< 演示模型信息 */
} GDEMOMODELLIST;

/* journey demo */
/**
 * 演示路线基本信息结构体类型
 *
 */
typedef struct tagGDEMOJOURNEYINFO {
    Gchar		szJourneyName[GMAX_MDL_NAME_LEN+1];		/**< 路线名称 */
    Guint32		nID;					/**< 路线ID */
    GCOORD		stCoord[GJOURNEY_MAX];  /**< 起点、途经点、目的地的经纬度坐标 */
} GDEMOJOURNEYINFO;

/**
 * 演示路线列表结构体类型
 *
 */
typedef struct tagGDEMOJOURNEYLIST {
    Guint32		nNumberOfDemoJourney; 		/**< 演示路线个数 */
    GDEMOJOURNEYINFO	*pDemoJourney; 		/**< 演示路线信息 */
} GDEMOJOURNEYLIST;

/* 旅游专题结构体定义 */
/**
 * 旅游专题POI类别信息结构体
 * 用于存储旅游专题类别编号、名称及其子类信息
 */
typedef struct tagGTPOICATEGORY {
    Gint32	lCategoryID;				/**< 类别编号，参见POI类别编码表 */
    Gint16	nNumberOfSubCategory;		/**< 子类个数 */
    Gint16	Reserved;					/**< 保留 */
    Gchar	szName[GMAX_TCAT_NAME_LEN+1];	/**< 类别名称 */
    struct tagGTPOICATEGORY	*pSubCategory;	/**< 子类别 */
}GTPOICATEGORY;

/**
 * POI类别列表结构体
 * 用于存储POI类别信息
 */
typedef struct tagGTPOICATEGORYLIST {
    Gint32         lNumberOfCategory;	/**< 类别个数 */
    GTPOICATEGORY   *pCategory;			/**< 类别信息 */
}GTPOICATEGORYLIST;

/**
 * 旅游专题POI信息结构体
 * 用于存储旅游专题POI信息
 */
typedef struct tagGTPOI {
    Guint32	nID;				/**< ID */
    Guint16	nCategoryID;		/**< 旅游专题类别编码，参见旅游专题类别编码表 */
    Guint8	nSubLevel;			/**< 等级（景点、酒店） */
    Guint8	Reserved;			/**< 预留 */
    Guint32	nAdminCode;			/**< 行政编码，参见行政区域编码表 */
    GCOORD	Coord;				/**< 经纬度坐标 */
    Gint32	lNaviLon;			/**< 导航经度坐标*/
    Gint32	lNaviLat;			/**< 导航纬度坐标*/
    Gchar	szName[GMAX_TPOI_NAME_LEN+1];		/**< 名称 */
    Guint32	nDistance;			/**< 距参考点的距离 */
} GTPOI;

/**
 * 旅游专题POI信息类别结构体
 * 用于存储旅游专题POI信息列表
 */
typedef struct tagGTPOILIST {
    Guint32  nNumberOfTPOI;		/**< TPOI个数 */
    GTPOI   *pTPOI;				/**< TPOI信息 */
} GTPOILIST;

/**
 * 旅游路线结构体
 * 用于存储旅游路线
 */
typedef struct tagGTROUTE {
    Guint32	nID;				/**< ID */
    Guint32	nAdminCode;			/**< 行政编码，参见行政区域编码表 */
    Gchar	szName[GMAX_TPOI_NAME_LEN+1];		/**< 路线名称 */
    Guint32	nNumberOfTPOI;		/**< 路线景点个数 */
    GTPOI	*pTPOI;				/**< 路线景点 */
} GTROUTE;

/**
 * 旅游路线信息列表结构体
 * 用于存储旅游路线信息列表
 */
typedef struct tagGTROUTELIST {
    Guint32  nNumberOfTRoute;	/**< 旅游路线条数 */
    GTROUTE  *pTRoute;			/**< 旅游路线 */
} GTROUTELIST;

/**
 * 旅游专题检索条件结构体
 * 用于存储旅游专题检索条件
 */
typedef struct tagGTSEARCHCONDITION {
    Gint16		CategoryID[20];			/**< 旅游专题类别编码集合，参见旅游专题类别编码表 */
    Gint8		SubLevel[20];			/**< 等级编码集合 */
    Guint32		nAdminCode;				/**< 行政编码，参见行政区域编码表 */
    Guint32		nAroundRange;			/**< 周边检索半径，单位：米 */
    GCOORD		Coord;					/**< 经纬度坐标 */
    Gchar     	szKeyword[GMAX_KEYWORD_LEN+1];		/**< 关键字 */
}GTSEARCHCONDITION;

/**
 * 旅游简介类型枚举
 *
 */
typedef enum tagGTINTRODUCTIONTYPE {
    GT_INTRODUCTION_TYPE_ADAREA 		= 0,	/**< 行政区域 */
    GT_INTRODUCTION_TYPE_ATTRACTIONS,			/**< 旅游景点 */
    GT_INTRODUCTION_TYPE_ROUTES,				/**< 旅游路线 */
} GTINTRODUCTIONTYPE;

/**
 * 旅游简介输入结构体
 *
 */
typedef struct tagGTINTRODUCTIONINPUT {
    GTINTRODUCTIONTYPE	eType;			/**< 介绍类别 */
    Guint32 		nAdmincode;		/**< 行政区域 */
    Guint32 		nID;			/**< ID */
} GTINTRODUCTIONINPUT;

/**
 * 旅游简介结构体
 * 用于存储旅游简介，不同类别的简介有效字段不一样，参加各接口说明。
 */
typedef struct tagGTINTRODUCTION {
    Gchar		*szIntroduction;	/**< 简介 */
    Gchar		*szWebSite;			/**< 网址 */
    Gchar		*szFood;			/**< 美食 */
    Gchar		*szClimate;			/**< 气候 */
    Gchar		*szBestTravelTime;	/**< 最佳旅游时间 */
    Gchar     	*szTel;				/**< 电话 */
    Gchar     	*szAddress;			/**< 地址 */
    Gchar     	*szPrice;			/**< 价格 */
    Gchar     	*szOpenTime;		/**< 开放时间 */
    Gchar     	*szTrafficInfo;		/**< 交通信息 */
} GTINTRODUCTION;

/**
 * 旅游专题图片资源类型枚举值
 *
 */
typedef enum tagGTRES {
    GTRES_196180 = 0,		/**< 图片分辨率196×180 */
    GTRES_400400 = 1,		/**< 图片分辨率400×400 */
    GTRES_800480 = 2,		/**< 图片分辨率800×480 */
} GTRES;

/* 公交 */
/**
 * 公交站点类型
 *
 */
typedef enum tagGBUSSTATIONTYPE
{
    GBUSSTATION_TYPE_START = 0,	/**< 起点站 */
    GBUSSTATION_TYPE_END,		/**< 终点站 */
    GBUSSTATION_TYPE_VIA,		/**< 途经站 */
    GBUSSTATION_TYPE_TRANSFER,	/**< 换乘站 */
}GBUSSTATIONTYPE;

/**
 * 公交站点信息
 *
 */
typedef struct tagGBUSSTATION
{
    GBUSSTATIONTYPE eType;								/**< 站点类型 */
    GCOORD			Coord;								/**< 站点坐标 */
    Gchar			szName[GMAX_BUS_NAME_LEN+1];			/**< 站点名称	 */
}GBUSSTATION;

/**
 * 公交路线信息
 *
 */
typedef struct tagGBYBUSLINE
{
    Guint32 nID;										/**< ID */
    Guint32 nNumberOfStations;							/**< 途经站数 */
    Guint32	nLength;									/**< 线路总长度（米） */
    Gchar	szLineName[GMAX_BUS_NAME_LEN+1];			/**< 线路名称:718路空调 */
    Gchar	szFrontName[GMAX_BUS_NAME_LEN+1];			/**< 起点站 */
    Gchar	szTerminalName[GMAX_BUS_NAME_LEN+1];		/**< 终点站 */
    GBUSSTATION *pGBusStation;							/**< 站点信息 */
}GBYBUSLINE;

/**
 * 公交换乘查询条件信息结构体
 * 用于存储公交换乘查询条件
 */
typedef enum tagGBYBUSRULE {
    GBYBUS_RULE_FAST		 	= 0,	/**< 快速，尽可能乘坐轨道交通和快速公交线路 */
    GBYBUS_RULE_ECONOMIC 		= 1,	/**< 经济，尽可能乘坐月票车路线 */
    GBYBUS_RULE_MIN_TRANSFER	= 2, 	/**< 换乘次数最少，换乘次数最少 */
    GBYBUS_RULE_WALK_SHORTEST 	= 3, 	/**< 步行距离最短，步行距离最短 */
    GBYBUS_RULE_COMFORTABLE		= 4 	/**< 舒适，尽可能乘坐有空调车线路 */
}GBYBUSRULE;

/**
 * 公交换乘查询条件信息结构体
 * 用于存储公交换乘查询条件
 */
typedef struct tagGBYBUSCONDITION {
    GCOORD		coordStart;		/**< 起点坐标 */
    GCOORD		coordEnd;		/**< 终点坐标 */
    GBYBUSRULE	eRule;			/**< 乘车规则 */
}GBYBUSCONDITION;

/**
 * 公交换乘方案信息结构体
 * 用于存储公交换乘方案信息
 */
typedef struct tagGBYBUSSCHEME {
    Guint32		nID;				/**< ID */
    Guint32		nStartFootLen;		/**< 起点步行至起点站距离 */
    Guint32		nEndFootLen;		/**< 终点站步行至终点距离 */
    Guint32		nDriveLen;			/**< 车行驶距离 */
    Guint32		nFee;				/**< 所需总费用 */
    Guint32		nNumberOfStations;	/**< 所经站点总数 */
    Guint32     nNumberOfLines;		/**< 线路条数 */
    GBYBUSLINE  *pBusLine;			/**< 路线信息 */
    Gchar	 	*pszDescription;	/**< 乘车方案文字描述 */
}GBYBUSSCHEME;

/* 用户电子眼 */
/**
 * 电子眼类型枚举定义
 * 用于表示电子眼类型
 */
typedef enum tagGSAFECATEGORY {
    GSAFE_CATEGORY_SPEEDLIMIT          = 1,			/**< 最大限速标志 */
    GSAFE_CATEGORY_RESTRICTION_CAMERA  = 4,			/**< 测速摄像头、测速雷达 */
    GSAFE_CATEGORY_ILLEGAL_CAMERA      = 5,			/**< 违章摄像头 */
    GSAFE_CATEGORY_SURVEILLANCE_CAMERA = 28,		/**< 监控摄像头 */
    GSAFE_CATEGORY_LANE_CAMERA         = 29,		/**< 专用道摄像头 */
    GSAFE_CATEGORY_ALL                 = 256		/**< 所有类别 */
}GSAFECATEGORY;

/**
 * 电子眼播报类型选项
 * 用于表示当前电子眼类型有效选项，相应位置1开启，否则关闭，可以组合
 */
typedef enum tagGSAFETYOPTION {
    G_SAFETY_OPTION_SPEEDLIMIT          = 1,		/**< 最大限速标志1、2、3 */
    G_SAFETY_OPTION_RESTRICTION_CAMERA  = 2,		/**< 测速摄像头、测速雷达4 */
    G_SAFETY_OPTION_ILLEGAL_CAMERA      = 4,		/**< 违章摄像头5 */
    G_SAFETY_OPTION_SURVEILLANCE_CAMERA = 8,		/**< 监控摄像头28 */
    G_SAFETY_OPTION_LANE_CAMERA         = 16,		/**< 专用道摄像头29 */
    G_SAFETY_OPTION_OTHERS              = 32,		/**< 其他类别 */
    G_SAFETY_OPTION_ALL                 = 255		/**< 默认 */
} GSAFETYOPTION;

/**
 * 用户自定义电子眼信息结构体
 * 用于存储用户自定义电子眼信息
 */
typedef struct tagGUSERSAFEINFO {
    Gint32			nIndex;		/**< 索引 */
    Gint32          nId;        /**< 用户电子眼ID */
    Gint32			lAdminCode;	/**< 行政区域编码，参见行政区域编码表 */
    GSAFECATEGORY	eCategory;	/**< 安全信息类别 */
    GCOORD			coord;		/**< 经纬度坐标 */
    Gint16			nSpeed; 	/**< 限速值 */
    Gint16			nAngle; 	/**< 电子眼角度（东0，逆向） */
    Gchar			szName[GMAX_USAFE_NAME_LEN+1];	/**< 电子眼名称 */
    GDATE			Date;		/**< 添加的日期 */
    GTIME			Time;		/**< 添加的时间 */
} GUSERSAFEINFO;

/**
 * 用户自定义电子眼信息列表结构体类型
 *
 */
typedef struct tagGUSERSAFEINFOLIST {
    Gint32			nNumberOfItem;		/**< 用户自定义电子眼个数 */
    GUSERSAFEINFO	*pSafeInfo; 		/**< 用户自定义电子眼 */
} GUSERSAFEINFOLIST;

/* 优先显示 */
/**
 * 优先显示POI类别信息结构体
 * 用于存储优先显示POI类别编号、名称
 */
typedef struct tagGPRIORITYCATEGORY {
    Gint32	nIndex;						/**< 索引 */
    Gint32	lCategoryID;				/**< 类别编号，与POI类别编码表不一致 */
    Gbool	bShow;						/**< 是否优先显示 */
    Gchar	szName[GMAX_CAT_NAME_LEN+1];	/**< 类别名称 */
} GPRIORITYCATEGORY;

/**
 * 优先显示POI类别信息列表结构体
 * 用于存储优先显示POI类别列表
 */
typedef struct tagGPRIORITYCATEGORYLIST {
    Gint32	nNumberOfItem;						/**< 优先显示POI类别个数 */
    GPRIORITYCATEGORY	*pPriorityCategory;		/**< 优先显示POI类别 */
} GPRIORITYCATEGORYLIST;

/* 用户图层 */
/**
 * 访问权限枚举类型
 *
 */
typedef enum tagGACCESSPERMISSION {
    GACCESS_PERMISSION_PRIVATE = 0,		/**< 私有 */
    GACCESS_PERMISSION_PROTECTED,		/**< 保护 */
    GACCESS_PERMISSION_PUBLIC			/**< 公开 */
} GACCESSPERMISSION;

/**
 * 用户图层点类别枚举类型
 *
 */
typedef enum tagGUPOICATEGORY {
    GUPOI_CATEGORY_CATE				= 0x0001,	/**< 美食 */
    GUPOI_CATEGORY_ENTERTAINMENT	= 0x0002,	/**< 娱乐 */
    GUPOI_CATEGORY_SHOPPING			= 0x0004,	/**< 购物 */
    GUPOI_CATEGORY_BUSINESS			= 0x0008,	/**< 商务 */
    GUPOI_CATEGORY_TRAVEL			= 0x0010,	/**< 旅游 */
    GUPOI_CATEGORY_OTHER			= 0x8000,	/**< 其他 */
    GUPOI_CATEGORY_ALL				= 0xffff	/**< 所有 */
} GUPOICATEGORY;

/**
 * 用户图层信息结构体
 * 用于存储用户图层点的名称、地址、电话等
 */
typedef struct tagGUPOI {
    Gint32	nIndex;							/**< 索引 */
    GDATETIME dtLastUpdateTime;				/**< 最近更新时间				 */
    Gint32	nAdminCode;						/**< 行政编码，参见行政编码表 */
    GCOORD	coord;							/**< 坐标 */
    GUPOICATEGORY	eCategory;				/**< 类别 */
    GACCESSPERMISSION eAccessPermission;	/**< 其他用户访问权限 */
    Gchar	szName[GMAX_UPOI_NAME_LEN+1];	/**< 名称 */
    Gchar	szAddr[GMAX_UPOI_ADDR_LEN+1];	/**< 地址 */
    Gchar	szTel[GMAX_UPOI_TEL_LEN+1];		/**< 电话 */
    Gchar	szImageURL[GMAX_UPOI_IMAGE_URL_LEN+1];	/**< 图片 */
    Gchar	szComment[GMAX_UPOI_COMMENT_LEN+1];	/**< 评论 */
} GUPOI;

/**
 * 交通事件信息结构体
 * 用于存储交通事件类型、位置、描述等
 */
typedef struct tagGUPOILIST {
    Gint32	nNumberOfItem;		/**< 用户图层点个数 */
    GUPOI	*pUPOI;				/**< 用户图层点 */
} GUPOILIST;

/**
 * 用户图层检索条件信息结构体
 * 用于存储用户图层检索条件
 */
typedef struct tagGUSEARCHCONDITION {
    GSEARCHTYPE	eSearchType;			/**< 检索类型 */
    Guint32		nAdminCode;				/**< 行政编码，参见行政区域编码表 */
    Guint32		nAroundRange;			/**< 周边检索半径，单位：米 */
    GCOORD		Coord;					/**< 经纬度坐标 */
    GUPOICATEGORY eCategory;			/**< 类别 */
    Gchar     	szKeyword[GMAX_KEYWORD_LEN+1];		/**< 关键字 */
} GUSEARCHCONDITION;

/**
 * 语音文本信息类型
 * 用于区别不同的语音文本信息
 */
typedef enum tagGSPEACHTEXT {
    GSPEACH_TEXT_GUIDE						= 0,	/**< 导航引导语音 */
    GSPEACH_TEXT_GUIDE_INITIATIVE			= 1,	/**< 主动播报引导语音 */
    GSPEACH_TEXT_GUIDE_REPEAT				= 2,	/**< 重复最近一次引导语音 */
    GSPEACH_TEXT_AREA					    = 3,	/**< 区域语音 */
    GSPEACH_TEXT_SAFE						= 4,	/**< 本地安全驾驶语音 */
    GSPEACH_TEXT_USERSAFE					= 5,    /**< 用户安全驾驶语音 */
    GSPEACH_TEXT_TMCEVENT					= 6,     /**< TMC事件语音 */
    GSPEACH_TEXT_GUIDE_END					= 7    /**< 导航结束语音 */
} GSPEACHTEXT;

/**
 * TBT导航信息点
 *
 */
typedef struct tagGTBTNAVIINTEM {
    GCOORD	Coord;						/**< TBT导航信息 */
} GTBTNAVIINTEM;

/**
 * 屏幕范围与经纬度范围之比
 *
 */
typedef enum tagGSCALERATE {
    GSCALERATE_PPI_DPI				= 0,	/**< 根据屏幕分辨率，及像素密度得到比例尺与标准比例尺的比值 */
    GSCALERATE_SIZE_DPI				= 1,	/**< 根据屏幕尺寸，及像素密度得到比例尺与标准比例尺的比值 */
    GSCALERATE_PPI_SIZE				= 2,	/**< 根据屏幕分辨率，及尺寸得到比例尺与标准比例尺的比值 */
} GSCALERATE;

/**
 * 点对象
 *
 */
typedef struct tagGPOINTOBJECT
{
    Gint32		nType;				/**< 点类型 */
    Guint8		u8LargeType;		/**< 大类 */
    Guint8		u8Flag;				/**< 标志位 */
    GOBJECTID  stImageID;           /* 图标ID */
    Guint16		u16Angle;			/**< 字体角度(逆时针0 ~ 360) */
    Guint16		u16Sign;			/**< 15w~14w:文字与图标的关系，0下1上2右3左;	13w~7w、6w~0w:名称分行标示 */
    GFPOINT		stPnt;				/**< 点坐标 */
    Gchar		czName[GMAX_ROAD_NAME_LEN+1];		/**< 点文本名称 */
}  GPOINTOBJECT ,*PGPOINTOBJECT;	/**< 点对象 */

/**
 * 线对象
 *
 */
typedef struct tagGLINEOBJECT {
    Gint8		cType;		/**< 类型 */
    Gint8		cTypeDt;	/**< 详细类型 */
    /* 显示道路:0-无、1-隧道、2-当前地图中心所在的道路  */
    /* 路径线:0-已行驶，1-未行驶。 */
    Gint8		cZLevel;	/**< 层级 */
    Gint32		nCount;		/**< 点个数 */
    GFPOINT		*pPntArray;	/**< 点坐标 */
} GLINEOBJECT, *PGLINEOBJECT;/**< 线对象 */

/**
 * 图块线对象
 *
 */
typedef struct tagGGLINETILE {
    Gint32			nLineNum;	/**< 线条数 */
    PGLINEOBJECT	pstLine;	/**< 线对象 */
} GLINETILE, *PGLINETILE;/**< 线对象 */

/**
 * 路径对象
 *
 */
typedef struct tagGPATHOBJECT {
    Gint32			nPointNum;		/**< 点个数 */
    PGPOINTOBJECT	pstPoint;			/**< 点对象（起点、语音点、中途点、终点） */
    
    Gint32			nLineNum;		/**< 线条数 */
    PGLINEOBJECT	pstLine;			/**< 线对象 */
    
    GFCOORD			stArrow;	/**< 箭头坐标 */
    Gint32			nAngle;		/**< 角度 */
    Gint32			nTailNum;	/**< 尾巴条数 */
    GLINEOBJECT		*pstArrowTail;/**< 路口箭头尾巴 */
} GPATHOBJECT, *PGPATHOBJECT;		/**< 路径对象 */

/**
 * 放大路口对象
 *
 */
typedef struct tagGZOOMOBJECT {
    Gint32			nRemainDis;	/**< 到该放大路口的剩余距离（单位：米） */
    
    /* 矢量图 */
    Gint32			nPointNum;	/**< 点个数 */
    PGPOINTOBJECT	pstPoint;		/**< 点对象 */
    
    Gint32			nLineTileNum;/**< 线图块个数 */
    PGLINETILE		pstLineTile;/**< 线图块对象 */
    
    GPATHOBJECT		stPath;		/**< 路径 */
    
    Gint32			nRoundPointNum;/**< 环岛点个数 */
    PGPOINTOBJECT	pstRoundPoint;/**< 环岛点对象 */
    
    GFCOORD		stCarPos;		/**< 车辆 */
    Gint32		nCarAngle;		/**< 车标角度 */
    Gint32 nFlag;               /* 标志位：0矢量图，1实景图，2位图，
                                 3 环岛路段(逆时针)，4环岛路段(顺时针)*/
    Gint8		*pstPicData;	/* 实景图数据 */
    Gint32		nPicSize;		/* 实景图数据大小 */
    Gint8       *pstETCArrData; /* 收费口ETC通道数据 */
    Gint32		nETCArrSize;	/* 收费口ETC通道数据大小 */
    Gint8       *pstArrData;	/* 实景图箭头数据 */
    Gint32		nArrSize;		/* 实景图箭头数据大小 */
} GZOOMOBJECT, *PGZOOMOBJECT;	/**< 放大路口对象 */


/**
 * FCD信息
 *
 */
typedef struct tagGFCDINFO{
    Gchar 	timestamp[15];		/**< 日期和时间文本 */
    Gfloat32 fLon;				/**< 坐标 */
    Gfloat32 fLat;				/**< 坐标 */
    Gint32	nAngle;				/**< 角度 */
    Gint32	nSpeed;				/**< 速度 */
    Gint32	nFRC;				/**< 功能道路类 */
    Gint32	nFOW;				/**< 方式格式 */
    Gint32	nTemperature;		/**< 温度 */
    Gbool	bGPSUsable;			/**< GPS是否可用 */
    Gint32	nVvelocity;			/**< 快速拨号时的车速*/
    Gint32	nAltitude;			/**< 车位的海拔高度 */
    Gint32	nDirection;			/**< 行驶方向-- DRIVINGDIR*/
    Gint32	nGradient;			/**< 车当前的道路的坡度--ROADGRADIENT */
    Gint32	nLane;				/**< 车所在的车道 */
    Gint32	nLinkID;			/**< 车所在的LinkID */
} GFCDINFO,*PGFCDINFO;			/**< FCD信息 */


typedef struct _GCUSTOMELEMENT {
    GBITMAP *pImage;	/* 图片数据 */
    Gint32 x, y;		/* 贴图位置 */
}GCUSTOMELEMENT, *PGCUSTOMELEMENT;/* 自定义元素 */

/**
 * 建筑物高度信息
 *
 */
typedef struct tagGBUILDRAISEINFO {
    Gint32 nIndex;					/**< 第几帧索引 */
    Gfloat32 fCurRaise;				/**< 设置的当前高度值 */
    Gfloat32 fDstRaise;				/**< 目的高度值 */
}GBUILDRAISEINFO, *PGBUILDRAISEINFO;/* 建筑物高度信息 */

/**
 **********************************************************************
 \brief 获取用户信息
 \details 该函数用于获取用户信息
 \param[in]	ppElements 用户元素
 \param[in]	pNumberOfElement 元素个数
 \remarks
 \since 7.0
 \see
 **********************************************************************/
typedef void (*GETELEMENT)(GCUSTOMELEMENT **ppElements, Gint32 *pNumberOfElement);


/* PCD 用户位置回传 - S */

/**
 * 需要回传PCD的服务
 */
typedef enum tagGPCDSERVICE
{
    GPCD_SERVICE_TMC         = 0x00000001, /* TMC */
    GPCD_SERVICE_BROADCAST   = 0x00000002, /* PCD播报 */
    GPCD_SERVICE_TFB_DYNAMIC = 0x00000004  /* 动态交通情报板 */
}GPCDSERVICE;
/* PCD 用户位置回传 - E */


/* TFB 交通情报板 - S */

/**
 * 交通情报板类型
 *
 */
typedef enum tagGTRAFFICBOARDTYPE
{
    GTRAFFIC_BOARD_TYPE_UNIDIRECTION	= 0, /**< 单向类型 */
    GTRAFFIC_BOARD_TYPE_BIDIRECTION		= 1, /**< 双向类型 */
    GTRAFFIC_BOARD_TYPE_CITY			= 2  /**< 全城类型 */
}GTRAFFICBOARDTYPE;

/**
 * 交通情报板信息
 *
 */
typedef struct tagGTRAFFICBOARD
{
    Gint32 nTrafficBoardID;						/**< 情报板ID */
    GCOORD stPos;								/**< 情报板经纬度 */
    Gint32 nDistance;                           /**< 与当前车位的距离 */
    Gchar szDirDescription[GMAX_TRAFFICBOARD_DESCRIPTION_LEN+1];	/**< 情报板描述信息 */
    GTRAFFICBOARDTYPE euBoardType;				/**< 类型 */
}GTRAFFICBOARD;

/**
 * 交通情报板列表信息
 *
 */
typedef struct tagGTRAFFICBOARDLIST
{
    Gint32 nNumberOfBoard;			/**< 情报板个数 */
    GTRAFFICBOARD *pstTrafficBoard;	/**< 情报板信息 */
}GTRAFFICBOARDLIST;

/**
 * 交通情报板数据
 *
 */
typedef struct tagGBOARDSTATUSINFO
{
    Gint32		nTrafficBoardID;	/**< 情报板ID */
    GDATETIME	stTimestamp;		/**< 时间戳 */
    Gchar		szDescription[GMAX_TRAFFICBOARD_DESCRIPTION_LEN+1];	/**< 情报板描述信息 */
    GBITMAP		stImage;			/**< 前方情报看板图片数据 */
}GBOARDSTATUSINFO;

/* TFB 交通情报板 - E */



/* Weather 天气预报 - S */

/**
 * 天气概要请求条件
 *
 */
typedef struct tagGWEATHERINFOSUMMARYREQ
{
    Gint32* pnAdcodes;	/* 六位行政区划编号 */
    Gint32	nCityNum;	/* 城市个数 */
}GWEATHERINFOSUMMARYREQ;

/**
 * 天气信息请求条件
 *
 */
typedef struct tagGWEATHERINFOREQ
{
    Gint32	nAdcode;	/* 六位行政区划编号 */
    Gint32	nDayNum;	/* 需要天气信息的天数 */
}GWEATHERINFOREQ;

/**
 * 天气概要内容
 *
 */
typedef struct tagGWEATHERINFOSUMMARY
{
    Gchar	szProvince[GMAX_WTHDSUMMARY_CONTENT_LEN+1];	/* 省名称 */
    Gchar	szCityName[GMAX_WTHDSUMMARY_CONTENT_LEN+1];	/* 城市名称 */
    Gint32	nAdCode;									/* 城市编码 */
    Gint32	nLowTemperature;							/* 低温  温度 单位:摄氏度 */
    Gint32	nHighTemperature;							/* 高温  温度 单位:摄氏度 */
    Gint32	nTemperature;								/* 即时温度 */
    Gint32	nHumidity;									/* unused, */
    Gchar	szDescription[GMAX_WTHDSUMMARY_CONTENT_LEN+1];/* 天气状况（描述） */
    Gchar   szWindDir[GMAX_WTHDSUMMARY_CONTENT_LEN+1];	/* 风向 */
    Gchar	szWindPower[GMAX_WTHDSUMMARY_CONTENT_LEN+1];	/* 风力 */
    Gint32	szWeatherType;								/* unused,天气类型 */
    GDATE   stDate;										/* 预报日期 */
    GDATETIME stLastUpdateTime;							/* 最后更新时间 */
}GWEATHERINFOSUMMARY;

/**
 * 天气概要信息
 *
 */
typedef struct tagGWEATHERINFOSUMMARYRESULT
{
    Gint32				nSummaryNum;				/* 天气概要信息个数 */
    GWEATHERINFOSUMMARY *pstWeatherInfoSummarys;	/* 天气概要信息 */
}GWEATHERINFOSUMMARYRESULT;

/**
 * 天气生活指数信息
 *
 */
typedef struct tagGLIVINGINDEX
{
    Gchar		szName[GMAX_WTHLIVEINDEX_CONTENT_LEN+1];			/* 指数名称 */
    Gchar		szValue[GMAX_WTHLIVEINDEX_CONTENT_LEN+1];			/* 指数内容 */
    Gchar		szDescription[GMAX_WTHLIVEINDEX_DESCRIPTION_LEN+1];/* 指数内容详情 */
}GLIVINGINDEX;

/**
 * 天气详细信息
 *
 */
typedef struct tagGWEATHERINFODETAIL
{
    Gchar		szDayDescription[GMAX_WTHDETAIL_CONTENT_LEN+1];	/* 白天天气状况 */
    Gchar		szDayWindDir[GMAX_WTHDETAIL_CONTENT_LEN+1];		/* 白天风向 */
    Gchar		szDayWindPower[GMAX_WTHDETAIL_CONTENT_LEN+1];		/* 白天风力 */
    Gchar		szNightDescription[GMAX_WTHDETAIL_CONTENT_LEN+1];	/* 夜间天气状况 */
    Gchar		szNightWindDir[GMAX_WTHDETAIL_CONTENT_LEN+1];		/* 夜间风向 */
    Gchar		szNightWindPower[GMAX_WTHDETAIL_CONTENT_LEN+1];	/* 夜间风力 */
    Gint32		nLivingIndexes;									/* 生活指数个数 */
    GLIVINGINDEX stLivingIndexes[GMAX_WTHLIVEINDEX_INFO_NUM];	/* 生活指数 */
}GWEATHERINFODETAIL;

/**
 * 天气概要和详细信息
 *
 */
typedef struct tagGWEATHERINFO
{
    GWEATHERINFOSUMMARY stWeatherInfoSummary;	/* 天气概要信息 */
    GWEATHERINFODETAIL  stWeatherInfoDetail;	/* 天气详细信息 */
}GWEATHERINFO;

/**
 * 天气信息
 *
 */
typedef struct tagGWEATHERINFORESULT
{
    Gint32			nDayNum;							/* 天数 */
    GWEATHERINFO	stWTHDaysInfo[GMAX_WEATHER_INFO_NUM];	/* 天气信息 */
}GWEATHERINFORESULT;

/* Weather 天气预报 - E */


/* SAF，USA 安全驾驶 - S */

/**
 * 安全驾驶信息提示图标显示选项
 * (可对枚举值进行或运算)
 */
typedef enum tagGSAFEHINTOPTION
{
    GSAFE_HINT_NONE           = 0x00000000,	/**< 不显示提示图标 */
    GSAFE_HINT_CAMERA         = 0x00000001,	/**< 仅显示摄像头提示图标 */
    GSAFE_HINT_SPEED_LIMIT    = 0x00000002,	/**< 仅显示最大限速标志提示图标 */
    GSAFE_HINT_NO_SPEED_LIMIT = 0x00000004, /**< 仅显示限速解除标志提示图标 */
    GSAFE_HINT_DANGERWARN     = 0x00000008, /**< 仅显示危险警示标志提示图标 */
    GSAFE_HINT_ALL            = 0x0000000f  /**< 显示所有类型的提示图标 */
}GSAFEHINTOPTION;

/**
 * 限速路牌播报形式
 */
typedef enum tagGSAFESPEEDLIMITSPEAKOPTION
{
    GSAFE_SPEEDLIMITSPEAK_DETAIL = 0, /**< 仅播详细语音 */
    GSAFE_SPEEDLIMITSPEAK_WARN = 1,   /**< 仅播提示音 */
    GSAFE_SPEEDLIMITSPEAK_BOTH = 2    /**< 提示音+详细语音 */
}GSAFESPEEDLIMITSPEAKOPTION;

/**
 * 摄像头播报形式
 */
typedef enum tagGSAFECAMERASPEAKOPTION
{
    GSAFE_CAMERASPEAK_DETAIL = 0, /**< 仅播详细语音 */
    GSAFE_CAMERASPEAK_WARN = 1,   /**< 仅播提示音 */
    GSAFE_CAMERASPEAK_BOTH = 2    /**< 提示音+详细语音 */
}GSAFECAMERASPEAKOPTION;

/**
 * 危险警示播报形式
 */
typedef enum tagGSAFEDANGERWARNSPEAKOPTION
{
    GSAFE_DANGERWARNSPEAK_DETAIL = 0, /**< 仅播详细语音 */
    GSAFE_DANGERWARNSPEAK_WARN = 1,   /**< 仅播提示音 */
    GSAFE_DANGERWARNSPEAK_BOTH = 2    /**< 提示音+详细语音 */
}GSAFEDANGERWARNSPEAKOPTION;

/**
 * 母库安全驾驶高危险警示标示类型
 *
 */
typedef enum tagGSAFEDANGERWARNPART1
{
    GSAF_JDFX	                    = 0x00000001, /**< 车道指示灯 */
    GSAF_WAITLIGHT	                = 0x00000002, /**< 等待信号灯 */
    GSAF_PEDESTRIANLIGHT	        = 0x00000004, /**< 人行横道灯 */
    GSAF_PEDESTRIAN	                = 0x00000008, /**< 人行横道 */
    GSAF_CSLS	                    = 0x00000010, /**< 可变限速 */
    GSAF_CHILDRENSAFE	            = 0x00000020, /**< 注意儿童 */
    GSAF_RAILWAYCROSSING	        = 0x00000040, /**< 铁路道口 */
    GSAF_FALLINGROCK	            = 0x00000080, /**< 注意落石 */
    GSAF_ACCIDENTPRONELOCATIONS	    = 0x00000100, /**< 事故易发地段 */
    GSAF_EASYGLIDE	                = 0x00000200, /**< 易滑 */
    GSAF_VILLAGE	                = 0x00000400, /**< 村庄 */
    GSAF_OVERPASS	                = 0x00000800, /**< 过街天桥 */
    GSAF_SCHOOLZONE	                = 0x00001000, /**< 前方学校 */
    GSAF_PEOPLEWATCHCROSS	        = 0x00002000, /**< 有人看管的铁路道口 */
    GSAF_NOPEOPLEWATCHCROSS	        = 0x00004000, /**< 无人看管的铁路道口 */
    GSAF_NARROWROADAHEAD        	= 0x00008000, /**< 前方道路变窄 */
    GSAF_SHARPLEFTTURN          	= 0x00010000, /**< 向左急弯路 */
    GSAF_SHARPRIGHTTURN	            = 0x00020000, /**< 向右急弯路 */
    GSAF_REVERSETURN            	= 0x00040000, /**< 反向弯路 */
    GSAF_CONTINUOUS             	= 0x00080000, /**< 连续弯路 */
    GSAF_LEFTSIGNBOARD          	= 0x00100000, /**< 左侧合流标识牌 */
    GSAF_RIGHTSIGNBOARD         	= 0x00200000, /**< 右侧合流标识牌 */
    GSAF_SPEEDPLACARD           	= 0x00400000, /**< 测速设施警示牌 */
    GSAF_DONOTPASS              	= 0x00800000, /**< 禁止超车 */
    GSAF_PASSTOLIFT             	= 0x01000000, /**< 禁止超车解除 */
    GSAF_PARKGIVEWAY            	= 0x02000000, /**< 停车让行 */
    GSAF_SLOWDOWNGIVEWAY        	= 0x04000000, /**< 减速让行 */
    GSAF_CARRETURNGIVEWAY       	= 0x08000000, /**< 会车让行 */
    GSAF_RIGHTNARROW            	= 0x10000000, /**< 右侧变窄 */
    GSAF_LEFTNARROW             	= 0x20000000, /**< 左侧变窄 */
    GSAF_NARROWBRIDGE           	= 0x40000000, /**< 窄桥 */
    GSAF_LEFTRIGHTAROUND	        = 0x80000000, /**< 左右绕行 */
}GSAFEDANGERWARNPART1;


/**
 * 母库安全驾驶高危险警示标示类型
 *
 */
typedef enum tagGSAFEDANGERWARNPART2
{
    GSAF_LEFTAROUND	                = 0x00000001, /**< 左侧绕行 */
    GSAF_RIGHTAROUND	            = 0x00000002, /**< 右侧绕行 */
    GSAF_FALLINGROCKRIGHT       	= 0x00000004, /**< 注意落石（右侧） */
    GSAF_BRINKPRECIPICELEFT        	= 0x00000008, /**< 傍山险路（左侧） */
    GSAF_BRINKPRECIPICERIGHT    	= 0x00000010, /**< 傍山险路（右侧） */
    GSAF_DAMROADLEFT	            = 0x00000020, /**< 堤坝路（左侧） */
    GSAF_DAMROADRIGHT	            = 0x00000040, /**< 堤坝路（右侧） */
    GSAF_UPSTEEPHILL	            = 0x00000080, /**< 上陡坡 */
    GSAF_DOWNSTEEPHILL	            = 0x00000100, /**< 下陡坡 */
    GSAF_RINSEROADBED           	= 0x00000200, /**< 过水路面 */
    GSAF_ROADBEDUNEVEN          	= 0x00000400, /**< 路面不平 */
    GSAF_HUMPBRIDGE             	= 0x00000800, /**< 驼峰桥 */
    GSAF_GOSLOW                 	= 0x00001000, /**< 慢行 */
    GSAF_NOTEDANGEROUS	            = 0x00002000, /**< 注意危险 */
    GSAF_DANGERCROSSWIND        	= 0x00004000, /**< 注意横风 */
    GSAF_NOTICELIVESTOCK        	= 0x00008000, /**< 注意牲畜 */
    GSAF_NOTICENONMOTOR         	= 0x00010000, /**< 注意非机动车 */
    GSAF_TWOWAYTRAFFIC          	= 0x00020000, /**< 双向交通 */
    GSAF_TUNNEL                 	= 0x00040000, /**< 隧道 */
    GSAF_FERRY                  	= 0x00080000, /**< 渡口 */
    GSAF_CRISSCROSS             	= 0x00100000, /**< 十字交叉 */
    GSAF_TCROSSLEFT             	= 0x00200000, /**< T形交叉（左侧） */
    GSAF_TCROSSRIGHT            	= 0x00400000, /**< T形交叉（右侧） */
    GSAF_TCROSSLEFTRIGHT        	= 0x00800000, /**< T形交叉（左右侧） */
    GSAF_YCROSS                 	= 0x01000000, /**< Y形交叉 */
    GSAF_RINGCROSS              	= 0x02000000, /**< 环形交叉 */
    GSAF_CONSTRUCTION           	= 0x04000000, /**< 施工 */
}GSAFEDANGERWARNPART2;

/**
 * 限速路牌播报类型
 *
 */
typedef enum tagGSAFESPEEDLIMITSPEAK
{
    GSAFE_SPEEDLIMITSPEAK_ALL = 0,		/**< 全部播报 */
    GSAFE_SPEEDLIMITSPEAK_OVERSPEED = 1,/**< 仅超速播报  */
    GSAFE_SPEEDLIMITSPEAK_CLOSE = 2,	/**< 不播报  */
}GSAFESPEEDLIMITSPEAK;

/**
 * 摄像头播报类型
 * 可对枚举值进行或运算, 其中的0-31位中：
 * 1. 第2位为新版标志位, 应始终置为1, 即设置的值应>=4;
 * 2. 第28-31位分别用于表示四种摄像头是否播报;
 * 3. 其它位(0-1、3-27)应保持为0.
 */
typedef enum tagGSAFECAMERASPEAK
{
    GSAFE_CAMERASPEAK_ALL          = 0xF0000004, /**< 全部播报 */
    GSAFE_CAMERASPEAK_RESTRICTION  = 0x80000004, /**< 仅播报限速摄像头 */
    GSAFE_CAMERASPEAK_ILLEGAL      = 0x40000004, /**< 仅播报违章摄像头 */
    GSAFE_CAMERASPEAK_SURVEILLANCE = 0x20000004, /**< 仅播报监控摄像头 */
    GSAFE_CAMERASPEAK_LANE         = 0x10000004, /**< 仅播报专用道摄像头 */
    GSAFE_CAMERASPEAK_CLOSE        = 0x00000004	 /**< 不播报任何摄像头 */
}GSAFECAMERASPEAK;

/**
 * 危险警示播报类型
 * (低危类型默认不播报)
 */
typedef enum tagGSAFEDANGERWARNSPEAK
{
    GSAFE_DANGERWARNSPEAK_HIGHRISK = 1,	/**< 高危播报  */
    GSAFE_DANGERWARNSPEAK_CLOSE = 2,	/**< 都不播报  */
}GSAFEDANGERWARNSPEAK;

/**
 * 对外提供的安全驾驶信息
 */
typedef struct tagGSAFEDATA
{
    Gint16 n16Kind;    /* 类别 */
    Gint16 n16Speed;    /* 限速 */
    GPOINT stPoint;    /* 经纬度坐标 */
    Gint32 nDistance;    /* 距离 */
}  GSAFEDATA,*PGSAFEDATA;

/**
 * 对外提供的安全驾驶警示信息
 */
typedef struct tagGSAFEALERTINFO
{
    Gint32 nAlertCnt;    /* 播报个数 */
    GSAFEDATA* pstAlertSafety;    /* 播报的安全驾驶信息 */
    Gint32 nDisyplayCnt;    /* 显示个数 */
    GSAFEDATA* pstDisplaySafety;    /* 显示的安全驾驶信息 */
}  GSAFEALERTINFO,*PGSAFEALERTINFO;

/**
 * 对外提供的用户安全驾驶信息头
 */
typedef struct tagGUSERSAFEDATAHEAD
{
    Gint8 n8Length;    /* 名称长度 */
    Gint8 n8ResVed;    /* 保留字段 */
    Gint16 n16Type;    /* 类别 */
    Gint16 n16Angle;    /* 角度 */
    Gint16 n16Speed;    /* 限速 */
    GOBJECTID stRoadId;/* 道路ID */
    GPOINT stPoint;    /* 经纬度坐标 */
}  GUSERSAFEDATAHEAD,*PGUSERSAFEDATAHEAD;

/**
 * 对外提供的用户安全驾驶信息
 */
typedef struct tagGUSERSAFEDATA
{
    Gint32 nId;
    GUSERSAFEDATAHEAD stDataHead;    /* 信息头 */
    Gint32 nAdaCode;    /* 行政区域编码 */
    GDATETIME stDateTime;    /* 创建/保存时间 */
    Gchar czName[GMAX_USAFE_NAME_LEN+1];    /* 名称 */
}  GUSERSAFEDATA,*PGUSERSAFEDATA;

/**
 * 对外提供的用户安全驾驶警示信息
 */
typedef struct tagGUSERSAFEALERTINFO
{
    Gint32 nAlertCnt;    /* 播报个数 */
    GUSERSAFEDATA* pstAlertSafety;    /* 播报的安全驾驶信息 */
    Gint32 *pnDisAlert; /* 播报信息与当前点的距离序列 */
    Gint32 nDisyplayCnt;    /* 显示个数 */
    GUSERSAFEDATA* pstDisplaySafety;    /* 显示的安全驾驶信息 */
    Gint32 *pnDisDisplay; /* 显示信息与当前点的距离序列 */
}  GUSERSAFEALERTINFO,*PGUSERSAFEALERTINFO;

/**
 * 图片类型
 */
typedef enum tagGMAPIMAGETYPE
{
    eGIMAGETYPE_3DMASK,		/* 2.5D图标 */
    eGIMAGETYPE_LOGO,		/* 常规POI图标 */
    eGIMAGETYPE_MAX
} enumGMAPIMAGETYPE;

/**
 * 图片的宽高信息
 */
typedef struct tagGIMAGEPIX
{
    Guint16 u16ImageH;    /* 图片的高度 */
    Guint16 u16ImageW;    /* 图片的宽度 */
}  GIMAGEPIX, *PGIMAGEPIX;

/**
 * 视角
 *
 */
typedef enum tagGANGLEVIEW {
    GANGLE_VIEW_ALL = 0,			/**< 非第一人称视角 */
    GANGLE_VIEW_FIRSTPERSON = 1,	/**< 第一人称视角 */
} GANGLEVIEW;

/**
 * 当前视图转换为全程概览视图类型
 * 
 */
typedef enum tagGTRANSFORMTYPE {
    GTRANSFORM_VIEW_ROUTE = 0,		/**< 当前车位到目的地路线 */
    GTRANSFORM_VIEW_TRACK = 1,		/**< 轨迹线 */
} GTRANSFORMTYPE;

/**
 * 当前视图转换为全程概览视图参数信息
 */
typedef struct tagGOVERVIEWPARAMS
{
    GTRANSFORMTYPE euType;			/**< 当前视图转换为全程概览视图类型 */
    GRECT	stFrontRect;			/**< 概览前景矩形框 */
    GRECT	stBackRect;				/**< 概览背景矩形框 */
    Gbool	bWhole;					/**< Gtrue:显示整条路径，Gfalse:显示当前车位到目的地 */
    GMAPVIEWMODE euMode;			/**< 视图模式，只有:GMAPVIEW_MODE_NORTH、GMAPVIEW_MODE_CAR两种模式 */
    GRECT	stPntRect;				/**< 经纬度矩形框, 对于GTRANSFORM_VIEW_TRACK有用 */				
}  GOVERVIEWPARAMS, *PGOVERVIEWPARAMS;

/**
 * 动态转换视图类型
 * 
 */
typedef enum tagGDYNAMICVIEWTYPE {
    GDYNAMIC_VIEW_TRANSFORM = 0,		/**< 转换视图 */
    GDYNAMIC_VIEW_RECOVERY = 1,		    /**< 恢复视图 */
} GDYNAMICVIEWTYPE;

/**
 * 动态转换视图参数信息
 */
typedef struct tagGDYNAMICVIEWPARAMS
{
    GDYNAMICVIEWTYPE euDynamicViewType;	/**< 动态转换视图类型 */
    Gint32 nIndex;						/**< 第几帧 */
    Guint32 uTickCount;					/**< 当前时间 */
}  GDYNAMICVIEWPARAMS, *PGDYNAMICVIEWPARAMS;

/**
 * 用于获取安全驾驶信息的回调函数
 * 
 */
typedef void (*PSAFEINFOCALLBACK)(GSAFEALERTINFO *pstAlertInfo);

/**
 * 用于获取用户自定义安全驾驶信息的回调函数
 * 
 */
typedef void (*PUSERSAFEINFOCALLBACK)(GUSERSAFEALERTINFO *pUserSafeAlertInfo);

/** 
 * 心跳回调函数
 *
 */
typedef void (*THeartbeat)(void);

/* SAF，USA 安全驾驶 - E */

/* TIR:Traffic incident report 交通事件上报 - S */

/**
 * 主图层编号
 * 
 */
typedef enum tgaGTIRTRAFFICTYPE
{
    GTIR_TRAFFIC_ACCIDENT = 1050,		   /**< 事故  */
    GTIR_TRAFFIC_JAMS     = 1055,		   /**< 拥堵  */
    GTIR_TRAFFIC_POLICE   = 1060,		   /**< 警察  */
    
}GTIRTRAFFICTYPE;

/**
 * 子图层编号
 * 
 */
typedef enum tgaGTIRCHILDTRAFFICTYPE      
{
    GTIR_FAULT_CAR        = 11010,		   /**< 故障车辆  */
    GTIR_CAR_ACCIDENT     = 11011,		   /**< 车祸  */
    GTIR_ROADBLOCKS       = 11012,		   /**< 道路障碍  */
    GTIR_SLOW			  = 11020,		   /**< 缓慢  */
    GTIR_JAM			  = 11021,		   /**< 拥堵  */
    GTIR_BLOCK			  = 11022,		   /**< 阻塞  */
    GTIR_CHECK			  = 11030,		   /**< 检查  */
    GTIR_CONTROL		  = 11031,		   /**< 管制  */
    
}GTIRCHILDTRAFFICTYPE;

/**
 * 用户交通事件上报 请求结构体
 *
 */
typedef struct tagGTIRUSERTRAFFICUPLOADREQ {
    Gchar	  szChannel[32];			    /**< 填充字段为"navigation"，渠道标识, 需系统统一分配 navigation */
    Gchar      szAppid[32];			        /**< 填充字段为"navigation"，产品代码(dip) 必填  请求发起方的应用唯一标识, 可严格区分不同应用、不同平台等等 */
    GCOORD	    stPos;						/**< 上报/请求的经纬度 必填 */
    GTIRTRAFFICTYPE	  euTirTrafficType;		/**< 图层编号. 事故 = 1050 拥堵 = 1055 警察 = 1060 必填(默认是1040) */
    GTIRCHILDTRAFFICTYPE  euTirChildTrafficType;    /**< 必填 子图层编号（layerid=1050,该值可为11010 故障车辆，11011 车祸，11012 路面障碍，layerid=1055,该值可为 11020 缓慢11021 拥堵 11022 阻塞， layerid=1060，该值可为11030 检查 11031 管制 ）*/
    /*可选项*/
    Gchar      szAddress[GMAX_TIR_ADDRESS+1];		/**< 地址（最大长度256）*/
    Gchar      szContent[GMAX_TIR_CONTENT];			/**< 发表内容（最大长度256）*/
    Gchar      *pPicBuff;				/**< 图片内存块地址 */
    Gint32     nSize;					/**< 图片大小  图片大小不超过50K */
}GTIRUSERTRAFFICUPLOADREQ;

/**
 * 交通事件下发 请求结构体
 *
 */
typedef struct tagGTIRGETTRAFFICEVENTREQ {     
    /*必填*/
    GPOINT  stLeftUpper;				/**< 屏幕左上角经纬度  */
    GPOINT  stRightDown;				/**< 屏幕右下角经纬度  */
    Gint32  nHeight;				    /**< 屏幕分辨率高度  */
    Gint32  nWeighth;					/**< 屏幕分辨率宽度  */
    Gint32  nlevelOfDetail;				/**< 地图放大比例  */
}GTIRGETTRAFFICEVENTREQ;

/* 用户事件信息结构体 */
typedef struct tagGTIRUSEREVENTINFO{    
    Gint32  nID;						/**< 事件ID */
    GCOORD	stPos;						/**< 用户事件的经纬度 */
    Gint32  iUids;                      /**< 交通事件区别高德交通信息与用户交通信息，高德交通信息为105，其余为用户交通信息 */
    GTIRTRAFFICTYPE	  euTirTrafficType;	/**< 图层编号. 事故 = 1050 拥堵 = 1055 警察 = 1060 必填(默认是1040) */
}GTIRUSEREVENTINFO;

/**
 * 交通事件 解析结构体
 *
 */
typedef struct tagGTIRANALYSISTRAFFICEVENT {
    
    Gchar     szUserName[GMAX_TIR_USERNAME+1];			/**< 用户名称 */
    GTIRCHILDTRAFFICTYPE  euTirChildTrafficType;		/**< 必填 子图层编号（layerid=1050,该值可为11010 故障车辆，11011 车祸，11012 路面障碍，layerid=1055,该值可为 11020 缓慢11021 拥堵 11022 阻塞， layerid=1060，该值可为11030 检查 11031 管制 ）*/
    Gchar     szTileid[GMAX_TIR_TITLE+1];				/**< tile id */
    Gchar     szAddress[GMAX_TIR_ADDRESS+1];            /**< 地址（最大长度256）*/
    Gchar     szContent[GMAX_TIR_CONTENT+1];            /**< 发表内容（最大长度256）*/
    Gchar     szPictureUrl[GMAX_TIR_PICTURE+1];			/**<　图片url */
    GDATETIME iTime;						/**< 创建时间 时间戳 例如：370330131*/
    GTIRUSEREVENTINFO stTriUserEventInfo;
}GTIRANALYSISTRAFFICEVENT;

/*交通事件下发 解析结构体*/
typedef struct tagGTIRDOWNGETTRAFFICEVENT {     
    Gint32    nNumber;						/**< 事件个数 */
    Gchar      szAc[16];						/**< 交通类型 */
    GTIRANALYSISTRAFFICEVENT *pTirAnalysisTrafficEvent; /**< 交通事件的解析结构体 */
}GTIRDOWNGETTRAFFICEVENT;
/* TIR 事件上报 - E */

/**
 * 色盘文件版本号与引擎版本对比信息
 * 
 */
typedef enum tagGPALETTEVERSION 
{
    GPALETTE_VERSION_LOW = 0,		/**< 色盘文件版本低于引擎版本 >*/
    GPALETTE_VERSION_EQUAL = 1,	    /**< 色盘文件版本等于引擎版本 >*/
    GPALETTE_VERSION_HIGH = 2,	    /**< 色盘文件版本高于引擎版本 >*/
}GPALETTEVERSION;
/** \} */
#endif /**< __GDBL_TYPEDEF_H__ */

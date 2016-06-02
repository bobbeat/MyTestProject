/********************************************************************
 created:    2011/12/02
 created:    2:12:2011   14:37
 author:        陈其义
 
 purpose:    定义GDBL对外接口
 *********************************************************************/
#ifndef GNAVTYPES_H
#define GNAVTYPES_H

#include "gtypes.h"

/**
 \defgroup data_structures_group Data Structures
 \{
 */

/* 字符串长度定义（单位：字符） */
#define	GMAX_CAT_NAME_LEN		47	/**< 类别名称最大长度 */
#define	GMAX_ADAREA_NAME_LEN	31	/**< 行政区域名称最大长度 */
#define	GMAX_ROAD_NAME_LEN		63	/**< 道路名称最大长度 */
#define	GMAX_POI_NAME_LEN		63	/**< POI名称最大长度 */
#define	GMAX_POI_ADDR_LEN		63	/**< POI地址最大长度 */
#define	GMAX_POI_TEL_LEN		31	/**< POI电话最大长度 */
#define GMAX_JOURNEY_POINT_NUM	7	/**< 最大行程点个数（包括起点） */
#define	GMAX_TPOI_NAME_LEN		63	/**< 旅游路线名称最大长度 */
#define GMAX_USAFE_NAME_LEN		47  /** 用户电子眼名称长度 */
#define GMAX_TCAT_NAME_LEN		63	/** 旅游电子书类别最大长度 */
#define	GMAX_LANE_LEN		    15	/**< 车道最大长度 */

#define GDMID_MAX_POI			200	/**< 搜索到的最大POI个数 */

#define GMAX_VERSION_LEN		31	/**< 版本信息最大长度 */
#define GMAX_POI_CAT_NUM		200 /**< POI检索类别编码组合个数 */
#define	GMAX_CANDIDATE_WORD_LEN	17	/**< POI联想候选词最大长度 */
#define GMAX_LINK_ROAD_NUM		8	/**< 目的地关联道路最大数 */

#define GMAX_UPOI_NAME_LEN		15	/**< UGC名称最大长度 */
#define GMAX_UPOI_ADDR_LEN		39	/**< UGC地址最大长度 */
#define GMAX_UPOI_TEL_LEN		15	/**< UGC电话最大长度 */
#define	GMAX_UPOI_COMMENT_LEN	159	/**< 评论最大长度 */
#define	GMAX_UPOI_IMAGE_URL_LEN	31	/**< 图片路径最大长度 */

#define	GMAX_KEYWORD_LEN		63	/**< 检索关键字最大长度 */
#define	GMAX_CANDIDATE_NUM		512	/**< 最大候选字（词）个数 */

/**
 * 街区数据等级
 *
 */
typedef enum tagGREGBLOCK {
    GREG_BLOCK_S  = 0,
    GREG_BLOCK_M  = 1,
    GREG_BLOCK_H  = 2,
    GREG_BLOCK_M1 = 3,
    GREG_BLOCK_M2 = 4
} GREGBLOCK;

/**
 * 资源数据等级
 *
 */
typedef enum tagGREGRES {
    GREG_RES_C_196180 = 0,
    GREG_RES_C_400400 = 1,
    GREG_RES_C_800480 = 2,
    GREG_RES_S_196180 = 3,
    GREG_RES_S_400400 = 4,
    GREG_RES_S_800480 = 5,
    GREG_RES_H_196180 = 6,
    GREG_RES_H_400400 = 7,
    GREG_RES_H_800480 = 8,
    GREG_RES_M_196180 = 9,
    GREG_RES_M_400400 =10,
    GREG_RES_M_800480 =11
} GREGRES;

/**
 * 注册模式
 *
 */
typedef enum tagGREGMODE {
    GREG_MODE_TOB = 0,
    GREG_MODE_TOC = 1,
    GREG_MODE_TOCAR = 2,
    GREG_MODE_CONTI_DPCA = 3,
    GREG_MODE_CONTI_CAPSA = 4,
    GREG_MODE_HONDA_CRV = 5
} GREGMODE;

#define GREG_CODE_LEN            24
#define GREG_MAX_DEVICEID_LEN    64

/**
 * 收藏兴趣点类别枚举类型
 * 可以组合
 */
typedef enum tagGFAVORITECATEGORY{
    GFAVORITE_CATEGORY_DEFAULT            = 0x00000001,    /**< 默认 */
    GFAVORITE_CATEGORY_HOME                = 0x00000002,     /**< 我家 */
    GFAVORITE_CATEGORY_COMPANY            = 0x00000004,     /**< 公司 */
    GFAVORITE_CATEGORY_SIGHT            = 0x00000008,     /**< 景点 */
    GFAVORITE_CATEGORY_FRIEND            = 0x00000010,     /**< 朋友 */
    GFAVORITE_CATEGORY_CUSTOMER         = 0x00000020,    /**< 客户 */
    GFAVORITE_CATEGORY_ENTERTAINMENT     = 0x00000040,    /**< 娱乐 */
    GFAVORITE_CATEGORY_HISTORY            = 0x00000080,    /**< 历史目的地 */
    GFAVORITE_CATEGORY_ALL                = 0x000000ff,    /**< 所有类别 */
    GFAVORITE_CATEGORY_MAX                = 8
} GFAVORITECATEGORY;

/**
 * 坐标转换标识
 *
 */
typedef enum  tagGCOORDCONVERT {
    GCC_SCR_TO_GEO = 0,        /**< 屏幕坐标转换为经纬度坐标 */
    GCC_GEO_TO_SCR = 1,        /**< 经纬度坐标转换为屏幕坐标 */
    GCC_GEO_TO_World = 2,    /**< 经纬度坐标转换为世界坐标 */
    GCC_SCR_TO_World = 3    /**< 屏幕坐标转换为世界坐标      */
} GCOORDCONVERT;

/**
 * 预定义视图类型
 *
 */
typedef enum tagGMAPVIEWTYPE {
    GMAP_VIEW_TYPE_MAIN = 0,        /**< 主地图单路线  */
    GMAP_VIEW_TYPE_WHOLE,           /**< 单路线全程概览*/
    GMAP_VIEW_TYPE_MULTI,           /**< 主地图多路线  */
    GMAP_VIEW_TYPE_MULTIWHOLE,      /**< 多路线全程概览*/
    GMAP_VIEW_TYPE_POI,             /**< 查看POI        */
    GMAP_VIEW_TYPE_SP,              /**< 查看SP码点    */
    GMAP_VIEW_TYPE_MANEUVER_POINT,  /**< 查看引导机动点 */
    GMAP_VIEW_TYPE_ROUTE_TMC,       /**< 路径TMC概览     */
    GMAP_VIEW_TYPE_MULTI_DIFF,      /**< 多路线不同处概览*/
    GMAP_VIEW_TYPE_JOURNEYPOINTS,   /**< 查看行程点在同一图层*/
    GMAP_VIEW_TYPE_BUS_OVERVIEW,    /**< 公交全程概览*/
    GMAP_VIEW_TYPE_NETROU_OVERVIEW, /**< 网路路径全程概览*/
    GMAP_VIEW_TYPE_CROSSZOOM,       /**< 路口放大图*/
    GMAP_VIEW_TYPE_MODEL_DEMO,      /**< 3D建筑演示 */
    GMAP_VIEW_TYPE_JOURNEY_DEMO,    /**< 3D路线演示 */
    GMAP_VIEW_MAX
} GMAPVIEWTYPE;

/**
 * 相机类型
 *
 */
typedef enum tagGCAMERATYPE {
    GCAMERA_VIEW_NORMAL = 0,       /**< 主地图模式  */
    GCAMERA_VIEW_DRIVER,           /**< 第一人称模式*/
    GCAMERA_VIEW_MAX
} GCAMERATYPE;


/**
 * 地图数据语言
 *
 */
typedef enum tagGLANGUAGE {
    GLANGUAGE_SIMPLE_CHINESE      = 0,	/**< 简体中文 */
    GLANGUAGE_ENGLISH             = 1,	/**< 英文 */
    GLANGUAGE_TRADITIONAL_CHINESE = 2,	/**< 繁体中文 */
    GLANGUAGE_MAX                       /**< 最大语言数 */
} GLANGUAGE;

/**
 * 国家地区代码，参照ISO-3166-1
 * http://en.wikipedia.org/wiki/ISO_3166-1
 */
typedef enum tagREGION_CODE
{
    eREGION_CODE_NULL   = 0       /**< 未定义 */,
    eREGION_CODE_CHN    = 156    /**< 中国大陆 */,
    eREGION_CODE_MAC    = 446    /**< 中国澳门 */,
    eREGION_CODE_HKG    = 344    /**< 中国香港 */,
    eREGION_CODE_TWN    = 158    /**< 中国台湾 */,
    eREGION_CODE_MAX    = 1000   /**< 最大值   */,
} enumREGION_CODE;

/**
 * 行政区域等级枚举
 */
typedef enum tagGADALEVEL
{
    eADALEVEL_COUNTRY = 0x00,	/* 国家 */
    eADALEVEL_PROVICE = 0x01,	/* 省级或直辖市 */
    eADALEVEL_CITY = 0x03,		/* 市级 */
    eADALEVEL_TOWN = 0x04,		/* 区(县)级 */
} GADALEVEL;

/**
 * 版本信息结构体
 * 用于存储引擎或数据等版本信息
 */
typedef struct tagGVERSION {
    Gint32	nData1; 		/**< 主版本 */
    Gint32	nData2; 		/**< 次版本 */
    Gint32	nData3; 		/**< 格式版本 */
    Gint32	nData4; 		/**< Build号 */
    Gchar	szVersion[GMAX_VERSION_LEN+1];	/**< 版本字符串 */
} GVERSION;

/**
 * 版本比较结果枚举值
 * 用于标识2个版本的新旧信息
 */
typedef enum tagGVERCHECKRESULT {
    GVERSION_SAME  = 0,		/**< 版本一致 */
    GVERSION_OLDER = 1,		/**< 版本较旧 */
    GVERSION_NEWER = 2		/**< 版本较新 */
} GVERCHECKRESULT;

/**
 * 行政编码结构
 */
typedef struct tagGADMINCODE
{
    enumREGION_CODE euRegionCode;      /* 国家编码 */
    Gint32          nAdCode;           /* 区域编码 */
} GADMINCODE, *PGADMINCODE;

/**
 * 数据类型枚举值.
 *
 */
typedef enum tagDBTYPE
{
    eDB_TYPE_MAP = 0    /* 图面 */,
    eDB_TYPE_POI		/* POI */,
    eDB_TYPE_USERPOI    /* 用户POI */,
    eDB_TYPE_DIFFPOI    /* 差分POI */,
    eDB_TYPE_ADDRBOOK   /* 常用地址簿 */,
    eDB_TYPE_TRACK      /* 轨迹 */,
    eDB_TYPE_ALL
} enumDBTYPE;

/**
 * 获取引导路径相关信息类型
 *
 */
typedef enum tagGGUIDEROUTETYPE {
    GGUIDEROUTE_TYPE_CARPOS = 0,    /**< 获取路径从车位到目的的信息*/
    GGUIDEROUTE_TYPE_ALL    = 1     /**< 获取整条路径的信息*/
} GGUIDEROUTETYPE;

/**
 * 服务区服务类型
 *
 */
typedef enum tagGSERVICEAREAFLAG {
    GSA_FLAG_AUTOMAT		= 0x80000000,		/**< 自动售货机 */
    GSA_FLAG_BED			= 0x40000000,		/**< 床 */
    GSA_FLAG_COFFEE			= 0x20000000,		/**< 咖啡 */
    GSA_FLAG_DINING			= 0x10000000,		/**< 餐厅 */
    GSA_FLAG_DRUGSTORE		= 0x08000000,		/**< 药店 */
    GSA_FLAG_PARKING		= 0x04000000,		/**< 停车场 */
    GSA_FLAG_NATURALGAS		= 0x02000000,		/**< 天然气 */
    GSA_FLAG_PHONEBOOTH		= 0x01000000,		/**< 公用电话亭 */
    GSA_FLAG_PHYSICAL		= 0x00800000,		/**<  */
    GSA_FLAG_REPAIR			= 0x00400000,		/**< 维修 */
    GSA_FLAG_RESTING		= 0x00200000,		/**< 休息 */
    GSA_FLAG_ATM			= 0x00100000,		/**< 自动取款机 */
    GSA_FLAG_SHOP			= 0x00080000,		/**< 商店 */
    GSA_FLAG_SHOWER			= 0x00040000,		/**< 淋浴 */
    GSA_FLAG_SPECIALITY		= 0x00020000,		/**< 特产 */
    GSA_FLAG_WC				= 0x00010000,		/**< 卫生间 */
    GSA_FLAG_GAS_STATION	= 0x00008000		/**< 加油站 */
} GSERVICEAREAFLAG;

/**
 * 模拟导航模式
 */
typedef enum tagGDEMOMODE
{
    GDEMO_NAVIMODE_NORMAL = 0,        /* 一般连续模拟模式 */
    GDEMO_NAVIMODE_SKIP               /* 跳跃模拟模式 */
} enumGDEMOMODE;

/** \} */
#endif

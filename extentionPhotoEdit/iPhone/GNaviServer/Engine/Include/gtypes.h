/********************************************************************
 created:    2011/12/02
 created:    2:12:2011   14:37
 author:        陈其义
 
 purpose:    定义GDBL对外接口
 *********************************************************************/
#ifndef GTYPES_H__
#define GTYPES_H__

/**
 \defgroup data_structures_group Data Structures
 \{
 */


/* 基本类型定义 */
typedef signed int      Gint32;     /**< -2147483648 ~ 2147483647             */
typedef unsigned int    Guint32;    /**< 0 ~ 4294967295(0xffffffff)           */
typedef signed short    Gint16;     /**< -32768 ~ 32767                       */
typedef unsigned short  Guint16;    /**< 0 ~ 65535(0xffff)                    */
typedef signed char     Gint8;      /**< -128 ~ 127                           */
typedef unsigned char   Guint8;     /**< 0 ~ 255(0xff)                        */
typedef float           Gfloat32;   /**< -3.40E+38 ~ +3.40E+38 精度为6~7位    */
typedef double          Gfloat64;   /**< -1.79E+308 ~ +1.79E+308 精度为15~16位*/

#if defined(PLATFORM_ANDROID) || defined(PLATFORM_MAC) || defined(PLATFORM_TIZEN) || defined(PLATFORM_UBUNTU)
typedef long long            Gint64;     /**< -9223372036854775808i64 ~ 9223372036854775807i64 */
typedef unsigned long long   Guint64;    /**< 0 ~ 18,446,744,073,709,551,615(0xffffffffffffffffui64) */
#else
#ifdef COMPILER_QT
typedef long long            Gint64;     /**< -9223372036854775808i64 ~ 9223372036854775807i64 */
typedef unsigned long long   Guint64;    /**< 0 ~ 18,446,744,073,709,551,615(0xffffffffffffffffui64) */
#else
typedef __int64              Gint64;     /**< -9223372036854775808i64 ~ 9223372036854775807i64 */
typedef unsigned __int64     Guint64;    /**< 0 ~ 18,446,744,073,709,551,615(0xffffffffffffffffui64) */
#endif
#endif

typedef Guint32            Gfile;		/**< 文件指针 */
typedef void*              GHANDLE;

/**
 * 搜索起始点枚举类型
 *
 */
typedef enum {
    GSEEK_BEGIN = 0,	/**< 文件指针指向文件的开始位置 */
    GSEEK_CURRENT,		/**< 文件指针指向当前读写位置 */
    GSEEK_END			/**< 文件指针指向文件的结尾位置 */
}GSEEK;

/**
 * Gtrue/Gfalse枚举类型
 *
 */
typedef enum {
    Gfalse = 0,	/**< 假 */
    Gtrue  = 1	/**< 真 */
} Gbool;

#if (defined PLATFORM_WIN32) || (defined PLATFORM_WINCE)
typedef Guint16        Gchar;	/**< 高德字符类型 */
#elif defined(PLATFORM_UBUNTU)
typedef Guint32        Gchar;	/**< 高德字符类型 */
#else
typedef Guint16        Gchar;	/**< 高德字符类型 */
#endif
#define GT(LS)        ((Gchar*)(L##LS))
#define GTC(LS)        ((L##LS))

/* 宏定义 */
#define GNULL        0
#define GMAX_PATH    260

#define WIDEN(x)        GT(x)
#define __GFILE__        WIDEN(__FILE__)

#define _TOSTRING(x)    #x
#define TOSTRING(x)        _TOSTRING(x)
#define __GLINE__        WIDEN(TOSTRING(__LINE__))

#define GALIGN4(align)    (((align) + 3) & (~3))
#define GNELEM(arr)            (sizeof((arr)) / sizeof((arr)[0]))

/**
 * 坐标结构体
 * 用于存储坐标(经纬度、屏幕坐标)
 */
typedef struct tagGCOORD {
    Gint32        x;    /**< X轴坐标值 */
    Gint32        y;    /**< Y轴坐标值 */
}GCOORD;

/**
 * 坐标结构体
 * 用于存储坐标(经纬度、屏幕坐标)
 */
typedef struct tagFGCOORD {
    Gfloat32        x;    /**< X轴坐标值 */
    Gfloat32        y;    /**< Y轴坐标值 */
}GFCOORD;

/**
 * 坐标结构体
 * 用于存储坐标(经纬度、屏幕坐标)
 */
typedef struct tagGPOINT
{
    Gint32        x;    /**< X轴坐标值 */
    Gint32        y;    /**< Y轴坐标值 */
    Gint32        z;    /**< Z轴坐标值 */
}GPOINT, *PGPOINT;		/**< 整形坐标结构体 */

/**
 * 坐标结构体
 * 用于存储坐标(经纬度、屏幕坐标)
 */
typedef struct tagGFPOINT
{
    Gfloat32    x;    /**< X轴坐标值 */
    Gfloat32    y;    /**< Y轴坐标值 */
    Gfloat32    z;    /**< Z轴坐标值 */
}GFPOINT, *PFGPOINT;	/**< 浮点型坐标结构体 */

/**
 * 坐标结构体
 * 用于存储坐标(经纬度、屏幕坐标)
 */
typedef struct tagGSCOORD {
    Gint16        x;    /**< X轴坐标值 */
    Gint16        y;    /**< Y轴坐标值 */
}GSCOORD;

/**
 * 尺寸结构体
 * 用于存储尺寸
 */
typedef struct tagGSIZE {
    Gint32        cx;    /**< X轴坐标值 */
    Gint32        cy;    /**< Y轴坐标值 */
} GSIZE;

/**
 * 矩形结构体
 * 用于存储矩形
 */
typedef struct tagGRECT {
    Gint32    left;    /**< 最左边坐标值 */
    Gint32    top;    /**< 最顶部坐标值 */
    Gint32    right;    /**< 最右边坐标值 */
    Gint32    bottom;    /**< 最底部坐标值 */
} GRECT;

/**
 * 矩形结构体
 * 用于存储矩形
 */
typedef struct tagFGRECT {
    Gfloat32    left;    /**< 最左边坐标值 */
    Gfloat32    top;    /**< 最顶部坐标值 */
    Gfloat32    right;    /**< 最右边坐标值 */
    Gfloat32    bottom;    /**< 最底部坐标值 */
} GFRECT;

/**
 * 日期信息结构体
 * 用于存储年月日
 */
typedef struct tagGDATE {
    Gint16    year;        /**< 年 */
    Gint8    month;        /**< 月 */
    Gint8    day;        /**< 日 */
} GDATE;

/**
 * 时间信息结构体
 * 用于存储时分秒
 */
typedef struct tagGTIME {
    Gint8    hour;        /**< 时 */
    Gint8    minute;        /**< 分 */
    Gint8    second;        /**< 秒 */
    Gint8    reserved;	/**< 保留 */
} GTIME;

/**
 * 日期时间信息结构体
 * 用于存储年月日时分秒
 */
typedef struct tagGDATETIME {
    GDATE    date;        /**< 日期 */
    GTIME    time;        /**< 时间 */
} GDATETIME;

/**
 * 颜色格式枚举类型
 *
 */
typedef enum GCOLORFORMAT {
    COLOR_FORMAT_RGB565        = 0,
    COLOR_FORMAT_RGBA565    = 1,
    COLOR_FORMAT_RGB555        = 2,
    COLOR_FORMAT_RGBA555    = 3,
    COLOR_FORMAT_RGB888        = 4,
    COLOR_FORMAT_RGBA8888    = 5,
    COLOR_FORMAT_RGBA4444    = 6,
    COLOR_FORMAT_GRAY        = 7,
    COLOR_FORMAT_GRAYALPHA  = 8,
    COLOR_FORMAT_PVR        = 9,
    COLOR_FORMAT_ALPHA		= 10,
    COLOR_FORMAT_MODEL      = 11,
    COLOR_FORMAT_NONE
} GCOLORFORMAT;

/**
 * 纹理坐标
 *
 */
typedef struct tagGTEXCOORD
{
    Gfloat32 du;    /**< 横轴坐标值 */
    Gfloat32 dv;    /**< 纵轴坐标值 */
}GTEXCOORD;

/**
 * 图片格式
 */
typedef enum tagGIMAGEFORMAT
{
    eIMAGE_FORMATE_BMP = 0,    /**< BMP */
    eIMAGE_FORMATE_JPG,        /**< JPG */
    eIMAGE_FORMATE_PNG        /**< PNG */
} enumGIMAGEFORMAT;

/**
 * RGBA结构体类型
 * 颜色分量
 */
typedef struct tagGRGBA {
    Guint8 r;                            /**< 颜色分量RED */
    Guint8 g;                            /**< 颜色分量GREEN */
    Guint8 b;                            /**< 颜色分量BLUE */
    Guint8 a;                            /**< 颜色分量ALPHA */
}GRGBA, *PGRGBA;	/**< RGBA结构体类型 */

/**
 * 图片结构类型
 *
 */
typedef struct tagGBITMAP {
    Gint32            nID;                /**< ID标识 */
    Guint32            nTextureID;            /**< 纹理ID */
    Gint32            nWidth;                /**< 图像宽 */
    Gint32            nHeight;            /**< 图像高 */
    Gint32            cbxPitch;            /**< 距下一个像素字节数 */
    Gint32            cbyPitch;            /**< 距下一行字节数 */
    Gint32            cBPP;                /**< 颜色位深度 */
    GCOLORFORMAT    euFormat;            /**< 颜色格式 */
    GTEXCOORD        texCoord;            /**< 纹理坐标 */
    Guint8*            pData;                /**< 图像数据 */
    Gint32            nPixelSize;            /**< 图像数据大小 */
    Guint8*            pAlpha;                /**< Alpha值 */
    Gint32            nAlphaSize;            /**< 图像Alpha数据大小 */
    GRECT*            pRect;                /**< 区域指针 */
    Gint32            nRectCount;            /**< 区域个数 */
} GBITMAP;

/**
 * 绘制回调函数类型
 *
 */
typedef enum tagGDRAWFUNCTYPE
{
    GDRAWTYPE_LINE = 0,		/**< 绘制线 >*/
    GDRAWTYPE_POLYGONS,     /**< 绘制面 >*/
}GDRAWFUNCTYPE;

/** \} */
#endif

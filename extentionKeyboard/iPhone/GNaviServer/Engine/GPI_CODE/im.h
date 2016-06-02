/* ***************************************************
 * Copyright(c) Xiamen AutoNavi Company. Ltd.
 * All Rights Reserved.
 *
 * File: im.h
 * Purpose:输入法对外接口
 *
 * Author: zhicheng.chen
 *
 *
 * Version: 7.0
 * Date: 12-Jul-2013 18:00:06
 * Update: Create
 *
 *************************************************** */
#ifndef IM_H__
#define IM_H__
#ifdef __cplusplus
extern "C"
{
#endif
#include "gtypes.h"
#include "gpimacro.h"
    
    /**
     \defgroup gpi_data_structures_group GPI Data Structures
     \{
     */
    
    
#define	MAX_CANDIDATE_WORD_LEN	17						/**< POI联想候选词最大长度 */
#define	MAX_CANDIDATE_NUM		512						/**< 最大候选字（词）个数 */
    
    /* 手写 */
    /**
     * 识别参数枚举类型
     *
     */
    typedef enum tagHWFLAG
    {
        eHW_CHARSET_CHINESE		= 0x0001,	/**< 中文字符集 */
        eHW_CHARSET_ENGLISH		= 0x0002,	/**< 英文字符集 */
        eHW_CHARSET_NUMBER		= 0x0004,	/**< 数字字符集 */
        eHW_CHARSET_PUNCTUATION	= 0x0008,	/**< 标点符号字符集 */
        eHW_OUTPUT_DEFAULT		= 0x0010,	/**< 默认输出，即不做任何转换 */
        eHW_OUTPUT_SIMPLE		= 0x0020,	/**< 输出简体中文 */
        eHW_OUTPUT_TRADITIONAL	= 0x0040,	/**< 输出繁体中文 */
        eHW_OUTPUT_LOWERCASE	= 0x0080,	/**< 输出小写字符 */
        eHW_OUTPUT_UPPERCASE	= 0x0100,	/**< 输出大写字符 */
    } enumHWFLAG;							/* 识别参数枚举类型 */
    
    /**
     * 识别手势枚举类型
     *
     */
    typedef enum tagHWGESTURE
    {
        eHW_GESTURE_BACKSPACE	= 0x0008,	/**< 回删 */
        eHW_GESTURE_TAB			= 0x0009,	/**< 制表符 */
        eHW_GESTURE_RETURN		= 0x000D,	/**< 回车 */
        eHW_GESTURE_SPACE		= 0x0020,	/**< 空格 */
    } enumHWGESTURE;						/* 识别手势枚举类型 */
    
    /**
     * 手写识别输入参数结构体类型
     *
     */
    typedef struct tagHWINPUT
    {
        enumHWFLAG	euFlag;					/**< 识别参数 */
        Gint16	nMaxNumberOfCandidate;		/**< 期望的识别候选字个数 */
        Gint16	nNumberOfStrokePoint;		/**< 笔画轨迹点个数 */
        GSCOORD	*pstStokePoint;				/**< 笔画轨迹点坐标（单位：像素） */
    } HWINPUT, *PHWINPUT;					/* 手写识别输入参数结构体类型 */
    
    /**
     * 手写识别输出结构体类型
     *
     */
    typedef struct tagHWCANDIDATE
    {
        Guint16	nNumberOfCandidate;		/**< 候选字个数 */
        Guint16	*pstCandidate;			/**< 候选字 */
    } HWCANDIDATE, *PHWCANDIDATE;		/* 手写识别输出结构体类型 */
    
    /**
     * 输入法枚举类型
     *
     */
    typedef enum tagIMMODE
    {
        eIM_MODE_PY		= 0,		/**< 拼音 */
        eIM_MODE_BH,				/**< 笔画 */
        eIM_MODE_WB,				/**< 五笔 */
        eIM_MODE_EN,				/**< 英文 */
        eIM_MODE_HW,				/**< 手写 */
    } enumIMMODE;					/* 输入法枚举类型 */
    
    /**
     * 输入法语言枚举类型
     *
     */
    typedef enum tagIMLANGUAGE
    {
        eIM_LANG_SIMPLE_CHINESE	  = 0,		/**< 简体中文 */
        eIM_LANG_ENGLISH,					/**< 英文 */
        eIM_LANG_TRADITIONAL_CHINESE,		/**< 繁体中文 */
    } enumIMLANGUAGE;						/* 输入法语言枚举类型 */
    
    
    /**
     * 联想候选字结构体
     * 用于存储联想候选字
     */
    typedef struct tagIMCANDIDATECHAR
    {
        Guint16	u16CharCode;			/**< 候选字编码 */
        Gint16	n16Reserved;			/**< 保留 */
        Gint32	nNumberOfPOI;			/**< 与候选字对应的POI记录条数 */
    }IMCANDIDATECHAR, *IMPCANDIDATECHAR;	/* 联想候选字结构体 */
    
    /**
     * 联想候选词结构体
     * 用于存储联想候选词
     */
    typedef struct tagIMCANDIDATEWORD
    {
        Gint8	n8Length;						/**< 词长度 */
        Gint8	n8Reserved1; 					/**< 保留 */
        Gint16	n16Reserved2; 					/**< 保留 */
        Gchar	czWord[MAX_CANDIDATE_WORD_LEN+1];	/**< 词 */
    }IMCANDIDATEWORD, *PIMCANDIDATEWORD;		/* 联想候选词结构体 */
    
    /**
     * 联想候选字（词）列表结构体
     * 用于存储联想候选字（词）列表
     */
    typedef struct tagIMCANDIDATELIST
    {
        Guint16 u16NumberOfCandidate;				/**< 候选字（词）个数，最多不超过GMAX_CANDIDATE_NUM */
        Guint16	u16NumberOfPOI;						/**< 可能的POI个数 */
        union
        {
            IMCANDIDATECHAR *pstCandidateChar;		/**< 候选字 */
            IMCANDIDATEWORD *pstCandidateWord;		/**< 候选词 */
        }u;											/**< 候选字或词 */
        Guint8	u8Flag;								/**< 联合体标识：0候选字，1候选词 */
    }IMCANDIDATELIST, *PIMCANDIDATELIST;			/* 联想候选字（词）列表结构体 */
    
    /** \} */
    
    /** \addtogroup platform_api_im_group
     \{ */
    
    /**
     **********************************************************************
     \brief 启动手写输入法
     \details 启动手写输入法,进行初始化。
     \param[in] pzPath	 资源目录
     \retval	Gtrue   启动成功
     \retval	Gfalse	启动化失败
     \remarks
     \since 6.0
     \see GPI_HWDeInitialize
     **********************************************************************/
    GPI_API_CALL Gbool GPI_HWInitialize(Gchar* pzPath);
    
    /**
     **********************************************************************
     \brief 退出手写输入法
     \details 退出手写输入法,释放内存。
     \remarks
     \since 6.0
     \see GPI_HWInitialize
     **********************************************************************/
    GPI_API_CALL void GPI_HWDeInitialize(void);
    
    /**
     **********************************************************************
     \brief 参数设置
     \details 设置手写识别类型。
     \param[in] euFlag	 设置参数
     \remarks
     - flag必须为手写识别的枚举类型
     \since 6.0
     \see
     **********************************************************************/
    GPI_API_CALL void GPI_HWSetParam(enumHWFLAG euFlag);
    
    /**
     **********************************************************************
     \brief 手写识别
     \details 通过手写设置传入的参数来获取手写识别的结果。
     \param[in] pstParam	 输入参数
     \param[out] pstCandidate	 识别结果
     \remarks
     - 1.候选字缓冲由应用层开辟空间，至少容纳下nMaxNumberOfCandidate个字
     - 2.GHW_CHARSET_CHINESE GHW_CHARSET_ENGLISH GHW_CHARSET_NUMBER GHW_CHARSET_PUNCTUATION
     这四个字符集可任意组合，至少选一
     - 3.GHW_OUTPUT_DEFAULT GHW_OUTPUT_SIMPLE GHW_OUTPUT_TRADITIONAL
     三个输出方式必先一
     - 4.GHW_OUTPUT_LOWERCASE GHW_OUTPUT_UPPERCASE
     限定大小写字母，在GHW_CHARSET_ENGLISH设置的情况下可选其一
     \since 6.0
     \see
     **********************************************************************/
    GPI_API_CALL void GPI_HWRecognize(HWINPUT *pstParam, HWCANDIDATE *pstCandidate);
    
    /**
     **********************************************************************
     \brief 启动拼音输入法
     \details 初始化输入法，加载指定动态库。
     \param[in] pzPath	 资源目录
     \retval	Gtrue   获取成功
     \retval	Gfalse	获取失败
     \remarks
     - GetProcAddress函数检索指定的动态链接库(DLL)中的输出库函数地址
     \since 6.0
     \see GPI_PYDeInitizlize
     **********************************************************************/
    GPI_API_CALL Gbool GPI_PYInitizlize(Gchar* pzPath);
    
    /**
     **********************************************************************
     \brief 退出拼音输入法
     \details 释放初始化时加载的指定动态链接库
     \remarks
     - FreeLibrary函数释放指定的动态库
     \since 6.0
     \see GPI_PYInitizlize
     **********************************************************************/
    GPI_API_CALL void GPI_PYDeInitizlize(void);
    
    /**
     **********************************************************************
     \brief 获取候选字列表
     \details 根据关键字获取候选字列表。
     \param[in] pzKeyword	 关键字
     \param[out] ppstCandidateList	 候选字列表
     \retval	Gtrue   获取成功
     \retval	Gfalse	获取失败
     \remarks
     - 在获取候选字列表之后记得要清空当前的候选字
     \since 6.0
     \see
     **********************************************************************/
    GPI_API_CALL Gbool GPI_PYGetCandidateList(Gchar *pzKeyword, IMCANDIDATELIST **ppstCandidateList);
    
    /**
     **********************************************************************
     \brief 设置输入法
     \details 设置输入法的格式。
     \param[in] euMode	 输入法模式
     \remarks
     - eMode为有效的参数类型
     \since 6.0
     \see
     **********************************************************************/
    GPI_API_CALL void GPI_PYSetMode(enumIMMODE euMode);
    
    /**
     **********************************************************************
     \brief 设置当前输入法语言
     \details 设置当前输入法语言。
     \param[in] euLanguage	 语言
     \retval	返回错误码
     \remarks
     \since 6.0
     \see
     **********************************************************************/
    GPI_API_CALL void GPI_PYSetLanguage(enumIMLANGUAGE euLanguage);
    
    /**
     **********************************************************************
     \brief 获取输入法类型
     \details 获取当前输入法的类型，包括拼音、英文、笔画、五笔。
     \retval	返回输入法模式
     \remarks
     - pIMMode为有效的参数类型
     \since 6.0
     \see
     **********************************************************************/
    GPI_API_CALL enumIMMODE GPI_PYGetMode();
    
    /**
     **********************************************************************
     \brief 获取联想字
     \details 获取当前输入法联想字词
     \param[in] nIndex	 索引
     \param[out] ppstCandidateList	 联想的字词
     \retval	Gtrue   获取成功
     \retval	Gfalse	获取失败
     \remarks
     - 当前输入法包括手写、拼音、笔画等
     \since 6.0
     \see
     **********************************************************************/
    GPI_API_CALL Gbool GPI_GetAssociateCandidateList(Gint32 nIndex, IMCANDIDATELIST **ppstCandidateList);
    
    /**
     **********************************************************************
     \brief 获取输入法版本号
     \details 获取当前输入法版本号
     \param[out] pVersion	 输入法版本号
     \retval	Gtrue   获取成功
     \retval	Gfalse	获取失败
     \remarks
     - 当前输入法包括手写、拼音、笔画等
     \since 7.0
     \see
     **********************************************************************/
    GPI_API_CALL Gbool GPI_GetIMVersion(Gchar *pzVersion);
    
    /* below this line DO NOT add anything */
    /** \} */
    
#ifdef __cplusplus
}
#endif
#endif

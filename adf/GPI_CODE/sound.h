/* ***************************************************
 * Copyright(c) Xiamen AutoNavi Company. Ltd.
 * All Rights Reserved.
 *
 * File: sound.h
 * Purpose:声音对外接口
 *
 * Author: zhicheng.chen
 *
 *
 * Version: 7.0
 * Date: 12-Jul-2013 18:00:06
 * Update: Create
 *
 *************************************************** */

#ifndef SOUND_H__
#define SOUND_H__

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
    
    typedef Guint32 (*TTSCALLBACKFUNC)(void);	/* TTS回调函数指针 */
    typedef void (*TTSPLAYCALLBACKFUNC)(Gchar *text);	/* TTS回调函数指针 */
    
    /* Sound */
    /**
     * 播报者角色枚举类型
     *
     */
    typedef enum tagTTSROLE
    {
        eSOUND_ROLE_DEFAULT_MAN = 0,	/**< 普通话男 */
        eSOUND_ROLE_DEFAULT_WOMAN,		/**< 普通话女 */
        eSOUND_ROLE_CANTONESE_MAN,		/**< 广东话男 */
        eSOUND_ROLE_CANTONESE_WOMAN,	/**< 广东话女 */
        eSOUND_ROLE_DONGBEI_MAN,		/**< 东北话男 */
        eSOUND_ROLE_DONGBEI_WOMAN,		/**< 东北话女 */
        eSOUND_ROLE_SICHUAN_MAN,		/**< 四川话男 */
        eSOUND_ROLE_SICHUAN_WOMAN,		/**< 四川话女 */
        eSOUND_ROLE_TAIWAN_MAN,			/**< 台湾话男 */
        eSOUND_ROLE_TAIWAN_WOMAN,		/**< 台湾话女 */
        eSOUND_ROLE_HUNAN_MAN,			/**< 湖南男声 */
        eSOUND_ROLE_HENAN_MAN,			/**< 河南男声 */
        eSOUND_ROLE_ENGLISH_MAN,		/**< 英文男 */
        eSOUND_ROLE_ENGLISH_WOMAN,		/**< 英文女 */
        eSOUND_ROLE_CHILD				/**< 普通话儿童 */
    } enumTTSROLE;
    
    /**
     * 播报回调枚举类型
     *
     */
    typedef enum tagTTSCALLBACKTYPE
    {
        eSOUND_CALLBACK_BEFORE_PLAY = 1,	/**< 播报前回调 */
        eSOUND_CALLBACK_AFTER_PLAY  = 2,	/**< 播报后回调 */
    } enumTTSCALLBACKTYPE;
    
    /**
     * 播报参数
     *
     */
    typedef enum tagTTSPARAM
    {
        eSOUND_PARAM_VOLUME = 0x00000504,	/**< volume value */
        eSOUND_PARAM_INCREASE = 0X00000505, /**< 音量增量 */
    }enumTTSPARAM;
    
    /**
     * 播报音量大小
     *
     */
    typedef enum tagTTSVOLUME
    {
        eSOUND_VOLUME_MIN = -32768,	/**< minimized volume */
        eSOUND_VOLUME_NORMAL = 0,	/**< normal volume */
        eSOUND_VOLUME_MAX = +32767,	/**< maximized volume (default) +32767 / 3 = 11000 */
    }enumTTSVOLUME;
    
    /** \} */
    
    /** \addtogroup platform_api_tts_group
     \{ */
    
    /**
     **********************************************************************
     \brief 启动TTS
     \details 启动TTS,默认是普通话女生
     \retval	Gtrue   获取成功
     \retval	Gfalse	获取失败
     \remarks
     \since 6.0
     \see GPI_TTSDeInitialize
     **********************************************************************/
    GPI_API_CALL Gbool GPI_TTSInitialize(Gchar* pzPath);
    
    /**
     **********************************************************************
     \brief 退出TTS
     \details 退出TTS,释放内存
     \remarks
     \since 6.0
     \see GPI_TTSInitialize
     **********************************************************************/
    GPI_API_CALL void GPI_TTSDeInitialize(void);
    
    /**
     **********************************************************************
     \brief TTS语音播报
     \details TTS语音播报指定的内容
     \param[in] pzText	 播报内容
     \remarks
     \since 6.0
     \see GPI_TTSStopSpeak
     **********************************************************************/
    GPI_API_CALL void GPI_TTSPlay(Gchar *pzText);
    
    /**
     **********************************************************************
     \brief TTS切换播报者角色
     \details TTS切换播报者角色,TTS声音变为默认大小
     \param[in] euRole	 播报者角色
     \remarks
     \since 6.0
     \see
     **********************************************************************/
    GPI_API_CALL Gbool GPI_TTSSwitchRole(enumTTSROLE euRole);
    
    /**
     **********************************************************************
     \brief 注册TTS播报的回调
     \details 注册TTS播报前后的回调接口
     \param[in] euType	 回调类型
     \param[in] fptrCallbackFunc	 回调接口地址
     \remarks
     \since 6.0
     \see
     **********************************************************************/
    GPI_API_CALL void GPI_TTSRegisterCallback(enumTTSCALLBACKTYPE euType, TTSCALLBACKFUNC fptrCallbackFunc);
    
    /**
     **********************************************************************
     \brief 设置参数
     \details 设置TTS参数值。
     \param[in] nParamID	 参数
     \param[in] pParamValue	 参数值
     \remarks
     \since 6.0
     \see
     **********************************************************************/
    GPI_API_CALL void GPI_TTSSetParam(Gint32 nParamID, void* pParamValue);
    
    /**
     **********************************************************************
     \brief 是否正在播报
     \details 判断当前是否处于播报状态。
     \retval	Gtrue   正在播报
     \retval	Gfalse	闲
     \remarks
     \since 6.0
     \see
     **********************************************************************/
    GPI_API_CALL Gbool GPI_TTSIsSpeaking(void);
    
    /**
     **********************************************************************
     \brief 停止TTS播报
     \details 停止当前正在TTS播报的文本
     \remarks
     \since 6.0
     \see GPI_TTSPlay
     **********************************************************************/
    GPI_API_CALL void GPI_TTSStopSpeak(void);
    
    /**
     **********************************************************************
     \brief 播放wav格式声音文件
     \details 调用平台相关接口播报wav格式的声音文件。
     \param[in] pzWaveFile	 资源文件名
     \remarks
     - 调用windows平台接口播报wav格式音频文件
     \since 6.0
     \see GUD_PlayWavFun
     **********************************************************************/
    GPI_API_CALL void GPI_PlayWaveFile(const Gchar *pzWaveFile);
    
    /**
     **********************************************************************
     \brief 设置tts播报回调
     \details 设置tts播报回调
     \param[in] palyFunc	 回调函数
     \remarks
     
     \since 6.0
     \see
     **********************************************************************/
    GPI_API_CALL void GPI_SetTTSPlayCallBack(TTSPLAYCALLBACKFUNC playFunc);
    /* below this line DO NOT add anything */
    /** \} */
    
#ifdef __cplusplus
}
#endif
#endif

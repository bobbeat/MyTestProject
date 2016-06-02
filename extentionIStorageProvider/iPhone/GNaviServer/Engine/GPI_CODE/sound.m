//
//  sound.mm
//  AutoNavi
//
//  Created by gaozhimin on 13-10-14.
//
//

#include "sound.h"
#import "MWTTS.h"
#import "DringTracksManage.h"
#pragma mark -

static TTSCALLBACKFUNC g_ttsPlayCallBackBefore = NULL;
static TTSCALLBACKFUNC g_ttsPlayCallBackAfter = NULL;

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
Gbool GPI_TTSInitialize(Gchar* pzPath)
{
    if (pzPath == NULL)
    {
        return Gfalse;
    }
    return Gfalse;
}

/**
 **********************************************************************
 \brief 退出TTS
 \details 退出TTS,释放内存
 \remarks
 \since 6.0
 \see GPI_TTSInitialize
 **********************************************************************/
void GPI_TTSDeInitialize(void)
{
    
}

/**
 **********************************************************************
 \brief TTS语音播报
 \details TTS语音播报指定的内容
 \param[in] pzText	 播报内容
 \remarks
 \since 6.0
 \see GPI_TTSStopSpeak
 **********************************************************************/
void GPI_TTSPlay(Gchar *pzText)
{
    if (pzText == NULL)
    {
        return;
    }
    NSString *text = GcharToNSString(pzText);
    if ([text length] == 0)
    {
        return;
    }
    NSLog(@"GPI_TTSPlay : %@",text);
    
    //add by hlf for 驾驶记录统计超速次数、得分，通过截取语音中包含“您已超速”
    [[DringTracksManage sharedInstance] countHypervelocityWithTTSString:text];
    
    [[MWTTS SharedInstance] playSoundWithString:text priority:TTSPRIORITY_LOW];
    if (g_ttsPlayCallBackAfter)
    {
        g_ttsPlayCallBackAfter();
    }
}

/**
 **********************************************************************
 \brief TTS切换播报者角色
 \details TTS切换播报者角色,TTS声音变为默认大小
 \param[in] euRole	 播报者角色
 \remarks
 \since 6.0
 \see
 **********************************************************************/
Gbool GPI_TTSSwitchRole(enumTTSROLE euRole)
{
    return YES;
}

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
void GPI_TTSRegisterCallback(enumTTSCALLBACKTYPE euType, TTSCALLBACKFUNC fptrCallbackFunc)
{
    if (euType == eSOUND_CALLBACK_BEFORE_PLAY)
    {
        g_ttsPlayCallBackBefore = fptrCallbackFunc;
    }
    else
    {
        g_ttsPlayCallBackAfter = fptrCallbackFunc;
    }
}

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
void GPI_TTSSetParam (Gint32 nParamID, void* pParamValue)
{
//    ivUInt32 *temp = (ivUInt32 *)pParamValue;
//    ivTTS_SetParam(g_hTTS, nParamID, *temp);
}

/**
 **********************************************************************
 \brief 停止TTS播报
 \details 停止当前正在TTS播报的文本
 \remarks
 \since 6.0
 \see GPI_TTSPlay
 **********************************************************************/
void GPI_TTSStopSpeak (void)
{
    [[MWTTS SharedInstance] stop];
}

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
Gbool GPI_TTSIsSpeaking (void)
{
    if ([[MWTTS SharedInstance] status])
    {
        return Gtrue;
    }
	return Gfalse;
}

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
void GPI_PlayWaveFile(const Gchar *pzWaveFile)
{
    if (pzWaveFile == NULL)
    {
        return;
    }
    if ([NSThread isMainThread])
    {
        NSString *path = GcharToNSString((Gchar *)pzWaveFile);
        [[MWTTS SharedInstance] playSoundWithPath:path priority:TTSPRIORITY_LOW];
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *path = GcharToNSString((Gchar *)pzWaveFile);
            [[MWTTS SharedInstance] playSoundWithPath:path priority:TTSPRIORITY_LOW];
        });
    }
}

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
Gbool GPI_GetTTSVersion(Gchar *pzVersion)
{
    return Gtrue;
}

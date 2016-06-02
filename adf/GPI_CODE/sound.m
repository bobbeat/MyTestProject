//
//  sound.mm
//  AutoNavi
//
//  Created by gaozhimin on 13-10-14.
//
//

#include "sound.h"
#pragma mark -

static TTSPLAYCALLBACKFUNC g_ttsPlayCallBack = NULL;
int convertUTF32to81(Gint8 *dest, const Gchar *orig)
{
    Gchar c;
    int i, len = 0;
    
    while ((c = *orig++) != '\0')
    {
        if (c < 0x80) {
            i = 1;
        } else if (c < 0x800) {
            i = 2;
        } else if (c < 0x10000) {
            i = 3;
        } else if (c < 0x200000) {
            i = 4;
        } else if (c < 0x4000000) {
            i = 5;
        } else {
            i = 6;
        }
        if (i == 1) {
            *dest++ = (Gchar)c;
        } else {
            Gint8 *dp = dest = dest + i;
            for (int m = 0; m < i; ++m) {
                *--dp = (Gchar)((c | (m == i - 1 ? (~0 << (8 - i)) : 0x80))
                                & (m == i - 1 ? (~(0x80 >> i)) : 0xbf));
                c >>= 6;
            }
        }
        len += i;
    }
    
    *dest = '\0';
    return len;
}

NSString *Cstring32ToNSString1(Gchar *orig)
{
    int len = 0;
    Gchar c, *cp = (Gchar *)orig;
    while ((c = *cp++) != '\0') ++len;
    
    Gint8 *c8 = malloc(6 * len + sizeof(Gint8));
//    convertUTF32to81(c8, (Gchar *)orig);
    NSString *string = [NSString stringWithCString:(const char *)c8 encoding:NSUTF8StringEncoding];
    free(c8);
    return string;
}

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
    NSString *text = Cstring32ToNSString1(pzText);
    if ([text length] == 0)
    {
        return;
    }
    NSLog(@"GPI_TTSPlay : %@",text);
//    [GDBL_TTS GDBL_TTSPlayByStr:text priority:TTSPRIORITY_NORMAL];
    if (g_ttsPlayCallBack)
    {
        g_ttsPlayCallBack(pzText);
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
//    [MWTTSService sharedInstance].languageIndex = 0;
//    switch (euRole) {
//        case eSOUND_ROLE_DEFAULT_MAN:
//            [MWTTSService sharedInstance].speakerIndex = 1;
//            break;
//        case eSOUND_ROLE_TAIWAN_WOMAN:
//            [MWTTSService sharedInstance].speakerIndex = 2;
//            break;
//        case eSOUND_ROLE_CANTONESE_WOMAN:
//            [MWTTSService sharedInstance].speakerIndex = 3;
//            break;
//        case eSOUND_ROLE_DONGBEI_WOMAN:
//            [MWTTSService sharedInstance].speakerIndex = 4;
//            break;
//        case eSOUND_ROLE_SICHUAN_WOMAN:
//            [MWTTSService sharedInstance].speakerIndex = 5;
//            break;
//        case eSOUND_ROLE_DEFAULT_WOMAN:
//            [MWTTSService sharedInstance].speakerIndex = 0;
//            break;
//        case eSOUND_ROLE_HUNAN_MAN:
//            [MWTTSService sharedInstance].speakerIndex = 6;
//            break;
//        case eSOUND_ROLE_HENAN_MAN:
//            [MWTTSService sharedInstance].speakerIndex = 7;
//            break;
//        case eSOUND_ROLE_ENGLISH_MAN:
//            [MWTTSService sharedInstance].languageIndex = 2;
//            break;
//        case eSOUND_ROLE_ENGLISH_WOMAN:
//            [MWTTSService sharedInstance].languageIndex = 2;
//            break;
//        default:
//            [MWTTSService sharedInstance].speakerIndex = 0;
//            break;
//    }
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
//    [[MWTTSService sharedInstance] stop];
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
//    if ([[MWTTSService sharedInstance] status])
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
//    NSString *path = Cstring32ToNSString((Gchar *)pzWaveFile);
//    [GDBL_TTS GDBL_TTSPlayWavPath:[path UTF8String] priority:TTSPRIORITY_NORMAL];
}

/**
 **********************************************************************
 \brief 设置tts播报回调
 \details 设置tts播报回调
 \param[in] palyFunc	 回调函数
 \remarks
 
 \since 6.0
 \see
 **********************************************************************/
GPI_API_CALL void GPI_SetTTSPlayCallBack(TTSPLAYCALLBACKFUNC playFunc)
{
    g_ttsPlayCallBack = playFunc;
}

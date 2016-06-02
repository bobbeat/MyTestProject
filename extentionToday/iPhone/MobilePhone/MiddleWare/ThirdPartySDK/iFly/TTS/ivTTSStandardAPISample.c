// ivTTSStandardAPISample.c : Defines the entry point for the console application.
//

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "ivTTS.h"
//#include "PublicDefine.h"
#include <TargetConditionals.h>
//#import	"Globall.h"
/* constant for TTS heap size */
/*
 #define ivTTS_HEAP_SIZE		50000 / * 混合，无音效 * /
 */
#define ivTTS_HEAP_SIZE		500*1024 /* 混合，音效 */

size_t ReadResFile(const char * filePathName, unsigned char ** ppContent)
{
    size_t nSize;
    size_t nRet;
    unsigned char * pTemp;
    
    FILE * fpFile = fopen(filePathName,"rb");
    if(!fpFile) return -1;
    
    fseek(fpFile,0,SEEK_END);
    nSize = ftell(fpFile);
    pTemp = (unsigned char *)malloc(nSize+2);
    memset(pTemp,0,nSize+2);
    
    fseek(fpFile,0,SEEK_SET);
    nRet = fread(pTemp,1,nSize,fpFile);
    if(0 == nRet)
    {
        free(pTemp);
        return -1;
    }
    
    fclose(fpFile);
    
    *ppContent = pTemp;
    
    return nSize;
}

/* Message */
ivTTSErrID DoMessage()
{
    /* 获取消息，用户实现 */
    if(1)
    {
        /* 继续合成 */
        return ivTTS_ERR_OK;
    }
    else
    {
        /* 退出合成 */
        return ivTTS_ERR_EXIT;
    }
}

FILE *fpOutput = 0;


/* read resource callback */
ivBool ivCall ReadResCB(
                        ivPointer		pParameter,		/* [in] user callback parameter */
                        ivPointer		pBuffer,		/* [out] read resource buffer */
                        ivResAddress	iPos,			/* [in] read start position */
                        ivResSize		nSize )			/* [in] read size */
{
    FILE* pFile = (FILE*)pParameter;
    int err;
    
    fseek(pFile, iPos, SEEK_SET);
    err = fread(pBuffer, 1, nSize, pFile);
    if ( err == (int)nSize )
        return ivTrue;
    else
        return ivFalse;
}

/* read resource from memory */
ivBool ivCall ReadResCBFromMem(	ivPointer		pParameter,		/* [in] user callback parameter */
                               ivPointer		pBuffer,		/* [out] read resource buffer */
                               ivResAddress	iPos,			/* [in] read start position */
                               ivResSize		nSize )			/* [in] read size */
{
    ivPByte pMemory = (ivPByte)pParameter;
    memcpy(pBuffer, pMemory+iPos, nSize);
    return ivTrue;
}

/* output callback */
ivTTSErrID ivCall OutputCB(
                           ivPointer		pParameter,		/* [in] user callback parameter */
                           ivUInt16		nCode,			/* [in] output data code */
                           ivCPointer		pcData,			/* [in] output data buffer */
                           ivSize			nSize )			/* [in] output data size */
{
    /* play */
    /* 根据实际平台将语音数据传给播音接口，这里只是简单的将语音数据保存在文件中 */
    fwrite(pcData, 1, nSize, fpOutput);
    fflush(fpOutput);
    return ivTTS_ERR_OK;
}

/* parameter change callback */
ivTTSErrID ivCall ParamChangeCB(
                                ivPointer       pParameter,		/* [in] user callback parameter */
                                ivUInt32		nParamID,		/* [in] parameter id */
                                ivUInt32		nParamValue )	/* [in] parameter value */
{
    return ivTTS_ERR_OK;
}

/* progress callback */
ivTTSErrID ivCall ProgressCB(
                             ivPointer       pParameter,		/* [in] user callback parameter */
                             ivUInt32		iProcPos,		/* [in] current processing position */
                             ivUInt32		nProcLen )		/* [in] current processing length */
{
    return ivTTS_ERR_OK;
}

FILE *fpCBLog = 0;
ivUInt16 ivCall LogCB(
                      ivPointer	pParameter,			/* [out] user callback parameter */
                      ivCPointer	pcData,				/* [in] output data buffer */
                      ivSize		nSize				/* [in] output data size */
)
{
    FILE *pFile = (FILE*)pParameter;
    ivSize nWriten = fwrite(pcData,1,nSize,pFile);
    if( nWriten == nSize )
        return ivTTS_ERR_OK;
    else
        return ivTTS_ERR_FAILED;
}

#define ivTTS_CACHE_SIZE	512
#define ivTTS_CACHE_COUNT	1024
#define ivTTS_CACHE_EXT		8

int getSpeakerName(char * speakerName,int spekerIndex)
{
    switch (spekerIndex) {
        case ivTTS_ROLE_CATHERINE:
            memcpy(speakerName, "Catherine", strlen("Catherine"));
            return 1;
            break;
        case ivTTS_ROLE_JOHN:
            memcpy(speakerName, "John", strlen("John"));
            return 1;
            break;
        case ivTTS_ROLE_XIAOFENG:
            memcpy(speakerName, "XiaoFeng", strlen("XiaoFeng"));
            return 1;
            break;
        case ivTTS_ROLE_XIAOLIN:
            memcpy(speakerName, "XiaoLin", strlen("XiaoLin"));
            return 1;
            break;
        case ivTTS_ROLE_XIAOMEI:
            memcpy(speakerName, "XiaoMei", strlen("XiaoMei"));
            return 1;
            break;
        case ivTTS_ROLE_XIAOQIAN:
            memcpy(speakerName, "XiaoQian", strlen("XiaoQian"));
            return 1;
            break;
        case ivTTS_ROLE_XIAORONG:
            memcpy(speakerName, "XiaoRong", strlen("XiaoRong"));
            return 1;
            break;
        case ivTTS_ROLE_XIAOQIANG:
            memcpy(speakerName, "XiaoQiang", strlen("XiaoQiang"));
            return 1;
            break;
        case ivTTS_ROLE_XIAOKUN:
            memcpy(speakerName, "XiaoKun", strlen("XiaoKun"));
            return 1;
        case ivTTS_ROLE_XIAOYAN:
            memcpy(speakerName, "XiaoYan", strlen("XiaoYan"));
            return 1;
        case ivTTS_ROLE_USER:
            memcpy(speakerName, "ZhiLin", strlen("ZhiLin"));
            return 1;
            break;
        default:
            break;
    }
    return 0;
}

//codeType:0 GBK,1 UTF8
int TTS_fun(char *szOutputFile,const char *pszText,int codeType,const char *sourceFileFolder,int speakerIndex,int ttsVoiceSpeed,int ttsUsePrompts)
{
#if !(TARGET_IPHONE_SIMULATOR)
	ivHTTS			hTTS;
	ivPByte			pHeap;
	ivTResPackDesc	tResPackDesc;
	ivTTSErrID		ivReturn;
	char pVoiceData[50];
	char TTS_name[200];
	memset(&TTS_name,0x0,200);
	if (!strlen(szOutputFile)) 
	{
		return 0;
	}
	fpOutput = fopen(szOutputFile,"wb");
	if( !fpOutput )
	{
//		printf("fpoutput is error");
		return 0;
	}
	pVoiceData[0] = 0x52;
	pVoiceData[1] = 0x49 ;
	pVoiceData[2] = 0x46;
	pVoiceData[3] = 0x46;
	pVoiceData[4] = 0xBC;
	pVoiceData[5] = 0x7A;
	pVoiceData[6] = 0x06;
	pVoiceData[7] = 0x00;
	pVoiceData[8] = 0x57;
	pVoiceData[9] = 0x41;
	pVoiceData[10] = 0x56;
	pVoiceData[11] = 0x45;
	pVoiceData[12] = 0x66;
	pVoiceData[13] = 0x6D;
	pVoiceData[14] = 0x74;
	pVoiceData[15] = 0x20;
	
	pVoiceData[16] = 0x10;
	pVoiceData[17] = 0x00;
	pVoiceData[18] = 0x00;
	pVoiceData[19] = 0x00;
	pVoiceData[20] = 0x01;
	pVoiceData[21] = 0x00;
	pVoiceData[22] = 0x01;
	pVoiceData[23] = 0x00;
	pVoiceData[24] = 0x80;
	pVoiceData[25] = 0x3E;
	pVoiceData[26] = 0x00;
	pVoiceData[27] = 0x00;
#if 1
	pVoiceData[28] = 0x80;
	pVoiceData[29] = 0x3e;
	pVoiceData[30] = 0x00;
	pVoiceData[31] = 0x00;
#else
	pVoiceData[28] = 0x00;
	pVoiceData[29] = 0x2e;
	pVoiceData[30] = 0x00;
	pVoiceData[31] = 0x00;
#endif
	
	
	pVoiceData[32] = 0x02;
	pVoiceData[33] = 0x00;
	pVoiceData[34] = 0x10;
	pVoiceData[35] = 0x00;
	pVoiceData[36] = 0x64;
	pVoiceData[37] = 0x61;
	pVoiceData[38] = 0x74;
	pVoiceData[39] = 0x61;
	pVoiceData[40] = 0x98;
	pVoiceData[41] = 0x7a;
	pVoiceData[42] = 0x06;
	pVoiceData[43] = 0x00;
	
	
	
	fwrite(pVoiceData,1,44,fpOutput);
	
	
	
	
	if (1)
	{
		/* ∑÷≈‰∂— */
		pHeap = (ivPByte)malloc(ivTTS_HEAP_SIZE);
		memset(pHeap, 0, ivTTS_HEAP_SIZE);
        sprintf(TTS_name, "%s/Resource.irf",sourceFileFolder);  //获取Resource.irf路径
        memset(&tResPackDesc, 0x0, sizeof(ivTResPackDesc));
        ReadResFile(TTS_name, (unsigned char **)&tResPackDesc.pCBParam);  //modify by gzm for 读取文件数据，来自iflydemo at 2014-11-24
		tResPackDesc.pfnRead = ReadResCBFromMem;
		tResPackDesc.pfnMap = NULL;
		tResPackDesc.nSize = 0;
		
		if (tResPackDesc.pCBParam)
		{
			tResPackDesc.pCacheBlockIndex = (ivPUInt8)malloc(ivTTS_CACHE_COUNT + ivTTS_CACHE_EXT);
			tResPackDesc.pCacheBuffer = (ivPUInt8)malloc((ivTTS_CACHE_COUNT + ivTTS_CACHE_EXT)*(ivTTS_CACHE_SIZE));
			tResPackDesc.nCacheBlockSize = ivTTS_CACHE_SIZE;
			tResPackDesc.nCacheBlockCount = ivTTS_CACHE_COUNT;
			tResPackDesc.nCacheBlockExt = ivTTS_CACHE_EXT;
		}
		else
		{
			fclose(fpOutput);
			//printf("tResPackDesc is error");
			return 0;
		}
		
		/*不使用log，就将最后一个参数设置为null*/
		ivReturn = ivTTS_Create(&hTTS, (ivPointer)pHeap, ivTTS_HEAP_SIZE, ivNull, (ivPResPackDescExt)&tResPackDesc, (ivSize)1,NULL);
		
		/* 设置音频输出回调 */
		ivReturn = ivTTS_SetParam(hTTS, ivTTS_PARAM_OUTPUT_CALLBACK, (ivSize)OutputCB);
		
		//@modi start by lzb for sound_flag
		
		if(codeType == 1)
		{
		
			ivReturn = ivTTS_SetParam(hTTS, ivTTS_PARAM_INPUT_CODEPAGE, ivTTS_CODEPAGE_UTF8);
		}
		else
		{
			ivReturn = ivTTS_SetParam(hTTS, ivTTS_PARAM_INPUT_CODEPAGE, ivTTS_CODEPAGE_GBK);
		}	
		
		//@modi end by lzb for sound_flag
		 /* 设置语种 */
		if (speakerIndex == ivTTS_ROLE_CATHERINE || speakerIndex == ivTTS_ROLE_JOHN)
		{
			ivReturn = ivTTS_SetParam(hTTS, ivTTS_PARAM_LANGUAGE, ivTTS_LANGUAGE_ENGLISH);	
		}
		else
		{
			ivReturn = ivTTS_SetParam(hTTS, ivTTS_PARAM_LANGUAGE, ivTTS_LANGUAGE_CHINESE);	
		}
	
		 /* 设置音量 */
		ivReturn = ivTTS_SetParam(hTTS, ivTTS_PARAM_VOLUME, ivTTS_VOLUME_MAX);
        ivReturn = ivTTS_SetParam(hTTS, ivTTS_PARAM_VOICE_SPEED, ttsVoiceSpeed);
        ivReturn = ivTTS_SetParam(hTTS, ivTTS_PARAM_USE_PROMPTS, ttsUsePrompts);
        
        /************************************************************************
         块式合成
         ************************************************************************/
		/* 设置发音人 */
        if (speakerIndex)
        {
            ivReturn = ivTTS_SetParam(hTTS, ivTTS_PARAM_ROLE, speakerIndex);
        }
        else
        {
            ivReturn = ivTTS_SetParam(hTTS, ivTTS_PARAM_ROLE, ivTTS_ROLE_XIAOYAN);
        }
		ivReturn = ivTTS_SynthText(hTTS, ivText(pszText), -1);
		
		ivReturn = ivTTS_Destroy(hTTS);
		
		if ( tResPackDesc.pCacheBlockIndex )
		{
			free(tResPackDesc.pCacheBlockIndex);
		}
		if ( tResPackDesc.pCacheBuffer )
		{
			free(tResPackDesc.pCacheBuffer);
		}
		if ( pHeap )
		{
			free(pHeap);
		}
	}
    if (tResPackDesc.pCBParam) {
        free(tResPackDesc.pCBParam);
    }
	
	long len;
	fseek(fpOutput, 0, SEEK_END);
	len = ftell(fpOutput);
	len = len - 8;
	
	fseek(fpOutput,4,SEEK_SET);
	fwrite(&len, 1, 4, fpOutput);
	
	len = len - 0x44;
	
	fseek(fpOutput,0x28,SEEK_SET);
	fwrite(&len, 1, 4, fpOutput);
	
	
	
	fclose(fpOutput);	
	//	printf("fpOutput is success");
	return 1;

#endif
}

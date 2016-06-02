//
//  im.m
//  Gpi
//
//  Created by gaozhimin on 13-10-23.
//  Copyright (c) 2013年 autonavi. All rights reserved.
//

#include "im.h"


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
Gbool GPI_HWInitialize(Gchar* pzPath)
{
    return Gfalse;
}

/**
 **********************************************************************
 \brief 退出手写输入法
 \details 退出手写输入法,释放内存。
 \remarks
 \since 6.0
 \see GPI_HWInitialize
 **********************************************************************/
void GPI_HWDeInitialize(void)
{
    
}

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
void GPI_HWSetParam(enumHWFLAG euFlag)
{
    
}

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
void GPI_HWRecognize(HWINPUT *pstParam, HWCANDIDATE *pstCandidate)
{
    
}

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
Gbool GPI_PYInitizlize(Gchar* pzPath)
{
    return Gfalse;
}

/**
 **********************************************************************
 \brief 退出拼音输入法
 \details 释放初始化时加载的指定动态链接库
 \remarks
 - FreeLibrary函数释放指定的动态库
 \since 6.0
 \see GPI_PYInitizlize
 **********************************************************************/
void GPI_PYDeInitizlize(void)
{
    
}

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
Gbool GPI_PYGetCandidateList(Gchar *pzKeyword, IMCANDIDATELIST **ppstCandidateList)
{
    return Gfalse;
}

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
void GPI_PYSetMode (enumIMMODE euMode)
{
    
}

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
enumIMMODE GPI_PYGetMode()
{
    return 0;
}

/**
 **********************************************************************
 \brief 获取联想字
 \details 获取当前输入法联想字词
 \param[in] pzKeyword	 关键字
 \param[out] ppstCandidateList	 联想的字词
 \retval	Gtrue   获取成功
 \retval	Gfalse	获取失败
 \remarks
 - 当前输入法包括手写、拼音、笔画等
 \since 6.0
 \see
 **********************************************************************/
Gbool GPI_GetAssociateCandidateList(Gint32 nIndex, IMCANDIDATELIST **ppstCandidateList)
{
    return Gfalse;
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
Gbool GPI_GetIMVersion(Gchar *pzVersion)
{
    return Gfalse;
}

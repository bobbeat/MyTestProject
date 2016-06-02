/*----------------------------------------------+
 |												|
 |	ivPlatform.h - Platform Config				|
 |												|
 |		Platform: ADS1.2 (ARM)					|
 |												|
 |		Copyright (c) 1999-2007, iFLYTEK Ltd.	|
 |		All rights reserved.					|
 |												|
 +----------------------------------------------*/


/*
 *	TODO: 在这里包含目标平台程序需要的公共头文件
 */
//#include <stdlib.h>
//#include <string.h>
/*#include <stdint.h>*/
#include  <stdio.h>
#include  <stdlib.h>
#include <stdint.h>

/*
 *	TODO: 根据目标平台特性修改下面的配置选项
 */

#define IV_UNIT_BITS			8			/* 内存基本单元位数 */
#define IV_BIG_ENDIAN			0			/* 是否是 Big-Endian 字节序 */
#define IV_PTR_GRID				8			/* 最大指针对齐值 */

#define IV_PTR_PREFIX						/* 指针修饰关键字(典型取值有 near | far, 可以为空) */
#define IV_CONST				const		/* 常量关键字(可以为空) */
#define IV_EXTERN				extern		/* 外部关键字 */
#define IV_STATIC				static		/* 静态函数关键字(可以为空) */
#define IV_INLINE				/*__inline*/	/* 内联关键字(典型取值有 inline, 可以为空) */
#define IV_CALL_STANDARD		/*__stdcall*/	/* 普通函数修饰关键字(典型取值有 stdcall | fastcall | pascal, 可以为空) */
#define IV_CALL_REENTRANT		/*__stdcall*/	/* 递归函数修饰关键字(典型取值有 stdcall | reentrant, 可以为空) */
#define IV_CALL_VAR_ARG			/*__cdecl*/		/* 变参函数修饰关键字(典型取值有 cdecl, 可以为空) */

#define IV_TYPE_INT8			char		/* 8位数据类型 */
#define IV_TYPE_INT16			short		/* 16位数据类型 */
#define IV_TYPE_INT24			int			/* 24位数据类型 */
#define IV_TYPE_INT32			int		/* 32位数据类型 */

#if 1 /* 48/64 位数据类型是可选的, 如非必要则不要定义, 在某些 32 位平台下, 使用模拟方式提供的 48/64 位数据类型运算效率很低 */
#define IV_TYPE_INT48			long long		/* 48位数据类型 */
#define IV_TYPE_INT64			long long	/* 64位数据类型 */
#endif

#define IV_TYPE_ADDRESS			size_t 		/* 地址数据类型 */
#define IV_TYPE_SIZE			size_t	/* 大小数据类型 */

#define IV_ANSI_MEMORY			0			/* 是否使用 ANSI 内存操作库 */
#define	IV_ANSI_STRING			0			/* 是否使用 ANSI 字符串操作库 */

#define IV_ASSERT(exp)			/*_ASSERT(exp)*//* 断言操作(可以为空) */
#define IV_YIELD				/*Sleep(0)*/	/* 空闲操作(在协作式调度系统中应定义为任务切换调用, 可以为空) */

#define IV_TTS_ARM_CODECACHE	1			/* 手工代码Cache */

/* 根据平台编译选项决定是否支持调试 */
#if defined(DEBUG) || defined(_DEBUG)
#define IV_DEBUG			1			/* 是否支持调试 */
#else
#define IV_DEBUG			0			/* 是否支持调试 */
#endif

/* 调试方式下则输出日志 */
#ifndef IV_LOG
#define IV_LOG				0	/* 是否输出日志 */
#endif

/* 根据平台编译选项决定是否以 Unicode 方式构建 */
#if defined(UNICODE) || defined(_UNICODE)
#define IV_UNICODE			1			/* 是否以 Unicode 方式构建 */
#else
#define IV_UNICODE			0			/* 是否以 Unicode 方式构建 */
#endif

/* ***************************************************
* Copyright(c) Xiamen AutoNavi Company. Ltd.
* All Rights Reserved.
*
* File: gpimacro.h
* Purpose:宏定义文件
*	
* Author: zhicheng.chen
*
*
* Version: 7.0
* Date: 12-Jul-2013 18:00:06
* Update: Create
*
*************************************************** */
#ifndef GPIMACRO_H__
#define GPIMACRO_H__

/**
\defgroup gpi_data_structures_group GPI Data Structures
\{
*/


#ifdef GNAVIGPI_LIB
	#define GPI_API_CALL
#else
	#ifdef PLATFORM_ANDROID
		#ifdef GNAVIGPI_EXPORTS
			#define GPI_API_CALL __attribute__ ((visibility ("default")))
		#else
			#define GPI_API_CALL
		#endif/*GNAVIMID_EXPORTS */
	#else
		#ifdef GNAVIGPI_EXPORTS
			#define GPI_API_CALL __declspec(dllexport)
		#else
			#define GPI_API_CALL __declspec(dllimport)
		#endif/*GNAVIMID_EXPORTS */
	#endif
#endif
#endif

/* below this line DO NOT add anything */
/** \} */

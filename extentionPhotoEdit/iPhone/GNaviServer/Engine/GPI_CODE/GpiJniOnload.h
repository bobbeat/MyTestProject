#ifndef __INCLUDED_GPIJNIONLOAD_H__
#define __INCLUDED_GPIJNIONLOAD_H__

#ifdef __cplusplus
extern "C" {
#endif
#include "gtypes.h"
#include "gpimacro.h"
#include <stdio.h>
#include <stdarg.h>

#include <jni.h>

GPI_API_CALL  Gint32 register_com_autonavi_xm_navigation_engine_GPITM(JavaVM* vm);
GPI_API_CALL Gint32 register_com_autonavi_xm_navigation_engine_GPITHREAD(JavaVM* vm);

#ifdef __cplusplus
}
#endif

#endif //__INCLUDED_GPIJNIONLOAD_H__

//
//  GDBL_InterfaceEx.h
//  AutoNavi
//
//  Created by yu.liao on 13-5-29.
//
//
#include "GDBL_typedefEx.h"
#include "GDBL_typedef.h"
#ifndef AutoNavi_GDBL_InterfaceEx_h
#define AutoNavi_GDBL_InterfaceEx_h
//#include "GDNet_ProtocolDefine.h"
//#include "GDNet_ProtocolParse.h"
#if (defined (WIN32) || defined (_WIN32) || defined(PLATFORM_WIN8) || defined(PLATFORM_WINPHONE))
#ifdef  GNAVISERVER_EXPORTS
#define GDBL_API_CALL		__declspec(dllexport)
#else
#define GDBL_API_CALL		__declspec(dllimport)
#endif
#elif defined(PLATFORM_TIZEN) || defined(PLATFORM_ANDROID)
#ifdef  GNAVISERVER_EXPORTS
#define GDBL_API_CALL			__attribute__ ((visibility ("default")))
#else
#define GDBL_API_CALL			/* extern */
#endif
#else
#define GDBL_API_CALL			/* extern */
#endif

//GDBL_API_CALL GSTATUS GDBL_GetCurrentMapViewType(Gint32 *mapViewType);
//GDBL_API_CALL GSTATUS GDBL_GetCurrentMapViewHandle(GHMAPVIEW *mapViewHandle);
//GDBL_API_CALL GSTATUS GDBL_SetMapType(Gint32 mapType);
//GDBL_API_CALL Gint32  GDBL_GetMapType(void);
//GDBL_API_CALL GSTATUS GDBL_SetVoicePlayType(Gint32 voiceType);
//GDBL_API_CALL Gint32  GDBL_GetVoicePlayType(void);
//
//GDBL_API_CALL GSTATUS GDBL_SetViewModeCar();
//GDBL_API_CALL GSTATUS GDBL_SetViewModeNorth();
//GDBL_API_CALL GSTATUS GDBL_SetViewMode3D();
//GDBL_API_CALL GSTATUS GDBL_GetViewMode(Gint32 *viewMode);
//
//
//GDBL_API_CALL GSTATUS GDBL_ScaleIn(Gfloat64 deltaScale);
//GDBL_API_CALL GSTATUS GDBL_ScaleOut(Gfloat64 deltaScale);
//GDBL_API_CALL GSTATUS GDBL_ScaleEnd(void);
GDBL_API_CALL GSTATUS GDBL_FlingMap(Gint32 iVelocityX, Gint32 iVelocityY);
//GDBL_API_CALL GSTATUS GDBL_StopFling(Gbool bShowBuffer);
//GDBL_API_CALL GSTATUS GDBL_StopRotate(Gbool bShowBuffer);
//GDBL_API_CALL GSTATUS GDBL_StopAdjustElevation(Gbool bShowBuffer);
GDBL_API_CALL Gbool GDBL_CheckRecognizeType(RECOGNIZETYPE compareRecoginzeType);
GDBL_API_CALL GSTATUS GDBL_SetRecognizeEvent(RECOGNIZETYPE newRecognizeType,Gbool isStopAllEvent);
GDBL_API_CALL GSTATUS GDBL_StopAllRecognizeEvent();


//GDBL_API_CALL GSTATUS GDBL_GetGPSInfo (GGPSINFO *pGpsInfo);
//GDBL_API_CALL GSTATUS GDBL_GetSatelliteInfo (GSATELLITEINFO *pSatellite);
//
//
//GDBL_API_CALL GSTATUS GDBL_TrackIsLoaded(
//                                         Gchar *szFileName,
//                                         Gbool *bLoaded
//                                         );
//
////替代引擎的GDBL_Startup GDBL_RotateMap  GDBL_RotateMapView
//GDBL_API_CALL GSTATUS GDBL_StartupEx (void* Wnd);
//GDBL_API_CALL GSTATUS GDBL_RotateMapEx (
//                                      Gint32 deltaAngle,
//                                      Gint32 deltaVelocity
//                                      );
//GDBL_API_CALL GSTATUS GDBL_RotateMapViewEx (
//                                          GHMAPVIEW hMapView,
//                                          Gbool bAbsolute,
//                                          Gfloat32  xa,
//                                          Gfloat32  ya,
//                                          Gfloat32  za,
//                                          Gint32 deltaVelocity
//                                          );
//GDBL_API_CALL GSTATUS GDBL_IsValidateUserEx(Gchar *path);
//

#endif

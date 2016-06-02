//
//  GDBL_typedefEx.h
//  AutoNavi
//
//  Created by yu.liao on 13-5-29.
//
//

#ifndef AutoNavi_GDBL_typedefEx_h
#define AutoNavi_GDBL_typedefEx_h
#define MODE_NORTH			1		//NORTH
#define MODE_CAR			2		//CAR
#define MODE_3D				4		//3D
#define MODE_MOVE			8		//北首上模式(移图状态)
#define MODE_ROTATE			16		//自由模式(旋转状态)
#define MODE_ROTATE_MOVE	24		//自由模式(旋转+移图状态)
#define MODE_ADJUST			32		//北首上(矫正状态)
/**
 * 手势事件结构体
 * 用于存储(ios平台)使用的手势类型信息,可包含多个
 */
typedef enum RECOGNIZETYPE {
	EVENT_NONE =0,
	EVENT_PINCH			=1,		//缩放
	EVENT_PAN_MOVE		=2,		//滑动移图
	EVENT_PAN			=4,		//移图
	EVENT_SWIP			=8,		//调整仰角
	EVENT_ROTATE		=16,	//旋转
	EVENT_TAP_SINGLE	=32,	//单指单击(目前无操作，但是有其它手势效果时会将手势结束)
	EVENT_TAP_DOUBLE	=64,	//单指双击 放大1级
	EVENT_DOUBLE_FINGER_TAP =128,//双指单击 缩小1级
    EVENT_LONGPRESS     =256,    //长按
}RECOGNIZETYPE;


/* 参数 */
typedef enum tagGPARAMEXT
{
    BACKGROUND_NAVI,
    VOICE_TRAFFIC,
    TMC_STATE,
    WARNINGVIEW,
    SKIN_CHECKRESULT,           //皮肤更新结果
    SKINTYPE,                   //皮肤类型 0:默认
    GRESOURCE_CHECKRESULT,      //资源更新结果
}GPARAMEXT;


#endif

//
//  MWTypedef.h
//  AutoNavi
//
//  Created by huang longfeng on 13-8-7.
//
//

#ifndef AutoNavi_MWTypedef_h
#define AutoNavi_MWTypedef_h

typedef enum IMAGEPATH_TYPE{
    IMAGEPATH_TYPE_1,            //普通图片获取
    IMAGEPATH_TYPE_2,            //区分白天黑夜，皮肤类型获取图片
    IMAGEPATH_TYPE_3,            //根据皮肤路径获取图片
    IMAGEPATH_TYPE_4,            //指定路径获取图片
}IMAGEPATHTYPE;

typedef enum MAINVIEWPROCESSTYPE
{
    ProcessType_MessageBox  = 23,//处理推送的消息盒子和客户反馈信息
    ProcessType_SmsMoveMap  = 21,//短信移图
    ProcessType_SetDes      = 20,//第三方软件传经纬度设置终点
    
}MAINVIEWPROCESSTYPE;

#endif

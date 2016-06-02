//
//  MWNotifyConstants.h
//  AutoNavi
//
//  Created by longfeng.huang on 14-5-6.
//  存放全局通知，如果不是全局通知，尽量声明在自己模块
//  命名规则：NOTIFY_功能名

#ifndef AutoNavi_MWNotifyConstants_h
#define AutoNavi_MWNotifyConstants_h

#pragma mark

#define MWDISMISSMODLEVIEWCONTROLLER        @"MWDismissModelViewcontroller"

#pragma mark 

#define NOTIFY_TOUCH			            @"_TOUCH"//触屏
#define NOTIFY_MOVEMAP			            @"_MOVEMAP"//移图
#define NOTIFY_GOTOCPP			            @"_GOTOCPP"//回车位
#define NOTIFY_BEGINPOINT		            @"_BEGINPOINT"//设起点
#define NOTIFY_STARTGUIDANCE	            @"_STARTGUIDANCE"//开始引导
#define NOTIFY_NO_PATH                      @"_NO_PATH"//将isPath置为NO
#define NOTIFY_STOPGUIDANCE                 @"_STOPGUIDANCE"//去除路径
#define NOTIFY_VIEWCONDITION	            @"_VIEWCONDITION"//视图显示条件
#define NOTIFY_ENDINGPOINT		            @"_ENDINGPOINT"//设终点
#define NOTIFY_MAPMODE			            @"_MAPMODE"//地图模式切换
#define NOTIFY_2DMAPENLARGE		            @"_2DMAPENLARGE"//2D地图放大
#define NOTIFY_2DMAPNARROW		            @"_2DMAPNARROW"//2D地图缩小
#define NOTIFY_3DMAPENLARGE		            @"_3DMAPENLARGE"//3D仰角放大
#define NOTIFY_3DMAPNARROW		            @"_3DMAPNARROW"//3D仰角缩小
#define NOTIFY_3DANGLELEFT		            @"_3DANGLELEFT"//3D右旋转角度
#define NOTIFY_3DANGLERIGHT		            @"_3DANGLERIGHT"//3D左旋转角度
#define NOTIFY_INSIMULATION		            @"_INSIMULATION"//进入模拟导航
#define NOTIFY_EXSIMULATION		            @"_EXSIMULATION"//退出模拟导航
#define NOTIFY_INVALIDPOSITION	            @"_INVALIDPOSITION"//非法位置
#define NOTIFY_PASSINFOTOHUD	            @"_PASSINFOTOHUD"//主界面传递相关信息至HUD界面
#define NOTIFY_VOICESYNC                    @"_VOICESYNC" //语音提示开关同步到路况播报开关

#pragma mark 新功能介绍

#define NOTIFY_popScrollView                @"popScrollView"
#define NOTIFY_HideNavigation               @"HideNavigation"
#define NOTIFY_ShowNavigation               @"ShowNavigation"

#pragma mark POI搜素
//poi搜索
//-------------------------------------------------
// NSNotification对象定义：
//通知参数对象：DefineNotificationParam
//  sender =（NSObject）通知的发送者
//  flag   =（bool）0: 搜索失败 1：搜索成功
//  param  = 无
//-------------------------------------------------
#define NOTIFY_POISEARCH	                @"_POISEARCH"//获取poi搜索列表成功



#endif

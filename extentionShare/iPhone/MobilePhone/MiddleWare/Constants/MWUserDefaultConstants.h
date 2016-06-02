//
//  MWUserDefaultConstants.h
//  AutoNavi
//
//  Created by longfeng.huang on 14-5-6.
//  用 NSUserDefaults 保存数据所用的key值均保存到此头文件，并按模块区分
//  命名规则：USERDEFAULT_保存的数据

#ifndef AutoNavi_MWUserDefaultConstants_h
#define AutoNavi_MWUserDefaultConstants_h

#pragma mark 开机相关 

//软件升级检测
#define USERDEFAULT_MWSoftWareUpdateReminderKey         @"SoftWareUpdateReminderKey"
//上传设备令牌
#define USERDEFAULT_MWUploadTokenAutoNaviSuccess        @"MWUploadTokenAutoNaviSuccess"
#define USERDEFAULT_LaunchImageID                       @"LaunchImageID"
#define USERDEFAULT_LaunchImageStartTime                @"LaunchImageStartTime"

#pragma mark 地图数据下载相关

//地图数据下载页面点击更新保存最新版本，用于控制new图标是否显示
#define USERDEFAULT_MWDataUpdateSaveNewVersion          @"MWDataUpdateSaveNewVersion"

#pragma mark 统计
//偏航统计的key --  NSUserDefault 使用的 key
#define USERDEFAULT_LoaclRecalculationRoute             @"LoaclRecalculationRoute"

#pragma mark 里程

//里程统计有效定位点行政编码
#define USERDEFAULT_MileCalAdminCode                                @"MileCalAdminCode"
//里程统计区域码
#define USERDEFAULT_MileCalArea                                     @"MileCalArea"
//里程活动弹出框标示
#define USERDEFAULT_MileActivePop                                   @"MileActivePop"

#pragma mark 资源文件

#pragma mark 人工导航
#define icallOperatorKey                                            @"icallOperatorKey"

#pragma mark 驾驶记录

#define USERDEFAULT_ScoreDetail                                      @"ScoreDetail" //驾驶记录击败多少人列表
#define USERDEFAULT_AlertDistanceShortOnce                           @"AlertDistanceShortOnce"//有效行驶距离小于1km，无法打分提示一次标示
#define USERDEFAULT_AlertViewScoreOnce                               @"AlertViewScoreOnce"//请在个人中心－驾驶记录查看此次行驶分数提示一次标示

#pragma mark 2/3D融合

#define USERDEFAULT_NaviMapMode                                      @"NaviMapMode"     //2/3D融合，记录导航时的视图类型，车首，北首，3D

#pragma mark  林志玲语音提示
#define USERDEFAULT_LinZhiLingTips                                  @"LinZhiLingTips"   //林志玲语音提示框

#endif

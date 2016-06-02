//
//  ANParamValue.h
//  AutoNavi
//
//  保存全局变量,主界面状态组合,逻辑判断处理
//
//  Created by GHY on 12-4-19.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HMI_typedef.h"

extern int isEngineInit;      //引擎是否初始化成功

@interface ANParamValue : NSObject 
{
    GCOORD startCoord;
}

@property (nonatomic, assign) int isReq95190Des;                   //是否请求95190目的地

@property (nonatomic, assign) BOOL isInit;                          //引擎是否初始化

@property (nonatomic, assign) BOOL isMove;                //当前是否是移图状态
@property (nonatomic, assign, readonly) BOOL isPath;                //当前是否是引导状态
@property (nonatomic, assign, readonly) BOOL isSafe;                //当前是否是屏保状态
@property (nonatomic, assign, readonly) BOOL isNavi;                //当前是否在模拟导航


@property (nonatomic, assign) long    total_byte;                   //总流量
@property (nonatomic, assign) long current_byte;                    //当前流量

@property (nonatomic, assign) int nSpeed;                           //摄像头类型
@property (nonatomic, assign) int eCategory;                        //摄像头类型

@property (nonatomic, assign) BOOL FavEditFlag;                     //我的收藏编辑标志：no：失败 yes：成功

@property (nonatomic, assign) GCOORD searchMapInfo;
@property (nonatomic, assign) BOOL addHistory;                      //添加到历史目的地

@property (nonatomic, assign) BOOL isDriveComputer;                 //是否进入行车电脑界面
@property (nonatomic, assign) BOOL isHud;                           //是否进入HUD界面

@property (nonatomic, retain) NSDictionary *busEndingPoint;
@property (nonatomic, retain) NSDictionary *navEndingPoint;

@property (nonatomic, assign) int scaleFactor;                      //设备比例因子


@property (nonatomic,assign) int isSelectCity;                      //去哪里搜索是否选择区域

@property (nonatomic,assign) GCOORD startCoord;                     //保存routing起点坐标
@property (nonatomic,assign) GCOORD desCoord;                       //保存routing终点坐标
@property (nonatomic,assign) GCOORD curGPSCoord;                    //保存当前gps定位点


@property (nonatomic,assign) BOOL bSupportAutorate;

@property (nonatomic,assign) BOOL beFirstNewFun;                    //是否是第一次新功能介绍
@property (nonatomic,assign) BOOL beFirstDown;                      //第一次进入地图数据下载列表



@property (nonatomic,assign) BOOL isMainViewController;//当前视图是否是主地图

@property (nonatomic,assign) int isRequestParking;  //0 : 不请求停车场信息  1：请求停车场信息 2:停车场为终点

@property (nonatomic,assign) BOOL new_fun_flag;//

@property (nonatomic,assign) BOOL isParseFinish;//地图数据下载列表是否已经下载过，如果更改了字体，则该变量会重新置为NO

@property (nonatomic,assign) BOOL isTMCRequest; //实时交通是否正在请求

@property (nonatomic,assign) GCOORD smsCoord;//短信移图经纬度

@property (nonatomic,assign) GPOI thirdPartDesPOI;//第三方目的地poi

@property (nonatomic,assign) GPOI palellerRoadPOI;//平行道路起点

@property (nonatomic,assign) BOOL isWarningView;//是否在警告界面

@property (nonatomic,assign) int skinType;      //皮肤的颜色类型 0 - 默认颜色

@property (nonatomic,assign) BOOL isStartUpNeedShowView; //解决ipad勾选不再提示会白屏问题

@property (nonatomic,assign) int isHistoryRouteClick; //是否点击历史路线进行路径演算，用来判断是否进行路线重新保存 保存点击的历史路线索引
#pragma mark 单例 
+ (ANParamValue *)sharedInstance;

- (int)GMD_GetViewConditon;

#pragma mark 主地图（更多按钮）new图标是否显示
- (BOOL) GMD_isMoreNew;


@end

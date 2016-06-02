//
//  GDBL_UserBehaviorCountNew.h
//  AutoNavi
//
//  Created by jiangshu.fu on 13-5-27.
//
//

#import <Foundation/Foundation.h>


@interface GDBL_UserBehaviorCountNew : NSObject
{
}

+(GDBL_UserBehaviorCountNew *) shareInstance;

#pragma  mark---  新添加  ---
//开启导航！
@property(nonatomic) int openNavigation;
//中间变量 —— 导航开启时间，导航开启次数
@property (nonatomic,retain) NSString *tempFirstStartUp;
@property (nonatomic) int tempOpenNavigation;
//北向上视角(t)
//---  时长  ---
@property(nonatomic) int northUpViewSeconds_InPath;
@property(nonatomic) int northUpViewSeconds;
//车头向上视角(t)

//---  时长  ---
@property(nonatomic) int upViewSeconds_InPath;
@property(nonatomic) int upViewSeconds;
//3D视角(t)

//---  时长  ---
@property(nonatomic) int car3DViewSeconds_InPath;
@property(nonatomic) int car3DViewSeconds;

//实时交通开启时长
@property (nonatomic) int TMCTime;
#pragma mark ---  函数  ---

//读取数据
-(void)readData;
//保存数据
-(void)saveData;
//复位 
-(void)resetData;
//计时器（确定各种视图或者东西的持续时间）
-(void)timeCount;


@end

//
//  MWRouteDemo.m
//  AutoNavi
//
//  Created by gaozhimin on 14-5-7.
//
//

#import "MWRouteDemo.h"

@implementation MWRouteDemo

/**
 **********************************************************************
 \brief 启动模拟导航
 \details 启动模拟导航。
 **********************************************************************/
+(GSTATUS)StartDemo
{
    GSTATUS res = GDBL_StartDemo();
    GDBL_GoToCCP();
    if (GD_ERR_OK==res)
    {
        [MWMapOperator SetBuildingRaiseRate:0.0];   //设置建筑物压低
        
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_INSIMULATION object:nil];
    }
    return res;
}

/**
 **********************************************************************
 \brief 暂停模拟导航
 \details 暂停模拟导航。
 *********************************************************************/
+(GSTATUS)PauseDemo
{
    return GDBL_PauseDemo();
}

/**
 **********************************************************************
 \brief 继续模拟导航
 \details 继续模拟导航。
 **********************************************************************/
+(GSTATUS)ContinueDemo
{
    return GDBL_ContinueDemo();
}

/**
 **********************************************************************
 \brief 停止模拟导航
 \details 停止模拟导航。
 **********************************************************************/
+(GSTATUS)StopDemo
{
    GSTATUS res;
    res = GDBL_StopDemo();
    GDBL_GoToCCP();
    if (GD_ERR_OK==res)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_EXSIMULATION object:nil];
    }
    return res;
}
@end

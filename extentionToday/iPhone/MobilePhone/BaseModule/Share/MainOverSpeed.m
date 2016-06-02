//
//  MainOverSpeed.m
//  AutoNavi
//
//  Created by bazinga on 14-10-16.
//
//

#import "MainOverSpeed.h"

@implementation MainOverSpeed


+ (instancetype)SharedInstance
{
    static MainOverSpeed *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[MainOverSpeed alloc] init];
        
        //限速摄像头回调
        PSAFEINFOCALLBACK temp = GNULL;
        temp = SetSafeInfoCallback;
        GDBL_SetSafeInfoCallback(temp);
        
        
        PUSERSAFEINFOCALLBACK temp1 = GNULL;
        temp1 = SetUserSafeInfoCallback;
        GDBL_SetUserSafeInfoCallback(temp1);
    });
    
    return sharedInstance;
}

- (id) init
{
    self = [super init];
    if(self)
    {
        self.speed = 0;
        self.hidden = YES;
        self.changeSpeed = nil;
        self.roadID = -1;
    }
    return self;
}


static void SetSafeInfoCallback(GSAFEALERTINFO *pstAlertInfo)
{
    //系统的摄像头
    NSLog(@"funcCallback");
    if(pstAlertInfo->nDisyplayCnt > 0 && pstAlertInfo->pstDisplaySafety->n16Speed > 0)
    {
        [MainOverSpeed SharedInstance].hidden = NO;
        [MainOverSpeed SharedInstance].speed = pstAlertInfo->pstDisplaySafety->n16Speed;
        NSLog(@"Speed = %d, Kind = %d",pstAlertInfo->pstDisplaySafety->n16Speed,pstAlertInfo->pstDisplaySafety->n16Kind);
        
        [[MainOverSpeed SharedInstance] speedNumAndNoHidden:pstAlertInfo->pstDisplaySafety->n16Speed];
    }
    else
    {
        [MainOverSpeed SharedInstance].hidden = [NSNumber numberWithInt:YES];
        [MainOverSpeed SharedInstance].speed = 0;
        [[MainOverSpeed SharedInstance] speedZeroAndHidden];
    }
}

static void SetUserSafeInfoCallback(GUSERSAFEALERTINFO *pstAlertInfo)
{
    //用户自定义摄像头
    if(pstAlertInfo->pstDisplaySafety->stDataHead.n16Speed > 0)
    {
        [MainOverSpeed SharedInstance].hidden = NO;
        [MainOverSpeed SharedInstance].speed = pstAlertInfo->pstDisplaySafety->stDataHead.n16Speed ;
        
        [[MainOverSpeed SharedInstance] speedNumAndNoHidden:pstAlertInfo->pstDisplaySafety->stDataHead.n16Speed];
    }
    else    //用户自定义摄像头没有
    {
        if([MainOverSpeed SharedInstance].speed == 0)   //速度 = 0 ，引擎摄像头为0，用道路速度去绑定
        {
            //删除道路速度
//            [MainOverSpeed SharedInstance].hidden = [NSNumber numberWithInt:YES];
//            [MainOverSpeed SharedInstance].speed = 0;
//            GCARINFO pCarInfo = {0};
//            GSTATUS res = GDBL_GetCarInfo(&pCarInfo);
//            if(res == GD_ERR_OK
//               && pCarInfo.stRoadId.unObjectID != [MainOverSpeed SharedInstance].roadID
//               && [[ANParamValue sharedInstance] isPath])   //有路径，道路 ID 有变化
//            {
//                GROADATTR roadAttr = {0};
//                [MWRouteGuide GetCarRoadAttr:&roadAttr];
//                if(roadAttr.nLimitSpeed > 0)
//                {
//                    [[MainOverSpeed SharedInstance] speedNumAndNoHidden:roadAttr.nLimitSpeed];
//                }
//                else
//                {
//                     [[MainOverSpeed SharedInstance] speedZeroAndHidden];
//                }
//            }
//            else
            {
                [[MainOverSpeed SharedInstance] speedZeroAndHidden];
            }
        }
    }
}

/*!
  @brief    设置速度并且显示
  @param
  @author   by bazinga
  */
- (void) speedNumAndNoHidden:(int)num
{
    if([MainOverSpeed SharedInstance].changeSpeed != nil)
    {
        [MainOverSpeed SharedInstance].changeSpeed(num);
    }
    if([MainOverSpeed SharedInstance].changeHidden != nil)
    {
        [MainOverSpeed SharedInstance].changeHidden(NO);
    }
}

/*!
  @brief    隐藏
  @param
  @author   by bazinga
  */
- (void) speedZeroAndHidden
{
    if([MainOverSpeed SharedInstance].changeSpeed != nil)
    {
        [MainOverSpeed SharedInstance].changeSpeed(0);
    }
    if([MainOverSpeed SharedInstance].changeHidden != nil)
    {
        [MainOverSpeed SharedInstance].changeHidden(YES);
    }

}




@end

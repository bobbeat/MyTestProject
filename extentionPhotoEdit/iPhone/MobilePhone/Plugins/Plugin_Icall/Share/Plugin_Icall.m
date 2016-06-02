//
//  Plugin_Icall.m
//  AutoNavi
//
//  Created by gaozhimin on 14-3-8.
//
//

#import "Plugin_Icall.h"
#import "iCallViewController.h"
@implementation Plugin_Icall

/*!
  @brief 相应模块调用该方法进入该模块
  @param: NSDictionary
        关键字                        值
 viewController             UIViewController   -- 加载视图的UIViewController
  @return 0失败;1成功
  */
//
-(int) enter:(id)param
{
    if ([param isKindOfClass:[NSDictionary class]])
    {
        NSDictionary* values=(NSDictionary*)param;
        if ([[values objectForKey:@"viewController"] isKindOfClass:[UIViewController class]])
        {
            
            UIViewController* ctl =(UIViewController*)[values objectForKey:@"viewController"];
            iCallViewController * icallView = [[iCallViewController alloc]init];
            [ctl presentModalViewController:icallView animated:YES];
            [icallView release];
        }
    }
    return 1;
}

@end

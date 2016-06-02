//
//  MapViewManager.m
//  AutoNavi
//
//  Created by gaozhimin on 14-8-5.
//
//

#import "MapViewManager.h"
#import "PaintingView.h"

static PaintingView *g_mapViewForVisible = nil; //地图视图用于显示当前视图

@implementation MapViewManager


/*
 * @brief 用于加载地图
 * @param ctl 加载地图的controller
 */
+ (PaintingView *)ShowMapViewInController:(UIViewController *)ctl;
{
    if (ctl)
    {
        if (g_mapViewForVisible == nil) {
            CGRect rect;
            if (Interface_Flag == 0)  //竖屏
            {
                rect = CGRectMake(0.0, 0.0, SCREENWIDTH, SCREENHEIGHT); //地图大小要使用手机屏幕大小，要不然会出现地图向上偏移的现象
            }
            else
            {
                rect = CGRectMake(0.0, 0.0, SCREENHEIGHT, SCREENWIDTH);
            }
            g_mapViewForVisible = [[PaintingView alloc] initWithFrame:rect];
            g_mapViewForVisible.userInteractionEnabled = YES;
            [ctl.view addSubview:g_mapViewForVisible];
        }
        else
        {
            if (g_mapViewForVisible.superview != ctl.view)
            {
                [g_mapViewForVisible removeFromSuperview];
                [ctl.view addSubview:g_mapViewForVisible];
                [ctl.view sendSubviewToBack:g_mapViewForVisible];
                
            }
        }
        g_mapViewForVisible.delegate = (id<PaintingViewDelegate>)ctl;
    }
    return g_mapViewForVisible;
}

/*
 * @brief 用于清楚缓存地图父视图，为下一次加载做准备，在viewdidapeare中调用
 */
+ (void)ClearBufferViewSuperview
{
    
}
@end

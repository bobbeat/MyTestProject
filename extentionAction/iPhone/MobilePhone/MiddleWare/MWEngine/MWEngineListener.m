//
//  MWEngineListener.m
//  AutoNavi
//
//  Created by gaozhimin on 14-7-9.
//
//

#import "MWEngineListener.h"

@implementation MWEngineListener

/*
 * @brief: 初始化监听类
 */
+ (MWEngineListener *)sharedInstance
{
    static MWEngineListener *engineListener = nil;
    if (engineListener == nil)
    {
        engineListener = [[MWEngineListener alloc] init];
    }
    return engineListener;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        void *pCB = (void *)RecievieMidMessage;
        GPI_SetMessageCB(pCB);
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(performInMain:) name:@"PERFORMINMAIN" object:Nil];
    }
    return self;
}

void RecievieMidMessage(Gint32 uMsg, void* wp, void* lp)
{
    //    NSLog(@"%d,%d,%d",uMsg,wp,lp);
    if ((int)lp == GD_ERR_IN_PROCESS) /**< 正在处理,则返回*/
    {
        return;
    }
    NSArray* param=[[NSArray alloc] initWithObjects:[NSNumber numberWithInt:uMsg],[NSNumber numberWithLong:wp],[NSNumber numberWithInt:lp],nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PERFORMINMAIN" object:param];
    [param release];
}

- (void)performInMain:(NSNotification *)notify
{
    if ([NSThread isMainThread])
    {
        NSArray *param = notify.object;
        [self postNotifyType:[[param objectAtIndex:0] intValue] WPARAM:[[param objectAtIndex:1] longValue] LPARAM:[[param objectAtIndex:2] intValue]];
    }
    else
    {
        [self performSelectorOnMainThread:@selector(performInMain:) withObject:notify waitUntilDone:NO];
    }
}


/**********************************************************************
 * 函数名称: postNotify
 * 功能描述: 消息(转)发送
 * 输入参数: 1:消息ID	2:wParam	3:lParam
 * 输出参数:
 * 返 回 值：
 * 其它说明:
 * 修改日期			版本号		修改人		修改内容
 * ---------------------------------------------------------------------
 * 2012/02/22		1.0			杨毅
 **********************************************************************/
-(void)postNotifyType:(int)notifyId WPARAM:(long) wParam LPARAM:(int)lParam
{
	NSArray* param=[[NSArray alloc] initWithObjects:[NSNumber numberWithLong:wParam],[NSNumber numberWithInt:lParam],nil];
	switch (notifyId) {
		case WM_BUS_NOTIFY:
		{
			[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_BUS object:param];
		}
			break;
		case WM_GETMAPVIEW:
        {
			[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_SHOWMAP object:param];
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_UPDATE_VIEWINFO object:nil];
        }
			break;
		case WM_ROUTE_CALCULATE:
			[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_STARTTODEMO object:param];
			break;
        case WM_ROUTE_CALCULATE2:
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_STARTTODEMO2 object:param];
            break;
		case WM_UPDATEFAVORITE:
			
			[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_UPDATEFAVORITE object:param];
			break;
			
		case WM_GETPOIDATA:
			
			[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_GETPOIDATA object:param];
			break;
		case WM_TRACKREPLAY:
			
			[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_TRACKREPLAY object:param];
            break;
		case WM_PARALLEL_NOTIFY:
			[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_PARALLEL_NOTIFY object:param];
			break;
        case WM_TMCUPDATE:
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_TMCUPDATE_NOTIFY object:param];
        }
			break;
        case WM_NETMAP_TASK:
        {
            if (lParam == GD_ERR_OK)
            {
                GDBL_NotifyMeshUpdated(G_NET_UPDATEEVENT_MAP);
                if (UIApplicationStateBackground != [[UIApplication sharedApplication] applicationState])
                {
                    GMAPVIEW pMapview;
                    GDBL_GetMapView(&pMapview);
                    
                    GHMAPVIEW phMapView;
                    GDBL_GetMapViewHandle(pMapview.eViewType, &phMapView);
                    GDBL_RefreshMapView(phMapView);
                    //                    GDBL_ShowMapView(pMapview.eViewType, 0, 0, 0);
                }
            };
        }
			break;
        case WM_REACH_DESTINATION_NOTIFY:   //到达目的地通知
        {
            if (wParam == 1) //表示模拟导航，只模拟导航一次
            {
                GDBL_StopDemo();
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_HandleUIUpdate object:[NSNumber numberWithInt:UIUpdate_SimNaviStop] userInfo:nil];
            }
            else if (wParam == 0) //表示定位导航
            {
                [MWRouteGuide GuidanceOperateWithMainID:1 GuideHandle:NULL];  //需要进入打分界面
                [MWJourneyPoint ClearJourneyPoint];
                [MWRouteDetour ClearDetourRoad];
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_STOPGUIDANCE object:nil];
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_SHOWMAP object:param]; //刷一帧图，删除路径线
            }
           
        }
            break;
        case WM_AUTOMODE_CHANGE:
        {
            [MWDayNight SetDayNightModeCallback];
        }
            break;
		default:
			break;
	}
    [param release];
}
@end

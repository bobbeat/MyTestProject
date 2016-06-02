//
//  MPApp.m
//  AutoNavi
//
//  Created by yu.liao on 13-5-23.
//
//

#import "MPApp.h"

#import "AppDelegate_iPhone.h"
#import "AppDelegate_iPad.h"
#import "MWSkinDownloadManager.h"
#import "MWDialectDownloadManage.h"
#import "ANParamValue.h"
#import "plugin-cdm-TaskManager.h"
#import "UIApplication+Category.h"
#import "MWTTS.h"
#import "VCCustomNavigationBar.h"
#import "GDBL_SinaWeibo.h"
#import "GDBL_TCWeibo.h"
#import "MainViewController.h"
// 消息盒子
#import "Plugin_Share.h"
#import "launchRequest.h"
#import "MWPreference.h"
#import "MWMapOperator.h"
#import "ControlCreat.h"
#import "MWApp.h"
#import "MobClick.h"
#import "plugin-cdm-Task.h"
#import "GDActionSheet.h"
#import "GDAlertView.h"
#import "WarningViewController.h"
#import "GDBL_LaunchRequest.h"
#import "CustomWindow.h"
#import "UMTrack.h"
#import "MWUserDeviceURL.h"
//Umeng 推送
#import "UMessage.h"
#import "LXActivity.h"
static MPApp *instance = nil;
static int downloadIndex = -1;
static int skinDownloadIndex = -1;
static int dialectDownloadIndex = -1;

#define NAVITO  @"NaviTo:"

@interface MPApp (Private)

- (void)MyalertView:(NSString *)titletext Message:(NSString *)messagetext Canceltext:(NSString *)mycanceltext Othertext:(NSString *)myothertext alerttag:(int)mytag;
@end

@implementation MPApp

- (id) init {
	self = [super init];
	if (self != nil)
    {
        navigationController = [self navigationController];
        rootViewController   = [self rootViewController];
	}
	return self;
}

+ (MPApp *)sharedInstance
{
    if (instance == nil) {
        instance = [[MPApp alloc] init];
    }
    return instance;
}

- (void)releaseInstance
{
    if (instance != nil)
    {
        [instance release];
        instance = nil;
    }
}

#pragma mark - MPApp Private Methods

- (UINavigationController *)navigationController
{
    AppDelegate_iPhone *delegate = (AppDelegate_iPhone *)[UIApplication sharedApplication].delegate;
    return delegate.navigationController;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        AppDelegate_iPhone *delegate = (AppDelegate_iPhone *)[UIApplication sharedApplication].delegate;
        return delegate.navigationController;
    }
    else
    {
        AppDelegate_iPad *delegate = (AppDelegate_iPad *)[UIApplication sharedApplication].delegate;
        return delegate.navigationController;
    }
    
}

- (ANViewController *)rootViewController
{
    AppDelegate_iPhone *delegate = (AppDelegate_iPhone *)[UIApplication sharedApplication].delegate;
    return delegate.rootViewController;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        AppDelegate_iPhone *delegate = (AppDelegate_iPhone *)[UIApplication sharedApplication].delegate;
        return delegate.rootViewController;
    }
    else
    {
        AppDelegate_iPad *delegate = (AppDelegate_iPad *)[UIApplication sharedApplication].delegate;
        return delegate.rootViewController;
    }
   
}

- (void)setMNavigationController:(UINavigationController *)m_navigationController
{
    navigationController = m_navigationController;
}

-(void)stopApp
{
	[[MWApp sharedInstance] saveAppData];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"exitApplication" object:nil];
	exit(1);
}


- (UIView *)FindAlertOrActionsheet:(NSArray *)array
{
    if (array == nil)
    {
        return 0;
    }
   
    if ([array count] == 0)
    {
        return 0;
    }
    
    int i = 0;
    UIView *view = [array objectAtIndex:i];
    while (view != nil)
    {
        if ([view isKindOfClass:[UIAlertView class]])
        {
            NSLog(@"exist UIAlertView");
            return view;
        }
        if ([view isKindOfClass:[GDActionSheet class]])
        {
            NSLog(@"exist UIImageActionSheet");
            return view;
        }
        if ([[view subviews] count] != 0)
        {
            UIView *sub_view = [self FindAlertOrActionsheet:[view subviews]];
            if (sub_view)
            {
                return sub_view;
            }
            else
            {
                i++;
                if (i == [array count])
                {
                    view = nil;
                }
                else
                {
                    view = [array objectAtIndex:i];
                }
                
            }
        }
        else
        {
            i++;
            if (i == [array count])
            {
                view = nil;
            }
            else
            {
                view = [array objectAtIndex:i];
            }
        }
    }
    
    return view;
}


//推送通知
- (void)pushNotification:(NSDictionary *)userInfo Type:(BOOL)type
{
    UIApplicationState state = [[UIApplication sharedApplication] applicationState];
    if (state == UIApplicationStateActive)
    {
            if ([[userInfo objectForKey:@"aps"] objectForKey:@"alert"])
            {
               
                    [ControlCreat createAlertViewWithTitle:STR(@"Universal_software", Localize_Universal) delegate:nil message:[[userInfo objectForKey:@"aps"] objectForKey:@"alert"]
                                         cancelButtonTitle:nil
                                         otherButtonTitles:@[STR(@"Universal_ok", Localize_Universal)] tag:0];
        
            }
                        
    }
}



- (void)naviTo:(NSString *)urlInfo
{
    NSString *tmpString = [urlInfo CutFromNSString:NAVITO];
    
    if (tmpString) {
        
        NSArray *tmpArray = [tmpString componentsSeparatedByString:@","];
        
        if (tmpArray && tmpArray.count > 1) {
            
            if ([[ANParamValue sharedInstance] isInit])
            {
                
                [navigationController popToRootViewControllerAnimated:NO];
               
                GPOI poi = {0};
                poi.Coord.x = [[tmpArray caObjectsAtIndex:0] floatValue] * 1000000;
                poi.Coord.y = [[tmpArray caObjectsAtIndex:1] floatValue] * 1000000;
                if (tmpArray.count > 2) {
                    
                    GcharMemcpy(poi.szName, NSStringToGchar([tmpArray caObjectsAtIndex:2]),GMAX_POI_NAME_LEN+1);
                }
                
                [MWRouteCalculate setDesWithPoi:poi poiType:GJOURNEY_GOAL calType:GROU_CAL_MULTI];
            }
            else
            {
                GPOI tmp = {0};
                tmp.Coord.x = [[tmpArray caObjectsAtIndex:0] floatValue] * 1000000;
                tmp.Coord.y = [[tmpArray caObjectsAtIndex:1] floatValue] * 1000000;
                if (tmpArray.count > 2) {
                    
                    GcharMemcpy(tmp.szName, NSStringToGchar([tmpArray caObjectsAtIndex:2]),GMAX_POI_NAME_LEN+1);
                }
                
                
                [ANParamValue sharedInstance].thirdPartDesPOI = tmp;
                
                [[MWMapOperator sharedInstance] MW_SetMapOperateType:ProcessType_SetDes];
            }
        }
    }
    
}

- (void)popToRootControllerWith:(UIViewController *)ModalViewController animated:(BOOL)animated
{
    if (ModalViewController == nil)
    {
        return;
    }
    if ([[[ModalViewController class] description] isEqualToString:@"ParentViewController"])
    {
        return;
    }
    
    __block UIViewController *presentingViewController = ModalViewController.presentingViewController;
    [ModalViewController dismissViewControllerAnimated:NO completion:^{
        [self popToRootControllerWith:presentingViewController animated:animated];
    }];
}

- (void)messageMoveMap:(NSString *)urlInfo
{
    
    NSString * strSPcode = [[urlInfo CutFromNSString:@"IA"] substringToIndex:14];
    char str_temp[20];
    memset(str_temp,0x0,20);
    memcpy(str_temp,NSSTRING_TO_CSTRING(strSPcode) ,strlen( NSSTRING_TO_CSTRING(strSPcode)));
    GCOORD tmp = [MWEngineTools SPToGeoCoord:strSPcode];
    //GCOORD tmp = [[ANDataSource sharedInstance] GMD_SPCodeToCoord:str_temp];
    if (tmp.x != 0 && tmp.y != 0) {
        
        
        
        if ([[ANParamValue sharedInstance] isInit])
        {
            
            //关闭弹出框
            [GDAlertView dismissCurrentAlertView];
            UIView *view = [self FindAlertOrActionsheet:[UIApplication sharedApplication].windows] ;
            if ([view isKindOfClass:[GDActionSheet class]])
            {
                [(GDActionSheet *)view ShowOrHiddenActionSheet:NO Animation:NO];
            }
            if ([CustomWindow existCustomWindow])
            {
                [CustomWindow DestroyCustomWindow];
            }
            [SociallShareManage RemoveSocialWindow];
            if (navigationController.visibleViewController && ![navigationController.visibleViewController  isMemberOfClass:[WarningViewController class] ])
            {
                if (navigationController.visibleViewController != navigationController.topViewController)
                {
                    BOOL sing = YES;
                    UIViewController *ctl = navigationController.visibleViewController;
                    while (sing)
                    {
                        if (ctl.presentedViewController)
                        {
                            ctl = ctl.presentedViewController;
                        }
                        else
                        {
                            sing = NO;
                        }
                        
                    }
                    [self popToRootControllerWith:ctl animated:NO];
                }
            }
            [navigationController popToRootViewControllerAnimated:NO];
            if ([ANParamValue sharedInstance].isPath && [ANParamValue sharedInstance].isNavi)
            {
                if ([rootViewController respondsToSelector:@selector(Action_simulatorNavi_Stop)]) {
                    [rootViewController Action_simulatorNavi_Stop];
                }
            }
            
            //得延迟0.5秒再做移图操作，要不然这时候还是处在后台模式，刷不了图，并且解决分享后打开程序，图面异常不能移图的现象。
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                GMOVEMAP moveMap;
                moveMap.eOP = MOVEMAP_OP_GEO_DIRECT;
                moveMap.deltaCoord = tmp;
                [[MWMapOperator sharedInstance] MW_MoveMapView:GMAP_VIEW_TYPE_MAIN TypeAndCoord:&moveMap];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_HandleUIUpdate object:[NSNumber numberWithInt:UIUpdate_MessageMoveMap] userInfo:nil];
            });
        }
        else
        {
            [ANParamValue sharedInstance].smsCoord = tmp;
            [[MWMapOperator sharedInstance] MW_SetMapOperateType:ProcessType_SmsMoveMap];
          
        }
    }
}


- (void)uploadToken:(NSData *)deviceToken
{
    NSRange range;
    //获得的 data 为 <****** **** *** ***> 所以要删掉开头和结尾的来个括号，从1开始，减掉2的长度
    range.length=[deviceToken description].length - 2;
    range.location = 1;
    NSString *deviceToken_ext = [[deviceToken description] substringWithRange:range];
//    if ([deviceTokenEx length]== 0 )
	{
		NSString *lTmp = [NSString stringWithFormat:@"%s"," "];
		NSString* dicStr = [deviceToken_ext stringByReplacingOccurrencesOfString:lTmp withString:@""];
        [MWPreference sharedInstance].deviceToken = dicStr;
	}
    //2f6b10e23478a6742162422137adfc4218b26835269cc53986ccf49ad2a5f2c8
    [[launchRequest shareInstance] UploadTokenToAutonavi:deviceToken_ext];
}


- (float)getSize:(int)size
{
    float _mSize = 0.0;
    
    if (size >= 1024*1024*1024) {
        
        _mSize = size*1.0/1024/1024/1024;
    }
    else if(1024*1024 <= size < 1024*1024*1024)
    {
        _mSize = size*1.0/1024/1024;
    }
    else if(size < 1024*1024){
        
        _mSize = size*1.0/1024;
    }
    
    return _mSize;
}

- (NSString *)getUnit:(int)size
{
    NSString *Unit = nil;
    
    if (size >= 1024*1024*1024) {
        Unit = @"GB";
        
    }
    else if(1024*1024 <= size < 1024*1024*1024)
    {
        Unit = @"MB";
        
    }
    else if(size < 1024*1024){
        Unit = @"KB";
        
    }
    
    return Unit;
}

#pragma mark -
#pragma mark UIAlert

- (void)MyalertView:(NSString *)titletext Message:(NSString *)messagetext Canceltext:(NSString *)mycanceltext Othertext:(NSString *)myothertext alerttag:(int)mytag
{
	
	UIAlertView *Myalert;
	
	Myalert = [[UIAlertView alloc] initWithTitle:titletext
									     message:messagetext
										delegate:self
							   cancelButtonTitle:mycanceltext
							   otherButtonTitles:myothertext,nil];
	
	Myalert.tag = mytag;
	[Myalert show];
	[Myalert release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case 0:
        {
            //默认不做任何操作
        }
            break;
        case 5://地图数据下载
        {
            switch (buttonIndex) {
                case 0:
                {
                    [[TaskManager taskManager] stopAllTask];
                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_HandleUIUpdate object:[NSNumber numberWithInt:UIUpdate_MapDataDownloadUpdate] userInfo:nil];
                }
                    break;
                case 1:
                {
                    [[TaskManager taskManager] start:downloadIndex];
                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_HandleUIUpdate object:[NSNumber numberWithInt:UIUpdate_MapDataDownloadUpdate] userInfo:nil];
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case 6://方言数据下载
        {
            switch (buttonIndex) {
                case 0:
                {
                    [[MWDialectDownloadManage sharedInstance] stopAllTask];
                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_HandleUIUpdate object:[NSNumber numberWithInt:UIUpdate_DialectDownloadUpdate] userInfo:nil];
                }
                    break;
                case 1:
                {
                    [[MWDialectDownloadManage sharedInstance] start:dialectDownloadIndex];
                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_HandleUIUpdate object:[NSNumber numberWithInt:UIUpdate_DialectDownloadUpdate] userInfo:nil];
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case 200:
        {
            [navigationController popToRootViewControllerAnimated:YES];
        }
            break;
        default:
            break;
    }
}
#pragma mark -
#pragma mark MPApp lifecycle

- (void)launchImage:(UIWindow *)window
{
    [[GDBL_LaunchRequest sharedInstance] NET_LaunchImage:window];
    //状态栏透明需打开下面代码
    [window setBackgroundColor:[UIColor colorWithPatternImage:IMAGE(@"viewBackground.png", IMAGEPATH_TYPE_1)]]; //设置背景为白色，使状态栏能和导航栏颜色一样
    
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    if (IOS_7) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }

    [[MWApp sharedInstance] restoreAppData]; //读取保存参数
    
    [[AVAudioSession sharedInstance]  setActive:NO error:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(stopApp) name: @"exitApplication" object: nil];
    
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;
	
	[self pushNotification:[launchOptions objectForKey:@"UIApplicationLaunchOptionsRemoteNotificationKey"] Type:YES];//推送通知
	
    
    //友盟统计
    [MobClick startWithAppkey:UMAppKey];
    [MobClick setAppVersion:XcodeAppVersion]; //参数为NSString * 类型,自定义app版本信息，如果不设置，默认从CFBundleVersion里取

     //友盟推广
    [UMTrack UMTrackMethod];
    
    //友盟推送
    [UMessage startWithAppkey:UMessageKey launchOptions:launchOptions];
     [UMessage setAutoAlert:NO];
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1)
    {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound) categories:nil];
        [UMessage registerRemoteNotificationAndUserNotificationSettings:settings];
    }
    else
    {
        [UMessage registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge
         |UIRemoteNotificationTypeSound
         |UIRemoteNotificationTypeAlert];
    }
    
    
   
        return YES;

}





- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [[MWPreference sharedInstance] setValue:PREF_BACKGROUND_MODE Value:0];
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    [[GDBL_SinaWeibo shareSinaWeibo].sinaweibo applicationDidBecomeActive];//新浪微博，应用从后台唤起时，应调用此方法，需要完成退出当前登录状态的功能

    
    if (![[MWPreference sharedInstance] getValue:PREF_BACKGROUNDDOWNLOAD]) {//后台数据下载
        if (downloadIndex > 0) {
            if (NetWorkType == 2) {
                
                [[TaskManager taskManager] start:downloadIndex];
            }
            else if (NetWorkType == 1){
                Task *temp = [[TaskManager taskManager].taskList objectAtIndex:downloadIndex];
                NSString * strTitle;
                TaskManager *taskmanager = [TaskManager taskManager];
//                long long totalsize = [taskmanager getNeedSize:nil] + temp.total - temp.current;
                long long totalsize = 0;
                if(temp.status == TASK_STATUS_BLOCK)
                {
                    totalsize += temp.total - temp.current;
                
                }
                for(DownloadTask *task in [TaskManager taskManager].taskList)
                {
                    if(task.status==TASK_STATUS_READY  || task.status == TASK_STATUS_RUNNING)
                    {
                        totalsize += task.total - task.current;
                    }
                }
                NSString *Unit = [self getUnit:totalsize];
                float size = [self getSize:totalsize];
                
                strTitle = [NSString stringWithFormat:STR(@"CityDownloadManage_startDownloadAlert", Localize_CityDownloadManage),size,Unit];
                [ControlCreat createAlertViewWithTitle:nil delegate:self message:strTitle cancelButtonTitle:STR(@"Universal_no", Localize_Universal) otherButtonTitles:@[STR(@"Universal_yes", Localize_Universal)] tag:5];
            }
            
        }
        
        if (skinDownloadIndex > 0) {
            
            [[MWSkinDownloadManager sharedInstance] start:skinDownloadIndex];
        }
        
        if (dialectDownloadIndex > 0) {
            
            if (NetWorkType == 2) {
                
                [[MWDialectDownloadManage sharedInstance] start:dialectDownloadIndex];
            }
            else if (NetWorkType == 1){
                
                MWDialectDownloadTask *temp = [[MWDialectDownloadManage sharedInstance].dialectTaskList objectAtIndex:dialectDownloadIndex];
                
                NSString * strTitle;
                
                long long totalsize = [[MWDialectDownloadManage sharedInstance] getNeedSize] + temp.total - temp.current;
                
                NSString *Unit = [self getUnit:totalsize];
                float size = [self getSize:totalsize];
                
                NSString *title = [[MWDialectDownloadManage sharedInstance] getDialectTitle:temp.title];
                strTitle = [NSString stringWithFormat:STR(@"Universal_downloadDialectWithNoWIFI",Localize_Universal),title,size,Unit];
                [ControlCreat createAlertViewWithTitle:nil delegate:self message:strTitle cancelButtonTitle:STR(@"Universal_no", Localize_Universal) otherButtonTitles:@[STR(@"Universal_yes", Localize_Universal)] tag:6];
            }
        }
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
     [[MWPreference sharedInstance] setValue:PREF_BACKGROUND_MODE Value:1];//add by ly for 后台定位会刷图造成死机问题 at 2014.8.20
    
    if (![[MWPreference sharedInstance] getValue:PREF_BACKGROUNDDOWNLOAD]) {//后台数据下载
        downloadIndex = [[TaskManager taskManager] _firstIndexWithStatus:TASK_STATUS_RUNNING];
        if (downloadIndex > 0) {
            [[TaskManager taskManager] stopCurrent:downloadIndex];
        }
        
        skinDownloadIndex = [[MWSkinDownloadManager sharedInstance] _firstIndexWithStatus:TASK_STATUS_RUNNING];
        if (skinDownloadIndex > 0) {
            [[MWSkinDownloadManager sharedInstance] stopCurrent:skinDownloadIndex];
        }
        
        dialectDownloadIndex = [[MWDialectDownloadManage sharedInstance] _firstIndexWithStatus:TASK_STATUS_RUNNING];
        if (dialectDownloadIndex > 0) {
            [[MWDialectDownloadManage sharedInstance] stopCurrent:dialectDownloadIndex];
        }
    }
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    [[GDBL_SinaWeibo shareSinaWeibo].sinaweibo handleOpenURL:url];//新浪微博客户端回调
    [[GDBL_TCWeibo shareTCWeibo].weiboEngine handleOpenURL:url];//腾讯微博客户端回调
    [MWEngineSwitch ClosePlainMap];
    // Are we being launched by Maps to show a route?
	NSString* urlInfo = [[url absoluteString] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"url==%@",urlInfo);
    
	if([urlInfo rangeOfString:@"IA"].length > 0 &&[urlInfo CutFromNSString:@"IA"].length >= 14 )
	{
        
		[self messageMoveMap:urlInfo];
		
	}
    else if ([urlInfo rangeOfString:NAVITO].length > 0 ) //url格式:ANav://NaviTo:116.445285,39.904989,厦门高德 (真实经纬度)
    {
        /*调用方法，字符串需经过如下转换，否则含有中文的话不能调用
        NSString *naviString = @"ANav://NaviTo:118.173606,24.471811,厦门大学";
        NSString* encodeString = [naviString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:encodeString]];
         */
        [self naviTo:urlInfo];
    }
	else
	{
        return YES;
		
	}    
    return YES;
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    
}


- (void)applicationDidEnterBackground:(UIApplication *)application
{
     [[MWPreference sharedInstance] setValue:PREF_BACKGROUND_MODE Value:1];//设置未后台模式
    
    [[MWApp sharedInstance] saveAppData];  //保存系统数据
   
}
- (void)applicationWillEnterForeground:(UIApplication *)application
{
    
     [[MWPreference sharedInstance] setValue:PREF_BACKGROUND_MODE Value:0];//add by ly for 后台定位会刷图造成死机问题 at 2014.8.20
    
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [UMessage registerDeviceToken:deviceToken];
    [self uploadToken:deviceToken];
    
}
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
     //   NSLog(@"Error in registration. Error: %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [self pushNotification:userInfo Type:NO];
     [UMessage didReceiveRemoteNotification:userInfo];
 
}


@end

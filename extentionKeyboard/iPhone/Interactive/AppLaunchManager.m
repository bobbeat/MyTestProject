//
//  AppLaunchManager.m
//  AutoNavi
//
//  Created by gaozhimin on 14-9-18.
//
//

#import "AppLaunchManager.h"
#import "AppDelegate_iPhone.h"
#import "Plugin_DataVerifyDelegate.h"
#import "MWApp.h"
#import "CityDownLoadModule.h"
#import "ParentViewController.h"
#import "launchRequest.h"
#import "VCCustomNavigationBar.h"
#import "WarningViewController.h"
#import "PluginStrategy.h"
#import "SettingNewVersionIntroduceViewController.h"
#import "MainViewController.h"
#import "MPApp.h"


@interface AppLaunchManager()
{
    MainViewController *_mainController;
}

@property(nonatomic,assign) UIWindow *myWindow;
@property(nonatomic,assign) ParentViewController *myNavigation;

@end

@implementation AppLaunchManager

+ (instancetype)SharedInstance
{
    static AppLaunchManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[AppLaunchManager alloc] init];
    });
    
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(dataVerify) name:kStartDataVerify object: nil];
        [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(backToNaviFromDataVerify) name:kDataVerify object: nil];
        [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(enterCityDataDownloadModule:) name:kDataDownload object: nil];
        [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(startEngineInit) name:kEngineInit object: nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (void)launchAppWith:(UIWindow *)window navigation:(UINavigationController *)navigation
{
    self.myWindow = window;
    
    //modify by gzm for 解决横屏进入，能够使程序翻转 at 2014-11-7
    ParentViewController *naviCtl = [[ParentViewController alloc] initWithNavigationBarClass:[VCCustomNavigationBar class] toolbarClass:nil];
    [naviCtl.navigationBar setHidden:YES];
    self.myWindow.rootViewController = naviCtl;
    [naviCtl release];
    
    if (isPad || (iPhone6Plus && Interface_Flag == 1))  //如果是ipad或者iphone6plus横屏则不需要延迟处理，要不会显示出一片空白
    {
        _mainController = [[MainViewController alloc] init]; //预先加载mainviewcontroller
        [self dataVerify];/*数据检测解压*/
    }
    else
    {
        UIViewController *ctl = [[UIViewController alloc] init];
        [MapViewManager ShowMapViewInController:ctl];  //先初始化opengl上下文，防止一开机启动切后台崩溃
        [ctl release];
        //延迟一下 为了更快的加载出开机图片
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            _mainController = [[MainViewController alloc] init]; //预先加载mainviewcontroller
            [self dataVerify];/*数据检测解压*/
        });
        
    }
}

#pragma mark -
#pragma mark =====数据，引擎，导航－初始化=====
//数据检测
- (void)dataVerify
{
    ParentViewController *naviCtl = nil;
    if ([self.myWindow.rootViewController isKindOfClass:[ParentViewController class]])
    {
        naviCtl = (ParentViewController *)self.myWindow.rootViewController;
    }
    else
    {
        naviCtl = [[[ParentViewController alloc] initWithNavigationBarClass:[VCCustomNavigationBar class] toolbarClass:nil] autorelease];
        [self.myWindow sendSubviewToBack:self.myWindow.rootViewController.view];  //将界面在window最底层显示，否则会盖住开机画面
    }
    
    
    Plugin_DataVerifyDelegate* module = [[Plugin_DataVerifyDelegate alloc] init];
    NSArray *param = [[NSArray alloc]initWithObjects:naviCtl,[NSNumber numberWithInt:1], nil];
    [module enter:param];
    [param release];
    [module release];
    
}
//引擎初始化
-(void)startEngineInit
{
    if ([[NSThread currentThread] isMainThread])
    {
        int tmp = [[MWApp sharedInstance] loadEngine];
        [MWPreference sharedInstance].mapVersion = [MWEngineTools GetMapVersion];
        if (!tmp) {
            
            [[ANOperateMethod sharedInstance] GMD_SetSystemLanguage:YES];
            int e_compass = 0;
            GDBL_GetParam(G_DISABLE_ECOMPASS, &e_compass);
            if (!e_compass) {
                [MWGPS  HeadingStartup];
            }
            
            [self backToNaviFromDataVerify];//add by hlf for 引擎初始化后调用 at 2014.08.22
        }
    }
    else
    {
        [self performSelectorOnMainThread:@selector(startEngineInit) withObject:nil waitUntilDone:NO];
    }
    
}

//导航初始化
- (void)start_fun/*:(NSTimer *)timer*/ {
    
    if (![[ANParamValue sharedInstance] isInit]) {
        return;
    }

    [GDBL_UserBehaviorCountNew shareInstance].tempOpenNavigation++;

    [self loadMainCtl];
}

- (void)loadMainCtl
{
    NSMutableArray *viewControllers = [[NSMutableArray alloc] init];
    [viewControllers addObject:_mainController];
    
    if (![[MWPreference sharedInstance] getValue:PREF_NEWFUNINTRODUCE])//新功能介绍界面
    {
        [ANParamValue sharedInstance].beFirstNewFun = 1;
        [ANParamValue sharedInstance].new_fun_flag = NO;//区分不同的界面进入
        
        SettingNewVersionIntroduceViewController *newVersion=[[SettingNewVersionIntroduceViewController alloc] initWithTarget:nil selector:@selector(loadMainCtl)];
        [viewControllers addObject:newVersion];
        [newVersion release];
        [[MWPreference sharedInstance] setValue:PREF_NEWFUNINTRODUCE Value:1];//是否否显示新功能介绍
    }
    
    if ([[MWPreference sharedInstance] getValue:PREF_STARTUPWARNING])
    {
        
        WarningViewController *ctl = [[WarningViewController alloc] initWithTarget:nil selector:@selector(start_fun)];
        [viewControllers addObject:ctl];
        [ctl release];
    }
    
    ParentViewController *naviCtl = nil;
    if ([self.myWindow.rootViewController isKindOfClass:[ParentViewController class]])
    {
        naviCtl = (ParentViewController *)self.myWindow.rootViewController;
    }else{
        naviCtl = [[[ParentViewController alloc] initWithNavigationBarClass:[VCCustomNavigationBar class] toolbarClass:nil] autorelease];
        self.myWindow.rootViewController = naviCtl;
    }
    
    [naviCtl setViewControllers:viewControllers];
    [viewControllers release];
    
    AppDelegate_iPhone *appDelegate = (AppDelegate_iPhone *)[[UIApplication sharedApplication] delegate];
    appDelegate.rootViewController = _mainController;
    appDelegate.navigationController = naviCtl;
    [_mainController release];
    
    [[MPApp sharedInstance] setMNavigationController:naviCtl];//add by hlf for 传入导航栏控制器解决第三方调用时控制器为空，不能回到主界面的问题 at 2014.11.07
    
    self.myNavigation = naviCtl;
    
    [naviCtl.navigationBar setHidden:YES];
}

//数据检测完成后，返回导航程序
-(void)backToNaviFromDataVerify
{
    
    if ([[NSThread currentThread] isMainThread])
    {
        [ANParamValue sharedInstance].bSupportAutorate = YES;

        [self start_fun];

        [[launchRequest shareInstance] launchRequest];
        [_mainController AddOverSpeedCallBack]; //添加引擎超速回调设置 by fujiangshu
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kDataVerify object:nil];
    }
    else
    {
        [self performSelectorOnMainThread:@selector(backToNaviFromDataVerify) withObject:nil waitUntilDone:NO];
    }
}


-(void)enterCityDataDownloadModule:(NSNotification *)downState
{
    ParentViewController *pushCtl = nil;
    int tmp = [[downState object] intValue];
    if (tmp == 0 || tmp == 1)  // 无
    {
        ParentViewController *naviCtl = nil;
        if ([self.myWindow.rootViewController isKindOfClass:[ParentViewController class]])
        {
            naviCtl = (ParentViewController *)self.myWindow.rootViewController;
        }
        else
        {
            naviCtl = [[[ParentViewController alloc] initWithNavigationBarClass:[VCCustomNavigationBar class] toolbarClass:nil] autorelease];
            [self.myWindow sendSubviewToBack:self.myWindow.rootViewController.view]; //将界面在window最底层显示，否则会盖住开机画面
        }
        pushCtl = naviCtl;
    }
    else
    {
        pushCtl = self.myNavigation;
    }
    
    
    
    CityDownLoadModule *tmpObject = [[CityDownLoadModule alloc] init];
    id<ModuleDelegate> module = tmpObject;
    NSDictionary *param;
    if (tmp  == 0)
    {
        param  = [[NSDictionary alloc] initWithObjectsAndKeys:pushCtl,@"controller",@"NoData",@"parma",nil];
    }
    else if(tmp ==1)
    {
        param  = [[NSDictionary alloc] initWithObjectsAndKeys:pushCtl,@"controller",@"HasData",@"parma",nil];
    }
    
    else{
        param  = [[NSDictionary alloc] initWithObjectsAndKeys:pushCtl,@"controller",@"updateAllData",@"parma",nil];
    }
    [module enter:param];
    [param release];
    [tmpObject release];
    
    [pushCtl.navigationBar setHidden:NO];
}


@end

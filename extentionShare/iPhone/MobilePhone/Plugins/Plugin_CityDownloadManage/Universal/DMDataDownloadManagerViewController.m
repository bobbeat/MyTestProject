//
//  DMDataDownloadManagerViewController.h
//  AutoNavi
//
//  Created by huang longfeng on 13-9-05.
//
//

#import "DMDataDownloadManagerViewController.h"
#import "DMDataDownloadPagesContainer.h"
#import "CityDataManagerFirstViewController.h"
#import "plugin-cdm-DownCityDataController.h"
#import "launchRequest.h"
#import "GDAlertView.h"
#import "Data_Upgrade.h"
#import "GDBL_LaunchRequest.h"
#import "MWCityDownloadMapDataList.h"
#import "plugin-cdm-DownloadTask.h"

@interface DMDataDownloadManagerViewController ()
{
    CityDataManagerFirstViewController *cityDataManagerFirstViewController;
    DownLoadCityDataController *downLoadCityDataController;
    BOOL isUpdate;
}

@property (nonatomic, assign) int mDataType;
@property (nonatomic, assign) GDDownloadViewType mViewType;
@property (nonatomic, retain) NSDictionary *adminDic;

@end

@implementation DMDataDownloadManagerViewController

@synthesize pagesContainer;

- (id)initWithViewType:(GDDownloadViewType)viewType DataType:(int)dataType CityAdminCodeArray:(NSDictionary *)adminArray
{
    
    self = [super init];
    if (self) {
        [ANParamValue sharedInstance].isParseFinish = NO;
        
        self.mDataType = dataType;
        self.mViewType = viewType;
        self.adminDic = adminArray;
        
    }
    return self;

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:NO];
    self.title = STR(@"CityDownloadManage_mapDataDownload", Localize_CityDownloadManage);
   
    self.navigationItem.leftBarButtonItem = LEFTBARBUTTONITEM(nil, @selector(goBack:));
    self.navigationItem.rightBarButtonItem = RIGHTBARBUTTONITEM(STR(@"CityDownloadManage_update", Localize_CityDownloadManage), @selector(mapDataUpdate:));
    
    pagesContainer = [[DMDataDownloadPagesContainer alloc] init];
    self.pagesContainer.view.frame = self.view.bounds;
    self.pagesContainer.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.pagesContainer.view];
    
    cityDataManagerFirstViewController = [[CityDataManagerFirstViewController alloc]init];
    cityDataManagerFirstViewController.managerController = self;
    cityDataManagerFirstViewController.isWholeMap = self.mDataType;
    cityDataManagerFirstViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    downLoadCityDataController = [[DownLoadCityDataController alloc] init];
    downLoadCityDataController.cityAdminCodeArray = self.adminDic;
    downLoadCityDataController.managerController = self;
    
    self.pagesContainer.viewControllers = @[cityDataManagerFirstViewController, downLoadCityDataController];
    [cityDataManagerFirstViewController release];
    [downLoadCityDataController release];
    
    
    [self.pagesContainer setSelectedIndex:self.mViewType animated:NO];
    [self.pagesContainer setTitleColor:self.mViewType];
    
    if (self.mDataType == 0) {
        if ([[TaskManager taskManager].taskList count] > 0) {
            self.navigationItem.leftBarButtonItem.enabled = YES;
        }
        else{
            self.navigationItem.leftBarButtonItem.enabled = NO;
        }
        
        
    }
    else{
        self.navigationItem.leftBarButtonItem.enabled = YES;
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleUIUpdate:) name:NOTIFY_HandleUIUpdate object:nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(EnterForegroundNotification:) name:UIApplicationWillEnterForegroundNotification object: nil];
    
    BOOL  isupdate = [[TaskManager taskManager]checkUpdate];
    self.navigationItem.rightBarButtonItem.enabled = isupdate;
}

- (void)goBack:(id)sender
{
    [cityDataManagerFirstViewController Back:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    
    
    if (Interface_Flag == 1)
	{
		[self changeLandscapeControlFrameWithImage];
		
	}
	else if(Interface_Flag == 0)
	{
		[self changePortraitControlFrameWithImage];
	}
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self hideLoadingViewWithAnimated:NO];
}

- (void)viewWillUnload
{
//    self.pagesContainer = nil;
    [super viewWillUnload];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    
    
    if(toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
	{
        [self changeLandscapeControlFrameWithImage];
	}
	else if(toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
	{
        [self changePortraitControlFrameWithImage];
    }
}

-(void)dealloc
{
    
    if (pagesContainer)
    [pagesContainer release];
    CRELEASE(_adminDic);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (void)changePortraitControlFrameWithImage
{
    self.pagesContainer.view.frame = CGRectMake(0., 0., APPWIDTH, APPHEIGHT + 27.);
    [self.pagesContainer updateLayoutForNewOrientation:0];
    [cityDataManagerFirstViewController set_HV:0];
    [downLoadCityDataController set_HV:0];
}

- (void)changeLandscapeControlFrameWithImage
{
    self.pagesContainer.view.frame = CGRectMake(0., 0., APPHEIGHT, APPWIDTH + 27.);
    [self.pagesContainer updateLayoutForNewOrientation:0];
    [cityDataManagerFirstViewController set_HV:1];
    [downLoadCityDataController set_HV:1];
}

- (void)EnterForegroundNotification:(NSNotification *)notification
{
    
    if (self.navigationController.topViewController != self) {
        return;
    }
    [cityDataManagerFirstViewController set_HV:2];
}


//更新按钮响应函数
- (void)mapDataUpdate:(id)sender
{

    [[TaskManager taskManager]processNoMatchTask];
    [[TaskManager taskManager] updateAll];//add by xyy for 全部更新
    

    //检查空间和网络
    long long totalsize = [[TaskManager taskManager] getNeedSize:nil];
    long long disksize = [UIDevice getCurDiskSpaceInBytes];
    
    if(disksize < totalsize)
    {
        
        float freesize = (float)(totalsize - disksize)/1024/1024/1024;
        NSString *strTitle;
        strTitle = [NSString stringWithFormat:STR(@"CityDownloadManage_noFreeSize", Localize_CityDownloadManage),disksize/1024/1024/1024.0,totalsize/1024/1024/1024.0,freesize];
        
        GDAlertView *alertView = [[GDAlertView alloc] initWithTitle:nil andMessage:strTitle];
        
        [alertView addButtonWithTitle:STR(@"Universal_ok", Localize_Universal) type:GDAlertViewButtonTypeDefault handler:^(GDAlertView *alertView){
            [[TaskManager taskManager]stopAllTask];
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_HandleUIUpdate object:[NSNumber numberWithInt:UIUpdate_MapDataDownloadUpdate] userInfo:nil];
        }];
        [alertView show];
        [alertView release];
        
    }
    else {
        int netType = NetWorkType;
        if (netType == 2) {
            [[TaskManager taskManager] start];
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_HandleUIUpdate object:[NSNumber numberWithInt:UIUpdate_MapDataDownloadUpdate] userInfo:nil];
        }
        else if(netType == 1){
            
            NSString * strTitle;
            
            long long totalsize =0;
            
            for(DownloadTask *task in [TaskManager taskManager].taskList)
            {
                if(task.status==TASK_STATUS_READY || task.status==TASK_STATUS_RUNNING)
                {
                    totalsize += task.total - task.current;
                }
            }
            
            
            NSString *Unit;
            float size;
            if (totalsize >= 1024*1024*1024) {
                Unit = @"GB";
                size = totalsize*1.0/1024/1024/1024;
            }
            else if(1024*1024 <= totalsize < 1024*1024*1024)
            {
                Unit = @"MB";
                size = totalsize*1.0/1024/1024;
            }
            else if(totalsize < 1024*1024){
                Unit = @"KB";
                size = totalsize*1.0/1024;
            }
            
            strTitle = [NSString stringWithFormat:STR(@"CityDownloadManage_startDownloadAlert", Localize_CityDownloadManage),size,Unit];
            
            GDAlertView *alertView = [[GDAlertView alloc] initWithTitle:nil andMessage:strTitle];
            [alertView addButtonWithTitle:STR(@"Universal_no", Localize_Universal) type:GDAlertViewButtonTypeCancel handler:^(GDAlertView *alertView){
                [[TaskManager taskManager]stopAllTask];
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_HandleUIUpdate object:[NSNumber numberWithInt:UIUpdate_MapDataDownloadUpdate] userInfo:nil];
            }];
            [alertView addButtonWithTitle:STR(@"Universal_yes", Localize_Universal) type:GDAlertViewButtonTypeDefault handler:^(GDAlertView *alertView){
                
                [[TaskManager taskManager] start];
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_HandleUIUpdate object:[NSNumber numberWithInt:UIUpdate_MapDataDownloadUpdate] userInfo:nil];
            }];
            [alertView show];
            [alertView release];
            
            
        }
        else {
            GDAlertView *alertView = [[GDAlertView alloc] initWithTitle:nil andMessage:STR(@"Universal_withoutNetwork",Localize_Universal)];
            
            [alertView addButtonWithTitle:STR(@"Universal_ok", Localize_Universal) type:GDAlertViewButtonTypeDefault handler:nil];
            [alertView show];
            [alertView release];
        }
        
    }

    /////
    [[TaskManager taskManager]store];
    //add by xyy for更新完需要重现检查有无更新情况，把全部更新按钮变灰
    BOOL  isupdate = [[TaskManager taskManager]checkUpdate];
    self.navigationItem.rightBarButtonItem.enabled = isupdate;
    
}

//隐藏导航栏右边按钮
- (void)setRightBarButtonHidden:(BOOL)hidden
{
    if (hidden) {
        self.navigationItem.rightBarButtonItem = nil;
    }
    else{
        self.navigationItem.rightBarButtonItem = RIGHTBARBUTTONITEM(STR(@"CityDownloadManage_update", Localize_CityDownloadManage), @selector(mapDataUpdate:));
    }
}

//地图升级检测委托回调
- (void)handleUIUpdate:(NSNotification *)result
{
    if (self.navigationController.topViewController != self) {
        return;
    }
    switch ([[result object] intValue]) {
        
        case UIUpdate_MapDataChangeView:
        {
            if ([[[result userInfo] objectForKey:@"selectindex"] intValue] == 0)//在下载管理页面
            {//add by xyy 根据有无更新 对右上角的“全部更新”按钮进行显示或灰化
                BOOL isupdate = [[TaskManager taskManager]checkUpdate];
                
                [self setRightBarButtonHidden:NO];
                self.navigationItem.rightBarButtonItem.enabled = isupdate;
                
            }
            else if ([[[result userInfo] objectForKey:@"selectindex"] intValue] == 1)//在省市列表页面
            {
                [self setRightBarButtonHidden:YES];//隐藏全部更新按钮
            }
        }
            break;
        default:
            break;
    }
    
}
@end
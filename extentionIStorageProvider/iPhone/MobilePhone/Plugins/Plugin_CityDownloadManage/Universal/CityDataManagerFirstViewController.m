//
//  CityDataManagerFirstViewController.m
//  plugin-CityDataManager
//
//  Created by hlf on 11-11-8.
//  Copyright (c) 2011年 Autonavi. All rights reserved.
//

#import "CityDataManagerFirstViewController.h"
#import "plugin-cdm-DownCityDataController.h"
#import "CustomCell.h"
#import "plugin-cdm-Task.h"
#import "plugin-cdm-DownloadTask.h"
#import "Quotation.h"
#import "plugin-cdm-IntegratedDownLoadTask.h"
#import "plugin-cdm-RoadDownloadTask.h"
#import "QLoadingView.h"
#import "GDAlertView.h"
#import "DMDataDownloadPagesContainer.h"
#import "POITableHeadView.h"
#import "DMDataDownloadManagerViewController.h"
#import "ControlCreat.h"
#import  "UIDevice+Category.h"
#import "MWCityDownloadMapDataList.h"
#import "SectionInfo.h"
#import "Play.h"
#import "quotation.h"
#import "GDBL_DataVerify.h"

@interface CityDataManagerFirstViewController ()
{
	
	UITableView                     *m_table;
    UIButton *deleteButton;
    UIButton *buttonStartAll;
    UIButton *buttonStopAll;
	UIButton *buttonDeleteAll;
	UIButton *buttonDeleteSelected;
    UIImageView *imageViewBac;
    UIImageView *imageViewLine1;
    UIImageView *imageViewLine2;
    
	__block BOOL  isRemove;       //是否有删除过地图数据
	BOOL  clickFlag;      //选择城市按钮是否点击
	BOOL  removeFlag;     //滑动删除按钮标志
    BOOL  isBaseDataUnzipFinish; //基础路网数据是否解压完成
    BOOL  isBaseUnzipQloadingFlag; //基础数据未解压完成菊花转动标志
    BOOL  isBackFromCitySeltct;
    int   finishTaskCount; //是否是两个section
    int   finishTaskType; //是否有完成的任务
    
}

@end

@implementation CityDataManagerFirstViewController

@synthesize isWholeMap;
@synthesize managerController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		self.title = STR(@"CityDownloadManage_downloadManager",Localize_CityDownloadManage);
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupCityItems:) name:kAddEarthquakesNotif object:nil]; //下载地图数据消息传递
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeAllTask) name:remallTask object:nil];             //删除所有任务消息回调
        [self restoreDownLoadTaskList]; //恢复下载列表
    }
    return self;
}
							
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

//读取下载列表
//检查是否有更新，更改updated字段
- (void)restoreDownLoadTaskList
{
    //恢复下载列表
	TaskManager *taskmanager = [TaskManager taskManager];
	[TaskManager taskManager].delegate = self;
	if ([taskmanager.taskList count] == 0) {
		[[TaskManager taskManager] restore];
        
	}
	
	for (Task *task in taskmanager.taskList) {
		task.delegate = taskmanager;
	}
    
    //比较版本，检查是否有更新,只检查已经下载完成的
    
    [taskmanager getUpdateStatus];
    [taskmanager checkTaskInfo];
    
    
}
- (void)continueToDownload
{
    if (isBackFromCitySeltct) {
        return;
    }
    
    //无任务在运行且有为下载完成的数据，则提示是否下载数据
	if ([[TaskManager taskManager] isRunning] == NO && isWholeMap != 3) {
        
		for (Task *task in [TaskManager taskManager].taskList) {
            
			if (task.status == TASK_STATUS_READY || task.status == TASK_STATUS_BLOCK) {
                
                __block CityDataManagerFirstViewController *weakSelf = self;
                double delayInSeconds = 0.6;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    
                    GDAlertView *alertView=[[GDAlertView alloc] initWithTitle:nil andMessage:STR(@"CityDownloadManage_continueToDownload",Localize_CityDownloadManage)];
                    [alertView addButtonWithTitle:STR(@"Universal_cancel", Localize_Universal) type:GDAlertViewButtonTypeCancel handler:nil];
                    [alertView addButtonWithTitle:STR(@"Universal_ok", Localize_Universal) type:GDAlertViewButtonTypeDefault handler:^(GDAlertView *alertView){
                        if([weakSelf isKindOfClass:[CityDataManagerFirstViewController class]] && m_table)
                            //m_table放在block中，retaincount+1
                        {
                            [weakSelf startAllAction];
                        }
                        
                    }];
                    [alertView show];
                    [alertView release];
                    
                });
                
				
				break;
			}
		}
	}
	else
    {
        if ([[ANParamValue sharedInstance] beFirstDown] == NO) {
            
            int index = [[TaskManager taskManager] _firstIndexWithStatus:TASK_STATUS_RUNNING];
            
            if (index < 0) {
                return;
            }
            int netType = NetWorkType;
            if (netType == 2) {
                
                [[TaskManager taskManager] firstStart:index];
            }
            else if(netType == 1 && netType != 2){
                
                GDAlertView *alertView = [[GDAlertView alloc] initWithTitle:nil andMessage:[self alert_DownLoad_NOWIFI]];
                [alertView addButtonWithTitle:STR(@"Universal_no", Localize_Universal) type:GDAlertViewButtonTypeCancel handler:^(GDAlertView *alertView){
                    [[TaskManager taskManager] stopAllTask];
                    [m_table reloadData];
                }];
                [alertView addButtonWithTitle:STR(@"Universal_yes", Localize_Universal) type:GDAlertViewButtonTypeDefault handler:^(GDAlertView *alertView){
                    TaskManager *taskmanager = [TaskManager taskManager];
                    [taskmanager firstStart:index];
                    [m_table reloadData];
                }];
                [alertView show];
                [alertView release];
            }
            else {
                
                [[TaskManager taskManager] stopAllTask];//add by hlf for 无网络连接则暂停所有任务
                
                GDAlertView *alertView = [[GDAlertView alloc] initWithTitle:nil andMessage:STR(@"Universal_withoutNetwork",Localize_Universal)] ;
                
                [alertView addButtonWithTitle:STR(@"Universal_ok", Localize_Universal) type:GDAlertViewButtonTypeDefault handler:nil];
                [alertView show];
                [alertView release];
                
            }
        }
        
        
    }
}
#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleUIUpdate:) name:NOTIFY_HandleUIUpdate object:nil];
    
    self.navigationItem.leftBarButtonItem = [[[VCTranslucentBarButtonItem alloc] initWithType:VCTranslucentBarButtonItemTypeBackward title:nil target:self action:@selector(Back:)] autorelease];
	self.view.autoresizingMask =  UIViewAutoresizingFlexibleWidth
    | UIViewAutoresizingFlexibleHeight;
    
    [ANParamValue sharedInstance].bSupportAutorate = YES;
    
    [self continueToDownload];
	
    [self buttonInit];

    [self setButtonHidden];
    
	isRemove = NO;  
	clickFlag = NO;
	removeFlag = NO;
	[ANParamValue sharedInstance].beFirstDown = YES;
    

    if (Interface_Flag == 1)
	{
		[self set_HV:1];
	}
	else if(Interface_Flag == 0)
	{
		[self set_HV:0];
	}
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	[self.navigationController setNavigationBarHidden:NO animated:animated];
    
	if (Interface_Flag == 1) 
	{
		[self set_HV:1];
		
	} 
	else if(Interface_Flag == 0)
	{
		[self set_HV:0];
	}
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if(toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
	{
		[self set_HV:1];
	}
	else if(toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
	{
		[self set_HV:0];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if (!OrientationSwitch) 
    {
        return (Orientation == interfaceOrientation);
    }
	return  YES;
    
}

- (void)dealloc 
{
    
    [m_table setEditing:NO];
    m_table.delegate = nil;
    m_table.dataSource = nil;
    m_table = nil;
    
	[TaskManager taskManager].delegate = nil;
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
    [super dealloc];
}

//横竖屏切换
-(void)set_HV:(int)flag
{
    float buttonHeight = 50.0;
	if (flag == 0) {
        [m_table setFrame:CGRectMake(0, 6.0f, APPWIDTH, CONTENTHEIGHT_V - 94.)];

        [imageViewBac setFrame:CGRectMake(0, m_table.frame.origin.y + m_table.frame.size.height, APPWIDTH, buttonHeight)];
        [imageViewLine1 setFrame:CGRectMake(APPWIDTH/3.0 - 1., 0, 2., buttonHeight)];
        [imageViewLine2 setFrame:CGRectMake(APPWIDTH * 2.0/3.0 - 1., 0, 2., buttonHeight)];
        [deleteButton setFrame:CGRectMake(0.,0, APPWIDTH/3.0, buttonHeight)];
        [buttonStartAll setFrame:CGRectMake(APPWIDTH/3.0, 0, APPWIDTH/3.0, buttonHeight)];
        [buttonStopAll setFrame:CGRectMake(APPWIDTH*2.0/3.0, 0, APPWIDTH/3.0, buttonHeight)];
        [buttonDeleteAll setFrame:CGRectMake(APPWIDTH/2.0-60.,0, 120., buttonHeight)];
        [buttonDeleteSelected setFrame:CGRectMake(APPWIDTH-120., 0, 120., buttonHeight)];
        
	}
	else if(flag == 1)
	{
        [m_table setFrame:CGRectMake(0, 6.0f, APPHEIGHT, CONTENTHEIGHT_H - 94.)];
        
        if (isPad) {
            [imageViewBac setFrame:CGRectMake(0, m_table.frame.origin.y + m_table.frame.size.height, APPHEIGHT, buttonHeight)];
            [imageViewLine1 setFrame:CGRectMake(APPHEIGHT/3.0 - 1., 0, 2., buttonHeight)];
            [imageViewLine2 setFrame:CGRectMake(APPHEIGHT * 2.0/3.0 - 1., 0, 2., buttonHeight)];
            [deleteButton setFrame:CGRectMake(0., 0, APPHEIGHT/3.0, buttonHeight)];
            [buttonStartAll setFrame:CGRectMake(APPHEIGHT/3.0, 0, APPHEIGHT/3.0, buttonHeight)];
            [buttonStopAll setFrame:CGRectMake(APPHEIGHT*2.0/3.0, 0, APPHEIGHT/3.0, buttonHeight)];
            [buttonDeleteAll setFrame:CGRectMake(APPHEIGHT/2.0-60., 0, 120., buttonHeight)];
            [buttonDeleteSelected setFrame:CGRectMake(APPHEIGHT-120., 0, 120., buttonHeight)];
        }
        else{
            [imageViewBac setFrame:CGRectMake(0, m_table.frame.origin.y + m_table.frame.size.height, APPHEIGHT, 50.)];
            [imageViewLine1 setFrame:CGRectMake(APPHEIGHT/3.0 - 1., 0, 2., buttonHeight)];
            [imageViewLine2 setFrame:CGRectMake(APPHEIGHT * 2.0/3.0 - 1., 0, 2., buttonHeight)];
            [deleteButton setFrame:CGRectMake(0., 0, APPHEIGHT/3.0, buttonHeight)];
            [buttonStartAll setFrame:CGRectMake(APPHEIGHT/3.0, 0, APPHEIGHT/3.0, buttonHeight)];
            [buttonStopAll setFrame:CGRectMake(APPHEIGHT*2.0/3.0, 0, APPHEIGHT/3.0, buttonHeight)];
            [buttonDeleteAll setFrame:CGRectMake(APPHEIGHT/2.0-60., 0, 120., buttonHeight)];
            [buttonDeleteSelected setFrame:CGRectMake(APPHEIGHT-120., 0, 120., buttonHeight)];
        }
        
	}
    
    [deleteButton setImageEdgeInsets:UIEdgeInsetsMake(10., deleteButton.frame.size.width/2.0-18.-20., 10., deleteButton.frame.size.width/2.0 + 20.)];
    [buttonStartAll setImageEdgeInsets:UIEdgeInsetsMake(11., buttonStartAll.frame.size.width/2.0-18.-30., 11., buttonStartAll.frame.size.width/2.0 + 30.)];
    [buttonStopAll setImageEdgeInsets:UIEdgeInsetsMake(12., buttonStopAll.frame.size.width/2.0-18.-30., 12., buttonStopAll.frame.size.width/2.0 + 30.)];
    
    [self setButtonHidden];
	[m_table reloadData];
}


- (void)delayBackToNavi
{
    [TaskManager taskManager].delegate = nil;
    [QLoadingView hideWithAnimated:NO];
    GDAlertView *alertView = [[GDAlertView alloc] initWithTitle:nil andMessage:STR(@"CityDownloadManage_completeBackToNavi",Localize_CityDownloadManage)];
    
    [alertView addButtonWithTitle:STR(@"Universal_ok", Localize_Universal) type:GDAlertViewButtonTypeDefault handler:^(GDAlertView *alertView){
        [[NSNotificationCenter defaultCenter] postNotificationName:kStartDataVerify object:nil];
    }];
    [alertView show];
    [alertView release];
    
}


- (void)baseDataUnzipFinishbackToNavi
{
    [QLoadingView hideWithAnimated:NO];
    [[NSNotificationCenter defaultCenter] postNotificationName:kStartDataVerify object:nil];
   
}

#pragma mark- 按钮响应
- (void)buttonInit
{
    m_table = [[UITableView alloc] initWithFrame:CGRectMake(0, 10, self.view.bounds.size.width, self.view.bounds.size.height-60.0) style:UITableViewStylePlain];
	m_table.delegate = self;
	m_table.dataSource = self;
	[self.view addSubview:m_table];
    m_table.backgroundColor = [UIColor clearColor];
    if ([UITableView instancesRespondToSelector:@selector(backgroundView)])
    {
        m_table.backgroundView = nil;
    }
    m_table.separatorStyle = UITableViewCellSeparatorStyleNone;
    m_table.separatorColor = [UIColor clearColor];
    m_table.allowsSelectionDuringEditing = YES;
    [m_table release];
    
    //底部按钮初始化
    UIImage *image = [IMAGE(@"DataDownloadBac.png", IMAGEPATH_TYPE_1) stretchableImageWithLeftCapWidth:0 topCapHeight:10];
    imageViewBac = [ControlCreat createImageViewWithFrame:CGRectMake(0., APPHEIGHT-134., APPWIDTH, 50) normalImage:image tag:0];
    imageViewBac.userInteractionEnabled = YES;
    [self.view addSubview:imageViewBac];
    
    imageViewLine1 = [ControlCreat createImageViewWithFrame:CGRectMake(APPWIDTH/3.0 - 1., APPHEIGHT - 131., 2., 41.) normalImage:IMAGE(@"DataDownloadLine.png", IMAGEPATH_TYPE_1) tag:1];
    [imageViewBac addSubview:imageViewLine1];
    
    imageViewLine2 = [ControlCreat createImageViewWithFrame:CGRectMake(APPWIDTH * 2.0/3.0 - 1., APPHEIGHT - 131., 2., 41.) normalImage:IMAGE(@"DataDownloadLine.png", IMAGEPATH_TYPE_1) tag:2];
    [imageViewBac addSubview:imageViewLine2];
    
    deleteButton = [ControlCreat createButtonWithTitle:STR(@"Universal_delete", Localize_Universal) normalImage:nil heightedImage:nil tag:0 withImageType:IMAGEPATH_TYPE_1];
    [deleteButton addTarget:self action:@selector(deleteButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [deleteButton setTitleColor:DATADOWNLOADBUTTONTEXTCOLOR forState:UIControlStateNormal];
    [deleteButton setTitleColor:DATADOWNLOADBUTTONALLCLICKTEXTGRAYCOLOR forState:UIControlStateDisabled];
    [deleteButton setFrame:CGRectMake(0., APPHEIGHT-130., APPWIDTH/3.0, 40.)];
    [deleteButton setImage:IMAGE(@"DataDownloadDelete.png", IMAGEPATH_TYPE_1) forState:UIControlStateNormal];
    [deleteButton setImage:IMAGE(@"DataDownloadDelete1.png", IMAGEPATH_TYPE_1) forState:UIControlStateDisabled];
    [deleteButton setImageEdgeInsets:UIEdgeInsetsMake(10., deleteButton.frame.size.width/2.0-18.-20., 10., deleteButton.frame.size.width/2.0 + 20.)];
    [deleteButton.titleLabel setFont:[UIFont systemFontOfSize:16.]];
    [deleteButton setBackgroundColor:[UIColor clearColor]];
    [imageViewBac addSubview:deleteButton];
    
    buttonStartAll = [ControlCreat createButtonWithTitle:STR(@"CityDownloadManage_startAll", Localize_CityDownloadManage) normalImage:nil heightedImage:nil tag:0 withImageType:IMAGEPATH_TYPE_1];
    [buttonStartAll addTarget:self action:@selector(startAllAction) forControlEvents:UIControlEventTouchUpInside];
    [buttonStartAll setTitleColor:DATADOWNLOADBUTTONTEXTCOLOR forState:UIControlStateNormal];
    [buttonStartAll setTitleColor:DATADOWNLOADBUTTONALLCLICKTEXTGRAYCOLOR forState:UIControlStateDisabled];
    [buttonStartAll setFrame:CGRectMake(APPWIDTH/3.0, APPHEIGHT-130., APPWIDTH/3.0, 40.)];
    [buttonStartAll setImage:IMAGE(@"DataDownloadAll.png", IMAGEPATH_TYPE_1) forState:UIControlStateNormal];
    [buttonStartAll setImage:IMAGE(@"DataDownloadAll1.png", IMAGEPATH_TYPE_1) forState:UIControlStateDisabled];
    [buttonStartAll setImageEdgeInsets:UIEdgeInsetsMake(11., buttonStartAll.frame.size.width/2.0-18.-30., 11., buttonStartAll.frame.size.width/2.0 + 30.)];
    [buttonStartAll.titleLabel setFont:[UIFont systemFontOfSize:16.]];
    [imageViewBac addSubview:buttonStartAll];
    
    buttonStopAll = [ControlCreat createButtonWithTitle:STR(@"CityDownloadManage_stopAll", Localize_CityDownloadManage) normalImage:nil heightedImage:nil tag:0 withImageType:IMAGEPATH_TYPE_1];
    [buttonStopAll addTarget:self action:@selector(stopAllAction) forControlEvents:UIControlEventTouchUpInside];
    [buttonStopAll setTitleColor:DATADOWNLOADBUTTONTEXTCOLOR forState:UIControlStateNormal];
    [buttonStopAll setTitleColor:DATADOWNLOADBUTTONALLCLICKTEXTGRAYCOLOR forState:UIControlStateDisabled];
    [buttonStopAll setFrame:CGRectMake(APPWIDTH*2.0/3.0, APPHEIGHT-130., APPWIDTH/3.0, 40.)];
    [buttonStopAll setImage:IMAGE(@"DownloadStop1.png", IMAGEPATH_TYPE_1) forState:UIControlStateNormal];
    [buttonStopAll setImage:IMAGE(@"DataDownloadPause1.png", IMAGEPATH_TYPE_1) forState:UIControlStateDisabled];
    [buttonStopAll setImageEdgeInsets:UIEdgeInsetsMake(12., buttonStopAll.frame.size.width/2.0-18.-30., 12., buttonStopAll.frame.size.width/2.0 + 30.)];
    [buttonStopAll.titleLabel setFont:[UIFont systemFontOfSize:16.]];
    [imageViewBac addSubview:buttonStopAll];
    
    buttonDeleteAll = [ControlCreat createButtonWithTitle:STR(@"CityDownloadManage_All", Localize_CityDownloadManage) normalImage:nil heightedImage:nil tag:0 withImageType:IMAGEPATH_TYPE_1];
    [buttonDeleteAll addTarget:self action:@selector(deleteAllAction) forControlEvents:UIControlEventTouchUpInside];
    [buttonDeleteAll setTitleColor:DATADOWNLOADBUTTONALLCLICKTEXTCOLOR forState:UIControlStateNormal];
    [buttonDeleteAll setTitleColor:DATADOWNLOADBUTTONTEXTCOLOR forState:UIControlStateDisabled];
    [buttonDeleteAll setFrame:CGRectMake(APPWIDTH/2.0-60., APPHEIGHT-130., 120., 40.)];
    [buttonDeleteAll.titleLabel setFont:[UIFont systemFontOfSize:16.]];
    [imageViewBac addSubview:buttonDeleteAll];
    buttonDeleteAll.hidden = YES;
    
    buttonDeleteSelected = [ControlCreat createButtonWithTitle:nil normalImage:nil heightedImage:nil tag:0 withImageType:IMAGEPATH_TYPE_1];
    [buttonDeleteSelected addTarget:self action:@selector(deleteSeleteAction) forControlEvents:UIControlEventTouchUpInside];
    [buttonDeleteSelected setFrame:CGRectMake(APPWIDTH-120., APPHEIGHT-130., 120., 40.)];
    [buttonDeleteSelected setImage:IMAGE(@"DataDownloadDelete.png", IMAGEPATH_TYPE_1) forState:UIControlStateNormal];
    [buttonDeleteSelected setImage:IMAGE(@"DataDownloadDelete1.png", IMAGEPATH_TYPE_1) forState:UIControlStateDisabled];
    [buttonDeleteSelected setImageEdgeInsets:UIEdgeInsetsMake(10., 58.0, 10., 30.)];
    [imageViewBac addSubview:buttonDeleteSelected];
    buttonDeleteSelected.hidden = YES;
}

- (void)deleteButtonAction
{
    
    [m_table setEditing:!m_table.editing animated:YES];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [m_table reloadData];
    });
    
    if (m_table.editing) {
        
        [[TaskManager taskManager] stopAllTask];
        
        buttonDeleteSelected.hidden = NO;
        buttonDeleteAll.hidden = NO;
        deleteButton.hidden = YES;
        buttonStartAll.hidden = YES;
        buttonStopAll.hidden = YES;
        imageViewLine1.hidden = YES;
        imageViewLine2.hidden = YES;
        if ([[TaskManager taskManager] isSelectedTask]) {
            buttonDeleteSelected.enabled = YES;
        }
        else{
            buttonDeleteSelected.enabled = NO;
        }
        if ([[TaskManager taskManager] isAllSelected]) {
            buttonDeleteAll.enabled = NO;
        }
        else{
            buttonDeleteAll.enabled = YES;
        }
        
        if (managerController) {
            ((UIViewController *)managerController).navigationItem.leftBarButtonItem = [[[VCTranslucentBarButtonItem alloc] initWithType:VCTranslucentBarButtonItemTypeLeftCancel title:STR(@"Universal_cancel", Localize_Universal) target:self action:@selector(Back:)] autorelease];
            
            [managerController setRightBarButtonHidden:YES];
            
             [((DMDataDownloadManagerViewController *)managerController).pagesContainer setButtonEnable:NO];
            
        }
        
    }
    else{
        
        [((DMDataDownloadManagerViewController *)managerController).pagesContainer setButtonEnable:YES];
        
        [[TaskManager taskManager] selectAllTask:NO];
        
        buttonDeleteAll.hidden = YES;
        buttonDeleteSelected.hidden = YES;
        
        deleteButton.hidden = NO;
        buttonStartAll.hidden = NO;
        buttonStopAll.hidden = NO;
        imageViewLine1.hidden = NO;
        imageViewLine2.hidden = NO;
        
        [self setButtonHidden];
        if (managerController) {
            ((UIViewController *)managerController).navigationItem.leftBarButtonItem= [[[VCTranslucentBarButtonItem alloc] initWithType:VCTranslucentBarButtonItemTypeBackward title:nil target:self action:@selector(Back:)] autorelease];
            
            if (isWholeMap != 0) {
                [managerController setRightBarButtonHidden:NO];
                if([[TaskManager taskManager]checkUpdate])
                {
                    ((UIViewController *)managerController).navigationItem.rightBarButtonItem.enabled = YES;
                }
                else{
                    ((UIViewController *)managerController).navigationItem.rightBarButtonItem.enabled = NO;
                }
            }
            
        }
        
    }
    
}

//开始所有任务
- (void)startAllAction
{
    long long disksize = [UIDevice getCurDiskSpaceInBytes];
    
    long long total;//总大小
	long long maxzipsize;//最大压缩包的大小
    total = 0;
    maxzipsize = 0;
    int count = [[TaskManager taskManager].taskList count];
    for (int i=0;i<count;i++)
    {
        DownloadTask *t = [[TaskManager taskManager].taskList caObjectsAtIndex:i];
        if(t.status != TASK_STATUS_FINISH)
        {
            if(t.total == t.all_size)
            {
                total += t.all_unzipsize-t.current;
                if(maxzipsize < t.all_size)
                {
                    maxzipsize = t.all_size;
                }
            }
            else
            {
                total += t.add_unzipsize-t.current;
                if(maxzipsize < t.add_size)
                {
                    maxzipsize = t.add_size;
                }
                
            }
        }
        
    }
    total += maxzipsize;
    
    if(disksize < total)
    {
        
        float freesize = (float)(total - disksize)/1024/1024/1024;
        float disksizeUintG = disksize/1024/1024/1024.0;
        float totalUintG = total/1024/1024/1024.0;
        if(disksizeUintG < 0.1)
        {
            disksizeUintG = 0.1;
        }
        if(totalUintG <0.1)
        {
            totalUintG = 0.1;
        }
        
        NSString *strTitle;
        strTitle = [NSString stringWithFormat:STR(@"CityDownloadManage_noFreeSize", Localize_CityDownloadManage),disksizeUintG,totalUintG,freesize];
        
        GDAlertView *alertView = [[GDAlertView alloc] initWithTitle:nil andMessage:strTitle];
        
        [alertView addButtonWithTitle:STR(@"Universal_ok", Localize_Universal) type:GDAlertViewButtonTypeDefault handler:^(GDAlertView *alertView){
            [[TaskManager taskManager]stopAllTask];
            [m_table reloadData];
        }];
        [alertView show];
        [alertView release];
        
        
    }
    else {
        int netType = NetWorkType;
        if (netType == 2) {
            
            [[TaskManager taskManager] startAllTask];
        }
        else if(netType == 1 && netType != 2){
            
            NSString * strTitle;
            long long  totalsize =0;
            
            for(DownloadTask *task in [TaskManager taskManager].taskList)
            {
                if(task.status!=TASK_STATUS_FINISH)
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
            else if(1024*103 <= totalsize && totalsize< 1024*1024*1024)
            {
                Unit = @"MB";
                size = totalsize*1.0/1024/1024;
            }
            else {
                Unit = @"MB";
                size = 0.1;
            }
            
            strTitle = [NSString stringWithFormat:STR(@"CityDownloadManage_startDownloadAlert", Localize_CityDownloadManage),size,Unit];
            
            GDAlertView *alertView = [[GDAlertView alloc] initWithTitle:nil andMessage:strTitle];
            [alertView addButtonWithTitle:STR(@"Universal_no", Localize_Universal) type:GDAlertViewButtonTypeCancel handler:nil];
            [alertView addButtonWithTitle:STR(@"Universal_yes", Localize_Universal) type:GDAlertViewButtonTypeDefault handler:^(GDAlertView *alertView){
                
                [[TaskManager taskManager] startAllTask];
                [m_table reloadData];
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_HandleUIUpdate object:[NSNumber numberWithInt:UIUpdate_MapDataDownloadFinish] userInfo:nil];
            }];
            [alertView show];
            [alertView release];
            
        }
        else {
            GDAlertView *alertView = [[GDAlertView alloc] initWithTitle:nil andMessage:STR(@"Universal_withoutNetwork",Localize_Universal)] ;
            
            [alertView addButtonWithTitle:STR(@"Universal_ok", Localize_Universal) type:GDAlertViewButtonTypeDefault handler:nil];
            [alertView show];
            [alertView release];
        }
        
        
        
    }
    
    
    [self setButtonHidden];
    [m_table reloadData];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_HandleUIUpdate object:[NSNumber numberWithInt:UIUpdate_MapDataDownloadFinish] userInfo:nil];
}

//暂停所有任务
- (void)stopAllAction
{
    [[TaskManager taskManager] stopAllTask];
    [self setButtonHidden];
    [m_table reloadData];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_HandleUIUpdate object:[NSNumber numberWithInt:UIUpdate_MapDataDownloadFinish] userInfo:nil];
}

//删除所有任务
-(void)deleteAllAction
{
    [[TaskManager taskManager] selectAllTask:YES];
    
    if ([[TaskManager taskManager] isSelectedTask]) {
        buttonDeleteSelected.enabled = YES;
    }
    else{
        buttonDeleteSelected.enabled = NO;
    }
    
    
    buttonDeleteAll.enabled = NO;
    
    [m_table reloadData];
    if(managerController)
    {
        BOOL isupdate = [[TaskManager taskManager] checkUpdate];
        ((DMDataDownloadManagerViewController*)managerController).navigationItem.rightBarButtonItem.enabled = isupdate;
        
    }
}

//删除选择的任务
- (void)deleteSeleteAction
{
    if ([[TaskManager taskManager] isAllSelected]) {
        
        __block CityDataManagerFirstViewController *weakSelf = self;
        
        GDAlertView *alertView = [[GDAlertView alloc] initWithTitle:nil andMessage:STR(@"CityDownloadManage_sureDeleteData",Localize_CityDownloadManage)];
        [alertView addButtonWithTitle:STR(@"Universal_cancel", Localize_Universal) type:GDAlertViewButtonTypeCancel handler:nil];
        [alertView addButtonWithTitle:STR(@"Universal_ok", Localize_Universal) type:GDAlertViewButtonTypeDefault handler:^(GDAlertView *alertView){
            
            [[TaskManager taskManager] removeAllTask];
            
            [weakSelf deleteButtonAction];
            
            if (managerController) {
                [((DMDataDownloadManagerViewController *)managerController).pagesContainer setButtonEnable:NO];
            }
            
            ((UIViewController *)managerController).navigationItem.leftBarButtonItem.enabled = NO;
            ((UIViewController *)managerController).navigationItem.rightBarButtonItem.enabled = NO;
            isWholeMap = 0;
            [m_table reloadData];
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_HandleUIUpdate object:[NSNumber numberWithInt:UIUpdate_MapDataDownloadFinish] userInfo:nil];
            
        }];
        [alertView show];
        [alertView release];
    }
    else{
        [QLoadingView showDefaultLoadingView:@"删除中"];
        [[TaskManager taskManager] removeSelectedTask];
        [[TaskManager taskManager] store];
        
        [self deleteButtonAction];
        [QLoadingView hideWithAnimated:YES];
        [m_table reloadData];
    }
    
    if ([[TaskManager taskManager] isSelectedTask]) {
        
        buttonDeleteSelected.enabled = YES;
    }
    else{
        
        buttonDeleteSelected.enabled = NO;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_HandleUIUpdate object:[NSNumber numberWithInt:UIUpdate_MapDataDownloadFinish] userInfo:nil];
    
}

//设置按钮显示隐藏
- (void)setButtonHidden
{
    if ([TaskManager taskManager].taskList.count == 0) {
        deleteButton.enabled = NO;
        buttonStartAll.enabled = NO;
        buttonStopAll.enabled = NO;
    }
    else{
        deleteButton.enabled = YES;
    }
    
    if ([[TaskManager taskManager] isAllRunning]) {
        buttonStartAll.enabled = NO;
    }
    else{
        buttonStartAll.enabled = YES;
    }
    
    if ([[TaskManager taskManager] isAllStop]) {
        
        buttonStopAll.enabled = NO;
    }
    else{
        
        buttonStopAll.enabled = YES;
    }
    
    
}

#pragma mark -
#pragma mark - 下载数据委托回调－delegate
//数据下载完成委托回调
-(void)finished:(Task*)sender
{
//    [self setButtonHidden];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_HandleUIUpdate object:[NSNumber numberWithInt:UIUpdate_MapDataDownloadFinish] userInfo:nil];
	[m_table reloadData];
    
    if (isWholeMap == 0)
    {
        TaskManager *taskmanager = [TaskManager taskManager];
        int finishNum = 0;
        for (Task *tmp in taskmanager.taskList) {
            
            if (tmp.status == TASK_STATUS_FINISH) {
                finishNum ++;
            }
        }
        if (finishNum == [taskmanager.taskList count])
        {
            [QLoadingView showDefaultLoadingView:STR(@"CityDownloadManage_unZip", Localize_CityDownloadManage)];
        }
    }
    
}
//数据下载中委托回调刷新列表
-(void)progress:(Task*)sender current:(long long)current total:(long long)total
{
    static int num = 0;
    
	num ++;
    if(num==30 || current == total)
    {
        if (removeFlag == NO) {
            [m_table reloadData];
            num=0;
		}

    }
	
}
-(void)exception:(Task*)sender exception:(id)exception
{
    [m_table reloadData];
    
	if (((NSError *)exception).code == DOWNLOADHANDLETYPE_NOSPACE)
	{
        
		GDAlertView *alertView = [[GDAlertView alloc] initWithTitle:nil andMessage:STR(@"CityDownloadManage_insufficientDiskSpace",Localize_CityDownloadManage)];
        
        [alertView addButtonWithTitle:STR(@"Universal_ok", Localize_Universal) type:GDAlertViewButtonTypeDefault handler:nil];
        [alertView show];
        [alertView release];
        
	}
    else if(((NSError *)exception).code == DOWNLOADHANDLETYPE_CURRENTLAGERTOTAL ){
		GDAlertView *alertView = [[GDAlertView alloc] initWithTitle:nil andMessage:STR(@"CityDownloadManage_actualLargerServer",Localize_CityDownloadManage)];
        
        [alertView addButtonWithTitle:STR(@"Universal_ok", Localize_Universal) type:GDAlertViewButtonTypeDefault handler:nil];
        [alertView show];
        [alertView release];
        
	}
	else if(((NSError *)exception).code == DOWNLOADHANDLETYPE_UPZIPFAIL){
		GDAlertView *alertView = [[GDAlertView alloc] initWithTitle:nil andMessage:STR(@"CityDownloadManage_dataDownloadError",Localize_CityDownloadManage)];
        
        [alertView addButtonWithTitle:STR(@"Universal_ok", Localize_Universal) type:GDAlertViewButtonTypeDefault handler:nil];
        [alertView show];
        [alertView release];
        [QLoadingView hideWithAnimated:NO];
	}
    else if(((NSError *)exception).code == DOWNLOADHANDLETYPE_CURRENTSMALLTOTAL){
		GDAlertView *alertView = [[GDAlertView alloc] initWithTitle:nil andMessage:STR(@"CityDownloadManage_actualSmallServer",Localize_CityDownloadManage)];
        
        [alertView addButtonWithTitle:STR(@"Universal_ok", Localize_Universal) type:GDAlertViewButtonTypeDefault handler:nil];
        [alertView show];
        [alertView release];
	}
    else if (((NSError *)exception).code == DOWNLOADHANDLETYPE_URLERROR)
    {
        GDAlertView *alertView = [[GDAlertView alloc] initWithTitle:@"Cannot Open the Request!" andMessage:STR(@"CityDownloadManage_urlEmpty",Localize_CityDownloadManage)] ;
        
        [alertView addButtonWithTitle:STR(@"Universal_ok", Localize_Universal) type:GDAlertViewButtonTypeCancel handler:nil];
        [alertView show];
        [alertView release];
        [QLoadingView hideWithAnimated:NO];
    }
    else if (((NSError *)exception).code == DOWNLOADHANDLETYPE_MD5NOMATCH)
    {
        [QLoadingView hideWithAnimated:NO];
    }
	else
	{
        
        int index = [[TaskManager taskManager] _indexWithTaskID:(Task *)sender.taskId];
        
        int netType = NetWorkType;
        if (netType == 2) {
            [[TaskManager taskManager] start:index];
        }
        else if(netType == 1){
            
            Task *tmp = [[TaskManager taskManager].taskList caObjectsAtIndex:index];
            NSString * strTitle;
            long long totalsize =0;
            if(tmp.status==TASK_STATUS_BLOCK)
            {
                totalsize += tmp.total - tmp.current;
            }
            for(DownloadTask *task in [TaskManager taskManager].taskList)
            {
                if(task.status==TASK_STATUS_READY  || task.status == TASK_STATUS_RUNNING)
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
            else if(1024*103 <= totalsize && totalsize< 1024*1024*1024)
            {
                Unit = @"MB";
                size = totalsize*1.0/1024/1024;
            }
            else {
                Unit = @"MB";
                size = 0.1;
            }
            
            strTitle = [NSString stringWithFormat:STR(@"CityDownloadManage_startDownloadAlert", Localize_CityDownloadManage),size,Unit];
            
            GDAlertView *alertView = [[GDAlertView alloc] initWithTitle:nil andMessage:strTitle] ;
            [alertView addButtonWithTitle:STR(@"Universal_no", Localize_Universal) type:GDAlertViewButtonTypeCancel handler:^(GDAlertView *alertView){
                [[TaskManager taskManager] stopAllTask];
                [m_table reloadData];
            }];
            [alertView addButtonWithTitle:STR(@"Universal_yes", Localize_Universal) type:GDAlertViewButtonTypeDefault handler:^(GDAlertView *alertView){
                TaskManager *taskmanager = [TaskManager taskManager];
				[taskmanager start:index];
				[m_table reloadData];
            }];
            [alertView show];
            [alertView release];
            
        }
        else {
            GDAlertView *alertView = [[GDAlertView alloc] initWithTitle:nil andMessage:STR(@"Universal_withoutNetwork",Localize_Universal)] ;
            
            [alertView addButtonWithTitle:STR(@"Universal_ok", Localize_Universal) type:GDAlertViewButtonTypeDefault handler:nil];
            [alertView show];
            [alertView release];
		}
        
        [self setButtonHidden];
        [m_table reloadData];

	}

    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_HandleUIUpdate object:[NSNumber numberWithInt:UIUpdate_MapDataDownloadFinish] userInfo:nil];
	
}
//数据解压完成回调
- (void)unZipFinish:(Task*)sender
{
    
    if (isWholeMap == 0)
    {
        if (sender.taskId == 0) {
            
            ((UIViewController *)managerController).navigationItem.leftBarButtonItem.enabled = YES;
            isBaseDataUnzipFinish = YES;
            if (isBaseUnzipQloadingFlag) {
                [self performSelectorOnMainThread:@selector(baseDataUnzipFinishbackToNavi) withObject:nil waitUntilDone:NO];
            }
        }
        TaskManager *taskmanager = [TaskManager taskManager];
        int unZipNum = 0;
        
        for (Task *tmp in taskmanager.taskList) {
            if (tmp.status == TASK_STATUS_FINISH) {
                unZipNum ++;
            }
        }
        
        if (unZipNum == [taskmanager.taskList count] && [GDBL_DataVerify checkBaseRoadDataExist])
        {
            
            [self performSelectorOnMainThread:@selector(delayBackToNavi) withObject:nil waitUntilDone:NO];
            
        }
    }

}
#pragma mark -
#pragma mark - nsnotification消息回调

//清空下载列表并保存
-(void)removeAllTask
{
	
	TaskManager *taskmanager = [TaskManager taskManager];
	[taskmanager removeAllTask];
	
	[[TaskManager taskManager] store];
	[m_table reloadData];
    
    ((UIViewController *)managerController).navigationItem.leftBarButtonItem.enabled = NO;
    ((UIViewController *)managerController).navigationItem.rightBarButtonItem.enabled = NO;
    
    isWholeMap = 0;
}

//将从城市数据下载选择中返回要下载的城市数组并加入到下载列表中
-(void)setupCityItems:(NSNotification*)items
{
    if([items object] == nil)
    {
        isBackFromCitySeltct = YES;
	
        [[TaskManager taskManager] store];
        
        [NSThread detachNewThreadSelector:@selector(start_download) toTarget:self
                               withObject:nil];
        
        if (managerController) {
            ((UIViewController *)managerController).navigationItem.leftBarButtonItem.enabled = YES;
        }
        
        [m_table reloadData];
    }
    
    //items=1的时候需要检查网络
    else if([[items object]intValue] == 1)
    {
        //已经开始下载，不要检查网络
        if([[TaskManager taskManager]isRunning])
        {
            [[TaskManager taskManager] store];
            if(managerController)
            {
                BOOL isupdate = [[TaskManager taskManager] checkUpdate];
                ((DMDataDownloadManagerViewController*)managerController).navigationItem.rightBarButtonItem.enabled = isupdate;
                ((UIViewController *)managerController).navigationItem.leftBarButtonItem.enabled = YES;
                
            }
            [m_table reloadData];
            return;
        }
        
        //都没有正在下载的，检查网络
        int netType = NetWorkType;
        if(netType == 2)//wifi
        {
            isBackFromCitySeltct = YES;
            
            [[TaskManager taskManager] store];
            
            [NSThread detachNewThreadSelector:@selector(start_download) toTarget:self withObject:nil];
            if (managerController && [managerController isKindOfClass:[DMDataDownloadManagerViewController class]])
            {
                ((UIViewController *)managerController).navigationItem.leftBarButtonItem.enabled = YES;
            }
            
           
            [m_table reloadData];
        }
        
        else if(netType == 1){//3G
            
            NSString * strTitle;
            
            long long totalsize =0;
            
            for(DownloadTask *task in [TaskManager taskManager].taskList)
            {
                if(task.status==TASK_STATUS_READY  || task.status == TASK_STATUS_RUNNING)
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
            else if(1024*103 <= totalsize && totalsize< 1024*1024*1024)
            {
                Unit = @"MB";
                size = totalsize*1.0/1024/1024;
            }
            else {
                Unit = @"MB";
                size = 0.1;
            }
            
            strTitle = [NSString stringWithFormat:STR(@"CityDownloadManage_startDownloadAlert", Localize_CityDownloadManage),size,Unit];
            
            GDAlertView *alertView = [[GDAlertView alloc] initWithTitle:nil andMessage:strTitle];
            [alertView addButtonWithTitle:STR(@"Universal_no", Localize_Universal) type:GDAlertViewButtonTypeCancel handler:^(GDAlertView *alertView){
                NSLog(@"cancel download");
                [m_table reloadData];
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_HandleUIUpdate object:[NSNumber numberWithInt:UIUpdate_MapDataDownloadFinish] userInfo:nil];
                
            }];
            [alertView addButtonWithTitle:STR(@"Universal_yes", Localize_Universal) type:GDAlertViewButtonTypeDefault handler:^(GDAlertView *alertView){
                isBackFromCitySeltct = YES;
                
                [[TaskManager taskManager] store];
                
                [NSThread detachNewThreadSelector:@selector(start_download) toTarget:self
                                       withObject:nil];
                
                if (managerController) {
                    ((UIViewController *)managerController).navigationItem.leftBarButtonItem.enabled = YES;
                }
              [m_table reloadData];
                
            }];
            [alertView show];
            [alertView release];
            
            
        }
        else if(netType == 0){//无网络
            GDAlertView *alertView = [[GDAlertView alloc] initWithTitle:nil andMessage:STR(@"Universal_withoutNetwork",Localize_Universal)];
            
            [alertView addButtonWithTitle:STR(@"Universal_ok", Localize_Universal) type:GDAlertViewButtonTypeDefault handler:nil];
            [alertView show];
            [alertView release];
            
            [[TaskManager taskManager]stopAllTask];
            [m_table reloadData];
            
        }
        if(managerController)
        {
            BOOL isupdate = [[TaskManager taskManager] checkUpdate];
            ((DMDataDownloadManagerViewController*)managerController).navigationItem.rightBarButtonItem.enabled = isupdate;
            
        }
        
    }
    
 
}


- (void)handleUIUpdate:(NSNotification *)result
{
    switch ([[result object] intValue]) {
        case UIUpdate_MapDataDownloadUpdate:
        {
            if (m_table) {
                [m_table reloadData];
            }
            if(managerController && ([managerController isKindOfClass:[DMDataDownloadManagerViewController class]]))
            {
                BOOL isupdate = [[TaskManager taskManager] checkUpdate];
                ((DMDataDownloadManagerViewController*)managerController).navigationItem.rightBarButtonItem.enabled = isupdate;
                
            }

            
        }
            break;
        
        default:
            break;
    }
    
}
#pragma mark -
#pragma mark - UI action
//多线程下载
-(void)start_download
{
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	
	[self performSelectorOnMainThread:@selector(start_index_download) 
							   withObject:nil waitUntilDone:NO];
	
	
	[pool release];
}
//开始下载
-(void)start_index_download
{
	
	TaskManager *taskmanager = [TaskManager taskManager];
	[taskmanager start];
	[m_table reloadData];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_HandleUIUpdate object:[NSNumber numberWithInt:UIUpdate_MapDataDownloadFinish] userInfo:nil];
	
}

-(void)Back:(id)sender
{
    if (m_table.editing) {
        
        [self deleteButtonAction];
        
        return;
    }
    if(![GDBL_DataVerify checkBaseRoadDataExist])
    {
        [self MyAlertWithType:0];
        return;
    }
    
    BOOL isforce = [[MWCityDownloadMapDataList citydownloadMapDataList]GetBasicResourceStatus];//检查基础资源是否为强制更新
    Task *basictask = [[TaskManager taskManager]getTaskWithTaskID:0];
    if(isforce && basictask.status != TASK_STATUS_FINISH)
    {//强制更新且基础资源不是完成状态
        [self MyAlertWithType:0];
        return;
    }
    
    if (isWholeMap == 0) {//基础路网数据未下载完成，或者未解压完处理
        
        if ([[TaskManager taskManager].taskList count] > 0) {
            
            for (Task *tmp in [TaskManager taskManager].taskList) {
                if (tmp.taskId == 0 ) {
                    if (tmp.status != TASK_STATUS_FINISH ) {
                        
                        [self MyAlertWithType:0];
                        return;
                    }
                    else if(!isBaseDataUnzipFinish){
                        isBaseUnzipQloadingFlag = YES;
                        [self MyAlertWithType:1];
                        return;
                    }
                    else{
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:kStartDataVerify object:nil];
                        
                        return;
                    }
                }
                
            }
        }
        
    }
	if (isRemove) {
        
        GDAlertView *alertView = [[GDAlertView alloc] initWithTitle:nil andMessage:STR(@"CityDownloadManage_deleteDataRestart",Localize_CityDownloadManage)];
        
        [alertView addButtonWithTitle:STR(@"Universal_ok", Localize_Universal) type:GDAlertViewButtonTypeDefault handler:nil];
        [alertView show];
        [alertView release];
        
	}
	else {
        
		if (managerController) {
            if (isEngineInit != 1) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kStartDataVerify object:nil];
            }
            else{
                [((UIViewController *)managerController).navigationController popViewControllerAnimated:YES];
            }
            
        }
		
	}
}
- (NSString *)alert_DownLoad_NOWIFI
{
    NSString * strTitle;
    long long  totalsize =0;
    
    for(DownloadTask *task in [TaskManager taskManager].taskList)
    {
        if(task.status==TASK_STATUS_READY  || task.status == TASK_STATUS_RUNNING)
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
    
    return strTitle;
    
}

- (void)MyAlertWithType:(int)type
{
    switch (type) {
        case 0:
        {
            GDAlertView *alertView = [[GDAlertView alloc] initWithTitle:nil andMessage:STR(@"CityDownloadManage_unCompleteBaseDataDown",Localize_CityDownloadManage)];
            [alertView addButtonWithTitle:STR(@"Universal_ok", Localize_Universal) type:GDAlertViewButtonTypeDefault handler:nil];
            [alertView show];
            [alertView release];
        }
            break;
        case 1:
        {
           
            [QLoadingView showDefaultLoadingView:STR(@"CityDownloadManage_unZipBasicData",Localize_CityDownloadManage)];
            
            
        }
            break;
        case 2:
        {
            GDAlertView *alertView = [[GDAlertView alloc] initWithTitle:nil andMessage:STR(@"CityDownloadManage_unCompleteNationalData",Localize_CityDownloadManage)];
            [alertView addButtonWithTitle:STR(@"Universal_ok", Localize_Universal) type:GDAlertViewButtonTypeDefault handler:nil];
            [alertView show];
            [alertView release];
            
        }
            break;
        case 3:
        {
            
        }
            break;
        default:
            break;
    }
}

- (void)startTaskAlert:(int)taskID
{
    removeFlag = NO;
	
	TaskManager *taskmanager = [TaskManager taskManager];
	Task* t = [taskmanager getTaskWithTaskID:taskID];
    t.delegate = taskmanager;
	//如果正在运行则暂停任务，如果处于等待则判断存储空间是否足够、是否有wifi网络，若足够且是wifi网络则下载数据，否则弹出相应的提示信息
	if (t.status == TASK_STATUS_RUNNING) {
		[taskmanager stop];
	}
    
	else if(t.status == TASK_STATUS_BLOCK || t.status == TASK_STATUS_READY) {
		
		long long totalsize = [taskmanager getNeedSize:nil] + t.total - t.current;
		long long disksize = [UIDevice getCurDiskSpaceInBytes];
		
		if(disksize < totalsize)
		{
			
			float freesize = (float)(totalsize - disksize)/1024/1024/1024;
            float disksizeUintG = disksize/1024/1024/1024.0;
            float totalUintG = totalsize/1024/1024/1024.0;
            if(disksizeUintG < 0.1)
            {
                disksizeUintG = 0.1;
            }
            if(totalUintG <0.1)
            {
                totalUintG = 0.1;
            }
            
            NSString *strTitle;
            strTitle = [NSString stringWithFormat:STR(@"CityDownloadManage_noFreeSize", Localize_CityDownloadManage),disksizeUintG,totalUintG,freesize];
            
            GDAlertView *alertView = [[GDAlertView alloc] initWithTitle:nil andMessage:strTitle];
            
            [alertView addButtonWithTitle:STR(@"Universal_ok", Localize_Universal) type:GDAlertViewButtonTypeDefault handler:^(GDAlertView *alertView){
                [[TaskManager taskManager]stopAllTask];
                [m_table reloadData];
            }];
            [alertView show];
			[alertView release];
			
		}
		else {
			int netType = NetWorkType;
			if (netType == 2) {
				[taskmanager startWithTaskID:taskID];
			}
			else if(netType == 1){
                    
                    NSString * strTitle;
                    
                    long long totalsize = 0;

                    for(DownloadTask *task in [TaskManager taskManager].taskList)
                    {
                        if(task.status==TASK_STATUS_READY  || task.status == TASK_STATUS_RUNNING)
                        {
                            totalsize += task.total - task.current;
                        }
                    }
                    if(t.status == TASK_STATUS_BLOCK) {
                        totalsize += t.total-t.current;
                    }
                
                    NSString *Unit;
                    float size;
                    if (totalsize >= 1024*1024*1024) {
                        Unit = @"GB";
                        size = totalsize*1.0/1024/1024/1024;
                    }
                    else if(1024*103 <= totalsize && totalsize< 1024*1024*1024)
                    {
                        Unit = @"MB";
                        size = totalsize*1.0/1024/1024;
                    }
                    else {
                        Unit = @"MB";
                        size = 0.1;
                    }
                    
                    strTitle = [NSString stringWithFormat:STR(@"CityDownloadManage_startDownloadAlert", Localize_CityDownloadManage),size,Unit];
                    
                    GDAlertView *alertView = [[GDAlertView alloc] initWithTitle:nil andMessage:strTitle];
                    [alertView addButtonWithTitle:STR(@"Universal_no", Localize_Universal) type:GDAlertViewButtonTypeCancel handler:nil];
                    [alertView addButtonWithTitle:STR(@"Universal_yes", Localize_Universal) type:GDAlertViewButtonTypeDefault handler:^(GDAlertView *alertView){
                        
                        [[TaskManager taskManager] startWithTaskID:taskID];
                        [m_table reloadData];
                        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_HandleUIUpdate object:[NSNumber numberWithInt:UIUpdate_MapDataDownloadFinish] userInfo:nil];
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
        
		
	}
	
	[m_table reloadData];
    if(managerController)
    {
        BOOL isupdate = [[TaskManager taskManager] checkUpdate];
        ((DMDataDownloadManagerViewController*)managerController).navigationItem.rightBarButtonItem.enabled = isupdate;
        
    }
}
- (void)removeTaskAlert:(int)taskID
{
    removeFlag = NO;
    
    int m_taskID = taskID;
	if (m_taskID == 0) {
        GDAlertView *alertView = [[GDAlertView alloc] initWithTitle:nil andMessage:STR(@"CityDownloadManage_basicResourcesDeleted",Localize_CityDownloadManage)];
        [alertView addButtonWithTitle:STR(@"Universal_ok", Localize_Universal) type:GDAlertViewButtonTypeCancel handler:nil];
        [alertView show];
        [alertView release];
        
	}
	else
	{
        __block CityDataManagerFirstViewController *weakSelf = self;
        
        GDAlertView *alertView = [[GDAlertView alloc] initWithTitle:nil andMessage:STR(@"CityDownloadManage_isDeleteData",Localize_CityDownloadManage)];
        [alertView addButtonWithTitle:STR(@"Universal_cancel", Localize_Universal) type:GDAlertViewButtonTypeCancel handler:nil];
        [alertView addButtonWithTitle:STR(@"Universal_ok", Localize_Universal) type:GDAlertViewButtonTypeDefault handler:^(GDAlertView *alertView){
            
            [weakSelf removeTaskWithTaskID:taskID];
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_HandleUIUpdate object:[NSNumber numberWithInt:UIUpdate_MapDataDownloadFinish] userInfo:nil];
        }];
        [alertView show];
        [alertView release];
        
	}
}

- (void)removeTaskWithTaskID:(int)taskID
{
    Task* task = [[TaskManager taskManager] getTaskWithTaskID:taskID];
    if(task.status == TASK_STATUS_FINISH)
    {
        
        if ([ANParamValue sharedInstance].isPath) {//如果存在路径，且路径的起点，途径点或终点有在被删除的地图范围内，则删除路径
            GPOI *ppJourneyPoint = NULL;
            GDBL_GetJourneyPoint(&ppJourneyPoint);
            
            for (int i = 0; i < 7; i++) {
                if (ppJourneyPoint[i].Coord.x != 0 || ppJourneyPoint[i].Coord.y != 0) {
                    int tmpAdcode = [[ MWAdminCode GetCityAdminCode:ppJourneyPoint[i].Coord.x Lat:ppJourneyPoint[i].Coord.y] intValue];
                    if (task.taskId == tmpAdcode) {
                        [MWRouteGuide GuidanceOperateWithMainID:1 GuideHandle:NULL];
                        break;
                    }
                }
            }
        }
    }
    
    [[TaskManager taskManager] update_erase:task.taskId];
    [[TaskManager taskManager] store];
    [m_table reloadData];
    if(managerController)
    {
        BOOL isupdate = [[TaskManager taskManager] checkUpdate];
        ((DMDataDownloadManagerViewController*)managerController).navigationItem.rightBarButtonItem.enabled = isupdate;
        
    }
}

-(void)dataDownloadCheck
{
    //检查空间和网络
    long long totalsize = [[TaskManager taskManager] getNeedSize:nil];
    long long disksize = [UIDevice getCurDiskSpaceInBytes];
    
    if(disksize < totalsize)
    {
        float freesize = (float)(totalsize - disksize)/1024/1024/1024;
        float disksizeUintG = disksize/1024/1024/1024.0;
        float totalUintG = totalsize/1024/1024/1024.0;
        if(disksizeUintG < 0.1)
        {
            disksizeUintG = 0.1;
        }
        if(totalUintG <0.1)
        {
            totalUintG = 0.1;
        }
        
        NSString *strTitle;
        strTitle = [NSString stringWithFormat:STR(@"CityDownloadManage_noFreeSize", Localize_CityDownloadManage),disksizeUintG,totalUintG,freesize];

        
        GDAlertView *alertView = [[GDAlertView alloc] initWithTitle:nil andMessage:strTitle];
        
        [alertView addButtonWithTitle:STR(@"Universal_ok", Localize_Universal) type:GDAlertViewButtonTypeDefault handler:^(GDAlertView *alertView){
            [[TaskManager taskManager]stopAllTask];
            [m_table reloadData];
        }];
        [alertView show];
        [alertView release];
        
    }
    else {
        int netType = NetWorkType;
        if (netType == 2) {
            [[TaskManager taskManager] start];
        }
        else if(netType == 1){
            
            NSString * strTitle;
            
            long long totalsize =0;
            
            for(DownloadTask *task in [TaskManager taskManager].taskList)
            {
                if(task.status==TASK_STATUS_READY  || task.status == TASK_STATUS_RUNNING)
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
            else if(1024*103 <= totalsize && totalsize< 1024*1024*1024)
            {
                Unit = @"MB";
                size = totalsize*1.0/1024/1024;
            }
            else {
                Unit = @"MB";
                size = 0.1;
            }
            
            strTitle = [NSString stringWithFormat:STR(@"CityDownloadManage_startDownloadAlert", Localize_CityDownloadManage),size,Unit];
            
            GDAlertView *alertView = [[GDAlertView alloc] initWithTitle:nil andMessage:strTitle];
            [alertView addButtonWithTitle:STR(@"Universal_no", Localize_Universal) type:GDAlertViewButtonTypeCancel handler:^(GDAlertView *alertView){
                [[TaskManager taskManager]stopAllTask];
                [m_table reloadData];
            }];
            [alertView addButtonWithTitle:STR(@"Universal_yes", Localize_Universal) type:GDAlertViewButtonTypeDefault handler:^(GDAlertView *alertView){
                
                [[TaskManager taskManager] start];
                [m_table reloadData];
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_HandleUIUpdate object:[NSNumber numberWithInt:UIUpdate_MapDataDownloadFinish] userInfo:nil];
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
    
    [[TaskManager taskManager]store];
    [m_table reloadData];
    
    //更改全部更新按钮状态
    if(managerController)
    {
        BOOL isupdate = [[TaskManager taskManager] checkUpdate];
        ((DMDataDownloadManagerViewController*)managerController).navigationItem.rightBarButtonItem.enabled = isupdate;
        
    }

}

#pragma mark -
#pragma mark CustomCellDelegate
- (void)cellButtonTaped:(id)cell
{
    
    CustomCell *tapCell = (CustomCell *)cell;
    if (tapCell.clickType == 0) {
        //开始，暂停任务
        if (tapCell.checked) {
            [[TaskManager taskManager] stopWithTaskID:tapCell.taskID];
        }
        else{
            [self startTaskAlert:tapCell.taskID];
        }
    }
    else{
        //删除任务
        [self removeTaskAlert:tapCell.taskID];
        
        //更改全部更新按钮状态
        if(managerController)
        {
            BOOL isupdate = [[TaskManager taskManager] checkUpdate];
            ((DMDataDownloadManagerViewController*)managerController).navigationItem.rightBarButtonItem.enabled = isupdate;
            
        }
    }
    
    [m_table reloadData];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_HandleUIUpdate object:[NSNumber numberWithInt:UIUpdate_MapDataDownloadFinish] userInfo:nil];
}

- (void)customCellUpdateData:(id)cell
{
    CustomCell *tapCell = (CustomCell *)cell;
    NSLog(@"%d",tapCell.taskID);

    DownloadTask *task = [[TaskManager taskManager] getTaskInfoFromMapList:tapCell.taskID];
    if(task)
    {
        //如果task是不交叉的，需要先删数据,再更新
        NSArray *nocrossTasklist= [[TaskManager taskManager]getNoCrossTask];
        for(Task *nocross in nocrossTasklist)
        {
            if(nocross.taskId == task.taskId)
            {
                [task erase];
                break;
            }
        }
        
        NSArray *nomatchlist= [[TaskManager taskManager]getNoMatchTask];
        for(Task *nomatch in nomatchlist)
        {
            if(nomatch.taskId == task.taskId)
            {
                [task erase];
                break;
            }
        }
        
        [[TaskManager taskManager] addTask:task atFirst:NO];//更新
        
        //检查基础资源是否存在
        Task *basetask = [[TaskManager taskManager]getTaskWithTaskID:0];
        if(!basetask)
        {
            [[TaskManager taskManager] updatecity:0];
        }
        
        //检查交叉更新，弹出确认框，如果OK，把不匹配的城市也加入更新列表中，否则不处理。
        
        if(!nocrossTasklist)
        {
            //数据下载检测
            [self dataDownloadCheck];
            return;
        }
        //有不交叉数据的处理
        NSString *citynames=@"";
        int count = [nocrossTasklist count];
        int i=0;
        for(DownloadTask *dtask in nocrossTasklist)
        {
            i++;
            citynames = [citynames stringByAppendingString:dtask.title];
            if(i>2)
            {
                break;
            }
            if(count>= 2 && i!=count)
            {
                citynames = [citynames stringByAppendingString:@","];
            }
        }
        if(fontType ==0 || fontType ==1)
        {
            if(count>2)
            {
                citynames = [citynames stringByAppendingFormat:@"......等%d",count];
            }
            else{
                citynames = [citynames stringByAppendingFormat:@"%d",count];
            }
        }
        
        else
        {
            citynames = @" ";
        }
        
        
        NSString *strTitle = [NSString stringWithFormat:STR(@"CityDownloadManage_noMatchUpdate",Localize_CityDownloadManage),citynames];
        
        GDAlertView *alertView = [[GDAlertView alloc] initWithTitle:nil andMessage:strTitle];
        [alertView addButtonWithTitle:STR(@"Universal_cancel", Localize_Universal) type:GDAlertViewButtonTypeCancel handler:^(GDAlertView *alertView){
            [self dataDownloadCheck];
        }];//不操作
        [alertView addButtonWithTitle:STR(@"CityDownloadManage_update", Localize_CityDownloadManage) type:GDAlertViewButtonTypeDefault handler:^(GDAlertView *alertView){
            for(DownloadTask *dtask in nocrossTasklist)
            {
                [dtask erase];//先删除数据在更新下载
                [[TaskManager taskManager] updatecity:dtask.taskId];
            }
            [self dataDownloadCheck];
        }];
        [alertView show];
        [alertView release];

    }
    else{
        NSLog(@"not find taskid%d",tapCell.taskID);
    }
        
}



#pragma mark -
#pragma mark Table view data source and delegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    [self setButtonHidden];
    
    finishTaskCount = [[TaskManager taskManager] getFinishTaskNumber];
    if (finishTaskCount == 0) {
        finishTaskType = 0;
        return 1;
    }
    else if ([[TaskManager taskManager].taskList count] == finishTaskCount)
    {
        finishTaskType = 1;
        return 1;
    }
    else{
        finishTaskType = 2;
        return 2;
    }
	
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *stringHeader;
    if (finishTaskType == 0) {
        stringHeader =  STR(@"CityDownloadManage_downloading", Localize_CityDownloadManage);
    }
    else if (finishTaskType == 1)
    {
        stringHeader =  STR(@"CityDownloadManage_completeDownload", Localize_CityDownloadManage);
    }
    else{
        if (section == 0) {
            stringHeader =  STR(@"CityDownloadManage_downloading", Localize_CityDownloadManage);
        }
        else{
            stringHeader = STR(@"CityDownloadManage_completeDownload", Localize_CityDownloadManage);
        }
        
    }
    
    POITableHeadView *headerView = [[[POITableHeadView alloc] initWithTitle:stringHeader] autorelease];
    if (section!=0) {
        [headerView downMove];
    }
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ([[TaskManager taskManager].taskList count] == 0) {
        return 0.;
    }
    if (section==0) {
        return 40;
    }
    return 40+CCTABLE_VIEW_SPACE_HEIGHT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 60.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (finishTaskType == 0 || finishTaskType == 1) {
        return [[TaskManager taskManager].taskList count];
    }
    else 
    {
        if (section == 0) {
            return ([[TaskManager taskManager].taskList count]-finishTaskCount);
        }
        return finishTaskCount;
    }
	
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	
	static NSString *sectiontableidentifier = @"sectiontableidentifier";
	CustomCell *cell = (CustomCell *)[tableView dequeueReusableCellWithIdentifier:sectiontableidentifier];
	if (cell == nil) {
		
        cell = [[[CustomCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:sectiontableidentifier] autorelease];
        cell.m_CustomCellDelegate = self;
    
    }
    
	cell.textLabel.font = [UIFont systemFontOfSize:18];
	cell.label.font = [UIFont systemFontOfSize:13];
	cell.label.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if ([tableView numberOfRowsInSection:indexPath.section] > 1) {
        if (indexPath.row == [tableView numberOfRowsInSection:indexPath.section] -1) {
            cell.emptyLineLength = -1;
        }
        else{
            cell.emptyLineLength = 0;
        }
        
    }
    else{
        cell.emptyLineLength = -1;
    }

    
    Task *t;
	if (finishTaskType == 0) {
        t = [[TaskManager taskManager] getTaskWithIndex:indexPath.row taskStatus:NO];
    }
    else if (finishTaskType == 1){
        t = [[TaskManager taskManager] getTaskWithIndex:indexPath.row taskStatus:YES];
    }
    else{
        if (indexPath.section == 0) {
            t = [[TaskManager taskManager] getTaskWithIndex:indexPath.row taskStatus:NO];
        }
        else{
            t = [[TaskManager taskManager] getTaskWithIndex:indexPath.row taskStatus:YES];
        }
    }
    
    if (!t) {
        return cell;
    }
	cell.taskID = t.taskId;
	//刷新进度条和进度百分比
	float progress = 0.0f;
	NSString *percent;
	if (t.total != 0) 
	{
		progress = (t.current*100.0)/t.total;
	}
	else 
	{
		progress = 0.0;
	}

	if (t.status == TASK_STATUS_RUNNING) {
		
		
        percent = [NSString stringWithFormat:STR(@"CityDownloadManage_downloadPrecent", Localize_CityDownloadManage),progress];
		[cell.buttonDownloadStatus setImage:IMAGE(@"DownloadStop1.png", IMAGEPATH_TYPE_1) forState:UIControlStateNormal];
        [cell.buttonDownloadStatus setTitle:STR(@"CityDownloadManage_stop", Localize_CityDownloadManage) forState:UIControlStateNormal];
        [cell.buttonDownloadStatus setTitleColor:TEXTDETAILCOLOR forState:UIControlStateNormal];
		cell.label.textColor = STOPDOWNLOADCOLOR;
		cell.label.text = percent;
        cell.label.hidden = NO;
		cell.progressBar.progress = progress/100.0;
        cell.buttonDownloadStatus.hidden = NO;
		cell.checked = YES;
        cell.m_updateButton.hidden = YES;

	}
	else if(t.status == TASK_STATUS_READY){
		NSString *percent;
		
        percent = [NSString stringWithFormat:STR(@"CityDownloadManage_readyDownloadPrecent", Localize_CityDownloadManage),progress];
		[cell.buttonDownloadStatus setImage:IMAGE(@"DownloadStart1.png", IMAGEPATH_TYPE_1) forState:UIControlStateNormal];
        [cell.buttonDownloadStatus setTitle:STR(@"CityDownloadManage_start", Localize_CityDownloadManage) forState:UIControlStateNormal];
        [cell.buttonDownloadStatus setTitleColor:TEXTDETAILCOLOR forState:UIControlStateNormal];
		cell.label.textColor = STOPDOWNLOADCOLOR;
		cell.label.text = percent;
        cell.label.hidden = NO;
		cell.progressBar.progress = progress/100.0;
        cell.buttonDownloadStatus.hidden = NO;
        cell.checked = NO;
        cell.m_updateButton.hidden = YES;

	}
    else if(t.status == TASK_STATUS_BLOCK){
		NSString *percent;
		
        percent = [NSString stringWithFormat:STR(@"CityDownloadManage_stopDownloadPrecent", Localize_CityDownloadManage),progress];
		[cell.buttonDownloadStatus setImage:IMAGE(@"DownloadStart1.png", IMAGEPATH_TYPE_1) forState:UIControlStateNormal];
        [cell.buttonDownloadStatus setTitle:STR(@"CityDownloadManage_start", Localize_CityDownloadManage) forState:UIControlStateNormal];
        [cell.buttonDownloadStatus setTitleColor:TEXTDETAILCOLOR forState:UIControlStateNormal];
		cell.label.textColor = STARTDOWNLOADCOLOR;
		cell.label.text = percent;
        cell.label.hidden = NO;
		cell.progressBar.progress = progress/100.0;
        cell.buttonDownloadStatus.hidden = NO;
        cell.checked = NO;
        cell.m_updateButton.hidden = YES;

	}
	else if(t.status == TASK_STATUS_FINISH){
        
		cell.label.textColor = DOWNLOADINGCOLOR;
        cell.label.text = STR(@"CityDownloadManage_beDownload", Localize_CityDownloadManage);
        cell.label.hidden = YES;
		cell.progressBar.progress = 1.0f;
		cell.buttonDownloadStatus.hidden = YES;
        cell.checked = NO;
        if(t.updated)
        {
            cell.m_updateButton.hidden = NO;//有更新，显示更新下载按钮
        }
        else
        {
            cell.m_updateButton.hidden = YES;
        }
	}
	
	//计算城市数据大小
	float size;
	int skb = 1024*103;
	NSString *detail;
    size = t.total*1.0f/1024/1024;
	if (t.total < skb) {
		
		detail = [NSString stringWithFormat:@"%@(0.1MB)",t.title];
	}
	else if (size > 1024){
		detail = [NSString stringWithFormat:@"%@(%.1fGB)",t.title,size/1024.0f];
	}
    else{
        detail = [NSString stringWithFormat:@"%@(%.1fMB)",t.title,size];
    }
	
	if (t.status != TASK_STATUS_FINISH || (t.status==TASK_STATUS_FINISH && t.updated)) {
		cell.textLabel.text =  detail;
	}
	else {
		cell.textLabel.text = t.title;
	}
    
    [cell setChecked:t.selected edit:m_table.editing];
    
    
    return cell;
}

//行点击响应函数
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
	CustomCell *currentCell = (CustomCell *)[tableView cellForRowAtIndexPath:indexPath];
    if(!currentCell || ![currentCell isKindOfClass:[CustomCell class]])
    {
        return;
    }
    
    if (m_table.editing) {
        Task *task = [[TaskManager taskManager] getTaskWithTaskID:currentCell.taskID];
        if (!task) {
            return;
        }
        if (task.taskId == 0) {//基础资源不能勾选
            return;
        }
        
        //勾选非基础资源，都把基础资源取消掉
        Task *baskTask = [[TaskManager taskManager] getTaskWithTaskID:0];
        if (baskTask) {
            baskTask.selected = NO;
            [m_table reloadData];
        }
        
        task.selected = !task.selected;
        
        [currentCell setChecked:task.selected edit:m_table.editing];
        
        if ([[TaskManager taskManager] isSelectedTask]) {
            buttonDeleteSelected.enabled = YES;
        }
        else{
            buttonDeleteSelected.enabled = NO;
        }
        if ([[TaskManager taskManager] isAllSelected]) {
            buttonDeleteAll.enabled = NO;
        }
        else{
            buttonDeleteAll.enabled = YES;
        }
    }
    else{
        currentCell.clickType = 0;
        
        [self cellButtonTaped:currentCell];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

//滑动删除响应函数
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	removeFlag = NO;
	CustomCell *currentCell = (CustomCell *)[tableView cellForRowAtIndexPath:indexPath];

	[self removeTaskAlert:currentCell.taskID];
	
}
-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
	removeFlag = YES;
    
	//当滑动行时如果正在下载，将下载状态置为等待
    CustomCell *cell = (CustomCell *)[m_table cellForRowAtIndexPath:indexPath];
    
    if (m_table.editing) {
        
        return UITableViewCellEditingStyleNone;
    }
    
    
    Task* t = [[TaskManager taskManager] getTaskWithTaskID:cell.taskID];
	
	if (t.status == TASK_STATUS_RUNNING || t.status == TASK_STATUS_READY) {
		[[TaskManager taskManager] stopWithTaskID:cell.taskID];
		
		float progress = (t.current/100.0)/(t.total/10000.0);
		NSString *percent;
		percent = [NSString stringWithFormat:STR(@"CityDownloadManage_stopDownloadPrecent", Localize_CityDownloadManage),progress];
		cell.label.textColor = STARTDOWNLOADCOLOR;
		cell.label.text = percent;
        cell.checked = NO;
        
        [cell.buttonDownloadStatus setImage:IMAGE(@"DownloadStart1.png", IMAGEPATH_TYPE_1) forState:UIControlStateNormal];
	}
	
    [self setButtonHidden];
    
	return UITableViewCellEditingStyleDelete;
}
-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return  STR(@"Universal_delete", Localize_Universal);

}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
	removeFlag = NO;
	return YES;
}

@end

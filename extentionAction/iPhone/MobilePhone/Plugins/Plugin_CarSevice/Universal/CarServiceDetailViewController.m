//
//  CarServiceDetailViewController.m
//  AutoNavi
//
//  Created by jiangshu-fu on 14-3-8.
//
//

#import "CarServiceDetailViewController.h"
#import "CarServiceMoreCell.h"
#import "CarServiceVarDefine.h"
#import "MWCarOwnerServiceManage.h"
#import "UMengEventDefine.h"
#import "QLoadingView.h"
#import "CarServiceMoreViewController.h"


#define DETAIL_NUMS 3
@interface CarServiceDetailViewController ()
{
    int _tableViewCount;
}

@end

@implementation CarServiceDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (id) initWithCarData:(MWCarOwnerServiceTask *) serviceData
{
    self = [super init];
    if(self)
    {
        self.serviceData = serviceData;
    }
    return  self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //请求详细数据
    
    
    //导航条
    NSString *tmpTitle;
    tmpTitle = STR(@"CarService_DetailService", Localize_CarService);
    _navigationBar = [POICommon allocNavigationBar:tmpTitle];
    
    UINavigationItem *navigationitem = [[UINavigationItem alloc] init];
    UIBarButtonItem *item=LEFTBARBUTTONITEM(@"", @selector(leftBtnEvent:));
    [navigationitem setLeftBarButtonItem:item];
    [_navigationBar pushNavigationItem:navigationitem animated:NO];
    [self.view addSubview:_navigationBar];
    [navigationitem release];
    _tableViewCount = 0;
    [self requestData];
    
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MWCarOwnerServiceManage sharedInstance].reqDelegare = self;
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MWCarOwnerServiceManage sharedInstance].delegate = nil;
}


- (void)dealloc
{
    [super dealloc];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - ---  初始化点击的安装按钮  ---
- (UIButton *)initDownloadButton
{
    UIButton *buttonInstall = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *buttonImageNormal1 =  IMAGE(@"CommonBtn1.png", IMAGEPATH_TYPE_1) ;
    UIImage *stretchableButtonImageNormal = [buttonImageNormal1 stretchableImageWithLeftCapWidth:buttonImageNormal1.size.width/2 topCapHeight:buttonImageNormal1.size.height/2];
    UIImage *buttonImagePressed =  IMAGE(@"CommonBtn2.png", IMAGEPATH_TYPE_1);
    UIImage *stretchableButtonImagePressed = [buttonImagePressed stretchableImageWithLeftCapWidth:buttonImageNormal1.size.width/2 topCapHeight:buttonImageNormal1.size.height/2];
    [buttonInstall setBackgroundImage:stretchableButtonImageNormal forState:UIControlStateNormal];
    [buttonInstall setBackgroundImage:stretchableButtonImagePressed forState:UIControlStateHighlighted];
    [buttonInstall addTarget:self action:@selector(buttonPress:) forControlEvents:UIControlEventTouchUpInside];
    buttonInstall.frame = CGRectMake(10.0f, 10.0f, _tableView.frame.size.width - 20, 41.0f);
    [buttonInstall setTitleColor:GETSKINCOLOR(ACCOUNT_BUTTON_TITLE_COLOR) forState:UIControlStateNormal];
    UIColor *color = GETSKINCOLOR(ACCOUNT_BUTTON_TITLE_COLOR);
    if(NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_5_0)
    {
        float redNum,blueNum,greenNum,alphaNum;
        [color getRed:&redNum green:&greenNum blue:&blueNum alpha:&alphaNum];
        [buttonInstall setTitleColor:[UIColor colorWithRed:redNum green:greenNum blue:blueNum alpha:0.3f] forState:UIControlStateDisabled];
    }
    buttonInstall.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    MWCarOwnerServiceTask *task = [[MWCarOwnerServiceManage sharedInstance] getTaskWithTaskID:self.serviceData.serviceID];
    if(task)
    {
         buttonInstall.enabled = NO;
        if(task.status == TASK_STATUS_RUNNING)
        {
            [buttonInstall setTitle:STR(@"CarService_Downloading", Localize_CarService) forState:UIControlStateNormal];
            
        }
        else if(task.status == TASK_STATUS_FINISH)
        {
            [buttonInstall setTitle:STR(@"CarService_DownloadComplete", Localize_CarService) forState:UIControlStateNormal];

        }
        else if(task.status == TASK_STATUS_BLOCK)
        {
            [buttonInstall setTitle:STR(@"CarService_DownloadWaitting", Localize_CarService) forState:UIControlStateNormal];
            buttonInstall.enabled = YES;
        }
        else
        {
            buttonInstall.enabled = YES;
            [buttonInstall setTitle:STR(@"CarService_InstallAndAdd", Localize_CarService) forState:UIControlStateNormal];
        }
       
    }
    else
    {
        [buttonInstall setTitle:STR(@"CarService_InstallAndAdd", Localize_CarService) forState:UIControlStateNormal];
    }
    return buttonInstall ;
}

#pragma mark - ---  按钮事件  ---
- (void) leftBtnEvent:(id) sender
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void) requestData
{
    if (self.serviceData) {
        [[MWCarOwnerServiceManage sharedInstance] RequestCarOwnerServiceDetail:self.serviceData];
        [QLoadingView showLoadingView:STR(@"Universal_loading", Localize_Universal) view:(UIWindow *)self.view];
    }
    [self.view bringSubviewToFront:_navigationBar];
}

//下载服务
- (void) buttonPress:(id)sender
{
    MWCarOwnerServiceTask *task = [[MWCarOwnerServiceManage sharedInstance] getTaskWithTaskID:self.serviceData.serviceID];
    [MWCarOwnerServiceManage sharedInstance].delegate = self;

    NSLog(@"button Press");
    if(!task || (task && task.status != TASK_STATUS_RUNNING
                         && task.status != TASK_STATUS_FINISH
                         && task.status != TASK_STATUS_BLOCK))
    {
        NSString *title  = [[MWCarOwnerServiceManage sharedInstance] getStringFormJson:self.serviceData.title];;
        title = [NSString stringWithFormat:@"%@%@",UM_EVENTID_DOWNLOAD,title];
        [MobClick event:UM_EVENTID_VEHICLE_OWNER_SERVICES_COUNT label:title];
        
        
        
        [[MWCarOwnerServiceManage sharedInstance] addTask:self.serviceData atFirst:NO];
        [[MWCarOwnerServiceManage sharedInstance] startWithTaskID:self.serviceData.serviceID];
        [(UIButton *)sender setTitle:STR(@"CarService_Downloading", Localize_CarService) forState:UIControlStateNormal];
        ((UIButton *)sender).enabled = NO;
    }

}

#pragma mark - ---  TableView Datasource  ---
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return  _tableViewCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    float headerHeight = 0;
    if(section < 2)
    {
        headerHeight = 10;
    }
    else
    {
        headerHeight = 62;
    }

    return headerHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[[UIView alloc]init] autorelease];
    if(section < 2)
    {
        view.hidden = YES;
    }
    else
    {
        [view addSubview:[self initDownloadButton]];
        view.backgroundColor = [UIColor clearColor];
    }
    return  view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    float rowHeight;
    if(indexPath.section == 0)
    {
        rowHeight = 71.0f;
    }
    else if(indexPath.section == 1)
    {
        NSString *stringText = [[MWCarOwnerServiceManage sharedInstance] getStringFormJson:self.serviceData.description];
        CGSize labelSize = [stringText
                            sizeWithFont:[UIFont systemFontOfSize:12.0f]
                       constrainedToSize:CGSizeMake(CARSERVICE_DETAIL_LABEL_WIDTH,2000)
                           lineBreakMode:UILineBreakModeWordWrap];
        rowHeight = (50.0f + labelSize.height > 104.0f) ? (50.0f + labelSize.height) : 104.0f;
    }
    else
    {
        rowHeight = 0;
    }
	return  rowHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier_Lable = @"Cell_Lable";
    
    CarServiceMoreCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_Lable];
    if (cell == nil)
    {
        cell = [[[CarServiceMoreCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier_Lable] autorelease];
    }
    cell.textLabel.textColor=TEXTCOLOR;
    cell.detailTextLabel.textColor=TEXTDETAILCOLOR;
    if(indexPath.section == 0)
    {
        cell.carServiceCellType =  CARSERVICE_CELL_DETAIL_IMAGE;
        cell.hidden = NO;
        cell.imageString = self.serviceData.iconUrl;
        NSString *textString =  [[MWCarOwnerServiceManage sharedInstance] getStringFormJson:self.serviceData.title];
        cell.textLabel.text = textString == nil ? @"":textString;
        __block int setSection = indexPath.section;
        __block UITableView *blockTableView = _tableView;
        cell.cellIamgeLoad = ^()
        {
            NSLog(@"---  RELOAD DATA  ---");
            NSIndexSet *indexSet=[[NSIndexSet alloc]initWithIndex:setSection];
            [blockTableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
            [indexSet release];
        };
        NSString *vendorString =  [[MWCarOwnerServiceManage sharedInstance] getStringFormJson:self.serviceData.vendor];
        NSString *vendor  = vendorString == nil ? @"" : vendorString;
        NSString *version = self.serviceData.versionName == nil ? @"" : self.serviceData.versionName;
        
        
        NSString *unitString = (self.serviceData.total / 1024 < 1024) ? @"KB" : @"MB";
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@\n%@：%@\n%@：%.1f%@",
                                     vendor,STR(@"CarService_Version",Localize_CarService),version,STR(@"CarService_Size",Localize_CarService),
                                     (self.serviceData.total / 1024 < 1024) ? (self.serviceData.total / 1024.0f): (self.serviceData.total / 1024.0f /1024.0f)
                                     ,unitString];
        cell.detailTextLabel.numberOfLines = 3;
        cell.textLabel.font = [UIFont systemFontOfSize:16.0f];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:10.0f];
    }
    else if(indexPath.section == 1)
    {
        cell.carServiceCellType =  CARSERVICE_CELL_DETAIL;
        cell.hidden = NO;
        cell.textLabel.font = [UIFont systemFontOfSize:16.0f];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:12.0f];
        cell.textLabel.text = STR(@"CarService_ServiceTips", Localize_CarService);
        cell.detailTextLabel.text = [[MWCarOwnerServiceManage sharedInstance] getStringFormJson:self.serviceData.description];
        cell.detailTextLabel.numberOfLines = 0;

    }
    else
    {
        cell.hidden = YES;
    }
    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark - ---  actionSheet 委托  ---
- (void)GDActionSheet:(GDActionSheet *)actionSheet clickedButtonAtIndex:(int)index
{
    NSLog(@"%d",index);
}
#pragma mark - ---  请求的详情信息的委托协议  ---
/***
 * @name    请求结束后，的回调
 * @param
 * @author  by bazinga
 ***/
- (void)requestToViewCtrWithRequestType:(RequestType)requestType didFinishLoadingWithResult:(id)result//id类型可以是NSDictionary NSArray
{
    
    [self performSelectorOnMainThread:@selector(didFinishLoadingData) withObject:nil waitUntilDone:YES];
    
}
- (void)requestToViewCtrWithRequestType:(RequestType)requestType didFailWithError:(NSError *)error//上层需根据error的值来判断网络连接超时还是网络连接错误
{
    [self performSelectorOnMainThread:@selector(didFailError) withObject:nil waitUntilDone:YES];
}


- (void) didFinishLoadingData
{
    _tableViewCount = DETAIL_NUMS;
    self.serviceData = [[MWCarOwnerServiceManage sharedInstance] getDetailCarOwnerServiceTask];
    [_tableView reloadData];
    [QLoadingView hideWithAnimated:YES];
    [MWCarOwnerServiceManage sharedInstance].reqDelegare = nil;
    NSLog(@"reqDelegare = nil in  CarServiceDetailViewController");
    
}

- (void) didFailError
{
    [QLoadingView hideWithAnimated:YES];
    if([[ANDataSource sharedInstance] isNetConnecting] == NO)
    {
        GDAlertView *alertView=[[GDAlertView alloc] initWithTitle:nil andMessage:STR(@"Account_NetError",Localize_Account)];
        [alertView addButtonWithTitle:STR(@"POI_OK", Localize_POI) type:GDAlertViewButtonTypeDefault handler:^(GDAlertView *alertView){
            NSLog(@"木有网络~你看不到。");
        }];
        [alertView show];
        [alertView release];
    }
    else
    {
        GDAlertView *alertView=[[GDAlertView alloc] initWithTitle:nil andMessage:STR(@"Account_NetTimeout",Localize_Account)];
        [alertView addButtonWithTitle:STR(@"POI_OK", Localize_POI) type:GDAlertViewButtonTypeDefault handler:^(GDAlertView *alertView){
            NSLog(@"木有网络~你看不到。");
        }];
        [alertView show];
        [alertView release];
    }
    [MWCarOwnerServiceManage sharedInstance].reqDelegare = nil;
    NSLog(@"reqDelegare = nil in  didFailWithError");

    
}



#pragma mark - ---  下载的委托协议  ---
/*
 进度通知
 sender：通知发送者
 current：当前已完成的工作量
 total：总的工作量
 */
-(void)progress:(Task*)sender current:(long long)current total:(long long)total
{
}

/*
 任务完成通知
 sender：通知发送者
 */
-(void)finished:(Task*)sender
{
}

/*
 出现异常通知
 sender：通知发送者
 exception：异常内容
 */
-(void)exception:(Task*)sender exception:(id)exception
{
    [QLoadingView hideWithAnimated:YES];
   if( [exception intValue] != DOWNLOADHANDLETYPE_MD5NOMATCH )
   {
       if([[ANDataSource sharedInstance] isNetConnecting] == NO)
       {
           GDAlertView *alertView=[[GDAlertView alloc] initWithTitle:nil andMessage:STR(@"Account_NetError",Localize_Account)];
           [alertView addButtonWithTitle:STR(@"POI_OK", Localize_POI) type:GDAlertViewButtonTypeDefault handler:^(GDAlertView *alertView){
               NSLog(@"木有网络~你看不到。");
           }];
           [alertView show];
           [alertView release];
       }
       else
       {
           GDAlertView *alertView=[[GDAlertView alloc] initWithTitle:nil andMessage:STR(@"Account_NetTimeout",Localize_Account)];
           [alertView addButtonWithTitle:STR(@"POI_OK", Localize_POI) type:GDAlertViewButtonTypeDefault handler:^(GDAlertView *alertView){
               NSLog(@"木有网络~你看不到。");
           }];
           [alertView show];
           [alertView release];
       }
   }
    [[MWCarOwnerServiceManage sharedInstance] removeTaskId:self.serviceData.serviceID];
    [_tableView reloadData];
    [[NSNotificationCenter defaultCenter] postNotificationName:CAR_SERVICE_NOTIFICATION_KEY object:nil];
    
}

/*
 数据解压完成通知
 sender: 通知发送者
 */
- (void)unZipFinish:(Task*)sender
{
    [self performSelectorOnMainThread:@selector(popViewController) withObject:self waitUntilDone:NO];
}

- (void) popViewController
{
//    [[NSNotificationCenter defaultCenter] postNotificationName:CAR_SERVICE_NOTIFICATION_KEY object:nil];
//    NSMutableArray *array = [[NSMutableArray alloc] initWithArray:[self viewControllers]];
//    if([[array objectAtIndex:array.count - 2] isKindOfClass:[CarServiceMoreViewController class]])
//    {
//        [array removeObjectAtIndex:array.count - 1];
//        [array removeObjectAtIndex:array.count - 1];
//        [self setViewControllers:array];
//    }
//    else
    {
        [self dismissModalViewControllerAnimated:YES];
    }
}

#pragma mark -  ---  横竖屏设置  ---
- (BOOL)shouldAutorotate {
    return NO;
}
- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIDeviceOrientationPortrait);
}

- (void) changePortraitControlFrameWithImage
{
    float screenHeight = SCREENHEIGHT- (((float)NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) ? 0 : 20);
    float screenWidth = SCREENWIDTH;
    CGFloat navigationHeight = _navigationBar.frame.size.height;
    if(isiPhone)
    {
        [_tableView setFrame:CGRectMake(0, navigationHeight, screenWidth , screenHeight - navigationHeight)];
    }
    else
    {
        [_tableView setFrame:CGRectMake(0, navigationHeight, screenWidth, screenHeight - navigationHeight)];
    }
}

@end

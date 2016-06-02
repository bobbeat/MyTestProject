//
//  CarServiceMoreViewController.m
//  AutoNavi
//
//  Created by jiangshu-fu on 14-3-8.
//
//

#import "CarServiceMoreViewController.h"
#import "CarServiceDetailViewController.h"
#import "CarServiceMoreCell.h"
#import "MWCarOwnerServiceManage.h"
#import "QLoadingView.h"
#import "CarServiceVarDefine.h"
#import "NewRedPointData.h"

#pragma mark - ---  TableCell 的数据对象  ---

@interface CarServiceMoreCellData : NSObject


@property (nonatomic, retain) MWCarOwnerServiceTask *carSerivceData;
@property (nonatomic,copy)TableCellTouchBlock touchBlock;

@end

@implementation CarServiceMoreCellData

-(void)dealloc
{
    if(_carSerivceData)
    {
        [_carSerivceData release];
        _carSerivceData=nil;
    }
    
    if(_touchBlock)
    {
        [_touchBlock release];
        _touchBlock=nil;
    }

    [super dealloc];
}

@end


#pragma  mark - ---  更多界面  ---
@interface CarServiceMoreViewController ()

@end

@implementation CarServiceMoreViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
     _arrayCellData = nil;
//    self.title = STR(@"CarService_carService", Localize_CarService);
//    self.navigationItem.leftBarButtonItem=LEFTBARBUTTONITEM(@"", @selector(leftBtnEvent:));
    //添加cell数据
    [self initCellData];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MWCarOwnerServiceManage sharedInstance].reqDelegare = self;
    
}

- (void) viewWillDisappear:(BOOL)animated
{
    
    [super viewWillDisappear:animated];
    
}

- (void) dealloc
{
    if(_arrayCellData)
    {
        [_arrayCellData release];
        _arrayCellData = nil;
    }
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - ---  初始化数据 —— table view 显示的数据  ---

- (void) initCellData
{
    if(!_arrayCellData)
    {
        _arrayCellData = [[NSMutableArray alloc]init];
    }
    else
    {
        [_arrayCellData removeAllObjects];
    }
    //导航条
    NSString *tmpTitle;
    tmpTitle = STR(@"CarService_More", Localize_CarService);;
    _navigationBar = [POICommon allocNavigationBar:tmpTitle];
    
    UINavigationItem *navigationitem = [[UINavigationItem alloc] init];
    UIBarButtonItem *item=LEFTBARBUTTONITEM(@"", @selector(leftBtnEvent:));
    [navigationitem setLeftBarButtonItem:item];
    [_navigationBar pushNavigationItem:navigationitem animated:NO];
    [self.view addSubview:_navigationBar];
    [navigationitem release];
    [self requestData];
}

- (void) addCellDataWithCarServiceItemData:(MWCarOwnerServiceTask *)tempCarServiceItemData withTouchBlock:(TableCellTouchBlock)tempTouchBlock
{
    if(_arrayCellData)
    {
        CarServiceMoreCellData *cellData = [[CarServiceMoreCellData alloc]init];
        cellData.carSerivceData = tempCarServiceItemData;
        cellData.touchBlock = tempTouchBlock;
        [_arrayCellData addObject:cellData];
        [cellData release];
    }
    else
    {
        NSLog(@"_arrayCellData is nil");
    }
}

#pragma mark - ---  按钮事件  ---
- (void) leftBtnEvent:(id) sender
{
    [self dismissModalViewControllerAnimated:YES];
}


- (void) requestData
{
    //请求数据
    [[MWCarOwnerServiceManage sharedInstance] RequestMoreCarOwnerService];
    [QLoadingView showLoadingView:STR(@"Universal_loading", Localize_Universal) view:(UIWindow *)self.view];
    [self.view bringSubviewToFront:_navigationBar];
}


#pragma mark - ---  网络请求回调  ---
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
    __block CarServiceMoreViewController *blockSelf = self;
    for (int i = 0 ; i < [MWCarOwnerServiceManage sharedInstance].carOwnerMoreTaskList.count; i ++) {
            [self addCellDataWithCarServiceItemData:[[MWCarOwnerServiceManage sharedInstance].carOwnerMoreTaskList objectAtIndex:i]
                                     withTouchBlock:^(id object){
                                         CarServiceDetailViewController *item = [[CarServiceDetailViewController alloc] initWithCarData:object];
                                         [blockSelf presentModalViewController:item animated:YES];
                                         [item release];
                                     }];
    }
    
    [_tableView reloadData];
    [QLoadingView hideWithAnimated:YES];
    [MWCarOwnerServiceManage sharedInstance].reqDelegare = nil;
    NSLog(@"reqDelegare = nil in  didFinishLoadingWithResult---------");

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
    NSLog(@"reqDelegare = nil in  didFailWithError---------");

}



#pragma mark - ---  TableView Datasource  ---
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _arrayCellData.count + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    float headerHeight = 0;
    if(section == _arrayCellData.count )
    {
        headerHeight = 45;
    }
    else
    {
        headerHeight = 10;
    }
    return headerHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(section == _arrayCellData.count && _arrayCellData.count > 0)
    {
        UILabel *moreLabel = [[[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 34.0f)] autorelease];
        moreLabel.textAlignment = NSTextAlignmentCenter;
        moreLabel.textColor = TEXTCOLOR;
        moreLabel.text = STR(@"CarService_MoreServiceToSee", Localize_CarService);
        moreLabel.backgroundColor = [UIColor clearColor];
        return moreLabel;
    }
    else
    {
        UIView *view = [[[UIView alloc]init] autorelease];
        view.hidden = YES;
        return view;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return  kHeight5+8;
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
    __block int setSection = indexPath.section;
    __block UITableView *blockTableView = _tableView;
    cell.cellIamgeLoad = ^()
    {
        NSLog(@"---  RELOAD DATA  ---");
        NSIndexSet *indexSet= [[NSIndexSet alloc]initWithIndex:setSection];
        [blockTableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
        [indexSet release];
    };
    if(indexPath.section != _arrayCellData.count)
    {
        
        
        CarServiceMoreCellData *tempData = [_arrayCellData objectAtIndex:indexPath.section];
        NSString *type = RED_TYPE_NO_RECOMMEND;
        BOOL isCarNew = [[NewRedPointData sharedInstance] getValueByType:type
                                                                  withID:tempData.carSerivceData.serviceID];
        cell.showNewPoint = isCarNew;
        cell.textLabel.text=nil;
        cell.detailTextLabel.text=nil;
        cell.textLabel.textColor=TEXTCOLOR;
        cell.textLabel.font = [UIFont systemFontOfSize:15.0f];
        cell.detailTextLabel.textColor=TEXTDETAILCOLOR;
        cell.detailTextLabel.font = [UIFont systemFontOfSize:10.0f];
        
        cell.textLabel.text =  [[MWCarOwnerServiceManage sharedInstance] getStringFormJson:tempData.carSerivceData.title];
        cell.detailTextLabel.text = [[MWCarOwnerServiceManage sharedInstance] getStringFormJson:tempData.carSerivceData.servicedesc];
        cell.imageString =  tempData.carSerivceData.iconUrl;        
        
        
        UIImageView *tempimg = [[UIImageView alloc] initWithImage:IMAGE(@"Accessory.png",IMAGEPATH_TYPE_1)];
        cell.accessoryView = tempimg;
        [tempimg release];

        cell.backgroundType = BACKGROUND_GROUP;
        cell.hidden = NO;
    }
    else
    {
        cell.textLabel.text=nil;
        cell.detailTextLabel.text=nil;
        cell.hidden = YES;
    }
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    CarServiceMoreCellData *temp =  ((CarServiceMoreCellData *)[_arrayCellData objectAtIndex:indexPath.section]);
    
    NSString *type = RED_TYPE_NO_RECOMMEND;
    [[NewRedPointData sharedInstance]setItemPress:type withID:temp.carSerivceData.serviceID];
    [_tableView reloadData];
    
    temp.touchBlock(temp.carSerivceData);
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
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
        [_tableView setFrame:CGRectMake(0, navigationHeight, screenWidth , screenHeight - navigationHeight )];
    }
    else
    {
        [_tableView setFrame:CGRectMake(0, navigationHeight, screenWidth, screenHeight - navigationHeight )];
    }
}

@end

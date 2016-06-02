//
//  RouteSearchTpyeView.m
//  AutoNavi
//
//  Created by jiangshu-fu on 14-4-2.
//
//

#import "RouteSearchTypeView.h"

@class  RouteSearchTpyeViewController;

static UIWindow *g_window = nil;
static UIWindowLevel Route_UIWindowLevelSIAlert = 1999.0;  // 不覆盖系统警告
static RouteSearchTpyeViewController *_ctl;

#pragma mark - ---  哟！ cell  ---
@interface RouteSearchTpyeCell : UITableViewCell
{
	
}

@end

@implementation RouteSearchTpyeCell


@end


#pragma mark-  ---  弹出框视图显示  ---

#define RouteSearchTypeData [NSArray arrayWithObjects:@"加油站",@"停车场",@"公共厕所",@"餐饮",@"便利店", nil]

//cell的高度
#define RouteSearchCellHeight kHeight2
//cell的header的高度
#define RouteSearchHeaderHeight 2

@interface RouteSearchTpyeViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, copy) SelectTypeHandle handle;

@end

@implementation RouteSearchTpyeViewController
{
    NSMutableArray *_arrayCellData;
    UITableView *_tableView;
}

@synthesize handle = _handle;


#pragma mark -
#pragma mark viewcontroller ,
- (id)init
{
	self = [super init];
	if (self)
	{
		 _arrayCellData = [[NSMutableArray alloc]initWithArray:RouteSearchTypeData];
	}
	return self;
}


- (void)dealloc
{
	
    if (_handle)
    {
        [_handle release];
        _handle = nil;
    }
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}
- (void)viewDidUnLoad
{
	[super viewDidLoad];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
    [self initControl];
}
// Called when the view is about to made visible. Default does nothing
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    
}
// Called when the view has been fully transitioned onto the screen. Default does nothing

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}
// Called when the view is dismissed, covered or otherwise hidden. Default does nothing

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

// Called after the view was dismissed, covered or otherwise hidden. Default does nothing
-(void)viewDidDisappear:(BOOL)animated;
{
    [super viewDidDisappear:animated];
}

#pragma mark -
#pragma mark control related
//初始化控件
-(void) initControl
{
    _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    if((float)NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_5_0)
    {
        _tableView.bounces = NO;
    }
    
    if(Interface_Flag == 0)
    {
        [self changePortraitControlFrameWithImage];
    }
    else
    {
        [self changeLandscapeControlFrameWithImage];
    }
    _tableView.layer.cornerRadius = 6;
    _tableView.layer.masksToBounds = YES;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.scrollEnabled = NO;
    _tableView.backgroundView = nil;
    _tableView.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:_tableView];
    [_tableView release];
    self.view.backgroundColor = GETSKINCOLOR(CONTROL_BACKGROUND_COLOR);
//    self.view.backgroundColor = [UIColor redColor];
}


- (CGFloat) getTableViewHeight:(CGFloat) screenHeight
{
    CGFloat height = RouteSearchCellHeight * ( _arrayCellData.count + 2);
    CGFloat maxHeight = screenHeight;
    
    CGFloat tableViewHeight = 0.0f;
    if(height > maxHeight)
    {
        tableViewHeight = maxHeight;
        _tableView.scrollEnabled = YES;
    }
    else
    {
        tableViewHeight = height;
        _tableView.scrollEnabled = NO;
    }
    return  tableViewHeight;
}

//调整控件竖屏坐标和图片
-(void)changePortraitControlFrameWithImage
{
    CGSize size = CGSizeMake(SCREENWIDTH, SCREENHEIGHT);
    
    CGFloat tableViewHeight = [self getTableViewHeight:size.height * 3 / 4];
   
    [_tableView setFrame:CGRectMake(0, 0, size.width * 3 / 4, tableViewHeight)];
    [_tableView setCenter:CGPointMake(size.width/2, size.height/2)];
}

//调整控件横屏坐标和图片
-(void)changeLandscapeControlFrameWithImage
{
    CGSize size = CGSizeMake(SCREENHEIGHT, SCREENWIDTH);
    
    CGFloat tableViewHeight = [self getTableViewHeight:size.height * 3 / 4];
    
    [_tableView setFrame:CGRectMake(0, 0, size.width * 3 / 4, tableViewHeight)];
    [_tableView setCenter:CGPointMake(size.width/2, size.height/2)];
}
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if(orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        [self changePortraitControlFrameWithImage];
    }
    else
    {
        [self changeLandscapeControlFrameWithImage];
    }
}

- (BOOL)shouldAutorotate
{
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationUnknown) {
        return YES;
    }
    
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if (!OrientationSwitch)
    {
        return (Orientation == interfaceOrientation);
    }
	return  YES;
    
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationUnknown) {
        [[MWPreference sharedInstance] loadPreference];
    }
    
    if ([[ANParamValue sharedInstance] bSupportAutorate] == NO)
    {
        return  UIInterfaceOrientationMaskPortrait;
    }
    else{
        if (!OrientationSwitch) {
            return (1<<[[UIApplication sharedApplication] statusBarOrientation]);
        }
        return  UIInterfaceOrientationMaskAll;
    }
}


#pragma mark -
#pragma mark notification
-(void)notificationReceived:(NSNotification*) notification
{

}

#pragma mark -
#pragma mark xxx delegate

#pragma mark ---  UITableViewDataSource  ---

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _arrayCellData.count + 2;// 标题 + 数据个数 + 返回按钮
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    float headerHeight = 0;
//    if(section == 1 )
//    {
//        headerHeight = RouteSearchHeaderHeight;
//    }
//    else
//    {
//        headerHeight = 0;
//    }
//    return headerHeight;
//}
//
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    UIView *view = [[[UIView alloc]init] autorelease];
//    if(section == 0)
//    {
//        view.backgroundColor = [UIColor redColor];
//    }
//    return view;
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return  RouteSearchCellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier_Lable = @"Cell_Lable";
    
    RouteSearchTpyeCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_Lable];
    if (cell == nil)
    {
        cell = [[[RouteSearchTpyeCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier_Lable] autorelease];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%d",indexPath.section];
    //    cell.cellIamgeLoad = ^()
//    {
//        NSLog(@"---  RELOAD DATA  ---");
//        NSIndexSet *indexSet= [[NSIndexSet alloc]initWithIndex:setSection];
//        [blockTableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
//    };
//    if(indexPath.section != _arrayCellData.count)
//    {
//        CarServiceMoreCellData *tempData = [_arrayCellData objectAtIndex:indexPath.section];
//        cell.textLabel.text=nil;
//        cell.detailTextLabel.text=nil;
//        cell.textLabel.textColor=TEXTCOLOR;
//        cell.textLabel.font = [UIFont systemFontOfSize:15.0f];
//        cell.detailTextLabel.textColor=TEXTDETAILCOLOR;
//        cell.detailTextLabel.font = [UIFont systemFontOfSize:10.0f];
//        
//        cell.textLabel.text =  [[MWCarOwnerServiceManage sharedInstance] getStringFormJson:tempData.carSerivceData.title];
//        cell.detailTextLabel.text = [[MWCarOwnerServiceManage sharedInstance] getStringFormJson:tempData.carSerivceData.servicedesc];
//        cell.imageString =  tempData.carSerivceData.iconUrl;
//        
//        
//        UIImageView *tempimg = [[UIImageView alloc] initWithImage:IMAGE(@"Accessory.png",IMAGEPATH_TYPE_1)];
//        cell.accessoryView = tempimg;
//        [tempimg release];
//        
//        cell.backgroundType = BACKGROUND_GROUP;
//        cell.hidden = NO;
//    }
//    else
//    {
//        cell.textLabel.text=nil;
//        cell.detailTextLabel.text=nil;
//        cell.hidden = YES;
//    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if(self.handle)
    {
        self.handle(indexPath.section);
    }
}



@end


#pragma mark- ---  弹出框显示Window实现  ---


@implementation RouteSearchTypeView

/***
 * @name    显示弹出选择框的界面
 * @param   handle  --  选择的函数句柄
 * @author  by bazinga
 ***/
+ (void) showRouteSearchTypWithHandle:(SelectTypeHandle)handle
{
    if (g_window)
    {
        return;
    }
    _ctl = [[RouteSearchTpyeViewController alloc] init];
    _ctl.handle = handle;
    
    g_window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    g_window.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    g_window.opaque = NO;
    g_window.windowLevel = Route_UIWindowLevelSIAlert;
    g_window.rootViewController = _ctl;
    g_window.hidden = NO;
    
    [_ctl release];
}

+ (void) hiddenRouteSearchType
{
    if(g_window)
    {
        [g_window release];
        g_window = nil;
        _ctl = nil;
    }
}


@end

//
//  POISearchDesViewController.m
//  AutoNavi
//
//  Created by weisheng on 14-7-11.
//
//

#import "POIWhereToGoViewController.h"
#import "POIDefine.h"
#import "POICommon.h"
#import "MWPoiOperator.h"
#import "MWMapOperator.h"
#import "POIDataCache.h"
#import "Plugin_Account.h"
#import "PluginStrategy.h"
#import "POITextField.h"
#import "POICommon.h"
#import "GDSearchListCell.h"
#import "POICellButtonEvent.h"
#import "UMengEventDefine.h"
#import "MWPathPOI.h"
#import "POISearchDesViewController.h"
#define DefineHeight 50 +50 +10+ kHeight5
typedef enum GOHomeOrGOCompany
{
    GO_Home       = 10,//回家
    GO_Company    = 11,//回公司
    Add_ImageView = 12,//添加图片
    GO_NaviGation = 13,//出发
}GOHomeOrGOCompany;
#define ADD_BUTTON_SIZE_WIDTH  30.0f
#define ADD_BUTTON_SIZE_HEIGHT 50.0f
@interface POIWhereToGoViewController ()<AddWayPointCellDelegate,POISelectPOIDelegate,MWPoiOperatorDelegate,POIDeleteNationControlDelegate>
{

    POICellButtonEvent *_cellButtonEvent;
   __block int          type;               //判断    1->表示设置家，2->表示设置公司 3->表示其他设置
    UIView             *headView;
    
    BOOL                isCanAdd;
    UIImageView        *_imageviewSlide;
    UIButton           *_buttonAdd;
    UIButton           *_buttonCalcRoute;
    
    int                 _totalCount;                    //途经点个数，不超过五个
    int                 _selectChoice;
    MWPoiOperator      *_poiOperator;
    NSMutableArray     *_arrayPoiData;
    UIView *            _tableHeadView;
}
@property(nonatomic,copy)NSString *homeAddress;
@property(nonatomic,copy)NSString *companyAddress;
@end

@implementation POIWhereToGoViewController
@synthesize whereFromGo;

#pragma mark -
#pragma mark viewcontroller ,
- (void)dealloc
{
    CLOG_DEALLOC(self);
    CRELEASE(_homeAddress);
    CRELEASE(_companyAddress);
    CRELEASE(_cellButtonEvent);
    CRELEASE(_arrayHistoryLineData);
    CRELEASE(_arrayAddRoutePoint);
    CRELEASE(_poiOperator);
    CRELEASE(_imageviewSlide);
    CRELEASE(_arrayPoiData);
    CRELEASE(_tableView2);
    CRELEASE(_tableView1);
    _poiOperator.poiDelegate = nil;
    _cellButtonEvent.route.delegate = nil;
	[super dealloc];
}
-(id)initWithArray:(NSArray *)array
{
    self = [super init];
    if (self) {
        _arrayPoiData = [[NSMutableArray alloc]init];
        [_arrayPoiData addObjectsFromArray:array];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    type = 0;
    _arrayHistoryLineData = [[NSMutableArray alloc]init];
    _arrayAddRoutePoint = [[NSMutableArray alloc]init];
    self.homeAddress=[POICommon getHomeAddress];
    self.companyAddress=[POICommon getCompantAddress];
    _cellButtonEvent=[[POICellButtonEvent alloc] init];

    
    
    _tableView1 = [[UITableView alloc] initWithFrame:CGRectMake(0,0,CCOMMON_APP_WIDTH-2*CCOMMON_TABLE_X,DefineHeight) style:UITableViewStylePlain];
    _tableView1.dataSource = self;
    _tableView1.delegate = self;
    _tableView1.separatorStyle = NO;
    _tableView1.backgroundColor = [UIColor clearColor];
    [_tableView1 setSeparatorColor:[UIColor clearColor]];
    if ([UITableView instancesRespondToSelector:@selector(backgroundView)])
    {
        _tableView1.backgroundView = nil;
    }
    _tableView2 = [[UITableView alloc] initWithFrame:CGRectMake(0,0, CCOMMON_APP_WIDTH-2*CCOMMON_TABLE_X,CCOMMON_CONTENT_HEIGHT) style:UITableViewStylePlain];
    _tableView2.dataSource = self;
    _tableView2.delegate = self;
    _tableView2.backgroundColor = [UIColor clearColor];
    _tableView2.separatorStyle = NO;
    _tableView2.backgroundColor = [UIColor clearColor];
    [_tableView2 setSeparatorColor:[UIColor clearColor]];
    if ([UITableView instancesRespondToSelector:@selector(backgroundView)])
    {
        _tableView2.backgroundView = nil;
    }
    _tableView2.tableHeaderView = _tableView1;
    [self.view addSubview:_tableView2];
    [_tableView1 setEditing:YES animated:YES];
    [self initControl];
    [self getPassPointPoi];
    
}
#pragma mark 判断当前是重导航进来 还是重添加途经点进来的
-(void)getPassPointPoi
{   NSLog(@"%@",_arrayPoiData);
    if (_arrayPoiData.count>0)
    {
        [_arrayAddRoutePoint addObjectsFromArray:_arrayPoiData];
        if (whereFromGo ==3) {
            
        }else
        {  //重添加起点进来 只有一个起点
            if (_arrayAddRoutePoint.count==1) {
                MWPoi * poi = [[MWPoi alloc]init];
                poi.szName = STR(@"Route_enterEnd", Localize_RouteOverview);
                [_arrayAddRoutePoint addObject:poi];
                [poi release];
            }
            //添加途径点进来 起点 终点 途经点之和 小于 7个
            else if (_arrayAddRoutePoint.count>1&&_arrayAddRoutePoint.count<7)
            {
                MWPoi * poi = [[MWPoi alloc]init];
                poi.szName = STR(@"Route_enterTempPoint", Localize_RouteOverview);
                [_arrayAddRoutePoint insertObject:poi atIndex:_arrayAddRoutePoint.count-1];
                [poi release];
            }
        }
        [_tableView1 reloadData];
        [self setImageHeight:_arrayAddRoutePoint.count];
    }
    else
    {
        [self setImageHeight:2];
        [self getCurrent];
        [self getCurrentNearbyPOI];
    }
}
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    _cellButtonEvent.viewController=self;
    _cellButtonEvent.route.delegate = self;
    
    self.navigationController.navigationBarHidden=NO;
    self.homeAddress   =[POICommon getHomeAddress];
    self.companyAddress=[POICommon getCompantAddress];
}
#pragma mark 创建控键
-(void) initControl
{
    isCanAdd = YES;
    self.title=STR(@"POI_WhereToGoTitle", Localize_POI);
    self.navigationItem.leftBarButtonItem=LEFTBARBUTTONITEM(@"", @selector(leftBtnEvent:));
    self.PgType = History_Line;
    [self setShowTableViewData:History_Line];
    
    _imageviewSlide = [[UIImageView alloc]initWithFrame:CGRectMake(7, 10, 27, 92)];
    _imageviewSlide.userInteractionEnabled = YES;
    if (isCanAdd)
    {
        _imageviewSlide.image = IMAGE(@"Route_addPoint0.png", IMAGEPATH_TYPE_1);
    }
    [_tableView1 addSubview:_imageviewSlide];
    _buttonAdd = [UIButton buttonWithType:UIButtonTypeCustom];
    [_buttonAdd setFrame:CGRectMake(0, 33.0f, ADD_BUTTON_SIZE_WIDTH, ADD_BUTTON_SIZE_HEIGHT)];
    [_buttonAdd addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    _buttonAdd.tag = Add_ImageView;
    [_imageviewSlide addSubview:_buttonAdd];
 
}
//调整控件竖屏坐标和图片
-(void)changePortraitControlFrameWithImage
{
    [_tableView2 setFrame:CGRectMake(CCOMMON_TABLE_X, 0, CCOMMON_APP_WIDTH-2*CCOMMON_TABLE_X, CCOMMON_CONTENT_HEIGHT)];
    [_tableView2 reloadData];
    [_tableView1 reloadData];
}

//调整控件横屏坐标和图片
-(void)changeLandscapeControlFrameWithImage
{
    [_tableView2 setFrame:CGRectMake(CCOMMON_TABLE_X, 0, CCOMMON_APP_WIDTH-2*CCOMMON_TABLE_X, CCOMMON_CONTENT_HEIGHT)];
    [_tableView2 reloadData];
    [_tableView1 reloadData];

}
-(void)leftBtnEvent:(id)object
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)setShowTableViewData:(int)typeName
{
    [_arrayHistoryLineData removeAllObjects];
    NSMutableArray * arr=[NSMutableArray arrayWithCapacity:0];
    _isNull=NO;
    [arr addObjectsFromArray:[POICommon getCollectList:SEARCH_HISTORYLINE]];
    if (arr.count==0) {
        _isNull=YES;
        [arr addObject:@"POI_NoHistiryLine"];
    }else
    {
        _isNull = NO;
        [arr addObject:@"POI_CleanHistiryLine"];
    }
    [_arrayHistoryLineData addObjectsFromArray:arr];
    [_tableView1 reloadData];
    [_tableView2 reloadData];
}

-(void)buttonAction:(UIButton*)button
{
    switch (button.tag) {
        case 10:
        {
            //回家
            [MobClick event:UM_EVENTID_ROUTE_PLANNING_VIEW_COUNT label:UM_LABEL_GoHome];
            [self goHomeOrCompany:NO];

        }
            break;
        case 11:
        {
            //回公司
            [MobClick event:UM_EVENTID_ROUTE_PLANNING_VIEW_COUNT label:UM_LABEL_GoCompany];
            [self goHomeOrCompany:YES];
            
        }break;
        case Add_ImageView:
        {
            [self buttonAdd:nil];
        }break;
        case GO_NaviGation:
        {
              [_cellButtonEvent.route gotoNavigationWithArray:_arrayAddRoutePoint];
        }break;
        default:
            break;
    }
}
#pragma mark 添加图片
- (void) buttonAdd:(id)sender
{
    if(_arrayAddRoutePoint.count >= 7)
    {
        [self createAlertViewWithTitle:nil message:STR(@"Route_mostFive", Localize_RouteOverview)
                     cancelButtonTitle:STR(@"RouteOverview_Back", Localize_RouteOverview)
                     otherButtonTitles:nil
                                   tag:ALERT_NONE];
        return ;
    }
    MWPoi * tempPoi = [[[MWPoi alloc]init] autorelease];
    tempPoi.szName = STR(@"Route_enterTempPoint", Localize_RouteOverview);
    [_arrayAddRoutePoint insertObject:tempPoi atIndex:_arrayAddRoutePoint.count - 1];
    [self setImageHeight:_arrayAddRoutePoint.count];
    
    [_tableView1 reloadData];
}
#pragma mark 回家回公司 0表示回家。1表示 回公司
-(void)goHomeOrCompany:(BOOL)isHome
{
    type = isHome + 1;
    NSLog(@"%d",type);
    
//    if ([POIDataCache sharedInstance].flag == 1) {//图层
//        
//        NSArray *arr = [POICommon getFavorite:isHome==NO?GFAVORITE_CATEGORY_HOME:GFAVORITE_CATEGORY_COMPANY];
//        MWPoi *poi=[arr objectAtIndex:0];
//        MWPoi * newPoi =[[MWPoi alloc] init];
//        [POICommon copyWMPoiValutToSubclass:poi withPoiSubclass:newPoi];
//        
//        [[POIDataCache sharedInstance].selectPOIDelegate selectPoi:newPoi withOperation:2];
//        UIViewController * viewController= [self.navigationController.viewControllers objectAtIndex:[POIDataCache sharedInstance].viewControllerLocation];
//        [self.navigationController popToViewController:viewController animated:NO ];
//        [[POIDataCache sharedInstance] clearData];
//        [newPoi release];
//        return;
//    }
    NSString * home = isHome==0?[POICommon getHomeAddress]:[POICommon getCompantAddress];
    if (home==nil||home.length==0)
    {
        //弹出
        __block  POIDataCache *dataCache=[POIDataCache sharedInstance];
        __block PluginStrategy *strategy=[PluginStrategy sharedInstance];
        __block POIWhereToGoViewController * weakSelf=self;
        GDAlertView *alertView=[[[GDAlertView alloc] initWithTitle:nil andMessage:isHome==0?STR(@"POI_SetHomeAddressTitle",Localize_POI):STR(@"POI_SetCompanyAddressTitle",Localize_POI)] autorelease];
        [alertView addButtonWithTitle:STR(@"POI_Cancel", Localize_POI) type:GDAlertViewButtonTypeCancel handler:nil];
        [alertView addButtonWithTitle:STR(@"POI_SetAlertSure",Localize_POI) type:GDAlertViewButtonTypeDefault handler:^(GDAlertView *alertView){
            type=1+isHome;
            dataCache.flag=EXAMINE_POI_ADD_FAV;
            dataCache.selectPOIDelegate=weakSelf;
            dataCache.layerController=weakSelf;
            dataCache.isSetHomeAddress=isHome;
            [strategy allocViewControllerWithName:@"POISearchDesViewController" withType:0 withViewController:weakSelf];
            
        }];
        [alertView show];
        
    }
    else
    {
        if (_cellButtonEvent) {
            isHome==0?[_cellButtonEvent.route goHome]:[_cellButtonEvent.route goCompany];
        }
        
    }
    
}
#pragma mark 获取当前位置最近点的POI信息
-(void)getCurrentNearbyPOI
{
    _poiOperator = [[MWPoiOperator alloc]initWithDelegate:self];
    
    GCARINFO carInfo = {0};
    [[MWMapOperator sharedInstance] GMD_GetCarInfo:&carInfo];
    GCOORD cood = {0};
    cood.x = carInfo.Coord.x;
    cood.y = carInfo.Coord.y;
    [_poiOperator poiNearestSearchWithCoord:cood];
}
-(void)getCurrent
{
    MWPoi * poi = [[MWPoi alloc]init];
    poi.szName = STR(@"POI_MyLocation",Localize_POI);
    GCARINFO carInfo = {0};
    [[MWMapOperator sharedInstance] GMD_GetCarInfo:&carInfo];
    poi.latitude = carInfo.Coord.y;
    poi.longitude = carInfo.Coord.x;
    [_arrayAddRoutePoint addObject:poi];
    [poi release];
    
    MWPoi * poiEnd = [[MWPoi alloc]init];
    poiEnd.szName = STR(@"Route_enterEnd", Localize_RouteOverview);
    [_arrayAddRoutePoint addObject:poiEnd];
    [poiEnd release];

}

#pragma mark 时间转换
-(NSString *)getChangeToSystemTime:(NSString *)time
{
    if (time.length<=7) {
        return time;
    }
    NSString * string = [time substringToIndex:8];
    int y = [string intValue]/10000;
    int m = [string intValue]/100%100;
    int d = [string intValue]%100;
    NSLog(@"%d - %d - %d",y,m,d);
    return [NSString stringWithFormat:@"%d-%d-%d",y,m,d];
    
}
#pragma mark UITableViewDataSource/UITableViewDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == _tableView1) {
        return 1;
    }else if (tableView ==_tableView2)
    {
        return 2;
    }
    return 0;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == _tableView1) {
        return _arrayAddRoutePoint.count>0?_arrayAddRoutePoint.count+1:0;
    }else if(tableView == _tableView2)
    {
        if (section ==0) {
            return 1;
        }else
        {
            return _arrayHistoryLineData.count?_arrayHistoryLineData.count:0;
        }
        
    }return 0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _tableView1) {
        if (indexPath.row==_arrayAddRoutePoint.count)
        {
            return kHeight5 + 10;
        }
        return 50;
    }
    else if (tableView == _tableView2)
    {
        if (indexPath.section ==0) {
           return kHeight5 + 10;
        }else
        {
            if(_isNull && _arrayHistoryLineData.count==1)
            {
                return kHeight2;
            }else if (!_isNull&&_arrayHistoryLineData.count-1==indexPath.row)
            {
                return kHeight5+10;
            }
            else
            {
                MWPathPOI * path=[_arrayHistoryLineData objectAtIndex:indexPath.row];
                NSString * stringName=@"";
                for (int i=0; i<path.poiArray.count; i++) {
                    MWPoi * poi=[path.poiArray objectAtIndex:i];
                    stringName=[[stringName stringByAppendingString:@"→"] stringByAppendingString:poi.szName];
                    
                }
                NSString * string2 = nil;
                if (stringName.length>0) {
                    string2 = [stringName substringFromIndex:1];
                }
                CGSize size=[string2 sizeWithFont:[UIFont systemFontOfSize:kSize2] constrainedToSize:CGSizeMake(_tableView1.bounds.size.width-30,2000.0f)];
                CGFloat height = MAX(size.height + 20+20, kHeight5 + 10);
                return height;//15 为时间字段的高度
            }
        }
        
    }
    return 0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}
-(UIView *)createHomeAndCompanyView
{
    headView=[[UIView alloc]initWithFrame:CGRectMake(0,0, _tableView1.bounds.size.width,kHeight5+10)];
    headView.tag = 4000;
    UIImage * image =[IMAGE(@"POILine.png", IMAGEPATH_TYPE_1) stretchableImageWithLeftCapWidth:0.5 topCapHeight:5];
    UIImageView * imageH = [[UIImageView alloc]initWithFrame:CGRectMake(_tableView1.bounds.size.width/2, 0, 1.5, kHeight5 +10)];
    imageH.image = image;
    [headView addSubview:imageH];
    [imageH release];
    UIButton *button[2];
    UILabel * label [2];
    UILabel * labelAdd[2];
    float width =_tableView1.bounds.size.width/2.0f;
    for (int i=0;i<2 ;i++ ) {
        button[i]=[UIButton buttonWithType:UIButtonTypeCustom];
        [button[i] setBackgroundImage:[IMAGE(@"POIWhereBtn1.png",IMAGEPATH_TYPE_1) stretchableImageWithLeftCapWidth:5 topCapHeight:5] forState:UIControlStateHighlighted];
        button[i].frame=CGRectMake(i*(width),0, width,kHeight5 + 10);
        [button[i] addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [headView addSubview:button[i]];
        button[i].tag=10+i;
        
        label[i]=[[UILabel alloc] initWithFrame:CGRectMake(i*(width),20, width, 20)];
        label[i].textAlignment=NSTextAlignmentCenter;
        label[i].textColor=GETSKINCOLOR(@"POI_NavigationButtonColor");
        label[i].font=[UIFont systemFontOfSize:kSize2];
        [label[i] setBackgroundColor:[UIColor clearColor]];
        [headView addSubview:label[i]];
        [label[i] release];
        
        labelAdd[i]=[[UILabel alloc] initWithFrame:CGRectMake(i*(width)+width/2-25,40, width/2+25, 16)];
        labelAdd[i].textAlignment=NSTextAlignmentLeft;
        labelAdd[i].textColor=GETSKINCOLOR(@"POI_NavigationButtonColor");
        labelAdd[i].font=[UIFont systemFontOfSize:kSize3];
        [labelAdd[i] setBackgroundColor:[UIColor clearColor]];
        [headView addSubview:labelAdd[i]];
        [labelAdd[i] release];
        
    }
    [button[0] setImage:IMAGE(@"PersonalHome.png", IMAGEPATH_TYPE_1) forState:UIControlStateNormal];
    [button[0] setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0,100)];
    
    [button[1] setImage:IMAGE(@"PersonalCompany.png", IMAGEPATH_TYPE_1) forState:UIControlStateNormal];
    [button [1] setImageEdgeInsets:UIEdgeInsetsMake(0,0, 0,100)];
    [label[0] setText:STR(@"POI_Home",Localize_POI)];
    [label[1] setText:STR(@"POI_Company",Localize_POI) ];
    if (!self.homeAddress) {
        [labelAdd[0] setText:STR(@"POI_NoSetting", Localize_POI)];
    }else
    {
        [labelAdd[0] setText:self.homeAddress];
    }
    if (!self.companyAddress) {
        [labelAdd[1] setText:STR(@"POI_NoSetting", Localize_POI)];
    }else
    {
        [labelAdd[1] setText:self.companyAddress];
    }
    return [headView autorelease];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _tableView1) {
        static NSString * identy1 = @"cellidenty1";
        AddWayPointCell * cell = [tableView dequeueReusableCellWithIdentifier:identy1];
        if (cell == nil)
        {
            cell = [[[AddWayPointCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identy1 withCellHeight:50] autorelease];
            cell.delegate = self;
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.emptyLineLength = 45;
        cell.endLineLength   = 47;
        UIButton * button2=(UIButton *)[cell viewWithTag:GO_NaviGation];
        if (button2) {
            [button2 removeFromSuperview];button2 = nil;
        }
        if(indexPath.row == 0 ||_arrayAddRoutePoint.count - 1 == indexPath.row||_arrayAddRoutePoint.count == indexPath.row)
        {
            cell.buttonDelete.hidden = YES;
        }
        else
        {
            cell.buttonDelete.hidden = NO;
        }
        if (_arrayAddRoutePoint.count>0) {
            if (_arrayAddRoutePoint.count == indexPath.row)//出发
            {
                [cell.buttonAddressInfo setTitle:nil forState:UIControlStateNormal];
                

                _buttonNaviGation = [self createButtonWithTitle:STR(@"POI_Go", Localize_POI) normalImage:@"POISearchBtn.png" heightedImage:@"POISearchBtn1.png" tag:GO_NaviGation strechParamX:4 strechParamY:5];
                [_buttonNaviGation setBackgroundImage:[IMAGE(@"POISearchBtn2.png",IMAGEPATH_TYPE_1) stretchableImageWithLeftCapWidth:5 topCapHeight:6]forState:UIControlStateNormal];
                [_buttonNaviGation setTitleColor:GETSKINCOLOR(@"POISearchButtonTitleDisableColor") forState:UIControlStateNormal];
                [_buttonNaviGation setUserInteractionEnabled:NO];
                [_buttonNaviGation setFrame:CGRectMake(10,8, _tableView1.bounds.size.width - 20, 45)];
                [cell addSubview:_buttonNaviGation];
                cell.emptyLineLength = 0;
                cell.endLineLength   = 0;
                if (_arrayAddRoutePoint.count>=2) {
                    MWPoi * areaStart = [_arrayAddRoutePoint objectAtIndex:0];
                    MWPoi * areaEnd   = [_arrayAddRoutePoint objectAtIndex:_arrayAddRoutePoint.count-1];
                    if (areaStart.latitude !=0&&areaEnd .latitude!=0) {
                        [_buttonNaviGation setBackgroundImage:[IMAGE(@"POISearchBtn.png",IMAGEPATH_TYPE_1) stretchableImageWithLeftCapWidth:5 topCapHeight:6]forState:UIControlStateNormal];
                        [_buttonNaviGation setTitleColor:GETSKINCOLOR(@"POISearchButtonTitleColor") forState:UIControlStateNormal];
                        [_buttonNaviGation setUserInteractionEnabled: YES];
                    }
                }

            }
            else
            {
                MWPoi * poi = [_arrayAddRoutePoint objectAtIndex:indexPath.row];
                if (poi.latitude == 0) {
                   [cell.buttonAddressInfo setTitleColor:GETSKINCOLOR(ROUTE_NO_ADDRESS_COLOR) forState:UIControlStateNormal];
                }else
                {
                     [cell.buttonAddressInfo setTitleColor:GETSKINCOLOR(ROUTE_ADDRESS_COLOR) forState:UIControlStateNormal];
                }
                [cell.buttonAddressInfo setTitle:poi.szName forState:UIControlStateNormal];
                GCARINFO carInfo = {0};
                [[MWMapOperator sharedInstance] GMD_GetCarInfo:&carInfo];
                if (poi.longitude == carInfo.Coord.x&&poi.latitude == carInfo.Coord.y)
                {
                    //如果当前位置 ＝＝ 车位
                    [cell.buttonAddressInfo setTitle:STR(@"POI_MyLocation", Localize_POI) forState:UIControlStateNormal];
                    [cell.buttonAddressInfo setTitleColor:GETSKINCOLOR(@"POINaviGationColor") forState:UIControlStateNormal];
                  
                }
            }
            cell.tag = indexPath.row;
        }
       
        
        return cell;
    }
    
    else if(tableView == _tableView2)
    {
        static NSString * identy2 = @"cellidenty2";
        
        GDTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identy2];
        if (cell == nil) {
            cell = [[GDTableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identy2];
            
        }
        headView = (UIView *)[cell viewWithTag:4000];
        if (headView) {
            [headView removeFromSuperview];headView = nil;
        }
        UILabel * labelCearAll = (UILabel *)[cell viewWithTag:4001];
        if (labelCearAll) {
            [labelCearAll removeFromSuperview];labelCearAll = nil;
        }
        if (indexPath.section == 0)
        {
            cell.imageView.image = nil;
            cell.textLabel.text = nil;
            cell.detailTextLabel.text = nil;
            [cell addSubview:[self createHomeAndCompanyView]];
        }else
        {
            if (_arrayHistoryLineData.count==1&&_isNull == YES) {
                cell.imageView.image = nil;
                cell.detailTextLabel.text = nil;
                cell.textLabel.textAlignment=NSTextAlignmentCenter;
                cell.textLabel.text = STR([_arrayHistoryLineData objectAtIndex:0],Localize_POI);
                
            }else if (_arrayHistoryLineData.count == indexPath.row+1&&_isNull==NO)
            {
                cell.imageView.image = nil;
                cell.textLabel.text = nil;
                cell.detailTextLabel.text = nil;
                labelCearAll = [self createLabelWithText:STR([_arrayHistoryLineData objectAtIndex:_arrayHistoryLineData.count-1], Localize_POI) fontSize:kSize2 textAlignment:NSTextAlignmentCenter];
                [labelCearAll setFrame:CGRectMake(0, 0, _tableView2.bounds.size.width,kHeight5+10)];
                labelCearAll.tag = 4001;
                labelCearAll.textColor = TEXTCOLOR;
                [cell addSubview:labelCearAll];
            }else
            {
                MWPathPOI * path=[_arrayHistoryLineData objectAtIndex:indexPath.row];
                NSString * stringName=@"";
                for (int i=0; i<path.poiArray.count; i++) {
                    MWPoi * poi=[path.poiArray objectAtIndex:i];
                    stringName=[[stringName stringByAppendingString:@"→"] stringByAppendingString:poi.szName];
                }
                NSString * string2 = nil;
                if (stringName.length>0) {
                    string2 = [stringName substringFromIndex:1];
                }
                cell.imageView.image = IMAGE(@"POIHistory_des.png", IMAGEPATH_TYPE_1);
                cell.textLabel.text = string2;
                cell.textLabel.numberOfLines = 0;
                cell.detailTextLabel.text = [self getChangeToSystemTime:path.operateTime];
            }
        }
        return cell;
    }
    return nil;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
     [_tableView2 deselectRowAtIndexPath:indexPath animated:NO];
    if (tableView == _tableView1) {
        if (indexPath.row == _arrayAddRoutePoint.count) {
            return;
        }else
        {
            NSLog(@"添加点");
        }
    }
    else if(tableView == _tableView2)
    {
        if (indexPath.section == 0) {
            return;
        }
        if(_isNull==YES)
        {
            return;
        }
        else
        {
            if (_arrayHistoryLineData.count-1==indexPath.row && _arrayHistoryLineData.count>1)
            {
                
                [self deleteAllEvent:nil];
            }
            else
            {
                [ANParamValue sharedInstance].isHistoryRouteClick = indexPath.row + 1;
                int NameRule=0;
                NSMutableArray * arrayName=[[NSMutableArray alloc]init];
                MWPathPOI * path=[_arrayHistoryLineData objectAtIndex:indexPath.row];
                NameRule = path.rule;
                GDBL_SetParam(G_ROUTE_OPTION, &NameRule);
                [arrayName addObjectsFromArray:path.poiArray];
                if (arrayName.count>1) {
                    [_cellButtonEvent.route gotoNavigationWithArray:arrayName];
                }
                [arrayName release];
            }
        }
    }
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _tableView1)
    {
        if (indexPath.section ==1)
        {
            if (indexPath.row!=_arrayAddRoutePoint.count)
            {
                return nil;
            }
            return UITableViewCellEditingStyleNone;
        }
    }
    else if (tableView ==_tableView2)
    {
        [_tableView1 setEditing:YES animated:NO];
        [_tableView1 reloadData];
        return UITableViewCellEditingStyleDelete;
    }
    return nil;
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _tableView1)
    {
        return YES;
    }else if (tableView == _tableView2)
    {
        if (indexPath.section ==1)
        {
            if (_arrayHistoryLineData.count ==1&&_isNull)
            {
                return NO;
            }else if (_arrayHistoryLineData.count ==indexPath.row +1&&!_isNull)
            {
                return NO;
            }
            return YES;
        }
    }
    return NO;
}
-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return  STR(@"Universal_delete", Localize_Universal);
    
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView!=_tableView2)
    {
        return;
    }
    if (indexPath.section ==0)
    {
        return;
    }
    if (editingStyle==UITableViewCellEditingStyleDelete)
    {
        if (indexPath.row==_arrayHistoryLineData.count-1)
        {
            return;
        }
        [self deleteWithIndexPath:indexPath];
    }
}
- (void)tableView:(UITableView*)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _tableView2) {
        [_tableView1 setEditing:YES animated:NO];
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _tableView2) {
        return NO;
    }
    else if (indexPath.row == _arrayAddRoutePoint.count)
    {
        return NO;
    }
    return YES;
}
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    if (sourceIndexPath.section==1||destinationIndexPath.section ==1) {
        [_tableView1 reloadData];
        return;
    }
    if (sourceIndexPath.row==_arrayAddRoutePoint.count||destinationIndexPath.row==_arrayAddRoutePoint.count) {
        [_tableView1 reloadData];
        return;
    }
    if (destinationIndexPath.row!=_arrayAddRoutePoint.count) {
        [_arrayAddRoutePoint  exchangeObjectAtIndex:sourceIndexPath.row withObjectAtIndex:destinationIndexPath.row];
    }
    else if (destinationIndexPath.row!=_arrayAddRoutePoint.count) {
        [_arrayAddRoutePoint exchangeObjectAtIndex:destinationIndexPath.row withObjectAtIndex:sourceIndexPath.row];
    }
    for (int i=0; i<_arrayAddRoutePoint.count; i++) {
        if (i==0) {
            if (((MWPoi *)[_arrayAddRoutePoint objectAtIndex:i]).longitude == 0) {
                ((MWPoi *)[_arrayAddRoutePoint objectAtIndex:i]).szName = STR(@"Route_enterStart", Localize_RouteOverview);
            }
        }
        else if (i==_arrayAddRoutePoint.count-1)
        {
            if (((MWPoi *)[_arrayAddRoutePoint objectAtIndex:i]).longitude == 0) {
                ((MWPoi *)[_arrayAddRoutePoint objectAtIndex:i]).szName = STR(@"Route_enterEnd", Localize_RouteOverview);
            }
        }
        else
        {
            if (((MWPoi *)[_arrayAddRoutePoint objectAtIndex:i]).longitude == 0)
            {
                ((MWPoi *)[_arrayAddRoutePoint objectAtIndex:i]).szName = STR(@"Route_enterTempPoint", Localize_RouteOverview);
            }
        }
    }
    [_tableView1 reloadData];
    
}
#pragma mark 删除历史路线 所有的
-(void)deleteAllEvent:(id)object
{
        GDAlertView *alertView=[[[GDAlertView alloc] initWithTitle:nil andMessage:STR(@"POI_EmptyAlertRecentLineMessage", Localize_POI)] autorelease];
        [alertView addButtonWithTitle:STR(@"Universal_cancel",Localize_Universal) type:GDAlertViewButtonTypeCancel handler:nil];
        
        __block POIWhereToGoViewController *weakSelf=self;
        [alertView addButtonWithTitle:STR(@"Universal_ok",Localize_Universal) type:GDAlertViewButtonTypeDefault handler:^(GDAlertView *alertView){
            [MobClick event:UM_EVENTID_ROUTE_PLANNING_VIEW_COUNT label:UM_LABEL_ClearHistoryLine];
            [POICommon deleteCollectList:SEARCH_HISTORYLINE];
            [weakSelf setShowTableViewData:History_Line];
        }];
        [alertView show];
}
#pragma mark 单条
-(void)deleteWithIndexPath:(NSIndexPath*)path
{
    [POICommon deleteOneCollect:SEARCH_HISTORYLINE withIndex:path.row];
    [self setShowTableViewData:History_Line];
    if (_isNull==YES&&path.row==_arrayHistoryLineData.count-1)
    {
        [_tableView2 reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
        [_tableView2 reloadData];
        [_tableView2 setEditing:NO animated:NO];
        [_tableView1 setEditing:YES animated:NO];
        [_tableView1 reloadData];
       
    }
}
- (void) setImageHeight:(int)count
{
    count = count - 2;
    float x = _imageviewSlide.frame.origin.x;
    float y = 3;
   // float width = _imageviewSlide.frame.size.width;
    
    float buttonWidth = ADD_BUTTON_SIZE_WIDTH;
    float buttonHeight = ADD_BUTTON_SIZE_HEIGHT;
    _buttonAdd.hidden = NO;
    
    if(isCanAdd)
    {
        NSString *imageString = [NSString stringWithFormat:@"Route_addPoint%d.png",count];
        UIImage *image = IMAGE(imageString, IMAGEPATH_TYPE_1);
        _imageviewSlide.image = image;
    }
    else
    {
        _imageviewSlide.image = IMAGE(@"Route_addPoint.png", IMAGEPATH_TYPE_1);
        _buttonAdd.hidden = YES;
        isCanAdd = NO;
    }
    [_imageviewSlide setFrame:CGRectMake(x,y, _imageviewSlide.image.size.width, _imageviewSlide.image.size.height)];
    switch (count) {
        case 0:
        {
            [_buttonAdd setFrame:CGRectMake(_buttonAdd.frame.origin.x, 18.0f, buttonWidth, buttonHeight)];
            [_buttonCalcRoute setFrame:CGRectMake(_buttonCalcRoute.frame.origin.x,
                                                  114.0f ,
                                                  _buttonCalcRoute.frame.size.width,
                                                  _buttonCalcRoute.frame.size.height)];
        }
            break;
        case 1:
        {
            [_buttonAdd setFrame:CGRectMake(_buttonAdd.frame.origin.x, 71.0f, buttonWidth, buttonHeight)];
            [_buttonCalcRoute setFrame:CGRectMake(_buttonCalcRoute.frame.origin.x,
                                                  165.0f ,
                                                  _buttonCalcRoute.frame.size.width,
                                                  _buttonCalcRoute.frame.size.height)];
        }
            break;
        case 2:
        {
            [_buttonAdd setFrame:CGRectMake(_buttonAdd.frame.origin.x, 124.5f, buttonWidth, buttonHeight)];
            [_buttonCalcRoute setFrame:CGRectMake(_buttonCalcRoute.frame.origin.x,
                                                  216.0f ,
                                                  _buttonCalcRoute.frame.size.width,
                                                  _buttonCalcRoute.frame.size.height)];
        }
            break;
        case 3:
        {
            [_buttonAdd setFrame:CGRectMake(_buttonAdd.frame.origin.x, 171.0f, buttonWidth, buttonHeight)];
            [_buttonCalcRoute setFrame:CGRectMake(_buttonCalcRoute.frame.origin.x,
                                                  267.0f ,
                                                  _buttonCalcRoute.frame.size.width,
                                                  _buttonCalcRoute.frame.size.height)];
        }
            break;
        case 4:
        {
            [_buttonAdd setFrame:CGRectMake(_buttonAdd.frame.origin.x, 222.5, buttonWidth, buttonHeight)];
            [_buttonCalcRoute setFrame:CGRectMake(_buttonCalcRoute.frame.origin.x,
                                                  318.0f ,
                                                  _buttonCalcRoute.frame.size.width,
                                                  _buttonCalcRoute.frame.size.height)];
        }
            break;
        case 5:
        {
            [_buttonAdd setFrame:CGRectMake(_buttonAdd.frame.origin.x, 0, 0, 0)];
            [_buttonCalcRoute setFrame:CGRectMake(_buttonCalcRoute.frame.origin.x,
                                                  364.0f ,
                                                  _buttonCalcRoute.frame.size.width,
                                                  _buttonCalcRoute.frame.size.height)];
            _buttonAdd.hidden = YES;
        }
            break;
        default:
            break;
    }
    [_tableView1 setFrame:CGRectMake(0,0,CCOMMON_APP_WIDTH-2*CCOMMON_TABLE_X,count*50 + DefineHeight)];
    _tableView2.tableHeaderView = _tableView1;
    [_tableView1 reloadData];
    [_tableView2 reloadData];
    
}
#pragma mark AddWayPointCellDelegate
- (void) buttonDelete:(AddWayPointCell *) cell
{
    if (cell.tag == _arrayAddRoutePoint.count) {
        return;
    }
    [_arrayAddRoutePoint removeObjectAtIndex:cell.tag];
    [self setImageHeight:_arrayAddRoutePoint.count];
    [_tableView1 reloadData];
}
- (void) infoAdd:(AddWayPointCell *)cell
{
    if (cell.tag == _arrayAddRoutePoint.count) {
        return;
    }
    [self gotoAddPoint:cell];
}
-(void)gotoAddPoint:(AddWayPointCell * )cell
{
    [MWAdminCode SetCurAdarea:[MWAdminCode GetCityAdminCodeWithAdminCode:[MWAdminCode GetCurAdminCode]]];
    __block POIDataCache * dataCache = [POIDataCache sharedInstance];
    __block POIWhereToGoViewController * poiWhere = self;
    POISearchDesViewController * searchDes = [[POISearchDesViewController alloc]init];
    [POIDataCache sharedInstance].selectPOIDelegate = poiWhere;
    [POIDataCache sharedInstance].layerController = poiWhere;
    if (cell) {
        type = 3;
        if (cell.tag ==_arrayAddRoutePoint.count -1)
        {
            dataCache.flag = EXAMINE_POI_ADD_END;
        }
        else if (cell.tag == 0)
        {
            dataCache.flag = EXAMINE_POI_ADD_START;
            
        }else
        {
            dataCache.flag = EXAMINE_POI_ADD_ADDRESS;
            
        }
        
    }
    _selectChoice = cell.tag;
    [self.navigationController pushViewController:searchDes animated:YES];
    [searchDes release];
}
#pragma mark POISelectPOIDelegate
-(void)selectPoi:(MWPoi*)object withOperation:(int)operation
{
    if (type == 0) {
        return;
    }
    //设置普通地点 和设置家、公司
    else if([POIDataCache sharedInstance].flag ==EXAMINE_POI_ADD_FAV)
    {
        BOOL isSuccess;
        MWFavoritePoi * favoritePoi=[[MWFavoritePoi alloc] init];
        [POICommon copyWMPoiValutToSubclass:object withPoiSubclass:favoritePoi];
        isSuccess = [POICommon collectFavorite:type-1 withPOI:favoritePoi];
        [favoritePoi release];
        if (isSuccess) {
            if (type==1) {
                self.homeAddress=[POICommon getHomeAddress];
            }
            else
            {
                self.companyAddress=[POICommon getCompantAddress];
            }
            GDAlertView *alertView =  [[[GDAlertView alloc] initWithTitle:nil andMessage:STR(type==1?@"POI_SetHomeAddressSuccess":@"POI_SetCompanyAddressSuccess", Localize_POI)] autorelease];
            [alertView show];
        }
    }
    //设置起点 终点 途经点
    else
    {
        if ([POIDataCache sharedInstance].flag ==EXAMINE_POI_ADD_ADDRESS||[POIDataCache sharedInstance].flag ==EXAMINE_POI_ADD_START||[POIDataCache sharedInstance].flag == EXAMINE_POI_ADD_END )
        {
            if ([POIDataCache sharedInstance].flag ==EXAMINE_POI_ADD_START)
            {
                  [MobClick event:UM_EVENTID_ROUTE_PLANNING_VIEW_COUNT label:UM_LABEL_NaviSetStart];
            }
            else if ([POIDataCache sharedInstance].flag ==EXAMINE_POI_ADD_END)
            {
                 [MobClick event:UM_EVENTID_ROUTE_PLANNING_VIEW_COUNT label:UM_LABEL_NaviSetEnd];
            }
            if(_selectChoice < _arrayAddRoutePoint.count)
            {
                [_arrayAddRoutePoint replaceObjectAtIndex:_selectChoice withObject:object];
            }
            [_tableView1 reloadData];
        }
        
    }
    type = 0;
}
#pragma mark MWPoiOperatorDelegate
-(void)poiNearestSearch:(GCOORD)coord Poi:(MWPoi *)poi
{
    if (poi) {
        [_arrayAddRoutePoint removeAllObjects];
        GCARINFO carInfo = {0};
        [[MWMapOperator sharedInstance] GMD_GetCarInfo:&carInfo];
        poi.latitude= carInfo.Coord.y;
        poi.longitude = carInfo.Coord.x;
        [_arrayAddRoutePoint addObject:poi];
        MWPoi * poiEnd = [[MWPoi alloc]init];
        poiEnd.szName = STR(@"Route_enterEnd", Localize_RouteOverview);
        [_arrayAddRoutePoint addObject:poiEnd];
        [poiEnd release];
    }
    [_tableView1 reloadData];
}
-(void)search:(id)poiOperatorOption Error:(NSError *)error
{
    [_arrayAddRoutePoint removeAllObjects];
    //设起点
    MWPoi * poiStart = [[MWPoi alloc]init];
    poiStart.szName = STR(@"Main_NoDefine", Localize_Main);
    GCARINFO carInfo = {0};
    [[MWMapOperator sharedInstance] GMD_GetCarInfo:&carInfo];
    poiStart.latitude= carInfo.Coord.y;
    poiStart.longitude = carInfo.Coord.x;
    [_arrayAddRoutePoint addObject:poiStart];
    [poiStart release];
    //设重点
    MWPoi * poiEnd = [[MWPoi alloc]init];
    poiEnd.szName = STR(@"Route_enterEnd", Localize_RouteOverview);
    [_arrayAddRoutePoint addObject:poiEnd];
    [poiEnd release];
    [_tableView1 reloadData];
}
#pragma mark POIDeleteNationControlDelegate
-(void)poiDeleteControlViewController
{
    //modify by wws for 代理解决 添加途经点一直循环的问题 at 2017-7-24
     NSMutableArray * array = [[NSMutableArray alloc]init];
     [array addObject:[self.navigationController.viewControllers caObjectsAtIndex:0]];
     [array addObject:[self.navigationController.viewControllers caObjectsAtIndex:self.navigationController.viewControllers.count - 1]];
     [self.navigationController setViewControllers:array animated:YES];
     [array release];
    
}
@end

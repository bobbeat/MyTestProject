//
//  POIAroundListViewController.m
//  AutoNavi
//
//  Created by huang on 13-8-20.
//
//

#import "POIAroundListViewController.h"
#import "ControlCreat.h"
#import "MWSearchResult.h"
#import "GDSearchListCell.h"
#import "POIDefine.h"
#import "POICommon.h"
#import "POITextField.h"
#import "POIRouteCalculation.h"
#import "POIDataCache.h"
#import "UMengEventDefine.h"
#import "MWSearchOption.h"
#import "MWSearchResult.h"
#import "MWNetSearchOperator.h"
#import "MWNetSearchOption.h"
#import "MWMapOperator.h"
@interface POIAroundListViewController ()<NetReqToViewCtrDelegate>
{
    POIRouteCalculation *_routeCalculation;
    MWPoiOperator       *_poiOperator;
    MWPoiCategory       *_poiCategory;
    
    NSMutableArray      *_arraySearchData;
    UIImageView         *_synchronousBg;
    UIButton            *_buttonSynchronous;
    int                 _pageCount,_sizeCount;
    BOOL                _bMoreResult;
}
@end

@implementation POIAroundListViewController
@synthesize searchType,keyWorld;
#pragma mark -
#pragma mark viewcontroller ,
- (id)init
{
	self = [super init];
	if (self)
	{
		
	}
	return self;
}
-(id)initWithTitle:(NSString*)title keyName:(NSString *)titleName withPoiCategroy:(MWPoiCategory*)poiCategory
{
    self=[super init];
    if (self) {
        _poiCategory=nil;
        if (poiCategory!=nil) {
            _poiCategory=[poiCategory retain];
        }
        self.gdtitle=title;
    }
    return self;
}


- (void)dealloc
{
    CLOG_DEALLOC(self);
    CRELEASE(_routeCalculation);
    CRELEASE(_arraySearchData);
    CRELEASE(_poiCategory);
    _poiOperator.poiDelegate=nil;
    [_poiOperator release];
    self.keyWorld=nil;
	[super dealloc];
}

- (void)viewDidLoad
{
    _pageCount=1;
	[super viewDidLoad];
    _poiOperator =[[MWPoiOperator alloc] initWithDelegate:self];
    [self initControl];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden=NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MWNetSearchOperator MWCancelNetSearchWith:REQ_NET_SEARCH_AROUND];
}
#pragma mark -
#pragma mark control related
//初始化控件
-(void) initControl{
    //联网获取更多的搜索结果
    _synchronousBg = [self createImageViewWithFrame:CGRectZero normalImage:[IMAGE(@"SynchronizationBg.png", IMAGEPATH_TYPE_1) stretchableImageWithLeftCapWidth:2 topCapHeight:0] tag:0];
    [self.view addSubview:_synchronousBg];
    _synchronousBg.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
    _synchronousBg.frame=CGRectMake(0,CONTENTHEIGHT_V-58 , APPWIDTH,58);
    _synchronousBg.userInteractionEnabled=YES;
    
    if ([[MWPreference sharedInstance] getValue:PREF_SKINTYPE] == 0)
    {
        _buttonSynchronous = [self createButtonWithTitle:nil normalImage:@"CommonBtn1.png" heightedImage:@"CommonBtn1.png" tag:4 strechParamX:5 strechParamY:10];
    }
    else
    {
        _buttonSynchronous = [self createButtonWithTitle:nil normalImage:@"CommonBtn1.png" heightedImage:@"CommonBtn1.png" tag:4 strechParamX:5 strechParamY:10];
    }
    _buttonSynchronous.frame=CGRectMake(10,6,APPWIDTH-2*10,40);
    _buttonSynchronous.tag=4;
    [_synchronousBg addSubview:_buttonSynchronous];

    _arraySearchData=[[NSMutableArray alloc] init];

    //搜索栏
    if (searchType==2) {
        [self changeSearchType:self.gdtitle];
    }
    else
    {
        [self changeSearchType:nil];
    }
    self.title=self.gdtitle;
    
   
}

//调整控件竖屏坐标和图片
-(void)changePortraitControlFrameWithImage
{
     _buttonSynchronous.frame=CGRectMake(10,6,APPWIDTH-2*10,40);
    _synchronousBg.frame=CGRectMake(0,CONTENTHEIGHT_V-52 , APPWIDTH,52);
    [self setButtonHidden:_synchronousBg.hidden];
}

//调整控件横屏坐标和图片
-(void)changeLandscapeControlFrameWithImage
{
     _buttonSynchronous.frame=CGRectMake(10,6,APPHEIGHT-2*10,40);
    _synchronousBg.frame=CGRectMake(0,CONTENTHEIGHT_H-52 ,APPHEIGHT,52);
    [self setButtonHidden:_synchronousBg.hidden];
}

- (void)setButtonHidden:(BOOL)hidden    //是否隐藏排序和更多按钮
{
    _synchronousBg.hidden = hidden;
    _buttonSynchronous.hidden = hidden;
    if (hidden == YES)
    {
        [_tableView setFrame:CGRectMake(CCOMMON_TABLE_X,0, CCOMMON_APP_WIDTH-2*CCOMMON_TABLE_X, CCOMMON_CONTENT_HEIGHT-0)];
    }
    else
    {
        [_tableView setFrame:CGRectMake(CCOMMON_TABLE_X,0, CCOMMON_APP_WIDTH-2*CCOMMON_TABLE_X, CCOMMON_CONTENT_HEIGHT-52)];
    }
    
}
//改变控件文本
-(void)changeControlText
{
    [_buttonSynchronous setTitle:STR(@"POI_SearchMoreResult", Localize_POI) forState:UIControlStateNormal];
      self.navigationItem.leftBarButtonItem=LEFTBARBUTTONITEM(@"", @selector(leftBtnEvent:));
}

-(void)leftBtnEvent:(id)object
{
    [MWNetSearchOperator MWCancelNetSearchWith:REQ_NET_SEARCH_AROUND];
	[self.navigationController popViewControllerAnimated:YES];
}
//改变搜索条件
-(void)changeSearchType:(NSString*)string
{
    [_arraySearchData removeAllObjects];
    [self showLoadingViewInView:@"" view:self.view];
    self.keyWorld=string;
    //0 优先使用网络搜索; 1 优先使用本地搜索
    int currentSearchType=[[MWPreference sharedInstance] getValue:PREF_SEARCHTYPE];
    switch (currentSearchType) {
        case 0:
        {
            if ([[ANDataSource sharedInstance] isNetConnecting] == 0)   //无网络连接
            {
                [self locationSearch];
            }
            else
            {
                netSearchBefore=YES;
                _firstTime=YES;
                _pageCount=1;
                [self networkSearch];
            }
        }break;
        case 1:
        {
            netSearchBefore=NO;
            [self locationSearch];
        }break;
    }
}
-(void)networkSearch//网络检索
{
    [self setButtonHidden:YES];
    if (_firstTime==YES) {
        [self performSelector:@selector(cancleLoading) withObject:nil afterDelay:5.0f];
    }
    int adminCode=[MWAdminCode GetCityAdminCodeWithAdminCode:[MWAdminCode GetCurAdminCode]];
    GSTATUS res;
    MWNetAroundSearchOption * arroundNetKeyWorld=[[[MWNetAroundSearchOption alloc]init] autorelease];
    arroundNetKeyWorld.cx= [NSString stringWithFormat:@"%f",[ANParamValue sharedInstance].searchMapInfo.x/1000000.0];
    arroundNetKeyWorld.cy= [NSString stringWithFormat:@"%f",[ANParamValue sharedInstance].searchMapInfo.y/1000000.0];
    arroundNetKeyWorld.range=50000;
    arroundNetKeyWorld.page= _pageCount;
    arroundNetKeyWorld.size=20;
    arroundNetKeyWorld.adcode=[NSString stringWithFormat:@"%d", adminCode];
    if (self.keyWorld) {//网络关键字
        arroundNetKeyWorld.search=self.keyWorld;
    }
    else//网络类别
    {
        arroundNetKeyWorld.category= [MWPoiOperator getNetCategaryStringWithLocalID:_poiCategory.pnCategoryID];
    }
    res= [MWNetSearchOperator MWNetAroundSearchWith:REQ_NET_SEARCH_AROUND option:arroundNetKeyWorld delegate:self];
    if (res==GD_ERR_OK) {
        _bNetWorking=YES;
        _bNetSearch=YES;
    }
}
-(void)locationSearch//本地检索
{
    [self setButtonHidden:NO];
    MWSearchOption * sOption=[[MWSearchOption alloc] init];
    sOption.sortType = 1;
    sOption.latitude= [ANParamValue sharedInstance].searchMapInfo.y;
    sOption.longitude= [ANParamValue sharedInstance].searchMapInfo.x;
    sOption.aroundRange=50000;
    GPOICATCODE stcatcode = {0};
    stcatcode.vnCatCodeCnt[0] = _poiCategory.nCategoryIDNum;
    for (int i = 0; i < [_poiCategory.pnCategoryID count]; i++)
    {
        stcatcode.vnCatCode[i] = [[_poiCategory.pnCategoryID objectAtIndex:i] intValue];
    }
    sOption.stCatCode = stcatcode;
    sOption.operatorType=GSEARCH_TYPE_AROUND;
    if (self.keyWorld)
    {//本地关键字检索
        sOption.keyWord=self.keyWorld;
        
    }else//本地类别检索
    {
        //关键字为空
    }
    BOOL res=[_poiOperator poiLocalSearchWithOption:sOption];
    if (res) {
        _bNetWorking=NO;
        _bNetSearch=NO;
    }
    
    [sOption release];
    
}
//联网获取更多结果
-(void)buttonAction:(UIButton *)sender
{
    if (sender.tag==4) {
        if ([[ANDataSource sharedInstance] isNetConnecting] == 0)
        {
            [self NetRequestError];
        }
        else
        {
            [self showLoadingViewInView:@"" view:self.view];
            _firstTime=NO;
            _pageCount=1;
            [_arraySearchData removeAllObjects];
            [_tableView reloadData];
            [self networkSearch];
        }
    }
}
//第一次网络5秒没应答转本地
-(void)cancleLoading
{
    if (_bNetWorking) {
        _bNetWorking=NO;
        [MWNetSearchOperator MWCancelNetSearchWith:REQ_NET_SEARCH_KERWORD];
        [self showLoadingViewInView:@"" view:self.view];
        [self locationSearch];
    }
}
-(void)naviEvent:(id)object
{
    if ([object isKindOfClass:[GDsearchButton class]]) {
        GDsearchButton  * button = (GDsearchButton *)object;
        NSIndexPath * indexPath =  [_tableView indexPathForCell:button.buttonCell];
        MWPoi * poi = {0};
        poi = [_arraySearchData objectAtIndex:indexPath.row];
        if (_routeCalculation == nil) {
            _routeCalculation=[[POIRouteCalculation alloc] initWithViewController:self];
        }
        [MobClick event:UM_EVENTID_NAVI_COUNT label:UM_LABEL_NAVI_FROM_NEARBY];
        [_routeCalculation setBourn:poi];
    }
}

#pragma mark UITableViewDelegate, UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	
	return kHeight5+10;
	
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_arraySearchData.count>0)
    {
        if (_bNetSearch==YES)
        {
            
            if(_sizeCount > [_arraySearchData count])
            {
                _bMoreResult = YES;
                return  [_arraySearchData count] + 1;
            }else
            {
                _bMoreResult = NO;
                return [_arraySearchData count];
            }
        }
        return _arraySearchData.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"Cell";
    GDSearchListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		
		cell = [[[GDSearchListCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        [cell.naviButton addTarget:self action:@selector(naviEvent:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    cell.type = SEARCH_CELL_LINE_TYPE;
    cell.backgroundType = BACKGROUND_FOOTER;
    UILabel *laberLoadMore = (UILabel *)[cell viewWithTag:123456];  //移除lable，防止复用cell的时候出现
    if (laberLoadMore) {
        [laberLoadMore removeFromSuperview];
        laberLoadMore = nil;
    }
    cell.detailTextLabel.hidden=NO;
    cell.textLabel.text = nil;
    cell.textLabel.hidden = YES;
    cell.labelName.hidden = NO;
    cell.labelAddress.hidden = NO;
    cell.imageViewButton.hidden = NO;
    cell.naviButton.hidden = NO;
    
    if (_bNetSearch==YES) {
        if (_bMoreResult==YES && indexPath.row == [_arraySearchData count])
        {
            laberLoadMore = [[[UILabel alloc]initWithFrame:CGRectMake(0,0,_tableView.bounds.size.width, kHeight5 + 10)] autorelease];
            laberLoadMore.textAlignment=1;
            laberLoadMore.text=STR(@"POI_GetMoreResult", Localize_POI);
            laberLoadMore.backgroundColor=[UIColor clearColor];
            laberLoadMore.tag = 123456;
            laberLoadMore.textColor = TEXTCOLOR;
            [cell addSubview:laberLoadMore];
            
            CGSize textSize = [laberLoadMore.text sizeWithFont:laberLoadMore.font];
            UIActivityIndicatorView * acti=[[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];;
            [acti setCenter:CGPointMake(laberLoadMore.bounds.size.width/2-textSize.width/2 - 10,(kHeight5 + 10)/2)];
            [acti startAnimating];
            [laberLoadMore addSubview:acti];
            

            cell.labelName.hidden = YES;
            cell.labelAddress.hidden = YES;
            cell.imageViewButton.hidden = YES;
            cell.naviButton.hidden = YES;
            cell.detailTextLabel.hidden = YES;
            cell.labelNaviGation.text = nil;
            cell.imageViewLine.hidden = YES;
            
            
        }else
        {
            cell.detailTextLabel.hidden=NO;
            cell.textLabel.text = nil;
            cell.textLabel.hidden = YES;
            cell.labelName.hidden = NO;
            cell.labelAddress.hidden = NO;
            cell.imageViewButton.hidden = NO;
            cell.naviButton.hidden = NO;
            cell.imageViewLine.hidden = NO;
            [self tableView:indexPath andCell:cell];
        }
    }
    else
    {
        [self tableView:indexPath andCell:cell];
    }
    return cell;
}
-(void)tableView:(NSIndexPath *)indexPath andCell:(GDSearchListCell *)cell
{
    cell.labelName.lineBreakMode = UILineBreakModeWordWrap;
	cell.labelName.numberOfLines = 2;
	MWPoi *item = [_arraySearchData objectAtIndex:indexPath.row];
    cell.poi=item;
    cell.labelName.m_HilightFlag =item.lHilightFlag;
    if ([POIDataCache sharedInstance].flag==EXAMINE_POI_NO) {
        cell.searchType=SEARCH_CELL_NAVI;
    }
    else
    {
        cell.accessoryType=UITableViewCellAccessoryNone;
        cell.accessoryView=nil;
        cell.searchType=SEARCH_CELL_ADD;
    }

}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (indexPath.row >= [_arraySearchData count])
    {
        return;
    }
    [POICommon intoPOIViewController:self withIndex:indexPath.row  withViewFlag:INTO_TYPE_NEARBY withPOIArray:_arraySearchData withTitle:self.gdtitle];
}
#pragma mark UIScrollViewDelegate method

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (_bMoreResult && [_arraySearchData count] > 0)
    {
        CGSize size = _tableView.contentSize;
        CGPoint point = _tableView.contentOffset;
        float height = _tableView.bounds.size.height;
        float y = size.height - height - (kHeight5 + 5);
        if (point.y >= y)
        {
            if (!_bNetWorking) {
                [self networkSearch];
            }
        }
    }
}
#pragma mark NetReqToViewCtrDelegate
- (void)requestToViewCtrWithRequestType:(RequestType)requestType didFinishLoadingWithResult:(id)result
{
    _bNetWorking=NO;
    _pageCount=_pageCount+1;
    [self hideLoadingViewWithAnimated:YES];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(cancleLoading) object:nil];
    _firstTime=NO;
    if ([result objectForKey:@"poilist"])
    {
        NSDictionary * poilist=[result objectForKey:@"poilist"];
        int count=[[poilist objectForKey:@"count"] intValue];
        _sizeCount=count;
        NSArray *poiArrayTmp = nil;
        if (_sizeCount >= 1)
        {
            NSDictionary * list=[poilist objectForKey:@"list"];
            id object = [list objectForKey:@"poi"];
            if ([object isKindOfClass:[NSDictionary class]])
            {
                poiArrayTmp = [NSArray arrayWithObjects:object, nil];
            }
            else
            {
                poiArrayTmp = object;
            }
            for (id arr in poiArrayTmp) {
                MWPoi * poi=[[MWPoi alloc]init];
                poi.szName=[arr objectForKey:[POICommon netGetKey:@"name"]];
                poi.szAddr=[arr objectForKey:[POICommon netGetKey:@"address"]];
                if ([poi.szAddr length] == 0)
                {
                    MWAreaInfo * info = [MWAdminCode GetCurAdareaWith:[[arr objectForKey:@"adcode"] intValue] ];
                    poi.szAddr = [NSString stringWithFormat:@"%@%@",info.szProvName?info.szProvName:@"",info.szCityName?info.szCityName:@""];
                }
                poi.szTel = [POICommon netGetTel:[arr objectForKey:@"tel"]];
                poi.szTown= [arr objectForKey:[POICommon netGetKey:@"dname"]];
                poi.latitude=[[arr objectForKey:@"y"] floatValue] * 1000000;
                poi.longitude=[[arr objectForKey:@"x"] floatValue] *1000000;
                poi.lAdminCode=[[arr objectForKey:@"adcode"] intValue] ;
                int dances = [self netCarToPOIDistance:poi];
                poi.lDistance=dances;
                [_arraySearchData addObject:poi];
                [poi release];
            }
            [_tableView reloadData];
        }
        else
        {
            //[self searchResultNullAlert];
            if (netSearchBefore == YES) {
                [self locationSearch];
            }else
            {
                [self searchResultNullAlert];
            }return;
        }
    }
    else
    {
        [self searchResultNullAlert];
    }
    
}
- (void)requestToViewCtrWithRequestType:(RequestType)requestType didFailWithError:(NSError *)error//上层需根据error的值来判断网络连接超时还是网络连接错误
{
    _bNetWorking=NO;
    [self hideLoadingViewWithAnimated:YES];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(cancleLoading) object:nil];
    if (_firstTime==YES) {
        [self showLoadingViewInView:@"" view:self.view];
        [self locationSearch];//先网络后本地
        return;
    }
    [self NetRequestError];
    CGSize size = _tableView.contentSize;
    CGPoint point = _tableView.contentOffset;
    float height = _tableView.bounds.size.height;
    float y = size.height - height - (kHeight5 + 10);
    point.y = y;
    if (point.y < 0)
    {
        point.y = 0;
    }
    _tableView.contentOffset = point;
    [_tableView setContentOffset:point animated:NO];
    _firstTime=NO;
}
#pragma mark  -
#pragma mark MWPoiOperatorDelegaet
-(void)search:(id)poiOperatorOption Error:(NSError *)error
{
    [self hideLoadingViewWithAnimated:YES];
    if (netSearchBefore==NO)
    {
        GDAlertView *alertView=[[[GDAlertView alloc] initWithTitle:nil andMessage:STR(@"POI_TryNetSearch",Localize_POI)] autorelease];
        [alertView addButtonWithTitle:STR(@"POI_Common_NO", Localize_POI) type:GDAlertViewButtonTypeCancel handler:nil];
        [alertView addButtonWithTitle:STR(@"POI_Common_YES",Localize_POI) type:GDAlertViewButtonTypeDefault handler:^(GDAlertView * alet){
            if ([[ANDataSource sharedInstance] isNetConnecting] == 0)   //无网络连接
            {
                [self NetRequestError];
                
            }else
            {
                [self showLoadingViewInView:@"" view:self.view];
                [self networkSearch];
            }
            
        }];
        [alertView show];
    }
    else
    {
        [self searchResultNullAlert];
    }
}
/*!
 @brief 本地POI查询回调函数
 @param poiSearchOption 发起POI查询的查询选项(具体字段参考MWSearchOption类中的定义)
 @param result 查询结果(具体字段参考MWSearchResult类中的定义)
 */
-(void)poiLocalSearch:(MWSearchOption*)poiSearchOption Result:(MWSearchResult *)result
{
    [self hideLoadingViewWithAnimated:YES];
    //判断本地数据是否存在，存在直接显示，不存在讲用网络请求
    if (result.pois.count==0) {
        GDAlertView *alertView=[[[GDAlertView alloc] initWithTitle:nil andMessage:STR(@"POI_TryNetSearch",Localize_POI)] autorelease];
        [alertView addButtonWithTitle:STR(@"POI_Common_NO", Localize_POI) type:GDAlertViewButtonTypeCancel handler:nil];
        [alertView addButtonWithTitle:STR(@"POI_Common_YES",Localize_POI) type:GDAlertViewButtonTypeDefault handler:^(GDAlertView * alet){
            if ([[ANDataSource sharedInstance] isNetConnecting] == 0)   //无网络连接
            {
                [self NetRequestError];
                
            }else
            {
                [self showLoadingViewInView:@"" view:self.view];
                [self networkSearch];
            }
            
        }];
        [alertView show];
        
        return;
    }
    else
    {//对搜索出来的结果进行
        netSearchBefore = NO;
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"lDistance" ascending:YES];
        NSArray *tempArray = [result.pois sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
        [_arraySearchData removeAllObjects];
        [_arraySearchData addObjectsFromArray:tempArray];
        [_tableView reloadData];
    }
}
#pragma mark 请求失败网路问题
- (void)NetRequestError
{
    GDAlertView *Myalert_ext = [[GDAlertView alloc] initWithTitle:nil andMessage:STR(@"Universal_networkError", Localize_Universal) ];
    [Myalert_ext addButtonWithTitle:STR(@"POI_OK", Localize_POI) type:GDAlertViewButtonTypeCancel handler:^(GDAlertView *alertView){
        
    }];
    [Myalert_ext show];
    [Myalert_ext release];
}
#pragma mark 请求结果为空
- (void)searchResultNullAlert
{
    [self hideLoadingViewWithAnimated:YES];
    static BOOL alert = NO;
    if (alert == YES)
    {
        return;
    }
    alert = YES;
    GDAlertView *alertView=[[[GDAlertView alloc] initWithTitle:nil andMessage:STR(@"POI_SearchResultEmpty",Localize_POI)] autorelease];
    [alertView addButtonWithTitle:STR(@"POI_OK", Localize_POI) type:GDAlertViewButtonTypeCancel handler:^(GDAlertView *alertView){
        [self hideLoadingViewWithAnimated:YES];
        [self.navigationController popViewControllerAnimated:YES];
        alert=NO;
    }];
    [alertView show];
    
}
//计算两点的距离 选中的点到POI点的距离
//附近 车位到POI点的距离
//周边 地图中心点到POI点的距离
-(int)netCarToPOIDistance:(MWPoi*)poi
{
    if (!poi) {
        return 0;
    }
    GCOORD coor1;
    GCOORD coor2;
    coor1.x=poi.longitude;
    coor1.y=poi.latitude;
    //当前车位的点
    coor2.x=[ANParamValue sharedInstance].searchMapInfo.x;
    coor2.y=[ANParamValue sharedInstance].searchMapInfo.y;
    int dances= [MWEngineTools CalcDistanceFrom:coor1 To:coor2];
    return dances;
}
@end

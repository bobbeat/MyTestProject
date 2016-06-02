//
//  POIOtherCityDetailViewController.m
//  AutoNavi
//
//  Created by huang on 13-8-19.
//
//

#import "POIOtherCityDetailViewController.h"
#import "MWMapOperator.h"
#import "MWSearchResult.h"
#import "GDSearchListCell.h"
#import "POIDataCache.h"

#import "POIDefine.h"
#import "POICommon.h"
#import "GDAlertView.h"

#import "POICellButtonEvent.h"
#import "UMengEventDefine.h"
#import "MWNetSearchOption.h"
#import "MWNetSearchOperator.h"
@interface POIOtherCityDetailViewController ()<NetReqToViewCtrDelegate>
{
    
    POICellButtonEvent  *_cellButtonEvent;
    MWPoiOperator       *_poiOperator;
    NSMutableArray      *_arraySearchData;
    BOOL _bMoreResult;  //是否有更多结果
    BOOL _bNetWorking;  //是否正在请求网络
    BOOL _bClickMore;   //是否点击更多结果
    int                 _sizeCount;
    int                 _pageCount;
}
@end

@implementation POIOtherCityDetailViewController
@synthesize keyWord;
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


- (void)dealloc
{
    CRELEASE(_cellButtonEvent);
    CRELEASE(keyWord);
    CRELEASE(_arraySearchData);
   
    _poiOperator.poiDelegate=nil;
    [_poiOperator release];
	[super dealloc];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
    [self initControl];
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden=NO;
    _cellButtonEvent.viewController=self;
}

#pragma mark -
#pragma mark control related
//初始化控件
-(void) initControl{
    _pageCount = 1;
//    poiOperator=[[MWPoiOperator alloc] initWithDelegate:self];
//    MWSearchOption *searchOption=[[MWSearchOption alloc] init];
//    searchOption.sortType=0;
//    searchOption.operatorType=self.searchType;
//    searchOption.keyWord=self.keyWord;
//    BOOL isSuccess= [poiOperator poiNetSearchWithOption:searchOption];
//    [searchOption release];
    if ([[ANDataSource sharedInstance] isNetConnecting] == 0)   //无网络连接
    {
        [self NetRequestError];
    }else
    {
        [self showLoadingViewInView:@"" view:self.view];
        [self netWorkSearch];
    }
    _arraySearchData=[[NSMutableArray alloc] init];
    self.title=self.keyWord;
    // 城市数据
    
     
    _cellButtonEvent=[[POICellButtonEvent alloc] init];
  
}
-(void)netWorkSearch
{
    MWNetKeyWordSearchOption * keyWorldSearch=[[[MWNetKeyWordSearchOption alloc]init] autorelease];
    keyWorldSearch.searchtype=self.searchType;// //搜索类型 0:普通关键字搜索 1:语音输入模式搜索 2:交叉路口搜索 可空,默认值=0
    keyWorldSearch.suggestion = @"true";
    keyWorldSearch.search=self.keyWord;
    keyWorldSearch.page=_pageCount;
    keyWorldSearch.size=20;
    keyWorldSearch.adcode=[NSString  stringWithFormat:@"%d",self.nAdminCode];
     GSTATUS res = [MWNetSearchOperator MWNetKeywordSearchWith:REQ_NET_SEARCH_KERWORD option:keyWorldSearch delegate:self];
    if (res == GD_ERR_OK)
    {
        _bNetWorking=YES;
    }
   
}
//调整控件竖屏坐标和图片
-(void)changePortraitControlFrameWithImage
{
  
    [_tableView setFrame:CGRectMake(CCOMMON_TABLE_X, 0.0f, CCOMMON_APP_WIDTH-2*CCOMMON_TABLE_X, CCOMMON_CONTENT_HEIGHT)];
    [_tableView reloadData];
}

//调整控件横屏坐标和图片
-(void)changeLandscapeControlFrameWithImage
{
    
    [_tableView setFrame:CGRectMake(CCOMMON_TABLE_X, 0.0f, CCOMMON_APP_WIDTH-2*CCOMMON_TABLE_X, CCOMMON_CONTENT_HEIGHT)];
    [_tableView reloadData];
}
//改变控件文本
-(void)changeControlText
{
//    self.title=STR(@"POI_WhereToGoTitle",Localize_POI);
     self.navigationItem.leftBarButtonItem=LEFTBARBUTTONITEM(@"", @selector(leftBtnEvent:));
}
-(void)leftBtnEvent:(id)sender
{
    
    [[MWMapOperator sharedInstance] MW_GoToCCP];
	[self.navigationController popViewControllerAnimated:YES];
}

-(void)naviEvent:(id)object
{
 
    NSIndexPath *path=[_cellButtonEvent buttonInTableCell:object withTableView:_tableView];
    if (path) {
        if ([POIDataCache sharedInstance].flag==EXAMINE_POI_NO) {
            [MobClick event:UM_EVENTID_NAVI_COUNT label:UM_LABEL_NAVI_FROM_SEARCH];
        }
        else if([POIDataCache sharedInstance].flag==EXAMINE_POI_ADD_ADDRESS)
        {
            [MobClick event:UM_EVENTID_ADD_WAY_POINT_COUNT label:UM_LABEL_ADD_FROM_SEARCH];
        }

        MWPoi *poi=[_arraySearchData objectAtIndex:path.row];
        [_cellButtonEvent buttonTouchEvent:poi];
    }
}

#pragma mark -
#pragma mark UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
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
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	
	return kHeight5+10;
	
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
	static NSString *CellIdentifier = @"Cell";
    
    GDSearchListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		cell = [[[GDSearchListCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
        [cell.naviButton addTarget:self action:@selector(naviEvent:) forControlEvents:UIControlEventTouchUpInside];
    }
    cell.emptyLineLength = 0;
    UILabel * laberLoadMore = (UILabel *)[cell viewWithTag:4001];  //移除lable，防止复用cell的时候出现
    if (laberLoadMore) {
        [laberLoadMore removeFromSuperview];laberLoadMore = nil;
    }
    cell.detailTextLabel.hidden=NO;
    cell.textLabel.text = nil;
    cell.textLabel.hidden = YES;
    cell.labelName.hidden = NO;
    cell.labelAddress.hidden = NO;
    cell.imageViewButton.hidden = NO;
    cell.naviButton.hidden = NO;
   
    if (_bMoreResult==YES && indexPath.row == [_arraySearchData count]) //有更多，最后一个cell为“获取更多结果”
    {
         cell.backgroundType = BACKGROUND_FOOTER;
        cell.searchType = SEARCH_CELL_NO;
        cell.labelNaviGation.hidden = YES;
        cell.labelNaviGation.text = nil;
        cell.imageViewLine.hidden = YES;
        cell.labelName.hidden = YES;
        cell.labelAddress.hidden = YES;
        cell.imageViewButton.hidden = YES;
        cell.naviButton.hidden = YES;
        cell.detailTextLabel.hidden = YES;
        laberLoadMore = [self createLabelWithText:STR(@"POI_GetMoreResult", Localize_POI) fontSize:kSize2 textAlignment:NSTextAlignmentCenter];
        [laberLoadMore setFrame:CGRectMake(0, 0, _tableView.bounds.size.width, kHeight5 +10)];
        laberLoadMore.tag = 4001;
        laberLoadMore.textColor = TEXTCOLOR;
        CGSize textSize = [laberLoadMore.text sizeWithFont:laberLoadMore.font];
        UIActivityIndicatorView * acti=[[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];;
        [acti setCenter:CGPointMake(laberLoadMore.bounds.size.width/2-textSize.width/2 - 10,(kHeight5 + 10)/2)];
        [acti startAnimating];
        [laberLoadMore addSubview:acti];
        [cell.contentView addSubview:laberLoadMore];
    }
    else
    {
        cell.labelNaviGation.hidden = NO;
        cell.imageViewLine.hidden = NO;
        cell.labelName.hidden = NO;
        cell.labelAddress.hidden = NO;
        cell.imageViewButton.hidden = NO;
        cell.naviButton.hidden = NO;
        cell.detailTextLabel.hidden = NO;
        cell.type = SEARCH_CELL_LINE_TYPE;
         cell.backgroundType = BACKGROUND_FOOTER;
        cell.labelName.lineBreakMode = UILineBreakModeWordWrap;
        cell.labelName.numberOfLines = 2;
        MWPoi * item = [_arraySearchData objectAtIndex:indexPath.row];
        cell.poi=item;
        cell.labelName.m_HilightFlag = item.lHilightFlag;
        if (item.lCategoryID & 0x80000000) {
            cell.labelName.textColor = USERPOICOLOR;
        }
        else
        {
            cell.labelName.textColor =TEXTCOLOR;
        }
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

    
	return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   
    [tableView deselectRowAtIndexPath:indexPath animated:NO];    
    int flag;
    //flag 8 表示 去哪里，9，周边，附近，10家的设置，添加途径点，11常用，数据管理 12常用添加
    POIDataCache *dataCache=[POIDataCache sharedInstance];
    if (dataCache.flag==EXAMINE_POI_NO) {
        flag=INTO_TYPE_NORMAL;
    }
    else if(dataCache.flag==EXAMINE_POI_ADD_FAV)
    {
        //添加家
        flag=INTO_TYPE_ADD_FAV;
    }
    else if(dataCache.flag==EXAMINE_POI_ADD_ADDRESS)
    {
        //添加途径点
        flag=INTO_TYPE_ADD_THROUGH_POINT;
    }
    else if (dataCache.flag ==EXAMINE_POI_ADD_START)
    {
        //添加起点
        flag = INTO_TYPE_ADD_THROUGH_START;
    }
    else if(dataCache.flag ==EXAMINE_POI_ADD_END)
    {
        //添加终点
        flag = INTO_TYPE_ADD_THROUGH_END;
    }

    if (indexPath.row >= [_arraySearchData count])
    {
        return;
    }
    if (_arraySearchData&&flag) {
        [POICommon intoPOIViewController:self withIndex:indexPath.row withViewFlag:flag withPOIArray:_arraySearchData];
    }
     
  
     
}
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
                [self netWorkSearch];
            }
        }
    }
}
- (void)requestToViewCtrWithRequestType:(RequestType)requestType didFinishLoadingWithResult:(id)result//id类型可以是
{
    [self hideLoadingViewWithAnimated:YES];
    _bNetWorking = NO;
    _bClickMore = NO;
    _pageCount=_pageCount+1;
    NSArray *poiArrayTmp = nil;
    if ([result objectForKey:@"poilist"]) {
        NSDictionary * poilist=[result objectForKey:@"poilist"];
        
        int count=[[poilist objectForKey:@"count"] intValue];
        _sizeCount = count;
        if (count >= 1)
        {//请求出来只有一个结果
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
                int dances = [POICommon netCarToPOIDistance:poi];
                poi.lDistance=dances;
                [_arraySearchData addObject:poi];
                [poi release];
            }
            [_tableView reloadData];
        }
        else
        {
            
            [self NetNoSearchResult];
            [self returnToView];
            return;
        }
    }
}
- (void)requestToViewCtrWithRequestType:(RequestType)requestType didFailWithError:(NSError *)error//上层需根据error的值来判断网络连接超时还是网络连接错误
{
    _bNetWorking = NO;
    _bClickMore = NO;
    if (requestType==REQ_NET_SEARCH_KERWORD) {
        [self hideLoadingViewWithAnimated:YES];
        [self returnToView];
        [self NetRequestError];
    }
}
-(void)returnToView
{
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
}
#pragma mark -
#pragma mark MWPoiOperatorDelegate
-(void)search:(id)poiOperatorOption Error:(NSError *)error
{
    [self hideLoadingViewWithAnimated:YES];
    
    GDAlertView *alertView=[[[GDAlertView alloc] initWithTitle:nil andMessage:STR(@"POI_NoSearchResult",Localize_POI)] autorelease];
    [alertView addButtonWithTitle:STR(@"POI_SearchAlertSure", Localize_POI) type:GDAlertViewButtonTypeCancel handler:nil];
    
    [alertView show];
	[_arraySearchData removeAllObjects];
    
}
-(void)poiNetSearch:(MWSearchOption*)poiSearchOption Result:(MWSearchResult *)result
{
    [self hideLoadingViewWithAnimated:YES];
    [_arraySearchData removeAllObjects];
    [_arraySearchData addObjectsFromArray:result.pois];
    
    if ([_arraySearchData count] == 0 ) {
        GDAlertView *alertView=[[[GDAlertView alloc] initWithTitle:nil andMessage:STR(@"POI_NoSearchResult",Localize_POI)] autorelease];
        [alertView addButtonWithTitle:STR(@"POI_SearchAlertSure", Localize_POI) type:GDAlertViewButtonTypeCancel handler:nil];
        
        [alertView show];
        return;
    }
    else
    {
        [_tableView reloadData];
	}
    
}
- (void)NetRequestError
{
    GDAlertView *Myalert_ext = [[GDAlertView alloc] initWithTitle:nil andMessage:STR(@"Universal_networkError", Localize_Universal) ];
    [Myalert_ext addButtonWithTitle:STR(@"Universal_ok", Localize_Universal)  type:GDAlertViewButtonTypeCancel handler:nil];
    [Myalert_ext show];
    [Myalert_ext release];
}

-(void)NetNoSearchResult
{
    GDAlertView *alertView=[[[GDAlertView alloc] initWithTitle:nil andMessage:STR(@"POI_NoSearchResult",Localize_POI)] autorelease];
    [alertView addButtonWithTitle:STR(@"POI_SearchAlertSure", Localize_POI) type:GDAlertViewButtonTypeCancel handler:nil];
    
    [alertView show];
}


@end

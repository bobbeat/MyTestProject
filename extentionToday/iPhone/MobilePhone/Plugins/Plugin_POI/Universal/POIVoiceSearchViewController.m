//
//  POIVoiceSearchViewController.m
//  AutoNavi
//
//  Created by huang on 13-8-19.
//
//

#import "POIVoiceSearchViewController.h"
#import "ControlCreat.h"
#import "SpeechService.h"
#import "GDSearchListCell.h"
#import "MWMapOperator.h"
#import "MWVoiceResult.h"
#import "POIDataCache.h"
#import "POIDefine.h"
#import "POICommon.h"
#import "GDAlertView.h"
#import "POICellButtonEvent.h"
#import "POIOtherCityViewController.h"
#import "UMengEventDefine.h"
#import "MWNetSearchListener.h"
#import "MWNetSearchOperator.h"
@interface POIVoiceSearchViewController ()<NetReqToViewCtrDelegate,MWPoiOperatorDelegate>
{
   
    POICellButtonEvent *_cellButtonEvent;
    MWPoiOperator      *_poiOperator;
    
    NSMutableArray * _arraySearchDataOtherCity;
    BOOL       netWorkSearchBefore;
    BOOL       netWorkSuccess;
    NSInteger  _pageCount,_sizeCount;//_page 是页数 _size总数
    BOOL       _bMoreResult;  //是否有更多结果
    BOOL       _bNetWorking;  //是否正在请求网络
    BOOL       _firstRequest; //第一次网络搜素请求
    UIImageView*_synchronousBg;
    UIButton   *_buttonSynchronous;
}
@end

@implementation POIVoiceSearchViewController
@synthesize  arraySearchData=_arraySearchData,aroundFlag,cmdtxt,voiceType;

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
    CLOG_DEALLOC(self);
    self.cmdtxt=nil;
    CRELEASE(_cellButtonEvent);
    CRELEASE(_arraySearchData);
    _poiOperator.poiDelegate=nil;
    [_poiOperator release];
	[super dealloc];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
    self.title=self.cmdtxt;
    _firstRequest=YES;
    _pageCount=1;
    _poiOperator=[[MWPoiOperator alloc] initWithDelegate:self];
    [self initControl];
 
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden=NO;
    _cellButtonEvent.viewController=self;
}

//初始化控件
-(void) initControl{
    if (_arraySearchData == nil)
    {
        _arraySearchData=[[NSMutableArray alloc] initWithCapacity:0];
    }
    _cellButtonEvent=[[POICellButtonEvent alloc] init];
    //联网获取更多的搜索结果
    _synchronousBg = [self createImageViewWithFrame:CGRectZero normalImage:[IMAGE(@"SynchronizationBg.png", IMAGEPATH_TYPE_1) stretchableImageWithLeftCapWidth:2 topCapHeight:0] tag:0];
    [self.view addSubview:_synchronousBg];
    _synchronousBg.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
    _synchronousBg.frame=CGRectMake(0,CONTENTHEIGHT_V-58 , APPWIDTH,58);
    _synchronousBg.userInteractionEnabled=YES;
    _synchronousBg.hidden=YES;
    
    if ([[MWPreference sharedInstance] getValue:PREF_SKINTYPE] == 0)
    {
        _buttonSynchronous = [self createButtonWithTitle:nil normalImage:@"CommonBtn1.png" heightedImage:@"CommonBtn2.png" tag:4 strechParamX:5 strechParamY:10];
    }
    else
    {
        _buttonSynchronous = [self createButtonWithTitle:nil normalImage:@"CommonBtn1.png" heightedImage:@"CommonBtn2.png" tag:4 strechParamX:5 strechParamY:10];
    }
    _buttonSynchronous.frame=CGRectMake(10,6,APPWIDTH-2*10,40);
    _buttonSynchronous.tag=4;
    _buttonSynchronous.hidden=NO;
    _buttonSynchronous.autoresizingMask=UIViewAutoresizingFlexibleWidth;
    [_synchronousBg addSubview:_buttonSynchronous];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (voiceType == MWVOICE_DATA_CMDID) {//区分周边和去哪里 方便后续排序
            [self searchEvent];
        }else
        {
            [self searchEvent];
        }
    });
}

//调整控件竖屏坐标和图片
-(void)changePortraitControlFrameWithImage
{
    _synchronousBg.frame=CGRectMake(0,CONTENTHEIGHT_V-52 , APPWIDTH,52);
    
    [MWPoiOperator setRecognizeViewCenter:CGPointMake(APPWIDTH/2.0, APPHEIGHT/2.0)];
    [self setButtonHidden:_synchronousBg.hidden];
}

//调整控件横屏坐标和图片
-(void)changeLandscapeControlFrameWithImage
{
    _synchronousBg.frame=CGRectMake(0,CONTENTHEIGHT_H-52 ,APPHEIGHT,52);
    [_tableView setFrame:CGRectMake(CCOMMON_TABLE_X, 0.0f, CCOMMON_APP_WIDTH-2*CCOMMON_TABLE_X, CCOMMON_CONTENT_HEIGHT)];
    [MWPoiOperator setRecognizeViewCenter:CGPointMake(APPHEIGHT/2.0, APPWIDTH/2.0)];
    [self setButtonHidden:_synchronousBg.hidden];
}
//改变控件文本
-(void)changeControlText
{
    [_buttonSynchronous setTitle:STR(@"POI_SearchMoreResult", Localize_POI) forState:UIControlStateNormal];
    self.navigationItem.leftBarButtonItem=LEFTBARBUTTONITEM(@"", @selector(leftBtnEvent:));
}

- (void)setButtonHidden:(BOOL)hidden    //是否隐藏排序和更多按钮
{
    _synchronousBg.hidden = hidden;
    _buttonSynchronous.hidden = hidden;
    if (hidden == YES)
    {
        [_tableView setFrame:CGRectMake(CCOMMON_TABLE_X,0, CCOMMON_APP_WIDTH-2*CCOMMON_TABLE_X, CCOMMON_CONTENT_HEIGHT)];
    }else
    {
        [_tableView setFrame:CGRectMake(CCOMMON_TABLE_X,0, CCOMMON_APP_WIDTH-2*CCOMMON_TABLE_X, CCOMMON_CONTENT_HEIGHT-52)];
    }
    
}
#pragma mark -
#pragma mark control related
-(void)searchEvent
{ 
    [_arraySearchData removeAllObjects];
    [self showLoadingViewInView:@"" view:self.view];
    // 0 优先使用网络搜索; 1 优先使用本地搜索
    int currentSearchType=[[MWPreference sharedInstance] getValue:PREF_SEARCHTYPE];
    switch (currentSearchType)
    {
        case 0:
        {
            //网络优先的时候
            if ([[ANDataSource sharedInstance] isNetConnecting] == 0)   //无网络连接
            {
                [self locationSearch];
                
            }else
            {
                netWorkSearchBefore=YES;
                [self netWorkSearch];
            }
            
        }break;
        case 1:
        {
            netWorkSearchBefore=NO;
            [self locationSearch];//本地检索
        }break;
    }
    
}
-(void)locationSearch
{
    [self setButtonHidden:NO];
    MWSearchOption *sOption=nil;
    BOOL res;
    if (aroundFlag) {
     //周边
        sOption=[self allocSearchNearByObject:self.cmdtxt];
    }
    else
    {//去哪里
        sOption=[self allocSearchObject:self.cmdtxt];
    }
    sOption.aroundRange=100000;
    res= [_poiOperator poiLocalSearchWithOption:sOption];//本地检索
    if (res) {
        netWorkSuccess = NO;
    }

}
-(MWSearchOption *)allocSearchNearByObject:(NSString*)_cmdid
{
    MWSearchOption* sOption=[[MWSearchOption alloc] init];
    sOption.sortType=1;
    sOption.latitude= [ANParamValue sharedInstance].searchMapInfo.y;
    sOption.longitude= [ANParamValue sharedInstance].searchMapInfo.x;
    sOption.aroundRange=50000;
    sOption.keyWord= _cmdid;
    //    GPOICATCODE stcatcode = {0};
    //    stcatcode.vnCatCodeCnt[0] = 1;
    //    stcatcode.vnCatCode[0] = [MWPoiOperator voicePOISearch:self.cmdid];
    //    sOption.stCatCode = stcatcode;
    sOption.operatorType=GSEARCH_TYPE_AROUND;
    sOption.routePoiTpe = GROUTEPOI_TYPE_STARTPOINT;
    return [sOption autorelease];
}
-(MWSearchOption *)allocSearchObject:(NSString*)cmText
{
    MWSearchOption* sOption=[[MWSearchOption alloc] init];
    sOption.keyWord=cmText;
    sOption.sortType = 1;
    sOption.operatorType=GSEARCH_TYPE_NAME;
    return [sOption autorelease];
}
-(void)netWorkSearch
{
    [self setButtonHidden:YES];

    if(voiceType == MWVOICE_DATA_CMDID)//语音周边查询
    {
        MWNetAroundSearchOption * arroundCategory =[[MWNetAroundSearchOption alloc]init];
        arroundCategory.page=_pageCount;
        arroundCategory.size=20;
        arroundCategory.range=50000;
        GMAPCENTERINFO mapinfo = {0};
        [[MWMapOperator sharedInstance] MW_GetMapViewCenterInfo:GMAP_VIEW_TYPE_MAIN mapCenterInfo:&mapinfo];
        arroundCategory.cx=[NSString stringWithFormat:@"%f",mapinfo.CenterCoord.x/1000000.0];
        arroundCategory.cy=[NSString stringWithFormat:@"%f",mapinfo.CenterCoord.y/1000000.0];
        
        int adminCode=[MWAdminCode GetCityAdminCodeWithAdminCode:[MWAdminCode GetCurAdminCode]];
        arroundCategory.search=self.cmdtxt;
        arroundCategory.adcode=[NSString stringWithFormat:@"%d",adminCode];
        
        if (_firstRequest)
        {
            [self performSelector:@selector(cancleLoading) withObject:nil afterDelay:5.0];  //第一次五秒后判断是否转本地
        }
        GSTATUS res=[MWNetSearchOperator MWNetAroundSearchWith:REQ_NET_SEARCH_AROUND option:arroundCategory delegate:self];
        [arroundCategory release];
        if (res==GD_ERR_OK) {
            netWorkSuccess=YES;
            _bNetWorking=YES;
        }
    }
    else// 语音导航
    {
        MWNetKeyWordSearchOption * keyWorldSearch=[[MWNetKeyWordSearchOption alloc]init];
        keyWorldSearch.searchtype=0;// //搜索类型     0:普通关键字搜索 1:语音输入模式搜索 2:交叉路口搜索 可空,默认值=0
        keyWorldSearch.page=_pageCount;
        keyWorldSearch.size=20;
        keyWorldSearch.suggestion = @"false";
        int adminCode=[MWAdminCode GetCityAdminCodeWithAdminCode:[MWAdminCode GetCurAdminCode]];
        if ([ANParamValue sharedInstance].isSelectCity==1) {
            MWAreaInfo * info = [MWAdminCode GetCurAdarea];
            adminCode = info.lAdminCode;
        }
        if (self.cmdtxt) {
            keyWorldSearch.search=self.cmdtxt;
        }
        keyWorldSearch.adcode=[NSString stringWithFormat:@"%d",adminCode];
        if (_firstRequest)
        {
            [self performSelector:@selector(cancleLoading) withObject:nil afterDelay:5.0];  //第一次五秒后判断是否转本地
        }
        GSTATUS res=[MWNetSearchOperator MWNetKeywordSearchWith:REQ_NET_SEARCH_KERWORD option:keyWorldSearch delegate:self];
        
        [keyWorldSearch release];
        if (res==GD_ERR_OK) {
            netWorkSuccess=YES;
            _bNetWorking=YES;
        }
    }
    
}

-(void)leftBtnEvent:(id)object
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)naviEvent:(id)object
{
    NSIndexPath *path=[_cellButtonEvent buttonInTableCell:object withTableView:_tableView];
    if (path) {
        if ([POIDataCache sharedInstance].flag==EXAMINE_POI_NO) {
            [MobClick event:UM_EVENTID_NAVI_COUNT label:UM_LABEL_NAVI_FROM_VOICE];
        }
        else if([POIDataCache sharedInstance].flag==EXAMINE_POI_ADD_ADDRESS)
        {
            [MobClick event:UM_EVENTID_ADD_WAY_POINT_COUNT label:UM_LABEL_ADD_FROM_SEARCH];
        }
        MWPoi *poi=[_arraySearchData objectAtIndex:path.row];
        [_cellButtonEvent buttonTouchEvent:poi];
    }
}


#pragma mark table delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_arraySearchData.count>0) {
        if (netWorkSuccess==YES)
        {
            if(_sizeCount>[_arraySearchData count])
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

    }else
        return 0;
    return [_arraySearchData count];
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return kHeight5+10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	GDSearchListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
		cell = [[[GDSearchListCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"] autorelease];
        [cell.naviButton addTarget:self action:@selector(naviEvent:) forControlEvents:UIControlEventTouchUpInside];
    }
     cell.emptyLineLength = 0;
    cell.type = SEARCH_CELL_LINE_TYPE;
    UILabel *laberLoadMore = (UILabel *)[cell viewWithTag:4000];  //移除lable，防止复用cell的时候出现
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
    if (_arraySearchData.count>0)
    {
        
        if (netWorkSuccess==YES)//网络
        {
            if (_bMoreResult==YES && indexPath.row == [_arraySearchData count])
            {
                laberLoadMore = [self createLabelWithText:STR(@"POI_GetMoreResult", Localize_POI) fontSize:kSize2 textAlignment:NSTextAlignmentCenter];
                [laberLoadMore setFrame:CGRectMake(0,0,_tableView.bounds.size.width, kHeight5 + 10)];
                laberLoadMore.tag = 4000;
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
                [self tableviewIndex:indexPath andCell:cell];
            }
        }
        else//本地
        {
            [self tableviewIndex:indexPath andCell:cell];
        }
        
        
    }
   	return cell;
}
-(void)tableviewIndex:(NSIndexPath *)indexPath andCell:(GDSearchListCell *)cell
{
    MWPoi *item = [_arraySearchData objectAtIndex:indexPath.row];
    cell.poi=item;
    cell.backgroundType = BACKGROUND_FOOTER;
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
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (indexPath.row >= [_arraySearchData count])
    {
        return;
    }
    int flag=INTO_TYPE_NORMAL;
    if([POIDataCache sharedInstance].flag == EXAMINE_POI_ADD_ADDRESS)
    {   //途径点
        flag=INTO_TYPE_ADD_THROUGH_POINT;
    }
    else if ([POIDataCache sharedInstance].flag  ==EXAMINE_POI_ADD_START)
    {
        //添加起点
        flag = INTO_TYPE_ADD_THROUGH_START;
    }
    else if([POIDataCache sharedInstance].flag  ==EXAMINE_POI_ADD_END)
    {
        //添加终点
        flag = INTO_TYPE_ADD_THROUGH_END;
    }else if ([POIDataCache sharedInstance].flag  ==EXAMINE_POI_ADD_FAV)
    {
        flag = INTO_TYPE_ADD_FAV;
    }
    [POICommon intoPOIViewController:self withIndex:indexPath.row withViewFlag:flag withPOIArray:_arraySearchData];
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

#pragma mark - MWPoiOperatorDelegate
-(void)search:(id)poiOperatorOption Error:(NSError *)error
{
    [self hideLoadingViewWithAnimated:NO];
    if (netWorkSearchBefore==YES) {
        [self  noSearchResultAlertView];
    }else
    {
        [self netWorkLoadMore];
    }
    
}
-(void)poiLocalSearch:(MWSearchOption*)poiSearchOption Result:(MWSearchResult *)result
{
    [self hideLoadingViewWithAnimated:NO];
        [_arraySearchData removeAllObjects];
        if (result.pois.count > 0) {
            //对检索出来的数据进行排序
            if (self.voiceType == MWVOICE_DATA_CMDID) {
                NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"lDistance" ascending:YES];
                NSArray * tempArray = [result.pois sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
                [_arraySearchData addObjectsFromArray:tempArray];
            }else
            {
                [_arraySearchData addObjectsFromArray:result.pois];
            }
            [_tableView reloadData];
        }
        else
        {
            [self netWorkLoadMore];
        }
}
#pragma mark NetReqToViewCtrDelegate
-(void)requestToViewCtrWithRequestType:(RequestType)requestType didFailWithError:(NSError *)error
{
    [self hideLoadingViewWithAnimated:YES];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(cancleLoading) object:nil];
    _firstRequest=NO;
    _bNetWorking = NO;
    
    if (_firstRequest) {
        [self locationSearch];
        return;
    }
    else
    {
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
    }
}
-(void)requestToViewCtrWithRequestType:(RequestType)requestType didFinishLoadingWithResult:(id)result
{
    [self hideLoadingViewWithAnimated:YES];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(cancleLoading) object:nil];
    _firstRequest=NO;
    _bNetWorking = NO;
    _pageCount=_pageCount+1;
    //2. 请求回来的数据的其他城市的结果
    if ([result objectForKey:@"citysuggestions"])
    {
        if (![[result objectForKey:@"citysuggestions"] objectForKey:@"citysuggestion"]) {
            [self noSearchResultAlertView];
            [self hideLoadingViewWithAnimated:YES];
            return;
        }
        NSArray *citysuggestions = nil;
        id   object = [[result objectForKey:@"citysuggestions"] objectForKey:@"citysuggestion"];
        if ([object isKindOfClass:[NSDictionary class]])
        {
            citysuggestions = [NSArray arrayWithObjects:object, nil];
        }
        else
        {
            citysuggestions = object;
        }
        
        _arraySearchDataOtherCity=[[NSMutableArray alloc]init];
        for (id arr in citysuggestions)
        {
            MWArea * area=[[MWArea alloc]init];
            area.lAdminCode=[[arr objectForKey:@"adcode"] intValue] ;
            area.lNumberOfSubAdarea=[[arr objectForKey:@"resultnum"] intValue];
            area.szAdminName=[arr objectForKey:[POICommon netGetKey:@"name"]];
            
            [_arraySearchDataOtherCity addObject:area];
            [area release];//010
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
           __block POIVoiceSearchViewController* voiceSearchViewController = self;
           __block POIOtherCityViewController * otherCityViewController=[[POIOtherCityViewController alloc] init];
            otherCityViewController.keyWord=voiceSearchViewController.cmdtxt;
            otherCityViewController.arrayOtherCityData=_arraySearchDataOtherCity;
            [voiceSearchViewController hideLoadingViewWithAnimated:YES];
            [voiceSearchViewController.navigationController pushViewController:otherCityViewController animated:YES];
            [otherCityViewController release];
        });
    }
    //1. 请求回来的数据在本地城市的结果
    else
    {
        NSDictionary * poilist=[result objectForKey:@"poilist"];
        _sizeCount = [[poilist objectForKey:@"count"] intValue];
        NSArray * poiArrayTmp = nil;
        if (_sizeCount >= 1)
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
                if (poi.szTown.length==0) {
                    MWAreaInfo * info = [MWAdminCode GetCurAdareaWith:[[arr objectForKey:@"adcode"] intValue]];
                    
                    poi.szAddr = [NSString stringWithFormat:@"%@%@",info.szProvName,info.szCityName];
                }
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
            [self noSearchResultAlertView];
        }
    }

}
- (void)NetRequestError
{
    GDAlertView *Myalert_ext = [[GDAlertView alloc] initWithTitle:nil andMessage:STR(@"Universal_networkError", Localize_Universal) ];
    [Myalert_ext addButtonWithTitle:STR(@"Universal_ok", Localize_Universal)  type:GDAlertViewButtonTypeCancel handler:nil];
    [Myalert_ext show];
    [Myalert_ext release];
}
-(void)noSearchResultAlertView
{
    [self hideLoadingViewWithAnimated:NO];
    GDAlertView *alertView=[[[GDAlertView alloc] initWithTitle:nil andMessage:STR(@"POI_NoSearchResult",Localize_POI)] autorelease];
    [alertView addButtonWithTitle:STR(@"POI_SearchAlertSure", Localize_POI) type:GDAlertViewButtonTypeCancel handler:nil];
    [alertView show];
}
-(void)cancleLoading
{
    if(_bNetWorking)
    {
        _bNetWorking = NO;
        [MWNetSearchOperator MWCancelNetSearchWith:REQ_NET_SEARCH_KERWORD];
        [self showLoadingViewInView:@"" view:self.view];
        [self locationSearch];
    }
}

-(void)buttonAction:(UIButton *)sender
{
    if (sender.tag==4) {
        if ([[ANDataSource sharedInstance] isNetConnecting] == 0)   //无网络连接
        {
            [self NetRequestError];
        }
        else
        {
            _pageCount=1;
            _firstRequest = NO;
            [_arraySearchData removeAllObjects];
            [_tableView reloadData];
            [self showLoadingViewInView:@"" view:self.view];
            [self netWorkSearch];
        }
    }
}
-(void)netWorkLoadMore
{
    
    if ([[ANDataSource sharedInstance] isNetConnecting] == 0)   //无网络连接
    {
        [self NetRequestError];
        
    }else
    {
        
        GDAlertView *alertView=[[[GDAlertView alloc] initWithTitle:nil andMessage:STR(@"POI_TryNetSearch",Localize_POI)] autorelease];
        [alertView addButtonWithTitle:STR(@"POI_Common_NO", Localize_POI) type:GDAlertViewButtonTypeCancel handler:nil];
        [alertView addButtonWithTitle:STR(@"POI_Common_YES",Localize_POI) type:GDAlertViewButtonTypeDefault handler:^(GDAlertView * alet){
            [self showLoadingViewInView:@"" view:self.view];
            [self netWorkSearch];
        }];
        [alertView show];
        return;
    }
}
@end

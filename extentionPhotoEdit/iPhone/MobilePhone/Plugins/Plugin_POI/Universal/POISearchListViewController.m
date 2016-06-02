//
//  POISearchListViewController.m
//  AutoNavi
//
//  Created by huang on 13-8-19.
//
//

#import "POISearchListViewController.h"
#import "MWSearchResult.h"
#import "ControlCreat.h"
#import "POISearchHistory.h"
#import "GDSearchListCell.h"
#import "POIOtherCityViewController.h"
#import "POIDataCache.h"
#import "POIDefine.h"
#import "POICommon.h"
#import "GDAlertView.h"
#import "POIToolBar.h"
#import "POICellButtonEvent.h"
#import "UMengEventDefine.h"
#import "MWNetSearchOperator.h"
#import "MWMapOperator.h"
#import "BottomMenuBar.h"
#define sizePageCount 20
@interface POISearchListViewController ()<NetReqToViewCtrDelegate,UIGestureRecognizerDelegate>
{
    POIToolBar           *_toolBar;
    POICellButtonEvent   *_cellButtonEvent;
    POISearchHistory     *_searchHistory;
    MWPoiOperator        *_poiOperator;
    GSEARCHTYPE           _localSearchType;
    BOOL isIntoOtherCity;
    BOOL _bMoreResult;  //是否有更多结果
    BOOL _bNetWorking;  //是否正在请求网络
    BOOL _firstRequest; //第一次网络搜素请求
    BOOL _bClickMore;   //是否点击更多结果
    
    NSInteger  _pageCount;//页数
    NSInteger  _sizeCount;//网络请求下来的条数
    UIImageView * _imageViewBg;
    UIImageView * _imageViewLine;
    UIImageView * _synchronousBg;
    UIButton    * _buttonName,*_buttonCrossroads,*_buttonAddress;
    UIButton    * _buttonSynchronous;
    
    
    NSMutableArray *_arraySearchData;         //用于存放搜索数据结果
    NSMutableArray *_arratSeatchDataOtherCity;//用于存放其他城市搜索结果
}

@property (nonatomic,retain) NSArray * arraySort;
@end


@implementation POISearchListViewController
@synthesize keyWord,arraySearchData=_arraySearchData,arraySort,recoveryKeyWorld;

#pragma mark -
#pragma mark viewcontroller ,
- (id)init
{
	self = [super init];
	if (self)
	{
        GSTATUS ret = [MWPoiOperator AbortSearchPOI];
        if (ret!=GD_ERR_OK) {

        }
	}
	return self;
}


- (void)dealloc
{
    self.arraySort = nil;
    CLOG_DEALLOC(self);
    CRELEASE(keyWord);
    CRELEASE(recoveryKeyWorld);
    CRELEASE(_cellButtonEvent);
    CRELEASE(_toolBar);
    _poiOperator.poiDelegate=nil;
    [_poiOperator release];
    CRELEASE(_searchHistory);
    CRELEASE(_arratSeatchDataOtherCity)
	[super dealloc];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
    _firstRequest = YES;
    _poiOperator=[[MWPoiOperator alloc] initWithDelegate:self];
    [self initControl];
    [self showLoadingViewInView:@"" view:self.view];

}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
     _cellButtonEvent.viewController=self;
    isIntoOtherCity=NO;
    self.navigationController.navigationBarHidden=NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MWNetSearchOperator MWCancelNetSearchWith:REQ_NET_SEARCH_KERWORD];
    //modify by wws for 本地请求返回时终止请求 at 2017-7-30
    GSTATUS res = [MWPoiOperator AbortSearchPOI];
    if (res == GD_ERR_OK ) {
        NSLog(@"＋＋＋＋＋＋＋＋＋＋＋＋＋＋＋＋＋＋");
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}
#pragma mark -
#pragma mark control related
//初始化控件
-(void) initControl{
    _pageCount=1;
    sortType=0;
    _synchronousBg = [self createImageViewWithFrame:CGRectZero normalImage:[IMAGE(@"SynchronizationBg.png", IMAGEPATH_TYPE_1) stretchableImageWithLeftCapWidth:2 topCapHeight:0] tag:0];
    [self.view addSubview:_synchronousBg];
    _synchronousBg.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
    _synchronousBg.frame=CGRectMake(0,CONTENTHEIGHT_V-58 , APPWIDTH,58);
    _synchronousBg.userInteractionEnabled=YES;
    _synchronousBg.hidden=YES;
    
    if ([[MWPreference sharedInstance] getValue:PREF_SKINTYPE] == 0)
    {
        _buttonSynchronous = [self createButtonWithTitle:nil normalImage:@"CommonBtn1.png" heightedImage:@"CommonBtn1.png" tag:4 strechParamX:5 strechParamY:10];
    }
    else
    {
        _buttonSynchronous = [self createButtonWithTitle:nil normalImage:@"CommonBtn1.png" heightedImage:@"CommonBtn2.png" tag:4 strechParamX:5 strechParamY:10];
    }
    _buttonSynchronous.frame=CGRectMake(10,6,APPWIDTH-2*10,40);
    _buttonSynchronous.tag=4;
    _buttonSynchronous.hidden=YES;
    [_synchronousBg addSubview:_buttonSynchronous];
    
    //设置背景
    _imageViewBg = [self createImageViewWithFrame:CGRectMake(0, 0, APPWIDTH, 40) normalImage:[IMAGE(@"TableCellBgFooter.png", IMAGEPATH_TYPE_1) stretchableImageWithLeftCapWidth:10 topCapHeight:25] tag:4001];
    _imageViewBg.userInteractionEnabled = YES;
    [self.view addSubview:_imageViewBg];
    _buttonName=[self allocButton:1 WithView:_imageViewBg];
    _buttonCrossroads=[self allocButton:2 WithView:_imageViewBg];
    
    //设置分割线
    _imageViewLine = [self createImageViewWithFrame:CGRectMake(0,40, APPWIDTH, 1) normalImage:[IMAGE(@"POIVerLine.png", IMAGEPATH_TYPE_1) stretchableImageWithLeftCapWidth:5 topCapHeight:0.5] tag:4002];
    [_imageViewBg addSubview:_imageViewLine];
    
    _toolBar=[[POIToolBar alloc] initWithView:_imageViewBg withHighlighted:0 withButtons:_buttonName,_buttonCrossroads,nil];
    _toolBar.type = POITOOLBAR_IN_BUTTON_FOOTER;
    [_toolBar refresh];
    
    searchType=0;
    _arraySearchData=[[NSMutableArray alloc] initWithCapacity:0];
    _searchHistory=[[POISearchHistory alloc] init];
    NSString *rightKey=sortType==0?@"POI_DefaultSort":@"POI_DistanceSort";
    self.navigationItem.leftBarButtonItem= LEFTBARBUTTONITEM(@"", @selector(leftBtnEvent:));
    self.navigationItem.rightBarButtonItem=RIGHTBARBUTTONITEM(STR(rightKey, Localize_POI), @selector(rightBarButtonAction:));
    
    
    
     self.navigationItem.rightBarButtonItem.enabled=NO;
    _cellButtonEvent=[[POICellButtonEvent alloc] init];
   
    
    self.title=self.keyWord;
    [_buttonName setTitle:STR(@"POI_NameSearch",Localize_POI) forState:UIControlStateNormal];
    [_buttonCrossroads setTitle:STR(@"POI_CrossSearch",Localize_POI) forState:UIControlStateNormal];
    [_buttonSynchronous setTitle:STR(@"POI_SearchMoreResult", Localize_POI) forState:UIControlStateNormal];
}
//调整控件竖屏坐标和图片
-(void)changePortraitControlFrameWithImage
{
     _buttonSynchronous.frame=CGRectMake(10,6,APPWIDTH-2*10,40);
    [_imageViewBg setFrame:CGRectMake(0, 0, APPWIDTH, 40)];
    [_imageViewLine setFrame:CGRectMake(0,40, APPWIDTH, 1.5)];
    float buttonHeight=42;
    float buttonY=0;
     
    float x=0;
    float width=(APPWIDTH-2*x)/2;
    _buttonName.frame=CGRectMake(x+width*0, buttonY, width, buttonHeight);
    _buttonCrossroads.frame=CGRectMake(x+width*1, buttonY, width, buttonHeight);
    _synchronousBg.frame=CGRectMake(0,CONTENTHEIGHT_V-52 , APPWIDTH,52);
    [_toolBar refresh];
    [self setButtonHidden:_synchronousBg.hidden];
    [_tableView reloadData];
}

//调整控件横屏坐标和图片
-(void)changeLandscapeControlFrameWithImage
{
     _buttonSynchronous.frame=CGRectMake(10,6,APPHEIGHT-2*10,40);
     [_imageViewBg setFrame:CGRectMake(0, 0, APPHEIGHT, 40)];
    [_imageViewLine setFrame:CGRectMake(0,40, APPHEIGHT, 1.5)];
    float buttonHeight=42;
    float buttonY=0;
    float x=0;
    float width=(APPHEIGHT-2*x)/2;
    _buttonName.frame=CGRectMake(x+width*0, buttonY, width, buttonHeight);
    _buttonCrossroads.frame=CGRectMake(x+width*1, buttonY, width, buttonHeight);
    [_toolBar refresh];
    
    _synchronousBg.frame=CGRectMake(0,CONTENTHEIGHT_H-52 ,APPHEIGHT,52);
    [self setButtonHidden:_synchronousBg.hidden];
    [_tableView reloadData];
}
//改变控件文本
-(void)changeControlText
{

}
-(void)leftBtnEvent:(id)object
{
    if(isIntoOtherCity)
        return;
    if (self.backType) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
        [self.navigationController popViewControllerAnimated:YES];
}
-(UIButton *)allocButton:(int)tag WithView:(UIView * )view
{
    UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:button];
    [button.titleLabel setFont:[UIFont systemFontOfSize:kSize2]];
    [button setTitleColor:GETSKINCOLOR(@"ToolBarSliderColor") forState:UIControlStateHighlighted];
    [button setTitleColor:GETSKINCOLOR(@"ToolBarSliderColor") forState:UIControlStateDisabled];
    [button setTitleColor:TOOLBARBUTTONCOLOR forState:UIControlStateNormal];
    button.tag=tag;
    
    return button;
}

- (void)setButtonHidden:(BOOL)hidden    //是否隐藏排序和更多按钮
{
    self.navigationItem.rightBarButtonItem.customView.hidden = hidden;
    _synchronousBg.hidden = hidden;
    _buttonSynchronous.hidden = hidden;
    if (hidden == YES)
    {
        [_tableView setFrame:CGRectMake(CCOMMON_TABLE_X,40, CCOMMON_APP_WIDTH-2*CCOMMON_TABLE_X, CCOMMON_CONTENT_HEIGHT-52+12)];
    }else
    {
        [_tableView setFrame:CGRectMake(CCOMMON_TABLE_X,40, CCOMMON_APP_WIDTH-2*CCOMMON_TABLE_X, CCOMMON_CONTENT_HEIGHT-104+12)];
    }
    
}

#pragma mark -
#pragma mark Action

-(void)buttonAction:(UIButton*)button
{// //搜索类型     0:普通关键字搜索 1:语音输入模式搜索 2:交叉路口搜索 可空,默认值=0
        
    int type;
    switch (button.tag-1) {
        case 0://0:普通关键字搜索
        {
            _pageCount = 1;
            //type=GSEARCH_TYPE_NAME;
            type=0;
        }
            break;
        case 1://交叉路口搜索
        {
            _pageCount=1;
             type=2;
        }
            break;
        case 3://联网获取更多
        {
            [self pwLoadMore];
            return;
        }break;
        case 2://纠错二次检索
        {
            self.keyWord = self.recoveryKeyWorld;
            self.recoveryKeyWorld = nil;
            self.title = self.keyWord;
            [_arraySearchData removeAllObjects];
             _pageCount=1;
            [self keyWordsearch];
       
            return;
        }break;
            
        default:
            break;
    }
   
    if (searchType!=type) {
        int currentSearchType=[[MWPreference sharedInstance] getValue:PREF_SEARCHTYPE];
        if (currentSearchType == 0)
        {//网络优先的时候
           [self setButtonHidden:YES];
        }else
        {
            [self setButtonHidden:NO];
        }
        
        //搜索
        _firstRequest = YES;
        [_arraySearchData removeAllObjects];
        self.recoveryKeyWorld = nil;
        [_tableView reloadData];
         searchType=type;
        [MWNetSearchOperator MWCancelNetSearchWith:REQ_NET_SEARCH_KERWORD];     //取消先前的请求
        
        [self keyWordsearch];
    }
}
-(void)rightBarButtonAction:(id)object
{
  
    sortType=!sortType;
    NSString *rightKey=sortType==0?@"POI_DefaultSort":@"POI_DistanceSort";

    self.navigationItem.rightBarButtonItem=RIGHTBARBUTTONITEM(STR(rightKey, Localize_POI), @selector(rightBarButtonAction:));
    
    //排序搜索
    if (_arraySearchData.count==0) {
        return;
    }
    
    if (sortType==0)
    {
        [_arraySearchData removeAllObjects];
        [_arraySearchData addObjectsFromArray:self.arraySort];
        [_tableView reloadData];
    }
    else
    {
        [self sortArray];
    }
}
//对数组进行排序
-(void)sortArray
{
    POISearchListViewController *weakSelf=self;
    NSMutableArray *blockArray=_arraySearchData;
    UITableView *blockTableView=_tableView;
    dispatch_async(dispatch_get_current_queue(), ^{
        self.navigationItem.rightBarButtonItem.enabled=NO;
        [weakSelf showLoadingViewInView:@"" view:weakSelf.view];
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"lDistance" ascending:YES];
        NSArray *tempArray = [blockArray sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
        [blockArray removeAllObjects];
        [blockArray addObjectsFromArray:tempArray];
        [weakSelf hideLoadingViewWithAnimated:YES];
        [blockTableView reloadData];
        self.navigationItem.rightBarButtonItem.enabled=YES;
        
    });

}
#pragma mark -
#pragma mark AllocMWPoiOperation
-(MWSearchOption*)allocSearchOperionWithType:(GSEARCHTYPE)type
{
    _localSearchType = type;
    MWSearchOption * searchOption=[[[MWSearchOption alloc] init] autorelease];
    searchOption.keyWord=self.keyWord;
    searchOption.operatorType=type;
    searchOption.sortType=sortType;
    return  searchOption ;

}

#pragma mark -
#pragma mark checking the network status
- (BOOL)isConnectNet
{
    int netType = [[ANDataSource sharedInstance] isNetConnecting];
    if (netType == 0) {
        return NO;
    }
    return YES;
}

#pragma mark -
#pragma mark  0 优先使用网络搜索; 1 优先使用本地搜索
-(void)keyWordsearch
{
    [self showLoadingViewInView:@"" view:self.view];
    int currentSearchType=[[MWPreference sharedInstance] getValue:PREF_SEARCHTYPE];
    switch (currentSearchType) {
        case 0:
        {
            //网络优先的时候
            if ([[ANDataSource sharedInstance] isNetConnecting] == 0)   //无网络连接
            {
                netSearchBeforeFlag=NO;
                [self locationSearch];
                
            }else
            {   netSearchBeforeFlag=YES;
                [self networkSearch];
            }

        }break;
        case 1:
        {
            netSearchBeforeFlag=NO;
            [self locationSearch];//本地检索
        }break;
    }
}
#pragma mark  本地检索
-(void)locationSearch
{
  
    MWSearchOption *searchOptain = nil;
    if (searchType == 2)
    {
        searchOptain=[self allocSearchOperionWithType:GSEARCH_TYPE_CROSS];
    }
    else
    {
        searchOptain=[self allocSearchOperionWithType:GSEARCH_TYPE_NAME];
    }
    
    int res=[_poiOperator poiLocalSearchWithOption:searchOptain];
    if (res) {
        bNetSearch = NO;
        self.navigationItem.rightBarButtonItem.enabled=NO;
    }
    [self setButtonHidden:NO];
}
#pragma mark 网络检索
-(void)networkSearch
{
    //网络优先并且有网络
    MWNetKeyWordSearchOption * keyWorldSearch=[[MWNetKeyWordSearchOption alloc]init];
    keyWorldSearch.searchtype=searchType;// //搜索类型     0:普通关键字搜索 1:语音输入模式搜索 2:交叉路口搜索 可空,默认值=0
    keyWorldSearch.search=self.keyWord;
    keyWorldSearch.page=_pageCount;//sizeCount;
    keyWorldSearch.size=20;
    keyWorldSearch.suggestion = @"false";
    //注意香港 澳门
   int adminCode=[MWAdminCode GetCityAdminCodeWithAdminCode:[MWAdminCode GetCurAdminCode]];
    if ([ANParamValue sharedInstance].isSelectCity==1) {
        MWAreaInfo * info = [MWAdminCode GetCurAdarea];
        adminCode = info.lAdminCode;
    }
    keyWorldSearch.adcode=[NSString stringWithFormat:@"%d",adminCode];
    if (_firstRequest)
    {
        [self performSelector:@selector(cancleLoading) withObject:nil afterDelay:5.0];  //第一次五秒后判断是否转本地
    }
    GSTATUS res = [MWNetSearchOperator MWNetKeywordSearchWith:REQ_NET_SEARCH_KERWORD option:
                   keyWorldSearch delegate:self];
    if (res == GD_ERR_OK)
    {
        bNetSearch = YES;
        _bNetWorking=YES;
    }
    [self setButtonHidden:YES];
    [keyWorldSearch release];
}
#pragma mark 5 秒转本地
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
#pragma mark 联网获取更多
-(void)pwLoadMore
{
    if ([[ANDataSource sharedInstance] isNetConnecting] == 0)   //无网络连接
    {
        [self NetRequestError];
    }
    else
    {
        bNetSearch=YES;
        _pageCount = 1;
        _firstRequest = NO;
        _bClickMore = YES;
        [_arraySearchData removeAllObjects];
        [_tableView reloadData];
        
        [self showLoadingViewInView:@"" view:self.view];
        [self networkSearch];
    }
}
#pragma mark 弹出是否使用网络搜索
- (void)PopNetSearch
{
    GDAlertView *alertView=[[[GDAlertView alloc] initWithTitle:nil andMessage:STR(@"POI_TryNetSearch",Localize_POI)] autorelease];
    [alertView addButtonWithTitle:STR(@"POI_Common_NO", Localize_POI) type:GDAlertViewButtonTypeCancel handler:nil];
    [alertView addButtonWithTitle:STR(@"POI_Common_YES",Localize_POI) type:GDAlertViewButtonTypeDefault handler:^(GDAlertView * alet)
     {
         //网络优先的时候
         if ([[ANDataSource sharedInstance] isNetConnecting] == 0)   //无网络连接
         {
             [self NetRequestError];
         }else
         {
             [self setButtonHidden:YES];
             _firstRequest = NO;
             [self showLoadingViewInView:@"" view:self.view];
             [self networkSearch];
         }
         
         
     }];
    [alertView show];
}
#pragma mark NetReqToViewCtrDelegate
- (void)requestToViewCtrWithRequestType:(RequestType)requestType didFailWithError:(NSError *)error
{
       [self hideLoadingViewWithAnimated:YES];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(cancleLoading) object:nil];
    if (requestType==REQ_NET_SEARCH_KERWORD)
    {
        if (_bClickMore)
        {
            [self NetRequestError];
        }
        else
        {
            if (netSearchBeforeFlag==YES)
            {
                if (_firstRequest)
                {
                    [self showLoadingViewInView:@"" view:self.view];
                    [self locationSearch];
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
            else
            {
                [self NetRequestError];
            }
        }
    }
 
    _bNetWorking = NO;
    _firstRequest = NO;
    _bClickMore = NO;
}

-(void)requestToViewCtrWithRequestType:(RequestType)requestType didFinishLoadingWithResult:(id)result
{
    [self hideLoadingViewWithAnimated:YES];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(cancleLoading) object:nil];
    _bNetWorking = NO;
    _bClickMore = NO;
    _pageCount=_pageCount+1;
    //1. 请求回来的数据的推荐城市的结果
    if ([result objectForKey:@"citysuggestions"])
    {
        [_arraySearchData removeAllObjects];
        [_tableView reloadData];
        //如果没有推荐城市就转向本地检索
        NSDictionary  * pinyinDictionary = [[result objectForKey:@"pinyin"] objectForKey:@"list"];
        if (![pinyinDictionary isKindOfClass:[NSDictionary class]])
        {
            self.recoveryKeyWorld = nil;
        }
        else
        {
            self.recoveryKeyWorld = [pinyinDictionary objectForKey:@"data"];
        }
        if (![[result objectForKey:@"citysuggestions"] objectForKey:@"citysuggestion"]&&!pinyinDictionary)
        {
            //本地城市无结果 推荐城市也无结果 直接显示纠错信息
            NSDictionary * poilist=[result objectForKey:@"poilist"];
            NSDictionary  * pinyinDictionary1 = [[poilist objectForKey:@"pinyin"] objectForKey:@"list"];
            if (![pinyinDictionary1 isKindOfClass:[NSDictionary class]])
            {
                self.recoveryKeyWorld = nil;
            }else
            {
                self.recoveryKeyWorld = [pinyinDictionary1 objectForKey:@"data"];
                [_tableView reloadData];
                return;
            }
            //没有纠错转向本地检索
            if (netSearchBeforeFlag == YES) {
                [self locationSearch];
            }else
            {
                
                [self searchResultNullAlert];
            }
            [self hideLoadingViewWithAnimated:YES];
            return;
        }
        [_searchHistory addHistory:self.keyWord];
        NSArray * citysuggestions = nil;
        id   object = [[result objectForKey:@"citysuggestions"] objectForKey:@"citysuggestion"];
        if ([object isKindOfClass:[NSDictionary class]])
        {
            citysuggestions = [NSArray arrayWithObjects:object, nil];
        }
        else
        {
            citysuggestions = object;
        }
        _arratSeatchDataOtherCity=[[NSMutableArray alloc]init];
        for (id arr in citysuggestions) {
            MWArea * area=[[MWArea alloc]init];
            area.lAdminCode=[[arr objectForKey:@"adcode"] intValue] ;
            area.lNumberOfSubAdarea=[[arr objectForKey:@"resultnum"] intValue];
            area.szAdminName=[arr objectForKey:[POICommon netGetKey:@"name"]];
            [_arratSeatchDataOtherCity addObject:area];
            [area release];
        }
        [self showLoadingViewInView:@"" view:self.view];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            isIntoOtherCity=YES;
            [self hideLoadingViewWithAnimated:YES];
            __block POISearchListViewController * searchListViewController = self;
            __block POIOtherCityViewController * otherCityViewController = [[POIOtherCityViewController alloc] init];
            otherCityViewController.searchType=searchType;
            otherCityViewController.keyWord=searchListViewController.keyWord;
            otherCityViewController.arrayOtherCityData=_arratSeatchDataOtherCity;
            otherCityViewController.recoveryKeyWorld = searchListViewController.recoveryKeyWorld;
            [searchListViewController hideLoadingViewWithAnimated:YES];
            [searchListViewController.navigationController pushViewController:otherCityViewController animated:YES];
            [otherCityViewController release];
            searchListViewController.recoveryKeyWorld = nil;
        });
        
    }
    //2. 请求回来的数据是本地城市的结果
    else
    {
        
        NSDictionary * poilist=[result objectForKey:@"poilist"];
        NSDictionary  * pinyinDictionary = [[poilist objectForKey:@"pinyin"] objectForKey:@"list"];
        if (![pinyinDictionary isKindOfClass:[NSDictionary class]])
        {
            self.recoveryKeyWorld = nil;
        }else
        {
            self.recoveryKeyWorld = [pinyinDictionary objectForKey:@"data"];
        }
        int count=[[poilist objectForKey:@"count"] intValue];
        _sizeCount=count;
        NSArray *poiArrayTmp = nil;
        if (_sizeCount >= 1)
        {
            [_searchHistory addHistory:self.keyWord];
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
            if (netSearchBeforeFlag == YES) {
                [self locationSearch];
            }else
            {
                [self searchResultNullAlert];
            }
            
            return;
        }
        [self hideLoadingViewWithAnimated:YES];
    }
    _firstRequest = NO;
    
}
#pragma mark -
#pragma mark MWPoiOperatorDelegate
-(void)search:(id)poiOperatorOption Error:(NSError *)error
{
    [self hideLoadingViewWithAnimated:YES];
    if (netSearchBeforeFlag == NO) {
    if (_localSearchType == GSEARCH_TYPE_CROSS)
    {
        if ([_arraySearchData count] == 0)
        {
            [_tableView reloadData];
            [self PopNetSearch];
        }
        else
        {
            [_tableView reloadData];
        }
    }
    else if (_localSearchType == GSEARCH_TYPE_NAME)  //名称搜索失败，转门址搜索
    {
        [self showLoadingViewInView:@"" view:self.view];
        double delayInSeconds = 0.5;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            __block MWSearchOption * searchOptain=[self allocSearchOperionWithType:GSEARCH_TYPE_ADDRESS];
            int res=[_poiOperator poiLocalSearchWithOption:searchOptain];
            if (res) {
                self.navigationItem.rightBarButtonItem.enabled=NO;
            }
        });
        return;
    }
    
    else  if (_localSearchType == GSEARCH_TYPE_ADDRESS)
    {
        if ([_arraySearchData count] == 0)
        {
            [_tableView reloadData];
            [self PopNetSearch];
            
        }
        else
        {
            [_tableView reloadData];
        }
    }
    self.navigationItem.rightBarButtonItem.enabled=YES;
    }else
    {
        netSearchBeforeFlag = NO;
        [_tableView reloadData];
        [self searchResultNullAlert];
    }
}
-(void)poiLocalSearch:(MWSearchOption*)poiSearchOption Result:(MWSearchResult *)result
{
    [self hideLoadingViewWithAnimated:NO];
    for (id object in result.pois) {
        MWPoi *poi = (MWPoi *)object;
        if (_localSearchType == GSEARCH_TYPE_ADDRESS)
        {
            poi.lHilightFlag = (poi.lHilightFlag | 0x80000000);   //高位至1
        }
        else
        {
            poi.lHilightFlag =  poi.lHilightFlag & 0x7fffffff;  //高位至0
        }
        [_arraySearchData addObject:object];
    }
    if ([_arraySearchData count] > 0)
    {
        [_searchHistory addHistory:self.keyWord];
    }
    self.arraySort = [NSArray arrayWithArray:_arraySearchData];
    if (sortType == 1)
    {
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"lDistance" ascending:YES];
        NSArray *tempArray = [_arraySearchData sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
        [_arraySearchData removeAllObjects];
        [_arraySearchData addObjectsFromArray:tempArray];
    }
    //路口
    if (_localSearchType == GSEARCH_TYPE_CROSS)
    {
        if ([_arraySearchData count] == 0)
        {
            [_tableView reloadData];
            [self PopNetSearch];
        }
        else
        {
            netSearchBeforeFlag = NO;
            [_tableView reloadData];
        }
    }
    else
    {
        if (result.pois.count>=5)
        {
            netSearchBeforeFlag = NO;
            [_tableView reloadData];
        }
        else
        {
            if (_localSearchType == GSEARCH_TYPE_NAME)  //名称搜索条数<5，转门址搜索
            {
                [self showLoadingViewInView:@"" view:self.view];
                double delayInSeconds = 0.5;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    __block MWSearchOption * searchOptain=[self allocSearchOperionWithType:GSEARCH_TYPE_ADDRESS];
                    int res=[_poiOperator poiLocalSearchWithOption:searchOptain];
                    if (res) {
                        self.navigationItem.rightBarButtonItem.enabled=NO;
                    }
                });
                return;
            }
            else if (_localSearchType == GSEARCH_TYPE_ADDRESS)
            {
                if ([_arraySearchData count] == 0)
                {
                    [_tableView reloadData];
                    [self PopNetSearch];
                }
                else
                {
                    netSearchBeforeFlag = NO;
                    [_tableView reloadData];
                }
            }
        }
    }
    self.navigationItem.rightBarButtonItem.enabled=YES;
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
        MWPoi * poi=[_arraySearchData objectAtIndex:path.row];
        [_cellButtonEvent buttonTouchEvent:poi];
        
    }
}

#pragma mark - 
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

#pragma mark -
#pragma mark UITableViewDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.recoveryKeyWorld.length>0 ? 2 : 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section ==0&&self.recoveryKeyWorld.length>0)
    {
        return 1;
    }else
    {
        if (_arraySearchData.count>0)
        {
            if (bNetSearch)
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
            else
            {
                _bMoreResult = NO;
                return [_arraySearchData count];
            }
        }
    }
    return 0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==0&&self.recoveryKeyWorld.length>0) {
        return kHeight5;
    }
    return kHeight5+10;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return  0;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * CellIdentifier1 = @"Cell";
    static NSString * CellIdentifier2 = @"cell2";
    if (indexPath.section ==0&&self.recoveryKeyWorld.length>0)
    {
        GDTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1];
        if (cell ==nil) {
            cell = [[GDTableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier1];
        }//移除掉表格的复用
        UILabel  * labelSearchFor =(UILabel *)[cell viewWithTag:5];
        UIButton * recoveryButton = (UIButton *)[cell viewWithTag:3];
        if (labelSearchFor) {
            [labelSearchFor removeFromSuperview];labelSearchFor = nil;
        }
        if (recoveryButton) {
            [recoveryButton removeFromSuperview];recoveryButton = nil;
        }
        labelSearchFor = [self createLabelWithText:STR(@"POI_SearchingFor", Localize_POI) fontSize:kSize2 textAlignment:NSTextAlignmentCenter];
        labelSearchFor.textColor = [UIColor colorWithRed:120.0/255.0f green:120.0/255.0f blue:120.0/255.0f alpha:1.0];
        labelSearchFor.tag = 5;
        CGSize textSize = [labelSearchFor.text sizeWithFont:labelSearchFor.font];
        [labelSearchFor setFrame:CGRectMake(5, 0, textSize.width, kHeight5)];
        [cell addSubview:labelSearchFor];
        
         recoveryButton = [self createButtonWithTitle:self.recoveryKeyWorld normalImage:@"" heightedImage:@"" tag:3 withImageType:IMAGEPATH_TYPE_1];
        [recoveryButton setTitleColor:[UIColor colorWithRed:55.0/255.0f green:135.0/255.0f blue:51/255.0f alpha:1.0] forState:UIControlStateNormal];
        CGSize buttonSize = [self.recoveryKeyWorld sizeWithFont:labelSearchFor.font];
        [recoveryButton setFrame:CGRectMake(5+textSize.width+5, 0, buttonSize.width+10, kHeight5)];
        labelSearchFor.numberOfLines = 2;
        [cell addSubview:recoveryButton];
        return cell;
    }
    else
    {
        GDSearchListCell *  cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier2];
        if (cell == nil) {
            cell = [[[GDSearchListCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier2] autorelease];
            [cell.naviButton addTarget:self action:@selector(naviEvent:) forControlEvents:UIControlEventTouchUpInside];
        }
        cell.type = SEARCH_CELL_LINE_TYPE;
        cell.emptyLineLength = 0;
        UILabel *laberLoadMore = (UILabel *)[cell viewWithTag:4001];  //移除lable，防止复用cell的时候出现
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
        if (_arraySearchData.count>0) {
            if (bNetSearch==YES)//网络
            {
                if (_bMoreResult==YES && indexPath.row == [_arraySearchData count]) //有更多，最后一个cell为“获取更多结果”
                {
                    laberLoadMore = [self createLabelWithText:STR(@"POI_GetMoreResult", Localize_POI) fontSize:kSize2 textAlignment:NSTextAlignmentCenter];
                    [laberLoadMore setFrame:CGRectMake(0, 0, _tableView.bounds.size.width, kHeight5)];
                    laberLoadMore.tag = 4001;
                    laberLoadMore.textColor = TEXTCOLOR;
                    [cell addSubview:laberLoadMore];
                    
                    CGSize textSize = [laberLoadMore.text sizeWithFont:laberLoadMore.font];
                    UIActivityIndicatorView * acti=[[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];;
                    [acti setCenter:CGPointMake(laberLoadMore.bounds.size.width/2-textSize.width/2 - 10,(kHeight5 + 10)/2)];
                    [acti startAnimating];
                    [laberLoadMore addSubview:acti];
                    
                    cell.labelNaviGation.text = nil;
                    cell.imageViewLine.hidden = YES;
                    cell.labelName.hidden = YES;
                    cell.labelAddress.hidden = YES;
                    cell.imageViewButton.hidden = YES;
                    cell.naviButton.hidden = YES;
                    cell.detailTextLabel.hidden = YES;
                    
                    
                }
                else
                {
                    cell.imageViewLine.hidden = NO;
                    cell.detailTextLabel.hidden=NO;
                    cell.textLabel.text = nil;
                    cell.textLabel.hidden = YES;
                    cell.labelName.hidden = NO;
                    cell.labelAddress.hidden = NO;
                    cell.imageViewButton.hidden = NO;
                    cell.naviButton.hidden = NO;
                    [self tableView:indexPath cell:cell];
                    
                }
            }
            else//本地
            {
                [self tableView:indexPath cell:cell];
            }
        }
        return cell;
    }

}
-(void)tableView:(NSIndexPath *)indexPath cell:(GDSearchListCell *)cell
{
    MWPoi * item = [_arraySearchData objectAtIndex:indexPath.row];
    cell.poi=item;
    
    if (item.lHilightFlag & 0x80000000)     //高位1是门址搜索，否则为名称或路口搜索
    {
        NSArray *array = [cell.labelAddress.text componentsSeparatedByString:@" "];
        if ([array count] > 1)
        {
            int length = [[array objectAtIndex:0] length];
            cell.labelAddress.m_HilightFlag = item.lHilightFlag << length+1;
        }
        else
        {
            cell.labelAddress.m_HilightFlag = item.lHilightFlag;
        }
        cell.labelName.m_HilightFlag =  0;
        
    }
    else
    {
        cell.labelName.m_HilightFlag = item.lHilightFlag;
        cell.labelAddress.m_HilightFlag = 0;
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
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    [self hideLoadingViewWithAnimated:YES];
    //做个容错处理 
    if(self.recoveryKeyWorld&&indexPath.section==0)
    {
        return;
    }
    int flag;
    POIDataCache *dataCache=[POIDataCache sharedInstance];
    if (dataCache.flag==EXAMINE_POI_NO) {
        //普通情况下
        flag=INTO_TYPE_NORMAL;
    }
    else if(dataCache.flag==EXAMINE_POI_ADD_FAV)
    {
        //添加家 或公司
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
    if (_arraySearchData&&flag) {
        
        if (indexPath.row >= [_arraySearchData count])
        {
            return;
        }
    
    [POICommon intoPOIViewController:self withIndex:indexPath.row withViewFlag:flag withPOIArray:_arraySearchData];
    }
}
-(void)searchResultNullAlert
{
    GDAlertView *alertView=[[[GDAlertView alloc] initWithTitle:nil andMessage:STR(@"POI_NoSearchResult",Localize_POI)] autorelease];
    [alertView addButtonWithTitle:STR(@"POI_SearchAlertSure", Localize_POI) type:GDAlertViewButtonTypeCancel handler:^(GDAlertView *ale)
     {
         [self hideLoadingViewWithAnimated:YES];
     }];
    [alertView show];
}

- (void)NetRequestError
{
    GDAlertView *Myalert_ext = [[GDAlertView alloc] initWithTitle:nil andMessage:STR(@"Universal_networkError", Localize_Universal) ];
    [Myalert_ext addButtonWithTitle:STR(@"Universal_ok", Localize_Universal)  type:GDAlertViewButtonTypeCancel handler:nil];
    [Myalert_ext show];
    [Myalert_ext release];
}
@end

//
//  CarServiceViewController.m
//  AutoNavi
//
//  Created by jiangshu-fu on 14-3-7.
//
//

#import "CarServiceViewController.h"
#import "CarServiceItemView.h"
#import "CarServiceJavascriptBridge.h"
#import "CarServiceMoreViewController.h"
#import "CarServiceDetailViewController.h"
#import "GDActionSheet.h"
#import "GDCacheManager.h"
#import "MWCarOwnerServiceManage.h"
#import "QLoadingView.h"
#import "HtmlFiveViewController.h"
#import "GDBL_Account.h"
#import "PluginStrategy.h"
#import "Plugin_Account.h"
#import "UMengEventDefine.h"
#import "MainDefine.h"



@interface CarServiceViewController ()
{
    UIBarButtonItem *_rightItem;
}

@end

@implementation CarServiceViewController

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(downloadComplete)
                                                 name:CAR_SERVICE_NOTIFICATION_KEY
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleUIUpdate:)
                                                 name:NOTIFY_HandleUIUpdate
                                               object:nil];
    
    [self initControl];
    
    
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -
#pragma mark viewcontroller
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
    [ANParamValue sharedInstance].beFirstNewFun = 0;
    
    if(_arrayCarServices)
    {
        [_arrayCarServices release];
        _arrayCarServices = nil;
    }
    if(_carserviceJavascriptBridege)
    {
        [_carserviceJavascriptBridege release];
        _carserviceJavascriptBridege = nil;
    }
    [MWCarOwnerServiceManage sharedInstance].reqDelegare = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}
// Called when the view is about to made visible. Default does nothing
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    [GDAlertView shouldAutorotate:NO];
    [ANParamValue sharedInstance].beFirstNewFun = 1;
    [_carserviceJavascriptBridege setDelegateWith:self];
    [MWCarOwnerServiceManage sharedInstance].reqDelegare = self;
    if(_isClickMore)
    {
        [self reloadCarServiceViewController];
    }
    
}
// Called when the view has been fully transitioned onto the screen. Default does nothing

- (void)viewDidAppear:(BOOL)animated
{
    
    [super viewDidAppear:animated];
    _isViewAppear = YES;
    [self loginBack];
}
// Called when the view is dismissed, covered or otherwise hidden. Default does nothing

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MWCarOwnerServiceManage sharedInstance].reqDelegare = nil;
    NSLog(@"reqDelegare....... = nil");
    [GDAlertView shouldAutorotate:YES];
    [_carserviceJavascriptBridege setDelegateWith:nil];
    _isViewAppear = NO;
}

// Called after the view was dismissed, covered or otherwise hidden. Default does nothing
-(void)viewDidDisappear:(BOOL)animated;
{
    [super viewDidDisappear:animated];
    
}

#pragma mark -
#pragma mark control related
//初始化控件
-(void) initControl{
    //天气的网页
    _isFromLoginInView = NO;
    _isRefresh = NO;
    _isRequestFail = YES;
    _isReloadCarServiceItem = NO;
    _isViewAppear = NO;
    _isRequestWeb = NO;
    _isClickMore = NO;
    _webViewWeather = [[UIWebView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, isiPhone? (524.0f / 2): (542.0f/2))];
    if((float)NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_5_0)
    {
        _webViewWeather.scrollView.bounces = NO;
    }
    [self loadRequest:WEATHER_URL isLocation:NO];
    [self.view addSubview:_webViewWeather];
    [_webViewWeather release];
    
    _scrollerViewItems = [[UIScrollView alloc]init];
     _scrollerViewItems.backgroundColor=[UIColor clearColor];
    [self.view addSubview:_scrollerViewItems];
    [_scrollerViewItems release];
    //服务的数据
    _arrayCarServices = [[NSMutableArray alloc]init];
    
    
    //JavaScript bridge 数据处理
    _carserviceJavascriptBridege = [[CarServiceJavascriptBridge alloc] initWithWebview:_webViewWeather
                                                                   withwebViewDelegate:self];
    __block CarServiceViewController *blockSelf = self;
    _carserviceJavascriptBridege.webOpenUrl = ^(NSString *url, BOOL isOpenLocal , BOOL isBrowse,NSString *title){
        if(isOpenLocal)
        {
            HtmlFiveViewController *webViewController = [[HtmlFiveViewController alloc] initWithWebUrl:url
                                                                                             withTitle:title
                                                                                           withBrowser:isBrowse];
            [blockSelf presentModalViewController:webViewController animated:YES];
            [webViewController release];
        }
        else
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        }
        
    };
    

    [_webViewWeather setScalesPageToFit:YES];                    //自动缩放页面以适应屏幕
    
    
    //低栏
    _imageViewTips = [[UIImageView alloc]init];
    _imageViewTips.backgroundColor = RGBACOLOR(255.0f, 255.0f, 255.0f, 0.56f);
    _imageViewTips.userInteractionEnabled = YES;

    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    if([ud objectForKey:CARSERVICE_SAVE_CLOSE_KEY])
    {
        _imageViewTips.hidden = [[ud objectForKey:CARSERVICE_SAVE_CLOSE_KEY] boolValue];
    }
    else
    {
        [ud setObject:[NSNumber numberWithBool:NO] forKey:CARSERVICE_SAVE_CLOSE_KEY];
    }
    
    //文字设置
    _labelTips = [[UILabel alloc]init];
    _labelTips.text = STR(@"CarService_Tips", Localize_CarService);
    _labelTips.backgroundColor = [UIColor clearColor];
    _labelTips.textAlignment = NSTextAlignmentLeft;
    _labelTips.numberOfLines = 2;
    _labelTips.lineBreakMode = NSLineBreakByWordWrapping;
    _labelTips.font  = [UIFont systemFontOfSize:12.0f];
    [_imageViewTips addSubview:_labelTips];
    [_labelTips release];
    
    _buttonClose = [UIButton buttonWithType:UIButtonTypeCustom];
    [_buttonClose setImage:IMAGE(@"CarServiceCloseTips.png", IMAGEPATH_TYPE_1) forState:UIControlStateNormal];
    [_buttonClose setImage:IMAGE(@"CarServiceCloseTipsPress.png", IMAGEPATH_TYPE_1) forState:UIControlStateHighlighted];
    [_buttonClose addTarget:self action:@selector(closeButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    [_imageViewTips addSubview:_buttonClose];
    
    [self.view addSubview:_imageViewTips];
    [_imageViewTips release];
    
    _buttonBack = [UIButton buttonWithType:UIButtonTypeCustom];
    [_buttonBack setImage:IMAGE(@"carServiceBack.png", IMAGEPATH_TYPE_1) forState:UIControlStateNormal];
    [_buttonBack setImage:IMAGE(@"carServiceBackPress.png", IMAGEPATH_TYPE_1) forState:UIControlStateHighlighted];
    [_buttonBack addTarget:self action:@selector(leftBtnEvent:) forControlEvents:UIControlEventTouchUpInside];
    [_webViewWeather addSubview:_buttonBack];
    
    _buttonReload = [UIButton buttonWithType:UIButtonTypeCustom];
    [_buttonReload setImage:IMAGE(@"carServiceBackReload.png", IMAGEPATH_TYPE_1) forState:UIControlStateNormal];
    [_buttonReload setImage:IMAGE(@"carServiceBackReloadPress.png", IMAGEPATH_TYPE_1) forState:UIControlStateHighlighted];
    [_buttonReload addTarget:self action:@selector(rightBtnEvent:) forControlEvents:UIControlEventTouchUpInside];
    [_webViewWeather addSubview:_buttonReload];
    
//    //导航条
//    NSString *tmpTitle;
//    tmpTitle = STR(@"CarService_carService", Localize_CarService);
//    _navigationBar = [POICommon allocNavigationBar:nil];
//    //...左上角按钮
//    UINavigationItem *navigationitem = [POICommon allocNavigationItem:tmpTitle rightTitle:STR(@"CarService_Refresh", Localize_CarService)];
//    
//    UIBarButtonItem *item=LEFTBARBUTTONITEM(@"", @selector(leftBtnEvent:));
//    //...右上角按钮
//    _rightItem = RIGHTBARBUTTONITEM(STR(@"CarService_Refresh", Localize_CarService), @selector(rightBtnEvent:));
//    [navigationitem setRightBarButtonItem:_rightItem];
//    [navigationitem setLeftBarButtonItem:item];
//    [_navigationBar pushNavigationItem:navigationitem animated:NO];
//    [self.view addSubview:_navigationBar];
    [self requestCarServiceItems];
    
}

- (void) loadRequest:(NSString *)urlString isLocation:(BOOL)isLocation
{
    if(_isRequestWeb)
    {
        NSLog(@"........._isRequestWeb return");
        return;
    }
    _isRequestWeb = YES;
    NSURL *url;
    if(isLocation)
    {
        url = [[NSURL alloc]initFileURLWithPath:urlString];
    }
    else
    {
        url = [NSURL URLWithString:urlString];
    }
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:60.0f];
    [_webViewWeather loadRequest:request];
    if(isLocation)
    {
        [url release];
    }
  
}

- (void)setWebViewFrame
{
    float totalHeight=[[_webViewWeather stringByEvaluatingJavaScriptFromString:@"document.documentElement.scrollHeight"] intValue] ;
    [_webViewWeather setFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, totalHeight )];
    NSLog(@"setWebViewFrame___%lf",totalHeight);
    [self changePortraitControlFrameWithImage];
}

//调整控件竖屏坐标和图片
-(void)changePortraitControlFrameWithImage
{
    float screenHeight = MAIN_POR_HEIGHT;
    float screenWidth = MAIN_POR_WIDTH;
    if (isiPhone) {

        [_scrollerViewItems setFrame:CGRectMake(0.0f,
                                                _webViewWeather.frame.size.height + _webViewWeather.frame.origin.y,
                                                screenWidth,
                                                screenHeight - (_webViewWeather.frame.origin.y + _webViewWeather.frame.size.height))];
        
        
        [_imageViewTips setFrame:CGRectMake(0.0f, screenHeight - 54.0f  , screenWidth, 54.0f)];
        [_labelTips setFrame:CGRectMake(20.0f, 0.0f, screenWidth - 70.0f, 54.0f)];
        [_buttonClose setFrame:CGRectMake(screenWidth - 50.0f, 0.0f, 50.0f, 54.0f)];
        [self reloadCarServicesRect];
        
        float backWidth = 136/2;
        float backHeight = 106/2;
        [_buttonReload setFrame:CGRectMake(screenWidth - backWidth, DIFFENT_STATUS_HEIGHT, backWidth, backHeight)];
        [_buttonBack setFrame:CGRectMake(0.0f, DIFFENT_STATUS_HEIGHT, backWidth, backHeight)];
    }
    else
    {
        [_scrollerViewItems setFrame:CGRectMake(0.0f,
                                                 _webViewWeather.frame.size.height + _webViewWeather.frame.origin.y,
                                                screenWidth,
                                                screenHeight - (_webViewWeather.frame.origin.y + _webViewWeather.frame.size.height))];
        
        [_imageViewTips setFrame:CGRectMake(0.0f, screenHeight - 54.0f  , screenWidth, 54.0f)];
        [_labelTips setFrame:CGRectMake(30.0, 0.0f, screenWidth - 80.0f, 54.0f)];
        [_buttonClose setFrame:CGRectMake(screenWidth - 50.0f, 0.0f, 50.0f, 54.0f)];
        [self reloadCarServicesRect];
        
        float backWidth = 204/2;
        float backHeight = 160/2;
        [_buttonReload setFrame:CGRectMake(screenWidth - backWidth, DIFFENT_STATUS_HEIGHT, backWidth, backHeight)];
        [_buttonBack setFrame:CGRectMake(0.0f, DIFFENT_STATUS_HEIGHT, backWidth, backHeight)];
    }
    
}

/***
 * @name
 * @param
 * @author  by bazinga
 ***/
- (void) reloadCarServicesRect
{
    float buttonWidth = isiPhone ? 60.0f : 72.0f; //按钮的宽度 CarServiceItemView
    
    float topMargins = 16.0f;
    float leftMargins = (MAIN_POR_WIDTH - 4 * buttonWidth ) / 5;
    float bottomMargins = 16.0f;
    
    if(!isiPhone)
    {
        topMargins = 96.0f;
        bottomMargins = 57.0f;
    }
    
    for (int i = 0; i < _arrayCarServices.count; i++) {
        CarServiceItemView *temp = [_arrayCarServices objectAtIndex:i];
        int row =  i / 4.0f;
        int range = i % 4;
        [temp setFrame:CGRectMake( (range + 1) * leftMargins + range * temp.frame.size.width ,
                                  topMargins + row * (temp.frame.size.height + bottomMargins),
                                  temp.frame.size.width,
                                  temp.frame.size.height)];
    }
    [_scrollerViewItems setContentSize:CGSizeMake(_scrollerViewItems.frame.size.width,
                                                  topMargins +  ceil(_arrayCarServices.count / 4.0f ) * (CARSERVICE_ITEMVIEW_HEIGHT + bottomMargins))];
}

#pragma mark - ---  按钮响应事件  ---
- (void) leftBtnEvent:(id)sender
{
    [ANParamValue sharedInstance].beFirstNewFun = 0;
    [self dismissModalViewControllerAnimated:NO];
}

- (void)rightBtnEvent:(id)object
{
    [self loadRequest:WEATHER_URL isLocation:NO];
    [self requestCarServiceItems];
}

/***
 * @name    关闭提示栏的按钮点击
 * @param
 * @author  by bazinga
 ***/
- (void) closeButtonPress:(id) sender
{
    //设置隐藏
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES]
                                              forKey:CARSERVICE_SAVE_CLOSE_KEY];
    
    _imageViewTips.hidden = YES;
}

- (void) loginBack
{
    if(_isFromLoginInView)
    {
        NSArray *arr;
        GDBL_GetAccountInfo(&arr);
        int loginState=[[arr objectAtIndex:0] intValue];
        //判断是否登入成功
        if (loginState!=0)
        {
            [self VerifyLoginIn:_longPressTask];
            
        }
        else
        {
            _isFromLoginInView = NO;
        }
        _isFromLoginInView = NO;
    }
    else
    {
        if(_isRefresh)
        {
            _isRefresh = NO;
            [self requestCarServiceItems];
        }
    }
    
}

- (void) downloadComplete
{
    _isRefresh = YES;
    NSLog(@"-------------_isRefresh");
}

#pragma  mark - ---  更新界面通知  ---
- (void) handleUIUpdate:(NSNotification *)result
{
    switch ([[result object] intValue]) {
        case UIUpdate_CarServiceDownloadFinish:
        {
            NSLog(@"-------------handleUIUpdate");
            if(!_isViewAppear)
            {
                NSLog(@"____________________________!_isViewAppear");
                [self downloadComplete];
            }
            else
            {
                 NSLog(@"_____________________________isViewAppear");
                [self performSelectorOnMainThread:@selector(requestCarServiceItems) withObject:nil waitUntilDone:YES];
                _isRefresh = NO;
            }
        }
            break;
        default:
            break;
    }

}

#pragma mark -
#pragma mark ---  UIWebViewDelegate  ---
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"........._isRequestWeb NO  webViewDidFinishLoad");
    _isRequestFail = YES;
    _isRequestWeb = NO;
    [webView sizeToFit];
    [self setWebViewFrame];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"........._isRequestWeb NO");

    _isRequestWeb = NO;
    if(_isRequestFail)
    {
        _isRequestFail = NO;
        NSString *noNetString = [[NSBundle mainBundle] pathForResource:@"carowner_weather_error_page" ofType:@"html"];
        [self loadRequest:noNetString isLocation:YES];
    }
    [webView sizeToFit];
    [self setWebViewFrame];
}



#pragma mark - ---  请求车主服务项目  ---
- (void)requestCarServiceItems
{
    [MWCarOwnerServiceManage sharedInstance].reqDelegare = self;
    NSLog(@"......reqDelegare = carService");
    [[MWCarOwnerServiceManage sharedInstance] RequestCarOwnerService];
    [QLoadingView showLoadingView:STR(@"Universal_loading", Localize_Universal) view:(UIWindow *)self.view];
//    [self.view bringSubviewToFront:_navigationBar];
    _rightItem.enabled = NO;
}

/***
 * @name    根据下载完成的数据，回调显示界面
 * @param
 * @author  by bazinga
 ***/
- (void) reloadCarServiceViewController
{
    if(_isReloadCarServiceItem)
    {
        NSLog(@"reloadCarServiceViewController  ************** RETURN ");
        return;
    }
    NSLog(@"-------------reloadCarServiceViewController");
    _isReloadCarServiceItem = YES;
    //清空界面之前加载的CarServiceItemView视图
    for(id subview in [_scrollerViewItems subviews])
    {
        if([subview isKindOfClass:[CarServiceItemView class]])
        {
            [subview removeFromSuperview];
        }
    }
    [_arrayCarServices removeAllObjects];
    //再添加视图
    for (int i = 0; i < [MWCarOwnerServiceManage sharedInstance].carOwnerTaskList.count +  [[MWCarOwnerServiceManage sharedInstance] isMore]; i++)
    {
        CarServiceItemView *temp = [[CarServiceItemView alloc]initWithItemImage:nil
                                                                      withLevel:0
                                                                   withItemText:@""];
        MWCarOwnerServiceTask *carTask ;
        if(i < [MWCarOwnerServiceManage sharedInstance].carOwnerTaskList.count)     //正常的按钮
        {
            carTask = [[MWCarOwnerServiceManage sharedInstance].carOwnerTaskList objectAtIndex:i];
            [temp setItemData:carTask];
            __block CarServiceViewController *blockSelf = self;
             __block BOOL blockClickMore = _isClickMore;
            temp.itemClick = ^(id data)
            {
                if(data && [data isKindOfClass:[MWCarOwnerServiceTask class]])
                {
                    [blockSelf clickWithData:data withCarService:blockSelf];
                }
                blockClickMore = NO;
            };
            temp.itemLongPress = ^(id data)
            {
                if(data &&  [data isKindOfClass:[MWCarOwnerServiceTask class]])
                {
                    [blockSelf LongPressWithData:data withCarService:blockSelf];
                }
            };
        }
        else    //更多的按钮
        {
            [temp setItemImage:IMAGE(@"carServiceMoreItem.png", IMAGEPATH_TYPE_1)];
            [temp setItemLevel:-1 withIsVip:0];
            [temp setItemText:STR(@"CarService_More", Localize_CarService)];
            __block CarServiceViewController *blockSelf = self;
            temp.itemClick = ^(id data)
            {
                [blockSelf clickMoreButton];
            };
        }
        
        
        
        [_scrollerViewItems addSubview:temp];
//        [self.view sendSubviewToBack:temp];
        [_arrayCarServices addObject:temp];
        [temp release];
    }
    [self reloadCarServicesRect];
    _isReloadCarServiceItem = NO;
}

- (void) clickMoreButton
{
    CarServiceMoreViewController *moreViewController = [[CarServiceMoreViewController alloc] init];
    [self presentModalViewController:moreViewController animated:YES];
    [moreViewController release];
    _isClickMore = YES;
}

#pragma mark - ---  车主服务请求回调函数   ---
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
    [QLoadingView hideWithAnimated:YES];
    [self reloadCarServiceViewController];
    _rightItem.enabled = YES;
}

- (void) didFailError
{
    [self reloadCarServiceViewController];
    [QLoadingView hideWithAnimated:YES];
    _rightItem.enabled = YES;
    //验证是否有网络- -。这是为什么，当然咯，没网络，怎么登入
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

#pragma mark-  ---  车主服务项目点击和长安处理  ---
- (void) clickWithData:(MWCarOwnerServiceTask *)data withCarService:(CarServiceViewController *)carserviceViewController
{
    //服务状态（非空 0-安装 1-未安装; 2-未安装,不适合安装; 3-有更新; 4-有更新,不适合安装; 5-强制更新6-禁用;7-非法）
    _longPressTask = data;
    _carPressController = carserviceViewController;
    switch (data.serviceStatus) {
        case 0:
        {
            [self VerifyLoginIn:data];
        }
            break;
        case 1:
        {

            [self pushToDetailViewController:data withViewController:carserviceViewController];
            
        }
            break;
        case 2:
        {
            [self createAlertViewWithTitle:[[MWCarOwnerServiceManage sharedInstance] getStringFormJson:_longPressTask.title]
                                   message:[[MWCarOwnerServiceManage sharedInstance] getStringFormJson:_longPressTask.warning]
                         cancelButtonTitle:STR(@"Universal_ok", Localize_Universal)
                         otherButtonTitles:nil
                                       tag:_longPressTask.serviceStatus];
        }
            break;
        case 3:
        {
            [self VerifyLoginIn:data];
        }
            break;
        case 4:
        {
            [self createAlertViewWithTitle:[self getTitleByServiceID:_longPressTask.serviceID]
                                   message:[[MWCarOwnerServiceManage sharedInstance] getStringFormJson:_longPressTask.warning]
                         cancelButtonTitle:STR(@"Universal_ok", Localize_Universal)
                         otherButtonTitles:nil
                                       tag:_longPressTask.serviceStatus];
        }
            break;
        case 5:
        {
            [self createAlertViewWithTitle:[self getTitleByServiceID:_longPressTask.serviceID]
                                   message:[NSString stringWithFormat:@"%@\n%@",
                                            [[MWCarOwnerServiceManage sharedInstance] getStringFormJson:_longPressTask.warning],
                                            [[MWCarOwnerServiceManage sharedInstance] getStringFormJson:_longPressTask.updatedesc]
                                           ]
                         cancelButtonTitle:STR(@"Universal_cancel", Localize_Universal)
                         otherButtonTitles:@[STR(@"CarService_UpdateNow", Localize_CarService)]
                                       tag:_longPressTask.serviceStatus];
        }
            break;
        case 6:
        {
            [self createAlertViewWithTitle:[self getTitleByServiceID:_longPressTask.serviceID]
                                   message:[[MWCarOwnerServiceManage sharedInstance] getStringFormJson:_longPressTask.warning]
                         cancelButtonTitle:STR(@"Universal_cancel", Localize_Universal)
                         otherButtonTitles:@[STR(@"CarService_Delete", Localize_CarService)]
                                       tag:_longPressTask.serviceStatus];
        }
            break;
        case 7:
        {
            [self createAlertViewWithTitle:[self getTitleByServiceID:_longPressTask.serviceID]
                                   message:[[MWCarOwnerServiceManage sharedInstance] getStringFormJson:_longPressTask.warning]
                         cancelButtonTitle:STR(@"Universal_ok", Localize_Universal)
                         otherButtonTitles:nil
                                       tag:_longPressTask.serviceStatus];
        }
            break;
            
        default:
            break;
    }
}


- (void) LongPressWithData:(MWCarOwnerServiceTask *)data withCarService:(CarServiceViewController *)carserviceViewController
{
    //如果是推薦服務，長按無效
    if (data.vip == 1) {
        return ;
    }
    GDActionSheet *actionSheet = nil;
    _longPressTask = data;
    //服务状态（非空 0-安装 1-未安装; 2-未安装,不适合安装; 3-有更新; 4-有更新,不适合安装; 5-强制更新6-禁用;7-非法）
    switch (data.serviceStatus) {
        case 0:
        {
            actionSheet = [self createGDActionSheetWithTitle:[self getTitleByServiceID:data.serviceID]
                                                    delegate:self
                                           cancelButtonTitle:STR(@"Universal_cancel", Localize_Universal)
                                      destructiveButtonTitle:nil
                                                         tag:data.serviceStatus
                                           otherButtonTitles:STR(@"CarService_Top", Localize_CarService),STR(@"CarService_DeleteService", Localize_CarService),nil];
            actionSheet.isSupportAutorotate = YES;
        }
            break;
        case 1://未安装长按，直接推去安装
        {
            [self pushToDetailViewController:data withViewController:carserviceViewController];
        }
            break;
        case 2:
        {
            
        }
            break;
        case 3:
        {
            actionSheet = [self createGDActionSheetWithTitle:[self getTitleByServiceID:data.serviceID]
                                                    delegate:self
                                           cancelButtonTitle:STR(@"Universal_cancel", Localize_Universal)
                                      destructiveButtonTitle:nil
                                                         tag:data.serviceStatus
                                           otherButtonTitles:STR(@"CarService_Top", Localize_CarService),STR(@"CarService_Update", Localize_CarService),STR(@"CarService_DeleteService", Localize_CarService),nil];
            actionSheet.isSupportAutorotate = YES;
            
        }
            break;
        case 4:
        {
        }
            break;
        case 5:
        {
            actionSheet = [self createGDActionSheetWithTitle:[self getTitleByServiceID:data.serviceID]
                                                    delegate:self
                                           cancelButtonTitle:STR(@"Universal_cancel", Localize_Universal)
                                      destructiveButtonTitle:nil
                                                         tag:data.serviceStatus
                                           otherButtonTitles:STR(@"CarService_Top", Localize_CarService),STR(@"CarService_Update", Localize_CarService),STR(@"CarService_DeleteService", Localize_CarService),nil];
            actionSheet.isSupportAutorotate = YES;
        }
            break;
        case 6:
        {
            
            actionSheet = [self createGDActionSheetWithTitle:[self getTitleByServiceID:data.serviceID]
                                                    delegate:self
                                           cancelButtonTitle:STR(@"Universal_cancel", Localize_Universal)
                                      destructiveButtonTitle:nil
                                                         tag:data.serviceStatus
                                           otherButtonTitles:STR(@"CarService_DeleteService", Localize_CarService),nil];
            actionSheet.isSupportAutorotate = YES;
        }
            break;
        case 7:
        {
            
            actionSheet = [self createGDActionSheetWithTitle:[self getTitleByServiceID:data.serviceID]
                                                    delegate:self
                                           cancelButtonTitle:STR(@"Universal_cancel", Localize_Universal)
                                      destructiveButtonTitle:nil
                                                         tag:data.serviceStatus
                                           otherButtonTitles:STR(@"CarService_DeleteService", Localize_CarService),nil];
            actionSheet.isSupportAutorotate = YES;
        }
            break;
            
        default:
            break;
    }
}


#pragma mark -  ---  已经安装进行使用处理  ---
/***
 * @name    已经安装项目，点击的处理
 * @param   点击 项目的任务
 * @author  by bazinga
 ***/
- (void) hasInstall:(MWCarOwnerServiceTask *) task
{
    NSDictionary *infoDictionary = [[MWCarOwnerServiceManage sharedInstance] getInstallCarOwnerServiceInfoWithTaskID:task.serviceID];
    
    NSString *title  = @"";
    title = [NSString stringWithFormat:@"%@%@",UM_EVENTID_USE,[infoDictionary objectForKey:CAR_SERVICE_TITLE_CN]];
    [MobClick event:UM_EVENTID_VEHICLE_OWNER_SERVICES_COUNT label:title];
    
    //默认不显示工具栏
    if([[infoDictionary objectForKey:CAR_SERVICE_FORM] isEqualToString:CAR_SERVICE_MODE_HTML])
    {
        HtmlFiveViewController *viewController = [[HtmlFiveViewController alloc]
                                                  initWithWebUrl:[infoDictionary objectForKey:CAR_SERVICE_ENTRY]
                                                  withTitle:[self getTitleByServiceID:task.serviceID]
                                                  withBrowser:NO];
        [self presentModalViewController:viewController animated:YES];
        [viewController release];
    }
    //本地代码插件
    else if([[infoDictionary objectForKey:CAR_SERVICE_FORM] isEqualToString:CAR_SERVICE_MODE_LOCAL_MODE])
    {
        
        Class someClass = NSClassFromString([infoDictionary objectForKey:CAR_SERVICE_ENTRY]);
        
        id obj = [[someClass alloc] init];
        id param = [infoDictionary objectForKey:CAR_SERVICE_ENTRY_PARAM];
        
        if ([param isKindOfClass:[NSDictionary class]])
        {
            for (NSString *key in [param allKeys])
            {
                if ([[param objectForKey:key] isEqualToString:@"self"])
                {
                    [param setObject:self forKey:key];
                    break;
                }
            }
            [obj enter:param];
        }
        [obj release];
    }
    //默认显示有工具栏
    else if([[infoDictionary objectForKey:CAR_SERVICE_FORM] isEqualToString:CAR_SERVICE_MODE_LOCAL_HTML_HAS_TOOLBAR])
    {
        HtmlFiveViewController *viewController = [[HtmlFiveViewController alloc]
                                                  initWithWebUrl:[infoDictionary objectForKey:CAR_SERVICE_ENTRY]
                                                  withTitle:[self getTitleByServiceID:task.serviceID]
                                                  withBrowser:YES];
        [self presentModalViewController:viewController animated:YES];
        [viewController release];
    }
    
}

/***
 * @name    移除服务
 * @param   serviceID -- 移除项目的id
 * @author  by bazinga
 ***/
- (void) removeServiceWithID:(NSString *)serviceID
{
    NSDictionary *infoDictionary = [[MWCarOwnerServiceManage sharedInstance] getInstallCarOwnerServiceInfoWithTaskID:serviceID];
    NSString *title  = @"";
    title = [NSString stringWithFormat:@"%@%@",UM_EVENTID_REMOVE,[infoDictionary objectForKey:CAR_SERVICE_TITLE_CN]];
    [MobClick event:UM_EVENTID_VEHICLE_OWNER_SERVICES_COUNT label:title];
    
    [[MWCarOwnerServiceManage sharedInstance] removeTaskId:serviceID];
    [self requestCarServiceItems];
}

/***
 * @name    置顶
 * @param   serviceID -- 置顶项目的id
 * @author  by bazinga
 ***/
- (void) setTopServiceWithID:(NSString *) serviceID
{
    [[MWCarOwnerServiceManage sharedInstance] moveTaskToTopWithTaskID:serviceID];
    [self reloadCarServiceViewController];
}

/***
 * @name    进入详情界面
 * @param
 * @author  by bazinga
 ***/
- (void) pushToDetailViewController :(MWCarOwnerServiceTask *)data
                  withViewController:(CarServiceViewController *)carserviceViewController
{
    CarServiceDetailViewController *viewController = [[CarServiceDetailViewController alloc]initWithCarData:data];
    [carserviceViewController presentModalViewController:viewController animated:YES];
    [viewController  release];
}

- (void) updatePushToDetail :(MWCarOwnerServiceTask *)data
          withViewController:(CarServiceViewController *)carserviceViewController
{
    NSDictionary *infoDictionary = [[MWCarOwnerServiceManage sharedInstance] getInstallCarOwnerServiceInfoWithTaskID:data.serviceID];
    NSString *title  = @"";
    title = [NSString stringWithFormat:@"%@%@",UM_EVENTID_UPDATE,[infoDictionary objectForKey:CAR_SERVICE_TITLE_CN]];
    [MobClick event:UM_EVENTID_VEHICLE_OWNER_SERVICES_COUNT label:title];
    
    
    [self pushToDetailViewController:data withViewController:carserviceViewController];
}

#pragma mark - ---  actionSheet 委托  ---
- (void)GDActionSheet:(GDActionSheet *)actionSheet clickedButtonAtIndex:(int)index
{
    //服务状态（非空 0-安装 1-未安装; 2-未安装,不适合安装; 3-有更新; 4-有更新,不适合安装; 5-强制更新6-禁用;7-非法）
    if(!_longPressTask)
    {
        return;
    }
    switch (_longPressTask.serviceStatus) {
        case 0:
        {
            if(index == 0)
            {
                //置顶
                [self setTopServiceWithID:_longPressTask.serviceID];
            }
            else if(index == 1)
            {
                NSLog(@"移除服务");
                [self removeServiceWithID:_longPressTask.serviceID];
            }
        }
            break;
        case 1:
        {
        }
            break;
        case 2:
        {
        }
            break;
        case 3:
        {
            if(index == 0)
            {
                //置顶
                [self setTopServiceWithID:_longPressTask.serviceID];
            }
            else if (index == 1)
            {
                [self createAlertViewWithTitle:[self getTitleByServiceID:_longPressTask.serviceID]
                                       message:[[MWCarOwnerServiceManage sharedInstance] getStringFormJson:_longPressTask.updatedesc]
                             cancelButtonTitle:STR(@"Universal_cancel", Localize_Universal)
                             otherButtonTitles:@[STR(@"CarService_UpdateNow", Localize_CarService)]
                                           tag:_longPressTask.serviceStatus];
            }
            else if(index == 2)
            {
                NSLog(@"移除服务");
                [self removeServiceWithID:_longPressTask.serviceID];
            }
            
        }
            break;
        case 5: //更新
        {
            if(index == 0)
            {
                //置顶
                [self setTopServiceWithID:_longPressTask.serviceID];
            }
            else if (index == 1)
            {
                NSLog(@"升级服务");
                [self updatePushToDetail:_longPressTask withViewController:_carPressController];
            }
            else if(index == 2)
            {
                NSLog(@"移除服务");
                [self removeServiceWithID:_longPressTask.serviceID];
            }
            
        }
            break;
        case 4:
        {
        }
            break;
        case 6:
        case 7:
        {
            if(index == 0)
            {
                NSLog(@"移除服务");
                [self removeServiceWithID:_longPressTask.serviceID];
            }
        }
            break;
        default:
            break;
    }
    
}

#pragma mark - ---  UIAlertViewDelegate  ---
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //服务状态（非空 0-安装 1-未安装; 2-未安装,不适合安装; 3-有更新; 4-有更新,不适合安装; 5-强制更新6-禁用;7-非法）
    switch (_longPressTask.serviceStatus) {
        case 0:
        {
        }
            break;
        case 1:
        {
            
        }
            break;
        case 2:
        {
            
        }
            break;
        case 3:
        {
            if (1 == buttonIndex)
            {
                NSLog(@"升级服务");
                [self updatePushToDetail:_longPressTask withViewController:_carPressController];
            }
            else
            {
            }
        }
            break;
        case 4:
        {
        }
            break;
        case 5: //强制升级
        {
            if (1 == buttonIndex)
            {
                NSLog(@"升级服务");
                [self updatePushToDetail:_longPressTask withViewController:_carPressController];
            }
            else
            {
                
            }
        }
            break;
        case 6:
        {
            if (1 == buttonIndex)
            {
                NSLog(@"移除服务");
                [self removeServiceWithID:_longPressTask.serviceID];
            }
        }
            break;
        case 7:
        {
            if (1 == buttonIndex)
            {
                NSLog(@"移除服务");
                [self removeServiceWithID:_longPressTask.serviceID];
            }
        }
            break;
            
        default:
            break;
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


#pragma  mark -  ---  任意点击一个已安装的服务，验证是否登入逻辑  ---
- (void) VerifyLoginIn:(MWCarOwnerServiceTask *)taskData
{
    NSDictionary *infoDictionary = [[MWCarOwnerServiceManage sharedInstance] getInstallCarOwnerServiceInfoWithTaskID:taskData.serviceID];
    if([[infoDictionary objectForKey:CAR_SERVICE_NEED_LOGIN] intValue] == 1)
    {
        //验证是否有网络- -。这是为什么，当然咯，没网络，怎么登入
        if([[ANDataSource sharedInstance] isNetConnecting] == NO)
        {
            GDAlertView *alertView=[[GDAlertView alloc] initWithTitle:nil andMessage:STR(@"Account_NetError",Localize_Account)];
            [alertView addButtonWithTitle:STR(@"POI_OK", Localize_POI) type:GDAlertViewButtonTypeDefault handler:^(GDAlertView *alertView){
                NSLog(@"木有网络~你看不到。");
            }];
            [alertView show];
            [alertView release];
            return;
        }
    
    
        if([[Plugin_Account getAccountInfoWith:1] intValue] != 0)
        {
            [self hasInstall:taskData];
        }
        else
        {
            [self loginPrompt:STR(@"Setting_SignInMessage", Localize_Setting)];
        }
    }
    else
    {
         [self hasInstall:taskData];
    }
}

-(void)loginPrompt:(NSString*)message
{
    GDAlertView *alertView=[[[GDAlertView alloc] initWithTitle:nil andMessage:message] autorelease];
    [alertView addButtonWithTitle:STR(@"Setting_NO", Localize_Setting) type:GDAlertViewButtonTypeCancel handler:nil];
    
    __block PluginStrategy *strategy=[PluginStrategy sharedInstance];
    [alertView addButtonWithTitle:STR(@"Setting_YES", Localize_Setting) type:GDAlertViewButtonTypeCancel handler:^(GDAlertView *alertView){
        [strategy allocModuleWithName:@"Plugin_Account" withObject:@{@"navigationController":self,@"loginType":@(10),@"bBack":@(1)}];
        _isFromLoginInView=YES;
    }];
    [alertView show];
    
}


#pragma  mark - ---  辅助函数  ---
- (NSString *)getTitleByServiceID:(NSString *)serviceID
{
    NSDictionary *infoDictionary = [[MWCarOwnerServiceManage sharedInstance] getInstallCarOwnerServiceInfoWithTaskID:serviceID];
    NSString *title  = @"";
    switch (fontType)
    {
        case 0:
        {
            title = [infoDictionary objectForKey:CAR_SERVICE_TITLE_CN];
        }
            break;
        case 1:
        {
            title = [infoDictionary objectForKey:CAR_SERVICE_TITLE_TW];
        }
            break;
        case 2:
        {
            title = [infoDictionary objectForKey:CAR_SERVICE_TITLE_EN];
        }
            break;
            
        default:
            break;
    }
    return  title;
    
}

@end

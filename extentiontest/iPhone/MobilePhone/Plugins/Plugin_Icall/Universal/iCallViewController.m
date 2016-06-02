//
//  iCallViewController.m
//  AutoNavi
//
//  Created by gaozhimin on 13-9-18.
//
//

#import "iCallViewController.h"
#import "GDTableViewCell.h"
#import "QLoadingView.h"
#import "MWAccountOperator.h"
#import "iCallBindPhoneViewController.h"
#import "GDActionSheet.h"
#import "GDAlertView.h"
#import "POIRouteCalculation.h"
#import "AccountNotify.h"
#import "MWICallRequest.h"
#import "ThreeDes.h"
#import "FeedBackTableViewCell.h"
#import "POICommon.h"
//测试电话
//#define ICALL_PHONE_NUMBER  @"01052043060"
//正式电话
#define ICALL_PHONE_NUMBER    @"4001811080"


typedef enum BTN_TYPE
{
    BTN_CALL_TYPE_TAG_100 = 100,//呼叫客服
    BTN_DES_TYPE_TAG_101  = 101,//手动获取目的地
    BTN_DELETE_TYPE_TAG_102 = 102,//删除
}BTN_TYPE;
@interface iCallViewController ()<NetReqToViewCtrDelegate,GDActionSheetDelegate>
{
    UINavigationBar     *_navigationBar;
    POIRouteCalculation *_routeCalculation;
    UIButton            *_buttonCall;
    UIButton            *_buttonDes;
}
@end

@implementation iCallViewController
@synthesize icallInfoPhone;
#pragma mark -
#pragma mark viewcontroller
- (id)init
{
	self = [super init];
	if (self)
	{
		self.navigationItem.leftBarButtonItem = LEFTBARBUTTONITEM(@"返回",@selector(GoBack:));
		self.title =STR(@"Icall_Store_iCallService", Localize_Icall);
	}
	return self;
}


- (void)dealloc
{
    [MWICallRequest sharedInstance].icallNetDelegate = nil;
    self.icallInfoPhone = nil;
    CRELEASE(_routeCalculation);
    [GDAlertView shouldAutorotate:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter ]removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
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
    [self userIDBingDingPhone];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationReceived:) name:Icall_Notify object:nil];
}
// 1. 判断当前userID有没有绑定手机号码
-(void)userIDBingDingPhone
{

    [[MWICallRequest sharedInstance]Net_accountGet95190PhoneWith:REQ_GET_95190PHONE_NUMBER delegate:self];
    [QLoadingView showLoadingView:STR(@"Universal_loading", Localize_Universal) view:(UIWindow *)self.view];
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
     [GDAlertView shouldAutorotate:NO];
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
    NSString *tmpTitle;
    UIButton * btnDelete = nil;
    tmpTitle = STR(@"Icall_Store_iCallService", Localize_Icall);
    _navigationBar=[POICommon allocNavigationBar:nil];
    
    UINavigationItem *navigationitem = [POICommon allocNavigationItem:tmpTitle rightTitle:nil];
    UIBarButtonItem *item=LEFTBARBUTTONITEM(@"", @selector(GoBack:));;
    [navigationitem setLeftBarButtonItem:item];
    [_navigationBar pushNavigationItem:navigationitem animated:NO];
    [self.view addSubview:_navigationBar];
    _tableView.bounces = NO;
    
    NSString  * titleNameDes= STR(@"Icall_PeleseGetDes",Localize_Icall);
    CGSize sizeOne=[titleNameDes sizeWithFont:[UIFont systemFontOfSize:kSize2] constrainedToSize:CGSizeMake(APPWIDTH,2000.0f)];
    CGFloat heightOne = MAX(sizeOne.height,55);
    imageViewBG = [[UIImageView alloc]init];
    imageViewBG.userInteractionEnabled = YES;
       float screenHeight = SCREENHEIGHT- (((float)NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) ? 0 : 20);
    [imageViewBG setFrame:CGRectMake(0.0f, screenHeight -heightOne, APPWIDTH, heightOne)];
    imageViewBG.backgroundColor = RGBACOLOR(255.0f, 255.0f, 255.0f, 0.56f);
    [self.view addSubview:imageViewBG];
    [imageViewBG release];
    
    UILabel * laberName =  [self createLabel:STR(@"Icall_BeginNaviGation", Localize_Icall) andFrame:CGRectMake(0,44+DIFFENT_STATUS_HEIGHT, APPWIDTH, 28) andView:self.view];
    laberName.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.68];
    laberName.textColor = [UIColor colorWithRed:195.0/255 green:195.0/255 blue:195.0/255 alpha:1.0];
    [laberName setFont:[UIFont systemFontOfSize:kSize2]];
    laberName.textAlignment =  NSTextAlignmentCenter;
    
    UILabel * label=  [self createLabel:titleNameDes
             andFrame:CGRectMake(10,0,APPWIDTH-50,heightOne)
              andView:imageViewBG];
    label.textColor = GETSKINCOLOR(@"IcallChangePhoneColor");
    label.font = [UIFont systemFontOfSize:kSize3];
    NSUserDefaults * ud = [NSUserDefaults standardUserDefaults];
    if([ud objectForKey:icallOperatorKey])
    {
        imageViewBG.hidden = [[ud objectForKey:icallOperatorKey] boolValue];
    }
    else
    {
        [ud setObject:[NSNumber numberWithBool:NO] forKey:icallOperatorKey];
    }
    btnDelete = [self createButtonWithTitle:nil  normalImage:@"CarServiceCloseTips.png" heightedImage:@"CarServiceCloseTipsPress.png" tag:BTN_DELETE_TYPE_TAG_102];
    [imageViewBG addSubview:btnDelete];
    btnDelete.frame  = CGRectMake(APPWIDTH - 30,(heightOne -18)/2,18,18);
}

//调整控件竖屏坐标和图片
-(void)changePortraitControlFrameWithImage
{
    [super changePortraitControlFrameWithImage];
    
    //[_navigationBar setFrame:CGRectMake(0.0, 0.0, APPWIDTH, 44.0)];
    UIImageView *tmp = (UIImageView *)[_navigationBar viewWithTag:1];
    [tmp setFrame:CGRectMake(0.0, 0.0, APPWIDTH, 44.0)];
    [tmp setImage:IMAGE(@"navigatorBarBg.png",IMAGEPATH_TYPE_1)];
    
    _tableView.frame = CGRectMake(10, 44.0+DIFFENT_STATUS_HEIGHT+28, self.view.bounds.size.width - 10 * 2, self.view.bounds.size.height);
    
    [_tableView reloadData];
}

//调整控件横屏坐标和图片
-(void)changeLandscapeControlFrameWithImage
{
    [super changeLandscapeControlFrameWithImage];
    [_tableView reloadData];
}

//改变控件文本
-(void)changeControlText
{
    
}

#pragma mark -
#pragma mark control action 拨打客服 手动获取目的地 移除掉低下
- (void)buttonAction:(UIButton *)button
{
//    if (_route==nil) {
//        _route=[[POIRouteCalculation alloc] initWithViewController:self.presentingViewController.presentingViewController];
//        _route.modalViewController = self;
//    }
//    MWPoi *node = [[MWPoi alloc] init];
//    node.szName = @"厦门市人民政府";
//    node.szAddr = @"湖滨北路";
//    node.longitude = 118089437;
//    node.latitude = 24479844;
//    [_route setBourn:node];
//    [node release];
//    return;
    switch (button.tag)
    {
        case BTN_CALL_TYPE_TAG_100:
        {
            if (self.icallInfoPhone) {
            NSString * phone=ICALL_PHONE_NUMBER;
            [[ANOperateMethod sharedInstance] GMD_Call_95190:phone];
            //用于实现客户端通知服务端拨打95190电话。 6.
            [[MWICallRequest sharedInstance]Net_accountPreCall95190With:REQ_PRE_CALL_95190 phone:self.icallInfoPhone delegate:nil];
            [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationReceived:) name:UIApplicationWillEnterForegroundNotification object:nil];
            }else
            {
                   [self setPhoneNumber];
            }
        }break;
        case BTN_DES_TYPE_TAG_101:
        {//手动获取目的地 7.
            if (self.icallInfoPhone) {
                [self showLoadingViewInView:STR(@"Icall_WaitingforDes", Localize_Icall) view:self.view];
                [[MWICallRequest sharedInstance]Net_accountGetOldDestinationWith:REQ_GET_95190_DESTINATION phone:self.icallInfoPhone delegate:self];
            }else
            {
                   [self setPhoneNumber];
            }
          
            
        }break;
        case BTN_DELETE_TYPE_TAG_102:
        {
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES]
                                                      forKey:icallOperatorKey];
            imageViewBG.hidden = YES;
        }break;
            
        default:
            break;
    }
}

- (void)GoBack:(id)sender
{

    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark logic relate

- (BOOL)shouldAutorotate
{
    return NO;
}
- (NSUInteger)supportedInterfaceOrientations
{
    return  UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (interfaceOrientation == UIDeviceOrientationPortrait)
    {
        return YES;
    }
	return  NO;
}

-	(void)landscapeLogic
{
    
}
-	(void)portraitLogic
{
    
    
}
- (void)MyalertView:(NSString *)titletext canceltext:(NSString *)mycanceltext othertext:(NSString *)myothertext alerttag:(int)mytag
{
	
    __block iCallViewController *weakself = self;
    GDAlertView *Myalert_ext = [[GDAlertView alloc] initWithTitle:nil andMessage:titletext];
    [GDAlertView shouldAutorotate:NO];
    if (mycanceltext)
    {
        [Myalert_ext addButtonWithTitle:mycanceltext type:GDAlertViewButtonTypeCancel handler:^(GDAlertView *alertView)
         {
             [weakself alertView:(UIAlertView *)alertView clickedButtonAtIndex:0];
         }];
    }
    if (myothertext)
    {
        [Myalert_ext addButtonWithTitle:myothertext type:GDAlertViewButtonTypeDefault handler:^(GDAlertView *alertView)
         {
             [weakself alertView:(UIAlertView *)alertView clickedButtonAtIndex:1];
         }];
    }
    Myalert_ext.tag = mytag;
    [Myalert_ext show];
    [Myalert_ext release];
}


#pragma mark -
#pragma mark notification
-(void)notificationReceived:(NSNotification*) notification
{
    if ([[notification name] isEqualToString:UIApplicationWillEnterForegroundNotification])
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
        if ([ANParamValue sharedInstance].isReq95190Des == 2)
        {
            [QLoadingView showLoadingView:STR(@"Icall_WaitingforDes", Localize_Icall) view:(UIWindow *)self.view];
            [[MWICallRequest sharedInstance]Net_accountGetCurrentDesWith:REQ_GET_CURRENT95190_DES phone:self.icallInfoPhone delegate:self];
        }[ANParamValue sharedInstance].isReq95190Des = 0;
        
    }
    if ([[notification name] isEqualToString:Icall_Notify])
    {
        self.icallInfoPhone = [notification object];
        [_tableView reloadData];
    }
}
#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kHeight2;
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CONTENTHEIGHT_V - 50 - kHeight2;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}


- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
#define BTN_HEIGHT        48
#define DISTANCE          35
#define LABEL_HEIGHT      40
  
    
    int offset = 20;
    float height = [self tableView:tableView heightForFooterInSection:section];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _tableView.bounds.size.width, height)];
   // view.backgroundColor = [UIColor redColor];
    if (section == 0)
    {
     
        NSString * titlename = STR(@"Icall_NumberSame", Localize_Icall);
        CGSize size=[titlename sizeWithFont:[UIFont systemFontOfSize:kSize2] constrainedToSize:CGSizeMake(_tableView.bounds.size.width - offset,2000.0f)];
        CGFloat heightName = MAX(size.height,LABEL_HEIGHT);
        
        UIImageView * imageViewName = [[UIImageView alloc]init];
        [imageViewName setFrame:CGRectMake(2, (heightName -22)/2,22, 22)];
        imageViewName.image = IMAGE(@"icallTip.png", IMAGEPATH_TYPE_1);
        [view addSubview:imageViewName];
        [imageViewName release];
       UILabel * laberTip = [self createLabel:titlename andFrame:CGRectMake(offset/2+15, 0, _tableView.bounds.size.width - offset,heightName) andView:view ];
        laberTip.textColor = GETSKINCOLOR(@"IcallChangePhoneColor");
        
            _buttonCall = [self createButtonWithTitle:STR(@"Icall_Call",Localize_Icall ) normalImage:@"CommonBtn1.png" heightedImage:@"CommonBtn2.png" tag:BTN_CALL_TYPE_TAG_100 strechParamX:5 strechParamY:10];
            [_buttonCall setTitleColor:GETSKINCOLOR(@"SubmitButtonColor") forState:UIControlStateNormal];
            _buttonCall.frame = CGRectMake(0,heightName+DISTANCE, APPWIDTH- 20, BTN_HEIGHT);
            _buttonCall.titleLabel.font =[UIFont systemFontOfSize:kSize2];
        
            if (!isiPhone) {
                [_buttonCall setTitleColor:GETSKINCOLOR(@"POISearchButtonTitleDisableColor") forState:UIControlStateNormal];
                _buttonCall.enabled = NO;
            }
            [view addSubview:_buttonCall];
            _buttonDes = [self createButtonWithTitle:STR(@"Icall_GetDes",Localize_Icall) normalImage:@"icallsendcode.png" heightedImage:@"icallsendcode_on.png" tag:BTN_DES_TYPE_TAG_101 strechParamX:5 strechParamY:10];
            [_buttonDes setTitleColor:GETSKINCOLOR(@"IcallPhoneColor") forState:UIControlStateNormal];
            _buttonDes .frame = CGRectMake(0,heightName+DISTANCE+BTN_HEIGHT+DISTANCE, _tableView.bounds.size.width,BTN_HEIGHT);
            _buttonDes.titleLabel.font =[UIFont systemFontOfSize:kSize2];
            [view addSubview:_buttonDes];
      
    }
    return [view autorelease];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Icall_Cell";
    FeedBackTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell)
    {
        cell = [[[FeedBackTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    cell.emptyLineLength = -1;
    cell.backgroundType = BACKGROUND_GROUP;
    cell.backgroundColor = [UIColor clearColor];
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    UIImageView * cellBgView = nil;
    if (!cellBgView) {
    UIImageView * tempimg = [[UIImageView alloc] initWithImage:IMAGE(@"Accessory.png", IMAGEPATH_TYPE_1)];
    cell.accessoryView = tempimg;
    [tempimg release];
    }
    if (indexPath.section == 0&&indexPath.row==0) {
        for(UIView * view in cell.contentView.subviews)
        {
            [view removeFromSuperview];
        }
        if ([NSString checkPhoneStandardWith:self.icallInfoPhone])
        {
            UILabel * labelPhone = [self createLabel:self.icallInfoPhone andFrame:CGRectMake(15, 10, _tableView.bounds.size.width-150, 28) andView:cell.contentView];
            labelPhone.textAlignment = NSTextAlignmentLeft;
            labelPhone.textColor = GETSKINCOLOR(@"IcallPhoneColor");
            labelPhone.font = [UIFont systemFontOfSize:kSize2];
            UILabel * labelChange= [self createLabel:STR(@"Icall_ModifyPhone", Localize_Icall) andFrame:CGRectMake(_tableView.bounds.size.width-150,0,115, 48) andView:cell.contentView];
            labelPhone.numberOfLines = 0;
            labelChange.textAlignment = NSTextAlignmentRight;
            labelChange.textColor = GETSKINCOLOR(@"IcallChangePhoneColor");
            labelChange.font = [UIFont systemFontOfSize:kSize3];

        }
        else
        {
            UILabel * labelPhone = [self createLabel:STR(@"Icall_NoSetPhone", Localize_Icall) andFrame:CGRectMake(15, 10, _tableView.bounds.size.width, 28) andView:cell.contentView];
            labelPhone.textAlignment = NSTextAlignmentLeft;
            labelPhone.font = [UIFont systemFontOfSize:kSize2];
             labelPhone.textColor = GETSKINCOLOR(@"IcallPhoneColor");
            UILabel * labelChange= [self createLabel:STR(@"Icall_RightSet", Localize_Icall) andFrame:CGRectMake(_tableView.bounds.size.width-110, 10,75, 28) andView:cell.contentView];
            labelChange.textAlignment = NSTextAlignmentRight;
            labelChange.textColor = GETSKINCOLOR(@"IcallChangePhoneColor");
            labelChange.font = [UIFont systemFontOfSize:kSize3];
        }
    }
    return cell;
}
#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIViewController *ctl;
    switch (indexPath.row + indexPath.section * 10)
    {
        case 0:
        {
            if ([NSString checkPhoneStandardWith:self.icallInfoPhone])
            {
             GDActionSheet * sheet=   [self createGDActionSheetWithTitle:STR(@"Icall_Store_iCallPhone",Localize_Icall) delegate:self cancelButtonTitle:STR(@"Universal_cancel", Localize_Universal) destructiveButtonTitle:nil tag:1 otherButtonTitles:STR(@"Icall_Store_ChangeiCallPhone", Localize_Icall), nil];
                sheet.isSupportAutorotate = YES;
            }
            else
            {
                ctl = [[iCallBindPhoneViewController alloc] initWithType:3];
                [self presentModalViewController:ctl animated:YES];
                [ctl release];
            }
            
            
        }
            break;

        default:
            break;
    }
}
-(UILabel *)createLabel:(NSString *)title andFrame:(CGRect )frame andView:(UIView *)view
{
    UILabel * label = [[[UILabel alloc]init]autorelease];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:kSize3];
    label.text = title;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.frame = frame;
    label.numberOfLines = 0;
    [view addSubview:label];
    return label;
}
#pragma mark - UIActionSheet  delegate
- (void)GDActionSheet:(GDActionSheet *)actionSheet clickedButtonAtIndex:(int)index
{
    UIViewController *ctl;
    switch (actionSheet.tag)
    {
        case 1:
            switch (index)
        {
            case 0:
            {
                ctl = [[iCallBindPhoneViewController alloc] initWithType:4];
                [self presentModalViewController:ctl animated:YES];
                [ctl release];
            }break;
            default:
                break;
        }
            break;
            
        default:
            break;
    }
}
#pragma mark - UIAlertView  delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag)
    {
        case 1:
            switch (buttonIndex)
        {
            case 1:
            {
                
            }break;
                
            default:
                break;
        }
            break;
        case 99:
        {
            [self dismissModalViewControllerAnimated:YES];
        }
            break;
        default:
            break;
    }
}
#pragma mark - NetReqToViewCtrDelegate
- (void)requestToViewCtrWithRequestType:(RequestType)requestType didFinishLoadingWithResult:(id)result
{
   [self hideLoadingViewWithAnimated:YES];
    if (requestType == REQ_GET_95190PHONE_NUMBER)//获取服务号码
    {
        NSString  * string =[[[result objectForKey:@"response"] objectForKey:@"repdesc"] isEqualToString:@"请求服务成功"];
        NSString * stringPhone = [[result objectForKey:@"svccont"] objectForKey:@"phone" ];
        if (string&& [stringPhone length]>0)//请求成功并且有手机号码
        {//改设备已经绑定号码了
            if ([[result objectForKey:@"svccont"] objectForKey:@"phone"]) {
                self.icallInfoPhone =  [ThreeDes decrypt:[[result objectForKey:@"svccont"] objectForKey:@"phone"]] ;
                [_tableView reloadData];
            }
        }else
        {   //该设备没有绑定手机号码
            [self setPhoneNumber];
        }
    }
    else if (requestType == REQ_GET_CURRENT95190_DES)//服务器下发的
    {
        if ([[[result objectForKey:@"response"] objectForKey:@"repdesc"] isEqualToString:@"请求服务成功"])
        {
            //if (_route==nil) {
                _routeCalculation=[[POIRouteCalculation alloc] initWithViewController:self.presentingViewController.presentingViewController];
                _routeCalculation.modalViewController = self;
            //}
            NSDictionary * dic = [result objectForKey:@"svccont"];
            MWPoi * poiNode = [[[MWPoi alloc] init] autorelease];
            poiNode.longitude = [[dic objectForKey:@"x"] floatValue]*1000000;
            poiNode.latitude = [[dic objectForKey:@"y"] floatValue]*1000000;
            poiNode.szAddr = [dic objectForKey:@"address"];
            poiNode.szName = [dic objectForKey:@"name"];
//            poiNode.lPoiId = [dic objectForKey:@"poiid"];
            poiNode.lNaviLon = 0;
            poiNode.lNaviLat = 0;
            [_routeCalculation setBourn:poiNode];

        }
        else
        {
            GDAlertView *alert = [[GDAlertView alloc] initWithTitle:nil andMessage:STR(@"Icall_UnableGetDes", Localize_Icall)];
            [GDAlertView shouldAutorotate:NO];
            [alert addButtonWithTitle:STR(@"POI_AlertCancel",Localize_POI) type:GDAlertViewButtonTypeCancel handler:nil];
            [alert addButtonWithTitle:STR(@"Icall_Tryagain", Localize_Icall) type:GDAlertViewButtonTypeDefault handler:^(GDAlertView * all)
             {
                 [self showLoadingViewInView:STR(@"Icall_WaitingforDes", Localize_Icall) view:self.view];
                 [[MWICallRequest sharedInstance]Net_accountGetOldDestinationWith:REQ_GET_95190_DESTINATION phone:self.icallInfoPhone delegate:self];
             }];
            [alert show];
            [alert release];
        }
    }
    else if (requestType == REQ_GET_95190_DESTINATION)//手动获取目的地
    {
        if ([[[result objectForKey:@"response"] objectForKey:@"repdesc"] isEqualToString:@"请求服务成功"])
        {
            //if (_route==nil) {
                _routeCalculation=[[POIRouteCalculation alloc] initWithViewController:self.presentingViewController.presentingViewController];
                _routeCalculation.modalViewController = self;
            //}
            NSDictionary * dic = [result objectForKey:@"svccont"];
            MWPoi * poiNode = [[[MWPoi alloc] init] autorelease];
            poiNode.longitude = [[dic objectForKey:@"x"] floatValue]*1000000;
            poiNode.latitude = [[dic objectForKey:@"y"] floatValue]*1000000;
            poiNode.szAddr = [dic objectForKey:@"address"];
            poiNode.szName = [dic objectForKey:@"name"];
//           poiNode.stPoiId.unMeshID = [[dic objectForKey:@"poiid"] intValue];
            poiNode.lNaviLon = 0;
            poiNode.lNaviLat = 0;
            [_routeCalculation setBourn:poiNode];
        }
        else
        {
            //[[AccountNotify SharedInstance] ShowAccountMessageWithTag:Account_Alert_UnFindDes_Fail delegate:nil];
            int errorType =[[[result objectForKey:@"response"] objectForKey:@"rspcode"] intValue];
            [[MWICallRequest sharedInstance] getErrorCodeType:errorType];
        }
    }
    else if (requestType == REQ_PRE_CALL_95190)
    {
        NSLog(@"%@",[[result objectForKey:@"response"] objectForKey:@"repdesc"]);
    }
   
}
        
- (void)requestToViewCtrWithRequestType:(RequestType)requestType didFailWithError:(NSError *)error
    {
        if ([error code] == NSURLErrorTimedOut)
        {
            [self MyalertView:STR(@"Universal_networkTimeout", Localize_Universal) canceltext:STR(@"Universal_ok", Localize_Universal) othertext:nil alerttag:-1];
            
        }
        else
        {
            [self MyalertView:STR(@"Universal_networkError", Localize_Universal) canceltext:STR(@"Universal_ok", Localize_Universal) othertext:nil alerttag:-1];
        }
    [QLoadingView hideWithAnimated:NO];
    }

-(void)setPhoneNumber
{
    GDAlertView *alert = [[GDAlertView alloc] initWithTitle:nil andMessage:STR(@"Icall_SetNumber", Localize_Icall)];
    [GDAlertView shouldAutorotate:NO];
    [alert addButtonWithTitle:STR(@"Universal_cancel", Localize_Universal) type:GDAlertViewButtonTypeCancel handler:^(GDAlertView * alertView){
        [_tableView reloadData];
        
    }];
    [alert addButtonWithTitle:STR(@"Universal_ok", Localize_Universal) type:GDAlertViewButtonTypeDefault handler:^(GDAlertView * alertView){
        iCallBindPhoneViewController * ctl = [[iCallBindPhoneViewController alloc] initWithType:3];
        [self presentModalViewController:ctl animated:YES];
        [ctl release];
    }];
    [alert show]; [alert release];

}



@end

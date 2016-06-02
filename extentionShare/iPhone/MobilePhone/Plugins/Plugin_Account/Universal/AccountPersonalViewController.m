//
//  AccountPersonalViewController.m
//  AutoNavi
//
//  Created by gaozhimin on 14-6-11.
//
//

#import "AccountPersonalViewController.h"
#import "MWAccountOperator.h"
#import "AccountPersonalCell.h"
#import "Plugin_Account.h"
#import "AccountLoginViewController.h"
#import "QLoadingView.h"
#import "AccountPersonalData.h"
#import "AccountNotify.h"
#import "GDBL_Account.h"
#import "POIDataCache.h"
#import "PluginStrategy.h"
#import "POICellButtonEvent.h"
#import "GDActionSheet.h"
#import "GDImagePickerController.h"
#import "AccountBackupViewController.h"
#import "DringTracksManage.h"
#import "DrivingTrackDetailViewController.h"
#import "DrivingTrackListViewController.h"
#import "MileRecordDataControl.h"
#import "GDStarView.h"
#import "MobClick.h"
#import "UMengEventDefine.h"
#import "AccountInfoViewController.h"
#import "MWAccountRequest.h"

typedef enum AccountPersonal_ButtonType
{
    AccountPersonal_Head = 1,
    AccountPersonal_Back = 2,
    AccountPersonal_Edit = 3,
    AccountPersonal_Edit_Home = 1000,
    AccountPersonal_Edit_Company = 1001,
}AccountPersonal_ButtonType;

#define PersonalCellEmptyLineLength 45.0
#define TrackLineHeight 70.0

@interface AccountPersonalViewController ()<NetReqToViewCtrDelegate,POISelectPOIDelegate,UIImagePickerControllerDelegate,UIActionSheetDelegate,UIAlertViewDelegate,UIPopoverControllerDelegate,UINavigationControllerDelegate>
{
    UIImageView *_topImageView; //顶部背景图片
    UIButton *_headButoon;      //头像按钮
    UILabel *_nameLable;        //名称
    
    UILabel *_leftNumberLable;  //驾驶平均分
    UILabel *_leftTipLable;
    
    UILabel *_rightNumberLable; //行驶总里程
    UILabel *_rightTipLable;
    
    
    NSArray *_imageArray;       //图片数组
    NSArray *_titleArray;       //标题数组
    
    UIButton *_buttonBack;      //后退按钮
    
    int _favoriteCount;     //收藏点个数  最多3条
    
    int _trackRecordCount;     //轨迹记录个数 最多3条
    
    BOOL isAlertLoginout;   //是否弹出注销框
    
    __block int type;               //判断是设置家还是公司            1表示设置家，2表示设置公司
    
    POICellButtonEvent *cellButtonEvent;
    
    UIPopoverController *m_popoverController;
    UIImagePickerController *_picker;
    AccountPersonalData *m_personalData;
    
    GDStarView *_starView;
    
    MWAccountRequest *m_accountNetReq;
}

@property (retain,nonatomic) MWFavorite *favoriteList;
@property (retain,nonatomic) MWFavorite *historyList;
@property (retain,nonatomic) MWSmartEyes *eyesList;
@property (retain,nonatomic) NSArray *drivingInfoList;

@end

@implementation AccountPersonalViewController

@synthesize favoriteList,historyList,eyesList,drivingInfoList;

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
    self.drivingInfoList = nil;
    self.eyesList = nil;
    self.historyList = nil;
    self.favoriteList = nil;
    [MileRecordDataControl sharedInstance].reqDelegare = nil;
    if (m_popoverController)
    {
        m_popoverController.delegate = nil;
        [m_popoverController dismissPopoverAnimated:NO];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    CRELEASE(cellButtonEvent);
    [_topImageView release];
    [_imageArray release];
    [_titleArray release];
    //网络请求
    m_accountNetReq.delegate = nil;
    [m_accountNetReq release];
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
    self.navigationItem.leftBarButtonItem = LEFTBARBUTTONITEM(@"", NULL);
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationReceived:) name:HEAD_GET_PROFILE object:nil];
    
    
    m_personalData = [AccountPersonalData SharedInstance];
    [m_personalData Account_GetUserinfo];
    
    cellButtonEvent=[[POICellButtonEvent alloc] init];
    cellButtonEvent.viewController=self;
    _favoriteCount = 0;
    _trackRecordCount = 0;
    [self initControl];
    
    _imageArray = [[NSArray alloc] initWithObjects:
                   IMAGE(@"PersonalHome.png", IMAGEPATH_TYPE_1),
                   IMAGE(@"PersonalCompany.png", IMAGEPATH_TYPE_1),
                   IMAGE(@"PersonalTrack.png", IMAGEPATH_TYPE_1),
                   IMAGE(@"PersonalCollectFull.png", IMAGEPATH_TYPE_1),
                   IMAGE(@"PersonalCamera.png", IMAGEPATH_TYPE_1),
                   IMAGE(@"PersonalHistory.png", IMAGEPATH_TYPE_1),
                   IMAGE(@"PersonalBackup.png", IMAGEPATH_TYPE_1),nil];
    
    _titleArray = [[NSArray alloc] initWithObjects:
                   STR(@"Account_Home", Localize_Account),
                   STR(@"Account_Company", Localize_Account),
                   STR(@"Account_DriveRecord", Localize_Account),
                   STR(@"Account_Collection", Localize_Account),
                   STR(@"Account_MyCamera", Localize_Account),
                   STR(@"Account_History", Localize_Account),
                   STR(@"Account_Backup", Localize_Account),
                   STR(@"Account_LogOut", Localize_Account),nil];
    
    //网络请求
    m_accountNetReq = [[MWAccountRequest alloc]init];
    m_accountNetReq.delegate = self;
    
}
// Called when the view is about to made visible. Default does nothing
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [self SetLoginInfo];
    MWFavorite *favorite = nil;
    [MWPoiOperator getPoiListWith:GFAVORITE_CATEGORY_DEFAULT poiList:&favorite];
    self.favoriteList = favorite;
    
    [MWPoiOperator getPoiListWith:GFAVORITE_CATEGORY_HISTORY poiList:&favorite];
    self.historyList = favorite;
    
    MWSmartEyes *smartEyes = nil;
    [MWPoiOperator getSmartEyesListWith:GSAFE_CATEGORY_ALL poiList:&smartEyes];
    self.eyesList = smartEyes;
    
    self.drivingInfoList = [[DringTracksManage sharedInstance] getDrivingInfoList];
    
    [_tableView reloadData];
}
// Called when the view has been fully transitioned onto the screen. Default does nothing

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [MileRecordDataControl sharedInstance].reqDelegare = self;
    [[MileRecordDataControl sharedInstance] mileageRequestWithType:RT_MileageStartUpRequest];
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
    
    _buttonBack = [self createButtonWithTitle:nil normalImage:nil heightedImage:nil tag:AccountPersonal_Back];
    [_buttonBack setImage:IMAGE(@"carServiceBack.png", IMAGEPATH_TYPE_1) forState:UIControlStateNormal];
    [_buttonBack setImage:IMAGE(@"carServiceBackPress.png", IMAGEPATH_TYPE_1) forState:UIControlStateHighlighted];
    [self.view addSubview:_buttonBack];
    
    CGSize size = self.view.bounds.size;
    float imageHeight = 242;
    _topImageView = [[self createImageViewWithFrame:CGRectMake(0, 0, size.width, imageHeight) normalImage:IMAGE(@"PersonalBackground.jpg", IMAGEPATH_TYPE_1) tag:0 ] retain];
    _topImageView.userInteractionEnabled = YES;
    _topImageView.backgroundColor = [UIColor clearColor];
    
    _headButoon = [self createButtonWithTitle:nil normalImage:@"non_head.png" heightedImage:nil tag:AccountPersonal_Head];
    _headButoon.frame = CGRectMake(0, 0, 60, 60);
    _headButoon.center = CGPointMake(size.width/2, 90);
    [_topImageView addSubview:_headButoon];
    
    _nameLable = [self createLabelWithText:STR(@"Account_LoginTip", Localize_Account) fontSize:14 textAlignment:UITextAlignmentCenter];
    _nameLable.frame = CGRectMake(0, 0, size.width, 40);
    _nameLable.center = CGPointMake(size.width/2, 140);
    [_topImageView addSubview:_nameLable];
    
    
    _starView = [[GDStarView alloc] initWithCount:5 score:0];
    [_starView setFrame:CGRectMake(0, 0, 80, 40)];
    [_topImageView addSubview:_starView];
    [_starView release];
    
    float leftLableWith = 70;
    _leftNumberLable = [self createLabelWithText:@"0" fontSize:30 textAlignment:UITextAlignmentRight];
    _leftNumberLable.frame = CGRectMake(0, imageHeight - 60, leftLableWith, 60);
    [_topImageView addSubview:_leftNumberLable];
    NSString *leftStr = [NSString stringWithFormat:@"%@\n%@",STR(@"Account_AverageTrack", Localize_Account),STR(@"Account_AverageScore", Localize_Account)];
    _leftTipLable = [self createLabelWithText:leftStr fontSize:12 textAlignment:UITextAlignmentLeft];
    _leftTipLable.frame = CGRectMake(leftLableWith + 5, imageHeight - 60, size.width - leftLableWith, 60);
    _leftTipLable.numberOfLines = 2;
    [_topImageView addSubview:_leftTipLable];
    
    _rightNumberLable = [self createLabelWithText:@"0" fontSize:30 textAlignment:UITextAlignmentRight];
    _rightNumberLable.frame = CGRectMake(size.width/2, imageHeight - 60, leftLableWith, 60);
    [_topImageView addSubview:_rightNumberLable];
    
    NSString *rightStr = [NSString stringWithFormat:@"%@\nkm",STR(@"Account_Totalkm", Localize_Account)];
    _rightTipLable = [self createLabelWithText:rightStr fontSize:12 textAlignment:UITextAlignmentLeft];
    _rightTipLable.frame = CGRectMake(size.width/2 + leftLableWith + 5, imageHeight - 60, size.width - leftLableWith, 60);
    _rightTipLable.numberOfLines = 2;
    [_topImageView addSubview:_rightTipLable];
}

//调整控件竖屏坐标和图片
-(void)changePortraitControlFrameWithImage
{
    [super changePortraitControlFrameWithImage];
    _tableView.frame = CGRectMake(0, 0, APPWIDTH, APPHEIGHT + DIFFENT_STATUS_HEIGHT);
    if (isiPhone)
    {
        float backWidth = 136/2;
        float backHeight = 106/2;
        [_buttonBack setFrame:CGRectMake(0.0f, DIFFENT_STATUS_HEIGHT, backWidth, backHeight)];
    }
    else
    {
        float backWidth = 204/2;
        float backHeight = 160/2;
        [_buttonBack setFrame:CGRectMake(0.0f, DIFFENT_STATUS_HEIGHT, backWidth, backHeight)];
    }
    CGSize size = self.view.bounds.size;
    float imageHeight = 242;
    _topImageView.frame = CGRectMake(0, 0, size.width, imageHeight);
    _headButoon.frame = CGRectMake(0, 0, 60, 60);
    _headButoon.center = CGPointMake(size.width/2, 90);
    _nameLable.frame = CGRectMake(0, 0, size.width, 40);
    _nameLable.center = CGPointMake(size.width/2, 140);
    float starY = 160;
    _starView.center = CGPointMake(size.width/2, starY);
    [self SetScroeFrame];
}

//调整控件横屏坐标和图片
-(void)changeLandscapeControlFrameWithImage
{
    [super changeLandscapeControlFrameWithImage];
    _tableView.frame = CGRectMake(0, 0, APPHEIGHT, APPWIDTH + DIFFENT_STATUS_HEIGHT);
    if (isiPhone)
    {
        float backWidth = 136/2;
        float backHeight = 106/2;
        [_buttonBack setFrame:CGRectMake(0.0f, DIFFENT_STATUS_HEIGHT, backWidth, backHeight)];
    }
    else
    {
        float backWidth = 204/2;
        float backHeight = 160/2;
        [_buttonBack setFrame:CGRectMake(0.0f, DIFFENT_STATUS_HEIGHT, backWidth, backHeight)];
    }
    CGSize size = self.view.bounds.size;
    float imageHeight = 242;
    _topImageView.frame = CGRectMake(0, 0, size.width, imageHeight);
    _headButoon.frame = CGRectMake(0, 0, 60, 60);
    _headButoon.center = CGPointMake(size.width/2, 90);
    _nameLable.frame = CGRectMake(0, 0, size.width, 40);
    _nameLable.center = CGPointMake(size.width/2, 140);
    float starY = 160;
    _starView.center = CGPointMake(size.width/2, starY);
    [self SetScroeFrame];
}

//改变控件文本
-(void)changeControlText
{
    
}

#pragma mark -
#pragma mark control action

- (void)buttonAction:(UIButton *)button
{
    switch (button.tag)
    {
        case AccountPersonal_Back:
        {
            [self leftBtnEvent:button];
        }
            break;
        case AccountPersonal_Head:
        {
            int logintype = [[Plugin_Account getAccountInfoWith:1] intValue];
            if (logintype == 0)
            {
                AccountLoginViewController *login=[[AccountLoginViewController alloc] initWithAccountName:nil  Password:nil back:YES];
                self.navigationController.navigationBarHidden = NO;   /*为了解决ios7下，导航栏会闪一下的问题*/
                [self.navigationController pushViewController:login animated:YES];
                [login release];
                
            }
            else
            {
                AccountInfoViewController *info = [[AccountInfoViewController alloc]init];
                 self.navigationController.navigationBarHidden = NO; 
                [self.navigationController pushViewController:info animated:YES];
                [info release];
            }
        }
            break;
        case AccountPersonal_Edit:
        {
            if ([self.favoriteList.pFavoritePOIArray count] > 0)
            {
                MWFavoritePoi *poi = [self.favoriteList.pFavoritePOIArray caObjectsAtIndex:0];
                Plugin_POI *plugin_poi = [[Plugin_POI alloc] init];
                [plugin_poi enter:@{POI_NAVIGATIONCONTROLLER:self.navigationController,POI_TYPE:@(11),@"poi":poi}];
                [plugin_poi release];
            }
        }
            break;
        case  AccountPersonal_Edit + 1:
        {
            if ([self.favoriteList.pFavoritePOIArray count] > 0)
            {
                MWFavoritePoi *poi = [self.favoriteList.pFavoritePOIArray caObjectsAtIndex:1];
                Plugin_POI *plugin_poi = [[Plugin_POI alloc] init];
                [plugin_poi enter:@{POI_NAVIGATIONCONTROLLER:self.navigationController,POI_TYPE:@(11),@"poi":poi}];
                [plugin_poi release];
            }
        }
            break;
        case AccountPersonal_Edit + 2:
        {
            if ([self.favoriteList.pFavoritePOIArray count] > 0)
            {
                MWFavoritePoi *poi = [self.favoriteList.pFavoritePOIArray caObjectsAtIndex:2];
                Plugin_POI *plugin_poi = [[Plugin_POI alloc] init];
                [plugin_poi enter:@{POI_NAVIGATIONCONTROLLER:self.navigationController,POI_TYPE:@(11),@"poi":poi}];
                [plugin_poi release];
            }
        }
            break;
        case AccountPersonal_Edit_Home:
        {
            [self reSetgoHomeOrCompany:0];

            
        }
            break;
        case AccountPersonal_Edit_Company:
        {//重新设置家和公司
            [self reSetgoHomeOrCompany:1];
            
        }
            break;
        default:
            break;
    }
}

- (void) leftBtnEvent:(id)sender
{
    [ANParamValue sharedInstance].beFirstNewFun = 0;
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) btn_logout_click
{
    if (isAlertLoginout)
    {
        return;
    }
    
    
    NSString *message = nil;
    message = STR(@"Account_SureLogOut", Localize_Account);
    __block AccountPersonalViewController *weakself = self;
    GDAlertView *Myalert_ext = [[GDAlertView alloc] initWithTitle:nil andMessage:message];
    [Myalert_ext addButtonWithTitle:STR(@"Universal_cancel", Localize_Universal) type:GDAlertViewButtonTypeCancel handler:nil];
    [Myalert_ext addButtonWithTitle:STR(@"Universal_ok", Localize_Universal) type:GDAlertViewButtonTypeDefault handler:^(GDAlertView *alertView)
     {
         [weakself alertView:(UIAlertView *)alertView clickedButtonAtIndex:1];
     }];
    Myalert_ext.tag = 1;
    [Myalert_ext show];
    [Myalert_ext release];
}

#pragma mark -
#pragma mark logic relate
-	(void)landscapeLogic
{
    
    
}
-	(void)portraitLogic
{
    
    
}

/*
 计算驾驶平均分，行驶总里程的lable位置
 */
- (void)SetScroeFrame
{
    //    _leftNumberLable.text = @"99999";
    //    _rightNumberLable.text = @"999999";
    CGSize size = self.view.bounds.size;
    float imageHeight = _topImageView.bounds.size.height;
    
    float leftLableWith = 0;
    int offsetx = 3;
    CGSize leftNumberSize = [_leftNumberLable.text sizeWithFont:_leftNumberLable.font];
    CGSize leftTipSize = [STR(@"Account_AverageTrack", Localize_Account) sizeWithFont:_leftTipLable.font];
    leftLableWith = size.width/4 - ((leftTipSize.width - leftNumberSize.width)/2) - offsetx;
    leftLableWith = (size.width/2 - leftTipSize.width) > leftLableWith ? leftLableWith : (size.width/2 - leftTipSize.width);
    _leftNumberLable.frame = CGRectMake(0, imageHeight - 60, leftLableWith, 60);
    _leftTipLable.frame = CGRectMake(leftLableWith + offsetx, imageHeight - 60, leftTipSize.width, 60);
    
    
    leftNumberSize = [_rightNumberLable.text sizeWithFont:_rightNumberLable.font];
    leftTipSize = [STR(@"Account_Totalkm", Localize_Account) sizeWithFont:_rightTipLable.font];
    leftLableWith = size.width/4 - ((leftTipSize.width - leftNumberSize.width)/2) - offsetx;
    leftLableWith = (size.width/2 - leftTipSize.width) > leftLableWith ? leftLableWith : (size.width/2 - leftTipSize.width);
    
    _rightNumberLable.frame = CGRectMake(size.width/2, imageHeight - 60, leftLableWith, 60);
    _rightTipLable.frame = CGRectMake(size.width/2 + leftLableWith + offsetx, imageHeight - 60, leftTipSize.width, 60);
}

- (void)SetLoginInfo
{
    NSArray *accountInfo = nil;
    [MWAccountOperator accountGetInfo:&accountInfo];
    if ([accountInfo count] > 0)
    {
        int loginType = [[accountInfo caObjectsAtIndex:0] intValue];
        if (loginType > 0) // 已登录
        {
            UIImage *headImage = [UIImage imageWithData:[accountInfo caObjectsAtIndex:4]];
            if(headImage){
                [_headButoon setBackgroundImage:headImage forState:UIControlStateNormal];
            }
            else
            {
                [_headButoon setBackgroundImage:IMAGE(@"non_head.png", IMAGEPATH_TYPE_1) forState:UIControlStateNormal];
            }
            UIGraphicsBeginImageContextWithOptions(_headButoon.bounds.size, _headButoon.opaque, 0); //高清下scale为2，否则为1
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextSaveGState(context);
            CGContextTranslateCTM(context, 0,0);
            CGContextScaleCTM(context, 1.0, 1.0);
            [_headButoon.layer renderInContext:context];
            headImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            if (headImage)
            {
                headImage = [UIImage getRoundImageWithImage:headImage from:0 to:360];
                [_headButoon setBackgroundImage:headImage forState:UIControlStateNormal];
                [_headButoon setBackgroundImage:headImage forState:UIControlStateHighlighted];
            }
            _nameLable.text = [Plugin_Account getAccountInfoWith:3];
            
            
            DringTracksManage *manage = [DringTracksManage sharedInstance];
            [_starView SetScore:manage.averageScore];
            _leftNumberLable.text = [NSString stringWithFormat:@"%.0f",manage.averageScore];
            _rightNumberLable.text = [NSString stringWithFormat:@"%d",[MileRecordDataControl sharedInstance].mileageServiceList.total/1000];
            
            [self SetScroeFrame];
        }
        else
        {
            [_headButoon setBackgroundImage:IMAGE(@"non_head.png", IMAGEPATH_TYPE_1) forState:UIControlStateNormal];
            _nameLable.text = STR(@"Account_LoginTip", Localize_Account);
            
            _leftNumberLable.text = @"0";
            _rightNumberLable.text = @"0";
            
            [self SetScroeFrame];
            
            [_starView SetScore:0];
        }
    }
}

//回家回公司 0表示回家。1表示 回公司
-(void)goHomeOrCompany:(BOOL)isHome index:(int)index
{
    NSString * home = isHome==0?[POICommon getHomeAddress]:[POICommon getCompantAddress];
    if (home==nil||home.length==0)
    {
        //弹出
        __block  POIDataCache *dataCache=[POIDataCache sharedInstance];
        __block PluginStrategy *strategy=[PluginStrategy sharedInstance];
        __block AccountPersonalViewController * weakSelf=self;
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
        MWFavorite * favorite = nil;
        [MWPoiOperator getPoiListWith:index==1?GFAVORITE_CATEGORY_HOME:GFAVORITE_CATEGORY_COMPANY poiList:&favorite];
        [POICommon intoPOIViewController:self withIndex:0 withViewFlag:INTO_TYPE_FAV withPOIArray:favorite.pFavoritePOIArray withTitle:index==1?STR(@"Account_Home", Localize_Account):STR(@"Account_Company", Localize_Account)];
        return;
    }
    
}

-(void)reSetgoHomeOrCompany:(BOOL)isHome
{
    __block  POIDataCache *dataCache=[POIDataCache sharedInstance];
    __block PluginStrategy *strategy=[PluginStrategy sharedInstance];
    __block AccountPersonalViewController * weakSelf=self;
    type=1+isHome;
    dataCache.flag=EXAMINE_POI_ADD_FAV;
    dataCache.selectPOIDelegate=weakSelf;
    dataCache.layerController=weakSelf;
    dataCache.isSetHomeAddress=isHome;
    [strategy allocViewControllerWithName:@"POISearchDesViewController" withType:0 withViewController:weakSelf];
}
#pragma mark -
#pragma mark notification
-(void)notificationReceived:(NSNotification*) notification
{
    if ([notification.name isEqualToString:HEAD_GET_PROFILE])
    {
        [self SetLoginInfo];
    }
}

#pragma mark -
#pragma mark POISelectPOIDelegate

-(void)selectPoi:(MWPoi*)object withOperation:(int)operation
{
    if (type==0) {
        return;
    }
    BOOL isSuccess;
    MWFavoritePoi *favoritePoi=[[MWFavoritePoi alloc] init];
    [POICommon copyWMPoiValutToSubclass:object withPoiSubclass:favoritePoi];
    isSuccess = [POICommon collectFavorite:type-1 withPOI:favoritePoi];
    [favoritePoi release];
    if (isSuccess) {
        
        [_tableView reloadData];
        GDAlertView *alertView =  [[[GDAlertView alloc] initWithTitle:nil andMessage:STR(type==1?@"POI_SetHomeAddressSuccess":@"POI_SetCompanyAddressSuccess", Localize_POI)] autorelease];
        [alertView show];
    }
    
    
}

#pragma mark - NetReqToViewCtrDelegate

- (void)requestToViewCtrWithRequestType:(RequestType)requestType didFinishLoadingWithResult:(id)result
{
    if (requestType == RT_MileageStartUpRequest)
    {
        [_tableView reloadData];
    }
    else if (requestType == REQ_UPLOAD_HEAD)
    {
        [QLoadingView hideWithAnimated:NO];//动画停止
        
        if ([result respondsToSelector:@selector(objectForKey:)] && [[result objectForKey:@"Result"] isEqualToString:@"SUCCESS"])
        {
            m_personalData.m_profileHead = m_personalData.p_profileHead;
            [[AccountNotify SharedInstance] ShowAccountMessageWithTag:Account_Alert_Head_Success delegate:self];
            NSData *data = UIImagePNGRepresentation(m_personalData.m_profileHead);
            if (data)
            {
                NSMutableArray *accountInfoArray = [NSMutableArray arrayWithArray:[[Account AccountInstance] getAccountInfo]];
                [accountInfoArray replaceObjectAtIndex:4 withObject:data];
                [[Account AccountInstance] setAccountInfo:accountInfoArray];
            }
            [_tableView reloadData];
        }
        else
        {
            [[AccountNotify SharedInstance] ShowAccountMessageWithTag:Account_Alert_Modify_Error delegate:self];
        }
    }
    else if (requestType == REQ_LOGOUT)
    {
        if ([[result objectForKey:@"Result"] isEqualToString:@"SUCCESS"] || [[result objectForKey:@"rspcode"] isEqualToString:@"0000"])
        {
           
            GDBL_setAccountImage(IMAGE(@"non_head.png", IMAGEPATH_TYPE_1));
            GDBL_setAccountNickName(@"");
            [[Account AccountInstance] setLoginStatus:0];
            [[AccountPersonalData SharedInstance] AccountClearAll];
            self.drivingInfoList = [[DringTracksManage sharedInstance] getDrivingInfoList]; //退出登陆，需要重新获取驾驶记录
            [_tableView reloadData];
        }
    }
    [QLoadingView hideWithAnimated:NO];
}

- (void)requestToViewCtrWithRequestType:(RequestType)requestType didFailWithError:(NSError *)error
{
    if (requestType == RT_MileageStartUpRequest)
    {
        return;
    }
    if ([error code] == NSURLErrorTimedOut)
    {
        [[AccountNotify SharedInstance] ShowAccountMessageWithTag:Account_Alert_Net_Error delegate:self];
    }
    else
    {
        [[AccountNotify SharedInstance] ShowAccountMessageWithTag:Account_Alert_Net_Error delegate:self];
    }
    [QLoadingView hideWithAnimated:NO];
}

#pragma mark - UIAlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case 1:
        {
            isAlertLoginout = NO;
            switch (buttonIndex)
            {
                case 1:
                {
                    NSArray *accountinfo = [[Account AccountInstance]getAccountInfo];
                    int logintype = [[accountinfo objectAtIndex:0]intValue];

                    if(logintype == 1 || logintype ==2)
                    {
                        [m_accountNetReq accountLogoutRequest:REQ_LOGOUT];
                        m_accountNetReq.delegate = self;
                    }
                    else
                    {
                        [MWAccountOperator accountLogoutWith:REQ_LOGOUT delegate:self];
                    }
                    
                    [QLoadingView showDefaultLoadingView:nil];
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
        default:
            break;
    }
}


#pragma mark - actionSheet

- (void)GDActionSheet:(GDActionSheet *)actionSheet clickedButtonAtIndex:(int)index
{
    switch (actionSheet.tag)
    {
        case 1:
        {
            switch (index) {
                case 0:
                {
                    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
                        _picker = [[GDImagePickerController alloc] init];
                        _picker.delegate = self;
                        _picker.allowsEditing = YES;
                        _picker.mediaTypes =[UIImagePickerController availableMediaTypesForSourceType:_picker.sourceType];
                        _picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                        if (isPad)
                        {
                            m_popoverController = [[UIPopoverController alloc] initWithContentViewController:_picker];
                            [m_popoverController presentPopoverFromRect:CGRectMake(0, 0, 300, 300)
                                                                 inView:self.view
                                               permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
                            m_popoverController.delegate = self;
                            [_picker release];
                            _picker = nil;
                        }
                        else
                        {
                            [self presentModalViewController:_picker animated:YES];
                            [_picker release];
                        }
                    } else {
                        GDAlertView *Myalert_ext = [[GDAlertView alloc] initWithTitle:nil andMessage:STR(@"Icall_NoSupportCall", Localize_Icall)];
                        [Myalert_ext addButtonWithTitle:STR(@"Universal_ok", Localize_Universal) type:GDAlertViewButtonTypeCancel handler:nil];
                        [Myalert_ext show];
                        [Myalert_ext release];
                    }
                }
                    break;
                case 1:
                {
                    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
                    {
                        _picker = [[GDImagePickerController alloc]init];
                        _picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                        _picker.delegate = self;
                        _picker.allowsEditing = YES;
                        [self presentModalViewController:_picker animated:YES];
                        [_picker release];
                    } else
                    {
                        GDAlertView *Myalert_ext = [[GDAlertView alloc] initWithTitle:nil andMessage:STR(@"Icall_NoSupportCall", Localize_Icall)];
                        [Myalert_ext addButtonWithTitle:STR(@"Universal_ok", Localize_Universal) type:GDAlertViewButtonTypeCancel handler:nil];
                        [Myalert_ext show];
                        [Myalert_ext release];
                    }
                }
                    break;
                default:
                    break;
            }
        }
    }
}

#pragma mark-
#pragma mark UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	if (picker.sourceType==UIImagePickerControllerSourceTypeCamera ||
		picker.sourceType==UIImagePickerControllerSourceTypePhotoLibrary)
	{
		UIImage *originalImage = [info objectForKey:UIImagePickerControllerEditedImage];
        if (originalImage)
        {
            m_personalData.p_profileHead = [self scaleToSize:originalImage size:CGSizeMake(ACCOUNT_HEAD_SIZE, ACCOUNT_HEAD_SIZE) changeRect:CGRectMake(0, 0, ACCOUNT_HEAD_SIZE, ACCOUNT_HEAD_SIZE)];
            m_personalData.bTip = YES;
            
            NSArray *tmpArray;
            GDBL_GetAccountInfo(&tmpArray);
            int loginType = [[tmpArray caObjectsAtIndex:0] intValue];
            if (loginType == 5)
            {
                [MWAccountOperator accountUploadHeadWith:REQ_UPLOAD_HEAD image:m_personalData.p_profileHead rect:CGRectMake(0, 0, 60, 60) tpuserid:m_personalData.m_accountXLWBuuid tptype:@"1" delegate:self];
            }
            else if (loginType == 6)
            {
                [MWAccountOperator accountUploadHeadWith:REQ_UPLOAD_HEAD image:m_personalData.p_profileHead rect:CGRectMake(0, 0, 60, 60) tpuserid:m_personalData.m_accountTXWBuuid tptype:@"2" delegate:self];
            }
            else
            {
                [MWAccountOperator accountUploadHeadWith:REQ_UPLOAD_HEAD image:m_personalData.p_profileHead rect:CGRectMake(0, 0, 60, 60) tpuserid:nil tptype:nil delegate:self];
            }
            [QLoadingView showLoadingView:nil view:(UIWindow *)self.view];
        }
	}
    if (m_popoverController)
    {
        [m_popoverController dismissPopoverAnimated:YES];
    }
    [picker dismissModalViewControllerAnimated:YES];
    _picker = nil;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	[picker dismissModalViewControllerAnimated:YES];
    _picker = nil;
}

- (void)saveTheImage:(UIImage*)image
{
	NSString *uniquePath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"selectedImage.png"];
	[UIImagePNGRepresentation(image) writeToFile: uniquePath atomically:YES];
    
	
}

//图片缩放到指定大小尺寸
- (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size changeRect:(CGRect)changRect
{
	// 创建一个bitmap的context
	// 并把它设置成为当前正在使用的context
	UIGraphicsBeginImageContext(size);
	// 绘制改变大小的图片
	[img drawInRect:changRect];
	// 从当前context中创建一个改变大小后的图片
	UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
	// 使当前的context出堆栈
	UIGraphicsEndImageContext();
	// 返回新的改变大小后的图片
	return scaledImage;
}

#pragma mark - UIPopoverControllerDelegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    [popoverController release];
    m_popoverController = nil;
}


#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0)
    {
        return _topImageView.bounds.size.height;
    }
    if (indexPath.section == 1)
    {
        if (indexPath.row != 0 && indexPath.row != _trackRecordCount+1)
        {
            return TrackLineHeight;
        }
    }
    else if (indexPath.section == 2)
    {
        if (indexPath.row != 0 && indexPath.row != _favoriteCount+1)
        {
            return TrackLineHeight;
        }
    }
    
    return kHeight2;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //取消注销按钮
    return 6;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section)
    {
        case 0:
            return 3;
            break;
        case 1:
        {
            
            NSArray *trackArray = self.drivingInfoList;
            int trackCount = [trackArray count];
            if (trackCount > 0)
            {
                if (trackCount > 3)
                {
                    _trackRecordCount = 3;
                    return 5;
                }
                else
                {
                    _trackRecordCount = trackCount;
                    return trackCount + 1;
                }
            }
            else
            {
                _trackRecordCount = 0;
                return 1;
            }
        }
            break;
        case 2:
        {
            if (self.favoriteList.nNumberOfItem > 0)
            {
                if (self.favoriteList.nNumberOfItem > 3)
                {
                    _favoriteCount = 3;
                    return 5;
                }
                else
                {
                    _favoriteCount = self.favoriteList.nNumberOfItem;
                    return self.favoriteList.nNumberOfItem+1;
                }
            }
            else
            {
                _favoriteCount = 0;
                return 1;
            }
        }
            break;
        case 3:
            return 1;
            break;
        case 4:
            return 1;
            break;
        case 5:
            return 1;
            break;
        case 6:
            return 1;
            break;
        default:
            break;
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 0;
    }
    return 20.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    float height = [self tableView:tableView heightForHeaderInSection:section];
    UIView *view = nil;
    view = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, height)] autorelease];
    view.backgroundColor = [UIColor clearColor];//GETSKINCOLOR(HUD_LABEL_CLEAR_BACK_COLOR);
    return view;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier_0 = @"Personal_CellIdentifier_0";
    static NSString *CellIdentifier_1 = @"Personal_CellIdentifier_1";
    static NSString *CellIdentifier_2 = @"Personal_CellIdentifier_2";
    static NSString *CellIdentifier_3 = @"Personal_CellIdentifier_3";
    
    AccountPersonalCell *cell = nil;
    if (indexPath.section == 0 && indexPath.row == 0)
    {
        if (_topImageView.superview)
        {
            [_topImageView removeFromSuperview];
        }
        UITableViewCell *imagecell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_0];
        if (!imagecell)
        {
            imagecell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier_0] autorelease];
        }
        [self SetLoginInfo];
        [imagecell addSubview:_topImageView];
        return imagecell;
    }
    if (indexPath.section == 1 && indexPath.row !=0 && indexPath.row < _trackRecordCount+1)
    {
        AccountTrackRecordCell *trackCell = nil;
        trackCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_1];
        if (!cell)
        {
            trackCell = [[[AccountTrackRecordCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier_1] autorelease];
        }
        trackCell.detailTextLabel.font = [UIFont systemFontOfSize:14];
        trackCell.detailTextLabel.textColor = TEXTDETAILCOLOR;
        trackCell.textLabel.font = [UIFont systemFontOfSize:16];
        trackCell.imageView.image =[_imageArray caObjectsAtIndex:indexPath.section+1];
        trackCell.imageView.alpha = 0;
        if (_trackRecordCount == indexPath.row)
        {
            trackCell.emptyLineLength = 0;
        }
        else
        {
            trackCell.emptyLineLength = PersonalCellEmptyLineLength;
        }
        
        NSArray *trackArray = self.drivingInfoList;
        DrivingInfo *trackInfo = [trackArray caObjectsAtIndex:indexPath.row - 1];
        
        [trackCell SetTrackInfo:trackInfo];
        
        UIImage *image = nil;
        if (_trackRecordCount == 1)
        {
            image = IMAGE(@"PersonalTimelineCircle.png", IMAGEPATH_TYPE_1);
        }
        else if (_trackRecordCount == 2)
        {
            if (indexPath.row == 1)
            {
                image = IMAGE(@"PersonalTimelineUp.png", IMAGEPATH_TYPE_1);
            }
            else
            {
                image = IMAGE(@"PersonalTimelineDown.png", IMAGEPATH_TYPE_1);
            }
        }
        else if (_trackRecordCount == 3)
        {
            if (indexPath.row == 1)
            {
                image = IMAGE(@"PersonalTimelineUp.png", IMAGEPATH_TYPE_1);
            }
            else if (indexPath.row == 2)
            {
                image = IMAGE(@"PersonalTimelineMid.png", IMAGEPATH_TYPE_1);
            }
            else
            {
                image = IMAGE(@"PersonalTimelineDown.png", IMAGEPATH_TYPE_1);
            }
        }
        
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
        imageView.image = image;
        imageView.center = CGPointMake(25, TrackLineHeight/2);
        imageView.tag = 112;
        [trackCell.contentView addSubview:imageView];
        [imageView release];
        return trackCell;
    }
    else if (indexPath.section == 2 && indexPath.row !=0 && indexPath.row < _favoriteCount+1)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_2];
        if (!cell)
        {
            cell = [[[AccountPersonalCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier_2] autorelease];
        }
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_3];
        if (!cell)
        {
            cell = [[[AccountPersonalCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier_3] autorelease];
        }
    }
    
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:112];
    if (imageView)
    {
        [imageView removeFromSuperview];
    }
    cell.textLabel.text = nil;
    cell.imageView.image = nil;
    cell.detailTextLabel.text = nil;
    cell.accessoryView = nil;
    cell.seeMoreLable.hidden = YES;
    cell.numberLable.hidden = YES;
    cell.emptyLineLength = -1;
    cell.detailTextLabel.textColor = TEXTDETAILCOLOR;
    cell.textLabel.font = [UIFont systemFontOfSize:18];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    cell.imageView.alpha = 1;
    if (indexPath.section == 0)
    {
        cell.detailTextLabel.textColor = GETSKINCOLOR(PERSONAL_SEEMORE_COLOR);
        cell.textLabel.text = [_titleArray caObjectsAtIndex:indexPath.row - 1];
        cell.imageView.image = [_imageArray caObjectsAtIndex:indexPath.row - 1];
        cell.detailTextLabel.text = STR(@"Account_TipSet", Localize_Account);
        BOOL isEdit = NO;
        if (indexPath.row == 1)
        {
            
            cell.emptyLineLength = PersonalCellEmptyLineLength;
            NSString *home = [POICommon getHomeAddress];
            if ([home length] > 0)
            {
                isEdit = YES;
                cell.detailTextLabel.text = home;
            }
            else
            {
                cell.detailTextLabel.textColor = GETSKINCOLOR(PERSONAL_CLICKSET_COLOR);
            }
        }
        else
        {
            NSString *company = [POICommon getCompantAddress];
            if ([company length] > 0)
            {
                isEdit = YES;
                cell.detailTextLabel.text = company;
            }
            else
            {
                cell.detailTextLabel.textColor = GETSKINCOLOR(PERSONAL_CLICKSET_COLOR);
            }
        }
        if (isEdit)
        {
            UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
            [button setBackgroundColor:[UIColor clearColor]];
            [button setImage:IMAGE(@"PersonalEdit1.png",IMAGEPATH_TYPE_1) forState:UIControlStateNormal];
            [button setImage:IMAGE(@"PersonalEdit2.png",IMAGEPATH_TYPE_1) forState:UIControlStateHighlighted];
            button.tag=AccountPersonal_Edit_Home + indexPath.row - 1;
            [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
            cell.accessoryView = button;
            UIImage * editImage = IMAGE(@"PersonalEdit1.png", IMAGEPATH_TYPE_1);
            button.frame = CGRectMake(10,0,editImage.size.width+15, kHeight5+10);
        }
        else
        {
            UIImageView *tempimg = [[UIImageView alloc] initWithImage:IMAGE(@"Accessory.png",IMAGEPATH_TYPE_1)];
            cell.accessoryView = tempimg;
            [tempimg release];
        }
    }
    else if (indexPath.section == 1)
    {
        if (indexPath.row == 0)
        {
            NSArray *trackArray = self.drivingInfoList;
            int trackCount = [trackArray count];
            cell.numberLable.hidden = NO;
            cell.numberLable.text = [NSString stringWithFormat:@"( %d )",trackCount];
            cell.emptyLineLength = 0;
            cell.textLabel.text = [_titleArray caObjectsAtIndex:indexPath.section+1];
            cell.imageView.image = [_imageArray caObjectsAtIndex:indexPath.section+1];
            
            if (_trackRecordCount == 0)
            {
                cell.numberLable.text = [NSString stringWithFormat:@"( %@ )",STR(@"Account_No", Localize_Account)];
                
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                UIImageView *tempimg = [[UIImageView alloc] initWithImage:IMAGE(@"AccessoryDisable.png",IMAGEPATH_TYPE_1)];
                cell.accessoryView = tempimg;
                [tempimg release];
            }
            else
            {
                UIImageView *tempimg = [[UIImageView alloc] initWithImage:IMAGE(@"Accessory.png",IMAGEPATH_TYPE_1)];
                cell.accessoryView = tempimg;
                [tempimg release];
            }
        }
        else
        {
            cell.textLabel.font = [UIFont systemFontOfSize:16];
            if (indexPath.row == _trackRecordCount+1)
            {
                cell.seeMoreLable.hidden = NO;
                cell.seeMoreLable.text = STR(@"Account_SeeMore", Localize_Account);
            }
        }
        
    }
    else if (indexPath.section == 2)
    {
        if (indexPath.row == 0)
        {
            MWFavorite *favorite = self.favoriteList;
            cell.numberLable.hidden = NO;
            cell.numberLable.text = [NSString stringWithFormat:@"( %d )",favorite.nNumberOfItem];
            cell.emptyLineLength = 0;
            cell.textLabel.text = [_titleArray caObjectsAtIndex:indexPath.section+1];
            cell.imageView.image = [_imageArray caObjectsAtIndex:indexPath.section+1];
            if (_favoriteCount == 0)
            {
                cell.numberLable.text = [NSString stringWithFormat:@"( %@ )",STR(@"Account_No", Localize_Account)];
                
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                UIImageView *tempimg = [[UIImageView alloc] initWithImage:IMAGE(@"AccessoryDisable.png",IMAGEPATH_TYPE_1)];
                cell.accessoryView = tempimg;
                [tempimg release];
            }
            else
            {
                UIImageView *tempimg = [[UIImageView alloc] initWithImage:IMAGE(@"Accessory.png",IMAGEPATH_TYPE_1)];
                cell.accessoryView = tempimg;
                [tempimg release];
            }
            
            
        }
        else
        {
            cell.textLabel.font = [UIFont systemFontOfSize:16];
            if (indexPath.row == _favoriteCount+1)
            {
                cell.seeMoreLable.hidden = NO;
                cell.seeMoreLable.text = STR(@"Account_SeeMore", Localize_Account);
            }
            else
            {
                if (_favoriteCount == indexPath.row)
                {
                    cell.emptyLineLength = 0;
                }
                else
                {
                    cell.emptyLineLength = PersonalCellEmptyLineLength;
                }
                cell.imageView.image = IMAGE(@"PersonalCollectEmpty.png", IMAGEPATH_TYPE_1);
                
                
                MWFavorite *favorite = self.favoriteList;
                if ([favorite.pFavoritePOIArray count] > indexPath.row - 1)
                {
                    MWFavoritePoi *poi = [favorite.pFavoritePOIArray caObjectsAtIndex:indexPath.row - 1];
                    cell.textLabel.text = poi.szName;
                    cell.detailTextLabel.text = [POICommon getPoiAddress:poi];
                }
                UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
                [button setBackgroundColor:[UIColor clearColor]];
                [button setImage:IMAGE(@"PersonalEdit1.png",IMAGEPATH_TYPE_1) forState:UIControlStateNormal];
                [button setImage:IMAGE(@"PersonalEdit2.png",IMAGEPATH_TYPE_1) forState:UIControlStateHighlighted];
                button.tag=AccountPersonal_Edit + indexPath.row - 1;
                [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
                cell.accessoryView = button;
                UIImage * editImage = IMAGE(@"PersonalEdit1.png", IMAGEPATH_TYPE_1);
                button.frame = CGRectMake(10,0,editImage.size.width+15, kHeight5+10);
            }
        }
        
    }
    else if (indexPath.section == 3)
    {
        if (indexPath.row == 0)
        {
            MWSmartEyes *smartEyes = self.eyesList;
            if (smartEyes.nNumberOfItem > 0)
            {
                UIImageView *tempimg = [[UIImageView alloc] initWithImage:IMAGE(@"Accessory.png",IMAGEPATH_TYPE_1)];
                cell.accessoryView = tempimg;
                [tempimg release];
                cell.numberLable.hidden = NO;
                cell.numberLable.text = [NSString stringWithFormat:@"( %d )",smartEyes.nNumberOfItem];
            }
            else
            {
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                UIImageView *tempimg = [[UIImageView alloc] initWithImage:IMAGE(@"AccessoryDisable.png",IMAGEPATH_TYPE_1)];
                cell.accessoryView = tempimg;
                [tempimg release];
                cell.numberLable.hidden = NO;
                cell.numberLable.text = [NSString stringWithFormat:@"( %@ )",STR(@"Account_No", Localize_Account)];
            }
            cell.textLabel.text = [_titleArray caObjectsAtIndex:indexPath.section+1];
            cell.imageView.image = [_imageArray caObjectsAtIndex:indexPath.section+1];
            
        }
        
    }
    else if (indexPath.section == 4)
    {
        if (indexPath.row == 0)
        {
            MWFavorite *favorite = self.historyList;
            if (favorite.nNumberOfItem > 0)
            {
                cell.numberLable.hidden = NO;
                cell.numberLable.text = [NSString stringWithFormat:@"( %d )",favorite.nNumberOfItem];
                UIImageView *tempimg = [[UIImageView alloc] initWithImage:IMAGE(@"Accessory.png",IMAGEPATH_TYPE_1)];
                cell.accessoryView = tempimg;
                [tempimg release];
            }
            else
            {
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.numberLable.hidden = NO;
                cell.numberLable.text = [NSString stringWithFormat:@"( %@ )",STR(@"Account_No", Localize_Account)];
                UIImageView *tempimg = [[UIImageView alloc] initWithImage:IMAGE(@"AccessoryDisable.png",IMAGEPATH_TYPE_1)];
                cell.accessoryView = tempimg;
                [tempimg release];
            }
            cell.textLabel.text = [_titleArray caObjectsAtIndex:indexPath.section+1];
            cell.imageView.image = [_imageArray caObjectsAtIndex:indexPath.section+1];
        }
        
    }
    else if (indexPath.section == 5)
    {
        if (indexPath.row == 0)
        {
            cell.textLabel.text = [_titleArray caObjectsAtIndex:indexPath.section+1];
            cell.imageView.image = [_imageArray caObjectsAtIndex:indexPath.section+1];
            UIImageView *tempimg = [[UIImageView alloc] initWithImage:IMAGE(@"Accessory.png",IMAGEPATH_TYPE_1)];
            cell.accessoryView = tempimg;
            [tempimg release];
        }
        
    }
    else if (indexPath.section == 5)
    {
        if (indexPath.row == 0)
        {
            cell.textLabel.text = [_titleArray caObjectsAtIndex:indexPath.section+1];
            cell.imageView.image = [_imageArray caObjectsAtIndex:indexPath.section+1];
            UIImageView *tempimg = [[UIImageView alloc] initWithImage:IMAGE(@"Accessory.png",IMAGEPATH_TYPE_1)];
            cell.accessoryView = tempimg;
            [tempimg release];
        }
        
    }
    else if (indexPath.section == 6)
    {
        if (indexPath.row == 0)
        {
            cell.seeMoreLable.hidden = NO;
            cell.seeMoreLable.text = STR(@"Account_LogOut", Localize_Account);
            
        }
        
    }
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0)
    {
        if (indexPath.row == 1)
        {
            [self goHomeOrCompany:NO index:indexPath.row];
        }
        else if (indexPath.row == 2)
        {
            [self goHomeOrCompany:YES index:indexPath.row];
        }
    }
    else if (indexPath.section == 1)
    {
        if (_trackRecordCount == 0)
        {
            return;
        }
        if (indexPath.row !=0 && indexPath.row != _trackRecordCount+1)
        {
            [MobClick event:UM_EVENTID_PersonalCenter_COUNT label:UM_LABEL_TrackViewCount];
            
            NSArray *trackArray = self.drivingInfoList;
            DrivingInfo *temp = [trackArray caObjectsAtIndex:indexPath.row - 1];
            
            DrivingTrackDetailViewController *ctl = [[DrivingTrackDetailViewController alloc] init];
            [ctl setValueWithDrivingTrack:temp];
            [self.navigationController pushViewController:ctl animated:YES];
            [ctl release];
        }
        else
        {
            [MobClick event:UM_EVENTID_PersonalCenter_COUNT label:UM_LABEL_TrackListCount];
            DrivingTrackListViewController *ctl = [[DrivingTrackListViewController alloc] init];
            self.navigationController.navigationBarHidden = NO;   /*为了解决ios7下，导航栏会闪一下的问题*/
            [self.navigationController pushViewController:ctl animated:YES];
            [ctl release];
        }
    }
    else if (indexPath.section == 2)
    {
        if (_favoriteCount == 0)
        {
            return;
        }
        if (indexPath.row !=0 && indexPath.row != _favoriteCount+1)
        {
            MWFavorite *favorite = self.favoriteList;
            if ([favorite.pFavoritePOIArray count] > indexPath.row - 1)
            {
                [POICommon intoPOIViewController:self withIndex:indexPath.row-1 withViewFlag:INTO_TYPE_FAV withPOIArray:favorite.pFavoritePOIArray withTitle:STR(@"Account_Collection", Localize_Account)];
            }
            return;
        }
        else
        {
            [MobClick event:UM_EVENTID_PersonalCenter_COUNT label:UM_LABEL_FavListCount];
            
            Plugin_POI *pluginPoi = [[Plugin_POI alloc] init];
            NSDictionary *dic=@{POI_NAVIGATIONCONTROLLER:self.navigationController,
                                POI_TYPE:@(7),
                                POI_ISBACKSUPERVIEWCONTROLLER:@(0),
                                POI_DELEGATE:self,
                                POI_VIEWCONTROLLER:self,
                                @"searchPOIType":@(SEARCH_FAVORITES),
                                @"collectIntoType":@(SETTING_INTO),
                                @"title":STR(@"Account_Collection", Localize_Account)};
            [pluginPoi enter:dic];
            [pluginPoi release];
        }
    }
    else if (indexPath.section == 3)
    {
        [MobClick event:UM_EVENTID_PersonalCenter_COUNT label:UM_LABEL_CameraListCount];
        
        MWSmartEyes *smartEyes = self.eyesList;
        if (smartEyes.nNumberOfItem == 0)
        {
            return;
        }
        Plugin_POI *pluginPoi = [[Plugin_POI alloc] init];
        NSDictionary *dic=@{POI_NAVIGATIONCONTROLLER:self.navigationController,
                            POI_TYPE:@(7),
                            POI_ISBACKSUPERVIEWCONTROLLER:@(0),
                            POI_DELEGATE:self,
                            POI_VIEWCONTROLLER:self,
                            @"searchPOIType":@(SEARCH_CAMERA),
                            @"collectIntoType":@(SETTING_INTO),
                            @"title":STR(@"Account_MyCamera", Localize_Account)};
        [pluginPoi enter:dic];
        [pluginPoi release];
    }
    else if (indexPath.section == 4)
    {
        [MobClick event:UM_EVENTID_PersonalCenter_COUNT label:UM_LABEL_HistoryListCcount];
        MWFavorite *favorite = self.historyList;
        if (favorite.nNumberOfItem == 0)
        {
            return;
            
        }
        Plugin_POI *pluginPoi = [[Plugin_POI alloc] init];
        NSDictionary *dic=@{POI_NAVIGATIONCONTROLLER:self.navigationController,
                            POI_TYPE:@(7),
                            POI_ISBACKSUPERVIEWCONTROLLER:@(0),
                            POI_DELEGATE:self,
                            POI_VIEWCONTROLLER:self,
                            @"searchPOIType":@(SEARCH_RECENTDESTINATIONS),
                            @"collectIntoType":@(SETTING_INTO),
                            @"title":STR(@"Account_History", Localize_Account)};
        [pluginPoi enter:dic];
        [pluginPoi release];
    }
    else if (indexPath.section == 5)
    {
        [MobClick event:UM_EVENTID_PersonalCenter_COUNT label:UM_LABEL_BackupListCount];
        AccountBackupViewController *ctl = [[AccountBackupViewController alloc] init];
        self.navigationController.navigationBarHidden = NO;   /*为了解决ios7下，导航栏会闪一下的问题*/
        [self.navigationController pushViewController:ctl animated:YES];
        [ctl release];
    }
    else if (indexPath.section == 6)
    {
        [MobClick event:UM_EVENTID_PersonalCenter_COUNT label:UM_LABEL_LogoutCount];
        [self btn_logout_click];
    }
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    CGFloat yOffset  = scrollView.contentOffset.y;
    
    if (yOffset < 0.) {
        [_tableView setContentOffset:CGPointMake(0., 0.)];
    }
    
}

@end

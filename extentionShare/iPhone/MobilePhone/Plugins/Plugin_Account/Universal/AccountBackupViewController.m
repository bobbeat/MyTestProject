//
//  AccountBackupViewController.m
//  AutoNavi
//
//  Created by gaozhimin on 14-6-13.
//
//

#import "AccountBackupViewController.h"
#import "POICellButtonEvent.h"
#import "MobClick.h"
#import "UMengEventDefine.h"
#import "MWAccountOperator.h"
#import "MWHistoryRouteSync.h"
#import "DringTracksManage.h"

@interface BackupTime : NSObject
@property (nonatomic,assign) GDATE dateFav;
@property (nonatomic,assign) GTIME timeFav;

@property (nonatomic,assign) GDATE dateHis;
@property (nonatomic,assign) GTIME timeHis;

@property (nonatomic,assign) GDATE dateCamera;
@property (nonatomic,assign) GTIME timeCamera;

@property (nonatomic,assign) GDATE dateRoute;
@property (nonatomic,assign) GTIME timeRoute;

@property (nonatomic,assign) GDATE dateTrack;
@property (nonatomic,assign) GTIME timeTrack;

@end

@implementation BackupTime

@synthesize dateCamera,dateFav,dateHis,dateRoute,dateTrack,timeCamera,timeFav,timeHis,timeRoute,timeTrack;

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:[NSString stringWithFormat:@"%d",self.dateFav.year] forKey:@"dateFav.year"];
	[encoder encodeObject:[NSString stringWithFormat:@"%d",self.dateFav.month] forKey:@"dateFav.month"];
	[encoder encodeObject:[NSString stringWithFormat:@"%d",self.dateFav.day] forKey:@"dateFav.day"];
	
    
    [encoder encodeObject:[NSString stringWithFormat:@"%d",self.dateHis.year] forKey:@"dateHis.year"];
	[encoder encodeObject:[NSString stringWithFormat:@"%d",self.dateHis.month] forKey:@"dateHis.month"];
	[encoder encodeObject:[NSString stringWithFormat:@"%d",self.dateHis.day] forKey:@"dateHis.day"];
    
    [encoder encodeObject:[NSString stringWithFormat:@"%d",self.dateCamera.year] forKey:@"dateCamera.year"];
	[encoder encodeObject:[NSString stringWithFormat:@"%d",self.dateCamera.month] forKey:@"dateCamera.month"];
	[encoder encodeObject:[NSString stringWithFormat:@"%d",self.dateCamera.day] forKey:@"dateCamera.day"];
    
    [encoder encodeObject:[NSString stringWithFormat:@"%d",self.dateRoute.year] forKey:@"dateRoute.year"];
	[encoder encodeObject:[NSString stringWithFormat:@"%d",self.dateRoute.month] forKey:@"dateRoute.month"];
	[encoder encodeObject:[NSString stringWithFormat:@"%d",self.dateRoute.day] forKey:@"dateRoute.day"];
    
    [encoder encodeObject:[NSString stringWithFormat:@"%d",self.dateTrack.year] forKey:@"dateTrack.year"];
	[encoder encodeObject:[NSString stringWithFormat:@"%d",self.dateTrack.month] forKey:@"dateTrack.month"];
	[encoder encodeObject:[NSString stringWithFormat:@"%d",self.dateTrack.day] forKey:@"dateTrack.day"];
}


- (id)initWithCoder:(NSCoder *) decoder
{
	if (self = [super init])
	{
        GDATE temp = {0};
        temp.year = [[decoder decodeObjectForKey:@"dateFav.year"] intValue];
        temp.month = [[decoder decodeObjectForKey:@"dateFav.month"] intValue];
        temp.day = [[decoder decodeObjectForKey:@"dateFav.day"] intValue];
        self.dateFav = temp;
        
        temp.year = [[decoder decodeObjectForKey:@"dateHis.year"] intValue];
        temp.month = [[decoder decodeObjectForKey:@"dateHis.month"] intValue];
        temp.day = [[decoder decodeObjectForKey:@"dateHis.day"] intValue];
        self.dateHis = temp;
        
        temp.year = [[decoder decodeObjectForKey:@"dateCamera.year"] intValue];
        temp.month = [[decoder decodeObjectForKey:@"dateCamera.month"] intValue];
        temp.day = [[decoder decodeObjectForKey:@"dateCamera.day"] intValue];
        self.dateCamera = temp;
        
        temp.year = [[decoder decodeObjectForKey:@"dateRoute.year"] intValue];
        temp.month = [[decoder decodeObjectForKey:@"dateRoute.month"] intValue];
        temp.day = [[decoder decodeObjectForKey:@"dateRoute.day"] intValue];
        self.dateRoute = temp;
        
        temp.year = [[decoder decodeObjectForKey:@"dateTrack.year"] intValue];
        temp.month = [[decoder decodeObjectForKey:@"dateTrack.month"] intValue];
        temp.day = [[decoder decodeObjectForKey:@"dateTrack.day"] intValue];
        self.dateTrack = temp;
	}
	
	return self;
}

@end

@interface BackupSynButton : UIButton
{
    UIImageView *_imageView;
    NSTimer *_timer;
    int _angle;
}

@end

@implementation BackupSynButton

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIImage *image = IMAGE(@"SynGray.png", IMAGEPATH_TYPE_1);
        _imageView = [[UIImageView alloc] initWithImage:image];
        _imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
        _imageView.center = CGPointMake(0, frame.size.height/2);
        [self addSubview:_imageView];
        [_imageView release];
        _angle = 0;
    }
    return self;
}

- (void)startRotating
{
    if (_timer)
    {
        [_timer invalidate];
        _timer = nil;
    }
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(timerMethod:) userInfo:nil repeats:YES];
    [_timer fire];
    
    
}

- (void)dealloc
{
    if (_timer)
    {
        [_timer invalidate];
        _timer = nil;
    }
    [super dealloc];
}
- (void)stopRotating
{
    if (_timer)
    {
        [_timer invalidate];
        _timer = nil;
    }
    _angle = 0;
    CGAffineTransform at =CGAffineTransformMakeRotation(0);
    [_imageView setTransform:at];
}

- (void)timerMethod:(NSTimer *)timer
{
    _angle += 2;
    CGFloat angle = (M_PI / 180.0) * _angle;
    CGAffineTransform at =CGAffineTransformMakeRotation(angle);
    [_imageView setTransform:at];
}


@end

typedef enum Backup_ButtonType
{
    Backup_SynAll = 1,
    Backup_SynFav = 2,
    Backup_SynHis = 3,
    Backup_SynRoute = 4,
    Backup_SynTrack = 5,
    Backup_SynCamera = 6,
}Backup_ButtonType;

@interface AccountBackupViewController ()<MWPoiOperatorDelegate,NetReqToViewCtrDelegate>
{
    NSArray *_contentArray;
    UIImageView *_synchronousBg;
    UIButton *_buttonSynchronous;
    BOOL isSynchronous[5];                                 //判断是否处于同步中
    POICellButtonEvent *cellEvent;
    
    NSMutableArray *_synButtonArray;
    
    BOOL _synAll;//是否同步所有
    
    DringTracksManage *_trackRequest;
}

@end

@implementation AccountBackupViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
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
    _trackRequest.delegate = nil;
    _trackRequest.historyDelegate = nil;

    [MWPoiOperator cancelSynFavoritePoiWith:REQ_SYN_FAV];
    [MWPoiOperator cancelSynFavoritePoiWith:REQ_SYN_DES];
    [MWPoiOperator cancelSynSmartEyesWith:REQ_SYN_DSP];
    CRELEASE(_synButtonArray);
    CRELEASE(_contentArray);
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
    self.navigationItem.leftBarButtonItem = LEFTBARBUTTONITEM(@"", @selector(leftBtnEvent:));
    
    _trackRequest = [DringTracksManage sharedInstance];
    _trackRequest.delegate = self;
    _trackRequest.historyDelegate = self;
    
    _synButtonArray = [[NSMutableArray alloc] init];
    [self initControl];
    _contentArray = [[NSArray alloc] initWithObjects:
                     STR(@"Account_Collection", Localize_Account),
                     STR(@"Account_History", Localize_Account),
                     STR(@"Account_HistoryRoute", Localize_Account),
                     STR(@"Account_DriveRecord", Localize_Account),
                     STR(@"Account_MyCamera", Localize_Account),nil];
    self.title = STR(@"Account_Backup", Localize_Account);
}
// Called when the view is about to made visible. Default does nothing
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    
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
-(void) initControl{
    _synchronousBg=[[UIImageView alloc] initWithImage:[IMAGE(@"SynchronizationBg.png", IMAGEPATH_TYPE_1) stretchableImageWithLeftCapWidth:2 topCapHeight:0]];
    [self.view addSubview:_synchronousBg];
    [_synchronousBg release];
    _synchronousBg.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
    _synchronousBg.frame=CGRectMake(0,CONTENTHEIGHT_V-64 , APPWIDTH,64);
    _synchronousBg.userInteractionEnabled=YES;
    _buttonSynchronous=[UIButton buttonWithType:UIButtonTypeCustom];
    [_buttonSynchronous setTitle:STR(@"Account_SynAll", Localize_Account) forState:UIControlStateNormal];
    [_buttonSynchronous setBackgroundImage:[IMAGE(@"CommonBtn1.png", IMAGEPATH_TYPE_1)stretchableImageWithLeftCapWidth:5 topCapHeight:10] forState:UIControlStateNormal];
    [_buttonSynchronous setBackgroundImage:[IMAGE(@"CommonBtn2.png", IMAGEPATH_TYPE_1)stretchableImageWithLeftCapWidth:5 topCapHeight:10] forState:UIControlStateHighlighted];
    
    _buttonSynchronous.frame=CGRectMake(0, 0, APPWIDTH,40);
    _buttonSynchronous.tag=Backup_SynAll;
    _buttonSynchronous.autoresizingMask=UIViewAutoresizingFlexibleWidth;
    [_buttonSynchronous addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_buttonSynchronous setTitleColor:GETSKINCOLOR(@"SubmitButtonColor") forState:UIControlStateNormal];
   
    
    [_synchronousBg addSubview:_buttonSynchronous];
    
    
    for (int i = 0; i < 5; i++)
    {
        BackupSynButton *button = [[BackupSynButton alloc] initWithFrame:CGRectMake(0, 0, 60, 35)];
        [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        button.titleLabel.font = [UIFont systemFontOfSize:16];
        [button setTitle:STR(@"Account_Syn", Localize_Account) forState:UIControlStateNormal];
        [button setTitleColor:TEXTCOLOR forState:UIControlStateNormal];
        button.tag = Backup_SynFav+i;
        [_synButtonArray addObject:button];
        [button release];
    }
    
}

//调整控件竖屏坐标和图片
-(void)changePortraitControlFrameWithImage
{
    [super changePortraitControlFrameWithImage];
    float height=64;
    _tableView.frame = CGRectMake(0, 0, self.view.bounds.size.width, CONTENTHEIGHT_V - height);
    _synchronousBg.frame=CGRectMake(0,CONTENTHEIGHT_V-height , APPWIDTH,height );
    _buttonSynchronous.frame=CGRectMake(8,10, APPWIDTH-16, 46);
}

//调整控件横屏坐标和图片
-(void)changeLandscapeControlFrameWithImage
{
    [super changeLandscapeControlFrameWithImage];
    float height=64;
    _tableView.frame = CGRectMake(0, 0, self.view.bounds.size.width, CONTENTHEIGHT_H - height);
    _synchronousBg.frame=CGRectMake(0,CONTENTHEIGHT_H-height ,APPHEIGHT,height );
    _buttonSynchronous.frame=CGRectMake(8,10, APPHEIGHT-16, 46);
}

//改变控件文本
-(void)changeControlText
{
    
}

#pragma mark -
#pragma mark control action

- (void)buttonAction:(UIButton *)button
{
    if (![self judgeIsLogin])
    {
        return;
    }
    switch (button.tag)
    {
        case Backup_SynAll:
        {
            [MobClick event:UM_EVENTID_PersonalCenter_COUNT label:UM_LABEL_SyncAllCount];
            
            for (int i = 0; i < 5; i++)
            {
                if (isSynchronous[i])
                {
                    return;
                }
            }
            _synAll = YES;
            [self buttonAction:[_synButtonArray objectAtIndex:0]];
        }
            break;
        case Backup_SynFav:
        {
            if (isSynchronous[0])
            {
                return;
            }
            isSynchronous[0] = YES;
            if (!_synAll)
            {
                [MobClick event:UM_EVENTID_PersonalCenter_COUNT label:UM_LABEL_SynFavCount];
            }
            MWFavoriteOption *favoriteOption=[[[MWFavoriteOption alloc] init] autorelease];
            favoriteOption.eCategory = GFAVORITE_CATEGORY_DEFAULT;
            [MWPoiOperator synFavoritePoiWith:favoriteOption requestType:REQ_SYN_FAV delegate:self];
             [self startRotating:Backup_SynFav];
        }
            break;
        case Backup_SynHis:
        {
            if (isSynchronous[1])
            {
                return;
            }
            isSynchronous[1] = YES;
            if (!_synAll)
            {
                [MobClick event:UM_EVENTID_PersonalCenter_COUNT label:UM_LABEL_SynHistoryCount];
            }
            MWFavoriteOption *favoriteOption=[[[MWFavoriteOption alloc] init] autorelease];
            favoriteOption.eCategory = GFAVORITE_CATEGORY_HISTORY;
            [MWPoiOperator synFavoritePoiWith:favoriteOption requestType:REQ_SYN_DES delegate:self];
            
            [self startRotating:Backup_SynHis];
        }
            break;
        case Backup_SynRoute:
        {
            if (isSynchronous[2])
            {
                return;
            }
            if (!_synAll)
            {
                [MobClick event:UM_EVENTID_PersonalCenter_COUNT label:UM_LABEL_SynHistoryRoutCount];
            }
            isSynchronous[2] = YES;
            [_trackRequest historyRouteSync];
            
            [self startRotating:Backup_SynRoute];
        }
            break;
        case Backup_SynTrack:
        {
            if (isSynchronous[3])
            {
                return;
            }
            if (!_synAll)
            {
                [MobClick event:UM_EVENTID_PersonalCenter_COUNT label:UM_LABEL_SynTrackRecordCount];
            }
            isSynchronous[3] = YES;
            
            [_trackRequest drivingTrackRequestWithType:RT_DrivingTrackSyncRequest pageIndex:0 pageCount:127 drivingTrack:nil];
            [self startRotating:Backup_SynTrack];
        }
            break;
        case Backup_SynCamera:
        {
            if (isSynchronous[4])
            {
                return;
            }
            if (!_synAll)
            {
                [MobClick event:UM_EVENTID_PersonalCenter_COUNT label:UM_LABEL_SynCameraCount];
            }
            isSynchronous[4] = YES;
            MWSmartEyesOption *smartEyes=[[MWSmartEyesOption alloc] init];
            [MWPoiOperator synSmartEyesWith:smartEyes requestType:REQ_SYN_DSP delegate:self];
            [smartEyes release];
            
            [self startRotating:Backup_SynCamera];
        }
            break;
        default:
            break;
    }
}

- (void) leftBtnEvent:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark logic relate
-	(void)landscapeLogic
{
    
    
}
-	(void)portraitLogic
{
    
    
}

- (BOOL)judgeIsLogin
{
    if ([[Plugin_Account getAccountInfoWith:0] intValue] != 0)
    {
        return YES;
    }
    GDAlertView *alertView=[[[GDAlertView alloc] initWithTitle:nil andMessage:STR(@"Setting_SignInMessage", Localize_Setting)] autorelease];
    [alertView addButtonWithTitle:STR(@"Setting_NO", Localize_Setting) type:GDAlertViewButtonTypeCancel handler:nil];
    
    __block UINavigationController *navigationController=self.navigationController;
    [alertView addButtonWithTitle:STR(@"Setting_YES", Localize_Setting) type:GDAlertViewButtonTypeCancel handler:^(GDAlertView *alertView){
        
        Plugin_Account *account = [[Plugin_Account alloc] init];
        [account enter:@{@"navigationController":navigationController,@"loginType":@(1),@"bBack":@(1)}];
        [account release];
    }];
    [alertView show];
    return NO;
}

- (void)startRotating:(Backup_ButtonType)type
{
    if (type >= Backup_SynFav && type <= Backup_SynCamera)
    {
        BackupSynButton *button = [_synButtonArray objectAtIndex:type-Backup_SynFav];
        [button startRotating];
    }
}

- (void)stopRotating:(Backup_ButtonType)type
{
    if (type >= Backup_SynFav && type <= Backup_SynCamera)
    {
        BackupSynButton *button = [_synButtonArray objectAtIndex:type-Backup_SynFav];
        [button stopRotating];
    }
}

- (NSString *)getSaveTime:(Backup_ButtonType)type
{
    NSMutableDictionary *dic = nil;
    dic = [NSKeyedUnarchiver unarchiveObjectWithFile:SynTime_Path];
    if (dic == nil)
    {
        NSLog(@"无文件数据");
        dic = [[[NSMutableDictionary alloc] init ]autorelease];
    }
    
    NSArray *array;
    [MWAccountOperator  accountGetInfo:&array];
    int loginType = [[array objectAtIndex:0] intValue];
    NSString *userid = nil;
    if (loginType == 3 || loginType == 5)
    {
        userid = [[array objectAtIndex:5] stringByAppendingString:@"1"];  //记录用户名
    }
    else if (loginType == 4 || loginType == 6)
    {
        userid = [[array objectAtIndex:5] stringByAppendingString:@"2"];  //记录用户名
    }
    else
    {
        userid = [array objectAtIndex:1];                                         //记录用户名
    }
    
    BackupTime *syntime = [dic objectForKey:userid];
    if (syntime == nil)
    {
        return nil;
    }
    
    GDATE	Date_tmp = {0};
    GTIME	Time_tmp = {0};
    switch (type) {
        case Backup_SynFav:
        {
            Date_tmp = syntime.dateFav;
            Time_tmp = syntime.timeFav;
        }
            break;
        case Backup_SynHis:
        {
            Date_tmp = syntime.dateHis;
            Time_tmp = syntime.timeHis;
        }
            break;
        case Backup_SynRoute:
        {
            Date_tmp = syntime.dateRoute;
            Time_tmp = syntime.timeRoute;
        }
            break;
        case Backup_SynTrack:
        {
            Date_tmp = syntime.dateTrack;
            Time_tmp = syntime.timeTrack;
        }
            break;
        case Backup_SynCamera:
        {
            Date_tmp = syntime.dateCamera;
            Time_tmp = syntime.timeCamera;
        }
            break;
            
        default:
            break;
    }
    if (Date_tmp.year == 0 && Date_tmp.month ==0 && Date_tmp.day == 0)
    {
        return nil;
    }
    
    NSString *timestr = [STR(@"Account_LastSynTime", Localize_Account) stringByAppendingFormat:@":%d-%d-%d",Date_tmp.year,Date_tmp.month,Date_tmp.day];
    return timestr;
}

- (void)SaveSynTime:(Backup_ButtonType)type
{
    NSMutableDictionary *dic = nil;
    dic = [NSKeyedUnarchiver unarchiveObjectWithFile:SynTime_Path];
    if (dic == nil)
    {
        NSLog(@"无文件数据");
        dic = [[[NSMutableDictionary alloc] init ]autorelease];
    }
    
    NSArray *array;
    [MWAccountOperator  accountGetInfo:&array];
    int loginType = [[array objectAtIndex:0] intValue];
    NSString *userid = nil;
    if (loginType == 3 || loginType == 5)
    {
        userid = [[array objectAtIndex:5] stringByAppendingString:@"1"];  //记录用户名
    }
    else if (loginType == 4 || loginType == 6)
    {
        userid = [[array objectAtIndex:5] stringByAppendingString:@"2"];  //记录用户名
    }
    else
    {
        userid = [array objectAtIndex:1];                                         //记录用户名
    }
    
    NSDate *localDate = [NSDate date];
    NSCalendar  * cal=[NSCalendar  currentCalendar];
    NSUInteger  unitFlags=NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit;
    NSDateComponents * conponent= [cal components:unitFlags fromDate:localDate];
    NSInteger year=[conponent year];
    NSInteger month=[conponent month];
    NSInteger day=[conponent day];
    
    NSDateFormatter *timeFormatter = [[[NSDateFormatter alloc]init]autorelease];
    timeFormatter.dateFormat = @"HH:mm:ss";
    NSString *dateString = [timeFormatter stringFromDate:localDate];
    NSInteger hour = [[dateString CutToNSString:@":"] intValue];
    NSInteger min = [[dateString CutFromNSString:@":" Tostring:@":"] intValue];
    NSInteger second = [[dateString CutToNSStringBackWard:@":"] intValue];
    
    GDATE	Date_tmp = {0};
    GTIME	Time_tmp = {0};
    Date_tmp.year = year;
    Date_tmp.month = month;
    Date_tmp.day = day;
    
    Time_tmp.hour = hour;
    Time_tmp.minute = min;
    Time_tmp.second = second;
    
    BackupTime *syntime = [dic objectForKey:userid];
    if (syntime == nil)
    {
        syntime = [[[BackupTime alloc] init] autorelease];
    }
    switch (type) {
        case Backup_SynFav:
        {
            syntime.dateFav = Date_tmp;
            syntime.timeFav = Time_tmp;
        }
            break;
        case Backup_SynHis:
        {
            syntime.dateHis = Date_tmp;
            syntime.timeHis = Time_tmp;
        }
            break;
        case Backup_SynRoute:
        {
            syntime.dateRoute = Date_tmp;
            syntime.timeRoute = Time_tmp;
        }
            break;
        case Backup_SynTrack:
        {
            syntime.dateTrack = Date_tmp;
            syntime.timeTrack = Time_tmp;
        }
            break;
        case Backup_SynCamera:
        {
            syntime.dateCamera = Date_tmp;
            syntime.timeCamera = Time_tmp;
        }
            break;
            
        default:
            break;
    }
    [dic setObject:syntime forKey:userid];
    
    if (![NSKeyedArchiver archiveRootObject:dic toFile:SynTime_Path])
    {
        NSLog(@"-------------同步时间失败-----------------");
    }
    else
    {
        NSLog(@"-------------同步时间成功-----------------");
    }
}

#pragma mark -
#pragma mark notification
-(void)notificationReceived:(NSNotification*) notification
{
    
}


#pragma mark - NetReqToViewCtrDelegate

- (void)requestToViewCtrWithRequestType:(RequestType)requestType didFinishLoadingWithResult:(id)result
{
    if (requestType == RT_HistoryRouteSync)
    {
        isSynchronous[2] = NO;
        [self stopRotating:Backup_SynRoute];
        [self SaveSynTime:Backup_SynRoute];
        [_tableView reloadData];
        if (_synAll)
        {
            [self buttonAction:[_synButtonArray objectAtIndex:3]];
        }
    }
    else if(requestType == RT_DrivingTrackSyncRequest)
    {
        isSynchronous[3] = NO;
        [self stopRotating:Backup_SynTrack];
        [self SaveSynTime:Backup_SynTrack];
        [_tableView reloadData];
        if (_synAll)
        {
            [self buttonAction:[_synButtonArray objectAtIndex:4]];
        }
    }
}

- (void)requestToViewCtrWithRequestType:(RequestType)requestType didFailWithError:(NSError *)error
{
    _synAll = NO;  //失败一个，终止同步所有
    if (requestType == RT_HistoryRouteSync)
    {
        isSynchronous[2] = NO;
        [self stopRotating:Backup_SynRoute];
    }
    else if (requestType == RT_DrivingTrackSyncRequest)
    {
        isSynchronous[3] = NO;
        [self stopRotating:Backup_SynTrack];
    }
    [self ShowFailMessageWithType:requestType error:error];
}

- (void)ShowFailMessageWithType:(RequestType)requestType error:(NSError *)error
{
    NSString *string = @"";
    if ([error.domain isEqualToString:KNetResponseErrorDomain])
    {
        //        服务器返回内容异常，HTTP error" 其中HTTP error后面要跟error的成员变量code
        
        string=[NSString stringWithFormat:STR(@"Universal_httpError",Localize_Universal),error.code];
        
    }
    else
    {
        if (error.code == 0 || error == nil)
        {
            if (requestType == RT_HistoryRouteSync)
            {
                string = [STR(@"Account_HistoryRoute",Localize_Account) stringByAppendingString:STR(@"Account_SynFail",Localize_Account)];
            }
            else if (requestType == RT_DrivingTrackSyncRequest)
            {
                string = [STR(@"Account_DriveRecord",Localize_Account) stringByAppendingString:STR(@"Account_SynFail",Localize_Account)];
            }
            else if (requestType == REQ_SYN_FAV)
            {
                string = [STR(@"Account_Collection",Localize_Account) stringByAppendingString:STR(@"Account_SynFail",Localize_Account)];
            }
            else if (requestType == REQ_SYN_DES)
            {
                string = [STR(@"Account_History",Localize_Account) stringByAppendingString:STR(@"Account_SynFail",Localize_Account)];
            }
            else if (requestType == REQ_SYN_DSP)
            {
                string = [STR(@"Account_MyCamera",Localize_Account) stringByAppendingString:STR(@"Account_SynFail",Localize_Account)];
            }
        }
        else if (error.code==NSURLErrorTimedOut) {
            string=STR(@"Universal_networkTimeout",Localize_Universal);
        }
        else
        {
            string=STR(@"Universal_networkError",Localize_Universal);
        }
        
    }
    GDAlertView *alertView=[[[GDAlertView alloc] initWithTitle:nil andMessage:string] autorelease];
    [alertView show];
}
#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kHeight3;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_contentArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier_2 = @"Backup_CellIdentifier_2";
    GDTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_2];
    if (!cell)
    {
        cell = [[[GDTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier_2] autorelease];
    }
    cell.textLabel.text = [_contentArray objectAtIndex:indexPath.row];
    Backup_ButtonType type = indexPath.row + Backup_SynFav;
    cell.detailTextLabel.text = [self getSaveTime:type];
    cell.accessoryView = [_synButtonArray objectAtIndex:indexPath.row];

    cell.emptyLineLength = 0;
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UIButton *button = [_synButtonArray objectAtIndex:indexPath.row];
    [self buttonAction:button];
}

#pragma mark -
#pragma mark MWPoiOperatorDelegate
-(void)synSuccessWith:(RequestType)type result:(id)result
{
    if (type == REQ_SYN_FAV)
    {
        isSynchronous[0] = NO;
        [self stopRotating:Backup_SynFav];
        [self SaveSynTime:Backup_SynFav];
        if (_synAll)
        {
            [self buttonAction:[_synButtonArray objectAtIndex:1]];
        }
    }
    else if (type == REQ_SYN_DES)
    {
        isSynchronous[1] = NO;
        [self stopRotating:Backup_SynHis];
        [self SaveSynTime:Backup_SynHis];
        if (_synAll)
        {
            [self buttonAction:[_synButtonArray objectAtIndex:2]];
        }
        
    }
    else if (type == REQ_SYN_DSP)
    {
        isSynchronous[4] = NO;
        [self stopRotating:Backup_SynCamera];
        [self SaveSynTime:Backup_SynCamera];
        _synAll = NO;
    }
    
    [_tableView reloadData];
//    GDAlertView *alertView=[[[GDAlertView alloc] initWithTitle:nil andMessage:STR(@"Setting_SynchronizedSuccess", Localize_Setting)] autorelease];
//    [alertView show];
}
-(void)synFailWith:(RequestType)type error:(NSError *)error
{
    _synAll = NO;  //失败一个，终止同步所有
    if (type == REQ_SYN_FAV)
    {
        isSynchronous[0] = NO;
        [self stopRotating:Backup_SynFav];
    }
    else if (type == REQ_SYN_DES)
    {
        isSynchronous[1] = NO;
        [self stopRotating:Backup_SynHis];
    }
    else if (type == REQ_SYN_DSP)
    {
        isSynchronous[4] = NO;
        [self stopRotating:Backup_SynCamera];
    }
    NSLog(@"error=%@ ",error);
    if (error.code==0) {
        NSLog(@"error.userInfo=%@",error.userInfo);
    }
    else if (error.code == 1)
    {
        static BOOL alert = NO;
        if (!alert)
        {
            alert = YES;
            GDAlertView *alertView=[[[GDAlertView alloc] initWithTitle:nil andMessage:STR(@"Setting_Authenticate", Localize_Setting)] autorelease];
            [alertView addButtonWithTitle:STR(@"Setting_NO", Localize_Setting) type:GDAlertViewButtonTypeCancel handler:^(GDAlertView *alertView) {
                alert = NO;
            }];
            
            __block UINavigationController *navigationController=self.navigationController;
            [alertView addButtonWithTitle:STR(@"Setting_YES", Localize_Setting) type:GDAlertViewButtonTypeCancel handler:^(GDAlertView *alertView){
                
                Plugin_Account *account = [[Plugin_Account alloc] init];
                [account enter:@{@"navigationController":navigationController,@"loginType":@(1),@"bBack":@(1)}];
                [account release];
                
                alert = NO;
            }];
            [alertView show];
        }
        
        return;
    }
    [self ShowFailMessageWithType:type error:error];
}
@end

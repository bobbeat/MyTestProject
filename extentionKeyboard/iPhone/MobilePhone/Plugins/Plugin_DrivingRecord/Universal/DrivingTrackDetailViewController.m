//
//  DrivingTrackDetailViewController.m
//  AutoNavi
//
//  Created by longfeng.huang on 14-6-13.
//
//

#import "DrivingTrackDetailViewController.h"
#import "ColorLable.h"
#import "TrackCountView.h"
#import "TrackScoreView.h"
#import "DrivingTrackMapDetailViewController.h"
#import "GDStarView.h"
#import "Plugin_Share.h"
#import "PluginStrategy.h"
#import "QLoadingView.h"
#import "UMengEventDefine.h"

#define kTopImageHight (isPad ? 580. : 290.)

@interface DrivingTrackDetailViewController ()
{
    Share_Type shareTypebtn;
    UIScrollView *_scollView;
    UIButton    *_backButton;
    UILabel     *_timeLabel;
    UIImageView *_topImageView;
    UILabel *_drivingScoreLabel;
    ColorLable *_totalDistanceLabel;
    ColorLable *_totalTimeLabel;
    ColorLable *_averageSpeedLabel;
    ColorLable *_beatsLabel;
    ColorLable *_topSpeedLabel;
    UILabel    *_scoreSymbolLabel;
    UILabel    *_disSymbolLabel;
    UILabel    *_timeSymbolLabel;
    UILabel    *_averageSpeedSymbolLabel;
    UILabel    *_topSpeedSymbolLabel;
    UILabel    *_disTextLabel;
    UILabel    *_timeTextLabel;
    UILabel    *_averageTextLabel;
    UILabel    *_topSpeedTextLabel;
    
    TrackScoreView *_fuleScoreView;
    TrackScoreView *_safeScoreView;
    TrackCountView *_oilCountView;
    TrackCountView *_brakeCountView;
    TrackCountView *_turnCountView;
    TrackCountView *_speedHightCountView;
    UIButton *_shareButton;
    UIButton *_deleteButton;
    UIImageView *_lineVer1;
    UIImageView *_lineVer2;
    UIImageView *_lineVer3;
    UIImageView *_lineVer4;
    UIImageView *_lineHer1;
    UIImageView *_lineHer2;
    GDStarView *_starView;
    
    UIImageView *_shareBacImageView;

}

@property (nonatomic, retain) DrivingInfo *mTrackInfo;

@end

@implementation DrivingTrackDetailViewController

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        [self initControl];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [MobClick event:UM_EVENTID_PersonalCenter_COUNT label:UM_LABEL_TrackViewCount];
    
    [self drivingTrackCountHandle];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [DringTracksManage sharedInstance].delegate = nil;
    
    [super dealloc];
}
#pragma mark - UIViewController delegate methods

- (void)initControl
{
    
    self.view.backgroundColor = [UIColor whiteColor];
    //scrollView
    _scollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0., 0., APPWIDTH, APPHEIGHT)];
    _scollView.backgroundColor=[UIColor whiteColor];
    [_scollView setShowsVerticalScrollIndicator:NO];
	[_scollView setScrollEnabled:YES];
    _scollView.delegate = self;
    
    [self.view addSubview:_scollView];
    [_scollView release];
    
    //顶部图片
    _topImageView = [self createImageViewWithFrame:CGRectMake(0., 0., self.view.frame.size.width, 290.) normalImage:nil tag:0];
    [_scollView addSubview:_topImageView];
    
    
    _backButton = [self createButtonWithTitle:nil normalImage:nil heightedImage:nil tag:2];
    [_backButton setFrame:CGRectMake(0., 10., 60., 60.)];
    [_backButton setImage:IMAGE(@"drivingTrackClose.png", IMAGEPATH_TYPE_1) forState:UIControlStateNormal];
    [_backButton setImage:IMAGE(@"drivingTrackClose_on.png", IMAGEPATH_TYPE_1) forState:UIControlStateHighlighted];
    _backButton.backgroundColor = [UIColor clearColor];
    [_scollView addSubview:_backButton];
    
    _timeLabel = [self createLabelWithText:nil fontSize:12.0 textAlignment:UITextAlignmentLeft];
    [_timeLabel setFrame:CGRectMake(80., 20., 150., 40.)];
    _timeLabel.textColor = [UIColor whiteColor];
    _timeLabel.font = [UIFont systemFontOfSize:15.];
    [_scollView addSubview:_timeLabel];
    
    _drivingScoreLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 140,140,80.)];
    _drivingScoreLabel.backgroundColor = [UIColor clearColor];
    _drivingScoreLabel.font = [UIFont boldSystemFontOfSize:80.];
    _drivingScoreLabel.textAlignment = NSTextAlignmentLeft;
    _drivingScoreLabel.textColor = [UIColor whiteColor];
    [_scollView addSubview:_drivingScoreLabel];
    [_drivingScoreLabel release];
    
    _scoreSymbolLabel = [self createLabelWithText:STR(@"DrivingTrack_symbol", Localize_DrivingTrack) fontSize:16.0 textAlignment:UITextAlignmentLeft];
    [_scoreSymbolLabel setFrame:CGRectMake(_drivingScoreLabel.frame.origin.x + _drivingScoreLabel.frame.size.width, _drivingScoreLabel.frame.origin.y + 50., 14., 14.)];
    [_scollView addSubview:_scoreSymbolLabel];
    
    _starView = [[GDStarView alloc] initWithCount:5 score:0];
    [_starView setFrame:CGRectMake(30., 260., 80., 14.)];
    [_scollView addSubview:_starView];
    [_starView release];
    
    _totalDistanceLabel = [[ColorLable alloc]initWithFrame:CGRectMake(20, 295,50,25.) ColorArray:[NSArray arrayWithObject:[UIColor redColor]]];
    [_totalDistanceLabel setColorText:@".",nil];
    _totalDistanceLabel.backgroundColor = [UIColor clearColor];
    _totalDistanceLabel.font = [UIFont systemFontOfSize:18.];
    _totalDistanceLabel.textAlignment = NSTextAlignmentCenter;
    _totalDistanceLabel.textColor = [UIColor blackColor];
    [_scollView addSubview:_totalDistanceLabel];
    [_totalDistanceLabel release];
    
    _disSymbolLabel = [self createLabelWithText:@"km" fontSize:9.0 textAlignment:UITextAlignmentLeft];
    [_disSymbolLabel setFrame:CGRectMake(_totalDistanceLabel.frame.origin.x + _totalDistanceLabel.frame.size.width, _totalDistanceLabel.frame.origin.y + 10., 25., 14.)];
    _disSymbolLabel.textColor = [UIColor blackColor];
    [_scollView addSubview:_disSymbolLabel];
    
    _totalTimeLabel = [[ColorLable alloc]initWithFrame:CGRectMake(100.,_totalDistanceLabel.frame.origin.y,80,25.) ColorArray:nil];
    _totalTimeLabel.backgroundColor = [UIColor clearColor];
    _totalTimeLabel.font = [UIFont systemFontOfSize:18];
    _totalTimeLabel.textAlignment = NSTextAlignmentCenter;
    _totalTimeLabel.textColor = [UIColor blackColor];
    [_scollView addSubview:_totalTimeLabel];
    [_totalTimeLabel release];
    
    _timeSymbolLabel = [self createLabelWithText:@"min" fontSize:9.0 textAlignment:UITextAlignmentLeft];
    [_timeSymbolLabel setFrame:CGRectMake(_totalTimeLabel.frame.origin.x + _totalTimeLabel.frame.size.width, _totalTimeLabel.frame.origin.y + 10., 22., 14.)];
    _timeSymbolLabel.textColor = [UIColor blackColor];
    [_scollView addSubview:_timeSymbolLabel];
    
    _averageSpeedLabel = [[ColorLable alloc]initWithFrame:CGRectMake(self.view.bounds.size.width - 120., _totalDistanceLabel.frame.origin.y,80,25.) ColorArray:[NSArray arrayWithObject:[UIColor redColor]]];
    [_averageSpeedLabel setColorText:@".",nil];
    _averageSpeedLabel.backgroundColor = [UIColor clearColor];
    _averageSpeedLabel.font = [UIFont systemFontOfSize:18];
    _averageSpeedLabel.textAlignment = NSTextAlignmentCenter;
    _averageSpeedLabel.textColor = [UIColor blackColor];
    [_scollView addSubview:_averageSpeedLabel];
    [_averageSpeedLabel release];
    
    _averageSpeedSymbolLabel = [self createLabelWithText:@"km/h" fontSize:9.0 textAlignment:UITextAlignmentLeft];
    [_averageSpeedSymbolLabel setFrame:CGRectMake(_averageSpeedLabel.frame.origin.x + _averageSpeedLabel.frame.size.width, _averageSpeedLabel.frame.origin.y + 10., 30., 14.)];
    _averageSpeedSymbolLabel.textColor = [UIColor blackColor];
    [_scollView addSubview:_averageSpeedSymbolLabel];
    
    _topSpeedLabel = [[ColorLable alloc]initWithFrame:CGRectMake(self.view.bounds.size.width - 120., _totalDistanceLabel.frame.origin.y,80,25.) ColorArray:[NSArray arrayWithObject:[UIColor redColor]]];
    [_topSpeedLabel setColorText:@".",nil];
    _topSpeedLabel.backgroundColor = [UIColor clearColor];
    _topSpeedLabel.font = [UIFont systemFontOfSize:18];
    _topSpeedLabel.textAlignment = NSTextAlignmentCenter;
    _topSpeedLabel.textColor = [UIColor blackColor];
    [_scollView addSubview:_topSpeedLabel];
    [_topSpeedLabel release];
    
    _topSpeedSymbolLabel = [self createLabelWithText:@"km/h" fontSize:9.0 textAlignment:UITextAlignmentLeft];
    _topSpeedSymbolLabel.textColor = [UIColor blackColor];
    [_scollView addSubview:_topSpeedSymbolLabel];
    
    _beatsLabel = [[ColorLable alloc]initWithFrame:CGRectMake(15., 265.,250.,25.) ColorArray:nil];
    _beatsLabel.backgroundColor = [UIColor clearColor];
    _beatsLabel.font = [UIFont systemFontOfSize:14.];
    _beatsLabel.textAlignment = NSTextAlignmentLeft;
    _beatsLabel.textColor = [UIColor blackColor];
    [_scollView addSubview:_beatsLabel];
    [_beatsLabel release];
    
    _disTextLabel = [self createLabelWithText:STR(@"DrivingTrack_dis", Localize_DrivingTrack) fontSize:11.0 textAlignment:UITextAlignmentCenter];
    [_disTextLabel setFrame:CGRectMake(_totalDistanceLabel.frame.origin.x , _totalDistanceLabel.frame.origin.y + _totalDistanceLabel.frame.size.height, 80., 20.)];
    _disTextLabel.textColor = [UIColor blackColor];
    [_scollView addSubview:_disTextLabel];
    
    _timeTextLabel = [self createLabelWithText:STR(@"DrivingTrack_time", Localize_DrivingTrack) fontSize:11.0 textAlignment:UITextAlignmentCenter];
    [_timeTextLabel setFrame:CGRectMake(_totalTimeLabel.frame.origin.x , _totalTimeLabel.frame.origin.y + _totalTimeLabel.frame.size.height, 100., 20.)];
    _timeTextLabel.textColor = [UIColor blackColor];
    [_scollView addSubview:_timeTextLabel];
    
    _averageTextLabel = [self createLabelWithText:STR(@"DrivingTrack_averageSpeed", Localize_DrivingTrack) fontSize:11.0 textAlignment:UITextAlignmentCenter];
    [_averageTextLabel setFrame:CGRectMake(_averageSpeedLabel.frame.origin.x +10., _averageSpeedLabel.frame.origin.y + _averageSpeedLabel.frame.size.height, 100., 20.)];
    _averageTextLabel.textColor = [UIColor blackColor];
    [_scollView addSubview:_averageTextLabel];
    
    _topSpeedTextLabel = [self createLabelWithText:STR(@"DrivingTrack_topSpeed", Localize_DrivingTrack) fontSize:11.0 textAlignment:UITextAlignmentCenter];
    _topSpeedTextLabel.textColor = [UIColor blackColor];
    [_scollView addSubview:_topSpeedTextLabel];
    
    
    _fuleScoreView = [[TrackScoreView alloc] initWithFrame:CGRectMake(15., 345., self.view.bounds.size.width, 30.)];
    _fuleScoreView.titleLabel.textColor = [UIColor blackColor];
    _fuleScoreView.titleLabel.font = [UIFont systemFontOfSize:14.];
    _fuleScoreView.symbolLabel.textColor = [UIColor colorWithRed:54/255.0 green:114/255.0 blue:5/255.0 alpha:1.0];
    _fuleScoreView.symbolLabel.font = [UIFont systemFontOfSize:12.];
    _fuleScoreView.scoreLabel.textColor = [UIColor colorWithRed:54.0/255.0 green:114.0/255.0 blue:5.0/255.0 alpha:1.0];
    _fuleScoreView.scoreLabel.font = [UIFont systemFontOfSize:24.];
    _fuleScoreView.scoreLabel.textAlignment = UITextAlignmentRight;
    _fuleScoreView.titleLabel.text = STR(@"DrivingTrack_fuelConsumption", Localize_DrivingTrack);
    _fuleScoreView.symbolLabel.text = STR(@"DrivingTrack_symbol", Localize_DrivingTrack);
    [_scollView addSubview:_fuleScoreView];
    [_fuleScoreView release];
    
    _safeScoreView = [[TrackScoreView alloc] initWithFrame:CGRectMake(15., 380., self.view.bounds.size.width, 30.)];
    _safeScoreView.titleLabel.textColor = [UIColor blackColor];
    _safeScoreView.titleLabel.font = [UIFont systemFontOfSize:14.];
    _safeScoreView.symbolLabel.textColor = [UIColor colorWithRed:54/255.0 green:114/255.0 blue:5/255.0 alpha:1.0];
    _safeScoreView.symbolLabel.font = [UIFont systemFontOfSize:12.];
    _safeScoreView.scoreLabel.textColor =  [UIColor colorWithRed:54/255.0 green:114/255.0 blue:5/255.0 alpha:1.0];
    _safeScoreView.scoreLabel.font = [UIFont systemFontOfSize:24.];
    _safeScoreView.scoreLabel.textAlignment = UITextAlignmentRight;
    _safeScoreView.titleLabel.text = STR(@"DrivingTrack_safety", Localize_DrivingTrack);
    _safeScoreView.symbolLabel.text = STR(@"DrivingTrack_symbol", Localize_DrivingTrack);
    [_scollView addSubview:_safeScoreView];
    [_safeScoreView release];
    
    _oilCountView = [[TrackCountView alloc] initWithFrame:CGRectMake(30., 410., 160., 80.)];
    _oilCountView.topImageView.image = IMAGE(@"drivingTrackHacceleration.png", IMAGEPATH_TYPE_1);
    _oilCountView.mtitleLabel.text = STR(@"DrivingTrack_hacceleration", Localize_DrivingTrack);
    [_scollView addSubview:_oilCountView];
    [_oilCountView release];
    
    _brakeCountView = [[TrackCountView alloc] initWithFrame:CGRectMake(180.,_oilCountView.frame.origin.y, 160., 80.)];
    _brakeCountView.topImageView.image = IMAGE(@"drivingTrackBrakes.png", IMAGEPATH_TYPE_1);
    _brakeCountView.mtitleLabel.text = STR(@"DrivingTrack_brakes", Localize_DrivingTrack);
    [_scollView addSubview:_brakeCountView];
    [_brakeCountView release];
    
    _turnCountView = [[TrackCountView alloc] initWithFrame:CGRectMake(30., 470., 160., 80.)];
    _turnCountView.topImageView.image = IMAGE(@"drivingTrackUturn.png", IMAGEPATH_TYPE_1);
    _turnCountView.mtitleLabel.text = STR(@"DrivingTrack_uturn", Localize_DrivingTrack);
    [_scollView addSubview:_turnCountView];
    [_turnCountView release];
    
    _speedHightCountView = [[TrackCountView alloc] initWithFrame:CGRectMake(180., _turnCountView.frame.origin.y, 160., 80.)];
    _speedHightCountView.topImageView.image = IMAGE(@"drivingTrackHypervelocity.png", IMAGEPATH_TYPE_1);
    _speedHightCountView.mtitleLabel.text = STR(@"DrivingTrack_hypervelocity", Localize_DrivingTrack);
    [_scollView addSubview:_speedHightCountView];
    [_speedHightCountView release];
    
    UIImage *bcImage = IMAGE(@"drivingTrackButtonBac.png", IMAGEPATH_TYPE_1);
    _shareBacImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0., 0., 320, 66.)];
    _shareBacImageView.image = [bcImage stretchableImageWithLeftCapWidth:6. topCapHeight:0];
    _shareBacImageView.userInteractionEnabled = YES;
    [self.view addSubview:_shareBacImageView];
    [_shareBacImageView release];
    
    _shareButton = [self createButtonWithTitle:STR(@"DrivingTrack_viewDetail", Localize_DrivingTrack) normalImage:@"drivingTrackShare.png" heightedImage:@"drivingTrackShare_1.png" tag:0 strechParamX:8 strechParamY:8];
    [_shareButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_shareBacImageView addSubview:_shareButton];
    
    _deleteButton = [self createButtonWithTitle:STR(@"DrivingTrack_share", Localize_DrivingTrack)  normalImage:@"POISearchBtn.png" heightedImage:@"POISearchBtn1.png" tag:1 strechParamX:5 strechParamY:6];
    UIImage *stretchableButtonImageNormal = [IMAGE(@"drivingTrackShare_1.png", IMAGEPATH_TYPE_1) stretchableImageWithLeftCapWidth:5 topCapHeight:6];
    [_deleteButton setBackgroundImage:stretchableButtonImageNormal  forState:UIControlStateHighlighted];
    [_deleteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_shareBacImageView addSubview:_deleteButton];
    
    UIImage *gradientHLine = [IMAGE(@"menulandscapeGrayLine.png", IMAGEPATH_TYPE_1) stretchableImageWithLeftCapWidth:0 topCapHeight:0];
    UIImage *gradientVLine = [IMAGE(@"menuportraitGrayline.png", IMAGEPATH_TYPE_1) stretchableImageWithLeftCapWidth:0 topCapHeight:0];
 
    _lineVer1 = [[UIImageView alloc] initWithImage:gradientVLine];
    _lineVer1.frame = (CGRect){_totalDistanceLabel.frame.origin.x + 80., _totalDistanceLabel.frame.origin.y +10., (CGSize){2. ,20.}};
    [_scollView addSubview:_lineVer1];
    [_lineVer1 release];
    
    _lineVer2 = [[UIImageView alloc] initWithImage:gradientVLine];
    _lineVer2.frame = (CGRect){_totalTimeLabel.frame.origin.x + 110., _totalTimeLabel.frame.origin.y +10., (CGSize){2. ,20.}};
    [_scollView addSubview:_lineVer2];
    [_lineVer2 release];
    
    _lineVer3 = [[UIImageView alloc] initWithImage:gradientVLine];
    _lineVer3.frame = (CGRect){_oilCountView.frame.origin.x + 130., _oilCountView.frame.origin.y +30., (CGSize){2. ,60.}};
    [_scollView addSubview:_lineVer3];
    [_lineVer3 release];
    
    _lineVer4 = [[UIImageView alloc] initWithImage:gradientVLine];
    _lineVer4.frame = (CGRect){_oilCountView.frame.origin.x + 130., _oilCountView.frame.origin.y +30., (CGSize){2. ,60.}};
    [_scollView addSubview:_lineVer4];
    [_lineVer4 release];
    
    _lineHer1 = [[UIImageView alloc] initWithImage:gradientHLine];
    _lineHer1.frame = (CGRect){10., _totalDistanceLabel.frame.origin.y +50., (CGSize){self.view.bounds.size.width - 20. ,2.}};
    [_scollView addSubview:_lineHer1];
    [_lineHer1 release];
    
    _lineHer2 = [[UIImageView alloc] initWithImage:gradientHLine];
    _lineHer2.frame = (CGRect){self.view.bounds.size.width/2.0 - 30., _oilCountView.frame.origin.y +60., (CGSize){60. ,2.}};
    [_scollView addSubview:_lineHer2];
    [_lineHer2 release];
    
    
}

- (void)drivingTrackCountHandle
{
    int count = [[DringTracksManage sharedInstance] getUnSyncDrivingFileCount];
    
    if (count > 90) {
        
        GDAlertView *alertView=[[GDAlertView alloc] initWithTitle:nil andMessage:STR(@"DrivingTrack_alertOverTrackCountLimit",Localize_DrivingTrack)];
        [alertView show];
        [alertView release];
    }
}

- (void)setValueWithDrivingTrack:(DrivingInfo *)trackInfo
{
    
    self.mTrackInfo = trackInfo;
    
    NSString *imageString = nil;
    
    if (self.mTrackInfo.resultType == DrivingResultType_Air) {
        imageString = [NSString stringWithFormat:@"drivingTrackAir_%@.jpg",STR(@"DrivingTrack_imageType", Localize_DrivingTrack)];
        
    }
    else if (self.mTrackInfo.resultType == DrivingResultType_Economical)
    {
        imageString = [NSString stringWithFormat:@"drivingTrackEconomical_%@.jpg",STR(@"DrivingTrack_imageType", Localize_DrivingTrack)];
    }
    else if (self.mTrackInfo.resultType == DrivingResultType_Happy)
    {
        imageString = [NSString stringWithFormat:@"drivingTrackHappy_%@.jpg",STR(@"DrivingTrack_imageType", Localize_DrivingTrack)];
    }
    else if (self.mTrackInfo.resultType == DrivingResultType_Police)
    {
        imageString = [NSString stringWithFormat:@"drivingTrackPolice_%@.jpg",STR(@"DrivingTrack_imageType", Localize_DrivingTrack)];
    }
    else if (self.mTrackInfo.resultType == DrivingResultType_Rookie)
    {
        imageString = [NSString stringWithFormat:@"drivingTrackRookie_%@.jpg",STR(@"DrivingTrack_imageType", Localize_DrivingTrack)];
    }
    
    _topImageView.image = IMAGE(imageString, IMAGEPATH_TYPE_1);
    
    _totalDistanceLabel.text = [NSString stringWithFormat:@"%.1f",self.mTrackInfo.trackLength/1000.0];
    _totalTimeLabel.text = [NSString stringWithFormat:@"%d",self.mTrackInfo.trackTimeConsuming];
    _averageSpeedLabel.text = [NSString stringWithFormat:@"%.0f",self.mTrackInfo.averageSpeed];
    
    double topSpeed = (self.mTrackInfo.higherSpeed > 0) ? self.mTrackInfo.higherSpeed : 0.0;
    _topSpeedLabel.text = [NSString stringWithFormat:@"%.0f",topSpeed];
    
    _drivingScoreLabel.text = [NSString stringWithFormat:@"%.f",self.mTrackInfo.trackScore];
    
    self.mTrackInfo.beatNum = [[DringTracksManage sharedInstance] countBeatNumWithScore:self.mTrackInfo.trackScore];
    
    _beatsLabel.text = [NSString stringWithFormat:STR(@"DrivingTrack_beats", Localize_DrivingTrack),self.mTrackInfo.beatNum,@"%"];
    _fuleScoreView.scoreLabel.text = [NSString stringWithFormat:@"%.f",self.mTrackInfo.fuelConsumption];
    [_fuleScoreView drawImageName:@"drivingTrackFuelConsumptionPrecent.png" precent:self.mTrackInfo.fuelConsumption width:self.view.bounds.size.width - 130.];
    [_fuleScoreView setNeedsDisplay];
    
    _safeScoreView.scoreLabel.text = [NSString stringWithFormat:@"%.f",self.mTrackInfo.safetyScore];
    [_safeScoreView drawImageName:@"drivingTrackSafePrecent.png" precent:self.mTrackInfo.safetyScore width:self.view.bounds.size.width - 130.];
    [_safeScoreView setNeedsDisplay];
    
    NSString *haccelerationCount = nil;
    NSString *brakesCount = nil;
    NSString *uturnCount = nil;
    NSString *hypervelocityCount = nil;
    
    if (self.mTrackInfo.haccelerationCount > 9) {
        haccelerationCount = [NSString stringWithFormat:@"%d",self.mTrackInfo.haccelerationCount];
    }
    else {
        haccelerationCount = [NSString stringWithFormat:@"0%d",self.mTrackInfo.haccelerationCount];
    }
    
    if (self.mTrackInfo.brakesCount > 9) {
        brakesCount = [NSString stringWithFormat:@"%d",self.mTrackInfo.brakesCount];
    }
    else {
        brakesCount = [NSString stringWithFormat:@"0%d",self.mTrackInfo.brakesCount];
    }
    
    if (self.mTrackInfo.uturnCount > 9) {
        uturnCount = [NSString stringWithFormat:@"%d",self.mTrackInfo.uturnCount];
    }
    else {
        uturnCount = [NSString stringWithFormat:@"0%d",self.mTrackInfo.uturnCount];
    }
    
    if (self.mTrackInfo.hypervelocityCount > 9) {
        hypervelocityCount = [NSString stringWithFormat:@"%d",self.mTrackInfo.hypervelocityCount];
    }
    else {
        hypervelocityCount = [NSString stringWithFormat:@"0%d",self.mTrackInfo.hypervelocityCount];
    }
    
    _oilCountView.countLabel.text = haccelerationCount;
    _brakeCountView.countLabel.text = brakesCount;
    _turnCountView.countLabel.text = uturnCount;
    _speedHightCountView.countLabel.text = hypervelocityCount;
    
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMddHHmmss"];
    NSDate *qtimeDate = [formatter dateFromString:self.mTrackInfo.creatTime];
    
    [formatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
    NSString *timeString = [formatter stringFromDate:qtimeDate];
    [formatter release];
    
    _timeLabel.text = timeString;
    [_starView SetScore:self.mTrackInfo.trackScore];
    
}

- (void)refreashDrivingTrack
{
    [_fuleScoreView drawImageName:@"drivingTrackFuelConsumptionPrecent.png" precent:self.mTrackInfo.fuelConsumption width:self.view.bounds.size.width - 140.];
    [_safeScoreView drawImageName:@"drivingTrackSafePrecent.png" precent:self.mTrackInfo.safetyScore width:self.view.bounds.size.width - 140.];
    
    [_fuleScoreView setNeedsDisplay];
    [_safeScoreView setNeedsDisplay];
}

//调整竖屏控件坐标和图片
-(void)changePortraitControlFrameWithImage
{
    float contentSize = -100.0;
    if (isiPhone) {
        if (iPhone5) {
            contentSize = 40.;
        }
        else{
            contentSize = 160.;
        }
    }
    [_scollView setFrame:CGRectMake(0., 0., APPWIDTH, APPHEIGHT)];
    [_scollView setContentSize:CGSizeMake(APPWIDTH,
                                          SCREENHEIGHT + contentSize)];
    
    [_topImageView setFrame:CGRectMake(0., 0., self.view.frame.size.width, kTopImageHight)];
    [_backButton setFrame:CGRectMake(APPWIDTH - 55., 10., 60., 60.)];
    [_timeLabel setFrame:CGRectMake(15., 26., 150., 30.)];
   
    
    if (isPad) {
        [_drivingScoreLabel setFrame:CGRectMake(_topImageView.frame.origin.x + 100,kTopImageHight - 200.,140,80.)];
    }
    else{
        [_drivingScoreLabel setFrame:CGRectMake(_topImageView.frame.origin.x + 17,kTopImageHight - 140.,140,80.)];
    }
    
    
    //得分
    CGSize labelSize = [_drivingScoreLabel.text sizeWithFont:_drivingScoreLabel.font
                              constrainedToSize:CGSizeMake(FLT_MAX,FLT_MAX)
                                  lineBreakMode:UILineBreakModeWordWrap];
    [_scoreSymbolLabel setFrame:CGRectMake(_drivingScoreLabel.frame.origin.x + labelSize.width, _drivingScoreLabel.frame.origin.y + 55., 55., 14.)];
    
    [_starView setFrame:CGRectMake(_drivingScoreLabel.frame.origin.x, _drivingScoreLabel.frame.origin.y + _drivingScoreLabel.frame.size.height, 80., 14.)];
    
     //总距离
    CGSize DistanceLabelSize = [_totalDistanceLabel.text sizeWithFont:_totalDistanceLabel.font
                                           constrainedToSize:CGSizeMake(FLT_MAX,FLT_MAX)
                                               lineBreakMode:UILineBreakModeWordWrap];
    [_totalDistanceLabel setFrame:CGRectMake(0., 0.,DistanceLabelSize.width+5.,DistanceLabelSize.height)];
    [_totalDistanceLabel setCenter:CGPointMake(APPWIDTH/8.0 - 10., _topImageView.frame.size.height + DistanceLabelSize.height/2.0 + 10.)];
    
    [_disSymbolLabel setFrame:CGRectMake(_totalDistanceLabel.frame.origin.x + DistanceLabelSize.width + 5., _totalDistanceLabel.frame.origin.y + 6., 25., 14.)];
    [_disTextLabel setFrame:CGRectMake(0., _totalDistanceLabel.frame.origin.y + _totalDistanceLabel.frame.size.height, APPWIDTH/4.0, 20.)];
    
    //总时间
    CGSize TimeSize = [_totalTimeLabel.text sizeWithFont:_totalTimeLabel.font
                                                    constrainedToSize:CGSizeMake(FLT_MAX,FLT_MAX)
                                                        lineBreakMode:UILineBreakModeWordWrap];
    [_totalTimeLabel setFrame:CGRectMake(0., 0.,TimeSize.width+5.,TimeSize.height)];
    [_totalTimeLabel setCenter:CGPointMake(APPWIDTH*3.0/8.0 - 10., _totalDistanceLabel.center.y)];
    [_timeSymbolLabel setFrame:CGRectMake(_totalTimeLabel.frame.origin.x + TimeSize.width + 5., _disSymbolLabel.frame.origin.y, 25., 14.)];
    [_timeTextLabel setFrame:CGRectMake(APPWIDTH/4.0 , _disTextLabel.frame.origin.y, APPWIDTH/4.0, 20.)];
    
    //平均速度
    CGSize AverageSize = [_averageSpeedLabel.text sizeWithFont:_averageSpeedLabel.font
                                               constrainedToSize:CGSizeMake(FLT_MAX,FLT_MAX)
                                                   lineBreakMode:UILineBreakModeWordWrap];
    [_averageSpeedLabel setFrame:CGRectMake(0., 0,AverageSize.width+5.,AverageSize.height)];
    [_averageSpeedLabel setCenter:CGPointMake(APPWIDTH*5.0/8.0 - 10. , _totalDistanceLabel.center.y)];
    
    [_averageSpeedSymbolLabel setFrame:CGRectMake(_averageSpeedLabel.frame.origin.x + AverageSize.width + 5., _disSymbolLabel.frame.origin.y, 30., 14.)];
    [_averageTextLabel setFrame:CGRectMake(APPWIDTH/2.0, _disTextLabel.frame.origin.y, APPWIDTH/4.0, 20.)];
    
    CGSize topSpeedSize = [_topSpeedLabel.text sizeWithFont:_topSpeedLabel.font
                                             constrainedToSize:CGSizeMake(FLT_MAX,FLT_MAX)
                                                 lineBreakMode:UILineBreakModeWordWrap];
    [_topSpeedLabel setFrame:CGRectMake(0., 0,topSpeedSize.width+5.,topSpeedSize.height)];
    [_topSpeedLabel setCenter:CGPointMake(APPWIDTH*7.0/8.0 - 10., _totalDistanceLabel.center.y)];
    
    [_topSpeedSymbolLabel setFrame:CGRectMake(_topSpeedLabel.frame.origin.x + topSpeedSize.width + 5., _disSymbolLabel.frame.origin.y, 30., 14.)];
    [_topSpeedTextLabel setFrame:CGRectMake(APPWIDTH*3.0/4.0, _disTextLabel.frame.origin.y, APPWIDTH/4.0, 20.)];
    
    float beaty = (isPad ? (kTopImageHight - 45.) : (kTopImageHight - 25.));
    [_beatsLabel setFrame:CGRectMake(_topImageView.frame.origin.x + 15., beaty,250.,25.)];
    
    _lineHer1.frame = (CGRect){10., _totalDistanceLabel.frame.origin.y +45., (CGSize){self.view.bounds.size.width - 20. ,2.}};
    
    [_fuleScoreView setFrame:CGRectMake(15., _lineHer1.frame.origin.y + 15., self.view.bounds.size.width, 30.)];
    
    [_safeScoreView setFrame:CGRectMake(15., _fuleScoreView.frame.origin.y + _fuleScoreView.frame.size.height , self.view.bounds.size.width, 30.)];
    
    //次数
    float countSize = (isPad ? (SCREENWIDTH - 220.) : (APPWIDTH/2.0 + 20.));
    float leftSize = (isPad ? (118.) : (APPWIDTH/2.0 - 150.));
    float countWidth = (isPad ? (90) : (50.));
    [_oilCountView setFrame:CGRectMake(leftSize, _safeScoreView.frame.origin.y + _safeScoreView.frame.size.height + 15., 160., 80.)];
    
    [_brakeCountView setFrame:CGRectMake(countSize,_oilCountView.frame.origin.y, 160., 80.)];
    
    [_turnCountView setFrame:CGRectMake(leftSize, _oilCountView.frame.origin.y + countWidth, 160., 80.)];
    
    [_speedHightCountView setFrame:CGRectMake(countSize, _turnCountView.frame.origin.y, 160., 80.)];
    
    float bacHeight = 0.0;
    if (IOS_7)
    {
        bacHeight = 34.;
    }
    else{
        bacHeight = 54.;
    }
    
    [_shareBacImageView setFrame:CGRectMake(0, APPHEIGHT - bacHeight, SCREENWIDTH, 54.)];
    [_shareButton setFrame:CGRectMake(5., 5., (self.view.bounds.size.width - 35.)/2.0, 44)];
    
    [_deleteButton setFrame:CGRectMake(self.view.bounds.size.width/2.0 + 12.5, 5., (self.view.bounds.size.width - 35.)/2.0, 44)];
    
    _lineVer1.frame = (CGRect){APPWIDTH/4.0, _totalDistanceLabel.frame.origin.y +10., (CGSize){2. ,20.}};
    
    _lineVer2.frame = (CGRect){APPWIDTH/2.0, _totalDistanceLabel.frame.origin.y +10., (CGSize){2. ,20.}};
    
    _lineVer3.frame = (CGRect){APPWIDTH/2.0, _oilCountView.frame.origin.y +18., (CGSize){2. ,60.}};
    
    _lineVer4.frame = (CGRect){APPWIDTH*3.0/4.0, _totalDistanceLabel.frame.origin.y +10., (CGSize){2. ,20.}};
    
    _lineHer2.frame = (CGRect){self.view.bounds.size.width/2.0 - 30., _oilCountView.frame.origin.y +43., (CGSize){60. ,2.}};
    
    [self refreashDrivingTrack];
}

//调整横屏控件坐标和图片
-(void)changeLandscapeControlFrameWithImage
{
    float contentSize = -50.0;
    float topImageSize = kTopImageHight;
    if (isiPhone) {
        if (iPhone5) {
            contentSize = 300.;
            topImageSize = kTopImageHight * 1.8f;
        }
        else{
            contentSize = 300.;
            topImageSize = kTopImageHight * 1.5f;
        }
    }
    else{
        topImageSize = kTopImageHight/2.0*3.2;
        contentSize = 300.;
    }
    [_scollView setFrame:CGRectMake(0., 0., SCREENHEIGHT, APPWIDTH)];
    [_scollView setContentSize:CGSizeMake(self.view.bounds.size.width,
                                          APPHEIGHT + contentSize)];
    
    [_topImageView setFrame:CGRectMake(0., 0.,APPHEIGHT, topImageSize)];
    [_backButton setFrame:CGRectMake(APPHEIGHT - 55., 10., 60., 60.)];
    [_timeLabel setFrame:CGRectMake(15., 26., 150., 30.)];
    
    if (isPad) {
        [_drivingScoreLabel setFrame:CGRectMake(_topImageView.frame.origin.x + 100,topImageSize - 250.,140,80.)];
    }
    else{
        [_drivingScoreLabel setFrame:CGRectMake(_topImageView.frame.origin.x + 20,topImageSize - 160.,140,80.)];
    }
    
    
    //得分
    CGSize labelSize = [_drivingScoreLabel.text sizeWithFont:_drivingScoreLabel.font
                                           constrainedToSize:CGSizeMake(FLT_MAX,FLT_MAX)
                                               lineBreakMode:UILineBreakModeWordWrap];
    [_scoreSymbolLabel setFrame:CGRectMake(_drivingScoreLabel.frame.origin.x + labelSize.width, _drivingScoreLabel.frame.origin.y + 55., 14., 14.)];
    
    [_starView setFrame:CGRectMake(_drivingScoreLabel.frame.origin.x, _drivingScoreLabel.frame.origin.y + _drivingScoreLabel.frame.size.height, 80., 14.)];
    
    //总距离
    CGSize DistanceLabelSize = [_totalDistanceLabel.text sizeWithFont:_totalDistanceLabel.font
                                                    constrainedToSize:CGSizeMake(FLT_MAX,FLT_MAX)
                                                        lineBreakMode:UILineBreakModeWordWrap];
    [_totalDistanceLabel setFrame:CGRectMake(0., 0.,DistanceLabelSize.width+5.,DistanceLabelSize.height)];
    [_totalDistanceLabel setCenter:CGPointMake(APPHEIGHT/8.0 - 10., _topImageView.frame.size.height + DistanceLabelSize.height/2.0 + 10.)];
    
    [_disSymbolLabel setFrame:CGRectMake(_totalDistanceLabel.frame.origin.x + DistanceLabelSize.width + 5., _totalDistanceLabel.frame.origin.y + 6., 25., 14.)];
    [_disTextLabel setFrame:CGRectMake(0., _totalDistanceLabel.frame.origin.y + _totalDistanceLabel.frame.size.height, APPHEIGHT/4.0, 20.)];
    
    //总时间
    CGSize TimeSize = [_totalTimeLabel.text sizeWithFont:_totalTimeLabel.font
                                       constrainedToSize:CGSizeMake(FLT_MAX,FLT_MAX)
                                           lineBreakMode:UILineBreakModeWordWrap];
    [_totalTimeLabel setFrame:CGRectMake(0., 0.,TimeSize.width+5.,TimeSize.height)];
    [_totalTimeLabel setCenter:CGPointMake(APPHEIGHT*3.0/8.0 - 10., _totalDistanceLabel.center.y)];
    [_timeSymbolLabel setFrame:CGRectMake(_totalTimeLabel.frame.origin.x + TimeSize.width + 5., _disSymbolLabel.frame.origin.y, 25., 14.)];
    [_timeTextLabel setFrame:CGRectMake(APPHEIGHT/4.0 , _disTextLabel.frame.origin.y, APPHEIGHT/4.0, 20.)];
    
    
    CGSize AverageSize = [_averageSpeedLabel.text sizeWithFont:_averageSpeedLabel.font
                                             constrainedToSize:CGSizeMake(FLT_MAX,FLT_MAX)
                                                 lineBreakMode:UILineBreakModeWordWrap];
    [_averageSpeedLabel setFrame:CGRectMake(0., 0,AverageSize.width+5.,AverageSize.height)];
    [_averageSpeedLabel setCenter:CGPointMake(APPHEIGHT*5.0/8.0 - 10., _totalDistanceLabel.center.y)];
    
    [_averageSpeedSymbolLabel setFrame:CGRectMake(_averageSpeedLabel.frame.origin.x + AverageSize.width + 5., _disSymbolLabel.frame.origin.y, 30., 14.)];
    [_averageTextLabel setFrame:CGRectMake(APPHEIGHT/2.0, _disTextLabel.frame.origin.y, APPHEIGHT/4.0, 20.)];
    
    CGSize topSpeedSize = [_topSpeedLabel.text sizeWithFont:_topSpeedLabel.font
                                          constrainedToSize:CGSizeMake(FLT_MAX,FLT_MAX)
                                              lineBreakMode:UILineBreakModeWordWrap];
    [_topSpeedLabel setFrame:CGRectMake(0., 0,topSpeedSize.width+5.,topSpeedSize.height)];
    [_topSpeedLabel setCenter:CGPointMake(APPHEIGHT*7.0/8.0 , _totalDistanceLabel.center.y)];
    
    [_topSpeedSymbolLabel setFrame:CGRectMake(_topSpeedLabel.frame.origin.x + topSpeedSize.width + 5., _disSymbolLabel.frame.origin.y, 30., 14.)];
    [_topSpeedTextLabel setFrame:CGRectMake(APPHEIGHT*3.0/4.0, _disTextLabel.frame.origin.y, APPHEIGHT/4.0, 20.)];
    
    float beaty = (isPad ? (topImageSize - 75.) : (topImageSize - 35.));
    [_beatsLabel setFrame:CGRectMake(_topImageView.frame.origin.x + 15., beaty,250.,25.)];
    
    _lineHer1.frame = (CGRect){10., _totalDistanceLabel.frame.origin.y +55., (CGSize){self.view.bounds.size.width - 20. ,2.}};
    
    [_fuleScoreView setFrame:CGRectMake(15., _lineHer1.frame.origin.y + 15., self.view.bounds.size.width, 30.)];
    
    [_safeScoreView setFrame:CGRectMake(15., _fuleScoreView.frame.origin.y + _fuleScoreView.frame.size.height + 10., self.view.bounds.size.width, 30.)];
    
    //次数
    float countSize = (isPad ? (SCREENHEIGHT - 200.) : (SCREENHEIGHT - 178.));
    float leftSize = (isPad ? (118.) : (49.));
    [_oilCountView setFrame:CGRectMake(leftSize, _safeScoreView.frame.origin.y + _safeScoreView.frame.size.height + 10., 160., 80.)];
    
    [_brakeCountView setFrame:CGRectMake(countSize,_oilCountView.frame.origin.y, 160., 80.)];
    
    [_turnCountView setFrame:CGRectMake(leftSize, _oilCountView.frame.origin.y + 50., 160., 80.)];
    
    [_speedHightCountView setFrame:CGRectMake(countSize, _turnCountView.frame.origin.y, 160., 80.)];
    
    float bacHeight = 0.0;
    if (IOS_7)
    {
        bacHeight = 34.;
    }
    else{
        bacHeight = 54.;
    }
    [_shareBacImageView setFrame:CGRectMake(0, APPWIDTH - bacHeight, SCREENHEIGHT, 54.)];
    [_shareButton setFrame:CGRectMake(5., 5., (self.view.frame.size.width - 35.)/2.0, 44)];
    [_deleteButton setFrame:CGRectMake(self.view.frame.size.width/2.0 + 12.5, 5., (self.view.frame.size.width - 35.)/2.0, 44)];
    
    _lineVer1.frame = (CGRect){APPHEIGHT/4.0, _totalDistanceLabel.frame.origin.y +10., (CGSize){2. ,20.}};
    
    _lineVer2.frame = (CGRect){APPHEIGHT/2.0, _totalDistanceLabel.frame.origin.y +10., (CGSize){2. ,20.}};
    
    _lineVer4.frame = (CGRect){APPHEIGHT*3.0/4.0, _totalDistanceLabel.frame.origin.y +10., (CGSize){2. ,20.}};
    
    _lineVer3.frame = (CGRect){APPHEIGHT/2.0, _oilCountView.frame.origin.y +13., (CGSize){2. ,60.}};
    
    _lineHer2.frame = (CGRect){self.view.bounds.size.width/2.0 - 30., _oilCountView.frame.origin.y +40., (CGSize){60. ,2.}};
    
    [self refreashDrivingTrack];
}

#pragma mark - LXActivityDelegate
- (void)didClickOnImageIndex:(NSInteger )didSelect
{
    //    Share_mileage_Message,//短信
    //    Share_mileage_Friend,//朋友圈
    //    Share_mileage_WeChat,//微信
    //    Share_mileage_SinaWeiBo,//新浪微博
    switch (didSelect) {
        case 0:
        {
            [MobClick event:UM_EVENTID_Mileage_Count label:UM_LABEL_Mileage_Message];
            shareTypebtn = Share_mileage_Message;
            [self requestMileageURLShare];
        }
            break;
        case 1:
        {
            [MobClick event:UM_EVENTID_Mileage_Count label:UM_LABEL_Mileage_ShareWeChat];
            shareTypebtn = Share_mileage_WeChat;
           [self requestMileageURLShare];
            
        }
            break;
        case 2:
        {
            [MobClick event:UM_EVENTID_Mileage_Count label:UM_LABEL_Mileage_ShareFriend];
            shareTypebtn = Share_mileage_Friend;
            [self requestMileageURLShare];
            
        }
            break;
        case 3:
        {
            [MobClick event:UM_EVENTID_Mileage_Count label:UM_LABEL_Mileage_ShareWeibo];
            shareTypebtn = Share_mileage_SinaWeiBo;
            [self requestMileageURLShare];
            
            
        }
            break;
            
        default:
            break;
    }

}

-(void)requestMileageURLShare{
    
    if (NetWorkType == 0) {
        GDAlertView *alertView=[[GDAlertView alloc] initWithTitle:nil andMessage:STR(@"MR_NetWorkErro",Localize_MileRecord)];
        [alertView show];
        [alertView release];
    }
    else{
        
        [QLoadingView showLoadingView:nil view:(UIWindow *)self.view];
        
        [[DringTracksManage sharedInstance] drivingTrackRequestWithType:RT_DrivingTrackShareRequest pageIndex:0 pageCount:0 drivingTrack:self.mTrackInfo];
        [DringTracksManage sharedInstance].delegate = self;
    }
    
}

- (NSString *)getShareText
{
    NSMutableString *shareString = [[NSMutableString alloc] init];
    [shareString appendString:STR(@"DrivingTrack_wholeTrack", Localize_DrivingTrack)];
    
    NSMutableArray *bArray = [[NSMutableArray alloc] init];
    NSMutableArray *nArray = [[NSMutableArray alloc] init];
    
    if (self.mTrackInfo.brakesCount > 0) {
        
       NSString *brakeString =  [NSString stringWithFormat:@"%@%d%@",STR(@"DrivingTrack_brakes", Localize_DrivingTrack),self.mTrackInfo.brakesCount,STR(@"DrivingTrack_times", Localize_DrivingTrack)];
        [bArray addObject:brakeString];
    }
    if (self.mTrackInfo.haccelerationCount > 0)
    {
        NSString *brakeString =  [NSString stringWithFormat:@"%@%d%@",STR(@"DrivingTrack_hacceleration", Localize_DrivingTrack),self.mTrackInfo.haccelerationCount,STR(@"DrivingTrack_times", Localize_DrivingTrack)];
        [bArray addObject:brakeString];
    }
    if (self.mTrackInfo.hypervelocityCount > 0)
    {
        NSString *brakeString =  [NSString stringWithFormat:@"%@%d%@",STR(@"DrivingTrack_hypervelocity", Localize_DrivingTrack),self.mTrackInfo.hypervelocityCount,STR(@"DrivingTrack_times", Localize_DrivingTrack)];
        [bArray addObject:brakeString];
    }
    if (self.mTrackInfo.uturnCount > 0)
    {
        NSString *brakeString =  [NSString stringWithFormat:@"%@%d%@",STR(@"DrivingTrack_uturn", Localize_DrivingTrack),self.mTrackInfo.uturnCount,STR(@"DrivingTrack_times", Localize_DrivingTrack)];
        [bArray addObject:brakeString];
    }

    if (self.mTrackInfo.brakesCount == 0) {
        
        [nArray addObject:STR(@"DrivingTrack_brakes", Localize_DrivingTrack)];
    }
    if (self.mTrackInfo.haccelerationCount == 0)
    {
        [nArray addObject:STR(@"DrivingTrack_hacceleration", Localize_DrivingTrack)];
    }
    if (self.mTrackInfo.hypervelocityCount == 0)
    {
        [nArray addObject:STR(@"DrivingTrack_hypervelocity", Localize_DrivingTrack)];
    }
    if (self.mTrackInfo.uturnCount == 0)
    {
        [nArray addObject:STR(@"DrivingTrack_uturn", Localize_DrivingTrack)];
    }

    if (bArray.count > 0) {
        NSString *bString = [bArray componentsJoinedByString:@"，"];
        [shareString appendString:bString];
    }
    if (nArray.count > 0) {
        [shareString appendString:@"，"];
        [shareString appendString:STR(@"DrivingTrack_no", Localize_DrivingTrack)];
        NSString *nString = [nArray componentsJoinedByString:@"、"];
        [shareString appendString:nString];
    }
    
    [bArray release];
    [nArray release];
    
    return [shareString autorelease];
}

-(void)turnToShare{
    
    NSString *shareURL = [DringTracksManage sharedInstance].shareText;
    
    NSString *moodString = [[DringTracksManage sharedInstance] countMoodTextWithType:self.mTrackInfo.resultType];
    
    if (shareURL) {
        
        if (shareTypebtn == Share_mileage_WeChat || shareTypebtn == Share_mileage_Friend) {
            
            int scene = 0;
            if (shareTypebtn == Share_mileage_Friend) {
                scene = 1;
            }
            
            NSString *content = [self getShareText];
            
            NSString *shareString = [NSString stringWithFormat:@"%.f%@,%@",self.mTrackInfo.trackScore,STR(@"DrivingTrack_symbol", Localize_DrivingTrack),moodString];
            
            NSDictionary *dic=@{@"viewController": self,
                                @"shareType":@(shareTypebtn),
                                @"Title":shareString,
                                @"content":content,
                                @"scene":@(scene),
                                @"URL":shareURL};
            
            [[PluginStrategy sharedInstance] allocModuleWithName:@"Plugin_Share" withObject:dic];
        }
        else
        {
            NSString *shareString = [NSString stringWithFormat:@"%.f%@,%@%@",self.mTrackInfo.trackScore,STR(@"DrivingTrack_symbol", Localize_DrivingTrack),moodString,shareURL];
            
            NSDictionary *dic=@{@"viewController": self,
                                @"shareType":@(shareTypebtn),
                                @"content":shareString};
            
            [[PluginStrategy sharedInstance] allocModuleWithName:@"Plugin_Share" withObject:dic];
        }
        
    }
    
}

//按钮点击事件
- (void)buttonAction:(id)sender {
    
	switch (((UIButton *)sender).tag) {
        case 0://点击查看轨迹
        {
            [MobClick event:UM_EVENTID_PersonalCenter_COUNT label:UM_LABEL_TrackDetailCount];
            if (self.mTrackInfo.drivingID) {
                DrivingTracks *trackInfo = [[DringTracksManage sharedInstance] readDrivingTrackWithID:self.mTrackInfo.drivingID dataURL:self.mTrackInfo.dataURL];
                if (trackInfo) {
                    DrivingTrackMapDetailViewController *viewController = [[DrivingTrackMapDetailViewController alloc] init];
                    viewController.trackInfo = [trackInfo retain];
                    [self.navigationController pushViewController:viewController animated:YES];
                    [viewController release];
                }
                else if (self.mTrackInfo.dataURL)
                {
                    [[DringTracksManage sharedInstance] drivingTrackFileDownloadWithURL:self.mTrackInfo.dataURL];
                    [DringTracksManage sharedInstance].delegate = self;
                    [QLoadingView showLoadingView:nil view:(UIWindow *)self.view];
                }
                
                
            }
        }
            break;
        case 1://点击分享
        {
            [MobClick event:UM_EVENTID_PersonalCenter_COUNT label:UM_LABEL_TrackShareCount];
            NSArray* arrayTitle=@[STR(@"Share_Sms", Localize_POIShare),STR(@"Share_Friend", Localize_POIShare),STR(@"Share_Moments", Localize_POIShare),STR(@"Share_Sina", Localize_POIShare),STR(@"Share_Cancel",Localize_POIShare)];
            NSArray* arrayImage =@[@"shareMess",@"shareFriend",@"shareWeixin",@"shareSina",@"Main_SettingCancel"];
            [SociallShareManage ShowViewWithDelegate:self andWithImage:arrayImage andWithTitle:arrayTitle];
            
            
        }
            break;
        case 2://点击返回按钮
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
            break;
    
        default:
        {
        }
            break;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat yOffset  = scrollView.contentOffset.y;
    if (yOffset < 0.) {
        CGRect f = _scollView.frame;
        f.origin.y = 0.;
        //f.size.height =  -yOffset + kTopImageHight;
        _scollView.frame = f;
    }
}

#pragma mark- 网络请求回调

- (void)requestToViewCtrWithRequestType:(RequestType)requestType didFinishLoadingWithResult:(id)result{
    
    if (requestType == RT_DrivingTrackShareRequest) {
        [QLoadingView hideWithAnimated:YES];
        
        [self turnToShare];
    }
    else if (requestType == RT_DrivingTrackDownload)
    {
        [QLoadingView hideWithAnimated:YES];
        
        DrivingTracks *trackInfo = [[DringTracksManage sharedInstance] readDrivingTrackWithID:self.mTrackInfo.drivingID dataURL:self.mTrackInfo.dataURL];
        if (trackInfo) {
            DrivingTrackMapDetailViewController *viewController = [[DrivingTrackMapDetailViewController alloc] init];
            viewController.trackInfo = [trackInfo retain];
            [self.navigationController pushViewController:viewController animated:YES];
            [viewController release];
        }
    }
    
    
    
}

- (void)requestToViewCtrWithRequestType:(RequestType)requestType didFailWithError:(NSError *)error{
    
    if (requestType == RT_DrivingTrackShareRequest) {
        [QLoadingView hideWithAnimated:YES];
        
        GDAlertView *alertView=[[GDAlertView alloc] initWithTitle:nil andMessage:STR(@"MR_NetWorkErro",Localize_MileRecord)];
        [alertView show];
        [alertView release];
    }
    else if (requestType == RT_DrivingTrackDownload)
    {
        [QLoadingView hideWithAnimated:YES];
        
        GDAlertView *alertView=[[GDAlertView alloc] initWithTitle:nil andMessage:STR(@"Universal_networkError",Localize_Universal)];
        [alertView show];
        [alertView release];
    }
    
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

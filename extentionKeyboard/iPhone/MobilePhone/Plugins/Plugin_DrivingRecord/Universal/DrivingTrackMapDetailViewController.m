//
//  DrivingTrackMapDetailViewController.m
//  AutoNavi
//
//  Created by longfeng.huang on 14-6-13.
//
//

#import "DrivingTrackMapDetailViewController.h"
#import "MWMapAddIconOperator.h"
#import "DrivingTracks.h"
#import "TrackCountView.h"
#import "DringTracksManage.h"
#import "MWMapOperator.h"
#import "MWMapOperator.h"
#import "MainDefine.h"

#import "PaintingView.h"

@interface DrivingTrackMapDetailViewController ()
{
    PaintingView *m_mapView;
    MWMapAddIconOperator *mapAddIcon;
    TrackCountView *_oilCountView;
    TrackCountView *_brakeCountView;
    TrackCountView *_turnCountView;
    TrackCountView *_speedHightCountView;
    
    UIView *backgroundView;
    UIImageView *_lineImageView1;
    UIImageView *_lineImageView2;
    UIImageView *_lineImageView3;
    UIButton *_buttonEnlargeMap;
    UIButton *_buttonNarrowMap;
    UIButton *_labelMeter;      //大小按钮下的地图比例尺大小图片
    NSTimer  *_timerInc;
    NSTimer  *_timerDec;
    BOOL    _isLongPress;
    int     onceTime;
}

@property (nonatomic, retain) NSMutableArray *iconArray;
@property (nonatomic, assign) DRIVINGTRACKVIEWTYPE viewType;

@end

@implementation DrivingTrackMapDetailViewController

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        _iconArray = [[NSMutableArray alloc] init];
        mapAddIcon = nil;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = STR(@"DrivingTrack_trackDetail", Localize_DrivingTrack);
    
    self.navigationItem.leftBarButtonItem = LEFTBARBUTTONITEM(@"", @selector(goBack));
    
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(listenNotification:) name:NOTIFY_SHOWMAP object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleUIUpdate:) name:NOTIFY_HandleUIUpdate object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(listenNotification:) name:NOTIFY_UPDATE_VIEWINFO object:nil];
    
    m_mapView  = [MapViewManager ShowMapViewInController:self];
    
    [self initControl];
    
    [self drawAllIcon];
    
    self.viewType = DRIVINGTRACKVIEWTYPE_WHOLE;
    onceTime = 0;
}

- (void)initControl
{
    backgroundView = [[UIView alloc] init];
    backgroundView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.9];
    [self.view addSubview:backgroundView];
    [backgroundView release];
    
    _oilCountView = [[TrackCountView alloc] initWithFrame:CGRectMake(0., APPHEIGHT - 110.,self.view.bounds.size.width/4., 80.)];
    _oilCountView.topImageView.image = IMAGE(@"drivingTrackOilIcon.png", IMAGEPATH_TYPE_1);
    _oilCountView.mtitleLabel.text = STR(@"DrivingTrack_hacceleration", Localize_DrivingTrack);
    _oilCountView.mtitleLabel.textAlignment = UITextAlignmentCenter;
    _oilCountView.countLabel.font = [UIFont systemFontOfSize:18.];
    _oilCountView.tag = 0;
    _oilCountView.showsTouchWhenHighlighted = YES;
    [_oilCountView addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_oilCountView];
    [_oilCountView release];
    
    _brakeCountView = [[TrackCountView alloc] initWithFrame:CGRectMake(_oilCountView.frame.origin.x + _oilCountView.frame.size.width,_oilCountView.frame.origin.y, _oilCountView.frame.size.width, _oilCountView.frame.size.height)];
    _brakeCountView.topImageView.image = IMAGE(@"drivingTrackBrakesIcon.png", IMAGEPATH_TYPE_1);
    _brakeCountView.mtitleLabel.text = STR(@"DrivingTrack_brakes", Localize_DrivingTrack);
    _brakeCountView.mtitleLabel.textAlignment = UITextAlignmentCenter;
    _brakeCountView.countLabel.font = [UIFont systemFontOfSize:18.];
    _brakeCountView.tag = 1;
    _brakeCountView.showsTouchWhenHighlighted = YES;
    [_brakeCountView addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_brakeCountView];
    [_brakeCountView release];
    
    _turnCountView = [[TrackCountView alloc] initWithFrame:CGRectMake(_brakeCountView.frame.origin.x + _brakeCountView.frame.size.width,_oilCountView.frame.origin.y, _oilCountView.frame.size.width, _oilCountView.frame.size.height)];
    _turnCountView.topImageView.image = IMAGE(@"drivingTrackUturnIcon.png", IMAGEPATH_TYPE_1);
    _turnCountView.mtitleLabel.text = STR(@"DrivingTrack_uturn", Localize_DrivingTrack);
    _turnCountView.mtitleLabel.textAlignment = UITextAlignmentCenter;
    _turnCountView.countLabel.font = [UIFont systemFontOfSize:18.];
    _turnCountView.tag = 2;
    _turnCountView.showsTouchWhenHighlighted = YES;
    [_turnCountView addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_turnCountView];
    [_turnCountView release];
    
    _speedHightCountView = [[TrackCountView alloc] initWithFrame:CGRectMake(_turnCountView.frame.origin.x + _turnCountView.frame.size.width,_oilCountView.frame.origin.y, _oilCountView.frame.size.width, _oilCountView.frame.size.height)];
    _speedHightCountView.topImageView.image = IMAGE(@"drivingTrackSpeedingIcon.png", IMAGEPATH_TYPE_1);
    _speedHightCountView.mtitleLabel.text = STR(@"DrivingTrack_hypervelocity", Localize_DrivingTrack);
    _speedHightCountView.mtitleLabel.textAlignment = UITextAlignmentCenter;
    _speedHightCountView.countLabel.font = [UIFont systemFontOfSize:18.];
    _speedHightCountView.tag = 3;
    _speedHightCountView.showsTouchWhenHighlighted = YES;
    [_speedHightCountView addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_speedHightCountView];
    [_speedHightCountView release];
    
    if (self.trackInfo) {
        NSString *haccelerationCount = nil;
        NSString *brakesCount = nil;
        NSString *uturnCount = nil;
        NSString *hypervelocityCount = nil;
        
        if (self.trackInfo.haccelerationArray.count > 9) {
            haccelerationCount = [NSString stringWithFormat:@"%d",self.trackInfo.haccelerationArray.count];
        }
        else {
            haccelerationCount = [NSString stringWithFormat:@"0%d",self.trackInfo.haccelerationArray.count];
        }
        
        if (self.trackInfo.brakesArray.count > 9) {
            brakesCount = [NSString stringWithFormat:@"%d",self.trackInfo.brakesArray.count];
        }
        else {
            brakesCount = [NSString stringWithFormat:@"0%d",self.trackInfo.brakesArray.count];
        }
        
        if (self.trackInfo.uturnArray.count > 9) {
            uturnCount = [NSString stringWithFormat:@"%d",self.trackInfo.uturnArray.count];
        }
        else {
            uturnCount = [NSString stringWithFormat:@"0%d",self.trackInfo.uturnArray.count];
        }
        
        if (self.trackInfo.hypervelocityArray.count > 9) {
            hypervelocityCount = [NSString stringWithFormat:@"%d",self.trackInfo.hypervelocityArray.count];
        }
        else {
            hypervelocityCount = [NSString stringWithFormat:@"0%d",self.trackInfo.hypervelocityArray.count];
        }
        
        _oilCountView.countLabel.text = haccelerationCount;
        _brakeCountView.countLabel.text = brakesCount;
        _turnCountView.countLabel.text = uturnCount;
        _speedHightCountView.countLabel.text = hypervelocityCount;
    }
    
    
    UIImage *gradientVLine = [IMAGE(@"menuportraitGrayline.png", IMAGEPATH_TYPE_1) stretchableImageWithLeftCapWidth:0 topCapHeight:0];
    
    _lineImageView1 = [[UIImageView alloc] initWithImage:gradientVLine];
    [self.view addSubview:_lineImageView1];
    [_lineImageView1 release];
    
    _lineImageView2 = [[UIImageView alloc] initWithImage:gradientVLine];
    [self.view addSubview:_lineImageView2];
    [_lineImageView2 release];
    
    _lineImageView3 = [[UIImageView alloc] initWithImage:gradientVLine];
    [self.view addSubview:_lineImageView3];
    [_lineImageView3 release];
    
    _buttonEnlargeMap = [self buttonInCondition:4];
    _buttonNarrowMap = [self buttonInCondition:5];
    
    UILongPressGestureRecognizer *longPress =[[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(ZoomInLongPressed:)]autorelease];
	longPress.minimumPressDuration =0.2;
	[_buttonEnlargeMap addGestureRecognizer:longPress];
	[_buttonEnlargeMap addTarget:self action:@selector(decFun:) forControlEvents:UIControlEventTouchUpInside];
    
    longPress =[[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(ZoomOutLongPressed:)]autorelease];
	longPress.minimumPressDuration =0.2;
	[_buttonNarrowMap addGestureRecognizer:longPress];
	[_buttonNarrowMap addTarget:self action:@selector(incFun:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_buttonEnlargeMap];
    [self.view addSubview:_buttonNarrowMap];
    
    //GPS-比例尺
	_labelMeter =  [self buttonInCondition:6] ;
    [_labelMeter.titleLabel setFont:[UIFont systemFontOfSize:10]];
	[self.view addSubview:_labelMeter];
    
    [_labelMeter setTitle:[[MWMapOperator sharedInstance] GetCurrentScale] forState:UIControlStateNormal];
    [self.view addSubview:_labelMeter];
    if([[MWPreference sharedInstance] getValue:PREF_DAYNIGHTMODE] == 1)
    {
        [_labelMeter setTitleColor:GETSKINCOLOR(MAIN_NIGHT_METER_COLOR) forState:UIControlStateNormal];
    }
    else
    {
        [_labelMeter setTitleColor:GETSKINCOLOR(MAIN_DAY_METER_COLOR) forState:UIControlStateNormal];
    }
}

- (void)setTrackLineInfoWithType
{
    if (self.trackInfo) {
        
        int count = self.trackInfo.trace.coordinates.count;
        
        if (count > 2000) {//引擎限制2000个点
            count = 2000;
        }
        
        if (self.viewType == DRIVINGTRACKVIEWTYPE_WHOLE) {
            
            if (self.trackInfo.hypervelocityArray.count > 0) {
                
                DCoordinate *firstCoord = [self.trackInfo.hypervelocityArray firstObject];
                
                if (firstCoord.coordType != 1) { //9.0版本之前使用遍历方法
                    
                    int index = 0;
                    
                    for (DCoordinate *coord in self.trackInfo.hypervelocityArray) {
                        
                            for (int i = index; i < count; i++) {
                                
                                DCoordinate *codinate = [self.trackInfo.trace.coordinates caObjectsAtIndex:i];
                                if (codinate && coord.lon == codinate.lon && coord.lat == codinate.lat) {
                                    
                                    index = i + 1;
                                    codinate.coordType = 1;
                                    
                                    break;
                                }
                            }
                        
                    }
                    
                }
                else {
                    
                    for (DCoordinate *coord in self.trackInfo.hypervelocityArray) {
                        
                            DCoordinate *tmp2 = [self.trackInfo.trace.coordinates caObjectsAtIndex:coord.arrayNum];
                        
                            tmp2.coordType = 1;
                        
                        
                    }
                }
            }
            if (self.trackInfo.haccelerationArray.count > 0) {
                
                DCoordinate *firstCoord = [self.trackInfo.haccelerationArray firstObject];
                
                if (firstCoord.coordType != 1) { //9.0版本之前使用遍历方法
                    
                    int index = 0;
                    
                    for (DCoordinate *coord in self.trackInfo.haccelerationArray) {
                        
                        
                        for (int i = index; i < count; i++) {
                            
                            DCoordinate *codinate = [self.trackInfo.trace.coordinates caObjectsAtIndex:i];
                            if (codinate && coord.lon == codinate.lon && coord.lat == codinate.lat) {
                                
                                index = i + 1;
                                codinate.coordType = 2;
                                
                                break;
                            }
                        }
                        
                    }
                    
                }
                else {
                    
                    for (DCoordinate *coord in self.trackInfo.haccelerationArray) {
                        
                        DCoordinate *tmp2 = [self.trackInfo.trace.coordinates caObjectsAtIndex:coord.arrayNum];
                        
                        tmp2.coordType = 2;
                        
                    }
                }
            }
            if (self.trackInfo.brakesArray.count > 0) {
                
                DCoordinate *firstCoord = [self.trackInfo.brakesArray firstObject];
                
                if (firstCoord.coordType != 1) { //9.0版本之前使用遍历方法
                    
                    int index = 0;
                    
                    for (DCoordinate *coord in self.trackInfo.brakesArray) {
                        
                        for (int i = index; i < count; i++) {
                            
                            DCoordinate *codinate = [self.trackInfo.trace.coordinates caObjectsAtIndex:i];
                            if (codinate && coord.lon == codinate.lon && coord.lat == codinate.lat) {
                                
                                index = i + 1;
                                codinate.coordType = 3;
                                
                                break;
                            }
                        }
                        
                    }
                    
                }
                else {
                    
                    for (DCoordinate *coord in self.trackInfo.brakesArray) {
                        
                        DCoordinate *tmp2 = [self.trackInfo.trace.coordinates caObjectsAtIndex:coord.arrayNum];
                        
                        tmp2.coordType = 3;
                        
                    }
                }
            }
            if (self.trackInfo.uturnArray.count > 0) {
                
                DCoordinate *firstCoord = [self.trackInfo.uturnArray firstObject];
                
                if (firstCoord.coordType != 1) { //9.0版本之前使用遍历方法
                    
                    int index = 0;
                    for (DCoordinate *coord in self.trackInfo.uturnArray) {
                        
                        
                        for (int i = index; i < count; i++) {
                            
                            DCoordinate *codinate = [self.trackInfo.trace.coordinates caObjectsAtIndex:i];
                            if (codinate && coord.lon == codinate.lon && coord.lat == codinate.lat) {
                                
                                index = i + 1;
                                codinate.coordType = 4;
                                
                                break;
                            }
                        }
                        
                    }
                    
                }
                else {
                    
                    for (DCoordinate *coord in self.trackInfo.uturnArray) {
                        
                        DCoordinate *tmp2 = [self.trackInfo.trace.coordinates caObjectsAtIndex:coord.arrayNum];
                        
                        tmp2.coordType = 4;
                    }
                }
            }
        }
        else if (self.viewType == DRIVINGTRACKVIEWTYPE_HYSPEED)
        {
            if (self.trackInfo.hypervelocityArray.count > 0) {
                
                DCoordinate *firstCoord = [self.trackInfo.hypervelocityArray firstObject];
                
                if (firstCoord.coordType != 1) { //9.0版本之前使用遍历方法
                    
                    int index = 0;
                    for (DCoordinate *coord in self.trackInfo.hypervelocityArray) {
                        
                        
                        for (int i = index; i < count; i++) {
                            
                            DCoordinate *codinate = [self.trackInfo.trace.coordinates caObjectsAtIndex:i];
                            if (codinate && coord.lon == codinate.lon && coord.lat == codinate.lat) {
                                
                                index = i + 1;
                                codinate.coordType = 1;
                                
                                break;
                            }
                        }
                        
                    }
                    
                }
                else {
                    
                    for (DCoordinate *coord in self.trackInfo.hypervelocityArray) {
                        
                        
                        DCoordinate *tmp2 = [self.trackInfo.trace.coordinates caObjectsAtIndex:coord.arrayNum];
                        
                        tmp2.coordType = 1;
                        
                    }
                }
            }
        }
        else if (self.viewType == DRIVINGTRACKVIEWTYPE_ACCELERATE)
        {
            if (self.trackInfo.haccelerationArray.count > 0) {
                
                DCoordinate *firstCoord = [self.trackInfo.haccelerationArray firstObject];
                
                if (firstCoord.coordType != 1) { //9.0版本之前使用遍历方法
                    
                    int index = 0;
                    for (DCoordinate *coord in self.trackInfo.haccelerationArray) {
                        
                        for (int i = index; i < count; i++) {
                            
                            DCoordinate *codinate = [self.trackInfo.trace.coordinates caObjectsAtIndex:i];
                            if (codinate && coord.lon == codinate.lon && coord.lat == codinate.lat) {
                                
                                index = i + 1;
                                codinate.coordType = 2;
                                
                                break;
                            }
                        }
                        
                    }
                    
                }
                else {
                    
                    for (DCoordinate *coord in self.trackInfo.haccelerationArray) {
                        
                        DCoordinate *tmp2 = [self.trackInfo.trace.coordinates caObjectsAtIndex:coord.arrayNum];
                        
                        tmp2.coordType = 2;
                        
                    }
                }
            }
        }
        else if (self.viewType == DRIVINGTRACKVIEWTYPE_BRAKES)
        {
            if (self.trackInfo.brakesArray.count > 0) {
                
                DCoordinate *firstCoord = [self.trackInfo.brakesArray firstObject];
                
                if (firstCoord.coordType != 1) { //9.0版本之前使用遍历方法
                    
                    int index = 0;
                    for (DCoordinate *coord in self.trackInfo.brakesArray) {
                        
                        for (int i = index; i < count; i++) {
                            
                            DCoordinate *codinate = [self.trackInfo.trace.coordinates caObjectsAtIndex:i];
                            if (codinate && coord.lon == codinate.lon && coord.lat == codinate.lat) {
                                
                                index = i + 1;
                                codinate.coordType = 3;
                                
                                break;
                            }
                        }
                        
                    }
                    
                }
                else {
                    
                    for (DCoordinate *coord in self.trackInfo.brakesArray) {
                        
                        DCoordinate *tmp2 = [self.trackInfo.trace.coordinates caObjectsAtIndex:coord.arrayNum];
                
                        tmp2.coordType = 3;
                        
                    }
                }
            }
        }
        else if (self.viewType == DRIVINGTRACKVIEWTYPE_TURN)
        {
            if (self.trackInfo.uturnArray.count > 0) {
                
                DCoordinate *firstCoord = [self.trackInfo.uturnArray firstObject];
                
                if (firstCoord.coordType != 1) { //9.0版本之前使用遍历方法
                    
                    int index = 0;
                    for (DCoordinate *coord in self.trackInfo.uturnArray) {
                        
                        for (int i = index; i < count; i++) {
                            
                            DCoordinate *codinate = [self.trackInfo.trace.coordinates caObjectsAtIndex:i];
                            if (codinate && coord.lon == codinate.lon && coord.lat == codinate.lat) {
                                
                                index = i + 1;
                                codinate.coordType = 4;
                                
                                break;
                            }
                        }
                        
                    }
                    
                }
                else {
                    
                    for (DCoordinate *coord in self.trackInfo.uturnArray) {
                       
                        DCoordinate *tmp2 = [self.trackInfo.trace.coordinates caObjectsAtIndex:coord.arrayNum];
                        
                        tmp2.coordType = 4;
                        
                        
                    }
                }
            }
        }
        
        
        int flag = 0; //记录点类型
        int numPoint = 0;//记录每段的点个数
        
        //统计轨迹分段绘图信息，段数，段索引，段长度
        NSMutableArray *drivingArray = [[NSMutableArray alloc] init];
        
        NSRange range = {0};
        for (int i = 0; i < count ; i++) {
            
            DCoordinate *coord = [self.trackInfo.trace.coordinates caObjectsAtIndex:i];
            
            if (i != 0 && flag != coord.coordType && (self.viewType == DRIVINGTRACKVIEWTYPE_WHOLE || self.viewType == coord.coordType || flag == self.viewType)) {
                
                flag = coord.coordType;
                
                range.length = numPoint;
                [drivingArray addObject:NSStringFromRange(range)];
                
                numPoint = 1;
                range.location = i-1;
            }
            
            numPoint++;
            
            if (i >= (count-1))
            {
                range.length = numPoint;
                [drivingArray addObject:NSStringFromRange(range)];
            }
            
        }
        
        int pTrackCount = drivingArray.count;
        int coordType = 0;
        
        
        GTRACKLINEINFO *pTrackInfo = {0};
        
        pTrackInfo = malloc(pTrackCount * sizeof(GTRACKLINEINFO));
        
        for (int i = 0; i < pTrackCount ; i++) {
            
            NSString *rangeString = [drivingArray caObjectsAtIndex:i];
            
            if (rangeString) {
                
                NSRange tRange = NSRangeFromString(rangeString);
                
                GPOINT *pcoord = malloc(tRange.length*sizeof(GPOINT));
                
                for (int j = tRange.location; j < (tRange.location + tRange.length); j++) {
                    
                    DCoordinate *coord = [self.trackInfo.trace.coordinates caObjectsAtIndex:j];
                    if (coord) {
                        
                        coordType = coord.coordType;
                        
                        pcoord[j-tRange.location].x = coord.lon;
                        pcoord[j-tRange.location].y = coord.lat;
                        pcoord[j-tRange.location].z = coord.Altitude;
                    }
                    
                }
                
                pTrackInfo[i].pCoord = pcoord;
                pTrackInfo[i].nNum = tRange.length;
                pTrackInfo[i].nLineSideWide = 6;
                pTrackInfo[i].nLineWide = 14;
                
                if (coordType == 0) {//一般颜色
                    
                    pTrackInfo[i].clrFill.r = 1;
                    pTrackInfo[i].clrFill.g = 111;
                    pTrackInfo[i].clrFill.b = 234;
                    pTrackInfo[i].clrFill.a = 255;
                    pTrackInfo[i].clrSide.r = 0;
                    pTrackInfo[i].clrSide.g = 72;
                    pTrackInfo[i].clrSide.b = 192;
                    pTrackInfo[i].clrSide.a = 255;
                    
                }
                else if (coordType == 1) {//超速颜色
                    
                    pTrackInfo[i].clrFill.r = 255;
                    pTrackInfo[i].clrFill.g = 131;
                    pTrackInfo[i].clrFill.b = 48;
                    pTrackInfo[i].clrFill.a = 255;
                    pTrackInfo[i].clrSide.r = 227;
                    pTrackInfo[i].clrSide.g = 87;
                    pTrackInfo[i].clrSide.b = 19;
                    pTrackInfo[i].clrSide.a = 255;
                }
                else if (coordType == 2) {//急加速颜色
                    
                    pTrackInfo[i].clrFill.r = 250;
                    pTrackInfo[i].clrFill.g = 98;
                    pTrackInfo[i].clrFill.b = 98;
                    pTrackInfo[i].clrFill.a = 255;
                    pTrackInfo[i].clrSide.r = 232;
                    pTrackInfo[i].clrSide.g = 68;
                    pTrackInfo[i].clrSide.b = 68;
                    pTrackInfo[i].clrSide.a = 255;
                }
                else if (coordType == 3) {//急刹车颜色
                    
                    pTrackInfo[i].clrFill.r = 68;
                    pTrackInfo[i].clrFill.g = 237;
                    pTrackInfo[i].clrFill.b = 51;
                    pTrackInfo[i].clrFill.a = 255;
                    pTrackInfo[i].clrSide.r = 32;
                    pTrackInfo[i].clrSide.g = 196;
                    pTrackInfo[i].clrSide.b = 15;
                    pTrackInfo[i].clrSide.a = 255;
                }
                else if (coordType == 4) {//急转弯颜色
                    
                    pTrackInfo[i].clrFill.r = 42;
                    pTrackInfo[i].clrFill.g = 201;
                    pTrackInfo[i].clrFill.b = 253;
                    pTrackInfo[i].clrFill.a = 255;
                    pTrackInfo[i].clrSide.r = 16;
                    pTrackInfo[i].clrSide.g = 163;
                    pTrackInfo[i].clrSide.b = 189;
                    pTrackInfo[i].clrSide.a = 255;
                }
                else {//一般颜色
                    
                    pTrackInfo[i].clrFill.r = 1;
                    pTrackInfo[i].clrFill.g = 111;
                    pTrackInfo[i].clrFill.b = 234;
                    pTrackInfo[i].clrFill.a = 255;
                    pTrackInfo[i].clrSide.r = 0;
                    pTrackInfo[i].clrSide.g = 72;
                    pTrackInfo[i].clrSide.b = 192;
                    pTrackInfo[i].clrSide.a = 255;
                    
                }
            }
            
            
        }
        
        GRECT rect = {0};
        rect.bottom = self.view.frame.size.height *2;
        rect.left = 0;
        rect.top = 0;
        rect.right = self.view.frame.size.width *2;
        
        [MWTrack SetTrackLineInfo:pTrackInfo nNUm:pTrackCount rect:rect];
        
        for (int k = 0 ; k < drivingArray.count; k++) {
            
            if (pTrackInfo[k].pCoord) {
                free(pTrackInfo[k].pCoord);
            }
        }
        
        if (pTrackInfo) {
            free(pTrackInfo);
        }
        
        
        [drivingArray release];
        
        //移图到轨迹中间点
        
        if (onceTime == 0) {
            
            onceTime ++;
            
            GCOORD firstCoord = {0};
            int halfCount = count/2;
            
            DCoordinate *tmp = [self.trackInfo.trace.coordinates caObjectsAtIndex:halfCount];
            
            firstCoord.x = tmp.lon;
            firstCoord.y = tmp.lat;
            
            if (firstCoord.x != 0 && firstCoord.y != 0) {
                
                GMOVEMAP moveMap;
                moveMap.eOP = MOVEMAP_OP_GEO_DIRECT;
                moveMap.deltaCoord.x = firstCoord.x;
                moveMap.deltaCoord.y = firstCoord.y;
                
                [[MWMapOperator sharedInstance] MW_MoveMapView:GMAP_VIEW_TYPE_MAIN TypeAndCoord:&moveMap];
            }
            
            [[MWMapOperator sharedInstance] MW_ZoomTo:ZOOM_5_KM Animated:NO]; //地图缩放到5km
        }
        
    }
}

- (void)viewWillAppear:(BOOL)animated {
    
    m_mapView  = [MapViewManager ShowMapViewInController:self]; //要放在调用 [super viewWillAppear:animated] 之前，切换多次地图后，会造成无法放大缩小
	[super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    
    
    
    [[MWMapOperator sharedInstance] MW_ShowMapView:GMAP_VIEW_TYPE_MAIN WithParma1:0 WithParma2:0 WithParma3:0];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    GRECT rect = {0};
    [MWTrack SetTrackLineInfo:NULL nNUm:0 rect:rect];
    
    if ([MWMapAddIconOperator ExistIconInMap:mapAddIcon]) {
        [MWMapAddIconOperator ClearMapIcon];
    }
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[MWMapOperator sharedInstance] MW_GoToCCP];
}

- (void)listenNotification:(NSNotification *)notification
{

    if([notification.name isEqual:NOTIFY_UPDATE_VIEWINFO])
    {
        [self viewInfoInCondition:0];
    }
   
	if ([notification.name isEqual:NOTIFY_SHOWMAP]&& self.navigationController.topViewController == self)
	{
        [m_mapView swapBuffers];
	}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    CRELEASE(mapAddIcon);
    CRELEASE(_trackInfo);
    CRELEASE(_iconArray);
    
    m_mapView.delegate=nil;
    
	[super dealloc];
}

- (void)changePortraitControlFrameWithImage {
	
    [m_mapView setmyFrame:CGRectMake(0.0, 0.0, SCREENWIDTH, SCREENHEIGHT)];
    [[MWPreference sharedInstance] setValue:PREF_DISPLAY_ORIENTATION Value:1];
    
    [_oilCountView setFrame:CGRectMake(0., SCREENHEIGHT - 140.,self.view.bounds.size.width/4., 80.)];
    [_oilCountView.topImageView setFrame:CGRectMake(_oilCountView.frame.size.width/2.0 - 40., 10., 42., 42.)];
    [_oilCountView.mtitleLabel setFrame:CGRectMake(0.,50., self.view.bounds.size.width/4., 25.)];
    [_oilCountView.symbolLabel setFrame:CGRectMake(_oilCountView.frame.size.width/2.0, 23., 15., 15.)];
    [_oilCountView.countLabel setFrame:CGRectMake(_oilCountView.frame.size.width/2.0 + 15., 5., 50., 50.)];
    
    [_brakeCountView setFrame:CGRectMake(_oilCountView.frame.origin.x + _oilCountView.frame.size.width,_oilCountView.frame.origin.y, _oilCountView.frame.size.width, _oilCountView.frame.size.height)];
    [_brakeCountView.topImageView setFrame:CGRectMake(_oilCountView.topImageView.frame.origin.x, 10., 42., 42.)];
    [_brakeCountView.mtitleLabel setFrame:CGRectMake(_oilCountView.mtitleLabel.frame.origin.x,50., self.view.bounds.size.width/4., 25.)];
    [_brakeCountView.symbolLabel setFrame:CGRectMake(_oilCountView.frame.size.width/2.0, 23., 15., 15.)];
    [_brakeCountView.countLabel setFrame:CGRectMake(_oilCountView.countLabel.frame.origin.x, 5., 50., 50.)];
    
    [_turnCountView setFrame:CGRectMake(_brakeCountView.frame.origin.x + _brakeCountView.frame.size.width,_oilCountView.frame.origin.y, _oilCountView.frame.size.width, _oilCountView.frame.size.height)];
    [_turnCountView.topImageView setFrame:CGRectMake(_oilCountView.topImageView.frame.origin.x, 10., 42., 42.)];
    [_turnCountView.mtitleLabel setFrame:CGRectMake(_oilCountView.mtitleLabel.frame.origin.x,50., self.view.bounds.size.width/4., 25.)];
    [_turnCountView.symbolLabel setFrame:CGRectMake(_oilCountView.frame.size.width/2.0, 23., 15., 15.)];
    [_turnCountView.countLabel setFrame:CGRectMake(_oilCountView.countLabel.frame.origin.x, 5., 50., 50.)];
    
    [_speedHightCountView setFrame:CGRectMake(_turnCountView.frame.origin.x + _turnCountView.frame.size.width,_oilCountView.frame.origin.y, _oilCountView.frame.size.width, _oilCountView.frame.size.height)];
    [_speedHightCountView.topImageView setFrame:CGRectMake(_oilCountView.topImageView.frame.origin.x, 10., 42., 42.)];
    [_speedHightCountView.mtitleLabel setFrame:CGRectMake(_oilCountView.mtitleLabel.frame.origin.x,50., self.view.bounds.size.width/4., 25.)];
    [_speedHightCountView.symbolLabel setFrame:CGRectMake(_oilCountView.frame.size.width/2.0, 23., 15., 15.)];
    [_speedHightCountView.countLabel setFrame:CGRectMake(_oilCountView.countLabel.frame.origin.x, 5., 50., 50.)];
    
    backgroundView.frame = (CGRect){0, SCREENHEIGHT - 130., (CGSize){APPWIDTH ,80.}};
    _lineImageView1.frame = (CGRect){APPWIDTH/4.0, SCREENHEIGHT - 90., (CGSize){2 ,20.}};
    _lineImageView2.frame = (CGRect){APPWIDTH*2.0/4.0, _lineImageView1.frame.origin.y, (CGSize){2 ,20.}};
    _lineImageView3.frame = (CGRect){APPWIDTH*3.0/4.0, _lineImageView2.frame.origin.y, (CGSize){2 ,20.}};
    
    if(isiPhone)
    {
        //放大，缩小
        [_buttonNarrowMap setFrame:CGRectMake(0.0f, 0.0f, 40.0f, 42.0f)];
        [_buttonNarrowMap setCenter:CGPointMake(MAIN_POR_WIDTH - BUTTON_BOUNDARY, CONTENTHEIGHT_V-84.0f - _buttonNarrowMap.frame.size.height / 2)];
        
        [_buttonEnlargeMap setFrame:CGRectMake(0.0f, 0.0f, 40.0f, 42.0f)];
        [_buttonEnlargeMap setCenter:CGPointMake(MAIN_POR_WIDTH - BUTTON_BOUNDARY, _buttonNarrowMap.center.y -_buttonEnlargeMap.frame.size.height  )];
        
        [_labelMeter setFrame:CGRectMake(0.0f, 0.0f, 36.0f, 12.0f)];
        [_labelMeter setCenter:CGPointMake(MAIN_POR_WIDTH - BUTTON_BOUNDARY, _buttonEnlargeMap.frame.origin.y - 5.0f - _labelMeter.frame.size.height / 2)];
        
    }
    else//ipad竖屏
    {
        //放大，缩小
        [_buttonEnlargeMap setFrame:CGRectMake(0.0f, 0.0f, 60.0f, 63.0f)];
        [_buttonEnlargeMap setCenter:CGPointMake(MAIN_POR_WIDTH - BUTTON_BOUNDARY, CONTENTHEIGHT_V-212.0f)];
        
        [_buttonNarrowMap setFrame:CGRectMake(0.0f, 0.0f, 60.0f, 63.0f)];
        
        if([[UIScreen mainScreen] scale] == 2)
        {
            [_buttonNarrowMap setCenter:CGPointMake(MAIN_POR_WIDTH - BUTTON_BOUNDARY, CONTENTHEIGHT_V-149.0f)];
        }
        else
        {
            [_buttonNarrowMap setCenter:CGPointMake(MAIN_POR_WIDTH - BUTTON_BOUNDARY, CONTENTHEIGHT_V-150.0f)];
        }
        
        [_labelMeter setFrame:CGRectMake(0.0f, 0.0f, 50.0f, 20.0f)];
        [_labelMeter setCenter:CGPointMake(MAIN_POR_WIDTH - BUTTON_BOUNDARY, CONTENTHEIGHT_V-106.5f)];
        _labelMeter.titleLabel.font = [UIFont systemFontOfSize:13];
    }
    
    [self reloadEnlargeAndNarrowImage];
    [self setTrackLineInfoWithType];
}

//横屏
- (void)changeLandscapeControlFrameWithImage {
    
    float hightSize = (isPad ? 10.0 : 0.0);
    
    [m_mapView setmyFrame:CGRectMake(0.0, 0.0, SCREENHEIGHT, SCREENWIDTH)];
    [[MWPreference sharedInstance] setValue:PREF_DISPLAY_ORIENTATION Value:0];
	
    [_oilCountView setFrame:CGRectMake(0., APPWIDTH - (70. + hightSize + self.navigationController.navigationBar.frame.size.height),self.view.bounds.size.width/4., 80.)];
    [_oilCountView.topImageView setFrame:CGRectMake(_oilCountView.frame.size.width/2.0 - 40., 0., 42., 42.)];
    [_oilCountView.mtitleLabel setFrame:CGRectMake(0.,40., self.view.bounds.size.width/4., 25.)];
    [_oilCountView.symbolLabel setFrame:CGRectMake(_oilCountView.frame.size.width/2.0, 23., 15., 15.)];
    [_oilCountView.countLabel setFrame:CGRectMake(_oilCountView.frame.size.width/2.0 + 15., 5., 50., 50.)];
    
    [_brakeCountView setFrame:CGRectMake(_oilCountView.frame.origin.x + _oilCountView.frame.size.width,_oilCountView.frame.origin.y, _oilCountView.frame.size.width, _oilCountView.frame.size.height)];
    [_brakeCountView.topImageView setFrame:CGRectMake(_oilCountView.topImageView.frame.origin.x, 0., 42., 42.)];
    [_brakeCountView.mtitleLabel setFrame:CGRectMake(_oilCountView.mtitleLabel.frame.origin.x,40., self.view.bounds.size.width/4., 25.)];
    [_brakeCountView.symbolLabel setFrame:CGRectMake(_oilCountView.symbolLabel.frame.origin.x, 23., 15., 15.)];
    [_brakeCountView.countLabel setFrame:CGRectMake(_oilCountView.countLabel.frame.origin.x, 5., 50., 50.)];
    
    [_turnCountView setFrame:CGRectMake(_brakeCountView.frame.origin.x + _brakeCountView.frame.size.width,_oilCountView.frame.origin.y, _oilCountView.frame.size.width, _oilCountView.frame.size.height)];
    [_turnCountView.topImageView setFrame:CGRectMake(_oilCountView.topImageView.frame.origin.x, 0., 42., 42.)];
    [_turnCountView.mtitleLabel setFrame:CGRectMake(_oilCountView.mtitleLabel.frame.origin.x,40., self.view.bounds.size.width/4., 25.)];
    [_turnCountView.symbolLabel setFrame:CGRectMake(_oilCountView.symbolLabel.frame.origin.x, 23., 15., 15.)];
    [_turnCountView.countLabel setFrame:CGRectMake(_oilCountView.countLabel.frame.origin.x, 5., 50., 50.)];
    
    [_speedHightCountView setFrame:CGRectMake(_turnCountView.frame.origin.x + _turnCountView.frame.size.width,_oilCountView.frame.origin.y, _oilCountView.frame.size.width, _oilCountView.frame.size.height)];
    [_speedHightCountView.topImageView setFrame:CGRectMake(_oilCountView.topImageView.frame.origin.x, 0., 42., 42.)];
    [_speedHightCountView.mtitleLabel setFrame:CGRectMake(_oilCountView.mtitleLabel.frame.origin.x,40., self.view.bounds.size.width/4., 25.)];
    [_speedHightCountView.symbolLabel setFrame:CGRectMake(_oilCountView.symbolLabel.frame.origin.x, 23., 15., 15.)];
    [_speedHightCountView.countLabel setFrame:CGRectMake(_oilCountView.countLabel.frame.origin.x, 5., 50., 50.)];
    
    backgroundView.frame = (CGRect){0, APPWIDTH - (70. + hightSize + self.navigationController.navigationBar.frame.size.height), (CGSize){APPHEIGHT ,80.}};
    _lineImageView1.frame = (CGRect){APPHEIGHT/4.0, APPWIDTH - (40. + hightSize + self.navigationController.navigationBar.frame.size.height), (CGSize){2 ,20.}};
    _lineImageView2.frame = (CGRect){APPHEIGHT*2.0/4.0, _lineImageView1.frame.origin.y, (CGSize){2 ,20.}};
    _lineImageView3.frame = (CGRect){APPHEIGHT*3.0/4.0, _lineImageView2.frame.origin.y, (CGSize){2 ,20.}};
    
    CGFloat enlargeAndNarrowWidth = 40.0f;
    CGFloat enlargeAndNarrowHeght = 42.0f;
    CGFloat rightButtonDis = MAIN_LAND_WIDTH - BUTTON_BOUNDARY;
    
    if(isiPhone)
    {
        float heightBottom = backgroundView.frame.size.height + 10;
        
        //放大，缩小
        [_buttonNarrowMap setFrame:CGRectMake(0.0f, 0.0f, enlargeAndNarrowWidth, enlargeAndNarrowHeght)];
        [_buttonNarrowMap setCenter:CGPointMake(rightButtonDis,
                                                //                 低栏的高度     按钮高度的一半
                                                CONTENTHEIGHT_H - heightBottom - _buttonNarrowMap.frame.size.height/2)];
        [_buttonEnlargeMap setFrame:CGRectMake(0.0f, 0.0f, enlargeAndNarrowWidth, enlargeAndNarrowHeght)];
        
        [_buttonEnlargeMap setCenter:CGPointMake(rightButtonDis,
                                                 //                 低栏的高度       按钮高度的一半
                                                 _buttonNarrowMap.frame.origin.y - _buttonEnlargeMap.frame.size.height/2)];
        
        
        [_labelMeter setFrame:CGRectMake(0.0f, 0.0f, 36.0f, 12.0f)];
        [_labelMeter setCenter:CGPointMake(rightButtonDis, _buttonEnlargeMap.frame.origin.y - 1.0f - _labelMeter.frame.size.height / 2)];
        
        
    }
    else//ipad 横屏
    {
        //放大，缩小
        [_buttonEnlargeMap setFrame:CGRectMake(0.0f, 0.0f, 60.0f, 63.0f)];
        [_buttonEnlargeMap setCenter:CGPointMake(MAIN_LAND_WIDTH - BUTTON_BOUNDARY, CONTENTHEIGHT_H-187.5f - 20.0f - 8.0f)];
        
        [_buttonNarrowMap setFrame:CGRectMake(0.0f, 0.0f, 60.0f, 63.0f)];
        [_buttonNarrowMap setCenter:CGPointMake(MAIN_LAND_WIDTH - BUTTON_BOUNDARY, CONTENTHEIGHT_H-132.5f - 20.0f)];
        
        [_labelMeter setFrame:CGRectMake(0.0f, 0.0f, 50.0f, 20.0f)];
        [_labelMeter setCenter:CGPointMake(MAIN_LAND_WIDTH - BUTTON_BOUNDARY, CONTENTHEIGHT_H-93.0f - 20.0f)];
        _labelMeter.titleLabel.font = [UIFont systemFontOfSize:13];
    }
    
    [self reloadEnlargeAndNarrowImage];
    [self setTrackLineInfoWithType];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if ( self.navigationController.visibleViewController != self)
    {
        return;
    }
    
    if(toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
    {
        [self changeLandscapeControlFrameWithImage];
    }
    else if(toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        [self changePortraitControlFrameWithImage];
    }
    
    [[MWMapOperator sharedInstance] MW_ShowMapView:GMAP_VIEW_TYPE_MAIN WithParma1:0 WithParma2:0 WithParma3:0];
    
}

- (void)viewInfoInCondition:(NSInteger)condition {
    
	switch (condition)
	{
		case 0:
		{
			
            [_labelMeter setTitle:[[MWMapOperator sharedInstance] GetCurrentScale] forState:UIControlStateNormal];
            
            if ([_labelMeter.titleLabel.text isEqualToString:@"15m"])
            {
                _buttonEnlargeMap.alpha = ALPHA_HIDEN;
                _buttonNarrowMap.alpha = ALPHA_APEAR;
                
            }
            else if ([_labelMeter.titleLabel.text  isEqualToString:@"500km"])
            {
                _buttonEnlargeMap.alpha = ALPHA_APEAR;
                _buttonNarrowMap.alpha = ALPHA_HIDEN;
            }
            else {
                _buttonEnlargeMap.alpha = ALPHA_APEAR;
                _buttonNarrowMap.alpha = ALPHA_APEAR;
            }
            
        }
			break;
			
		default:
			break;
	}
}

/***
 * @name    根据不同的tag创建button
 * @param   condition:button的tag
 ***/
- (UIButton *)buttonInCondition:(NSInteger)condition
{
    UIButton *button;
	NSString *titleT;
	NSString *normalImage;
	NSString *highlightedImage;
    CGFloat strechParamX = 0;
    CGFloat strechParamy = 0;
    
    switch (condition) {
        case 4://放大
        {
            normalImage = @"mainEnlargeMap.png";
            highlightedImage = @"mainEnlargeMapPress.png";
            
            
            titleT = nil;
        }
            break;
        case 5://缩小
        {
            normalImage = @"mainNarrow.png";
            highlightedImage = @"mainNarrowPress.png";
            
            titleT = nil;
        }
            break;
        case 6:// 比例尺
		{
			titleT = nil;
			normalImage = @"mainScaleIcon.png";
			highlightedImage = nil;
		}
			break;
        default:
        {
            normalImage = nil;
            highlightedImage = nil;
            titleT = nil;
        }
            break;
    }
    
    button = [self createButtonWithTitle:titleT normalImage:normalImage heightedImage:highlightedImage tag:condition strechParamX:strechParamX strechParamY:strechParamy];
	titleT = nil;
	normalImage = nil;
	highlightedImage = nil;
	return button;
}

- (void) reloadEnlargeAndNarrowImage
{
    //竖屏状态或者是iPad都不用横屏的图片
    if(Interface_Flag == 0 || !isiPhone)
    {
        [_buttonEnlargeMap setBackgroundImage:IMAGE(@"mainEnlargeMap.png", IMAGEPATH_TYPE_2) forState:UIControlStateNormal];
        [_buttonEnlargeMap setBackgroundImage:IMAGE(@"mainEnlargeMapPress.png", IMAGEPATH_TYPE_2) forState:UIControlStateHighlighted];
        [_buttonNarrowMap setBackgroundImage:IMAGE(@"mainNarrow.png", IMAGEPATH_TYPE_2) forState:UIControlStateNormal];
        [_buttonNarrowMap setBackgroundImage:IMAGE(@"mainNarrowPress.png", IMAGEPATH_TYPE_2) forState:UIControlStateHighlighted];
    }
    else
    {
        [_buttonEnlargeMap setBackgroundImage:IMAGE(@"mainEnlargeMap.png", IMAGEPATH_TYPE_2) forState:UIControlStateNormal];
        [_buttonEnlargeMap setBackgroundImage:IMAGE(@"mainEnlargeMapPress.png", IMAGEPATH_TYPE_2) forState:UIControlStateHighlighted];
        [_buttonNarrowMap setBackgroundImage:IMAGE(@"mainNarrow.png", IMAGEPATH_TYPE_2) forState:UIControlStateNormal];
        [_buttonNarrowMap setBackgroundImage:IMAGE(@"mainNarrowPress.png", IMAGEPATH_TYPE_2) forState:UIControlStateHighlighted];
    }
}

//更新主界面上——更多，微享的new图标的显示
- (void)handleUIUpdate:(NSNotification *)result
{
    switch ([[result object] intValue]) {
        case UIUpdate_MapDayNightModeChange:
        {
            if([[MWPreference sharedInstance] getValue:PREF_DAYNIGHTMODE] == 1)
            {
                [_labelMeter setTitleColor:GETSKINCOLOR(MAIN_NIGHT_METER_COLOR) forState:UIControlStateNormal];
            }
            else
            {
                [_labelMeter setTitleColor:GETSKINCOLOR(MAIN_DAY_METER_COLOR) forState:UIControlStateNormal];
            }
            [self reloadEnlargeAndNarrowImage];
        }
            break;
        
        default:
            break;
    }
    
    
}
/***
 * @name    地图的比例尺
 * @param
 * @author  by bazinga
 ***/
- (GZOOMLEVEL)setZoomButtonsRespondStatus
{
    GZOOMLEVEL nScale;
    int nMapViewType = 0;
    
    nMapViewType = GMAP_VIEW_TYPE_MAIN;
    
    nScale = [[MWMapOperator sharedInstance] GetMapScaleLevelWithType:nMapViewType];
    
    if (nScale ==ZOOM_15_M)
    {
        _buttonEnlargeMap.alpha = ALPHA_HIDEN;
        _buttonNarrowMap.alpha = ALPHA_APEAR;
    }
    else if (nScale ==ZOOM_500_KM)
    {
        _buttonEnlargeMap.alpha = ALPHA_APEAR;
        _buttonNarrowMap.alpha = ALPHA_HIDEN;
    }
    else
    {
        _buttonEnlargeMap.alpha = ALPHA_APEAR;
        _buttonNarrowMap.alpha = ALPHA_APEAR;
    }
    
    //获取当前比例尺
    
    [_labelMeter setTitle:[[MWMapOperator sharedInstance] GetCurrentScale] forState:UIControlStateNormal];
    
    return nScale;
}

#pragma mark   NSTimer *m_timerInc, *m_timerDec;


- (void)ZoomInLongPressed:(UILongPressGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan)
	{
        _isLongPress = YES;
		_timerInc = [NSTimer scheduledTimerWithTimeInterval:0.2f
                                                     target:self
                                                   selector:@selector(decFun:)
                                                   userInfo:nil
                                                    repeats:YES];
        [_timerInc fire];
	}
	else if (recognizer.state == UIGestureRecognizerStateChanged)
	{
        
	}else 	if (recognizer.state == UIGestureRecognizerStateEnded)
	{
        [self Stop_Idec:_buttonEnlargeMap];
	}
    
}


- (void)ZoomOutLongPressed:(UILongPressGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan)
	{
        _isLongPress = YES;
		_timerDec = [NSTimer scheduledTimerWithTimeInterval:0.2f
                                                     target:self
                                                   selector:@selector(incFun:)
                                                   userInfo:nil
                                                    repeats:YES];
        [_timerDec fire];
	}
	else if (recognizer.state == UIGestureRecognizerStateChanged)
	{
        
	}else 	if (recognizer.state == UIGestureRecognizerStateEnded)
	{
        [self Stop_Idec:_buttonNarrowMap];
	}
}

- (void)incFun:(NSTimer *)timer {
    if (_isLongPress)
    {
        _isLongPress = NO;
        return;
    }

    int nMapViewType = 0;
	
    nMapViewType = GMAP_VIEW_TYPE_MAIN;
    
    GZOOMLEVEL nScale = [self setZoomButtonsRespondStatus];
    
    if (nScale==ZOOM_500_KM)
    {
        if (_timerDec != nil)
        {
            [_timerDec invalidate];
            _timerDec = nil;
        }
        return;
    }
	[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_TOUCH object:[NSNumber numberWithBool:NO]];
    [[MWMapOperator sharedInstance] MW_ZoomMapView:nMapViewType ZoomFlag:GSETMAPVIEW_LEVEL_OUT ZoomLevel:0];
}

- (void)decFun:(NSTimer *)timer {
    
    if (_isLongPress)
    {
        _isLongPress = NO;
        return;
    }
    
    int nMapViewType = 0;
    nMapViewType = GMAP_VIEW_TYPE_MAIN;
       
    GZOOMLEVEL nScale = [self setZoomButtonsRespondStatus];
    if (nScale == ZOOM_15_M)
    {
        
        if (_timerInc != nil)
        {
            [_timerInc invalidate];
            _timerInc = nil;
        }
        return;
    }
	[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_TOUCH object:[NSNumber numberWithBool:NO]];
    [[MWMapOperator sharedInstance] MW_ZoomMapView:nMapViewType ZoomFlag:GSETMAPVIEW_LEVEL_IN ZoomLevel:0];
}

- (void)Stop_Idec:(id)sender {
	
	NSLog(@"Stop_Idec");
	UIButton *button = (UIButton *)sender;
	if (button.tag==4)
	{
		if (_timerInc != nil) {
            [_timerInc invalidate];
            _timerInc = nil;
        }
	}
	else if (button.tag==5)
	{
        if (_timerDec != nil) {
            [_timerDec invalidate];
            _timerDec = nil;
        }
	}
}

//按钮点击事件
- (void)buttonAction:(id)sender {
    
	switch (((UIButton *)sender).tag) {
        case 0:
        {
            
            if (self.trackInfo) {
                
                [self.iconArray removeAllObjects];
                
                NSMutableDictionary *iconDic = [[NSMutableDictionary alloc] init];
                
                for (DCoordinate *coord in self.trackInfo.haccelerationArray) {
                    
                    MWPoi *poi = [[MWPoi alloc] init];
                    poi.longitude = coord.lon;
                    poi.latitude = coord.lat;
                    
                    MWMapPoi *addIcon = [[MWMapPoi alloc] init];
                    [POICommon copyWMPoiValutToSubclass:poi withPoiSubclass:addIcon];
                    
                    
                    [self.iconArray addObject:addIcon];
                    
                    
                    
                    [poi release];
                    [addIcon release];
                    
                }
                
                if (self.iconArray.count > 0) {
                    [iconDic setValue:self.iconArray forKey:@"drivingTrackOilIcon.png"];
                }
                
                
                if ([MWMapAddIconOperator ExistIconInMap:mapAddIcon]) {
                    [MWMapAddIconOperator ClearMapIcon];
                }
                CRELEASE(mapAddIcon);
                if(!mapAddIcon)
                {
                    mapAddIcon = [[MWMapAddIconOperator alloc] initWith:iconDic inView:m_mapView delegate:self];
                }
                
                [mapAddIcon SetIconPosition:Position_Bottom];
                [mapAddIcon freshPoiDic:iconDic];
                
                
                [iconDic release];
                
                self.viewType = DRIVINGTRACKVIEWTYPE_ACCELERATE;
            }
            
            
        }
            break;
        case 1:
        {
            if (self.trackInfo) {
                
                [self.iconArray removeAllObjects];
                
                NSMutableDictionary *iconDic = [[NSMutableDictionary alloc] init];
                
                for (DCoordinate *coord in self.trackInfo.brakesArray) {
                    MWPoi *poi = [[MWPoi alloc] init];
                    poi.longitude = coord.lon;
                    poi.latitude = coord.lat;
                    
                    MWMapPoi *addIcon = [[MWMapPoi alloc] init];
                    [POICommon copyWMPoiValutToSubclass:poi withPoiSubclass:addIcon];
                    
                    [self.iconArray addObject:addIcon];
                    
                    
                    
                    [poi release];
                    [addIcon release];
                    
                }
                
                if (self.iconArray.count > 0) {
                    [iconDic setValue:self.iconArray forKey:@"drivingTrackBrakesIcon.png"];
                }
                
                
                if ([MWMapAddIconOperator ExistIconInMap:mapAddIcon]) {
                    [MWMapAddIconOperator ClearMapIcon];
                }
                CRELEASE(mapAddIcon);
                if(!mapAddIcon)
                {
                    mapAddIcon = [[MWMapAddIconOperator alloc] initWith:iconDic inView:m_mapView delegate:self];
                }
                
                [mapAddIcon SetIconPosition:Position_Bottom];
                [mapAddIcon freshPoiDic:iconDic];
                
                [iconDic release];
                
                self.viewType = DRIVINGTRACKVIEWTYPE_BRAKES;
            }
        }
            break;
        case 2:
        {
            if (self.trackInfo) {
                
                [self.iconArray removeAllObjects];
                
                NSMutableDictionary *iconDic = [[NSMutableDictionary alloc] init];
                
                for (DCoordinate *coord in self.trackInfo.uturnArray) {
                    MWPoi *poi = [[MWPoi alloc] init];
                    poi.longitude = coord.lon;
                    poi.latitude = coord.lat;
                    
                    MWMapPoi *addIcon = [[MWMapPoi alloc] init];
                    [POICommon copyWMPoiValutToSubclass:poi withPoiSubclass:addIcon];
                    
                    [self.iconArray addObject:addIcon];
                    
                    
                    
                    [poi release];
                    [addIcon release];
                    
                }
                
                if (self.iconArray.count > 0) {
                    [iconDic setValue:self.iconArray forKey:@"drivingTrackUturnIcon.png"];
                }
                
                
                if ([MWMapAddIconOperator ExistIconInMap:mapAddIcon]) {
                    [MWMapAddIconOperator ClearMapIcon];
                }
                CRELEASE(mapAddIcon);
                if(!mapAddIcon)
                {
                    mapAddIcon = [[MWMapAddIconOperator alloc] initWith:iconDic inView:m_mapView delegate:self];
                }
                
                [mapAddIcon SetIconPosition:Position_Bottom];
                [mapAddIcon freshPoiDic:iconDic];
                
                [iconDic release];
                
                self.viewType = DRIVINGTRACKVIEWTYPE_TURN;
            }
        }
            break;
        case 3:
        {
            if (self.trackInfo) {
                
                [self.iconArray removeAllObjects];
                
                NSMutableDictionary *iconDic = [[NSMutableDictionary alloc] init];
                
                for (DCoordinate *coord in self.trackInfo.hypervelocityArray) {
                    MWPoi *poi = [[MWPoi alloc] init];
                    poi.longitude = coord.lon;
                    poi.latitude = coord.lat;
                    
                    MWMapPoi *addIcon = [[MWMapPoi alloc] init];
                    [POICommon copyWMPoiValutToSubclass:poi withPoiSubclass:addIcon];
                    
                    [self.iconArray addObject:addIcon];
                    
                    [poi release];
                    [addIcon release];
                    
                }
                
                if (self.iconArray.count > 0) {
                    [iconDic setValue:self.iconArray forKey:@"drivingTrackSpeedingIcon.png"];
                }
                
                if ([MWMapAddIconOperator ExistIconInMap:mapAddIcon]) {
                    [MWMapAddIconOperator ClearMapIcon];
                }
                CRELEASE(mapAddIcon);
                if(!mapAddIcon)
                {
                    mapAddIcon = [[MWMapAddIconOperator alloc] initWith:iconDic inView:m_mapView delegate:self];
                }
                
                [mapAddIcon SetIconPosition:Position_Bottom];
                [mapAddIcon freshPoiDic:iconDic];
                
                [iconDic release];
                
                self.viewType = DRIVINGTRACKVIEWTYPE_HYSPEED;
            }
            
        }
            break;
        default:
        {
        }
            break;
    }
    
    [self setTrackLineInfoWithType];
    [[MWMapOperator sharedInstance] MW_ShowMapView:GMAP_VIEW_TYPE_MAIN WithParma1:0 WithParma2:0 WithParma3:0];
}

- (void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)drawAllIcon
{
    if (self.trackInfo) {
        
        NSMutableDictionary *iconDic = [[NSMutableDictionary alloc] init];
        
        NSMutableArray *haArray = [[NSMutableArray alloc] init];
        
        for (DCoordinate *coord in self.trackInfo.haccelerationArray) {
            
            MWPoi *poi = [[MWPoi alloc] init];
            poi.longitude = coord.lon;
            poi.latitude = coord.lat;
            
            MWMapPoi *addIcon = [[MWMapPoi alloc] init];
            [POICommon copyWMPoiValutToSubclass:poi withPoiSubclass:addIcon];
            
            
            [haArray addObject:addIcon];
            
            
            
            [poi release];
            [addIcon release];
            
        }
        
        if (haArray.count > 0) {
            [iconDic setValue:haArray forKey:@"drivingTrackOilIcon.png"];
        }
        
        [haArray release];
        
        NSMutableArray *brArray = [[NSMutableArray alloc] init];
        
        for (DCoordinate *coord in self.trackInfo.brakesArray) {
            MWPoi *poi = [[MWPoi alloc] init];
            poi.longitude = coord.lon;
            poi.latitude = coord.lat;
            
            MWMapPoi *addIcon = [[MWMapPoi alloc] init];
            [POICommon copyWMPoiValutToSubclass:poi withPoiSubclass:addIcon];
            
            [brArray addObject:addIcon];
            
            [poi release];
            [addIcon release];
            
        }
        
        if (brArray.count > 0) {
            [iconDic setValue:brArray forKey:@"drivingTrackBrakesIcon.png"];
        }
        
        [brArray release];
        
        NSMutableArray *tuArray = [[NSMutableArray alloc] init];
        
        for (DCoordinate *coord in self.trackInfo.uturnArray) {
            MWPoi *poi = [[MWPoi alloc] init];
            poi.longitude = coord.lon;
            poi.latitude = coord.lat;
            
            MWMapPoi *addIcon = [[MWMapPoi alloc] init];
            [POICommon copyWMPoiValutToSubclass:poi withPoiSubclass:addIcon];
            
            [tuArray addObject:addIcon];
            
            [poi release];
            [addIcon release];
            
        }
        
        if (tuArray.count > 0) {
            [iconDic setValue:tuArray forKey:@"drivingTrackUturnIcon.png"];
        }
        
        [tuArray release];
        
        NSMutableArray *hyArray = [[NSMutableArray alloc] init];
        for (DCoordinate *coord in self.trackInfo.hypervelocityArray) {
            
            MWPoi *poi = [[MWPoi alloc] init];
            poi.longitude = coord.lon;
            poi.latitude = coord.lat;
            
            MWMapPoi *addIcon = [[MWMapPoi alloc] init];
            [POICommon copyWMPoiValutToSubclass:poi withPoiSubclass:addIcon];
            
            [hyArray addObject:addIcon];
            
            [poi release];
            [addIcon release];
            
        }
        
        if (hyArray.count > 0) {
            [iconDic setValue:hyArray forKey:@"drivingTrackSpeedingIcon.png"];
        }
        
        [hyArray release];
        
        if ([MWMapAddIconOperator ExistIconInMap:mapAddIcon]) {
            [MWMapAddIconOperator ClearMapIcon];
        }
        CRELEASE(mapAddIcon);
        if(!mapAddIcon)
        {
            mapAddIcon = [[MWMapAddIconOperator alloc] initWith:iconDic inView:m_mapView delegate:self];
        }
        
        [mapAddIcon SetIconPosition:Position_Bottom];
        [mapAddIcon freshPoiDic:iconDic];
        
        [iconDic release];
        
        
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

//
//  HudViewController.m
//  AutoNavi
//
//  Created by gaozhimin on 13-4-28.
//
//

#import "HudViewController.h"
#import "ANParamValue.h"
#import "ANDataSource.h"
#import "ANOperateMethod.h"
#import "MoveTextLable.h"
#import "KLSwitch.h"
#import "MainDefine.h"

#define HUD_BACK_BUTTON  0
#define HUD_SWITCH       1
#define LABEL_HIGHT      (isiPhone ? 50: 108)
#define HUD_BUTTON_BACK_WIDTH      (isiPhone ? 65: 130)
#define SWITCH_WIDTH      (isiPhone ? 50: 80)
#define SWITCH_HIGHT      (isiPhone ? 33: 50)

@interface HudViewController ()
{
    MoveTextLable *m_nextLoadName; //下一道路名
    UILabel *m_remainLoadLength;//下个路口距离
    UILabel *m_remainRouteLength;//全程剩余距离
    UILabel *m_directionLable;
    UIImageView *m_turnImageView;//转向图标
    
    NSArray *m_content;
    
    UIImageView *m_endView;
    UIImageView *m_upLineView;
    UIImageView *m_downLineView;
    UIImageView *m_directionView;
    
    UIView *_viewContent;   //除了底栏，控件，之上的显示控件都放在这个view上
    UIView *_viewBlack;     //黑色背景视图
    
    UILabel *_labelBottom;    //底栏视图
    UIButton *_buttonBack;  //返回按钮
    KLSwitch *_switchReflection;  //是否打开反射到挡风玻璃上
    
    NSTimer *_timer;
    
    int _timeCount;
}

@end

@implementation HudViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}



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

    [[ANOperateMethod sharedInstance] GMD_ChangeTomirrorViewInView:nil isSwitch:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
	UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(TapRecongnizer:)];
    [tapGes setNumberOfTouchesRequired:1];//触摸点个数
    [tapGes setNumberOfTapsRequired:1];//点击次数
    tapGes.delegate = self;
    [self.view addGestureRecognizer:tapGes];
    [tapGes release];
    
    [self initControl];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationReceived:) name:NOTIFY_PASSINFOTOHUD object:nil];
    _timeCount = 0;
    _timer =  [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(fireTimer:) userInfo:nil repeats:YES];
}
// Called when the view is about to made visible. Default does nothing
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
	[self setViewFrame:Interface_Flag];
    
}
// Called when the view has been fully transitioned onto the screen. Default does nothing

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}
// Called when the view is dismissed, covered or otherwise hidden. Default does nothing

-(void)viewWillDisappear:(BOOL)animated
{
    if([_timer isValid])
    {
        [_timer invalidate];
        _timer = nil;
    }
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
    
    //底栏显示控件
    _labelBottom = [[UILabel alloc]initWithFrame:CGRectMake(0,
                                                            self.view.frame.size.height - LABEL_HIGHT,
                                                            self.view.frame.size.width,
                                                            LABEL_HIGHT)];
    _labelBottom.textAlignment = NSTextAlignmentCenter;
    _labelBottom.text = STR(@"Main_HUDReflection", Localize_Main);
    _labelBottom.font = [UIFont systemFontOfSize:kSize2];
    _labelBottom.userInteractionEnabled = YES;
    [_labelBottom setBackgroundColor:GETSKINCOLOR(HUD_BOTTOM_LABEL_BACK_COLOR)];
    
    _buttonBack = [self createButtonWithTitle:nil
                                  normalImage:nil
                                heightedImage:nil
                                          tag:HUD_BACK_BUTTON];
    [_buttonBack setFrame:CGRectMake(0, 0, 65, 50)];
    [_buttonBack setImage:IMAGE(@"hud_Bck.png", IMAGEPATH_TYPE_1) forState:UIControlStateNormal];
//    [_buttonBack setImage:IMAGE(@"BackBtn2.png", IMAGEPATH_TYPE_1) forState:UIControlStateHighlighted];
    __block HudViewController *blockSelf = self;
    _switchReflection = [[KLSwitch alloc]initWithFrame:CGRectMake(0, 0, SWITCH_WIDTH, SWITCH_HIGHT)
                                      didChangeHandler:^(BOOL isOn)
                         {
                             [blockSelf switchChange];
                         }];
    _switchReflection.tag = HUD_SWITCH;
    [_switchReflection setOnTintColor:SWITCHCOLOR];
    //    [self createSwitchWithFrame:CGRectMake(0, 0, 80, 30)
    //                                                tag:HUD_SWITCH];
    [_switchReflection addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_switchReflection setOn:[[MWPreference sharedInstance] getValue:PREF_HUD_DISPLAYORIENTATION]];
    
    
    _viewContent = [[UIView alloc]initWithFrame:CGRectMake(0,
                                                           0,
                                                           self.view.frame.size.width,
                                                           self.view.frame.size.height - LABEL_HIGHT)];
    _viewBlack = [[UIView alloc]initWithFrame:CGRectMake(0,
                                                         0,
                                                         self.view.frame.size.width,
                                                         self.view.frame.size.height)];
    
    _viewBlack.backgroundColor = GETSKINCOLOR(HUD_BLACK_BACKGROUND_COLOR);
    _viewContent.backgroundColor = GETSKINCOLOR(HUD_CLEAR_BACKGROUND_COLOR);
    self.view.backgroundColor = GETSKINCOLOR(HUD_BLACK_BACKGROUND_COLOR);
    
    [self.view addSubview:_viewBlack];
    [self.view addSubview:_viewContent];
    [self.view addSubview:_labelBottom];
    [self.view bringSubviewToFront:_labelBottom];
    [self.view addSubview:_buttonBack];
    [self.view addSubview:_switchReflection];
    
    [_switchReflection release];
    [_viewContent release];
    [_labelBottom release];
    
    m_nextLoadName = [[MoveTextLable alloc] initWithFrame:CGRectMake(0, 0, 320, 200) delegate:self selector:@selector(ChangeTextPosition)];
    m_nextLoadName.backgroundColor = GETSKINCOLOR(HUD_LABEL_CLEAR_BACK_COLOR);
    m_nextLoadName.textColor =GETSKINCOLOR(HUD_LABEL_TEXT_COLOR);
    m_nextLoadName.font = [UIFont boldSystemFontOfSize:40];
    m_nextLoadName.textAlignment = NSTextAlignmentCenter;
    [_viewContent addSubview:m_nextLoadName];
    [m_nextLoadName release];
    m_nextLoadName.center = CGPointMake(160, 400);
    
    m_remainLoadLength = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 200)];
    m_remainLoadLength.backgroundColor = GETSKINCOLOR(HUD_LABEL_CLEAR_BACK_COLOR);
    m_remainLoadLength.textColor = GETSKINCOLOR(HUD_LABEL_TEXT_COLOR);
    m_remainLoadLength.font = [UIFont boldSystemFontOfSize:40];
    m_remainLoadLength.textAlignment = NSTextAlignmentCenter;
    [_viewContent addSubview:m_remainLoadLength];
    [m_remainLoadLength release];
    m_remainLoadLength.center = CGPointMake(160, 100);
    
    m_remainRouteLength = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 100)];
    m_remainRouteLength.backgroundColor = GETSKINCOLOR(HUD_LABEL_CLEAR_BACK_COLOR);
    m_remainRouteLength.textColor = GETSKINCOLOR(HUD_LABEL_TEXT_COLOR);
    m_remainRouteLength.font = [UIFont boldSystemFontOfSize:30];
    m_remainRouteLength.textAlignment = NSTextAlignmentCenter;
    [_viewContent addSubview:m_remainRouteLength];
    [m_remainRouteLength release];
    m_remainRouteLength.center = CGPointMake(260, 50);
    
    m_turnImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 185, 185)];
    [_viewContent addSubview:m_turnImageView];
    [m_turnImageView release];
    m_turnImageView.center = CGPointMake(160, 240);
    
    m_upLineView = [[UIImageView alloc] init];
    m_upLineView.backgroundColor = GETSKINCOLOR(HUD_DIVING_LINE_COLOR);
    [_viewContent addSubview:m_upLineView];
    [m_upLineView release];
    
    m_downLineView = [[UIImageView alloc] init];
    m_downLineView.backgroundColor = GETSKINCOLOR(HUD_DIVING_LINE_COLOR);
    [_viewContent addSubview:m_downLineView];
    [m_downLineView release];
    
    NSString *endString = [NSString stringWithFormat:@"%@%d%@",@"HUD_end",fontType,@".png"];
    m_endView = [[UIImageView alloc] initWithImage:IMAGE(endString, IMAGEPATH_TYPE_1)];
    m_endView.backgroundColor = GETSKINCOLOR(HUD_LABEL_CLEAR_BACK_COLOR);
    [_viewContent addSubview:m_endView];
    [m_endView release];
    
    m_directionView = [[UIImageView alloc] initWithImage:IMAGE(@"Hud_Direction.png", IMAGEPATH_TYPE_1) ];
    m_directionView.backgroundColor = GETSKINCOLOR(HUD_LABEL_CLEAR_BACK_COLOR);
    [_viewContent addSubview:m_directionView];
    [m_directionView release];
    
    m_directionLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 70, 40)];
    m_directionLable.textColor = GETSKINCOLOR(HUD_LABEL_TEXT_COLOR);;
    m_directionLable.backgroundColor = GETSKINCOLOR(HUD_LABEL_CLEAR_BACK_COLOR);;
    m_directionLable.textAlignment = NSTextAlignmentCenter;
    m_directionLable.font = [UIFont boldSystemFontOfSize:30];
    m_directionLable.text = @"北";
    [_viewContent addSubview:m_directionLable];
    [m_directionLable release];
}


- (UIImage *)GetImageWithID
{
    GMANEUVERINFO *info = NULL;
    GSTATUS res = [MWRouteGuide GetManeuverInfo:&info];
    if (res != GD_ERR_OK)
    {
        return nil;
    }
    Guint32 ID = info->nTurnID;
    //    (nturnid >> 31) & 0x01
    //判断左舵
    BOOL isLeft = NO;
    if(((info->nTurnID >> 31) & 0x01) == 1)
    {
        isLeft = YES;
        ID = ID & 0x7fffffff;
    }
    if(ID == 3)
    {
        ID = 2;
    }
    else if(ID == 6)
    {
        ID = 5;
    }
    else if(ID == 17 ||ID == 20 ||ID == 116 || ID == 187 ||ID == 282 ||ID == 294 )
    {
        ID = 10;
    }
    else if(ID == 16)
    {
        ID = 15;
    }
    else if(ID == 35 || ID == 78 || ID == 99 || ID == 114|| ID == 119|| ID == 127|| ID == 129|| ID == 148|| ID == 151|| ID == 152|| ID == 166|| ID == 168|| ID == 185|| ID == 207|| ID == 279|| ID == 291|| ID == 300)
    {
        ID = 18;
    }
    else if(ID == 36|| ID == 79|| ID == 100 || ID == 115 || ID == 120 || ID == 128 || ID == 130 || ID == 149 || ID == 150 || ID == 167 || ID == 169 || ID == 186 || ID == 208 || ID == 281 || ID == 293 || ID == 305)
    {
        ID = 19;
    }else if(ID == 117 || ID == 188 || ID == 283 || ID == 295)
    {
        ID = 21;
    }
    else if(ID == 39 || ID == 40 || ID == 61 || ID == 62 || ID == 124 || ID == 134 || ID == 172 || ID == 195 || ID == 211 || ID == 212 || ID == 284 || ID == 60 || ID == 80 || ID == 296)
    {
        ID = 22;
    }
    else if(ID == 43 || ID == 44 || ID == 66 || ID == 67 || ID == 68 || ID == 81 || ID == 215 || ID == 216 || ID == 285 || ID == 297)
    {
        ID = 23;
    }
    else if(ID == 47 || ID == 48 || ID == 72 || ID == 73 || ID == 74 || ID == 82 || ID == 126 || ID == 136 || ID == 175 || ID == 197 || ID == 219 || ID == 220 || ID == 286 || ID == 298)
    {
        ID = 24;
    }
    else if(ID == 45 || ID == 46 || ID == 75 || ID == 76 || ID == 77 || ID == 83 || ID == 125 || ID == 135 || ID == 174 || ID == 196 || ID == 217 || ID == 218 || ID == 287 || ID == 299)
    {
        ID = 25;
    }
    else if(ID == 41 || ID == 42 || ID == 69 || ID == 70 || ID == 71 || ID == 84 || ID == 213 || ID == 214 || ID == 288 || ID == 300)
    {
        ID = 26;
    }
    else if(ID == 37 || ID == 38 || ID == 63 || ID == 64 || ID == 65 || ID == 85 || ID == 123 || ID == 133 || ID == 172 || ID == 194 || ID == 209 || ID == 210 || ID == 289 || ID == 301)
    {
        ID = 27;
    }
    else if(ID == 118 || ID == 189 || ID == 290 || ID == 302)
    {
        ID = 28;
    }
    else if(ID == 153 || ID == 190 || ID == 221 || ID == 311 || ID == 86 || ID == 101 || ID == 137)
    {
        ID = 29;
    }
    else if(ID == 87 || ID == 102 || ID == 138 || ID == 191 || ID == 222 || ID == 132 || ID == 154 || ID == 312)
    {
        ID = 30;
    }
    else if(ID == 88 || ID == 103 || ID == 139 || ID == 157 || ID == 176 || ID == 198 || ID == 223)
    {
        ID = 49;
    }
    else if(ID == 89 || ID == 104 || ID == 140 || ID == 158 || ID == 177 || ID == 199 || ID == 224 || ID == 232)
    {
        ID = 50;
    }
    else if(ID == 90 || ID == 105 || ID == 141 || ID == 178 || ID == 200 || ID == 225 || ID == 159)
    {
        ID = 51;
    }
    else if(ID == 91 || ID == 106 || ID == 142 || ID == 160 || ID == 179 || ID == 201 || ID == 226)
    {
        ID = 52;
    }
    else if(ID == 92 || ID == 107 || ID == 143 || ID == 161 || ID == 180 || ID == 202 || ID == 227 || ID == 223)
    {
        ID = 53;
    }
    else if(ID == 93 || ID == 108 || ID == 144 || ID == 162 || ID == 181 || ID == 203 || ID == 228)
    {
        ID = 54;
    }
    else if(ID == 94 || ID == 109 || ID == 145 || ID == 163 || ID == 182 || ID == 204 || ID == 229)
    {
        ID = 55;
    }
    else if(ID == 95 || ID == 110 || ID == 146 || ID == 164 || ID == 183 || ID == 205 || ID == 230 || ID == 234 || ID == 280 || ID == 292 || ID == 304)
    {
        ID = 56;
    }
    else if(ID == 96 || ID == 111 || ID == 147 || ID == 165 || ID == 174 || ID == 206 || ID == 231)
    {
        ID = 57;
    }
    else if(ID == 97 || ID == 112 || ID == 121 || ID == 131 || ID == 155 || ID == 170 || ID == 192)
    {
        ID = 58;
    }
    else if(ID == 98 || ID == 113 || ID == 122 || ID == 132 || ID == 156 || ID == 171)
    {
        ID = 59;
    }
    else if(ID == 236 || ID == 237 || ID == 238)
    {
        ID = 235;
    }
    else if(ID == 240 || ID == 241 || ID == 242)
    {
        ID = 239;
    }
    else if(ID == 244 || ID == 245 || ID == 246)
    {
        ID = 243;
    }
    else if(ID == 248 || ID == 249 || ID == 250)
    {
        ID = 247;
    }
    else if(ID == 252 || ID == 253 || ID == 254)
    {
        ID = 251;
    }
    else if(ID == 256 || ID == 257 || ID == 258 )
    {
        ID = 255;
    }
    else if(ID == 260 || ID == 261 || ID == 262)
    {
        ID = 259;
    }
    else if(ID == 264 || ID == 265 || ID == 266)
    {
        ID = 263;
    }
    else if(ID == 268 || ID == 269 || ID == 270)
    {
        ID = 267;
    }
    else if(ID == 272 || ID == 273 || ID == 274)
    {
        ID = 271;
    }
    else if(ID == 276 || ID == 277 || ID == 278)
    {
        ID = 275;
    }
    UIImage *image = nil;
    if (isLeft)
    {
        image = IMAGE(([NSString stringWithFormat:@"%@TURN_%d.png",@"L",ID]), IMAGEPATH_TYPE_1);
        if(image == nil)
        {
            image = IMAGE(([NSString stringWithFormat:@"TURN_%d.png",ID]), IMAGEPATH_TYPE_1);
        }
    }
    else
    {
        image = IMAGE(([NSString stringWithFormat:@"TURN_%d.png",ID]), IMAGEPATH_TYPE_1);
    }
    return image;
}

- (void)ChangeViewInfo
{
    //获取离下个路口的距离
    m_remainLoadLength.text = [MWRouteGuide GetManeuverInfoWithMainID:1];
    
    //获取离终点的距离
    m_remainRouteLength.text = [MWRouteGuide GetManeuverInfoWithMainID:2];
    
    //获取离终点的距离
    m_nextLoadName.text = [MWRouteGuide GetManeuverInfoWithMainID:10];
    
    //转向图标
    m_turnImageView.image = [self GetImageWithID];
    
    GCARINFO pCarInfo;
    GDBL_GetCarInfo(&pCarInfo);
    
    int direction = 450 - pCarInfo.nAzimuth;
    if (direction >= 15 && direction <= 75)
    {
        m_directionLable.text = STR(@"Route_EastNorth", Localize_RouteOverview);
    }
    else if (direction > 75 && direction < 105)
    {
        m_directionLable.text = STR(@"Route_East", Localize_RouteOverview);
    }
    else if (direction >= 105 && direction <= 165)
    {
        m_directionLable.text = STR(@"Route_EastSouth", Localize_RouteOverview);
    }
    else if (direction > 165 && direction < 195)
    {
        m_directionLable.text = STR(@"Route_South", Localize_RouteOverview);
    }
    else if (direction >= 195 && direction <= 255)
    {
        m_directionLable.text = STR(@"Route_WestSouth", Localize_RouteOverview);
    }
    else if (direction > 255 && direction < 285)
    {
        m_directionLable.text = STR(@"Route_West", Localize_RouteOverview);
    }
    else if (direction >= 285 && direction <= 345)
    {
        m_directionLable.text = STR(@"Route_WestNorth", Localize_RouteOverview);
    }
    else
    {
        m_directionLable.text = STR(@"Route_North", Localize_RouteOverview);
    }
    
    
    [[ANOperateMethod sharedInstance] GMD_ChangeTomirrorViewInView:_viewContent isSwitch:_switchReflection.on];
    
}



//调整控件竖屏坐标和图片
-(void)changePortraitControlFrameWithImage
{
    [self setViewFrame:0];
}

//调整控件横屏坐标和图片
-(void)changeLandscapeControlFrameWithImage
{
    [self setViewFrame:1];
}

-(void) setViewFrame:(int)flag
{
    
    _buttonBack.frame = CGRectMake(0, 0, HUD_BUTTON_BACK_WIDTH, LABEL_HIGHT);
    if (flag == 0)
    {
        CGSize size = {MAIN_POR_WIDTH,MAIN_POR_HEIGHT};
        _viewContent.frame = CGRectMake(0, 0, size.width,  size.height - LABEL_HIGHT);
        _labelBottom.frame = CGRectMake(0,
                                        size.height - LABEL_HIGHT,
                                        size.width,
                                        LABEL_HIGHT);
       
        _viewBlack.frame = CGRectMake(0, 0, size.width,  size.height);
        _labelBottom.textColor = GETSKINCOLOR(HUD_BOTTOM_LABEL_COLOR);
        if(isiPhone)
        {
            m_upLineView.frame = CGRectMake(0, size.height - 170.0f,  size.width, 1);
            
            m_remainRouteLength.center = CGPointMake(size.width - 65, size.height - 80);
            
            m_endView.center = CGPointMake(size.width / 2, size.height - 80);
            m_directionLable.center = CGPointMake(85, size.height - 80);
            m_directionView.center = CGPointMake(40, size.height - 80);
            
            m_nextLoadName.frame = CGRectMake(0, 0, size.width, 160.0f);
            m_nextLoadName.center = CGPointMake(size.width / 2, 40.0f + iPhoneOffset / 2);
            m_downLineView.frame = CGRectMake(0,iPhoneOffset / 2 +  90.0f , size.width, 1);
            
            m_remainLoadLength.center = CGPointMake(size.width / 2, size.height - 140);
            
            CGFloat turnHight = m_upLineView.frame.origin.y - m_downLineView.frame.origin.y;
            CGFloat leftWidth = 60.0f;
            CGFloat upWidth = 35.0f;
            CGFloat width = turnHight - 2 *upWidth > size.width - 2 * leftWidth ?  size.width - 2 * leftWidth : turnHight - 2 *upWidth;
            m_turnImageView.frame = CGRectMake(0, 0, width , width);
            m_turnImageView.center = CGPointMake(size.width / 2, m_downLineView.frame.origin.y + turnHight / 2);
        }
        else//ipad竖屏
        {
            _labelBottom.font = [UIFont systemFontOfSize:34.0f];
            
            
            m_turnImageView.frame = CGRectMake(0, 0, 400.0f, 400.0f);
            m_turnImageView.center = CGPointMake(384, size.height - 622.0f);
            
            m_remainRouteLength.frame = CGRectMake(0, 0, 277.5f, 183.0f);
            m_remainRouteLength.center = CGPointMake(size.width - 143.5, size.height - 200.0f);
            m_remainRouteLength.font = [UIFont systemFontOfSize:50.0f];
            
            m_endView.center = CGPointMake(443.0f, size.height - 200.0f);
            
            m_directionLable.frame = CGRectMake(0, 0, 110.0f, 110.0f);
            m_directionLable.center = CGPointMake(237.5, size.height - 200.0f);
            m_directionLable.font = [UIFont systemFontOfSize:50.0f];
            
            m_directionView.center = CGPointMake(144.5f, size.height - 200.0f);
            
            m_nextLoadName.frame = CGRectMake(0, 0, size.width, 155.0f);
            m_nextLoadName.center = CGPointMake(size.width / 2, 80.0f);
            
            m_remainLoadLength.frame = CGRectMake(0, 0, size.width, 220.0f);
            m_remainLoadLength.center = CGPointMake(size.width / 2, size.height - 373.0f);
            m_remainLoadLength.font = [UIFont systemFontOfSize:100.0f];
            
            m_downLineView.frame = CGRectMake(0,  159.0f, size.width, 1);
            m_upLineView.frame = CGRectMake(0, size.height - 292.0f,  size.width, 1);
            
        }
    }
    else
    {
        CGSize size = {MAIN_LAND_WIDTH,MAIN_LAND_HEIGHT};
        _viewContent.frame = CGRectMake(0, 0, size.width, size.height - LABEL_HIGHT);
        _labelBottom.frame = CGRectMake(0,
                                        size.height - LABEL_HIGHT,
                                        size.width,
                                        LABEL_HIGHT);
        _viewBlack.frame = CGRectMake(0, 0, size.width, size.height);
        
        m_downLineView.frame = CGRectMake(0, 0, 0, 0);
        m_upLineView.frame = CGRectMake(size.width - 231 - iPhoneOffset, size.height -220, 231 + iPhoneOffset, 1);
        m_nextLoadName.frame = CGRectMake(0, 0, 230 + iPhoneOffset, 200);
        m_turnImageView.frame = CGRectMake(0, 0, 185.0f, 185.0f);
        
        CGFloat moreHeight = MAIN_LAND_HEIGHT - 320.0f - 40.0f > 0 ? MAIN_LAND_HEIGHT - 320.0f :0;  //横屏高度问题
        CGFloat activeHeight = size.height  - moreHeight / 2;
        m_upLineView.center = CGPointMake(size.width - (231 + iPhoneOffset)/2, activeHeight - 219);
        m_nextLoadName.center = CGPointMake(size.width - 115.5 - iPhoneOffset / 2, activeHeight -250);
        m_remainRouteLength.center = CGPointMake(size.width - 110, activeHeight -80);
        m_endView.center = CGPointMake(size.width - 210, activeHeight -80);
        
        m_directionLable.center = CGPointMake(size.width - 110, activeHeight - 180);
        m_directionView.center = CGPointMake(size.width - 210, activeHeight - 180);
        m_remainLoadLength.center = CGPointMake(size.width / 4, activeHeight -80);
        m_turnImageView.center = CGPointMake(size.width / 4, activeHeight -190);
       
        
        if(isiPhone)
        {
            
        }
        else//ipad横屏
        {
            
            m_downLineView.frame = CGRectMake(0, 0, 0, 0);
            m_upLineView.frame = CGRectMake(size.width / 2, 148.0f,  size.width / 2, 1);
            
            _labelBottom.font = [UIFont systemFontOfSize:34.0f];
            
            m_turnImageView.frame = CGRectMake(0, 0, 400.0f, 400.0f);
            m_turnImageView.center = CGPointMake(258.5, 250.0f);
            
            m_remainRouteLength.frame = CGRectMake(0, 0, 297.5f, 183.0f);
            m_remainRouteLength.center = CGPointMake(size.width - 200.0f, 463.0f);
            m_remainRouteLength.font = [UIFont systemFontOfSize:50.0f];
            
            m_endView.center = CGPointMake(size.width - 389.0f, 461.0f);
            
            m_directionLable.frame = CGRectMake(0, 0, 110.0f, 110.0f);
            m_directionLable.center = CGPointMake(size.width - 272.0f, 305.5);
            m_directionLable.font = [UIFont systemFontOfSize:50.0f];
            
            m_directionView.center = CGPointMake(size.width - 389.0f,305.5f);
            
            m_nextLoadName.frame = CGRectMake(0, 0, size.width / 2 , 155.0f);
            m_nextLoadName.center = CGPointMake(size.width - 272, 79.5f);
            
            m_remainLoadLength.frame = CGRectMake(0, 0, size.width / 2 , 220.0f);
            m_remainLoadLength.center = CGPointMake(201.5f, size.height - 259.5);
            m_remainLoadLength.font = [UIFont systemFontOfSize:100.0f];
            
        }
        
    }
    [self ChangeViewInfo];
    
    [self setHiddenTipsLabel:NO];
}

//改变控件文本
-(void)changeControlText
{
    
}

#pragma mark -
#pragma mark control action

-(void)buttonAction:(id) sender
{
    _timeCount = 0;
    switch (((UIButton *)sender).tag) {
        case HUD_BACK_BUTTON:
        {
            [m_nextLoadName ClearDelegate];
            [[ANParamValue sharedInstance] setIsHud:NO];
            [self.navigationController popViewControllerAnimated:YES];
        }
            break;
        case HUD_SWITCH:
        {
            [self switchChange];
        }
            break;
        default:
            break;
    }
}

- (void) switchChange
{
    _timeCount = 0;
    [[ANOperateMethod sharedInstance] GMD_ChangeTomirrorViewInView:_viewContent isSwitch:_switchReflection.on];
    [[MWPreference sharedInstance] setValue:PREF_HUD_DISPLAYORIENTATION Value:_switchReflection.on];
}

- (void)ChangeTextPosition
{
    [self ChangeViewInfo];
}


#pragma mark -
#pragma mark logic relate
-	(void)landscapeLogic
{
    
    
}
-	(void)portraitLogic
{
    
    
}

#pragma mark -
#pragma mark notification
-(void)notificationReceived:(NSNotification*) notification
{
    if ([notification.name isEqual:NOTIFY_PASSINFOTOHUD])
	{
        [self ChangeViewInfo];
	}
}

#pragma mark -
#pragma mark xxx delegate


#pragma mark - GestureRecognizer method

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isKindOfClass:[UIButton class]]) {
        return NO;
    }
    return YES;
}

- (void)TapRecongnizer:(UITapGestureRecognizer *)recognizer
{
    if (recognizer.numberOfTapsRequired == 1 && recognizer.numberOfTouchesRequired == 1)
    {
        
        __block HudViewController *blockHud = self;
        __block UILabel *blockLabel = _labelBottom;
        [UIView animateWithDuration:0.2f animations:^{
            if(blockLabel.center.y == blockHud.view.frame.size.height - LABEL_HIGHT / 2)
            {
                [blockHud setHiddenTipsLabel:YES];
            }
            else
            {
                [blockHud setHiddenTipsLabel:NO];
            }
        }];
    }
}

- (void)fireTimer:(NSTimer *)timer
{
    if(_timeCount == 3)
    {
        __block HudViewController *blockHud = self;
        [UIView animateWithDuration:0.2f animations:^{
             [blockHud setHiddenTipsLabel:YES];
        }];
    }
    _timeCount++;
}

- (void) setHiddenTipsLabel:(BOOL) isHidden
{
    CGFloat height = (Interface_Flag == 0 ? MAIN_POR_HEIGHT : MAIN_LAND_HEIGHT);
    CGFloat width = (Interface_Flag == 0 ? MAIN_POR_WIDTH : MAIN_LAND_WIDTH);
    if(isHidden == YES)
    {
        _labelBottom.center = CGPointMake(_labelBottom.center.x,
                                        self.view.frame.size.height + LABEL_HIGHT / 2);

        _buttonBack.center = CGPointMake(HUD_BUTTON_BACK_WIDTH / 2, height + LABEL_HIGHT / 2);
        
        _switchReflection.center = CGPointMake(width - _switchReflection.frame.size.width  * 5 / 7,
                                               height + LABEL_HIGHT / 2);
        _timeCount = 4;
    }
    else
    {
        _labelBottom.center = CGPointMake(_labelBottom.center.x,
                                          self.view.frame.size.height - LABEL_HIGHT / 2);
        
        _buttonBack.center = CGPointMake(HUD_BUTTON_BACK_WIDTH / 2, height - LABEL_HIGHT / 2);
        
        _switchReflection.center = CGPointMake(width - _switchReflection.frame.size.width * 5 / 7 ,
                                               height - LABEL_HIGHT / 2);
        
        _timeCount = 0;
    }
}


@end

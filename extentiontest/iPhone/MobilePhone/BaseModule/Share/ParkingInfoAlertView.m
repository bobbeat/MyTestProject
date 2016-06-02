//
//  ParkingInfoAlertView.m
//  AutoNavi
//
//  Created by jiangshu-fu on 14-4-10.
//
//

#import "ParkingInfoAlertView.h"
#import "POIDesParkObj.h"
#import "ColorLable.h"
#import "ANParamValue.h"

#pragma mark - ---  视图~  ---
@interface ParkingInfoView : UIView
{
    UIControl *_controlBack;    //半透明黑色背景
    UIView *_viewBack;          //弹出框白色背景
    UILabel *_labelPark;        //停车场名字
    UILabel *_labelAdd;         //停车场地址
    ColorLable *_colorLableInfo;        //停车场相信信息
    UIImageView *_imageViewLine;        //分割线
    
    UIButton *_buttonSetDes;    //就停这里
    UIButton *_buttonViewMap;   //查看地图
}

@property (nonatomic, retain) POIDesParkObj *infoObj;
@property (nonatomic, copy)   SetDesToHandle setDesToHandle;
@property (nonatomic, copy)   ViewMapInfoHandle viewMapInfoHandle;

- (id) initWIthInfo:(POIDesParkObj *)infoObj
    withDesToHandle:(SetDesToHandle)setDesToHandle
withViewMapInfoHandle:(ViewMapInfoHandle) viewMapInfoHandle;

@end

@implementation ParkingInfoView

@synthesize infoObj = _infoObj;
@synthesize setDesToHandle = _setDesToHandle;
@synthesize viewMapInfoHandle = _viewMapInfoHandle;

- (id) init
{
    self  = [super init];
    if(self)
    {
        _infoObj = nil;
        _setDesToHandle = nil;
        _viewMapInfoHandle = nil;
    }
    return self;
}

- (id) initWIthInfo:(POIDesParkObj *)infoObj
    withDesToHandle:(SetDesToHandle)setDesToHandle
withViewMapInfoHandle:(ViewMapInfoHandle) viewMapInfoHandle
{
    self = [self init];
    if(self)
    {
        self.infoObj = infoObj;
        self.setDesToHandle = setDesToHandle;
        self.viewMapInfoHandle = viewMapInfoHandle;
        [self initControl];
    }
    return self;
}

- (void) initControl
{
    //view设置
    self.backgroundColor = [UIColor clearColor];
    _controlBack = [[UIControl alloc]initWithFrame:self.bounds];
    _controlBack.backgroundColor = GETSKINCOLOR(CONTROL_BACKGROUND_COLOR);
    [_controlBack  addTarget:self action:@selector(controlClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_controlBack];
    [_controlBack release];
    
    _viewBack = [[UIView alloc]init];
    _viewBack.backgroundColor = [UIColor whiteColor];
    _viewBack.layer.cornerRadius = 6;
    _viewBack.layer.masksToBounds = YES;
    [self addSubview:_viewBack];
    [_viewBack release];
    
    _imageViewLine = [[UIImageView alloc]init];
    _imageViewLine.backgroundColor = RGBACOLOR(216.0f, 216.0f, 216.0f,0.8f);
    [_viewBack addSubview:_imageViewLine];
    [_imageViewLine release];
    
    
    
    UIColor *labelColor = RGBCOLOR(38.0f, 38.0f, 38.0f);
    //label 设置
    _labelPark  = [[UILabel alloc]init];
    _labelPark.backgroundColor = [UIColor clearColor];
    _labelPark.font = [UIFont boldSystemFontOfSize:18.0f];
    _labelPark.textColor = labelColor;
    [_viewBack addSubview:_labelPark];
    [_labelPark release];
    
    _labelAdd = [[UILabel alloc]init];
    _labelAdd.backgroundColor = [UIColor clearColor];
    _labelAdd.font = [UIFont boldSystemFontOfSize:14.0f];
    _labelAdd.textColor = labelColor;
    [_viewBack addSubview:_labelAdd];
    [_labelAdd release];
    
    _colorLableInfo = [[ColorLable alloc]initWithFrame:CGRectZero ColorArray:@[RGBCOLOR(182.0f, 15.0f, 39.0f)]];
    _colorLableInfo.backgroundColor = [UIColor clearColor];
    _colorLableInfo.font = [UIFont systemFontOfSize:15.0f];
    _colorLableInfo.lineSpace = 5.0f;
    _colorLableInfo.textColor = labelColor;
    [_viewBack addSubview:_colorLableInfo];
    [_colorLableInfo release];
    
    //button设置
    UIColor *buttonTitleColor = RGBCOLOR(77.0f, 140.0f,252.0f);
    UIColor *buttonSetDesColor = RGBCOLOR(25.0f, 88.0f,229.0f);
    UIColor *buttonTitleHighlightColor = RGBCOLOR(255.0f, 255.0f, 255.0f);
    _buttonSetDes = [UIButton buttonWithType:UIButtonTypeCustom];
    [_buttonSetDes setTitle:STR(@"Main_ParkingSetDes", Localize_Main) forState:UIControlStateNormal];
    
    [_buttonSetDes setBackgroundImage:[IMAGE(@"AlertViewButtonBac1.png", IMAGEPATH_TYPE_1) stretchableImageWithLeftCapWidth:3 topCapHeight:3] forState:UIControlStateNormal];
    [_buttonSetDes setBackgroundImage:[IMAGE(@"ButtonHightlightBac.png", IMAGEPATH_TYPE_1) stretchableImageWithLeftCapWidth:3 topCapHeight:0] forState:UIControlStateHighlighted];
    [_buttonSetDes setTitleColor:buttonSetDesColor forState:UIControlStateNormal];
    [_buttonSetDes setTitleColor:buttonTitleHighlightColor forState:UIControlStateHighlighted];
    
    _buttonSetDes.tag = 0;
    [_buttonSetDes addTarget:self  action:@selector(buttonPress:) forControlEvents:UIControlEventTouchUpInside];
    [_viewBack addSubview:_buttonSetDes];
    
    _buttonViewMap = [UIButton buttonWithType:UIButtonTypeCustom];
    [_buttonViewMap setTitle:STR(@"Main_ParkingViewMap", Localize_Main) forState:UIControlStateNormal];
    
    [_buttonViewMap setBackgroundImage:[IMAGE(@"AlertViewButtonBac2.png", IMAGEPATH_TYPE_1) stretchableImageWithLeftCapWidth:3 topCapHeight:3] forState:UIControlStateNormal];
    [_buttonViewMap setBackgroundImage:[IMAGE(@"ButtonHightlightBac.png", IMAGEPATH_TYPE_1) stretchableImageWithLeftCapWidth:3 topCapHeight:0] forState:UIControlStateHighlighted];
    [_buttonViewMap setTitleColor:buttonTitleColor forState:UIControlStateNormal];
    [_buttonViewMap setTitleColor:buttonTitleHighlightColor forState:UIControlStateHighlighted];
    
    _buttonViewMap.tag = 1;
    [_buttonViewMap addTarget:self  action:@selector(buttonPress:) forControlEvents:UIControlEventTouchUpInside];
    [_viewBack addSubview:_buttonViewMap];
    
    [self addData];
    
    if(Interface_Flag == 0)
    {
        [self changePortraitControlFrameWithImage];
    }
    else
    {
        [self changeLandscapeControlFrameWithImage];
    }
}

- (void) dealloc
{
    [ParkingInfoAlertView hiddenParkingInfo];
    if(_setDesToHandle)
    {
        [_setDesToHandle release];
        _setDesToHandle = nil;
    }
    if(_viewMapInfoHandle)
    {
        [_viewMapInfoHandle release];
        _viewMapInfoHandle = nil;
    }
    [super dealloc];
}


#pragma mark ---  按钮响应事件  ---
- (void) controlClick
{
    [self removeFromSuperview];
    [ParkingInfoAlertView hiddenParkingInfo];
}

- (void)buttonPress:(id)sender
{
    [self removeFromSuperview];
    if(((UIButton *)sender).tag == 0)
    {
        if(self.setDesToHandle)
        {
            self.setDesToHandle();
        }
    }
    else if(((UIButton *)sender).tag == 1)
    {
        if(self.viewMapInfoHandle)
        {
            self.viewMapInfoHandle();
        }
    }
}

#pragma  mark ---  填充数据  ---
- (void) addData
{
    if(self.infoObj )
    {
        
        _labelPark.text = self.infoObj.szName;
        _labelAdd.text = self.infoObj.szAddr;
        
        if( self.infoObj.bParkDetail)
        {
            
            NSMutableString *colorString = [[NSMutableString alloc]initWithFormat:@""];
            
            
            
            [colorString appendString:
             [NSString stringWithFormat:STR(@"Main_ParkingDistance", Localize_Main),
              [NSString stringWithFormat:@"%d%@", self.infoObj.lDistance,STR(@"Universal_M", Localize_Universal)]]];
            [colorString appendString:@"\n"];
            if( self.infoObj.prc_c_d_e != -1)
            {
                [colorString appendString:
                 [NSString stringWithFormat:STR(@"Main_ParkingCarDay", Localize_Main),
                  [NSString stringWithFormat:@"%d%@", self.infoObj.prc_c_d_e,STR(@"Main_ParkingMoneyPerHour", Localize_Main)]]];
                
            }
            else
            {
                [colorString appendString:
                 [NSString stringWithFormat:STR(@"Main_ParkingCarDay", Localize_Main),STR(@"Main_ParkNoMoney", Localize_Main)
                  ]];
            }
            
            [colorString appendString:@"\n"];
            if(self.infoObj.prc_t_d_e != -1)
            {
                [colorString appendString:
                 [NSString stringWithFormat:STR(@"Main_ParkingCarNight", Localize_Main),
                  [NSString stringWithFormat:@"%d%@", self.infoObj.prc_t_d_e,STR(@"Main_ParkingMoneyPerHour", Localize_Main)]]];
            }
            else
            {
                [colorString appendString:
                 [NSString stringWithFormat:STR(@"Main_ParkingCarNight", Localize_Main),STR(@"Main_ParkNoMoney", Localize_Main)
                  ]];
            }
            
            [colorString appendString:@"\n"];
            if(self.infoObj.prc_c_d_e != -1)
            {
                [colorString appendString:
                 [NSString stringWithFormat:STR(@"Main_ParkingvehicleDay", Localize_Main),
                  [NSString stringWithFormat:@"%d%@", self.infoObj.prc_c_d_e,STR(@"Main_ParkingMoneyPerHour", Localize_Main)]]];
            }
            else
            {
                [colorString appendString:
                 [NSString stringWithFormat:STR(@"Main_ParkingvehicleDay", Localize_Main),STR(@"Main_ParkNoMoney", Localize_Main)
                  ]];
            }
            [colorString appendString:@"\n"];
            if(self.infoObj.prc_t_n_e != -1)
            {
                [colorString appendString:
                 [NSString stringWithFormat:STR(@"Main_ParkingvehicleNight", Localize_Main),
                  [NSString stringWithFormat:@"%d%@", self.infoObj.prc_t_n_e,STR(@"Main_ParkingMoneyPerHour", Localize_Main)]]];
            }
            else
            {
                [colorString appendString:
                 [NSString stringWithFormat:STR(@"Main_ParkingvehicleNight", Localize_Main),STR(@"Main_ParkNoMoney", Localize_Main)
                  ]];
            }
            [colorString appendString:@"\n"];
            if(self.infoObj.num_space != -1)
            {
                [colorString appendString:
                 [NSString stringWithFormat:STR(@"Main_ParkingCarRoom", Localize_Main),
                  [NSString stringWithFormat:@"%d%@", self.infoObj.num_space,STR(@"Main_ParkingNum", Localize_Main)]]];
            }
            else
            {
                [colorString appendString:
                 [NSString stringWithFormat:STR(@"Main_ParkingCarRoom", Localize_Main),STR(@"Main_ParkNoInformation", Localize_Main)
                  ]];
            }
            [colorString appendString:@"\n"];
            
            
            
            NSLog(@"%@",colorString);
            
            _colorLableInfo.text = colorString;
            _colorLableInfo.hidden = NO;
            _imageViewLine.hidden = NO;
            [colorString release];
        }
        else
        {
            NSMutableString *colorString = [[NSMutableString alloc]initWithFormat:@""];
            
            if(self.infoObj.lDistance < 1000)
            {
                [colorString appendString:
                 [NSString stringWithFormat:STR(@"Main_ParkingDistance", Localize_Main),
                  [NSString stringWithFormat:@"%d%@",  self.infoObj.lDistance,STR(@"Universal_M", Localize_Universal)]]];
            }
            else
            {
                [colorString appendString:
                 [NSString stringWithFormat:STR(@"Main_ParkingDistance", Localize_Main),
                  [NSString stringWithFormat:@"%0.lf%@",  (self.infoObj.lDistance / 1000.0f),STR(@"Universal_KM", Localize_Universal)]]];
            }
            [colorString appendString:@"\n"];
            [colorString appendString:
             [NSString stringWithFormat:STR(@"Main_ParkingCarDay", Localize_Main),STR(@"Main_ParkNoMoney", Localize_Main)
              ]];
            [colorString appendString:@"\n"];
            [colorString appendString:
             [NSString stringWithFormat:STR(@"Main_ParkingCarNight", Localize_Main),STR(@"Main_ParkNoMoney", Localize_Main)
              ]];
            [colorString appendString:@"\n"];
            [colorString appendString:
             [NSString stringWithFormat:STR(@"Main_ParkingvehicleDay", Localize_Main),STR(@"Main_ParkNoMoney", Localize_Main)
              ]];
            [colorString appendString:@"\n"];
            [colorString appendString:
             [NSString stringWithFormat:STR(@"Main_ParkingvehicleNight", Localize_Main),STR(@"Main_ParkNoMoney", Localize_Main)
              ]];
            [colorString appendString:@"\n"];
            [colorString appendString:
             [NSString stringWithFormat:STR(@"Main_ParkingCarRoom", Localize_Main),STR(@"Main_ParkNoInformation", Localize_Main)
              ]];
            [colorString appendString:@"\n"];
            
            
            NSLog(@"%@",colorString);
            
            _colorLableInfo.text = colorString;
            _colorLableInfo.hidden = NO;
            _imageViewLine.hidden = NO;
            [colorString release];
        }
    }
}


#pragma mark ---  界面横竖屏和位置调整  ---
//调整控件竖屏坐标和图片
-(void)changePortraitControlFrameWithImage
{
    
    float viewHeight = 560.0f / 2.0f;// : (256 / 2);
    float viewWidth = 560.0f / 2.0f;
    [_controlBack  setFrame:CGRectMake(0, 0, SCREENWIDTH,SCREENHEIGHT )];
    [_viewBack setFrame:CGRectMake(0, 0, viewWidth, viewHeight)];
    [_viewBack setCenter:CGPointMake(_controlBack.bounds.size.width / 2 , _controlBack.bounds.size.height / 2)];
    //label设置
    float labelBlank = 36.0f;
    [_labelPark setFrame:CGRectMake(labelBlank, 25.0f, viewWidth - 2 * labelBlank, 20.0f)];
    
    [_labelAdd setFrame:CGRectMake(labelBlank,
                                   _labelPark.frame.origin.y + _labelPark.frame.size.height,
                                   viewWidth - 2 * labelBlank,
                                   18.0f)];
    
    //    if(self.infoObj.bParkDetail)
    //    {
    [_imageViewLine setFrame:CGRectMake(0,
                                        _labelAdd.frame.origin.y + _labelAdd.frame.size.height + 9.0f,
                                        _viewBack.frame.size.width,
                                        1.0f)];
    
    
    [_colorLableInfo setFrame:CGRectMake(labelBlank,
                                         _labelAdd.frame.origin.y + _labelAdd.frame.size.height + 20.0f,
                                         viewWidth - 2 * labelBlank,
                                         140.0f)];
    //    }
    //button 设置
    float buttonHeight = 44.0f;
    [_buttonSetDes setFrame:CGRectMake(0,
                                       _viewBack.frame.size.height - buttonHeight,
                                       _viewBack.frame.size.width / 2 ,
                                       buttonHeight)];
    [_buttonViewMap setFrame:CGRectMake(_viewBack.frame.size.width / 2,
                                        _viewBack.frame.size.height - buttonHeight,
                                        _viewBack.frame.size.width / 2 ,
                                        buttonHeight)];
    
}

//调整控件横屏坐标和图片
-(void)changeLandscapeControlFrameWithImage
{
    
    float viewHeight = 560.0f / 2.0f;// : (256 / 2);
    float viewWidth = 560.0f / 2.0f;
    [_controlBack  setFrame:CGRectMake(0, 0, SCREENHEIGHT, SCREENWIDTH)];
    [_viewBack setFrame:CGRectMake(0, 0, viewWidth, viewHeight)];
    [_viewBack setCenter:CGPointMake(_controlBack.bounds.size.width / 2 , _controlBack.bounds.size.height / 2)];
    //label设置
    float labelBlank = 36.0f;
    [_labelPark setFrame:CGRectMake(labelBlank, 25.0f, viewWidth - 2 * labelBlank, 20.0f)];
    
    [_labelAdd setFrame:CGRectMake(labelBlank,
                                   _labelPark.frame.origin.y + _labelPark.frame.size.height,
                                   viewWidth - 2 * labelBlank,
                                   18.0f)];
    //
    //    if(self.infoObj.bParkDetail)
    //    {
    [_imageViewLine setFrame:CGRectMake(0,
                                        _labelAdd.frame.origin.y + _labelAdd.frame.size.height + 9.0f,
                                        _viewBack.frame.size.width,
                                        1.0f)];
    
    
    [_colorLableInfo setFrame:CGRectMake(labelBlank,
                                         _labelAdd.frame.origin.y + _labelAdd.frame.size.height + 20.0f,
                                         viewWidth - 2 * labelBlank,
                                         140.0f)];
    //    }
    //button 设置
    float buttonHeight = 44.0f;
    [_buttonSetDes setFrame:CGRectMake(0,
                                       _viewBack.frame.size.height - buttonHeight,
                                       _viewBack.frame.size.width / 2 ,
                                       buttonHeight)];
    [_buttonViewMap setFrame:CGRectMake(_viewBack.frame.size.width / 2,
                                        _viewBack.frame.size.height - buttonHeight,
                                        _viewBack.frame.size.width / 2 ,
                                        buttonHeight)];
    
}
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if(orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        [self changePortraitControlFrameWithImage];
    }
    else
    {
        [self changeLandscapeControlFrameWithImage];
    }
}

- (BOOL)shouldAutorotate
{
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationUnknown) {
        return YES;
    }
    
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if (!OrientationSwitch)
    {
        return (Orientation == interfaceOrientation);
    }
	return  YES;
    
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationUnknown) {
        [[MWPreference sharedInstance] loadPreference];
    }
    
    if ([[ANParamValue sharedInstance] bSupportAutorate] == NO)
    {
        return  UIInterfaceOrientationMaskPortrait;
    }
    else{
        if (!OrientationSwitch) {
            return (1<<[[UIApplication sharedApplication] statusBarOrientation]);
        }
        return  UIInterfaceOrientationMaskAll;
    }
}



@end

@interface ParkingInfoViewController : UIViewController
{
    ParkingInfoView *parkView;
}
@end

@implementation ParkingInfoViewController

- (id) initWIthInfo:(POIDesParkObj *)infoObj
    withDesToHandle:(SetDesToHandle)setDesToHandle
withViewMapInfoHandle:(ViewMapInfoHandle) viewMapInfoHandle
{
    if (self = [super init])
    {
        parkView = [[ParkingInfoView alloc] initWIthInfo:infoObj withDesToHandle:setDesToHandle withViewMapInfoHandle:viewMapInfoHandle];
        parkView.frame = self.view.bounds;
        self.view = parkView;
        [parkView release];
        
    }
    return self;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if(orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        [parkView changePortraitControlFrameWithImage];
    }
    else
    {
        [parkView changeLandscapeControlFrameWithImage];
    }
}

- (BOOL)shouldAutorotate
{
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationUnknown) {
        return YES;
    }
    
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if (!OrientationSwitch)
    {
        return (Orientation == interfaceOrientation);
    }
	return  YES;
    
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationUnknown) {
        [[MWPreference sharedInstance] loadPreference];
    }
    
    if ([[ANParamValue sharedInstance] bSupportAutorate] == NO)
    {
        return  UIInterfaceOrientationMaskPortrait;
    }
    else{
        if (!OrientationSwitch) {
            return (1<<[[UIApplication sharedApplication] statusBarOrientation]);
        }
        return  UIInterfaceOrientationMaskAll;
    }
}

@end

static UIWindow *g_window = nil;
static UIWindowLevel Route_UIWindowLevelSIAlert = 1999.0;  // 不覆盖系统警告
static ParkingInfoViewController *_infoViewController;

#pragma mark - ---  视图显示window  ---
@implementation ParkingInfoAlertView

+ (void) showParkingInfo:(POIDesParkObj *)infoObject
               desHandle:(SetDesToHandle)desToHandle
              viewHandle:(ViewMapInfoHandle)viewHandle
{
    if (g_window) //存在window，需要先释放window
    {
        [g_window release];
        g_window = nil;
    }
    _infoViewController = [[ParkingInfoViewController alloc] initWIthInfo:infoObject
                                                          withDesToHandle:desToHandle
                                                    withViewMapInfoHandle:viewHandle];
    
    g_window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    g_window.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    g_window.opaque = NO;
    g_window.windowLevel = Route_UIWindowLevelSIAlert;
    g_window.rootViewController = _infoViewController;
    g_window.hidden = NO;
    
    [_infoViewController release];
}

+ (void) hiddenParkingInfo
{
    if(g_window)
    {
        [g_window release];
        g_window = nil;
        _infoViewController = nil;
    }
}

@end

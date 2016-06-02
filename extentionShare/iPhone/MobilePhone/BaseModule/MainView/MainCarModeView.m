//
//  MainCarModeView.m
//  AutoNavi
//
//  Created by jiangshu-fu on 14-8-28.
//
//

#import "MainCarModeView.h"
#import "ControlCreat.h"
#import "MainDefine.h"
#import "UMengEventDefine.h"

@implementation MainCarModeView
@synthesize mainCarModeClick = _mainCarModeClick;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void) dealloc
{
    CRELEASE(_mainCarModeClick);
    [super dealloc];
}

#pragma mark ---  给外部调用接口  ---
- (id) initWithFrame:(CGRect)frame withAnimateCenter:(CGPoint)animateCenter withSizeButton:(CGSize) sizeButton
{
    self = [self initWithFrame:frame];
    if(self)
    {
        _pointAnimate = animateCenter;
        [self initSwitchMode];
        [self setFrame:frame withAnimateCenter:animateCenter withSizeButton:sizeButton];
    }
    return self;
}

- (void) setFrame:(CGRect)frame withAnimateCenter:(CGPoint) animateCenter withSizeButton:(CGSize) sizeButton
{
    _pointAnimate = animateCenter;
    _sizeButton = sizeButton;
    [self setFrame:frame];
}

static bool canChangeMode = YES;
- (void) showHideModeSwitch
{
    if(canChangeMode == NO) return ;
    canChangeMode = NO;
    if(_viewSwitchModeBG.hidden)
    {
        [self bringSubviewToFront:_controlBG];
        [self bringSubviewToFront:_viewSwitchModeBG];
        //        [self bringSubviewToFront:_buttonModeChange];
        [self showModeSwitch];
        
    }
    else
    {
        [self hideModeSwitch];
    }
    //设置是否显示
    [self switchModeButton];
    
}

/*!
  @brief    语言修改时候，修改文字显示
  @param
  @author   by bazinga
  */
- (void) reloadText
{
    _labelNAngel.text = STR(@"Main_nAngel", Localize_Main) ;
    _labelCarAngel.text = STR(@"Main_carAngel", Localize_Main);
    _label3DAngel.text = STR(@"Main_3DAngel", Localize_Main) ;
    _labelnHUD.text = STR(@"Main_hudAngel", Localize_Main) ;
}


#pragma mark ---  重载函数  ---
- (void) setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self setSwitchModeContentFrame];
}

- (void) setHidden:(BOOL)hidden
{
    [super setHidden:hidden];
    _viewSwitchModeBG.hidden = hidden;
    _controlBG.hidden = hidden;
    [self switchModeButton];
}

#pragma mark ---  地图模式切换按钮  ---
/*!
  @brief    初始化函数
  @param
  @author   by bazinga
  */
- (void) initSwitchMode
{
    _viewSwitchModeBG = [[UIImageView alloc] init];
    _viewSwitchModeBG.userInteractionEnabled = YES;
    _viewSwitchModeBG.image = [IMAGE(@"main_modeBG.png", IMAGEPATH_TYPE_1)stretchableImageWithLeftCapWidth:13
                                                                                              topCapHeight:54];
    
    _buttonNAngel = [MainControlCreate createButtonWithTitle:nil
                                                 normalImage:IMAGE(@"main_NAngle.png", IMAGEPATH_TYPE_1)
                                               heightedImage:IMAGE(@"main_NAnglePress.png", IMAGEPATH_TYPE_1)
                                                         tag:BUTTON_MODE_NORTH
                                                      target:self
                                                      action:@selector(buttonClick:)];
    
   _button3DAngel = [MainControlCreate createButtonWithTitle:nil
                                   normalImage:IMAGE(@"main_3DAngle.png", IMAGEPATH_TYPE_1)
                                 heightedImage:IMAGE(@"main_3DAnglePress.png", IMAGEPATH_TYPE_1)
                                           tag:BUTTON_MODE_3D
                                        target:self
                                        action:@selector(buttonClick:)];
    
    _buttonCarAngel = [MainControlCreate createButtonWithTitle:nil
                                                  normalImage:IMAGE(@"main_carAngle.png", IMAGEPATH_TYPE_1)
                                                heightedImage:IMAGE(@"main_carAnglePress.png", IMAGEPATH_TYPE_1)
                                                          tag:BUTTON_MODE_CAR
                                                       target:self
                                                       action:@selector(buttonClick:)];
    
    _buttonHUD = [MainControlCreate createButtonWithTitle:nil
                                                   normalImage:IMAGE(@"main_hud.png", IMAGEPATH_TYPE_1)
                                                 heightedImage:IMAGE(@"main_hudPress.png", IMAGEPATH_TYPE_1)
                                                           tag:BUTTON_HUD
                                                        target:self
                                                        action:@selector(buttonClick:)];

    [_buttonNAngel setBackgroundImage:IMAGE(@"main_NAnglePress.png",IMAGEPATH_TYPE_1) forState:UIControlStateSelected];
    [_button3DAngel setBackgroundImage:IMAGE(@"main_3DAnglePress.png",IMAGEPATH_TYPE_1) forState:UIControlStateSelected];
    [_buttonCarAngel setBackgroundImage:IMAGE(@"main_carAnglePress.png",IMAGEPATH_TYPE_1) forState:UIControlStateSelected];
    _viewSwitchModeBG.hidden = self.hidden;
    
    _labelNAngel = [ControlCreat createLabelWithText:STR(@"Main_nAngel", Localize_Main) fontSize:15.0f textAlignment:NSTextAlignmentCenter];
    _labelCarAngel = [ControlCreat createLabelWithText:STR(@"Main_carAngel", Localize_Main) fontSize:15.0f textAlignment:NSTextAlignmentCenter];
    _label3DAngel = [ControlCreat createLabelWithText:STR(@"Main_3DAngel", Localize_Main) fontSize:15.0f textAlignment:NSTextAlignmentCenter];
    _labelnHUD = [ControlCreat createLabelWithText:STR(@"Main_hudAngel", Localize_Main) fontSize:15.0f textAlignment:NSTextAlignmentCenter];
    
    _labelNAngel.textColor = GETSKINCOLOR(MAIN_MODELABEL_COLOR);
    _labelCarAngel.textColor = GETSKINCOLOR(MAIN_MODELABEL_COLOR);
    _label3DAngel.textColor = GETSKINCOLOR(MAIN_MODELABEL_COLOR);
    _labelnHUD.textColor = GETSKINCOLOR(MAIN_MODELABEL_COLOR);
    
    _controlBG = [[UIControl alloc]init];
    _controlBG.backgroundColor = GETSKINCOLOR(CONTROL_BACKGROUND_COLOR);
    [_controlBG addTarget:self action:@selector(hideModeSwitch) forControlEvents:UIControlEventTouchUpInside];
    _controlBG.hidden = self.hidden;
    
    [_viewSwitchModeBG addSubview:_buttonNAngel];
    [_viewSwitchModeBG addSubview:_button3DAngel];
    [_viewSwitchModeBG addSubview:_buttonCarAngel];
    [_viewSwitchModeBG addSubview:_buttonHUD];
    
    [_viewSwitchModeBG addSubview:_labelNAngel];
    [_viewSwitchModeBG addSubview:_labelCarAngel];
    [_viewSwitchModeBG addSubview:_label3DAngel];
    [_viewSwitchModeBG addSubview:_labelnHUD];
    
    [self switchModeButton];
    [self addSubview:_controlBG];
    [self addSubview:_viewSwitchModeBG];
    
    [_controlBG release];
    [_viewSwitchModeBG release];
}

- (void) switchModeButton
{
    _buttonNAngel.hidden = _viewSwitchModeBG.hidden;
    _button3DAngel.hidden = _viewSwitchModeBG.hidden;
    _buttonCarAngel.hidden = _viewSwitchModeBG.hidden;
    
    _labelNAngel.hidden = _viewSwitchModeBG.hidden;
    _labelCarAngel.hidden = _viewSwitchModeBG.hidden;
    _label3DAngel.hidden = _viewSwitchModeBG.hidden;
    if([[ANParamValue sharedInstance] isPath])
    {
        _buttonHUD.hidden = _viewSwitchModeBG.hidden;
        _labelnHUD.hidden = _viewSwitchModeBG.hidden;
    }
    else
    {
        _labelnHUD.hidden = YES;
        _buttonHUD.hidden = YES;
    }
}

- (void) setModeSwitch:(GMAPVIEWMODE)mode withButton:(UIButton *)button
{
    [self hideModeSwitch];
    GMAPVIEWINFO mapViewInfo = {0};
    
    if([[MWMapOperator sharedInstance] MW_GetMapViewInfo:GMAP_VIEW_TYPE_MAIN MapViewInfo:&mapViewInfo] == GD_ERR_OK)
    {
        if(mapViewInfo.eMapMode == mode)
        {
            return;
        }
    }
    
    if([[MWMapOperator sharedInstance]  MW_SetMapViewMode:GMAP_VIEW_TYPE_MAIN Type:0 MapMode:mode] == GD_ERR_OK)
    {
        //        GMAPVIEW_MODE_NORTH = 0,	/**< 北向模式 */
        //        GMAPVIEW_MODE_CAR   = 1,	/**< 车向模式 */
        //        GMAPVIEW_MODE_3D    = 2,	/**< 3D模式 */
        if ([[ANParamValue sharedInstance] isPath])
        {
            if(mode == GMAPVIEW_MODE_NORTH)
            {
                [MobClick event:UM_UM_EVENTID_NaviViewCount_COUNT label:UM_LABEL_Navi_NorthOn];
            }
            else if(mode == GMAPVIEW_MODE_CAR)
            {
                [MobClick event:UM_UM_EVENTID_NaviViewCount_COUNT label:UM_LABEL_Navi_CarOn];
            }
            else if(mode == GMAPVIEW_MODE_3D)
            {
                [MobClick event:UM_UM_EVENTID_NaviViewCount_COUNT label:UM_LABEL_Navi_3D];
            }
        }
        _buttonCarAngel.selected = NO; _button3DAngel.selected = NO; _buttonNAngel.selected = NO;
        button.selected = YES;
        [[MWMapOperator sharedInstance] MW_ShowMapView:GMAP_VIEW_TYPE_MAIN WithParma1:0 WithParma2:0 WithParma3:0];
     }
}



#pragma mark ---  动画设置  ---
- (void) showModeSwitch
{
    //设置右上角地图视角的图片
    GMAPVIEWINFO mapObjectInfo = {0};
    [[MWMapOperator sharedInstance] MW_GetMapViewInfo:GMAP_VIEW_TYPE_MAIN MapViewInfo:&mapObjectInfo];
    //    GMAPVIEW_MODE_NORTH = 0,
    //	GMAPVIEW_MODE_CAR   = 1,
    //	GMAPVIEW_MODE_3D    = 2,
    switch (mapObjectInfo.eMapMode) {
        case GMAPVIEW_MODE_NORTH:
        {
            _buttonCarAngel.selected = NO; _button3DAngel.selected = NO; _buttonNAngel.selected = YES;
        }
            break;
        case GMAPVIEW_MODE_CAR:
        {
            _buttonCarAngel.selected = YES; _button3DAngel.selected = NO; _buttonNAngel.selected = NO;
        }
            break;
        case GMAPVIEW_MODE_3D:
        {
            _buttonCarAngel.selected = NO; _button3DAngel.selected = YES; _buttonNAngel.selected = NO;
        }
            break;
        default:
            break;
    }
    
    CGPoint point;
    if(Interface_Flag == 0 || isPad) //竖屏
    {
        point = CGPointMake(_pointAnimate.x + _sizeButton.width / 2 - _viewSwitchModeBG.frame.size.width / 2,
                            _pointAnimate.y + _viewSwitchModeBG.frame.size.height/2 + _sizeButton.height / 2);
        _viewSwitchModeBG.center = CGPointMake(_pointAnimate.x, _pointAnimate.y + _sizeButton.height / 2);

    }
    else
    {
        point = CGPointMake(_pointAnimate.x - _sizeButton.width / 2 - _viewSwitchModeBG.frame.size.width / 2,
                            _pointAnimate.y - _sizeButton.height / 2 + _viewSwitchModeBG.frame.size.height/2 );
        
        _viewSwitchModeBG.center = CGPointMake(_pointAnimate.x - _sizeButton.width / 2 ,
                                               _pointAnimate.y);
    }
    self.hidden = NO;
    
    GMAPVIEWINFO mapObjectInfo1 = {0};
    [[MWMapOperator sharedInstance] MW_GetMapViewInfo:GMAP_VIEW_TYPE_MAIN MapViewInfo:&mapObjectInfo1];
    
    //缩放动画(放大动画)
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.fromValue = [NSNumber numberWithFloat:0.0];
    scaleAnimation.toValue = [NSNumber numberWithFloat:1.0];
    scaleAnimation.duration = 0.2f;
    scaleAnimation.removedOnCompletion = YES;
    scaleAnimation.byValue  = [NSValue valueWithCGRect:_viewSwitchModeBG.bounds];
    
    //位置偏移动画
    CABasicAnimation *positionAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
    positionAnimation.duration = 0.2f;
    positionAnimation.fromValue = [NSValue valueWithCGPoint:_viewSwitchModeBG.center];
    positionAnimation.toValue = [NSValue valueWithCGPoint:point];
    
    
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.duration = 0.2f;
    animationGroup.autoreverses = NO;
    animationGroup.removedOnCompletion = NO;
    animationGroup.fillMode = kCAFillModeForwards;
    //是否重播，原动画的倒播
    animationGroup.repeatCount = 0;
    animationGroup.delegate = self;
    [animationGroup setValue:@"showMode" forKey:@"animateType"];
    [animationGroup setValue:[NSValue valueWithCGPoint:point] forKey:@"endPoint"];
    [animationGroup setAnimations:[NSArray arrayWithObjects: scaleAnimation,positionAnimation, nil]];
    
    [_viewSwitchModeBG.layer addAnimation:animationGroup forKey:@"animationGroup"];
    
}

- (void) hideModeSwitch
{
    CGPoint endPoint;
    if(Interface_Flag == 0 || isPad)//竖屏
    {
        endPoint = CGPointMake(_pointAnimate.x, _pointAnimate.y + _sizeButton.height / 2);
    }
    else
    {
        endPoint = CGPointMake(_pointAnimate.x - _sizeButton.width / 2 ,
                               _pointAnimate.y);
    }
    //缩放动画(缩小动画)
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.fromValue = [NSNumber numberWithFloat:1.0];
    scaleAnimation.toValue = [NSNumber numberWithFloat:0.0];
    scaleAnimation.duration = 0.2f;
    scaleAnimation.removedOnCompletion = YES;
    scaleAnimation.byValue  = [NSValue valueWithCGRect:_viewSwitchModeBG.bounds];
    
    //位置偏移动画
    CABasicAnimation *positionAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
    positionAnimation.duration = 0.2f;
    positionAnimation.fromValue = [NSValue valueWithCGPoint:_viewSwitchModeBG.center];
    positionAnimation.toValue = [NSValue valueWithCGPoint:endPoint];
    
    
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.duration = 0.2f;
    animationGroup.autoreverses = NO;
    animationGroup.removedOnCompletion = NO;
    animationGroup.fillMode = kCAFillModeForwards;
    //是否重播，原动画的倒播
    animationGroup.repeatCount = 0;
    animationGroup.delegate = self;
    [animationGroup setValue:@"hideMode" forKey:@"animateType"];
    [animationGroup setAnimations:[NSArray arrayWithObjects: scaleAnimation,positionAnimation, nil]];
    
    [_viewSwitchModeBG.layer addAnimation:animationGroup forKey:@"animationGroup"];
}

//隐藏车位选择模式按钮动画结束
- (void) animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if([[anim valueForKey:@"animateType"]isEqualToString:@"hideMode"])
    {
        self.hidden = YES;
        [self sendSubviewToBack:_controlBG];
        canChangeMode = YES;
        [_viewSwitchModeBG.layer removeAllAnimations];
    }
    if([[anim valueForKey:@"animateType"]isEqualToString:@"showMode"])
    {
        canChangeMode = YES;
        _viewSwitchModeBG.center = ((NSValue *)[anim valueForKey:@"endPoint"]).CGPointValue;
        [_viewSwitchModeBG.layer removeAllAnimations];
    }
}

#pragma  mark ---  界面坐标设置  ---
-  (void) setSwitchModeContentFrame
{
    if(isiPhone)
    {
        if([[ANParamValue sharedInstance] isPath])
        {
            _viewSwitchModeBG.frame = CGRectMake(0, 0, 310.0f, 108.0f);
            
            _buttonNAngel.frame = CGRectMake(0, 0, 70.0f, 60.0f);
            _buttonNAngel.center = CGPointMake(43.5f, 40.5f);
            
            _buttonCarAngel.frame = CGRectMake(0, 0, 70.0f, 60.0f);
            _buttonCarAngel.center = CGPointMake(117.5f, 40.5f);
            
            _button3DAngel.frame = CGRectMake(0, 0, 70.0f, 60.0f);
            _button3DAngel.center = CGPointMake(191.5f, 40.5f);
            
            _buttonHUD.frame = CGRectMake(0, 0, 70.0f, 60.0f);
            _buttonHUD.center = CGPointMake(265.5f, 40.5f);
            
            //label
            _labelNAngel.frame = CGRectMake(0, 0, 70.0f, 35.0f);
            _labelNAngel.center = CGPointMake(43.5f, 86.5);
            _labelNAngel.font = [UIFont systemFontOfSize:15.0f];
            
            _labelCarAngel.frame = CGRectMake(0, 0, 70.0f, 35.0f);
            _labelCarAngel.center = CGPointMake(117.5f, 86.5);
            _labelCarAngel.font = [UIFont systemFontOfSize:15.0f];
            
            _label3DAngel.frame = CGRectMake(0, 0, 70.0f, 35.0f);
            _label3DAngel.center = CGPointMake(191.5f, 86.5);
            _label3DAngel.font = [UIFont systemFontOfSize:15.0f];
            
            _labelnHUD.frame = CGRectMake(0, 0, 70.0f, 35.0f);
            _labelnHUD.center = CGPointMake(265.5f, 86.5);
            _labelnHUD.font = [UIFont systemFontOfSize:15.0f];
        }
        else
        {
            _viewSwitchModeBG.frame = CGRectMake(0, 0, 236.0f, 108.0f);
            
            _buttonNAngel.frame = CGRectMake(0, 0, 70.0f, 60.0f);
            _buttonNAngel.center = CGPointMake(43.5f, 40.5f);
            
            _buttonCarAngel.frame = CGRectMake(0, 0, 70.0f, 60.0f);
            _buttonCarAngel.center = CGPointMake(117.5f, 40.5f);
            
            _button3DAngel.frame = CGRectMake(0, 0, 70.0f, 60.0f);
            _button3DAngel.center = CGPointMake(191.5f, 40.5f);
            
            //label
            _labelNAngel.frame = CGRectMake(0, 0, 70.0f, 35.0f);
            _labelNAngel.center = CGPointMake(43.5f, 86.5);
            _labelNAngel.font = [UIFont systemFontOfSize:15.0f];
            
            _labelCarAngel.frame = CGRectMake(0, 0, 70.0f, 35.0f);
            _labelCarAngel.center = CGPointMake(117.5f, 86.5);
            _labelCarAngel.font = [UIFont systemFontOfSize:15.0f];
            
            _label3DAngel.frame = CGRectMake(0, 0, 70.0f, 35.0f);
            _label3DAngel.center = CGPointMake(191.5f, 86.5);
            _label3DAngel.font = [UIFont systemFontOfSize:15.0f];
        }
    }
    else //ipad
    {
        if([[ANParamValue sharedInstance] isPath])
        {
            _viewSwitchModeBG.frame = CGRectMake(0, 0, 464.0f, 160.0f);
            
            _buttonNAngel.frame = CGRectMake(0, 0, 105.0f, 90.0f);
            _buttonNAngel.center = CGPointMake(65.5f, 60.5);
            
            _buttonCarAngel.frame = CGRectMake(0, 0, 105.0f, 90.0f);
            _buttonCarAngel.center = CGPointMake(176.0f, 60.5);
            
            _button3DAngel.frame = CGRectMake(0, 0, 105.0f, 90.0f);
            _button3DAngel.center = CGPointMake(286.5f, 60.5);
            
            _buttonHUD.frame = CGRectMake(0, 0, 105.0f, 90.0f);
            _buttonHUD.center = CGPointMake(397, 60.5);
            
            //label
            _labelNAngel.frame = CGRectMake(0, 0, 105.0f, 50);
            _labelNAngel.center = CGPointMake(65.5f, 130.0f);
            _labelNAngel.font = [UIFont systemFontOfSize:21.0f];
            
            _labelCarAngel.frame = CGRectMake(0, 0, 105.0f, 50);
            _labelCarAngel.center = CGPointMake(176.0f, 130.0f);
            _labelCarAngel.font = [UIFont systemFontOfSize:21.0f];
            
            _label3DAngel.frame = CGRectMake(0, 0, 105.0f, 50);
            _label3DAngel.center = CGPointMake(286.5f, 130.0f);
            _label3DAngel.font = [UIFont systemFontOfSize:21.0f];
            
            _labelnHUD.frame = CGRectMake(0, 0, 105.0f, 50);
            _labelnHUD.center = CGPointMake(397.0f, 130.0f);
            _labelnHUD.font = [UIFont systemFontOfSize:21.0f];
        }
        else
        {
            _viewSwitchModeBG.frame = CGRectMake(0, 0, 354.0f, 160.0f);
            
            _buttonNAngel.frame = CGRectMake(0, 0, 105.0f, 90.0f);
            _buttonNAngel.center = CGPointMake(65.5f, 60.5);
            
            _buttonCarAngel.frame = CGRectMake(0, 0, 105.0f, 90.0f);
            _buttonCarAngel.center = CGPointMake(176.0f, 60.5);
            
            _button3DAngel.frame = CGRectMake(0, 0, 105.0f, 90.0f);
            _button3DAngel.center = CGPointMake(286.5f, 60.5);
            
            
            //label
            _labelNAngel.frame = CGRectMake(0, 0, 105.0f, 90.0f);
            _labelNAngel.center = CGPointMake(65.5f, 130.0f);
            _labelNAngel.font = [UIFont systemFontOfSize:21.0f];
            
            _labelCarAngel.frame = CGRectMake(0, 0, 105.0f, 90.0f);
            _labelCarAngel.center = CGPointMake(176.0f, 130.0f);
            _labelCarAngel.font = [UIFont systemFontOfSize:21.0f];
            
            _label3DAngel.frame = CGRectMake(0, 0, 105.0f, 90.0f);
            _label3DAngel.center = CGPointMake(286.5f, 130.0f);
            _label3DAngel.font = [UIFont systemFontOfSize:21.0f];
            
        }
        
    }
    
    if(Interface_Flag == 0 || isPad) //竖屏
    {
        _viewSwitchModeBG.center = CGPointMake(_pointAnimate.x + _sizeButton.width / 2 - _viewSwitchModeBG.frame.size.width / 2,
                            _pointAnimate.y + _viewSwitchModeBG.frame.size.height/2 + _sizeButton.height / 2);
    }
    else
    {
        _viewSwitchModeBG.center = CGPointMake(_pointAnimate.x - _sizeButton.width / 2 - _viewSwitchModeBG.frame.size.width / 2,
                            _pointAnimate.y - _sizeButton.height / 2 + _viewSwitchModeBG.frame.size.height/2 );
    }
    _controlBG.frame = CGRectMake(0, 0, SCREENHEIGHT, SCREENHEIGHT);
}

#pragma mark ---  按钮响应函数  ---
- (void) buttonClick:(UIButton *)sender
{
    switch (sender.tag)
    {
        case BUTTON_MODE_NORTH:
        {
            [self setModeSwitch:GMAPVIEW_MODE_NORTH withButton:sender];
        }
            break;
        case BUTTON_MODE_CAR:
        {
            [self setModeSwitch:GMAPVIEW_MODE_CAR withButton:sender];
        }
            break;
        case BUTTON_MODE_3D:
        {
            [self setModeSwitch:GMAPVIEW_MODE_3D withButton:sender];
        }
            break;
        default:
            break;
    }
    
    if(self.mainCarModeClick)
    {
        self.mainCarModeClick(sender);
    }
}

#pragma mark - ---  辅助函数  ---
- (UIButton *)createButtonWithTitle:(NSString *)titleT normalImage:(NSString *)normalImage heightedImage:(NSString *)heightedImage tag:(NSInteger)tagN
{
    UIButton *button = [ControlCreat createButtonWithTitle:titleT normalImage:normalImage heightedImage:heightedImage tag:tagN];
    [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

@end

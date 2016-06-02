//
//  MainBottomMenuObject.m
//  AutoNavi
//
//  Created by jiangshu-fu on 14-8-28.
//
//

#import "MainBottomMenuObject.h"
#import "MainDefine.h"

@implementation MainBottomMenuObject

#define  BOTTOM_BAR_COMMON          @"BOTTOM_BAR_COMMON"        //导航，常用，附近，设置

#define BOTTOM_BAR_FONT       ( isiPhone ? 13 : 18 )

@synthesize bottomMenuBar = _bottomMenuBar;

- (id) init
{
    self = [super init];
    if(self)
    {
        _arrayMenuBarinfo = nil;
        _dictMenuKeyForAppear = nil;
        //初始化视图及数据
        UIImage *image1_1 = IMAGE(@"mainMenuFirst.png", IMAGEPATH_TYPE_2);
        UIImage *image2_1 = IMAGE(@"mainMenuFirstPress.png", IMAGEPATH_TYPE_2);
        UIImage *image1 = [image1_1 stretchableImageWithLeftCapWidth:(image1_1.size.width / 2) topCapHeight:0];
        UIImage *image2 = [image2_1 stretchableImageWithLeftCapWidth:(image2_1.size.width/2) topCapHeight:0];
        UIImage *image3 = [IMAGE(@"mainMenuMiddle.png", IMAGEPATH_TYPE_2)stretchableImageWithLeftCapWidth:7 topCapHeight:0];
        UIImage *image4 = [IMAGE(@"mainMenuMiddlePress.png", IMAGEPATH_TYPE_2) stretchableImageWithLeftCapWidth:7 topCapHeight:0];
        UIImage *image5 = [IMAGE(@"mainMenuLast.png", IMAGEPATH_TYPE_2)stretchableImageWithLeftCapWidth:7 topCapHeight:0];
        UIImage *image6 = [IMAGE(@"mainMenuLastPress.png", IMAGEPATH_TYPE_2)stretchableImageWithLeftCapWidth:7 topCapHeight:0];
        
        NSArray *barImages = [[NSArray alloc]initWithObjects:image1,image2,image3,image4,image5,image6,nil];
        //底栏bar的内容容器
        _bottomMenuBar = [[BottomMenuBar alloc] initWithFrame:CGRectMake(0, 0, 308, 48)
                                             withButtonNumber:4
                                         withButtonBackImages:barImages];
        //底栏按钮坐标设置
        _bottomMenuBar.autoresizesSubviews = YES;
        [barImages release];
        
        _imageViewNew = [[UIImageView alloc] initWithImage:IMAGE(@"main_newPoint.png", IMAGEPATH_TYPE_1)];
        _imageViewNew.hidden = YES;
        [_bottomMenuBar addSubview:_imageViewNew];
        
        _imageViewNewCar = [[UIImageView alloc] initWithImage:IMAGE(@"main_newPoint.png", IMAGEPATH_TYPE_1)];
        _imageViewNewCar.hidden = YES;
        [_bottomMenuBar addSubview:_imageViewNewCar];
        //初始化底栏数据
        [self initMenubarDictionary];
        
        [_bottomMenuBar SetButtonsByInfoes:[_dictMenuKeyForAppear objectForKey:BOTTOM_BAR_COMMON]];
        [_bottomMenuBar setTitleColor:GETSKINCOLOR(MAIN_DAY_BOTTOMMENU_COLOR)   forState:UIControlStateNormal];
    }
    return self;
}

- (void) dealloc
{
    CRELEASE(_arrayMenuBarinfo);
    CRELEASE(_dictMenuKeyForAppear);
    CRELEASE(_bottomMenuBar);
    [super dealloc];
}

#pragma  mark - ---  外部调用接口  ---


/*!
  @brief    设置底部菜单栏是否隐藏
  @param
  @author   by bazinga
  */
- (void) setBottomMenuBarHidden:(BOOL)hidden
{
    _bottomMenuBar.hidden = hidden;
}

/*!
  @brief    设置 设置 按钮是否显示
  @param
  @author   by bazinga
  */
- (void) setSettingNewHidden:(BOOL) hidden
{
    _imageViewNew.hidden = hidden;
}

/*!
  @brief    设置车主服务按钮红点是否显示
  @param
  @author   by bazinga
  */
- (void) setCarNewHidden:(BOOL) hidden
{
    _imageViewNewCar.hidden = hidden;
}
/*!
  @brief    重新加载按钮图片
  @param
  @author   by bazinga
  */
- (void) reloadBottomBarButtonImage
{
    if(Interface_Flag == 0 || !isiPhone)
    {
        UIImage *image1_1 = IMAGE(@"main_bottomMenuNormal.png", IMAGEPATH_TYPE_1);
        UIImage *image2_1 = IMAGE(@"mainMenuPress.png", IMAGEPATH_TYPE_2);
        UIImage *image1 = [image1_1 stretchableImageWithLeftCapWidth:(image1_1.size.width / 2) topCapHeight:0];
        UIImage *image2 = [image2_1 stretchableImageWithLeftCapWidth:(image2_1.size.width/2) topCapHeight:0];
        
        NSArray *barImages = [[NSArray alloc]initWithObjects:image1,image2,image1,image2,image1,image2,nil];
        [_bottomMenuBar setBackImages:barImages];
        [barImages release];
        [_bottomMenuBar setBackgroundImage:IMAGE(@"mainMenu.png", IMAGEPATH_TYPE_2)];
    }
    else
    {
        UIImage *image1_1 = IMAGE(@"main_bottomMenuNormal.png", IMAGEPATH_TYPE_1);
        UIImage *image2_1 = IMAGE(@"mainMenuFirstPress.png", IMAGEPATH_TYPE_2);
        UIImage *image1 = [image1_1 stretchableImageWithLeftCapWidth:(image1_1.size.width / 2) topCapHeight:0];
        UIImage *image2 = [image2_1 stretchableImageWithLeftCapWidth:(image2_1.size.width/2) topCapHeight:0];
        UIImage *image3 = IMAGE(@"main_bottomMenuNormal.png", IMAGEPATH_TYPE_1);
        UIImage *image4 = [IMAGE(@"mainMenuMiddlePress.png", IMAGEPATH_TYPE_2) stretchableImageWithLeftCapWidth:7 topCapHeight:0];
        UIImage *image5 =IMAGE(@"main_bottomMenuNormal.png", IMAGEPATH_TYPE_1);
        UIImage *image6 = [IMAGE(@"mainMenuLastPress.png", IMAGEPATH_TYPE_2)stretchableImageWithLeftCapWidth:7 topCapHeight:0];
        NSArray *barImages = [[NSArray alloc]initWithObjects:image1,image2,image3,image4,image5,image6,nil];
        [_bottomMenuBar setBackImages:barImages];
        [barImages release];
        [_bottomMenuBar setBackgroundImage:IMAGE(@"mainMenuLand.png", IMAGEPATH_TYPE_2)];
    }
    UIImage * image1 = [IMAGE(@"mainNavi.png", IMAGEPATH_TYPE_2) stretchableImageWithLeftCapWidth:7 topCapHeight:0];
    UIImage * image2 = [IMAGE(@"mainNearby.png", IMAGEPATH_TYPE_2)stretchableImageWithLeftCapWidth:7 topCapHeight:0];
    UIImage * image3 = [IMAGE(@"mainCommonUse.png", IMAGEPATH_TYPE_2)stretchableImageWithLeftCapWidth:7 topCapHeight:0];
    UIImage * image4 = [IMAGE(@"mainSetting.png", IMAGEPATH_TYPE_2) stretchableImageWithLeftCapWidth:7 topCapHeight:0];
    NSArray *barImages1 = [[NSArray alloc]initWithObjects:image1,image2,image3,image4,nil];
    [_bottomMenuBar setImages:barImages1 withState:UIControlStateNormal];
    [_bottomMenuBar setImages:barImages1 withState:UIControlStateHighlighted];
    [_bottomMenuBar setImages:barImages1 withState:UIControlStateSelected];
    
    [barImages1 release];
}

/*!
  @brief    重新加载按钮颜色
  @param
  @author   by bazinga
  */
- (void) reloadBottomBarButtonTextColor:(int) type
{
    if(type == 1)
    {
        [_bottomMenuBar setTitleColor:GETSKINCOLOR(MAIN_NIGHT_BOTTOMMENU_COLOR) forState:UIControlStateNormal];
    }
    else
    {
        [_bottomMenuBar setTitleColor:GETSKINCOLOR(MAIN_DAY_BOTTOMMENU_COLOR) forState:UIControlStateNormal];
    }
}

/*!
  @brief    中英文切换文字
  @param
  @author   by bazinga
  */
- (void) reloadBottomText
{
    NSArray *tempArray = [_bottomMenuBar getButtonArray];
    [((UIButton *)[tempArray objectAtIndex:0]) setTitle:STR(@"Main_mainNavi", Localize_Main)
                                               forState:UIControlStateNormal];
    [((UIButton *)[tempArray objectAtIndex:1]) setTitle:STR(@"Main_mainNearby", Localize_Main)
     
                                               forState:UIControlStateNormal];
    
    [((UIButton *)[tempArray objectAtIndex:2]) setTitle:STR(@"Main_mainCommonUse", Localize_Main)
     
                                               forState:UIControlStateNormal];
    [((UIButton *)[tempArray objectAtIndex:3]) setTitle:STR(@"Main_mainSetting", Localize_Main)
                                               forState:UIControlStateNormal];
}
#pragma mark -
#pragma mark ---  底栏数据的填充  ---


//底栏的各种状态
//#define  BOTTOM_BAR_CRUISE          @"BOTTOM_BAR_CRUISE"        //去哪儿，周边，常用，更多
//#define  BOTTOM_BAR_CRUISE_MOVE     @"BOTTOM_BAR_CRUISE_MOVE"   //回车位，设终点，设起点，周边
//#define  BOTTOM_BAR_NAVI_MOVE       @"BOTTOM_BAR_NAVI_MOVE"     //回车位，设终点，加途经点，周边
- (void) initMenubarDictionary
{
    
    [self menuBarDataArray];
    if(_dictMenuKeyForAppear)
    {
        [_dictMenuKeyForAppear release] ;
        _dictMenuKeyForAppear = nil;
    }
    _dictMenuKeyForAppear = [[NSMutableDictionary alloc] init];
    //一般状态
    if(_arrayMenuBarinfo && _arrayMenuBarinfo.count >= 4)
    {
        [_dictMenuKeyForAppear setObject:[[[NSArray alloc]initWithObjects:[_arrayMenuBarinfo objectAtIndex:0],
                                           [_arrayMenuBarinfo objectAtIndex:1],
                                           [_arrayMenuBarinfo objectAtIndex:2],
                                           [_arrayMenuBarinfo objectAtIndex:3],nil]autorelease]
                                  forKey:BOTTOM_BAR_COMMON];
    }
}

- (void) menuBarDataArray
{
    if(_arrayMenuBarinfo)
    {
        [_arrayMenuBarinfo release] ;
        _arrayMenuBarinfo = nil;
    }
    _arrayMenuBarinfo = [[NSMutableArray alloc] init];
    //导航 - 0
    [_arrayMenuBarinfo addObject:[self addMenuBarData:@"mainNavi" withTag:BUTTON_SEARCH ]];
    //附近 - 1
    [_arrayMenuBarinfo addObject:[self addMenuBarData:@"mainNearby" withTag:BUTTON_NEARBY ]];
    //常用 - 2
    [_arrayMenuBarinfo addObject:[self addMenuBarData:@"mainCommonUse" withTag:BUTTON_COMMON ]];
    //设置 - 3
    [_arrayMenuBarinfo addObject:[self addMenuBarData:@"mainSetting" withTag:BUTTON_MORE ]];
}

- (BottomMenuInfo *) addMenuBarData : (NSString *)nameInfo withTag:(int) tag
{
    BottomMenuInfo *menuInfo = [[[BottomMenuInfo alloc] init] autorelease];
    NSString *titleString = [NSString stringWithFormat:@"Main_%@",nameInfo];
    NSString *imageString = [NSString stringWithFormat:@"%@.png",nameInfo];
    NSString *highlightedIamgeString = [NSString stringWithFormat:@"%@.png",nameInfo];
    menuInfo.title = STR(titleString, Localize_Main);
    menuInfo.image = IMAGE(imageString, IMAGEPATH_TYPE_2);
    menuInfo.highlightedImage = IMAGE(highlightedIamgeString, IMAGEPATH_TYPE_2);
    menuInfo.tag = tag;
    __block MainBottomMenuObject *blockSelf = self;
    menuInfo.buttonPress = ^(id sender){
        if(blockSelf.bottomMenuClick)
        {
            blockSelf.bottomMenuClick(sender);
        }
    };
    return  menuInfo;
}

/*!
  @brief    设置低栏四个按钮的位置
  @param
  @author   by bazinga
  */
- (void) setRealBottomButtonFrame
{
    NSLog(@"setBottomButtonFrame------------");
    [self reloadBottomBarButtonImage];
    if(Interface_Flag == 0)
    {
        if(isiPhone)//iphone 竖屏
        {
            //底栏按钮坐标设置 //导航，常用，附近，设置
            [_bottomMenuBar setFrame:CGRectMake(0, 0, MAIN_POR_WIDTH, CONFIG_CRUISE_BOTTOM_HEIGHT)];
            [_bottomMenuBar setCenter:CGPointMake(MAIN_POR_WIDTH / 2, MAIN_POR_HEIGHT - _bottomMenuBar.frame.size.height / 2)];
            
            [_bottomMenuBar bringSubviewToFront:_imageViewNew];
            _imageViewNew.center = CGPointMake(_bottomMenuBar.frame.size.width - _imageViewNew.frame.size.width / 2 - 4, _imageViewNew.frame.size.height / 2 + 4);
            
            [_bottomMenuBar bringSubviewToFront:_imageViewNewCar];
            _imageViewNewCar.center = CGPointMake(_bottomMenuBar.frame.size.width * 3 / 4 - _imageViewNew.frame.size.width / 2 - 4 , _imageViewNew.frame.size.height / 2 + 4);
            
            float height = _bottomMenuBar.frame.size.height;
            if(fontType == 2)
            {
                _bottomMenuBar.textOffsetValue = 0;
                _bottomMenuBar.textWidth = [_bottomMenuBar buttonWidth] * 5.5 / 9 + 4;
                [_bottomMenuBar setTextAlignment:NSTextAlignmentCenter];
                [_bottomMenuBar setTitleFont:[UIFont systemFontOfSize:BOTTOM_BAR_FONT]];
                
                
                //设置菜单栏的坐标
                NSMutableArray *bottomMenuArray = [_bottomMenuBar getButtonArray];
                for (int i = 0; i < bottomMenuArray.count; i++)
                {
                    BottomButton * button  = (BottomButton *)[bottomMenuArray objectAtIndex:i];
                    float tempTextRightValue = 0;
                    CGRect tempImageRect = CGRectMake(0, 0, 0, 0);
                    if(i == 0)
                    {
                        tempTextRightValue =  [_bottomMenuBar buttonWidth]* 3 / 9 ;
                        tempImageRect =  CGRectMake( [_bottomMenuBar buttonWidth]* 3 / 9 - 18.0f, (height - 20.0f) / 2, 20.0f , 20.0f);
                    }
                    else if(i == 1)
                    {
                        tempTextRightValue =  [_bottomMenuBar buttonWidth]* 3 / 9 - 2;
                        tempImageRect =  CGRectMake( [_bottomMenuBar buttonWidth]* 3 / 9 - 18.0f - 4, (height - 20.0f) / 2, 20.0f , 20.0f);
                    }
                    else if(i == 2)
                    {
                        tempTextRightValue =  [_bottomMenuBar buttonWidth]* 3 / 9;
                        tempImageRect =  CGRectMake( [_bottomMenuBar buttonWidth]* 3 / 9 - 18.0f , (height - 20.0f) / 2, 20.0f , 20.0f);
                    }
                    else if(i == 3)
                    {
                        tempTextRightValue =  [_bottomMenuBar buttonWidth]* 3 / 9 - 6;
                        tempImageRect =  CGRectMake( [_bottomMenuBar buttonWidth]* 3 / 9 - 18.0f - 5.0f, (height - 20.0f) / 2, 20.0f , 20.0f);
                    }
                    button.textRightsetValue = tempTextRightValue;
                    button.imageRect = tempImageRect;
                    [button setNeedsLayout];
                }
            }
            else
            {
                _bottomMenuBar.textOffsetValue = 0;
                _bottomMenuBar.textWidth = [_bottomMenuBar buttonWidth] * 4.5 / 9;
                [_bottomMenuBar setTextAlignment:NSTextAlignmentLeft];
                [_bottomMenuBar setTitleFont:[UIFont systemFontOfSize:BOTTOM_BAR_FONT]];
                
                //设置菜单栏的坐标
                NSMutableArray *bottomMenuArray = [_bottomMenuBar getButtonArray];
                for (int i = 0; i < bottomMenuArray.count; i++)
                {
                    BottomButton * button  = (BottomButton *)[bottomMenuArray objectAtIndex:i];
                    float tempTextRightValue = 0;
                    CGRect tempImageRect = CGRectMake(0, 0, 0, 0);
                    if(i == 0)
                    {
                        tempTextRightValue =  [_bottomMenuBar buttonWidth]* 4 / 9 + 3;
                        tempImageRect =  CGRectMake( [_bottomMenuBar buttonWidth]* 4 / 9 - 20.0f, (height - 20.0f) / 2, 20.0f , 20.0f);
                    }
                    else if(i == 1)
                    {
                        tempTextRightValue =  [_bottomMenuBar buttonWidth]* 4 / 9 + 4;
                        tempImageRect =  CGRectMake( [_bottomMenuBar buttonWidth]* 4 / 9 - 23.0f + 4, (height - 20.0f) / 2, 20.0f , 20.0f);
                    }
                    else if(i == 2)
                    {
                        tempTextRightValue =  [_bottomMenuBar buttonWidth]* 4 / 9 + 2;
                        tempImageRect =  CGRectMake( [_bottomMenuBar buttonWidth]* 4 / 9 - 23.0f + 2, (height - 20.0f) / 2, 20.0f , 20.0f);
                    }
                    else if(i == 3)
                    {
                        tempTextRightValue =  [_bottomMenuBar buttonWidth]* 4 / 9 + 1;
                        tempImageRect =  CGRectMake( [_bottomMenuBar buttonWidth]* 4 / 9 - 23.0f + 1, (height - 20.0f) / 2, 20.0f , 20.0f);
                    }
                    button.textRightsetValue = tempTextRightValue;
                    button.imageRect = tempImageRect;
                    [button setNeedsLayout];
                }
                
            }
            
        }
        else
        {
            //底栏按钮坐标设置 //导航，常用，附近，设置
            [_bottomMenuBar setFrame:CGRectMake(0, 0, MAIN_POR_WIDTH, CONFIG_CRUISE_BOTTOM_HEIGHT)];
            [_bottomMenuBar setCenter:CGPointMake(MAIN_POR_WIDTH / 2, MAIN_POR_HEIGHT - _bottomMenuBar.frame.size.height / 2)];
            
            [_bottomMenuBar bringSubviewToFront:_imageViewNew];
            _imageViewNew.center = CGPointMake(_bottomMenuBar.frame.size.width - _imageViewNew.frame.size.width / 2 - 45.0f, _imageViewNew.frame.size.height / 2 + 12.0f);
            
            [_bottomMenuBar bringSubviewToFront:_imageViewNewCar];
            _imageViewNewCar.center = CGPointMake(_bottomMenuBar.frame.size.width * 3 / 4 - _imageViewNew.frame.size.width / 2 - 45.0f, _imageViewNew.frame.size.height / 2 + 12.0f);
            
            float height = _bottomMenuBar.frame.size.height;
            _bottomMenuBar.textOffsetValue = 0;
            _bottomMenuBar.textWidth = [_bottomMenuBar buttonWidth] * 4.5 / 9;
            [_bottomMenuBar setTextAlignment:NSTextAlignmentLeft];
            [_bottomMenuBar setTitleFont:[UIFont systemFontOfSize:BOTTOM_BAR_FONT]];
            
            
            //设置菜单栏的坐标
            NSMutableArray *bottomMenuArray = [_bottomMenuBar getButtonArray];
            if(fontType == 2)
            {
                for (int i = 0; i < bottomMenuArray.count; i++)
                {
                    BottomButton * tempbutton  = (BottomButton *)[bottomMenuArray objectAtIndex:i];
                    float tempTextRightValue = 0;
                    CGRect tempImageRect = CGRectMake(0, 0, 0, 0);
                    if(i == 0)
                    {
                        tempTextRightValue = [_bottomMenuBar buttonWidth]* 4 / 9 ;
                        tempImageRect =  CGRectMake( [_bottomMenuBar buttonWidth]* 4 / 9 - 35.0f, (height - 30.0f) / 2, 30.0f , 30.0f);
                    }
                    else if(i == 1)
                    {
                        tempTextRightValue = [_bottomMenuBar buttonWidth]* 4 / 9 - 7;
                        tempImageRect =  CGRectMake( [_bottomMenuBar buttonWidth]* 4 / 9 - 35.0f - 7, (height - 30.0f) / 2, 30.0f , 30.0f);
                    }
                    else if(i == 2)
                    {
                        tempTextRightValue = [_bottomMenuBar buttonWidth]* 4 / 9 - 3;
                        tempImageRect =  CGRectMake( [_bottomMenuBar buttonWidth]* 4 / 9 - 35.0f - 3, (height - 30.0f) / 2, 30.0f , 30.0f);
                    }
                    else if(i == 3)
                    {
                        tempTextRightValue = [_bottomMenuBar buttonWidth]* 4 / 9 - 8;
                        tempImageRect =  CGRectMake( [_bottomMenuBar buttonWidth]* 4 / 9 - 35.0f - 8, (height - 30.0f) / 2, 30.0f , 30.0f);
                    }
                    tempbutton.textRightsetValue = tempTextRightValue;
                    tempbutton.imageRect = tempImageRect;
                    [tempbutton setNeedsLayout];
                }
            }
            else
            {
                for (int i = 0; i < bottomMenuArray.count; i++)
                {
                    BottomButton * tempbutton  = (BottomButton *)[bottomMenuArray objectAtIndex:i];
                    float tempTextRightValue = 0;
                    CGRect tempImageRect = CGRectMake(0, 0, 0, 0);
                    if(i == 0)
                    {
                        tempTextRightValue = [_bottomMenuBar buttonWidth]* 4 / 9 + 10;
                        tempImageRect =  CGRectMake( [_bottomMenuBar buttonWidth]* 4 / 9 - 35.0f + 10, (height - 30.0f) / 2, 30.0f , 30.0f);
                    }
                    else if(i == 1)
                    {
                        tempTextRightValue = [_bottomMenuBar buttonWidth]* 4 / 9 + 9;
                        tempImageRect =  CGRectMake( [_bottomMenuBar buttonWidth]* 4 / 9 - 35.0f + 9, (height - 30.0f) / 2, 30.0f , 30.0f);
                    }
                    else if(i == 2)
                    {
                        tempTextRightValue = [_bottomMenuBar buttonWidth]* 4 / 9 + 7;
                        tempImageRect =  CGRectMake( [_bottomMenuBar buttonWidth]* 4 / 9 - 35.0f + 7, (height - 30.0f) / 2, 30.0f , 30.0f);
                    }
                    else if(i == 3)
                    {
                        tempTextRightValue = [_bottomMenuBar buttonWidth]* 4 / 9 + 6;
                        tempImageRect =  CGRectMake( [_bottomMenuBar buttonWidth]* 4 / 9 - 35.0f + 6, (height - 30.0f) / 2, 30.0f , 30.0f);
                    }
                    tempbutton.textRightsetValue = tempTextRightValue;
                    tempbutton.imageRect = tempImageRect;
                    [tempbutton setNeedsLayout];
                }
            }
            
        }
    }
    else
    {
        
        if(isiPhone)//iphone 横屏
        {
            CGFloat barWidth = MAIN_LAND_WIDTH - 6 * CONFIG_BUTTON_SAPCE - 4 * CONFIG_BUTTON_NORMAL_WIDTH;
            //底栏按钮坐标设置
            [_bottomMenuBar setFrame:CGRectMake(0, 0, barWidth, CONFIG_CRUISE_BOTTOM_HEIGHT)];
            [_bottomMenuBar setCenter:CGPointMake(MAIN_LAND_WIDTH / 2, MAIN_LAND_HEIGHT  - CONFIG_BUTTON_SAPCE - CONFIG_CRUISE_BOTTOM_HEIGHT / 2)];
            
            [_bottomMenuBar bringSubviewToFront:_imageViewNew];
            _imageViewNew.center = CGPointMake(_bottomMenuBar.frame.size.width - _imageViewNew.frame.size.width / 2 - 16, _imageViewNew.frame.size.height / 2 + 4);
            
            [_bottomMenuBar bringSubviewToFront:_imageViewNewCar];
            _imageViewNewCar.center = CGPointMake(_bottomMenuBar.frame.size.width * 3 / 4 - _imageViewNew.frame.size.width / 2 , _imageViewNew.frame.size.height / 2 + 4);
            
            float height = _bottomMenuBar.frame.size.height;
            _bottomMenuBar.textOffsetValue = 0;
            [_bottomMenuBar setTextAlignment:NSTextAlignmentLeft];
            [_bottomMenuBar setTitleFont:[UIFont systemFontOfSize:BOTTOM_BAR_FONT]];
            _bottomMenuBar.textWidth = [_bottomMenuBar buttonWidth] * 4.5 / 9 + 5;
            
            //设置菜单栏的坐标
            NSMutableArray *bottomMenuArray = [_bottomMenuBar getButtonArray];
            if(fontType == 2)
            {
                [_bottomMenuBar setTitleFont:[UIFont systemFontOfSize: (iPhone4 ? 10.0f : BOTTOM_BAR_FONT)]];
                for (int i = 0; i < bottomMenuArray.count; i++)
                {
                    BottomButton * tempbutton  = (BottomButton *)[bottomMenuArray objectAtIndex:i];
                    float tempTextRightValue = 0;
                    CGRect tempImageRect = CGRectMake(0, 0, 0, 0);
                    if(i == 0)
                    {
                        tempTextRightValue = [_bottomMenuBar buttonWidth]* 4 / 9 + 4;
                        tempImageRect =  CGRectMake( [_bottomMenuBar buttonWidth]* 4 / 9 - 19.0f, (height - 20.0f) / 2, 20.0f , 20.0f);
                    }
                    else if(i == 1)
                    {
                        tempTextRightValue = [_bottomMenuBar buttonWidth]* 4 / 9 -  5 + 1;
                        tempImageRect =  CGRectMake( [_bottomMenuBar buttonWidth]* 4 / 9 - 28.0f - 1, (height - 20.0f) / 2, 20.0f , 20.0f);
                    }
                    else if(i == 2)
                    {
                        tempTextRightValue = [_bottomMenuBar buttonWidth]* 4 / 9 + 4 ;
                        tempImageRect =  CGRectMake( [_bottomMenuBar buttonWidth]* 4 / 9 - 19.0f, (height - 20.0f) / 2, 20.0f , 20.0f);
                    }
                    else if(i == 3)
                    {
                        tempTextRightValue = [_bottomMenuBar buttonWidth]* 4 / 9 -  7;
                        tempImageRect =  CGRectMake( [_bottomMenuBar buttonWidth]* 4 / 9 - 30.0f,
                                                    (height - 20.0f) / 2,
                                                    20.0f ,
                                                    20.0f);
                    }
                    tempbutton.textRightsetValue = tempTextRightValue;
                    tempbutton.imageRect = tempImageRect;
                    [tempbutton setNeedsLayout];
                }
            }
            else
            {
                for (int i = 0; i < bottomMenuArray.count; i++)
                {
                    BottomButton * tempbutton  = (BottomButton *)[bottomMenuArray objectAtIndex:i];
                    float tempTextRightValue = 0;
                    CGRect tempImageRect = CGRectMake(0, 0, 0, 0);
                    if(i == 0)
                    {
                        tempTextRightValue = [_bottomMenuBar buttonWidth]* 4 / 9 + 7 ;
                        tempImageRect =  CGRectMake( [_bottomMenuBar buttonWidth]* 4 / 9 - 23.0f + 7, (height - 20.0f) / 2, 20.0f , 20.0f);
                    }
                    else if(i == 1)
                    {
                        tempTextRightValue = [_bottomMenuBar buttonWidth]* 4 / 9 -  5 + 11.5 - (iPhone5 ? 0 : 1.5 );
                        tempImageRect =  CGRectMake( [_bottomMenuBar buttonWidth]* 4 / 9 - 28.0f + 11.5 - (iPhone5 ? 0 : 1.5 ), (height - 20.0f) / 2, 20.0f , 20.0f);
                    }
                    else if(i == 2)
                    {
                        tempTextRightValue = [_bottomMenuBar buttonWidth]* 4 / 9 -  3 + 10 - (iPhone5 ? 0 : 3 );
                        tempImageRect =  CGRectMake( [_bottomMenuBar buttonWidth]* 4 / 9 - 26.0f + 10 - (iPhone5 ? 0 : 3 ), (height - 20.0f) / 2, 20.0f , 20.0f);
                    }
                    else if(i == 3)
                    {
                        tempTextRightValue = [_bottomMenuBar buttonWidth]* 4 / 9 -  5 + 10 - (iPhone5 ? 0 : 1.5 );
                        tempImageRect =  CGRectMake( [_bottomMenuBar buttonWidth]* 4 / 9 - 28.0f + 10 - (iPhone5 ? 0 : 1.5 ), (height - 20.0f) / 2, 20.0f , 20.0f);
                    }
                    tempbutton.textRightsetValue = tempTextRightValue;
                    tempbutton.imageRect = tempImageRect;
                    [tempbutton setNeedsLayout];
                }
            }
            
        }
        else
        {
            //底栏按钮坐标设置 //导航，常用，附近，设置
            [_bottomMenuBar setFrame:CGRectMake(0, 0, MAIN_LAND_WIDTH, CONFIG_CRUISE_BOTTOM_HEIGHT)];
            [_bottomMenuBar setCenter:CGPointMake(MAIN_LAND_WIDTH / 2, MAIN_LAND_HEIGHT - _bottomMenuBar.frame.size.height / 2)];
            
            [_bottomMenuBar bringSubviewToFront:_imageViewNew];
            _imageViewNew.center = CGPointMake(_bottomMenuBar.frame.size.width - _imageViewNew.frame.size.width / 2 - 55.0f, _imageViewNew.frame.size.height / 2 + 12.0f);
            
            [_bottomMenuBar bringSubviewToFront:_imageViewNewCar];
            _imageViewNewCar.center = CGPointMake(_bottomMenuBar.frame.size.width * 3 / 4 - _imageViewNew.frame.size.width / 2 - 55.0f, _imageViewNew.frame.size.height / 2 + 12.0f);
            
            float height = _bottomMenuBar.frame.size.height;
            _bottomMenuBar.textOffsetValue = 0;
            _bottomMenuBar.textWidth = [_bottomMenuBar buttonWidth] * 4.5 / 9;
            [_bottomMenuBar setTextAlignment:NSTextAlignmentLeft];
            [_bottomMenuBar setTitleFont:[UIFont systemFontOfSize:BOTTOM_BAR_FONT]];
            
            //设置菜单栏的坐标
            NSMutableArray *bottomMenuArray = [_bottomMenuBar getButtonArray];
            if(fontType == 2)
            {
                for (int i = 0; i < bottomMenuArray.count; i++)
                {
                    BottomButton * tempbutton  = (BottomButton *)[bottomMenuArray objectAtIndex:i];
                    float tempTextRightValue = 0;
                    CGRect tempImageRect = CGRectMake(0, 0, 0, 0);
                    if(i == 0)
                    {
                        tempTextRightValue = [_bottomMenuBar buttonWidth]* 4 / 9 + 3 ;
                        tempImageRect =  CGRectMake( [_bottomMenuBar buttonWidth]* 4 / 9 - 35.0f + 3, (height - 30.0f) / 2, 30.0f , 30.0f);
                    }
                    else if(i == 1)
                    {
                        tempTextRightValue = [_bottomMenuBar buttonWidth]* 4 / 9 - 4 ;
                        tempImageRect =  CGRectMake( [_bottomMenuBar buttonWidth]* 4 / 9 - 35.0f - 4, (height - 30.0f) / 2, 30.0f , 30.0f);
                    }
                    else if(i == 2)
                    {
                        tempTextRightValue = [_bottomMenuBar buttonWidth]* 4 / 9 + 1;
                        tempImageRect =  CGRectMake( [_bottomMenuBar buttonWidth]* 4 / 9 - 35.0f + 1, (height - 30.0f) / 2, 30.0f , 30.0f);
                    }
                    else if(i == 3)
                    {
                        tempTextRightValue = [_bottomMenuBar buttonWidth]* 4 / 9 - 5;
                        tempImageRect =  CGRectMake( [_bottomMenuBar buttonWidth]* 4 / 9 - 35.0f - 5, (height - 30.0f) / 2, 30.0f , 30.0f);
                    }
                    tempbutton.textRightsetValue = tempTextRightValue;
                    tempbutton.imageRect = tempImageRect;
                    [tempbutton setNeedsLayout];
                }
            }
            else
            {
                for (int i = 0; i < bottomMenuArray.count; i++)
                {
                    BottomButton * tempbutton  = (BottomButton *)[bottomMenuArray objectAtIndex:i];
                    float tempTextRightValue = 0;
                    CGRect tempImageRect = CGRectMake(0, 0, 0, 0);
                    if(i == 0)
                    {
                        tempTextRightValue = [_bottomMenuBar buttonWidth]* 4 / 9 + 12 ;
                        tempImageRect =  CGRectMake( [_bottomMenuBar buttonWidth]* 4 / 9 - 35.0f + 12, (height - 30.0f) / 2, 30.0f , 30.0f);
                    }
                    else if(i == 1)
                    {
                        tempTextRightValue = [_bottomMenuBar buttonWidth]* 4 / 9 + 14 ;
                        tempImageRect =  CGRectMake( [_bottomMenuBar buttonWidth]* 4 / 9 - 35.0f + 14, (height - 30.0f) / 2, 30.0f , 30.0f);
                    }
                    else if(i == 2)
                    {
                        tempTextRightValue = [_bottomMenuBar buttonWidth]* 4 / 9 + 10;
                        tempImageRect = CGRectMake( [_bottomMenuBar buttonWidth]* 4 / 9 - 35.0f + 10, (height - 30.0f) / 2, 30.0f , 30.0f);
                    }
                    else if(i == 3)
                    {
                        tempTextRightValue = [_bottomMenuBar buttonWidth]* 4 / 9 + 10;
                        tempImageRect =  CGRectMake( [_bottomMenuBar buttonWidth]* 4 / 9 - 35.0f + 10, (height - 30.0f) / 2, 30.0f , 30.0f);
                    }
                    tempbutton.textRightsetValue = tempTextRightValue;
                    tempbutton.imageRect = tempImageRect;
                    [tempbutton setNeedsLayout];
                }
            }
        }
    }
}

@end

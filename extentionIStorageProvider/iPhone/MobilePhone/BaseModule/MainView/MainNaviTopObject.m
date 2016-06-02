//
//  MainNaviTopObject.m
//  AutoNavi
//
//  Created by bazinga on 14-9-2.
//  Copyright (c) 2014年 bazinga. All rights reserved.
//

#import "MainNaviTopObject.h"


@implementation MainNaviTopObject

@synthesize  imageViewNaviTopBG = _imageViewNaviTopBG;
@synthesize  imageDirectAndDistance  = _imageDirectAndDistance;

@synthesize handleTap = _handleTap;
@synthesize handleSwipe = _handleSwipe;

- (id) init
{
    self = [super init];
    if(self)
    {
        [self setNaviTopView];
        [self setTopFrame];
    }
    return self;
}

- (void) dealloc
{
    CRELEASE(_imageViewNaviTopBG);
    CRELEASE(_imageDirectAndDistance);
    CRELEASE(_handleTap);
    CRELEASE(_handleSwipe);
    [super dealloc];
}

/***
 * @name    设置导航时，顶部部分的视图界面
 * @param
 * @author  by bazinga
 ***/
- (void)setNaviTopView
{
    
    //导航的上下的底 —— 前方道路 & 无名道路（长方形的部分）
    _imageViewNaviTopBG = [[UIImageView alloc]init];
    _imageViewNaviTopBG.backgroundColor = GETSKINCOLOR(ROUTE_BLACK_TOP_BAR_COLOR);
    _imageViewNaviTopBG.userInteractionEnabled = YES;
    
    
    _imageRight = [[UIImageView alloc] init];
    _imageRight.image = IMAGE(@"shareRightArrow.png", IMAGEPATH_TYPE_1);
    [_imageViewNaviTopBG addSubview:_imageRight];
    //导航状态下，顶部的东西
    _labelQianfang  = [MainControlCreate createLabelWithText:STR(@"Mian_forward", Localize_Main)
                                                    fontSize:15
                                               textAlignment:NSTextAlignmentLeft];
    _labelQianfang.textColor = [UIColor grayColor];
    [_labelQianfang setFrame:CGRectMake(72.0f, 0.0f, 248, 23)];
    [_imageViewNaviTopBG addSubview:_labelQianfang];
    //进入
    _labelEnter = [MainControlCreate  createLabelWithText:STR(@"Main_Enter", Localize_Main)
                                    fontSize:12.0f
                               textAlignment:NSTextAlignmentCenter];
    [_imageViewNaviTopBG addSubview:_labelEnter];
    _labelEnter.textColor = [UIColor grayColor];
    
    //下一道路名－移动文字
	_labelNextRoad = [[[MoveTextLable alloc] initLabelWithText:STR(@"Main_unNameRoad", Localize_Main)
                                                      fontSize:20.0f
                                                 textAlignment:UITextAlignmentCenter] autorelease];
	_labelNextRoad.textColor = GETSKINCOLOR(MAIN_NEXTLROAD_COLOR);
    [_imageViewNaviTopBG addSubview:_labelNextRoad];
    _labelNextRoad.textAlignment = NSTextAlignmentCenter;
    _labelNextRoad.userInteractionEnabled = YES;
    
    
    //顶部的底 -- 转向箭头和距离 (大块正方形)
    _imageDirectAndDistance = [[UIImageView alloc]init];
    _imageDirectAndDistance.backgroundColor = GETSKINCOLOR(ROUTE_BLACK_TOP_BAR_COLOR);
    _imageDirectAndDistance.userInteractionEnabled = YES;
    //下一个路口的转向图标
	_buttonLeftDirect = [[UIImageView alloc]init];
	[_imageDirectAndDistance addSubview:_buttonLeftDirect];
    [_buttonLeftDirect release];
    //方向标－下个路口的距离
	_labelLeft = [MainControlCreate createLabelWithText:@"0km"
                                               fontSize:17.0f
                                          textAlignment:UITextAlignmentCenter];
    _labelLeft.textColor = GETSKINCOLOR(LEFTROAD_LABEL_COLOR);
    _labelLeft.adjustsFontSizeToFitWidth = YES;
	[_imageDirectAndDistance addSubview:_labelLeft];
    
    //添加手势
    UISwipeGestureRecognizer *recognizer;
    recognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeFrom:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [_imageViewNaviTopBG addGestureRecognizer:recognizer];
    [recognizer release];
    
    recognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeFrom:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [_imageDirectAndDistance addGestureRecognizer:recognizer];
    [recognizer release];
    
    recognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeFrom:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [_imageViewNaviTopBG addGestureRecognizer:recognizer];
    [recognizer release];
    
    recognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeFrom:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [_imageDirectAndDistance addGestureRecognizer:recognizer];
    [recognizer release];
    
    
    //点击手势
    UITapGestureRecognizer *tap;
    tap = [[UITapGestureRecognizer alloc]initWithTarget:self  action:@selector(handleTapFrom:)];
    [_imageViewNaviTopBG addGestureRecognizer:tap];
    [tap release];
    
}


- (void) setTopFrame
{
    float englishHeight = fontType == 2 ? (isiPhone ? 5:5) : 0 ;
    
    if(Interface_Flag == 0)
    {
        if (isiPhone)
        {
            
            _labelNextRoad.font = [UIFont boldSystemFontOfSize:24.0f];
            _labelQianfang.font = [UIFont boldSystemFontOfSize:23.0f];
            _labelQianfang.textAlignment = NSTextAlignmentRight;
            _labelEnter.font = [UIFont systemFontOfSize:15.0f];
            CGSize enterSize = [_labelEnter.text sizeWithFont:_labelEnter.font];
            CGSize nextRoadSize = [_labelNextRoad.text sizeWithFont:_labelNextRoad.font];
            //导航顶部的半透明条
            [_imageViewNaviTopBG setFrame:CGRectMake(0, 0, MAIN_POR_WIDTH - 103, CONFIG_NAVI_TOP_NAME_HEIGHT)];
            [_imageViewNaviTopBG setCenter:CGPointMake((MAIN_POR_WIDTH - 103)/ 2 + 103,
                                                       _imageViewNaviTopBG.frame.size.height / 2 )];
            
            [_labelEnter setFrame:CGRectMake(0, 0, enterSize.width + 2, enterSize.height + 2)];
            
            [_labelQianfang setFrame:CGRectMake(0.0f, DIFFENT_STATUS_HEIGHT + 15, MAIN_POR_WIDTH - 103 - 37.0f, 26 + englishHeight)];
            float maxNextRoadWidth = _imageViewNaviTopBG.frame.size.width - 37.0f - _labelEnter.frame.size.width - 20.0f;
            nextRoadSize.width = (nextRoadSize.width > maxNextRoadWidth) ? maxNextRoadWidth : nextRoadSize.width;
            [_labelNextRoad setFrame:CGRectMake(_imageViewNaviTopBG.frame.size.width - nextRoadSize.width - 37.0f,
                                                42.0f + DIFFENT_STATUS_HEIGHT,
                                                nextRoadSize.width,
                                                25  + englishHeight)];
            float enterY = _labelNextRoad.frame.origin.x - 10.0f - _labelEnter.frame.size.width/2;
            [_labelEnter setCenter:CGPointMake(enterY, DIFFENT_STATUS_HEIGHT + 56.0f + englishHeight)];
            
            
            [_imageRight setFrame:CGRectMake(0.0f, 0.0f, 5.0f, 10.0f)];
            [_imageRight setCenter:CGPointMake(_imageViewNaviTopBG.frame.size.width - 7.0f,
                                               _imageViewNaviTopBG.frame.size.height / 2 + DIFFENT_STATUS_HEIGHT/2)];
            
            [_imageDirectAndDistance setFrame:CGRectMake(0.0f, 0.0f, 103.0f, CONFIG_NAVI_TOP_DIRE_HEIGHT)];
            [_labelLeft setFrame:CGRectMake(0.0f, 59.0f + DIFFENT_STATUS_HEIGHT, 103.0f, 26.0f)];
            _labelLeft.font = [UIFont boldSystemFontOfSize:20.0f];
            [_buttonLeftDirect setFrame:CGRectMake(0.0f, 0.0f, 61.0f,61.0f)];
            [_buttonLeftDirect setCenter:CGPointMake(103.0f/2 ,
                                                     _buttonLeftDirect.frame.size.height/2+ DIFFENT_STATUS_HEIGHT)];
        }
        else
        {
            
            _labelNextRoad.font = [UIFont boldSystemFontOfSize:45.0f];
            _labelQianfang.font = [UIFont systemFontOfSize:43.0f];
            _labelQianfang.textAlignment = NSTextAlignmentRight;
            _labelEnter.font = [UIFont systemFontOfSize:23.0f];
            CGSize enterSize = [_labelEnter.text sizeWithFont:_labelEnter.font];
            CGSize nextRoadSize = [_labelNextRoad.text sizeWithFont:_labelNextRoad.font];
            //导航顶部的半透明条
            [_imageViewNaviTopBG setFrame:CGRectMake(0, 0, MAIN_POR_WIDTH - 134.0f, CONFIG_NAVI_TOP_NAME_HEIGHT)];
            [_imageViewNaviTopBG setCenter:CGPointMake((MAIN_POR_WIDTH - 134.0f)/ 2 + 134.0f,
                                                       _imageViewNaviTopBG.frame.size.height / 2 )];
            
            [_labelEnter setFrame:CGRectMake(0, 0, enterSize.width + 2, enterSize.height + 2)];
            
            [_labelQianfang setFrame:CGRectMake(0.0f, DIFFENT_STATUS_HEIGHT + 20, MAIN_POR_WIDTH - 134.0f - 100.0f, 45.0f + englishHeight)];
            
            float maxWidth =  _imageViewNaviTopBG.frame.size.width  - 100.0f - _labelEnter.frame.size.width - 25.0f;
            nextRoadSize.width = (nextRoadSize.width > maxWidth) ? (maxWidth) : nextRoadSize.width;
            [_labelNextRoad setFrame:CGRectMake(_imageViewNaviTopBG.frame.size.width - nextRoadSize.width - 100.0f,
                                                68.0f + DIFFENT_STATUS_HEIGHT,
                                                nextRoadSize.width,
                                                nextRoadSize.height + 4 + englishHeight)];
            float enterY = _labelNextRoad.frame.origin.x - _labelEnter.frame.size.width / 2 - 25.0f;
            [_labelEnter setCenter:CGPointMake(enterY, DIFFENT_STATUS_HEIGHT + 110.0f)];
            
            
            [_imageRight setFrame:CGRectMake(0.0f, 0.0f, 7.0f, 14.0f)];
            [_imageRight setCenter:CGPointMake(_imageViewNaviTopBG.frame.size.width - 25.0f,
                                               _imageViewNaviTopBG.frame.size.height / 2 + DIFFENT_STATUS_HEIGHT/2)];
            
            
            [_imageDirectAndDistance setFrame:CGRectMake(0.0f, 0.0f, 134.0f, CONFIG_NAVI_TOP_DIRE_HEIGHT)];
            [_labelLeft setFrame:CGRectMake(0.0f, 112.0f+ DIFFENT_STATUS_HEIGHT, 112.0f, 31.0f)];
            _labelLeft.font = [UIFont boldSystemFontOfSize:24.0f];
            [_buttonLeftDirect setFrame:CGRectMake(0.0f, 0.0f, 112.0f,112.0f)];
            [_buttonLeftDirect setCenter:CGPointMake(134.0f/2, 112.0f/2+ DIFFENT_STATUS_HEIGHT)];
        }
    }
    else
    {
        if(isiPhone)
        {
            _labelNextRoad.font = [UIFont boldSystemFontOfSize:24.0f];
            _labelQianfang.font = [UIFont boldSystemFontOfSize:23.0f];
            _labelQianfang.textAlignment = NSTextAlignmentRight;
            _labelEnter.font = [UIFont systemFontOfSize:15.0f];
            CGSize enterSize = [_labelEnter.text sizeWithFont:_labelEnter.font];
            CGSize nextRoadSize = [_labelNextRoad.text sizeWithFont:_labelNextRoad.font];
            //导航顶部的半透明条
            [_imageViewNaviTopBG setFrame:CGRectMake(0, 0, MAIN_LAND_WIDTH - 103, CONFIG_NAVI_TOP_NAME_HEIGHT)];
            [_imageViewNaviTopBG setCenter:CGPointMake((MAIN_LAND_WIDTH - 103)/ 2 + 103, _imageViewNaviTopBG.frame.size.height / 2)];
            
            float nextRoadWidth = (nextRoadSize.width > (_imageViewNaviTopBG.frame.size.width/ 2 - 37.0f)) ?(_imageViewNaviTopBG.frame.size.width/ 2 - 37.0f): nextRoadSize.width;
            [_labelNextRoad setFrame:CGRectMake(_imageViewNaviTopBG.frame.size.width - 37.0f - nextRoadWidth,
                                                7.0f + DIFFENT_STATUS_HEIGHT,
                                                nextRoadWidth,
                                                nextRoadSize.height + englishHeight)];
            [_labelEnter setFrame:CGRectMake(0, 0, enterSize.width + 2, enterSize.height + 2)];
            [_labelEnter setCenter:CGPointMake(_labelNextRoad.frame.origin.x - _labelEnter.frame.size.width + 8,
                                               25.0f + DIFFENT_STATUS_HEIGHT)];
            
            [_labelQianfang setFrame:CGRectMake(0.0f, DIFFENT_STATUS_HEIGHT + 10.0f, _labelEnter.frame.origin.x - 8, 26.0f + englishHeight)];
            
            [_imageRight setFrame:CGRectMake(0.0f, 0.0f, 5.0f, 10.0f)];
            
            [_imageRight setCenter:CGPointMake(_imageViewNaviTopBG.frame.size.width - 7.0f,
                                               _imageViewNaviTopBG.frame.size.height / 2 + DIFFENT_STATUS_HEIGHT / 2)];
            
            
            [_imageDirectAndDistance setFrame:CGRectMake(0.0f, 0.0f, 103.0f, CONFIG_NAVI_TOP_DIRE_HEIGHT)];
            [_labelLeft setFrame:CGRectMake(0.0f, 60.0f + DIFFENT_STATUS_HEIGHT, 103.0f, 26.0f)];
            _labelLeft.font = [UIFont boldSystemFontOfSize:20.0f];
            [_buttonLeftDirect setFrame:CGRectMake(0.0f, 0.0f, 61.0f,61.0f)];
            [_buttonLeftDirect setCenter:CGPointMake(103.0f/2, 61.0f/2 + DIFFENT_STATUS_HEIGHT)];
            
        }
        else
        {
            _labelNextRoad.font = [UIFont boldSystemFontOfSize:42.0f];
            _labelQianfang.font = [UIFont systemFontOfSize:35.0f];
            _labelQianfang.textAlignment = NSTextAlignmentLeft;
            _labelEnter.font = [UIFont systemFontOfSize:23.0f];
            CGSize nextRoadSize = [_labelNextRoad.text sizeWithFont:_labelNextRoad.font];
            CGSize enterSize = [_labelEnter.text sizeWithFont:_labelEnter.font];
            
            //导航顶部的半透明条
            [_imageViewNaviTopBG setFrame:CGRectMake(0, 0, MAIN_LAND_WIDTH - 134.0f, CONFIG_NAVI_TOP_NAME_HEIGHT)];
            [_imageViewNaviTopBG setCenter:CGPointMake((MAIN_LAND_WIDTH - 134.0f)/ 2 + 134.0f, _imageViewNaviTopBG.frame.size.height / 2)];
            [_labelNextRoad setFrame:CGRectMake(_imageViewNaviTopBG.frame.size.width - 540.0f,
                                                20.0f+ DIFFENT_STATUS_HEIGHT,
                                                540.0f - 100.0f,
                                                nextRoadSize.height + 3 + englishHeight)];
            [_labelQianfang setFrame:CGRectMake(25.0f, 7.0f+ DIFFENT_STATUS_HEIGHT, 280.0f, 37.0f + englishHeight)];
            [_labelEnter setFrame:CGRectMake(0, 0, enterSize.width + 2, enterSize.height + 2)];
            [_labelEnter setCenter:CGPointMake(_labelNextRoad.frame.origin.x - _labelEnter.frame.size.width,
                                               57.0f + DIFFENT_STATUS_HEIGHT)];
            [_imageRight setFrame:CGRectMake(0.0f, 0.0f, 7.0f, 14.0f)];
            [_imageRight setCenter:CGPointMake(_imageViewNaviTopBG.frame.size.width - 25.0f,
                                               _imageViewNaviTopBG.frame.size.height / 2 + DIFFENT_STATUS_HEIGHT / 2 )];
            
            [_imageDirectAndDistance setFrame:CGRectMake(0.0f, 0.0f, 134.0f, CONFIG_NAVI_TOP_DIRE_HEIGHT)];
            [_labelLeft setFrame:CGRectMake(0.0f, 112.0f+ DIFFENT_STATUS_HEIGHT, 112.0f, 31.0f)];
            _labelLeft.font = [UIFont boldSystemFontOfSize:24.0f];
            [_buttonLeftDirect setFrame:CGRectMake(0.0f, 0.0f, 112.0f,112.0f)];
            [_buttonLeftDirect setCenter:CGPointMake(134.0f/2, 112.0f/2+ DIFFENT_STATUS_HEIGHT)];
            
        }
    }
}

#pragma mark - ---  外部调用函数  ---
/*!
  @brief    设置（前方）控件的文字
  @param    string ： 文字标题
  @author   by bazinga
  */
- (void) setQianfangText:(NSString *)string
{
    _labelQianfang.text = string;
}

/*!
  @brief    设置（进入）控件的文字
  @param    string ： 文字标题
  @author   by bazinga
  */
- (void) setEnterText:(NSString *)string
{
    _labelEnter.text = string;
}

/*!
  @brief    设置（下一道路名）控件的文字
  @param    string ： 文字标题
  @author   by bazinga
  */
- (void) setNextRoadText:(NSString *)string
{
    _labelNextRoad.text = string;
}


/*!
  @brief    设置（剩余距离）控件的问题
  @param    string：剩余距离
  @author   by bazinga
  */
- (void) setLeftText:(NSString *)string
{
    _labelLeft.text = string;
}


/*!
  @brief    重新加载视图坐标
  @param
  @author   by bazinga
  */
- (void) reloadFrame
{
    [self setTopFrame];
}

/*!
  @brief    设置改视图是否隐藏
  @param    hidden - YES: 隐藏  NO：显示
  @author   by bazinga
  */
- (void) setViewHidden:(BOOL)hidden
{
    _imageDirectAndDistance.hidden = hidden;
    _imageViewNaviTopBG.hidden = hidden;
}

/*!
  @brief    设置转向图片
  @param
  @author   by bazinga
  */
- (void) setImageDirect:(UIImage *)image
{
    [_buttonLeftDirect setImage:image];
}

/*!
  @brief    下一道路名是否隐藏
  @param    hidden - YES: 隐藏  NO：显示
  @author   by bazinga
  */
- (void) setNextRoadHidden:(BOOL)hidden
{
    _labelNextRoad.hidden = hidden;
}

#pragma  mark - ---  事件响应  ---

/*!
  @brief    左右滑动手势
  @param
  @author   by bazinga
  */
-(void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer
{
    if(self.handleSwipe)
    {
        self.handleSwipe(recognizer);
    }
}

/*!
  @brief    视图点击手势
  @param
  @author   by bazinga
  */
- (void)handleTapFrom:(UITapGestureRecognizer *)tap
{
    if(self.handleTap)
    {
        self.handleTap(tap);
    }
}



@end

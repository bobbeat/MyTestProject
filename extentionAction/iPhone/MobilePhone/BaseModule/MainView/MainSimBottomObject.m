//
//  MainSimBottomObject.m
//  AutoNavi
//
//  Created by bazinga on 14-9-2.
//  Copyright (c) 2014年 bazinga. All rights reserved.
//

#import "MainSimBottomObject.h"

@implementation MainSimBottomObject

@synthesize viewSimuBG = _viewSimuBG;
@synthesize mainButtonClick = _mainButtonClick;

- (id) init
{
    if(self)
    {
        [self initSimBar];
    }
    return self;
}

- (void)initSimBar
{
    _viewSimuBG = [[UIView alloc]init];
    _viewSimuBG.backgroundColor = GETSKINCOLOR(MAIN_SIM_CLEAR_COLOR);
    _viewSimuBG.userInteractionEnabled  = YES;
    _viewSimuBG.autoresizesSubviews = YES;
    _viewSimuBG.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    
    
    _bottomButtonSimuStop = [[BottomButton alloc]init];
    [_bottomButtonSimuStop setFrame:CGRectMake(0, 0, APPWIDTH / 3, 44)];
    [_bottomButtonSimuStop setBackgroundImage:[IMAGE(@"mainSimuBGFirst.png", IMAGEPATH_TYPE_1) stretchableImageWithLeftCapWidth:5 topCapHeight:22]
                                     forState:UIControlStateNormal];
    [_bottomButtonSimuStop setBackgroundImage:[IMAGE(@"mainSimuBGFirst.png", IMAGEPATH_TYPE_1) stretchableImageWithLeftCapWidth:5 topCapHeight:22]
                                     forState:UIControlStateHighlighted];
    [_bottomButtonSimuStop setImage:IMAGE(@"mainSimuNaviStop.png", IMAGEPATH_TYPE_1)
                           forState:UIControlStateNormal];
    [_bottomButtonSimuStop setImage:IMAGE(@"mainSimuNaviStopPress.png", IMAGEPATH_TYPE_1)
                           forState:UIControlStateHighlighted];
    [_bottomButtonSimuStop addTarget:self
                              action:@selector(buttonAction:)
                    forControlEvents:UIControlEventTouchUpInside];
    _bottomButtonSimuStop.tag = BUTTON_SIMULATOR_STOP;

    
    _bottomButtonSimuPlay = [[BottomButton alloc]init];
    [_bottomButtonSimuPlay setFrame:CGRectMake(0, 0, APPWIDTH / 3, 44)];
    [_bottomButtonSimuPlay setBackgroundImage:[IMAGE(@"mainSimuBGFirst.png", IMAGEPATH_TYPE_1) stretchableImageWithLeftCapWidth:5 topCapHeight:22]
                                     forState:UIControlStateNormal];
    [_bottomButtonSimuPlay setBackgroundImage:[IMAGE(@"mainSimuBGFirst.png", IMAGEPATH_TYPE_1) stretchableImageWithLeftCapWidth:5 topCapHeight:22]
                                     forState:UIControlStateHighlighted];
    [_bottomButtonSimuPlay setImage:IMAGE(@"mainSimuNaviPlay.png", IMAGEPATH_TYPE_1)
                           forState:UIControlStateNormal];
    [_bottomButtonSimuPlay setImage:IMAGE(@"mainSimuNaviPlayPress.png", IMAGEPATH_TYPE_1)
                           forState:UIControlStateHighlighted];
    [_bottomButtonSimuPlay addTarget:self
                              action:@selector(buttonAction:)
                    forControlEvents:UIControlEventTouchUpInside];
    _bottomButtonSimuPlay.tag = BUTTON_SIMULATOR_PAUSE;
    
    
    _bottomSelect = [[BottomButton alloc]init];
    [_bottomSelect setFrame:CGRectMake(0, 0, APPWIDTH / 3, 44)];
    [_bottomSelect setBackgroundImage:[IMAGE(@"mainSimuBGSecond.png", IMAGEPATH_TYPE_1) stretchableImageWithLeftCapWidth:5 topCapHeight:22]
                             forState:UIControlStateNormal];
    [_bottomSelect setBackgroundImage:[IMAGE(@"mainSimuBGSecond.png", IMAGEPATH_TYPE_1) stretchableImageWithLeftCapWidth:5 topCapHeight:22]
                             forState:UIControlStateHighlighted];
    [_bottomSelect setImage:IMAGE(@"mainSimuSelect.png", IMAGEPATH_TYPE_1)
                   forState:UIControlStateNormal];
    [_bottomSelect setImage:IMAGE(@"mainSimuSelectPress.png", IMAGEPATH_TYPE_1)
                   forState:UIControlStateNormal];
    [_bottomSelect addTarget:self
                      action:@selector(buttonAction:)
            forControlEvents:UIControlEventTouchUpInside];
    [_bottomSelect setTitleColor:GETSKINCOLOR(MAIN_SIM_SELECT_COLOR) forState:UIControlStateNormal];
    _bottomSelect.titleLabel.font = [UIFont systemFontOfSize:15];
    _bottomSelect.tag = BUTTON_SIMULATOR_SLOW;
    
    [_viewSimuBG addSubview:_bottomButtonSimuPlay];
    [_viewSimuBG addSubview:_bottomButtonSimuStop];
    [_viewSimuBG addSubview:_bottomSelect];
    [_bottomButtonSimuPlay release];
    [_bottomButtonSimuStop release];
    [_bottomSelect release];
}

- (void) dealloc
{
    CRELEASE(_viewSimuBG);
    [super dealloc];
}

#pragma mark - ---  外部调用函数  ---
/*!
  @brief    设置视图是否隐藏
  @param
  @author   by bazinga
  */
- (void) setViewHidden:(BOOL)hidden
{
    _viewSimuBG.hidden = hidden;
}

/*!
  @brief    重新加载控件坐标
  @param
  @author   by bazinga
  */
- (void) reloadFrame
{
    if(Interface_Flag == 0)
    {
        if(isiPhone)//iphone竖屏
        {
            [_viewSimuBG setFrame:CGRectMake(0, 0, MAIN_POR_WIDTH, CONFIG_NAVI_BOTTOM_HEIGHT)];
            float height = _viewSimuBG.frame.size.height;
            int buttonWidth = ceilf(MAIN_POR_WIDTH / 3.0f);
            [_viewSimuBG setCenter:CGPointMake(MAIN_POR_WIDTH / 2, MAIN_POR_HEIGHT - height / 2)];
            //按钮内图标长宽——21,18
            [_bottomButtonSimuStop setFrame:CGRectMake(0, 0, buttonWidth, height)];
            _bottomButtonSimuStop.imageRect = CGRectMake(buttonWidth / 2 - 10.5, height / 2 - 9, 21, 18);
            
            [_bottomButtonSimuPlay setFrame:CGRectMake(buttonWidth, 0, buttonWidth, height)];
            _bottomButtonSimuPlay.imageRect = CGRectMake(buttonWidth / 2 - 10.5, height / 2 - 9, 21, 18);
            //图标长宽——16，16
            [_bottomSelect setFrame:CGRectMake(2 * buttonWidth, 0, buttonWidth, height)];
            _bottomSelect.imageRect = CGRectMake(buttonWidth  * 5/ 9 + 5, height / 2 - 6, 16.0f, 16.0f);
            _bottomSelect.textRightsetValue = 0;
            _bottomSelect.textWidth = buttonWidth  * 5/ 9;
            _bottomSelect.titleLabel.textAlignment = NSTextAlignmentRight;
        }
        else
        {
            [_viewSimuBG setFrame:CGRectMake(0, 0, MAIN_POR_WIDTH , CONFIG_NAVI_BOTTOM_HEIGHT)];
            float height = _viewSimuBG.frame.size.height;
            int buttonWidth = ceilf(_viewSimuBG.frame.size.width / 3);
            [_viewSimuBG setCenter:CGPointMake(MAIN_POR_WIDTH / 2, MAIN_POR_HEIGHT - _viewSimuBG.frame.size.height / 2)];
            //按钮内图标长宽——32,27
            [_bottomButtonSimuStop setFrame:CGRectMake(0, 0, buttonWidth, height)];
            _bottomButtonSimuStop.imageRect = CGRectMake(buttonWidth / 2 - 16, height / 2 - 13.5, 32, 27);
            
            [_bottomButtonSimuPlay setFrame:CGRectMake(buttonWidth, 0, buttonWidth, height)];
            _bottomButtonSimuPlay.imageRect = CGRectMake(buttonWidth / 2 - 16, height / 2 - 13.5, 32, 27);
            //图标长宽——25，25
            [_bottomSelect setFrame:CGRectMake(2 * buttonWidth, 0, buttonWidth, height)];
            _bottomSelect.titleLabel.font = [UIFont systemFontOfSize:18.0f];
            _bottomSelect.imageRect = CGRectMake(buttonWidth  * 5/ 9 + 8, height / 2 - 12, 25.0f, 25.0f);
            _bottomSelect.textRightsetValue = 0;
            _bottomSelect.textWidth = buttonWidth  * 5/ 9;
            _bottomSelect.titleLabel.textAlignment = NSTextAlignmentRight;
        }
    }
    else
    {
        if(isiPhone)//iphone横屏
        {
            CGFloat bottomWidth = MAIN_LAND_WIDTH - 4 * CONFIG_BUTTON_NORMAL_WIDTH - 6 * CONFIG_BUTTON_SAPCE;
            [_viewSimuBG setFrame:CGRectMake(0, 0, bottomWidth, CONFIG_NAVI_BOTTOM_HEIGHT)];
            float height = _viewSimuBG.frame.size.height;
            int buttonWidth = ceilf(_viewSimuBG.frame.size.width / 3.0f);
            [_viewSimuBG setCenter:CGPointMake(MAIN_LAND_WIDTH / 2, MAIN_LAND_HEIGHT  - CONFIG_BUTTON_SAPCE - CONFIG_BUTTON_NORMAL_WIDTH / 2)];
            
            //按钮内图标长宽——21,18
            [_bottomButtonSimuStop setFrame:CGRectMake(0, 0, buttonWidth, height)];
            _bottomButtonSimuStop.imageRect = CGRectMake(buttonWidth / 2 - 10.5, height / 2 - 9, 21, 18);
            
            [_bottomButtonSimuPlay setFrame:CGRectMake(buttonWidth, 0, buttonWidth, height)];
            _bottomButtonSimuPlay.imageRect = CGRectMake(buttonWidth / 2 - 10.5, height / 2 - 9, 21, 18);
            //图标长宽——16，16
            [_bottomSelect setFrame:CGRectMake(2 * buttonWidth, 0, buttonWidth, height)];
            _bottomSelect.imageRect = CGRectMake(buttonWidth  * 5/ 9 + 5, height / 2 - 6, 16.0f, 16.0f);
            _bottomSelect.textRightsetValue = 0;
            _bottomSelect.textWidth = buttonWidth  * 5/ 9;
            _bottomSelect.titleLabel.textAlignment = NSTextAlignmentRight;
        }
        else
        {
            [_viewSimuBG setFrame:CGRectMake(0, 0, MAIN_LAND_WIDTH , CONFIG_NAVI_BOTTOM_HEIGHT)];
            [_viewSimuBG setCenter:CGPointMake(MAIN_LAND_WIDTH/2,
                                               MAIN_LAND_HEIGHT - _viewSimuBG.frame.size.height / 2)];
            float height = _viewSimuBG.frame.size.height;
            int buttonWidth = ceilf(_viewSimuBG.frame.size.width / 3);
            //按钮内图标长宽——32,27
            [_bottomButtonSimuStop setFrame:CGRectMake(0, 0, buttonWidth, height)];
            _bottomButtonSimuStop.imageRect = CGRectMake(buttonWidth / 2 - 16, height / 2 - 13.5, 32, 27);
            
            [_bottomButtonSimuPlay setFrame:CGRectMake(buttonWidth, 0, buttonWidth, height)];
            _bottomButtonSimuPlay.imageRect = CGRectMake(buttonWidth / 2 - 16, height / 2 - 13.5, 32, 27);
            //图标长宽——25，25
            [_bottomSelect setFrame:CGRectMake(2 * buttonWidth, 0, buttonWidth, height)];
            _bottomSelect.titleLabel.font = [UIFont systemFontOfSize:18.0f];
            _bottomSelect.imageRect = CGRectMake(buttonWidth  * 5/ 9 + 8, height / 2 - 12, 25.0f, 25.0f);
            _bottomSelect.textRightsetValue = 0;
            _bottomSelect.textWidth = buttonWidth  * 5/ 9;
            _bottomSelect.titleLabel.textAlignment = NSTextAlignmentRight;
        }
    }
    [_bottomButtonSimuStop setNeedsLayout];
    [_bottomButtonSimuPlay setNeedsLayout];
    [_bottomSelect setNeedsLayout];
}

/*!
  @brief    设置模拟导航 开始/暂停 图片
  @param    isPlay —— YES : 开始图片   NO：暂停图片
  @author   by bazinga
  */
- (void) setSimPlayImage:(BOOL) isPlay
{
    if(isPlay)
    {
        [_bottomButtonSimuPlay setImage:IMAGE(@"mainSimuNaviPlay.png", IMAGEPATH_TYPE_1)   forState:UIControlStateNormal];
        [_bottomButtonSimuPlay setImage: IMAGE(@"mainSimuNaviPlayPress.png", IMAGEPATH_TYPE_1)   forState:UIControlStateHighlighted];
    }
    else
    {
        [_bottomButtonSimuPlay setImage: IMAGE(@"mainSimuNaviPause.png", IMAGEPATH_TYPE_1)  forState:UIControlStateNormal];
        [_bottomButtonSimuPlay setImage: IMAGE(@"mainSimuNaviPausePress.png", IMAGEPATH_TYPE_1)  forState:UIControlStateHighlighted];
    }
}

/*!
  @brief    设置速度的标题
  @param
  @author   by bazinga
  */
- (void) setSelectTitle:(NSString *)string
{
    [_bottomSelect setTitle:string  forState:UIControlStateNormal];
}

- (CGRect) getSelectRect
{
    return _bottomSelect.frame;
}
#pragma mark - ---  按钮点击事件  ---
- (void) buttonAction:(id) sender
{
    if(self.mainButtonClick)
    {
        self.mainButtonClick(sender);
    }
}

@end

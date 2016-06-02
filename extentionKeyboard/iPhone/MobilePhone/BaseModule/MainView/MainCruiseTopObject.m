//
//  MainCruiseTopObject.m
//  AutoNavi
//
//  Created by bazinga on 14-9-1.
//  Copyright (c) 2014年 bazinga. All rights reserved.
//

#import "MainCruiseTopObject.h"
//图片定义
#define IMAGE_TOP_SEARCH (IMAGE(@"navigatorBarBg.png", IMAGEPATH_TYPE_2))
#define IMAGE_TOP_FACE_IMAGE (IMAGE(@"main_searchFace.png",IMAGEPATH_TYPE_2))

@implementation MainCruiseTopObject

@synthesize imageTopSearch = _imageTopSearch;

@synthesize mainButtonClick = _mainButtonClick;

- (id) init
{
    self = [super init];
    if(self)
    {
        //顶部搜索栏
        _mainButtonClick = nil;
        _imageTopSearch = [[UIImageView alloc] init];
        
        _imageTopSearch.userInteractionEnabled = YES;
        
        _buttonViewFace = [UIButton buttonWithType:UIButtonTypeCustom];
        [_buttonViewFace addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_imageTopSearch addSubview:_buttonViewFace];
        _buttonViewFace.tag = BUTTON_TOP_FACEBUTTON;
        //    if([[GDNewJudge sharedInstance] isAppearNewWithType:NEW_JUDGE_FACE_TYPE])
        {
            //        _imageFaceNew = [[UIImageView alloc] initWithImage:IMAGE(@"main_newPointFace.png", IMAGEPATH_TYPE_1)];
            //        [_buttonViewFace addSubview:_imageFaceNew];
        }
        //    else
        {
            _imageFaceNew = nil;
        }
        

        _anbuttonTopSearch = [MainControlCreate createANButtonWithTitle:STR(@"Main_searchPlaceholder", Localize_Main)
                                                                  image:[IMAGE(@"mainSearchInput.png", IMAGEPATH_TYPE_2) stretchableImageWithLeftCapWidth:5 topCapHeight:8]
                                                           imagePressed:[IMAGE(@"mainSearchInput.png", IMAGEPATH_TYPE_2) stretchableImageWithLeftCapWidth:5 topCapHeight:8]
                                                               imageTop:nil
                                                                    tag:BUTTON_TOP_SEARCH
                                                        textOffsetValue:13.0f
                                                                 target:self
                                                                 action:@selector(buttonAction:)];
        [_anbuttonTopSearch setTitle:STR(@"Main_searchPlaceholder", Localize_Main)
                            forState:UIControlStateNormal];
        _anbuttonTopSearch.textOffsetValue = 0;
        _anbuttonTopSearch.textRightsetValue = 30;
        _anbuttonTopSearch.titleLabel.textAlignment = NSTextAlignmentLeft;
        _anbuttonTopSearch.autoresizesSubviews = YES;
        _anbuttonTopSearch.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [_anbuttonTopSearch setTitleColor:GETSKINCOLOR(MAIN_DAY_TOPSEARCH_COLOR) forState:UIControlStateNormal];
        
        _buttonSoundSearch  =[UIButton buttonWithType:UIButtonTypeCustom];
        [_buttonSoundSearch setBackgroundImage:IMAGE(@"mainSoundSearch.png",IMAGEPATH_TYPE_2) forState:UIControlStateNormal];
        [_buttonSoundSearch setBackgroundImage:IMAGE(@"mainSoundSearchPress.png",IMAGEPATH_TYPE_2) forState:UIControlStateHighlighted];
        _buttonSoundSearch.tag = BUTTON_SEARCH_SOUND;
        [_buttonSoundSearch addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        _buttonSoundSearch.autoresizesSubviews = YES;
        _buttonSoundSearch.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [_anbuttonTopSearch addSubview:_buttonSoundSearch];
        
        _imageviewMagnifier = [[UIImageView alloc] initWithImage:IMAGE(@"mainSearchIcon.png", IMAGEPATH_TYPE_2)];
        [_anbuttonTopSearch addSubview:_imageviewMagnifier];
        
        UIImage *divIamge = IMAGE(@"main_topImageDiv.png", IMAGEPATH_TYPE_2);
        _imageViewdiv = [[UIImageView alloc] initWithImage:divIamge];
        [_imageViewdiv setFrame:CGRectMake(0, 0, divIamge.size.width, divIamge.size.height)];
        _imageViewdiv.autoresizesSubviews = YES;
        _imageViewdiv.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [_anbuttonTopSearch addSubview:_imageViewdiv];
        
        [_imageTopSearch addSubview:_anbuttonTopSearch];
        
        [_imageviewMagnifier release];
        [self reloadImage];
        //初始化界面坐标
        [self setTopSearchFrame];
    }
    return self;
}

- (void) dealloc
{
    CRELEASE(_imageTopSearch);
    [super dealloc];
}

#pragma mark - ---  外部调用函数  ---
/*!
  @brief    重新加载头像
  @param
  @author   by bazinga
  */
- (void) reloadFaceImage
{
    id imageFace = [Plugin_Account getAccountInfoWith:4];
    if(imageFace && [imageFace isKindOfClass:[UIImage class]])
    {
        [_buttonViewFace setImage:imageFace forState:UIControlStateNormal];
    }
    else
    {
        [_buttonViewFace setImage:IMAGE_TOP_FACE_IMAGE forState:UIControlStateNormal];
    }
}

/*!
  @brief    重新加载图片，白天黑夜 or 皮肤
  @param
  @author   by bazinga
  */
- (void) reloadImage
{
    [_buttonSoundSearch setBackgroundImage:IMAGE(@"mainSoundSearch.png",IMAGEPATH_TYPE_2) forState:UIControlStateNormal];
    [_buttonSoundSearch setBackgroundImage:IMAGE(@"mainSoundSearchPress.png",IMAGEPATH_TYPE_2) forState:UIControlStateHighlighted];
    _imageviewMagnifier.image =  IMAGE(@"mainSearchIcon.png", IMAGEPATH_TYPE_2);
    UIImage *searchBG =IMAGE_TOP_SEARCH;
    _imageTopSearch.image = [searchBG stretchableImageWithLeftCapWidth:searchBG.size.width / 2 topCapHeight:searchBG.size.height / 2];
    
    [_anbuttonTopSearch setBackgroundImage:[IMAGE(@"mainSearchInput.png", IMAGEPATH_TYPE_2) stretchableImageWithLeftCapWidth:5 topCapHeight:0]
                                  forState:UIControlStateNormal];
    [_anbuttonTopSearch setBackgroundImage:[IMAGE(@"mainSearchInput.png", IMAGEPATH_TYPE_2) stretchableImageWithLeftCapWidth:5 topCapHeight:0]
                                  forState:UIControlStateHighlighted];

}

/*!
  @brief    重新加载文字颜色，白天 or 黑夜
  @param
  @author   by bazinga
  */
- (void) reloadTextColor:(int) type
{
    if(type == 1)
    {
        [_anbuttonTopSearch setTitleColor:GETSKINCOLOR(MAIN_NIGHT_NORMAL_COLOR) forState:UIControlStateNormal];
    }
    else
    {
        [_anbuttonTopSearch setTitleColor:GETSKINCOLOR(MAIN_DAY_TOPSEARCH_COLOR) forState:UIControlStateNormal];
    }
}

/*!
  @brief    隐藏 new 的红点图标
  @param
  @author   by bazinga
  */
- (void) hiddenFaceNew
{
    if(_imageFaceNew)
    {
        //        [[GDNewJudge sharedInstance] setHiddenNewByKey:NEW_JUDGE_FACE_TYPE];
        _imageFaceNew.hidden = YES;
    }
}

/*!
  @brief    设置是否显示顶部搜索栏（巡航显示，导航隐藏）
  @param    hidden —— YES: 隐藏  NO: 显示
  @author   by bazinga
  */
- (void) setTopHidden:(BOOL) hidden
{
    _imageTopSearch.hidden = hidden;
}

/*!
  @brief    设置顶部搜索栏的大小
  @param    rect —— 顶部搜索栏的大小
  @author   by bazinga
  */
- (void) setTopFrame:(CGRect )rect
{
    [_imageTopSearch setFrame:rect];
}
#pragma mark - ---  设置界面坐标  ---
- (void) setTopSearchFrame
{
    
    UIImage *searchBG = IMAGE_TOP_SEARCH;
    _imageTopSearch.image = [searchBG stretchableImageWithLeftCapWidth:searchBG.size.width / 2 topCapHeight:searchBG.size.height / 2];
    if(isiPhone)
    {
        CGFloat buttonFcaeCenterX = BUTTON_BOUNDARY;
        
        [_imageTopSearch setFrame:CGRectMake(0,
                                             0,
                                             MAIN_POR_WIDTH,
                                             CONFIG_CRUISE_TOP_HEIGHT)];
        [_buttonViewFace setFrame:CGRectMake(0,
                                             0,
                                             36.0f,
                                             36.0f)];
        [_buttonViewFace setCenter:CGPointMake(buttonFcaeCenterX,
                                               CONFIG_CRUISE_TOP_HEIGHT / 2 + DIFFENT_STATUS_HEIGHT / 2)];
        if(_imageFaceNew)
        {
            [_imageFaceNew setCenter:CGPointMake(_buttonViewFace.frame.size.width / 2 + 9.0f,
                                                 _buttonViewFace.frame.size.height / 2 - 9.0f)];
        }
        
        _anbuttonTopSearch.textRightsetValue = 30;
        _anbuttonTopSearch.titleLabel.font = [UIFont systemFontOfSize:16];
        _anbuttonTopSearch.frame = CGRectMake(_buttonViewFace.center.x * 2 - 3,
                                              _buttonViewFace.frame.origin.y,
                                              _imageTopSearch.frame.size.width -  _buttonViewFace.center.x * 2 - 5,
                                              36.0f  );
        
        [_buttonSoundSearch setFrame:CGRectMake(0,
                                                0,
                                                36.0f,
                                                32.0f)];
        [_buttonSoundSearch setCenter:CGPointMake(_anbuttonTopSearch.frame.size.width - _buttonSoundSearch.frame.size.width / 2 ,
                                                  _anbuttonTopSearch.frame.size.height / 2)];
        
        [_imageViewdiv setCenter:CGPointMake(_anbuttonTopSearch.frame.size.width - _buttonSoundSearch.frame.size.width,
                                             _anbuttonTopSearch.frame.size.height / 2)];
        
        _imageviewMagnifier.frame = CGRectMake(0,
                                               0,
                                               _imageviewMagnifier.image.size.width,
                                               _imageviewMagnifier.image.size.height);
        _imageviewMagnifier.center = CGPointMake(17, _anbuttonTopSearch.frame.size.height / 2);
        
        
    }
    else
    {
        CGFloat navigationHeight = 86.0f - (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1 ? 0 : 20);
        CGFloat centerY = navigationHeight  - 33.0f;
        
        [_imageTopSearch setFrame:CGRectMake(0,
                                             0,
                                             MAIN_POR_WIDTH,
                                             CONFIG_CRUISE_TOP_HEIGHT)];
        
        [_buttonViewFace setFrame:CGRectMake(0,
                                             0,
                                             54.0f,
                                             54.0f)];
        [_buttonViewFace setCenter:CGPointMake(CONFIG_CENTER_LEFT, centerY)];
        if(_imageFaceNew)
        {
            [_imageFaceNew setCenter:CGPointMake(_buttonViewFace.frame.size.width / 2 + 16.0f,
                                                 _buttonViewFace.frame.size.height / 2 - 16.0f)];
        }
        
        _anbuttonTopSearch.textRightsetValue = 50;
        _anbuttonTopSearch.titleLabel.font = [UIFont systemFontOfSize:22];
        _anbuttonTopSearch.frame = CGRectMake(_buttonViewFace.center.x * 2 - 3,
                                              _buttonViewFace.frame.origin.y,
                                              _imageTopSearch.frame.size.width -  _buttonViewFace.center.x * 2 - 5,
                                              54.0f  );
        
        [_anbuttonTopSearch setCenter:CGPointMake(CONFIG_CENTER_LEFT * 2 + _anbuttonTopSearch.frame.size.width / 2,
                                                  centerY)];
        
        [_buttonSoundSearch setFrame:CGRectMake(0,
                                                0,
                                                54.0f,
                                                48.0f)];
        [_buttonSoundSearch setCenter:CGPointMake(_anbuttonTopSearch.frame.size.width - _buttonSoundSearch.frame.size.width / 2 ,
                                                  _anbuttonTopSearch.frame.size.height / 2)];
        
        [_imageViewdiv setCenter:CGPointMake(_anbuttonTopSearch.frame.size.width - _buttonSoundSearch.frame.size.width,
                                             _anbuttonTopSearch.frame.size.height / 2)];
        
        _imageviewMagnifier.frame = CGRectMake(0,
                                               0,
                                               _imageviewMagnifier.image.size.width,
                                               _imageviewMagnifier.image.size.height);
        _imageviewMagnifier.center = CGPointMake(_imageviewMagnifier.frame.size.width / 2 + 10, _anbuttonTopSearch.frame.size.height / 2);
    }
}


/*!
  @brief    中英繁切换，设置文字
  @param
  @author   by bazinga
  */
- (void) reloadText
{
    [_anbuttonTopSearch setTitle:STR(@"Main_searchPlaceholder", Localize_Main)
                        forState:UIControlStateNormal];
}

#pragma mark - ---  按钮点击事件  ---
- (void) buttonAction:(id)sender
{
    if(_mainButtonClick)
    {
        self.mainButtonClick(sender);
    }
}

@end

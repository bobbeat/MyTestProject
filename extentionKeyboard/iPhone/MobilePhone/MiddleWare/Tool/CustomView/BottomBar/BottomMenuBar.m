//
//  BottomMenuBar.m
//  testRightViewController
//
//  Created by bazinga on 13-8-26.
//  Copyright (c) 2013年 bazinga. All rights reserved.
//

#import "BottomMenuBar.h"
#import "BottomButton.h"

#pragma mark -
#pragma mark -
#pragma mark ---  底栏按钮button的信息对象  ---
@implementation BottomMenuInfo

@synthesize title = _title;
@synthesize image = _image;
@synthesize highlightedImage = _highlightedImage;
@synthesize tag = _tag;
@synthesize index = _index;
@synthesize buttonPress = _buttonPress;
@synthesize buttonPressCancel = _buttonPressCancel;

- (id) init
{
    self = [super init];
    if(self)
    {
        _title = nil;
        _image = nil;
        _highlightedImage = nil;
        _tag = -1;
        _buttonPress = nil;
        _buttonPressCancel = nil;
    }
    return self;
}
- (void)dealloc
{
    if(_title)
    {
        [_title release];
        _title = nil;
    }
    if(_image)
    {
        [_image release];
        _image = nil;
    }
    if(_highlightedImage)
    {
        [_highlightedImage release];
        _highlightedImage = nil;
    }
    if(_buttonPress)
    {
        [_buttonPress release];
        _buttonPress = nil;
    }
    if(_buttonPressCancel)
    {
        [_buttonPressCancel release];
        _buttonPressCancel = nil;
    }
    [super dealloc];
}

@end

#pragma mark -
#pragma mark -
#pragma mark ---  底栏的按钮栏  ---
@implementation BottomMenuBar

#define BOTTOM_HEADER_HEIGHT 2.0f

@synthesize textOffsetValue = _textOffsetValue;
@synthesize textRightsetValue = _textRightsetValue;
@synthesize imageRect= _imageRect;
@synthesize bottomMenuBarType = _bottomMenuBarType;
@synthesize textWidth = _textWidth;
@synthesize isVertical = _isVertical;

- (id)initWithFrame:(CGRect)frame withButtonNumber:(int) buttonNum 
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _buttonNum = buttonNum;
        _fonsize = 12.0f;
        _buttons = nil;
        _images = nil;
        _textOffsetValue = 0;
        _textRightsetValue = 0;
        _textWidth = 0;
        _imageRect = CGRectZero;
        _bottomMenuBarType = BOTTOM_MENU_NO_HEADER;
        _isVertical = NO;
    }
    return self;
}

/***
 * @name    初始化按钮底栏
 * @param   @frame 大小位置
 * @param   @buttonNum 按钮个数
 * @param   @images 背景图片 —— 1、有右边边栏，2、右边边栏按下   |  3、无右边边栏，4、无右边边栏按下
 * @author  by bazinga
 ***/
- (id) initWithFrame:(CGRect)frame
    withButtonNumber:(int) buttonNum
withButtonBackImages:(NSArray *)images
{
    self = [self initWithFrame:frame withButtonNumber:buttonNum];
    if (self)
    {
        [self initBackImageAndButton:images];
    }
    return self;
}

- (void) dealloc
{
    if(_images)
    {
        [_images release];
        _images = nil;
    }
    if(_buttons)
    {
        [_buttons release];
        _buttons = nil;
    }
    [super dealloc];
}

#pragma mark -
#pragma mark ---  数据初始化  ---
//初始化各种数据
- (void) initBackImageAndButton:(NSArray *)images
{
    if(images == nil || images.count != 6)
    {
        {
            _images =  [[NSMutableArray alloc] initWithObjects:
                        [IMAGE(@"BottomHasRight.png", IMAGEPATH_TYPE_1) stretchableImageWithLeftCapWidth:7 topCapHeight:0],
                        [IMAGE(@"BottomHasRightPress.png", IMAGEPATH_TYPE_1)stretchableImageWithLeftCapWidth:7 topCapHeight:0],
                        [IMAGE(@"BottomHasRight.png", IMAGEPATH_TYPE_1)  stretchableImageWithLeftCapWidth:7 topCapHeight:0],
                        [IMAGE(@"BottomHasRightPress.png", IMAGEPATH_TYPE_1) stretchableImageWithLeftCapWidth:7 topCapHeight:0],
                        [IMAGE(@"BottomNoRight.png", IMAGEPATH_TYPE_1)  stretchableImageWithLeftCapWidth:7 topCapHeight:0],
                        [IMAGE(@"BottomNoRightPress.png", IMAGEPATH_TYPE_1)  stretchableImageWithLeftCapWidth:7 topCapHeight:0],
                        nil] ;
        }
        
    }
    else
    {
        if(_images)
        {
            [_images release];
            _images = nil;
        }
        _images = [[NSMutableArray alloc] initWithArray:images];;
    }
    //如果你像，可以一个背景图
    _imageViewBack =  [[UIImageView alloc] init];
    _imageViewBack.hidden = YES;
    [self addSubview:_imageViewBack];
    [_imageViewBack release];
    //顶部蓝色条
    _viewHeader = [[UIView alloc]init];
    [_viewHeader setBackgroundColor:GETSKINCOLOR(BOTTOM_HEADER_BACK_COLOR)];
    _viewHeader.hidden = YES;
    [self addSubview:_viewHeader];
    [_viewHeader release];
    //设置完背景图片，设置button
    [self initButton];
}

- (void) initButton
{
    if(_buttons == nil)
    {
        _buttons = [[NSMutableArray alloc]init];
    }
    else
    {
        [_buttons removeAllObjects];
        for(id subview in [self subviews])
        {
            if([subview isKindOfClass:[BottomButton class]])
            {
                [subview removeFromSuperview];
            }
        }
    }
    for (int i = 0; i < _buttonNum; i++)
    {
        BottomButton *tempBottomButton = [[BottomButton alloc]init];
        tempBottomButton.tag = i;
        if(i == 0) //第一个
        {
            [tempBottomButton setBackgroundImage:[_images objectAtIndex:0]  forState:UIControlStateNormal];
            [tempBottomButton setBackgroundImage:[_images objectAtIndex:1] forState:UIControlStateHighlighted];
            [tempBottomButton setBackgroundImage:[_images objectAtIndex:1] forState:UIControlStateSelected];
        }
        else if(i != _buttonNum - 1) //中间按钮
        {
            [tempBottomButton setBackgroundImage:[_images objectAtIndex:2]  forState:UIControlStateNormal];
            [tempBottomButton setBackgroundImage:[_images objectAtIndex:3] forState:UIControlStateHighlighted];
            [tempBottomButton setBackgroundImage:[_images objectAtIndex:3] forState:UIControlStateSelected];
        }
        else    //最后面的按钮
        {
            [tempBottomButton setBackgroundImage:[_images objectAtIndex:4]  forState:UIControlStateNormal];
            [tempBottomButton setBackgroundImage:[_images objectAtIndex:5] forState:UIControlStateHighlighted];
            [tempBottomButton setBackgroundImage:[_images objectAtIndex:5] forState:UIControlStateSelected];
        }
        
        [_buttons addObject:tempBottomButton];
        tempBottomButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        tempBottomButton.titleLabel.font  = [UIFont systemFontOfSize:12.0f];

        [self addSubview:tempBottomButton];
        
        [tempBottomButton release];
    }
    
    //重新夹在设置button的大小和位置
    [self reloadButtonsFrame];
}


#pragma mark - 
#pragma mark ---  设置按钮数据  ---
//设置单个数据
- (BOOL) setSingleButton:(NSString *)title
                withIcon:(UIImage *)icon
     withHighlightedIcon:(UIImage *)highlightedIcon
                 withTag:(int) tag
            withFontSize:(CGFloat)fontsize
               withIndex:(int)index
{
    if(index  > (_buttons.count - 1))
    {
        return NO;
    }
    BottomButton *button = [_buttons objectAtIndex:index];
    if(icon == nil && highlightedIcon == nil)
    {
    }
    else
    {
        button.imageRect = _imageRect;
        [button setImage:icon forState:UIControlStateNormal];
        [button setImage:highlightedIcon forState:UIControlStateHighlighted];
        [button setImage:highlightedIcon forState:UIControlStateSelected];
    }
    
    button.textOffsetValue = _textOffsetValue;
    button.textRightsetValue = _textRightsetValue;
    button.textWidth = _textWidth;
    [button setTitle:title forState:UIControlStateNormal];
    
    button.tag = tag;
    button.titleLabel.font = [UIFont systemFontOfSize:fontsize];
    

    
    return YES;
}

//设置一组数据
- (BOOL) setButtonsTitle:(NSArray *)titles
               withIcon:(NSArray *)icons
    withHighlightedIcon:(NSArray *)highlightedIcon
             withOffset:(int)offset
       withTextFontSize:(CGFloat)fontsize
                withTag:(NSArray *)tags
{
    int min = MIN(MIN(titles.count, icons.count),MIN(highlightedIcon.count,tags.count));
    _buttonNum = min;
    BOOL rtValue = YES;
    [self initButton];
    for(int i = 0 ; i < min; i++)
    {
        BOOL tempValue = [self setSingleButton:[titles objectAtIndex:i]
                                      withIcon:[icons objectAtIndex:i]
                           withHighlightedIcon:[highlightedIcon objectAtIndex:i]
                                       withTag:[[tags objectAtIndex:i] intValue]
                                  withFontSize:fontsize
                                     withIndex:i];
        if(!tempValue )
        {
            rtValue = tempValue;
        }
    }
    return rtValue;
}


//通过自定义的button对象设置button的数据
-  (BOOL) setSingleByInfo:(BottomMenuInfo *)buttonInfo
{
    if(buttonInfo.index  > (_buttons.count - 1))
    {
        return NO;
    }
    BottomButton *button = [_buttons objectAtIndex:buttonInfo.index];
//    if(button.frame.size.width > buttonInfo.image.size.width || button.frame.size.height > buttonInfo.image.size.height)
//    {
//        float left = (button.frame.size.width - buttonInfo.image.size.width) / 2.0f;
//        float top = (button.frame.size.height - buttonInfo.image.size.height) / 2.0f;
//        
//        button.imageEdgeInsets = UIEdgeInsetsMake(top, left, 0, 0);
//    }
//   
    if(buttonInfo.image == nil && buttonInfo.highlightedImage == nil)
    {
    }
    else
    {
        button.imageRect = _imageRect;
        [button setImage:buttonInfo.image forState:UIControlStateNormal];
        [button setImage:buttonInfo.highlightedImage forState:UIControlStateHighlighted];
        [button setImage:buttonInfo.highlightedImage forState:UIControlStateSelected];
    }
    button.textOffsetValue = _textOffsetValue;
    button.textRightsetValue = _textRightsetValue;
    button.textWidth = _textWidth;
    [button setTitle:buttonInfo.title forState:UIControlStateNormal];
    button.buttonPress = buttonInfo.buttonPress;
    button.buttonPressCancel = buttonInfo.buttonPressCancel;

    button.tag = buttonInfo.tag;
    

    return YES;
}

- (BOOL) SetButtonsByInfoes :(NSArray *)infoArray
{
    BOOL rtValue = YES;
    _buttonNum = infoArray.count;
    
    [self initButton];
    
    for ( int i = 0; i < _buttons.count; i ++)
    {
        id tempData = [infoArray  objectAtIndex:i];
        BOOL tempValue = [tempData isKindOfClass:[BottomMenuInfo class]];
        if(!tempValue)
        {
            rtValue = tempValue;
            continue;
        }
        ((BottomMenuInfo *)tempData).index = i;
        tempValue = [self setSingleByInfo:tempData];
        //如果出错，就返回NO
        if(!tempValue)
        {
            rtValue = tempValue;
        }
    }
    return rtValue;
}

#pragma  mark ---  设置控件  ---
- (void) setFrame:(CGRect)frame
{
    [super setFrame: frame];
    [self reloadButtonsFrame];
    _imageViewBack.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
}

- (void) reloadButtonsFrame
{
    if(_isVertical == NO)
    {
        int width = self.frame.size.width / ((_buttons.count == 0) ? 1 :_buttons.count);
        float heigt = self.frame.size.height ;

        for (int i = 0; i < _buttons.count; i++)
        {
            BottomButton *button = [_buttons objectAtIndex:i];
            [button setFrame:CGRectMake(i * width, 0, width,heigt)];
            if(_imageRect.size.width == 0 && _imageRect.size.height == 0)
            {
                _imageRect = button.bounds;
            }
        }
        [_viewHeader setFrame:CGRectMake(0.125 * width, heigt - BOTTOM_HEADER_HEIGHT, width * 0.75, BOTTOM_HEADER_HEIGHT)];
    }
    else
    {
        int width = self.frame.size.width;
        float heigt = self.frame.size.height / ((_buttons.count == 0) ? 1 :_buttons.count);
        for (int i = 0; i < _buttons.count; i++)
        {
            BottomButton *button = [_buttons objectAtIndex:i];
            [button setFrame:CGRectMake(0, i * heigt, width,heigt)];
            if(_imageRect.size.width == 0 && _imageRect.size.height == 0)
            {
                _imageRect = button.bounds;
            }
        }
        [_viewHeader setFrame:CGRectMake(width - BOTTOM_HEADER_HEIGHT, 0, BOTTOM_HEADER_HEIGHT, heigt)];
    }
}

//设置不同状态下，标题的颜色
- (void) setTitleColor:(UIColor *)color forState:(UIControlState)state
{
    for (int i = 0;  i < _buttons.count; i++) {
        [((BottomButton *)[_buttons objectAtIndex:i]) setTitleColor:color forState:state];
    }
}

- (void) setTextOffsetValue:(CGFloat)tmptextOffsetValue
{
    _textOffsetValue = tmptextOffsetValue;
    for (int i = 0;  i < _buttons.count; i++) {
        ((BottomButton *)[_buttons objectAtIndex:i]).textOffsetValue = _textOffsetValue;
    }
}

- (void) setTextWidth:(CGFloat)textWidth
{
    _textWidth = textWidth;
    for (int i = 0;  i < _buttons.count; i++) {
        ((BottomButton *)[_buttons objectAtIndex:i]).textWidth = _textWidth;
    }
}

- (void) setTextRightsetValue:(CGFloat)tmptextRightsetValue
{
    _textRightsetValue = tmptextRightsetValue;
    for (int i = 0;  i < _buttons.count; i++) {
        ((BottomButton *)[_buttons objectAtIndex:i]).textRightsetValue = _textRightsetValue;
    }
}

- (void) setTextAlignment:(NSTextAlignment)textAlignment
{
    for (int i = 0;  i < _buttons.count; i++) {
        ((BottomButton *)[_buttons objectAtIndex:i]).titleLabel.textAlignment = textAlignment;
    }
}

- (void) setImageRect:(CGRect)imageRect
{
    _imageRect = imageRect;
    for (int i = 0;  i < _buttons.count; i++) {
        ((BottomButton *)[_buttons objectAtIndex:i]).imageRect = _imageRect;
        [((BottomButton *)[_buttons objectAtIndex:i]) setNeedsLayout];
    }
}

- (void) setTitleFont:(UIFont *)font
{
    for (int i = 0;  i < _buttons.count; i++) {
        ((BottomButton *)[_buttons objectAtIndex:i]).titleLabel.font = font;
    }
}

- (void) setTitleFont:(UIFont *)font withTag:(int)tag
{
    for (int i = 0;  i < _buttons.count; i++) {
        if( ((BottomButton *)[_buttons objectAtIndex:i]).tag == tag)
        {
            ((BottomButton *)[_buttons objectAtIndex:i]).titleLabel.font = font;
        }
    }
}


#pragma mark -
#pragma mark ---  对某一个按键按下后，保持高亮状态  ---
- (void) selectTag :(int) tag
{
    __block NSMutableArray *blockarray = _buttons;
    __block int selectNum = 0;
    
    for(int i = 0 ; i < blockarray.count;i++)
    {
        BottomButton * button =  [blockarray objectAtIndex:i];
        if(tag != -1 && tag == button.tag)
        {
            button.selected = YES;
            selectNum = i;
            NSLog(@"--------%d",i);
        }
        else
        {
            button.selected = NO;
        }
    }

    if(self.bottomMenuBarType == BOTTOM_MENU_HAS_HEADER)
    {
        NSLog(@"BOTTOM_MENU_HAS_HEADER : - %d",selectNum);
        __block UIView *blockview = _viewHeader;
        [self bringSubviewToFront:_viewHeader];
        _viewHeader.hidden = NO;
        CGPoint center = CGPointMake((selectNum + 0.5 )* (self.frame.size.width / _buttonNum),
                                    self.frame.size.height - blockview.frame.size.height / 2);
        if(_isVertical)
        {
            center = CGPointMake((blockview.frame.size.width / 2),
                                 (selectNum + 0.5 )* (self.frame.size.width / _buttonNum));
        }
        [UIView animateWithDuration:0.2
                         animations:^{
                             [blockview setCenter:center];
        }];
    }
    
    
}

- (NSMutableArray *)getButtonArray
{
    return _buttons;
}
- (int)getButtonCount
{
    return  _buttonNum;
}

- (CGFloat) buttonWidth
{
    int width = 0;
    if(_buttons.count != 0)
    {
        if (_isVertical) {
            width = self.frame.size.width;
        }
        else
        {
            width = self.frame.size.width / (_buttons.count * 1);
        }
    }
    return width;
}

#pragma mark ---  设置背景图片和图片  ---
- (void) setBackImages: (NSArray *)images
{
    if(images  && images.count == 6)
    {
        [_images removeAllObjects];
        [_images addObjectsFromArray:images];
        for (int i = 0;  i < _buttons.count; i++) {
            BottomButton *tempBottomButton = [_buttons objectAtIndex:i];
            if(i == 0) //第一个
            {
                [tempBottomButton setBackgroundImage:[images objectAtIndex:0]  forState:UIControlStateNormal];
                [tempBottomButton setBackgroundImage:[images objectAtIndex:1] forState:UIControlStateHighlighted];
                [tempBottomButton setBackgroundImage:[images objectAtIndex:1] forState:UIControlStateSelected];
            }
            else if(i != _buttonNum - 1) //中间按钮
            {
                [tempBottomButton setBackgroundImage:[images objectAtIndex:2]  forState:UIControlStateNormal];
                [tempBottomButton setBackgroundImage:[images objectAtIndex:3] forState:UIControlStateHighlighted];
                [tempBottomButton setBackgroundImage:[images objectAtIndex:3] forState:UIControlStateSelected];
            }
            else    //最后面的按钮
            {
                [tempBottomButton setBackgroundImage:[images objectAtIndex:4]  forState:UIControlStateNormal];
                [tempBottomButton setBackgroundImage:[images objectAtIndex:5] forState:UIControlStateHighlighted];
                [tempBottomButton setBackgroundImage:[images objectAtIndex:5] forState:UIControlStateSelected];
            }
        }
    }
    
}

- (void) setImages :(NSArray *)images  withState:(UIControlState) state
{
    if(images  && images.count == _buttons.count)
    {
        for (int i = 0;  i < _buttons.count; i++) {
            BottomButton *tempBottomButton = [_buttons objectAtIndex:i];
            [tempBottomButton setImage:[images objectAtIndex:i]  forState: state];
        }
    }

}

- (void) setButtonsType :(UILineBreakMode) lineBreakMode
{
    for (int i = 0;  i < _buttons.count; i++)
    {
        BottomButton *tempBottomButton = [_buttons objectAtIndex:i];
        tempBottomButton.titleLabel.lineBreakMode = lineBreakMode;
        tempBottomButton.titleLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    }
}

//设置整体的背景图片
- (void) setBackgroundImage:(UIImage *) backImage
{
    [self sendSubviewToBack:_imageViewBack];
    _imageViewBack.hidden = NO;
    [_imageViewBack setImage:[backImage stretchableImageWithLeftCapWidth:backImage.size.width / 2
                                                            topCapHeight:backImage.size.height / 2]];
}

@end

//
//  BottomButton.m
//  AutoNavi
//
//  Created by jiangshu.fu on 13-9-9.
//
//

#import "BottomButton.h"

@implementation BottomButton

@synthesize textOffsetValue;
@synthesize textRightsetValue;
@synthesize imageRect;
@synthesize textWidth;
@synthesize buttonPress = _buttonPress;

- (id)init
{
	self = [super init];
    if(self)
    {
        textOffsetValue = 0;
        textRightsetValue = 0;
        imageRect = CGRectZero;
        textWidth = 0;
        [self setExclusiveTouch:YES];
        [self addTarget:self action:@selector(buttonPress:) forControlEvents:UIControlEventTouchUpInside];
        [self addTarget:self  action:@selector(buttonPressCancel:) forControlEvents:UIControlEventTouchUpOutside];
    }
	return self;
}

- (void) dealloc
{
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



- (void) setFrame:(CGRect)frame
{
    [super setFrame:frame];
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect
{
	contentRect.origin.y += textOffsetValue;
    contentRect.origin.x += textRightsetValue;
    if(textWidth != 0)
    {
        contentRect.size.width = textWidth;
    }
	return contentRect;
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect
{
	return self.imageRect;
}

//按钮响应事件
- (void) buttonPress:(id) sender
{
    if(self.buttonPress)
    {
        self.buttonPress(sender);
    }
}

- (void) buttonPressCancel:(id) sender
{
    if(self.buttonPressCancel)
    {
        self.buttonPressCancel(sender);
    }
}

@end


//
//  MainControlCreate.m
//  AutoNavi
//
//  Created by bazinga on 14-8-29.
//  Copyright (c) 2014年 bazinga. All rights reserved.
//

#import "MainControlCreate.h"
#import "ControlCreat.h"

@implementation MainControlCreate

+ (UIButton *) createButton
{
    UIButton *button = [ControlCreat createButtonWithTitle:nil normalImage:nil heightedImage:nil tag:-1];
    return button;
}



+ (UIButton *) createButtonWithTitle:(NSString *)title
                         normalImage:(UIImage *)normalImage
                       heightedImage:(UIImage *)heightedImage
                                 tag:(NSInteger)tagN
                              target:(id)target
                              action:(SEL)action
                    forControlEvents:(UIControlEvents)controlEvents
{
    UIButton *button = [MainControlCreate createButton];
    button.tag = tagN;
	
	if (normalImage != nil)
	{
		[button setBackgroundImage:normalImage  forState:UIControlStateNormal];
        
	}
	
	if (heightedImage != nil)
	{
		[button setBackgroundImage:heightedImage  forState:UIControlStateHighlighted];
	}
	
	if (title != nil)
	{
		[button setTitle:title forState:UIControlStateNormal];
	}
    
    [button addTarget:target action:action forControlEvents:controlEvents];
    
    return button;
}

+ (UIButton *) createButtonWithTitle:(NSString *)title
                         normalImage:(UIImage *)normalImage
                       heightedImage:(UIImage *)heightedImage
                                 tag:(NSInteger)tagN
                              target:(id)target
                              action:(SEL)action
{
    UIButton *button = [MainControlCreate createButtonWithTitle:title normalImage:normalImage heightedImage:heightedImage tag:tagN target:target action:action forControlEvents:UIControlEventTouchUpInside];
    return button;
    
}

+ (ANButton *)createANButtonWithTitle:(NSString *)title
								image:(UIImage *)image
						 imagePressed:(UIImage *)imagePressed
							 imageTop:(UIImage *)imageTop
								  tag:(NSInteger)tagN
                      textOffsetValue:(CGFloat)textOffsetValue
                               target:(id)target
                               action:(SEL)action
{
   ANButton *button = [ControlCreat createANButtonWithTitle:title image:image imagePressed:imagePressed imageTop:imageTop tag:tagN textOffsetValue:textOffsetValue];
	
	[button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}


#pragma mark UILabel
+ (UILabel *)createLabelWithText:(NSString *)text fontSize:(CGFloat)size textAlignment:(UITextAlignment)textAlignment
{
	
	return [ControlCreat createLabelWithText:text fontSize:size textAlignment:textAlignment];
}



@end

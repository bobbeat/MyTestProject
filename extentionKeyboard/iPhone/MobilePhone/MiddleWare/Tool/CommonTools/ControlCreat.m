//
//  ControlCreat.m
//  AutoNavi
//
//  Created by huang longfeng on 12-4-20.
//  Copyright 2012 autonavi. All rights reserved.
//

#import "ControlCreat.h"
#import "GDActionSheet.h"
#import "KLSwitch.h"
#import "GDAlertView.h"

@implementation ControlCreat

#pragma mark -
#pragma mark 常用控件创建
#pragma mark ---------------------------------------------------------------------------------------------------------------
#pragma mark UIButton
+ (UIButton *)createButtonWithTitle:(NSString *)titleT normalImage:(NSString *)normalImage heightedImage:(NSString *)heightedImage tag:(NSInteger)tagN
{
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	button.tag = tagN;
	
	if (normalImage != nil)
	{
		[button setBackgroundImage:IMAGE(normalImage, IMAGEPATH_TYPE_1)  forState:UIControlStateNormal];
        
	}
	
	if (heightedImage != nil)
	{
		[button setBackgroundImage:IMAGE(heightedImage, IMAGEPATH_TYPE_1)  forState:UIControlStateHighlighted];
	}
	
	[button setBackgroundColor:[UIColor clearColor]];
	[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	
	if (titleT != nil)
	{
		[button setTitle:titleT forState:UIControlStateNormal];
	}
	
	return button;
}

+ (UIButton *)createButtonWithTitle:(NSString *)titleT normalImage:(NSString *)normalImage heightedImage:(NSString *)heightedImage tag:(NSInteger)tagN withImageType:(IMAGEPATHTYPE)type
{
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	button.tag = tagN;
	
	if (normalImage != nil)
	{
		[button setBackgroundImage:IMAGE(normalImage, type) forState:UIControlStateNormal];
        
	}
	
	if (heightedImage != nil)
	{
        [button setBackgroundImage:IMAGE(heightedImage, type) forState:UIControlStateHighlighted];
	}
	
	[button setBackgroundColor:[UIColor clearColor]];
	[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	
	if (titleT != nil)
	{
		[button setTitle:titleT forState:UIControlStateNormal];
	}
	
	return button;
}


// 添加带拉伸参数的初始化函数lyh10-25
+ (UIButton*)createButtonWithTitle:(NSString *)titleT normalImage:(NSString *)normalImage heightedImage:(NSString *)heightedImage tag:(NSInteger)tagN strechParamX:(NSInteger)xParam strechParamY:(NSInteger)yParam
{
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	button.tag = tagN;
	
	if (normalImage != nil)
	{
        UIImage *stretchableButtonImageNormal = [ IMAGE(normalImage, IMAGEPATH_TYPE_1) stretchableImageWithLeftCapWidth:xParam topCapHeight:yParam];
		[button setBackgroundImage:stretchableButtonImageNormal  forState:UIControlStateNormal];
        
	}
	
	if (heightedImage != nil)
	{
        UIImage *stretchableButtonImageNormal = [ IMAGE(heightedImage, IMAGEPATH_TYPE_1) stretchableImageWithLeftCapWidth:xParam topCapHeight:yParam];
		[button setBackgroundImage:stretchableButtonImageNormal  forState:UIControlStateHighlighted];
	}
    
	[button setBackgroundColor:[UIColor clearColor]];
	[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	
	if (titleT != nil)
	{
		[button setTitle:titleT forState:UIControlStateNormal];
	}
	
	return button;
}

+ (UIButton*)createButtonWithTitle:(NSString *)titleT normalImage:(NSString *)normalImage heightedImage:(NSString *)heightedImage tag:(NSInteger)tagN strechParamX:(NSInteger)xParam strechParamY:(NSInteger)yParam withType:(IMAGEPATHTYPE)type
{
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	button.tag = tagN;
	
	if (normalImage != nil)
	{
        UIImage *stretchableButtonImageNormal = [IMAGE(normalImage, type) stretchableImageWithLeftCapWidth:xParam topCapHeight:yParam];
		[button setBackgroundImage:stretchableButtonImageNormal  forState:UIControlStateNormal];
        
	}
	
	if (heightedImage != nil)
	{
        UIImage *stretchableButtonImageNormal = [IMAGE(heightedImage, type) stretchableImageWithLeftCapWidth:xParam topCapHeight:yParam];
		[button setBackgroundImage:stretchableButtonImageNormal  forState:UIControlStateHighlighted];
	}
    
	[button setBackgroundColor:[UIColor clearColor]];
	[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	
	if (titleT != nil)
	{
		[button setTitle:titleT forState:UIControlStateNormal];
	}
	
	return button;
}


+ (ANButton *)createANButtonWithTitle:(NSString *)title
								image:(UIImage *)image
						 imagePressed:(UIImage *)imagePressed
							 imageTop:(UIImage *)imageTop
								  tag:(NSInteger)tagN
                      textOffsetValue:(CGFloat)textOffsetValue
{
	ANButton *button = [ANButton buttonWithType:UIButtonTypeCustom];
	button.textOffsetValue = textOffsetValue;
	button.tag = tagN;
	button.titleLabel.font = [UIFont systemFontOfSize:15.0f];
	button.titleLabel.textAlignment = UITextAlignmentCenter;
	[button setTitle:title forState:UIControlStateNormal];
	[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	button.adjustsImageWhenHighlighted = NO;
    //	UIImage *newImage = [image stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
	[button setBackgroundImage:image forState:UIControlStateNormal];
    //	UIImage *newPressedImage = [imagePressed stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
	[button setBackgroundImage:imagePressed forState:UIControlStateHighlighted];
	[button setImage:imageTop forState:UIControlStateNormal];
	
    
	return button;
}

#pragma mark UIActivityIndicatorView
+ (UIActivityIndicatorView *)createActivityIndicatorViewWithActivityIndicatorStyle:(UIActivityIndicatorViewStyle)style
{
	UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:style];
	[activityIndicatorView sizeToFit];
	return [activityIndicatorView autorelease];
}


#pragma mark UILabel
+ (UILabel *)createLabelWithText:(NSString *)text fontSize:(CGFloat)size textAlignment:(UITextAlignment)textAlignment
{
	UILabel *label = [[UILabel alloc] init];
	label.font = [UIFont systemFontOfSize:size];
	label.textColor = [UIColor whiteColor];
	label.textAlignment = textAlignment;
	label.backgroundColor = [UIColor clearColor];
	if (nil != text)
	{
		[label setText:text];
	}
	return [label autorelease];
}


#pragma mark － UISearchBar
+ (UISearchBar *)createSearchBarWithPlaceholder:(NSString *)placeholder tag:(NSInteger)tag
{
	UISearchBar *searchBar = [[UISearchBar alloc] init];
	searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
	searchBar.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
	searchBar.showsCancelButton = NO;
	searchBar.barStyle = UIBarStyleBlack;
	searchBar.placeholder = placeholder;
    searchBar.tag = tag;
	return [searchBar autorelease];
}


#pragma mark － UIActionSheet

+ (GDActionSheet *)createGDActionSheetWithTitle:(NSString *)titleT
                                       delegate:(id<GDActionSheetDelegate>)delegate
                              cancelButtonTitle:(NSString *)cancelButtonTitle
                         destructiveButtonTitle:(NSString *)destructiveButtonTitle
                                            tag:(NSInteger)tagN
                              otherButtonTitles:(NSString*)other,...

{
    va_list list;
    va_start(list, other);
    
    GDActionSheet *actionSheet = [[GDActionSheet alloc] initWithTitle:titleT
                                                             delegate:delegate
                                                    cancelButtonTitle:cancelButtonTitle
                                               destructiveButtonTitle:destructiveButtonTitle
                                                    otherButtonTitles:nil];
    actionSheet.tag = tagN;
    NSString *string=other;//va_arg(list, (NSString*));
    while (string) {
        [actionSheet addOtherButton:string];
        string= va_arg(list,NSString*);
    }
    
    [actionSheet ShowOrHiddenActionSheet:YES Animation:YES];
    
    return [actionSheet autorelease];
    
}

+ (GDActionSheet *)createGDActionSheetWithTitle:(NSString *)titleT
                                       delegate:(id<GDActionSheetDelegate>)delegate
                              cancelButtonTitle:(NSString *)cancelButtonTitle
                         destructiveButtonTitle:(NSString *)destructiveButtonTitle
                              otherButtonTitles:(NSArray*)other
                                            tag:(NSInteger)tagN


{
    
    
    GDActionSheet *actionSheet = [[GDActionSheet alloc] initWithTitle:titleT
                                                             delegate:delegate
                                                    cancelButtonTitle:cancelButtonTitle
                                               destructiveButtonTitle:destructiveButtonTitle
                                                    otherButtonTitles:nil];
    actionSheet.tag = tagN;
    for (NSString *string in other ) {
        [actionSheet addOtherButton:string];
    }
    
    [actionSheet ShowOrHiddenActionSheet:YES Animation:YES];
    
    return [actionSheet autorelease];
    
}

#pragma mark - UIAlertView
+ (GDAlertView *)createAlertViewWithTitle:(NSString *)titleT
                                 delegate:(id)delegate
								  message:(NSString *)message
						cancelButtonTitle:(NSString *)cancelButtonTitle
						otherButtonTitles:(NSArray *)otherButtonTitles
									  tag:(NSInteger)tagN
{
    __block id weakself = delegate;
    GDAlertView *alertView = [[GDAlertView alloc] initWithTitle:titleT andMessage:message];
    alertView.tag = tagN;
    if (cancelButtonTitle) {
        [alertView addButtonWithTitle:cancelButtonTitle type:GDAlertViewButtonTypeCancel handler:^(GDAlertView *alertView) {
            if (weakself && [weakself respondsToSelector:@selector(alertView:clickedButtonAtIndex:)])
            {
                [weakself alertView:(UIAlertView *)alertView clickedButtonAtIndex:0];
            }
        }];
    }
    if (otherButtonTitles && otherButtonTitles.count > 0) {
        for (int i = 0 ; i < [otherButtonTitles count] ; i++) {
            [alertView addButtonWithTitle:[otherButtonTitles objectAtIndex:i] type:GDAlertViewButtonTypeCancel handler:^(GDAlertView *alertView) {
                if (weakself && [weakself respondsToSelector:@selector(alertView:clickedButtonAtIndex:)])
                {
                    int clickIndex = 0;
                    if (cancelButtonTitle) {
                        clickIndex = i + 1;
                    }
                    else{
                        clickIndex = i;
                    }
                    [weakself alertView:(UIAlertView *)alertView clickedButtonAtIndex:clickIndex];
                }
            }];
        }
    }
    
    [alertView show];
    
    return [alertView autorelease];
    
}

#pragma mark - UITextView
+ (UITextView *)createTextViewWithTitle:(NSString *)text fontSize:(CGFloat)size textAlignment:(UITextAlignment)textAlignment tag:(NSInteger)tag
{
	UITextView *textView = [[UITextView alloc] init];
    textView.text = text;
	textView.textColor = [UIColor blackColor];
	textView.font = [UIFont systemFontOfSize:size];
	textView.backgroundColor = [UIColor whiteColor];
    textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	textView.returnKeyType = UIReturnKeyDefault;
	textView.keyboardType = UIKeyboardTypeDefault;	// use the default type input method (entire keyboard)
	textView.scrollEnabled = YES;
    textView.textAlignment = textAlignment;
    textView.tag = tag;
	// note: for UITextView, if you don't like auto correction while typing use:
	// myTextView.autocorrectionType = UITextAutocorrectionTypeNo;
	
	return [textView autorelease];
}

#pragma mark - UITextField
+ (UITextField *)createTextFieldWithPlaceholder:(NSString *)text fontSize:(CGFloat)size tag:(NSInteger)kViewTag
{
	
    UITextField *textFieldRounded = [[UITextField alloc] init];
    
    textFieldRounded.borderStyle = UITextBorderStyleRoundedRect;
    textFieldRounded.textColor = [UIColor blackColor];
    textFieldRounded.font = [UIFont systemFontOfSize:size];
    textFieldRounded.placeholder = text;
    textFieldRounded.backgroundColor = [UIColor whiteColor];
    textFieldRounded.autocorrectionType = UITextAutocorrectionTypeNo;	// no auto correction support
    textFieldRounded.keyboardType = UIKeyboardTypeDefault;
    textFieldRounded.returnKeyType = UIReturnKeyDone;
    textFieldRounded.clearButtonMode = UITextFieldViewModeWhileEditing;	// has a clear 'x' button to the right
    textFieldRounded.tag = kViewTag;		// tag this control so we can remove it later for recycled cells
    
	return [textFieldRounded autorelease];
}

#pragma mark ---  UISwitch  ---
+ (UISwitch *) createSwitchWithFrame:(CGRect)frame tag:(NSInteger)kSwitchtag
{
    UISwitch *createSwitch = [[UISwitch alloc] initWithFrame:frame];
    createSwitch.backgroundColor = [UIColor clearColor];
    createSwitch.tag = kSwitchtag;
    return [createSwitch autorelease];
}

+ (KLSwitch *) createKLSwitchWithTag:(NSInteger)kSwitchtag target:(id)target selector:(SEL)selector
{
    CGRect frame = CGRectMake(0, 0, 51, 31);
    __block id weakTarget = target;
    __block SEL weakSelector = selector;
    __block KLSwitch *klswitch = [[KLSwitch alloc] initWithFrame:frame didChangeHandler:^(BOOL isOn)
    {
        if (weakTarget && [weakTarget respondsToSelector:weakSelector])
        {
            [weakTarget performSelector:weakSelector withObject:klswitch];
        }
    }];
    [klswitch setOnTintColor:SWITCHCOLOR];
    return [klswitch autorelease];
}

#pragma mark ---  UISlider  ---
+ (UISlider *) createSliderWithFrame:(CGRect)frame
                            minValue:(float)sliderMiniValue
                            maxValue:(float)sliderMaxValue
                         appearValue:(float)appearVlaue
                                 tag:(NSInteger)ktag
{
    UISlider *sliderCtl = [[UISlider alloc] initWithFrame:frame];
    sliderCtl.backgroundColor = [UIColor clearColor];
    sliderCtl.minimumValue = sliderMiniValue;
    sliderCtl.maximumValue = sliderMaxValue;
    sliderCtl.value = appearVlaue;
    sliderCtl.tag = ktag;
    sliderCtl.continuous = YES;
    return [sliderCtl autorelease];
}

+ (UISlider *) createCustomSliderWithFrame:(CGRect)frame
                                 leftTrack:(UIImage *)leftImage
                                rightTrack:(UIImage *)rightImage
                           silderBallImage:(UIImage *)ballImage
                                  minValue:(float)sliderMiniValue
                                  maxValue:(float)sliderMaxValue
                               appearValue:(float)appearVlaue
                                       tag:(NSInteger)ktag
{
    UISlider *sliderCustomCtl = [[UISlider alloc] initWithFrame:frame];
    sliderCustomCtl.backgroundColor = [UIColor clearColor];
    [sliderCustomCtl setThumbImage: ballImage forState:UIControlStateNormal];
    [sliderCustomCtl setMinimumTrackImage:leftImage forState:UIControlStateNormal];
    [sliderCustomCtl setMaximumTrackImage:rightImage forState:UIControlStateNormal];
    sliderCustomCtl.minimumValue = sliderMiniValue;
    sliderCustomCtl.maximumValue = sliderMaxValue;
    sliderCustomCtl.value = appearVlaue;
    sliderCustomCtl.continuous = YES;
    sliderCustomCtl.tag = ktag;
    return [sliderCustomCtl autorelease];
}

#pragma mark ---  UIProgressView  ---
+ (UIProgressView *) createProgressWithFrame:(CGRect)frame
                           viewProgressStyle:(UIProgressViewStyle) progressStyle
                               progressValue:(float) progress
                                         tag:(NSInteger)ktag
{
    UIProgressView *progressBar = [[UIProgressView alloc] initWithFrame:frame];
    progressBar.progressViewStyle = progressStyle;
    progressBar.progress = progress;
    progressBar.tag = ktag;	// tag this view for later so we can remove it from recycled table cells
    return [progressBar autorelease];
}

#pragma mark ---  UIPickView  ---
+ (UIPickerView *) createPickViewWithFrame : (CGRect) frame tag:(NSInteger)ktag
{
    UIPickerView *myPickerView = [[UIPickerView alloc] initWithFrame:frame];
    myPickerView.showsSelectionIndicator = YES;
    myPickerView.tag = ktag;
    return  [myPickerView autorelease];
}

#pragma mark ---  UIImageView  ---
+ (UIImageView *) createImageViewWithFrame: (CGRect) frame
                               normalImage:(UIImage *)normalImage
                                       tag:(NSInteger)ktag
{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
    imageView.image = normalImage;
    imageView.tag = ktag;
    return  [imageView autorelease];
}

#pragma mark ---  UIWebView  ---
+ (UIWebView *) createWebViewWithFrame: (CGRect) frame
                                   tag:(NSInteger)ktag
{
    UIWebView* myWebView = [[UIWebView alloc] initWithFrame:frame];
	myWebView.backgroundColor = [UIColor clearColor];
	[myWebView setOpaque:NO];
	myWebView.scalesPageToFit = YES;
	myWebView.autoresizesSubviews = YES;
	myWebView.clipsToBounds = YES;
    return [myWebView autorelease];
}

#pragma mark ---  UITableView  ---
+ (UITableView *) createTableViewWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    UITableView *myTableView = [[UITableView alloc] initWithFrame:frame style:style];
    myTableView.backgroundColor = [UIColor clearColor];
    myTableView.autoresizesSubviews = YES;
    myTableView.clipsToBounds = YES;
    return [myTableView autorelease];
}


@end

//
//  HTextVIewPlaceholder.m
//  LocaleTest
//
//  Created by huang on 13-10-15.
//  Copyright (c) 2013年 huang. All rights reserved.
//

#import "HTextVIewPlaceholder.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreText/CoreText.h>

@interface HTextVIewPlaceholder()
{
    CATextLayer *layer;
    UILabel *label;
}

@end

@implementation HTextVIewPlaceholder

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.font = [UIFont systemFontOfSize:kSize2];
        self.returnKeyType = UIReturnKeyDone;
        self.keyboardType = UIKeyboardTypeDefault;
        self.autocorrectionType = UITextAutocorrectionTypeNo;
        [self allocLabel];
        self.frame=frame;
    }
    return self;
}
-(id)init
{
    if (self=[super init]) {
        [self allocLabel];
    }
    return self;
}
-(void)allocLabel
{
    label=[[UILabel alloc] init];
    [label setBackgroundColor:[UIColor clearColor]];
    label.numberOfLines=0;
    label.lineBreakMode=UILineBreakModeWordWrap;
    label.font=[UIFont systemFontOfSize:kSize2];
    label.textColor=GETSKINCOLOR(@"PlaceholderColor");
    label.textAlignment=NSTextAlignmentLeft;
    [self addSubview:label];
    [self setPlaceholder:STR(@"TS_Describe", Localize_UserFeedback)];
    [label release];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChange:) name:UITextViewTextDidChangeNotification object:nil];

}
-(void)dealloc
{
    self.placeholder=nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}
-(void)setFont:(UIFont *)font
{
    [super setFont:font];
    if (label) {
        label.font=font;
    }
}
-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    if (label) {
        CGSize size=[label.text sizeWithFont:label.font constrainedToSize:CGSizeMake(self.bounds.size.width-10, 1000) lineBreakMode:NSLineBreakByCharWrapping];
        label.frame=CGRectMake(5, 9, size.width,size.height);
    }
}
-(void)textDidChange:(NSNotification*)notification
{
   
    if (self.text.length==0) {
        label.hidden=NO;
    }
    else
    {
        label.hidden=YES;
    }

}
-(void)setText:(NSString *)text
{
    [super setText:text];
    if (self.text.length==0) {
        label.hidden=NO;
    }
    else
    {
        label.hidden=YES;
    }

}
-(void)setPlaceholder:(NSString *)placeholder
{
    label.text=placeholder;
    CGSize size=[label.text sizeWithFont:label.font constrainedToSize:CGSizeMake(self.bounds.size.width-10, 1000) lineBreakMode:NSLineBreakByCharWrapping];
    label.frame=CGRectMake(5, 9, size.width,size.height);
}



@end

//
//  POITextField.m
//  AutoNavi
//
//  Created by huang on 13-9-8.
//
//

#import "POITextField.h"

@implementation POITextField
@synthesize imageViewTextfield;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //Initialization code
        UIView * view=[[[UIView alloc] initWithFrame:CGRectMake(0,0,30, frame.size.height)] autorelease];
        UIImage *image=IMAGE(@"POITextFeildSearchIcon.png", IMAGEPATH_TYPE_1) ;
        imageViewTextfield=[[UIImageView alloc] initWithImage:image];
        self.borderStyle=UITextBorderStyleNone;
        self.placeholder=STR(@"Main_searchPlaceholder", Localize_Main);
        self.textColor=TEXTCOLOR;
        imageViewTextfield.center=CGPointMake(15,15);
        imageViewTextfield.autoresizingMask=UIViewAutoresizingNone;
        [view addSubview:imageViewTextfield];
        self.leftView=view;
        self.leftViewMode=UITextFieldViewModeAlways;
        [imageViewTextfield release];

        self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;//设置光标在中心
        self.autoresizingMask=UIViewAutoresizingFlexibleWidth;
        self.returnKeyType=UIReturnKeySearch;
        _placeholderFontSize=kSize3;
      
    }
    return self;
}
- (void)drawPlaceholderInRect:(CGRect)rect
{
    [GETSKINCOLOR(@"PlaceholderColor") setFill];
    UIFont *font=nil;
    if (self.placeholderFont) {
        font=self.placeholderFont;
    }
    else
    {
        font=[UIFont systemFontOfSize:_placeholderFontSize];
    }
   
    [[self placeholder] drawInRect:rect withFont:font lineBreakMode:NSLineBreakByCharWrapping alignment:NSTextAlignmentLeft];
}
-(CGRect)placeholderRectForBounds:(CGRect)bounds
{
    float y=bounds.size.height=_offsetY;
    if ([[[UIDevice currentDevice] systemVersion] floatValue]>=7.0) {
//        y+=5;
    }
    //return CGRectInset(bounds, 20, 0);
    float leftView=0;
    if (self.leftView) {
        leftView=self.leftView.frame.size.width;
    }
    CGRect inset = CGRectMake(bounds.origin.x+leftView, y, bounds.size.width -50, bounds.size.height);//更好理解些
    return inset;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
-(void)dealloc
{
    self.placeholderFont=nil;
    [super dealloc];
}

@end

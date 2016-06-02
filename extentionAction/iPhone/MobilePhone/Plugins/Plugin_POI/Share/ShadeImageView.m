//
//  ShadeImageView.m
//  AutoNavi
//
//  Created by huang on 13-11-7.
//
//

#import "ShadeImageView.h"

@interface ShadeImageView ()
{
    UIButton *button;
    UIImageView *imageView;
}
@end

@implementation ShadeImageView

-(id)initWithButton:(UIButton*)_button
{
    self=[super init];
    if (self) {
        if (_button) {
            self.userInteractionEnabled=YES;
            button=_button;
            self.frame=CGRectMake(0, 0,CGRectGetWidth(_button.frame), CGRectGetHeight(_button.frame));
            [_button addSubview:self];
            UITapGestureRecognizer *tapGesture=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchImageView:)];
            [self addGestureRecognizer:tapGesture];
            [tapGesture release];
            
        }

    }
    return self;
}
-(void)touchImageView:(id)object
{
    if (button) {
        [button sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
}
-(void)dealloc
{
    
    CLOG_DEALLOC(self);
    [super dealloc];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end

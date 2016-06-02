//
//  FeedBackImageView.m
//  AutoNavi
//
//  Created by weisheng on 14-6-10.
//
//

#import "FeedBackImageView.h"

@implementation FeedBackImageView
@synthesize delegate;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        int nWide = frame.size.width;
  
        UILabel  * label = [[UILabel alloc]initWithFrame:CGRectMake(70, 20,nWide - 70, 30)];
        label.userInteractionEnabled = YES;
        label.font = [UIFont systemFontOfSize:kSize2];
        label.textColor = GETSKINCOLOR(@"PlaceholderColor");
        label.text = STR(@"TS_UpLoadPic", Localize_UserFeedback);
        [self addSubview:label];
        [label release];
        
        
        _selectButton=[UIButton buttonWithType:UIButtonTypeCustom];
        [_selectButton setFrame:CGRectMake(10,10, 50, 50)];
        [_selectButton setImage:IMAGE(@"PhotoButton.png",IMAGEPATH_TYPE_1) forState:UIControlStateNormal];
        _selectButton.userInteractionEnabled = YES;
        if (_selectImage) {
            [_selectButton setImage:_selectImage forState:UIControlStateNormal];
        }
        [self addSubview:_selectButton];
        [_selectButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

-(void)setSelectImage:(UIImage *)selectImage
{
    if (_selectImage) {
        [_selectImage release];
    }
    if (selectImage==nil) {
        _selectImage=nil;
    }
    else
    {
        _selectImage=[selectImage copy];
    }
    if (selectImage) {
        [_selectButton setImage:_selectImage forState:UIControlStateNormal];
    }
    else
    {
        [_selectButton setImage:IMAGE(@"PhotoButton.png",IMAGEPATH_TYPE_1) forState:UIControlStateNormal];
    }
}
-(void)setFrame:(CGRect)frame
{
    int nSizeOfPick = 50;
    [_selectButton setFrame:CGRectMake(10,10, nSizeOfPick, nSizeOfPick)];
    [super setFrame:frame];
}

-(void)buttonAction:(UIButton *)button
{
    if (button==_selectButton) {
        
        if (self.delegate &&[self.delegate respondsToSelector:@selector(selectImageView)]) {
            [self.delegate selectImageView];
        }
    }
 
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

//
//  FeedBackTableViewCell.m
//  AutoNavi
//
//  Created by weisheng on 14-6-12.
//
//

#import "FeedBackTableViewCell.h"

@implementation FeedBackTableViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
   
    }
    return self;
}
-(void)setBackgroundType:(GDTABLE_CELL_BACKGROUND_TYPE)backgroundType
{
    if (self.backgroundType==backgroundType ) {
        return;
    }
   // _backgroundType = backgroundType;
    NSString *name = @"";
    NSString *selectName = @"";
    int capWidth = 15;
    int capHeight = 20;
    switch (backgroundType) {
        case BACKGROUND_GROUP://输入框的背景图片
        {
            UIImage * buttonImageNormal1 =IMAGE(@"icallinput.png", IMAGEPATH_TYPE_1);
            name=@"icallinput.png";
            //selectName = @"feedBackQue.png";
            capWidth  = (buttonImageNormal1.size.width-1)/2;
            capHeight =( buttonImageNormal1.size.height-1) /2;
        }
            break;
        case BACKGROUND_FOOTER://相册的背景图片
        {
            UIImage * buttonImageNormal1s =IMAGE(@"AddImage.png", IMAGEPATH_TYPE_1);
            name = @"AddImage.png";
             //selectName = @"AddImage.png";
            capWidth  = (buttonImageNormal1s.size.width-1)/2;
            capHeight =( buttonImageNormal1s.size.height-1) /2;
        }break;
        case BACKGROUND_HEAD://意见反馈上
        {
            UIImage * buttonImageNormal1s =IMAGE(@"feedBackUp.png", IMAGEPATH_TYPE_1);
            name = @"feedBackUp.png";
           // selectName = @"feedBackUp.png";
            capWidth  = buttonImageNormal1s.size.width/2;
            capHeight = buttonImageNormal1s.size.height /2;
        }break;
        case BACKGROUND_TRACKTOP:
        {
            UIImage * buttonImageNormal1s =IMAGE(@"feedBackDown.png", IMAGEPATH_TYPE_1);
            name = @"feedBackDown.png";
           // selectName = @"feedBackDown.png";
            capWidth  = buttonImageNormal1s.size.width/2;
            capHeight = buttonImageNormal1s.size.height /2;
        }break;

        default:
            break;
    }
    
    UIImage *image=[IMAGE(name, IMAGEPATH_TYPE_1) stretchableImageWithLeftCapWidth:capWidth topCapHeight:capHeight];
    UIImageView *imageView;
    if( [self.backgroundView isMemberOfClass:[UIImageView class]])
    {
        imageView=(UIImageView*)self.backgroundView;
        imageView.image=image;
    }
    else
    {
        imageView=[[UIImageView alloc] initWithImage:image];
        self.backgroundView=imageView;
        [imageView release];
    }
    imageView.userInteractionEnabled = YES;
    if (selectName.length>0) {
        UIImage *selectImage=[IMAGE(selectName, IMAGEPATH_TYPE_1) stretchableImageWithLeftCapWidth:capWidth topCapHeight:capHeight];
        UIImageView *selectImageView;
        if ([self.selectedBackgroundView isMemberOfClass:[UIImageView class]]) {
            selectImageView=(UIImageView*)self.selectedBackgroundView;
            selectImageView.image=selectImage;
        }
        else
        {
            UIImageView *selectImageView=[[[UIImageView alloc] initWithImage:selectImage] autorelease];
            self.selectedBackgroundView=selectImageView;
        }
    }
    self.backgroundColor=[UIColor clearColor];
    
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

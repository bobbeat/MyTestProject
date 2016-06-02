//
//  GDSetFavTableCell.m
//  AutoNavi
//
//  Created by weisheng on 14-8-15.
//
//

#import "GDSetFavTableCell.h"

@implementation GDSetFavTableCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
-(void)layoutSubviews
{
    [super layoutSubviews];
    [self.accessoryView setFrame:CGRectMake(self.bounds.size.width-56, 0, 56,self.bounds.size.height)];
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

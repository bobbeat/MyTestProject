//
//  GDSettingTabelCell.m
//  AutoNavi
//
//  Created by jiangshu-fu on 14-6-19.
//
//

#import "GDSettingTabelCell.h"
#import "GDTableViewCell.h"

@implementation GDSettingTabelCell

-(void)layoutSubviews
{
    [super layoutSubviews];
    CGRect rect = CGRectMake(self.detailTextLabel.frame.origin.x - 10,
                             self.detailTextLabel.frame.origin.y,
                             self.detailTextLabel.frame.size.width,
                             self.detailTextLabel.frame.size.height);
    self.detailTextLabel.frame = rect;
}


@end

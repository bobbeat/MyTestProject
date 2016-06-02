//
//  AccountInfoCell.m
//  AutoNavi
//
//  Created by yaying.xiao on 14-10-22.
//
//

#import "AccountInfoCell.h"

@implementation AccountInfoCell

@synthesize  headImageView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        headImageView = [[UIImageView alloc] initWithImage:IMAGE(@"non_head.png",IMAGEPATH_TYPE_1)];
        [self.contentView addSubview:headImageView];
        
        self.emptyLineLength = 0;
        self.textLabel.textColor = TEXTCOLOR;
        self.textLabel.backgroundColor = GETSKINCOLOR(HUD_LABEL_CLEAR_BACK_COLOR);
        self.textLabel.font = [UIFont systemFontOfSize:16];
        
        self.detailTextLabel.textColor = TITLECOLOR;
        self.detailTextLabel.backgroundColor = GETSKINCOLOR(HUD_LABEL_CLEAR_BACK_COLOR);
        self.detailTextLabel.font = [UIFont systemFontOfSize:14];
        
    }
    return  self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect contentRect = [self.contentView bounds];
    headImageView.frame = CGRectMake(contentRect.size.width-80, 5.0, 60.0, 60.0);
    self.detailTextLabel.frame = CGRectMake(contentRect.size.width-120, 5.0, 100.0, 38.0);
    
}

- (void)dealloc
{
    [headImageView release];
    headImageView = nil;
    [super dealloc];
}


@end

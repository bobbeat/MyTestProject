//
//  TrackCountView.m
//  AutoNavi
//
//  Created by longfeng.huang on 14-6-13.
//
//

#import "TrackCountView.h"

@implementation TrackCountView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initControl];
    }
    return self;
}

- (void)initControl
{
    _topImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0., 0., 30., 30.)];
    [self addSubview:_topImageView];
    [_topImageView release];
    
    _mtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(30., 7., 100., 25.)];
    _mtitleLabel.backgroundColor = [UIColor clearColor];
    _mtitleLabel.font = [UIFont systemFontOfSize:14];
    [self addSubview:_mtitleLabel];
    [_mtitleLabel release];
    
    _symbolLabel = [[UILabel alloc] initWithFrame:CGRectMake(80., 12., 15., 15.)];
    _symbolLabel.text = @"X";
    _symbolLabel.textColor = [UIColor redColor];
    _symbolLabel.font = [UIFont systemFontOfSize:18.];
    _symbolLabel.backgroundColor = [UIColor clearColor];
    [self addSubview:_symbolLabel];
    [_symbolLabel release];
    
    _countLabel = [[UILabel alloc] initWithFrame:CGRectMake(95., 5., 50., 30.)];
    _countLabel.textColor = [UIColor colorWithRed:88/255 green:88/255 blue:88/255 alpha:1.0];
    _countLabel.font = [UIFont systemFontOfSize:30.];
    _countLabel.backgroundColor = [UIColor clearColor];
    [self addSubview:_countLabel];
    [_countLabel release];
    
    _addLabel = [[UILabel alloc] initWithFrame:CGRectMake(80., 10., 10., 10.)];
    _addLabel.text = @"+";
    _addLabel.textColor = [UIColor colorWithRed:54/255.0 green:114/255.0 blue:5/255.0 alpha:1.0];
    _addLabel.backgroundColor = [UIColor clearColor];
    [self addSubview:_addLabel];
    [_addLabel release];
    _addLabel.hidden = YES;
    
    
    
}

- (void)dealloc
{
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

//
//  TrackScoreView.m
//  AutoNavi
//
//  Created by longfeng.huang on 14-6-13.
//
//

#import "TrackScoreView.h"

@interface TrackScoreView()

@property (nonatomic, copy) NSString *imageName;
@property (nonatomic, assign) float percent;
@property (nonatomic, assign) float width;

@end

@implementation TrackScoreView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initControl];
    }
    return self;
}

- (void)initControl
{
    self.backgroundColor = [UIColor clearColor];
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0., 5., 100., 25.)];
    _titleLabel.backgroundColor = [UIColor clearColor];
    [self addSubview:_titleLabel];
    [_titleLabel release];
    
    _scoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.size.width - 100., 0., 50., 30.)];
    _scoreLabel.backgroundColor = [UIColor clearColor];
    [self addSubview:_scoreLabel];
    [_scoreLabel release];
    
    _symbolLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.size.width - 40., 10., 35., 15.)];
    _symbolLabel.backgroundColor = [UIColor clearColor];
    [self addSubview:_symbolLabel];
    [_symbolLabel release];
    
}

- (void)layoutSubviews
{
    
    [_titleLabel setFrame:CGRectMake(0., 5., 100., 25.)];
    [_scoreLabel setFrame:CGRectMake(self.bounds.size.width - 100., 0., 50., 30.)];
    [_symbolLabel setFrame:CGRectMake(self.bounds.size.width - 50., 13., 35., 15.)];
    
}

- (void)drawImageName:(NSString *)imageName precent:(float)precent width:(float)width
{
    self.imageName = imageName;
    self.percent = precent;
    self.width = width;
    
}

- (void)dealloc
{
    CRELEASE(_imageName);

    [super dealloc];
}
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    float height = self.frame.size.height;
    
    UIImage *backImage = [IMAGE(@"drivingTrackPrecentBac.png", IMAGEPATH_TYPE_1) stretchableImageWithLeftCapWidth:4
                                                                                                     topCapHeight:0];
    UIImage *percentImage = [IMAGE(self.imageName, IMAGEPATH_TYPE_1) stretchableImageWithLeftCapWidth:4
                                                                                    topCapHeight:0];
    [backImage drawInRect:CGRectMake(52.0f,
                                     height / 2 - 1,
                                     self.width,
                                     6)];
    [percentImage drawInRect:CGRectMake(52.0f,
                                        height / 2 - 1,
                                        (self.percent/100.0f) * self.width,
                                        6)];
}


@end

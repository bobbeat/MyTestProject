//
//  DrivingTrackInfoView.m
//  AutoNavi
//
//  Created by longfeng.huang on 14-6-10.
//
//

#import "DrivingTrackInfoView.h"
#import "ColorLable.h"

@implementation DrivingTrackInfoView

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
    self.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.5];
    self.userInteractionEnabled = NO;
    
    _drivingScoreLabel = [[ColorLable alloc]initWithFrame:CGRectMake(0, 0,150,44) ColorArray:[NSArray arrayWithObject:[UIColor redColor]]];
    _drivingScoreLabel.backgroundColor = GETSKINCOLOR(MAIN_LABEL_CLEARBACK_COLOR);
    _drivingScoreLabel.font = [UIFont systemFontOfSize:15];
    _drivingScoreLabel.textAlignment = NSTextAlignmentLeft;
    _drivingScoreLabel.textColor = [UIColor blackColor];
    [self addSubview:_drivingScoreLabel];
    [_drivingScoreLabel release];
    
    _totalDistanceLabel = [[ColorLable alloc]initWithFrame:CGRectMake(0, 20,150,44) ColorArray:[NSArray arrayWithObject:[UIColor redColor]]];
    _totalDistanceLabel.backgroundColor = GETSKINCOLOR(MAIN_LABEL_CLEARBACK_COLOR);
    _totalDistanceLabel.font = [UIFont systemFontOfSize:15];
    _totalDistanceLabel.textAlignment = NSTextAlignmentLeft;
    _totalDistanceLabel.textColor = [UIColor blackColor];
    [self addSubview:_totalDistanceLabel];
    [_totalDistanceLabel release];
    
    _totalTimeLabel = [[ColorLable alloc]initWithFrame:CGRectMake(0, 40,150,44) ColorArray:[NSArray arrayWithObject:[UIColor redColor]]];
    _totalTimeLabel.backgroundColor = GETSKINCOLOR(MAIN_LABEL_CLEARBACK_COLOR);
    _totalTimeLabel.font = [UIFont systemFontOfSize:15];
    _totalTimeLabel.textAlignment = NSTextAlignmentLeft;
    _totalTimeLabel.textColor = [UIColor blackColor];
    [self addSubview:_totalTimeLabel];
    [_totalTimeLabel release];
    
    _averageSpeedLabel = [[ColorLable alloc]initWithFrame:CGRectMake(0, 60,150,44) ColorArray:[NSArray arrayWithObject:[UIColor redColor]]];
    _averageSpeedLabel.backgroundColor = GETSKINCOLOR(MAIN_LABEL_CLEARBACK_COLOR);
    _averageSpeedLabel.font = [UIFont systemFontOfSize:15];
    _averageSpeedLabel.textAlignment = NSTextAlignmentLeft;
    _averageSpeedLabel.textColor = [UIColor blackColor];
    [self addSubview:_averageSpeedLabel];
    [_averageSpeedLabel release];
    
    _fuelConsumptionScoreLabel = [[ColorLable alloc]initWithFrame:CGRectMake(0, 80,150,44) ColorArray:[NSArray arrayWithObject:[UIColor redColor]]];
    _fuelConsumptionScoreLabel.backgroundColor = GETSKINCOLOR(MAIN_LABEL_CLEARBACK_COLOR);
    _fuelConsumptionScoreLabel.font = [UIFont systemFontOfSize:15];
    _fuelConsumptionScoreLabel.textAlignment = NSTextAlignmentLeft;
    _fuelConsumptionScoreLabel.textColor = [UIColor blackColor];
    [self addSubview:_fuelConsumptionScoreLabel];
    [_fuelConsumptionScoreLabel release];
    
    _safetyScoreLabel = [[ColorLable alloc]initWithFrame:CGRectMake(0, 100,150,44) ColorArray:[NSArray arrayWithObject:[UIColor redColor]]];
    _safetyScoreLabel.backgroundColor = GETSKINCOLOR(MAIN_LABEL_CLEARBACK_COLOR);
    _safetyScoreLabel.font = [UIFont systemFontOfSize:15];
    _safetyScoreLabel.textAlignment = NSTextAlignmentLeft;
    _safetyScoreLabel.textColor = [UIColor blackColor];
    [self addSubview:_safetyScoreLabel];
    [_safetyScoreLabel release];
    
    _haccelerationScoreLabel = [[ColorLable alloc]initWithFrame:CGRectMake(0, 120,150,44) ColorArray:[NSArray arrayWithObject:[UIColor redColor]]];
    _haccelerationScoreLabel.backgroundColor = GETSKINCOLOR(MAIN_LABEL_CLEARBACK_COLOR);
    _haccelerationScoreLabel.font = [UIFont systemFontOfSize:15];
    _haccelerationScoreLabel.textAlignment = NSTextAlignmentLeft;
    _haccelerationScoreLabel.textColor = [UIColor blackColor];
    [self addSubview:_haccelerationScoreLabel];
    [_haccelerationScoreLabel release];
    
    _brakesScoreLabel = [[ColorLable alloc]initWithFrame:CGRectMake(0, 140,150,44) ColorArray:[NSArray arrayWithObject:[UIColor redColor]]];
    _brakesScoreLabel.backgroundColor = GETSKINCOLOR(MAIN_LABEL_CLEARBACK_COLOR);
    _brakesScoreLabel.font = [UIFont systemFontOfSize:15];
    _brakesScoreLabel.textAlignment = NSTextAlignmentLeft;
    _brakesScoreLabel.textColor = [UIColor blackColor];
    [self addSubview:_brakesScoreLabel];
    [_brakesScoreLabel release];
    
    _uturnScoreLabel = [[ColorLable alloc]initWithFrame:CGRectMake(0, 160,150,44) ColorArray:[NSArray arrayWithObject:[UIColor redColor]]];
    _uturnScoreLabel.backgroundColor = GETSKINCOLOR(MAIN_LABEL_CLEARBACK_COLOR);
    _uturnScoreLabel.font = [UIFont systemFontOfSize:15];
    _uturnScoreLabel.textAlignment = NSTextAlignmentLeft;
    _uturnScoreLabel.textColor = [UIColor blackColor];
    [self addSubview:_uturnScoreLabel];
    [_uturnScoreLabel release];
    
    _hypervelocityScoreLabel = [[ColorLable alloc]initWithFrame:CGRectMake(0, 180,150,44) ColorArray:[NSArray arrayWithObject:[UIColor redColor]]];
    _hypervelocityScoreLabel.backgroundColor = GETSKINCOLOR(MAIN_LABEL_CLEARBACK_COLOR);
    _hypervelocityScoreLabel.font = [UIFont systemFontOfSize:15];
    _hypervelocityScoreLabel.textAlignment = NSTextAlignmentLeft;
    _hypervelocityScoreLabel.textColor = [UIColor blackColor];
    [self addSubview:_hypervelocityScoreLabel];
    [_hypervelocityScoreLabel release];
    
    _courseLabel = [[ColorLable alloc]initWithFrame:CGRectMake(0, 200,150,44) ColorArray:[NSArray arrayWithObject:[UIColor redColor]]];
    _courseLabel.backgroundColor = GETSKINCOLOR(MAIN_LABEL_CLEARBACK_COLOR);
    _courseLabel.font = [UIFont systemFontOfSize:15];
    _courseLabel.textAlignment = NSTextAlignmentLeft;
    _courseLabel.textColor = [UIColor blackColor];
    [self addSubview:_courseLabel];
    [_courseLabel release];
    
    _yawLabel = [[ColorLable alloc]initWithFrame:CGRectMake(0, 220,150,44) ColorArray:[NSArray arrayWithObject:[UIColor redColor]]];
    _yawLabel.backgroundColor = GETSKINCOLOR(MAIN_LABEL_CLEARBACK_COLOR);
    _yawLabel.font = [UIFont systemFontOfSize:15];
    _yawLabel.textAlignment = NSTextAlignmentLeft;
    _yawLabel.textColor = [UIColor blackColor];
    [self addSubview:_yawLabel];
    [_yawLabel release];
    
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

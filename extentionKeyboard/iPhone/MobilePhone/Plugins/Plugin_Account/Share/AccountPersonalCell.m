//
//  AccountPersonalCell.m
//  AutoNavi
//
//  Created by gaozhimin on 14-6-11.
//
//

#import "AccountPersonalCell.h"
#import "ControlCreat.h"

@interface AccountPersonalCell()
{
    
}

@end

@implementation AccountPersonalCell

@synthesize seeMoreLable,numberLable;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        
        UILabel *lable = [[UILabel alloc] initWithFrame:self.bounds];
        lable.backgroundColor = [UIColor clearColor];
        lable.textAlignment = NSTextAlignmentCenter;
        lable.textColor = GETSKINCOLOR(PERSONAL_SEEMORE_COLOR);;
        lable.text = STR(@"Account_SeeMore", Localize_Account);
        lable.font = [UIFont systemFontOfSize:15];
        [self addSubview:lable];
        [lable release];
        lable.hidden = YES;
        self.seeMoreLable = lable;
        
        
        lable = [[UILabel alloc] initWithFrame:self.bounds];
        lable.backgroundColor = [UIColor clearColor];
        lable.textAlignment = NSTextAlignmentLeft;
        lable.textColor = self.textLabel.textColor;
        [self addSubview:lable];
        [lable release];
        lable.hidden = YES;
        self.numberLable = lable;
        
    }
    return self;
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

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.seeMoreLable.frame = self.bounds;
    
    self.numberLable.font = self.textLabel.font;
    self.numberLable.textColor = self.detailTextLabel.textColor;
    if (self.textLabel.text)
    {
        CGSize size = [self.textLabel.text sizeWithFont:self.textLabel.font];
        
        float originX = size.width + self.textLabel.frame.origin.x + 5;
        CGRect rect =  CGRectMake(originX, 0, self.bounds.size.width - originX - 40, self.bounds.size.height);
        self.numberLable.frame = rect;
    }
    if ([self.accessoryView isKindOfClass:[UIButton class]])
    {
        [self.accessoryView setFrame:CGRectMake(self.bounds.size.width-56, 0, 56,self.bounds.size.height)];
        if (self.accessoryView.tag == 1000 || self.accessoryView.tag == 1001) //家和公司固定名称lable
        {
            CGSize size = [self.textLabel.text sizeWithFont:self.textLabel.font];
            self.detailTextLabel.frame = CGRectMake(58 + size.width, 0, self.bounds.size.width-(105 + size.width), self.bounds.size.height);
        }
    }
}
@end

@interface AccountTrackRecordCell()
{
    UIImageView *kmImageView;//距离图标
    UIImageView *timeImageView;//时间图标
    UILabel *_scoreLabel;
    UILabel *_minutesLabel;
}

@end

@implementation AccountTrackRecordCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        
        kmImageView = [[UIImageView alloc] initWithImage: IMAGE(@"PersonalKM.png", IMAGEPATH_TYPE_1)];
        [self addSubview:kmImageView];
        [kmImageView release];
        
        timeImageView = [[UIImageView alloc] initWithImage: IMAGE(@"PersonalTime.png", IMAGEPATH_TYPE_1)];
        [self addSubview:timeImageView];
        [timeImageView release];
        
        float lableLength = 45;
        _scoreLabel = [ControlCreat createLabelWithText:@"" fontSize:24 textAlignment:UITextAlignmentLeft];
        _scoreLabel.frame = CGRectMake(0, 0, lableLength, self.bounds.size.height);
        _scoreLabel.textColor = GETSKINCOLOR(PERSONAL_TRACKSCORE_COLOR);
        _scoreLabel.clipsToBounds = NO;
        [self addSubview:_scoreLabel];
        
        _minutesLabel = [ControlCreat createLabelWithText:STR(@"Account_Score", Localize_Account) fontSize:12 textAlignment:UITextAlignmentLeft];
        CGSize scoreSize = [_scoreLabel.text sizeWithFont:_scoreLabel.font];
        _minutesLabel.frame = CGRectMake(scoreSize.width, 3, 30, self.bounds.size.height);
        _minutesLabel.textColor = TEXTDETAILCOLOR;
        [_scoreLabel addSubview:_minutesLabel];

    }
    return self;
}

/**
 *	根据日期返回日期
 *
 *	@param	date	如，20120916
 *
 *	@return	返回月日，如09.16，或今天，昨天，前天
 */
- (NSString *)getDateWith:(NSString *)date
{
    if ([date length] < 8)
    {
        return date;
    }
    
    int thisyear = 0;
    NSInteger date_month = [[date substringWithRange:NSMakeRange(4, 2)] integerValue];
    NSInteger date_day = [[date substringWithRange:NSMakeRange(6, 2)] integerValue];
    NSInteger date_year = [[date substringWithRange:NSMakeRange(0, 4)] integerValue];
    
    NSDate *today = [NSDate date];
    NSCalendar  * cal = [NSCalendar  currentCalendar];
    NSUInteger  unitFlags = NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit;
    NSDateComponents * conponent= [cal components:unitFlags fromDate:today];
    NSInteger year = [conponent year];
    NSInteger month = [conponent month];
    NSInteger day = [conponent day];
    thisyear = year;
    if (year == date_year && month == date_month && day == date_day)
    {
        return STR(@"TrackToday", Localize_Track);
    }
    
    
    NSDate * yesterday = [NSDate dateWithTimeIntervalSinceNow:-86400];
    cal=[NSCalendar  currentCalendar];
    unitFlags=NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit;
    conponent= [cal components:unitFlags fromDate:yesterday];
    year = [conponent year];
    month = [conponent month];
    day = [conponent day];
    if (year == date_year && month == date_month && day == date_day)
    {
        return STR(@"TrackYesterday", Localize_Track);
    }
    
    
    NSDate * beforeYesterday = [NSDate dateWithTimeIntervalSinceNow:-86400 * 2];
    cal=[NSCalendar  currentCalendar];
    unitFlags=NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit;
    conponent= [cal components:unitFlags fromDate:beforeYesterday];
    year = [conponent year];
    month = [conponent month];
    day = [conponent day];
    if (year == date_year && month == date_month && day == date_day)
    {
        return STR(@"TrackBeforYesterday", Localize_Track);
    }
    
    if (abs(thisyear - date_year) > 0)
    {
        return [NSString stringWithFormat:@"%02d.%02d.%02d",date_year,date_month,date_day];
    }
    return [NSString stringWithFormat:@"%02d.%02d",date_month,date_day];
}

- (void)SetTrackInfo:(DrivingInfo *)trackInfo
{
    NSString *name = trackInfo.name;
    
    NSString *time = nil;
    if (trackInfo.trackTimeConsuming > 60)
    {
        time = [NSString stringWithFormat:@"%d%@%d%@",trackInfo.trackTimeConsuming/60,STR(@"Account_Hours", Localize_Account),trackInfo.trackTimeConsuming%60,STR(@"Account_Minutes", Localize_Account)];
    }
    else
    {
        time = [NSString stringWithFormat:@"%d%@",trackInfo.trackTimeConsuming,STR(@"Account_Minutes", Localize_Account)];
    }
    NSString *creatTime = nil;
    if ([trackInfo.creatTime length] > 8)
    {
        creatTime = [self getDateWith:[trackInfo.creatTime substringToIndex:8]];
    }
    self.detailTextLabel.numberOfLines = 2;
    NSString *detailInfo = [NSString stringWithFormat:@"    %.1fkm  %@      \n    %@",(double)trackInfo.trackLength/1000.0,time,creatTime];
    NSString *score = [NSString stringWithFormat:@"%.0f",trackInfo.trackScore];
    
    self.textLabel.text = name;
    self.detailTextLabel.text = detailInfo;
    _scoreLabel.text = score;
    [self layoutSubviews];
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    
    CGSize cellsize = self.bounds.size;
    _scoreLabel.frame = CGRectMake(cellsize.width-60, 0, 45, cellsize.height);
    CGSize scoreSize = [_scoreLabel.text sizeWithFont:_scoreLabel.font];
    _minutesLabel.frame = CGRectMake(scoreSize.width, 3, 20, cellsize.height);
    
    if (self.textLabel.text)
    {
        CGRect textRect = self.textLabel.frame;
        textRect.size.width = cellsize.width - 60 - textRect.origin.x;
        self.textLabel.frame = textRect;
    }
   
    if (self.detailTextLabel.text)
    {
        CGRect rect = self.detailTextLabel.frame;
        kmImageView.center = CGPointMake(rect.origin.x + kmImageView.frame.size.width/2 - 5, rect.origin.y + rect.size.height/4 );
        timeImageView.center = CGPointMake(rect.origin.x + kmImageView.frame.size.width/2 - 5, rect.origin.y + rect.size.height*3/4 );
    }
}
@end

//
//  GDStarView.m
//  AutoNavi
//
//  Created by gaozhimin on 14-6-16.
//
//

#import "GDStarView.h"
#import "ControlCreat.h"

@interface SingleStarView : UIView
{
    UIImageView *_lightStar;
    UIImageView *_darkStar;
}


@end

@implementation SingleStarView

- (instancetype)init
{
    UIImage *starimage = IMAGE(@"PersonalStarEmpty.png", IMAGEPATH_TYPE_1);
    CGRect rect = CGRectMake(0, 0, starimage.size.width, starimage.size.height);
    self = [super initWithFrame:rect];
    if (self) {
        _lightStar = [[UIImageView alloc] initWithFrame:rect];
        [self addSubview:_lightStar];
        [_lightStar release];
        
        _darkStar = [[UIImageView alloc] initWithFrame:rect];
        _darkStar.image = starimage;
        [self addSubview:_darkStar];
        [_darkStar release];
    }
    return self;
}

- (void)setPercent:(float)percent
{
    UIImage *starimage = IMAGE(@"PersonalStarFull.png", IMAGEPATH_TYPE_1);
    CGSize size = starimage.size;
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextAddRect(context, CGRectMake(0, 0, (float)percent/100.0 * size.width, size.height));
    CGContextClosePath(context);
    CGContextClip(context);
    CGContextTranslateCTM(context, 0,size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextDrawImage(context, CGRectMake(0, 0, size.width, size.height), starimage.CGImage);
    UIImage *changeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    _lightStar.image = changeImage;
    
    starimage = IMAGE(@"PersonalStarEmpty.png", IMAGEPATH_TYPE_1);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    context = UIGraphicsGetCurrentContext();
    CGContextAddRect(context, CGRectMake((float)percent/100.0 * size.width, 0, size.width - (float)percent/100.0 * size.width, size.height));
    CGContextClosePath(context);
    CGContextClip(context);
    CGContextTranslateCTM(context, 0,size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextDrawImage(context, CGRectMake(0, 0, size.width, size.height), starimage.CGImage);
    changeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    _darkStar.image = changeImage;
}
@end

@interface GDStarView()
{
    NSMutableArray *_starArray;
    int _starCount;
    int _score;
}

@end

@implementation GDStarView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)dealloc
{
    [_starArray release];
    [super dealloc];
}
/*
 *@bief初始化
 *@param count 传入星星的个数
 *@param score 传入的分数
 */
- (id)initWithCount:(int)count score:(int)score
{
    self = [super init];
    if (self)
    {
        _starCount = count;
        _score = score;
        [self initControl];
        [self SetScore:score];
    }
    return self;
}

- (void) initControl
{
    _starArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < _starCount; i++)
    {
        SingleStarView  *imageView = [[SingleStarView alloc] init];
        [self addSubview:imageView];
        [imageView release];
        [_starArray addObject:imageView];
    }
}

- (void)SetScore:(int)score
{
    if (_starCount == 0)
    {
        return;
    }
    
    _score = score;
    if (score > 0 && score <= 60)
    {
        _score = 20;
    }
    else if (score > 60 && score <= 70)
    {
        _score = 40;
    }
    else if (score > 70 && score <= 80)
    {
        _score = 60;
    }
    else if (score > 80 && score <= 90)
    {
        _score = 80;
    }
    else if (score > 90 && score <= 100)
    {
        _score = 100;
    }
    
    float percent = (float)100.0/_starCount;
    for (int i = 0; i < _starCount; i++)
    {
        SingleStarView *view = [_starArray objectAtIndex:i];
        if (_score <= 0)
        {
            [view setPercent:0];
        }
        else if (_score >= 100)
        {
            [view setPercent:100];
        }
        else
        {
            float currentPercent = i * percent;
            if (currentPercent <= _score)
            {
                if (_score - currentPercent >= percent)
                {
                    [view setPercent:100];
                }
                else
                {
                    [view setPercent:(float)(_score - currentPercent)/percent * 100];
                }
            }
        }
    }
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    if (_starCount == 0)
    {
        return;
    }
    int offsetx = frame.size.width / _starCount;
    for (int i = 0; i < _starCount; i++)
    {
        SingleStarView *view = [_starArray objectAtIndex:i];
        CGPoint center = CGPointMake(offsetx * i + offsetx/2, frame.size.height/2);
        view.center = center;
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

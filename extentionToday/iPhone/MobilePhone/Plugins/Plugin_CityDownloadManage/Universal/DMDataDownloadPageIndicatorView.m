//
//  DMDataDownloadPageIndicatorView.m
//  AutoNavi
//
//  Created by huang longfeng on 13-9-05.
//
//

#import "DMDataDownloadPageIndicatorView.h"


@implementation DMDataDownloadPageIndicatorView
@synthesize color = _color;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = NO;
    }
    return self;
}

#pragma mark - Public


#pragma mark - Private

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextClearRect(context, rect);
    
    CGContextBeginPath(context);
    CGContextMoveToPoint   (context, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGContextAddLineToPoint(context, CGRectGetMinX(rect), CGRectGetMaxY(rect));
    CGContextAddLineToPoint(context, CGRectGetMaxX(rect), CGRectGetMaxY(rect));
    CGContextAddLineToPoint(context, CGRectGetMaxX(rect), CGRectGetMinY(rect));
    CGContextClosePath(context);
    
    CGContextSetFillColorWithColor(context, GETSKINCOLOR(@"ToolBarSliderColor").CGColor);
    CGContextFillPath(context);
}
-(void)dealloc
{
    [super dealloc];
}

@end
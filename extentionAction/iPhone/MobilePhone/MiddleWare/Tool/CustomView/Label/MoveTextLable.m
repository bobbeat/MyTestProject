//
//  TextMovingLable.m
//  NewLableText
//
//  Created by gaozhimin on 12-9-26.
//  Copyright (c) 2012年 autonavi. All rights reserved.
//

#import "MoveTextLable.h"
#define COLOR_LABALE_TO_CENTER 4
#define BUFFER_LENGTH 10


@interface MoveTextLable()
{
    CGPoint m_textPosition;
    NSTimer *m_timer;
    float m_moveLength;
    float m_currentX;
    SEL m_selector;
    id m_delegate;
}

@property(nonatomic,assign) CGPoint m_textPosition;

- (void)updateTextPosition;

@end

@implementation MoveTextLable

@synthesize m_textPosition;
@synthesize mColor;
@synthesize mMoving;


- (id)init
{
    return [self initWithFrame:CGRectZero];
}

- (id)initWithFrame:(CGRect)frame delegate:(id)delegate selector:(SEL)selector
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.font = [UIFont systemFontOfSize:20];
        self.text = [NSString string];
        self.textColor = [UIColor whiteColor];
        self.backgroundColor = [UIColor clearColor];
        self.textAlignment = NSTextAlignmentCenter;
        m_moveLength = 0;
        m_currentX = 0;
        m_nStart = -1;
        m_nLength = -1;
        self.mMoving = YES;
        
        m_delegate = delegate;
        m_selector = selector;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    return [self  initWithFrame:frame delegate:nil selector:nil];
}

- (id)initLabelWithText:(NSString *)str fontSize:(CGFloat)size textAlignment:(UITextAlignment)textAlignment
{
    self = [super init];
    if (self) {
        // Initialization code
        self.font = [UIFont systemFontOfSize:size];
        self.text = str;
        self.textColor = [UIColor whiteColor];
        self.backgroundColor = [UIColor clearColor];
        self.textAlignment = textAlignment;
        m_moveLength = 0;
        m_currentX = 0;
        m_nStart = -1;
        m_nLength = -1;
        self.mMoving = YES;
    }
    return self;
}
// 设置某段字的颜色
- (void)setColor:(UIColor *)color fromIndex:(NSInteger)location length:(NSInteger)length{
//    if (location < 0||location>self.text.length-1||length+location>self.text.length) {
//        return;
//    }
//    [_attString addAttribute:(NSString *)kCTForegroundColorAttributeName
//                       value:(id)color.CGColor
//                       range:NSMakeRange(location, length)];
    if (m_colorSpecial) {
        [m_colorSpecial release];
    }
    m_colorSpecial = [color retain];
    m_nStart = location;
    m_nLength = length;
}
- (void)dealloc
{
    if (m_timer)
    {
        [m_timer invalidate];
        m_timer = nil;
    }
    if (m_colorSpecial) {
        [m_colorSpecial release];
        m_colorSpecial = nil;
    }
    m_delegate = nil;
    m_selector = nil;
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [super dealloc];
   
}

- (void)setFont:(UIFont *)font
{
    [super setFont:font];
    [self setText:self.text];
}

-(void)setMMoving:(BOOL)moving
{
    mMoving = moving;
    [self setText:self.text];
}

- (void)setText:(NSString *)text
{
    [super setText:text];
    CGSize size = [self.text sizeWithFont:self.font];
    if (self.mMoving)
    {
        if (size.width > self.bounds.size.width)
        {
            m_moveLength = size.width - self.bounds.size.width;
            
            if (m_timer == nil)
            {
                m_currentX = BUFFER_LENGTH;
                m_timer = [NSTimer scheduledTimerWithTimeInterval:0.03 target:self selector:@selector(updateTextPosition) userInfo:nil repeats:YES];
                [m_timer fire];
            }
            
        }
        else
        {
            m_currentX = 0;
            if (m_timer)
            {
                [m_timer invalidate];
                m_timer = nil;
            }
        }
    }
    else
    {
        m_currentX = 0;
        if (m_timer)
        {
            [m_timer invalidate];
            m_timer = nil;
        }
    }
    [self setTextAlignment:self.textAlignment];
}

- (void)setTextColor:(UIColor *)textColor
{
//    self.m_textColor = textColor;
    [super setTextColor:textColor];
    [self setNeedsDisplay];
}

- (void)updateTextPosition
{
    m_currentX -= 0.5;
    if (abs(m_currentX) >= m_moveLength + 2*BUFFER_LENGTH)
    {
        m_currentX = BUFFER_LENGTH;
    }
    if ([m_delegate respondsToSelector:m_selector])
    {
        [m_delegate performSelector:m_selector];
    }
    [self setNeedsDisplay];
}

- (void)ClearDelegate
{
    m_selector = nil;
    m_delegate = nil;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self setText:self.text];
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment
{
    [super setTextAlignment:textAlignment];
    CGSize size = [self.text sizeWithFont:self.font];
    //    float
    
    if (textAlignment == NSTextAlignmentLeft)
    {
        self.m_textPosition = CGPointMake(-self.bounds.size.width/2 , self.bounds.size.height/2 - size.height/2 +COLOR_LABALE_TO_CENTER);
    }
    else if(textAlignment == NSTextAlignmentCenter)
    {
        float origin_x = self.bounds.size.width/2 - size.width/2 ;
        if (origin_x <= 0)
        {
            origin_x = 0;
        }
        self.m_textPosition = CGPointMake(-self.bounds.size.width/2 + origin_x , self.bounds.size.height/2 - size.height/2 + COLOR_LABALE_TO_CENTER);
    }
    else if(textAlignment == NSTextAlignmentRight)
    {
        self.m_textPosition = CGPointMake(self.bounds.size.width/2 - size.width, self.bounds.size.height/2 - size.height/2 + COLOR_LABALE_TO_CENTER);
    }
    else
    {
        self.m_textPosition = CGPointMake(-self.bounds.size.width/2, self.bounds.size.height/2 - size.height/2 + COLOR_LABALE_TO_CENTER);
    }
    [self setNeedsDisplay];
}

// Only override drawRect: if you perform custom drawing.
- (void)drawRect:(CGRect)rect
{
    if (self.text == nil || [self.text length] == 0)
    {
        return;
    }
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, self.bounds.size.width/2,
                          self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    NSMutableAttributedString *mutaString =
    [[[NSMutableAttributedString alloc] initWithString:self.text] autorelease];
    
    [mutaString addAttribute:(NSString *)(kCTForegroundColorAttributeName)
                       value:(id)self.textColor.CGColor
                       range:[self.text rangeOfString:self.text]];
    
    CFStringRef str_ref = (CFStringRef)(self.font.fontName);
    CGFloat   pointSize = self.font.pointSize;
    CTFontRef ctFont = CTFontCreateWithName(str_ref,
                                            pointSize,
                                            NULL);
    [mutaString addAttribute:(NSString *)(kCTFontAttributeName)
                       value:(id)ctFont
                       range:[self.text rangeOfString:self.text]];
    
    CFRelease(ctFont);
    /*
     Special color
     */
    if ( m_nStart>= 0&&m_nLength<=self.text.length-1&&m_nStart+m_nLength<=self.text.length) {
        [mutaString addAttribute:(NSString *)kCTForegroundColorAttributeName
                           value:(id)m_colorSpecial.CGColor
                           range:NSMakeRange(m_nStart, m_nLength)];
    }

    CTLineRef line = CTLineCreateWithAttributedString((CFAttributedStringRef)mutaString);
    CGContextSetTextPosition(context, ceill(self.m_textPosition.x + m_currentX),
                             ceill(self.m_textPosition.y));
    CTLineDraw(line, context);
    CGContextRestoreGState(context);
    CFRelease(line);
    
}



@end

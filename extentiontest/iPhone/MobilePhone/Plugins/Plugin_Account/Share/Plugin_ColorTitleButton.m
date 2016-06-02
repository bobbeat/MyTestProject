//
//  Plugin_ColorTitleButton.m
//  AutoNavi
//
//  Created by gaozhimin on 12-12-19.
//
//

#import "Plugin_ColorTitleButton.h"

@implementation Plugin_ColorTitleButton
@synthesize m_colorTitle;
@synthesize m_color;
- (id)init
{
    return [self initWithFrame:CGRectZero];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.m_colorTitle = @"";
        [self addTarget:self action:@selector(ButtonDown) forControlEvents:UIControlEventTouchDown];
        [self addTarget:self action:@selector(ButtonUp) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside |UIControlEventTouchCancel];
        m_x = 1;
        m_y = 5;
    }
    return self;
}

- (void)dealloc
{
    if (m_colorTitle)
    {
        [m_colorTitle release];
        m_colorTitle = nil;
    }
    if (m_color)
    {
        [m_color release];
        m_color = nil;
    }
    [super dealloc];
}

- (void)ButtonUp
{
    m_x = 1;
    m_y = 5;
    [self setNeedsDisplay];
}

- (void)ButtonDown
{
    m_x = 0;
    m_y = 6;
    [self setNeedsDisplay];
}

- (void)setTitle:(NSString *)title forState:(UIControlState)state
{
    self.m_colorTitle = title;
    [self setNeedsDisplay];
}

- (void)setTitleColor:(UIColor *)color forState:(UIControlState)state
{
    self.m_color = color ;
    [self setNeedsDisplay];
}


- (NSAttributedString *)illuminatedString:(NSString *)text lightColor:(UIColor *)color font:(UIFont *)font
{
    int len = [text length];
    NSMutableAttributedString *mutaString =
    [[[NSMutableAttributedString alloc] initWithString:text] autorelease];
    
    [mutaString addAttribute:(NSString *)(kCTForegroundColorAttributeName)
                       value:(id)color.CGColor
                       range:[text rangeOfString:text]];
    
   
    [mutaString addAttribute:(NSString *)kCTUnderlineStyleAttributeName
                            value:[NSNumber numberWithInteger:kCTUnderlineStyleSingle] // 添加下化线
                            range:[text rangeOfString:text]];
    
    [mutaString addAttribute:(NSString *)kCTUnderlineColorAttributeName
                       value:(id)color.CGColor // 添加下化线
                       range:[text rangeOfString:text]];
    
    CTFontRef ctFont = CTFontCreateWithName((CFStringRef)font.fontName,
                                            font.pointSize,
                                            NULL);
    [mutaString addAttribute:(NSString *)(kCTFontAttributeName)
                       value:(id)ctFont
                       range:NSMakeRange(0, len)];
    
    
    //    CTFramesetterSuggestFrameSizeWithConstraints

    CTParagraphStyleSetting lineBreakMode;
    CTLineBreakMode lineBreak = kCTLineBreakByCharWrapping; //换行模式
    lineBreakMode.spec = kCTParagraphStyleSpecifierLineBreakMode;
    lineBreakMode.value = &lineBreak;
    lineBreakMode.valueSize = sizeof(CTLineBreakMode);
    //行间距
    CTParagraphStyleSetting LineSpacing;
    CGFloat spacing = 0.0;  //指定间距
    LineSpacing.spec = kCTParagraphStyleSpecifierLineSpacingAdjustment;
    LineSpacing.value = &spacing;
    LineSpacing.valueSize = sizeof(CGFloat);
    
    CTParagraphStyleSetting settings[] = {lineBreakMode,LineSpacing};
    CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(settings, 2);   //第二个参数为settings的长度
    [mutaString addAttribute:(NSString *)kCTParagraphStyleAttributeName
                       value:(id)paragraphStyle
                       range:NSMakeRange(0, len)];
    CFRelease(paragraphStyle);
    
    
    
    CFRelease(ctFont);
    return mutaString;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 0,
                          self.frame.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CTLineRef line = CTLineCreateWithAttributedString((CFAttributedStringRef)
                                                      [self illuminatedString:self.m_colorTitle lightColor:self.m_color  font:self.titleLabel.font]);
    
    CGContextSetTextPosition(context, ceill(m_x),
                             ceill(self.frame.size.height/2 - m_y));
    CTLineDraw(line, context);
    CGContextRestoreGState(context);
    CFRelease(line);
}

@end

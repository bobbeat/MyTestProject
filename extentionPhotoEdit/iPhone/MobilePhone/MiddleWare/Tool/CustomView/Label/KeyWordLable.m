//
//  KeyWordLable.m
//  AutoNavi
//
//  Created by gaozhimin on 12-11-14.
//
//

#define COLOR_LABALE_TO_CENTER 3

#import "KeyWordLable.h"

@interface KeyWordLable()
{
}
@end

@implementation KeyWordLable
@synthesize m_Lable_Type;

@synthesize m_HilightFlag;
@synthesize m_hilightColor;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.m_hilightColor = [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:0/255.0f alpha:1.0];
        self.clipsToBounds = NO;
        m_Lable_Type = Key_Lable;
    }
    return self;
}

- (id)init
{
    return [self initWithFrame:CGRectZero];
}

- (id)initWithType:(enum Color_Lable_Type)type
{
    self = [super init];
    if (self) {
        // Initialization code
        self.m_hilightColor = [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:0/255.0f alpha:1.0];
        self.clipsToBounds = NO;
        m_Lable_Type = type;
    }
    return self;
    
}

- (void)dealloc
{
    [m_hilightColor release];
    [super dealloc];
}

- (void)setFont:(UIFont *)font
{
    [super setFont:font];
    [self setNeedsDisplay];
}

- (void)setText:(NSString *)text
{
    [super setText:text];
    [self setTextAlignment:self.textAlignment];
}

- (void)setTextColor:(UIColor *)textColor
{
    [super setTextColor:textColor];
    [self setNeedsDisplay];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self setTextAlignment:self.textAlignment];
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment
{
    [super setTextAlignment:textAlignment];
    [self setNeedsDisplay];
}

- (void)setM_HilightFlag:(int)flag
{
    m_HilightFlag = flag;
    [self setNeedsDisplay];
}


- (NSAttributedString *)illuminatedString:(NSString *)text lightFlag:(int)flag lightColor:(UIColor *)color
{
    int len = [text length];
    NSMutableAttributedString *mutaString =
    [[[NSMutableAttributedString alloc] initWithString:text] autorelease];
    
    [mutaString addAttribute:(NSString *)(kCTForegroundColorAttributeName)
                       value:(id)self.textColor.CGColor
                       range:[text rangeOfString:text]];
    
    NSRange range;
    range.length = 1;
    BOOL sigh;
    for (int i = 0; i < len; i ++)
    {
        sigh = flag & 0x00000001;
        if (sigh)
        {
            range.location = i;
            [mutaString addAttribute:(NSString *)(kCTForegroundColorAttributeName)
                               value:(id)color.CGColor
                               range:range];
        }
        flag = flag>>1;
    }
    [mutaString addAttribute:(NSString *)(kCTForegroundColorAttributeName)
                       value:(id)self.textColor.CGColor
                       range:[text rangeOfString:@"..."]];
    
    CTFontRef ctFont = CTFontCreateWithName((CFStringRef)self.font.fontName,
                                            self.font.pointSize,
                                            NULL);
    [mutaString addAttribute:(NSString *)(kCTFontAttributeName)
                       value:(id)ctFont
                       range:NSMakeRange(0, len)];
    
    
//    CTFramesetterSuggestFrameSizeWithConstraints
    if (Key_Lable == m_Lable_Type)
    {
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
    }
    
    
    
    CFRelease(ctFont);
    return mutaString;
}

- (void)drawRect:(CGRect)rect
{
    
    
    if (!self.text)
    {
        return;
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0,
                          self.frame.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);

    if (Key_Lable == m_Lable_Type)
    {
        CFAttributedStringRef attri_str = (CFAttributedStringRef)[self illuminatedString:self.text lightFlag:self.m_HilightFlag lightColor:self.m_hilightColor];
        CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(attri_str);
        CGMutablePathRef leftColumnPath = CGPathCreateMutable();
        
        //     CTFramesetterSuggestFrameSizeWithConstraints
        CFRange ril_range;
        CGSize single_size = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, 1), NULL, self.bounds.size, &ril_range);
        CGSize real_size = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, self.text.length), NULL, self.bounds.size, &ril_range);
        int abs_height = real_size.height * 1000 - single_size.height * 1000;
        if (abs(abs_height) < 5000)
        {
            CGPathAddRect(leftColumnPath, NULL,
                          CGRectMake(0, -12,
                                     self.bounds.size.width,
                                     self.bounds.size.height));
        }
        else
        {
            if (real_size.height > 2.5*single_size.height)
            {
                CGSize temp;
                int position = self.text.length - 1;
                for (int i = 10; i < self.text.length; i++)
                {
                    temp = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, i), NULL, self.bounds.size, &ril_range);
                    if (temp.height > 2.5*single_size.height)
                    {
                        position = i;
                        break;
                    }
                }
                NSString *temp_str = nil;
                temp_str = [self.text substringWithRange:NSMakeRange(0, position - 3)];
                temp_str = [temp_str stringByAppendingString:@"..."];
                CFRelease(framesetter);
                
                attri_str = (CFAttributedStringRef)[self illuminatedString:temp_str lightFlag:self.m_HilightFlag lightColor:self.m_hilightColor];
                framesetter = CTFramesetterCreateWithAttributedString(attri_str);
                CGPathAddRect(leftColumnPath, NULL,
                              CGRectMake(0, 0,
                                         self.bounds.size.width,
                                         self.bounds.size.height));
            }
            else
            {
                CGPathAddRect(leftColumnPath, NULL,
                              CGRectMake(0, 0,
                                         self.bounds.size.width,
                                         self.bounds.size.height));
            }
            
        }
        
        CTFrameRef leftFrame = CTFramesetterCreateFrame(framesetter,
                                                        CFRangeMake(0, 0),
                                                        leftColumnPath, NULL);
        CTFrameDraw(leftFrame, context);//此处也可以单行来画，CTLineDraw
        CGPathRelease(leftColumnPath);
        CFRelease(framesetter);
        CFRelease(leftFrame);
        UIGraphicsPushContext(context);
    }
    else if(m_Lable_Type == Address_Lable)
    {
        CGSize size = [self.text sizeWithFont:self.font];
        NSString *temp_str = self.text;
        if (size.width > self.bounds.size.width)
        {
            CGSize temp;
            for (int i = 10; i < self.text.length; i++)
            {
                temp_str = [self.text substringWithRange:NSMakeRange(0, i)];
                temp_str = [temp_str stringByAppendingString:@"..."];
                temp = [temp_str sizeWithFont:self.font];
                if (temp.width > self.bounds.size.width - 12)
                {
                    break;
                }
            }
        }
        CTLineRef line = CTLineCreateWithAttributedString((CFAttributedStringRef)
                                                          [self illuminatedString:temp_str lightFlag:self.m_HilightFlag lightColor:self.m_hilightColor]);
        CGContextSetTextPosition(context, ceill(0),ceill(self.bounds.size.height/2 - 6));
        CTLineDraw(line, context);
        CGContextRestoreGState(context);
        CFRelease(line);
    }
    
    
}


@end

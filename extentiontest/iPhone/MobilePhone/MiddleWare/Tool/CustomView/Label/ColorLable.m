//
//  ColorLable.m
//  ColorLableTest
//
//  Created by gaozhimin on 12-9-18.
//  Copyright (c) 2012年 autonavi. All rights reserved.
//

#define COLOR_LABALE_TO_CENTER 3
#import "ColorLable.h"
#import "ANParamValue.h"
#import "RegexKitLite.h"

@interface ColorLable()
{
    NSArray *m_colorArray;
}
@property (nonatomic,retain) NSArray *m_colorArray;
@property (nonatomic,retain) NSMutableArray *colorTextArray;
@property (nonatomic,retain) UIFont *numFont;

@end

@implementation ColorLable

@synthesize m_colorArray,colorTextArray,bTop,lineSpace,numFont;

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame ColorArray:nil];
}

- (id)initWithFrame:(CGRect)frame ColorArray:(NSArray *)color_array
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor grayColor];
        self.m_colorArray = color_array;
        self.font = [UIFont systemFontOfSize:15];
        self.text = [NSString string];
        self.textColor = [UIColor whiteColor];
        self.colorTextArray = [NSMutableArray array];
        self.lineSpace = 1.0f;
        self.numFont = nil;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame ColorArray:(NSArray *)color_array TextFontArray:(UIFont *)tempNumFont
{
    self = [self initWithFrame:frame ColorArray:color_array];
    if (self) {
        self.numFont = tempNumFont;
    }
    return self;
}

- (id)init
{
    return  [self initWithFrame:CGRectZero ColorArray:[NSArray arrayWithObjects:
                                                       [UIColor colorWithRed:1.0 green:0.0 blue:0 alpha:1.0],
                                                       nil]];
}

- (void)setColorText:(NSString *)text,...;
{
    [self.colorTextArray removeAllObjects];
    va_list list;
    va_start(list, text);
    
    NSString *string=text;//va_arg(list, (NSString*));
    while (string) {
        [self.colorTextArray addObject:string];
        string= va_arg(list,NSString*);
    }
    va_end(list);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self setTextAlignment:self.textAlignment];
}

-(void)dealloc
{
    self.colorTextArray = nil;
    self.m_colorArray = nil;
    self.numFont = nil;
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

- (NSAttributedString *)illuminatedString:(NSString *)text
                                     font:(UIFont *)AtFont
{

    int len = [text length];
    NSMutableAttributedString *mutaString =
    [[[NSMutableAttributedString alloc] initWithString:text] autorelease];
    
    [mutaString addAttribute:(NSString *)(kCTForegroundColorAttributeName)
                       value:(id)self.textColor.CGColor
                       range:[text rangeOfString:text]];
    
    CTFontRef ctFont = CTFontCreateWithName((CFStringRef)AtFont.fontName,
                                            AtFont.pointSize,
                                            NULL);
    [mutaString addAttribute:(NSString *)(kCTFontAttributeName)
                       value:(id)ctFont
                       range:NSMakeRange(0, len)];
    CFRelease(ctFont);
    
    NSArray *num_array = nil;
    if ([self.colorTextArray count] != 0)
    {
        num_array = self.colorTextArray;
    }
    else
    {
        num_array = [text componentsMatchedByRegex:@"[0-9]{1,}[.]{1,1}[0-9]{1,}|[0-9]{1,}"];
    }
    
    NSRange searchRange = NSMakeRange(0, len);
    
    for (int i = 0; i < [num_array count]; i++)
    {
        NSString *str = [num_array objectAtIndex:i];
        UIColor *temp_color = self.textColor;
        if ([self.m_colorArray count] > 0)
        {
            int select_color =  i%[self.m_colorArray count];
            temp_color = [self.m_colorArray objectAtIndex:select_color];
        }
        [mutaString addAttribute:(NSString *)(kCTForegroundColorAttributeName)
                           value:(id)(temp_color.CGColor)
                           range:[text rangeOfString:str options:NSCaseInsensitiveSearch range:searchRange]];
        
        if( self.numFont )
        {
            CTFontRef ctFont1 = CTFontCreateWithName((CFStringRef)self.numFont.fontName,
                                                     self.numFont.pointSize,
                                                     NULL);
            [mutaString addAttribute:(NSString *)(kCTFontAttributeName)
                               value:(id)ctFont1
                               range:[text rangeOfString:str options:NSCaseInsensitiveSearch range:searchRange]];
            CFRelease(ctFont1);
        }
        
        NSRange curRange = [self.text rangeOfString:str options:NSCaseInsensitiveSearch range:searchRange];
        searchRange.location = curRange.location + curRange.length;
        searchRange.length = len - searchRange.location;
    }
    
    CTLineBreakMode lineBreakMode = kCTLineBreakByWordWrapping;//换行模式
    
    
    CTTextAlignment alignment = self.textAlignment;//对齐方式
    if (self.textAlignment == NSTextAlignmentCenter)
    {
        alignment = kCTTextAlignmentCenter;
    }
    else if (self.textAlignment == NSTextAlignmentRight)
    {
        alignment = kCTTextAlignmentRight;
    }
    float lineSpacing = lineSpace;//行间距
    
    CTParagraphStyleSetting paraStyles[3] = {
        
        {.spec = kCTParagraphStyleSpecifierLineBreakMode,.valueSize = sizeof(CTLineBreakMode), .value = (const void*)&lineBreakMode},
        
        {.spec = kCTParagraphStyleSpecifierAlignment,.valueSize = sizeof(CTTextAlignment), .value = (const void*)&alignment},
        
        {.spec = kCTParagraphStyleSpecifierLineSpacing,.valueSize = sizeof(CGFloat), .value = (const void*)&lineSpacing},
    };
    
    CTParagraphStyleRef style = CTParagraphStyleCreate(paraStyles,3);
    
    [mutaString addAttribute:(NSString*)(kCTParagraphStyleAttributeName) value:(id)style range:NSMakeRange(0,[text length])];
    
    CFRelease(style);
    
    return [[mutaString copy] autorelease];
    
}

- (void)drawRect:(CGRect)rect
{
    if ([self.text length] == 0)
    {
        return;
    }
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 0,
                          self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CFAttributedStringRef attri_str = (CFAttributedStringRef)[self illuminatedString:self.text font:self.font];
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(attri_str);
    CGMutablePathRef leftColumnPath = CGPathCreateMutable();
    
    CGSize size = self.bounds.size;
    
    CFRange ril_range;
    CGSize real_size = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, self.text.length), NULL, size, &ril_range);
    
     CGSize all_size = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, self.text.length), NULL, CGSizeMake(size.width, 1000), &ril_range);
    
    if (real_size.height == 0)
    {
        [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, all_size.height + 1)];
    }
    
    if (all_size.height * 1000 > real_size.height * 1000 && real_size.height > 0)
    {
        CGSize temp;
        int position = self.text.length - 1;
        for (int i = 1; i < self.text.length; i++)
        {
            temp = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, i), NULL, CGSizeMake(size.width, 1000), &ril_range);
            if (temp.height * 1000 > real_size.height * 1000)
            {
                position = i;
                break;
            }
        }
        NSString *temp_str = nil;
        if (position >= 3)
        {
            temp_str = [self.text substringWithRange:NSMakeRange(0, position - 3)];
            temp_str = [temp_str stringByAppendingString:@"..."];
            CFRelease(framesetter);
            
            attri_str = (CFAttributedStringRef)[self illuminatedString:temp_str font:self.font];
            framesetter = CTFramesetterCreateWithAttributedString(attri_str);
            CGPathAddRect(leftColumnPath, NULL,
                          CGRectMake(0, size.height/2 - real_size.height/2,
                                     size.width,
                                     real_size.height+1));
        }
    }
    else
    {
        if (self.bTop)
        {
            CGPathAddRect(leftColumnPath, NULL,
                          CGRectMake(0, size.height - real_size.height,
                                     size.width,
                                     real_size.height +1 ));
        }
        else
        {
            CGPathAddRect(leftColumnPath, NULL,
                          CGRectMake(0, size.height/2 - real_size.height/2,
                                     size.width,
                                     real_size.height +1 ));
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

@end

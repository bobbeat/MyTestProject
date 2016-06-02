//
//  WarningView.m
//  ImageTest
//
//  Created by gaozhimin on 13-9-14.
//  Copyright (c) 2013年 autonavi. All rights reserved.
//

#import "WarningLable.h"
#import <CoreText/CoreText.h>


@interface WarningLable()
{
    BOOL touchBegin;            //可点击字体部分是否被点击
}

@property (nonatomic,copy) NSString *clickContent;
@property (nonatomic,assign) id<warningLableDelegate> warningDelegate;

@end

@implementation WarningLable

@synthesize clickContent,warningDelegate;

- (void)dealloc
{
    self.clickContent = nil;
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame 
{
    return [self initWithFrame:frame clickContent:nil delegate:nil];
}

- (id)initWithFrame:(CGRect)frame clickContent:(NSString *)content delegate:(id<warningLableDelegate>)delegate
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = RGBCOLOR(237, 237, 237);
        self.clickContent = content;
        self.userInteractionEnabled = YES;
        self.warningDelegate = delegate;
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self setNeedsDisplay];
}

- (void)setText:(NSString *)text
{
    [super setText:text];
    [self setNeedsDisplay];
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment
{
    [super setTextAlignment:textAlignment];
    [self setNeedsDisplay];
}

- (void)setTextColor:(UIColor *)textColor
{
    [super setTextColor:textColor];
    [self setNeedsDisplay];
}

- (void)setFont:(UIFont *)font
{
    [super setFont:font];
    [self setNeedsDisplay];
}

- (NSMutableAttributedString *)illuminatedString:(NSString *)text
                                     font:(UIFont *)AtFont
{
    
    int len = [text length];
    NSMutableAttributedString *mutaString =
    [[[NSMutableAttributedString alloc] initWithString:text] autorelease];
    
    [mutaString addAttribute:(NSString *)(kCTForegroundColorAttributeName)
                       value:(id)self.textColor.CGColor
                       range:[text rangeOfString:text]];
    
    
    [mutaString addAttribute:(NSString *)(kCTForegroundColorAttributeName)
                       value:(id)GETSKINCOLOR(WARNING_PRESS_COLOR).CGColor
                       range:[text rangeOfString:self.clickContent]];
    
    [mutaString addAttribute:(NSString *)kCTUnderlineStyleAttributeName
                       value:[NSNumber numberWithInteger:kCTUnderlineStyleSingle] // 添加下化线
                       range:[text rangeOfString:self.clickContent]];
    
    [mutaString addAttribute:(NSString *)kCTUnderlineColorAttributeName
                       value:(id)GETSKINCOLOR(WARNING_PRESS_COLOR).CGColor // 添加下化线颜色
                       range:[text rangeOfString:self.clickContent]];
    
    int languageOff = 0;

    
    CTFontRef ctFont = CTFontCreateWithName((CFStringRef)AtFont.fontName,
                                            AtFont.pointSize - languageOff,
                                            NULL);
    [mutaString addAttribute:(NSString *)(kCTFontAttributeName)
                       value:(id)ctFont
                       range:NSMakeRange(0, len)];
    
    CFRelease(ctFont);
    
    CTLineBreakMode lineBreakMode = kCTLineBreakByWordWrapping;//换行模式
    
    CTTextAlignment alignment = kCTLeftTextAlignment;//对齐方式
    
    CGFloat lineSpacing = 6.0 + iPhoneOffset / 15.0f;//行间距
    if(!IOS_7)
    {
        lineSpacing = 6.0 + iPhoneOffset / 20.0f;//行间距
    }
    if (isPad)
    {
        lineSpacing = 30.0;
    }

    
    CTParagraphStyleSetting paraStyles[3] = {
        
        {.spec = kCTParagraphStyleSpecifierLineBreakMode,.valueSize = sizeof(CTLineBreakMode), .value = (const void*)&lineBreakMode},
        
        {.spec = kCTParagraphStyleSpecifierAlignment,.valueSize = sizeof(CTTextAlignment), .value = (const void*)&alignment},
        
        {.spec = kCTParagraphStyleSpecifierMinimumLineSpacing,.valueSize = sizeof(CGFloat), .value = (const void*)&lineSpacing},
    };
    
    CTParagraphStyleRef style = CTParagraphStyleCreate(paraStyles,3);
        
    [mutaString addAttribute:(NSString*)(kCTParagraphStyleAttributeName) value:(id)style range:NSMakeRange(0,[text length])];
    
    CFRelease(style);

    
    return [[mutaString copy] autorelease];
    
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 0,
                          self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CFAttributedStringRef attri_str = (CFAttributedStringRef)[self illuminatedString:self.text font:self.font];
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(attri_str);
    CGMutablePathRef leftColumnPath = CGPathCreateMutable();
    
    CGPathAddRect(leftColumnPath, NULL,self.bounds);
    
    CTFrameRef leftFrame = CTFramesetterCreateFrame(framesetter,
                                                    CFRangeMake(0, 0),
                                                    leftColumnPath, NULL);
    CTFrameDraw(leftFrame, context);//此处也可以单行来画，CTLineDraw
    CGPathRelease(leftColumnPath);
    CFRelease(framesetter);
    CFRelease(leftFrame);
    UIGraphicsPushContext(context);
}

//获取文字行宽
- (CGFloat)boundingWidthForHeight
{
    NSMutableAttributedString* optimizedAttributedText = (NSMutableAttributedString*)[self illuminatedString:self.text font:self.font];
    CTFramesetterRef framesetter =CTFramesetterCreateWithAttributedString( (CFMutableAttributedStringRef) optimizedAttributedText);
    CGSize suggestedSize =CTFramesetterSuggestFrameSizeWithConstraints(framesetter,CFRangeMake(0, 0), NULL,CGSizeMake(CGFLOAT_MAX, self.bounds.size.height), NULL);
    CFRelease(framesetter);
    return suggestedSize.width;
}

//获取文字总高度
- (CGFloat)boundingHeightForWidth
{
    NSMutableAttributedString* optimizedAttributedText = (NSMutableAttributedString*)[self illuminatedString:self.text font:self.font];
    CTFramesetterRef framesetter =CTFramesetterCreateWithAttributedString( (CFMutableAttributedStringRef) optimizedAttributedText);
    CGSize suggestedSize =CTFramesetterSuggestFrameSizeWithConstraints(framesetter,CFRangeMake(0, 0), NULL,CGSizeMake(self.bounds.size.width, CGFLOAT_MAX), NULL);
    CFRelease(framesetter);
    return suggestedSize.height;
}

- (CFIndex)characterIndexAtPoint:(CGPoint)point {
    ////////
    NSMutableAttributedString* optimizedAttributedText = (NSMutableAttributedString*)[self illuminatedString:self.text font:self.font];;
    
    
    if (!CGRectContainsPoint(self.bounds, point)) {
        return NSNotFound;
    }
    
    // Offset tap coordinates by textRect origin to make them relative to the origin of frame
    point = CGPointMake(point.x - self.bounds.origin.x, point.y - self.bounds.origin.y);
    // Convert tap coordinates (start at top left) to CT coordinates (start at bottom left)
    point = CGPointMake(point.x, self.bounds.size.height - point.y);
    
    //////
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)optimizedAttributedText);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, self.bounds);
    
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, [self.text length]), path, NULL);
    CFRelease(framesetter);
    if (frame == NULL) {
        CFRelease(path);
        return NSNotFound;
    }
    
    CFArrayRef lines = CTFrameGetLines(frame);
    
    NSInteger numberOfLines = CFArrayGetCount(lines);
    
    //NSLog(@"num lines: %d", numberOfLines);
    
    if (numberOfLines == 0) {
        CFRelease(frame);
        CFRelease(path);
        return NSNotFound;
    }
    
    NSUInteger idx = NSNotFound;
    
    CGPoint lineOrigins[numberOfLines];
    CTFrameGetLineOrigins(frame, CFRangeMake(0, numberOfLines), lineOrigins);
    
    for (CFIndex lineIndex = 0; lineIndex < numberOfLines; lineIndex++) {
        
        CGPoint lineOrigin = lineOrigins[lineIndex];
        CTLineRef line = CFArrayGetValueAtIndex(lines, lineIndex);
        
        // Get bounding information of line
        CGFloat ascent, descent, leading, width;
        width = CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
        CGFloat yMin = floor(lineOrigin.y - descent);
        CGFloat yMax = ceil(lineOrigin.y + ascent);
        
        // Check if we've already passed the line
        if (point.y > yMax) {
            break;
        }
        
        // Check if the point is within this line vertically
        if (point.y >= yMin) {
            
            // Check if the point is within this line horizontally
            if (point.x >= lineOrigin.x && point.x <= lineOrigin.x + width) {
                
                // Convert CT coordinates to line-relative coordinates
                CGPoint relativePoint = CGPointMake(point.x - lineOrigin.x, point.y - lineOrigin.y);
                idx = CTLineGetStringIndexForPosition(line, relativePoint);
                
                break;
            }
        }
    }
    
    CFRelease(frame);
    CFRelease(path);
    
    return idx;
}

#pragma mark --

- (CGRect)textRect {
    
    CGRect textRect = [self textRectForBounds:self.bounds limitedToNumberOfLines:self.numberOfLines];
    textRect.origin.y = (self.bounds.size.height - textRect.size.height)/2;
    
    if (self.textAlignment == NSTextAlignmentCenter) {
        textRect.origin.x = (self.bounds.size.width - textRect.size.width)/2;
    }
    if (self.textAlignment == NSTextAlignmentRight) {
        textRect.origin.x = self.bounds.size.width - textRect.size.width;
    }
    
    return textRect;
}


#pragma mark --

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.warningDelegate == nil)
    {
        return;
    }
    UITouch *touch = [touches anyObject];
    CFIndex index = [self characterIndexAtPoint:[touch locationInView:self]];
    touchBegin = NO;
    NSLog(@"characterIndexAtPoint %ld",index);
    NSRange clickRange = [self.text rangeOfString:self.clickContent];
    if (NSLocationInRange(index, clickRange))
    {
        touchBegin = YES;
        [self setNeedsDisplay];
    }

    
    [super touchesBegan:touches withEvent:event];
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.warningDelegate == nil)
    {
        return;
    }
    UITouch *touch = [touches anyObject];
    CFIndex index = [self characterIndexAtPoint:[touch locationInView:self]];
    NSRange clickRange = [self.text rangeOfString:self.clickContent];
    if (NSLocationInRange(index, clickRange) && touchBegin)
    {
        if ([self.warningDelegate respondsToSelector:@selector(clickContentSuccessWith:)])
        {
            [self.warningDelegate clickContentSuccessWith:self];
        }
    }
    touchBegin = NO;
    [self setNeedsDisplay];
    [super touchesEnded:touches withEvent:event];
}


@end

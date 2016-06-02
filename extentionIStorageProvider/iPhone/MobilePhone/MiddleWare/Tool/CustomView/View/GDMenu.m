//
//  GDMenu.h
//  AutoNavi
//
//  Created by huang longfeng on 13-8-29.
//
//

#import "GDMenu.h"
#import <QuartzCore/QuartzCore.h>
#import "GDSkinColor.h"

#define MENUWIDTH 310

const CGFloat kArrowSize = 12.f;

@interface GDMenuView : UIView
@end

@interface GDMenuOverlay : UIView
@end

@implementation GDMenuOverlay

// - (void) dealloc { NSLog(@"dealloc %@", self); }

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0. alpha:0.4];
        self.opaque = NO;
    }
    return self;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UIView *touched = [[touches anyObject] view];
    if (touched == self) {
        
        for (UIView *v in self.subviews) {
            if ([v isKindOfClass:[GDMenuView class]]
                && [v respondsToSelector:@selector(dismissMenu:)]) {
                
                [v performSelector:@selector(dismissMenu:) withObject:@(YES)];
            }
        }
    }
}

@end


@implementation GDMenuItem

+ (instancetype) menuItem:(NSString *) title
                    image:(UIImage *) image
                   target:(id)target
                   action:(SEL) action
{
    return [[[GDMenuItem alloc] init:title
                              image:image
                             target:target
                             action:action] autorelease];
}

- (id) init:(NSString *) title
      image:(UIImage *) image
     target:(id)target
     action:(SEL) action
{
    NSParameterAssert(title.length || image);
    
    self = [super init];
    if (self) {
        
        self.title = title;
        self.image = image;
        _target = target;
        _action = action;
    }
    return self;
}

- (BOOL) enabled
{
    return _target != nil && _action != NULL;
}

- (void) performAction
{
    __strong id target = self.target;
    
    if (target && [target respondsToSelector:_action]) {
        
        [target performSelectorOnMainThread:_action withObject:self waitUntilDone:YES];
    }
}

- (NSString *) description
{
    return [NSString stringWithFormat:@"<%@ #%p %@>", [self class], self, _title];
}

- (void)dealloc{
    if (_image) {
        [_image release];
        _image = nil;
    }
    if (_title) {
        [_title release];
        _title = nil;
    }
   
    [super dealloc];
}
@end

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

typedef enum {
  
    GDMenuViewArrowDirectionNone,
    GDMenuViewArrowDirectionUp,
    GDMenuViewArrowDirectionDown,
    GDMenuViewArrowDirectionLeft,
    GDMenuViewArrowDirectionRight,
    
} GDMenuViewArrowDirection;

@implementation GDMenuView {
    
    GDMenuViewBackgroundType    _backgroundType;
    GDMenuViewArrowDirection    _arrowDirection;
    CGFloat                     _arrowPosition;
    UIView                      *_contentView;
    NSArray                     *_menuItems;
    UIScrollView                *scrollerView;
    GDMenuOverlay               *overlay;
    BOOL                        isAnimated;
}

- (id)init
{
    self = [super initWithFrame:CGRectZero];    
    if(self) {

        self.backgroundColor = [UIColor clearColor];
        self.opaque = YES;
        self.alpha = 0;
        self.clipsToBounds = YES;
        isAnimated = NO;
        
        self.layer.shadowOpacity = 0.5;
        self.layer.shadowOffset = CGSizeMake(2, 2);
        self.layer.shadowRadius = 2;
    }
    
    return self;
}

- (void) dealloc {
     if (_menuItems) {
         [_menuItems release];
         _menuItems = nil;
     }
     [super dealloc];
}

- (void) setupFrameInView:(UIView *)view
                 fromRect:(CGRect)fromRect
{
    const CGSize contentSize = _contentView.frame.size;
    
    const CGFloat outerWidth = view.bounds.size.width;
    const CGFloat outerHeight = view.bounds.size.height;
    
    const CGFloat rectX0 = fromRect.origin.x;
    const CGFloat rectX1 = fromRect.origin.x + fromRect.size.width;
    const CGFloat rectXM = fromRect.origin.x + fromRect.size.width * 0.5f;
    const CGFloat rectY0 = fromRect.origin.y;
    const CGFloat rectY1 = fromRect.origin.y + fromRect.size.height;
    const CGFloat rectYM = fromRect.origin.y + fromRect.size.height * 0.5f;;
    
    const CGFloat widthPlusArrow = contentSize.width + kArrowSize;
    const CGFloat heightPlusArrow = contentSize.height + kArrowSize;
    const CGFloat widthHalf = contentSize.width * 0.5f;
    const CGFloat heightHalf = contentSize.height * 0.5f;
    
    const CGFloat kMargin = 5.f;
    
    if (heightPlusArrow < (outerHeight - rectY1)) {
    
        _arrowDirection = GDMenuViewArrowDirectionUp;
        CGPoint point = (CGPoint){
            rectXM - widthHalf,
            rectY1
        };
        
        if (point.x < kMargin)
            point.x = kMargin;
        
        if ((point.x + contentSize.width + kMargin) > outerWidth)
            point.x = outerWidth - contentSize.width - kMargin;
        
        _arrowPosition = rectXM - point.x;
        //_arrowPosition = MAX(16, MIN(_arrowPosition, contentSize.width - 16));        
        _contentView.frame = (CGRect){0, kArrowSize, contentSize};
                
        self.frame = (CGRect) {
            
            point,
            contentSize.width,
            contentSize.height + kArrowSize
        };
        
    } else if (heightPlusArrow < rectY0) {
        
        _arrowDirection = GDMenuViewArrowDirectionDown;
        CGPoint point = (CGPoint){
            rectXM - widthHalf,
            rectY0 - heightPlusArrow
        };
        
        if (point.x < kMargin)
            point.x = kMargin;
        
        if ((point.x + contentSize.width + kMargin) > outerWidth)
            point.x = outerWidth - contentSize.width - kMargin;
        
        _arrowPosition = rectXM - point.x;
        _contentView.frame = (CGRect){CGPointZero, contentSize};
        
        self.frame = (CGRect) {
            
            point,
            contentSize.width,
            contentSize.height + kArrowSize
        };
        
    } else if (widthPlusArrow < (outerWidth - rectX1)) {
        
        _arrowDirection = GDMenuViewArrowDirectionLeft;
        CGPoint point = (CGPoint){
            rectX1,
            rectYM - heightHalf
        };
        
        if (point.y < kMargin)
            point.y = kMargin;
        
        if ((point.y + contentSize.height + kMargin) > outerHeight)
            point.y = outerHeight - contentSize.height - kMargin;
        
        _arrowPosition = rectYM - point.y;
        _contentView.frame = (CGRect){kArrowSize, 0, contentSize};
        
        self.frame = (CGRect) {
            
            point,
            contentSize.width + kArrowSize,
            contentSize.height
        };
        
    } else if (widthPlusArrow < rectX0) {
        _arrowDirection = GDMenuViewArrowDirectionDown;
        CGPoint point = (CGPoint){
            rectXM - widthHalf,
            rectY0 - 200
        };
        
        if (point.x < kMargin)
            point.x = kMargin;
        
        if ((point.x + contentSize.width + kMargin) > outerWidth)
            point.x = outerWidth - contentSize.width - kMargin;
        
        _arrowPosition = rectXM - point.x;
        _contentView.frame = (CGRect){CGPointZero, contentSize};
        
        self.frame = (CGRect) {
            
            point,
            contentSize.width,
            200
        };
        
//        _arrowDirection = GDMenuViewArrowDirectionRight;
//        CGPoint point = (CGPoint){
//            rectX0 - widthPlusArrow,
//            rectYM - heightHalf
//        };
//        
//        if (point.y < kMargin)
//            point.y = kMargin;
//        
//        if ((point.y + contentSize.height + 5) > outerHeight)
//            point.y = outerHeight - contentSize.height - kMargin;
//        
//        _arrowPosition = rectYM - point.y;
//        _contentView.frame = (CGRect){CGPointZero, contentSize};
//        
//        self.frame = (CGRect) {
//            
//            point,
//            contentSize.width  + kArrowSize,
//            contentSize.height
//        };
        
    } else {
        
        _arrowDirection = GDMenuViewArrowDirectionNone;
        
        self.frame = (CGRect) {
            
            (outerWidth - contentSize.width)   * 0.5f,
            (outerHeight - contentSize.height) * 0.5f,
            contentSize,
        };
    }    
}

- (void)AutoSetUpFrameInView:(UIView *)view fromRect:(CGRect)rect
{
    if (self.superview) {
        [self setupFrameInView:view fromRect:rect];
        [scrollerView setFrame:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height-12.0)];
        
        [overlay setFrame:view.bounds];
    }
}

- (void)showMenuInView:(UIView *)view
              fromRect:(CGRect)rect
             menuItems:(NSArray *)menuItems
        backgroundType:(GDMenuViewBackgroundType)type
 
{
    
    _backgroundType = type;
    _menuItems = [menuItems retain];
    
    _contentView = [self mkContentView];
    
    [self setupFrameInView:view fromRect:rect];
    
    scrollerView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height-12.0)];
    scrollerView.scrollEnabled = YES;
    [scrollerView setContentSize:CGSizeMake(self.frame.size.width, _contentView.frame.size.width-4.0)];
    [scrollerView addSubview:_contentView];
   
    
    [self addSubview:scrollerView];
    [scrollerView release];
        
    overlay = [[GDMenuOverlay alloc] initWithFrame:view.bounds];
    [overlay addSubview:self];
    [view addSubview:overlay];
    [overlay release];
    
    _contentView.hidden = YES;
    const CGRect toFrame = self.frame;
    self.frame = (CGRect){self.arrowPoint, 1, 1};
    
    [UIView animateWithDuration:0.2
                     animations:^(void) {
                         
                         self.alpha = 1.0f;
                         self.frame = toFrame;
                         
                     } completion:^(BOOL completed) {
                         _contentView.hidden = NO;
                     }];
   
}

- (void)dismissMenu:(BOOL) animated
{
    if (self.superview) {
     
        if (animated) {
            
            _contentView.hidden = YES;            
            const CGRect toFrame = (CGRect){self.arrowPoint, 1, 1};
            
            [UIView animateWithDuration:0.3
                             animations:^(void) {
                                 isAnimated = YES;
                                 self.alpha = 0;
                                 self.frame = toFrame;
                                 
                             } completion:^(BOOL finished) {
                                 isAnimated = NO;
                                 if ([self.superview isKindOfClass:[GDMenuOverlay class]])
                                     [self.superview removeFromSuperview];
                                 [self removeFromSuperview];
                             }];
            
        } else {
            
            if ([self.superview isKindOfClass:[GDMenuOverlay class]])
                [self.superview removeFromSuperview];
            [self removeFromSuperview];
        }
    }
}

- (void)performAction:(id)sender
{
    if (isAnimated) {
        return;
    }
    [self dismissMenu:YES];
    
    UIButton *button = (UIButton *)sender;
    GDMenuItem *menuItem = _menuItems[button.tag];
    [menuItem performAction];
}

- (UIView *) mkContentView
{
    for (UIView *v in self.subviews) {
        [v removeFromSuperview];
    }
    
    if (!_menuItems.count)
        return nil;
 
    const CGFloat kMinMenuItemHeight = 42.f;
    const CGFloat kMinMenuItemWidth = 32.f;
    const CGFloat kMarginX = 10.f;
    const CGFloat kMarginY = 0.f;
    
    UIFont *titleFont = [GDMenu titleFont];
    if (!titleFont) titleFont = [UIFont boldSystemFontOfSize:18];
    
    CGFloat maxImageWidth = 0;    
    CGFloat maxItemHeight = 0;
    CGFloat maxItemWidth = 0;
    
    for (GDMenuItem *menuItem in _menuItems) {
        
        const CGSize imageSize = menuItem.image.size;        
        if (imageSize.width > maxImageWidth)
            maxImageWidth = imageSize.width;        
    }
    
    for (GDMenuItem *menuItem in _menuItems) {

        const CGSize titleSize = [menuItem.title sizeWithFont:titleFont];
        const CGSize imageSize = menuItem.image.size;

        const CGFloat itemHeight = MAX(titleSize.height, imageSize.height) + kMarginY * 2;
        const CGFloat itemWidth = (menuItem.image ? maxImageWidth + kMarginX : 0) + titleSize.width + kMarginX * 4;
        
        if (itemHeight > maxItemHeight)
            maxItemHeight = itemHeight;
        
        if (itemWidth > maxItemWidth)
            maxItemWidth = itemWidth;
    }
       
    maxItemWidth  = MAX(maxItemWidth, kMinMenuItemWidth);
    maxItemHeight = MAX(maxItemHeight, kMinMenuItemHeight);

    const CGFloat titleX = kMarginX * 2 + (maxImageWidth > 0 ? maxImageWidth + kMarginX : 0);
    //const CGFloat titleWidth = maxItemWidth - titleX - kMarginX;
    
    UIImage *selectedImage = [IMAGE(@"ButtonHightlightBac.png", IMAGEPATH_TYPE_1) stretchableImageWithLeftCapWidth:1 topCapHeight:0];
    UIImage *gradientLine = [IMAGE(@"menulandscapeGrayLine.png", IMAGEPATH_TYPE_1) stretchableImageWithLeftCapWidth:1 topCapHeight:0];
    
    CGFloat lineWidth = 0.0f;
    if (_backgroundType == GDMenuViewBackgroundTypeBlack) {
        lineWidth = 130.;
    }
    else{
        lineWidth = 310.f;
    }
    UIImage *blackLine = [IMAGE(@"blackGrayLine.png", IMAGEPATH_TYPE_1) stretchableImageWithLeftCapWidth:1 topCapHeight:0];
    
    
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectZero];
    contentView.autoresizingMask = UIViewAutoresizingNone;
    contentView.backgroundColor = [UIColor clearColor];
    contentView.opaque = NO;
    
    
    CGFloat itemY = kMarginY * 2;
    NSUInteger itemNum = 0;
        
    for (GDMenuItem *menuItem in _menuItems) {
                
        const CGRect itemFrame = (CGRect){0, itemY, MENUWIDTH, maxItemHeight};
        
        UIView *itemView = [[UIView alloc] initWithFrame:itemFrame];
        itemView.autoresizingMask = UIViewAutoresizingNone;
        itemView.backgroundColor = [UIColor clearColor];        
        itemView.opaque = NO;
                
        [contentView addSubview:itemView];
        [itemView release];
        if (menuItem.enabled) {
        
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.tag = itemNum;
            button.frame = itemView.bounds;
            button.enabled = menuItem.enabled;
            button.backgroundColor = [UIColor clearColor];
            button.opaque = NO;
            button.autoresizingMask = UIViewAutoresizingNone;
            
            [button addTarget:self
                       action:@selector(performAction:)
             forControlEvents:UIControlEventTouchUpInside];
            
            [button setBackgroundImage:selectedImage forState:UIControlStateHighlighted];
            
            [itemView addSubview:button];
            
        }
        
        if (menuItem.title.length) {
            
            CGRect titleFrame;
            
            if (!menuItem.enabled && !menuItem.image) {
                
                titleFrame = (CGRect){
                    kMarginX * 2,
                    kMarginY,
                    MENUWIDTH - kMarginX * 4,
                    maxItemHeight - kMarginY * 2
                };
                
            } else {
                
                titleFrame = (CGRect){
                    titleX,
                    kMarginY,
                    MENUWIDTH-40.0,
                    maxItemHeight - kMarginY * 2
                };
            }
            
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:titleFrame];
            titleLabel.text = menuItem.title;
            titleLabel.font = titleFont;
            titleLabel.textAlignment = menuItem.alignment ? menuItem.alignment : (_backgroundType == GDMenuViewBackgroundTypeBlack ? UITextAlignmentLeft : UITextAlignmentCenter);
            titleLabel.textColor = menuItem.foreColor ? menuItem.foreColor : (_backgroundType ? [UIColor whiteColor]:GETSKINCOLOR(MAIN_MENU_CLICK_COLOR));
            titleLabel.backgroundColor = [UIColor clearColor];
            titleLabel.autoresizingMask = UIViewAutoresizingNone;
            //titleLabel.backgroundColor = [UIColor greenColor];
            [itemView addSubview:titleLabel];
            [titleLabel release];
        }
        
        if (menuItem.image) {
            
            const CGRect imageFrame = {kMarginX * 2, kMarginY, maxImageWidth, maxItemHeight - kMarginY * 2};
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:imageFrame];
            imageView.image = menuItem.image;
            imageView.clipsToBounds = YES;
            imageView.contentMode = UIViewContentModeCenter;
            imageView.autoresizingMask = UIViewAutoresizingNone;
            [itemView addSubview:imageView];
            [imageView release];
        }
        
        if (itemNum < _menuItems.count - 1) {
            if (_backgroundType == GDMenuViewBackgroundTypeBlack || _backgroundType == GDMenuViewBackgroundTypeNight) {
                UIImageView *gradientView = [[UIImageView alloc] initWithImage:blackLine];
                gradientView.frame = (CGRect){0, maxItemHeight + 1,(CGSize){lineWidth,2}};
               // gradientView.contentMode = UIViewContentModeLeft;
            
                [itemView addSubview:gradientView];
                [gradientView release];
            }
            else{
                UIImageView *gradientView = [[UIImageView alloc] initWithImage:gradientLine];
                gradientView.frame = (CGRect){kMarginX * 2, maxItemHeight + 1, (CGSize){MENUWIDTH - kMarginX * 4,2}};
                //gradientView.contentMode = UIViewContentModeLeft;
                
                [itemView addSubview:gradientView];
                [gradientView release];
            }
            
            itemY += 2;
        }
        
        itemY += maxItemHeight;
        ++itemNum;
    }
    
    float menuWidth = 0.0f;
    
    if (_backgroundType == GDMenuViewBackgroundTypeWhite || _backgroundType == GDMenuViewBackgroundTypeNight) {
        menuWidth = 310.f;
    }
    else if (_backgroundType == GDMenuViewBackgroundTypeBlack)
    {
        menuWidth = 130;
    }
    contentView.frame = (CGRect){0, 0, menuWidth, itemY + kMarginY};
    
    return [contentView autorelease];
}

- (CGPoint) arrowPoint
{
    CGPoint point;
    
    if (_arrowDirection == GDMenuViewArrowDirectionUp) {
        
        point = (CGPoint){ CGRectGetMinX(self.frame) + _arrowPosition, CGRectGetMinY(self.frame) };
        
    } else if (_arrowDirection == GDMenuViewArrowDirectionDown) {
        
        point = (CGPoint){ CGRectGetMinX(self.frame) + _arrowPosition, CGRectGetMaxY(self.frame) };
        
    } else if (_arrowDirection == GDMenuViewArrowDirectionLeft) {
        
        point = (CGPoint){ CGRectGetMinX(self.frame), CGRectGetMinY(self.frame) + _arrowPosition  };
        
    } else if (_arrowDirection == GDMenuViewArrowDirectionRight) {
        
        point = (CGPoint){ CGRectGetMaxX(self.frame), CGRectGetMinY(self.frame) + _arrowPosition  };
        
    } else {
        
        point = self.center;
    }
    
    return point;
}

- (void) drawRect:(CGRect)rect
{
    [self drawBackground:self.bounds
               inContext:UIGraphicsGetCurrentContext()];
}

- (void)drawBackground:(CGRect)frame
             inContext:(CGContextRef) context
{
    
    NSArray *array = [[GDSkinColor sharedInstance] getArrayByKey:MENU_LIST_BACK];
    
    CGFloat R0 = [[array objectAtIndex:0] floatValue]/255.0f, G0 = [[array objectAtIndex:1] floatValue]/255.0f, B0 = [[array objectAtIndex:2] floatValue]/255.0f;
    CGFloat R1 =  [[array objectAtIndex:0] floatValue]/255.0f, G1 = [[array objectAtIndex:1] floatValue]/255.0f, B1 = [[array objectAtIndex:2] floatValue]/255.0f;
    float m_alpha = 0.0f;
    if (_backgroundType == GDMenuViewBackgroundTypeBlack || _backgroundType == GDMenuViewBackgroundTypeNight) {
        NSArray *array = [[GDSkinColor sharedInstance] getArrayByKey:ROUTE_BLACK_BAR_COLOR];
         R0 = [[array objectAtIndex:0] floatValue]/255.0f, G0 = [[array objectAtIndex:1] floatValue]/255.0f, B0 = [[array objectAtIndex:2] floatValue]/255.0f;
         R1 =  [[array objectAtIndex:0] floatValue]/255.0f, G1 = [[array objectAtIndex:1] floatValue]/255.0f, B1 = [[array objectAtIndex:2] floatValue]/255.0f;
        if(array .count == 4)
        {
            m_alpha = [[array objectAtIndex:3] floatValue];
        }
    }
    else{
        R0 = [[array objectAtIndex:0] floatValue]/255.0f, G0 = [[array objectAtIndex:1] floatValue]/255.0f, B0 = [[array objectAtIndex:2] floatValue]/255.0f;
        R1 =  [[array objectAtIndex:0] floatValue]/255.0f, G1 = [[array objectAtIndex:1] floatValue]/255.0f, B1 = [[array objectAtIndex:2] floatValue]/255.0f;
        m_alpha = 0.9f;
    }
    
//    UIColor *tintColor = [GDMenu tintColor];
//    if (tintColor) {
//        
//        CGFloat a;
//        [tintColor getRed:&R0 green:&G0 blue:&B0 alpha:&a];
//    }
    
    CGFloat X0 = frame.origin.x;
    CGFloat X1 = frame.origin.x + frame.size.width;
    CGFloat Y0 = frame.origin.y;
    CGFloat Y1 = frame.origin.y + frame.size.height;
    
    // render arrow
    
    UIBezierPath *arrowPath = [UIBezierPath bezierPath];
    
    // fix the issue with gxap of arrow's base if on the edge
    const CGFloat kEmbedFix = 0.5f;
    
    if (_arrowDirection == GDMenuViewArrowDirectionUp) {
        
        const CGFloat arrowXM = _arrowPosition;
        const CGFloat arrowX0 = arrowXM - 12.;
        const CGFloat arrowX1 = arrowXM + 12.;
        const CGFloat arrowY0 = Y0;
        const CGFloat arrowY1 = Y0 + kArrowSize + kEmbedFix;
        
        [arrowPath moveToPoint:    (CGPoint){arrowXM, arrowY0}];
        [arrowPath addLineToPoint: (CGPoint){arrowX1, arrowY1}];
        [arrowPath addLineToPoint: (CGPoint){arrowX0, arrowY1}];
        [arrowPath addLineToPoint: (CGPoint){arrowXM, arrowY0}];
        
        [[UIColor colorWithRed:R0 green:G0 blue:B0 alpha:m_alpha] set];
        
        Y0 += kArrowSize;
        
    } else if (_arrowDirection == GDMenuViewArrowDirectionDown) {
        
        const CGFloat arrowXM = _arrowPosition;
        const CGFloat arrowX0 = arrowXM - kArrowSize;
        const CGFloat arrowX1 = arrowXM + kArrowSize;
        const CGFloat arrowY0 = Y1 - kArrowSize - kEmbedFix;
        const CGFloat arrowY1 = Y1;
        
        [arrowPath moveToPoint:    (CGPoint){arrowXM, arrowY1}];
        [arrowPath addLineToPoint: (CGPoint){arrowX1, arrowY0}];
        [arrowPath addLineToPoint: (CGPoint){arrowX0, arrowY0}];
        [arrowPath addLineToPoint: (CGPoint){arrowXM, arrowY1}];
        
        [[UIColor colorWithRed:R1 green:G1 blue:B1 alpha:m_alpha] set];
        
        Y1 -= kArrowSize;
        
    } else if (_arrowDirection == GDMenuViewArrowDirectionLeft) {
        
        const CGFloat arrowYM = _arrowPosition;        
        const CGFloat arrowX0 = X0;
        const CGFloat arrowX1 = X0 + kArrowSize + kEmbedFix;
        const CGFloat arrowY0 = arrowYM - kArrowSize;;
        const CGFloat arrowY1 = arrowYM + kArrowSize;
        
        [arrowPath moveToPoint:    (CGPoint){arrowX0, arrowYM}];
        [arrowPath addLineToPoint: (CGPoint){arrowX1, arrowY0}];
        [arrowPath addLineToPoint: (CGPoint){arrowX1, arrowY1}];
        [arrowPath addLineToPoint: (CGPoint){arrowX0, arrowYM}];
        
        [[UIColor colorWithRed:R0 green:G0 blue:B0 alpha:m_alpha] set];
        
        X0 += kArrowSize;
        
    } else if (_arrowDirection == GDMenuViewArrowDirectionRight) {
        
        const CGFloat arrowYM = _arrowPosition;        
        const CGFloat arrowX0 = X1;
        const CGFloat arrowX1 = X1 - kArrowSize - kEmbedFix;
        const CGFloat arrowY0 = arrowYM - kArrowSize;;
        const CGFloat arrowY1 = arrowYM + kArrowSize;
        
        [arrowPath moveToPoint:    (CGPoint){arrowX0, arrowYM}];
        [arrowPath addLineToPoint: (CGPoint){arrowX1, arrowY0}];
        [arrowPath addLineToPoint: (CGPoint){arrowX1, arrowY1}];
        [arrowPath addLineToPoint: (CGPoint){arrowX0, arrowYM}];
        
        [[UIColor colorWithRed:R1 green:G1 blue:B1 alpha:m_alpha] set];
        
        X1 -= kArrowSize;
    }
    
    [arrowPath fill];

    // render body
    
    const CGRect bodyFrame = {X0, Y0, X1 - X0, Y1 - Y0};
    
    UIBezierPath *borderPath = [UIBezierPath bezierPathWithRoundedRect:bodyFrame
                                                          cornerRadius:8];
        
    const CGFloat locations[] = {0, 1};
    const CGFloat components[] = {
        R0, G0, B0, m_alpha,
        R1, G1, B1, m_alpha,
    };
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace,
                                                                 components,
                                                                 locations,
                                                                 sizeof(locations)/sizeof(locations[0]));
    CGColorSpaceRelease(colorSpace);
    
    
    [borderPath addClip];
    
    CGPoint start, end;
    
    if (_arrowDirection == GDMenuViewArrowDirectionLeft ||
        _arrowDirection == GDMenuViewArrowDirectionRight) {
                
        start = (CGPoint){X0, Y0};
        end = (CGPoint){X1, Y0};
        
    } else {
        
        start = (CGPoint){X0, Y0};
        end = (CGPoint){X0, Y1};
    }
    
    CGContextDrawLinearGradient(context, gradient, start, end, 0);
    
    if (gradient) {
        CGGradientRelease(gradient);
    }
    
    
}

@end

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

static GDMenu *gMenu;
static UIColor *gTintColor;
static UIFont *gTitleFont;

@implementation GDMenu {
    
    GDMenuView *_menuView;
    BOOL        _observing;
}

+ (instancetype) sharedMenu
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        gMenu = [[GDMenu alloc] init];
    });
    return gMenu;
}

- (id) init
{
    NSAssert(!gMenu, @"singleton object");
    
    self = [super init];
    if (self) {
    }
    return self;
}

- (void) dealloc
{
    
    if (_observing) {        
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
    [super dealloc];
}

- (BOOL)isMenuShow
{
    if (_menuView) {
        
        return YES;
    }
    return NO;
}
- (void)AutoSetUpFrameInView:(UIView *)view fromRect:(CGRect)rect
{
    if (_menuView) {
        [_menuView AutoSetUpFrameInView:view fromRect:rect];
    }
}
- (void) showMenuInView:(UIView *)view
               fromRect:(CGRect)rect
              menuItems:(NSArray *)menuItems
         backgroundType:(GDMenuViewBackgroundType)type
{
    NSParameterAssert(view);
    NSParameterAssert(menuItems.count);
    
    
    if (_menuView) {
        
        [_menuView dismissMenu:NO];
        _menuView = nil;
    }

    if (!_observing) {
    
        _observing = YES;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(orientationWillChange:)
                                                     name:UIApplicationWillChangeStatusBarOrientationNotification
                                                   object:nil];
    }

    
    _menuView = [[GDMenuView alloc] init];
    [_menuView showMenuInView:view fromRect:rect menuItems:menuItems backgroundType:type];
    
}

- (void) dismissMenu
{
    if (_menuView) {
        
        [_menuView dismissMenu:NO];
       // [_menuView release];
        _menuView = nil;
    }
    
    if (_observing) {
        
        _observing = NO;
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

- (void) orientationWillChange: (NSNotification *) n
{
//    [self dismissMenu];
}

+ (void)AutoSetUpFrameInView:(UIView *)view fromRect:(CGRect)rect
{
    [[self sharedMenu] AutoSetUpFrameInView:view fromRect:rect];
}

+ (void) showMenuInView:(UIView *)view
               fromRect:(CGRect)rect
              menuItems:(NSArray *)menuItems
         backgroundType:(GDMenuViewBackgroundType)type
{
    [[self sharedMenu] showMenuInView:view fromRect:rect menuItems:menuItems backgroundType:type];
}

+ (BOOL)isShowMenu
{
    return [[self sharedMenu] isMenuShow];
}

+ (void) dismissMenu
{
    [[self sharedMenu] dismissMenu];
}

+ (UIColor *) tintColor
{
    return gTintColor;
}

+ (void) setTintColor: (UIColor *) tintColor
{
    if (tintColor != gTintColor) {
        gTintColor = tintColor;
    }
}

+ (UIFont *) titleFont
{
    return gTitleFont;
}

+ (void) setTitleFont: (UIFont *) titleFont
{
    if (titleFont != gTitleFont) {
        gTitleFont = titleFont;
    }
}

@end

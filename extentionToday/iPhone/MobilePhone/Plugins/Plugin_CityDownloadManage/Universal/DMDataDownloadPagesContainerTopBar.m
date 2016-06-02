//
//  DMDataDownloadPagesContainerTopBar.m
//  AutoNavi
//
//  Created by huang longfeng on 13-9-05.
//
//

#import "DMDataDownloadPagesContainerTopBar.h"

#define ButtonBac1  @"TableCellBgFooter.png"
#define ButtonBac2  @"TableCellBgFooter.png"

@interface DMDataDownloadPagesContainerTopBar ()

@property (retain, nonatomic) UIScrollView *scrollView;
@property (retain, nonatomic) NSArray *itemViews;

- (void)layoutItemViews;

@end


@implementation DMDataDownloadPagesContainerTopBar

CGFloat const DMDataDownloadPagesContainerTopBarItemViewWidth = 160.;
CGFloat const DMDataDownloadPagesContainerTopBarItemsOffset = 70.;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.pagingEnabled = NO;
        self.scrollView.scrollEnabled = NO;
        [self addSubview:self.scrollView];
        [_scrollView release];
        self.font = [UIFont systemFontOfSize:14];
        
        
    }
    return self;
}

#pragma mark - Public

- (CGPoint)centerForSelectedItemAtIndex:(NSUInteger)index
{
    CGPoint center = ((UIView *)self.itemViews[index]).center;
    CGPoint offset = [self contentOffsetForSelectedItemAtIndex:index];
    center.x -= offset.x - (CGRectGetMinX(self.scrollView.frame));
    return center;
}

- (CGPoint)contentOffsetForSelectedItemAtIndex:(NSUInteger)index
{
    if (self.itemViews.count < index || self.itemViews.count == 1) {
        return CGPointZero;
    } else {
        CGFloat totalOffset = self.scrollView.contentSize.width - CGRectGetWidth(self.scrollView.frame);
        return CGPointMake(index * totalOffset / (self.itemViews.count - 1), 0.);
    }
}

#pragma mark * Overwritten setters

- (void)setItemTitles:(NSArray *)itemTitles
{
    if (_itemTitles != itemTitles) {
        _itemTitles = [itemTitles retain];
        NSMutableArray *mutableItemViews = [NSMutableArray arrayWithCapacity:itemTitles.count];
        for (NSUInteger i = 0; i < itemTitles.count; i++) {
            UIButton *itemView = [self addItemView];
            [itemView setTitle:itemTitles[i] forState:UIControlStateNormal];
            [mutableItemViews addObject:itemView];
        }
        self.itemViews = [NSArray arrayWithArray:mutableItemViews];
        [self layoutItemViews];
    }
}

- (void)setFont:(UIFont *)font
{
    for (UIButton *itemView in self.itemViews) {
        [itemView.titleLabel setFont:font];
    }
}

#pragma mark - Private

- (UIButton *)addItemView
{
    CGRect frame = CGRectMake(0., 0., self.frame.size.width, CGRectGetHeight(self.frame));
    UIButton *itemView = [[UIButton alloc] initWithFrame:frame];
    [itemView addTarget:self action:@selector(itemViewTapped:) forControlEvents:UIControlEventTouchUpInside];
    itemView.titleLabel.font = [UIFont systemFontOfSize:15.];
    
    [itemView setBackgroundImage:[IMAGE(ButtonBac1, IMAGEPATH_TYPE_1) stretchableImageWithLeftCapWidth:5 topCapHeight:10] forState:UIControlStateNormal];
    [itemView setBackgroundImage:[IMAGE(ButtonBac2, IMAGEPATH_TYPE_1) stretchableImageWithLeftCapWidth:5 topCapHeight:10] forState:UIControlStateHighlighted];
    [itemView setTitleColor:GETSKINCOLOR(@"ToolbarButtonDisabledColor") forState:UIControlStateNormal];
    [self.scrollView addSubview:itemView];
    return [itemView autorelease];
}

- (void)itemViewTapped:(UIButton *)sender
{
    [self.delegate itemAtIndex:[self.itemViews indexOfObject:sender] didSelectInPagesContainerTopBar:self];
}

- (void)layoutItemViews
{
    CGFloat x = DMDataDownloadPagesContainerTopBarItemsOffset;
    for (NSUInteger i = 0; i < self.itemViews.count; i++) {
        CGFloat width = [self.itemTitles[i] sizeWithFont:self.font].width;
        UIView *itemView = self.itemViews[i];
        itemView.frame = CGRectMake( CGRectGetWidth(self.frame)*i*0.5 , 0., CGRectGetWidth(self.frame)/2.0+i, CGRectGetHeight(self.frame));
        x += width + DMDataDownloadPagesContainerTopBarItemsOffset;
    }
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.frame), CGRectGetHeight(self.scrollView.frame));
    CGRect frame = self.scrollView.frame;
//    if (CGRectGetWidth(self.frame) > x) {
//        frame.origin.x = (CGRectGetWidth(self.frame) - x) / 2.;
//        frame.size.width = x;
//    } else
    {
        frame.origin.x = 0.;
        frame.size.width = CGRectGetWidth(self.frame);
    }
    self.scrollView.frame = frame;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self layoutItemViews];
}
-(void)dealloc
{
    if (_itemTitles) {
        [_itemTitles release];
        _itemTitles = nil;
    }
    if (_font) {
        [_font release];
        _font = nil;
    }
    if (_itemViews) {
        [_itemViews release];
        _itemViews = nil;
    }
    
    [super dealloc];
}
@end
//
//  DMDataDownloadPagesContainer.m
//  AutoNavi
//
//  Created by huang longfeng on 13-9-05.
//
//

#import "DMDataDownloadPagesContainer.h"

#import "DMDataDownloadPagesContainerTopBar.h"
#import "DMDataDownloadPageIndicatorView.h"
#import "plugin-cdm-DownCityDataController.h"


@interface DMDataDownloadPagesContainer () <DMDataDownloadPagesContainerTopBarDelegate, UIScrollViewDelegate>

@property (retain, nonatomic) DMDataDownloadPagesContainerTopBar *topBar;
@property (retain, nonatomic) UIScrollView *scrollView;
@property (assign,   nonatomic) UIScrollView *observingScrollView;
@property (retain, nonatomic) DMDataDownloadPageIndicatorView *pageIndicatorView;

@property (          assign, nonatomic) BOOL shouldObserveContentOffset;
@property (readonly, assign, nonatomic) CGFloat scrollWidth;
@property (readonly, assign, nonatomic) CGFloat scrollHeight;

- (void)layoutSubviews;
- (void)startObservingContentOffsetForScrollView:(UIScrollView *)scrollView;
- (void)stopObservingContentOffset;

@end


#define IndicatorView_Y 41

@implementation DMDataDownloadPagesContainer

#pragma mark - Initialization

- (id)init
{
    self = [super init];
    if (self) {
        [self setUp];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setUp];
    }
    return self;
}

- (void)dealloc
{
    _scrollView.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self stopObservingContentOffset];
    
    if (_viewControllers) {
        [_viewControllers release];
        _viewControllers = nil;
    }
    
    if (_topBarItemLabelsFont) {
        [_topBarItemLabelsFont release];
        _topBarItemLabelsFont = nil;
    }
    if (_pageItemsTitleColor) {
        [_pageItemsTitleColor release];
        _pageItemsTitleColor = nil;
    }
    if (_selectedPageItemColor) {
        [_selectedPageItemColor release];
        _selectedPageItemColor = nil;
    }
    [super dealloc];
}

- (void)setUp
{
    _topBarHeight = 42.;
    _topBarItemLabelsFont = [[UIFont systemFontOfSize:14] retain];
    _pageIndicatorViewSize = CGSizeMake(90, 2);
}

#pragma mark - View life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:NO];
    self.title = @"地图下载";
    
    self.shouldObserveContentOffset = YES;
    
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.,
                                                                     self.topBarHeight+3.0,
                                                                     CGRectGetWidth(self.view.frame),
                                                                     CGRectGetHeight(self.view.frame) - self.topBarHeight)];
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth
        | UIViewAutoresizingFlexibleHeight;
    self.scrollView.delegate = self;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.alwaysBounceHorizontal = NO;
    self.scrollView.backgroundColor = [UIColor clearColor];
    self.scrollView.scrollsToTop = NO;
    self.scrollView.scrollEnabled = NO;
    
    [self.view addSubview:self.scrollView];
    [_scrollView release];
    
    [self startObservingContentOffsetForScrollView:self.scrollView];    

    _topBar = [[DMDataDownloadPagesContainerTopBar alloc] initWithFrame:CGRectMake(0.,
                                                                           0.,
                                                                           CGRectGetWidth(self.view.frame),
                                                                           self.topBarHeight)];
    self.topBar.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    self.topBar.delegate = self;
    self.topBar.font = [UIFont systemFontOfSize:18.0];
    [self.view addSubview:self.topBar];
    [_topBar release];
   
    _pageIndicatorView = [[DMDataDownloadPageIndicatorView alloc] initWithFrame:CGRectMake(0.,
                                                                                   0.,
                                                                                   self.pageIndicatorViewSize.width,
                                                                                   self.pageIndicatorViewSize.height)];
    [self.view addSubview:self.pageIndicatorView];
    [_pageIndicatorView release];
    self.topBar.backgroundColor = [UIColor clearColor];
}

- (void)viewDidUnload
{
    [self stopObservingContentOffset];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self layoutSubviews];
}

#pragma mark - Public
- (int)getCurIndex
{
    return _selectedIndex;
}

- (void)setButtonEnable:(BOOL)enable
{
    int buttonCount = self.topBar.itemViews.count;
    for (int i = 0; i < buttonCount ; i++) {
        UIButton *button = self.topBar.itemViews[i];
        [button setEnabled:enable];
    }
}

- (void)setTitleColor:(int)type
{
    if (self.topBar.itemViews.count < 2) {
        return;
    }
    
    UIButton *previosSelectdItem = self.topBar.itemViews[0];
    UIButton *nextSelectdItem = self.topBar.itemViews[1];
    
    if (type) {
        
        [previosSelectdItem setTitleColor:TOOLBARBUTTONCOLOR forState:UIControlStateNormal];
        [nextSelectdItem setTitleColor:TOOLBARBUTTONDISABLEDCOLOR forState:UIControlStateNormal];
        
    }
    else{
        
        [previosSelectdItem setTitleColor:TOOLBARBUTTONDISABLEDCOLOR forState:UIControlStateNormal];
        [nextSelectdItem setTitleColor:TOOLBARBUTTONCOLOR forState:UIControlStateNormal];
    }
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex animated:(BOOL)animated
{
    
    UIButton *previosSelectdItem = self.topBar.itemViews[self.selectedIndex];
    UIButton *nextSelectdItem = self.topBar.itemViews[selectedIndex];
    if (abs(self.selectedIndex - selectedIndex) <= 1) {
        [self.scrollView setContentOffset:CGPointMake(selectedIndex * self.scrollWidth, 0.) animated:animated];
        if (selectedIndex == _selectedIndex) {
            self.pageIndicatorView.center = CGPointMake([self.topBar centerForSelectedItemAtIndex:selectedIndex].x,
                                                        IndicatorView_Y);
            return;
        }
        [previosSelectdItem setTitleColor:TOOLBARBUTTONCOLOR forState:UIControlStateNormal];
        
        [nextSelectdItem setTitleColor:TOOLBARBUTTONDISABLEDCOLOR forState:UIControlStateNormal];
       
        [UIView animateWithDuration:(animated) ? 0.3 : 0. delay:0. options:UIViewAnimationOptionBeginFromCurrentState animations:^
         {
             [previosSelectdItem setTitleColor:GETSKINCOLOR(@"ToolbarButtonColor") forState:UIControlStateNormal];
             [nextSelectdItem setTitleColor:GETSKINCOLOR(@"ToolbarButtonDisabledColor") forState:UIControlStateNormal];
         } completion:nil];
    } else {
        // This means we should "jump" over at least one view controller
        self.shouldObserveContentOffset = NO;
        BOOL scrollingRight = (selectedIndex > self.selectedIndex);
        UIViewController *leftViewController = self.viewControllers[MIN(self.selectedIndex, selectedIndex)];
        UIViewController *rightViewController = self.viewControllers[MAX(self.selectedIndex, selectedIndex)];
        leftViewController.view.frame = CGRectMake(0., 0., self.scrollWidth, self.scrollHeight);
        rightViewController.view.frame = CGRectMake(self.scrollWidth, 0., self.scrollWidth, self.scrollHeight);
        self.scrollView.contentSize = CGSizeMake(2 * self.scrollWidth, self.scrollHeight);
        
        CGPoint targetOffset;
        if (scrollingRight) {
            self.scrollView.contentOffset = CGPointZero;
            targetOffset = CGPointMake(self.scrollWidth, 0.);
        } else {
            self.scrollView.contentOffset = CGPointMake(self.scrollWidth, 0.);
            targetOffset = CGPointZero;
            
        }
        [self.scrollView setContentOffset:targetOffset animated:YES];
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.pageIndicatorView.center = CGPointMake([self.topBar centerForSelectedItemAtIndex:selectedIndex].x,
                                                        IndicatorView_Y);
            self.topBar.scrollView.contentOffset = [self.topBar contentOffsetForSelectedItemAtIndex:selectedIndex];
            [previosSelectdItem setTitleColor:[UIColor colorWithWhite:0.6 alpha:1.] forState:UIControlStateNormal];
            [nextSelectdItem setTitleColor:[UIColor colorWithWhite:1. alpha:1.] forState:UIControlStateNormal];
        } completion:^(BOOL finished) {
            for (NSUInteger i = 0; i < self.viewControllers.count; i++) {
                UIViewController *viewController = self.viewControllers[i];
                viewController.view.frame = CGRectMake(i * self.scrollWidth, 0., self.scrollWidth, self.scrollHeight);
                [self.scrollView addSubview:viewController.view];
            }
            self.scrollView.contentSize = CGSizeMake(self.scrollWidth * self.viewControllers.count, self.scrollHeight);
            [self.scrollView setContentOffset:CGPointMake(selectedIndex * self.scrollWidth, 0.) animated:NO];
            self.scrollView.userInteractionEnabled = YES;
            self.shouldObserveContentOffset = YES;
        }];
    }
    _selectedIndex = selectedIndex;
    if (selectedIndex == 1) {
        DownLoadCityDataController *viewCotroller = self.viewControllers[1];
        [viewCotroller loadingDataList];
    }
    
    NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:_selectedIndex],@"selectindex",nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_HandleUIUpdate object:[NSNumber numberWithInt:UIUpdate_MapDataChangeView] userInfo:dic];
    CRELEASE(dic);
    

}

- (void)updateLayoutForNewOrientation:(UIInterfaceOrientation)orientation
{
    [self layoutSubviews];
}

#pragma mark * Overwritten setters

- (void)setPageIndicatorViewSize:(CGSize)size
{
    if (!CGSizeEqualToSize(self.pageIndicatorView.frame.size, size)) {
        [self layoutSubviews];
    }
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex
{
    [self setSelectedIndex:selectedIndex animated:NO];
}

- (void)setTopBarBackgroundColor:(UIColor *)topBarBackgroundColor
{
    self.topBar.backgroundColor = topBarBackgroundColor;
    self.pageIndicatorView.color = topBarBackgroundColor;
}

- (void)setTopBarHeight:(NSUInteger)topBarHeight
{
    if (_topBarHeight != topBarHeight) {
        _topBarHeight = topBarHeight;
        [self layoutSubviews];
    }
}

- (void)setTopBarItemLabelsFont:(UIFont *)font
{
    self.topBar.font = font;
}

- (void)setViewControllers:(NSArray *)viewControllers
{
    if (_viewControllers != viewControllers) {
        _viewControllers = [viewControllers retain];
        self.topBar.itemTitles = [viewControllers valueForKey:@"title"];
        for (UIViewController *viewController in viewControllers) {
            //[viewController willMoveToParentViewController:self];
            viewController.view.frame = CGRectMake(0., 0., CGRectGetWidth(self.scrollView.frame), self.scrollHeight);
            [self.scrollView addSubview:viewController.view];
            //[self addChildViewController:viewController];
            //[viewController didMoveToParentViewController:self];
        }
        [self layoutSubviews];
        self.selectedIndex = 0;
        self.pageIndicatorView.center = CGPointMake([self.topBar centerForSelectedItemAtIndex:self.selectedIndex].x,
                                                    IndicatorView_Y);
    }
}

#pragma mark - Private

- (void)layoutSubviews
{
    [self.scrollView setFrame:CGRectMake(0.0, self.topBarHeight+3.0, self.view.frame.size.width, self.view.frame.size.height - self.topBarHeight)];
    
    NSLog(@"%f",self.view.frame.size.width);
    [self.topBar setFrame:CGRectMake(0., 0., self.view.frame.size.width, self.topBarHeight)];
    [self.topBar.scrollView setFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.topBarHeight)];
    self.pageIndicatorView.frame = CGRectMake(0.,
                                              0.,
                                              self.pageIndicatorViewSize.width,
                                              self.pageIndicatorViewSize.height);
    CGFloat x = 0.;
    for (UIViewController *viewController in self.viewControllers) {
        
        viewController.view.frame = CGRectMake(x, 0, CGRectGetWidth(self.scrollView.frame), self.scrollHeight);
        x += CGRectGetWidth(self.scrollView.frame);
    }
    self.scrollView.contentSize = CGSizeMake(x,0);
    [self.scrollView setContentOffset:CGPointMake(self.selectedIndex * self.scrollWidth, 0.) animated:YES];
    self.pageIndicatorView.center = CGPointMake([self.topBar centerForSelectedItemAtIndex:self.selectedIndex].x,
                                                IndicatorView_Y);
    self.topBar.scrollView.contentOffset = [self.topBar contentOffsetForSelectedItemAtIndex:self.selectedIndex];
    self.scrollView.userInteractionEnabled = YES;
     [_topBar layoutSubviews];
    
}

- (CGFloat)scrollHeight
{
    return CGRectGetHeight(self.view.frame) - self.topBarHeight;
}

- (CGFloat)scrollWidth
{
    return CGRectGetWidth(self.scrollView.frame);
}

- (void)startObservingContentOffsetForScrollView:(UIScrollView *)scrollView
{
    [scrollView addObserver:self forKeyPath:@"contentOffset" options:0 context:nil];
    self.observingScrollView = scrollView;
}

- (void)stopObservingContentOffset
{
    if (self.observingScrollView) {
        [self.observingScrollView removeObserver:self forKeyPath:@"contentOffset"];
        self.observingScrollView = nil;
    }
}

#pragma mark - DAPagesContainerTopBar delegate

- (void)itemAtIndex:(NSUInteger)index didSelectInPagesContainerTopBar:(DMDataDownloadPagesContainerTopBar *)bar
{
    [self setSelectedIndex:index animated:YES];
}

#pragma mark - UIScrollView delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    self.selectedIndex = scrollView.contentOffset.x / CGRectGetWidth(self.scrollView.frame);
    self.scrollView.userInteractionEnabled = YES;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        self.scrollView.userInteractionEnabled = YES;
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    self.scrollView.userInteractionEnabled = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_HandleUIUpdate object:[NSNumber numberWithInt:UIUpdate_MapDataDownloadresignKeyboard] userInfo:nil];
    
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object
						change:(NSDictionary *)change
                       context:(void *)context
{
    
    CGFloat oldX = self.selectedIndex * CGRectGetWidth(self.scrollView.frame);
    if (oldX != self.scrollView.contentOffset.x && self.shouldObserveContentOffset) {
        BOOL scrollingTowards = (self.scrollView.contentOffset.x > oldX);
        NSInteger targetIndex = (scrollingTowards) ? self.selectedIndex + 1 : self.selectedIndex - 1;
        if (targetIndex >= 0 && targetIndex < self.viewControllers.count) {
            CGFloat ratio = (self.scrollView.contentOffset.x - oldX) / CGRectGetWidth(self.scrollView.frame);
            CGFloat previousItemContentOffsetX = [self.topBar contentOffsetForSelectedItemAtIndex:self.selectedIndex].x;
            CGFloat nextItemContentOffsetX = [self.topBar contentOffsetForSelectedItemAtIndex:targetIndex].x;
            CGFloat previousItemPageIndicatorX = [self.topBar centerForSelectedItemAtIndex:self.selectedIndex].x;
            CGFloat nextItemPageIndicatorX = [self.topBar centerForSelectedItemAtIndex:targetIndex].x;
            UIButton *previosSelectedItem = self.topBar.itemViews[self.selectedIndex];
            UIButton *nextSelectedItem = self.topBar.itemViews[targetIndex];
            [previosSelectedItem setTitleColor:TOOLBARBUTTONDISABLEDCOLOR forState:UIControlStateNormal];
            [nextSelectedItem setTitleColor:TOOLBARBUTTONCOLOR forState:UIControlStateNormal];
            if (scrollingTowards) {
                self.topBar.scrollView.contentOffset = CGPointMake(previousItemContentOffsetX +
                                                                   (nextItemContentOffsetX - previousItemContentOffsetX) * ratio , 0.);
                self.pageIndicatorView.center = CGPointMake(previousItemPageIndicatorX +
                                        (nextItemPageIndicatorX - previousItemPageIndicatorX) * ratio,
                                                            IndicatorView_Y);
  
            } else {
                self.topBar.scrollView.contentOffset = CGPointMake(previousItemContentOffsetX -
                                                                   (nextItemContentOffsetX - previousItemContentOffsetX) * ratio , 0.);
                self.pageIndicatorView.center = CGPointMake(previousItemPageIndicatorX -
                                        (nextItemPageIndicatorX - previousItemPageIndicatorX) * ratio,
                                                            IndicatorView_Y);
            }
        }
    }
    else{
        
        self.pageIndicatorView.center = CGPointMake([self.topBar centerForSelectedItemAtIndex:self.selectedIndex].x,
                                                    IndicatorView_Y);
       
    }
}

@end
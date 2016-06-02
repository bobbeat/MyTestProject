//
//  CycleScrollView.m
//  AutoNavi
//
//  Created by jiangshu-fu on 13-12-27.
//
//

#import "CycleScrollView.h"

@implementation CycleScrollView

@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _index = 0;
    }
    return self;
}
/***
 * @name    初始化
 * @param   index == -1 说明是有三个视图，否则，只有两个，并且，只显示前面两个
 * @author  by bazinga
 ***/
- (id) initWithFrame:(CGRect)frame
       withFirstView:(UIView *)firstView
      withSecondView:(UIView *)secondView
       withThirdView:(UIView *)thirdView
           withIndex:(int)index
{
    self = [super initWithFrame:frame];
    if (self) {
        //设置ScrollView
        _index = index;
        _scrollViewFrame = CGRectMake(frame.origin.x,
                                      frame.origin.y,
                                      frame.size.width,
                                      frame.size.height);
        _scrollView = [[UIScrollView alloc] initWithFrame:frame];
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.pagingEnabled = YES;
        _scrollView.bounces = NO;
        [self addSubview:_scrollView];
        _scrollView.delegate = self;
        [_scrollView release];
        _scrollView.autoresizesSubviews = YES;
        _firstView = firstView;
        _secondView = secondView;
        _thirdView = thirdView;
        _firstView.autoresizingMask  = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _secondView.autoresizingMask  = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _thirdView.autoresizingMask  = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        CGSize contentSize ;
        if(index == -1)  //表示节点超过三个
        {
            //设置内容宽度
           contentSize = CGSizeMake(frame.size.width * 3, frame.size.height);
        }
        else
        {
            contentSize = CGSizeMake(frame.size.width * 2, frame.size.height);
        }
        
        
        [_scrollView addSubview:_firstView];
        [_scrollView addSubview:_secondView];
        [_scrollView addSubview:_thirdView];
        
        [_scrollView setContentSize:contentSize];
        
        [self setScrollViewCenter];
    }
    return self;
}



- (void) setScrollViewCenter
{
    [_firstView setCenter:CGPointMake(_scrollViewFrame.size.width / 2,
                                      _scrollViewFrame.size.height / 2)];
    [_secondView setCenter:CGPointMake(_scrollViewFrame.size.width  / 2 + _scrollViewFrame.size.width,
                                       _scrollViewFrame.size.height / 2)];
    [_thirdView setCenter:CGPointMake(_scrollViewFrame.size.width  / 2 + _scrollViewFrame.size.width * 2,
                                      _scrollViewFrame.size.height / 2)];
    if(_scrollView.contentSize.width == _scrollView.frame.size.width * 3)
    {
        [_scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width,
                                                  _scrollView.contentOffset.y)];
    }
    else
    {
        [_scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width * _index,
                                                  _scrollView.contentOffset.y)];
    }
}

- (void) scrollToFirst
{
    [_scrollView setContentOffset:CGPointMake(0,
                                              _scrollView.contentOffset.y)];
}
- (void) ScrollToEnd
{
    [_scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width * 2,
                                              _scrollView.contentOffset.y)];
}
- (void) setIndex:(int) index
{
    _index = index;
}
- (void) dealloc
{
    _delegate = nil;
    [super dealloc];
}

- (void) setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    int indexScroll = 0;
    if(_scrollView.frame.size.width != 0)
    {
        indexScroll = _scrollView.contentOffset.x / _scrollView.frame.size.width;
    }

    [_scrollView setFrame:frame];
    _scrollViewFrame = CGRectMake(frame.origin.x,
                                  frame.origin.y,
                                  frame.size.width,
                                  frame.size.height);
    CGSize contentSize ;
    if(_index == -1)  //表示节点超过三个
    {
        //设置内容宽度
        contentSize = CGSizeMake(frame.size.width * 3, frame.size.height);
    }
    else
    {
        contentSize = CGSizeMake(frame.size.width * 2, frame.size.height);
    }
    
    [_scrollView setContentSize:contentSize];
    [_firstView setCenter:CGPointMake(_scrollViewFrame.size.width / 2,
                                      _scrollViewFrame.size.height / 2)];
    [_secondView setCenter:CGPointMake(_scrollViewFrame.size.width  / 2 + _scrollViewFrame.size.width,
                                       _scrollViewFrame.size.height / 2)];
    [_thirdView setCenter:CGPointMake(_scrollViewFrame.size.width  / 2 + _scrollViewFrame.size.width * 2,
                                      _scrollViewFrame.size.height / 2)];
    [_scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width * indexScroll, _scrollView.contentOffset.y)];
}

#pragma mark -
#pragma mark ---  scrollerDelegate  ---
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if(_index == -1)
    {
        if(_scrollView.contentOffset.x == _scrollView.frame.size.width)
        {
            if(self.delegate && [self.delegate respondsToSelector:@selector(scrollToEqual)])
            {
                [self.delegate scrollToEqual];
            }
       
        }
        else if (_scrollView.contentOffset.x < _scrollView.frame.size.width)
        {
            if(self.delegate && [self.delegate respondsToSelector:@selector(scrollToPre)])
            {
                [self.delegate scrollToPre];
            }
        }
        else
        {
            if(self.delegate && [self.delegate respondsToSelector:@selector(scrollToNext)])
            {
                [self.delegate scrollToNext];
            }
        }
    }
    else
    {
        if(self.delegate && [self.delegate respondsToSelector:@selector(scrollToIndex:)])
        {
            if(scrollView.frame.size.width != 0)
            {
                [self.delegate scrollToIndex:scrollView.contentOffset.x / scrollView.frame.size.width];
            }
        }
    }
    NSLog(@"scrollViewDidEndDecelerating--------------");
    NSLog(@"scrollView,%f",scrollView.contentOffset.x);
    
}

@end

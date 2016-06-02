//
//  CycleScrollView.h
//  AutoNavi
//
//  Created by jiangshu-fu on 13-12-27.
//
//

#import <UIKit/UIKit.h>

@protocol CycleScollViewDelegate <NSObject>

@optional
- (void) scrollToNext;

- (void) scrollToPre;

- (void) scrollToEqual;

- (void) scrollToIndex:(int)index;

@end

@interface CycleScrollView : UIView <UIScrollViewDelegate>
{
    UIScrollView *_scrollView;
    UIView *_firstView;
    UIView *_secondView;
    UIView *_thirdView;
    
    CGRect _scrollViewFrame;
    
    int _index;
}

@property (assign,nonatomic) id<CycleScollViewDelegate> delegate;

/***
 * @name    初始化
 * @param   index == -1 说明是有三个视图，否则，只有两个，并且，只显示前面两个
 * @author  by bazinga
 ***/
- (id) initWithFrame:(CGRect)frame
       withFirstView:(UIView *)firstView
      withSecondView:(UIView *)secondView
       withThirdView:(UIView *)thirView
           withIndex:(int)index;

- (void) setScrollViewCenter;
- (void) scrollToFirst;
- (void) ScrollToEnd;

- (void) setIndex:(int) index;
@end

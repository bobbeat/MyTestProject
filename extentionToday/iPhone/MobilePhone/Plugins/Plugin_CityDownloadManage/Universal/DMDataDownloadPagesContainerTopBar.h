//
//  DMDataDownloadPagesContainerTopBar.h
//  AutoNavi
//
//  Created by huang longfeng on 13-9-05.
//
//

#import <UIKit/UIKit.h>


@class DMDataDownloadPagesContainerTopBar;

@protocol DMDataDownloadPagesContainerTopBarDelegate <NSObject>

- (void)itemAtIndex:(NSUInteger)index didSelectInPagesContainerTopBar:(DMDataDownloadPagesContainerTopBar *)bar;

@end


@interface DMDataDownloadPagesContainerTopBar : UIView

@property (retain, nonatomic) NSArray *itemTitles;
@property (retain, nonatomic) UIFont *font;
@property (readonly, retain, nonatomic) NSArray *itemViews;
@property (readonly, retain, nonatomic) UIScrollView *scrollView;
@property (assign, nonatomic) id<DMDataDownloadPagesContainerTopBarDelegate> delegate;

- (CGPoint)centerForSelectedItemAtIndex:(NSUInteger)index;
- (CGPoint)contentOffsetForSelectedItemAtIndex:(NSUInteger)index;

@end
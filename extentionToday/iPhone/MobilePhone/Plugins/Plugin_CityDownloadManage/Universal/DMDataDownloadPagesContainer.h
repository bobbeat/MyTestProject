//
//  DMDataDownloadPagesContainer.h
//  AutoNavi
//
//  Created by huang longfeng on 13-9-05.
//
//

#import <UIKit/UIKit.h>

@protocol DownloadPagesContainerDelegate <NSObject>

- (void)setSelectedIndex:(NSUInteger)selectedIndex animated:(BOOL)animated;

@end

@interface DMDataDownloadPagesContainer : UIViewController

@property (retain, nonatomic) NSArray *viewControllers;
@property (assign, nonatomic) NSUInteger selectedIndex;

@property (assign, nonatomic) NSUInteger topBarHeight;
@property (assign, nonatomic) CGSize pageIndicatorViewSize;
@property (retain, nonatomic) UIColor *topBarBackgroundColor;
@property (retain, nonatomic) UIFont *topBarItemLabelsFont;
@property (retain, nonatomic) UIColor *pageItemsTitleColor;
@property (retain, nonatomic) UIColor *selectedPageItemColor;

- (void)setTitleColor:(int)type;
- (void)setButtonEnable:(BOOL)enable;
- (void)setSelectedIndex:(NSUInteger)selectedIndex animated:(BOOL)animated;
- (void)updateLayoutForNewOrientation:(UIInterfaceOrientation)orientation;
- (int)getCurIndex;
@end
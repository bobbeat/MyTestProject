//
//  MyScrollView.h
//  MyPageView
//
//  Created by lin jingjie on 11-8-28.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIView.h>
#import <UIKit/UIGeometry.h>
#import <UIKit/UIKitDefines.h>

@interface MyScrollView : UIScrollView <UIScrollViewDelegate>{
	NSMutableArray *imageArry;
	NSMutableArray * imageNames;
	BOOL hasHScreen;
	NSUInteger kNumberOfPages;
    BOOL isClicked;
    
}
-(id)initWithFrame:(CGRect)frame names:(NSMutableArray *)names hasHScreen:(BOOL)bHScr;//names：图片名数组 hasHScreen：是否有横屏
- (void)loadVScrollViewWithPage:(int)page;
- (void)loadHScrollViewWithPage:(int)page;
-(void)setHV:(int)flag newFrame:(CGRect)newFrame;
-(void)changePage:(int)page animated:(BOOL)animated;
@property BOOL hasHScreen;
@property (nonatomic,retain)NSMutableArray * imageNames;
@end



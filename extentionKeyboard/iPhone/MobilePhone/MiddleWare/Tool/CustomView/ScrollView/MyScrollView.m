//
//  MyScrollView.m
//  MyPageView
//
//  Created by lin jingjie on 11-8-28.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MyScrollView.h"
#import "ANParamValue.h"

@implementation MyScrollView
@synthesize hasHScreen;
@synthesize imageNames;

-(id)initWithFrame:(CGRect)frame names:(NSMutableArray *)names hasHScreen:(BOOL)bHScr
{
	self = [super initWithFrame:frame];
	// a page is the width of the scroll view
	imageNames = names;
	hasHScreen = bHScr;
	if(self != nil)
	{
		if(hasHScreen)
		{
			kNumberOfPages = [imageNames count]/2;
		}
		else
		{
			kNumberOfPages = [imageNames count];
		}

		NSMutableArray *arry = [[NSMutableArray alloc] init];
		for (int i = 0; i < kNumberOfPages * (1 + hasHScreen); i++)
		{
			[arry addObject:[[[UIImageView alloc] initWithImage:IMAGE([imageNames objectAtIndex:i],IMAGEPATH_TYPE_1)] autorelease]];
		}
		imageArry = arry;
		
		
		NSString *sysVersion = CurrentSystemVersion;
		self.pagingEnabled = YES;
		self.showsHorizontalScrollIndicator = NO;
		self.showsVerticalScrollIndicator = NO;
		self.scrollsToTop = NO;
		if ([sysVersion floatValue] >=4.0) 
		{
			self.bounces = NO;
		}
		else {
			self.bounces = YES;
		}

		self.delegate = self;
		[self setHV:0 newFrame:frame];
//        UITouch
        UITapGestureRecognizer *singleFingerOne = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleFingerEvent:)] autorelease]; singleFingerOne.numberOfTouchesRequired = 1;
        //手指数
        singleFingerOne.numberOfTapsRequired = 1; //tap次数
        singleFingerOne.delegate = self;
        [self addGestureRecognizer:singleFingerOne];
//        [singleFingerOne requireGestureRecognizerToFail:pinchRecognizer];
       
		
	}
	return self;
}

- (void)dealloc
{
    if (imageArry)
    {
        [imageArry release];
        imageArry = nil;
    }
    [super dealloc];
}
-(void)handleSingleFingerEvent:(UITapGestureRecognizer*)tap
{
    if (tap.numberOfTapsRequired == 1)
	{
        if ([[ANParamValue sharedInstance] new_fun_flag] == 1) {
            if (isClicked) {
                isClicked = NO;
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_ShowNavigation object:nil];
                
            }
            else {
                isClicked = YES;
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_HideNavigation object:nil];
                
            }
            return;
        }

    }
}

-(void)setHV:(int)flag newFrame:(CGRect)newFrame
{
	CGFloat pageWidth = self.frame.size.width;
    int page = floor((self.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
	for (int i = 0; i <kNumberOfPages*2; i++)
	{
		UIImageView *imgView = [imageArry objectAtIndex:i];
		[imgView removeFromSuperview];
	}
	if(flag == 0)
	{
		[self setFrame:newFrame];
		self.contentSize = CGSizeMake(self.frame.size.width * kNumberOfPages, self.frame.size.height);
		for (int i = 0; i < kNumberOfPages; i++)
		{
			[self loadVScrollViewWithPage:i];
		}
	}
	else
	{
		[self setFrame:newFrame];
		self.contentSize = CGSizeMake(self.frame.size.width * kNumberOfPages, self.frame.size.height);
		for (int i = 0; i < kNumberOfPages; i++)
		{
			[self loadHScrollViewWithPage:i];
		}
	}
	
	[self changePage:page animated:NO];
}

- (void)loadHScrollViewWithPage:(int)page {
    if (page < 0) return;
    if (page >= kNumberOfPages) return;
	
    UIImageView *imgView = [imageArry objectAtIndex:(page + kNumberOfPages)];

	CGRect frame = self.frame;
	frame.origin.x = frame.size.width * page;
	frame.origin.y = 0;
	[imgView setFrame:frame];
	[self addSubview:imgView];

}

- (void)loadVScrollViewWithPage:(int)page {
    if (page < 0) return;
    if (page >= kNumberOfPages) return;

    UIImageView *imgView = [imageArry objectAtIndex:page];

	CGRect frame = self.frame;
	frame.origin.x = frame.size.width * page;
	frame.origin.y = 0;
	[imgView setFrame:frame];
	[self addSubview:imgView];

}
-(void)changePage:(int)page animated:(BOOL)animated
{
	if (page >= kNumberOfPages)
	{
		if ([[ANParamValue sharedInstance] new_fun_flag] == 1) {
			return;
		}
		else {
			[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_popScrollView object:nil];
		}
		return;
	}
	CGRect frame = self.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [self scrollRectToVisible:frame animated:animated];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event 
{
    return;
    if ([[ANParamValue sharedInstance] new_fun_flag] == 1) {
        if (isClicked) {
            isClicked = NO;
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_ShowNavigation object:nil];
            
        }
        else {
            isClicked = YES;
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_HideNavigation object:nil];
            
        }
        return;
    }

}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([[ANParamValue sharedInstance] new_fun_flag] == 1) {
        return;
    }
	CGFloat pageWidth = self.frame.size.width;
    int page = floor((self.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
	page++;
	[self changePage:page animated:YES];
}
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    isClicked = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_HideNavigation object:nil];
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
	if(self.contentOffset.x >= (kNumberOfPages-1)*self.frame.size.width
       || (Interface_Flag == 1 && self.contentOffset.x >= (kNumberOfPages-1)*self.frame.size.height))
	{
		if ([[ANParamValue sharedInstance] new_fun_flag] == 1) {
			return;
		}
		else {
			[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_popScrollView object:nil];
		}
	}
		
	
}

@end

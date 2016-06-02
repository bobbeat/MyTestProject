//
//  GDProgressObject.m
//  AutoNavi
//
//  Created by gaozhimin on 14-7-25.
//
//

#import "GDProgressObject.h"

static UIWindow *g_progressWindow = nil;
static UIWindowLevel Progress_UIWindowLevelSIAlert = 1999.0;  // 不覆盖系统警告

@interface GDProgressView : UIView
{
    UIView *backgroundView;
	UILabel *labelInfo;
	UIImageView *boardView;
	UIActivityIndicatorView *activityView;
}

@end

@implementation GDProgressView

- (instancetype)init
{
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		self.backgroundColor = [UIColor clearColor];
        
        backgroundView = [[UIView alloc] initWithFrame:self.bounds];
		backgroundView.backgroundColor = [UIColor blackColor];
		backgroundView.alpha = 0.2;
		backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[self addSubview:backgroundView];
		
		UIViewAutoresizing viewAutoResizing = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin |
		UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
		
		boardView = [[UIImageView alloc] initWithImage: IMAGE(@"info_bkg.png", IMAGEPATH_TYPE_1)];
        [boardView setFrame:CGRectMake(0.0, 0.0, 130.0, 120.0)];
		boardView.center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2 );
		boardView.autoresizingMask = viewAutoResizing;
		//boardView.userInteractionEnabled = YES;
		
		[self addSubview:boardView];
		
		
		activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		activityView.center = CGPointMake(boardView.bounds.size.width/2, 40);
		activityView.hidesWhenStopped = YES;
        activityView.hidden = NO;
		[boardView addSubview:activityView];
        [activityView startAnimating];
		
		labelInfo = [[UILabel alloc] initWithFrame:CGRectMake(boardView.bounds.size.width/2 - 60,
															  60, boardView.bounds.size.width - 10.0, 60)];
		labelInfo.numberOfLines = 2;
		labelInfo.backgroundColor = [UIColor clearColor];
		labelInfo.textAlignment = UITextAlignmentCenter;
		labelInfo.textColor = [UIColor whiteColor];
		labelInfo.font = [UIFont systemFontOfSize:16];
		labelInfo.shadowColor = [UIColor blackColor];
		labelInfo.shadowOffset = CGSizeMake(0, 1.0);
		[boardView addSubview:labelInfo];
	    
        [backgroundView release];
        [boardView release];
        [labelInfo release];
        [activityView release];
    }
    return self;
}

- (void)dealloc
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
	[super dealloc];
}


- (void)setInfo:(NSString *)info
{
	labelInfo.text = info;
    if (!info || [info length] == 0) {
        activityView.center = CGPointMake(boardView.bounds.size.width/2, boardView.bounds.size.height/2);
    }
    else{
        activityView.center = CGPointMake(boardView.bounds.size.width/2, 40);
    }
    
}
@end


@interface GDProgressViewController : UIViewController

@end

static GDProgressView *g_progressView = nil;

@implementation GDProgressViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (g_progressView == nil)
    {
        g_progressView = [[GDProgressView alloc] initWithFrame:self.view.bounds];
        self.view = g_progressView;
        [g_progressView release];
    }
}

- (void)setInfo:(NSString *)info
{
    if (g_progressView)
    {
        [g_progressView setInfo:info];
    }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    
}

- (BOOL)shouldAutorotate
{
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationUnknown) {
        return YES;
    }
    
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if (!OrientationSwitch)
    {
        return (Orientation == interfaceOrientation);
    }
	return  YES;
    
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationUnknown) {
        [[MWPreference sharedInstance] loadPreference];
    }
    
    if ([[ANParamValue sharedInstance] bSupportAutorate] == NO)
    {
        return  UIInterfaceOrientationMaskPortrait;
    }
    else{
        if (!OrientationSwitch) {
            return (1<<[[UIApplication sharedApplication] statusBarOrientation]);
        }
        return  UIInterfaceOrientationMaskAll;
    }
}

@end

@implementation GDProgressObject

+ (void)ShowProgressWith:(NSString *)tip
{
    if (g_progressWindow)
    {
        return;
    }
    GDProgressViewController *ctl = [[GDProgressViewController alloc] init];
    g_progressWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    g_progressWindow.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    g_progressWindow.opaque = NO;
    g_progressWindow.windowLevel = Progress_UIWindowLevelSIAlert;
    g_progressWindow.rootViewController = ctl;
    g_progressWindow.hidden = NO;
    [ctl release];
    
    [ctl setInfo:tip];
}

+ (void)HideenProgress
{
    if (g_progressView)
    {
        [g_progressView removeFromSuperview];
        g_progressView = nil;
    }
    if (g_progressWindow)
    {
        [g_progressWindow release];
        g_progressWindow = nil;
    }
}

@end

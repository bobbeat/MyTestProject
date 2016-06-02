//
//  GDAlertView.h
//  AutoNavi
//
//  Created by huang longfeng on 13-8-22.
//

#import "GDAlertView.h"
#import <QuartzCore/QuartzCore.h>

NSString *const GDAlertViewWillShowNotification = @"GDAlertViewWillShowNotification";
NSString *const GDAlertViewDidShowNotification = @"GDAlertViewDidShowNotification";
NSString *const GDAlertViewWillDismissNotification = @"GDAlertViewWillDismissNotification";
NSString *const GDAlertViewDidDismissNotification = @"GDAlertViewDidDismissNotification";

#define DEBUG_LAYOUT 0
#define AUTOHIDETIME 2.0
#define MESSAGE_MIN_LINE_COUNT 3
#define MESSAGE_MAX_LINE_COUNT 10
#define GAP 0
#define CANCEL_BUTTON_PADDING_TOP 0
#define LABEL_LEFT  10
#define CONTENT_PADDING_LEFT 0
#define CONTENT_PADDING_TOP 8
#define CONTENT_PADDING_BOTTOM 0
#define BUTTON_HEIGHT 44
#define CONTAINER_WIDTH 280

const UIWindowLevel UIWindowLevelSIAlert = 1999.0;  // 不覆盖系统警告
const UIWindowLevel UIWindowLevelSIAlertBackground = 1998.0; //在 alert window 下面

@class SIAlertBackgroundWindow;

static NSMutableArray *__si_alert_queue;
static BOOL __si_alert_animating;
static SIAlertBackgroundWindow *__si_alert_background_window;
static GDAlertView *__si_alert_current_view;

static BOOL isShouldAutorotate=YES;

@interface GDAlertView ()

@property (nonatomic, retain) NSMutableArray *items;
@property (nonatomic, retain) UIWindow *alertWindow;
@property (nonatomic, assign, getter = isVisible) BOOL visible;

@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UILabel *messageLabel;
@property (nonatomic, retain) UIView *containerView;
@property (nonatomic, retain) NSMutableArray *buttons;

@property (nonatomic, assign, getter = isLayoutDirty) BOOL layoutDirty;

+ (NSMutableArray *)sharedQueue;
+ (GDAlertView *)currentAlertView;

+ (BOOL)isAnimating;
+ (void)setAnimating:(BOOL)animating;

+ (void)showBackground;
+ (void)hideBackgroundAnimated:(BOOL)animated;

- (void)setup;
- (void)invaliadateLayout;
- (void)resetTransition;

@end

#pragma mark - SIBackgroundWindow

@interface SIAlertBackgroundWindow : UIView

@end

@interface SIAlertBackgroundWindow ()

@property (nonatomic, assign) GDAlertViewBackgroundStyle style;

@end

@implementation SIAlertBackgroundWindow

@synthesize style;

- (id)initWithFrame:(CGRect)frame andStyle:(GDAlertViewBackgroundStyle)style1
{
    self = [super initWithFrame:frame];
    if (self) {
        self.style = style1;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.opaque = NO;
        self.clipsToBounds = YES;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    switch (self.style) {
        case GDAlertViewBackgroundStyleGradient:
        {
            size_t locationsCount = 2;
            CGFloat locations[2] = {0.0f, 1.0f};
            CGFloat colors[8] = {0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.75f};
            CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
            CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, colors, locations, locationsCount);
            CGColorSpaceRelease(colorSpace);
            
            CGPoint center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
            CGFloat radius = MIN(self.bounds.size.width, self.bounds.size.height) ;
            CGContextDrawRadialGradient (context, gradient, center, 0, center, radius, kCGGradientDrawsAfterEndLocation);
            CGGradientRelease(gradient);
            break;
        }
        case GDAlertViewBackgroundStyleSolid:
        {
            [[UIColor colorWithWhite:0 alpha:0.5] set];
            CGContextFillRect(context, self.bounds);
            break;
        }
    }
}

@end

#pragma mark - SIAlertItem

@interface SIAlertItem : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) GDAlertViewButtonType type;
@property (nonatomic, copy) GDAlertViewHandler action;

@end

@implementation SIAlertItem
-(void)dealloc
{
    if (action) {
        [action release];
        action=nil;
    }
     [super dealloc];
}
@synthesize title,type,action;

@end

#pragma mark - GDAlertViewController

@interface GDAlertViewController : UIViewController

@property (nonatomic, retain) GDAlertView *alertView;

@end

@implementation GDAlertViewController

@synthesize alertView;

#pragma mark - View life cycle

- (void)loadView
{
    self.view = self.alertView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.alertView setup];
}


- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self.alertView resetTransition];
    [self.alertView invaliadateLayout];
}

- (BOOL)shouldAutorotate
{
    
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationUnknown) {
        return YES;
    }
//    if (!OrientationSwitch)
//    {
//        return NO;
//    }
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
    if (isShouldAutorotate==NO) {
        return NO;
    }
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
    
    if (isShouldAutorotate==NO) {
        return UIInterfaceOrientationMaskPortrait;
    }
    
    if (([ANParamValue sharedInstance].isWarningView) && [[ANParamValue sharedInstance] bSupportAutorate] == NO)
    {
        return  UIInterfaceOrientationMaskPortrait;
    }
    else{
        if (!OrientationSwitch){
            return (1<<[[UIApplication sharedApplication] statusBarOrientation]);
        }
        return  UIInterfaceOrientationMaskAll;
    }
}

- (void)dealloc
{
    if (alertView) {
        [alertView release];
        alertView = nil;
    }
    [super dealloc];
}
@end

#pragma mark - SIAlert

@implementation GDAlertView

@synthesize tag,titleColor,title,message,willShowHandler,didShowHandler,willDismissHandler,didDismissHandler,viewBackgroundColor,messageColor,titleFont,messageFont,buttonFont,transitionStyle,backgroundStyle,visible,cornerRadius,shadowRadius,items,alertWindow,containerView,buttons,layoutDirty,titleLabel,messageLabel,autoDismissTime;

+ (void)initialize
{
    if (self != [GDAlertView class])
        return;

    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_5_0) {
        GDAlertView *appearance = [self appearance];
        appearance.viewBackgroundColor = [UIColor clearColor];
        appearance.titleColor = [UIColor blackColor];
        appearance.messageColor = [UIColor blackColor];
        appearance.titleFont = [UIFont boldSystemFontOfSize:20];
        appearance.messageFont = [UIFont boldSystemFontOfSize:17];
        appearance.buttonFont = [UIFont systemFontOfSize:[UIFont buttonFontSize]];
        appearance.cornerRadius = 6.;
        appearance.shadowRadius = 6.;
    }
    
    
}

- (id)init
{
	return [self initWithTitle:nil andMessage:nil];
}

- (id)initWithTitle:(NSString *)titl andMessage:(NSString *)messag
{
	self = [super init];
	if (self) {
		self.title = titl;
        self.message = messag;
		items = [[NSMutableArray alloc] init];
        self.clipsToBounds = YES;
        self.autoDismissTime = 0.0f;
        [self setViewBackgroundColor:[UIColor clearColor]];
        [self setTitleFont:[UIFont boldSystemFontOfSize:20]];
        [self setMessageFont:[UIFont boldSystemFontOfSize:17]];
        [self setTitleColor:[UIColor blackColor]];
        [self setButtonFont:[UIFont systemFontOfSize:[UIFont buttonFontSize]]];
        [self setCornerRadius:6.];
        [self setShadowRadius:6.];
	}
	return self;
}

- (void)dealloc{
    if (title) {
        [title release];
        title = nil;
    }
    if (message) {
        [message release];
        message = nil;
    }
    if (willShowHandler) {
        [willShowHandler release];
        willShowHandler  = nil;
    }
    if (didShowHandler) {
        [didShowHandler release];
        didShowHandler = nil;
    }
    if (willDismissHandler) {
        [willDismissHandler release];
        willDismissHandler = nil;
    }
    if (didDismissHandler) {
        [didDismissHandler release];
        didDismissHandler = nil;
    }
    if (viewBackgroundColor) {
        [viewBackgroundColor release];
        viewBackgroundColor = nil;
    }
    if (titleColor) {
        [titleColor release];
        titleColor = nil;
    }
    if (messageColor) {
        [messageColor release];
        messageColor = nil;
    }
    if (titleFont) {
        [titleFont release];
        titleFont = nil;
    }
    if (messageFont) {
        [messageFont release];
        messageFont = nil;
    }
    if (buttonFont) {
        [buttonFont release];
        buttonFont = nil;
    }
    if (items) {
        [items release];
        items = nil;
    }
    if (alertWindow) {
        [alertWindow release];
        alertWindow = nil;
    }
    if (containerView) {
        [containerView release];
        containerView = nil;
    }
    if (buttons) {
        [buttons release];
        buttons = nil;
    }
    if (titleLabel) {
        [titleLabel release];
        titleLabel = nil;
    }
    if (messageLabel) {
        [messageLabel release];
        messageLabel = nil;
    }
    
    [super dealloc];
}
#pragma mark - Class methods

+ (NSMutableArray *)sharedQueue
{
    if (!__si_alert_queue) {
        __si_alert_queue = [[NSMutableArray alloc] init];
    }
    return __si_alert_queue;
}

+ (GDAlertView *)currentAlertView
{
    return __si_alert_current_view;
}

+ (void)setCurrentAlertView:(GDAlertView *)alertView
{
    __si_alert_current_view = alertView;
}

+ (BOOL)isAnimating
{
    return __si_alert_animating;
}

+ (void)setAnimating:(BOOL)animating
{
    __si_alert_animating = animating;
}

+ (void)showBackground:(UIView *)supperView
{
    if (!__si_alert_background_window) {
        __si_alert_background_window = [[SIAlertBackgroundWindow alloc] initWithFrame:supperView.bounds
                                                                             andStyle:[GDAlertView currentAlertView].backgroundStyle];
        //[__si_alert_background_window makeKeyAndVisible];
        __si_alert_background_window.hidden = NO;
        __si_alert_background_window.alpha = 1.0;
        __si_alert_background_window.userInteractionEnabled = NO;
        [supperView addSubview:__si_alert_background_window];
        [supperView sendSubviewToBack:__si_alert_background_window];
//        [UIView animateWithDuration:0.2
//                         animations:^{
//                             __si_alert_background_window.alpha = 1;
//                         }];
    }
}

+ (void)hideBackgroundAnimated:(BOOL)animated
{
    if (__si_alert_background_window)
    {
        [__si_alert_background_window removeFromSuperview];
        [__si_alert_background_window release];
        __si_alert_background_window = nil;
    }
}

+ (void)dismissCurrentAlertView
{
    if ([GDAlertView currentAlertView].isVisible) {
        GDAlertView *alert = [GDAlertView currentAlertView];
        [alert dismissAlert];
    }
}

+(void)dismissAllAlertView
{
    NSMutableArray *dismissArray = [[NSMutableArray alloc] init];
    
    for (GDAlertView *alertView in [GDAlertView sharedQueue]) {
        [dismissArray addObject:alertView];
    }
    
    for (GDAlertView *alertView in dismissArray) {
        [alertView dismissAlert];
    }
    
    [dismissArray release];
}

+ (void)shouldAutorotate:(BOOL)autorotate
{
    isShouldAutorotate=autorotate;
}
#pragma mark - Setters

- (void)setTitle:(NSString *)titl
{
    title = [titl retain];
	[self invaliadateLayout];
}

- (void)setMessage:(NSString *)messag
{
	message = [messag retain];
    [self invaliadateLayout];
}

#pragma mark - Public

- (void)addButtonWithTitle:(NSString *)titl type:(GDAlertViewButtonType)type handler:(GDAlertViewHandler)handler
{
    SIAlertItem *item = [[SIAlertItem alloc] init];
	item.title = titl;
	item.type = type;
	item.action = handler;
	[self.items addObject:item];
    [item release];
}

- (void)show
{
    if (![[GDAlertView sharedQueue] containsObject:self]) {
        [[GDAlertView sharedQueue] addObject:self];
    }
    
    if ([GDAlertView isAnimating]) {
        return; // wait for next turn
    }
    
    if (self.isVisible) {
        return;
    }
    
    if ([GDAlertView currentAlertView].isVisible) {
        GDAlertView *alert = [GDAlertView currentAlertView];
        [alert dismissAnimated:YES cleanup:NO];
        return;
    }
    
    if (self.willShowHandler) {
        self.willShowHandler(self);
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:GDAlertViewWillShowNotification object:self userInfo:nil];
    
    self.visible = YES;
    
    [GDAlertView setAnimating:YES];
    [GDAlertView setCurrentAlertView:self];
    
    
    
    GDAlertViewController *viewController = [[GDAlertViewController alloc] initWithNibName:nil bundle:nil];
    viewController.alertView = self;
   
    if (!self.alertWindow)
    {
        
        UIWindow *window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        window.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        window.opaque = NO;
        window.windowLevel = UIWindowLevelSIAlert;
        window.rootViewController = viewController;
        self.alertWindow = window;
        [window release];
        
        //self.alertWindow = [[UIApplication sharedApplication].windows objectAtIndex:0];
    }
    [viewController release];
    
    // transition background
    [GDAlertView showBackground:self.alertWindow];
    
    //[self.alertWindow makeKeyAndVisible];
    self.alertWindow.hidden = NO;
    
    [self validateLayout];
    
    [self transitionInCompletion:^{
        if (self.didShowHandler) {
            self.didShowHandler(self);
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:GDAlertViewDidShowNotification object:self userInfo:nil];
        
        [GDAlertView setAnimating:NO];
       
        NSInteger index = [(NSMutableArray *)[GDAlertView sharedQueue] indexOfObject:self];
        if (index < [GDAlertView sharedQueue].count - 1) {
            [self dismissAnimated:YES cleanup:NO]; // dismiss to show next alert view
        }
    }];
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

- (void)dismissAnimated:(BOOL)animated
{
    [self dismissAnimated:animated cleanup:YES];
}

- (void)dismissAnimated:(BOOL)animated cleanup:(BOOL)cleanup
{
    BOOL isVisible = self.isVisible;
    
    if (isVisible) {
        if (self.willDismissHandler) {
            self.willDismissHandler(self);
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:GDAlertViewWillDismissNotification object:self userInfo:nil];
    }
    
    void (^dismissComplete)(void) = ^{
        self.visible = NO;
        
        [self teardown];
        
        [GDAlertView setCurrentAlertView:nil];
        
        GDAlertView *nextAlertView = nil;
        NSInteger index = [[GDAlertView sharedQueue] indexOfObject:self];
        if (index != NSNotFound && index < [GDAlertView sharedQueue].count - 1) {
            nextAlertView = [GDAlertView sharedQueue][index + 1];
        }
        
        if (cleanup) {
            [[GDAlertView sharedQueue] removeObject:self];
        }
        
        [GDAlertView setAnimating:NO];
        
        if (isVisible) {
            if (self.didDismissHandler) {
                self.didDismissHandler(self);
            }
            //[[NSNotificationCenter defaultCenter] postNotificationName:GDAlertViewDidDismissNotification object:self userInfo:nil];
        }
        
        // check if we should show next alert
        if (!isVisible) {
            return;
        }
        
        if (nextAlertView) {
            [nextAlertView show];
        } else {
            // show last alert view
            if ([GDAlertView sharedQueue].count > 0) {
                GDAlertView *alert = [[GDAlertView sharedQueue] lastObject];
                [alert show];
            }
        }
    };
    
    if (animated && isVisible) {
        [GDAlertView setAnimating:YES];
        
        if ([GDAlertView sharedQueue].count == 1) {
            [GDAlertView hideBackgroundAnimated:YES];
        }
        
        [self transitionOutCompletion:dismissComplete];
        
        
        
    } else {
        dismissComplete();
        
        if ([GDAlertView sharedQueue].count == 0) {
            [GDAlertView hideBackgroundAnimated:YES];
        }
    }
}

#pragma mark - Transitions

- (void)transitionInCompletion:(void(^)(void))completion
{
    switch (self.transitionStyle) {
        case GDAlertViewTransitionStyleSlideFromBottom:
        {
            CGRect rect = self.containerView.frame;
            CGRect originalRect = rect;
            rect.origin.y = self.bounds.size.height;
            self.containerView.frame = rect;
            [UIView animateWithDuration:0.3
                             animations:^{
                                 self.containerView.frame = originalRect;
                             }
                             completion:^(BOOL finished) {
                                 if (completion) {
                                     completion();
                                 }
                             }];
        }
            break;
        case GDAlertViewTransitionStyleSlideFromTop:
        {
            CGRect rect = self.containerView.frame;
            CGRect originalRect = rect;
            rect.origin.y = -rect.size.height;
            self.containerView.frame = rect;
            [UIView animateWithDuration:0.3
                             animations:^{
                                 self.containerView.frame = originalRect;
                             }
                             completion:^(BOOL finished) {
                                 if (completion) {
                                     completion();
                                 }
                             }];
        }
            break;
        case GDAlertViewTransitionStyleFade:
        {
            self.containerView.alpha = 0;
            [UIView animateWithDuration:0.3
                             animations:^{
                                 self.containerView.alpha = 1;
                             }
                             completion:^(BOOL finished) {
                                 if (completion) {
                                     completion();
                                 }
                             }];
        }
            break;
        case GDAlertViewTransitionStyleBounce:
        {
            self.containerView.alpha = 0.0f;
			[UIView animateWithDuration:0.17 animations:^{
				self.containerView.layer.transform = CATransform3DMakeScale(1.1, 1.1, 1.0);
				self.containerView.alpha = 1.0f;
			} completion:^(BOOL finished) {
				[UIView animateWithDuration:0.12 animations:^{
					self.containerView.layer.transform = CATransform3DMakeScale(0.9, 0.9, 1.0);
				} completion:^(BOOL finished) {
					[UIView animateWithDuration:0.1 animations:^{
						self.containerView.layer.transform = CATransform3DIdentity;
					} completion:^(BOOL finished) {
						if (completion)
							completion();
					}];
				}];
			}];
        }
            break;
        case GDAlertViewTransitionStyleFlipVertical:
        
        case GDAlertViewTransitionStyleFlipHorizontal:
        {
            CGFloat xAxis = (self.transitionStyle == GDAlertViewTransitionStyleFlipVertical) ? 1.0 : 0.0;
            CGFloat yAxis = (self.transitionStyle == GDAlertViewTransitionStyleFlipHorizontal) ? 1.0 : 0.0;
            
        
                self.containerView.layer.zPosition = 100;
                
                CATransform3D perspectiveTransform = CATransform3DIdentity;
                perspectiveTransform.m34 = 1.0 / -500;
                
                // initial starting rotation
                self.containerView.layer.transform = CATransform3DConcat(CATransform3DMakeRotation(70.0 * M_PI / 180.0, xAxis, yAxis, 0.0), perspectiveTransform);
                self.containerView.alpha = 0.0f;
                
               // [self showOverlay:YES];
                
                [UIView animateWithDuration:0.2 animations:^{ // flip remaining + bounce
                    self.containerView.layer.transform = CATransform3DConcat(CATransform3DMakeRotation(-25.0 * M_PI / 180.0, xAxis, yAxis, 0.0), perspectiveTransform);
                    self.containerView.alpha = 1.0f;
                } completion:^(BOOL finished) {
                    [UIView animateWithDuration:0.13 animations:^{
                        self.containerView.layer.transform = CATransform3DConcat(CATransform3DMakeRotation(12.0 * M_PI / 180.0, xAxis, yAxis, 0.0), perspectiveTransform);
                    } completion:^(BOOL finished) {
                        [UIView animateWithDuration:0.1 animations:^{
                            self.containerView.layer.transform = CATransform3DConcat(CATransform3DMakeRotation(-8.0 * M_PI / 180.0, xAxis, yAxis, 0.0), perspectiveTransform);
                        } completion:^(BOOL finished) {
                            [UIView animateWithDuration:0.1 animations:^{
                                self.containerView.layer.transform = CATransform3DConcat(CATransform3DMakeRotation(0.0 * M_PI / 180.0, xAxis, yAxis, 0.0), perspectiveTransform);
                            } completion:^(BOOL finished) {
                                if (completion)
                                    completion();
                            }];
                        }];
                    }];
                }];
            
        }
            break;
            
        case GDAlertViewTransitionStyleNone:
        {
            if (completion) {
                completion();
            }
        }
            break;
        default:
            break;
    }
}

- (void)transitionOutCompletion:(void(^)(void))completion
{
    switch (self.transitionStyle) {
        case GDAlertViewTransitionStyleSlideFromBottom:
        {
            if (completion) {
                completion();
            }
//            CGRect rect = self.containerView.frame;
//            rect.origin.y = self.bounds.size.height;
//            [UIView animateWithDuration:0.3
//                                  delay:0
//                                options:UIViewAnimationOptionCurveEaseIn
//                             animations:^{
//                                 self.containerView.frame = rect;
//                             }
//                             completion:^(BOOL finished) {
//                                 if (completion) {
//                                     completion();
//                                 }
//                             }];
        }
            break;
        case GDAlertViewTransitionStyleSlideFromTop:
        {
            CGRect rect = self.containerView.frame;
            rect.origin.y = -rect.size.height;
            [UIView animateWithDuration:0.3
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseIn
                             animations:^{
                                 self.containerView.frame = rect;
                             }
                             completion:^(BOOL finished) {
                                 if (completion) {
                                     completion();
                                 }
                             }];
        }
            break;
        case GDAlertViewTransitionStyleFade:
        {
            [UIView animateWithDuration:0.25
                             animations:^{
                                 self.containerView.alpha = 0;
                             }
                             completion:^(BOOL finished) {
                                 if (completion) {
                                     completion();
                                 }
                             }];
        }
            break;
        case GDAlertViewTransitionStyleBounce:
        {
            if (completion) {
                completion();
            }
            
            
//            [UIView animateWithDuration:0.1 animations:^{
//				self.containerView.layer.transform = CATransform3DMakeScale(1.1, 1.1, 1.0);
//			} completion:^(BOOL finished) {
//				[UIView animateWithDuration:0.15 animations:^{
//					self.containerView.layer.transform = CATransform3DIdentity;
//					self.containerView.alpha = 0.0f;
//				} completion:^(BOOL finished) {
//					//[self cleanup];
//					if (completion)
//						completion();
//				}];
//			}];
        }
            break;
        case GDAlertViewTransitionStyleFlipVertical:
        case GDAlertViewTransitionStyleFlipHorizontal:
        {
            CGFloat xAxis = (self.transitionStyle == GDAlertViewTransitionStyleFlipVertical) ? 1.0 : 0.0;
            CGFloat yAxis = (self.transitionStyle == GDAlertViewTransitionStyleFlipHorizontal) ? 1.0 : 0.0;
           // [self showOverlay:NO];
			
			self.containerView.layer.zPosition = 100;
			self.containerView.alpha = 1.0f;
			
			CATransform3D perspectiveTransform = CATransform3DIdentity;
			perspectiveTransform.m34 = 1.0 / -500;
			
			[UIView animateWithDuration:0.08 animations:^{
				self.containerView.layer.transform = CATransform3DConcat(CATransform3DMakeRotation(-10.0 * M_PI / 180.0, xAxis, yAxis, 0.0), perspectiveTransform);
			} completion:^(BOOL finished) {
				[UIView animateWithDuration:0.17 animations:^{
					self.containerView.layer.transform = CATransform3DConcat(CATransform3DMakeRotation(70.0 * M_PI / 180.0, xAxis, yAxis, 0.0), perspectiveTransform);
					self.containerView.alpha = 0.0f;
				} completion:^(BOOL finished) {
					//[self cleanup];
					if (completion)
						completion();
				}];
			}];
        }
            break;
        default:
            break;

    }
}

- (void)resetTransition
{
    [self.containerView.layer removeAllAnimations];
}

#pragma mark - Layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self validateLayout];
}

- (void)invaliadateLayout
{
    self.layoutDirty = YES;
    [self setNeedsLayout];
}

- (void)validateLayout
{
    if (!self.isLayoutDirty) {
        return;
    }
    self.layoutDirty = NO;
#if DEBUG_LAYOUT
    NSLog(@"%@, %@", self, NSStringFromSelector(_cmd));
#endif
    
    CGFloat height = [self preferredHeight];
    CGFloat left = (self.bounds.size.width - CONTAINER_WIDTH) * 0.5;
    CGFloat top = (self.bounds.size.height - height) * 0.5-6.;
    self.containerView.transform = CGAffineTransformIdentity;
    self.containerView.frame = CGRectMake(left, top, CONTAINER_WIDTH, height);
    self.containerView.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.containerView.bounds cornerRadius:self.containerView.layer.cornerRadius].CGPath;
    self.containerView.clipsToBounds = YES;
    CGFloat y = CONTENT_PADDING_TOP;
	if (self.titleLabel) {
        self.titleLabel.text = self.title;
        CGFloat height = [self heightForTitleLabel];
        self.titleLabel.frame = CGRectMake(LABEL_LEFT, y, self.containerView.bounds.size.width - LABEL_LEFT * 2, height);
        y += height;
	}
    if (self.messageLabel) {
        if (y > CONTENT_PADDING_TOP) {
            y += GAP;
        }
        self.messageLabel.text = self.message;
        CGFloat height = [self heightForMessageLabel];
        self.messageLabel.frame = CGRectMake(LABEL_LEFT, y, self.containerView.bounds.size.width - LABEL_LEFT * 2, height);
        y += height;
    }
    if (self.items.count > 0) {
        if (y > CONTENT_PADDING_TOP) {
            y += GAP;
        }
        if (self.items.count == 2) {
            if (!self.buttons || self.buttons.count < 2) {
                return;
            }
            CGFloat width = (self.containerView.bounds.size.width - CONTENT_PADDING_LEFT * 2 - GAP) * 0.5;
            UIButton *button = self.buttons[0];
           
            button.frame = CGRectMake(CONTENT_PADDING_LEFT, y, width, BUTTON_HEIGHT);
            [button setBackgroundImage:[IMAGE(@"AlertViewButtonBac1.png", IMAGEPATH_TYPE_1) stretchableImageWithLeftCapWidth:3 topCapHeight:3] forState:UIControlStateNormal];
            
            button = self.buttons[1];
            
            button.frame = CGRectMake(CONTENT_PADDING_LEFT + width + GAP, y, width, BUTTON_HEIGHT);
            [button setBackgroundImage:[IMAGE(@"AlertViewButtonBac2.png", IMAGEPATH_TYPE_1) stretchableImageWithLeftCapWidth:3 topCapHeight:3] forState:UIControlStateNormal];
            
        } else {
            for (NSUInteger i = 0; i < self.buttons.count; i++) {
                UIButton *button = self.buttons[i];
                if ((i > 1) && (i == self.buttons.count - 1)) {//大于等于三行，最后一行都用粗体显示
                    [button.titleLabel setFont:[UIFont boldSystemFontOfSize:17.]];
                }
                button.frame = CGRectMake(CONTENT_PADDING_LEFT, y, self.containerView.bounds.size.width - CONTENT_PADDING_LEFT * 2, BUTTON_HEIGHT);
                [button setBackgroundImage:[IMAGE(@"AlertViewButtonBac2.png", IMAGEPATH_TYPE_1) stretchableImageWithLeftCapWidth:3 topCapHeight:3] forState:UIControlStateNormal];
                
                if (self.buttons.count > 1) {
                    if (i == self.buttons.count - 1 && ((SIAlertItem *)self.items[i]).type == GDAlertViewButtonTypeCancel) {
                        CGRect rect = button.frame;
                        rect.origin.y += CANCEL_BUTTON_PADDING_TOP;
                        button.frame = rect;
                       
                    }
                    y += BUTTON_HEIGHT + GAP;
                }
            }
        }
    }
    else{
        self.containerView.frame = CGRectMake(left, top, CONTAINER_WIDTH, height + 5.);
        double dismissTime = AUTOHIDETIME;
        if (autoDismissTime > 0.0f) {
            dismissTime = autoDismissTime;
        }
        [NSTimer scheduledTimerWithTimeInterval:dismissTime target:self selector:@selector(dismissAlert) userInfo:nil repeats:NO];
    }
}

- (CGFloat)preferredHeight
{
	CGFloat height = CONTENT_PADDING_TOP;
	if (self.title) {
		height += [self heightForTitleLabel];
	}
    if (self.message) {
        if (height > CONTENT_PADDING_TOP) {
            height += GAP;
        }
        height += [self heightForMessageLabel];
    }
    if (self.items.count > 0) {
        if (height > CONTENT_PADDING_TOP) {
            height += GAP;
        }
        if (self.items.count <= 2) {
            height += BUTTON_HEIGHT;
        } else {
            height += (BUTTON_HEIGHT + GAP) * self.items.count - GAP;
            if (self.buttons.count > 2 && ((SIAlertItem *)[self.items lastObject]).type == GDAlertViewButtonTypeCancel) {
                height += CANCEL_BUTTON_PADDING_TOP;
            }
        }
    }
    height += CONTENT_PADDING_BOTTOM;
	return height;
}

- (CGFloat)heightForTitleLabel
{
    if (self.titleLabel) {
        CGSize size = [self.title sizeWithFont:self.titleLabel.font
                                   minFontSize:
#ifndef __IPHONE_6_0
                       self.titleLabel.font.pointSize * self.titleLabel.minimumScaleFactor
#else
                       self.titleLabel.minimumFontSize
#endif
                                actualFontSize:nil
                                      forWidth:CONTAINER_WIDTH - CONTENT_PADDING_LEFT * 2
                                 lineBreakMode:self.titleLabel.lineBreakMode];
        return size.height;
    }
    return 0;
}

- (CGFloat)heightForMessageLabel
{
    CGFloat minHeight = (MESSAGE_MIN_LINE_COUNT * self.messageLabel.font.lineHeight)*3.0/5.0;
    if (self.messageLabel) {
        CGFloat maxHeight = MESSAGE_MAX_LINE_COUNT * self.messageLabel.font.lineHeight;
        
        CGSize size;
        
        if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1)
        {
            NSAttributedString *attributedText =
            [[NSAttributedString alloc]
             initWithString:self.messageLabel.text
             attributes:@
             {
             NSFontAttributeName: self.messageLabel.font
             }];
            CGRect rect = [attributedText boundingRectWithSize:(CGSize){CONTAINER_WIDTH - 10 * 2, maxHeight}
                                                       options:NSStringDrawingUsesLineFragmentOrigin
                                                       context:nil];
            [attributedText release];
            size = rect.size;
        }
        else{
            size = [self.message sizeWithFont:self.messageLabel.font
                            constrainedToSize:CGSizeMake(CONTAINER_WIDTH - 10 * 2, maxHeight)
                                lineBreakMode:self.messageLabel.lineBreakMode];
        }
        
        return (MAX(minHeight, size.height)+20.);
    }
    return minHeight;
}

#pragma mark - Setup

- (void)setup
{
    [self setupContainerView];
    [self updateTitleLabel];
    [self updateMessageLabel];
    [self setupButtons];
    [self invaliadateLayout];
}

- (void)teardown
{
    [self.containerView removeFromSuperview];
    containerView = nil;
    titleLabel = nil;
    messageLabel = nil;
    [self.buttons removeAllObjects];
    [self.alertWindow removeFromSuperview];
    [alertWindow release];
    alertWindow = nil;
    [self removeFromSuperview];
}

- (void)setupContainerView
{
    containerView = [[UIView alloc] initWithFrame:self.bounds];
    self.containerView.backgroundColor = [UIColor colorWithRed:0.933333F green:0.937255F blue:0.933333F alpha:0.97F];
    self.containerView.layer.cornerRadius = self.cornerRadius;
    self.containerView.layer.shadowOffset = CGSizeZero;
    self.containerView.layer.shadowRadius = self.shadowRadius;
    self.containerView.layer.shadowOpacity = 0.5;
    [self addSubview:self.containerView];
    [containerView release];
    
}

- (void)updateTitleLabel
{
	if (self.title) {
		if (!self.titleLabel) {
			titleLabel = [[UILabel alloc] initWithFrame:self.bounds];
			self.titleLabel.textAlignment = NSTextAlignmentCenter;
            self.titleLabel.backgroundColor = [UIColor clearColor];
			self.titleLabel.font = self.titleFont;
            self.titleLabel.textColor = self.titleColor;
            self.titleLabel.adjustsFontSizeToFitWidth = YES;
#ifndef __IPHONE_6_0
            self.titleLabel.minimumScaleFactor = 0.75;
#else
            self.titleLabel.minimumFontSize = self.titleLabel.font.pointSize * 0.75;
#endif
			[self.containerView addSubview:self.titleLabel];
            [titleLabel release];
#if DEBUG_LAYOUT
            self.titleLabel.backgroundColor = [UIColor redColor];
#endif
		}
		self.titleLabel.text = self.title;
	} else {
		[self.titleLabel removeFromSuperview];
		self.titleLabel = nil;
	}
    [self invaliadateLayout];
}

- (void)updateMessageLabel
{
    if (self.message) {
        if (!self.messageLabel) {
            messageLabel = [[UILabel alloc] initWithFrame:self.bounds];
            self.messageLabel.textAlignment = NSTextAlignmentCenter;
            self.messageLabel.backgroundColor = [UIColor clearColor];
            self.messageLabel.font = [UIFont boldSystemFontOfSize:17];
            self.messageLabel.textColor = [UIColor blackColor];
            self.messageLabel.numberOfLines = MESSAGE_MAX_LINE_COUNT;
            [self.containerView addSubview:self.messageLabel];
            [messageLabel release];
#if DEBUG_LAYOUT
            self.messageLabel.backgroundColor = [UIColor redColor];
#endif
        }
        self.messageLabel.text = self.message;
    } else {
        [self.messageLabel removeFromSuperview];
        self.messageLabel = nil;
    }
    [self invaliadateLayout];
}

- (void)setupButtons
{
    if (buttons) {
        [buttons release];
        buttons = nil;
    }
    buttons = [[NSMutableArray alloc] initWithCapacity:self.items.count];
    for (NSUInteger i = 0; i < self.items.count; i++) {
        UIButton *button = [self buttonForItemIndex:i];
        [self.buttons addObject:button];
        [self.containerView addSubview:button];
    }
}

- (UIButton *)buttonForItemIndex:(NSUInteger)index
{
    SIAlertItem *item = self.items[index];
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	button.tag = index;
	button.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    button.titleLabel.font = self.buttonFont;
	[button setTitle:item.title forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor clearColor]];
    
    [button setBackgroundImage:[IMAGE(@"ButtonHightlightBac.png", IMAGEPATH_TYPE_1) stretchableImageWithLeftCapWidth:3 topCapHeight:0] forState:UIControlStateHighlighted];

	switch (item.type) {
		case GDAlertViewButtonTypeCancel:
			[button setTitleColor:[UIColor colorWithRed:0.301961F green:0.549020F blue:0.988235F alpha:1.0F] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor colorWithWhite:1.0 alpha:1.0] forState:UIControlStateHighlighted];
            [button.titleLabel setFont:[UIFont systemFontOfSize:17.]];
			break;
		case GDAlertViewButtonTypeDestructive:
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor colorWithWhite:1 alpha:0.8] forState:UIControlStateHighlighted];
			break;
        case  GDAlertViewButtonTypeBlack:
        {
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor colorWithWhite:1 alpha:0.8] forState:UIControlStateHighlighted];
            [button.titleLabel setFont:[UIFont systemFontOfSize:17.]];
        }break;
            
		case GDAlertViewButtonTypeDefault:
		default:
			[button setTitleColor:[UIColor colorWithRed:0.301961F green:0.549020F blue:0.988235F alpha:1.0F] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor colorWithWhite:1.0 alpha:1.0] forState:UIControlStateHighlighted];
            [button.titleLabel setFont:[UIFont boldSystemFontOfSize:17.]];
			break;
	}

	[button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

#pragma mark - Actions
- (void)dismissAlert
{
    [GDAlertView setAnimating:YES]; // set this flag to YES in order to prevent showing another alert in action block
	[self dismissAnimated:YES];
}
- (void)buttonAction:(UIButton *)button
{
	[GDAlertView setAnimating:YES]; // set this flag to YES in order to prevent showing another alert in action block
    SIAlertItem *item = self.items[button.tag];
	if (item.action) {
		item.action(self);
	}
	[self dismissAnimated:YES];
}

#pragma mark - CAAnimation delegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    void(^completion)(void) = [anim valueForKey:@"handler"];
    if (completion) {
        completion();
    }
}

#pragma mark - UIAppearance setters

- (void)setViewBackgroundColor:(UIColor *)viewBackgroundColo
{
    if (viewBackgroundColor == viewBackgroundColo) {
        return;
    }
    viewBackgroundColor = [viewBackgroundColo retain];
    self.containerView.backgroundColor = viewBackgroundColo;
}

- (void)setTitleFont:(UIFont *)titleFon
{
    if (titleFont == titleFon) {
        return;
    }
    titleFont = [titleFon retain];
    self.titleLabel.font = titleFon;
    [self invaliadateLayout];
}

- (void)setMessageFont:(UIFont *)messageFon
{
    if (messageFont == messageFon) {
        return;
    }
    messageFont = [messageFon retain];
    self.messageLabel.font = messageFon;
    [self invaliadateLayout];
}

- (void)setTitleColor:(UIColor *)titleColo
{
    if (titleColor == titleColo) {
        return;
    }
    titleColor = [titleColo retain];
    self.titleLabel.textColor = titleColo;
}

- (void)setMessageColor:(UIColor *)messageColo
{
    if (messageColor == messageColo) {
        return;
    }
    messageColor = [messageColo retain];
    self.messageLabel.textColor = messageColo;
}

- (void)setButtonFont:(UIFont *)buttonFon
{
    if (buttonFont == buttonFon) {
        return;
    }
    buttonFont = [buttonFon retain];
    for (UIButton *button in self.buttons) {
        button.titleLabel.font = buttonFon;
    }
}

- (void)setCornerRadius:(CGFloat)cornerRadiu
{
    if (cornerRadius == cornerRadiu) {
        return;
    }
    cornerRadius = cornerRadiu;
    self.containerView.layer.cornerRadius = cornerRadiu;
}

- (void)setShadowRadius:(CGFloat)shadowRadiu
{
    if (shadowRadius == shadowRadiu) {
        return;
    }
    shadowRadius = shadowRadiu;
    self.containerView.layer.shadowRadius = shadowRadiu;
}

@end

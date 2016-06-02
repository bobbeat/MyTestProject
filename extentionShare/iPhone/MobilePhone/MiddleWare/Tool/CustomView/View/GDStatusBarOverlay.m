//
//  GDStatusBarOverlay.m
//  AutoNavi
//
//  Created by huang longfeng on 13-12-24.
//
//

#import "GDStatusBarOverlay.h"

#import <QuartzCore/QuartzCore.h>

#define ROTATION_ANIMATION_DURATION [UIApplication sharedApplication].statusBarOrientationAnimationDuration
#define STATUS_BAR_HEIGHT           CGRectGetHeight([UIApplication sharedApplication].statusBarFrame)
#define STATUS_BAR_WIDTH            CGRectGetWidth([UIApplication sharedApplication].statusBarFrame)
#define STATUS_BAR_ORIENTATION      [UIApplication sharedApplication].statusBarOrientation
#define IS_IPAD                     UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad

#define TEXT_LABEL_FONT             [UIFont boldSystemFontOfSize:12]


@interface GDStatusBarOverlay ()

@property (nonatomic, assign) float progress;

@property (nonatomic, retain) UIView *contentView;

@property (nonatomic, retain) UILabel *textLabel;

@property (nonatomic, retain) UILabel *statusLabel;

@property (nonatomic, retain) UIActivityIndicatorView *activityView;

@property (nonatomic, assign) GDStatusBarOverlayAnimationType animation;

@property (nonatomic, assign) UIColor *progressBackgroundColor;

@property (nonatomic, copy) GDStatusBarBasicBlock actionBlock;

- (void)animatateview:(UIView *)view show:(BOOL)show completion:(GDStatusBarBasicBlock)completion;

- (void)animatateview:(UIView *)view
    withAnimationType:(GDStatusBarOverlayAnimationType)animationType
                 show:(BOOL)show
           completion:(GDStatusBarBasicBlock)completion;

- (void)fromTopAnimatateview:(UIView *)view show:(BOOL)show completion:(GDStatusBarBasicBlock)completion;

- (void)fadeAnimatateview:(UIView *)view show:(BOOL)show completion:(GDStatusBarBasicBlock)completion;

- (void)initializeToDefaultState;

- (void)rotateStatusBarWithFrame:(NSValue *)frameValue;

- (void)rotateStatusBarAnimatedWithFrame:(NSValue *)frameValue;

- (void)showMessage:(NSString *)message
         withStatus:(GDStatusBarOverlayStatus)status
           duration:(NSTimeInterval)duration
           animated:(BOOL)animated;

- (void)setStatusBarStyle:(UIStatusBarStyle)statusBarStyle;

@end

@implementation GDStatusBarOverlay

@synthesize progress     = _progress;
@synthesize activityView = _activityView;
@synthesize textLabel    = _textLabel;
@synthesize animation    = _animation;
@synthesize actionBlock  = _actionBlock;
@synthesize contentView  = _contentView;
@synthesize statusLabel  = _statusLabel;


- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (_actionBlock) {
        [_actionBlock release];
        _actionBlock = nil;
    }
    
    [super dealloc];
}

+ (GDStatusBarOverlay *)shared {
    static dispatch_once_t pred = 0;
    static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (id)init {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.windowLevel = UIWindowLevelStatusBar + 1;
        self.frame = CGRectMake(0., 0., APPWIDTH, 20.);
        self.animation = GDStatusBarOverlayAnimationTypeFromTop;
        
        _contentView = [[UIView alloc] initWithFrame:self.frame];
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:self.contentView];
        [_contentView release];
        
        _progressView = [[UIView alloc] initWithFrame:self.frame];
        _progressView.frame = CGRectMake(0, 0, 0, CGRectGetHeight(self.frame));
        [self.contentView addSubview:_progressView];
        [_progressView release];
        
        _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        self.activityView.frame = CGRectMake(4, 4, CGRectGetHeight(self.frame) - 4 * 2, CGRectGetHeight(self.frame) - 4 * 2);
        self.activityView.hidesWhenStopped = YES;
        
        if ([self.activityView respondsToSelector:@selector(setColor:)]) { // IOS5 or greater
            [self.activityView.layer setValue:[NSNumber numberWithFloat:0.7f] forKeyPath:@"transform.scale"];
        }
        
        [self.contentView addSubview:self.activityView];
        [_activityView release];
        
        _statusLabel = [[UILabel alloc] initWithFrame:self.activityView.frame];
        self.statusLabel.backgroundColor = [UIColor clearColor];
        self.statusLabel.textAlignment = UITextAlignmentCenter;
        [self.contentView addSubview:self.statusLabel];
        [_statusLabel release];
        
        _textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.textLabel.frame = CGRectMake(CGRectGetWidth(self.activityView.frame) + 10,
                                          0,
                                          CGRectGetWidth(self.frame) - (CGRectGetWidth(self.activityView.frame) * 2) - (10 * 2),
                                          CGRectGetHeight(self.frame));
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.textLabel.font = TEXT_LABEL_FONT;
        self.textLabel.textAlignment = UITextAlignmentCenter;
        [self.contentView addSubview:self.textLabel];
        [_textLabel release];
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didPressOnView:)];
        [self addGestureRecognizer:tapGestureRecognizer];
        [tapGestureRecognizer release];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(willRotateScreen:)
                                                     name:UIApplicationWillChangeStatusBarFrameNotification object:nil];
        
        self.textLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        [self initializeToDefaultState];
    }
    
    return self;
}


#pragma mark -
#pragma mark Public

- (void)showWithMessage:(NSString *)message loading:(BOOL)loading animated:(BOOL)animated {
    
    [self initializeToDefaultState];
    self.textLabel.text = message;
    self.hidden = NO;
    
    if (YES == loading) {
        
        [self.activityView startAnimating];
    }
    else {
        
        [self.activityView stopAnimating];
    }
    
    if (animated) {
        [self animatateview:self.contentView show:YES completion:nil];
    }
}

- (void)setMessage:(NSString *)message animated:(BOOL)animated {
    
    if (animated) {
        
        [self animatateview:self.textLabel show:NO completion:^{
            self.textLabel.text = message;
            [self animatateview:self.textLabel show:YES completion:nil];
        }];
        
    }
    else {
        
        self.textLabel.text = message;
        
    }
}

- (void)setProgress:(float)progress animated:(BOOL)animated {
    
    _progress = progress;
    
    CGRect frame = _progressView.frame;
    CGFloat width = CGRectGetWidth(self.bounds);
    frame.size.width = width * _progress;
    
    if (animated) {
        [UIView animateWithDuration:0.33 animations:^{
            _progressView.frame = frame;
        }];
    }
    else {
        
        _progressView.frame = frame;
    }
}

- (void)showActivity:(BOOL)show animated:(BOOL)animated {
    
    if (show) {
        
        [self.activityView startAnimating];
        
    }
    else if (NO == animated) {
        
        [self.activityView stopAnimating];
    }
    
    if (animated) {
        
        [self animatateview:self.activityView show:show completion:^{
            if (NO == show) {
                [self.activityView stopAnimating];
            }
        }];
    }
    else {
        
        self.activityView.hidden = !show;
    }
}

- (void)showWithAutoHideMessage:(NSString *)message duration:(NSTimeInterval)duration animated:(BOOL)animated {
    
    [self showMessage:message
           withStatus:GDStatusBarOverlayStatusSuccess
             duration:duration
             animated:animated];
}

- (void)dismissAnimated:(BOOL)animated {
    
    if (animated) {
        
        [self animatateview:self.contentView show:NO completion:^{
            self.hidden = YES;
        }];
    }
    else {
        
        self.hidden = YES;
    }
}


- (void)dismissAnimated {
    
    [self dismissAnimated:YES];
    
}


- (void)dismiss {
    
    [self dismissAnimated:NO];
    
}


- (void)setBackgroundColor:(UIColor *)backgroundColor {
    
    [self.contentView setBackgroundColor:backgroundColor];
    
}

- (void)setStatusBarStyle:(UIStatusBarStyle)statusBarStyle animated:(BOOL)animated {
    
    if (animated) {
        
        [self animatateview:self.contentView show:NO completion:^{
            [self setStatusBarStyle:statusBarStyle];
            [self animatateview:self.contentView show:YES completion:nil];
        }];
    }
    else
    {
        
        [self setStatusBarStyle:statusBarStyle];
    }
}

#pragma mark -
#pragma mark Getters and setters

- (void)setProgressBackgroundColor:(UIColor *)progressBackgroundColor {
    
    _progressView.backgroundColor = progressBackgroundColor;
    
}

- (UIColor *)progressBackgroundColor {
    
    return _progressView.backgroundColor;
    
}

- (void)setProgress:(float)progress {
    
    [self setProgress:progress animated:NO];
    
}

#pragma mark -
#pragma mark Class methods

/**
 显示状态栏信息
 
 @param message  显示信息
 @param loading  是否显示菊花
 @param animated 是否动画
 */
+ (void)showWithMessage:(NSString *)message loading:(BOOL)loading animated:(BOOL)animated {
    [[GDStatusBarOverlay shared] showWithMessage:message loading:loading animated:animated];
}

/**
 改变状态栏文字（在已经有显示状态栏都情况下才能显示）
 
 @param message  显示信息
 @param animated 是否动画
 */
+ (void)setMessage:(NSString *)message animated:(BOOL)animated {
    [[GDStatusBarOverlay shared] setMessage:message animated:animated];
}

/**
 显示状态栏信息（自动隐藏）
 
 @param message  显示信息
 @param duration 显示时间
 @param animated 是否动画
 */
+ (void)showWithAutoHideMessage:(NSString *)message duration:(NSTimeInterval)duration animated:(BOOL)animated {
    [[GDStatusBarOverlay shared] showWithAutoHideMessage:message duration:duration animated:animated];
}

/**
 隐藏状态栏
 
 @param animated 是否动画
 */
+ (void)dismissAnimated:(BOOL)animated {
    [[GDStatusBarOverlay shared] dismissAnimated:animated];
}

/**
 改变进度条进度值
 
 @param progress 进度值1-0
 @param animated 是否动画
 */
+ (void)setProgress:(float)progress animated:(BOOL)animated {
    [[GDStatusBarOverlay shared] setProgress:progress animated:animated];
}

/**
 显示菊花
 
 @param show     是否显示
 @param animated 是否动画
 */
+ (void)showActivity:(BOOL)show animated:(BOOL)animated {
    [[GDStatusBarOverlay shared] showActivity:show animated:animated];
}

/**
 设置状态栏背景颜色
 
 @param backgroundColor 颜色值
 */
+ (void)setBackgroundColor:(UIColor *)backgroundColor {
    [[GDStatusBarOverlay shared] setBackgroundColor:backgroundColor];
}

/**
 设置状态栏样式
 
 @param statusBarStyle  UIStatusBarStyle（状态栏样式）
 @param animated        是否动画
 */
+ (void)setStatusBarStyle:(UIStatusBarStyle)statusBarStyle animated:(BOOL)animated {
    [[GDStatusBarOverlay shared] setStatusBarStyle:statusBarStyle animated:animated];
}

/**
 设置点击状态栏处理
 
 @param actionBlock  block
 */
+ (void)setActionBlock:(GDStatusBarBasicBlock)actionBlock {
    [[GDStatusBarOverlay shared] setActionBlock:actionBlock];
}

/**
 设置进度条背景颜色
 
 @param backgroundColor 颜色值
 */
+ (void)setProgressBackgroundColor:(UIColor *)backgroundColor {
    [[GDStatusBarOverlay shared] setProgressBackgroundColor:backgroundColor];
}

/**
 设置显示动画
 
 @param animation 动画类型GDStatusBarOverlayAnimationType
 */
+ (void)setAnimation:(GDStatusBarOverlayAnimationType)animation {
    [[GDStatusBarOverlay shared] setAnimation:animation];
}

#pragma mark -
#pragma mark Gesture recognizer

- (void)didPressOnView:(UIGestureRecognizer *)gestureRecognizer {
    if (nil != _actionBlock) {
        _actionBlock();
    }
}

#pragma mark -
#pragma mark Rotation

- (void)willRotateScreen:(NSNotification *)notification {
    NSValue *frameValue = [notification.userInfo valueForKey:UIApplicationStatusBarFrameUserInfoKey];
    
    if (NO == self.hidden) {
        [self rotateStatusBarAnimatedWithFrame:frameValue];
    } else {
        [self rotateStatusBarWithFrame:frameValue];
    }
}

#pragma mark -
#pragma mark Private

- (void)setStatusBarStyle:(UIStatusBarStyle)statusBarStyle {
    if (UIStatusBarStyleBlackOpaque == statusBarStyle ||
        UIStatusBarStyleBlackTranslucent == statusBarStyle ||
        IS_IPAD) {
        
        [self setBackgroundColor:[UIColor colorWithWhite:0. alpha:0.8]];
        self.textLabel.textColor = [UIColor whiteColor];
        [self setProgressBackgroundColor:[UIColor colorWithRed:48/255.0f green:159/255.0f blue:211/255.0f alpha:1]];
        [self.activityView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
        
    } else {
        [self setBackgroundColor:[UIColor whiteColor]];
        self.textLabel.textColor = [UIColor blackColor];
        [self setProgressBackgroundColor:[UIColor blueColor]];
        [self.activityView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    }
    
    [self setProgressBackgroundColor:[UIColor blueColor]];
    self.statusLabel.textColor = self.textLabel.textColor;
}

- (void)showMessage:(NSString *)message
         withStatus:(GDStatusBarOverlayStatus)status
           duration:(NSTimeInterval)duration
           animated:(BOOL)animated {
    
    if (YES == self.hidden) {
        [self setMessage:message animated:NO];
        [self initializeToDefaultState];
        [self.activityView stopAnimating];
        self.hidden = NO;
        
        if (animated) {
            [self animatateview:self.contentView show:YES completion:nil];
        }
    } else {
        [self setMessage:message animated:animated];
        [self showActivity:NO animated:animated];
        [self fadeAnimatateview:_progressView show:NO completion:nil];
    }
    
    [self performSelector:(animated) ? @selector(dismissAnimated) : @selector(hide)
               withObject:nil
               afterDelay:duration];
}

- (void)rotateStatusBarAnimatedWithFrame:(NSValue *)frameValue {
    [UIView animateWithDuration:ROTATION_ANIMATION_DURATION animations:^{
       // self.alpha = 0;
    } completion:^(BOOL finished) {
        [self rotateStatusBarWithFrame:frameValue];
        [UIView animateWithDuration:ROTATION_ANIMATION_DURATION animations:^{
         //   self.alpha = 1;
        }];
    }];
}


- (void)rotateStatusBarWithFrame:(NSValue *)frameValue {
   // CGRect frame = [frameValue CGRectValue];
    UIInterfaceOrientation orientation = STATUS_BAR_ORIENTATION;
    
    if (UIDeviceOrientationPortrait == orientation) {
        self.transform = CGAffineTransformIdentity;
    } else if (UIDeviceOrientationPortraitUpsideDown == orientation) {
        self.transform = CGAffineTransformMakeRotation(M_PI);
    } else if (UIDeviceOrientationLandscapeRight == orientation) {
        self.transform = CGAffineTransformMakeRotation(M_PI * (-90.0f) / 180.0f);
    } else {
        self.transform = CGAffineTransformMakeRotation(M_PI * 90.0f / 180.0f);
    }
    
    self.frame = [UIApplication sharedApplication].statusBarFrame;
    
    [self setProgress:self.progress animated:NO];
}

- (void)animatateview:(UIView *)view show:(BOOL)show completion:(GDStatusBarBasicBlock)completion {
    [self animatateview:view withAnimationType:self.animation show:show completion:completion];
}

- (void)animatateview:(UIView *)view
    withAnimationType:(GDStatusBarOverlayAnimationType)animationType
                 show:(BOOL)show
           completion:(GDStatusBarBasicBlock)completion {
    
    if (GDStatusBarOverlayAnimationTypeFade == animationType) {
        [self fadeAnimatateview:view show:show completion:completion];
        
    } else if (GDStatusBarOverlayAnimationTypeFromTop == animationType) {
        [self fromTopAnimatateview:view show:show completion:completion];
        
    }
}

- (void)fadeAnimatateview:(UIView *)view show:(BOOL)show completion:(GDStatusBarBasicBlock)completion {
    if (show) {
        view.alpha = 0;
        view.hidden = NO;
    }
    
    [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        view.alpha = (show) ? 1 : 0;
    } completion:^(BOOL finished) {
        if (NO == show) {
            view.hidden = YES;
            view.alpha = 1;
        }
        
        if (nil != completion)
            completion();
    }];
}

- (void)fromTopAnimatateview:(UIView *)view show:(BOOL)show completion:(GDStatusBarBasicBlock)completion {
    __block CGRect frame = view.frame;
    CGFloat previousY = view.frame.origin.y;
    
    if (show) {
        view.hidden = NO;
        view.alpha = 0;
        frame.origin.y = -CGRectGetHeight(self.frame);
        view.frame = frame;
    }
    
    [UIView animateWithDuration:0.4 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        frame.origin.y += (show ? 1 : -1) * CGRectGetHeight(self.frame);
        view.frame = frame;
        view.alpha = (show) ? 1 : 0;
    } completion:^(BOOL finished) {
        if (NO == show) {
            frame.origin.y = previousY;
            view.frame = frame;
            view.hidden = YES;
            view.alpha = 1;
        }
        
        if (nil != completion)
            completion();
    }];
}

- (void)initializeToDefaultState {
    CGRect statusBarFrame = [UIApplication sharedApplication].statusBarFrame;
    [self rotateStatusBarWithFrame:[NSValue valueWithCGRect:statusBarFrame]];
    [self setProgress:0];
    _progressView.hidden = NO;
    
    [self setStatusBarStyle:[UIApplication sharedApplication].statusBarStyle animated:NO];
}

@end

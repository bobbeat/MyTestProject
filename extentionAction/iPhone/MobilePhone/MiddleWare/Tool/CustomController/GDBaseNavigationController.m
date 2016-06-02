//
//  GDBaseNavigationController.m
//
//
//
// add by hlf for 连续push或pop 动画冲突问题 at 2014.07.19
//

#import "GDBaseNavigationController.h"

typedef void (^GDTransitionBlock)(void);

@interface GDBaseNavigationController () <UINavigationControllerDelegate> {
    BOOL _transitionInProgress;
    NSMutableArray *_peddingBlocks;
    CGFloat _systemVersion;
}

@end

@implementation GDBaseNavigationController

#pragma mark - Creating Navigation Controllers

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    _transitionInProgress = NO;
    _peddingBlocks = [[NSMutableArray alloc] init];
    _systemVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
}

#pragma mark - Pushing and Popping Stack Items

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (_systemVersion >= 8.0) {
        [super pushViewController:viewController animated:animated];
    }
    else {
        [self addTransitionBlock:^{
            [super pushViewController:viewController animated:animated];
        }];
    }
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
    UIViewController *poppedViewController = nil;
    if (_systemVersion >= 8.0) {
        poppedViewController = [super popViewControllerAnimated:animated];
    }
    else {
        __block GDBaseNavigationController *weakSelf = self;
        [self addTransitionBlock:^{
            UIViewController *viewController = [super popViewControllerAnimated:animated];
            if (viewController == nil) {
                weakSelf.transitionInProgress = NO;
            }
        }];
    }
    return poppedViewController;
}

- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    NSArray *poppedViewControllers = nil;
    if (_systemVersion >= 8.0) {
        poppedViewControllers = [super popToViewController:viewController animated:animated];
    }
    else {
        __block GDBaseNavigationController *weakSelf = self;
        [self addTransitionBlock:^{
            if ([weakSelf.viewControllers containsObject:viewController]) {
                NSArray *viewControllers = [super popToViewController:viewController animated:animated];
                if (viewControllers.count == 0) {
                    weakSelf.transitionInProgress = NO;
                }
            }
            else {
                weakSelf.transitionInProgress = NO;
            }
        }];
    }
    return poppedViewControllers;
}

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated
{
    NSArray *poppedViewControllers = nil;
    if (_systemVersion >= 8.0) {
        poppedViewControllers = [super popToRootViewControllerAnimated:animated];
    }
    else {
        __block GDBaseNavigationController *weakSelf = self;
        [self addTransitionBlock:^{
            NSArray *viewControllers = [super popToRootViewControllerAnimated:animated];
            if (viewControllers.count == 0) {
                weakSelf.transitionInProgress = NO;
            }
        }];
    }
    return poppedViewControllers;
}

#pragma mark - Accessing Items on the Navigation Stack

- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated
{
    if (_systemVersion >= 8.0) {
        [super setViewControllers:viewControllers animated:animated];
    }
    else {
        __block GDBaseNavigationController *weakSelf = self;
        [self addTransitionBlock:^{
            NSArray *originalViewControllers = weakSelf.viewControllers;
            NSLog(@"%s", __FUNCTION__);
            [super setViewControllers:viewControllers animated:animated];
            if (!animated || originalViewControllers.lastObject == viewControllers.lastObject) {
                weakSelf.transitionInProgress = NO;
            }
        }];
    }
}

#pragma mark - Transition Manager

- (void)addTransitionBlock:(void (^)(void))block
{
    if (![self isTransitionInProgress]) {
        self.transitionInProgress = YES;
        block();
    }
    else {
        [_peddingBlocks addObject:[block copy]];
    }
}

- (BOOL)isTransitionInProgress
{
    return _transitionInProgress;
}

- (void)setTransitionInProgress:(BOOL)transitionInProgress
{
    _transitionInProgress = transitionInProgress;
    if (!transitionInProgress && _peddingBlocks.count > 0) {
        _transitionInProgress = YES;
        [self runNextTransition];
    }
}

- (void)runNextTransition
{
    GDTransitionBlock block = _peddingBlocks.firstObject;
    [_peddingBlocks removeObject:block];
    block();
}

- (void)dealloc
{
    CRELEASE(_peddingBlocks);
    
    [super dealloc];
}

@end


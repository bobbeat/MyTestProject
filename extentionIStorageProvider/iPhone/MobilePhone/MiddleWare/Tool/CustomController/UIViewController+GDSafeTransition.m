//
//  UIViewController+GDSafeTransition.m
//
//
//
//
//  add by hlf for 连续push或pop 动画冲突问题 at 2014.07.19
//

#import "UIViewController+GDSafeTransition.h"
#import "GDBaseNavigationController.h"
#import <objc/runtime.h>

@implementation UIViewController (GDSafeTransition)

+ (void)load
{
    Method m1;
    Method m2;

    m1 = class_getInstanceMethod(self, @selector(sofaViewDidAppear:));
    m2 = class_getInstanceMethod(self, @selector(viewDidAppear:));
    method_exchangeImplementations(m1, m2);
}


- (void)sofaViewDidAppear:(BOOL)animated
{
    if ([self.navigationController respondsToSelector:@selector(setTransitionInProgress:)]) {
        self.navigationController.transitionInProgress = NO;
    }
    
    [self sofaViewDidAppear:animated];
}

@end

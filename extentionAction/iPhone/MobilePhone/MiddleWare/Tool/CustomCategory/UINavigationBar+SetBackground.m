//
//  UINavigationBar+SetBackground.m
//  AutoNavi
//
//  Created by huang on 13-11-6.
//
//

#import "UINavigationBar+SetBackground.h"
#import <objc/runtime.h>

@implementation UINavigationBar (SetBackground)


static char backgroundImageKey;

// iOS5 之前的版本调用

- (void)drawRect:(CGRect)rect {
    UIImage *image = objc_getAssociatedObject(self, &backgroundImageKey);
    if (!image) {
        image= IMAGE(@"navigatorBarBg.png",IMAGEPATH_TYPE_1);
        objc_setAssociatedObject(self, &backgroundImageKey, image, OBJC_ASSOCIATION_RETAIN);
    }
    [image drawAsPatternInRect:rect];
    return;
}

-(void)setBackgroundImage:(UIImage *)backgroundImage
{
    if ([self respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]) {
        [self setBackgroundImage:backgroundImage forBarMetrics:UIBarMetricsDefault];
    }else{
        objc_setAssociatedObject(self, &backgroundImageKey, backgroundImage, OBJC_ASSOCIATION_RETAIN);
        [self setNeedsDisplay];
    }
}

-(UIImage*)backgroundImage
{
    if ([self respondsToSelector:@selector(backgroundImageForBarMetrics:)]) {
        return [self backgroundImageForBarMetrics:UIBarMetricsDefault];
    }else{
        return objc_getAssociatedObject(self, &backgroundImageKey);
    }
}

@end

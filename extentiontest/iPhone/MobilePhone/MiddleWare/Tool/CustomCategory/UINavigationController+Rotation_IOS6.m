//
//  UINavigationController+Rotation_IOS6.m
//  AutoNavi
//
//  Created by huang on 13-11-6.
//
//

#import "UINavigationController+Rotation_IOS6.h"

@implementation UINavigationController (Rotation_IOS6)
-(BOOL)shouldAutorotate {
    return [[self.viewControllers lastObject] shouldAutorotate];
}

-(NSUInteger)supportedInterfaceOrientations {
    return [[self.viewControllers lastObject] supportedInterfaceOrientations];
}

//- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
//    return [[self.viewControllers lastObject] preferredInterfaceOrientationForPresentation];
//}
@end

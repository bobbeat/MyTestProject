//
//  GDAlertView.h
//  AutoNavi
//
//  Created by huang longfeng on 13-8-22.
//  


#import <UIKit/UIKit.h>

extern NSString *const GDAlertViewWillShowNotification;
extern NSString *const GDAlertViewDidShowNotification;
extern NSString *const GDAlertViewWillDismissNotification;
extern NSString *const GDAlertViewDidDismissNotification;

typedef NS_ENUM(NSInteger, GDAlertViewButtonType) {
    GDAlertViewButtonTypeDefault = 0,
    GDAlertViewButtonTypeDestructive,
    GDAlertViewButtonTypeCancel,
    GDAlertViewButtonTypeBlack,
    
};

typedef NS_ENUM(NSInteger, GDAlertViewBackgroundStyle) {
    GDAlertViewBackgroundStyleGradient = 0,
    GDAlertViewBackgroundStyleSolid,
};

typedef NS_ENUM(NSInteger, GDAlertViewTransitionStyle) {
    GDAlertViewTransitionStyleBounce = 0,
    GDAlertViewTransitionStyleSlideFromTop,
    GDAlertViewTransitionStyleFade,
    GDAlertViewTransitionStyleSlideFromBottom,
    GDAlertViewTransitionStyleFlipHorizontal,
    GDAlertViewTransitionStyleFlipVertical,
    GDAlertViewTransitionStyleNone,
};

@class GDAlertView;
typedef void(^GDAlertViewHandler)(GDAlertView *alertView);

@interface GDAlertView : UIView

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, assign) int tag;
@property (nonatomic, assign) double autoDismissTime;
@property (nonatomic, assign) GDAlertViewTransitionStyle transitionStyle; // default is GDAlertViewTransitionStyleSlideFromBottom
@property (nonatomic, assign) GDAlertViewBackgroundStyle backgroundStyle; // default is GDAlertViewButtonTypeGradient

@property (nonatomic, copy) GDAlertViewHandler willShowHandler;
@property (nonatomic, copy) GDAlertViewHandler didShowHandler;
@property (nonatomic, copy) GDAlertViewHandler willDismissHandler;
@property (nonatomic, copy) GDAlertViewHandler didDismissHandler;

@property (nonatomic, readonly, getter = isVisible) BOOL visible;

@property (nonatomic, retain) UIColor *viewBackgroundColor NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR;
@property (nonatomic, retain) UIColor *titleColor NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR;
@property (nonatomic, retain) UIColor *messageColor NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR;
@property (nonatomic, retain) UIFont *titleFont NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR;
@property (nonatomic, retain) UIFont *messageFont NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR;
@property (nonatomic, retain) UIFont *buttonFont NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR;
@property (nonatomic, assign) CGFloat cornerRadius NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR; // default is 2.0
@property (nonatomic, assign) CGFloat shadowRadius NS_AVAILABLE_IOS(5_0) UI_APPEARANCE_SELECTOR; // default is 8.0

- (id)initWithTitle:(NSString *)titl andMessage:(NSString *)messag;
- (void)addButtonWithTitle:(NSString *)titl type:(GDAlertViewButtonType)type handler:(GDAlertViewHandler)handler;

- (void)show;
- (void)dismissAnimated:(BOOL)animated;
+ (void)dismissCurrentAlertView;
+ (void)shouldAutorotate:(BOOL)autorotate;
+(void)dismissAllAlertView;

@end

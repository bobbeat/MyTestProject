//
//  GDMenu.h
//  AutoNavi
//
//  Created by huang longfeng on 13-8-29.
//
//


#import <Foundation/Foundation.h>

typedef enum {
    
    GDMenuViewBackgroundTypeWhite = 0,  //白天大框
    GDMenuViewBackgroundTypeBlack,      //小框
    GDMenuViewBackgroundTypeNight,      //黑夜大框
} GDMenuViewBackgroundType;

@interface GDMenuItem : NSObject

@property (readwrite, nonatomic, retain) UIImage *image;
@property (readwrite, nonatomic, copy) NSString *title;
@property (readwrite, nonatomic ,assign) id target;
@property (readwrite, nonatomic) SEL action;
@property (readwrite, nonatomic, retain) UIColor *foreColor;
@property (readwrite, nonatomic) NSTextAlignment alignment;

+ (instancetype) menuItem:(NSString *) title
                    image:(UIImage *) image
                   target:(id)target
                   action:(SEL) action;

@end

@interface GDMenu : NSObject

+ (void) showMenuInView:(UIView *)view
               fromRect:(CGRect)rect
              menuItems:(NSArray *)menuItems
         backgroundType:(GDMenuViewBackgroundType)type;

+ (void) dismissMenu;
+ (BOOL)isShowMenu;
+ (void)AutoSetUpFrameInView:(UIView *)view fromRect:(CGRect)rect;
+ (UIColor *) tintColor;
+ (void) setTintColor: (UIColor *) tintColor;

+ (UIFont *) titleFont;
+ (void) setTitleFont: (UIFont *) titleFont;

@end

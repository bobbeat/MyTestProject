//
//  POIKeyBoardButton.h
//  AutoNavi
//
//  Created by huang on 13-8-24.
//
//

#import <Foundation/Foundation.h>
@protocol POIKeyBoardEventProtocol;
//用于键盘上方的按钮
@interface POIKeyBoardEvent : NSObject
{
    UIButton *_button;
    int isShow;               //0表示隐藏，1表示显示
    BOOL isNavigationBarHidden;             //0存在导航条，1没有导航条
    float navigationBarHeight;
}
@property(nonatomic,assign)id<POIKeyBoardEventProtocol> delegate;
@property(nonatomic,retain)UITextField *textFiled;
@property(nonatomic)float addKeyboardButtonY;
@property(nonatomic)BOOL isShowInView;                          //当换去焦点的时候是否显示按钮在界面内 默认不显示NO   YES表示显示
//view 用于显示按钮
-(id)initWithView:(UIView*)view;
//调整控件竖屏坐标和图片
-(void)changePortraitControlFrameWithImage;
//调整控件横屏坐标和图片
-(void)changeLandscapeControlFrameWithImage;
//设置按钮是否隐藏
-(void)setHiddenButton:(BOOL)hidden;
@end

@protocol POIKeyBoardEventProtocol <NSObject>
@optional
-(void)keyBoardEvent:(BOOL)isShow;//0表示隐藏，1表示显示


@end
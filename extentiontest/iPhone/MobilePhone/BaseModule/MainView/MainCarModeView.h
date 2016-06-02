//
//  MainCarModeView.h
//  AutoNavi
//
//  选择视图对象 —— 车首上，北首上，3D
//
//  Created by jiangshu-fu on 14-8-28.
//
//

#import <UIKit/UIKit.h>
#import "MainDefine.h"

@interface MainCarModeView : UIView
{
    UIImageView *_viewSwitchModeBG;              //视图选择按钮背景
    UIButton *_buttonNAngel;                //北
    UIButton *_button3DAngel;               //3D
    UIButton *_buttonCarAngel;              //车
    UIButton *_buttonHUD;                   //HUD
    
    UILabel *_labelNAngel;                //北
    UILabel *_label3DAngel;               //3D
    UILabel *_labelCarAngel;              //车
    UILabel *_labelnHUD;                   //HUD
    
    UIControl *_controlBG;              //半透明背景图
    
    CGPoint _pointAnimate;              //放大缩小的 center
    
    CGSize _sizeButton;               //算上按钮的高宽
}

@property (nonatomic, copy) MainButtonClick mainCarModeClick;

/*!
  @brief    初始化对象
  @param    frame ： 视图的大小
  @param    animateCenter： 视图动画的中心点
  @param    sizeButton:动画中心点按钮的 size
  @author   by bazinga
  */
- (id) initWithFrame:(CGRect)frame withAnimateCenter:(CGPoint)animateCenter withSizeButton:(CGSize) sizeButton;

/*!
  @brief    设置界面的 frame
  @param    frame ： 视图的大小
  @param    animateCenter： 视图动画的中心点
  @param    sizeButton:动画中心点按钮的 size
  @author   by bazinga
  */
- (void) setFrame:(CGRect)frame withAnimateCenter:(CGPoint) animateCenter withSizeButton:(CGSize) sizeButton;

/*!
  @brief    显示和隐藏视图（如果视图在显示，就隐藏，反之显示。）
  @param
  @author   by bazinga
  */
- (void) showHideModeSwitch;

/*!
  @brief    隐藏视图
  @param
  @author   by bazinga
  */
- (void) hideModeSwitch;

/*!
  @brief    语言修改时候，修改文字显示
  @param
  @author   by bazinga
  */
- (void) reloadText;

@end

//
//  POIAroundTextfield.h
//  AutoNavi
//
//  Created by huang on 13-8-24.
//
//

#import <UIKit/UIKit.h>
@protocol POIAroundTextFieldDelegate;
//@class POITextField;
#import "POITextField.h"
//周边的搜索框
@interface POIAroundTextField : UIView<UITextFieldDelegate>
{
    POITextField *_textField;
    UIButton *_button,*_buttonVoice;
    
}
@property(nonatomic,copy)NSString *text;
@property(nonatomic,assign)id<POIAroundTextFieldDelegate> delegate;
@property(nonatomic,readonly)POITextField * textField;
@property(nonatomic,copy)NSString *buttonText;
@property(nonatomic) BOOL isShowAlways;                    //设置YES ,按钮是否一直显示
@property(nonatomic) BOOL isShowButton;                    //是否显示按钮
@property(nonatomic) BOOL resignShowButton;                //失去焦点，是否显示按钮 YES表示显示，NO表示不显示 默认NO
@property (nonatomic) int limitLength;                      //限制输入长度 默认为0，表示不限制输入
@property(nonatomic)BOOL  isHaveVoice;
//调整控件竖屏坐标和图片
-(void)changePortraitControlFrameWithImage;
//调整控件横屏坐标和图片
-(void)changeLandscapeControlFrameWithImage;
//-(void)hiddenButton;
@end


@protocol POIAroundTextFieldDelegate <NSObject>
@optional
-(void)buttonTouchEvent:(NSString*)string withButton:(UIButton*)button;             //按钮点击
-(void)textFieldReturn:(NSString *)string;                                          //return按钮点击
-(void)textFieldBackSpace:(NSString *)string;                                       //退格事件，
-(BOOL)textFieldChanage:(UITextField*)textField withRange:(NSRange)range withString:(NSString*)string;
-(void)textFieldClear:(UITextField*)textField;
@end
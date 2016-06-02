//
//  AccountAgePickerView.h
//  AutoNavi
//
//  Created by gaozhimin on 13-5-16.
//
//

#import <UIKit/UIKit.h>

@interface DatePickerView : UIView<UIPickerViewDataSource,UIPickerViewDelegate>
{
    UIPickerView      *m_pickView;
    UIImageView       *m_pickViewBack;
    UIImageView       *m_imageView;
    
    UIButton          *m_cancelButton;
    UIButton          *m_sureButton;
    UIView            *_blockerView;//背景
    BOOL              isHiddenTopBar;//是否隐藏导航条
}

@property(nonatomic,readonly) UIPickerView *m_pickView;
@property(nonatomic,readonly)  NSMutableArray   *pickerItem;
@property(nonatomic,assign) BOOL                isShow;
@property(nonatomic,assign) int                m_day;  //选择的日期
@property(nonatomic,assign) int                m_hour;
@property(nonatomic,assign) int                m_minus;

@property(nonatomic,assign) int                m_showday;  //每次出现时的日期
@property(nonatomic,assign) int                m_showhour;
@property(nonatomic,assign) int                m_showminus;

- (id)initWithdelegate:(id)delegate cancel:(SEL)cancel_selector sure:(SEL)sure_selector;
- (void)ShowOrHiddenPickView:(BOOL)show Animation:(BOOL)animation;
-(void)setIsHiddenTopBar:(BOOL)hidden;


@end

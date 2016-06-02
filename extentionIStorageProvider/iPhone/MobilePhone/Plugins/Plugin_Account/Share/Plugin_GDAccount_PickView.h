//
//  Plugin_GDAccount_PickView.h
//  AutoNavi
//
//  Created by gaozhimin on 12-12-20.
//
//

#import <UIKit/UIKit.h>

@interface Plugin_GDAccount_PickView : UIView<UIPickerViewDataSource,UIPickerViewDelegate>
{
    UIPickerView      *m_pickView;
    UIImageView       *m_pickBackView;
    UIImageView       *m_imageView;
    
    UIButton          *m_cancelButton;
    UIButton          *m_sureButton;

    NSMutableArray    *pickerItem;
    NSUInteger        citySelectRow;
    
    NSString          *cityName;
    NSString          *townName;
    UIView            *_blockerView;//背景
    BOOL              isHiddenTopBar;//是否隐藏导航条
}

@property(nonatomic,readonly) UIPickerView *m_pickView;
@property(nonatomic,readonly)  NSMutableArray   *pickerItem;
@property (copy,nonatomic) NSString                  *cityName; //选择的城市
@property (copy,nonatomic) NSString                   *townName;

@property (copy,nonatomic) NSString                  *show_cityName;  //每次出现显示的名称
@property (copy,nonatomic) NSString                   *show_townName;

@property(nonatomic,assign) BOOL                isShow;

- (id)initWithdelegate:(id)delegate cancel:(SEL)cancel_selector sure:(SEL)sure_selector;
- (void)ShowOrHiddenPickView:(BOOL)show Animation:(BOOL)animation;
-(void)setIsHiddenTopBar:(BOOL)hidden;

@end

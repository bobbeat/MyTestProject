//
//  CustomBtn.h
//  AutoNavi
//
//  Created by liyuhang on 12-12-20.
//
//

#import <UIKit/UIKit.h>
#import "MoveTextLable.h"
/*
 自定义按钮
 1 暂时支持显示3行文本，因为各行文本不同
 2 3行文本两种方式1独立三行；2两行一个上面，两个下面
 */

@interface CustomBtn : UIButton
{
    MoveTextLable *m_labelTitle1;
    MoveTextLable *m_labelTitle2;
    MoveTextLable *m_labelTitle3;
    // 两段文字，第二段文字显示不同颜色
    //
    float   m_fOffsetForTitle;          // 标签右移
    float   m_fOffsetForTitleRight;     // 标签左移
    int     m_nLableNumber;               // 标签个数
    int     m_nStyleForThreeLable;      // 0 三个独立分行；1 两个分行，一个上面，两个下面;2 一行两文本，两个颜色
    // label高度开始位置
    int     m_nHeightOffSet;            // 路况信息条，因为图片不规则，加特殊处理
}
@property (nonatomic, readonly) UILabel *psLabelTitle1;
@property (nonatomic, readonly) UILabel *psLabelTitle2;
@property (nonatomic, readonly) UILabel *psLabelTitle3;
@property (nonatomic, assign) float psfOffsetForTitle;
@property (nonatomic, assign) float psfOffsetForTitleRight;
@property (nonatomic, assign) int psnLabelNumber;
@property (nonatomic, assign) int psnStyleForThreeLable;
@property (nonatomic, assign) int psnHeightOffset;


- (id)createButtonWithTitle:(NSString *)titleT normalImage:(NSString *)normalImage heightedImage:(NSString *)heightedImage tag:(NSInteger)tagN strechParamX:(NSInteger)xParam strechParamY:(NSInteger)yParam;
-(void) setBtnFrame:(CGRect) rcFrame;               // 设置区域，同时重新设置子区域
-(void) setTitleSubViewNumber:(int) nNum;           // 添加标题
-(void) setViewHidden:(BOOL)bHidden;                                     //  设置视图的隐藏喝显示
@end

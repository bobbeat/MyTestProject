//
//  SoundGuideView.h
//  AutoNavi
//
//  Created by jiangshu-fu on 14-6-18.
//
//

#import <UIKit/UIKit.h>
//返回按钮
typedef void (^ButtonCloseClick)(id);
//确定按钮
typedef void (^ButtonCotinueClick)(id);

@interface SoundGuideView : UIImageView


@property (nonatomic, assign) BOOL isHidden;
@property (nonatomic, copy) ButtonCloseClick clickClose;
@property (nonatomic, copy) ButtonCotinueClick clickContinue;
@property (nonatomic, retain) UIImageView *soundView;

/*!
  @brief    初始化函数
  @param
  @author   by bazinga
  */
- (id) initHiddenRect:(CGRect)rect;

- (void) setHiddenFrame:(CGRect)frame;

@end

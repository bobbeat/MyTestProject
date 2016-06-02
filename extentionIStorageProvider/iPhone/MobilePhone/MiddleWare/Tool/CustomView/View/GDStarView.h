//
//  GDStarView.h
//  AutoNavi
//
//  Created by gaozhimin on 14-6-16.
//
//

#import <UIKit/UIKit.h>

@interface GDStarView : UIView

/*
 *@bief初始化
 *@param count 传入星星的个数
 *@param score 传入的分数
 */
- (id)initWithCount:(int)count score:(int)score;

/*
 *@bief设置分数
 *@param score 分值
 */
- (void)SetScore:(int)score;
@end

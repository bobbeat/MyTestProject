//
//  POITableHeadView.h
//  AutoNavi
//
//  Created by huang on 13-9-10.
//
//

#import <UIKit/UIKit.h>

@interface POITableHeadView : UIView
@property(nonatomic,copy)NSString *title;
@property(nonatomic) BOOL deletaBtn;
@property (nonatomic)BOOL group;
-(void)downMove;//向下移动15个像素
-(id)initWithTitle:(NSString*)title;
-(id)initWithTitle:(NSString *)title WithTarget:(id)target WithSelector:(SEL)sel;
-(void)setImageViewWidth:(float)width;
@end

//
//  POIToolBar.h
//  AutoNavi
//
//  Created by huang on 13-9-10.
//
//

#import <Foundation/Foundation.h>

typedef enum
{
    POITOOLBAR_IN_BUTTON_HEAD,//线在头部
    POITOOLBAR_IN_BUTTON_FOOTER,//线在底部
    POITOOLBAR_IN_BUTTON_NO,//不存在线
}POITOOLBAR_ACTION_TYPE;

@interface POIToolBar : NSObject
{
    UIView *_viewAction;
    NSMutableArray *_buttonArray;
    
    
}
@property(nonatomic,copy)UIColor *viewColor;
@property(nonatomic)POITOOLBAR_ACTION_TYPE type;
-(id)initWithView:(UIView*)superView withHighlighted:(int)whichOne withButtons:(UIButton*)buttons,...;
-(void)refresh;
@end

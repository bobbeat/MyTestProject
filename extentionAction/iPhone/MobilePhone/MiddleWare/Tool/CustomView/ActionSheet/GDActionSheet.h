//
//  GDActionSheet.h
//  AutoNavi
//
//  Created by huang longfeng on 13-8-21.
//
//

#import <UIKit/UIKit.h>
@class GDActionSheet;

@protocol GDActionSheetDelegate <NSObject>

- (void)GDActionSheet:(GDActionSheet *)actionSheet clickedButtonAtIndex:(int)index;

@end

@interface GDActionSheet : UIView<UITableViewDataSource,UITableViewDelegate>
{
    id<GDActionSheetDelegate> delegate;
}

@property (nonatomic,assign) id<GDActionSheetDelegate> delegate;
@property (nonatomic,assign) int tag;
@property (nonatomic) BOOL isSupportAutorotate;

- (id)initWithTitle:titleT delegate:(id)delegate1 cancelButtonTitle:(NSString *)cancelString destructiveButtonTitle:(NSString *)destrucString otherButtonTitles:(NSString*)other,...;
- (void)ShowOrHiddenActionSheet:(BOOL)show Animation:(BOOL)animation;
- (void)addOtherButton:(NSString *)otherString;

@end

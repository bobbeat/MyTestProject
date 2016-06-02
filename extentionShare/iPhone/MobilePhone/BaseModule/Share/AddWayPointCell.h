//
//  AddWayPointCell.h
//  AutoNavi
//
//  Created by jiangshu.fu on 13-9-3.
//
//

#import <UIKit/UIKit.h>

#define POINT_CELL_ADD      10
#define POINT_CELL_REDUCE   11
#define POINT_CELL_NONE     12

#define ADDRESSINFO_WIDTH  212.0f
#define ADDRESSINFO_HEIGHT  36.0f
#define ADDRESSINFO_RIGHT  45.0f

@class AddWayPointCell;

@protocol AddWayPointCellDelegate <NSObject>

@required
//- (void) clickFrontButton:(AddWayPointCell *) cell;
- (void) infoAdd:(AddWayPointCell *) cell;
- (void) buttonDelete:(AddWayPointCell *) cell;

@end

@interface AddWayPointCell : GDTableViewCell

@property (nonatomic, assign) id<AddWayPointCellDelegate> delegate;
@property (nonatomic, retain) UIButton *buttonDelete;
@property (nonatomic, retain) UIButton *buttonAddressInfo;
@property (nonatomic, assign) float cellHeight;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withCellHeight:(float)height;

@end

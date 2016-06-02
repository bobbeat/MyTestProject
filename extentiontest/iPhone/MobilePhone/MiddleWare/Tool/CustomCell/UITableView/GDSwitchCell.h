//
//  GDSwitchCell.h
//  AutoNavi
//
//  Created by huang on 13-9-9.
//
//

#import "GDTableViewCell.h"
#import "KLSwitch.h"

@class GDSwitchCell;

@protocol GDSwitchCellDelegate <NSObject>

-(void)switchAction:(id)object cell:(GDSwitchCell *)cell;

@end

@interface GDSwitchCell : GDTableViewCell
{
   
}
@property(nonatomic,retain)KLSwitch *onswitch;
@property(nonatomic,assign)id<GDSwitchCellDelegate> delegate;

@end

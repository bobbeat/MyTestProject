//
//  SettingTableCellData.h
//  AutoNavi
//
//  Created by huang on 13-9-8.
//
//

#import <Foundation/Foundation.h>
#import "POIDefine.h"
//#define CCELL_TITLE @"title"
//#define CCELL_DETAIL_TITLE_TYPE @"detailTitleType"               //用于可变性中的type
//#define CCELL_DETAIL_TITLE_BLOCK @"detailTitleBlock"
//#define CCELL_IS_SWITCH  @"isSwitch"
//#define CCELL_TOUCH_EVENT_BLOCK @"touchEventBlock"
@interface SettingTableCellData : NSObject
@property(nonatomic,copy) NSString *title;
@property(nonatomic,copy) NSString *imageString;
@property(nonatomic) int detailTitleType;
@property(nonatomic) BOOL *isSwitch;
@property(nonatomic,copy) TableCellTouchBlock touchEventBlock;
@property(nonatomic,copy) GetTableDetailTilteBlock getDetailBlock;

+(SettingTableCellData*)allocCellData:(NSString*)title withImageString:(NSString *)imageString withType:(int)type  withIsSwitch:(BOOL)isSwitch withArray:(NSMutableArray*)arr withTouchBlock:(TableCellTouchBlock)_block withDetailTitleBlock:(GetTableDetailTilteBlock) detailBlock;
@end

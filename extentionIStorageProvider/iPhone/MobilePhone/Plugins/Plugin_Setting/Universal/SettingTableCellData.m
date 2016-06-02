//
//  SettingTableCellData.m
//  AutoNavi
//
//  Created by huang on 13-9-8.
//
//

#import "SettingTableCellData.h"

@implementation SettingTableCellData

-(void)dealloc
{
    CRELEASE(_title);
    CRELEASE(_getDetailBlock);
    CRELEASE(_touchEventBlock);
    CLOG_DEALLOC(self);
    [super dealloc];
}
+(SettingTableCellData*)allocCellData:(NSString*)title withImageString:(NSString *)imageString withType:(int)type  withIsSwitch:(BOOL)isSwitch withArray:(NSMutableArray*)arr withTouchBlock:(TableCellTouchBlock)_block withDetailTitleBlock:(GetTableDetailTilteBlock) detailBlock
{
    SettingTableCellData *tableData=[[SettingTableCellData alloc] init];
    tableData.title=title;
    tableData.detailTitleType=type;
     tableData.isSwitch=isSwitch;
     tableData.touchEventBlock=_block;
     tableData.getDetailBlock=detailBlock;
    tableData.imageString = imageString;
    if (arr) {
        [arr addObject:tableData];
    }
    else
    {
        NSLog(@"array is nil");
    }
    [tableData release];
    return tableData;
}
@end

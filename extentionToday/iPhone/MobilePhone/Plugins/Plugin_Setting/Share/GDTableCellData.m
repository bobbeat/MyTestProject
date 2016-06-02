//
//  GDTableCellData.m
//  AutoNavi
//
//  Created by jiangshu-fu on 14-5-21.
//
//

#import "GDTableCellData.h"

@implementation GDTableCellData


-(void)dealloc
{
    CRELEASE(_stringIcon);
    CRELEASE(_stringTitle);
    CRELEASE(_viewAccessory);
    CRELEASE(_blockDetail);
    CRELEASE(_blockTouchEvent);
    CRELEASE(_blockShowNewIcon);
    CLOG_DEALLOC(self);
    [super dealloc];
}


+ (GDTableCellData *) getTableCellDataByIconString:(NSString *)icon
                                         withTitle:(NSString *)title
                                 withAccessoryView:(GetAccessoryView)accessory
                                    withHeightCell:(float)height
                                    withTouchEvent:(CellTouchEventBlock)touchEvent
                                   withDetailTitle:(GetDetailTilteBlock)detailTitle
{
    GDTableCellData *tempData = [[[GDTableCellData alloc]init] autorelease];
    tempData.stringIcon = icon;
    tempData.stringTitle = title;
    tempData.viewAccessory = accessory;
    tempData.heightCell = height;
    tempData.blockDetail = detailTitle;
    tempData.blockTouchEvent = touchEvent;
    tempData.isCanSelect = YES;
    tempData.blockShowNewIcon = nil;
    return  tempData;
}

+ (GDTableCellData *) getTableCellDataByIconString:(NSString *)icon
                                         withTitle:(NSString *)title
                                 withAccessoryView:(GetAccessoryView)accessory
                                    withHeightCell:(float)height
                                    withTouchEvent:(CellTouchEventBlock)touchEvent
                                   withDetailTitle:(GetDetailTilteBlock)detailTitle
                                       withNewIcon:(GetShowNewIcon) newIcon
{
    GDTableCellData *tempData = [self getTableCellDataByIconString:icon
                                                         withTitle:title
                                                 withAccessoryView:accessory
                                                    withHeightCell:height
                                                    withTouchEvent:touchEvent
                                                   withDetailTitle:detailTitle];
    tempData.blockShowNewIcon = newIcon;
    return  tempData;
}




+ (GDTableCellData *) getTableCellDataByIconString:(NSString *)icon
                                         withTitle:(NSString *)title
                                 withAccessoryView:(GetAccessoryView)accessory
                                    withHeightCell:(float)height
                                    withTouchEvent:(CellTouchEventBlock)touchEvent
                                   withDetailTitle:(GetDetailTilteBlock)detailTitle
                                        withSelect:(BOOL) isCanSelect
{
    GDTableCellData *tempData = [self getTableCellDataByIconString:icon
                                                         withTitle:title
                                                 withAccessoryView:accessory
                                                    withHeightCell:height
                                                    withTouchEvent:touchEvent
                                                   withDetailTitle:detailTitle];
    tempData.isCanSelect = isCanSelect;
    return tempData;
}

@end

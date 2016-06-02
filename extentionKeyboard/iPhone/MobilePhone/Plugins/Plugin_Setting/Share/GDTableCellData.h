//
//  GDTableCellData.h
//  AutoNavi
//
//  用来保存 cell 的数据，界面更改，只需要修改数据源即可
//
//  Created by jiangshu-fu on 14-5-21.
//
//

#import <Foundation/Foundation.h>

@interface GDTableCellData : NSObject

typedef NSString *(^ GetDetailTilteBlock)(void);
typedef void (^ CellTouchEventBlock)(id object);
typedef UIView *(^ GetAccessoryView)(void);
typedef BOOL (^ GetShowNewIcon)(void);

@property (nonatomic, copy) NSString *stringIcon;   //图标文件名称
@property (nonatomic, copy) NSString *stringTitle;  //cell 的标题
@property (nonatomic, copy) GetAccessoryView viewAccessory;//右侧视图
@property (nonatomic, assign) float heightCell;     //cell 的高度

@property (nonatomic, copy) GetDetailTilteBlock blockDetail;    //获取详细信息的文字
@property (nonatomic, copy) CellTouchEventBlock blockTouchEvent;    //cell 点击事件
@property (nonatomic, copy) GetShowNewIcon blockShowNewIcon;    //是否显示 new icon

@property (nonatomic, assign) BOOL isCanSelect;



+ (GDTableCellData *) getTableCellDataByIconString:(NSString *)icon
                                         withTitle:(NSString *)title
                                 withAccessoryView:(GetAccessoryView)accessory
                                    withHeightCell:(float)height
                                    withTouchEvent:(CellTouchEventBlock)touchEvent
                                   withDetailTitle:(GetDetailTilteBlock)detailTitle;

+ (GDTableCellData *) getTableCellDataByIconString:(NSString *)icon
                                         withTitle:(NSString *)title
                                 withAccessoryView:(GetAccessoryView)accessory
                                    withHeightCell:(float)height
                                    withTouchEvent:(CellTouchEventBlock)touchEvent
                                   withDetailTitle:(GetDetailTilteBlock)detailTitle
                                       withNewIcon:(GetShowNewIcon) newIcon;

+ (GDTableCellData *) getTableCellDataByIconString:(NSString *)icon
                                         withTitle:(NSString *)title
                                 withAccessoryView:(GetAccessoryView)accessory
                                    withHeightCell:(float)height
                                    withTouchEvent:(CellTouchEventBlock)touchEvent
                                   withDetailTitle:(GetDetailTilteBlock)detailTitle
                                        withSelect:(BOOL) isCanSelect;

@end

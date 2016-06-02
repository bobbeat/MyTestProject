//
//  GDTableViewCell.h
//  AutoNavi
//
//  Created by huang on 13-9-8.
//
//

#import <UIKit/UIKit.h>

typedef enum
{
    BACKGROUND_GROUP=0,
    BACKGROUND_HEAD,
    BACKGROUND_MIDDLE,
    BACKGROUND_FOOTER,
    BACKGROUND_TRACK,
    BACKGROUND_TRACKTOP,
    BACKGROUND_SECONDMIDDLE,
    BACKGROUND_TWO_MIDDLE,
    BACKGROUND_TWO_FOOTER,
}GDTABLE_CELL_BACKGROUND_TYPE;


@interface GDTableViewCell : UITableViewCell
{
    UITableViewCellStyle _gdStyle;
}

@property (nonatomic) float emptyLineLength;     //cell底部横线空白的长度 注：是空白长度，例如cell底部有一整条横线，则该值应设为0，若cell底部无横线，则该值应设为-1。
@property (nonatomic) float  endLineLength;     //cell底部的线距离最后的距离，emptyLineLength ： 距离左边的距离，这个是距离右边的距离
@property (nonatomic) GDTABLE_CELL_BACKGROUND_TYPE backgroundType;
@property (nonatomic,assign) float widthAdd;

@end

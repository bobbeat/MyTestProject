//
//  CarServiceMoreCell.h
//  AutoNavi
//
//  Created by jiangshu-fu on 14-3-8.
//
//

#import "GDTableViewCell.h"

typedef enum CARSERVICE_CELL_TYPE
{
    CARSERVICE_CELL_MORE = 0,
    CARSERVICE_CELL_DETAIL_IMAGE = 1,
    CARSERVICE_CELL_DETAIL = 2,
}CARSERVICE_CELL_TYPE;

@class MWSkinAndCarListRequest;

typedef void (^CellImageLoad)();

@interface CarServiceMoreCell : GDTableViewCell <NetReqToViewCtrDelegate>
{
    //请求图片
    MWSkinAndCarListRequest *_imageLoadRequest;
    //红点显示提醒
    UIImageView *_imageViewNew;
}
//cell的类型，默认是 CARSERVICE_CELL_MORE
@property (nonatomic, assign) CARSERVICE_CELL_TYPE carServiceCellType;
@property (nonatomic, copy) NSString *imageString;
@property (nonatomic, copy) CellImageLoad cellIamgeLoad;
@property (nonatomic, assign) BOOL showNewPoint;


@end

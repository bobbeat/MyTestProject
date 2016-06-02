//
//  CarServicItemView.h
//  AutoNavi
//
//  Created by jiangshu-fu on 14-3-6.
//
//

#import <UIKit/UIKit.h>
#import "CarServiceVarDefine.h"


@class CarServiceItemData;
@class MWCarOwnerServiceTask;
@class MWSkinAndCarListRequest;
// item项目点击的属性
typedef void (^CarServiceItemClick)(id);
// item项目长按的属性
typedef void (^CarServiceItemLongPress)(id);

@interface CarServiceItemView : UIView<UIGestureRecognizerDelegate,NetReqToViewCtrDelegate>
{
    //可点击的按钮
    UIButton *_buttonItem;
    //item等级的右上角图片
    UIImageView *_imageViewLevel;
    //item的名称
    UILabel *_labelItem;
//    //item的等级，优先状态
//    CARSERVICE_LEVEL carserviceLevel;
    //是否在长按的状态
    BOOL _isLongPress;
    //请求图片
    MWSkinAndCarListRequest *_imageLoadRequest;
    int _carLevel;
}

// item项目点击的属性
@property (nonatomic, copy) CarServiceItemClick itemClick;
// item项目长按的属性
@property (nonatomic, copy) CarServiceItemLongPress itemLongPress;
//item的数据
@property (nonatomic, retain) MWCarOwnerServiceTask *itemData;

/***
 * @name    初始化对象
 * @param   itemImage —— 按钮的图片
            carLevel  —— 服务的级别（默认,推荐,更新,禁用）
            itemText  —— 服务的名称
 * @author  by bazinga
 ***/
- (id) initWithItemImage:(UIImage *)itemImage
               withLevel:(int) carLevel
            withItemText:(NSString *)itemText;

/* ↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑ */
/* ---             上面的三个参数的细化               ---  */
/* ↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑ */
- (void) setItemImage:(UIImage *)itemImage;
- (void) setItemLevel:(int) carLevel  withIsVip:(int)vip;
- (void) setItemText:(NSString *)itemText;


@end

//
//  RouteDetailListCell.h
//  AutoNavi
//
//  Created by jiangshu-fu on 14-7-21.
//
//

#import <UIKit/UIKit.h>


@class ManeuverInfo;
@class GDTableViewCell;
//避让按钮事件
typedef void(^AvoidInfo)(ManeuverInfo *);
//选择选中事件
typedef void(^SelectInfo)(ManeuverInfo *);

@interface RouteDetailListCell : GDTableViewCell

@property (nonatomic, retain) ManeuverInfo *cellData;   //cell 的数据
@property (nonatomic, copy) AvoidInfo avoidPress;       //避让按钮点击事件
@property (nonatomic, copy) SelectInfo selectPress;     //选择按钮事件 -- 有扩展就扩展，没有扩展就进入节点查看

@end

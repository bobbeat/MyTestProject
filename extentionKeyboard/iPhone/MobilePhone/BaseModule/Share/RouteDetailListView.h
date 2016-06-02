//
//  RouteDetailListView.h
//  AutoNavi
//
//  Created by jiangshu-fu on 14-7-16.
//
//

#import <Foundation/Foundation.h>

typedef void(^ClosePress) (void);           //关闭
typedef void(^SelectCell) (NSArray *,NSIndexPath *); //选择
typedef void(^AvoidCell) (ManeuverInfo *);  //避让

@interface RouteDetailViewController : UIView<UITableViewDataSource,UITableViewDelegate>
{
    NSMutableDictionary *_dictionaryOpen;    //获取打开的数组的顺序 key 为数组中的顺序，value
    UIImageView *_imageHeaderView;
    UILabel *_labelTitle;
    UIButton *_buttonClose;
    UIView *_shadeView;
    UITableView *_tableView;
}

@property (nonatomic, retain) NSArray *arrayListData;

@property (nonatomic, copy) ClosePress closePress;
@property (nonatomic, copy) SelectCell selectCell;
@property (nonatomic, copy) AvoidCell  avoidCell;

-(void) reloadData;
-(void) changePortraitControlFrameWithImage;
-(void) changeLandscapeControlFrameWithImage;

@end

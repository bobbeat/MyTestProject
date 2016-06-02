//
//  POISearchDesViewController.m
//  AutoNavi
//
//  Created by weisheng on 14-7-11.
//
//

#import <UIKit/UIKit.h>
#import "POIToolBar.h"
#import "MWPoiOperator.h"
#import "AddWayPointCell.h"
#define ButtonBackground   @""
#define ButtonBackground1  @"POISelectImage.png"
typedef enum HistoryType
{
    History_Destination = 200,//历史目的地
    History_Line,             //历史路线

}HistoryType;
@class POISearchHistory;
@class POITextField;
@interface POIWhereToGoViewController : ANViewController<MWPoiOperatorDelegate,UITableViewDataSource,UITableViewDelegate>
{
 
    UITableView    *_tableView2;
    UITableView    *_tableView1;
    NSMutableArray *_arrayHistoryLineData;//存放历史路线的数组
    NSMutableArray *_arrayAddRoutePoint;   //存放poi点
    UIImageView    *_imageView;
    BOOL            _isNull;//YES->表示数据为空 NO->表示有数据
    UIButton       *_buttonNaviGation;//出发的按钮
}
@property(assign,nonatomic)HistoryType  PgType;//0->历史目的地 1->历史路线
@property(nonatomic,assign)int          whereFromGo;//判断是否从主界面进来 YES表示从主界面进入
-(id)initWithArray:(NSArray *)array;
@end

//
//  POISearchListViewController.h
//  AutoNavi
//
//  Created by huang on 13-8-19.
//
//

#import "ANViewController.h"
#import "MWPoiOperator.h"
#import "POITableHeadView.h"

//搜索
@class POISearchHistory;
@interface POISearchListViewController : ANTableViewController<MWPoiOperatorDelegate>
{
    int sortType;                             //排序类型 0表示默认，1表示距离
    int searchType;                           //0:普通关键字搜索 2:路口搜索 可空,默认值=0
    BOOL    netSearchBeforeFlag;              // YES->网络 NO－>本地
    BOOL    bNetSearch;                       //是否为网络搜索
}
@property(nonatomic,copy)NSString* keyWord; //搜索关键字
@property(nonatomic)int backType;           //0表示返回上一层，1表示返回上两层，
@property(nonatomic,retain)NSMutableArray * arraySearchData;
@property(nonatomic,copy)NSString * adcode;//搜索区域编码
@property(copy,nonatomic)NSString * recoveryKeyWorld;//后台返回的纠错文字提示

-(void)keyWordsearch;
@end

//
//  POIOtherCityDetailViewController.h
//  AutoNavi
//
//  Created by huang on 13-8-19.
//
//

#import "ANViewController.h"
#import "MWPoiOperator.h"
@interface POIOtherCityDetailViewController : ANTableViewController<MWPoiOperatorDelegate,NetReqToViewCtrDelegate>
{
}
@property(nonatomic)int searchType;
@property(nonatomic,copy)NSString * keyWord;
@property(nonatomic)int nAdminCode;
@property(assign,nonatomic)int sizePageCount;
@end

//
//  POIOtherCityViewController.h
//  AutoNavi
//
//  Created by huang on 13-8-19.
//
//

#import "ANViewController.h"

@interface POIOtherCityViewController : ANTableViewController
{
    
}
@property(nonatomic,retain)NSArray *arrayOtherCityData;
@property(nonatomic,copy)NSString  *keyWord;
@property(nonatomic)GSEARCHTYPE     searchType;
@property(copy,nonatomic)NSString  *recoveryKeyWorld;//后台返回的纠错文字提示
@end

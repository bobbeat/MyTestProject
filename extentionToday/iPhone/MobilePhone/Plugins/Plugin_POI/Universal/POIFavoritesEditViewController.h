//
//  POIFavoritesEditViewController.h
//  AutoNavi
//
//  Created by huang on 13-8-20.
//
//

#import "ANViewController.h"
#import "MWSearchResult.h"
@interface POIFavoritesEditViewController : ANTableViewController
{
    UITextField *_textFieldName;
    UITextField *_textFieldLocal;
    UITextField *_textFieldTel;
}
@property(nonatomic,retain)MWPoi *poi;
@end

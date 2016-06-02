//
//  POIInputCell.h
//  AutoNavi
//
//  Created by huang on 13-8-23.
//
//

#import <UIKit/UIKit.h>
#import "GDTableViewCell.h"
@interface POIInputCell : GDTableViewCell<UITextFieldDelegate>
@property(nonatomic,retain)UITextField *textField;


@end

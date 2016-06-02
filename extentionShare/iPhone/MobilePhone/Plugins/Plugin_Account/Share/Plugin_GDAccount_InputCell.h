//
//  Plugin_GDAccount_InputCell.h
//  AutoNavi
//
//  Created by gaozhimin on 12-12-18.
//
//

#import <UIKit/UIKit.h>
#import "GDTableViewCell.h"
#import "POITextField.h"
@interface Plugin_GDAccount_InputCell : GDTableViewCell
{
    POITextField *m_input;
}

@property (readonly,nonatomic) UITextField *m_input;

- (void)SetTitle:(NSString *)title;

@end

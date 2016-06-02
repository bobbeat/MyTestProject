//
//  Plugin_GDAccount_InputView.h
//  AutoNavi
//
//  Created by gaozhimin on 12-12-19.
//
//

#import <UIKit/UIKit.h>
#import "POITextField.h"
#import "GDTableViewCell.h"
@interface Plugin_GDAccount_InputView : UIImageView
{
    POITextField *m_input;
}

- (void)setBackgroundType:(GDTABLE_CELL_BACKGROUND_TYPE)type;

@property (readonly,nonatomic) UITextField *m_input;
@end

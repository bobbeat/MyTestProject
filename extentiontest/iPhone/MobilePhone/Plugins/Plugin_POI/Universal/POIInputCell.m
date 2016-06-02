//
//  POIInputCell.m
//  AutoNavi
//
//  Created by huang on 13-8-23.
//
//

#import "POIInputCell.h"

@implementation POIInputCell
@synthesize textField;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CGSize size = self.contentView.bounds.size;
        
        self.textLabel.backgroundColor=[UIColor clearColor];
        
        textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 10, size.width - 30, size.height-20)];
        textField.backgroundColor = [UIColor clearColor];
        textField.delegate = self;
        textField.textColor = TEXTCOLOR;
        textField.borderStyle = UITextBorderStyleNone;
        textField.autocorrectionType = UITextAutocorrectionTypeNo;
        textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        textField.keyboardType = UIKeyboardTypeDefault;
        textField.returnKeyType = UIReturnKeyDone;
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.font = [UIFont systemFontOfSize:kSize2];
        self.textLabel.font = [UIFont systemFontOfSize:kSize2];
        [self.contentView addSubview:textField];
        [textField release];
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    CGSize size = self.contentView.bounds.size;
    CGSize title_size = [self.textLabel.text sizeWithFont:self.textLabel.font];
    textField.frame = CGRectMake(18+title_size.width+IOS_7*6, 6, size.width - 20 - title_size.width, size.height-10);
 
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

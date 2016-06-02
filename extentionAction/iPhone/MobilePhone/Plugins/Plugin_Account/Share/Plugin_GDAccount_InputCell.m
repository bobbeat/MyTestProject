//
//  Plugin_GDAccount_InputCell.m
//  AutoNavi
//
//  Created by gaozhimin on 12-12-18.
//
//

#import "Plugin_GDAccount_InputCell.h"

@implementation Plugin_GDAccount_InputCell

@synthesize m_input;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        self.backgroundColor = GETSKINCOLOR(HUD_CLEAR_BACKGROUND_COLOR);
        
                
        CGSize size = self.contentView.bounds.size;
        
        
        m_input = [[POITextField alloc] initWithFrame:CGRectMake(0, 10, size.width - 30, size.height-20)];
        m_input.backgroundColor = GETSKINCOLOR(HUD_CLEAR_BACKGROUND_COLOR);
        m_input.textColor = TEXTCOLOR;
        m_input.borderStyle = UITextBorderStyleNone;
        m_input.autocorrectionType = UITextAutocorrectionTypeNo;
        m_input.autocapitalizationType = UITextAutocapitalizationTypeNone;
        m_input.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        m_input.keyboardType = UIKeyboardTypeDefault;
        m_input.returnKeyType = UIReturnKeyDone;
        m_input.clearButtonMode = UITextFieldViewModeWhileEditing;
        m_input.leftView=nil;
        m_input.background=nil;
        m_input.placeholderFontSize=kSize2;
        m_input.offsetY=0;
        m_input.placeholder=@"";
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
            m_input.font = [UIFont systemFontOfSize:kSize2];
            self.textLabel.font = [UIFont systemFontOfSize:kSize2];
        }
        else
        {
            m_input.font = [UIFont systemFontOfSize:kSize2];
            self.textLabel.font = [UIFont systemFontOfSize:kSize2];
        }
        [self.contentView addSubview:m_input];
        [m_input release];
    }
    return self;
}

- (void)SetTitle:(NSString *)title
{
    self.textLabel.backgroundColor = GETSKINCOLOR(HUD_CLEAR_BACKGROUND_COLOR);
    self.textLabel.textColor = TEXTCOLOR;
    self.textLabel.text = title;
    [self layoutSubviews];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGSize size = self.contentView.bounds.size;
    
    CGSize title_size = [self.textLabel.text sizeWithFont:self.textLabel.font];
    
    if (self.imageView.image)
    {
         m_input.frame = CGRectMake(40+12+title_size.width+IOS_7*6, 6, size.width - 20 - title_size.width-40, size.height-10);
    }
    else
    {
         m_input.frame = CGRectMake(12+title_size.width+IOS_7*6, 6, size.width - 20 - title_size.width, size.height-10);
    }
   
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

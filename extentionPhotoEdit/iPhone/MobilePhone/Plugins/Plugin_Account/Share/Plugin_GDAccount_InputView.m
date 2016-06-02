//
//  Plugin_GDAccount_InputButton.m
//  AutoNavi
//
//  Created by gaozhimin on 12-12-19.
//
//

#import "Plugin_GDAccount_InputView.h"

@implementation Plugin_GDAccount_InputView

@synthesize m_input;

- (id)init
{
    return [self initWithFrame:CGRectZero];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = GETSKINCOLOR(HUD_CLEAR_BACKGROUND_COLOR);
        
        
        CGSize size = frame.size;
        m_input = [[POITextField alloc] initWithFrame:CGRectMake(0, 10, size.width  - 10, size.height-20)];
        m_input.backgroundColor = GETSKINCOLOR(HUD_CLEAR_BACKGROUND_COLOR);
        m_input.textColor = TEXTCOLOR;
        m_input.borderStyle = UITextBorderStyleNone;
        m_input.autocorrectionType = UITextAutocorrectionTypeNo;
        m_input.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        m_input.keyboardType = UIKeyboardTypeDefault;
        m_input.returnKeyType = UIReturnKeyDone;
        m_input.clearButtonMode = UITextFieldViewModeWhileEditing;
        m_input.leftView=nil;
        m_input.placeholderFontSize=kSize2;
        m_input.background=nil;
        m_input.placeholder=@"";
        
        UIImage *buttonImageNormal1 =IMAGE(@"icallinput.png", IMAGEPATH_TYPE_1)  ;
        UIImage *stretchableButtonImageNormal = [buttonImageNormal1 stretchableImageWithLeftCapWidth:buttonImageNormal1.size.width/2 topCapHeight:buttonImageNormal1.size.height/2];
        self.image = stretchableButtonImageNormal;
        m_input.font = [UIFont systemFontOfSize:kSize2];
      
        
        [self addSubview:m_input];
        [m_input release];


    }
    return self;
}
- (void)setBackgroundType:(GDTABLE_CELL_BACKGROUND_TYPE)_type
{
    
    NSString *name = @"";
    NSString *selectName = @"";
    switch (_type) {
        case BACKGROUND_GROUP:
        {
            name=@"icallinput.png";
            selectName = @"TableCellBgGroup2.png";
        }
            break;
        default:
        {
            name=@"icallinput.png";
            return;
        }
            break;
    }
    
    UIImage *buttonImageNormal1 =IMAGE(name, IMAGEPATH_TYPE_1)  ;
    UIImage *image=[IMAGE(name, IMAGEPATH_TYPE_1) stretchableImageWithLeftCapWidth:buttonImageNormal1.size.width/2 topCapHeight:buttonImageNormal1.size.height/2];
    self.image=image;
    
    
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    CGSize size = frame.size;
    m_input.frame = CGRectMake(10, 5, size.width - 20, size.height-10);
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end

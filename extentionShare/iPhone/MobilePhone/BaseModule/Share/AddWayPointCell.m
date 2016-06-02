//
//  AddWayPointCell.m
//  AutoNavi
//
//  Created by jiangshu.fu on 13-9-3.
//
//

#import "AddWayPointCell.h"

@implementation AddWayPointCell


@synthesize cellHeight = _cellHeight;
@synthesize buttonAddressInfo = _buttonAddressInfo;
@synthesize buttonDelete = _buttonDelete;
@synthesize delegate = _delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withCellHeight:(float)height
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        _cellHeight = height;
        [self initControl];
    }
    return self;
}


- (void)initControl
{
    
    
    _buttonAddressInfo = [UIButton buttonWithType:UIButtonTypeCustom];
    _buttonAddressInfo.autoresizesSubviews =  YES;
    _buttonAddressInfo.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [_buttonAddressInfo addTarget:self action:@selector(addInfo:) forControlEvents:UIControlEventTouchUpInside];
    [_buttonAddressInfo setTitleColor:GETSKINCOLOR(ROUTE_ADDRESS_COLOR) forState:UIControlStateNormal];
    _buttonAddressInfo.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [_buttonAddressInfo setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    _buttonAddressInfo.titleEdgeInsets = UIEdgeInsetsMake(0, 4, 0, 15);
    
    [self addSubview:_buttonAddressInfo];
    
    [_buttonAddressInfo setFrame:CGRectMake(0, 0, ADDRESSINFO_WIDTH, ADDRESSINFO_HEIGHT)];
    
    [_buttonAddressInfo setCenter:CGPointMake(ADDRESSINFO_RIGHT + ADDRESSINFO_WIDTH / 2,_cellHeight / 2)];
    
    _buttonDelete = [UIButton buttonWithType:UIButtonTypeCustom];
    _buttonDelete.autoresizesSubviews =  YES;
    _buttonDelete.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [_buttonDelete addTarget:self action:@selector(buttonDelete:) forControlEvents:UIControlEventTouchUpInside];
    [_buttonDelete setImage:IMAGE(@"Route_PointDelete.png", IMAGEPATH_TYPE_1) forState:UIControlStateNormal];
    [_buttonDelete setImage:IMAGE(@"Route_PointDeletePress.png", IMAGEPATH_TYPE_1) forState:UIControlStateHighlighted];
    [_buttonDelete setFrame:CGRectMake(0, 0, _cellHeight, _cellHeight)];
    float edge = ( _cellHeight - 24 ) / 2;
    _buttonDelete.imageEdgeInsets = UIEdgeInsetsMake(edge, edge, edge, edge);
    [_buttonDelete setCenter:CGPointMake(ADDRESSINFO_RIGHT + ADDRESSINFO_WIDTH, _cellHeight / 2)];
    self.backgroundColor =  GETSKINCOLOR(ROUTE_DETAIL_BACKCOLOR);
    [self addSubview:_buttonDelete];
    
    
 
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) buttonDelete:(id)sender
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(buttonDelete:)])
    {
        [self.delegate buttonDelete:self];
    }
}

- (void) addInfo:(id)sender
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(infoAdd:)])
    {
        [self.delegate infoAdd:self];
    }
}

- (void) dealloc
{
    _delegate = nil;
    [super dealloc];
}

@end

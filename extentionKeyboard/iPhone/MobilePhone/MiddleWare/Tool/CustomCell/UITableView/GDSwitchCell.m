//
//  GDSwitchCell.m
//  AutoNavi
//
//  Created by huang on 13-9-9.
//
//

#import "GDSwitchCell.h"
#import "POIDefine.h"
#import "ControlCreat.h"
@implementation GDSwitchCell
//@synthesize onSwitch;

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        
        _onswitch= [ControlCreat createKLSwitchWithTag:0 target:self selector:@selector(switchAction:)];
//        _onswitch = [[KLSwitch alloc] initWithFrame:CGRectMake(0, 0, 55, 33) ];
        [_onswitch setOnTintColor:SWITCHCOLOR];
        self.accessoryView = _onswitch;
//        [_onswitch release];
       
    }
    return self;
}

-(void)switchAction:(id)object
{
    if(self.delegate &&[self.delegate respondsToSelector:@selector(switchAction: cell:)])
    {
        [self.delegate switchAction:object cell:self];
    }
}

-(void)dealloc
{
    CLOG_DEALLOC(self);
//    [_onswitch release];
    [super dealloc];
}
-(void)layoutSubviews
{
    [super layoutSubviews];
    [_onswitch setOnTintColor:SWITCHCOLOR];
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

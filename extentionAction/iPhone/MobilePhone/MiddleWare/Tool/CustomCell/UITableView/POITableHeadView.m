//
//  POITableHeadView.m
//  AutoNavi
//
//  Created by huang on 13-9-10.
//
//

#import "POITableHeadView.h"
#import "POIDefine.h"

@interface POITableHeadView ()
{
    UILabel *_label;
    UIButton *_button;
    UIImageView *imageView;
}

@end

@implementation POITableHeadView

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    UIImage *image = IMAGE(@"viewBackground.png", IMAGEPATH_TYPE_1);
    [image drawAsPatternInRect:rect];
}


-(id)init
{
    self=[super initWithFrame:CGRectMake(0, 0, CCOMMON_APP_WIDTH, 40)];
    if (self) {
        imageView=[[[UIImageView alloc] initWithFrame:CGRectMake(0, 0,self.frame.size.width, 40)] autorelease];
        imageView.center=CGPointMake(imageView.center.x, imageView.center.y);
        imageView.autoresizingMask=UIViewAutoresizingFlexibleWidth;
        imageView.image=[IMAGE(@"TableCellBgFooter.png", IMAGEPATH_TYPE_1) stretchableImageWithLeftCapWidth:10 topCapHeight:10];
        [self addSubview:imageView];
        imageView.userInteractionEnabled=YES;
        _label=[[UILabel alloc] initWithFrame:CGRectMake(20, 0,imageView.frame.size.width-40 , 40)];
        _label.backgroundColor=[UIColor clearColor];
        _label.font=[UIFont systemFontOfSize:kSize3];
        _label.textColor=TITLECOLOR;
        [imageView addSubview:_label];
        [_label release];
        
        UIImageView *lineImage = [[UIImageView alloc] initWithImage:IMAGE(@"TableCellLine.png",IMAGEPATH_TYPE_1)];
        lineImage.frame = CGRectMake(0, 40, CCOMMON_APP_WIDTH, 1);
        [imageView addSubview:lineImage];
        [lineImage release];
        lineImage.alpha = 0.8;
        
        _deletaBtn=NO;
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        _button.frame=CGRectMake(imageView.frame.size.width-47-2*CCOMMON_TABLE_X, 0, 47, 40);
        [_button setImage:IMAGE(@"POIDeleteAllBtn1.png",IMAGEPATH_TYPE_1) forState:UIControlStateNormal];
        [_button setImage:IMAGE(@"POIDeleteAllBtn2.png",IMAGEPATH_TYPE_1) forState:UIControlStateHighlighted];
        [imageView addSubview:_button];
        _button.tag=100;
        _button.hidden=!_deletaBtn;
        
    }
    return self;
}
-(id)initWithTitle:(NSString*)title
{
    self=[self init];
    _label.text=title;
    return self;
}
-(id)initWithTitle:(NSString *)title WithTarget:(id)target WithSelector:(SEL)sel
{
    self=[self initWithTitle:title];
    self.deletaBtn=YES;
    [_button addTarget:target action:sel forControlEvents:UIControlEventTouchUpInside];
    return self;
}
-(void)setGroup:(BOOL)group
{
//    _group=group;
//    if (_group) {
//      imageView.frame =  CGRectMake(CCOMMON_TABLE_X, 0,self.frame.size.width-2*CCOMMON_TABLE_X, 40);
//    }
//    else
//    {
//        imageView.frame =  CGRectMake(0, 0,self.frame.size.width, 40);
//    }
}
-(void)downMove
{
    [self downMove:CCTABLE_VIEW_SPACE_HEIGHT];
}
-(void)downMove:(float)move
{
    CGRect rect=imageView.frame;
    rect.origin.y+=move;
    imageView.frame=rect;
}
-(void)setImageViewWidth:(float)width
{
    CGRect rect=imageView.frame;
    rect.size.width=width;
    imageView.frame=rect;
}

-(void)setTitle:(NSString *)title
{
    _label.text=title;
}
-(void)setDeletaBtn:(BOOL)deletaBtn
{
    _button.hidden=!deletaBtn;
}
-(void)buttonAction:(UIButton*)button
{
    
}

-(void)dealloc
{
    CLOG_DEALLOC(self);
    [super dealloc];
}

@end

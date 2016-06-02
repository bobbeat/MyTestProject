//
//  GDTableViewCell.m
//  AutoNavi
//
//  Created by huang on 13-9-8.
//
//

#import "GDTableViewCell.h"

@interface GDTableViewCell()
{
    UIImageView *_lineImageView;
}

@end

@implementation GDTableViewCell

@synthesize emptyLineLength;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _gdStyle=style;
        self.textLabel.backgroundColor=[UIColor clearColor];
        self.textLabel.textColor=TEXTCOLOR;
        self.textLabel.font=[UIFont systemFontOfSize:kSize2];
        self.detailTextLabel.backgroundColor=[UIColor clearColor];
        self.detailTextLabel.font=[UIFont systemFontOfSize:kSize3];
        _backgroundType=-1;
        self.backgroundType=BACKGROUND_FOOTER;
        self.selectionStyle=UITableViewCellSelectionStyleGray;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshImage:) name:NOTIFY_HandleUIUpdate object:nil];
        _widthAdd = -1.0f;
        
        _lineImageView = [[UIImageView alloc] initWithImage:IMAGE(@"TableCellLine.png",IMAGEPATH_TYPE_1)];
        [self addSubview:_lineImageView];
        [_lineImageView release];
        _lineImageView.alpha = 0.8;
        _endLineLength = 0;
    }
    return self;
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}
-(void)refreshImage:(NSNotification*)notification
{
    if ([notification.object intValue]!=UIUpdate_SkinTypeChange) {
        return;
    }
    _backgroundType=-1;
    _lineImageView.image = IMAGE(@"TableCellLine.png",IMAGEPATH_TYPE_1);

}
-(void)setBackgroundType:(GDTABLE_CELL_BACKGROUND_TYPE)backgroundType
{
    if (self.backgroundType==backgroundType ) {
        return;
    }
    _backgroundType=backgroundType;
    NSString *name = @"";
    NSString *selectName = @"";
    int capWidth = 15;
    int capHeight = 20;
    switch (backgroundType) {
        case BACKGROUND_FOOTER:
        {
            name=@"TableCellBgFooter.png";
            selectName = @"TableCellBgFooter1.png";
            self.emptyLineLength = 0;
        }
            break;
        case BACKGROUND_GROUP:
        {
            name=@"TableCellBgFooter.png";
            selectName = @"TableCellBgFooter1.png";
            self.emptyLineLength = 0;
        }
            break;
        default:
        {
            self.emptyLineLength = 10;
            name=@"TableCellBgFooter.png";
            selectName = @"TableCellBgFooter1.png";
        }
            break;
    }
    
    UIImage *image=[IMAGE(name, IMAGEPATH_TYPE_1) stretchableImageWithLeftCapWidth:capWidth topCapHeight:capHeight];
    UIImageView *imageView;
    if( [self.backgroundView isMemberOfClass:[UIImageView class]])
    {
        imageView=(UIImageView*)self.backgroundView;
        imageView.image=image;
    }
    else
    {
        imageView=[[UIImageView alloc] initWithImage:image];
        self.backgroundView=imageView;
        [imageView release];
    }
    if (selectName.length>0) {
        UIImage *selectImage=[IMAGE(selectName, IMAGEPATH_TYPE_1) stretchableImageWithLeftCapWidth:capWidth topCapHeight:capHeight];
        UIImageView *selectImageView;
        if ([self.selectedBackgroundView isMemberOfClass:[UIImageView class]]) {
            selectImageView=(UIImageView*)self.selectedBackgroundView;
            selectImageView.image=selectImage;
        }
        else
        {
            UIImageView *selectImageView=[[[UIImageView alloc] initWithImage:selectImage] autorelease];
            self.selectedBackgroundView=selectImageView;
        }
    }
    self.backgroundColor=[UIColor clearColor];

}

- (void)setEmptyLineLength:(float)length
{
    emptyLineLength = length;
    [self layoutSubviews];
}

- (void) setEndLineLength:(float)endLineLength
{
    _endLineLength = endLineLength;
    [self layoutSubviews];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    self.textLabel.textColor=TEXTCOLOR;

    CGSize size = self.bounds.size;
    if (emptyLineLength == -1)
    {
        _lineImageView.frame = CGRectMake(0, size.height - 1,0, 1);
    }
    else
    {
        _lineImageView.frame = CGRectMake(self.emptyLineLength, size.height - 1,size.width - self.emptyLineLength - _endLineLength, 1);
    }
    
 
    if (self.imageView.image)
    {
        CGRect rect = self.imageView.frame;
        rect.origin.x+=2;
        if(!isiPhone && !ISRETINA)
        {
            rect.origin.x += 2;
        }
        if( _widthAdd != -1.0f)
        {
            rect.origin.x += _widthAdd;
        }
        
        if (rect.size.height>=self.contentView.bounds.size.height) {
//            rect.origin.x+=8;
            rect.origin.y+=10;
            rect.size.height-=20;
            
             rect.size.width-=20;
        
        }
        self.imageView.frame=rect;
    }
    else
    {
        
        CGRect contentRect = [self.textLabel frame];
        contentRect.origin.x+=self.textLabel.textAlignment==NSTextAlignmentCenter?0:7;
        self.textLabel.frame = contentRect;
        contentRect = [self.detailTextLabel frame];
        contentRect.origin.x+=7;
        if (_gdStyle==UITableViewCellStyleValue1)
        {
            contentRect.origin.y-=2;
        }
        
        self.detailTextLabel.frame = contentRect;
    }
     [self applyEditingModeBackgroundViewPositionCorrections];
    
}
- (void)applyEditingModeBackgroundViewPositionCorrections {
    if (!self.editing) { return; } // BAIL. This fix is not needed.
    
    // Assertion: we are in editing mode.
    
    // Do we have a regular background view?
    if (self.backgroundView) {
        // YES: So adjust the frame for that:
        CGRect backgroundViewFrame = self.backgroundView.frame;
        backgroundViewFrame.origin.x = 0;
        self.backgroundView.frame = backgroundViewFrame;
    }
    
    // Do we have a selected background view?
    if (self.selectedBackgroundView) {
        // YES: So adjust the frame for that:
        CGRect selectedBackgroundViewFrame = self.selectedBackgroundView.frame;
        selectedBackgroundViewFrame.origin.x = 0;
        self.selectedBackgroundView.frame = selectedBackgroundViewFrame;
    }
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
        // Configure the view for the selected state
}

@end

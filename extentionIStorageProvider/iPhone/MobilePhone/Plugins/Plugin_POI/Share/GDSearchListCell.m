//
//  GDSearchListself.m
//  AutoNavi
//
//  Created by huang on 13-9-9.
//
//

#import "GDSearchListCell.h"
#import "KeyWordLable.h"


@implementation GDsearchButton

@synthesize buttonCell;

@end

@interface GDSearchListCell()
{
    UILabel * labelNaviGation;
    UIImageView * _imageViewLine;
}

@end

@implementation GDSearchListCell
@synthesize labelNaviGation,imageViewLine=_imageViewLine;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
	{
        self.textLabel.hidden = YES;
        _labelName = [[KeyWordLable alloc] init];
		_labelName.backgroundColor = [UIColor clearColor];
		_labelName.opaque = NO;
        _labelName.font=[UIFont systemFontOfSize:kSize2];
        _labelName.lineBreakMode = UILineBreakModeCharacterWrap;
        _labelName.numberOfLines = 2;
        _labelName.textColor=TEXTCOLOR;
		[self.contentView addSubview:_labelName];
		[_labelName release];
        
		self.detailTextLabel.textAlignment = UITextAlignmentCenter;
		self.detailTextLabel.font = [UIFont systemFontOfSize:kSize3];
		self.detailTextLabel.backgroundColor = [UIColor clearColor];
        self.detailTextLabel.textColor=TEXTCOLOR;
        
		_labelAddress = [[KeyWordLable alloc] initWithType:Address_Lable];
		_labelAddress.textAlignment = UITextAlignmentLeft;
        _labelAddress.backgroundColor = [UIColor clearColor];
		_labelAddress.opaque = NO;
        _labelAddress.textColor=TEXTDETAILCOLOR;
        _labelAddress.font=[UIFont systemFontOfSize:kSize3];
		[self.contentView addSubview:_labelAddress];
		[_labelAddress release];
        
        
        _imageViewLine  = [[UIImageView alloc]init];
        UIImage * image =[IMAGE(@"POILine.png", IMAGEPATH_TYPE_1) stretchableImageWithLeftCapWidth:0.5 topCapHeight:5];
        [_imageViewLine  setImage:image];
        [self.contentView addSubview:_imageViewLine];
        [_imageViewLine release];
        
        
         _naviButton=[GDsearchButton buttonWithType:UIButtonTypeCustom];
        [_naviButton setImage:IMAGE(@"SearchNaviBtn1.png",IMAGEPATH_TYPE_1) forState:UIControlStateNormal];
        _naviButton.frame=CGRectMake(0,0,80,65);
        _labelName.m_hilightColor=GETSKINCOLOR(@"LocationSearchListColor");
        _labelAddress.m_hilightColor=GETSKINCOLOR(@"LocationSearchListColor");
        _naviButton.buttonCell = self;
        [self.contentView addSubview: _naviButton];
        
        
        
        _imageViewButton=[[UIImageView alloc] init];
        _imageViewButton.frame=CGRectMake(0, 0,80,65);
        _imageViewButton.userInteractionEnabled=YES;
        [_naviButton addSubview:_imageViewButton];
        [_imageViewButton release];
        UITapGestureRecognizer *tapGes=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchButton:)];
        [_imageViewButton addGestureRecognizer:tapGes];
        [tapGes release];
        self.accessoryType=UITableViewCellAccessoryNone;
        
        labelNaviGation = [[UILabel alloc]init];
        labelNaviGation.font = [UIFont systemFontOfSize:kSize2-2];
        labelNaviGation.textColor = GETSKINCOLOR(@"POINaviGationColor");
        labelNaviGation.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:labelNaviGation];
        [labelNaviGation release];
        
    }
	return self;
}
-(void)touchButton:(id)touch
{
    [_naviButton sendActionsForControlEvents:UIControlEventTouchUpInside];
}
-(void)setSearchType:(SEARCH_CELL_TYPE)searchType
{
    _searchType=searchType;
    _naviButton.hidden=NO;
    if (searchType==SEARCH_CELL_NO) {
        self.accessoryType=UITableViewCellAccessoryNone;
        self.accessoryView=nil;
        _naviButton.hidden=YES;
        labelNaviGation.hidden = YES;
    }
    else if(searchType==SEARCH_CELL_NAVI)
    {
        labelNaviGation.hidden = NO;
         labelNaviGation.text = STR(@"POI_Navi",Localize_POI);
        [_naviButton setImage:IMAGE(@"SearchNaviBtn1.png",IMAGEPATH_TYPE_1) forState:UIControlStateNormal];
        [_naviButton setImage:IMAGE(@"SearchNaviBtn2.png",IMAGEPATH_TYPE_1) forState:UIControlStateHighlighted];
    }
    else if(searchType==SEARCH_CELL_ADD)
    {
         labelNaviGation.hidden = YES;
        [_naviButton setImage:IMAGE(@"SearchAddBtn1.png",IMAGEPATH_TYPE_1) forState:UIControlStateNormal];
        [_naviButton setImage:IMAGE(@"SearchAddBtn2.png",IMAGEPATH_TYPE_1) forState:UIControlStateHighlighted];
        
    }
}
-(void)setPoi:(MWPoi *)poi
{
    if (poi==nil) {
        return;
    }
    _poi=poi;
    MWPoi *item = self.poi;
    
    self.labelName.text  = item.szName;
    self.labelName.m_hilightColor =GETSKINCOLOR(@"LocationSearchListColor");
    if (item.lDistance > 1000) {
        
        NSString *str=@"%0.1f";
        if (item.lDistance/1000.0f/1000>1) {
            str=@"%0.f";
        }
        str=[NSString stringWithFormat:str,poi.lDistance/1000.0f];
        
        if ([str hasSuffix:@".0"]) {
            str=[NSString stringWithFormat:@"%d",[str intValue]];
        }
        [self.detailTextLabel setText:[NSString stringWithFormat:@"%@%@",str,STR(@"Universal_KM", Localize_Universal)]];
        
    }
    else{
        [self.detailTextLabel setText:[NSString stringWithFormat:@"%d%@",poi.lDistance,STR(@"Universal_M", Localize_Universal)]];
    }
    self.labelAddress.text = [POICommon getPoiAddress:self.poi];
    
}
- (void)layoutSubviews
{
	[super layoutSubviews];
    CGRect contentRect = [self.contentView bounds];
	CGRect frame;
    int weight = 90;
    if (self.searchType ==SEARCH_CELL_NO)
    {
        weight = 0;
    }
    frame = CGRectMake(contentRect.origin.x + 17.0, 3.0, contentRect.size.width - weight-5+-20 , contentRect.size.height);
    if (self.imageView.image) {
        frame = CGRectMake(contentRect.origin.x + 17.0 +30, 3.0, contentRect.size.width - weight-5-20 , contentRect.size.height);
    }
	_labelName.frame = frame;
    
    frame = CGRectMake(contentRect.origin.x +17.0, 42.0, contentRect.size.width-weight-5-20, 20.0);
    if (self.imageView.image) {
        frame = CGRectMake(contentRect.origin.x +17.0+30, 42.0, contentRect.size.width-weight-5-20, 20.0);
    }
	_labelAddress.frame = frame;
    
	frame = CGRectMake(contentRect.size.width-78.0, 42.0, 70, 20.0);
    _naviButton.frame=CGRectMake(CGRectGetWidth( contentRect)-56,0,80,self.detailTextLabel.text.length==0?CGRectGetHeight(contentRect):65);
    
    if (_searchType == SEARCH_CELL_NAVI)
    {
          _naviButton.frame=CGRectMake(CGRectGetWidth( contentRect)-56-20,0,80,self.detailTextLabel.text.length==0?CGRectGetHeight(contentRect):65);
    }
    if (_searchType==SEARCH_CELL_ADD)
    {
        _naviButton.imageEdgeInsets=UIEdgeInsetsMake(0,0,0,40);
    }
    else
        _naviButton.imageEdgeInsets=UIEdgeInsetsMake(0,0,10,40);
	self.detailTextLabel.frame = frame;
    
     labelNaviGation.frame=CGRectMake(CGRectGetWidth( contentRect)-50,0, 56,self.detailTextLabel.text.length==0?CGRectGetHeight(contentRect):56);
     [_imageViewLine  setFrame:CGRectMake(CGRectGetWidth( contentRect)-56-20,15,1.5,self.frame.size.height-30)];
    if (self.type == SEARCH_CELL_LINE_TYPE_NO)
    {
         [_imageViewLine  setFrame:CGRectMake(CGRectGetWidth( contentRect)-56-20,15,0,0)];
    }
  
	
}

@end

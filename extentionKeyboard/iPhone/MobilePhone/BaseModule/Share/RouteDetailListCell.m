//
//  RouteDetailListCell.m
//  AutoNavi
//
//  Created by jiangshu-fu on 14-7-21.
//
//

#import "RouteDetailListCell.h"
#import "ColorLable.h"
@interface RouteDetailListCell()
{
    UIImageView *_imageViewLeft;    //左边的图片
    UIImageView *_imageViewDirect;  //左边图片上的转向图标
    UIImageView *_imageViewArrow;   //展开缩放图片
    
//    UIImageView *_imageViewSmallDirect; //子道路的转向图标
    
    UILabel *_labelRoadName;        //道路名称
    UILabel *_labelDistance;        //道路距离
    ColorLable *_labelTraffic;         //红绿灯个数
    
    UIButton *_buttonAvoid;         //避让按钮

}

@end

@implementation RouteDetailListCell
- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self)
    {
        _imageViewLeft = [[UIImageView alloc]init];
        [self.contentView addSubview:_imageViewLeft];
        [_imageViewLeft release];
        _imageViewDirect = [[UIImageView alloc]init];
        [self.contentView addSubview:_imageViewDirect];
         [_imageViewDirect release];
        _imageViewArrow = [[UIImageView alloc]init];
        [self.contentView addSubview:_imageViewArrow];
         [_imageViewArrow release];
        
        _labelRoadName = [self createLabel];
        _labelRoadName.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:_labelRoadName];
        _labelDistance = [self createLabel];
        [self.contentView addSubview:_labelDistance];
        
        UIColor *numColor = RGBACOLOR(184.0f, 36.0f, 66.0f, 1.0f);
        _labelTraffic = [[ColorLable alloc] initWithFrame:CGRectZero ColorArray:@[numColor]];
        _labelTraffic.backgroundColor = [UIColor clearColor];
        _labelTraffic.font = [UIFont systemFontOfSize:13.0f];
        _labelTraffic.textAlignment = NSTextAlignmentCenter;
        _labelTraffic.textColor = [UIColor blackColor];
        [self.contentView addSubview:_labelTraffic];
        [_labelTraffic release];
        
        _buttonAvoid = [UIButton buttonWithType:UIButtonTypeCustom];
        [_buttonAvoid setBackgroundImage:[IMAGE(@"Route_avoid.png", IMAGEPATH_TYPE_1) stretchableImageWithLeftCapWidth:8 topCapHeight:15] forState:UIControlStateNormal];
        [_buttonAvoid setBackgroundImage:[IMAGE(@"Route_avoidPress.png", IMAGEPATH_TYPE_1) stretchableImageWithLeftCapWidth:8 topCapHeight:15] forState:UIControlStateHighlighted];
        [_buttonAvoid setTitle:STR(@"RouteOverview_Avoid", Localize_RouteOverview) forState:UIControlStateNormal];
        [_buttonAvoid setTitleColor:GETSKINCOLOR(ROUTE_DETAIL_BUTTON_COLOR) forState:UIControlStateNormal];
        _buttonAvoid.titleLabel.font = [UIFont systemFontOfSize:14];
        [self.contentView addSubview:_buttonAvoid];
        [_buttonAvoid addTarget:self action:@selector(buttonAvoid:) forControlEvents:UIControlEventTouchUpInside];
        
        ManeuverInfo *info = [[ManeuverInfo alloc]init];
        self.cellData = info;
        self.avoidPress = nil;
        self.selectPress = nil;
        [info release];
    }
    return self;
}

- (void) dealloc
{
    CRELEASE(_cellData);
    CRELEASE(_selectPress);
    CRELEASE(_avoidPress);
    [super dealloc];
}

#pragma mark -  ---  设置程序数据  ---
- (void) loadImage
{

    //起点终点的图片设置
    if([self getActiveId:self.cellData.unTurnID] == 1)
    {
        _imageViewLeft.image = IMAGE(@"RouteDetailListBegin.png", IMAGEPATH_TYPE_1);
        _imageViewDirect.image = IMAGE(@"RouteDetailBack.png", IMAGEPATH_TYPE_1);
    }
    else if([self getActiveId:self.cellData.unTurnID] == 6)
    {
        _imageViewLeft.image = IMAGE(@"RouteDetailListEnd.png", IMAGEPATH_TYPE_1);
        _imageViewDirect.image = IMAGE(@"RouteDetailBack.png", IMAGEPATH_TYPE_1);
    }
    else
    {
        //转向图片的设置
        if(self.cellData.isSonPoint)
        {
            _imageViewLeft.image = IMAGE(@"RouteDetailListSmallDir.png", IMAGEPATH_TYPE_1);
        }
        else
        {
            _imageViewLeft.image = IMAGE(@"RouteDetailListMiddle.png", IMAGEPATH_TYPE_1);
        }
        UIImage *image =  [MWRouteGuide GetTurnIconWithID:self.cellData.unTurnID flag:0];
        NSLog(@"%d",self.cellData.unTurnID);
        _imageViewDirect.image = image;
    }
    
    //是否展开的图片设置
    if(self.cellData.isExtension)
    {
        _imageViewArrow.image = IMAGE(@"RouteDetailArrowUp.png", IMAGEPATH_TYPE_1);
    }
    else
    {
        _imageViewArrow.image = IMAGE(@"RouteDetailArrowDown.png", IMAGEPATH_TYPE_1);
    }
}

- (void) loadTextData
{
//    UILabel *_labelRoadName;        //道路名称
//    UILabel *_labelDistance;        //道路距离
//    ColorLable *_labelTraffic;         //红绿灯个数
    _labelRoadName.text = self.cellData.szDescription;
    if(self.cellData.isSonPoint == NO)
    {
        _labelDistance.text = [self.cellData getNextDisString];
        if(self.cellData.nTrafficLightNum > 0)//红绿灯个数大于0 才显示
        {
            _labelTraffic.text = [NSString stringWithFormat:STR(@"Route_LightTraffic", Localize_RouteOverview),
                                  self.cellData.nTrafficLightNum];
        }
        else
        {
            _labelTraffic.text = @"";
        }

    }
    else
    {
        _labelDistance.text  = @"";
        _labelTraffic.text = @"";
    }
}


- (Guint32) getActiveId:(Guint32)turnID
{
    Guint32 ID = turnID;
    //判断左舵
    BOOL isLeft = NO;
    if(((turnID >> 31) & 0x01) == 1)
    {
        isLeft = YES;
        ID = ID & 0x7fffffff;
    }
    return ID;
}

/*!
  @brief    设置程序数据
  @param
  @author   by bazinga
  */
- (void) setCellData:(ManeuverInfo *)cellData
{
    [cellData retain];
    if (_cellData != nil) {
        [_cellData release];
    }
    //直接release无需判断也是可以的，iOS中对nil进行release操作合法
    //[_test1 release];
    _cellData = cellData;
    
    Guint32 ID = [self getActiveId:cellData.unTurnID];
    //起点终点中途点
    if(ID == 1 || ID  == 6  || (ID  >= 306 && ID  <= 310))
    {
        _buttonAvoid.hidden = YES;
        _imageViewArrow.hidden = YES;
        _labelDistance.hidden = YES;
        _labelTraffic.hidden = YES;
    }
    else
    {
        _buttonAvoid.hidden = NO;
        _labelDistance.hidden = NO;
        _labelTraffic.hidden = NO;
        //是否有子道路
        if(cellData.nNumberOfSubManeuver > 0)
        {
            _imageViewArrow.hidden = NO;
        }
        else
        {
            _imageViewArrow.hidden = YES;
        }
    }
    
    if(cellData.stObjectId.u8LayerID == 0
       && cellData.stObjectId.u8Rev == 0
       && cellData.stObjectId.u16AdareaID == 0
       && cellData.stObjectId.unMeshID == 0
       && cellData.stObjectId.unObjectID == 0
       && cellData.stObjectId.unRev == 0)
    {
        _buttonAvoid.hidden = YES;
    }
    
    
    [self loadImage];
    [self loadTextData];
}

#pragma mark - ---  设置控件的坐标  ---
-(void) layoutSubviews
{
    [super layoutSubviews];
    
    
    
    CGRect contentRect = [self.contentView bounds];
    
    float distanceToLeftCenter = 26.0f;
    float centerY = contentRect.size.height / 2;
    [_imageViewLeft setFrame:CGRectMake(0, 0, 34.0f, contentRect.size.height)];
    [_imageViewLeft setCenter:CGPointMake(distanceToLeftCenter, centerY)];
    if(self.cellData.isSonPoint)
    {
        [_imageViewDirect setFrame:CGRectMake(0, 0, 13.0f, 13.0f)];
        [_imageViewDirect setCenter:CGPointMake(60.0f, centerY)];
    }
    else
    {
        [_imageViewDirect setFrame:CGRectMake(0, 0, 18.0f, 18.0f)];
        [_imageViewDirect setCenter:CGPointMake(distanceToLeftCenter,centerY )];
    }
    
    [_imageViewArrow setFrame:CGRectMake(0, 0, 22.0f, 22.0f)];
    [_imageViewArrow setCenter:CGPointMake(contentRect.size.width - 18.0f, centerY)];
    
    float avoidWidth = 45.0f;
    [_buttonAvoid setFrame:CGRectMake(0.0f,10.0f,avoidWidth,30.0f)];
    [_buttonAvoid setCenter:CGPointMake(contentRect.size.width - 18.0f * 2 - avoidWidth / 2,
                                        centerY)];
    
    CGSize labelSize = CGSizeZero;
    float labelWidth = contentRect.size.width - 52.0f - 85.0f;
    float labelx = 52.0f;
    if([self getActiveId:self.cellData.unTurnID] == 1
       || [self getActiveId:self.cellData.unTurnID]  == 6
       || ([self getActiveId:self.cellData.unTurnID]  >= 306 && [self getActiveId:self.cellData.unTurnID]  <= 310))
    {
        labelSize = [_labelRoadName.text sizeWithFont:_labelRoadName.font];
        [_labelRoadName setFrame:CGRectMake(labelx,
                                            (contentRect.size.height - labelSize.height) / 2,
                                            labelWidth,
                                            labelSize.height)];
        
    }
    else
    {
        if(self.cellData.isSonPoint)
        {
            labelSize = [_labelRoadName.text sizeWithFont:_labelRoadName.font];
            labelWidth = contentRect.size.width - 72.0f - 85.0f;
            [_labelRoadName setFrame:CGRectMake(72.0,
                                                0,
                                                labelWidth,
                                                labelSize.height)];
            [_labelRoadName setCenter:CGPointMake(_labelRoadName.center.x, contentRect.size.height / 2)];
            [_labelTraffic setFrame: CGRectZero];
            [_labelDistance setFrame:CGRectZero];
        }
        else
        {
            labelSize = [_labelRoadName.text sizeWithFont:_labelRoadName.font];
            [_labelRoadName setFrame:CGRectMake(labelx,
                                                11.0f,
                                               labelWidth,
                                                labelSize.height)];
            labelSize =  [_labelDistance.text sizeWithFont:_labelDistance.font];
            [_labelDistance setFrame:CGRectMake(labelx,
                                               _labelRoadName.frame.origin.y + _labelRoadName.frame.size.height + 2,
                                               labelSize.width + 10.0f,
                                                labelSize.height)];
            
            [_labelTraffic setFrame:CGRectMake(_labelDistance.frame.origin.x + _labelDistance.frame.size.width,
                                              _labelDistance.frame.origin.y,
                                              labelWidth - _labelDistance.frame.size.width,
                                               labelSize.height)];
        }
    }
}


#pragma mark - ---  辅助函数  ---
- (UILabel *) createLabel
{
    UILabel *label = [[UILabel alloc] init];
	label.font = [UIFont systemFontOfSize:16.0f];
	label.textColor = [UIColor blackColor];
	label.textAlignment = NSTextAlignmentCenter;
	label.backgroundColor = [UIColor clearColor];
    
    return [label autorelease];
}

#pragma - ---  按钮响应事件  ---
- (void) buttonAvoid:(id) sender
{
    if(self.avoidPress)
    {
        self.avoidPress(_cellData);
    }
}



@end

//
//  RouteDetailButton.m
//  AutoNavi
//
//  Created by jiangshu-fu on 14-7-18.
//
//

#import "RouteDetailButton.h"
#import "ControlCreat.h"
#import "ColorLable.h"

#pragma  mark - ---  按钮使用数据  ---

@implementation RouteDetailButtonData
//@property (nonatomic, copy) NSString *stringTime;     //总时间
//@property (nonatomic, copy) NSString *stringLength;   //路径长度
//@property (nonatomic, assign) int trafficeNum;      //交通信号灯个数
//@property (nonatomic, assign) int tollNum;          //加油站个数
//@property (nonatomic, assign) int buttonTag;        //按钮的 tag 标示符
//@property (nonatomic, assign) int routeChose;       //路线选择类型
//@property (nonatomic, assign) BOOL isTuiJian;       //是否是推荐（233） 默认是非推荐
//@property (nonatomic, assign) BOOL isAvoid;         //是否是躲避拥堵
- (id) init
{
    self = [super init];
    if(self)
    {
        //设置默认值
        self.stringTime = @"";
        self.stringLength = @"";
        self.stringTrafficeNum = @"0";
        self.stringTollNum = @"0";
        self.stringType = @"";
        self.buttonTag = -1;
        self.routeChose = -1;
        self.isTuiJian = NO;
        self.isAvoid = NO;
    }
    
    return self;
}

- (void) setData:(RouteDetailButtonData *)tempData
{
    self.stringTime = tempData.stringTime;
    self.stringLength = tempData.stringLength;
    self.stringTrafficeNum = tempData.stringTrafficeNum;
    self.stringTollNum = tempData.stringTollNum;
    self.buttonTag = tempData.buttonTag;
    self.routeChose = tempData.routeChose;
    self.isTuiJian = tempData.isTuiJian;
    self.isAvoid = tempData.isAvoid;
    self.stringType = tempData.stringType;
}

- (void) dealloc
{
    CRELEASE(_stringTime);
    CRELEASE(_stringLength)
    CRELEASE(_stringTollNum);
    CRELEASE(_stringTrafficeNum);
    CRELEASE(_stringType);

    [super dealloc];
}

@end

#pragma  mark -
#pragma  mark -
#pragma  mark - ---  按钮对象  ---

#define IMAGE_HOR_DETAIL IMAGE(@"POIVerLine.png", IMAGEPATH_TYPE_1)
#define IMAGE_VER_DETAIL IMAGE(@"POILine.png", IMAGEPATH_TYPE_1)
#define IMAGE_DETAIL_BUTTON_NORMAL_BACK IMAGE(@"RouteDetailNormal.png", IMAGEPATH_TYPE_1)
#define IMAGE_DETAIL_BUTTON_PRESS_BACK IMAGE(@"POIWhereBtn1.png", IMAGEPATH_TYPE_1)
#define IMAGE_DETAIL_BUTTON_INFO_BACK IMAGE(@"RouteDetailButtonInfoBack.png", IMAGEPATH_TYPE_1)
#define IMAGE_DETAIL_AVOID_BACK IMAGE(@"RouteDetailButtonType.png", IMAGEPATH_TYPE_1)

#define DETAIL_NUM_FONT [UIFont boldSystemFontOfSize:(isiPhone ? 16.0f : 29.0f)]


typedef enum RouteDetailButton
{
    RouteDetailButton_NEXT = 0,      //改变table高度，也就是减去键盘高度
    RouteDetailButton_PRE,          //仅仅只做table的content偏移
}ListenerType;

@interface RouteDetailButton()
{
    ColorLable *_labelTime;     //时间
    ColorLable *_labelLength;   //距离
    ColorLable *_labelTraffic;  //红绿灯
    ColorLable *_labelToll;     //收费站
    
    UIButton *_buttonRouteType;     //躲避拥堵和推荐
    UIImageView *_imageViewTraffic; //交通灯图片
    UIImageView *_imageViewToll;    //收费站图片
    UIImageView *_imageViewHengLineShang;//按钮的横线 233 ---
    UIImageView *_imageViewHengLineXia;//按钮的横线 233 ---
    UIImageView *_imageShuLine;     //按钮的竖线 233 |||
    
    UIButton *_buttonNext ;         //吓一跳路线
    UIButton *_buttonPre;           //上一条路线
}

@end

@implementation RouteDetailButton
/*!
  @brief    初始化函数
  @param
  @author   by bazinga
  */
- (id) init
{
    self = [super init];
    if(self)
    {
        self.clipsToBounds  = YES;
        _dataWithButton = [[RouteDetailButtonData alloc]init];
        
        _labelTime = [[ColorLable alloc]initWithFrame:CGRectMake(0, 0, 0, 0)
                                           ColorArray:@[[UIColor blackColor]]
                                        TextFontArray:DETAIL_NUM_FONT];
        _labelTime.textColor = [UIColor blackColor];
        _labelTime.textAlignment = NSTextAlignmentRight;
        _labelTime.backgroundColor = [UIColor clearColor];
        
        _labelLength = [[ColorLable alloc]initWithFrame:CGRectMake(0, 0, 0, 0)
                                             ColorArray:@[[UIColor blackColor]]
                                          TextFontArray:DETAIL_NUM_FONT];
        _labelLength.textColor = [UIColor blackColor];
        _labelLength.textAlignment = NSTextAlignmentLeft;
        _labelLength.backgroundColor = [UIColor clearColor];
        
        _labelTraffic = [self createColorLabel];
        _labelTraffic.textAlignment = NSTextAlignmentRight;
        _labelToll = [self createColorLabel];
        _labelToll.textAlignment = NSTextAlignmentLeft;
        [self addSubview:_labelTime];
        [self addSubview:_labelLength];
        [self addSubview:_labelTraffic];
        [self addSubview:_labelToll];
        _imageViewTraffic = [self createImageView];
        _imageViewToll = [self createImageView];
        _imageViewHengLineShang = [self createImageView];
        _imageViewHengLineXia = [self createImageView];
        _imageShuLine = [self createImageView];
        
        [self addSubview:_imageViewTraffic];
        [self addSubview:_imageViewToll];
        [self addSubview:_imageViewHengLineShang];
        [self addSubview:_imageViewHengLineXia];
        [self addSubview:_imageShuLine];

        _buttonRouteType = [UIButton buttonWithType:UIButtonTypeCustom];
        _buttonRouteType.hidden = YES;

        [self addSubview:_buttonRouteType];
        
        [self loadControlSetting];
        
        //按钮前一个后一个~
        _buttonNext = [UIButton buttonWithType:UIButtonTypeCustom];
        _buttonNext.tag = RouteDetailButton_NEXT;
        _buttonNext.backgroundColor = [UIColor clearColor];
        _buttonPre = [UIButton buttonWithType:UIButtonTypeCustom];
        _buttonPre.backgroundColor = [UIColor clearColor];
        _buttonPre.tag = RouteDetailButton_PRE;
        
        [_buttonPre addTarget:self action:@selector(buttonPress:) forControlEvents:UIControlEventTouchUpInside];
        [_buttonNext addTarget:self action:@selector(buttonPress:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview: _buttonNext];
        [self addSubview:_buttonPre];
        
        self.userInteractionEnabled = YES;
    }
    return self;
}
- (id) initWithData:(RouteDetailButtonData *)data
{
    self = [self init];
    if(self)
    {
        self.dataWithButton = data;
    }
    return self;
}

//- (id)initWithFrame:(CGRect)frame
//{
//    self = [super initWithFrame:frame];
//    if (self)
//    {
//        [self setFrame:frame];
//    }
//    return self;
//}

- (void) dealloc
{
    CRELEASE(_labelTime);
    CRELEASE(_dataWithButton);
    CRELEASE(_labelLength);
    CRELEASE(_PreButtonPress);
    CRELEASE(_NextButtonPress);
    [super dealloc];
}

#pragma mark - ---  重载赋值函数  ---
- (void) setDataWithButton:(RouteDetailButtonData *)dataWithButton
{
    [_dataWithButton setData:dataWithButton];

    [_buttonRouteType setTitle:dataWithButton.stringType
                      forState: UIControlStateNormal];
    _buttonRouteType.hidden = NO;
    _labelTime.text = dataWithButton.stringTime;
    _labelLength.text = dataWithButton.stringLength;
    _labelTraffic.text = [NSString stringWithFormat:STR(@"Main_TrafficNum", Localize_Main),dataWithButton.stringTrafficeNum] ;
    _labelToll.text =  [NSString stringWithFormat:STR(@"Main_TollNum", Localize_Main),dataWithButton.stringTollNum];
    
    if(dataWithButton.indexButton == 0) //没有前一个
    {
        [_buttonPre setImage:IMAGE(@"RouteDetail_NoPre.png", IMAGEPATH_TYPE_1) forState:UIControlStateNormal];
        _buttonPre.enabled = NO;
    }
    else
    {
        [_buttonPre setImage:IMAGE(@"RouteDetail_Pre.png", IMAGEPATH_TYPE_1) forState:UIControlStateNormal];
        _buttonPre.enabled = YES;
    }
    if(dataWithButton.indexButton == dataWithButton.indexTotal - 1) //没有后一个
    {
         [_buttonNext setImage:IMAGE(@"RouteDetail_NoNext.png", IMAGEPATH_TYPE_1) forState:UIControlStateNormal];
        _buttonNext.enabled = NO;
    }
    else
    {
        [_buttonNext setImage:IMAGE(@"RouteDetail_Next.png", IMAGEPATH_TYPE_1) forState:UIControlStateNormal];
        _buttonNext.enabled = YES;
    }
    if(dataWithButton.indexTotal == 1)
    {
        _buttonNext.hidden = YES;
        _buttonPre.hidden = YES;
    }
    
    [self setFrame:self.frame];
}

- (void) setFrame:(CGRect)frame
{
    [super setFrame:frame];
    float buttonWidth = isiPhone ? 44.0f : 70.0f;
    CGRect buttonRect = CGRectMake(0, 0, buttonWidth, frame.size.height);
    [_buttonNext setFrame:buttonRect];
    [_buttonPre setFrame:buttonRect];
    [_buttonPre setCenter:CGPointMake(buttonWidth / 2 , frame.size.height / 2)];
    [_buttonNext setCenter:CGPointMake(frame.size.width - buttonWidth / 2, frame.size.height / 2)];
    
//    CGAffineTransform at =CGAffineTransformMakeRotation(0);
    if(isiPhone)
    {
        float width = frame.size.width / 2;
        
        CGSize size = [_buttonRouteType.titleLabel.text sizeWithFont:_buttonRouteType.titleLabel.font];
        size.width += 30.0f;
        float buttonTypeHeight = 17.0f;
        
        [_buttonRouteType setFrame:CGRectMake(width - size.width / 2, 2.5f,  size.width, buttonTypeHeight)];
        int y =  _buttonRouteType.frame.size.height + 5.0f;
        [_labelTime setFrame:CGRectMake(0,  y,width - 5,20.0f)];
        [_labelLength setFrame:CGRectMake(width + 5, y, width - 5, 20.0f)];
        
        y = _labelTime.frame.origin.y + _labelTime.frame.size.height + 3.0f;
        
        [_labelTraffic setFrame:CGRectMake(0,  y,width - 5, 13.0f)];
        [_labelToll setFrame:CGRectMake(width + 5, y, width - 5, 13.0f)];
    }
    else
    {
        
        float width = frame.size.width / 2;
        
        CGSize size = [_buttonRouteType.titleLabel.text sizeWithFont:_buttonRouteType.titleLabel.font];
        size.width += 45.0f;
        float buttonTypeHeight = 26.0f;
        
        [_buttonRouteType setFrame:CGRectMake(width - size.width / 2, 3.0f,  size.width, buttonTypeHeight)];
        int y =  _buttonRouteType.frame.size.height + 8.0f;
        CGSize timeSize = [_labelTime.text sizeWithFont:DETAIL_NUM_FONT];
        [_labelTime setFrame:CGRectMake(0,  y,width - 5, timeSize.height)];
        [_labelLength setFrame:CGRectMake(width + 5, y, width - 5, timeSize.height)];
        
        timeSize = [_labelTraffic.text sizeWithFont:_labelTraffic.font];
        y = frame.size.height - 15.0f - timeSize.height;
        [_labelTraffic setFrame:CGRectMake(0,  y,width - 5, timeSize.height)];
        [_labelToll setFrame:CGRectMake(width + 5, y, width - 5, timeSize.height)];
    }

    
    //控件旋转
//    CGFloat angle = - (M_PI ) * (1.0f / 4.0f);
//    at =CGAffineTransformMakeRotation(angle);
//    UIImageView *_imageViewHengLineShang;//按钮的横线 233 ---
//    UIImageView *_imageViewHengLineXia;//按钮的横线 233 ---
//    UIImageView *_imageShuLine;     //按钮的竖线 233 |||
//    [_imageViewHengLineShang setFrame:CGRectMake(0, 0, width, 1.0f)];
//    [_imageViewHengLineXia setFrame:CGRectMake(0, height - 1.0f, width, 1.0f)];
//    [_imageShuLine setFrame:CGRectMake(width - 1.0f, 0, 1.0f, height)];
    
}


#pragma mark - ---  辅助函数  ---
- (ColorLable *) createColorLabel
{
    
    ColorLable *label = [[ColorLable alloc] initWithFrame:CGRectMake(0, 0, 0, 0) ColorArray:@[RGBCOLOR(190.0f, 49.0f, 55.0f)]];
    label.font = [UIFont systemFontOfSize:13.0f];
    label.textColor = [UIColor blackColor];
    label.backgroundColor = [UIColor clearColor];
    
    return [label autorelease];
}


- (UIImageView *)createImageView
{
    UIImageView *imageView = [[UIImageView alloc]init];
    imageView.userInteractionEnabled = NO;
    return [imageView autorelease];
}
/*!
  @brief    加载控件设置
  @param
  @author   by bazinga
  */
- (void) loadControlSetting
{
    [self setViewImage];
    [self setTextFont];
}

/*!
  @brief    设置各种按钮，图片视图的资源
  @param
  @author   by bazinga
  */
- (void) setViewImage
{
    CGSize imageSize = IMAGE_DETAIL_AVOID_BACK.size;
    [_buttonRouteType setBackgroundImage:[IMAGE_DETAIL_AVOID_BACK stretchableImageWithLeftCapWidth:imageSize.width / 2
                                                                                             topCapHeight:imageSize.height / 2]
                                forState:UIControlStateNormal];
    [_buttonRouteType setBackgroundImage:[IMAGE_DETAIL_AVOID_BACK stretchableImageWithLeftCapWidth:imageSize.width / 2
                                                                                      topCapHeight:imageSize.height / 2]
                                forState:UIControlStateHighlighted];
    
    _imageViewTraffic.image = IMAGE(@"RouteDetailButtonTraffic.png", IMAGEPATH_TYPE_1);
    _imageViewToll.image = IMAGE(@"RouteDetailButtonToll.png", IMAGEPATH_TYPE_1);
    UIImage *hengxiangImage = [IMAGE_HOR_DETAIL stretchableImageWithLeftCapWidth:5
                                                                    topCapHeight:0];
    _imageViewHengLineShang.image = hengxiangImage;
    _imageViewHengLineXia.image = hengxiangImage;
    
    _imageShuLine.image = [IMAGE_VER_DETAIL stretchableImageWithLeftCapWidth:0
                                                                topCapHeight:5];
    
    imageSize = IMAGE_DETAIL_BUTTON_NORMAL_BACK.size;
    [self setImage:[IMAGE_DETAIL_BUTTON_NORMAL_BACK stretchableImageWithLeftCapWidth:imageSize.width /2 topCapHeight:imageSize.height / 2]];
}
/*!
  @brief    设置字体大小
  @param
  @author   by bazinga
  */
- (void) setTextFont
{
    _labelToll.textColor = [UIColor blackColor];
    _labelTraffic.textColor =[UIColor blackColor];

    if(isiPhone)
    {
        _labelTime.font = [UIFont systemFontOfSize:12.0f];
        _labelLength.font = [UIFont systemFontOfSize:12.0f];
        _labelTraffic.font = [UIFont systemFontOfSize:11.0f];
        _labelToll.font = [UIFont systemFontOfSize:11.0f];
        _buttonRouteType.titleLabel.font = [UIFont systemFontOfSize:11.0f];
    }
    else
    {
        _labelTime.font = [UIFont systemFontOfSize:20.0f];
        _labelLength.font = [UIFont systemFontOfSize:20.0f];
        _labelTraffic.font = [UIFont systemFontOfSize:18.0f];
        _labelToll.font = [UIFont systemFontOfSize:18.0f];
        _buttonRouteType.titleLabel.font = [UIFont systemFontOfSize:20.0f];
    }
}


#pragma mark - ---  按钮响应事件  ---
- (void) buttonPress:(UIButton *)button
{
    if(button.tag == RouteDetailButton_PRE)
    {
        if(self.PreButtonPress != nil)
        {
            self.PreButtonPress();
        }
    }
    if(button.tag == RouteDetailButton_NEXT)
    {
        if(self.NextButtonPress != nil)
        {
            self.NextButtonPress();
        }
    }
    
}

@end

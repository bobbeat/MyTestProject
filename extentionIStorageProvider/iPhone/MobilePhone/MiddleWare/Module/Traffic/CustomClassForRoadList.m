//
//  CustomClassForRoadList.m
//  AutoNavi
//
//  Created by liyuhang on 12-12-11.
//
//

/*
 自定义路线详情界面的列表单元格
 */

#import "CustomClassForRoadList.h"
#import "ANParamValue.h"
#import <QuartzCore/QuartzCore.h>
@implementation CustomCellForRoadList
@synthesize psImageViewCar = m_imageViewCar;
@synthesize psImgViewTopArrow = m_imgViewTopArrow;
@synthesize m_imageViewArrow;
@synthesize m_imageViewDirection;
@synthesize m_lableDis;
@synthesize m_lableRoad;
@synthesize m_buttonSelect;
@synthesize m_bShowSelectButtton;
@synthesize m_bSelect;
@synthesize m_delegate;
@synthesize m_nIndexInTableView;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIImageView *tmpView =  [[UIImageView alloc] init];
        self.backgroundView = tmpView;
        [tmpView release];
        [self addSubviewsToCell];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)addSubviewsToCell
{
    //
    m_lableDis = [[UILabel alloc] initWithFrame:CGRectZero];
    m_lableDis.font = [UIFont systemFontOfSize:18];
    m_lableDis.textColor = [UIColor colorWithRed:138/255.0 green:138/255.0 blue:138/255.0 alpha:1];
    m_lableDis.textAlignment = UITextAlignmentLeft;
    m_lableDis.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:m_lableDis];
    //
    m_lableRoad = [[UILabel alloc] initWithFrame:CGRectZero];
    m_lableRoad.font = [UIFont systemFontOfSize:18];
    m_lableRoad.textColor = [UIColor colorWithRed:138/255.0 green:138/255.0 blue:138/255.0 alpha:1];
    m_lableRoad.textAlignment = UITextAlignmentLeft;
    m_lableRoad.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:m_lableRoad];
    //
    m_imageViewArrow = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:m_imageViewArrow];
    //
    m_imgViewTopArrow = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:m_imgViewTopArrow];
    //
    m_imageViewDirection = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:m_imageViewDirection];
    //
    m_imageViewCar = [[UIImageView alloc]initWithImage: IMAGE(@"roadlist-tableview-car.png", IMAGEPATH_TYPE_1)];
    [self.contentView addSubview:m_imageViewCar];
    
    m_buttonSelect = [[UIButton alloc] initWithFrame:CGRectZero];
//    [m_buttonSelect addTarget:self action:@selector(buttonClicked) forControlEvents:UIControlEventTouchUpInside];
    [m_buttonSelect setUserInteractionEnabled:NO];
    [self.contentView addSubview:m_buttonSelect];
    //
    [self setSubviewsFrame];
}

-(void) setSubviewsFrame
{
    CGRect rcCell = [self.contentView frame];
    int nWidthOfCell = rcCell.size.width;
    float fHeightOfCell = rcCell.size.height;
    CGRect disFrame,roadFram, rcArrowFram, rcDirectionFram, rcButtonFram, rcCarFrame, rcTopArrowFrame;
    int nOffset = 0;
//    enum Position{
//        kRoadNameOffset = 20,         // 一 道路名左移
//        kDisOffset = 70,              // 二 距离显示（70） 中间左移动30开始显示
//        kDirectionImageSize = 30,     // 三 道路方向位置，根据箭头长度的一半
//        kDetourBtnSize = 25,          // 四 规避按钮，在三的基础上
//    };
    // 设置区域
    NSString* szImageName = Nil;
    int nLengthOfArrow, nHeightOfArrow;
    int nLengthOfcar=19, nHeightOfCar=17;
    if (isPad) {
        if (Interface_Flag == 0) {// 竖屏
            szImageName = @"roadlist-ArrowForRoadList_V_iPad";// 190*18
            nLengthOfArrow = 516;
            nHeightOfArrow = 28;
        } else {
            szImageName = @"roadlist-ArrowForRoadList_H_iPad";// 313*18
            nLengthOfArrow = 762;
            nHeightOfArrow = 28;
        }
    } else {
        if (Interface_Flag == 0) {// 竖屏
            szImageName = @"roadlist-ArrowForRoadList_V";// 190*18
            nLengthOfArrow = 190;
            nHeightOfArrow = 18;
        } else {
            szImageName = @"roadlist-ArrowForRoadList_H";// 313*18
            nLengthOfArrow = 313;
            nHeightOfArrow = 18;
        }
    }
    // 是否右移转向图片和展开提示
    if (m_bShowSelectButtton) {
        nOffset = 20;
    }
    // 车位区域
    rcCarFrame = CGRectMake(1, (fHeightOfCell-nHeightOfCar)/2,  nLengthOfcar, nHeightOfCar);

    // 箭头区域
    rcTopArrowFrame = CGRectMake(nWidthOfCell/2-nLengthOfArrow/2, 0-nHeightOfArrow/2, nLengthOfArrow, nHeightOfArrow);
    rcArrowFram = CGRectMake(nWidthOfCell/2-nLengthOfArrow/2, fHeightOfCell-nHeightOfArrow/2, nLengthOfArrow, nHeightOfArrow);      
    // 道路名区域
    roadFram = CGRectMake(kRoadNameOffset, 0,  nWidthOfCell/2-kRoadNameOffset, fHeightOfCell);
    // 距离区域
    disFrame = CGRectMake(nWidthOfCell/2, 0.0f, nLengthOfArrow/2-kDirectionImageSize + 15, fHeightOfCell);
    // 方向区域
    rcDirectionFram = CGRectMake(nWidthOfCell/2+nLengthOfArrow/2-kDirectionImageSize/2, (fHeightOfCell-kDirectionImageSize)/2, kDirectionImageSize, kDirectionImageSize);
    // 规避按钮区域
    rcButtonFram = CGRectMake(nWidthOfCell-(nWidthOfCell-nLengthOfArrow-kDirectionImageSize)/4-kDetourBtnSize/2, (fHeightOfCell-kDetourBtnSize)/2, kDetourBtnSize, kDetourBtnSize);
    //
    [m_imageViewCar setFrame:rcCarFrame];
    [m_lableDis setFrame:disFrame];
    [m_lableRoad setFrame:roadFram];
    [m_imageViewArrow setFrame:rcArrowFram];
    [m_imageViewArrow setImage: IMAGE(szImageName, IMAGEPATH_TYPE_1)];
    //
    [m_imgViewTopArrow setFrame:rcTopArrowFrame];
    [m_imgViewTopArrow setImage:IMAGE(szImageName, IMAGEPATH_TYPE_1)];
    //
    [m_imageViewDirection setFrame:rcDirectionFram];
    [m_buttonSelect setFrame:rcButtonFram];
    UIImage* imageForButton = IMAGE(@"Unselected.png", IMAGEPATH_TYPE_1);
    [m_buttonSelect setImage:imageForButton forState:UIControlStateNormal];
}

-(void) layoutSubviews
{
    [super layoutSubviews];
    [self setSubviewsFrame];
    // 
    if (m_bShowSelectButtton) {
        [m_buttonSelect setHidden:NO];
    } else {
        [m_buttonSelect setHidden:YES];
    }
    // 
    if (m_bSelect) {
        UIImage* imageForButton = IMAGE(@"Selected.png", IMAGEPATH_TYPE_1) ;
        [m_buttonSelect setImage:imageForButton forState:UIControlStateNormal];
    } else {
        UIImage* imageForButton = IMAGE(@"Unselected.png", IMAGEPATH_TYPE_1);
        [m_buttonSelect setImage:imageForButton forState:UIControlStateNormal];
    }
}

- (void) buttonClicked
{
    m_bSelect = !m_bSelect;
    [self setNeedsLayout];
    [m_delegate CustomCellForRoadListHandlebCheck:m_bSelect atIndex:m_nIndexInTableView ];
}

- (void) dealloc
{
    [m_lableDis release];
    [m_lableRoad release];
    [m_imageViewArrow release];
    [m_imgViewTopArrow release];
    [m_imageViewDirection release];
    [m_buttonSelect release];
    [m_imageViewCar release];
    [super dealloc];
}
@end



/*
 
 路线详情界面交通情况分布
 
 */
@implementation TraficStatusForRoutes

@synthesize psfWideForCarImage=m_fwideForCarImage;

-(id)initWithGrayComponet:(float)fGray YellowComponent:(float)fYellow RedComponent:(float)fRed GreenComponent:(float)fGreen forIpad:(BOOL)bForIpad
{
    self = [super init];
    if (self==NULL) {
        return NULL;
    }
    //
    m_fGrayComponent = fGray;
    m_fGreenComponent = fGreen;
    m_fRedComponent = fRed;
    m_fYellowComponent = fYellow;
    if (bForIpad) {
        // 42*42 ipad 38*38
        m_imageCar = [[UIImageView alloc] initWithImage:IMAGE(@"roadlist-car_iPad.png", IMAGEPATH_TYPE_1)];
        m_imageDestination = [[UIImageView alloc] initWithImage: IMAGE(@"roadlist-destination_iPad.png", IMAGEPATH_TYPE_1)];
        // 48*2 ipad 34*34
        m_imageRedComponent = [[UIImageView alloc] initWithImage: IMAGE(@"roadlist-red-component_iPad.png", IMAGEPATH_TYPE_1)];
        m_imageGreenComponent = [[UIImageView alloc] initWithImage:IMAGE(@"roadlist-green-component_iPad.png", IMAGEPATH_TYPE_1) ];
        m_imageGrayComponent = [[UIImageView alloc] initWithImage:IMAGE(@"roadlist-gray-component_iPad.png", IMAGEPATH_TYPE_1) ];
        m_imageYellowComponent = [[UIImageView alloc] initWithImage:IMAGE(@"roadlist-yellow-component_iPad.png", IMAGEPATH_TYPE_1) ];
        //
        m_imgBackGround= [[UIImageView alloc] initWithImage:IMAGE(@"roadlist-background-component_iPad.png", IMAGEPATH_TYPE_1)  ];

    } else {
        // 42*42 ipad 38*38
        m_imageCar = [[UIImageView alloc] initWithImage:IMAGE(@"roadlist-car.png", IMAGEPATH_TYPE_1) ];
        m_imageDestination = [[UIImageView alloc] initWithImage: IMAGE(@"roadlist-destination.png", IMAGEPATH_TYPE_1)];
        // 48*2 ipad 34*34
        m_imageRedComponent = [[UIImageView alloc] initWithImage:IMAGE(@"roadlist-red-component.png", IMAGEPATH_TYPE_1)];
        m_imageGreenComponent = [[UIImageView alloc] initWithImage:IMAGE(@"roadlist-green-component.png", IMAGEPATH_TYPE_1)];
        m_imageGrayComponent = [[UIImageView alloc] initWithImage:IMAGE(@"roadlist-gray-component.png", IMAGEPATH_TYPE_1)];
        m_imageYellowComponent = [[UIImageView alloc] initWithImage: IMAGE(@"roadlist-yellow-component.png", IMAGEPATH_TYPE_1)];
        //
        m_imgBackGround= [[UIImageView alloc] initWithImage:[IMAGE(@"roadlist-background-component.png", IMAGEPATH_TYPE_1) stretchableImageWithLeftCapWidth:0 topCapHeight:30]];

    }
    //
    [self addSubview:m_imgBackGround];
    [self addSubview:m_imageCar];
    [self addSubview:m_imageDestination];
    [self addSubview:m_imageRedComponent];
    [self addSubview:m_imageGreenComponent];
    [self addSubview:m_imageGrayComponent];
    [self addSubview:m_imageYellowComponent];
    //
    [m_imgBackGround release];
    //
    [m_imageCar release];
    [m_imageDestination release];
    //
    [m_imageRedComponent release];
    [m_imageGreenComponent release];
    [m_imageGrayComponent release];
    [m_imageYellowComponent release];
    //
    return  self;
}

-(void) setViewFrame:(CGRect)frame
{
    CGRect rcBackground,rcDestination, rcCar, rcGray, rcRed, rcYellow,rcGreen;
    float fTotalHeigth, fWide;
    self.frame = frame;
    fTotalHeigth = frame.size.height;
    fWide = frame.size.width;
    //
    rcBackground = CGRectMake(0, fWide*2/3.0, fWide, fTotalHeigth-fWide*2/3.0);
    //(fWide-m_fwideForCarImage)/2
    rcDestination = CGRectMake(0, 0, fWide, fWide);
    rcCar = CGRectMake(0, fTotalHeigth-fWide, fWide, fWide);
    //
    float fHeigthForComponet = fTotalHeigth - fWide*2;
    float fGray = fHeigthForComponet*m_fGrayComponent;
    float fRed = fHeigthForComponet*m_fRedComponent;
    float fYellow = fHeigthForComponet*m_fYellowComponent;
    float fGreen = fHeigthForComponet*m_fGreenComponent;
    //
    rcGray = CGRectMake(0.0f, fWide, fWide, fGray);
    rcRed = CGRectMake(0.0f, fGray+fWide, fWide, fRed);
    rcYellow = CGRectMake(0.0f, fGray+fRed+fWide, fWide, fYellow);
    rcGreen = CGRectMake(0.0f, fGray+fRed+fYellow+fWide, fWide, fGreen);
    //
    [m_imgBackGround setFrame:rcBackground];
    [m_imageCar setFrame:rcCar];
    [m_imageDestination setFrame:rcDestination];
    [m_imageGrayComponent setFrame:rcGray];
    [m_imageRedComponent setFrame:rcRed];
    [m_imageYellowComponent setFrame:rcYellow];
    [m_imageGreenComponent setFrame:rcGreen];
}

-(void) dealloc
{
    [super dealloc];
    //
}

@end



@implementation CustomHeaderForRoadList
@synthesize psImageViewCar = m_imageViewCar;
@synthesize psImgViewTopArrow = m_imgViewTopArrow;
@synthesize psBtnDetailInfo = m_btnDetailInfo;
@synthesize m_imageViewArrow;
@synthesize m_imageViewDirection;
@synthesize m_lableDis;
@synthesize m_lableRoad;
@synthesize m_buttonSelect;
@synthesize m_bShowSelectButtton;
@synthesize m_bSelect;
@synthesize m_delegate;
@synthesize m_nIndexInTableView;
@synthesize psbShowDetails = m_bShowDetails;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Set up the tap gesture recognizer.
        [self addSubviewsToCell];
    }
    return self;
}

//- (void)setSelected:(BOOL)selected animated:(BOOL)animated
//{
//    [super setSelected:selected animated:animated];
//    
//    // Configure the view for the selected state
//}

- (void)addSubviewsToCell
{
    m_viewGesture = [[UIView alloc] initWithFrame:CGRectZero];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleOpen:)];
    [m_viewGesture addGestureRecognizer:tapGesture];
    [tapGesture release];
    [self addSubview:m_viewGesture];
    //
    m_lableDis = [[UILabel alloc] initWithFrame:CGRectZero];
    m_lableDis.font = [UIFont systemFontOfSize:18];
    m_lableDis.textColor = [UIColor whiteColor];
    m_lableDis.textAlignment = UITextAlignmentLeft;
    m_lableDis.backgroundColor = [UIColor clearColor];
    [self addSubview:m_lableDis];
    //
    m_lableRoad = [[UILabel alloc] initWithFrame:CGRectZero];
    m_lableRoad.font = [UIFont systemFontOfSize:18];
    m_lableRoad.textColor = [UIColor whiteColor];
    m_lableRoad.textAlignment = UITextAlignmentLeft;
    m_lableRoad.backgroundColor = [UIColor clearColor];
    [self addSubview:m_lableRoad];
    //
    m_imageViewArrow = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self addSubview:m_imageViewArrow];
    //
    m_imgViewTopArrow = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self addSubview:m_imgViewTopArrow];
    //
    m_imageViewDirection = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self addSubview:m_imageViewDirection];
    //
    m_imageViewCar = [[UIImageView alloc]initWithImage:IMAGE(@"roadlist-tableview-car.png", IMAGEPATH_TYPE_1) ];
    [self addSubview:m_imageViewCar];
    
    m_buttonSelect = [[UIButton alloc] initWithFrame:CGRectZero];
    [m_buttonSelect addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:m_buttonSelect];
    //
    m_btnDetailInfo = [[UIButton alloc] initWithFrame:CGRectZero];
     if (isPad)
     {
         [m_btnDetailInfo setBackgroundImage:[UIImage imageNamed:@"CustomList-open_iPad.png"] forState:UIControlStateNormal];
         [m_btnDetailInfo setBackgroundImage:[UIImage imageNamed:@"CustomList-close_iPad.png"] forState:UIControlStateSelected];
     }else{
         [m_btnDetailInfo setBackgroundImage:[UIImage imageNamed:@"CustomList-open.png"] forState:UIControlStateNormal];
         [m_btnDetailInfo setBackgroundImage:[UIImage imageNamed:@"CustomList-close.png"] forState:UIControlStateSelected];
     }
    [m_btnDetailInfo addTarget:self action:@selector(toggleOpen:) forControlEvents:UIControlEventTouchUpInside];
    [m_btnDetailInfo setUserInteractionEnabled:NO];
    [self addSubview:m_btnDetailInfo];
    //
    m_viewSpearate = [[UIView alloc] init];
    [m_viewSpearate setBackgroundColor:[UIColor colorWithRed:119.0/255 green:119.0/255 blue:119.0/255 alpha:1]]; 
    [self addSubview:m_viewSpearate];
    //
    [self setSubviewsFrame];
}

-(void) setSubviewsFrame
{
    CGRect rcCell = [self frame];
    int nWidthOfCell = rcCell.size.width;
    float fHeightOfCell = rcCell.size.height;
    CGRect disFrame,roadFram, rcArrowFram, rcDirectionFram, rcButtonFram, rcCarFrame, rcTopArrowFrame;
    CGRect rcBtnDetails, rcViewGesture, rcViewSeparate;
    int nOffset=0;
    int nOffsetForGesture = 0;

    //    enum Position{
    //        kRoadNameOffset = 20,         // 一 道路名左移
    //        kDisOffset = 70,              // 二 距离显示（70） 中间左移动30开始显示
    //        kDirectionImageSize = 30,     // 三 道路方向位置，根据箭头长度的一半
    //        kDetourBtnSize = 25,          // 四 规避按钮，在三的基础上
    //    };
    // 设置区域
    NSString* szImageName = Nil;
    int nLengthOfArrow, nHeightOfArrow;
    int nLengthOfcar=19, nHeightOfCar=17;
    if (isPad) {
        if (Interface_Flag == 0) {// 竖屏
            szImageName = @"roadlist-ArrowForRoadList_V_iPad";// 190*18
            nLengthOfArrow = 516;
            nHeightOfArrow = 28;
        } else {
            szImageName = @"roadlist-ArrowForRoadList_H_iPad";// 313*18
            nLengthOfArrow = 762;
            nHeightOfArrow = 28;
        }
    } else {
        if (Interface_Flag == 0) {// 竖屏
            szImageName = @"roadlist-ArrowForRoadList_V";// 190*18
            nLengthOfArrow = 190;
            nHeightOfArrow = 18;
        } else {
            szImageName = @"roadlist-ArrowForRoadList_H";// 313*18
            nLengthOfArrow = 313;
            nHeightOfArrow = 18;
        }
    }
    // 是否右移转向图片和展开提示
    if (m_bShowSelectButtton) {
        nOffset = 25;
        nOffsetForGesture= (nWidthOfCell-nLengthOfArrow-kDirectionImageSize)/4-kDetourBtnSize/25;
    }
    rcViewSeparate = CGRectMake(0.0, fHeightOfCell-1, nWidthOfCell, 1);
    // 手势识别
    rcViewGesture = CGRectMake(0.0, 0.0, nWidthOfCell-nOffsetForGesture, fHeightOfCell);
    // 车位区域
    rcCarFrame = CGRectMake(1, (fHeightOfCell-nHeightOfCar)/2,  nLengthOfcar, nHeightOfCar);
    
    // 箭头区域
    rcTopArrowFrame = CGRectMake(nWidthOfCell/2-nLengthOfArrow/2, 0-nHeightOfArrow/2, nLengthOfArrow, nHeightOfArrow);
    rcArrowFram = CGRectMake(nWidthOfCell/2-nLengthOfArrow/2, fHeightOfCell-nHeightOfArrow/2, nLengthOfArrow, nHeightOfArrow);
    // 道路名区域
    roadFram = CGRectMake(kRoadNameOffset, 0,  nWidthOfCell/2-kRoadNameOffset-nOffset, fHeightOfCell);
    // 距离区域
    disFrame = CGRectMake(nWidthOfCell/2-nOffset, 0.0f, nLengthOfArrow/2-kDirectionImageSize+15, fHeightOfCell);
    // 方向区域
    rcDirectionFram = CGRectMake(nWidthOfCell/2+nLengthOfArrow/2-kDirectionImageSize/2-nOffset, (fHeightOfCell-kDirectionImageSize)/2, kDirectionImageSize, kDirectionImageSize);
    // 规避按钮区域
    rcButtonFram = CGRectMake(nWidthOfCell-(nWidthOfCell-nLengthOfArrow-kDirectionImageSize)/4-kDetourBtnSize/2, (fHeightOfCell-kDetourBtnSize)/2, kDetourBtnSize, kDetourBtnSize);
    // 子列
    rcBtnDetails =CGRectMake(nWidthOfCell-(nWidthOfCell-nLengthOfArrow-kDirectionImageSize)/4-kDetourBtnSize/2-nOffset, (fHeightOfCell-kDetourBtnSize)/2, kDetourBtnSize, kDetourBtnSize);
    [m_viewGesture setFrame:rcViewGesture];
    [m_imageViewCar setFrame:rcCarFrame];
    [m_lableDis setFrame:disFrame];
    [m_lableRoad setFrame:roadFram];
    [m_imageViewArrow setFrame:rcArrowFram];
    [m_imageViewArrow setImage:[UIImage imageNamed:szImageName]];
    //
    [m_imgViewTopArrow setFrame:rcTopArrowFrame];
    [m_imgViewTopArrow setImage:[UIImage imageNamed:szImageName]];
    //
    [m_imageViewDirection setFrame:rcDirectionFram];
    [m_buttonSelect setFrame:rcButtonFram];
    [m_btnDetailInfo setFrame:rcBtnDetails];
    [m_viewSpearate setFrame:rcViewSeparate];
    UIImage* imageForButton = [UIImage imageNamed:@"Unselected.png"];
    [m_buttonSelect setImage:imageForButton forState:UIControlStateNormal];
}

-(void) layoutSubviews
{
    [super layoutSubviews];
    [self setSubviewsFrame];
    //
    if (m_bShowSelectButtton) {
        [m_buttonSelect setHidden:NO];
    } else {
        [m_buttonSelect setHidden:YES];
    }
    //
    if (m_bSelect) {
        UIImage* imageForButton = [UIImage imageNamed:@"Selected.png"];
        [m_buttonSelect setImage:imageForButton forState:UIControlStateNormal];
    } else {
        UIImage* imageForButton = [UIImage imageNamed:@"Unselected.png"];
        [m_buttonSelect setImage:imageForButton forState:UIControlStateNormal];
    }
}
-(void)toggleOpen:(id)sender {
    
    [self toggleOpenWithUserAction:YES];
}


-(void)toggleOpenWithUserAction:(BOOL)userAction {
    
    // Toggle the disclosure button state.
    m_btnDetailInfo.selected = !m_btnDetailInfo.selected;
    
    // If this was a user action, send the delegate the appropriate message.
    if (userAction) {
        if (m_btnDetailInfo.selected) {
			
            if ([m_delegate respondsToSelector:@selector(sectionHeaderView:sectionOpened:)]) {
                [m_delegate sectionHeaderView:self sectionOpened:m_nIndexInTableView];
            }
        }
        else {
            if ([m_delegate respondsToSelector:@selector(sectionHeaderView:sectionClosed:)]) {
                [m_delegate sectionHeaderView:self sectionClosed:m_nIndexInTableView];
            }
        }
    }
}

- (void) buttonClicked:(id)sender
{
 //   m_bSelect = !m_bSelect;
    [self setNeedsLayout];
    if ([m_delegate respondsToSelector:@selector(clickDetourButton:atIndex:)]) {
        [m_delegate clickDetourButton:m_bSelect atIndex:m_nIndexInTableView];
    }
}

- (void) dealloc
{
    [m_lableDis release];
    [m_lableRoad release];
    [m_imageViewArrow release];
    [m_imgViewTopArrow release];
    [m_imageViewDirection release];
    [m_buttonSelect release];
    [m_imageViewCar release];
    [m_btnDetailInfo release];
    [m_viewGesture release];
    [m_viewSpearate release];
    [super dealloc];
}

//// 自绘分割线
//- (void)drawRect:(CGRect)rect
//{
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    
////    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
////    CGContextFillRect(context, rect);
//    
//    CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:0xE2/255.0f green:0xE2/255.0f blue:0xE2/255.0f alpha:1].CGColor);
//    CGContextStrokeRect(context, CGRectMake(0, rect.size.height - 1, rect.size.width, 1));
//}

@end






























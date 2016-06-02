//
//  GDMenu.h
//  AutoNavi
//
//  Created by huang longfeng on 13-8-29.
//
//

#import "GDPopPOI.h"
#import "MWSearchResult.h"
#import "BottomButton.h"
#import "MWMapOperator.h"
#import "ColorLable.h"

#define FRAME_HEIGHT 85.0f
#define FRAME_WIDTH  233.0f
#define SIDE 24
#define CENTERWIDTH 24
#define COLLECT_HEIGHT 40.5f
#define COLLECT_TOP_YINYING 4.0f
#define COLLENT_LEFT_YINYING 3.0F

#define FavoriteImage_Collect   @"POICollect_2.png"  //已收藏图片名称
#define FavoriteImage_NoCollect @"POICollect_1.png"  //未收藏图片名称
#define POPPOI_COLOR         GETSKINCOLOR(@"PopPoiColor")
#define POPPOI_TITLE_COLOR   GETSKINCOLOR(@"PopPoiTitleColor")
#define POPPOI_CLOSE_COLOR   GETSKINCOLOR(@"PopPoiCloseButtonColor")
#define POPPOI_TRAFFIC_COLOR   GETSKINCOLOR(@"PopPoiTrafficColor")
#define POPPOI_NIGHT_TEXT_COLOR  GETSKINCOLOR(@"PopPoiNightTextColor")  //弹出框 tips 黑夜的字体颜色

const CGFloat kArrowSize_Pop = 8.f;

@interface GDPopPOI() {
	UIView   *text_view;
	UILabel     *labelPOIName;
    UILabel     *labelAddress;
    UILabel     *labelDistance;
	UIButton    *button_collect;
    UIButton    *button_setStart;
    UIButton    *button_setDes;
    UIButton    *button_around;
    UIButton    *button_more;
    UIButton    *button_save;
    UIButton    *button_cancel;
    UIButton    *button_close;
    UIButton    *button_avoid;
    UIImageView *shareBackground;
    UIView      *addCommonBackground;
    UIView      *POIHandleBackground;
    UITextField *textFieldName;
    UIView      *viewTrafficBackground;
    UIView      *viewDesAroundBackground;
	UIImageView *imageViewTrafficIcon;
    UILabel     *labelTrafficType;
    UILabel     *labelTrafficDetail;
    UILabel     *labelDesAroundName;
    UILabel     *labelDesAroundAddress;
    ColorLable  *colorLabelDesAroundDisToDes;
    UIImageView *lineAddress;
    BottomButton    *button_timeCount;
    UIView      *_blockerView;
    UIButton    *button_setPassby;
    UIButton    *button_selectPOISetDes;
    UIButton    *button_desAroundSetDes;
	id          topView;
    MWPoi       *curPOI;
    int         _iTimeCount;
    NSTimer     *timerClose;
    
    UIImageView *back_center;
    UIImageView *back_left;
    UIImageView *back_right;
    UIImageView *gradientHView;
    UIImageView *lineView_1;
    UIImageView *lineView_2;
    UIImageView *lineView_desAround;
    ViewPOIType viewPOIType;
    
}

@property(nonatomic,retain) MWPoi *curPOI;
@property(nonatomic,assign) GMAPVIEWTYPE curMapViewType;

@end


@implementation GDPopPOI

@synthesize topView,delegate,curPOI,favoriteState,curMapViewType,isShow;


-(id)initWithType:(ViewPOIType)viewType
{
	self = [super init];
	if(self != nil)
	{

		viewPOIType = viewType;
        [self initControl];
		[self setButtonHidden];
        _iTimeCount = 10;
	}
	return self;
}

- (void)initControl
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshColorAndImage:) name:NOTIFY_HandleUIUpdate object:nil];
    curPOI = [[MWPoi alloc] init];
    
    text_view = [[UIView alloc] init];
    text_view.clipsToBounds = YES;
    if (viewPOIType == ViewPOIType_Common ) {
        [text_view setFrame:CGRectMake(0, 0, FRAME_WIDTH, FRAME_HEIGHT+40)];
    }
    else if(viewPOIType == ViewPOIType_Detail ){
        [text_view setFrame:CGRectMake(0, 0, FRAME_WIDTH, FRAME_HEIGHT)];
    }
    else if(viewPOIType == ViewPOIType_Traffic || viewPOIType == ViewPOIType_TrafficNoArrow)
    {
        [text_view setFrame:CGRectMake(0, 0, FRAME_WIDTH, FRAME_HEIGHT+50.)];
    }
    else if (viewPOIType == ViewPOIType_desAround)
    {
        [text_view setFrame:CGRectMake(0, 0, FRAME_WIDTH, FRAME_HEIGHT)];
    }
    else{
        [text_view setFrame:CGRectMake(0, 0, FRAME_WIDTH, 46)];
    }
    
    [text_view setBackgroundColor:[UIColor clearColor]];
    text_view.clipsToBounds = YES;
    
    back_center = [[UIImageView alloc] init];
    back_left = [[UIImageView alloc] init];
    back_right = [[UIImageView alloc] init];
    
    [text_view addSubview:back_left];
    [text_view addSubview:back_right];
    [text_view addSubview:back_center];
    
    labelPOIName = [[UILabel alloc] init];
    if (viewPOIType == ViewPOIType_passBy || viewPOIType == ViewPOIType_SelectPOI) {
        [labelPOIName setFrame:CGRectMake(0.0f, 0.0f, FRAME_WIDTH-90.0, 38.0)];
    }
    else{
        [labelPOIName setFrame:CGRectMake(10.0f, 0.0f, FRAME_WIDTH-60.0, 30.0)];
        [labelPOIName setCenter:CGPointMake(107, 18.0)];
    }

    
    [labelPOIName setFont:[UIFont boldSystemFontOfSize:15.0]];
    [labelPOIName setTextColor:POPPOI_TITLE_COLOR];
    [labelPOIName setBackgroundColor:[UIColor clearColor]];
    [labelPOIName setTextAlignment:NSTextAlignmentCenter];
    [text_view addSubview:labelPOIName];
    [labelPOIName release];
    
    labelAddress = [[UILabel alloc] init];
    [labelAddress setFrame:CGRectMake(10.0, 25.0, text_view.bounds.size.width-40.0, 30.0)];
    [labelAddress setTextColor:POPPOI_COLOR];
    [labelAddress setBackgroundColor:[UIColor clearColor]];
    [labelAddress setTextAlignment:NSTextAlignmentLeft];
    [text_view addSubview:labelAddress];
    [labelAddress release];labelAddress.hidden = YES;
    
    labelDistance = [[UILabel alloc] init];
    [labelDistance setFrame:CGRectMake(FRAME_WIDTH-110.0, 5.0, 100.0, 30.0)];
    [labelDistance setTextColor:POPPOI_COLOR];
    [labelDistance setBackgroundColor:[UIColor clearColor]];
    [labelDistance setTextAlignment:NSTextAlignmentLeft];
    [text_view addSubview:labelDistance];
    [labelDistance release];labelDistance.hidden = YES;
    button_collect = [UIButton buttonWithType:UIButtonTypeCustom];

    [button_collect setFrame:CGRectMake(COLLENT_LEFT_YINYING, COLLECT_TOP_YINYING, text_view.frame.size.width - 2 * COLLENT_LEFT_YINYING, COLLECT_HEIGHT - COLLECT_TOP_YINYING)];
    [button_collect setBackgroundColor:[UIColor clearColor]];
    [button_collect setImage:IMAGE(@"POI_MoreDetail.png", IMAGEPATH_TYPE_2) forState:UIControlStateNormal];
    [button_collect setImage:IMAGE(@"POI_MoreDetailPress.png", IMAGEPATH_TYPE_2) forState:UIControlStateNormal];
    [button_collect setImageEdgeInsets:UIEdgeInsetsMake(7., text_view.frame.size.width-30., 8, 10.)];
    [button_collect setTitleColor:POPPOI_COLOR forState:UIControlStateNormal];
    [button_collect addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    button_collect.tag = ViewPOIButtonType_more;
    [text_view addSubview:button_collect];
    
    UIImage *imageBackground1 = [IMAGE(@"POIPersonBtn.png", IMAGEPATH_TYPE_2) stretchableImageWithLeftCapWidth:5. topCapHeight:5.];
    UIImage *imageBackground2 = [IMAGE(@"POIPersonBtn1.png", IMAGEPATH_TYPE_2) stretchableImageWithLeftCapWidth:5. topCapHeight:5.];
    UIImage *imageBackground3 = [IMAGE(@"CommonBtn1.png", IMAGEPATH_TYPE_2) stretchableImageWithLeftCapWidth:5. topCapHeight:5.];
    UIImage *imageBackground4 = [IMAGE(@"CommonBtn2.png", IMAGEPATH_TYPE_2) stretchableImageWithLeftCapWidth:5. topCapHeight:5.];
    
    //设起点，设终点，周边，更多按钮初始化
    POIHandleBackground = [[UIView alloc] initWithFrame:CGRectMake(0.0, COLLECT_HEIGHT, FRAME_WIDTH, 36.0)];
    [text_view addSubview:POIHandleBackground];
    [POIHandleBackground release];
    
    button_setDes   = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_setDes setFrame:CGRectMake(COLLENT_LEFT_YINYING, 0.0, 80.0 - COLLENT_LEFT_YINYING, 36.0)];
    button_setDes.titleLabel.font = [UIFont systemFontOfSize:12.0];
    [button_setDes setTitle:STR(@"Main_setAsDestination", Localize_Main) forState:UIControlStateNormal];
    [button_setDes setTitleColor:POPPOI_COLOR forState:UIControlStateNormal];
    [button_setDes setImage:IMAGE(@"PopPOISetDes.png", IMAGEPATH_TYPE_2) forState:UIControlStateNormal];
    [button_setDes setImageEdgeInsets:UIEdgeInsetsMake(9., 4., 10., 52.)];
    [button_setDes addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    button_setDes.tag = ViewPOIButtonType_setDes;
    [POIHandleBackground addSubview:button_setDes];
    
    button_setStart = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_setStart setFrame:CGRectMake(button_setDes.frame.size.width, 0.0, 68.0, 36.0)];
    [button_setStart setTitleColor:POPPOI_COLOR forState:UIControlStateNormal];
    [button_setStart addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    button_setStart.tag = ViewPOIButtonType_setStart;
    [POIHandleBackground addSubview:button_setStart];
    
    button_around   = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_around setFrame:CGRectMake(button_setDes.frame.size.width + COLLENT_LEFT_YINYING, 0.0, 80.0, 36.0)];
    button_around.titleLabel.font = [UIFont systemFontOfSize:12.0];
    [button_around setTitle:STR(@"Main_periphery", Localize_Main) forState:UIControlStateNormal];
    [button_around setTitleColor:POPPOI_COLOR forState:UIControlStateNormal];
    [button_around setImage:IMAGE(@"PopPOIAround.png", IMAGEPATH_TYPE_2) forState:UIControlStateNormal];
    [button_around setImageEdgeInsets:UIEdgeInsetsMake(9., 13., 9., 49.)];
    [button_around addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    button_around.tag = ViewPOIButtonType_around;
    [POIHandleBackground addSubview:button_around];
    
    button_more     = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_more setFrame:CGRectMake(button_setDes.frame.size.width+button_around.frame.size.width+ COLLENT_LEFT_YINYING, 0.0, 70.0, 36.0)];
    [button_more setTitleColor:POPPOI_COLOR forState:UIControlStateNormal];
    [button_more setImage:IMAGE(FavoriteImage_NoCollect, IMAGEPATH_TYPE_2) forState:UIControlStateNormal];
    [button_more setTitle:STR(@"Main_collect", Localize_Main) forState:UIControlStateNormal];
    [button_more setTitleColor:POPPOI_COLOR forState:UIControlStateNormal];
    button_more.titleLabel.font = [UIFont systemFontOfSize:12.0];
    [button_more setImageEdgeInsets:UIEdgeInsetsMake(0.0f, -5.0f,0, 0)];
    [button_more addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    button_more.tag = ViewPOIButtonType_collect;
    [POIHandleBackground addSubview:button_more];
    
    
    //更多下分享按钮
    shareBackground = [[UIImageView alloc] init];
    [shareBackground setFrame:CGRectMake(0.0, 35.0, FRAME_WIDTH, 90.0)];
    [text_view addSubview:shareBackground];
    [shareBackground release];
    
    //添加常用弹出框控件
    addCommonBackground = [[UIView alloc] initWithFrame:CGRectMake(0.0, 35.0, FRAME_WIDTH, 90.0)];
    [text_view addSubview:addCommonBackground];
    [addCommonBackground release];
    
    UILabel *labelCommon = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 8.0, 40.0, 20.0)];
    [labelCommon setBackgroundColor:[UIColor clearColor]];
    labelCommon.font = [UIFont systemFontOfSize:15.0];
    [labelCommon setText:STR(@"Universal_remark", Localize_Universal)];
    [addCommonBackground addSubview:labelCommon];
    [labelCommon release];
    
    textFieldName = [[UITextField alloc] initWithFrame:CGRectMake(44.0, 3.0, FRAME_WIDTH-55.0, 32.0)];
    textFieldName.delegate = self;
    textFieldName.backgroundColor = [UIColor clearColor];
    textFieldName.textColor = POPPOI_COLOR;
    textFieldName.borderStyle = UITextBorderStyleRoundedRect;
    textFieldName.autocorrectionType = UITextAutocorrectionTypeNo;
    textFieldName.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textFieldName.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    textFieldName.keyboardType = UIKeyboardTypeDefault;
    textFieldName.returnKeyType = UIReturnKeyDone;
    textFieldName.clearButtonMode = UITextFieldViewModeWhileEditing;
    UILabel *fieldLabel = [[UILabel alloc] initWithFrame:CGRectMake(0., 0., 20., 20.)];
    fieldLabel.text = STR(@"Universal_go", Localize_Universal);
    fieldLabel.backgroundColor = [UIColor clearColor];
    fieldLabel.font = [UIFont systemFontOfSize:15.];
   // UIView *fieldView = [[UIView alloc] initWithFrame:CGRectMake(0., 0., 20., 20.)];
    textFieldName.leftView = fieldLabel;
    textFieldName.leftViewMode = UITextFieldViewModeAlways;
    [addCommonBackground addSubview:textFieldName];
    [fieldLabel release];
    [textFieldName release];
    
    button_save = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_save setBackgroundColor:[UIColor clearColor]];
    [button_save setBackgroundImage:imageBackground1 forState:UIControlStateNormal];
    [button_save setBackgroundImage:imageBackground2 forState:UIControlStateHighlighted];
    [button_save setFrame:CGRectMake(10.0, 40.0, FRAME_WIDTH/2.0-15.0, 34.0)];
    [button_save setTitle:STR(@"Universal_save", Localize_Universal) forState:UIControlStateNormal];
    button_save.titleLabel.font = [UIFont systemFontOfSize:18.0];
    [button_save setTitleColor:TITLECOLOR forState:UIControlStateNormal];
    [button_save addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    button_save.tag = ViewPOIButtonType_save;
    [addCommonBackground addSubview:button_save];
    
    button_cancel = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_cancel setBackgroundColor:[UIColor clearColor]];
    [button_cancel setBackgroundImage:imageBackground1 forState:UIControlStateNormal];
    [button_cancel setBackgroundImage:imageBackground2 forState:UIControlStateHighlighted];
    [button_cancel setFrame:CGRectMake(button_save.frame.size.width+ 20.0, 40.0, FRAME_WIDTH/2.0-15.0, 34.0)];
    [button_cancel setTitle:STR(@"Universal_cancel", Localize_Universal) forState:UIControlStateNormal];
    button_cancel.titleLabel.font = [UIFont systemFontOfSize:18.0];
    [button_cancel setTitleColor:TITLECOLOR forState:UIControlStateNormal];
    [button_cancel addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    button_cancel.tag = ViewPOIButtonType_cancel;
    [addCommonBackground addSubview:button_cancel];
    
    //点击事件图标控件创建
    _blockerView = [[UIView alloc] initWithFrame:CGRectZero];
    _blockerView.backgroundColor = GETSKINCOLOR(CONTROL_BACKGROUND_COLOR);
    _blockerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _blockerView.userInteractionEnabled = YES;
//    [MainWindow addSubview: _blockerView];
    _blockerView.alpha = 0.7;
    _blockerView.hidden = YES;
    
    viewTrafficBackground = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, text_view.frame.size.width,text_view.frame.size.height)];
    [text_view addSubview:viewTrafficBackground];
    [viewTrafficBackground release];viewTrafficBackground.hidden = YES;
    
    imageViewTrafficIcon = [[UIImageView alloc] initWithFrame:CGRectMake(10., 4., 26., 34.)] ;
    [viewTrafficBackground addSubview:imageViewTrafficIcon];
    [imageViewTrafficIcon release];
    imageViewTrafficIcon.hidden = YES;//add by hlf for 实时交通图标暂且隐藏 at 2014.08.04
    
    labelTrafficType = [[UILabel alloc] initWithFrame:CGRectMake(10., 10., 120., 20.)];
    [labelTrafficType setTextColor:POPPOI_TRAFFIC_COLOR];
    labelTrafficDetail.font = [UIFont systemFontOfSize:15.0];
    [labelTrafficType setBackgroundColor:[UIColor clearColor]];
    [labelTrafficType setTextAlignment:NSTextAlignmentLeft];
    [viewTrafficBackground addSubview:labelTrafficType];
    [labelTrafficType release];
    
    labelTrafficDetail = [[UILabel alloc] initWithFrame:CGRectMake(10., 35., text_view.frame.size.width-10., 50.)];
    [labelTrafficDetail setTextColor:POPPOI_TRAFFIC_COLOR];
    labelTrafficDetail.font = [UIFont systemFontOfSize:13.0];
    [labelTrafficDetail setBackgroundColor:[UIColor clearColor]];
    [labelTrafficDetail setTextAlignment:NSTextAlignmentLeft];
    labelTrafficDetail.numberOfLines = 2;
    [viewTrafficBackground addSubview:labelTrafficDetail];
    [labelTrafficDetail release];
    
    
    button_close = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_close setBackgroundColor:[UIColor clearColor]];
    [button_close setBackgroundImage:imageBackground1 forState:UIControlStateNormal];
    [button_close setBackgroundImage:imageBackground2 forState:UIControlStateHighlighted];
    [button_close setFrame:CGRectMake(10., 83.0, FRAME_WIDTH/2.0-15.0, 34.0)];
    [button_close setTitle:STR(@"Main_close", Localize_Main) forState:UIControlStateNormal];
    button_close.titleLabel.font = [UIFont boldSystemFontOfSize:12.0];
    [button_close setTitleColor:POPPOI_CLOSE_COLOR forState:UIControlStateNormal];
    [button_close addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    button_close.tag = ViewPOIButtonType_close;
    [viewTrafficBackground addSubview:button_close];
    
    button_avoid = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_avoid setBackgroundColor:[UIColor clearColor]];
    [button_avoid setBackgroundImage:imageBackground3 forState:UIControlStateNormal];
    [button_avoid setBackgroundImage:imageBackground4 forState:UIControlStateHighlighted];
    [button_avoid setFrame:CGRectMake(FRAME_WIDTH/2.0 + 5., 83.0, FRAME_WIDTH/2.0-12.0, 34.0)];
    [button_avoid setTitle:STR(@"Main_avoidRoute", Localize_Main) forState:UIControlStateNormal];
    button_avoid.titleLabel.font = [UIFont boldSystemFontOfSize:12.0];
    [button_avoid setTitleColor:GETSKINCOLOR(@"PopPoiAvoidColor") forState:UIControlStateNormal];
    [button_avoid addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    button_avoid.tag = ViewPOIButtonType_avoidRoute;
    [viewTrafficBackground addSubview:button_avoid];
    
    button_timeCount = [BottomButton buttonWithType:UIButtonTypeCustom];
   
    [button_timeCount setBackgroundColor:[UIColor clearColor]];
    [button_timeCount setBackgroundImage:IMAGE(@"timeCount1.png", IMAGEPATH_TYPE_2) forState:UIControlStateNormal];
    [button_timeCount setFrame:CGRectMake(button_close.frame.size.width-25., 6.0, 21., 21.)];
    button_timeCount.imageRect =  button_timeCount.bounds;
    button_timeCount.textRightsetValue = 7;
    [button_timeCount setTitle:@"9" forState:UIControlStateNormal];
    button_timeCount.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [button_timeCount setTitleColor:GETSKINCOLOR(@"PopPoiTimeCountColor") forState:UIControlStateNormal];
    button_timeCount.userInteractionEnabled = NO;
    [button_close addSubview:button_timeCount];
    
    //设途径点控件创建
    button_setPassby = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_setPassby setFrame:CGRectMake(FRAME_WIDTH - 90., 0.0, 88.0, 38.0)];
    button_setPassby.titleLabel.font = [UIFont systemFontOfSize:12.0];
    [button_setPassby setTitle:STR(@"Main_setAsPassBy", Localize_Main) forState:UIControlStateNormal];
    [button_setPassby setTitleColor:POPPOI_COLOR forState:UIControlStateNormal];
    [button_setPassby setImage:IMAGE(@"PopPOISetPassby.png", IMAGEPATH_TYPE_2) forState:UIControlStateNormal];
    [button_setPassby setImageEdgeInsets:UIEdgeInsetsMake(9., 4., 10., 62.)];
    [button_setPassby addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    button_setPassby.tag = ViewPOIButtonType_passBy;
    [text_view addSubview:button_setPassby];button_setPassby.hidden = YES;
    
    //地图选点设终点控件创建
    button_selectPOISetDes = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_selectPOISetDes setFrame:CGRectMake(FRAME_WIDTH - 90., 2.0, 90.0, 36.0)];
    button_selectPOISetDes.titleLabel.font = [UIFont systemFontOfSize:12.0];
    [button_selectPOISetDes setTitle:STR(@"Main_setAsDestination", Localize_Main) forState:UIControlStateNormal];
    [button_selectPOISetDes setTitleColor:POPPOI_COLOR forState:UIControlStateNormal];
    [button_selectPOISetDes setImage:IMAGE(@"PopPOISetDes.png", IMAGEPATH_TYPE_2) forState:UIControlStateNormal];
    [button_selectPOISetDes setImageEdgeInsets:UIEdgeInsetsMake(9., 4., 10., 62.)];
    [button_selectPOISetDes addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    button_selectPOISetDes.tag = ViewPOIButtonType_selectPOISetDes;
    [text_view addSubview:button_selectPOISetDes];button_selectPOISetDes.hidden = YES;
    
    UIImage *gradientHLine = [IMAGE(@"landscapeGrayLine.png", IMAGEPATH_TYPE_2) stretchableImageWithLeftCapWidth:1 topCapHeight:1];
    UIImage *gradientVLine = [IMAGE(@"portraitGrayline.png", IMAGEPATH_TYPE_2) stretchableImageWithLeftCapWidth:0 topCapHeight:0];
    //横线195
    gradientHView = [[UIImageView alloc] initWithImage:gradientHLine];
    gradientHView.frame = (CGRect){2.5, COLLECT_HEIGHT - 2, (CGSize){FRAME_WIDTH-5.0f ,2}};
   // gradientHView.contentMode = UIViewContentModeLeft;
    [text_view addSubview:gradientHView];
    [gradientHView release];
    
    
    //竖线
    lineView_1 = [[UIImageView alloc] initWithImage:gradientVLine];
    lineView_1.frame = (CGRect){80.0, 5.0, 2.0,25.0};
    //lineView_1.contentMode = UIViewContentModeLeft;
    [POIHandleBackground addSubview:lineView_1];
    [lineView_1 release];
    
    lineView_2 = [[UIImageView alloc] initWithImage:gradientVLine];
    lineView_2.frame = (CGRect){160.0, 5.0, (CGSize){2 ,25.0}};
    //lineView_2.contentMode = UIViewContentModeLeft;
    [POIHandleBackground addSubview:lineView_2];
    [lineView_2 release];
    
//    UIImageView *lineView_3 = [[UIImageView alloc] initWithImage:gradientVLine];
//    lineView_3.frame = (CGRect){220.0, 5.0, (CGSize){2 ,25.0}};
//    //lineView_3.contentMode = UIViewContentModeLeft;
//    [POIHandleBackground addSubview:lineView_3];
//    [lineView_3 release];lineView_3.hidden = YES;
    
    lineAddress = [[UIImageView alloc] initWithImage:gradientVLine];
    lineAddress.frame = (CGRect){FRAME_WIDTH - 90., 9.0, (CGSize){2 ,25.0}};
   // lineAddress.contentMode = UIViewContentModeLeft;
    [text_view addSubview:lineAddress];
    [lineAddress release];lineAddress.hidden = YES;
    
    //目的地周边按钮创建
    viewDesAroundBackground = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, text_view.frame.size.width,text_view.frame.size.height)];
    [text_view addSubview:viewDesAroundBackground];
    [viewDesAroundBackground release];viewDesAroundBackground.hidden = YES;
    
    labelDesAroundName = [[UILabel alloc] init];
    [labelDesAroundName setFont:[UIFont boldSystemFontOfSize:16.0]];
    [labelDesAroundName setTextColor:POPPOI_TITLE_COLOR];
    [labelDesAroundName setBackgroundColor:[UIColor clearColor]];
    [labelDesAroundName setTextAlignment:NSTextAlignmentLeft];
    [viewDesAroundBackground addSubview:labelDesAroundName];
    [labelDesAroundName release];
    
    labelDesAroundAddress = [[UILabel alloc] init];
    [labelDesAroundAddress setFont:[UIFont systemFontOfSize:12.0]];
    [labelDesAroundAddress setTextColor:POPPOI_COLOR];
    [labelDesAroundAddress setBackgroundColor:[UIColor clearColor]];
    [labelDesAroundAddress setTextAlignment:NSTextAlignmentLeft];
    [viewDesAroundBackground addSubview:labelDesAroundAddress];
    [labelDesAroundAddress release];
    
    colorLabelDesAroundDisToDes = [[ColorLable alloc]initWithFrame:CGRectMake(20, 295,50,25.) ColorArray:[NSArray arrayWithObject:[UIColor redColor]]];
    colorLabelDesAroundDisToDes.backgroundColor = [UIColor clearColor];
    colorLabelDesAroundDisToDes.font = [UIFont systemFontOfSize:12.];
    colorLabelDesAroundDisToDes.textAlignment = NSTextAlignmentLeft;
    [colorLabelDesAroundDisToDes setTextColor:POPPOI_COLOR];
    [viewDesAroundBackground addSubview:colorLabelDesAroundDisToDes];
    [colorLabelDesAroundDisToDes release];
    
    lineView_desAround = [[UIImageView alloc] initWithImage:gradientVLine];
    lineView_desAround.frame = (CGRect){FRAME_WIDTH - 70., 22.0, (CGSize){2 ,40.0}};
    [viewDesAroundBackground addSubview:lineView_desAround];
    [lineView_desAround release];
    
    button_desAroundSetDes = [UIButton buttonWithType:UIButtonTypeCustom];
    [button_desAroundSetDes setFrame:CGRectMake(FRAME_WIDTH - 74., 5.0, 70.0, 70.)];
    button_desAroundSetDes.titleLabel.font = [UIFont systemFontOfSize:12.0];
    button_desAroundSetDes.titleLabel.textAlignment = UITextAlignmentCenter;
    [button_desAroundSetDes setTitle:STR(@"Main_setAsDestination", Localize_Main) forState:UIControlStateNormal];
    [button_desAroundSetDes setTitleColor:POPPOI_COLOR forState:UIControlStateNormal];
    [button_desAroundSetDes setImage:IMAGE(@"PopPOISetDes.png", IMAGEPATH_TYPE_2) forState:UIControlStateNormal];
    
    CGSize imageSize = IMAGE(@"PopPOISetDes.png", IMAGEPATH_TYPE_2).size;
//    UIEdgeInsets insets = {top, left, bottom, right};
    [button_desAroundSetDes setImageEdgeInsets:UIEdgeInsetsMake(19., 24., 29., 24.)];
    button_desAroundSetDes.titleEdgeInsets = UIEdgeInsetsMake(10, -imageSize.width, -imageSize.height, 0);
    
    [button_desAroundSetDes addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    button_desAroundSetDes.tag = ViewPOIButtonType_desAroundSetDes;
    [viewDesAroundBackground addSubview:button_desAroundSetDes];
    
    [self setPopPOIFrame];
    
    [self setButtonHighlight];
    //设置白天黑夜颜色
    if([[MWPreference sharedInstance] getValue:PREF_DAYNIGHTMODE] == 1)
    {
        [self setDayAndNightTextColor:1];
    }
    else
    {
        [self setDayAndNightTextColor:0];
    }


}

- (void) setButtonHighlight
{
    [self setButtonHighlightBackground:button_collect];
    [self setButtonHighlightBackground:button_setStart];
    [self setButtonHighlightBackground:button_setDes];
    [self setButtonHighlightBackground:button_around];
    [self setButtonHighlightBackground:button_more];
    [self setButtonHighlightBackground:button_save];
    [self setButtonHighlightBackground:button_cancel];
    [self setButtonHighlightBackground:button_close];
    [self setButtonHighlightBackground:button_setPassby];
    [self setButtonHighlightBackground:button_avoid];
    [self setButtonHighlightBackground:button_selectPOISetDes];
    [self setButtonHighlightBackground:button_desAroundSetDes];
}

- (void) setButtonHighlightBackground:(UIButton *) button
{
    UIImage *bcImage = IMAGE(@"poiButtonPress.png", IMAGEPATH_TYPE_2);
    [button setBackgroundImage:[bcImage stretchableImageWithLeftCapWidth:bcImage.size.width / 2 topCapHeight:bcImage.size.height/ 2]
                      forState:UIControlStateHighlighted];
}

-(void)setStringAtPos:(MWPoi *)poiItem withMapType:(GMAPVIEWTYPE)mapViewType
{
    
    
    if (GDBL_CheckRecognizeType(EVENT_PAN) ||  GDBL_CheckRecognizeType(EVENT_PAN_MOVE)) {
        return;
    }
    
    [self setButtonHidden];
    
    self.curPOI = poiItem;
    self.curMapViewType = mapViewType;
    
    self.favoriteState = [MWPoiOperator isCollect:self.curPOI]; //设置收藏点状态
    [self setFavoriteState:self.favoriteState];
    
    GCOORD poiCoord = {0};
    
    
    GMAPVIEWINFO mapCenter = {0};
    [[MWMapOperator sharedInstance] MW_GetMapViewInfo:mapViewType MapViewInfo:&mapCenter];
    
    
    if (((self.curPOI.longitude != mapCenter.MapCenter.x || self.curPOI.latitude != mapCenter.MapCenter.y) && self.curPOI.longitude != 0 && self.curPOI.latitude != 0)
        ) {
        
        GMOVEMAP moveMap;
        moveMap.eOP = MOVEMAP_OP_GEO_DIRECT;
        moveMap.deltaCoord.x = self.curPOI.longitude;
        moveMap.deltaCoord.y = self.curPOI.latitude;
        [[MWMapOperator sharedInstance] MW_MoveMapView:mapViewType TypeAndCoord:&moveMap];
    }
    
    
    GCOORD geoCoord = {0};
    geoCoord.x = self.curPOI.longitude;
    geoCoord.y = self.curPOI.latitude;
    GFCOORD coord_temp = [MWEngineTools GeoToScr:geoCoord];
    poiCoord.x = coord_temp.x;
    poiCoord.y = coord_temp.y;
    
    CGPoint poiPoint;
    poiPoint.x = poiCoord.x;
	poiPoint.y = poiCoord.y - text_view.frame.size.height*0.5f;
	
	[text_view setCenter:poiPoint];
	
	labelPOIName.text = self.curPOI.szName;
    labelAddress.text = self.curPOI.szAddr;
    labelDesAroundName.text = self.curPOI.szName;
    labelDesAroundAddress.text = self.curPOI.szAddr;
    if (self.curPOI.lDistance > 1000) {
        labelDistance.text = [NSString stringWithFormat:@"%fkm",self.curPOI.lDistance/1000.0];
        
        colorLabelDesAroundDisToDes.text = [NSString stringWithFormat:STR(@"Main_ParkingDistance", Localize_Main),self.curPOI.lDistance/1000,@"km"];
    }
    else{
        labelDistance.text = [NSString stringWithFormat:@"%dm",self.curPOI.lDistance];
        colorLabelDesAroundDisToDes.text = [NSString stringWithFormat:STR(@"Main_ParkingDistance", Localize_Main),self.curPOI.lDistance,@"m"];
    }
    
    if (viewPOIType == ViewPOIType_Traffic || viewPOIType == ViewPOIType_TrafficNoArrow) {
        
        if (self.curPOI.usNodeId == 2 || self.curPOI.usNodeId == 3) {
            [imageViewTrafficIcon setImage:IMAGE(@"TrafficIcon_4.png", IMAGEPATH_TYPE_2)];
        }
        else if(self.curPOI.usNodeId == 4 || self.curPOI.usNodeId == 5)
        {
            [imageViewTrafficIcon setImage:IMAGE(@"TrafficIcon_5.png", IMAGEPATH_TYPE_2)];
        }
        else if (self.curPOI.usNodeId == 33)
        {
            [imageViewTrafficIcon setImage:IMAGE(@"TrafficIcon_21.png", IMAGEPATH_TYPE_2)];
        }
        else if (self.curPOI.usNodeId == 34)
        {
            [imageViewTrafficIcon setImage:IMAGE(@"TrafficIcon_22.png", IMAGEPATH_TYPE_2)];
        }
        else if (self.curPOI.usNodeId == 35)
        {
            [imageViewTrafficIcon setImage:IMAGE(@"TrafficIcon_23.png", IMAGEPATH_TYPE_2)];
        }
        else if (self.curPOI.usNodeId == 36)
        {
            [imageViewTrafficIcon setImage:IMAGE(@"TrafficIcon_24.png", IMAGEPATH_TYPE_2)];
        }
        else if (self.curPOI.usNodeId == 37)
        {
            [imageViewTrafficIcon setImage:IMAGE(@"TrafficIcon_25.png", IMAGEPATH_TYPE_2)];
        }
        else if (self.curPOI.usNodeId == 38)
        {
            [imageViewTrafficIcon setImage:IMAGE(@"TrafficIcon_26.png", IMAGEPATH_TYPE_2)];
        }
        else if (self.curPOI.usNodeId == 39)
        {
            [imageViewTrafficIcon setImage:IMAGE(@"TrafficIcon_27.png", IMAGEPATH_TYPE_2)];
        }
    
        if (self.curPOI.szName && [self.curPOI.szName length] > 0) {
            labelTrafficType.text = self.curPOI.szName;
        }
        else{
            labelTrafficType.text = @"";
        }
        if (self.curPOI.szAddr && [self.curPOI.szAddr length] > 0) {
            NSString *roadName;
            GMAPCENTERINFO centerInfo = {0};
            [[MWMapOperator sharedInstance] MW_GetMapViewCenterInfo:mapViewType mapCenterInfo:&centerInfo];
            
            roadName = [NSString chinaFontStringWithCString:centerInfo.szRoadName];
            if (!roadName || [roadName length] == 0) {
                roadName = STR(@"Main_unNameRoad", Localize_Main);
            }
            
            if (self.curPOI.usNodeId > 20)
            {
                labelTrafficDetail.text = [NSString stringWithFormat:STR(@"TMC_eventInfo", Localize_TMC),self.curPOI.szTown,roadName,labelTrafficType.text];
            }
            else{
                labelTrafficDetail.text = self.curPOI.szAddr;
            }
            
        }
        else{
            labelTrafficDetail.text = @"";
        }
        _iTimeCount = 10;
        
        if (timerClose != nil)
        {
            [timerClose invalidate];
            timerClose = nil;
        }
        timerClose = [NSTimer scheduledTimerWithTimeInterval:1.f
                                                      target:self
                                                    selector:@selector(closePopPOIView:)
                                                    userInfo:nil
                                                     repeats:YES];
        [timerClose fire];
    }
    if (viewPOIType == ViewPOIType_TrafficNoArrow || viewPOIType == ViewPOIType_Traffic) {
        if (viewPOIType == ViewPOIType_TrafficNoArrow) {
            [self setViewFrame];
            
        }
        
        [topView addSubview:_blockerView];
        [topView addSubview:text_view];
    }
    else{
        [topView addSubview:text_view];
    }
    
	
}

- (void)movePOIViewWithPoint
{
    if (GDBL_CheckRecognizeType(EVENT_PAN) ||  GDBL_CheckRecognizeType(EVENT_PAN_MOVE)) {
        return;
    }
    GCOORD poiCoord;
    
    GCOORD geoCoord = {0};
    geoCoord.x = self.curPOI.longitude;
    geoCoord.y = self.curPOI.latitude;
    GFCOORD coord_temp = [MWEngineTools GeoToScr:geoCoord];
    poiCoord.x = coord_temp.x;
    poiCoord.y = coord_temp.y;
    
    CGPoint poiPoint;
    poiPoint.x = poiCoord.x;
	poiPoint.y = poiCoord.y - text_view.bounds.size.height*0.5f;
    if ((poiPoint.x > 0) && (poiCoord.y > 0)) {
        [text_view setCenter:poiPoint];
    }
    else{
        [self setHidden:YES];
    }
	
    
    if (viewPOIType == ViewPOIType_TrafficNoArrow || viewPOIType == ViewPOIType_Traffic) {
        NSArray  *windows = [UIApplication sharedApplication].windows;
        UIWindow *window = [windows objectAtIndex:0];
        CGSize windowSize = window.rootViewController.view.bounds.size;
        
        [_blockerView setFrame:CGRectMake(0.0, 0.0, windowSize.width, windowSize.height)];
    }
    
}

- (void)movePOIViewWithCenter:(CGPoint)center
{
    CGPoint poiPoint;
    poiPoint.x = center.x;
	poiPoint.y = center.y - text_view.bounds.size.height*0.5f;
    
	[text_view setCenter:poiPoint];
}

-(void)setHidden:(BOOL)isHidden
{
    if (GDBL_CheckRecognizeType(EVENT_PAN) ||  GDBL_CheckRecognizeType(EVENT_PAN_MOVE)) {
        return;
    }
	text_view.hidden = isHidden;
    if (viewPOIType == ViewPOIType_TrafficNoArrow || viewPOIType == ViewPOIType_Traffic) {
        _blockerView.hidden = isHidden;
        
    }
    else{
        _blockerView.hidden = YES;
    }
    if (isHidden == YES)
    {
        if (timerClose)
        {
            [timerClose invalidate];
            timerClose = nil;
        }
    }
}

- (void)setFavorite
{
    self.favoriteState = [MWPoiOperator isCollect:self.curPOI];
    [self setPopPOIText];
    
}
- (void)setPopPOIType:(ViewPOIType)viewType
{
    viewPOIType = viewType;
    [self setPopPOIFrame];
    [self setPopPOIText];
}

- (BOOL)getHidden
{
    return text_view.hidden;
}

- (BOOL)getShowState
{
    return isShow;
}

- (MWPoi *)getPopPOIData
{
    return curPOI;
}

- (void)buttonAction:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    if (button.tag == ViewPOIButtonType_save){
        if (textFieldName.text && [textFieldName.text length] > 0) {
            curPOI.szName = textFieldName.text;
        }
        
        [self setHidden:YES];
    }
    else if (button.tag == ViewPOIButtonType_collect || button.tag == ViewPOIButtonType_more || button.tag == ViewPOIButtonType_around){
        
    }
    else{
        [self setHidden:YES];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(GDPopViewTaped:POI:)]) {
        [self.delegate GDPopViewTaped:sender POI:curPOI];
    }
    
}
#pragma mark pritate

- (void)moreButtonClick
{
    float shareBackgroundHeigth = 0.0;
    if (self.curPOI.szTel && [self.curPOI.szTel length] > 0) {
        shareBackgroundHeigth = 90.0;
    }
    else{
        shareBackgroundHeigth = 50.0;
    }
    
    if (shareBackground.hidden == YES) {
        
        shareBackground.alpha = 0.0;
        [shareBackground setFrame:CGRectMake(0.0, 85.0, FRAME_WIDTH, 0.0)];
        [UIView animateWithDuration:0.4f animations:^
         {
             
             shareBackground.alpha = 1.0;
             [shareBackground setFrame:CGRectMake(0.0, 85.0, FRAME_WIDTH, shareBackgroundHeigth)];
             [text_view setFrame:CGRectMake(20.0, text_view.frame.origin.y-shareBackgroundHeigth, FRAME_WIDTH, FRAME_HEIGHT + shareBackgroundHeigth)];
             [text_view setNeedsDisplay];
             
         }
                         completion:^(BOOL finished)
         {
             shareBackground.hidden = NO;
             
         }];
    }
    else{
        shareBackground.hidden = YES;
        shareBackground.alpha = 1.0;
        [UIView animateWithDuration:0.4f animations:^
         {
             shareBackground.alpha = 0.0;
             [shareBackground setFrame:CGRectMake(0.0, 85.0, FRAME_WIDTH, 0.0)];
             [text_view setFrame:CGRectMake(20.0, text_view.frame.origin.y+shareBackgroundHeigth , FRAME_WIDTH, FRAME_HEIGHT)];
             [text_view setNeedsDisplay];
             
         }
                         completion:^(BOOL finished)
         {
             
             
         }];
    }
    
}

- (void)setButtonHidden
{
    switch (viewPOIType) {
        case ViewPOIType_Normal:
        {
            labelPOIName.hidden = NO;
            POIHandleBackground.hidden = YES;
            shareBackground.hidden = YES;
            addCommonBackground.hidden = YES;
            button_collect.hidden = YES;
            gradientHView.hidden = YES;
            lineAddress.hidden = YES;
            button_setPassby.hidden = YES;
            button_selectPOISetDes.hidden = YES;
            viewTrafficBackground.hidden = YES;
            viewDesAroundBackground.hidden = YES;
        }
            break;
        case ViewPOIType_Common:
        {
            labelPOIName.hidden = YES;
            POIHandleBackground.hidden = YES;
            shareBackground.hidden = YES;
            addCommonBackground.hidden = NO;
            button_collect.hidden = YES;
            gradientHView.hidden = NO;
            lineAddress.hidden = YES;
            button_setPassby.hidden = YES;
            button_selectPOISetDes.hidden = YES;
            viewTrafficBackground.hidden = YES;
            viewDesAroundBackground.hidden = YES;
        }
            break;
        case ViewPOIType_Detail:
        {
            POIHandleBackground.hidden = NO;
            shareBackground.hidden = YES;
            addCommonBackground.hidden = YES;
            gradientHView.hidden = NO;
            lineAddress.hidden = YES;
            button_setPassby.hidden = YES;
            button_selectPOISetDes.hidden = YES;
            button_collect.hidden = NO;
            viewTrafficBackground.hidden = YES;
            labelPOIName.hidden = NO;
            viewDesAroundBackground.hidden = YES;
        }
            break;
        case ViewPOIType_TrafficNoArrow:
        case ViewPOIType_Traffic:
        {
            POIHandleBackground.hidden = YES;
            shareBackground.hidden = YES;
            addCommonBackground.hidden = YES;
            button_collect.hidden = YES;
            labelPOIName.hidden = YES;
            viewTrafficBackground.hidden = NO;
            lineAddress.hidden = YES;
            gradientHView.hidden = NO;
            button_setPassby.hidden = YES;
            button_selectPOISetDes.hidden = YES;
            if ([ANParamValue sharedInstance].isPath) {
                button_avoid.hidden = NO;
            }
            else{
                button_avoid.hidden = YES;
            }
            viewDesAroundBackground.hidden = YES;
        }
            break;
        case ViewPOIType_passBy:
        {
            POIHandleBackground.hidden = YES;
            shareBackground.hidden = YES;
            addCommonBackground.hidden = YES;
            button_collect.hidden = YES;
            labelPOIName.hidden = NO;
            viewTrafficBackground.hidden = YES;
            button_setPassby.hidden = NO;
            lineAddress.hidden = NO;
            gradientHView.hidden = YES;
            button_selectPOISetDes.hidden = YES;
            viewDesAroundBackground.hidden = YES;
        }
            break;
        case ViewPOIType_SelectPOI:
        {
            POIHandleBackground.hidden = YES;
            shareBackground.hidden = YES;
            addCommonBackground.hidden = YES;
            button_collect.hidden = YES;
            labelPOIName.hidden = NO;
            viewTrafficBackground.hidden = YES;
            button_setPassby.hidden = YES;
            lineAddress.hidden = NO;
            gradientHView.hidden = YES;
            button_selectPOISetDes.hidden = NO;
            viewDesAroundBackground.hidden = YES;
        }
            break;
        case ViewPOIType_desAround:
        {
            POIHandleBackground.hidden = YES;
            shareBackground.hidden = YES;
            addCommonBackground.hidden = YES;
            button_collect.hidden = YES;
            labelPOIName.hidden = YES;
            viewTrafficBackground.hidden = YES;
            lineAddress.hidden = YES;
            gradientHView.hidden = YES;
            button_setPassby.hidden = YES;
            button_selectPOISetDes.hidden = YES;
            viewDesAroundBackground.hidden = NO;
        }
            break;
        default:
            break;
    }
}
- (void)setDesEnable:(BOOL)enable
{
    button_setDes.enabled = enable;
}

- (void)setFavoriteState:(BOOL)_favoriteState
{
    favoriteState = _favoriteState;
    UIImage *m_Image = favoriteState ? IMAGE(FavoriteImage_Collect, IMAGEPATH_TYPE_2) : IMAGE(FavoriteImage_NoCollect, IMAGEPATH_TYPE_2);
    [button_more setImage:m_Image forState:UIControlStateNormal];
}

- (void)setPopPOIFrame
{
    if (viewPOIType == ViewPOIType_Common ) {
        [text_view setFrame:CGRectMake(0, 0, FRAME_WIDTH, FRAME_HEIGHT+40)];
    }
    else if(viewPOIType == ViewPOIType_Detail ){
        [text_view setFrame:CGRectMake(0, 0, FRAME_WIDTH, FRAME_HEIGHT)];
    }
    else if(viewPOIType == ViewPOIType_Traffic || viewPOIType == ViewPOIType_TrafficNoArrow)
    {
        [text_view setFrame:CGRectMake(0, 0, FRAME_WIDTH, FRAME_HEIGHT+50.)];
    }
    else if (viewPOIType == ViewPOIType_desAround)
    {
        [text_view setFrame:CGRectMake(0, 0, FRAME_WIDTH, FRAME_HEIGHT)];
    }
    else{
        [text_view setFrame:CGRectMake(0, 0, FRAME_WIDTH, 46)];
    }
    
    
    int total_width = text_view.frame.size.width;
    int total_height = text_view.frame.size.height;
    float center_pos = 0.5f;
    
	
	[back_left setFrame:CGRectMake(0.0f, 0.0f, total_width * center_pos - CENTERWIDTH/2, total_height)];
	[back_left setImage:[ IMAGE(@"poiLeft.png", IMAGEPATH_TYPE_2) stretchableImageWithLeftCapWidth:5 topCapHeight:10]];
    
	[back_center setFrame:CGRectMake(total_width * center_pos - CENTERWIDTH/2, 0.0f,CENTERWIDTH, total_height)];
	[back_center setImage:[ IMAGE(@"poiCenter.png", IMAGEPATH_TYPE_2)stretchableImageWithLeftCapWidth:22 topCapHeight:10]];
	
	
	[back_right setFrame:CGRectMake(total_width * center_pos + CENTERWIDTH/2, 0.0f, total_width * center_pos - CENTERWIDTH/2, total_height)];
	[back_right setImage:[IMAGE(@"poiRight.png", IMAGEPATH_TYPE_2) stretchableImageWithLeftCapWidth:4 topCapHeight:10]];
    
    if (viewPOIType == ViewPOIType_passBy || viewPOIType == ViewPOIType_SelectPOI) {
        [labelPOIName setFrame:CGRectMake(3.0f, 3.0f, FRAME_WIDTH-94.0, 38.0)];
    }
    else if (viewPOIType == ViewPOIType_Normal){
        
        [labelPOIName setFrame:CGRectMake(10.0f, 0.0f, FRAME_WIDTH-60.0, 30.0)];
        [labelPOIName setCenter:CGPointMake(107, 22.0)];
    }
    else{
        [labelPOIName setFrame:CGRectMake(10.0f, 0.0f, FRAME_WIDTH-60.0, 35.0)];
        [labelPOIName setCenter:CGPointMake(107, 21.0)];
    }
    
    [labelAddress setFrame:CGRectMake(10.0, 25.0, text_view.bounds.size.width-40.0, 30.0)];
    [labelDistance setFrame:CGRectMake(FRAME_WIDTH-110.0, 5.0, 100.0,  30.0)];
        [button_collect setFrame:CGRectMake(COLLENT_LEFT_YINYING, COLLECT_TOP_YINYING, text_view.frame.size.width - 2 * COLLENT_LEFT_YINYING, COLLECT_HEIGHT - COLLECT_TOP_YINYING)];
    [POIHandleBackground setFrame:CGRectMake(0.0, COLLECT_HEIGHT, FRAME_WIDTH, 36.0)];
    [button_around setFrame:CGRectMake(button_setDes.frame.size.width, 0.0, 80.0, 36.0)];
    [button_setStart setFrame:CGRectMake(button_setDes.frame.size.width, 0.0, 68.0, 36.0)];
        [button_around setFrame:CGRectMake(button_setDes.frame.size.width + COLLENT_LEFT_YINYING, 0.0, 80.0, 36.0)];
    [button_more setFrame:CGRectMake(button_setDes.frame.size.width+button_around.frame.size.width + COLLENT_LEFT_YINYING, 0.0, 70.0, 36.0)];
    [shareBackground setFrame:CGRectMake(0.0, 35.0, FRAME_WIDTH, 90.0)];
    [addCommonBackground setFrame:CGRectMake(0.0, 35.0, FRAME_WIDTH, 90.0)];
    [textFieldName setFrame:CGRectMake(44.0, 3.0, FRAME_WIDTH-55.0, 32.0)];
    
    [viewTrafficBackground setFrame:CGRectMake(0.0, 0.0, text_view.frame.size.width,text_view.frame.size.height)];
    [imageViewTrafficIcon setFrame:CGRectMake(10., 4., 26., 34.)];
    [labelTrafficType setFrame:CGRectMake(10., 10., 120., 20.)];
    [labelTrafficDetail setFrame:CGRectMake(10., 35., text_view.frame.size.width-20., 50.)];
    [button_timeCount setFrame:CGRectMake(FRAME_WIDTH/2.0-40.0, 6.0, 21., 21.)];
    [button_setPassby setFrame:CGRectMake(FRAME_WIDTH - 90., 2.0, 88.0, 40.0)];
    [button_selectPOISetDes setFrame:CGRectMake(FRAME_WIDTH - 90., 5.0, 90.0, 36.0)];
    [button_desAroundSetDes setFrame:CGRectMake(FRAME_WIDTH - 74., 5.0, 70.0, 70.)];
    
    if ([ANParamValue sharedInstance].isPath) {
        [button_close setFrame:CGRectMake(10., 83.0, FRAME_WIDTH/2.0-15.0, 34.0)];
    }
    else{
        [button_close setFrame:CGRectMake(10., 83.0, FRAME_WIDTH-20.0, 34.0)];
    }
    [button_timeCount setFrame:CGRectMake(button_close.frame.size.width-25., 6.0, 21., 21.)];
    
    [labelDesAroundName setFrame:CGRectMake(10.0f, 10.0f, FRAME_WIDTH-80.0, 28.0)];
    [labelDesAroundAddress setFrame:CGRectMake(10.0f, 32.0f, FRAME_WIDTH-80.0, 28.0)];
    [colorLabelDesAroundDisToDes setFrame:CGRectMake(10.0f, 50.0f, FRAME_WIDTH-64.0, 28.0)];
}

- (void)setPopPOIText
{
    [button_setDes setTitle:STR(@"Main_setAsDestination", Localize_Main) forState:UIControlStateNormal];
    [button_around setTitle:STR(@"Main_periphery", Localize_Main) forState:UIControlStateNormal];
     [button_more setTitle:STR(@"Main_collect", Localize_Main) forState:UIControlStateNormal];
    [button_save setTitle:STR(@"Universal_save", Localize_Universal) forState:UIControlStateNormal];
    [button_setPassby setTitle:STR(@"Main_setAsPassBy", Localize_Main) forState:UIControlStateNormal];
    [button_selectPOISetDes setTitle:STR(@"Main_setAsDestination", Localize_Main) forState:UIControlStateNormal];
    [button_avoid setTitle:STR(@"Main_avoidRoute", Localize_Main) forState:UIControlStateNormal];
    [button_close setTitle:STR(@"Main_close", Localize_Main) forState:UIControlStateNormal];
    [button_cancel setTitle:STR(@"Universal_cancel", Localize_Universal) forState:UIControlStateNormal];
    [button_desAroundSetDes setTitle:STR(@"Main_setAsDestination", Localize_Main) forState:UIControlStateNormal];
}

- (void) setDayAndNightTextColor:(int) mode // 1 = 黑夜   0 = 白天
{
    if(mode == 1)//黑夜
    {
        [labelPOIName setTextColor:POPPOI_NIGHT_TEXT_COLOR];
        [labelAddress setTextColor:POPPOI_NIGHT_TEXT_COLOR];
        [labelDistance setTextColor:POPPOI_NIGHT_TEXT_COLOR];
        [labelTrafficType setTextColor:POPPOI_NIGHT_TEXT_COLOR];
        [labelTrafficDetail setTextColor:POPPOI_NIGHT_TEXT_COLOR];
        [labelDesAroundName setTextColor:POPPOI_NIGHT_TEXT_COLOR];
        [labelDesAroundAddress setTextColor:POPPOI_NIGHT_TEXT_COLOR];
        [colorLabelDesAroundDisToDes setTextColor:POPPOI_NIGHT_TEXT_COLOR];
        [button_collect setTitleColor:POPPOI_NIGHT_TEXT_COLOR forState:UIControlStateNormal];;
        [button_setStart setTitleColor:POPPOI_NIGHT_TEXT_COLOR forState:UIControlStateNormal];
        [button_setDes  setTitleColor:POPPOI_NIGHT_TEXT_COLOR forState:UIControlStateNormal];
        [button_around  setTitleColor:POPPOI_NIGHT_TEXT_COLOR forState:UIControlStateNormal];
        [button_save  setTitleColor:POPPOI_NIGHT_TEXT_COLOR forState:UIControlStateNormal];
        [button_setPassby  setTitleColor:POPPOI_NIGHT_TEXT_COLOR forState:UIControlStateNormal];
        [button_selectPOISetDes setTitleColor:POPPOI_NIGHT_TEXT_COLOR forState:UIControlStateNormal];
        [button_close  setTitleColor:POPPOI_CLOSE_COLOR forState:UIControlStateNormal];
        [button_cancel  setTitleColor:POPPOI_NIGHT_TEXT_COLOR forState:UIControlStateNormal];
        [button_more setTitleColor:POPPOI_NIGHT_TEXT_COLOR forState:UIControlStateNormal];
        [button_desAroundSetDes setTitleColor:POPPOI_NIGHT_TEXT_COLOR forState:UIControlStateNormal];
    }
    else
    {
        [labelPOIName setTextColor:POPPOI_TITLE_COLOR];
        [labelAddress setTextColor:POPPOI_COLOR];
        [labelDistance setTextColor:POPPOI_COLOR];
        [labelTrafficType setTextColor:POPPOI_TRAFFIC_COLOR];
        [labelTrafficDetail setTextColor:POPPOI_TRAFFIC_COLOR];
        [labelDesAroundAddress setTextColor:POPPOI_COLOR];
        [labelDesAroundName setTextColor:POPPOI_COLOR];
        [colorLabelDesAroundDisToDes setTextColor:POPPOI_COLOR];
        [button_collect setTitleColor:POPPOI_COLOR forState:UIControlStateNormal];;
        [button_setStart setTitleColor:POPPOI_COLOR forState:UIControlStateNormal];
        [button_setDes  setTitleColor:GETSKINCOLOR(MAIN_TIPS_SETDES_COLOR) forState:UIControlStateNormal];
        [button_around  setTitleColor:POPPOI_COLOR forState:UIControlStateNormal];
        [button_save  setTitleColor:POPPOI_COLOR forState:UIControlStateNormal];
        [button_setPassby  setTitleColor:POPPOI_COLOR forState:UIControlStateNormal];
        [button_selectPOISetDes setTitleColor:POPPOI_COLOR forState:UIControlStateNormal];
        [button_close  setTitleColor:POPPOI_CLOSE_COLOR forState:UIControlStateNormal];
        [button_cancel  setTitleColor:POPPOI_COLOR forState:UIControlStateNormal];
        [button_more setTitleColor:POPPOI_COLOR forState:UIControlStateNormal];
        [button_desAroundSetDes setTitleColor:POPPOI_COLOR forState:UIControlStateNormal];
    }
}

- (void)refreshColorAndImage:(NSNotification*)notification
{
    if ([notification.object intValue] != UIUpdate_SkinTypeChange && [notification.object intValue] != UIUpdate_MapDayNightModeChange) {
        return;
    }
    [self setDayAndNightTextColor:[[MWPreference sharedInstance] getValue:PREF_DAYNIGHTMODE] ];
    if([notification.object intValue] == UIUpdate_MapDayNightModeChange)
    {
        [self setDayAndNightTextColor:[[notification.userInfo objectForKey:@"dayNightMode"] intValue]];
    }

    [self setButtonHighlight];
    [button_setDes setImage:IMAGE(@"PopPOISetDes.png", IMAGEPATH_TYPE_2) forState:UIControlStateNormal];
    [button_around setImage:IMAGE(@"PopPOIAround.png", IMAGEPATH_TYPE_2) forState:UIControlStateNormal];
    [self setFavoriteState:favoriteState];
    [button_setPassby setImage:IMAGE(@"PopPOISetPassby.png", IMAGEPATH_TYPE_2) forState:UIControlStateNormal];
    [button_selectPOISetDes setImage:IMAGE(@"PopPOISetDes.png", IMAGEPATH_TYPE_2) forState:UIControlStateNormal];
    [button_desAroundSetDes setImage:IMAGE(@"PopPOISetDes.png", IMAGEPATH_TYPE_2) forState:UIControlStateNormal];
    
    UIImage *gradientHLine = [IMAGE(@"landscapeGrayLine.png", IMAGEPATH_TYPE_2) stretchableImageWithLeftCapWidth:1 topCapHeight:1];
    UIImage *gradientVLine = [IMAGE(@"portraitGrayline.png", IMAGEPATH_TYPE_2) stretchableImageWithLeftCapWidth:0 topCapHeight:0];
    //横线195
    gradientHView.image = gradientHLine;

    //竖线
    lineView_1.image = gradientVLine;
    
    lineView_2.image = gradientVLine;
    lineAddress.image = gradientVLine;
    lineView_desAround.image = gradientVLine;
    
	[back_left setImage:[ IMAGE(@"poiLeft.png", IMAGEPATH_TYPE_2) stretchableImageWithLeftCapWidth:5 topCapHeight:10]];
    
	[back_center setImage:[ IMAGE(@"poiCenter.png", IMAGEPATH_TYPE_2)stretchableImageWithLeftCapWidth:22 topCapHeight:10]];
	
	
	[back_right setImage:[IMAGE(@"poiRight.png", IMAGEPATH_TYPE_2) stretchableImageWithLeftCapWidth:4 topCapHeight:10]];
    
    UIImage *imageBackground1 = [IMAGE(@"POIPersonBtn.png", IMAGEPATH_TYPE_2) stretchableImageWithLeftCapWidth:5. topCapHeight:5.];
    UIImage *imageBackground2 = [IMAGE(@"POIPersonBtn1.png", IMAGEPATH_TYPE_2) stretchableImageWithLeftCapWidth:5. topCapHeight:5.];
    UIImage *imageBackground3 = [IMAGE(@"CommonBtn1.png", IMAGEPATH_TYPE_2) stretchableImageWithLeftCapWidth:5. topCapHeight:5.];
    UIImage *imageBackground4 = [IMAGE(@"CommonBtn2.png", IMAGEPATH_TYPE_2) stretchableImageWithLeftCapWidth:5. topCapHeight:5.];
    
    [button_close setBackgroundImage:imageBackground1 forState:UIControlStateNormal];
    [button_close setBackgroundImage:imageBackground2 forState:UIControlStateHighlighted];
    
    [button_avoid setBackgroundImage:imageBackground3 forState:UIControlStateNormal];
    [button_avoid setBackgroundImage:imageBackground4 forState:UIControlStateHighlighted];
    
    [button_collect setImage:IMAGE(@"POI_MoreDetail.png", IMAGEPATH_TYPE_2) forState:UIControlStateNormal];
    [button_collect setImage:IMAGE(@"POI_MoreDetailPress.png", IMAGEPATH_TYPE_2) forState:UIControlStateNormal];
    
}

- (void)setViewFrame
{
    NSArray  *windows = [UIApplication sharedApplication].windows;
    UIWindow *window = [windows objectAtIndex:0];
    CGSize windowSize = window.rootViewController.view.bounds.size;
    
    [_blockerView setFrame:CGRectMake(0.0, 0.0, windowSize.width, windowSize.height)];
    [text_view setCenter:CGPointMake(windowSize.width/2.0, windowSize.height/2.)];
}

- (void)ChangeOrientation:(NSNotification*)notify
{
    if (viewPOIType == ViewPOIType_TrafficNoArrow) {
        [self setViewFrame];
    }
    else{
        NSArray  *windows = [UIApplication sharedApplication].windows;
        UIWindow *window = [windows objectAtIndex:0];
        CGSize windowSize = window.rootViewController.view.bounds.size;
        
        [_blockerView setFrame:CGRectMake(0.0, 0.0, windowSize.width, windowSize.height)];
    }
}


- (void)closePopPOIView:(NSTimer *)timer
{
	
	if (_iTimeCount == 1)
	{
    
		[self setHidden:YES];
	}
	else
	{
        UIImage *imageProgress = [UIImage getRoundImageWithImage:IMAGE(@"timeCount2.png", IMAGEPATH_TYPE_2) from:0 to:36*(_iTimeCount-1)];
        [button_timeCount setImage:imageProgress forState:UIControlStateNormal];
        
        [button_timeCount setTitle:[NSString stringWithFormat:@"%d",_iTimeCount-1] forState:UIControlStateNormal];
        
        
    }
	_iTimeCount--;
}
#pragma mark animations
static CGFloat kTransitionDuration = 0.3f;
-(void)startAnimate:(NSTimeInterval)ti
{
    if (GDBL_CheckRecognizeType(EVENT_PAN) ||  GDBL_CheckRecognizeType(EVENT_PAN_MOVE)) {
        return;
    }
    self.isShow = YES;
	kTransitionDuration = ti;
	text_view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.001, 0.001);
	[NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(bounceAnimationStopped) userInfo:nil repeats:NO];
}
- (void)endAnimation
{
    self.isShow = NO;
}

- (void)bounce2AnimationStopped
{
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:kTransitionDuration/2];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(endAnimation)];
	text_view.transform = CGAffineTransformIdentity;
	[UIView commitAnimations];
}

- (void)bounce1AnimationStopped
{
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:kTransitionDuration/2];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(bounce2AnimationStopped)];
	text_view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.9, 0.9);
	[UIView commitAnimations];
}

- (void)bounceAnimationStopped
{
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:kTransitionDuration/1.5];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(bounce1AnimationStopped)];
	text_view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1);
	[UIView commitAnimations];
}
#pragma mark -
#pragma mark UITextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{

    return YES;
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [back_center release];
    [back_left release];
    [back_right release];
	[text_view release];
	if (curPOI) {
        [curPOI release];
        curPOI = nil;
    }
    if (_blockerView) {
        [_blockerView release];
        _blockerView = nil;
    }
	[super dealloc];
}
@end

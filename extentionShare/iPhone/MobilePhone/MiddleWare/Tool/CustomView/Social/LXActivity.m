//
//  LXActivity.m
//  LXActivityDemo
//
//  Created by lixiang on 14-3-17.
//  Copyright (c) 2014年 lcolco. All rights reserved.
//

#import "LXActivity.h"
#define CancleButtonTag 9011


#define isiPhone (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)

#define SHAREBUTTON_WIDTH                       60   //分享按钮的宽
#define SHAREBUTTON_HEIGHT                      60   //分享按钮的高



#define Share_Label_Height                      30  //label的高
//#define ShareLabelWeight                        20


#define SHAREBUTTON_INTERVAL_HEIGHT             35
//背景颜色
#define ACTIONSHEET_BACKGROUNDCOLOR             [UIColor colorWithRed:0/255.00f green:0/255.00f blue:0/255.00f alpha:0.56]
#define ANIMATE_DURATION                        0.25f //动画时间

#define TITLE_HEIGHT                            20

#define BUTTON_INTERVAL_HEIGHT                  20
#define BUTTON_HEIGHT                           50//取消按钮的高度
#define kSizeFont14                        [UIFont systemFontOfSize:14.0f]//字体的大小

#define BUTTON_TOPHEIGHT                         20
@interface UIImage (custom)

+ (UIImage *)imageWithColor:(UIColor *)color;

@end


@implementation UIImage (custom)

+ (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}
@end


static UIWindow *g_socialWindow = nil;
static UIWindowLevel social_UIWindowLevelSIAlert = 1996.0;  // 不覆盖系统警告


@interface LXActivity : UIView{
    NSMutableArray *_shareButtonArray;
    UIButton *_cancelButton;
    UIView *_tapView;
}

@property (nonatomic,retain) UIView *backGroundView;
@property (nonatomic,retain) NSString *actionTitle;
@property (nonatomic,assign) NSInteger postionIndexNumber;
@property (nonatomic,assign) BOOL isHadTitle;
@property (nonatomic,assign) BOOL isHadShareButton;
@property (nonatomic,assign) BOOL isHadCancelButton;
@property (nonatomic,assign) CGFloat LXActivityHeight;
@property (nonatomic,assign) id<LXActivityDelegate>delegate;
@property (assign,nonatomic) int arrayCount;

@end

@implementation LXActivity

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

#pragma mark - Public method

- (id)initWithTitle:(NSString *)title delegate:(id<LXActivityDelegate>)delegate cancelButtonTitle:(NSString *)cancelButtonTitle andWithImage:(NSArray *)arrayImage andWithTitle:(NSArray *)arrayTitle;
{
    self = [super init];
    if (self) {
        _shareButtonArray = [[NSMutableArray alloc] init];
        _cancelButton = nil;

        self.arrayCount = arrayTitle.count -1;
        
        self.backgroundColor = ACTIONSHEET_BACKGROUNDCOLOR ;
        self.userInteractionEnabled = YES;
        if (delegate) {
            self.delegate = delegate;
        }
        [self creatButtonsWithTitle:nil cancelButtonTitle:[arrayTitle caObjectsAtIndex:arrayTitle.count-1] shareButtonTitles:arrayTitle withShareButtonImagesNameNoral:arrayImage];
        
        _tapView = [[UIView alloc] init];
        _tapView.backgroundColor = [UIColor clearColor];
        [self addSubview:_tapView];
        [_tapView release];
        
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedCancel)];
        recognizer.numberOfTapsRequired = 1;
        recognizer.numberOfTouchesRequired = 1;
        [_tapView addGestureRecognizer:recognizer];
        [recognizer release];
    }
    return self;
}

- (void)show
{
    CGSize size = self.bounds.size;
    NSLog(@"%f,%f",size.width,size.height);
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if(orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight)
    {
        if (NSFoundationVersionNumber>NSFoundationVersionNumber_iOS_7_1) {
            NSLog(@"IOS 8下做特殊处理");
        }else
        {
            size = CGSizeMake(size.height, size.width);
        }
    }
    else
    {
        if ( NSFoundationVersionNumber == NSFoundationVersionNumber_iOS_5_0 || NSFoundationVersionNumber == NSFoundationVersionNumber_iOS_5_1)
        {
            size.height += 20;
        }
    }
    float perButtonWidth = SHAREBUTTON_WIDTH + 46;    //一个按钮所占的大概宽度， 用于计算每行按钮的个数。
    NSLog(@"%f %f",size.width,perButtonWidth);
    int   perButtonCount = size.width / perButtonWidth;
    int lines  = 0;
    lines = ceil((double)[_shareButtonArray count]/(double)perButtonCount);
    if (self.isHadCancelButton)
    {
        self.LXActivityHeight = BUTTON_TOPHEIGHT + (SHAREBUTTON_INTERVAL_HEIGHT+SHAREBUTTON_HEIGHT) * lines + BUTTON_INTERVAL_HEIGHT + BUTTON_HEIGHT-15;
    }
    else
    {//BUTTON_TOPHEIGHT
        self.LXActivityHeight = BUTTON_TOPHEIGHT + (SHAREBUTTON_INTERVAL_HEIGHT+SHAREBUTTON_HEIGHT) * lines;
    }
    
    
    self.frame = CGRectMake(0, 0, size.width, size.height);
    self.backGroundView.frame = CGRectMake(0, size.height, size.width, self.LXActivityHeight);
    [self setButtonFrame];
    [UIView animateWithDuration:ANIMATE_DURATION
                     animations:^{
                         [self.backGroundView setFrame:CGRectMake(0, size.height - self.LXActivityHeight, size.width, self.LXActivityHeight)];
                     } completion:^(BOOL finished) {
                     }];
    
    _tapView.frame = CGRectMake(0, 0, size.width, size.height - self.LXActivityHeight);
}
#pragma mark - Praviate method

- (void)creatButtonsWithTitle:(NSString *)title
            cancelButtonTitle:(NSString *)cancelButtonTitle
            shareButtonTitles:(NSArray *)shareButtonTitlesArray
withShareButtonImagesNameNoral:(NSArray *)shareButtonImagesNameArray
{
    //初始化
    self.isHadShareButton = NO;
    self.isHadCancelButton = NO;
    self.LXActivityHeight = 0;
    //生成LXActionSheetView
    self.backGroundView = [[[UIView alloc] init] autorelease];
    self.backGroundView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.backGroundView];
    [_backGroundView release];
    
    
    
    if (shareButtonImagesNameArray) {
        if (shareButtonImagesNameArray.count > 0) {
            self.isHadShareButton = YES;
            for (int i = 1; i < shareButtonImagesNameArray.count; i++) {
                //计算出行数，与列数
                UIButton * shareButton = [self creatShareButtonWithColumn:0 andLine:0];
                shareButton.tag = i-1;
                [shareButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
                [shareButton setImage:[UIImage imageNamed:[shareButtonImagesNameArray caObjectsAtIndex:i-1]] forState:UIControlStateNormal];
                NSString * stringImage = [NSString stringWithFormat:@"%@_on.png",[shareButtonImagesNameArray caObjectsAtIndex:i-1]];
                UIImage * image=[UIImage imageNamed:stringImage];
                [shareButton setImage:image forState:UIControlStateDisabled];
                [self.backGroundView addSubview:shareButton];
               
                UILabel *lable = [self createLabel:i];
                lable.text =  [shareButtonTitlesArray caObjectsAtIndex:i-1];
                lable.center = CGPointMake(SHAREBUTTON_WIDTH/2, SHAREBUTTON_HEIGHT + Share_Label_Height/2 + 10);
                [shareButton addSubview:lable];
                [_shareButtonArray addObject:shareButton];
            }
        }
    }
    if (cancelButtonTitle) {
        self.isHadCancelButton = YES;
        UIButton * cancelButton = [self creatCancelButtonWith:cancelButtonTitle andWithImage:shareButtonImagesNameArray];
        cancelButton.tag = CancleButtonTag;
        [cancelButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [cancelButton setFrame:CGRectMake(cancelButton.frame.origin.x, self.LXActivityHeight, cancelButton.frame.size.width, cancelButton.frame.size.height)];
        NSLog(@"%lf",cancelButton.frame.size.height);
        [self.backGroundView addSubview:cancelButton];
        _cancelButton = cancelButton;
    }
   
}

- (void)setButtonFrame
{
    CGSize size = self.backGroundView.bounds.size;
    

    float perButtonWidth = SHAREBUTTON_WIDTH + 46;    //一个按钮所占的大概宽度， 用于计算每行按钮的个数。
    int   perButtonCount = size.width / perButtonWidth;
    if (_shareButtonArray.count < perButtonCount)
    {
        perButtonCount = _shareButtonArray.count;
    }
    float realButtonWidth =(float) size.width/perButtonCount;  //实际上一个按钮所占宽度

    for (int i = 0; i < _shareButtonArray.count; i++)
    {
        UIButton *button = [_shareButtonArray objectAtIndex:i];
        CGFloat x = realButtonWidth/2 + realButtonWidth*(i%perButtonCount);
        CGFloat y = TITLE_HEIGHT + SHAREBUTTON_HEIGHT/2 + (i/perButtonCount)*( SHAREBUTTON_HEIGHT+ 35);
        button.frame = CGRectMake(0, 0, SHAREBUTTON_WIDTH, SHAREBUTTON_HEIGHT + 20);
        button.center = CGPointMake(x, y);
        
        
    }
    
    if (_cancelButton)
    {
        _cancelButton.frame = CGRectMake(0, 0, size.width - 20, BUTTON_HEIGHT);
        _cancelButton.center = CGPointMake(size.width / 2, size.height - BUTTON_HEIGHT/2 - 5);
    }
}
//创建分享文字
-(UILabel *)createLabel:(int)num
{
    int with = (SCREENWIDTH/ (isiPhone ? 3 : 4) );
    UILabel * label=[[UILabel alloc]initWithFrame:CGRectMake(num* with,TITLE_HEIGHT + SHAREBUTTON_HEIGHT,with,Share_Label_Height)];
    label.textAlignment=NSTextAlignmentCenter;
    label.textColor=[UIColor blackColor];
    label.backgroundColor=[UIColor clearColor];
    label.font= kSizeFont14;
    return [label autorelease];

}
//创建分享按钮
- (UIButton *)creatShareButtonWithColumn:(int)column andLine:(int)line
{
    int with = (SCREENWIDTH/3-SHAREBUTTON_WIDTH)/2;
    int lines=line-1;
    UIButton * btn=[UIButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:CGRectMake(lines*SHAREBUTTON_WIDTH + (2*lines+1)*with, BUTTON_TOPHEIGHT+((column-1)*(BUTTON_TOPHEIGHT+SHAREBUTTON_HEIGHT)), SHAREBUTTON_WIDTH, SHAREBUTTON_HEIGHT + 50)];
    return btn ;
}
//创建取消按钮
- (UIButton *)creatCancelButtonWith:(NSString *)cancelButtonTitle andWithImage:(NSArray *)arrayImage;
{
    UIButton * cancelButton =[UIButton buttonWithType:UIButtonTypeCustom];
    if (isiPhone) {
        [cancelButton setFrame:CGRectMake(10, BUTTON_INTERVAL_HEIGHT,SCREENWIDTH - 10*2, BUTTON_HEIGHT)];
    }else
    {  int a=(SCREENWIDTH - 50*4)/5;
        [cancelButton setFrame:CGRectMake(a,0,SCREENWIDTH-2*a, BUTTON_HEIGHT)];
    }
    
    UIImage * image= [UIImage imageNamed:[NSString stringWithFormat:@"%@",[arrayImage caObjectsAtIndex:arrayImage.count-1]]];
    image = [image stretchableImageWithLeftCapWidth:image.size.width/2 topCapHeight:image.size.height/2];
    [cancelButton setBackgroundImage:image forState:UIControlStateNormal];
    
    UIImage * image2= [UIImage imageNamed:[NSString stringWithFormat:@"_on%@",[arrayImage caObjectsAtIndex:arrayImage.count-1]]];
    image2 = [image2 stretchableImageWithLeftCapWidth:image2.size.width/2 topCapHeight:image2.size.height/2];
    [cancelButton setBackgroundImage:image2 forState:UIControlStateDisabled];
    
    [cancelButton setTitle:cancelButtonTitle forState:UIControlStateNormal];
    cancelButton.titleLabel.font = [UIFont systemFontOfSize:17.0];
    [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    return cancelButton;
}
//按钮的响应
-(void)buttonAction:(UIButton *)sender
{
    if (sender.tag == CancleButtonTag) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didClickOnCancelButton)]) {
            [self.delegate didClickOnCancelButton];
        }
    }else
    {
        if (self.delegate&&[self.delegate respondsToSelector:@selector(didClickOnImageIndex:)]) {
            [self.delegate didClickOnImageIndex:sender.tag];
        }
    }
    [self tappedCancel];
}
- (void)tappedCancel
{
    [UIView animateWithDuration:ANIMATE_DURATION animations:^{
        [self.backGroundView setFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, 0)];
        self.alpha = 0;
    } completion:^(BOOL finished) {
        if (finished) {
            [self removeFromSuperview];
            if (g_socialWindow)
            {
                [g_socialWindow release];
                g_socialWindow = nil;
            }
        }
    }];
}

-(void)dealloc
{
    [_shareButtonArray release];
    _shareButtonArray = nil;
    
    if (_delegate) {
        _delegate = nil;
    }
    [super dealloc];
}

- (void)ChangeFrame
{
    CGSize size = self.bounds.size;
    float perButtonWidth = SHAREBUTTON_WIDTH + 46;    //一个按钮所占的大概宽度， 用于计算每行按钮的个数。
    int   perButtonCount = size.width / perButtonWidth;
    int lines  = 0;
    lines = ceil((double)[_shareButtonArray count]/(double)perButtonCount);
    if (self.isHadCancelButton)
    {
        self.LXActivityHeight = BUTTON_TOPHEIGHT + (SHAREBUTTON_INTERVAL_HEIGHT+SHAREBUTTON_HEIGHT) * lines + BUTTON_INTERVAL_HEIGHT + BUTTON_HEIGHT-15;
    }
    else
    {
        self.LXActivityHeight = BUTTON_TOPHEIGHT + (SHAREBUTTON_INTERVAL_HEIGHT+SHAREBUTTON_HEIGHT) * lines;
    }
    
    [self.backGroundView setFrame:CGRectMake(0, size.height - self.LXActivityHeight, size.width, self.LXActivityHeight)];
    _tapView.frame = CGRectMake(0, 0, size.width, size.height - self.LXActivityHeight);
    [self setButtonFrame];
}
@end



@interface SocialShareViewController : UIViewController
{
    LXActivity *_socialView;
}




@end

@implementation SocialShareViewController

- (instancetype)initWithDelegate:(id<LXActivityDelegate>)delegate andWithImage:(NSArray *)arrayImage andWithTitle:(NSArray *)arrayTitle;
{
    self = [super init];
    if (self) {
        _socialView= [[LXActivity alloc] initWithTitle:nil delegate:delegate cancelButtonTitle:nil andWithImage:arrayImage andWithTitle:arrayTitle];
        _socialView.frame = self.view.bounds;
        self.view = _socialView;
        [_socialView release];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_socialView show];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_socialView ChangeFrame];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    UIDeviceOrientation currentOrientation = [[UIDevice currentDevice] orientation];
    if ( (currentOrientation == UIDeviceOrientationFaceUp)
        || (currentOrientation == UIDeviceOrientationFaceDown)
        || (currentOrientation == UIDeviceOrientationUnknown)) {
        return;
    }
    [_socialView ChangeFrame];
}

- (BOOL)shouldAutorotate
{
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationUnknown) {
        return YES;
    }
    
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if (!OrientationSwitch)
    {
        return (Orientation == interfaceOrientation);
    }
	return  YES;
    
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationUnknown) {
        [[MWPreference sharedInstance] loadPreference];
    }
    
    if ( [[ANParamValue sharedInstance] bSupportAutorate] == NO)
    {
        return  UIInterfaceOrientationMaskPortrait;
    }
    else{
        if (!OrientationSwitch) {
            return (1<<[[UIApplication sharedApplication] statusBarOrientation]);
        }
        return  UIInterfaceOrientationMaskAll;
    }
}
@end

@implementation SociallShareManage


+ (void)ShowViewWithDelegate:(id<LXActivityDelegate>)delegate andWithImage:(NSArray *)arrayImage andWithTitle:(NSArray *)arrayTitle;
{
    if (g_socialWindow)  //容错添加，防止不能重现创建该window视图
    {
        [g_socialWindow release];
        g_socialWindow = nil;
    }
    if (g_socialWindow == nil)
    {
        SocialShareViewController *ctl = [[SocialShareViewController alloc] initWithDelegate:delegate andWithImage:arrayImage andWithTitle:arrayTitle];
        
        g_socialWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        g_socialWindow.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        g_socialWindow.opaque = NO;
        g_socialWindow.windowLevel = social_UIWindowLevelSIAlert;
        g_socialWindow.rootViewController = ctl;
        g_socialWindow.hidden = NO;
        [ctl release];
    }
}

+ (void)RemoveSocialWindow
{
    if (g_socialWindow)
    {
        [g_socialWindow release];
        g_socialWindow = nil;
    }
}

@end
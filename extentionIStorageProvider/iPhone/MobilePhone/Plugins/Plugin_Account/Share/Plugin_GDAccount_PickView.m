//
//  Plugin_GDAccount_PickView.m
//  AutoNavi
//
//  Created by gaozhimin on 12-12-20.
//
//

#import "Plugin_GDAccount_PickView.h"
#import "AppDelegate_iPhone.h"
#import "ANParamValue.h"

#define PickView_Button_Height 44.0f
#define AppDelegate 	((AppDelegate_iPhone*)[[UIApplication sharedApplication] delegate])
#define MainController [AppDelegate mainViewController]
#define MainView [MainController view]

@interface Plugin_GDAccount_PickView()

- (void)ShowPosition;

@end

@implementation Plugin_GDAccount_PickView

@synthesize m_pickView,pickerItem;
@synthesize cityName;
@synthesize townName;
@synthesize isShow;
@synthesize show_cityName,show_townName;

- (id)initWithdelegate:(id)delegate cancel:(SEL)cancel_selector sure:(SEL)sure_selector
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        // Initialization code
        
        [self readPickerData];
        
        self.show_cityName = [NSString stringWithFormat:@"%@",[[pickerItem objectAtIndex:0] objectForKey:@"province"]];
        NSMutableArray *cityArray = [[pickerItem objectAtIndex:0] objectForKey:@"districts"];
        self.show_townName = [NSString stringWithFormat:@"%@",[[cityArray objectAtIndex:0] objectForKey:@"district"]];
        
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        _blockerView = [[UIView alloc] initWithFrame:CGRectZero];
        _blockerView.backgroundColor = GETSKINCOLOR(CONTROL_BACKGROUND_COLOR);
        _blockerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _blockerView.userInteractionEnabled = YES;
        [MainView addSubview: _blockerView];
        [_blockerView release];_blockerView.alpha = 0.0;
        
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognizer:)];
        recognizer.numberOfTapsRequired = 1;
        recognizer.numberOfTouchesRequired = 1;
        [_blockerView addGestureRecognizer:recognizer];
        [recognizer release];
        
        citySelectRow = 0;
        
        m_pickBackView = [[UIImageView alloc]initWithFrame:CGRectZero];
        m_pickBackView.backgroundColor = GETSKINCOLOR(ACCOUNT_PICKVIEW_BACK_COLOR);
        [self addSubview:m_pickBackView];
        [m_pickBackView release];
        
        m_pickView = [[UIPickerView alloc] initWithFrame:CGRectZero];
        m_pickView.dataSource = self;
        m_pickView.delegate = self;
        m_pickView.showsSelectionIndicator = YES;
        [self addSubview:m_pickView];
        [m_pickView release];
        
        
       
        
        m_imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        UIImage *buttonImage = IMAGE(@"pickSelectBac.png", IMAGEPATH_TYPE_1);
        UIImage *stretchableButtonImage = [buttonImage stretchableImageWithLeftCapWidth:0 topCapHeight:0];
        m_imageView.backgroundColor = [UIColor colorWithPatternImage:stretchableButtonImage];
        m_imageView.userInteractionEnabled = YES;
        [self addSubview:m_imageView];
        [m_imageView release];
        
        m_cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        m_cancelButton.titleLabel.textColor = GETSKINCOLOR(ACCOUNT_BUTTON_TITLE_COLOR);
        [m_cancelButton setBackgroundImage: IMAGE(@"Button_Sort0.png", IMAGEPATH_TYPE_1)  forState:UIControlStateNormal];
        [m_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [m_cancelButton addTarget:delegate action:cancel_selector forControlEvents:UIControlEventTouchUpInside];
        [m_imageView addSubview:m_cancelButton];
        
        m_sureButton = [UIButton buttonWithType:UIButtonTypeCustom];
        m_sureButton.titleLabel.textColor = GETSKINCOLOR(ACCOUNT_BUTTON_TITLE_COLOR);
        [m_sureButton setBackgroundImage: IMAGE(@"Button_Sort0.png", IMAGEPATH_TYPE_1) forState:UIControlStateNormal];
        [m_sureButton setTitle:@"确定" forState:UIControlStateNormal];
        [m_sureButton addTarget:delegate action:sure_selector forControlEvents:UIControlEventTouchUpInside];
        [m_imageView addSubview:m_sureButton];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ChangeOrientation:) name:UIDeviceOrientationDidChangeNotification object:nil];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithdelegate:nil cancel:NULL sure:NULL];
}

- (void)setFrame:(CGRect)frame
{
    NSArray  *windows = [UIApplication sharedApplication].windows;
    UIWindow *window = [windows objectAtIndex:0];
    CGSize windowSize = window.rootViewController.view.bounds.size;
    UIView *view = [self superview];
    CGRect rect = view.bounds;
    float topBarHeight;
    float oriHeight = 0.0;
    if (isHiddenTopBar == YES) {
        topBarHeight = 0.0;
    }
    else{
        
        topBarHeight = PickView_Button_Height;
    }
    if ([view isKindOfClass:[UITableView class]])
    {
        UITableView *tablveiw = (UITableView *)view;
        oriHeight = tablveiw.contentOffset.y;
    }
    frame = CGRectMake(0, rect.size.height - 216 - topBarHeight+oriHeight, rect.size.width, 216 + topBarHeight);
    [super setFrame:frame];
    
    CGSize size = frame.size;
    m_imageView.frame = CGRectMake(0, 0, size.width, topBarHeight);
    m_pickView.frame = CGRectMake(0, topBarHeight, size.width, size.height - topBarHeight);
    m_pickBackView.frame = CGRectMake(0, topBarHeight, size.width, size.height - topBarHeight);
    
    m_cancelButton.frame = CGRectMake(0, 0, 50.0f, 30.0f);
    m_cancelButton.center = CGPointMake(30.0f, topBarHeight/2);
    
    m_sureButton.frame = CGRectMake(0, 0, 50.0f, 30.0f);
    m_sureButton.center = CGPointMake(size.width - 30.0f, topBarHeight/2);
    
    [_blockerView setFrame:CGRectMake(0.0, 0.0, windowSize.width, windowSize.height-size.height)];
    
//    [m_pickView reloadAllComponents];
}

- (void)dealloc
{
    if (_blockerView)
    {
        [_blockerView removeFromSuperview];
        _blockerView = nil;
    }
    if (pickerItem)
    {
        [pickerItem release];
    }
    if (cityName) {
        [cityName release];
    }
    if (townName) {
        [townName release];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
    
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

//读取城市列表文件

- (void)ChangeOrientation:(NSNotification*)notify
{
    UIInterfaceOrientation toInterfaceOrientation;
    NSDictionary *userInfo = [notify userInfo];
    toInterfaceOrientation = [[userInfo objectForKey:@"UIDeviceOrientationRotateAnimatedUserInfoKey"] integerValue];
    if(toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
	{
		[self setFrame:CGRectZero];
	}
	else if(toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
	{
		[self setFrame:CGRectZero];
    }
    
}

-(void)readPickerData
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"cityTownList" ofType:@"plist"];
	
	pickerItem=[[NSMutableArray alloc] initWithContentsOfFile:path];
}

- (void)ShowPosition
{
    NSDictionary *dic;
    citySelectRow = 0;
    for (int i = 0; i < [pickerItem count]; i++)
    {
        dic = [pickerItem objectAtIndex:i];
        NSString *province = [dic objectForKey:@"province"];
        if ([self.show_cityName rangeOfString:province].length > 0)
        {
            citySelectRow = i;
            break;
        }
    }
    [m_pickView selectRow:citySelectRow inComponent:0 animated:NO];
    self.cityName = [self pickerView:m_pickView titleForRow:citySelectRow forComponent:0];
    int town_row = 0;
    dic = [pickerItem objectAtIndex:citySelectRow];
    NSArray *array= [dic objectForKey:@"districts"];
    for (int i = 0; i < [array count]; i ++)
    {
        NSString *city = [[array objectAtIndex:i] objectForKey:@"district"];
        if ([self.show_townName rangeOfString:city].length > 0)
        {
            town_row = i;
            break;
        }
    }
    [m_pickView selectRow:town_row inComponent:1 animated:NO];
    self.townName = [self pickerView:m_pickView titleForRow:town_row forComponent:1];
    [m_pickView reloadAllComponents];
}

- (void)ShowOrHiddenPickView:(BOOL)show Animation:(BOOL)animation
{
    NSArray  *windows = [UIApplication sharedApplication].windows;
    UIWindow *window = [windows objectAtIndex:0];
    CGSize windowSize = window.rootViewController.view.bounds.size;
    UIView *view = [self superview];
    CGSize size = view.bounds.size;
    float oriHeight = 0.0;

    if ([view isKindOfClass:[UITableView class]])
    {
        UITableView *tablveiw = (UITableView *)view;
        tablveiw.scrollEnabled = NO;
        oriHeight = tablveiw.contentOffset.y;
    }
    if (show)
    {
        if (self.hidden == NO)
        {
            return;
        }
        isShow = YES;
        _blockerView.hidden = NO;
        if (isHiddenTopBar == YES) {
            
            m_imageView.hidden = YES;
        }
        [self ShowPosition];
        _blockerView.alpha = 0.0;
        [_blockerView setFrame:CGRectMake(0.0, 0.0, size.width, windowSize.height-size.height)];
        self.hidden = NO;
        self.frame = CGRectMake(0, 0, size.width, 0);
        
        if (YES == animation) {
            self.center = CGPointMake(size.width/2, size.height + self.frame.size.height/2);
            [UIView animateWithDuration:0.3f animations:^
             {
                 self.center = CGPointMake(size.width/2, size.height - self.frame.size.height/2+oriHeight);
                 _blockerView.center = CGPointMake(size.width/2.0, (windowSize.height-self.frame.size.height)/2.0);
                 _blockerView.alpha = 0.7;
             }
                             completion:^(BOOL finished)
             {
                 
             }];
        }
        else{
            self.center = CGPointMake(size.width/2, size.height - self.frame.size.height/2+oriHeight);
            _blockerView.center = CGPointMake(size.width/2.0, (windowSize.height-self.frame.size.height)/2.0);
            _blockerView.alpha = 0.7;
        }
    }
    else
    {
        if ([view isKindOfClass:[UITableView class]])
        {
            UITableView *tablveiw = (UITableView *)view;
            tablveiw.scrollEnabled = YES;
        }
        if (self.hidden == YES)
        {
            return;
        }

        isShow = NO;

        if (YES == animation) {
            _blockerView.alpha = 0.7;
            [_blockerView setFrame:CGRectMake(0.0, 0.0, size.width, windowSize.height-size.height)];
            self.frame = CGRectMake(0, 0, size.width, 0);
            self.center = CGPointMake(size.width/2, size.height - self.frame.size.height/2+oriHeight);
            [UIView animateWithDuration:0.3f animations:^
             {
                 self.center = CGPointMake(size.width/2, size.height + self.frame.size.height/2);
                 
                 _blockerView.alpha = 0.0;
                 
             }
                             completion:^(BOOL finished)
             {
                 self.hidden = YES;
                 _blockerView.center = CGPointMake(size.width/2.0, -windowSize.height);
             }];
        }
        else{
            self.hidden = YES;
        }
        
    }
}
//是否显示导航条
-(void)setIsHiddenTopBar:(BOOL)hidden
{
    isHiddenTopBar = hidden;
}
#pragma mark - pick view data source

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (0 == component) {
        return [pickerItem count];
    }
    
    return [[[pickerItem objectAtIndex:citySelectRow] objectForKey:@"districts"] count];
}

#pragma mark - pick view delegate
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    CGSize size = [pickerView rowSizeForComponent:component];
    
    //取得指定列的宽度
    CGFloat width = size.width;
    //取得指定列，行的高度
    CGFloat height = size.height;
    //定义一个视图
    UIView *myView=[[UIView alloc] init];
    //指定视图frame
    myView.frame=CGRectMake(0, 0, width, height);
    UILabel *labelOnComponent = [[UILabel alloc] init];
    labelOnComponent.backgroundColor = [UIColor clearColor];
    labelOnComponent.frame = CGRectMake(10, 0, width-10, height);
    labelOnComponent.tag = 200;
    labelOnComponent.textAlignment = NSTextAlignmentLeft;
    labelOnComponent.font = [UIFont boldSystemFontOfSize:20];
    UIColor *black = GETSKINCOLOR(ROUTE_ADDRESS_COLOR);
    labelOnComponent.textColor = black;
    labelOnComponent.text = [self pickerView:pickerView titleForRow:row forComponent:component];
    [myView addSubview:labelOnComponent];
    //内存管理，建立后释放
    [labelOnComponent release];
    return [myView autorelease];
    
}

// returns width of column and height of row for each component.
//- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
//{
//
//}
//
//- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
//{
//
//}

// these methods return either a plain NSString, a NSAttributedString, or a view (e.g UILabel) to display the row for the component.
// for the view versions, we cache any hidden and thus unused views and pass them back for reuse.
// If you return back a different object, the old one will be released. the view will be centered in the row rect
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (0 == component) {
        NSString *cityString = [NSString stringWithFormat:@"%@",[[pickerItem objectAtIndex:row] objectForKey:@"province"]];
        
		return cityString;
	}
    else if(1 == component) {
        
        NSMutableArray *cityArray = [NSMutableArray arrayWithArray:[[pickerItem objectAtIndex:citySelectRow] objectForKey:@"districts"]];
        NSString *townString = [NSString stringWithFormat:@"%@",[[cityArray objectAtIndex:row] objectForKey:@"district"]];
        return townString;
        
    }
    return nil;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    
    
    if (0 == component) {
        self.cityName = [NSString stringWithFormat:@"%@",[[pickerItem objectAtIndex:row] objectForKey:@"province"]];
        citySelectRow = row;
        [pickerView selectRow:0 inComponent:1 animated:NO];
        
        NSMutableArray *cityArray = [[pickerItem objectAtIndex:citySelectRow] objectForKey:@"districts"];
        self.townName = [NSString stringWithFormat:@"%@",[[cityArray objectAtIndex:0] objectForKey:@"district"]];
    }
    else {
        NSMutableArray *cityArray = [[pickerItem objectAtIndex:citySelectRow] objectForKey:@"districts"];
        self.townName = [NSString stringWithFormat:@"%@",[[cityArray objectAtIndex:row] objectForKey:@"district"]];
    }
    
	[pickerView reloadAllComponents];
}

- (void)tapGestureRecognizer:(UITapGestureRecognizer *)recognizer
{
    [self ShowOrHiddenPickView:NO Animation:YES];
}

@end

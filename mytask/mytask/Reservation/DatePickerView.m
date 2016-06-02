//
//  AccountAgePickerView.m
//  AutoNavi
//
//  Created by gaozhimin on 13-5-16.
//
//

#import "DatePickerView.h"

#define PickView_Button_Height 44.0f
#define MainView [DatePickerView getWindow]
#define Gray_Color [UIColor redColor]
#define Black_Color [UIColor blackColor]

@interface DatePickerView()

- (void)ShowPosition;

@end

@implementation DatePickerView

@synthesize m_pickView;
@synthesize isShow,m_day,m_hour,m_minus,m_showday,m_showhour,m_showminus;
+ (UIWindow *)getWindow
{
    return [[[UIApplication sharedApplication] windows] objectAtIndex:0];
}

- (id)initWithdelegate:(id)delegate cancel:(SEL)cancel_selector sure:(SEL)sure_selector
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        // Initialization code
        
        self.m_day = -1;
        self.m_hour = -1;
        self.m_minus = -1;
        
        [self readPickerData];
        
        _blockerView = [[UIView alloc] initWithFrame:CGRectZero];
        _blockerView.backgroundColor = [UIColor grayColor];
        _blockerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _blockerView.userInteractionEnabled = YES;
        [MainView addSubview: _blockerView];
        [_blockerView release];_blockerView.alpha = 0.0;
        
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognizer:)];
        recognizer.numberOfTapsRequired = 1;
        recognizer.numberOfTouchesRequired = 1;
        [_blockerView addGestureRecognizer:recognizer];
        [recognizer release];
        
        m_pickViewBack = [[UIImageView alloc]initWithFrame:CGRectZero];
        m_pickViewBack.backgroundColor = [UIColor grayColor];
        [self addSubview:m_pickViewBack];
        [m_pickViewBack release];
        
        
        m_pickView = [[UIPickerView alloc] initWithFrame:CGRectZero];
        m_pickView.dataSource = self;
        m_pickView.delegate = self;
        m_pickView.showsSelectionIndicator = YES;
        [self addSubview:m_pickView];
        [m_pickView release];
        
        
        
        m_imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        UIImage *buttonImage = [UIImage imageNamed:@"CommonBtn1.png"] ;
        UIImage *stretchableButtonImage = [buttonImage stretchableImageWithLeftCapWidth:0 topCapHeight:0];
        m_imageView.backgroundColor = [UIColor colorWithPatternImage:stretchableButtonImage];
        m_imageView.userInteractionEnabled = YES;
        [self addSubview:m_imageView];
        [m_imageView release];
        
        m_cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        m_cancelButton.titleLabel.textColor = Gray_Color;
        [m_cancelButton setBackgroundImage: [UIImage imageNamed:@"CommonBtn1.png"]  forState:UIControlStateNormal];
        [m_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [m_cancelButton addTarget:delegate action:cancel_selector forControlEvents:UIControlEventTouchUpInside];
        [m_imageView addSubview:m_cancelButton];
        
        m_sureButton = [UIButton buttonWithType:UIButtonTypeCustom];
        m_sureButton.titleLabel.textColor = Gray_Color;
        [m_sureButton setBackgroundImage: [UIImage imageNamed:@"CommonBtn1.png"] forState:UIControlStateNormal];
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
    m_pickViewBack.frame = CGRectMake(0, topBarHeight, size.width, size.height - topBarHeight);
    
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
   
}

- (void)ShowPosition
{
    m_minus = m_showminus;
    m_hour = m_showhour;
    m_day = m_showday;
    [m_pickView selectRow:m_day  inComponent:0 animated:NO];
    [m_pickView selectRow:m_hour inComponent:1 animated:NO];
    [m_pickView selectRow:m_minus inComponent:2 animated:NO];


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
        [self.superview bringSubviewToFront:self];
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

- (BOOL)GrayTitle
{
    int year = [m_pickView selectedRowInComponent:0] + 1;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY"];
    NSString *DateYear = [formatter stringFromDate: [NSDate date]];
    [formatter release];
    
    if (year > [DateYear intValue])
    {
        return YES;
    }
    else if (year == [DateYear intValue])
    {
        
    }
    return NO;
}

#pragma mark - pick view data source

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 3;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    if (0 == component)
    {
        return 120;
	}
    else if(1 == component)
    {
        return 75;
    }
    else if(2 == component)
    {
        return 75;
    }
    else
    {
        return 100;
    }
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 45;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{

    //取得指定列的宽度
    CGFloat width=[self pickerView:pickerView widthForComponent:component];
    
    //取得指定列，行的高度
    CGFloat height=[self pickerView:pickerView rowHeightForComponent:component];
    
    //定义一个视图
    UIView *myView=[[UIView alloc] init];
    
    //指定视图frame
    myView.frame=CGRectMake(0, 0, width, height);
    
    UILabel *labelOnComponent = [[UILabel alloc] init];
    
    labelOnComponent.frame = myView.frame;
    labelOnComponent.tag = 200;
    labelOnComponent.textAlignment = NSTextAlignmentCenter;
    labelOnComponent.font = [UIFont boldSystemFontOfSize:20];
    labelOnComponent.text = [self pickerView:pickerView titleForRow:row forComponent:component];
    labelOnComponent.textColor = Black_Color;
    [myView addSubview:labelOnComponent];
    
    //内存管理，建立后释放
    [labelOnComponent release];
    
    
    return [myView autorelease];
    
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (component == 0)
    {
        return 2;
    }
    else if (component == 1)
    {
        return 24;
    }
    else if (component == 2)
    {
        return 60;
    }
    return 15000;
}

#pragma mark - pick view delegate
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    
    
    if (0 == component)
    {
        NSDate *date = [NSDate date];
        NSDate *toDate = [NSDate dateWithTimeIntervalSinceNow:86400];
        
        NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
        [outputFormatter setDateFormat:@"EEEE"];
        
        if (row == 0)
        {
            return [NSString stringWithFormat:@"今天(%@)",[outputFormatter stringFromDate:date]];
        }
        else
        {
            return [NSString stringWithFormat:@"明天(%@)",[outputFormatter stringFromDate:toDate]];
        }
        return [NSString stringWithFormat:@"%d年",row];
	}
    else if(1 == component)
    {
        return [NSString stringWithFormat:@"%d时",row];
    }
    else if(2 == component)
    {
        return [NSString stringWithFormat:@"%d分",row];
    }
    return nil;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    [pickerView reloadAllComponents];
    
    if (component == 0)
    {
        self.m_day = row;
    }
    else if (component == 1)
    {
        self.m_hour = row;
    }
    else if (component == 2)
    {
        self.m_minus = row;
    }
}

- (void)tapGestureRecognizer:(UITapGestureRecognizer *)recognizer
{
    [self ShowOrHiddenPickView:NO Animation:YES];
}

@end


//
//  AccountAgePickerView.m
//  AutoNavi
//
//  Created by gaozhimin on 13-5-16.
//
//

#import "AccountAgePickerView.h"
#import "AppDelegate_iPhone.h"
#import "ANParamValue.h"

#define PickView_Button_Height 44.0f
#define AppDelegate 	((AppDelegate_iPhone*)[[UIApplication sharedApplication] delegate])
#define MainController [AppDelegate mainViewController]
#define MainView [MainController view]

@interface AccountAgePickerView()

- (void)ShowPosition;

@end

@implementation AccountAgePickerView

@synthesize m_pickView;
@synthesize isShow,m_day,m_month,m_year,m_showday,m_showyear,m_showmonth;

- (id)initWithdelegate:(id)delegate cancel:(SEL)cancel_selector sure:(SEL)sure_selector
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        // Initialization code
        
        [self readPickerData];
        
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
        
        m_pickViewBack = [[UIImageView alloc]initWithFrame:CGRectZero];
        m_pickViewBack.backgroundColor = GETSKINCOLOR(ACCOUNT_PICKVIEW_BACK_COLOR);
        [self addSubview:m_pickViewBack];
        [m_pickViewBack release];
        
        
        m_pickView = [[UIPickerView alloc] initWithFrame:CGRectZero];
        m_pickView.dataSource = self;
        m_pickView.delegate = self;
        m_pickView.showsSelectionIndicator = YES;
        [self addSubview:m_pickView];
        [m_pickView release];
        
        
        
        m_imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        UIImage *buttonImage = IMAGE(@"pickSelectBac.png", IMAGEPATH_TYPE_1) ;
        UIImage *stretchableButtonImage = [buttonImage stretchableImageWithLeftCapWidth:0 topCapHeight:0];
        m_imageView.backgroundColor = [UIColor colorWithPatternImage:stretchableButtonImage];
        m_imageView.userInteractionEnabled = YES;
        [self addSubview:m_imageView];
        [m_imageView release];
        
        m_cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        m_cancelButton.titleLabel.textColor = GETSKINCOLOR(ACCOUNT_BUTTON_TITLE_COLOR);
        [m_cancelButton setBackgroundImage: IMAGE(@"Button_Sort0.png", IMAGEPATH_TYPE_1) forState:UIControlStateNormal];
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
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY"];
    NSString *DateYear = [formatter stringFromDate: [NSDate date]];
    [formatter release];
    
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM"];
    NSString *Datemonth = [formatter stringFromDate: [NSDate date]];
    [formatter release];
    
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd"];
    NSString *DateDay = [formatter stringFromDate: [NSDate date]];
    [formatter release];
    
    int mid_month = 15000/12/2;
    int mid_day  = 15000/31/2;
    if (m_showyear == 0 || m_showyear >= [DateYear intValue] )
    {
        m_showyear = [DateYear intValue] - 1;
    }
    if (m_showmonth == 0)
    {
        m_showmonth = [Datemonth intValue];
    }
    if (m_showday == 0)
    {
        m_showday = [DateDay intValue];
    }
    m_year = m_showyear;
    m_month = m_showmonth;
    m_day = m_showday;
    [m_pickView selectRow:m_showyear - 1 inComponent:0 animated:NO];
    [m_pickView selectRow:m_showmonth - 1 +  mid_month*12 inComponent:1 animated:NO];
    [m_pickView selectRow:m_showday - 1 + mid_day * 31 inComponent:2 animated:NO];


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
        return 100;
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
    
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY"];
    NSString *DateYear = [formatter stringFromDate: [NSDate date]];
    [formatter release];
    
    UIColor *gray = GETSKINCOLOR(ROUTE_NO_ADDRESS_COLOR);
    UIColor *black = GETSKINCOLOR(ROUTE_ADDRESS_COLOR);
    
    if (component == 0)
    {
        if (row + 1 >= [DateYear intValue])
        {
            labelOnComponent.textColor = gray;
        }
        else
        {
            labelOnComponent.textColor = black;
        }
    }
    else if (component == 1)
    {
        int year = [pickerView selectedRowInComponent:0] + 1;
        if (year >= [DateYear intValue])
        {
            labelOnComponent.textColor = gray;
        }
        else
        {
            labelOnComponent.textColor = black;
        }
    }
    else if (component == 2)
    {
        int year = [pickerView selectedRowInComponent:0] + 1;
        if (year >= [DateYear intValue])
        {
            labelOnComponent.textColor = gray;
        }
        else
        {
            int month = [pickerView selectedRowInComponent:1]%12 + 1;
            if (month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12)
            {
                labelOnComponent.textColor = black;
            }
            else if(month == 2)
            {
                if (((year % 4 == 0) && ( year % 100!=0)) || year%400==0)
                {
                    if (row%31 + 1 == 31 || row%31 + 1 == 30)
                    {
                        labelOnComponent.textColor = gray;
                    }
                    else
                    {
                        labelOnComponent.textColor = black;
                    }
                }
                else
                {
                    if (row%31 + 1 == 31 || row%31 + 1 == 30 || row%31 + 1 == 29)
                    {
                        labelOnComponent.textColor = gray;
                    }
                    else
                    {
                        labelOnComponent.textColor = black;
                    }
                }
            }
            else
            {
                if (row%31 + 1 == 31)
                {
                    labelOnComponent.textColor = gray;
                }
                else
                {
                    labelOnComponent.textColor = black;
                }
            }
        }        
    }
    
    [myView addSubview:labelOnComponent];
    
    //内存管理，建立后释放
    [labelOnComponent release];
    
    
    return [myView autorelease];
    
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 15000;
}

#pragma mark - pick view delegate
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (0 == component)
    {
        return [NSString stringWithFormat:@"%d年",row + 1];
	}
    else if(1 == component)
    {
        return [NSString stringWithFormat:@"%d月",row%12 + 1];
    }
    else if(2 == component)
    {
        return [NSString stringWithFormat:@"%d日",row%31 + 1];
    }
    return nil;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    [pickerView reloadAllComponents];
    
    if (0 == component)
    {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"YYYY"];
        NSString *DateYear = [formatter stringFromDate: [NSDate date]];
        [formatter release];
        if (row + 1 >= [DateYear intValue])
        {
            [pickerView selectRow:[DateYear intValue] - 2 inComponent:0 animated:YES];
        }
        else
        {
            int day = [pickerView selectedRowInComponent:2];
            UIView *view = [pickerView viewForRow:day forComponent:2];
            UILabel *lable = (UILabel *)[view viewWithTag:200];
            if ([lable.textColor isEqual:GETSKINCOLOR(ROUTE_NO_ADDRESS_COLOR)])
            {
                [self pickerView:pickerView didSelectRow:day - 1 inComponent:2];
            }
            else
            {
                [pickerView selectRow:day  inComponent:2 animated:YES];
            }
        }
    }
    else if (1 == component)
    {
        int day = [pickerView selectedRowInComponent:2];
        UIView *view = [pickerView viewForRow:day forComponent:2];
        UILabel *lable = (UILabel *)[view viewWithTag:200];
        if ([lable.textColor isEqual:GETSKINCOLOR(ROUTE_NO_ADDRESS_COLOR)])
        {
            [self pickerView:pickerView didSelectRow:day - 1 inComponent:2];
        }
        else
        {
            [pickerView selectRow:day  inComponent:2 animated:YES];
        }
        
        [pickerView selectRow:row  inComponent:component animated:YES];
    }
    else if (2 == component)
    {
        UIView *view = [pickerView viewForRow:row forComponent:component];
        UILabel *lable = (UILabel *)[view viewWithTag:200];
        if ([lable.textColor isEqual:GETSKINCOLOR(ROUTE_NO_ADDRESS_COLOR)])
        {
            [self pickerView:pickerView didSelectRow:row - 1 inComponent:2];
        }
        else
        {
            [pickerView selectRow:row  inComponent:2 animated:YES];
        }
    }
    
	self.m_year = [[self pickerView:pickerView titleForRow:[pickerView selectedRowInComponent:0] forComponent:0] intValue];
    self.m_month = [[self pickerView:pickerView titleForRow:[pickerView selectedRowInComponent:1] forComponent:1] intValue];
    self.m_day = [[self pickerView:pickerView titleForRow:[pickerView selectedRowInComponent:2] forComponent:2] intValue];
}

- (void)tapGestureRecognizer:(UITapGestureRecognizer *)recognizer
{
    [self ShowOrHiddenPickView:NO Animation:YES];
}

@end


//
//  Plugin_Account_TimeButton.m
//  AutoNavi
//
//  Created by gaozhimin on 13-5-10.
//
//

#import "AccountTimeButton.h"
#import "ANParamValue.h"

#define AccountCountTime @"AccountCountTime"

@interface CountTime : NSObject
{
    NSTimer *m_registTimer;
    NSTimer *m_phoneCheckTimer;
    NSTimer *m_findPSWTimer;
    NSTimer *m_bindPhoneTimer;
    int m_curentRegistCount;
    int m_curentphoneCheckCount;
    int m_curentFindPSWCount;
    int m_curentBindPhoneCount;
}

@end

static CountTime  *g_CountTime = nil;

@implementation CountTime

+ (CountTime *)SharedInstance
{
    if (g_CountTime == nil)
    {
        g_CountTime = [[CountTime alloc] init];
    }
    return g_CountTime;
}

- (void)dealloc
{
    if (m_registTimer)
    {
        [m_registTimer invalidate];
        m_registTimer = nil;
    }
    if (m_phoneCheckTimer)
    {
        [m_phoneCheckTimer invalidate];
        m_phoneCheckTimer = nil;
    }
    if (m_findPSWTimer)
    {
        [m_findPSWTimer invalidate];
        m_findPSWTimer = nil;
    }
    if (m_bindPhoneTimer)
    {
        [m_bindPhoneTimer invalidate];
        m_bindPhoneTimer = nil;
    }
    [super dealloc];
}

- (void)InvalidateTimer:(TIME_BUTTON_VIEW_TYPE)m_viewType
{
    if (m_viewType == REGIST_VIEW)
    {
        if (m_registTimer)
        {
            [m_registTimer invalidate];
            m_registTimer = nil;
        }
        m_curentRegistCount = 0;
    }
    else if (m_viewType == PHONE_CHECK_VIEW)
    {
        if (m_phoneCheckTimer)
        {
            [m_phoneCheckTimer invalidate];
            m_phoneCheckTimer = nil;
        }
        m_curentphoneCheckCount = 0;
    }
    else if (m_viewType == FIND_PSW_VIEW)
    {
        if (m_findPSWTimer)
        {
            
            [m_findPSWTimer invalidate];
            m_findPSWTimer = nil;
        }
        m_curentFindPSWCount = 0;
    }
    else if (m_viewType == BIND_PHONE_VIEW)
    {
        if (m_bindPhoneTimer)
        {
            [m_bindPhoneTimer invalidate];
            m_bindPhoneTimer = nil;
        }
        m_curentBindPhoneCount = 0;
    }
}

- (int)GetTimerCount:(TIME_BUTTON_VIEW_TYPE)m_viewType
{
    if (m_viewType == REGIST_VIEW)
    {
        return m_curentRegistCount;
    }
    else if (m_viewType == PHONE_CHECK_VIEW)
    {
        return m_curentphoneCheckCount;
    }
    else if (m_viewType == FIND_PSW_VIEW)
    {
        return m_curentFindPSWCount;
    }
    else if (m_viewType == BIND_PHONE_VIEW)
    {
        return m_curentBindPhoneCount;
    }
    return 0;
}

- (void)CountViewTime:(TIME_BUTTON_VIEW_TYPE)m_viewType withCount:(int)count
{
    if (m_viewType == REGIST_VIEW)
    {
        m_registTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(registTimerMethod:) userInfo:nil repeats:YES];
        m_curentRegistCount  = count;
    }
    else if (m_viewType == PHONE_CHECK_VIEW)
    {
        m_phoneCheckTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(checkTimerMethod:) userInfo:nil repeats:YES];
        m_curentphoneCheckCount = count;
    }
    else if (m_viewType == FIND_PSW_VIEW)
    {
        m_findPSWTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(findTimerMethod:) userInfo:nil repeats:YES];
        m_curentFindPSWCount = count;
    }
    else if (m_viewType == BIND_PHONE_VIEW)
    {
        m_bindPhoneTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(bindTimerMethod:) userInfo:nil repeats:YES];
        m_curentBindPhoneCount = count;
    }
}

- (void)registTimerMethod:(NSTimer *)timer
{
    m_curentRegistCount --;
    if (m_curentRegistCount <= 0)
    {
        m_curentRegistCount = 0;
        [m_registTimer invalidate];
        m_registTimer = nil;
    }
    NSArray *array = [NSArray arrayWithObjects:[NSNumber numberWithInt:REGIST_VIEW], [NSNumber numberWithInt:m_curentRegistCount],nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:AccountCountTime object:array];
}

- (void)checkTimerMethod:(NSTimer *)timer
{
    m_curentphoneCheckCount --;
    if (m_curentphoneCheckCount <= 0)
    {
        m_curentphoneCheckCount = 0;
        [m_phoneCheckTimer invalidate];
        m_phoneCheckTimer = nil;
    }
    NSArray *array = [NSArray arrayWithObjects:[NSNumber numberWithInt:PHONE_CHECK_VIEW], [NSNumber numberWithInt:m_curentphoneCheckCount],nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:AccountCountTime object:array];
}

- (void)findTimerMethod:(NSTimer *)timer
{
    m_curentFindPSWCount --;
    if (m_curentFindPSWCount <= 0)
    {
        m_curentFindPSWCount = 0;
        [m_findPSWTimer invalidate];
        m_findPSWTimer = nil;
    }
    NSArray *array = [NSArray arrayWithObjects:[NSNumber numberWithInt:FIND_PSW_VIEW], [NSNumber numberWithInt:m_curentFindPSWCount],nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:AccountCountTime object:array];
}

- (void)bindTimerMethod:(NSTimer *)timer
{
    m_curentBindPhoneCount --;
    if (m_curentBindPhoneCount <= 0)
    {
        m_curentBindPhoneCount = 0;
        [m_bindPhoneTimer invalidate];
        m_bindPhoneTimer = nil;
    }
    NSArray *array = [NSArray arrayWithObjects:[NSNumber numberWithInt:BIND_PHONE_VIEW], [NSNumber numberWithInt:m_curentBindPhoneCount],nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:AccountCountTime object:array];
}

@end

@interface AccountTimeButton()
{
    NSTimer *m_timer;
    int m_countdown; //设置的倒计时时间
    CountTime *m_currentCountdown; //当前倒计时时间
    NSString *m_titleNormal;
    TIME_BUTTON_VIEW_TYPE m_viewType;
}

@end

@implementation AccountTimeButton

- (id)initWithFrame:(CGRect)frame countDown:(int)countDown viewType:(TIME_BUTTON_VIEW_TYPE)type
{
    self = [super initWithFrame:frame];
    if (self)
    {
        m_currentCountdown = [CountTime SharedInstance];
        m_countdown = countDown;
        m_viewType = type;
        [self setTitleColor:GETSKINCOLOR(ROUTE_NO_ADDRESS_COLOR) forState:UIControlStateDisabled];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(CountTimeNotify:) name:AccountCountTime object:nil];
        [self loadButtonStatus];
        [self setTitleColor:GETSKINCOLOR(ACCOUNT_GET_VERIFICATION)  forState:UIControlStateNormal];
        UIImage* buttonImageNormal1 = IMAGE(@"icallsendcode.png", IMAGEPATH_TYPE_1);
        UIImage* stretchableButtonImageNormal = [buttonImageNormal1 stretchableImageWithLeftCapWidth:buttonImageNormal1.size.width/2 topCapHeight:buttonImageNormal1.size.height/2];
        UIImage* buttonImagePressed = IMAGE(@"icallsendcode_on.png", IMAGEPATH_TYPE_1);
        UIImage* stretchableButtonImagePressed = [buttonImagePressed stretchableImageWithLeftCapWidth:buttonImageNormal1.size.width/2 topCapHeight:buttonImageNormal1.size.height/2];
        [self setBackgroundImage:stretchableButtonImageNormal forState:UIControlStateNormal];
        [self setBackgroundImage:stretchableButtonImagePressed forState:(UIControlState)UIControlStateHighlighted];
        
        [self setTitle:STR(@"Account_GetVerification", Localize_Account) forState:(UIControlState)UIControlStateNormal];
        
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame countDown:(int)countDown
{
    return [self initWithFrame:frame countDown:countDown viewType:REGIST_VIEW];
}

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame countDown:0];
}

- (void)loadButtonStatus //设定当前按钮状态
{
    int count = [m_currentCountdown GetTimerCount:m_viewType];
    if (count != 0)
    {
        self.enabled = NO;
        [self setTitle:[NSString stringWithFormat:STR(@"Account_Seconds", Localize_Account),count] forState:UIControlStateDisabled];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}


- (void)CountTimeNotify:(NSNotification *)notify
{
    NSArray *array = [notify object];
    if ([array count] < 2)
    {
        return;
    }
    TIME_BUTTON_VIEW_TYPE type = [[array objectAtIndex:0] intValue];
    if (m_viewType == type)
    {
        int count = [[array objectAtIndex:1] intValue];
        if (count == 0)
        {
            self.enabled = YES;
        }
        else
        {
            [self setTitle:[NSString stringWithFormat:STR(@"Account_Seconds", Localize_Account),count] forState:UIControlStateDisabled];
        }
    }
}

- (void)ButtonPressd
{
    [m_currentCountdown CountViewTime:m_viewType withCount:m_countdown];
    [self setTitle:[NSString stringWithFormat:STR(@"Account_Seconds", Localize_Account),m_countdown] forState:UIControlStateDisabled];
    self.enabled = NO;
}

- (void)ButtonActive:(TIME_BUTTON_VIEW_TYPE)viewType
{
    [m_currentCountdown InvalidateTimer:viewType];
    self.enabled = YES;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end

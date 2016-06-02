//
//  CustomTrafficPlaySound.m
//  AutoNavi
//
//  Created by gaozhimin on 13-5-25.
//
//

#import "CustomTrafficPlaySound.h"
#import "CustomRealTimeTraffic.h"
#import "MWTTS.h"
#import "ANParamValue.h"

static CustomTrafficPlaySound *g_CustomTrafficPlaySound = nil;

@interface CustomTrafficPlaySound ()
{
    NSTimer *m_timer;
    int m_distanceFromStart;//播报点距起点距离
    BOOL isPlaySound;   //是否正在播报语音，yes：正在播报，no：没有播报
    BOOL shouldPlaySound; //是否需要播报语音，yes：需要播报，no：不需要不播报
}

- (void)PlaySoundTimer:(NSTimer *)timer;
@end

@implementation CustomTrafficPlaySound

+ (CustomTrafficPlaySound *)SharedInstance
{
    if (g_CustomTrafficPlaySound == nil)
    {
        g_CustomTrafficPlaySound = [[CustomTrafficPlaySound alloc] init];
    }
    return g_CustomTrafficPlaySound;
}

- (id)init
{
    if (self = [super init])
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(routeListenNotification:) name:NOTIFY_STARTTODEMO object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(routeListenNotification:) name:NOTIFY_STARTTODEMO2 object:nil];
        isPlaySound = NO;
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (void)routeListenNotification:(NSNotification *)notification  //路径演算时，将播报点距离清零
{
    m_distanceFromStart = 0;
    shouldPlaySound = YES;
}

- (void)StartPlaySound
{
    if (m_timer)
    {
        if (shouldPlaySound && m_distanceFromStart == 0 && isPlaySound == NO)
        {
            shouldPlaySound = NO;
            isPlaySound = YES;
            [self performSelector:@selector(PlaySoundTimer:) withObject:nil afterDelay:2.0f];
        }
        return;
    }
    m_timer = [NSTimer scheduledTimerWithTimeInterval:90.0f target:self selector:@selector(PlaySoundTimer:) userInfo:nil repeats:YES];
    if (m_distanceFromStart != 0) {
        [m_timer fire];
    }
    //[self PlaySoundTimer:nil];
}

- (void)StopPlaySound
{
    if (m_timer)
    {
        [m_timer invalidate];
        m_timer = nil;
    }
    m_distanceFromStart = 0;
}

- (void)PlaySoundWithObject:(NSString *)sound
{
    if ([[MWTTS SharedInstance] status] == NO)
    {
        isPlaySound = NO;
        [[MWTTS SharedInstance] playSoundWithString:sound priority:TTSPRIORITY_LOW];
    }
    else
    {
        isPlaySound = YES;
        [self performSelector:@selector(PlaySoundWithObject:) withObject:sound afterDelay:1.0f];
    }
}

- (void)PlaySoundTimer:(NSTimer *)timer
{
    int count = [[CustomRealTimeTraffic sharedInstance] RtcInfoArrayCount];
    int playIndex = -1;
    for (int i = 0; i < count; i++)
    {
        int distanceFromStart = [[CustomRealTimeTraffic sharedInstance] RtcSpecificInfoDistanceFromStart:i];
        int distance = [[CustomRealTimeTraffic sharedInstance] RtcSpecificInfoDistanceFromCar:i];
        int status = [[CustomRealTimeTraffic sharedInstance] RtcSpecificInfoStatus:i];
        if (distanceFromStart == 0 && m_distanceFromStart == 0)
        {
            playIndex = i;
            m_distanceFromStart = 1;
            break;
        }
        if (distance <= 5000  && distanceFromStart > m_distanceFromStart)
        {
            if (status == UI_RTC_STREAM_CROWDED || status == UI_RTC_STREAM_SLOW)
            {
                playIndex = i;
                m_distanceFromStart = distanceFromStart;
                break;
            }
        }
    }
    
    if (playIndex != -1)
    {
        NSString *roadName = [[CustomRealTimeTraffic sharedInstance] RtcSpecificInfoName:playIndex];
        int distance = [[CustomRealTimeTraffic sharedInstance] RtcSpecificInfoDistanceFromCar:playIndex];
        int status = [[CustomRealTimeTraffic sharedInstance] RtcSpecificInfoStatus:playIndex];
        
        
        if (distance <= 101)
        {
            if (status == UI_RTC_STREAM_CROWDED)
            {
                [self PlaySoundWithObject:[NSString stringWithFormat:@"前方%@拥堵",roadName]];
            }
            else if (status == UI_RTC_STREAM_SLOW)
            {
                [self PlaySoundWithObject:[NSString stringWithFormat:@"前方%@缓行",roadName]];
            }
            return;
        }
        
        NSString *str_distance;
        if (distance >= 1000)
        {
            str_distance = [NSString stringWithFormat:@"%0.1fkm",distance/1000.0];
        }
        else
        {
            int index = distance/50;
            int play_distance = index * 50;
            str_distance  = [NSString stringWithFormat:@"%d米",play_distance];
        }
        
        
        if (status == UI_RTC_STREAM_CROWDED)
        {
            [self PlaySoundWithObject:[NSString stringWithFormat:@"前方%@,%@拥堵",str_distance,roadName]];
        }
        else if (status == UI_RTC_STREAM_SLOW)
        {
            [self PlaySoundWithObject:[NSString stringWithFormat:@"前方%@,%@缓行",str_distance,roadName]];
        }
    }
    else
    {
        isPlaySound = NO;
    }
}



@end

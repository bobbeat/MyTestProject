//
//  iFlySpeechService.m
//  AutoNavi
//
//  Created by lin jingjie on 11-12-14.
//  Copyright 2011 autonavi. All rights reserved.
//

#import "iFlySpeechService.h"
#import "iflyMSC/IFlySpeechRecognizer.h"
#import "iflyMSC/IFlySpeechUtility.h"
#import "iflyMSC/IFlySetting.h"

#define H_CONTROL_ORIGIN CGPointMake(SCREENWIDTH/2, SCREENHEIGHT/2)
#define APPID @"4e9175b8" // appid for 开心网 iphone，请勿修改！
#define TIMEOUT @"20000"

static NSMutableString *g_iflyResultStr = nil;

@implementation iFlySpeechService
@synthesize voiceRecognizeController;
-(id)initWithView:(UIView *) view Lon:(int)lon Lat:(int)lat AdminCode:(int)adminCode
{
	self = [super init];

    //创建语音配置,appid必须要传入，仅执行一次则可
    NSString *initParam = [[NSString alloc] initWithFormat:
                           @"server_url=http://autonavi.voicecloud.cn:1028/index.htm,search_best_url=false,appid=%@",APPID];
    //所有服务启动前，需要确保执行createUtility
    [IFlySpeechUtility createUtility:initParam];
    [initParam release];
    
    [IFlySetting setLogFile:LVL_NONE];
    [IFlySetting showLogcat:NO]; //控制台不打log
	// 识别控件
	self.voiceRecognizeController = [[IFlyRecognizerView alloc] initWithOrigin:H_CONTROL_ORIGIN atCenter:YES initParam:nil relative:NO];
	[self.voiceRecognizeController release];
	self.voiceRecognizeController.delegate = self;
    // 参数设置
    [self setPosition:lon Lat:lat AdminCode:adminCode];
    [self.voiceRecognizeController setParameter:@"domain" value:@"autonavi"];
    [self.voiceRecognizeController setParameter:@"sample_rate" value:@"16000"];
    [self.voiceRecognizeController setParameter:@"vad_eos" value:@"1800"];
    [self.voiceRecognizeController setParameter:@"vad_bos" value:@"1500"];
    
    [self.voiceRecognizeController setParameter:@"asr_ptt" value:@"0"];
    [self.voiceRecognizeController setParameter:@"plain_result" value:@"0"];
    [self.voiceRecognizeController setParameter:@"result_type" value:@"plain"];
    //设置为录音方式
    [self.voiceRecognizeController setParameter:@"audio_source" value:IFLY_AUDIO_SOURCE_MIC];
    //不保存录音文件
    [self.voiceRecognizeController setParameter:@"asr_audio_path" value:nil];
    
    [self setViewOrientation];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeDeviceOrientation:) name:UIApplicationWillChangeStatusBarOrientationNotification object:NULL];
	return self;
}

- (void) updateResult:(NSString *)resultText{
    
    [speechServiceDelegate speechResultText:resultText];
}

- (void) errorHappend:(NSNumber *)errorCode
{
    int code = [errorCode intValue];
    if (code == 0) {
        [self performSelectorOnMainThread:@selector(updateResult:)
                               withObject:g_iflyResultStr
                            waitUntilDone:YES];
        if (g_iflyResultStr)
        {
            [g_iflyResultStr release];
            g_iflyResultStr = nil;
        }
    }
	[speechServiceDelegate errorOccur:[errorCode intValue]];
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if(voiceRecognizeController)
    {
        voiceRecognizeController.delegate = nil;
    }
    [voiceRecognizeController removeFromSuperview];
    voiceRecognizeController = nil;
	[super dealloc];
}
#pragma mark IFlyRecognizeControl Callback

- (void)onResult:(IFlyRecognizerView *)iFlyRecognizerView theResult:(NSArray *)resultArray
{
    if (g_iflyResultStr == nil)
    {
        g_iflyResultStr = [[NSMutableString alloc] init];
    }
	NSDictionary *dic = (NSDictionary*)[resultArray objectAtIndex:0];
    if ([dic count]  > 0)
    {
        [g_iflyResultStr appendString:[[dic allKeys] lastObject]];
    }
}

- (void)onEnd:(IFlyRecognizerView *)iFlyRecognizerView theError:(IFlySpeechError *)error
{
	[self performSelectorOnMainThread:@selector(errorHappend:)
						   withObject:[NSNumber numberWithInt:error.errorCode]
						waitUntilDone:YES];
}
#pragma mark SpeechService Method
-(void)setResultType:(int)resultType
{
	mResultType = resultType;
}

-(void)setPosition:(int)gaoLon Lat:(int)gaoLat AdminCode:(int)adminCode
{
    [self.voiceRecognizeController setParameter:@"params" value:[NSString  stringWithFormat:@"area=%.6f;%.6f;%d",gaoLon/1000000.0,gaoLat/1000000.0,adminCode]];
}

-(void)start
{
	if([voiceRecognizeController start])
	{
		//[self disableButton];
	}
}

- (void)setViewOrientation
{
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    [self.voiceRecognizeController rotationToInterfaceOrientation:interfaceOrientation];
    if ((NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1))
    {

        if (interfaceOrientation == UIInterfaceOrientationLandscapeRight || interfaceOrientation == UIInterfaceOrientationLandscapeLeft)
        {
            self.voiceRecognizeController.frame = CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGHT);
            for (UIView *view in self.voiceRecognizeController.subviews)
            {
                if ([[[view class] description] isEqualToString:@"IFlyRecognizerViewImp"])
                {
                    CGPoint point = {0};
                    point.x = SCREENWIDTH/2;
                    point.y = SCREENHEIGHT/2;
                    view.center = point;
                }
            }
        }
        
        CGFloat angle = (M_PI / 180.0) * 90;
        CGAffineTransform at =CGAffineTransformMakeRotation(0);
        if (interfaceOrientation == UIInterfaceOrientationLandscapeRight)
        {
            angle = (M_PI / 180.0) * -90;
            at =CGAffineTransformMakeRotation(angle);
            [self.voiceRecognizeController setTransform:at];
            
            CGPoint point = {0};
            point.x = SCREENHEIGHT/2;
            point.y = SCREENWIDTH/2;
            self.voiceRecognizeController.center = point;
        }
        else if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft)
        {
            angle = (M_PI / 180.0) * 90;
            at =CGAffineTransformMakeRotation(angle);
            [self.voiceRecognizeController setTransform:at];
            
            CGPoint point = {0};
            point.x = SCREENHEIGHT/2;
            point.y = SCREENWIDTH/2;
            self.voiceRecognizeController.center = point;
        }
        else if (interfaceOrientation == UIInterfaceOrientationPortrait)
        {
            angle = (M_PI / 180.0) * 0;
            at =CGAffineTransformMakeRotation(angle);
            [self.voiceRecognizeController setTransform:at];
            
            CGPoint point = {0};
            point.x = SCREENWIDTH/2;
            point.y = SCREENHEIGHT/2;
            self.voiceRecognizeController.center = point;
        }
        else if (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
        {
            angle = (M_PI / 180.0) * 180;
            at =CGAffineTransformMakeRotation(angle);
            [self.voiceRecognizeController setTransform:at];
            
            CGPoint point = {0};
            point.x = SCREENWIDTH/2;
            point.y = SCREENHEIGHT/2;
            self.voiceRecognizeController.center = point;
        }
        
    }
}

#pragma mark - UIDeviceOrientationDidChangeNotification
- (void)changeDeviceOrientation:(NSNotification *)notification {
    
    UIDeviceOrientation interfaceOrientation = [[UIDevice currentDevice] orientation];
    [self.voiceRecognizeController rotationToInterfaceOrientation:interfaceOrientation];
    if ((NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1))
    {
        
        CGFloat angle = (M_PI / 180.0) * 90;
        CGAffineTransform at =CGAffineTransformMakeRotation(0);
        
        if (interfaceOrientation == UIDeviceOrientationLandscapeLeft)
        {
            angle = (M_PI / 180.0) * -90;
            at =CGAffineTransformMakeRotation(angle);
            [self.voiceRecognizeController setTransform:at];
            
            CGPoint point = {0};
            point.x = SCREENHEIGHT/2;
            point.y = SCREENWIDTH/2;
            self.voiceRecognizeController.center = point;
        }
        else if (interfaceOrientation == UIDeviceOrientationLandscapeRight)
        {
            angle = (M_PI / 180.0) * 90;
            at =CGAffineTransformMakeRotation(angle);
            [self.voiceRecognizeController setTransform:at];
            
            CGPoint point = {0};
            point.x = SCREENHEIGHT/2;
            point.y = SCREENWIDTH/2;
            self.voiceRecognizeController.center = point;
        }
        else if (interfaceOrientation == UIDeviceOrientationPortrait)
        {
            angle = (M_PI / 180.0) * 0;
            at =CGAffineTransformMakeRotation(angle);
            [self.voiceRecognizeController setTransform:at];
            
            CGPoint point = {0};
            point.x = SCREENWIDTH/2;
            point.y = SCREENHEIGHT/2;
            self.voiceRecognizeController.center = point;
        }
        else if (interfaceOrientation == UIDeviceOrientationPortraitUpsideDown)
        {
            angle = (M_PI / 180.0) * 180;
            at =CGAffineTransformMakeRotation(angle);
            [self.voiceRecognizeController setTransform:at];
            
            CGPoint point = {0};
            point.x = SCREENWIDTH/2;
            point.y = SCREENHEIGHT/2;
            self.voiceRecognizeController.center = point;
        }
        
    }
   

}

@end

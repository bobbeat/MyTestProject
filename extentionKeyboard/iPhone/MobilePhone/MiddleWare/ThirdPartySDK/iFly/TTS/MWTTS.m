//
//  MWTTS.m
//  AutoNavi
//
//  Created by gaozhimin on 14-9-3.
//
//

#import "MWTTS.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <CoreTelephony/CTCallCenter.h>
#import <CoreTelephony/CTCall.h>

extern int TTS_fun(char *szOutputFile,const char *pszText,int codeType,const char *sourceFileFolder,int speakerIndex,int ttsVoiceSpeed,int ttsUsePrompts);

@interface MWTTS()<AVAudioPlayerDelegate>
{
@private
    BOOL _interruptedOnPlayback;
    BOOL _stoping;
    BOOL _transeforming;
    BOOL backgroundSoundFlag;
    BOOL isOtherShouldDuck;         //是否降低其他程序声音
    BOOL isSystemMuted;             //系统静音
    
	AVAudioPlayer *_appSoundPlayer;
    NSMutableArray *TTSPlayArray;
}

@property (nonatomic,assign) Role_Player rolePlayer;  //播报角色
@property (nonatomic,copy) NSString* folderName;  //播报文件夹名称
@property (nonatomic,assign) int playerSpeed;  //播报语速
@property (nonatomic,assign) BOOL ttsUsePrompts; //是否为录音方式


@property(nonatomic,readonly) __block BOOL isPlaying;                    //是否正在播放
@property(nonatomic,copy) NSString *playString;                  //语音播报内容


@end


@implementation MWTTS

@synthesize rolePlayer,playerSpeed,ttsUsePrompts,isPlaying,playString,folderName;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    CRELEASE(TTSPlayArray);
    self.playString = nil;
    self.folderName = nil;
    [super dealloc];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(TTSDidEnterBackgroundNotification:) name:UIApplicationDidEnterBackgroundNotification object: nil];
        [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(TTSWillResignActiveNotification:) name:UIApplicationWillResignActiveNotification object: nil];
        [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(TTSDidBecomeActiveNotification:) name:UIApplicationDidBecomeActiveNotification object: nil];
        CTCallCenter *callCenter = [[CTCallCenter alloc] init];
        
        TTSPlayArray = [[NSMutableArray alloc] init];
        __block ANParamValue *weakInstance = [ANParamValue sharedInstance];
        callCenter.callEventHandler=^(CTCall* call){
            if (call.callState == CTCallStateIncoming) {
                _interruptedOnPlayback = YES;
                NSLog(@"Call incoming");
            }
            else if (call.callState == CTCallStateDialing){
                _interruptedOnPlayback = YES;
                if (weakInstance.isReq95190Des == 1)
                {
                    weakInstance.isReq95190Des = 2;
                }
                NSLog(@"Call Dialing");
            }
            else if (call.callState == CTCallStateConnected){
                NSLog(@"Call Connected");
            }
            else if (call.callState == CTCallStateDisconnected){
                _interruptedOnPlayback = NO;
                NSLog(@"Call Disconnected");
            }
            else
            {
                NSLog(@"Call Unkown");
            }
        };
    }
    return self;
}

+ (instancetype)SharedInstance
{
    static MWTTS *tts = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tts = [[MWTTS alloc] init];
    });
    return tts;
}

#pragma mark -
#pragma mark public method
/*
 * @brief 根据字符串播报语音
 * @param str 播报字符串
 * @param priority 播报优先级
 */
- (void)playSoundWithString:(NSString *)str priority:(TTSPRIORITY)priority
{
    __block MWTTS *weakSelf = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf TTSAddPlayItemToPlayList:str priority:priority ttsType:TTSPLAYTYPE_STRING];
    });
}

/*
 * @brief 根据wav文件路径播报语音
 * @param path wav文件路径
 * @param priority 播报优先级
 */
- (void)playSoundWithPath:(NSString *)path priority:(TTSPRIORITY)priority
{
    __block MWTTS *weakSelf = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf TTSAddPlayItemToPlayList:path priority:priority ttsType:TTSPLAYTYPE_WAV];
    });
}

/*
 * @brief 设置播报角色 @seeRole_Player
 * @param role 要设置的播报角色
 */
- (void)SetTTSRole:(Role_Player)role
{
    if (role == 0) {
        if (fontType == 2)
        {
            role = Role_Catherine;
        }
        else
        {
            role = Role_XIAOYAN;
        }
    }
    self.rolePlayer = role;
}

/*
 * @brief 获取播报角色 @seeRole_Player
 * @return Role_Player 当前的播报角色
 */
- (Role_Player)GetTTSRole
{
    if (self.rolePlayer == 0)
    {
        if (fontType == 2)
        {
            return Role_Catherine;
        }
        else
        {
            return Role_XIAOYAN;
        }
    }
    return self.rolePlayer;
}

/*
 * @brief 设置播报文件夹名称
 * @return folder 播报文件夹名称
 */
- (void)SetTTSFolder:(NSString *)folder
{
    self.folderName = folder;
}

/*
 * @brief 设置播报语速
 * @param speed 要设置的播报语速
 */
- (void)SetTTSSpeed:(int)speed
{
    self.playerSpeed = speed;
}

/*
 * @brief 设置是否为录音
 * @param prompts 是否为录音
 */
- (void)SetTTSUsePrompts:(BOOL)prompts
{
    self.ttsUsePrompts = prompts;
}


#pragma mark -
#pragma mark private method

#pragma mark -
#pragma mark Foundation Method

- (void)playWavByPath:(NSString *)path
{
    if (!path) {
        return;
    }
    if (![self isAllowedPlay])
    {
        return;
    }
    
    [self TTSSetPlayingStatus:path];
    
    NSLog(@"playWavByPath = %@",path);
    
    [self playByVoicePath:path];
}
-(void)playByVoicePath:(NSString *)path
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_sync(queue, ^{
        
        BOOL isBackNavi = [[MWPreference sharedInstance] getValue:PREF_BACKGROUND_NAVI];
        if (isBackNavi) {
            [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: nil]; //支持后台播报语音
        }
        else{
            [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryAmbient error: nil];  //不支持后台播报语音
            
        }
       
        [self setOtherMixableAudioShouldDuck:YES];
        
        [[AVAudioSession sharedInstance] setActive:YES error:nil];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if([fileManager fileExistsAtPath:path] == 0)
        {
            isPlaying = NO;
            return;
        }
        
        if (_appSoundPlayer && _appSoundPlayer.isPlaying)
        {
            return;
        }
        
        NSError * error = nil;
        NSURL *tts_url = [[NSURL alloc] initFileURLWithPath: path];
        
        if(_appSoundPlayer != nil)
        {
            [_appSoundPlayer release];
            _appSoundPlayer = nil;
        }
        _appSoundPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:tts_url  error: &error];
        [tts_url release];
        
        if(( 0 != error.code ) || ( _appSoundPlayer == nil ))
        {
            isPlaying = NO;
            
            if(_appSoundPlayer != nil)
            {
                [_appSoundPlayer release];
                _appSoundPlayer = nil;
            }
            return;
            
        }
        BOOL res = YES;
        [_appSoundPlayer setVolume: 1.0];
        [_appSoundPlayer setDelegate: self];
        
        res = [_appSoundPlayer prepareToPlay];
        
        if (res == YES)
        {
            
            res = [_appSoundPlayer play];
            
            if (res == NO)
            {
                isPlaying = NO;
                if(_appSoundPlayer != nil)
                {
                    [_appSoundPlayer release];
                    _appSoundPlayer = nil;
                }
                return;
            }
        }
        else
        {
            isPlaying = NO;
            if(_appSoundPlayer != nil)
            {
                [_appSoundPlayer release];
                _appSoundPlayer = nil;
            }
            return;
        }
        
        return;
    });
    
}

-(void)playByStr:(NSString *)str
{
    if (!str) {
        return;
    }
    //转换str为音频，调用TTS库，然后在完成的处理方法中播放
    if (![self isAllowedPlay])
    {
        return;
    }
    
    [self TTSSetPlayingStatus:str];
    
    NSString * text;
    NSLog(@"%@",str);
    if([str hasPrefix:@"[z1]"])
    {
        text = [NSString stringWithFormat:@"%@",str];
    }
    else
    {
        text = [NSString stringWithFormat:@"[z1]%@",str];
    }
    [NSThread detachNewThreadSelector:@selector(transformThread:) toTarget:self
						   withObject:text];
}


-(void)stop
{
    if(_transeforming)
    {
        _stoping = YES;
    }
    else if(_appSoundPlayer != nil)
    {
        if (_appSoundPlayer.playing)
        {
            [_appSoundPlayer stop];
        }
        
    }
    isPlaying = NO;
}

- (BOOL)status
{
    return isPlaying;
}

//设置当导航语音播报时是否降低其他程序的音量
- (void)setOtherMixableAudioShouldDuck:(BOOL)isDuck
{
    
    isOtherShouldDuck = isDuck;
    UInt32 doSetProperty;
    if (isDuck) {
        doSetProperty = true;
        AudioSessionSetProperty (
                                 kAudioSessionProperty_OtherMixableAudioShouldDuck,
                                 sizeof (doSetProperty),
                                 &doSetProperty
                                 );
    }
    else{
        doSetProperty = true;
        //支持多种语音混合
        AudioSessionSetProperty (
                                 kAudioSessionProperty_OverrideCategoryMixWithOthers,
                                 sizeof (doSetProperty),
                                 &doSetProperty
                                 );
    }
    
}



- (void)isMuted:(BOOL)muted {
    // NSLog(@"ismuted:%d",muted);
    isSystemMuted = muted;
    
    if (isSystemMuted && isPlaying ) {
        [self stop];
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
        dispatch_async(queue, ^{
            [[AVAudioSession sharedInstance] setActive:NO error:nil];
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                
            });
        });
    }
}

- (BOOL)isAllowedPlay
{
    
    int bMute;
    int isPath = 0;
    int isBackground = 0;
    GDBL_GetParam(G_MUTE , &bMute);
    GDBL_GetParam(G_GUIDE_STATUS, &isPath);
    GDBL_GetParam(G_BACKGROUND_MODE, &isBackground);
    
    
    if ((isPlaying || _interruptedOnPlayback || bMute || (!isPath && isBackground ) || (_appSoundPlayer && _appSoundPlayer.isPlaying)))
    {
        return NO;
    }
    
    backgroundSoundFlag = NO;
    isPlaying = YES;
    return YES;
}

- (void)TTSAddPlayItemToPlayList:(NSString *)str priority:(TTSPRIORITY)mPriority ttsType:(TTSPLAYTYPE)ttsPlayType
{
    int bMute;
    int isPath = 0;
    int isBackground = 0;
    GDBL_GetParam(G_MUTE , &bMute);
    GDBL_GetParam(G_GUIDE_STATUS, &isPath);
    GDBL_GetParam(G_BACKGROUND_MODE, &isBackground);
    
    
    if ((!str || _interruptedOnPlayback || bMute || (!isPath && isBackground) ) || (mPriority == TTSPRIORITY_LOW && isPlaying) || [ANParamValue sharedInstance].isWarningView)//modify by ly for[ANParamValue sharedInstance].isWarningView9.0版本暂时这样处理，9.0以后的版本语音要定义一个参数来确定是否播报 at 2014.08.09
    {
        
        return;
    }
    
    MWTTSItem *playItem = [self TTSGetPlayItemWithStatus:TTSSTATUS_PLAYING];
    
    if (((mPriority == TTSPRIORITY_SUPERHIGHT || mPriority == TTSPRIORITY_NOINTERRUPT) && _appSoundPlayer &&_appSoundPlayer.isPlaying && playItem && playItem.playPriority != TTSPRIORITY_NOINTERRUPT) || (mPriority == TTSPRIORITY_INTERRUPTSELF && _appSoundPlayer && _appSoundPlayer.isPlaying && playItem && playItem.playPriority == TTSPRIORITY_INTERRUPTSELF)) {
        
        
        [self stop];
        [self TTSRemovePlayItemForStatus:TTSSTATUS_PLAYING];
        
        MWTTSItem *item = [[MWTTSItem alloc] init];
        
        if (ttsPlayType == TTSPLAYTYPE_STRING) {
            item.playString = str;
        }
        else if (ttsPlayType == TTSPLAYTYPE_WAV)
        {
            item.playPath = str;
        }
        item.playType = ttsPlayType;
        item.playPriority = mPriority;
        item.playStatus = TTSSTATUS_WAITING;
        
        [TTSPlayArray addObject:item];
        
        [item release];
        
        [self TTSCheckForPlay];
        
        return;
        
    }
    
    MWTTSItem *item = [[MWTTSItem alloc] init];
    
    if (ttsPlayType == TTSPLAYTYPE_STRING) {
        item.playString = str;
    }
    else if (ttsPlayType == TTSPLAYTYPE_WAV)
    {
        item.playPath = str;
    }
    item.playType = ttsPlayType;
    item.playPriority = mPriority;
    item.playStatus = TTSSTATUS_WAITING;
    
    [TTSPlayArray addObject:item];
    
    [item release];
    
    [self TTSCheckForPlay];
    
    return;
}

- (BOOL)TTSRemovePlayItemForStatus:(TTSSTATUS)status
{
    BOOL res = NO;
    
    NSMutableArray *removeArray = [[NSMutableArray alloc] init];
    
    for (MWTTSItem *item in TTSPlayArray)
    {
        
        if (item.playStatus == status)
        {
            [removeArray addObject:item];
        }
    }
    
    if (removeArray && removeArray.count > 0)
    {
        [TTSPlayArray removeObjectsInArray:removeArray];
        
        res = YES;
    }
    
    [removeArray release];
    
    return res;
}

- (MWTTSItem *)TTSGetPlayItemWithStatus:(TTSSTATUS)status
{
    for (MWTTSItem *item in TTSPlayArray) {
        if (item.playStatus == status) {
            return item;
        }
    }
    
    return nil;
}

- (BOOL)TTSCheckForPlay
{
    int noInterruptIndex = -1;
    int superHightIndex = -1;
    int interruptSelfIndex = -1;
    int hightIndex = -1;
    int normalIndex = -1;
    int lowIndex = -1;
    int playArrayCount = TTSPlayArray.count;
    
    for (int i = 0; i < playArrayCount; i++) {
        
        MWTTSItem *item = [TTSPlayArray objectAtIndex:i];
        
        if (item.playStatus == TTSSTATUS_WAITING && item.playPriority == TTSPRIORITY_NOINTERRUPT && noInterruptIndex < 0) {
            
            noInterruptIndex = i;
        }
        else if (item.playStatus == TTSSTATUS_WAITING && item.playPriority == TTSPRIORITY_SUPERHIGHT && superHightIndex < 0) {
            
            superHightIndex = i;
        }
        else if (item.playStatus == TTSSTATUS_WAITING && item.playPriority == TTSPRIORITY_INTERRUPTSELF && interruptSelfIndex < 0) {
            
            interruptSelfIndex = i;
        }
        else if (item.playStatus == TTSSTATUS_WAITING && item.playPriority == TTSPRIORITY_HIGHT && hightIndex < 0)
        {
            hightIndex = i;
        }
        else if (item.playStatus == TTSSTATUS_WAITING && item.playPriority == TTSPRIORITY_NORMAL && normalIndex < 0)
        {
            normalIndex = i;
        }
        else if (item.playStatus == TTSSTATUS_WAITING && item.playPriority == TTSPRIORITY_LOW && lowIndex < 0)
        {
            lowIndex = i;
        }
        
    }
    
    if (noInterruptIndex >= 0) {
        
        MWTTSItem *playItem = [TTSPlayArray objectAtIndex:noInterruptIndex];
        
        if (playItem.playType == TTSPLAYTYPE_STRING)
        {
            [self playByStr:playItem.playString];
        }
        else if (playItem.playType == TTSPLAYTYPE_WAV)
        {
            [self playWavByPath:playItem.playPath];
        }
        
        
    }
    else if (superHightIndex >= 0) {
        
        MWTTSItem *playItem = [TTSPlayArray objectAtIndex:superHightIndex];
        
        if (playItem.playType == TTSPLAYTYPE_STRING)
        {
            [self playByStr:playItem.playString];
        }
        else if (playItem.playType == TTSPLAYTYPE_WAV)
        {
            [self playWavByPath:playItem.playPath];
        }
        
        
    }
    else if (interruptSelfIndex >= 0) {
        
        MWTTSItem *playItem = [TTSPlayArray objectAtIndex:interruptSelfIndex];
        
        if (playItem.playType == TTSPLAYTYPE_STRING)
        {
            [self playByStr:playItem.playString];
        }
        else if (playItem.playType == TTSPLAYTYPE_WAV)
        {
            [self playWavByPath:playItem.playPath];
        }
        
        
    }
    else if (hightIndex >= 0)
    {
        MWTTSItem *playItem = [TTSPlayArray objectAtIndex:hightIndex];
        
        if (playItem.playType == TTSPLAYTYPE_STRING)
        {
            [self playByStr:playItem.playString];
        }
        else if (playItem.playType == TTSPLAYTYPE_WAV)
        {
            [self playWavByPath:playItem.playPath];
        }
    }
    else if (normalIndex >= 0)
    {
        MWTTSItem *playItem = [TTSPlayArray objectAtIndex:normalIndex];
        
        if (playItem.playType == TTSPLAYTYPE_STRING)
        {
            [self playByStr:playItem.playString];
        }
        else if (playItem.playType == TTSPLAYTYPE_WAV)
        {
            [self playWavByPath:playItem.playPath];
        }
    }
    else if (lowIndex >= 0)
    {
        MWTTSItem *playItem = [TTSPlayArray objectAtIndex:lowIndex];
        
        if (playItem.playType == TTSPLAYTYPE_STRING)
        {
            [self playByStr:playItem.playString];
        }
        else if (playItem.playType == TTSPLAYTYPE_WAV)
        {
            [self playWavByPath:playItem.playPath];
        }
    }
    
    return YES;
}


- (void)TTSSetPlayingStatus:(NSString *)str
{
    for (MWTTSItem *item in TTSPlayArray) {
        if (item.playType == TTSPLAYTYPE_STRING && [item.playString isEqualToString:str]) {
            item.playStatus = TTSSTATUS_PLAYING;
        }
        else if (item.playType == TTSPLAYTYPE_WAV && [item.playPath isEqualToString:str])
        {
            item.playStatus = TTSSTATUS_PLAYING;
        }
    }
}

#pragma mark 音频转换

-(void)transeformDone:(NSString *)voicePath
{
    if(_stoping)
    {
        _stoping = NO;
        isPlaying = NO;//add by hlf for 有时语音播报无声音处理 at 2014.08.21
        return;
    }
    [self playByVoicePath:voicePath];
}

-(void)transeformFail
{
    isPlaying = NO;
}

-(void)strToVoice:(NSString *)str
{
    self.playString = str;
    char szOutputFilePath[512] = {0};
    NSString *docPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    sprintf(szOutputFilePath, "%s/VoiceData.wav",[docPath UTF8String]);
    
    NSString *ttsResourcePath = nil;
    if (self.rolePlayer == Role_Catherine)
    {
        ttsResourcePath = [tts_path stringByAppendingPathComponent:@"Catherine"] ;
    }
    else if (self.rolePlayer == Role_XIAOYAN || self.rolePlayer == 0)  //等于0是为了容错，开机进来没有设置角色时，默认为xiaoy
    {
        ttsResourcePath = [tts_path stringByAppendingPathComponent:@"XiaoYan"] ;
    }
    else
    {
        ttsResourcePath = [Dialect_path stringByAppendingPathComponent:self.folderName];
    }
    
    if(TTS_fun(szOutputFilePath,[str UTF8String],1,[ttsResourcePath UTF8String],self.rolePlayer,self.playerSpeed,self.ttsUsePrompts))
    {
        NSString * strPath = [NSString stringWithFormat:@"%s",szOutputFilePath];
        [self transeformDone:strPath];
    }
    else
    {
        [self performSelectorOnMainThread:@selector(transeformFail) withObject:nil waitUntilDone:NO];
    }
    
}
-(void)transformThread:(NSString *)str
{
    
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    _transeforming = YES;
    [self strToVoice:str];
    _transeforming = NO;
    [pool release];
    
}

#pragma mark AV Foundation delegate methods____________



- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player withFlags:(NSUInteger)flags
{
    NSLog(@"audioPlayerEndInterruption");
#ifdef __IPHONE_4_0
    [[AVAudioSession sharedInstance] setActive: YES error: nil];
	
	if (_interruptedOnPlayback) {
		
		[_appSoundPlayer prepareToPlay];
		[_appSoundPlayer play];
        
		_interruptedOnPlayback = NO;
	}
#endif
}

- (void) audioPlayerDidFinishPlaying: (AVAudioPlayer *) player successfully: (BOOL) flag
{
    //add by hlf for 降低其他程序音量后恢复 2014.01.06
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
    dispatch_async(queue, ^{
        
        UInt32 otherAudioIsPlaying;
        
        UInt32 propertySize = sizeof (otherAudioIsPlaying);
        
        AudioSessionGetProperty (
                                 
                                 
                                 kAudioSessionProperty_OtherAudioIsPlaying,
                                 
                                 
                                 &propertySize,
                                 
                                 
                                 &otherAudioIsPlaying
                                 
                                 
                                 );
        
        
        if (otherAudioIsPlaying) {
            
            [[AVAudioSession sharedInstance] setActive:NO error:nil];
        }
    });
    
    
    
	isPlaying = NO;
	[player release];
	player = nil;
	if(_appSoundPlayer != nil)
	{
		_appSoundPlayer = nil;
	}
    
    [self TTSRemovePlayItemForStatus:TTSSTATUS_PLAYING];
    [self TTSCheckForPlay];
}
- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
    if (isPlaying)
	{
		isPlaying = NO;
		
	}
}
- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player {
	NSLog(@"audioPlayerBeginInterruption");
#ifdef __IPHONE_4_0
	if (isPlaying)
	{
		isPlaying = NO;
        _interruptedOnPlayback = YES;
		
	}
    
#endif
}

- (void) audioPlayerEndInterruption: (AVAudioPlayer *)player {
#ifdef __IPHONE_4_0
	NSLog(@"audioPlayerEndInterruption");
	
	[[AVAudioSession sharedInstance] setActive: YES error: nil];
	
	if (_interruptedOnPlayback) {
		
		[_appSoundPlayer prepareToPlay];
		[_appSoundPlayer play];
        
		_interruptedOnPlayback = NO;
	}
#endif
}
- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player withOptions:(NSUInteger)flags
{
    NSLog(@"audioPlayerEndInterruption");
#ifdef __IPHONE_4_0
    [[AVAudioSession sharedInstance] setActive: YES error: nil];
	
	if (_interruptedOnPlayback) {
		
		[_appSoundPlayer prepareToPlay];
		[_appSoundPlayer play];
        
		_interruptedOnPlayback = NO;
	}
#endif
}
#pragma mark --
#pragma mark Notification
- (void)playAutoNavi
{
    backgroundSoundFlag = YES;
    int isBackground = 0;
    GLANGUAGE eMapLanguage;
    GDBL_GetParam(G_LANGUAGE, &eMapLanguage);
    GDBL_GetParam(G_BACKGROUND_MODE, &isBackground);
    
    if (isBackground){
        
        if (eMapLanguage == 1) {
            [self playSoundWithString:@"[z1]Autonavi will continue for your navigation" priority:TTSPRIORITY_HIGHT];
        }
        else{
            [self playSoundWithString:@"[z1]高德导航持续为[=wei4]您服务" priority:TTSPRIORITY_HIGHT];
            
        }
    }
    
}
- (void)TTSWillResignActiveNotification:(NSNotification *)notification
{
    
    
}
- (void)TTSDidEnterBackgroundNotification:(NSNotification *)notification
{
    /*容错：有时候在后台会莫名播报，高德导航持续为您服务*/
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    /*容错：有时候在后台会莫名播报，高德导航持续为您服务*/
    
    if (isEngineInit != 1) {
        return;
    }
    
    int isPath = 0;
    GDBL_GetParam(G_GUIDE_STATUS, &isPath);
    
    //后台导航是否开启，开启才能播报：高德导航持续为[=wei4]您服务
    BOOL isBackNavi = [[MWPreference sharedInstance] getValue:PREF_BACKGROUND_NAVI];
    if ((isPath) && !_interruptedOnPlayback && isBackNavi)
    {
        [self playAutoNavi];
    }
    
}
- (void)TTSDidBecomeActiveNotification:(NSNotification *)notification
{
    /*容错：有时候在后台会莫名播报，高德导航持续为您服务*/
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(TTSDidEnterBackgroundNotification:) name:UIApplicationDidEnterBackgroundNotification object: nil];
    /*容错：有时候在后台会莫名播报，高德导航持续为您服务*/
    
    backgroundSoundFlag = NO;
    if (isPlaying && ([self.playString hasSuffix:@"高德导航持续为[=wei4]您服务"] || [self.playString hasSuffix:@"Autonavi will continue for your navigation"])) {
        [self stop];
    }
    
    _interruptedOnPlayback = NO;
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
    dispatch_async(queue, ^{
        
        UInt32 otherAudioIsPlaying;
        
        UInt32 propertySize = sizeof (otherAudioIsPlaying);
        
        AudioSessionGetProperty (
                                 
                                 
                                 kAudioSessionProperty_OtherAudioIsPlaying,
                                 
                                 
                                 &propertySize,
                                 
                                 
                                 &otherAudioIsPlaying
                                 
                                 
                                 );
        
        
        if (!otherAudioIsPlaying) {
            
            [[AVAudioSession sharedInstance] setActive:YES error:nil];
        }
    });
    
}
@end

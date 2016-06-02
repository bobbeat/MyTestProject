//
//  GDTableVoiceData.m
//  AutoNavi
//
//  Created by jiangshu-fu on 14-7-15.
//
//

#import "GDTableVoiceData.h"
#import "MWDialectDownloadTask.h"

@implementation GDTableVoiceData
////是否是默认 ，yes = 默认  NO = 需要下载
//@property (nonatomic, assign) BOOL isDefault;
////语音名称（string）
//@property (nonatomic, copy) NSString *voiceName;
////语音 id（string）
//@property (nonatomic, copy) NSString *voiceID;
////语音下载地址（string）
//@property (nonatomic, copy) NSString *voiceDownloadURL;
////是否被选择的（bool）
//@property (nonatomic, assign) BOOL isSelect;
////该语音的下载状态
//@property (nonatomic, retain) MWDialectDownloadTask *voiceTask;

//@synthesize voiceDefault = _voiceDefault;
//@synthesize voiceDownloadURL = _voiceDownloadURL;
//@synthesize voiceID = _voiceID;
//@synthesize voiceName = _voiceName;
//@synthesize voiceSelect = _voiceSelect;
//@synthesize voiceTask = _voiceTask;

- (id) init
{
    if (self = [super init])
    {
        self.voiceDefault = YES;
        self.voiceSelect = nil;
        self.voiceDownloadURL = @"";
        self.voiceID = -1;
        self.voiceName = @"";
        MWDialectDownloadTask *tempTask =  [[MWDialectDownloadTask alloc] init];
        self.voiceTask = tempTask;
        [tempTask release];
    }
    return self;
}

- (id) initWithIsDefault:(BOOL) voiceDefalut withSelect:(VoiceSelect )voiceSelect 
{
    if (self = [self init])
    {
        self.voiceDefault = voiceDefalut;
        self.voiceSelect = voiceSelect;
    }
    return self;
}

- (id) initWithIsDefault:(BOOL) voiceDefalut
              withSelect:(VoiceSelect )voiceSelect
           withVoiceName:(NSString *) voiceName
             withVoiceID:(int) voiceID

{
    if(self = [self initWithIsDefault:voiceDefalut withSelect:voiceSelect])
    {
        self.voiceID = voiceID;
        self.voiceName = voiceName;
    }
    return self;

}

- (id) initWithIsDefault:(BOOL) isdefalut
              withSelect:(VoiceSelect)isSelect
             withVoiceID:(int)voiceID
    withVoiceDownloadUrl:(NSString *)downloadUrl
           withVoiceName:(NSString *)voiceName
 withDialectDownloadTask:(MWDialectDownloadTask *)voiceTask
{
    if(self = [self initWithIsDefault:isdefalut withSelect:isSelect])
    {
        self.voiceDownloadURL = downloadUrl;
        self.voiceID = voiceID;
        self.voiceName = voiceName;
        self.voiceTask = voiceTask;
    }
    return self;
}

-(void) dealloc
{
    CRELEASE(_voiceDownloadURL);
    CRELEASE(_voiceName);
    CRELEASE(_voiceSelect);
    CRELEASE(_voiceTask);
    [super dealloc];
}

@end

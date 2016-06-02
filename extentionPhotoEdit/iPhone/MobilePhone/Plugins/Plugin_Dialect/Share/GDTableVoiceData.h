//
//  GDTableVoiceData.h
//  AutoNavi
//
//  Created by jiangshu-fu on 14-7-15.
//
//

#import <Foundation/Foundation.h>
@class MWDialectDownloadTask;

typedef BOOL (^VoiceSelect)();
typedef void (^VoiceSetId)(int);

@interface GDTableVoiceData : NSObject

//是否是默认 ，yes = 默认  NO = 需要下载
@property (nonatomic, assign) BOOL voiceDefault;
//语音名称（string）
@property (nonatomic, copy) NSString *voiceName;
//语音 id（string）
@property (nonatomic, assign) int voiceID;
//语音下载地址（string）
@property (nonatomic, copy) NSString *voiceDownloadURL;
//是否被选择的（bool）
@property (nonatomic, copy) VoiceSelect voiceSelect;
//该语音的下载状态
@property (nonatomic, retain) MWDialectDownloadTask *voiceTask;


- (id) init;

- (id) initWithIsDefault:(BOOL) voiceDefalut
              withSelect:(VoiceSelect )voiceSelect;

- (id) initWithIsDefault:(BOOL) voiceDefalut
              withSelect:(VoiceSelect )voiceSelect
           withVoiceName:(NSString *) voiceName
             withVoiceID:(int) voiceID;

- (id) initWithIsDefault:(BOOL) isdefalut
              withSelect:(VoiceSelect)isSelect
             withVoiceID:(int)voiceID
    withVoiceDownloadUrl:(NSString *)downloadUrl
           withVoiceName:(NSString *)voiceName
 withDialectDownloadTask:(MWDialectDownloadTask *)voiceTask;

@end

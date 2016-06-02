//
//  ANTTSManager.h
//  ANApi
//
//  Created by liyuhang on 14-12-4.
//  Copyright (c) 2014年 yuhang. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 * 导航在引导的过程中
 * 1 将引导的信息以文本的方式通知delegate的@selector（playText:）
 * 2 将电子眼等提示音的音频文件路径通知delegate的@selector(playWavefile:)
 */

@protocol TTSManagerDelegate <NSObject>

@required

- (BOOL)isPlaying;

- (void)playText:(NSString *)text;

- (void)playWavefile:(NSString *)fileName;

- (void)stopPlay;

@optional

- (void)willPlay;

- (void)endPlay;

@end


/**
 *  语音管理器
 */
@interface ANTTSManager : NSObject
{
    
}

/**fun
 * @brief 单例
 * @return
 */
+ (instancetype)shareInstance;

+ (void)releaseInstance;


/**Property
 * @Property 导航有语音需要播报时，将调用该delegate中的接口
 * @brief
 *
 */
@property (nonatomic, assign) id<TTSManagerDelegate> delegateTTS;


@end

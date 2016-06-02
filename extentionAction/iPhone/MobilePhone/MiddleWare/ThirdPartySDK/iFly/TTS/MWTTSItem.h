//
//  MWTTSItem.h
//  AutoNavi
//
//  Created by longfeng.huang on 14-4-28.
//
//

#import <Foundation/Foundation.h>

typedef enum TTSPLAYTYPE
{
    TTSPLAYTYPE_STRING = 0,   //播放字符串
    TTSPLAYTYPE_WAV    = 1,   //播放音频文件
    
}TTSPLAYTYPE;

typedef enum TTSSTATUS
{
    TTSSTATUS_WAITING = 0,    //等待播放
    TTSSTATUS_PAUSE   = 1,    //暂停播放
    TTSSTATUS_PLAYING = 2,    //播放中
    TTSSTATUS_FINISH  = 3,    //播放完成
    
}TTSSTATUS;

typedef enum TTSPRIORITY
{
    TTSPRIORITY_LOW        = 0, //最低级，如果有语音正在播报则舍弃播报，可被中断
    TTSPRIORITY_NORMAL     = 1, //在low等级之上，hight等级之下，等待hight播报完成后播报，可被中断
    TTSPRIORITY_HIGHT      = 2, //在normal等级之上，superhight等级之下，等待当前语音播报完成后播报，可被中断
    TTSPRIORITY_INTERRUPTSELF = 3, //在hight之上，中断当前类型跟自己一样的语音，播报当前的语音，可被中断
    TTSPRIORITY_SUPERHIGHT = 4, //更高等级，中断当前播报的语音，播报当前的语音，可被中断
    TTSPRIORITY_NOINTERRUPT= 5, //最高等级，中断当前播报的语音，播报当前的语音，不可被中断
    
}TTSPRIORITY;

@interface MWTTSItem : NSObject

@property (nonatomic, copy) NSString *playString;         //播放内容
@property (nonatomic, copy) NSString *playPath;           //播放文件路径
@property (nonatomic, assign) TTSSTATUS playStatus;       //播放状态
@property (nonatomic, assign) TTSPLAYTYPE playType;       //播放类型
@property (nonatomic, assign) TTSPRIORITY playPriority;   //播放优先级

@end

//
//  MWTTS.h
//  AutoNavi
//
//  Created by gaozhimin on 14-9-3.
//
//

#import <Foundation/Foundation.h>
#import "ivTTS.h"
#import "MWTTSItem.h"

typedef enum Role_Player
{
    /*索引中文对应角色为*/
    Role_XIAOYAN = ivTTS_ROLE_XIAOYAN,          //国语女声
    Role_XiaoFeng = ivTTS_ROLE_XIAOFENG,        //国语男声
    Role_XiaoLin = ivTTS_ROLE_XIAOLIN,          //台湾普通话女声
    Role_XiaoMei = ivTTS_ROLE_XIAOMEI,          //粤语女声
    Role_XiaoQian = ivTTS_ROLE_XIAOQIAN,        //东北话女声
    Role_XiaoRong = ivTTS_ROLE_XIAORONG,        //四川话女声
    Role_XiaoQiang = ivTTS_ROLE_XIAOQIANG,      //湖南话男声
    Role_XiaoKun = ivTTS_ROLE_XIAOKUN,          //河南话男声
    Role_ZhiLing = ivTTS_ROLE_USER,             //志玲语音
    /*索引英文对应角色为*/
    Role_Catherine = ivTTS_ROLE_CATHERINE,      //英语女声
    Role_John = ivTTS_ROLE_JOHN,                //英语男声
}Role_Player;

@interface MWTTS : NSObject

+ (instancetype)SharedInstance;

/*
 * @brief 根据字符串播报语音
 * @param str 播报字符串
 * @param priority 播报优先级
 */
- (void)playSoundWithString:(NSString *)str priority:(TTSPRIORITY)priority;

/*
 * @brief 根据wav文件路径播报语音
 * @param path wav文件路径
 * @param priority 播报优先级
 */
- (void)playSoundWithPath:(NSString *)path priority:(TTSPRIORITY)priority;
/*
 * @brief 设置播报角色 @seeRole_Player
 * @param role 要设置的播报角色
 */
- (void)SetTTSRole:(Role_Player)role;

/*
 * @brief 获取播报角色 @seeRole_Player
 * @return Role_Player 当前的播报角色
 */
- (Role_Player)GetTTSRole;

/*
 * @brief 设置播报文件夹名称
 * @return folder 播报文件夹名称
 */
- (void)SetTTSFolder:(NSString *)folder;

/*
 * @brief 设置播报语速
 * @param speed 要设置的播报语速
 */
- (void)SetTTSSpeed:(int)speed;

/*
 * @brief 设置是否为录音
 * @param prompts 是否为录音
 */
- (void)SetTTSUsePrompts:(BOOL)prompts;

/*!
  @brief 停止当前语音播放
  */
-(void)stop;

/*!
 *@brief 获取当前语音播放状态
 *@return YES 正在播放 NO 没有播放
 **/
- (BOOL)status;

@end

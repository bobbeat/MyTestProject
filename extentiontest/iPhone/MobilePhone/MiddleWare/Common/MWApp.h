//
//  MWApp.h
//  AutoNavi
//
//  Created by yu.liao on 13-7-29.
//
//

#import <Foundation/Foundation.h>

@interface MWApp : NSObject<NetReqToViewCtrDelegate>

+(MWApp *)sharedInstance;
+(void)releaseInstance;

- (BOOL)loadTTS;
- (BOOL)loadAccount;
- (int)loadEngine;
- (BOOL)initEngine;
- (void)loadSkin;
-(BOOL)saveAppData;
- (BOOL)restoreAppData;
/**********************************************************************
 * 函数名称: ClearAllEngineData
 * 功能描述: 删除所有引擎保存的数据
 * 输入参数:
 * 输出参数:
 * 返 回 值:
 **********************************************************************/
-(void)ClearAllEngineData;

-(void)executeLogicAfterWarningViewAndNewFunction:(id)viewController;

@end

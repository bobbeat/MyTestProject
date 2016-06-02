//
//  RecognizerManager.h
//  RecognizerTest
//
//  Created by Autonavi on 12-5-10.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GDBL_Interface.h"
//

@protocol PaintingViewDelagate;
#define MUT_RECOGNIZE_SUPPORT	1	//多类手势共存支持
@interface RecognizerManager : NSObject
{

	CGFloat lastScale;
	CGPoint startLocation;	
	CGPoint secondLocation;
	CGFloat firstRotation;
	GMOVEMAP stMoveMap;
	
	CGFloat mapScale;
	int iAcitveTypes;
	
	BOOL bPinchActive;
	BOOL bRotateActive;
	BOOL bPanActive;
	BOOL bPanMoveActive;
	BOOL bSwipActive;
	BOOL bTapSingleActive;
	BOOL bTapDoubleActive;
	BOOL bDoubleFingerActive;
    BOOL bLongPressActive;
	
	CGRect myRecognizeFrame;
    
}
@property (nonatomic,assign) id<PaintingViewDelagate> delegate;
/**********************************************************************
 * 函数名称: recognizerInstance
 * 功能描述: 单例,回调函数中使用   
 * 输入参数: 
 * 输出参数: 
 * 返 回 值：成功返回recognizerManager对象
 * 其它说明: 
 * 修改日期			版本号		修改人		修改内容
 * ---------------------------------------------------------------------
 **********************************************************************/
+(id)recognizerInstance;

/**********************************************************************
 * 函数名称: setDelegate
 * 功能描述: 设置手势委托   
 * 输入参数: (id)recognizerDelegate
 * 输出参数: 
 * 返 回 值：
 * 其它说明: 
 * 修改日期			版本号		修改人		修改内容
 * ---------------------------------------------------------------------
 **********************************************************************/
-(void)setDelegateExt:(id)recognizerDelegate;

/**********************************************************************
 * 函数名称: setRecognizeFrame
 * 功能描述: 设置手势响应区域   
 * 输入参数: (CGRect)recognizedFrame
 * 输出参数: 
 * 返 回 值：
 * 其它说明: 
 * 修改日期			版本号		修改人		修改内容
 * ---------------------------------------------------------------------
 **********************************************************************/
-(void)setRecognizeFrame:(CGRect)recognizedFrame;

/**********************************************************************
 * 函数名称: setRecognizeActive
 * 功能描述: 设置手势响应开关   
 * 输入参数: (int) activeType
 * 输出参数: 
 * 返 回 值：
 * 其它说明: 
 * 修改日期			版本号		修改人		修改内容
 * ---------------------------------------------------------------------
 **********************************************************************/
-(void)setRecognizeActive:(int) activeType;
@end

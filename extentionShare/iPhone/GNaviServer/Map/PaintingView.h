/*

File: PaintingView.h
Abstract: The class responsible for the finger painting.

Version: 1.6

Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple Inc.
("Apple") in consideration of your agreement to the following terms, and your
use, installation, modification or redistribution of this Apple software
constitutes acceptance of these terms.  If you do not agree with these terms,
please do not use, install, modify or redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and subject
to these terms, Apple grants you a personal, non-exclusive license, under
Apple's copyrights in this original Apple software (the "Apple Software"), to
use, reproduce, modify and redistribute the Apple Software, with or without
modifications, in source and/or binary forms; provided that if you redistribute
the Apple Software in its entirety and without modifications, you must retain
this notice and the following text and disclaimers in all such redistributions
of the Apple Software.
Neither the name, trademarks, service marks or logos of Apple Inc. may be used
to endorse or promote products derived from the Apple Software without specific
prior written permission from Apple.  Except as expressly stated in this notice,
no other rights or licenses, express or implied, are granted by Apple herein,
including but not limited to any patent rights that may be infringed by your
derivative works or by other works in which the Apple Software may be
incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO
WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED
WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR
PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN
COMBINATION WITH YOUR PRODUCTS.

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR
DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF
CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF
APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

Copyright (C) 2008 Apple Inc. All Rights Reserved.

*/

#import "EAGLView.h"
#import "GDBL_typedefEx.h"
#import "MapViewManager.h"
@protocol PaintingViewDelegate;
@class RecognizerManager;
@interface PaintingView : EAGLView<UIGestureRecognizerDelegate,PaintingViewDelegate>
{
	GLint backingWidth;
	GLint backingHeight;
	CGPoint   mLastTouchLocation;
	float spacing;
	float mLastTouchSpacing,spacingRatio;
	int touch_count;
	id<PaintingViewDelegate> delegate;
    RecognizerManager *_recognizerManager;
}

@property (nonatomic,assign) id<PaintingViewDelegate> delegate;
-(void) setmyFrame:(CGRect)newFrame;
/**********************************************************************
 * 函数名称: setRecognizeSwitchOn
 * 功能描述: 设置手势响应开关   
 * 输入参数: (int) recoginzeTypes(-1,不启用手势,0，表示所有手势打开，反之,EVENT_PINCH｜EVENT_ROTATE表示仅支持缩放+旋转，其它手势见GDBL_typedef.h说明)
 * 输出参数: 
 * 返 回 值：
 * 其它说明: 
 * 修改日期			版本号		修改人		修改内容
 * ---------------------------------------------------------------------
 **********************************************************************/
-(void) setRecognizeSwitchOn:(int) recoginzeTypes;

/**********************************************************************
 * 函数名称: setRecognizeFrame
 * 功能描述: 设置手势响应区域   
 * 输入参数: (CGRect)recognizedFrame
 * 输出参数: 
 * 返 回 值：
 * 其它说明: 
 * 修改日期			版本号		修改人		修改内容
 **********************************************************************/
-(void) setRecognizeFrame:(CGRect) recognizeRect;
@end


@protocol PaintingViewDelegate <NSObject>

-(void)mapView:(PaintingView *)mapView GestureRecognizer:(UIGestureRecognizer *)recognizer gestureType:(RECOGNIZETYPE)gesturetype  withParam:(int)param;

@end

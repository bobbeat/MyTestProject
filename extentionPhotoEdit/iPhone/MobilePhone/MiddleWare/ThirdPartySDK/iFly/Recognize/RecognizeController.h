//
//  RecognizeController.h
//  RecognizeControllerTest
//
//  Created by jingjie lin on 12-3-26.
//  Copyright (c) 2012年 autonavi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "iFlySpeechService.h"
@interface RecognizeController : iFlySpeechService
/*
 初始化
 */
-(id)initWithView:(UIView *) view Lon:(int)lon Lat:(int)lat AdminCode:(int)adminCode;
/*
 设置当前语音区域
 gaoLon：高德经度
 gaoLat：高德纬度
 adminCode：6位行政编码
 */
-(void)setPosition:(int)gaoLon Lat:(int)gaoLat AdminCode:(int)adminCode;

/*
 设置返回的结果类型
 resultType: 取值见结果类型枚举
 */
-(void)setResultType:(int)resultType;

/*
 调用该方法后，应该弹出一个模式录音窗口。上面一般要有【确定】【取消】按钮可供用户操作
 */
-(void)start;

/*
 调用该方法后，终止本次语音操作
 */
-(void)stop;

/*
 设置委托
 */
-(void)setDelegate:(id)delegate;
/*
 设置语音输入视图的中心点
 */
-(void)setViewCenter:(CGPoint)center;
@end

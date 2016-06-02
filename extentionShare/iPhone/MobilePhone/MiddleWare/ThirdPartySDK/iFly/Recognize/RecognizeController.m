//
//  RecognizeController.m
//  RecognizeControllerTest
//
//  Created by jingjie lin on 12-3-26.
//  Copyright (c) 2012年 autonavi. All rights reserved.
//

#import "RecognizeController.h"

@implementation RecognizeController

-(id)initWithView:(UIView *) view Lon:(int)lon Lat:(int)lat AdminCode:(int)adminCode
{
    return [super initWithView:view Lon:lon Lat:lat AdminCode:adminCode];
}
/*
 设置当前语音区域
 gaoLon：高德经度
 gaoLat：高德纬度
 adminCode：6位行政编码
 */
-(void)setPosition:(int)gaoLon Lat:(int)gaoLat AdminCode:(int)adminCode
{
    [super setPosition:gaoLon Lat:gaoLat AdminCode:adminCode];
}

/*
 设置返回的结果类型
 resultType: 取值见结果类型枚举
 */
-(void)setResultType:(int)resultType
{
    [super setResultType:resultType];
}

/*
 调用该方法后，应该弹出一个模式录音窗口。上面一般要有【确定】【取消】按钮可供用户操作
 */
-(void)start
{
    [super start];
}

/*
 调用该方法后，终止本次语音操作
 */
-(void)stop
{
    [super stop];
}
-(void)setDelegate:(id)delegate
{
    self.speechServiceDelegate = delegate;
}
-(void)setViewCenter:(CGPoint)center
{
    self.voiceRecognizeController.center = center;
}
@end

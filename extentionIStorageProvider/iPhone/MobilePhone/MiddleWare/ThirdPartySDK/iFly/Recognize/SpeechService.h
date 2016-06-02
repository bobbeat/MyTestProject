//
//  SpeechService.h
//  
//
//  Created by mark on 11-11-18.
//  Copyright (c) 2011年 Autonavi. All rights reserved.
//

#import <Foundation/Foundation.h>

// 错误码枚举
enum{
    ERROR_CODE_CANCEL = 0,          // 用户取消了录音窗口
    ERROR_CODE_NETWORK = 1,         // 网络故障
    ERROR_CODE_RECOGNIZE = 2,       // 识别出错
};

// 结果类型枚举
enum{
    RESULT_TYPE_KEYWORD_CONTENT = 0,    // 返回识别字符串和内容数据
    RESULT_TYPE_KEYWORD_ONLY = 1,       // 仅返回转换后的识别字符串
};


/*
 结果回调
 */
@protocol SpeechServiceDelegate <NSObject>
@required
/*
 当发生错误时，回调此方法
 */
-(void)errorOccur:(int)errorCode;

/*
 语音识别成功，返回请求结果
 */
-(void)speechResultText:(NSString *)resultText;

@end




/*
 语音服务抽象基类：采用不同的语音后台时，子类化具体实现类。采用讯飞后台，派生类为XunFeiSpeechService；采用车音网后台，派生类为CarSpeechService
 1、调用者不能直接实例化抽象基类，而应该实例化某个派生类，来获取对应服务
 2、派生类负责实现抽象基类的方法以及正确使用委托把数据传给调用者
 */
@interface SpeechService : NSObject
{
	id<SpeechServiceDelegate> speechServiceDelegate;
}
/*
 通过此委托把信息传递到调用者
 */
@property(nonatomic,assign)id<SpeechServiceDelegate> speechServiceDelegate;

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

@end

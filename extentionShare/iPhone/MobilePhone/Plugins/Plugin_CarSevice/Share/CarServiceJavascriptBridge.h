//
//  CarServiceJavascriptBridge.h
//  AutoNavi
//
//  Created by jiangshu-fu on 14-3-7.
//
//

#import <Foundation/Foundation.h>

/***
 * @name    JavaScript 桥的注册
 * @param
 * @author  by bazinga
 ***/
typedef void (^JavaScriptWebRegister)();

/***
 * @name    根据给的URL打开连接（内置打开或者打开Safari）
 * @param   NSString -- 打开的url地址， 
 * @param   BOOL —— YES：内置程序打开   NO：系统Safari打开
 * @param   BOOL -- YES: 显示前进后退刷新的按钮  NO：不显示前进后退刷新的按钮
 * @author  by bazinga
 ***/
typedef void (^JavaScriptOpenUrl)(NSString *,BOOL,BOOL,NSString *);

/***
 * @name    关闭webView
 * @param
 * @author  by bazinga
 ***/
typedef  void (^JavaScriptCloseWebView)();

/***
 * @name    更新程序标题
 * @param   更新的标题
 * @author  by bazinga
 ***/
typedef void (^JavaScriptUpdateTitle)(NSString *);

/***
 * @name    重载页面
 * @param
 * @author  by bazinga
 ***/
typedef void (^JavaScriptReload)();

@interface CarServiceJavascriptBridge : NSObject<UIWebViewDelegate>

@property (nonatomic, copy) JavaScriptWebRegister webRegister;
@property (nonatomic, copy) JavaScriptOpenUrl webOpenUrl;
@property (nonatomic, copy) JavaScriptCloseWebView webCloseView;
@property (nonatomic, copy) JavaScriptUpdateTitle webUpdateTitle;
@property (nonatomic, copy) JavaScriptReload webReload;

- (id) initWithWebview:(UIWebView *)webView withwebViewDelegate:(id<UIWebViewDelegate>)webViewDelegate;
- (void)setDelegateWith:(id)delege;

@end

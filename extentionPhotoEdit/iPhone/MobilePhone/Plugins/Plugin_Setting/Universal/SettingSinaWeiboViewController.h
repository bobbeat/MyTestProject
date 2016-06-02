//
//  SettingSinaWeiboViewController.h
//  AutoNavi
//
//  Created by huang on 13-8-13.
//
//

#import "ANViewController.h"
//新浪微博
@interface SettingSinaWeiboViewController : ANViewController<UIWebViewDelegate>
{
    UIWebView * _webView;
    BOOL _backFlag;
}
@property(nonatomic,copy)NSString *webUrl;
@end

//
//  htmlFiveViewController.h
//  AutoNavi
//
//  Created by jiangshu-fu on 14-3-11.
//
//

#import "ANViewController.h"

@interface HtmlFiveViewController : ANViewController<UIWebViewDelegate>

@property (nonatomic,copy) NSString *webUrl;

@property (nonatomic,copy) NSString *viewTitle;

@property (nonatomic,assign) BOOL isBrowser;

- (id) initWithWebUrl:(NSString *)webUrl withTitle:(NSString *)viewTitle withBrowser:(BOOL) isBrowser;
@end

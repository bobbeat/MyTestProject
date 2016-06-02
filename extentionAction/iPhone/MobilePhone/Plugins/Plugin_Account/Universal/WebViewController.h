//
//  WebViewController.h
//  AutoNavi
//
//  Created by gaozhimin on 12-12-28.
//
//

#import <UIKit/UIKit.h>

@interface WebViewController : ANViewController<UIWebViewDelegate,UIAlertViewDelegate>


- (id)initWithURL:(NSString *)url;
@end

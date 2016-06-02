//
//  Data_Upgrade.h
//  AutoNavi－sj
//
//  Created by huang longfeng on 11-8-11.
//  Copyright 2011 autonavi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ANParamValue.h"
#import "Map_Upgrade.h"
#import "NSString+Category.h"

@interface Data_Upgrade : ANViewController< UIWebViewDelegate,UIScrollViewDelegate> {
	
	UIButton *Button_Upgrade;
	
	UIScrollView *detail_scroll;
	UIActivityIndicatorView *progressInd;
	NSTimer *downloadVersion_timer;
	
	Map_Upgrade *Map_Upgrade_Controller;
	NSString *s;
	NSString *temp;
	UIFont *font;
	CGSize labelsize;
	UIWebView *webView;
    NSString *updateUrl;
	
}

@property (nonatomic,copy) NSString *updateUrl;

- (id)initWithUpdateURL:(NSString *)updateURL;
-(void)create_UIActivityIndView;
-(void)downloadVersion;
-(void)downloadVersion_Finish:(id)sender;
- (void)MyalertView:(NSString *)titletext canceltext:(NSString *)mycanceltext othertext:(NSString *)myothertext alerttag:(int)mytag;
@end

//
//  ShareMailViewController.h
//  AutoNavi
//
//  Created by gaozhimin on 13-8-15.
//
//

#import <MessageUI/MessageUI.h>

@interface ShareMailViewController : MFMailComposeViewController<MFMailComposeViewControllerDelegate>

- (id)initWithBody:(NSString *)body;

@end

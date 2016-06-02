//
//  ShareViewController.m
//  extension
//
//  Created by gaozhimin on 14-12-16.
//
//

#import "ShareViewController.h"

@interface ShareViewController ()

@end

@implementation ShareViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIViewController *ctl = [[UIViewController alloc] init];
    ctl.view.backgroundColor = [UIColor redColor];
    [self pushConfigurationViewController:ctl];
}

- (BOOL)isContentValid {
    // Do validation of contentText and/or NSExtensionContext attachments here
    return YES;
}

- (void)didSelectPost {
    // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
    NSArray *array =  self.extensionContext.inputItems;
    for (NSExtensionItem *item in self.extensionContext.inputItems) {
        for (NSItemProvider *itemProvider in item.attachments) {
            NSLog(@"%@",itemProvider);
        }
    }
    NSString *temp = self.contentText;
    NSString *s = self.placeholder;
    NSArray *array1 =[self configurationItems];
    // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
    [self.extensionContext completeRequestReturningItems:@[] completionHandler:nil];
}

- (NSArray *)configurationItems {
    // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
    SLComposeSheetConfigurationItem *item = [[SLComposeSheetConfigurationItem alloc] init];
    item.title = @"gzmtext";
    item.value = @"111";
//    item.valuePending = YES;
    item.tapHandler = ^(){
        UIViewController *ctl = [[UIViewController alloc] init];
        ctl.view.backgroundColor = [UIColor blueColor];
        [self pushConfigurationViewController:ctl];
    };
    return @[item];
}

@end

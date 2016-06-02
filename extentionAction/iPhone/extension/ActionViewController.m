//
//  ActionViewController.m
//  extension
//
//  Created by gaozhimin on 14-12-15.
//
//

#import "ActionViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface ActionViewController ()

@property(strong,nonatomic) IBOutlet UIImageView *imageView;
@property(strong,nonatomic) IBOutlet UILabel *mylable;

@end

@implementation ActionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Get the item[s] we're handling from the extension context.
    self.mylable.numberOfLines = 5;
    // For example, look for an image and place it into an image view.
    // Replace this with something appropriate for the type[s] your extension supports.
    BOOL imageFound = NO;
    for (NSExtensionItem *item in self.extensionContext.inputItems) {
        NSLog(@"%@",item.attachments);
        for (NSItemProvider *itemProvider in item.attachments) {
            NSLog(@"%@",itemProvider);
            if ([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeImage]) {
                // This is an image. We'll load it, then place it in our image view.
                __weak UIImageView *imageView = self.imageView;
                [itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeImage options:nil completionHandler:^(UIImage *image, NSError *error) {
                    if(image) {
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            [imageView setImage:image];
                        }];
                    }
                }];
                
                imageFound = YES;
            }
            else
            {
                if ([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypePlainText]) {
                    // This is an image. We'll load it, then place it in our image view.
                    __weak UILabel *lable = self.mylable;
                    [itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypePlainText options:nil completionHandler:^(NSString *str, NSError *error) {
                        if(str) {
                            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                if ([lable.text length] > 0)
                                {
                                    lable.text  = [lable.text  stringByAppendingFormat:@"\n%@",str];
                                }
                                else
                                {
                                     lable.text = str;
                                }
                               
                            }];
                        }
                    }];
                }
            }
        }
        
        if (imageFound) {
            // We only handle one image, so stop looking for more.
            break;
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)done {
    // Return any edited content to the host app.
    // This template doesn't do anything, so we just echo the passed in items.
    [self.extensionContext completeRequestReturningItems:self.extensionContext.inputItems completionHandler:nil];
}

@end

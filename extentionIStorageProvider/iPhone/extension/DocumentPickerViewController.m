//
//  DocumentPickerViewController.m
//  extension
//
//  Created by gaozhimin on 14-12-22.
//
//

#import "DocumentPickerViewController.h"

@interface DocumentPickerViewController ()

@end

@implementation DocumentPickerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

- (IBAction)openDocument:(id)sender {
    
    NSURL* test = [self.documentStorageURL URLByAppendingPathComponent:@"Untitled.txt"];
    NSString *doc = test.path;
    NSError *error = nil;
    if (![[NSFileManager defaultManager] fileExistsAtPath:doc])
    {
        NSString *bundle_txt = [[NSBundle mainBundle] pathForResource:@"Untitled" ofType:@"txt"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:bundle_txt])
        {
            [[NSFileManager defaultManager] copyItemAtPath:bundle_txt toPath:doc error:&error];
        }
        NSLog(@"%@",error);
    }
    
    NSURL* documentURL = [self.documentStorageURL URLByAppendingPathComponent:@"Untitled.txt"];
    
    // TODO: if you do not have a corresponding file provider, you must ensure that the URL returned here is backed by a file
    [self dismissGrantingAccessToURL:documentURL];
}

-(void)prepareForPresentationInMode:(UIDocumentPickerMode)mode {
    // TODO: present a view controller appropriate for picker mode here
}

@end

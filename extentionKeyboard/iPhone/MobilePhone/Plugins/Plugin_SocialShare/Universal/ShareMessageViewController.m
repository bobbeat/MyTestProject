//
//  ShareMessageViewController.m
//  AutoNavi
//
//  Created by gaozhimin on 13-8-15.
//
//

#import "ShareMessageViewController.h"

@interface ShareMessageViewController ()

@end

@implementation ShareMessageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)init
{
    if (self = [super init])
    {
        self.messageComposeDelegate = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - MFMessageComposeViewControllerDelegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    NSLog(@"messageComposeViewController");
    switch (result)
    {
        case MessageComposeResultSent:
            break;
			
        case MessageComposeResultFailed:
            break;
			
        default:
            break;
    }
	
    [controller dismissModalViewControllerAnimated:YES];
}

@end

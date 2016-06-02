//
//  ShareMailViewController.m
//  AutoNavi
//
//  Created by gaozhimin on 13-8-15.
//
//

#import "ShareMailViewController.h"

@interface ShareMailViewController ()

@end

@implementation ShareMailViewController

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
        self.mailComposeDelegate = self;
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

#pragma mark - public method


#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    NSLog(@"mailComposeController");
    switch (result)
    {
        case MFMailComposeResultCancelled:
            break;
			
        case MFMailComposeResultSaved:
            break;
			
        case MFMailComposeResultSent:
            break;
			
        case MFMailComposeResultFailed:
            break;
			
        default:
            break;
    }
	
    [controller dismissModalViewControllerAnimated:YES];
}

@end

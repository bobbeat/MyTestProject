//
//  GDImagePickerViewController.m
//  AutoNavi
//
//  Created by huang on 13-10-30.
//
//

#import "GDImagePickerController.h"
#import <AVFoundation/AVFoundation.h>
@interface GDImagePickerController ()

@end

@implementation GDImagePickerController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if(IOS_7)
    {
        if (self.sourceType ==UIImagePickerControllerSourceTypeCamera) {
            NSString *mediaType = AVMediaTypeVideo; // Or AVMediaTypeAudio
            AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
//        请打开系统设置中\"隐私→麦克风\"，允许\"高德导航\"访问您的相机。
            if(authStatus == AVAuthorizationStatusDenied){
                GDAlertView *alertView=[[[GDAlertView alloc] initWithTitle:nil andMessage:STR(@"Share_VisitCamer",Localize_POIShare)] autorelease];
                [alertView addButtonWithTitle:STR(@"POI_OK", Localize_POI) type:GDAlertViewButtonTypeDefault handler:nil];
                [alertView show];
            }

        }
    }
    
        // Do any additional setup after loading the view.
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (!isPad) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
	}
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dismissModalViewControllerAnimated:(BOOL)animated
{
    if (IOS_7) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }
    [super dismissModalViewControllerAnimated:animated];
}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if (IOS_7) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }

}
-(void)dealloc
{
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [super dealloc];
}
@end

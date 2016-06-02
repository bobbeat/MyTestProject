//
//  CustomImagePickerCtr.m
//  AutoNavi
//
//  Created by liyuhang on 13-4-28.
//
//

#import "CustomImagePickerCtr.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "ANParamValue.h"
#import "GDAlertView.h"
#import "GDActionSheet.h"
#import "GDImagePickerController.h"
@interface CustomImagePickerCtr ()<GDActionSheetDelegate,UIPopoverControllerDelegate>
{
    UIImagePickerController* imagePickerController;
}

@end

@implementation CustomImagePickerCtr

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
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)dealloc
{
    if (m_pPopoverViewController) {
        [m_pPopoverViewController dismissPopoverAnimated:NO];
    }

    [super dealloc];
}

#pragma mark takePicture

- (BOOL)takePictureButtonClick:(id)sender{
    //检查相机模式是否可用
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        NSLog(@"sorry, no camera or camera is unavailable.");
        return NO;
    }
    //获得相机模式下支持的媒体类型
    NSArray* availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
    BOOL canTakePicture = NO;
    for (NSString* mediaType in availableMediaTypes) {
        if ([mediaType isEqualToString:(NSString*)kUTTypeImage]) {
            //支持拍照
            canTakePicture = YES;
            break;
        }
    }
    //检查是否支持拍照
    if (!canTakePicture) {
        NSLog(@"sorry, taking picture is not supported.");
        return NO;
    }
    //创建图像选取控制器
    imagePickerController = [[GDImagePickerController alloc] init];
    //设置图像选取控制器的来源模式为相机模式
    imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    //设置图像选取控制器的类型为静态图像
//    imagePickerController.mediaTypes = [[[NSArray alloc] initWithObjects:(NSString*)kUTTypeImage, nil] autorelease];
//    imagePickerController.mediaTypes =[UIImagePickerController availableMediaTypesForSourceType:imagePickerController.sourceType];
    //允许用户进行编辑
    imagePickerController.allowsEditing = YES;
    //设置委托对象
    imagePickerController.delegate = self;
    //以模视图控制器的形式显示
    [self presentModalViewController:imagePickerController animated:YES];
    [imagePickerController release];
    return YES;
}

- (BOOL)ChoosePictureButtonClick:(id)sender{
    //检查相机模式是否可用
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        NSLog(@"sorry, no camera or camera is unavailable.");
        return NO;
    }
    //获得相机模式下支持的媒体类型
    NSArray* availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    BOOL canTakePicture = NO;
    for (NSString* mediaType in availableMediaTypes) {
        if ([mediaType isEqualToString:(NSString*)kUTTypeImage]) {
            //支持拍照
            canTakePicture = YES;
            break;
        }
    }
    //检查是否支持拍照
    if (!canTakePicture) {
        NSLog(@"sorry, taking picture is not supported.");
        return NO;
    }
    //创建图像选取控制器
    imagePickerController = [[GDImagePickerController alloc] init];
    //设置图像选取控制器的来源模式为相机模式
    imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    //设置图像选取控制器的类型为静态图像
//    imagePickerController.mediaTypes = [[[NSArray alloc] initWithObjects:(NSString*)kUTTypeImage, nil] autorelease];
    imagePickerController.mediaTypes =[UIImagePickerController availableMediaTypesForSourceType:imagePickerController.sourceType];
    //允许用户进行编辑
    imagePickerController.allowsEditing = YES;
    //设置委托对象
    imagePickerController.delegate = self;
    //以模视图控制器的形式显示
 //   [self presentModalViewController:imagePickerController animated:YES];
    if (isPad) {
        if (m_pPopoverViewController) {
            [m_pPopoverViewController release];
            m_pPopoverViewController = nil;
        }
        m_pPopoverViewController = [[UIPopoverController alloc] initWithContentViewController:imagePickerController];
        [m_pPopoverViewController presentPopoverFromRect:CGRectMake(10, 10, self.view.frame.size.width*3/4, self.view.frame.size.height*3/4) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        
        [imagePickerController release];
        imagePickerController = nil;
    } else
    {
        [self presentModalViewController:imagePickerController animated:YES];
        [imagePickerController release];
    }
    return YES;
}

- (BOOL)captureVideoButtonClick:(id)sender{
    //检查相机模式是否可用
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        NSLog(@"sorry, no camera or camera is unavailable!!!");
        return NO;
    }
    //获得相机模式下支持的媒体类型
    NSArray* availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
    BOOL canTakeVideo = NO;
    for (NSString* mediaType in availableMediaTypes) {
        if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
            //支持摄像
            canTakeVideo = YES;
            break;
        }
    }
    //检查是否支持摄像
    if (!canTakeVideo) {
        NSLog(@"sorry, capturing video is not supported.!!!");
        return NO;
    }
    //创建图像选取控制器
    imagePickerController = [[GDImagePickerController alloc] init];
    //设置图像选取控制器的来源模式为相机模式
    imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    //设置图像选取控制器的类型为动态图像
    imagePickerController.mediaTypes = [[[NSArray alloc] initWithObjects:(NSString*)kUTTypeMovie, nil] autorelease];
    //设置摄像图像品质
    imagePickerController.videoQuality = UIImagePickerControllerQualityTypeHigh;
    //设置最长摄像时间
    imagePickerController.videoMaximumDuration = 30;
    //允许用户进行编辑
    imagePickerController.allowsEditing = YES;
    //设置委托对象
    imagePickerController.delegate = self;
    //以模式视图控制器的形式显示
    [self presentModalViewController:imagePickerController animated:YES];
    [imagePickerController release];
    return YES;
    
}


- (void)image:(UIImage*)image didFinishSavingWithError:(NSError*)error contextInfo:(void*)contextInfo{
    if (!error) {
        NSLog(@"picture saved with no error.");
    }
    else
    {
        NSLog(@"error occured while saving the picture%@", error);
    }
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}
#pragma mark -

- (UIImage *) scaleFromImage: (UIImage *) image toSize: (CGSize) size
{
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
	
    return newImage;
}

- (void)changeLandscapeControlFrameWithImage
{
    [super changeLandscapeControlFrameWithImage];
//	if (cameraSheet && isPad)
//    {
//        [cameraSheet dismissWithClickedButtonIndex:0 animated:YES];
//        [self performSelector:@selector(CtImagePickerChoosePic) withObject:nil afterDelay:0.1];
//    }
}


- (void)changePortraitControlFrameWithImage
{
    [super changePortraitControlFrameWithImage];
//	if (cameraSheet && isPad)
//    {
//        [cameraSheet dismissWithClickedButtonIndex:0 animated:YES];
//        [self performSelector:@selector(CtImagePickerChoosePic) withObject:nil afterDelay:0.1];
//    }
}

#pragma mark-
#pragma mark UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissModalViewControllerAnimated:YES];
    
    if (nil==info) {
        return;
    }
    UIImage* editedImage = [info objectForKey:UIImagePickerControllerEditedImage];
    if (picker.sourceType==UIImagePickerControllerSourceTypeCamera)
//	if (picker.sourceType==UIImagePickerControllerSourceTypeCamera ||
//		picker.sourceType==UIImagePickerControllerSourceTypePhotoLibrary)
	{
       
        
        NSLog(@"get the media info: %@", info);
        //获取媒体类型
        NSString* mediaType = [info objectForKey:UIImagePickerControllerMediaType];
        //判断是静态图像还是视频
        if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
            //获取用户编辑之后的图像
 
            //将该图像保存到媒体库中
            UIImageWriteToSavedPhotosAlbum(editedImage, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
            //
           
        }
	}
    if (isPad)
    {
        [m_pPopoverViewController dismissPopoverAnimated:YES];
    }
     [self CtImagePickerDealWithPicture:editedImage];
    imagePickerController = nil;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	[picker dismissModalViewControllerAnimated:YES];
    imagePickerController = nil;
}

#pragma mark - UIPopoverControllerDelegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    [popoverController release];
    m_pPopoverViewController = nil;
}

#pragma mark
- (void)CtImagePickerChoosePic
{
    [self createGDActionSheetWithTitle:STR(@"Universal_edit", Localize_Universal) delegate:self cancelButtonTitle:STR(@"Universal_cancel", Localize_Universal) destructiveButtonTitle:nil tag:100 otherButtonTitles:STR(@"Universal_chooseFromAlbum", Localize_Universal),STR(@"Universal_tackPhoto", Localize_Universal), nil];
}

#pragma mark UIActionSheetDelegate Methods
- (void)GDActionSheet:(GDActionSheet *)actionSheet clickedButtonAtIndex:(int)index
{
   
	if (actionSheet.tag ==100)
	{
        if (index == 1)
        {
            if (![self takePictureButtonClick:nil])
            {
                GDAlertView *Myalert_ext = [[GDAlertView alloc] initWithTitle:nil andMessage:STR(@"Icall_NoSupportCall", Localize_Icall)];
                [Myalert_ext addButtonWithTitle:STR(@"Universal_ok", Localize_Universal) type:GDAlertViewButtonTypeCancel handler:nil];
                [Myalert_ext show];
                [Myalert_ext release];
            }
        }
		else  if(index == 0)
		{
			if (![self ChoosePictureButtonClick:nil])
            {
				GDAlertView *Myalert_ext = [[GDAlertView alloc] initWithTitle:nil andMessage:STR(@"Icall_NoSupportCall", Localize_Icall)];
                [Myalert_ext addButtonWithTitle:STR(@"Universal_ok", Localize_Universal) type:GDAlertViewButtonTypeCancel handler:nil];
                [Myalert_ext show];
                [Myalert_ext release];
			}
		}
        else if(index == 2)
        {
//            if (![self captureVideoButtonClick:nil])
//            {
//				NSLog(@"no PhotoLibrary");
//			}
        }
	}
}
-(void)CtImagePickerDealWithPicture:(UIImage*)imgPicture
{
    
}
-(UIImage*)CtIncapsulateImage:(UIImage*)imgPic andSize:(int)nSizeOfKByte
{
    NSData* pDataPic = UIImageJPEGRepresentation(imgPic, 1);
    UIImage *SmallImage = imgPic;
    NSUInteger sizeOrigin = [pDataPic length];
    NSUInteger sizesizeOriginKB = sizeOrigin / 1024;
    // 图片大于500k要先进行压缩
    if (sizesizeOriginKB > nSizeOfKByte) {
        float a = nSizeOfKByte;
        float  b = (float)sizesizeOriginKB;
        float q = sqrt(a/b);
        CGSize sizeImage = [imgPic size];
        CGFloat iwidthSmall = sizeImage.width * q;
        CGFloat iheightSmall = sizeImage.height * q;
        CGSize itemSizeSmall = CGSizeMake(iwidthSmall, iheightSmall);
        UIGraphicsBeginImageContext(itemSizeSmall);
        CGRect imageRectSmall = CGRectMake(0.0f, 0.0f, itemSizeSmall.width, itemSizeSmall.height);
        [imgPic drawInRect:imageRectSmall];
        SmallImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return SmallImage;
}
@end

//
//  CustomImagePickerCtr.h
//  AutoNavi
//
//  Created by liyuhang on 13-4-28.
//
//

#import <UIKit/UIKit.h>
#import "Foundation/Foundation.h"
#import "ANViewController.h"
@interface CustomImagePickerCtr : ANTableViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
    UIPopoverController *m_pPopoverViewController;
}
/*
 1 choose the picture
 */
-(void)CtImagePickerChoosePic;
/*
 2 SubCalss deal with the picture self
 */
-(void)CtImagePickerDealWithPicture:(UIImage*)imgPicture;
/*
 3 incapsulate
 */
-(UIImage*)CtIncapsulateImage:(UIImage*)imgPic andSize:(int)nSizeOfKByte;
@end

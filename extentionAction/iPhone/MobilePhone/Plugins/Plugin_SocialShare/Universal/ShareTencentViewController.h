//
//  ShareTencentViewController.h
//  AutoNavi
//
//  Created by gaozhimin on 13-8-15.
//
//

#import "ANViewController.h"
#import "ANParamValue.h"
#import "MBProgressHUD.h"
#import <QuartzCore/QuartzCore.h>
#import "ANViewController.h"
#import "GDBL_TCWeibo.h"

@interface ShareTencentViewController : ANViewController<UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate,MBProgressHUDDelegate,UIActionSheetDelegate,GDBL_TCWeiboDelegate,UIPopoverControllerDelegate> {
    GDBL_TCWeibo            *_tcWeibo;
    MBProgressHUD           *HUD;
    UITextView              *textView,*textView1;
    
    NSURLConnection         *my_connection;
    NSMutableData           *responseData;
    UILabel                 *left_Char;
    //UILabel                 *user_name;
    UIButton                *imageSwitch;
    UIImageView             * ImageTabbar;
    
    UIImage                 *image,*_IMageSharePicture;
    NSString                *oldcontent;
    UIView					*_blockerView;
    NSString                *share_content;
    UIWindow                *mTempFullscreenWindow;
    UIActionSheet           *Myalert_ext;
    UITextField             *textField;
    NSURLConnection         *urlconnection;
    NSString                *m_strSPcode;
    NSString                *m_locate;
    long Admin_code;
    
    BOOL  image_flag;      //图片点击放大标志
    id    delegate;
    id    restoreDelegate;
    int   click_flag;      //拍照或者相册选取标志
    char poi_name[128];
    long oldLon,oldLat;
}

@property (nonatomic, retain)  UITextView	    *textView;
@property (nonatomic, retain)  UITextView	    *textView1;
@property(assign)id restoreDelegate;
@property (nonatomic, copy) NSString            *share_content;
@property(nonatomic,retain)   UIImage           *_IMageSharePicture;
@property(nonatomic,copy) NSString              *m_strSPcode;
@property(nonatomic,copy) NSString              *m_locate;


- (id)initWithPicture:(UIImage*)type;
-(void)label_LeftCharInit;
-(void)blackViewInit;
-(void)Myalert_ext:(NSString *)message target:(id)target image:(UIImageView *)picture;
- (void)setupTextView;
-(void)setupImageSwitch;

@end

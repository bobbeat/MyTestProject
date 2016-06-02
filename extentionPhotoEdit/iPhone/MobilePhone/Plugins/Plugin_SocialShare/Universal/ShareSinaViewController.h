//
//  ShareSinaViewController.h
//  AutoNavi
//
//  Created by gaozhimin on 13-8-14.
//
//

#import "ANViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "ANParamValue.h"
#import "MBProgressHUD.h"
#import "GDBL_SinaWeibo.h"

@interface ShareSinaViewController : ANViewController<UITextViewDelegate,UIImagePickerControllerDelegate,UIActionSheetDelegate,UINavigationControllerDelegate,GDBL_SinaWeiboDelegate,UIPopoverControllerDelegate>
{
    GDBL_SinaWeibo * _sinaWeibo;

	UITextView              *_textViewAuto,*_textViewUserInput;
	
	UIImageView             *ImageTabbar;
	
	UILabel                 *_labelLimit;                                   //限制输入label
	//UILabel                 *user_name;
	UIView					*_blockerView;
	NSString                *share_content;
	UIButton                *imageSwitch;
	NSURLConnection         *urlconnection;
	NSString* m_strSPcode;
	NSString* m_locate;
	long Admin_code;

	int       click_flag;//图片点击放大标志
	id    restoreDelegate;
	char poi_name[128];
	long oldLon,oldLat;
    UIImageView *_imageViewBg;
    UIImageView *_imageViewInputBG;
}

//@property (nonatomic, retain) UITextView *textViewAuto;
//@property (nonatomic, retain) UITextView *textViewUserInput;
@property(nonatomic,retain)   UIImage    *imageSharePicture;                    //分享图片
@property (nonatomic, copy) NSString     *share_content;
@property(nonatomic,copy) NSString* m_strSPcode;
@property(nonatomic,copy) NSString* m_locate;
@property(assign)id restoreDelegate;

- (id)initWithPicture:(UIImage*)ShareImage;
- (void)setupTextView;
- (void)label_LeftCharInit;
- (void)blackViewInit;
-(void)setupImageSwitch;
//设置xml格式
-(NSString *)composeXML:(int)type SPcode:(NSString *)sptext adminCode:(long)code address:(NSString *)poitext description:(NSString *)desctext;


@end

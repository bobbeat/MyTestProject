//
//  ShareTencentViewController.m
//  AutoNavi
//
//  Created by gaozhimin on 13-8-15.
//
//

#import "ShareTencentViewController.h"
#import "NSString+Category.h"


#import "plugin_PoiNode.h"
#import "GDBL_Account.h"

typedef enum Button_ShareTencentMessage_Type
{
    Button_ShareTencentMessage_Picture,    //点击相机按钮
    
}Button_ShareTencentMessage_Type;

@interface ShareTencentViewController ()
{
    UIPopoverController *m_popoverController;
    UIImagePickerController *_picker;
    
}

@property (nonatomic, retain) NSURLConnection	*my_connection;

@end

@implementation ShareTencentViewController

@synthesize my_connection;
@synthesize textView;
@synthesize textView1;
@synthesize restoreDelegate;
@synthesize share_content;
@synthesize _IMageSharePicture;
@synthesize m_strSPcode;
@synthesize m_locate;

#pragma mark -
#pragma mark viewcontroller

- (id)initWithPicture:(UIImage*)ShareImage
{
	self = [super init];
	self._IMageSharePicture = ShareImage;
	
	return self;
}

- (id)init
{
	self = [super init];
	if (self)
	{
		
	}
	return self;
}


- (void)dealloc
{
    if (m_popoverController)
    {
        [m_popoverController dismissPopoverAnimated:YES];
    }
    [self._IMageSharePicture release];
	if (urlconnection != nil) {
		[urlconnection cancel];
		[urlconnection release];
		urlconnection = nil;
	}
    if (HUD.delegate != nil) {
        HUD.delegate = nil;
    }
    if (mTempFullscreenWindow != nil) {
        [mTempFullscreenWindow release];
        mTempFullscreenWindow = nil;
    }
    if (HUD != nil) {
        [HUD removeFromSuperview];
        [HUD release];
        HUD = nil;
    }
    
	[my_connection release];
    
	[super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}
- (void)viewDidUnLoad
{
	[super viewDidLoad];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
    
    self.title = STR(@"Share_SinaTwitterShare", Localize_POIShare);
    self.navigationItem.leftBarButtonItem = LEFTBARBUTTONITEM(STR(@"Universal_back", Localize_Universal), @selector(Logout:));
    self.navigationItem.rightBarButtonItem = RIGHTBARBUTTONITEM(STR(@"Share_Send", Localize_POIShare), @selector(send:));
    
    click_flag = 1;
    
    [self setupTextField];
	[self setupTextView];
	[self setupTextView1];
	[self setupImageSwitch];
	[self label_LeftCharInit];
    [self imageview_Init];
	[self blackViewInit];
	
	[textView1 becomeFirstResponder];
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
}
// Called when the view is about to made visible. Default does nothing
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    if (![textView1 isFirstResponder])
	{
		[textView1 becomeFirstResponder];
	}
	self.textView.selectedRange = NSMakeRange(0,0);
    
}
// Called when the view has been fully transitioned onto the screen. Default does nothing

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}
// Called when the view is dismissed, covered or otherwise hidden. Default does nothing

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

// Called after the view was dismissed, covered or otherwise hidden. Default does nothing
-(void)viewDidDisappear:(BOOL)animated;
{
    [super viewDidDisappear:animated];
}

#pragma mark -
#pragma mark control related
//初始化控件
-(void) initControl{
    
}

//调整控件竖屏坐标和图片
-(void)changePortraitControlFrameWithImage
{
    if (isiPhone)
    {
        [imageSwitch setCenter:CGPointMake(25, APPHEIGHT/2.0-46.0)];
        [textField setFrame:CGRectMake(1.0f, 0.0f, APPWIDTH-2.0, APPHEIGHT/2.0-30.0)];
        [self.textView setFrame:CGRectMake(10.0f, 10.0f, APPWIDTH-20.0, APPHEIGHT/2.0-72.0)];
        [self.textView1 setFrame:CGRectMake(13.0f, 12.0f, APPWIDTH-30.0, 53.0f)];
        [left_Char setCenter:CGPointMake(APPWIDTH-60.0,APPHEIGHT/2.0-47.0)];
        [_blockerView setFrame:CGRectMake(0.0f, 0.0f, APPWIDTH, CONTENTHEIGHT_V)];
        if (click_flag == 0) {
            [ImageTabbar setCenter:CGPointMake(APPWIDTH/2.0,APPHEIGHT/2.0-30.0)];
        }
        else {
            [ImageTabbar setFrame:CGRectMake(APPWIDTH/2.0-15.0, APPHEIGHT/2.0-56.0, 25.0f, 20.0f)];
        }
    }
    else
    {
        [textField setFrame:CGRectMake(15.0f, 15.0f, APPWIDTH-30.0, APPHEIGHT/2.0+138.0)];
		[imageSwitch setCenter:CGPointMake(55.0f, APPHEIGHT/2.0+123.0)];
		[self.textView setFrame:CGRectMake(30.0f, 30.0f, APPWIDTH-58.0, APPHEIGHT/2.0+68.0)];
		[self.textView1 setFrame:CGRectMake(33.0f, 33.0f, APPWIDTH-68.0, 52.3f)];
		[left_Char setCenter:CGPointMake(APPWIDTH-88.0,APPHEIGHT/2.0+128.0)];
		//[user_name setCenter:CGPointMake(110.0f,630.0f)];
		[_blockerView setFrame:CGRectMake(0.0f, 0.0f, APPWIDTH, CONTENTHEIGHT_V)];
		if (click_flag == 0) {
			[ImageTabbar setCenter:CGPointMake(APPWIDTH/2.0-4.0,APPHEIGHT/2.0-50.0)];
		}
		else {
		    [ImageTabbar setFrame:CGRectMake(APPWIDTH/2.0-34.0, APPHEIGHT/2.0+105.0, 50.0f, 35.0f)];
		}
    }
}

//调整控件横屏坐标和图片
-(void)changeLandscapeControlFrameWithImage
{
    if (isiPhone)
    {
        [imageSwitch setCenter:CGPointMake(25, 92)];
        [textField setFrame:CGRectMake(1.0f, 0.0f, APPHEIGHT-2.0, APPWIDTH/2.0-44.0)];
        [self.textView setFrame:CGRectMake(10.0f, 5.0f, APPHEIGHT-20.0, APPWIDTH/2.0-76.0)];
        [self.textView1 setFrame:CGRectMake(13.0f, 7.0f, APPHEIGHT-30.0, 53.0f)];
        [left_Char setCenter:CGPointMake(APPHEIGHT-60.0,APPWIDTH/2.0-57.0)];
        [_blockerView setFrame:CGRectMake(0.0f, 0.0f, APPHEIGHT, CONTENTHEIGHT_H)];
        if (click_flag == 0) {
            [ImageTabbar setCenter:CGPointMake(APPHEIGHT/2.0,APPWIDTH/2.0-20.0)];
        }
        else {
            [ImageTabbar setFrame:CGRectMake(APPHEIGHT/2.0-5.0, APPWIDTH/2.0-68.0, 25.0f, 20.0f)];
        }
    }
    else
    {
        [textField setFrame:CGRectMake(15.0f, 15.0f, APPHEIGHT-30.0, APPWIDTH/2.0-79.0)];
		[imageSwitch setCenter:CGPointMake(55.0f, APPWIDTH/2.0-94.0)];
		[self.textView setFrame:CGRectMake(30.0f, 30.0f, APPHEIGHT-60.0, APPWIDTH/2.0-144.0)];
		[self.textView1 setFrame:CGRectMake(34.0f, 33.0f, APPHEIGHT-70.0, 52.3f)];
		[left_Char setCenter:CGPointMake(APPHEIGHT-104.0,APPWIDTH/2.0-84.0)];
		//[user_name setCenter:CGPointMake(110.0f,290.0f)];
		[_blockerView setFrame:CGRectMake(0.0f, 0.0f, APPHEIGHT, CONTENTHEIGHT_H)];
		if (click_flag == 0) {
			[ImageTabbar setCenter:CGPointMake(APPHEIGHT/2.0-2.0,APPWIDTH/2.0-24.0)];
		}
		else {
		    [ImageTabbar setFrame:CGRectMake(APPHEIGHT/2.0-2.0, APPWIDTH/2.0-112.0, 50.0f, 35.0f)];
		}
    }
}

//改变控件文本
-(void)changeControlText
{
    
}

-(UIImageView*)FnallocImage
{
	ImageTabbar = [self createImageViewWithFrame:CGRectMake(165.0f, 174.0f, 25.0f, 20.0f) normalImage:_IMageSharePicture tag:0];
	ImageTabbar.userInteractionEnabled = YES;
	[ImageTabbar.layer setBackgroundColor:[[UIColor clearColor] CGColor]];
    [ImageTabbar.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    [ImageTabbar.layer setBorderWidth:0.5];
	[ImageTabbar.layer setCornerRadius:5.0];
	[ImageTabbar.layer setMasksToBounds:YES];
    ImageTabbar.clipsToBounds = YES;
	return ImageTabbar;
}

-(void)setupTextField
{
    textField = [[UITextField alloc] initWithFrame:CGRectMake(2.0f, 2.0f, 316.0f, 198.0f)];
	[textField setBorderStyle:UITextBorderStyleRoundedRect]; //外框类型
	[textField setBackgroundColor:[UIColor whiteColor]];
	textField.placeholder = @""; //默认显示的字
	
	//[textField.layer setBackgroundColor:[[UIColor grayColor] CGColor]];
    //	[textField.layer setBorderColor:[[UIColor grayColor] CGColor]];
    //	[textField.layer setBorderWidth:2.5];
    //	[textField.layer setCornerRadius:8.5];
    //	[textField.layer setMasksToBounds:YES];
    //	textField.clipsToBounds = YES;
	
	textField.userInteractionEnabled = NO;
	[self.view addSubview:  textField];
	[textField release];
	
}

- (void)setupTextView1
{
	self.textView1 = [self createTextViewWithTitle:nil fontSize:kSize2 textAlignment:UITextAlignmentLeft tag:0];
	self.textView1.frame = CGRectMake(13.0f, 12.0f, 290.0f, 45.0f);
	self.textView1.userInteractionEnabled = YES;
	
	[self.textView1.layer setBackgroundColor:[[UIColor whiteColor] CGColor]];
    [self.textView1.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    [self.textView1.layer setBorderWidth:0.5];
	[self.textView1.layer setCornerRadius:8.5];
	[self.textView1.layer setMasksToBounds:YES];
    self.textView1.clipsToBounds = YES;
	
	self.textView1.textColor = [UIColor blackColor];
	self.textView1.font = [UIFont systemFontOfSize:18];
	self.textView1.delegate = self;
	self.textView1.backgroundColor = [UIColor whiteColor];
	
	//self.textView1.text = [NSString stringWithFormat:@"%@",share_content];
	self.textView1.returnKeyType = UIReturnKeyDefault;
	self.textView1.keyboardType = UIKeyboardTypeDefault;	// use the default type input method (entire keyboard)
	self.textView1.scrollEnabled = YES;
	self.textView1.bounces = NO;
	self.textView1.tag =0;
	[self.view addSubview: self.textView1];
	
}

- (void)setupTextView
{
    self.textView = [self createTextViewWithTitle:nil fontSize:kSize2 textAlignment:UITextAlignmentLeft tag:0];
	self.textView.frame = CGRectMake(10.0f, 10.0f, 300.0f, 150.0f);
	self.textView.userInteractionEnabled = YES;
	self.textView.editable = NO;
	
	[self.textView.layer setBackgroundColor:[[UIColor whiteColor] CGColor]];
    [self.textView.layer setBorderColor:[[UIColor grayColor] CGColor]];
    [self.textView.layer setBorderWidth:2.5];
	[self.textView.layer setCornerRadius:8.5];
	[self.textView.layer setMasksToBounds:YES];
    self.textView.clipsToBounds = YES;
	
	self.textView.textColor = [UIColor blackColor];
	self.textView.font = [UIFont fontWithName:@"Arial" size:18];
	self.textView.delegate = self;
	self.textView.backgroundColor = [UIColor whiteColor];
	
	self.textView.text = [NSString stringWithFormat:@"%@",share_content];
	self.textView.returnKeyType = UIReturnKeyDefault;
	self.textView.keyboardType = UIKeyboardTypeDefault;	// use the default type input method (entire keyboard)
	self.textView.scrollEnabled = YES;
	self.textView.bounces = NO;
	self.textView.tag = 1;
	self.textView.selectedRange = NSMakeRange(0,0);
	// this will cause automatic vertical resize when the table is resized
	//self.textView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
	[self.view addSubview: self.textView];
	
}
-(void)setupImageSwitch
{
    imageSwitch = [self createButtonWithTitle:nil normalImage:@"photo.png" heightedImage:nil tag:Button_ShareTencentMessage_Picture];
	imageSwitch.frame = CGRectMake(0, 0, 40, 25);
	[imageSwitch setCenter:CGPointMake(165, 184)];
	[self.view addSubview:imageSwitch];
}

-(void)label_LeftCharInit
{
    left_Char = [self createLabelWithText:nil fontSize:0 textAlignment:UITextAlignmentRight];
	left_Char = [[UILabel alloc] initWithFrame:CGRectMake(0.0f,0.0f,100.0f, 20.0f)];
	int count = [self CountWord:textView.text];
	left_Char.text = [NSString stringWithFormat:@"%d/140",count];
	[left_Char setCenter:CGPointMake(300.0f,183.0f)];
	left_Char.textAlignment = UITextAlignmentRight;
	left_Char.textColor = [UIColor blackColor];
	left_Char.backgroundColor = [UIColor clearColor];
	left_Char.font = [UIFont systemFontOfSize:18.0f];
	left_Char.numberOfLines = 1;
	[self.view addSubview:left_Char];
}

-(void)blackViewInit
{
	_blockerView = [[[UIView alloc] initWithFrame: CGRectMake(0, 0, APPWIDTH, CONTENTHEIGHT_V)] autorelease];
	_blockerView.backgroundColor = [UIColor colorWithWhite: 0.0 alpha: 0.8];
	_blockerView.center = CGPointMake(self.view.bounds.size.width / 2, self.view.bounds.size.height / 2);
	_blockerView.alpha = 0.0;
	_blockerView.clipsToBounds = YES;
	[self.view addSubview: _blockerView];
}

-(void)imageview_Init
{
    ImageTabbar = [self createImageViewWithFrame:CGRectMake(185.0f, 174.0f, 25.0f, 20.0f) normalImage:_IMageSharePicture tag:0];
	[ImageTabbar setImage:_IMageSharePicture];
	ImageTabbar.userInteractionEnabled = YES;
	[ImageTabbar.layer setBackgroundColor:[[UIColor clearColor] CGColor]];
    [ImageTabbar.layer setBorderColor:[[UIColor whiteColor] CGColor]];
    [ImageTabbar.layer setBorderWidth:0.5];
	[ImageTabbar.layer setCornerRadius:5.0];
	[ImageTabbar.layer setMasksToBounds:YES];
    ImageTabbar.clipsToBounds = YES;
	[self.view addSubview:ImageTabbar];
}

#pragma mark -
#pragma mark control action

- (void)buttonAction:(UIButton *)button
{
    switch (button.tag)
    {
        case Button_ShareTencentMessage_Picture:
        {
            [self actionsheet_image:button];
        }
            break;
            
        default:
            break;
    }
}

- (void)send:(id)sender {
    
	
    NSString * temptext = [NSString stringWithFormat:@"%@%@",textView1.text,textView.text];
    
    if ([temptext isEqualToString:@""])
    {
        [self createAlertViewWithTitle:STR(@"Share_TencentTwitter", Localize_POIShare) message:STR(@"Share_InputSinaTwitterContent", Localize_POIShare) cancelButtonTitle:STR(@"Share_Ok", Localize_POIShare) otherButtonTitles:nil tag:-1];
        
		return;
    }
    
    [_tcWeibo TCSendWeibo:temptext WeiboImage:self._IMageSharePicture];
    if (!mTempFullscreenWindow)
    {
        mTempFullscreenWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        mTempFullscreenWindow.windowLevel = UIWindowLevelStatusBar;
        mTempFullscreenWindow.backgroundColor = [UIColor clearColor];
        [mTempFullscreenWindow makeKeyAndVisible];
        HUD = [[MBProgressHUD alloc] initWithWindow:mTempFullscreenWindow];
        HUD.labelText = STR(@"Share_TwitterSharing", Localize_POIShare);
        [mTempFullscreenWindow addSubview:HUD];
        HUD.delegate = self;
        [HUD show:YES];
    }
    
}
-(void)actionsheet_image:(id)sender
{
	if (ImageTabbar.hidden == YES)
    {
        [self createActionSheetWithTitle:nil cancelButtonTitle:STR(@"Share_Cancel", Localize_POIShare) destructiveButtonTitle:nil tag:1 otherButtonTitles:STR(@"Share_Photograph", Localize_POIShare),STR(@"Share_SelectFromAlbum", Localize_POIShare),nil];
	}
	else
	{
        [self createActionSheetWithTitle:nil cancelButtonTitle:STR(@"Share_Cancel", Localize_POIShare) destructiveButtonTitle:nil tag:0 otherButtonTitles:STR(@"Share_Photograph", Localize_POIShare),STR(@"Share_SelectFromAlbum", Localize_POIShare),STR(@"Share_ClearPicture", Localize_POIShare),nil];
	}
}

-(void)Myalert_ext:(NSString *)message target:(id)target image:(UIImageView *)img
{
	
	if(target == nil)
	{
		if (!mTempFullscreenWindow)
		{
			
			mTempFullscreenWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
			mTempFullscreenWindow.windowLevel = UIWindowLevelStatusBar;
			mTempFullscreenWindow.backgroundColor = [UIColor clearColor];
			[mTempFullscreenWindow makeKeyAndVisible];
			
			HUD = [[MBProgressHUD alloc] initWithView:mTempFullscreenWindow];
			
			// Add HUD to screen
			[mTempFullscreenWindow addSubview:HUD];
			
			// Regisete for HUD callbacks so we can remove it from the window at the right time
			HUD.delegate = self;
			
			HUD.labelText = message;
			
			// Show the HUD while the provided method executes in a new thread
			[HUD show:YES];
		}
	}
	else
	{
		HUD.labelText = message;
		HUD.customView = img;
		HUD.mode = MBProgressHUDModeCustomView;
	}
	
	[NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(hideMyHUD:) userInfo:nil repeats:NO];
	
	
	
}
-(void)hideMyHUD:(NSTimer*)timer
{
	[HUD hide:YES];
}

#pragma mark -
#pragma mark logic relate
-	(void)landscapeLogic
{
    
    
}
-	(void)portraitLogic
{
    
    
}

-(void)Logout:(id)sender
{
	[self.navigationController popViewControllerAnimated:YES];
	
}




#pragma mark -
#pragma mark notification
-(void)notificationReceived:(NSNotification*) notification
{
    
}

#pragma mark -
#pragma mark UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textview{
	if (textview.tag == 0) {
		return YES;
	}
	else if(textview.tag == 1){
		return NO;
	}
	return NO;
}
/********************************************
 function:微博字数限制
 auther:hlf
 date:2011.09.21
 parm_in:nil
 parm_out:nil
 ********************************************/
- (int)CountWord:(NSString*)s
{
    int i,n=[s length],l=0,a=0,b=0;
    unichar c;
    for(i=0;i<n;i++){
        c=[s characterAtIndex:i];
        if(isblank(c)){
            b++;
        }else if(isascii(c)){
            a++;
        }else{
            l++;
        }
    }
    if(a==0 && l==0) return 0;
    return l+(int)ceilf((float)(a+b)/2.0);
}

- (BOOL)textView:(UITextView *)textview shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
	NSString *temptext = [NSString stringWithFormat:@"%@%@",textView1.text,textView.text];
	int myInputcount = [self CountWord:temptext];
	if (range.length == 1 && myInputcount > 0) {
		myInputcount--;
	}
	if ((range.length == 0 && text.length > 0) || (range.length == 0 && myInputcount > 0) ) {
		myInputcount ++;
	}
	
	if (myInputcount >= 141) {
		
		return NO;
	}
	left_Char.text = [NSString stringWithFormat:@"%d/140",myInputcount];
    return YES;
}

#pragma mark -
#pragma mark UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	if (picker.sourceType==UIImagePickerControllerSourceTypeCamera ||
		picker.sourceType==UIImagePickerControllerSourceTypePhotoLibrary)
	{
		UIImage *originalImage = [info objectForKey:UIImagePickerControllerEditedImage];
        if (originalImage)
        {
            self._IMageSharePicture = originalImage;
            ImageTabbar.hidden = NO;
            [ImageTabbar setImage:originalImage];
            if (Interface_Flag == 0 ) {
                [ImageTabbar setFrame:CGRectMake(APPWIDTH/2.0-15.0, APPHEIGHT/2.0-76.0, 25.0f, 20.0f)];
            }
            else if(Interface_Flag == 1)
            {
                [ImageTabbar setFrame:CGRectMake(APPHEIGHT/2.0-5.0, APPWIDTH/2.0-68.0, 25.0f, 20.0f)];
            }
        }
	}
    if (m_popoverController)
    {
        [m_popoverController dismissPopoverAnimated:YES];
    }
	[picker dismissModalViewControllerAnimated:YES];
	_picker = nil;
}
/********************************************
 function:图片点击动画效果响应函数
 auther:hlf
 date:2011.09.21
 parm_in:nil
 parm_out:nil
 ********************************************/
-(void)imagePlay{
	
	
	if (click_flag == 1) {
		
		click_flag = 0;
		
		[_blockerView addSubview: ImageTabbar];
		_blockerView.alpha = 0.0;
		[UIView beginAnimations: nil context: nil];
		[UIView setAnimationDuration:0.5];
		[UIView setAnimationCurve:UIViewAnimationCurveLinear];
		_blockerView.alpha = 1.0;
		[UIView commitAnimations];
		_blockerView.center = CGPointMake(self.view.bounds.size.width / 2, self.view.bounds.size.height / 2);
		
		[ImageTabbar setFrame:CGRectMake(0.0f, 0.0f, self._IMageSharePicture.size.width/[ANParamValue sharedInstance].scaleFactor, self._IMageSharePicture.size.height/[ANParamValue sharedInstance].scaleFactor)];
		if (Interface_Flag == 0) {
			[ImageTabbar setCenter:CGPointMake(APPWIDTH/2.0,APPHEIGHT/2.0-30.0)];
		}
		else if(Interface_Flag == 1)
		{
			[ImageTabbar setCenter:CGPointMake(APPHEIGHT/2.0,APPWIDTH/2.0)];
		}
		[textView1 resignFirstResponder];
	}
	else {
		click_flag = 1;
		_blockerView.alpha = 1.0;
		[UIView beginAnimations: nil context: nil];
		[UIView setAnimationDuration:0.5];
		[UIView setAnimationCurve:UIViewAnimationCurveLinear];
		_blockerView.alpha = 0.0;
		[UIView commitAnimations];
		[self.view addSubview: ImageTabbar];
		if (Interface_Flag == 0 ) {
			[ImageTabbar setFrame:CGRectMake(APPWIDTH/2.0-15.0, APPHEIGHT/2.0-56.0, 25.0f, 20.0f)];
		}
		else if(Interface_Flag == 1)
		{
			[ImageTabbar setFrame:CGRectMake(APPHEIGHT/2.0-5.0, APPWIDTH/2.0-68.0, 25.0f, 20.0f)];
		}
		[textView1 becomeFirstResponder];
		self.textView.selectedRange = NSMakeRange(0,0);
	}
    
	
	
}
- (void) touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event
{
	UITouch *touch = [[event allTouches] anyObject];
	
	if ([touch view] == ImageTabbar) {
		[self imagePlay];
        
	}
    
	
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	
	[picker dismissModalViewControllerAnimated:YES];
	_picker = nil;
}

#pragma mark - UIPopoverControllerDelegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    [popoverController release];
    m_popoverController = nil;
}

#pragma mark -
#pragma mark TCWEIBOSEND delegate
-(void)TCSendWeiboSucceed
{
    UIImageView *tempimg = [[UIImageView alloc] initWithImage:IMAGE(@"Checkmark.png",IMAGEPATH_TYPE_1)];
    [self Myalert_ext:STR(@"Share_ShareSuccess", Localize_POIShare) target:HUD image:tempimg];
    [tempimg release];
    [self.navigationController popToRootViewControllerAnimated:YES];
}
-(void)TCSendWeiboFailedWithError:(NSError *) error{
    if (error.code == 100) {
        [self Myalert_ext:STR(@"Share_ShareAlready", Localize_POIShare) target:HUD image:nil];
    }
    else if(error.code == -1009)
    {
        [self Myalert_ext:STR(@"Share_ShareNetError", Localize_POIShare) target:HUD image:nil];
    }
    else if(error.code == 403)
    {
        [self Myalert_ext:STR(@"Share_ShareFrequently", Localize_POIShare) target:HUD image:nil];
    }
    else {
        [self Myalert_ext:STR(@"Share_ShareFail", Localize_POIShare) target:HUD image:nil];
    }
}

#pragma mark -
#pragma mark MBProgressHUDDelegate methods

- (void)hudWasHidden:(MBProgressHUD *)hud {
    // Remove HUD from screen when the HUD was hidded
	[mTempFullscreenWindow release];
	mTempFullscreenWindow = nil;
    [HUD removeFromSuperview];
    [HUD release];
	HUD = nil;
}

#pragma mark -
#pragma mark alertView delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	
	switch (alertView.tag)
	{
		case 0:
		    switch(buttonIndex + 1)
		{
			case 1:
				
			    break;
			case 2:
			{
				
			}
				break;
				
			default:
				break;
		}
			break;
            
		default:
			break;
			
	}
}

#pragma mark -
#pragma mark actionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	switch (actionSheet.tag)
	{
		case 0:
			switch(buttonIndex + 1)
		{
				
			case 1:
			{
				if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
                {
                    _picker = [[UIImagePickerController alloc]init];
                    _picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                    _picker.delegate = self;
                    _picker.allowsEditing = YES;
                    [self presentModalViewController:_picker animated:YES];
                    [_picker release];
                }
                else
                {
                    [self createAlertViewWithTitle:STR(@"Share_DeviceNotSupport", Localize_POIShare) message:nil cancelButtonTitle:STR(@"Share_Ok", Localize_POIShare) otherButtonTitles:nil tag:-1];
                }
				
			}
				break;
			case 2:
			{
				
                if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
                    
                    _picker = [[UIImagePickerController alloc] init];
                    _picker.delegate = self;
                    _picker.allowsEditing = YES;
                    _picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                    if (isPad)
                    {
                        m_popoverController = [[UIPopoverController alloc] initWithContentViewController:_picker];
                        [m_popoverController presentPopoverFromRect:CGRectMake(0, 0, 300, 300)
                                                             inView:self.view
                                           permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
                        m_popoverController.delegate = self;
                        [_picker release];
                        _picker = nil;
                    }
                    else
                    {
                        [self presentModalViewController:_picker animated:YES];
                        [_picker release];
                    }
                }
                else {
                    [self createAlertViewWithTitle:STR(@"Share_DeviceNotSupport", Localize_POIShare) message:nil cancelButtonTitle:STR(@"Share_Ok", Localize_POIShare) otherButtonTitles:nil tag:-1];
                }
				
			}
				break;
			case 3:
				ImageTabbar.hidden = YES;
				self._IMageSharePicture = nil;
				break;
            case 4:
				
				break;
			default:
				break;
		}
			break;
		case 1:
			switch(buttonIndex + 1)
		{
				
			case 1:
			{
                
                if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
                {
                    
                    UIImagePickerController *picker = [[UIImagePickerController alloc]init];
                    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                    picker.delegate = self;
                    picker.allowsEditing = YES;
                    [self presentModalViewController:picker animated:YES];
                    [picker release];
                }
                else
                {
                    [self createAlertViewWithTitle:STR(@"Share_DeviceNotSupport", Localize_POIShare) message:nil cancelButtonTitle:STR(@"Share_Ok", Localize_POIShare) otherButtonTitles:nil tag:-1];
                }
                
				
				
			}
				break;
			case 2:
			{
				if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
                    
                    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
                    picker.delegate = self;
                    picker.allowsEditing = YES;
                    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                    [self presentModalViewController:picker animated:YES];
                    [picker release];
                }
                else
                {
                    [self createAlertViewWithTitle:STR(@"Share_DeviceNotSupport", Localize_POIShare) message:nil cancelButtonTitle:STR(@"Share_Ok", Localize_POIShare) otherButtonTitles:nil tag:-1];
                }
			}
				break;
			case 3:
				break;
			default:
				break;
		}
		default:
			break;
	}
	
	
}

@end

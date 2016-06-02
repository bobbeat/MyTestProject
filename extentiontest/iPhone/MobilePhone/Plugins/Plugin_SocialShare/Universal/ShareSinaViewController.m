//
//  ShareSinaViewController.m
//  AutoNavi
//
//  Created by gaozhimin on 13-8-14.
//
//
#import "ShareSinaViewController.h"
#import "NSString+Category.h"
#import "GDBL_Account.h"
#import "POIDefine.h"
#import "GDActionSheet.h"
#import "GDImagePickerController.h"
#define kOAuthConsumerKey				@"1529070077"
#define kOAuthConsumerSecret			@"576a40e9e67f8b2a3d3723b89aa06b7b"

typedef enum Button_ShareSinaMessage_Type
{
    Button_ShareSinaMessage_Picture,    //点击相机按钮
    
}Button_ShareSinaMessage_Type;

@interface ShareSinaViewController ()
{
    UINavigationBar *_navigationBar;
    UINavigationItem *_navigationItem;
    UIPopoverController *m_popoverController;
    UIImagePickerController *_picker;
}

@end

@implementation ShareSinaViewController

//@synthesize textViewAuto;
//@synthesize textViewUserInput;
@synthesize imageSharePicture;
@synthesize share_content;
@synthesize m_strSPcode;
@synthesize m_locate;
@synthesize restoreDelegate;

#pragma mark -
#pragma mark viewcontroller

- (id)initWithPicture:(UIImage*)ShareImage
{
	self = [super init];
	self.imageSharePicture = ShareImage;
    self.imageSharePicture=nil;
    _sinaWeibo=[GDBL_SinaWeibo shareSinaWeibo];//新浪微博初始化
    _sinaWeibo.delegate = self;
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
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    [GDAlertView shouldAutorotate:YES];
    _sinaWeibo.delegate=nil;
	if (imageSharePicture!=nil) {
        [imageSharePicture release];
        imageSharePicture=nil;
    }
	if (urlconnection != nil) {
		[urlconnection cancel];
		[urlconnection release];
		urlconnection = nil;
	}
    [_textViewUserInput resignFirstResponder];
    
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
    
    //    self.title = STR(@"Share_SinaTwitterShare", Localize_POIShare);
    self.navigationItem.leftBarButtonItem = LEFTBARBUTTONITEM(STR(@"Universal_back", Localize_Universal), @selector(Logout:));
    self.navigationItem.rightBarButtonItem = RIGHTBARBUTTONITEM(STR(@"Share_Send", Localize_POIShare), @selector(send:));
	click_flag = 1;
	
    
    _imageViewBg=[[UIImageView alloc] initWithImage:[IMAGE(@"ShareBg.png", IMAGEPATH_TYPE_1) stretchableImageWithLeftCapWidth:10 topCapHeight:10]];
    _imageViewInputBG=[[UIImageView alloc] initWithImage:[IMAGE(@"ShareInputBg.png", IMAGEPATH_TYPE_1)stretchableImageWithLeftCapWidth:10 topCapHeight:10]];
    [self.view addSubview:_imageViewBg];
    _imageViewBg.userInteractionEnabled=YES;
    [_imageViewBg addSubview:_imageViewInputBG];
    _imageViewInputBG.userInteractionEnabled=YES;
    
	[self setupTextView];
	[self setup_textViewUserInput];
	[self setupImageSwitch];
	
	[self label_LeftCharInit];
	
	[self FnallocImage];
	
	[self blackViewInit];
    [self initControl];
	
	if (![_textViewUserInput isFirstResponder])
	{
		[_textViewUserInput becomeFirstResponder];
	}
    //    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
}
// Called when the view is about to made visible. Default does nothing
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    
    if (![_textViewUserInput isFirstResponder])
	{
		[_textViewUserInput becomeFirstResponder];
	}
	_textViewAuto.selectedRange = NSMakeRange(0,0);
}
// Called when the view has been fully transitioned onto the screen. Default does nothing

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_textViewUserInput becomeFirstResponder];
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
-(void )leftBtnEvent:(id)object
{
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark control related
//初始化控件
-(void) initControl{
  
    NSString *tmpTitle;
 
    tmpTitle=STR(@"Share_SinaTwitterShare", Localize_POIShare);
    
    _navigationBar =[POICommon allocNavigationBar:tmpTitle];

    _navigationItem = [[UINavigationItem alloc] init];
    UIBarButtonItem *item=LEFTBARBUTTONITEM(@"", @selector(Logout:));;
    [_navigationItem setLeftBarButtonItem:item];
    [_navigationBar pushNavigationItem:_navigationItem animated:NO];
    UIBarButtonItem *rightButon=RIGHTBARBUTTONITEM(STR(@"Share_Send", Localize_POIShare), @selector(send:));
    _navigationItem.rightBarButtonItem=rightButon;
    [self.view addSubview:_navigationBar];
    [_navigationItem release];
     
    self.title=STR(@"Share_SinaTwitterShare", Localize_POIShare);
    self.navigationItem.leftBarButtonItem=LEFTBARBUTTONITEM(@"", @selector(Logout:));
    self.navigationItem.rightBarButtonItem=RIGHTBARBUTTONITEM(STR(@"Share_Send", Localize_POIShare), @selector(send:));
    ImageTabbar.hidden = YES;
}

-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
//    if (IOS_7) {
//        CGRect rect=[[UIScreen mainScreen] applicationFrame];
//        rect.origin.x=0;
//        rect.origin.y=20;
//        rect.size.width=CCOMMON_APP_WIDTH;
//        rect.size.height=CCOMMON_APP_HEIGHT;
//        self.view.frame=rect;
//        //        [self changeLogicAfterRotation];
//    }
    
}

//调整控件竖屏坐标和图片
-(void)changePortraitControlFrameWithImage
{
    if (isiPhone)
    {
        [_imageViewBg setFrame:CGRectMake(3, 3+44 + DIFFENT_STATUS_HEIGHT, CGRectGetWidth(self.view.bounds)-6, 192)];
        [_imageViewInputBG setFrame:CGRectMake(7, 7, CGRectGetWidth(_imageViewBg.frame)-14, 135)];
        [imageSwitch setCenter:CGPointMake(16+16.5, 150+13.5)];
        [_textViewAuto setFrame:CGRectMake(7, 55, 296, 80)];
        [_textViewUserInput setFrame:CGRectMake(7, 7, 296, 48.0f)];
        [_labelLimit setCenter:CGPointMake(CGRectGetWidth(self.view.bounds)-75.0,150+13.5)];
    }
    else
    {
        
        
        [_imageViewBg setFrame:CGRectMake(3, 3+44+ DIFFENT_STATUS_HEIGHT, CGRectGetWidth(self.view.bounds)-6, 192+100)];
        [_imageViewInputBG setFrame:CGRectMake(7, 7, CGRectGetWidth(_imageViewBg.frame)-14, 135+100)];
        [imageSwitch setCenter:CGPointMake(16+16.5, 150+13.5+100)];
        [_textViewAuto setFrame:CGRectMake(7, 55+20, CGRectGetWidth(self.view.bounds)-11*2, 80+80)];
        [_textViewUserInput setFrame:CGRectMake(7, 7, CGRectGetWidth(self.view.bounds)-11*2, 48.0f+20)];
        [_labelLimit setCenter:CGPointMake(CGRectGetWidth(self.view.bounds)-75.0,150+13.5+100)];
    }
     [_blockerView setFrame:CGRectMake(0.0f, 44.0f+ DIFFENT_STATUS_HEIGHT, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds))];
    [_navigationBar setFrame:CGRectMake(_navigationBar.frame.origin.x,
                                        _navigationBar.frame.origin.y,
                                        APPWIDTH,
                                        _navigationBar.frame.size.height)];
    [self imageTabbarRefresh];
}

//调整控件横屏坐标和图片
-(void)changeLandscapeControlFrameWithImage
{
    if (isiPhone)
    {
        /*
        [_imageViewBg setFrame:CGRectMake(3, 3+44, CGRectGetWidth(self.view.bounds)-6, 192)];
        [imageSwitch setCenter:CGPointMake(25, 92)];
        [_textViewAuto setFrame:CGRectMake(10.0f, 5.0f, CGRectGetWidth(self.view.bounds)-20.0, CGRectGetHeight(self.view.bounds)/2.0-76.0)];
        [_textViewUserInput setFrame:CGRectMake(13.0f, 7.0f, CGRectGetWidth(self.view.bounds)-30.0, 53.0f)];
        [_labelLimit setCenter:CGPointMake(CGRectGetWidth(self.view.bounds)-60.0,CGRectGetHeight(self.view.bounds)/2.0-57.0)];
         */
        [_imageViewBg setFrame:CGRectMake(3, 3+44, CGRectGetWidth(self.view.bounds)-6, 192)];
        [_imageViewInputBG setFrame:CGRectMake(7, 7, CGRectGetWidth(_imageViewBg.frame)-14, 135)];
        [imageSwitch setCenter:CGPointMake(16+16.5, 150 +13.5)];
        [_textViewAuto setFrame:CGRectMake(10.0f, 38, CGRectGetWidth(self.view.bounds)-11*2, CGRectGetHeight(self.view.bounds)/2.0-76.0)];
        [_textViewUserInput setFrame:CGRectMake(13.0f, 7.0f, CGRectGetWidth(self.view.bounds)-30.0, 28.0f)];
        [_labelLimit setCenter:CGPointMake(CGRectGetWidth(self.view.bounds)-75.0,150+13.5)];
    }
    else
    {
        
        [_imageViewBg setFrame:CGRectMake(3, 3+44+ DIFFENT_STATUS_HEIGHT, CGRectGetWidth(self.view.bounds)-6, 192+100)];
        [_imageViewInputBG setFrame:CGRectMake(7, 7, CGRectGetWidth(_imageViewBg.frame)-14, 135+100)];
        [imageSwitch setCenter:CGPointMake(16+16.5, 150+13.5+100)];
        [_textViewAuto setFrame:CGRectMake(7, 55+20, CGRectGetWidth(self.view.bounds)-11*2, 80+80)];
        [_textViewUserInput setFrame:CGRectMake(7, 7, CGRectGetWidth(self.view.bounds)-11*2, 48.0f+20)];
        [_labelLimit setCenter:CGPointMake(CGRectGetWidth(self.view.bounds)-75.0,150+13.5+100)];
    
    }
    [_blockerView setFrame:CGRectMake(0.0f, 44.0f+ DIFFENT_STATUS_HEIGHT, CGRectGetWidth(self.view.bounds), CCOMMON_CONTENT_HEIGHT)];
    [self imageTabbarRefresh];
    [_navigationBar setFrame:CGRectMake(_navigationBar.frame.origin.x,
                                        _navigationBar.frame.origin.y,
                                        APPHEIGHT,
                                        _navigationBar.frame.size.height)];
    UIBarButtonItem *rightButon=RIGHTBARBUTTONITEM(STR(@"Share_Send", Localize_POIShare), @selector(send:));
    _navigationItem.rightBarButtonItem=rightButon;
}
-(void)imageTabbarRefresh
{
    
    if (click_flag == 0) {
//        [ImageTabbar setCenter:CGPointMake(CGRectGetWidth(self.view.bounds)/2.0,154+13.5+44+100*isPad)];
        [ImageTabbar setCenter:CGPointMake(CGRectGetWidth(self.view.bounds)/2.0,CCOMMON_CONTENT_HEIGHT/2.0f + DIFFENT_STATUS_HEIGHT)];
    }
    else {
        [ImageTabbar setFrame:CGRectMake(CGRectGetWidth(self.view.bounds)/2.0-25, 154+44+100*isPad+ DIFFENT_STATUS_HEIGHT, 50.0f, 27.0f )];
    }
    
}


-(void)FnallocImage
{
	ImageTabbar = [self createImageViewWithFrame:CGRectMake(165.0f, 174.0f + DIFFENT_STATUS_HEIGHT, 50, 27.0f) normalImage:imageSharePicture tag:0];
	ImageTabbar.userInteractionEnabled = YES;
	[ImageTabbar.layer setBackgroundColor:[[UIColor clearColor] CGColor]];
    [ImageTabbar.layer setBorderColor:[GETSKINCOLOR(@"SinaSelectImageBorderColor") CGColor]];
    [ImageTabbar.layer setBorderWidth:0.5];
	[ImageTabbar.layer setCornerRadius:5.0];
	[ImageTabbar.layer setMasksToBounds:YES];
    ImageTabbar.clipsToBounds = YES;
	[self.view addSubview:ImageTabbar];
}



- (void)setup_textViewUserInput
{
	_textViewUserInput = [self createTextViewWithTitle:nil fontSize:kSize2 textAlignment:UITextAlignmentLeft tag:0];
	_textViewUserInput.frame = CGRectMake(13.0f, 12.0f, 290.0f, 45.0f);
	_textViewUserInput.userInteractionEnabled = YES;
	_textViewUserInput.backgroundColor=[UIColor clearColor];
	_textViewUserInput.delegate = self;
    
    _textViewUserInput.textColor=TEXTCOLOR;
    _textViewUserInput.font=[UIFont systemFontOfSize:kSize2];
	_textViewUserInput.returnKeyType = UIReturnKeyDefault;
	_textViewUserInput.keyboardType = UIKeyboardTypeDefault;	// use the default type input method (entire keyboard)
	_textViewUserInput.scrollEnabled = YES;
	_textViewUserInput.bounces = NO;
	_textViewUserInput.tag =0;
    _textViewUserInput.contentInset=UIEdgeInsetsZero;
	[_imageViewBg addSubview: _textViewUserInput];
	
}

- (void)setupTextView
{
    _textViewAuto = [self createTextViewWithTitle:nil fontSize:kSize2 textAlignment:UITextAlignmentLeft tag:0];
	_textViewAuto.frame = CGRectMake(10.0f, 10.0f, 300.0f, 150.0f);
	_textViewAuto.userInteractionEnabled = YES;
	_textViewAuto.editable = NO;
	[_textViewAuto setFrame:CGRectMake(7, 55, 296, 135)];
    _textViewAuto.backgroundColor=[UIColor clearColor];
    
	_textViewAuto.delegate = self;
    
	_textViewAuto.textColor=TEXTCOLOR;
    _textViewAuto.font=[UIFont systemFontOfSize:kSize2];
	_textViewAuto.text = [NSString stringWithFormat:@"%@",share_content];
	_textViewAuto.returnKeyType = UIReturnKeyDefault;
	_textViewAuto.keyboardType = UIKeyboardTypeDefault;	// use the default type input method (entire keyboard)
	_textViewAuto.scrollEnabled = YES;
	_textViewAuto.bounces = NO;
	_textViewAuto.tag = 1;
    _textViewAuto.editable=NO;
    
	[_imageViewBg addSubview: _textViewAuto];
    
	
}
-(void)setupImageSwitch
{
    imageSwitch = [self createButtonWithTitle:nil normalImage:@"photo1.png" heightedImage:@"photo2.png" tag:Button_ShareSinaMessage_Picture];
	imageSwitch.frame = CGRectMake(0, 0, 33, 27);
	[imageSwitch setCenter:CGPointMake(165, 184)];
	[_imageViewBg addSubview:imageSwitch];
}

-(void)label_LeftCharInit
{
    //    _labelLimit = [self createLabelWithText:nil fontSize:0 textAlignment:UITextAlignmentRight];
	_labelLimit = [[UILabel alloc] initWithFrame:CGRectMake(0.0f,0.0f,100.0f, 20.0f)];
	int count = [self CountWord:_textViewAuto.text];
	_labelLimit.text = [NSString stringWithFormat:@"%d/140",count];
	[_labelLimit setCenter:CGPointMake(300.0f,183.0f)];
	_labelLimit.textAlignment = UITextAlignmentRight;
	_labelLimit.textColor = GETSKINCOLOR(@"SinaLimitPromptColor");
	_labelLimit.backgroundColor = [UIColor clearColor];
	_labelLimit.font = [UIFont systemFontOfSize:18.0f];
	_labelLimit.numberOfLines = 1;
	[_imageViewBg addSubview:_labelLimit];
    [_labelLimit release];
}

-(void)blackViewInit
{
	_blockerView = [[[UIView alloc] initWithFrame: CGRectMake(0, 44, APPWIDTH, CONTENTHEIGHT_V)] autorelease];
	_blockerView.backgroundColor = GETSKINCOLOR( @"SinaImageDisplayColor");
	_blockerView.center = CGPointMake(self.view.bounds.size.width / 2, self.view.bounds.size.height / 2);
	_blockerView.alpha = 0.0;
	_blockerView.clipsToBounds = YES;
	[self.view addSubview: _blockerView];
}

#pragma mark -
#pragma mark control action

- (void)buttonAction:(UIButton *)button
{
    switch (button.tag)
    {
        case Button_ShareSinaMessage_Picture:
        {
            [self actionsheet_image:button];
        }
            break;
            
        default:
            break;
    }
}

- (void)send:(id)sender {
    [_textViewUserInput resignFirstResponder];
	if ([_textViewAuto.text isEqualToString:@""])
    {
        [self createAlertViewWithTitle:STR(@"Share_SinaTwitter", Localize_POIShare) message:STR(@"Share_InputSinaTwitterContent", Localize_POIShare) cancelButtonTitle:STR(@"Share_Ok", Localize_POIShare) otherButtonTitles:nil tag:-1];
        
		return;
	}
    NSString * temptext = [NSString stringWithFormat:@"%@%@",_textViewUserInput.text,_textViewAuto.text];
    [_sinaWeibo sendWeibo:temptext WeiboImage:imageSharePicture];
    
    [self showLoadingViewInView:STR(@"Share_TwitterSharing", Localize_POIShare) view:self.view];
}
-(void)actionsheet_image:(id)sender
{
    GDActionSheet *actionSheet=nil;
	if (ImageTabbar.hidden == YES)
    {
        actionSheet= [self createGDActionSheetWithTitle:nil delegate:self cancelButtonTitle:STR(@"Share_Cancel", Localize_POIShare) destructiveButtonTitle:nil tag:1 otherButtonTitles:STR(@"Share_Photograph", Localize_POIShare),STR(@"Share_SelectFromAlbum", Localize_POIShare),nil];
        
	}
	else
	{
        
        actionSheet= [self createGDActionSheetWithTitle:nil delegate:self cancelButtonTitle:STR(@"Share_Cancel", Localize_POIShare) destructiveButtonTitle:nil tag:0 otherButtonTitles:STR(@"Share_Photograph", Localize_POIShare),STR(@"Share_SelectFromAlbum", Localize_POIShare),STR(@"Share_ClearPicture", Localize_POIShare),nil];
        
    }
    if (!isPad) {
        actionSheet.isSupportAutorotate=YES;
    }
}


-(void)Logout:(id)sender
{
    //	[self.navigationController popViewControllerAnimated:YES];
	[self dismissModalViewControllerAnimated:YES];
}

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
		
		[ImageTabbar setFrame:CGRectMake(0.0f, 0.0f, self.imageSharePicture.size.width/[ANParamValue sharedInstance].scaleFactor, self.imageSharePicture.size.height/[ANParamValue sharedInstance].scaleFactor)];
        
        [self imageTabbarRefresh];
        
		
		[_textViewUserInput resignFirstResponder];
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
		
        
        [self imageTabbarRefresh];
		[_textViewUserInput becomeFirstResponder];
		_textViewAuto.selectedRange = NSMakeRange(0,0);
	}
    
	
	
}
- (void) touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event
{
	UITouch *touch = [[event allTouches] anyObject];
	
	if ([touch view] == ImageTabbar||[touch view] == _blockerView) {
        if (self.imageSharePicture) {
            
            
            [self imagePlay];
        }
		
	}
	
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
            
            NSString* mediaType = [info objectForKey:UIImagePickerControllerMediaType];
          
                //将该图像保存到媒体库中
            if (picker.sourceType==UIImagePickerControllerSourceTypeCamera) {
                UIImageWriteToSavedPhotosAlbum(originalImage, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
            }
            
            self.imageSharePicture = originalImage;
            ImageTabbar.hidden = NO;
            [ImageTabbar setImage:originalImage];
            [self imageTabbarRefresh];
        }
	}
    if (m_popoverController)
    {
        [m_popoverController dismissPopoverAnimated:NO];
    }
	[picker dismissModalViewControllerAnimated:YES];
    if (isPad && IOS_7) {
        [self viewWillLayoutSubviews];
    }
	_picker = nil;
	
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	
    [picker dismissModalViewControllerAnimated:YES];
    if (isPad && IOS_7) {
        [self viewWillLayoutSubviews];
    }
	_picker = nil;
	
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

#pragma mark - UIPopoverControllerDelegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    [popoverController release];
    m_popoverController = nil;
    if (isPad && IOS_7) {
        [self viewWillLayoutSubviews];
    }
}
#pragma mark -
#pragma mark textviewdelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textview{
	if (textview.tag == 0) {
		return YES;
	}
	else if(textview.tag == 1){
		return NO;
	}
    return NO;
}
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
-(NSString*)cutoOutString:(NSString *)string wihtLenght:(int )lenght
{
    int i,n=[string length];
    if (n<lenght) {
        return string;
    }
    int count=0;
    unichar c;
    for(i=0;i<n;i++){
        c=[string characterAtIndex:i];
        if(isblank(c)){
            count+=1;
        }else if(isascii(c)){
            count+=1;
        }else{
            count+=2;
        }
        if (count>=lenght*2) {
            break;
        }
    }
    return [string substringToIndex:i];
}

- (BOOL)textView:(UITextView *)textview shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
	NSString *temptext = [NSString stringWithFormat:@"%@%@",_textViewUserInput.text,_textViewAuto.text];
	int myInputcount = [self CountWord:temptext];
	if (text.length == 0) {
        if(textview.text.length > 0)
            myInputcount--;
        return YES;
	}
    else {
        myInputcount ++;
    }
    
	if (myInputcount >= 141) {
        
		return NO;
	}
	
    return YES;
}
-(void)textViewDidChange:(UITextView *)_textView
{
    NSString *temptext = [NSString stringWithFormat:@"%@%@",_textViewUserInput.text,_textViewAuto.text];
	int myInputcount = [self CountWord:temptext];
    if (myInputcount>140) {
        double delayInSeconds = 0.02;
        int count1=[self CountWord:_textViewAuto.text];
        int lenght = 140-count1;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            _textViewUserInput.text=[self cutoOutString:_textViewUserInput.text wihtLenght:lenght];
             _labelLimit.text = [NSString stringWithFormat:@"%d/140",140];
        });
    }
    else
    {

    _labelLimit.text = [NSString stringWithFormat:@"%d/140",myInputcount];
    }
}
#pragma mark - sinaWeiboDelegate
-(void)sendWeiboSucceed
{
    [self hideLoadingViewWithAnimated:nil];
    [_textViewUserInput resignFirstResponder];
    [self dismissModalViewControllerAnimated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ShareSuccess" object:nil];
}

-(void)sendWeiboFailedWithError:(NSError *)error
{
    [self hideLoadingViewWithAnimated:NO];
    if (error.code == 100) {
        [self showAutoHideAlertView:STR(@"Share_ShareSuccess", Localize_POIShare) showTime:2.0f];
        
    }
    else if(error.code == -1009)
    {
        [self showAutoHideAlertView:STR(@"Share_ShareNetError", Localize_POIShare) showTime:2.0f];
        
    }
    else if(error.code == 403)
    {
        [self showAutoHideAlertView:STR(@"Share_ShareFrequently", Localize_POIShare) showTime:2.0f];
        
    }
    else {
        [self showAutoHideAlertView:STR(@"Share_ShareFail", Localize_POIShare) showTime:2.0f];
    }
    
    NSLog(@"Post status failed with error : %@", error);
    
}



#pragma mark -
#pragma mark actionSheetDelegate

- (void)GDActionSheet:(GDActionSheet *)actionSheet clickedButtonAtIndex:(int)index
{
    [_textViewUserInput resignFirstResponder];
    if ([actionSheet tag]==0) {
        if (index==2) {
            ImageTabbar.hidden = YES;
            self.imageSharePicture = nil;
            return;
        }
    }
    switch (index) {
        case 0:
        {
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
            {
                _picker = [[GDImagePickerController alloc]init];
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
        case 1:
        {
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
                
                _picker = [[GDImagePickerController alloc] init];
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
            
        default:
            break;
    }
}
- (BOOL)shouldAutorotate
{
    return isPad;
    
}

- (NSUInteger)supportedInterfaceOrientations
{
    
    NSUInteger  orientations=isPad==NO? UIInterfaceOrientationMaskPortrait:UIInterfaceOrientationMaskAll;
    if (isPad==NO) {
        [GDAlertView shouldAutorotate:NO];
        return UIInterfaceOrientationMaskPortrait;
    }
    else
    {
        if (!OrientationSwitch) {
           
            return (1<<[[UIApplication sharedApplication] statusBarOrientation]);
            
        }
        else
        {
            return UIInterfaceOrientationMaskAll;
        }
    }
    return  orientations;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    
    return  isPad?(OrientationSwitch) : (interfaceOrientation == UIDeviceOrientationPortrait);
    
}

@end

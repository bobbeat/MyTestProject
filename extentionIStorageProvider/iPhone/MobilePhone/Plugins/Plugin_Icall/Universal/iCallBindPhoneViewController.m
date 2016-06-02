//
//  Plugin_GDAccount_RegistController.m
//  AutoNavi
//
//  Created by gaozhimin on 12-12-18.
//
//

#import "iCallBindPhoneViewController.h"
#import "Plugin_Account_Globall.h"
#import "Plugin_Account_Utility.h"
#import "GDBL_Account.h"
#import "VCTranslucentBarButtonItem.h"
#import "ANParamValue.h"
#import "QLoadingView.h"
#import "Plugin_GDAccount_InputCell.h"
#import "Plugin_GDAccount_InputView.h"
#import "Plugin_ColorTitleButton.h"
#import "WebViewController.h"
#import "AppDelegate_iPhone.h"
#import "AccountTimeButton.h"
#import "AccountNotify.h"
#import "AccountRegistPasswordViewController.h"
#import "AccountPersonalData.h"
#import "NSString+Category.h"
#import "GDAlertView.h"
#import "MWAccountOperator.h"
#import "MWICallRequest.h"
#import "MWDefine.h"
#import "POICommon.h"
@interface iCallBindPhoneViewController ()<NetReqToViewCtrDelegate>
{
    UINavigationBar *_navigationBar;
    NSArray         *_arrayTitle;
    Plugin_GDAccount_InputView *m_checkButton,*m_userNameButton;
    UIButton        *_buttonRegist;
    AccountTimeButton *m_btnGetAuthCode;
    UITextField *m_userNameField;
    UITextField *m_checkField;
    UITextField *m_currentField;
    int m_type;  // 3 智驾绑定手机 4:智驾修改手机
    UIImageView * _imageViewUserBg,*_imageViewVerificationBg;
}


@end


@implementation iCallBindPhoneViewController

#pragma mark -
#pragma mark initialization
-(id)initWithType:(int)type
{
    self= [super init];
    if (self)
    {
        m_type = type;
		moveHeight =0;
		currText = nil;
    }
    return self;
}

-(id)init
{
    return [self initWithType:0];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.layer.contents = nil;
    self.navigationItem.leftBarButtonItem =BARBUTTON(@"",@selector(goBack_Click));
    _arrayTitle = [[NSArray alloc] initWithObjects:STR(@"Account_PhoneNumber", Localize_Account),STR(@"Account_Verification", Localize_Account),STR(@"Account_Next", Localize_Account),STR(@"Account_RegistrationAgreement", Localize_Account),STR(@"Account_Agree", Localize_Account),STR(@"Account_BindPhoneNumber", Localize_Account),STR(@"Universal_ok", Localize_Universal), nil];
    [self initControl];
}
-(void)initControl
{
    if (m_type == 3 || m_type == 4)
    {
        NSString *tmpTitle;
        if (m_type==3) {
            tmpTitle = [_arrayTitle objectAtIndex:5];
        }else if (m_type == 4)
        {
            tmpTitle = STR(@"Icall_ModifyPhone", Localize_Icall);
        }
        
        _navigationBar=[POICommon allocNavigationBar:tmpTitle];
        
        UINavigationItem *navigationitem = [[UINavigationItem alloc] init];
        UIBarButtonItem *item=LEFTBARBUTTONITEM(@"", @selector(GoBack:));;
        [navigationitem setLeftBarButtonItem:item];
        [_navigationBar pushNavigationItem:navigationitem animated:NO];
        [self.view addSubview:_navigationBar];
        [navigationitem release];
    }
    //用户名
    UIImage * buttonImageNormal1s = IMAGE(@"icallinput.png", IMAGEPATH_TYPE_1);
    UIImage * searchBG = [IMAGE(@"icallinput.png", IMAGEPATH_TYPE_1) stretchableImageWithLeftCapWidth:7 topCapHeight:buttonImageNormal1s.size.width/2];
    _imageViewUserBg = [[self createImageViewWithFrame:CGRectMake(0, 10, _tableView.bounds.size.width, kHeight2) normalImage:searchBG tag:4001] retain];
    _imageViewUserBg.userInteractionEnabled = YES;
    [_tableView addSubview:_imageViewUserBg];
    
    UITextField * textField1 = [[UITextField alloc]initWithFrame:CGRectMake(20,5, APPWIDTH-40, 38)];
    textField1.placeholder = [_arrayTitle objectAtIndex:0];;
    textField1.keyboardType = UIKeyboardTypeNumberPad;
    textField1.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [_imageViewUserBg addSubview:textField1];
    textField1.delegate = self;
    m_userNameField = textField1;
    [textField1 release];
    
    _imageViewVerificationBg = [[self createImageViewWithFrame:CGRectMake(0, 65, APPWIDTH-130, kHeight2) normalImage:searchBG tag:4002] retain];
    _imageViewVerificationBg.userInteractionEnabled = YES;
    [_tableView addSubview:_imageViewVerificationBg];
    
    UITextField * textField2 = [[UITextField alloc]initWithFrame:CGRectMake(20,5,APPWIDTH-160, 38)];
    textField2.placeholder = [_arrayTitle objectAtIndex:1];
    textField2.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [_imageViewVerificationBg addSubview:textField2];
    textField2.delegate = self;
    m_checkField = textField2;
    [textField2 release];
    
    UIImage * buttonImageNormal1 = IMAGE(@"CommonBtn1.png", IMAGEPATH_TYPE_1) ;
    _buttonRegist = [self createButtonWithTitle:[_arrayTitle objectAtIndex:6] normalImage:@"CommonBtn1.png" heightedImage:@"CommonBtn2.png" tag:4003 strechParamX:buttonImageNormal1.size.width/2 strechParamY:buttonImageNormal1.size.height/2];
    _buttonRegist.titleLabel.font = [UIFont systemFontOfSize:18.0];
   	[_buttonRegist setTitleColor:GETSKINCOLOR(ACCOUNT_BUTTON_TITLE_COLOR) forState:(UIControlState)UIControlStateNormal];
    if ( m_type == 3 || m_type == 4)
    {//完成绑定
        m_btnGetAuthCode  = [[AccountTimeButton alloc] initWithFrame:CGRectZero countDown:60 viewType:BIND_PHONE_VIEW];
        [m_btnGetAuthCode setTitle:STR(@"Account_GetVerification", Localize_Account) forState:(UIControlState)UIControlStateNormal];
        [m_btnGetAuthCode addTarget:self action:@selector(getAuthCode_click)forControlEvents:UIControlEventTouchUpInside];
        m_btnGetAuthCode.titleLabel.font =  [UIFont boldSystemFontOfSize:14];
        [_tableView addSubview:m_btnGetAuthCode];
        [m_btnGetAuthCode release];
    }
    [_tableView  addSubview:_buttonRegist];
}
- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [GDAlertView shouldAutorotate:NO];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    m_userNameField.text = @"";
    m_checkField.text = @"";

    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)dealloc{
    [MWICallRequest sharedInstance].icallNetDelegate = nil;
    [GDAlertView shouldAutorotate:YES];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    CRELEASE(_imageViewVerificationBg);
    CRELEASE(_imageViewUserBg);
    [_arrayTitle release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - nomal method

-(void)registListenMessage:(NSNotification*)notify
{
	
}

//调整控件竖屏坐标和图片
-(void)changePortraitControlFrameWithImage
{
    [super changePortraitControlFrameWithImage];
    _tableView.frame = CGRectMake(10, 44.0+DIFFENT_STATUS_HEIGHT, self.view.bounds.size.width - 10 * 2, self.view.bounds.size.height);
    CGSize size = _tableView.bounds.size;
    [_imageViewUserBg setFrame:CGRectMake(0, 10, _tableView.bounds.size.width, kHeight2)];
    [_imageViewVerificationBg setFrame:CGRectMake(0, 65, _tableView.bounds.size.width -130, kHeight2)];
    
    
    m_userNameButton.frame = CGRectMake(0, 10,size.width, kHeight2);
    
    m_checkButton.frame = CGRectMake(0, 65,size.width - 140, kHeight2);
    
    m_btnGetAuthCode.frame = CGRectMake(size.width - 110, 65, 110, kHeight2);
    

    _buttonRegist.frame = CGRectMake(0, 150, size.width, 46.0f);
    UIImageView *tmp = (UIImageView *)[_navigationBar viewWithTag:1];
    [tmp setFrame:CGRectMake(0.0, 0.0, APPWIDTH, 44.0)];
    [tmp setImage:IMAGE(@"navigatorBarBg.png",IMAGEPATH_TYPE_1)];
    
    
    
}

//调整控件横屏坐标和图片
-(void)changeLandscapeControlFrameWithImage
{
    [super changeLandscapeControlFrameWithImage];
    [_tableView reloadData];
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return  UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (interfaceOrientation == UIDeviceOrientationPortrait)
    {
        return YES;
    }
	return  NO;
}

-(void)GoBack:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}


-(void) btn_agreement_click
{
    WebViewController *web;
    if (fontType == 0)
    {
        web = [[WebViewController alloc] initWithURL:REQ_MZDM];
    }
    else if (fontType == 1)
    {
        web = [[WebViewController alloc] initWithURL:REQ_MZDM_TW];
    }
    else
    {
        web = [[WebViewController alloc] initWithURL:REQ_MZDM_EN];
    }
    [self.navigationController pushViewController:web animated:YES];
    [web release];
}

#pragma mark 获取验证码
-(void) getAuthCode_click
{//获取验证码
	if (m_currentField)
    {
        [m_currentField resignFirstResponder];
        m_currentField = nil;
    }
    if ([NSString checkPhoneStandardWith:m_userNameField.text])
    {
        [[MWICallRequest sharedInstance]Net_accountGet95190CheckNumberWith:REQ_GET_95190CHECK phone:m_userNameField.text delegate:self];
        [m_btnGetAuthCode ButtonPressd];
        [QLoadingView showLoadingView:nil view:(UIWindow *)self.view];
        }
        else
        {
         [[AccountNotify SharedInstance] ShowAccountMessageWithTag:Account_Alert_Input_Phone delegate:self];
        }
    }
#pragma mark 完成绑定

-(void)buttonAction:(UIButton *)sender
{
    if (sender.tag == 4003) {
        [self btn_next_click];
    }
}
-(void) btn_next_click
{//完成绑定
    if (m_currentField)
    {
        [m_currentField resignFirstResponder];
        m_currentField = nil;
    }

    if (![NSString checkPhoneStandardWith:m_userNameField.text]) {
        [[AccountNotify SharedInstance] ShowAccountMessageWithTag:Account_Alert_Input_Phone delegate:self];
		return;
	}
    if([m_checkField.text length]<1)//验证码不能为空
    {
		[[AccountNotify SharedInstance] ShowAccountMessageWithTag:Account_Alert_Input_Check delegate:self];
		return;
	}
    if ([m_checkField.text isEqual:self.identifyCode])
    {
    if (m_type == 3 || m_type == 4)
    {
        if (m_type == 3)
        {//接口用于实现客户端向服务端绑定用于95190服务的电话号码 3.
            [[MWICallRequest sharedInstance]Net_accountBind95190PhoneWith:REQ_BIND_95190PHONE_NUMBER phone:m_userNameField.text license_val:m_checkField.text delegate:self];
             }
        else
        {//接口用于实现客户端向服务端修改95190服务的电话号码。 4.
            [[MWICallRequest sharedInstance]Net_accountModify95190PhoneWith:REQ_MODIFY_95190PHONE_NUMBER phone:m_userNameField.text  license_val:m_checkField.text delegate:self];
             }
         [QLoadingView showLoadingView:nil view:(UIWindow *)self.view];
    }
    }
    else
    {
        [POICommon showAutoHideAlertView:STR(@"Icall_EnterRightVerCode",Localize_Icall )];
    }
	
   
    }
#pragma mark UITextField delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    m_currentField = textField;
	return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
   
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField;
{
   
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
	return YES;
}
- (BOOL)textFieldShouldClear:(UITextField *)textField
{
	return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
    m_currentField = nil;
	if ([textField.text length] > 0) {
		if (strlen(NSSTRING_TO_CSTRING(textField.text )) > 49)
		{
			GDAlertView *Myalert_ext = [[GDAlertView alloc] initWithTitle:nil andMessage:STR(@"Universal_lengthTooLong", Localize_Universal)];
            [GDAlertView shouldAutorotate:NO];
            [Myalert_ext addButtonWithTitle:STR(@"Universal_ok", Localize_Universal) type:GDAlertViewButtonTypeDefault handler:nil];
			[Myalert_ext show];
			[Myalert_ext release];
			textField.text = @"";
		}
	}
	return YES;
}

#pragma mark - UITableViewDataSource,UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kHeight2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    
    return 20.0;
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 150;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    float height = [self tableView:tableView heightForFooterInSection:section];
    UIView *view = nil;
    view = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, height)] autorelease];
    view.backgroundColor = GETSKINCOLOR(HUD_CLEAR_BACKGROUND_COLOR);
    return view;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    float height = [self tableView:tableView heightForHeaderInSection:section];
    UIView *view = nil;
    view = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, height)] autorelease];
    view.backgroundColor = GETSKINCOLOR(HUD_CLEAR_BACKGROUND_COLOR);
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell)
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    // Configure the cell...
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = GETSKINCOLOR(HUD_CLEAR_BACKGROUND_COLOR);
    cell.backgroundView = nil;
    return cell;
}

#pragma mark - NetReqToViewCtrDelegate

- (void)requestToViewCtrWithRequestType:(RequestType)requestType didFinishLoadingWithResult:(id)result
{
    NSLog(@"%@",result);
    if (requestType == REQ_GET_95190CHECK)
    {
        if ([[[result objectForKey:@"response"] objectForKey:@"repdesc"] isEqualToString:@"请求服务成功"]) {
            //验证码已经发送
            self.identifyCode = [[result objectForKey:@"svccont"] objectForKey:@"identifyCode"];
            [[AccountNotify SharedInstance] ShowAccountMessageWithTag:Account_Alert_Check_Success delegate:self];
        }else
            {
            int errorType =[[[result objectForKey:@"response"] objectForKey:@"rspcode"] intValue];
             [[MWICallRequest sharedInstance] getErrorCodeType:errorType];

        }
        
    }
    else if (requestType == REQ_BIND_95190PHONE_NUMBER)
    {
        if ([[[result objectForKey:@"response"] objectForKey:@"repdesc"] isEqualToString:@"请求服务成功"]) {
            [self GoBack:nil];
            [[AccountNotify SharedInstance] ShowAccountMessageWithTag:Account_Alert_Bind_Success delegate:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:Icall_Notify object:m_userNameField.text];
        }else
        {
            int errorType =[[[result objectForKey:@"response"] objectForKey:@"rspcode"] intValue];
            [[MWICallRequest sharedInstance] getErrorCodeType:errorType];
        }
    }
    else if (requestType == REQ_MODIFY_95190PHONE_NUMBER)
    {
        if ([[[result objectForKey:@"response"] objectForKey:@"repdesc"] isEqualToString:@"请求服务成功"]) {
            [self GoBack:nil];
            [[AccountNotify SharedInstance] ShowAccountMessageWithTag:Account_Alert_Bind_Success delegate:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:Icall_Notify object:m_userNameField.text];
        }else
        {
            int errorType =[[[result objectForKey:@"response"] objectForKey:@"rspcode"] intValue];
            [[MWICallRequest sharedInstance] getErrorCodeType:errorType];
        }
    }
    [QLoadingView hideWithAnimated:NO];
}

- (void)requestToViewCtrWithRequestType:(RequestType)requestType didFailWithError:(NSError *)error
{
    if ([error code] == NSURLErrorTimedOut)
    {
        [[AccountNotify SharedInstance] ShowAccountMessageWithTag:Account_Alert_Net_TimeOut delegate:self];
    }
    else
    {
        [[AccountNotify SharedInstance] ShowAccountMessageWithTag:Account_Alert_Net_Error delegate:self];
    }
    [QLoadingView hideWithAnimated:NO];
}

#pragma mark UIAlertView
- (void)MyalertView:(NSString *)titletext canceltext:(NSString *)mycanceltext othertext:(NSString *)myothertext alerttag:(int)mytag
{
	
    GDAlertView *alert;
    
    __block id weakDelegate = self;
    alert = [[GDAlertView alloc] initWithTitle:nil andMessage:titletext];
    [GDAlertView shouldAutorotate:NO];
    if (mycanceltext)
    {
        [alert addButtonWithTitle:mycanceltext type:GDAlertViewButtonTypeDefault handler:^(GDAlertView *alertView)
         {
             if (weakDelegate && [weakDelegate respondsToSelector:@selector(alertView:clickedButtonAtIndex:)])
             {
                 [weakDelegate alertView:(UIAlertView *)alertView clickedButtonAtIndex:0];
             }
         }];
    }
    if (myothertext)
    {
        [alert addButtonWithTitle:myothertext type:GDAlertViewButtonTypeDefault handler:^(GDAlertView *alertView)
         {
             if (weakDelegate && [weakDelegate respondsToSelector:@selector(alertView:clickedButtonAtIndex:)])
             {
                 [weakDelegate alertView:(UIAlertView *)alertView clickedButtonAtIndex:1];
             }
         }];
    }
	
	alert.tag = mytag;
	[alert show];
	[alert release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
	switch (alertView.tag)
    {
            
        case 1:
            [_tableView reloadData];
            break;
        case 2:
            
            break;
        default:
            break;
    }
}

- (void)NetRequestError
{
    GDAlertView *Myalert_ext = [[GDAlertView alloc] initWithTitle:nil andMessage:STR(@"Universal_networkError", Localize_Universal) ];
   [GDAlertView shouldAutorotate:NO];
    [Myalert_ext addButtonWithTitle:STR(@"Universal_ok", Localize_Universal)  type:GDAlertViewButtonTypeCancel handler:^(GDAlertView * alert){
    }];
    [Myalert_ext show];
    [Myalert_ext release];
}

@end

//
//  Plugin_GDAccount_RegistController.m
//  AutoNavi
//
//  Created by gaozhimin on 12-12-18.
//
//

#import "AccountRegistPhoneViewController.h"
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
#import "MWAccountRequest.h"
#import "AccountLoginViewController.h"

@interface AccountRegistPhoneViewController ()<NetReqToViewCtrDelegate>
{
    
    NSArray *m_registContent;
    Plugin_GDAccount_InputView *m_checkButton,*m_userNameButton;
    UIButton *m_registButton;
    Plugin_ColorTitleButton *m_agreementButton;
    UILabel *m_tipLable;
    AccountTimeButton *m_btnGetAuthCode;
    
    UITextField *m_userNameField;
    UITextField *m_checkField;
    
    UITextField *m_currentField;
    
    UIButton *button_prompt;
    
    int m_type;  //0 注册界面  1 第三方帐号绑定手机 2 老用户绑定手机
    MWAccountRequest *m_accountNetReq;
    
    NSString *m_getCheckcodePhone;//获取验证码的手机号，用于合法性检查
}


@end


@implementation AccountRegistPhoneViewController


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
    
    self.title = STR(@"Account_Register", Localize_Account);
    self.navigationItem.leftBarButtonItem =BARBUTTON(@"",@selector(goBack_Click));
    m_registContent = [[NSArray alloc] initWithObjects:STR(@"Account_PhoneNumber", Localize_Account),STR(@"Account_Verification", Localize_Account),STR(@"Account_Next", Localize_Account),STR(@"Account_RegistrationAgreement", Localize_Account),STR(@"Account_Agree", Localize_Account),STR(@"Account_BindPhoneNumber", Localize_Account),STR(@"Account_FinishBind", Localize_Account), nil];
    
    if (m_type == 1 || m_type == 2)
    {
        self.title = [m_registContent objectAtIndex:5];
    }
    //用户名
    m_userNameButton = [[Plugin_GDAccount_InputView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, kHeight2)];
    m_userNameButton.m_input.delegate = self;
    m_userNameButton.userInteractionEnabled = YES;
    m_userNameButton.m_input.tag = 0;
    m_userNameButton.m_input.placeholder = [m_registContent objectAtIndex:0];
    m_userNameButton.m_input.keyboardType = UIKeyboardTypeNumberPad;
    [_tableView addSubview:m_userNameButton];
    [m_userNameButton release];
    m_userNameField = m_userNameButton.m_input;
    [m_userNameField becomeFirstResponder];
   
    //验证码
    m_checkButton = [[Plugin_GDAccount_InputView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 95, kHeight2)];
    m_checkButton.m_input.delegate = self;
    m_checkButton.userInteractionEnabled = YES;
    m_checkButton.m_input.tag = 10;
    m_checkButton.m_input.placeholder = [m_registContent objectAtIndex:1];
    [_tableView addSubview:m_checkButton];
    [m_checkButton release];
    m_checkField = m_checkButton.m_input;
    
    m_registButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[m_registButton addTarget:self action:@selector(btn_next_click)forControlEvents:UIControlEventTouchUpInside];
	[m_registButton setTitleColor:GETSKINCOLOR(ACCOUNT_BUTTON_TITLE_COLOR) forState:(UIControlState)UIControlStateNormal];
	m_registButton.titleLabel.font =  [UIFont boldSystemFontOfSize:18];
	UIImage *buttonImageNormal1 = IMAGE(@"CommonBtn1.png", IMAGEPATH_TYPE_1) ;
    UIImage *stretchableButtonImageNormal = [buttonImageNormal1 stretchableImageWithLeftCapWidth:buttonImageNormal1.size.width/2 topCapHeight:buttonImageNormal1.size.height/2];
	UIImage *buttonImagePressed = IMAGE(@"CommonBtn2.png", IMAGEPATH_TYPE_1) ;
    UIImage *stretchableButtonImagePressed = [buttonImagePressed stretchableImageWithLeftCapWidth:buttonImageNormal1.size.width/2 topCapHeight:buttonImageNormal1.size.height/2];
    [m_registButton setBackgroundImage:stretchableButtonImageNormal forState:UIControlStateNormal];
    [m_registButton setBackgroundImage:stretchableButtonImagePressed forState:(UIControlState)UIControlStateHighlighted];
    [m_registButton setTitle:[m_registContent objectAtIndex:2] forState:(UIControlState)UIControlStateNormal];

    if (m_type == 2)
    {
        [m_registButton setTitle:[m_registContent objectAtIndex:6] forState:(UIControlState)UIControlStateNormal];
    }
	[_tableView  addSubview:m_registButton];
    
   
    m_btnGetAuthCode  = [[AccountTimeButton alloc] initWithFrame:CGRectZero countDown:60 viewType:REGIST_VIEW];
    [m_btnGetAuthCode addTarget:self action:@selector(getAuthCode_click)forControlEvents:UIControlEventTouchUpInside];
    m_btnGetAuthCode.titleLabel.font =  [UIFont boldSystemFontOfSize:14];
    [_tableView addSubview:m_btnGetAuthCode];
    [m_btnGetAuthCode release];
    
    if (!(m_type == 2))
    {
        m_tipLable = [[UILabel alloc] init];
        m_tipLable.font = [UIFont boldSystemFontOfSize:15];
        m_tipLable.text = [m_registContent objectAtIndex:4];
        m_tipLable.textColor = TEXTCOLOR;
        m_tipLable.backgroundColor = GETSKINCOLOR(HUD_LABEL_CLEAR_BACK_COLOR);
        m_tipLable.numberOfLines = 2;
        [_tableView addSubview:m_tipLable];
        [m_tipLable release];
        
        m_agreementButton = [[Plugin_ColorTitleButton alloc] init];
        [m_agreementButton addTarget:self action:@selector(btn_agreement_click)forControlEvents:UIControlEventTouchUpInside];
        m_agreementButton.titleLabel.font = [UIFont boldSystemFontOfSize:15];
        [m_agreementButton setTitleColor:TITLECOLOR forState:(UIControlState)UIControlStateNormal];
        [m_agreementButton setTitle:[m_registContent objectAtIndex:3] forState:UIControlStateNormal];
        [_tableView addSubview:m_agreementButton];
        [m_agreementButton release];
        
        button_prompt = [UIButton buttonWithType:UIButtonTypeCustom];
        [button_prompt addTarget:self action:@selector(btn_prompt_click)forControlEvents:UIControlEventTouchUpInside];
        buttonImageNormal1 = IMAGE(@"accountPrompt1.png", IMAGEPATH_TYPE_1);
        [button_prompt setBackgroundImage:buttonImageNormal1 forState:UIControlStateNormal];
        [button_prompt setBackgroundImage:IMAGE(@"accountPrompt2.png", IMAGEPATH_TYPE_1) forState:UIControlStateSelected];
        button_prompt.selected = NO;
        [_tableView addSubview:button_prompt];
    }
    
    //北京后台注册
    //网络请求
    m_accountNetReq = [[MWAccountRequest alloc]init];
    m_accountNetReq.delegate = self;
    
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    m_userNameField.text = @"";
    m_checkField.text = @"";

    [self.navigationController setNavigationBarHidden:NO animated:animated];
	[self setViewFrame:Interface_Flag];
}

- (void)dealloc{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [m_registContent release];
    
    //网络请求
    m_accountNetReq.delegate = nil;
    [m_accountNetReq release];
    CRELEASE(m_getCheckcodePhone);
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

-(void) setViewFrame:(int)flag
{
    
    CGSize size = _tableView.bounds.size;
    
    float offsetx = 10;

    m_userNameButton.frame = CGRectMake(offsetx, 10,size.width-2*offsetx, kHeight2);
    
    m_checkButton.frame = CGRectMake(offsetx, 65,size.width - 150, kHeight2);
    
    m_btnGetAuthCode.frame = CGRectMake(size.width - 130, 65, 120, kHeight2);
    
    
    m_tipLable.frame = CGRectMake(45, 130 , size.width , 26.0f);
    button_prompt.frame = CGRectMake(15, 130, 26.0f, 26.0f);
    
    CGSize tip_size = [m_tipLable.text sizeWithFont:m_tipLable.font];
    CGSize button_size = [m_agreementButton.m_colorTitle sizeWithFont:m_agreementButton.titleLabel.font];
    m_agreementButton.frame = CGRectMake(tip_size.width + 50, 130, button_size.width + 10, 26.0f);
    if (isiPhone && fontType == 2 && Interface_Flag == 0)
    {
        m_tipLable.frame = CGRectMake(45, 125, size.width, 26.0f);
        m_agreementButton.frame = CGRectMake(45, 145, button_size.width + 10, 26.0f);
    }
    
    if (m_type == 0 || m_type == 1)
    {
        m_registButton.frame = CGRectMake(offsetx, 175, size.width-2*offsetx, 46.0f);
    }
    else
    {
        m_registButton.frame = CGRectMake(offsetx, 136, size.width-2*offsetx, 46.0f);
    }
    
     
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    if(toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
	{
		[self setViewFrame:1];
	}
	else if(toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
	{
		[self setViewFrame:0];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if (!OrientationSwitch)
    {
        return (Orientation == interfaceOrientation);
    }
	return  YES;
    
}

-(void) goBack_Click
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    
    //清除网络请求回调
    m_accountNetReq.delegate = nil;
    [[NetExt sharedInstance] Net_CancelRequestWithType:REQ_CHECK_CODE];
    
    if ([CustomWindow existCustomWindow])
    {
        [CustomWindow DestroyCustomWindow];
        return;
    }
    if(m_type != 0)
    {
        int count = self.navigationController.viewControllers.count;
        UIViewController *last2 = [self.navigationController.viewControllers caObjectsAtIndex:count-2];
        UIViewController *last3 = [self.navigationController.viewControllers caObjectsAtIndex:count-3];
        
        if(last3  && last2 && [last2 isKindOfClass:[AccountLoginViewController class]])
        {
            [self.navigationController popToViewController:last3 animated:YES];
        }
        else
        {
            
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
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

- (void)btn_prompt_click
{
    button_prompt.selected = !button_prompt.selected;
}

-(void) btn_next_click
{
	if (m_currentField)
    {
        [m_currentField resignFirstResponder];
        m_currentField = nil;
    }
        
	if ([m_userNameField.text length]<1 || [[Plugin_Account_Utility shareInstance] bCheckPhone:m_userNameField.text]==NO)
    {
        [[AccountNotify SharedInstance] ShowAccountMessageWithTag:Account_Alert_Input_Phone delegate:self];
		return;
	}
    
    
	if([m_checkField.text length]<1)
    {
		[[AccountNotify SharedInstance] ShowAccountMessageWithTag:Account_Alert_Input_Check delegate:self];
		return;
	}
    
    if (!(m_type == 2))
    {
        if (!button_prompt.selected)
        {
            
            [self MyalertView:[NSString stringWithFormat:@"%@%@",STR(@"Account_Agree", Localize_Account),STR(@"Account_RegistrationAgreement", Localize_Account)] canceltext:STR(@"Universal_cancel", Localize_Universal) othertext:STR(@"Universal_ok", Localize_Universal) alerttag:222];
            return;
        }
    }
    
    if(m_getCheckcodePhone && [m_getCheckcodePhone isEqualToString:m_userNameField.text]==NO)
    {
        [[AccountNotify SharedInstance] ShowAccountMessageWithTag:Account_Alert_Phone_Different delegate:self];
        return;
    }
    
    if(m_type==0)//北京后台
    {
        //检查验证码
        if([m_accountNetReq.strcheckcode isEqualToString:m_checkField.text])
        {
            AccountRegistPasswordViewController *ctl;
            ctl = [[AccountRegistPasswordViewController alloc] init];
            ctl.m_telPhone = m_userNameField.text;
            ctl.m_checkNum = m_checkField.text;
            [self.navigationController pushViewController:ctl animated:YES];
            [ctl release];
        }
        else//提示验证码错误
        {
            [[AccountNotify SharedInstance] ShowAccountMessageWithTag:Account_Alert_Check_Error delegate:self];
        }
        
    }
    else
    {
        [MWAccountOperator accountCheckCodeWith:REQ_CHECK_CODE phone:m_userNameField.text license_val:m_checkField.text delegate:self];
        [QLoadingView showLoadingView:nil view:(UIWindow *)self.view];

    }
    
}

-(void) getAuthCode_click
{
    
    if (m_currentField)
    {
        [m_currentField resignFirstResponder];
        m_currentField = nil;
    }

    if ([m_userNameField.text length]<1 || [[Plugin_Account_Utility shareInstance] bCheckPhone:m_userNameField.text]==NO)
    {
        [[AccountNotify SharedInstance] ShowAccountMessageWithTag:Account_Alert_Input_Phone delegate:self];
		return;
	}
    if(m_type==0)
    {
        [m_accountNetReq accountCheckCodeRequest:REQ_CHECK_CODE phone:m_userNameField.text actiontype:@"register"];
        m_accountNetReq.delegate = self;
        CRELEASE(m_getCheckcodePhone);
        m_getCheckcodePhone = [[NSString alloc]initWithString:m_userNameField.text];
    }
    else
    {
        [MWAccountOperator accountGetPhoneCheckNumberWith:REQ_GET_CHECK_NUMBER phone:m_userNameField.text vtype:@"1" delegate:self];
    }
    
    [m_btnGetAuthCode ButtonPressd];
    [QLoadingView showLoadingView:nil view:(UIWindow *)self.view];
}


#pragma mark UIAlertView
- (void)MyalertView:(NSString *)titletext canceltext:(NSString *)mycanceltext othertext:(NSString *)myothertext alerttag:(int)mytag
{
	
    GDAlertView *alert;

    __block id weakDelegate = self;
    alert = [[GDAlertView alloc] initWithTitle:nil andMessage:titletext];
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
        case 222:
            switch (buttonIndex)
            {
                case 1:
                    button_prompt.selected = YES;
                    break;
                    
                default:
                    break;
            }
            
            break;
        default:
            break;
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
            [Myalert_ext addButtonWithTitle:STR(@"Universal_ok", Localize_Universal) type:GDAlertViewButtonTypeDefault handler:nil];
			[Myalert_ext show];
			[Myalert_ext release];
			textField.text = @"";
		}
	}
	return YES;
}

#pragma mark - Table view data source

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


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - NetReqToViewCtrDelegate

- (void)requestToViewCtrWithRequestType:(RequestType)requestType didFinishLoadingWithResult:(id)result
{
    if (requestType == REQ_OLD_USER_BIND_PHONE_NUMBER)
    {
        if ([[result objectForKey:@"Result"] isEqualToString:@"SUCCESS"])
        {
            AccountPersonalData *data = [AccountPersonalData SharedInstance];
            data.m_accountPhoneNumber = m_userNameField.text;
            data.bThirdToGD = YES;
            [self.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            NSString *error = [result objectForKey:KEY_FOR_Error];
            if ([error isEqualToString:ERROR_PHONE_REGISTERED])
            {
                [[AccountNotify SharedInstance] ShowAccountMessageWithTag:Account_Alert_Phone_Registed delegate:self];
            }
            else
            {
                [[AccountNotify SharedInstance] ShowAccountMessageWithTag:Account_Alert_Modify_Error delegate:self];
            }
        }
    }
    else if (requestType == REQ_GET_CHECK_NUMBER)
    {
        if ([[result objectForKey:@"Result"] isEqualToString:@"SUCCESS"])
        {
            [[AccountNotify SharedInstance] ShowAccountMessageWithTag:Account_Alert_Check_Success delegate:self];
        }
        else
        {
            [m_btnGetAuthCode ButtonActive:REGIST_VIEW];
            NSString *key_error = [result objectForKey:KEY_FOR_Error];
            if ([key_error isEqualToString:ERROR_SENDMSG_MORE8])
            {
                [[AccountNotify SharedInstance] ShowAccountMessageWithTag:Account_Alert_SMS_Limit delegate:self];
            }
            else if ([key_error isEqualToString:ERROR_PHONE_NOT_REGISTERED])
            {
                [[AccountNotify SharedInstance] ShowAccountMessageWithTag:Account_Alert_Phone_Unregisted delegate:self];
            }
            else
            {
                [[AccountNotify SharedInstance] ShowAccountMessageWithTag:Account_Alert_Phone_Registed delegate:self];
            }
        }
    }
    else if (requestType == REQ_CHECK_CODE)
    {
        if ([[result objectForKey:@"Result"] isEqualToString:@"SUCCESS"])
        {
            if (m_type == 2)
            {
                [MWAccountOperator accountOldBindPhoneWith:REQ_OLD_USER_BIND_PHONE_NUMBER phone:m_userNameField.text delegate:self];
                return;
            }
            else
            {
                AccountRegistPasswordViewController *ctl;
                if (m_type == 0)
                {
                    ctl = [[AccountRegistPasswordViewController alloc] init];
                }
                else
                {
                    ctl = [[AccountRegistPasswordViewController alloc] initWithType:2];
                }
                
                ctl.m_telPhone = m_userNameField.text;
                ctl.m_checkNum = m_checkField.text;
                [self.navigationController pushViewController:ctl animated:YES];
                [ctl release];
            }
        }
        else if([[result objectForKey:@"rspcode"] isEqualToString:@"1221"])//北京后台注册验证码-手机已经注册
        {
            [[AccountNotify SharedInstance] ShowAccountMessageWithTag:Account_Alert_Phone_Registed delegate:self];
        }
        else if(![[result objectForKey:@"rspcode"] isEqualToString:@"0000"])
        {
            [[AccountNotify SharedInstance] ShowAccountMessageWithTag:Account_Alert_Check_Error delegate:self];
        }
        else
        {
            [[AccountNotify SharedInstance] ShowAccountMessageWithTag:Account_Alert_Check_Success delegate:self];
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

@end

//
//  AccountGetPwdViewController.m
//  AutoNavi
//
//  Created by gaozhimin on 12-12-18.
//
//

#import "AccountGetPwdViewController.h"
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
#import "NSString+Category.h"
#import "GDAlertView.h"
#import "MWAccountOperator.h"
#import "MWAccountRequest.h"

#define TableView_Head_Height 20.0f

@interface AccountGetPwdViewController ()<NetReqToViewCtrDelegate>
{
    
    NSArray *m_registContent;
    Plugin_GDAccount_InputView *m_checkButton,*m_userNameButton;
    UIButton *m_registButton;
    Plugin_ColorTitleButton *m_agreementButton;
    Plugin_ColorTitleButton *m_emailButton;
    UILabel *m_tipLable;
    AccountTimeButton *m_btnGetAuthCode;
    
    UITextField *m_userNameField;
    UITextField *m_checkField;
    
    UITextField *m_currentField;
    
    UIButton *button_prompt;
    MWAccountRequest *m_accountNetReq;
    NSString *m_getCheckcodePhone;//获取验证码的手机号，用于合法性检查
}


@end


@implementation AccountGetPwdViewController


#pragma mark -
#pragma mark initialization
-(id)init
{
    self= [super init];
    if (self) {

		moveHeight =0;
		currText = nil;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = STR(@"Account_FindPassword", Localize_Account);
    self.navigationItem.leftBarButtonItem =BARBUTTON(@"",@selector(goBack_Click));
    m_registContent = [[NSArray alloc] initWithObjects:STR(@"Account_PhoneNumber", Localize_Account),STR(@"Account_Verification", Localize_Account),STR(@"Account_Next", Localize_Account),STR(@"Account_RegistrationAgreement", Localize_Account),STR(@"Account_Agree", Localize_Account),STR(@"Account_EmailFindPassword", Localize_Account), nil];
    
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
    
    
    NSArray *array = [[Account AccountInstance] getAccountInfo];
    if ([[Plugin_Account_Utility shareInstance] bCheckPhone:[array objectAtIndex:1]])
    {
		m_userNameField.text = [array objectAtIndex:1];
	}
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
	UIImage *buttonImageNormal1 = IMAGE(@"CommonBtn1.png", IMAGEPATH_TYPE_1);
    UIImage *stretchableButtonImageNormal = [buttonImageNormal1 stretchableImageWithLeftCapWidth:buttonImageNormal1.size.width/2 topCapHeight:buttonImageNormal1.size.height/2];
	UIImage *buttonImagePressed = IMAGE(@"CommonBtn2.png", IMAGEPATH_TYPE_1);
    UIImage *stretchableButtonImagePressed = [buttonImagePressed stretchableImageWithLeftCapWidth:buttonImageNormal1.size.width/2 topCapHeight:buttonImageNormal1.size.height/2];
    [m_registButton setBackgroundImage:stretchableButtonImageNormal forState:UIControlStateNormal];
    [m_registButton setBackgroundImage:stretchableButtonImagePressed forState:(UIControlState)UIControlStateHighlighted];
    [m_registButton setTitle:[m_registContent objectAtIndex:2] forState:(UIControlState)UIControlStateNormal];
    
	[_tableView  addSubview:m_registButton];

    
    
    m_emailButton = [[Plugin_ColorTitleButton alloc] init];
    [m_emailButton addTarget:self action:@selector(btn_email_click)forControlEvents:UIControlEventTouchUpInside];
    m_emailButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    [m_emailButton setTitleColor:TITLECOLOR forState:(UIControlState)UIControlStateNormal];
    [m_emailButton setTitle:[m_registContent objectAtIndex:5] forState:UIControlStateNormal];
    [_tableView addSubview:m_emailButton];
    m_emailButton.hidden=YES;
    [m_emailButton release];
    
    
    m_btnGetAuthCode  = [[AccountTimeButton alloc] initWithFrame:CGRectZero countDown:60 viewType:FIND_PSW_VIEW];
    [m_btnGetAuthCode addTarget:self action:@selector(getAuthCode_click)forControlEvents:UIControlEventTouchUpInside];
    m_btnGetAuthCode.titleLabel.font =  [UIFont boldSystemFontOfSize:14];
    [_tableView addSubview:m_btnGetAuthCode];
    [m_btnGetAuthCode release];
    
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

-(void) setViewFrame:(int)flag
{
    CGSize size = _tableView.bounds.size;

    float offsetx = 10;
    m_userNameButton.frame = CGRectMake(offsetx, 10,size.width - 2*offsetx, kHeight2);
    
    
    m_checkButton.frame = CGRectMake(offsetx, 65,size.width - 150, kHeight2);
    
    m_btnGetAuthCode.frame = CGRectMake(size.width - 130, 65, 120, kHeight2);
    
    m_registButton.frame = CGRectMake(offsetx, 125, size.width - 2*offsetx, 46.0f);

    CGSize button_size = [m_emailButton.m_colorTitle sizeWithFont:m_emailButton.titleLabel.font];
    m_emailButton.frame = CGRectMake(offsetx, 170, button_size.width + 10, 40.0f);
    
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
    //清除网络请求回调
    m_accountNetReq.delegate = nil;
    [[NetExt sharedInstance] Net_CancelRequestWithType:REQ_CHECK_CODE];
    
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[self.navigationController popViewControllerAnimated:YES];
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

- (void)btn_email_click
{
    return;//已经没有邮箱找回密码
}

- (void)btn_prompt_click
{
    button_prompt.selected = !button_prompt.selected;
    if (button_prompt.selected)
    {
        [button_prompt setBackgroundImage: IMAGE(@"prompt2.png", IMAGEPATH_TYPE_1) forState:UIControlStateNormal];
    }
    else
    {
        
        [button_prompt setBackgroundImage: IMAGE(@"prompt1.png", IMAGEPATH_TYPE_1) forState:UIControlStateNormal];
    }
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

    if(m_getCheckcodePhone && [m_getCheckcodePhone isEqualToString:m_userNameField.text]==NO)
    {
        [[AccountNotify SharedInstance] ShowAccountMessageWithTag:Account_Alert_Phone_Different delegate:self];
        return;
    }
  
    AccountRegistPasswordViewController *ctl;
    ctl = [[AccountRegistPasswordViewController alloc] initWithType:1];
    ctl.m_telPhone = m_userNameField.text;
    ctl.m_checkNum = m_checkField.text;
    [self.navigationController pushViewController:ctl animated:YES];
    [ctl release];

    
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
    
//    [MWAccountOperator accountGetPhoneCheckNumberWith:REQ_GET_CHECK_NUMBER phone:m_userNameField.text vtype:@"2" delegate:self];
    [m_accountNetReq accountCheckCodeRequest:REQ_CHECK_CODE phone:m_userNameField.text actiontype:@"resetpwd"];
    m_accountNetReq.delegate = self;
    CRELEASE(m_getCheckcodePhone);
    m_getCheckcodePhone = [[NSString alloc]initWithString:m_userNameField.text];
    [m_btnGetAuthCode ButtonPressd];
    [QLoadingView showLoadingView:nil view:(UIWindow *)self.view];
}


#pragma mark UIAlertView

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
        {
            switch (buttonIndex) {
                case 1:
                    [self btn_prompt_click];
                    break;
                    
                default:
                    break;
            }
        }
            break;
        default:
            break;
    }
}





#pragma mark UITextField delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
//    CGSize size = self.view.bounds.size;
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
		if (strlen(NSSTRING_TO_CSTRING(textField.text)/*[textField.text cStringUsingEncoding:0x80000632]*/) > 49)
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
    view.backgroundColor = GETSKINCOLOR(HUD_LABEL_CLEAR_BACK_COLOR);
    return view;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    float height = [self tableView:tableView heightForHeaderInSection:section];
    UIView *view = nil;
    view = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, height)] autorelease];
    view.backgroundColor = GETSKINCOLOR(HUD_LABEL_CLEAR_BACK_COLOR);
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
    cell.backgroundColor = GETSKINCOLOR(HUD_LABEL_CLEAR_BACK_COLOR);
    cell.backgroundView = nil;
    return cell;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - NetReqToViewCtrDelegate method
- (void)requestToViewCtrWithRequestType:(RequestType)requestType didFinishLoadingWithResult:(id)result
{
    
    if (requestType == REQ_GET_CHECK_NUMBER)
    {
        if ([[result objectForKey:@"Result"] isEqualToString:@"SUCCESS"])
        {
            [[AccountNotify SharedInstance] ShowAccountMessageWithTag:Account_Alert_Check_Success delegate:self];
        }
        else
        {
            [m_btnGetAuthCode ButtonActive:FIND_PSW_VIEW];
            
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
            AccountRegistPasswordViewController *ctl = [[AccountRegistPasswordViewController alloc] initWithType:1];
            ctl.m_telPhone = m_userNameField.text;
            ctl.m_checkNum = m_checkField.text;
            [self.navigationController pushViewController:ctl animated:YES];
            [ctl release];
        }
        else if([[result objectForKey:@"rspcode"] isEqualToString:@"1218"])//北京后台注册验证码-手机不存在
        {
            [[AccountNotify SharedInstance] ShowAccountMessageWithTag:Account_Alert_Phone_Unregisted delegate:self];
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

//
//  PluginAccountRegistPasswordViewController.m
//  AutoNavi
//
//  Created by gaozhimin on 13-5-10.
//
//

#import "AccountRegistPasswordViewController.h"
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
#import "AccountPersonalData.h"
#import "GDAlertView.h"
#import "MWAccountOperator.h"
#import "AccountLoginViewController.h"
#import "Plugin_Account.h"
#import "MWAccountRequest.h"

@interface AccountRegistPasswordViewController ()<NetReqToViewCtrDelegate>
{
    NSArray *m_registContent;
    Plugin_GDAccount_InputView *m_passwordButton,*m_confirmButton;
    UIButton *m_registButton;
    BOOL bFirstResponder;
    
    UITextField *m_passWordField;
    UITextField *m_confirmField;
    UITextField *m_currentField;
    
    int m_type;  //0 注册界面 1 找回密码 2 完成绑定
    MWAccountRequest *m_accountNetReq;
}

@end


@implementation AccountRegistPasswordViewController

@synthesize m_checkNum,m_telPhone;

#pragma mark -
#pragma mark initialization
-(id)init
{
    return [self initWithType:0];
}

- (id)initWithType:(int)type
{
   
    self= [super init];
    if (self) {
        bFirstResponder = NO;
		moveHeight =0;
		currText = nil;
         m_type = type;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    
    NSString *str[3] = {STR(@"Account_Register", Localize_Account),STR(@"Account_FindPassword", Localize_Account),STR(@"Account_BindPhoneNumber", Localize_Account)};
    if (m_type < 3)
    {
        self.title = str[m_type];
    }
    
    self.navigationItem.leftBarButtonItem =BARBUTTON(@"",@selector(goBack_Click));
    m_registContent = [[NSArray alloc] initWithObjects:STR(@"Account_PasswordCondition", Localize_Account),STR(@"Account_InputPasswordAgain", Localize_Account),STR(@"Account_Register", Localize_Account),STR(@"Account_NewPassword", Localize_Account),STR(@"Account_ConfirmPassword", Localize_Account),STR(@"Account_Confirm", Localize_Account),STR(@"Account_FinishBind", Localize_Account),nil];
    
    m_passwordButton = [[Plugin_GDAccount_InputView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, kHeight2)];
    [m_passwordButton setBackgroundType:BACKGROUND_HEAD];
    m_passwordButton.m_input.delegate = self;
    m_passwordButton.userInteractionEnabled = YES;
    m_passwordButton.m_input.secureTextEntry = YES;
    m_passwordButton.m_input.tag = 0;
    m_passwordButton.m_input.placeholder = [m_registContent objectAtIndex:0];
    [_tableView addSubview:m_passwordButton];
    [m_passwordButton release];
    m_passWordField = m_passwordButton.m_input;
    
    m_confirmButton = [[Plugin_GDAccount_InputView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 95, kHeight2)];
    [m_confirmButton setBackgroundType:BACKGROUND_FOOTER];
    m_confirmButton.m_input.delegate = self;
    m_confirmButton.userInteractionEnabled = YES;
    m_confirmButton.m_input.secureTextEntry = YES;
    m_confirmButton.m_input.tag = 10;
    m_confirmButton.m_input.placeholder = [m_registContent objectAtIndex:1];
    
    [_tableView addSubview:m_confirmButton];
    [m_confirmButton release];
    m_confirmField = m_confirmButton.m_input;
    
    
    m_registButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[m_registButton addTarget:self action:@selector(btn_registSubmit_click)forControlEvents:UIControlEventTouchUpInside];
	[m_registButton setTitleColor:GETSKINCOLOR(ACCOUNT_BUTTON_TITLE_COLOR) forState:(UIControlState)UIControlStateNormal];
	m_registButton.titleLabel.font =  [UIFont boldSystemFontOfSize:18];
	UIImage *buttonImageNormal1 = IMAGE(@"CommonBtn1.png", IMAGEPATH_TYPE_1) ;
    UIImage *stretchableButtonImageNormal = [buttonImageNormal1 stretchableImageWithLeftCapWidth:buttonImageNormal1.size.width/2 topCapHeight:buttonImageNormal1.size.height/2];
	UIImage *buttonImagePressed = IMAGE(@"CommonBtn2.png", IMAGEPATH_TYPE_1);
    UIImage *stretchableButtonImagePressed = [buttonImagePressed stretchableImageWithLeftCapWidth:buttonImageNormal1.size.width/2 topCapHeight:buttonImageNormal1.size.height/2];
    [m_registButton setBackgroundImage:stretchableButtonImageNormal forState:UIControlStateNormal];
    [m_registButton setBackgroundImage:stretchableButtonImagePressed forState:(UIControlState)UIControlStateHighlighted];

    [m_registButton setTitle:[m_registContent objectAtIndex:2] forState:(UIControlState)UIControlStateNormal];

	[_tableView  addSubview:m_registButton];
    
    if (m_type == 1)
    {
        [m_registButton setTitle:[m_registContent objectAtIndex:5] forState:(UIControlState)UIControlStateNormal];
        m_passwordButton.m_input.placeholder = [m_registContent objectAtIndex:3];
        m_confirmButton.m_input.placeholder = [m_registContent objectAtIndex:4];
    }
    else if (m_type == 2)
    {
        [m_registButton setTitle:[m_registContent objectAtIndex:6] forState:(UIControlState)UIControlStateNormal];
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
    [self.navigationController setNavigationBarHidden:NO animated:animated];
	[self setViewFrame:Interface_Flag];
}

- (void)dealloc
{
    [m_registContent release];
    m_registContent = nil;
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    //网络请求
    m_accountNetReq.delegate = nil;
    [m_accountNetReq release];
    
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
    m_passwordButton.frame = CGRectMake(offsetx, 10,size.width - 2*offsetx, kHeight2);
    
    
    
    m_confirmButton.frame = CGRectMake(offsetx, 68,size.width - 2*offsetx, kHeight2);
    
    
    m_registButton.frame = CGRectMake(offsetx, 135, size.width - 2*offsetx, 40.0f);
    
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
    [[NetExt sharedInstance] Net_CancelRequestWithType:REQ_LOGIN];
    [[NetExt sharedInstance] Net_CancelRequestWithType:REQ_REGIST];
    [[NetExt sharedInstance] Net_CancelRequestWithType:REQ_RESET_PWD];

	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[self.navigationController popViewControllerAnimated:YES];
}



-(void) btn_registSubmit_click
{
	if (m_currentField)
    {
        [m_currentField resignFirstResponder];
        m_currentField = nil;
    }
    
    if ([m_passWordField.text length] < 1 || [m_confirmField.text length]<1)
    {
        [[AccountNotify SharedInstance] ShowAccountMessageWithTag:Account_Alert_Input_Password delegate:self];
        return;
    }
    
    if ([m_passWordField.text length] < 6 || [m_passWordField.text length] > 32 || [[Plugin_Account_Utility shareInstance] bCheckStrFormat:m_passWordField.text MatchStr:MATCH_PWD]==NO)
	{
		[[AccountNotify SharedInstance] ShowAccountMessageWithTag:Account_Alert_Password_Condition delegate:self];
		return;
	}

	
	if([m_confirmField.text length] < 6 || [m_confirmField.text length] > 32 || [[Plugin_Account_Utility shareInstance] bCheckStrFormat:m_confirmField.text MatchStr:MATCH_PWD]==NO)
	{
		[[AccountNotify SharedInstance] ShowAccountMessageWithTag:Account_Alert_Password_Condition delegate:self];
		return;
	}
	
	
	if (![m_passWordField.text isEqual:m_confirmField.text])
    {
		[[AccountNotify SharedInstance] ShowAccountMessageWithTag:Account_Alert_Password_Different delegate:self];
		return;
	}
    
    
    if (m_type == 1)
    {
//        [MWAccountOperator accountResetPwdWith:REQ_RESET_PWD phone:m_telPhone newpw:m_passWordField.text delegate:self];
        [m_accountNetReq accountpwdResetRequest:REQ_RESET_PWD username:m_telPhone password:m_passWordField.text checkcode:self.m_checkNum];
        m_accountNetReq.delegate = self;
    }
    else if (m_type == 0)
    {
//        [MWAccountOperator accountRegistWith:REQ_REGIST phone:m_telPhone szPwd:m_confirmField.text tpuserid:nil tptype:nil delegate:self];
        [m_accountNetReq accountRegistRequest:REQ_REGIST username:m_telPhone password:m_confirmField.text];
        m_accountNetReq.delegate = self;
    }
    else if (m_type == 2)
    {
        NSArray *tmpArray;
        GDBL_GetAccountInfo(&tmpArray);
        int login = [[tmpArray objectAtIndex:0] intValue];
       
        AccountPersonalData *data = [AccountPersonalData SharedInstance];
        if (login == 3 || login == 5)
        {
            [MWAccountOperator accountRegistWith:REQ_REGIST phone:m_telPhone szPwd:m_confirmField.text tpuserid:data.m_accountXLWBuuid tptype:@"1" delegate:self];
        }
        else if (login == 4 || login == 6)
        {
            [MWAccountOperator accountRegistWith:REQ_REGIST phone:m_telPhone szPwd:m_confirmField.text tpuserid:data.m_accountTXWBuuid tptype:@"2" delegate:self];
        }
        
    }
    
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
    m_currentField = textField;
    bFirstResponder = YES;
    
    
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
    bFirstResponder = NO;
    
	if ([textField.text length] > 0) {
		if (strlen(NSSTRING_TO_CSTRING(textField.text)) > 49)
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
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kHeight2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    //    if (section == 0) {
    //        return 55.0;
    //    }
    return 20.0;
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *HeaderLabel = nil;
    return HeaderLabel;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 100;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    float height = [self tableView:tableView heightForFooterInSection:section];
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


#pragma mark - NetReqToViewCtrDelegate method 
- (void)requestToViewCtrWithRequestType:(RequestType)requestType didFinishLoadingWithResult:(id)result
{
    if (requestType == REQ_LOGIN)
    {
        if ([[result objectForKey:@"Result"] isEqualToString:@"SUCCESS"] || [[result objectForKey:@"rspcode"] isEqualToString:@"0000"])
        {
            [QLoadingView hideWithAnimated:NO];
            AccountPersonalData *personal = [AccountPersonalData SharedInstance];
            if (m_type == 2)
            {
                personal.bThirdToGD = YES;
                NSArray *tmpArray;
                GDBL_GetAccountInfo(&tmpArray);
                int login_type = [[tmpArray objectAtIndex:0] intValue];
                if (login_type == 3)
                {
                    [[Account AccountInstance] setLoginStatus:5];
                    [personal UploadXLInfo:personal.m_XL_Info];
                }
                else if (login_type  == 4)
                {
                    [[Account AccountInstance] setLoginStatus:6];
                    [personal UploadTXInfo:personal.m_TX_Info];
                }
                NSMutableArray *ctl_array = [[NSMutableArray alloc] init];
                
                for (int i = 0; i < [self.navigationController.viewControllers count] - 2; i ++)
                {
                    [ctl_array addObject:[self.navigationController.viewControllers objectAtIndex:i]];
                }
                [self.navigationController setViewControllers:ctl_array animated:NO];
                
                [[AccountNotify SharedInstance] ShowAccountMessageWithTag:Account_Alert_ThirdToGD_Success delegate:self];
                [ctl_array release];
                return;
            }
            
            [[Account AccountInstance] setLoginStatus:2];
            if ([CustomWindow existCustomWindow])
            {
                [CustomWindow DestroyCustomWindow];
            }
            else
            {
                int off = 3;
                NSMutableArray *ctl_array = [[NSMutableArray alloc] init];
                for (int i = 0; i < [self.navigationController.viewControllers count] - off; i ++)
                {
                    [ctl_array addObject:[self.navigationController.viewControllers objectAtIndex:i]];
                }
                [self.navigationController setViewControllers:ctl_array animated:NO];
                [ctl_array release];
            }
            [[AccountNotify SharedInstance] ShowAccountMessageWithTag:Account_Alert_Regist_Success delegate:self];
        }
    }
    else if (requestType == REQ_REGIST)
    {
//        if ([[result objectForKey:@"Result"] isEqualToString:@"SUCCESS"])
//        {
//            [MWAccountOperator accountLoginWith:REQ_LOGIN phone:self.m_telPhone password:m_passWordField.text type:@"2" delegate:self];
//            return;
//        }
        if(m_type == 2)
        {
            if ([[result objectForKey:@"Result"] isEqualToString:@"SUCCESS"])
            {
                [AccountPersonalData SharedInstance].m_accountPhoneNumber = self.m_telPhone;
                NSArray *tmpArray;
                GDBL_GetAccountInfo(&tmpArray);
                int login_type = [[tmpArray objectAtIndex:0] intValue];
                if (login_type == 3)
                {
                    [[Account AccountInstance] setLoginStatus:5];
                }
                else if (login_type  == 4)
                {
                    [[Account AccountInstance] setLoginStatus:6];
                }
                [[AccountPersonalData SharedInstance] Account_GetUserinfo];//modify by gzm for 第三方绑定完手机号，需要重新登陆一次第三方帐号，改变驾驶记录和历史轨迹的userid，防止数据丢失 at 2014-11-10
                [[AccountNotify SharedInstance] ShowAccountMessageWithTag:Account_Alert_Bind_Success delegate:self];
                //绑定成功后回退到个人信息页面
                NSMutableArray *ctl_array = [[NSMutableArray alloc] init];
                
                for (int i = 0; i < [self.navigationController.viewControllers count] - 2; i ++)
                {
                    if([[self.navigationController.viewControllers objectAtIndex:i] isKindOfClass:[AccountLoginViewController class]])//不跳到登陆界面
                    {
                        continue;
                    }
                    [ctl_array addObject:[self.navigationController.viewControllers objectAtIndex:i]];
                }
                [self.navigationController setViewControllers:ctl_array animated:NO];
                [ctl_array release];
                
            }
            else
            {
                //绑定失败，请重试
                [[AccountNotify SharedInstance] ShowAccountMessageWithTag:Account_Alert_Bind_Error delegate:self];

            }
            
        }
        else
        {
            if([[result objectForKey:@"rspcode"] isEqualToString:@"0000"])
            {
                [m_accountNetReq accountLoginRequest:REQ_LOGIN username:self.m_telPhone password:m_passWordField.text];
                m_accountNetReq.delegate = self;
                return;
            }
            else
            {
                [[AccountNotify SharedInstance] ShowAccountMessageWithTag:Account_Alert_Regist_Error delegate:self];
            }
        }
        
    }
    else if (requestType == REQ_RESET_PWD)
    {
        if ([[result objectForKey:@"Result"] isEqualToString:@"SUCCESS"])
        {
            NSMutableArray *ctl_array = [[NSMutableArray alloc] init];
            for (int i = 0; i < [self.navigationController.viewControllers count] - 2; i ++)
            {
                [ctl_array addObject:[self.navigationController.viewControllers objectAtIndex:i]];
            }
            [self.navigationController setViewControllers:ctl_array animated:NO];
            [ctl_array release];
            
            [[AccountNotify SharedInstance] ShowAccountMessageWithTag:Account_Alert_Password_Success delegate:nil];
        }
        else if ([[result objectForKey:@"rspcode"] isEqualToString:@"0000"])
        {
            NSMutableArray *ctl_array = [[NSMutableArray alloc] init];
            for (int i = 0; i < [self.navigationController.viewControllers count] - 2; i ++)
            {
                [ctl_array addObject:[self.navigationController.viewControllers objectAtIndex:i]];
            }
            [self.navigationController setViewControllers:ctl_array animated:NO];
            [ctl_array release];
            
            [[AccountNotify SharedInstance] ShowAccountMessageWithTag:Account_Alert_Password_Success delegate:nil];
        }
        else if ([[result objectForKey:@"rspcode"] isEqualToString:@"1031"] || [[result objectForKey:@"rspcode"] isEqualToString:@"1027"])
        {
                       
            [[AccountNotify SharedInstance] ShowAccountMessageWithTag:Account_Alert_Check_Error delegate:nil];
        }
        else
        {
            [[AccountNotify SharedInstance] ShowAccountMessageWithTag:Account_Alert_Modify_Error delegate:nil];
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



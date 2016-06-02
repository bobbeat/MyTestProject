//
//  Plugin_GDAccount_LoginController.m
//  AutoNavi
//
//  Created by gaozhimin on 12-12-17.
//
//

#import "AccountLoginViewController.h"
#import "Plugin_Account_Globall.h"
#import "AccountGetPwdViewController.h"
#import "AccountRegistPhoneViewController.h"
#import "Plugin_Account_Utility.h"
#import "GDBL_Account.h"
#import "VCTranslucentBarButtonItem.h"
#import "ANParamValue.h"
#import "QLoadingView.h"
#import "Plugin_GDAccount_InputCell.h"
#import "Plugin_ColorTitleButton.h"
#import "AccountPersonalData.h"
#import "AccountNotify.h"
#import "GDAlertView.h"
#import "GDBL_SinaWeibo.h"
#import "GDBL_TCWeibo.h"
#import "MWAccountOperator.h"
#import "AccountTextFieldListener.h"
#import "Plugin_Account.h"
#import "AccountBindPhoneViewController.h"
#import "AccountInfoViewController.h"
#import "MWAccountRequest.h"

@interface AccountLoginViewController ()<GDBL_SinaWeiboDelegate,GDBL_TCWeiboDelegate,NetReqToViewCtrDelegate>
{
    Plugin_ColorTitleButton *m_forgetPWButton; //忘记密码按钮
    Plugin_ColorTitleButton *m_regist; //注册按钮按钮
    NSArray *loginContent;
    BOOL isReadFromBuffer;
    BOOL isAlertViewShow;  //提示框是否显示
    UIButton* btnLogin;
    NSString *m_userName;
    NSString *m_userPSW;
    AccountInfo* myProfile;
    
    UILabel *m_sectionLable;
    
    int m_currentTextFieldIndex;
    
    GDBL_SinaWeibo      * _sinaWeibo;
    GDBL_TCWeibo        * _tcWeibo;
    AccountPersonalData *m_personalData;
    
    int m_loginType;
    
    UIButton *_sinaButton;
    UIButton *_tencentButton;
    UIImageView *_leftLine;
    UIImageView *_rightLine;
    id s_myViewDelegate;
    BOOL _bBack;
    MWAccountRequest *m_accountNetReq;
}

@property (nonatomic,copy)  NSString *m_userName;
@property (nonatomic,copy)  NSString *m_userPSW;

@end

@implementation AccountLoginViewController

@synthesize m_userName;
@synthesize m_userPSW;

-(id)initWithAccountName:(NSString*)myAccountName Password:(NSString*)myPwd back:(BOOL)back
{
	self =[super init];
	if (self) {
        self.m_userPSW = @"";
        _bBack = back;
        s_myViewDelegate = self;
	}
	
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSArray *accountInfo = [[Account AccountInstance] getAccountInfo];
    if ([accountInfo count] > 1)
    {
        self.m_userName = (NSString*)[accountInfo objectAtIndex:1];
    }
    
    [AccountTextFieldListener startAccountTextFieldListner];
    
    m_personalData= [AccountPersonalData SharedInstance];
    
    m_currentTextFieldIndex = -1;
    _sinaWeibo=[GDBL_SinaWeibo shareSinaWeibo];//新浪微博初始化
    _sinaWeibo.delegate = self;
    
    _tcWeibo=[GDBL_TCWeibo shareTCWeibo];//腾讯微博初始化
    _tcWeibo.delegate = self;
    [_tcWeibo setController:self];
    
    self.title = STR(@"Account_Login", Localize_Account);
    self.navigationItem.leftBarButtonItem = BARBUTTON(@"",@selector(goBack_Click));
    loginContent = [[NSArray alloc] initWithObjects:STR(@"Account_PhoneOrEmail", Localize_Account), STR(@"Account_Password", Localize_Account),STR(@"Account_ThirdAccount", Localize_Account),STR(@"Account_Register", Localize_Account),STR(@"Account_AccountTip4", Localize_Account),STR(@"Account_Notice", Localize_Account),nil];
    
    btnLogin = [UIButton buttonWithType:UIButtonTypeCustom];
	[btnLogin addTarget:self action:@selector(btn_login_click)forControlEvents:UIControlEventTouchUpInside];
    btnLogin.titleLabel.font =  [UIFont boldSystemFontOfSize:18];
	UIImage *buttonImageNormal1 =  IMAGE(@"CommonBtn1.png", IMAGEPATH_TYPE_1) ;
    UIImage *stretchableButtonImageNormal = [buttonImageNormal1 stretchableImageWithLeftCapWidth:buttonImageNormal1.size.width/2 topCapHeight:buttonImageNormal1.size.height/2];
	UIImage *buttonImagePressed =  IMAGE(@"CommonBtn2.png", IMAGEPATH_TYPE_1);
    UIImage *stretchableButtonImagePressed = [buttonImagePressed stretchableImageWithLeftCapWidth:buttonImageNormal1.size.width/2 topCapHeight:buttonImageNormal1.size.height/2];
    [btnLogin setBackgroundImage:stretchableButtonImageNormal forState:UIControlStateNormal];
    [btnLogin setBackgroundImage:stretchableButtonImagePressed forState:(UIControlState)UIControlStateHighlighted];
	[btnLogin setTitle:STR(@"Account_Login", Localize_Account) forState:(UIControlState)UIControlStateNormal];
    [btnLogin setTitleColor:GETSKINCOLOR(ACCOUNT_BUTTON_TITLE_COLOR) forState:UIControlStateNormal];
	[_tableView  addSubview:btnLogin];
	
    m_forgetPWButton = [[Plugin_ColorTitleButton alloc] init];
    [m_forgetPWButton addTarget:self action:@selector(fogetPwd_Click)forControlEvents:UIControlEventTouchUpInside];
    m_forgetPWButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [m_forgetPWButton setTitleColor:GETSKINCOLOR(ACCOUNT_REGIST_COLOR) forState:(UIControlState)UIControlStateNormal];
    [m_forgetPWButton setTitle:STR(@"Account_ForgetPassword", Localize_Account) forState:UIControlStateNormal];
    
    [_tableView  addSubview:m_forgetPWButton];
    [m_forgetPWButton release];
    
    m_regist = [[Plugin_ColorTitleButton alloc] init];
    [m_regist addTarget:self action:@selector(btn_regist_click)forControlEvents:UIControlEventTouchUpInside];
    m_regist.titleLabel.font = [UIFont systemFontOfSize:14];
    [m_regist setTitleColor:GETSKINCOLOR(ACCOUNT_REGIST_COLOR) forState:(UIControlState)UIControlStateNormal];
    [m_regist setTitle:[loginContent objectAtIndex:3] forState:UIControlStateNormal];
    [_tableView  addSubview:m_regist];
    [m_regist release];
    
    _sinaButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _sinaButton.titleLabel.font = [UIFont systemFontOfSize:kSize2];
    [_sinaButton setTitleColor:GETSKINCOLOR(ACCOUNT_BUTTON_TITLE_COLOR) forState:UIControlStateNormal];
    [_sinaButton setTitle:STR(@"Account_Sina", Localize_Account) forState:UIControlStateNormal];
    [_sinaButton setImage: IMAGE(@"AccountSina.png", IMAGEPATH_TYPE_1) forState:UIControlStateNormal];
    [_sinaButton setImageEdgeInsets:UIEdgeInsetsMake(0, -5, 0, 0)];
    [_sinaButton setBackgroundImage:[ IMAGE(@"AccountSinaBg1.png", IMAGEPATH_TYPE_1) stretchableImageWithLeftCapWidth:8 topCapHeight:20]  forState:UIControlStateNormal];
    [_sinaButton setBackgroundImage:[IMAGE(@"AccountSinaBg2.png", IMAGEPATH_TYPE_1) stretchableImageWithLeftCapWidth:8 topCapHeight:20]  forState:UIControlStateHighlighted];
    [_sinaButton addTarget:self action:@selector(XLWeiBo_BindingAction:) forControlEvents:UIControlEventTouchUpInside];
    [_tableView addSubview:_sinaButton];
    
    _tencentButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _tencentButton.titleLabel.font = [UIFont systemFontOfSize:kSize2];
    [_tencentButton setTitleColor:GETSKINCOLOR(ACCOUNT_BUTTON_TITLE_COLOR) forState:UIControlStateNormal];
    [_tencentButton setTitle:STR(@"Account_Tencent", Localize_Account) forState:UIControlStateNormal];
    [_tencentButton setImage: IMAGE(@"AccountTencent.png", IMAGEPATH_TYPE_1) forState:UIControlStateNormal];
    [_tencentButton setImageEdgeInsets:UIEdgeInsetsMake(0, -5, 0, 0)];
    [_tencentButton setBackgroundImage:[IMAGE(@"AccountTencentBg1.png", IMAGEPATH_TYPE_1) stretchableImageWithLeftCapWidth:8 topCapHeight:20]  forState:UIControlStateNormal];
    [_tencentButton setBackgroundImage:[IMAGE(@"AccountTencentBg2.png", IMAGEPATH_TYPE_1) stretchableImageWithLeftCapWidth:8 topCapHeight:20]  forState:UIControlStateHighlighted];
    [_tencentButton addTarget:self action:@selector(TXWeiBo_BindingAction:) forControlEvents:UIControlEventTouchUpInside];
    [_tableView addSubview:_tencentButton];
    
    
    _leftLine = [[UIImageView alloc] init];
    _leftLine.backgroundColor = GETSKINCOLOR(ACCOUNT_LINE_COLOR);
    _leftLine.alpha = 0.5;
    [_tableView addSubview:_leftLine];
    [_leftLine release];
    
    _rightLine = [[UIImageView alloc] init];
    _rightLine.backgroundColor = GETSKINCOLOR(ACCOUNT_LINE_COLOR);
    _rightLine.alpha = 0.5;
    [_tableView addSubview:_rightLine];
    [_rightLine release];
    
    m_sectionLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 50)];
    m_sectionLable.backgroundColor = GETSKINCOLOR(HUD_LABEL_CLEAR_BACK_COLOR);
    m_sectionLable.textColor = FOOTERCOLOR;
    m_sectionLable.text = [loginContent objectAtIndex:2];
    m_sectionLable.font = [UIFont systemFontOfSize:14];
    m_sectionLable.textAlignment = NSTextAlignmentCenter;
    [_tableView addSubview:m_sectionLable];
    [m_sectionLable release];
    
    m_accountNetReq = [[MWAccountRequest alloc]init];
    m_accountNetReq.delegate = self;
    
    
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
	if (m_currentTextFieldIndex > -1)
    {
        Plugin_GDAccount_InputCell *cell = (Plugin_GDAccount_InputCell*)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:m_currentTextFieldIndex inSection:0]];
        [cell.m_input resignFirstResponder];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(textFieldDidChange:) name: UITextFieldTextDidChangeNotification object: nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(thirdLoginGetProfileFinished:) name:THIRD_LODIN_FINISH object:nil];

    [self setViewFrame:Interface_Flag];
    
}

- (void)dealloc
{
    s_myViewDelegate = nil;
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    if (m_userName)
    {
        [m_userName release];
        m_userName = nil;
    }
    if (m_userPSW)
    {
        [m_userPSW release];
        m_userPSW = nil;
    }
    [loginContent release];
    if (_sinaWeibo.delegate == self)
    {
        _sinaWeibo.delegate = nil;
    }
    if (_tcWeibo.delegate == self)
    {
        _tcWeibo.delegate = nil;
    }
    m_accountNetReq.delegate = nil;
    [m_accountNetReq release];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark notify method
- (void)thirdLoginGetProfileFinished:(NSNotification *)notify
{
    [QLoadingView hideWithAnimated:NO];
    m_loginType = [[Plugin_Account getAccountInfoWith:1] intValue];
    [self checkPhoneNumberBinding];
}
#pragma mark - nomal method
-(void) setViewFrame:(int)flag
{
    if (flag == 1)
    {
        _tableView.frame = CGRectMake(0, 0, APPHEIGHT, APPWIDTH - NAVICTR_H);
    }
    else
    {
        _tableView.frame = CGRectMake(0, 0, APPWIDTH, APPHEIGHT - NAVICTR_H);
    }
    CGSize size = _tableView.frame.size;
    CGRect tableFrame = _tableView.frame;
    
    btnLogin.frame = CGRectMake(10, 120, tableFrame.size.width-20, 46);
    
    CGSize button_size = [m_forgetPWButton.m_colorTitle sizeWithFont:m_forgetPWButton.titleLabel.font];
    
    m_forgetPWButton.frame = CGRectMake(size.width - button_size.width  - 10 , 180 , button_size.width + 10, 20.0f);
    
    button_size = [m_regist.m_colorTitle sizeWithFont:m_regist.titleLabel.font];
    
    m_regist.frame = CGRectMake(12 , 180 , button_size.width + 10, 20.0f);
    if (isPad)
    {
        if (flag == 1)
        {
            m_sectionLable.frame = CGRectMake(0, size.height - 110, size.width, 40);
            _sinaButton.frame = CGRectMake(0, 0, 485, 42);
            _sinaButton.center = CGPointMake(size.width / 4, size.height - 40);
            _tencentButton.frame = CGRectMake(0, 0, 485, 42);
            _tencentButton.center = CGPointMake(size.width * 3 / 4, size.height - 40);
            CGSize secitonLableSize = [m_sectionLable.text sizeWithFont:m_sectionLable.font];
            _leftLine.frame = CGRectMake(0, size.height - 90, (size.width - secitonLableSize.width)/2, 1);
            _rightLine.frame = CGRectMake(size.width - _leftLine.frame.size.width, size.height - 90, (size.width - secitonLableSize.width)/2, 1);
        }
        else
        {
            m_sectionLable.frame = CGRectMake(0, size.height - 110, size.width, 40);
            _sinaButton.frame = CGRectMake(0, 0, 365, 42);
            _sinaButton.center = CGPointMake(size.width / 4, size.height - 40);
            _tencentButton.frame = CGRectMake(0, 0, 365, 42);
            _tencentButton.center = CGPointMake(size.width * 3 / 4, size.height - 40);
            CGSize secitonLableSize = [m_sectionLable.text sizeWithFont:m_sectionLable.font];
            _leftLine.frame = CGRectMake(0, size.height - 90, (size.width - secitonLableSize.width)/2, 1);
            _rightLine.frame = CGRectMake(size.width - _leftLine.frame.size.width, size.height - 90, (size.width - secitonLableSize.width)/2, 1);
        }
    }
    else
    {
        if (flag == 1)
        {
            m_sectionLable.frame = CGRectMake(0, size.height - 50, size.width, 40);
            _sinaButton.frame = CGRectMake(0, 0, 210, 42);
            _sinaButton.center = CGPointMake(size.width / 4, size.height + 20);
            _tencentButton.frame = CGRectMake(0, 0, 210, 42);
            _tencentButton.center = CGPointMake(size.width * 3 / 4, size.height + 20);
            
            CGSize secitonLableSize = [m_sectionLable.text sizeWithFont:m_sectionLable.font];
            _leftLine.frame = CGRectMake(0, size.height - 30, (size.width - secitonLableSize.width )/2, 1);
            _rightLine.frame = CGRectMake(size.width - _leftLine.frame.size.width, size.height - 30, (size.width - secitonLableSize.width )/2, 1);
        }
        else
        {
            m_sectionLable.frame = CGRectMake(0, size.height - 110, size.width, 40);
            _sinaButton.frame = CGRectMake(0, 0, 140, 42);
            _sinaButton.center = CGPointMake(size.width / 4, size.height - 40);
            _tencentButton.frame = CGRectMake(0, 0, 140, 42);
            _tencentButton.center = CGPointMake(size.width * 3 / 4, size.height - 40);
            CGSize secitonLableSize = [m_sectionLable.text sizeWithFont:m_sectionLable.font];
            _leftLine.frame = CGRectMake(0, size.height - 90, (size.width - secitonLableSize.width)/2, 1);
            _rightLine.frame = CGRectMake(size.width - _leftLine.frame.size.width, size.height - 90, (size.width - secitonLableSize.width)/2, 1);
        }
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
- (void)checkPhoneNumberBinding
{
//    [QLoadingView hideWithAnimated:NO];
    if(m_loginType == 1 || m_loginType == 2)
    {
        //获取头像
        if(m_accountNetReq.strimageurl)
        {
            AccountPersonalData *persondata = [AccountPersonalData SharedInstance];
            [persondata GetImageWithURL:m_accountNetReq.strimageurl];
        }
    }
    
    if(m_loginType==2)
    {
        [self goBack_Click];
    }
    else if(m_loginType ==1)
    {
        if([[Plugin_Account_Utility shareInstance] bCheckPhone:m_accountNetReq.strphone] == YES)
        {
            //提示用手机号码登录？
            [self goBack_Click];

        }
        else
        {
            //提示绑定手机号
            AccountBindPhoneViewController *bindphonectl = [[AccountBindPhoneViewController alloc]init];
            [self.navigationController pushViewController:bindphonectl animated:YES];
            [bindphonectl release];

        }
    }
    else if(m_loginType == 3 || m_loginType ==4)
    {
//        [self.navigationController popViewControllerAnimated:NO];

        AccountRegistPhoneViewController *ctl = [[AccountRegistPhoneViewController alloc] initWithType:1];
        [self.navigationController pushViewController:ctl animated:YES];
        [ctl release];
    }
    else if(m_loginType == 5 || m_loginType ==6)
    {
        //提示手机号登录
        //提示框 6s消失
        GDAlertView *alert = [[[GDAlertView alloc] initWithTitle:[loginContent objectAtIndex:5] andMessage:[loginContent objectAtIndex:4]]autorelease];
        alert.autoDismissTime = 6.0f;
        [alert show];
        [self performSelector:@selector(DisppearAlert:) withObject:alert afterDelay:6.0f];
        m_loginType = 0;
        [[Account AccountInstance] setLoginStatus:m_loginType];
        _sinaButton.enabled = NO;
        _tencentButton.enabled = NO;
        self.m_userPSW = @"";
        self.m_userName = @"";
        AccountPersonalData *persondata = [AccountPersonalData SharedInstance];
        if (persondata.m_accountPhoneNumber)
        {
            self.m_userName=persondata.m_accountPhoneNumber;
        }

    }
    else
    {
        [[AccountNotify SharedInstance] ShowAccountMessageWithTag:Account_Alert_Net_Error delegate:self];
//        [self goBack_Click];
    }
}
- (void)DisppearAlert:(GDAlertView *)view
{
    [view dismissAnimated:YES];
     [_tableView reloadData];
}

#pragma mark - NetReqToViewCtrDelegate

- (void)requestToViewCtrWithRequestType:(RequestType)requestType didFinishLoadingWithResult:(id)result
{
    

    if (requestType == REQ_LOGIN)
    {
        [QLoadingView hideWithAnimated:NO];
        if ([[result objectForKey:@"Result"] isEqualToString:@"SUCCESS"] || [[result objectForKey:@"Result"] isEqualToString:@"ALREADY_LOGIN"] || [[result objectForKey:@"rspcode"] isEqualToString:@"0000"])
        {
            [[Account AccountInstance] setLoginStatus:m_loginType];
            [self checkPhoneNumberBinding];
            

        }
        else
        {
            if([[result objectForKey:@"Error"] isEqualToString:@"ERROR_USER_NOTEXIST"] ||[[result objectForKey:@"rspcode"] isEqualToString:@"1027"])
            {
                self.m_userPSW = @"";
                [_tableView reloadData];
                [[AccountNotify SharedInstance] ShowAccountMessageWithTag:Account_Alert_Non_Account delegate:self];
            }
            else
            {
                self.m_userPSW = @"";
                [_tableView reloadData];
                [[AccountNotify SharedInstance] ShowAccountMessageWithTag:Account_Alert_Password_Error delegate:self];
            }
        }
    }
    else if (requestType == REQ_THIRD_LOGIN)
    {
        if ([[result objectForKey:@"Result"] isEqualToString:@"SUCCESS"] || [[result objectForKey:@"Result"] isEqualToString:@"ALREADY_LOGIN"])
        {
            
            [[Account AccountInstance] setLoginStatus:m_loginType];
            if (m_loginType == 3 || m_loginType == 5)
            {
                [MWAccountOperator accountGetProfileWith:REQ_GET_PROFILE tpuserid:m_personalData.m_accountXLWBuuid tptype:@"1" delegate:(id<NetReqToViewCtrDelegate>)[AccountPersonalData SharedInstance]];
                return;
            }
            else if (m_loginType == 4 || m_loginType == 6)
            {
                [MWAccountOperator accountGetProfileWith:REQ_GET_PROFILE tpuserid:m_personalData.m_accountTXWBuuid tptype:@"2" delegate:(id<NetReqToViewCtrDelegate>)[AccountPersonalData SharedInstance]];
                return;
            }
        }
        else
        {
            [QLoadingView hideWithAnimated:NO];
            GDAlertView *Myalert_ext = [[GDAlertView alloc] initWithTitle:nil andMessage:STR(@"Account_LoginFail", Localize_Account)];
            [Myalert_ext addButtonWithTitle:STR(@"Universal_ok", Localize_Universal) type:GDAlertViewButtonTypeCancel handler:nil];
            [Myalert_ext show];
            [Myalert_ext release];
        }
    }
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
    GDBL_clearAccountInfo();
}

#pragma mark click events

-(void) goBack_Click
{
    m_accountNetReq.delegate = nil;
    [AccountTextFieldListener StopAccountTextFieldListner];
    
    if ([CustomWindow existCustomWindow])
    {
        [CustomWindow DestroyCustomWindow];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void) fogetPwd_Click
{
	AccountGetPwdViewController *getPwd=[[AccountGetPwdViewController alloc] init];
	[self.navigationController pushViewController:getPwd animated:YES];
    [getPwd release];

}

-(void) btn_login_click
{
    if (m_currentTextFieldIndex > -1)
    {
        Plugin_GDAccount_InputCell *cell = (Plugin_GDAccount_InputCell*)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:m_currentTextFieldIndex inSection:0]];
        [cell.m_input resignFirstResponder];
    }
    
	isReadFromBuffer =NO;
    
    
    if ([[Plugin_Account_Utility shareInstance] bCheckPhone:self.m_userName] == NO && [[Plugin_Account_Utility shareInstance] bCheckEmail:self.m_userName]==NO)
    {
        [[AccountNotify SharedInstance] ShowAccountMessageWithTag:Account_Alert_Input_Account delegate:self];
        return;
    }
    else
    {
        if ([[Plugin_Account_Utility shareInstance] bCheckEmail:self.m_userName] == YES)
        {
            m_loginType = 1;
        }
        else
        {
            m_loginType = 2;
        }
    }
	
    if ([self.m_userPSW length] < 1)
    {
		[[AccountNotify SharedInstance] ShowAccountMessageWithTag:Account_Alert_Input_Password delegate:s_myViewDelegate];
		return;
	}
	
	isAlertViewShow = YES;
    
    [m_accountNetReq accountLoginRequest:REQ_LOGIN username:self.m_userName password:self.m_userPSW];
    m_accountNetReq.delegate = self;
    
	if ([CustomWindow existCustomWindow])
    {
        [QLoadingView showLoadingView:STR(@"Universal_loading", Localize_Universal) view:[CustomWindow existCustomWindow]] ;
    }
    else
    {
        [QLoadingView showDefaultLoadingView:STR(@"Universal_loading", Localize_Universal)];
    }
}

-(void)btn_regist_click
{
	AccountRegistPhoneViewController *regist =[[AccountRegistPhoneViewController alloc]init];
	[self.navigationController pushViewController:regist animated:YES];
    [regist release];
}

-(void)TXWeiBo_BindingAction:(id)sender
{
	if (![_tcWeibo isAuthValid])
    {
		
		[_tcWeibo logIn:self];
    }
    else
    {
        [_tcWeibo logOut];
        
        [_tcWeibo logIn:self];
    }
    
	
}

-(void)XLWeiBo_BindingAction:(id)sender
{
	if (!_sinaWeibo.sinaweibo.isAuthValid)
	{
        [_sinaWeibo logIn:self.navigationController];
    }
    else
    {
        [_sinaWeibo logOut];
        [_sinaWeibo logIn:self.navigationController];
    }
}

#pragma mark - SinaWeibo Delegate

- (void)sinaweiboDidLogIn:(SinaWeibo *)sinaweibo
{
    m_loginType = 3;
    [_sinaWeibo storeAuthData];
    [_sinaWeibo getUserInfo];
    if ([CustomWindow existCustomWindow])
    {
        [QLoadingView showLoadingView:STR(@"Universal_loading", Localize_Universal) view:[CustomWindow existCustomWindow]] ;
    }
    else
    {
        [QLoadingView showDefaultLoadingView:STR(@"Universal_loading", Localize_Universal)];
    }
}
- (void)sinaweiboAreadyLogIn:(SinaWeibo *)sinaweibo
{
    
    [_sinaWeibo logOut];
    
    [_sinaWeibo logIn:self.navigationController];
}
- (void)sinaweiboDidLogOut:(SinaWeibo *)sinaweibo
{
    NSLog(@"sinaweiboDidLogOut");
    [_sinaWeibo removeAuthData];
    
}

- (void)sinaweiboLogInDidCancel:(SinaWeibo *)sinaweibo
{
    NSLog(@"sinaweiboLogInDidCancel");
}

- (void)sinaweibo:(SinaWeibo *)sinaweibo logInDidFailWithError:(NSError *)error
{
    GDAlertView *Myalert_ext = [[GDAlertView alloc] initWithTitle:nil andMessage:@"登录失败！"];
    [Myalert_ext addButtonWithTitle:STR(@"Universal_ok", Localize_Universal) type:GDAlertViewButtonTypeCancel handler:nil];
    [Myalert_ext show];
    [Myalert_ext release];
}

- (void)sinaweibo:(SinaWeibo *)sinaweibo accessTokenInvalidOrExpired:(NSError *)error
{
    GDAlertView *Myalert_ext = [[GDAlertView alloc] initWithTitle:nil andMessage:@"请重新登录！"];
    [Myalert_ext addButtonWithTitle:STR(@"Universal_ok", Localize_Universal) type:GDAlertViewButtonTypeCancel handler:nil];
    [Myalert_ext show];
    [Myalert_ext release];
    
}
//获取用户信息回调－成功
-(void)onGetUserInfo:(NSDictionary *)newuserInfo
{
    NSDictionary *dic_data = newuserInfo;
    m_personalData.m_profileNickName = [dic_data objectForKey:@"screen_name"];
    m_personalData.m_profileLocation = [dic_data objectForKey:@"location"];
    
    m_personalData.m_accountXLWBName = m_personalData.m_profileNickName;
    m_personalData.m_profileCode = [NSString stringWithFormat:@"%02d%02d00",
                                    [[dic_data objectForKey:@"province"] intValue],
                                    [[dic_data objectForKey:@"city"] intValue]
                                    ];
    m_personalData.m_profileSignature = [dic_data objectForKey:@"description"];
    if ([[dic_data objectForKey:@"gender"] isEqualToString:@"m"])
    {
        m_personalData.m_profileSex = 1;
    }
    else
    {
        m_personalData.m_profileSex = 2;
    }
    
    m_personalData.m_accountXLWBuuid = [NSString stringWithFormat:@"%d",[[dic_data objectForKey:@"id"] intValue]];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/50",[dic_data objectForKey:@"profile_image_url"]]];
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    NSData *received = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    [request release];
    
    m_personalData.m_profileHead = [[[UIImage alloc]initWithData:received] autorelease];
    //    [self.tableView reloadData];
    
    m_personalData.m_XL_Info = newuserInfo;
    
    NSData *data = UIImagePNGRepresentation(m_personalData.m_profileHead);
    NSMutableArray *accountInfoArray = [NSMutableArray arrayWithArray:[[Account AccountInstance] getAccountInfo]];
    [accountInfoArray replaceObjectAtIndex:3 withObject:m_personalData.m_profileNickName?m_personalData.m_profileNickName:@""];
    [accountInfoArray replaceObjectAtIndex:4 withObject:data?data:[NSData data]];
    [accountInfoArray replaceObjectAtIndex:5 withObject:m_personalData.m_accountXLWBuuid?m_personalData.m_accountXLWBuuid:@""];
    [[Account AccountInstance] setAccountInfo:accountInfoArray];
    
    [MWAccountOperator accountThirdLoginWith:REQ_THIRD_LOGIN tpuserid:m_personalData.m_accountXLWBuuid tpusername:m_personalData.m_accountNickNmae tptype:@"1" delegate:self];
}
//获取用户信息回调－失败
-(void)onGetUserInfoFailed:(NSError *)error
{
    GDAlertView *Myalert_ext = [[GDAlertView alloc] initWithTitle:nil andMessage:STR(@"Account_LoginFail", Localize_Account)];
    [Myalert_ext addButtonWithTitle:STR(@"Universal_ok", Localize_Universal) type:GDAlertViewButtonTypeCancel handler:nil];
    [Myalert_ext show];
    [Myalert_ext release];
}

#pragma mark - login callback

- (void)TCWeiboDidLogIn:(WeiboApi *)TCweibo
{
    m_loginType = 4;
    [_tcWeibo getUserInfo];
    
    if ([CustomWindow existCustomWindow])
    {
        [QLoadingView showLoadingView:STR(@"Universal_loading", Localize_Universal) view:[CustomWindow existCustomWindow]] ;
    }
    else
    {
        [QLoadingView showDefaultLoadingView:STR(@"Universal_loading", Localize_Universal)];
    }
}

- (void)TCWeiboAreadyLogIn:(WeiboApi *)TCweibo
{
    
}

- (void)TCGetUserInfo:(NSDictionary *)userInfo
{
    if ([[userInfo objectForKey:@"msg"] isEqual:@"ok"])
    {
        NSDictionary *dic_data = [userInfo objectForKey:@"data"];
        m_personalData.m_profileNickName = [dic_data objectForKey:@"nick"];
        m_personalData.m_profileLocation = [dic_data objectForKey:@"location"];
        m_personalData.m_profileCode =[NSString stringWithFormat:@"%02d%02d00",
                                       [[dic_data objectForKey:@"province_code"] intValue],
                                       [[dic_data objectForKey:@"city_code"] intValue]
                                       ];
        m_personalData.m_profileMonth = [[dic_data objectForKey:@"birth_month"] intValue];
        m_personalData.m_profileYear = [[dic_data objectForKey:@"birth_year"] intValue];
        m_personalData.m_profileDay = [[dic_data objectForKey:@"birth_day"] intValue];
        m_personalData.m_profileSex = [[dic_data objectForKey:@"sex"] intValue];
        m_personalData.m_accountTXWBuuid = [NSString stringWithFormat:@"%@",[dic_data objectForKey:@"openid"]];
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/50",[dic_data objectForKey:@"head"]]];
        NSURLRequest *request = [[NSURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
        NSData *received = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        [request release];
        m_personalData.m_profileHead = [[[UIImage alloc]initWithData:received] autorelease];
        m_personalData.m_accountTXWBName = m_personalData.m_profileNickName;
        
        
        NSData *data = UIImagePNGRepresentation(m_personalData.m_profileHead);
        NSMutableArray *accountInfoArray = [NSMutableArray arrayWithArray:[[Account AccountInstance] getAccountInfo]];
        [accountInfoArray replaceObjectAtIndex:3 withObject:m_personalData.m_profileNickName?m_personalData.m_profileNickName:@""];
        [accountInfoArray replaceObjectAtIndex:4 withObject:data?data:[NSData data]];
        [accountInfoArray replaceObjectAtIndex:5 withObject:m_personalData.m_accountTXWBuuid?m_personalData.m_accountTXWBuuid:@""];
        [[Account AccountInstance] setAccountInfo:accountInfoArray];
        m_personalData.m_TX_Info = userInfo;
        [MWAccountOperator accountThirdLoginWith:REQ_THIRD_LOGIN tpuserid:m_personalData.m_accountTXWBuuid tpusername:m_personalData.m_accountNickNmae tptype:@"2" delegate:self];
    }
    else
    {
        GDAlertView *Myalert_ext = [[GDAlertView alloc] initWithTitle:nil andMessage:STR(@"Account_LoginFail", Localize_Account)];
        [Myalert_ext addButtonWithTitle:STR(@"Universal_ok", Localize_Universal) type:GDAlertViewButtonTypeCancel handler:nil];
        [Myalert_ext show];
        [Myalert_ext release];
    }
}

- (void)TCGetUserInfoFailed:(NSError *)error
{
    
}

#pragma mark UIAlertView
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	switch (alertView.tag)
    {
        case 223:
		    switch(buttonIndex + 1)
		{
			case 1:
				
			    break;
			case 2:
			{
				
			    [_sinaWeibo logOut];
                
			}
				break;
				
			default:
				break;
		}
			break;
        case 224:
		    switch(buttonIndex + 1)
		{
			case 1:
				
			    break;
			case 2:
			{
                [_tcWeibo logOut];
                
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

#pragma mark UITextField delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    m_currentTextFieldIndex = textField.tag;
    if (textField.tag == 2)
    {
        
    }
	return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    m_currentTextFieldIndex = textField.tag;
    
}
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    _tableView.frame = CGRectMake(CCOMMON_TABLE_X, 0, self.view.bounds.size.width - CCOMMON_TABLE_X * 2, self.view.bounds.size.height);
}

- (void)textFieldDidChange:(NSNotification *)notification
{
    UITextField *textField = nil;
    NSObject* obj = [notification object];
    if ([obj isKindOfClass:[UITextField class]])
    {
        textField = (UITextField*)obj;
        
    }
    
    if (textField.tag == 0)
    {
        self.m_userName = textField.text;
    }
    else if (textField.tag == 1)
    {
        self.m_userPSW = textField.text;
    }
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
	if (textField.tag == 0)
    {
        self.m_userName = @"";
		self.m_userPSW = @"";
	}
    else if (textField.tag == 1)
    {
		self.m_userPSW = @"";
	}
	return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
    m_currentTextFieldIndex = -2;
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kHeight2;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    
    return 10.0;
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (Interface_Flag == 1)
    {
        CGFloat offset = SCREENWIDTH - 320;  //plus偏移添加
        return 220 + offset;
    }
    else
    {
        return 300 + iPhoneOffset;
    }
    
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
    static NSString *CellIdentifier_2 = @"login_CellIdentifier_2";
    Plugin_GDAccount_InputCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier_2];
    if (!cell)
    {
        cell = [[[Plugin_GDAccount_InputCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier_2] autorelease];
    }
    cell.m_input.secureTextEntry = NO;
    cell.m_input.placeholder = nil;
    cell.m_input.tag = indexPath.row;
    cell.m_input.delegate = self;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    // Configure the cell...
    cell.emptyLineLength = -1;
    
    if (indexPath.row == 0)
    {
        cell.emptyLineLength = 45;
        cell.imageView.image = IMAGE(@"AccountEdit.png", IMAGEPATH_TYPE_1);
        cell.m_input.placeholder = [loginContent objectAtIndex:0];
        cell.m_input.text = m_userName;
        
    }
    else if (indexPath.row == 1)
    {
        cell.imageView.image = IMAGE(@"AccountLock.png", IMAGEPATH_TYPE_1);
        cell.m_input.placeholder = [loginContent objectAtIndex:1];
        cell.m_input.secureTextEntry=YES;
        cell.m_input.text = m_userPSW;
    }
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 4)
    {
        if (indexPath.row == 0)
        {
            [self XLWeiBo_BindingAction:nil];
        }
        else
        {
            [self TXWeiBo_BindingAction:nil];
        }
    }
}

@end

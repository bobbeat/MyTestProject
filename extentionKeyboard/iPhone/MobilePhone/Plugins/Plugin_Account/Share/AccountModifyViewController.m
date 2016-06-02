//
//  AccountModifyViewController.m
//  AutoNavi
//
//  Created by gaozhimin on 13-5-15.
//
//

#import "AccountModifyViewController.h"
#import "Plugin_Account_Globall.h"
#import "Plugin_Account_Utility.h"
#import "GDBL_Account.h"
#import "VCTranslucentBarButtonItem.h"
#import "ANParamValue.h"
#import "QLoadingView.h"
#import "Plugin_GDAccount_InputCell.h"
#import "Plugin_GDAccount_InputView.h"
#import "AccountPersonalData.h"
#import "AccountNotify.h"
#import "RegexKitLite.h"
#import "GDAlertView.h"
#import "MWAccountOperator.h"

@interface AccountModifyViewController ()<NetReqToViewCtrDelegate>
{
    GD_Account_ItemType m_itemType;
    int m_currentFieldTag;
    
    NSArray *m_Content;
    UIButton *m_btnGetAuthCode;
    Plugin_GDAccount_InputView *m_checkButton;
    
    AccountPersonalData *m_personalData;
    
    UIButton *m_finishButton;
    float m_boundary;
    id s_myViewDelegate;
}

@end

@implementation AccountModifyViewController

@synthesize m_telNumber,m_firstName,m_check,m_confirmPassWord,m_newPassWord,m_nickName,m_oldPassWord,m_signature;

- (id)initWithItemType:(GD_Account_ItemType)type
{
    self = [super init];
    if (self) {
        // Custom initialization
        m_itemType = type;
        s_myViewDelegate = self;
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    m_personalData = [AccountPersonalData SharedInstance];
    
    m_currentFieldTag = 0;
    

    m_boundary = 20;

    
    self.navigationItem.leftBarButtonItem = BARBUTTON(@"",@selector(goBack_Click));
    m_Content = [[NSArray alloc] initWithObjects:STR(@"Account_NickName", Localize_Account), STR(@"Account_OldPassword", Localize_Account),STR(@"Account_NewPassword", Localize_Account),STR(@"Account_ConfirmPassword", Localize_Account),STR(@"Account_FirstName", Localize_Account),STR(@"Account_ModifyNick", Localize_Account),STR(@"Account_ModifyPassword", Localize_Account),STR(@"Account_Save", Localize_Account),STR(@"Account_EditSignature", Localize_Account),nil];
    
    if (m_itemType == GD_Account_Item_NickName)
    {
        self.title = [m_Content objectAtIndex:5];
        self.m_nickName = m_personalData.m_profileNickName;
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(getListenMessage:) name:HEAD_UPDATE_PROFILE object:nil];
    }
    else if (m_itemType == GD_Account_Item_ModifyPSW)
    {
        self.title = [m_Content objectAtIndex:6];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(getListenMessage:) name:HEAD_UPDATE_PWD object:nil];
    }
    else if (m_itemType == GD_Account_Item_FirstName)
    {
        self.title = [m_Content objectAtIndex:4];
        self.m_firstName = m_personalData.m_icallFirstName;
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(getListenMessage:) name:HEAD_UPDATE_PROFILE object:nil];
    }
    else if (m_itemType == GD_Account_Item_Signature)
    {
        self.title = [m_Content objectAtIndex:8];
        self.m_signature = m_personalData.m_profileSignature;
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(getListenMessage:) name:HEAD_UPDATE_PROFILE object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewNotify:) name:UITextViewTextDidChangeNotification object:nil];
    }
    
    m_finishButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[m_finishButton addTarget:self action:@selector(btn_Submit_click)forControlEvents:UIControlEventTouchUpInside];
	[m_finishButton setTitleColor:GETSKINCOLOR(ACCOUNT_BUTTON_TITLE_COLOR) forState:(UIControlState)UIControlStateNormal];
	m_finishButton.titleLabel.font =  [UIFont boldSystemFontOfSize:18];
	UIImage *buttonImageNormal1 = IMAGE(@"CommonBtn1.png", IMAGEPATH_TYPE_1);
    UIImage *stretchableButtonImageNormal = [buttonImageNormal1 stretchableImageWithLeftCapWidth:buttonImageNormal1.size.width/2 topCapHeight:buttonImageNormal1.size.height/2];
	UIImage *buttonImagePressed = IMAGE(@"CommonBtn2.png", IMAGEPATH_TYPE_1) ;
    UIImage *stretchableButtonImagePressed = [buttonImagePressed stretchableImageWithLeftCapWidth:buttonImageNormal1.size.width/2 topCapHeight:buttonImageNormal1.size.height/2];
    [m_finishButton setBackgroundImage:stretchableButtonImageNormal forState:UIControlStateNormal];
    [m_finishButton setBackgroundImage:stretchableButtonImagePressed forState:(UIControlState)UIControlStateHighlighted];
    [m_finishButton setTitle:[m_Content objectAtIndex:7] forState:(UIControlState)UIControlStateNormal];
	[_tableView  addSubview:m_finishButton];
        
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(textFieldDidChange:) name: UITextFieldTextDidChangeNotification object: nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
	[self setViewFrame:Interface_Flag];
    [self performSelector:@selector(Delay_Method) withObject:nil afterDelay:0.1];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    self.m_check = nil;
    self.m_confirmPassWord = nil;
    self.m_firstName = nil;
    self.m_newPassWord = nil;
    self.m_nickName = nil;
    self.m_oldPassWord = nil;
    self.m_signature = nil;
    self.m_telNumber = nil;
    s_myViewDelegate = nil;
    
    if (m_Content)
    {
        [m_Content release];
        m_Content = nil;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

#pragma mark - click event

-(void) goBack_Click
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)btn_Submit_click
{
    if (m_currentFieldTag > -1)
    {
        if (m_currentFieldTag == 1)
        {
            [m_checkButton.m_input resignFirstResponder];
        }
        else
        {
            Plugin_GDAccount_InputCell *cell = (Plugin_GDAccount_InputCell*)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:m_currentFieldTag]];
            [cell.m_input resignFirstResponder];
        }
    }
    if (m_itemType == GD_Account_Item_Signature)
    {
        Plugin_GDAccount_InputCell *cell = (Plugin_GDAccount_InputCell*)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:m_currentFieldTag]];
        
        UITextView *view = (UITextView *)[cell viewWithTag:100];
        [view resignFirstResponder];
    }
    
    if (m_itemType == GD_Account_Item_NickName)
    {
        if (![m_nickName isMatchedByRegex:@"^[\u4e00-\u9fa5A-Za-z0-9]+$"])
        {
            [[AccountNotify SharedInstance] ShowAccountMessageWithTag:Account_Alert_Nickname_Condition delegate:s_myViewDelegate];
            return;
        }
        
        if ([m_nickName isEqualToString:m_personalData.m_profileNickName])
        {
            [self.navigationController popViewControllerAnimated:YES];
            return;
        }
        else
        {
            if ([m_nickName length] == 0 || [m_nickName length] > 24)
            {
                [[AccountNotify SharedInstance] ShowAccountMessageWithTag:Account_Alert_Nickname_Condition delegate:s_myViewDelegate];
                return;
            }
            m_personalData.p_profileNickName = m_nickName;
            m_personalData.m_modifyType = ACCOUNT_MODIFY_NICK;
            
            NSArray *tmpArray;
            GDBL_GetAccountInfo(&tmpArray);
            int loginType = [[tmpArray objectAtIndex:0] intValue];//0未登录，1老用户登录，2新用户登录，3新浪微博帐号登录，4腾讯微博帐号登录，5 新浪帐号绑定高德帐号 6 腾讯帐号绑定高德帐号
            if (loginType == 5)
            {
                [MWAccountOperator accountUpadataProfileWith:REQ_UPDATE_PROFILE nickName:m_nickName province:nil city:nil birthday:nil signature:nil sex:nil firstname:nil tpuserid:m_personalData.m_accountXLWBuuid tptype:@"1" delegate:self];
            }
            else if (loginType == 6)
            {
                [MWAccountOperator accountUpadataProfileWith:REQ_UPDATE_PROFILE nickName:m_nickName province:nil city:nil birthday:nil signature:nil sex:nil firstname:nil tpuserid:m_personalData.m_accountTXWBuuid tptype:@"2" delegate:self];
            }
            else
            {
                [MWAccountOperator accountUpadataProfileWith:REQ_UPDATE_PROFILE nickName:m_nickName province:nil city:nil birthday:nil signature:nil sex:nil firstname:nil tpuserid:nil tptype:nil delegate:self];
            }
        }
        
    }
    else if (m_itemType == GD_Account_Item_FirstName)
    {
        if ([m_firstName length] == 0 || [m_firstName length] > 24)
        {
            [[AccountNotify SharedInstance] ShowAccountMessageWithTag:Account_Alert_Nickname_Condition delegate:s_myViewDelegate];
            return;
        }
        m_personalData.p_icallFirstName = m_firstName;
        m_personalData.m_modifyType = ACCOUNT_MODIFY_FIRST_NAME;
        
        NSArray *tmpArray;
        GDBL_GetAccountInfo(&tmpArray);
        int loginType = [[tmpArray objectAtIndex:0] intValue];//0未登录，1老用户登录，2新用户登录，3新浪微博帐号登录，4腾讯微博帐号登录，5 新浪帐号绑定高德帐号 6 腾讯帐号绑定高德帐号
        if (loginType == 5)
        {
            [MWAccountOperator accountUpadataProfileWith:REQ_UPDATE_PROFILE nickName:nil province:nil city:nil birthday:nil signature:nil sex:nil firstname:m_firstName tpuserid:m_personalData.m_accountXLWBuuid tptype:@"1" delegate:self];
        }
        else if (loginType == 6)
        {
            [MWAccountOperator accountUpadataProfileWith:REQ_UPDATE_PROFILE nickName:nil province:nil city:nil birthday:nil signature:nil sex:nil firstname:m_firstName tpuserid:m_personalData.m_accountTXWBuuid tptype:@"2" delegate:self];
        }
        else
        {
            [MWAccountOperator accountUpadataProfileWith:REQ_UPDATE_PROFILE nickName:nil province:nil city:nil birthday:nil signature:nil sex:nil firstname:m_firstName tpuserid:nil tptype:nil delegate:self];
        }

    }
    else if (m_itemType == GD_Account_Item_ModifyPSW)
    {
        if ([m_oldPassWord length] == 0 || [m_newPassWord length] == 0 || [m_confirmPassWord length] == 0)
        {
            [[AccountNotify SharedInstance] ShowAccountMessageWithTag:Account_Alert_Input_Password delegate:s_myViewDelegate];
            return;
        }
        
        
        if ([m_oldPassWord length] < 6
            || [m_oldPassWord length] > 32
            || [[Plugin_Account_Utility shareInstance] bCheckStrFormat:m_oldPassWord MatchStr:MATCH_PWD]==NO
            ||[m_newPassWord length] < 6
            ||[m_newPassWord length] > 32
            ||[[Plugin_Account_Utility shareInstance] bCheckStrFormat:m_newPassWord MatchStr:MATCH_PWD]==NO
            |[m_confirmPassWord length] < 6
            ||[m_confirmPassWord length] > 32
            ||[[Plugin_Account_Utility shareInstance] bCheckStrFormat:m_confirmPassWord MatchStr:MATCH_PWD]==NO
            )
        {
            [[AccountNotify SharedInstance] ShowAccountMessageWithTag:Account_Alert_Password_Condition delegate:s_myViewDelegate];
            return;
        }
        
        
        if (![m_confirmPassWord isEqual:m_newPassWord])
        {
            [[AccountNotify SharedInstance] ShowAccountMessageWithTag:Account_Alert_NewPassword_Different delegate:s_myViewDelegate];
            return;
        }
        NSArray *tmpArray;
        GDBL_GetAccountInfo(&tmpArray);
        int loginType = [[tmpArray objectAtIndex:0] intValue];//0未登录，1老用户登录，2新用户登录，3新浪微博帐号登录，4腾讯微博帐号登录，5 新浪帐号绑定高德帐号 6 腾讯帐号绑定高德帐号

        if (loginType == 5)
        {
            [MWAccountOperator accountModifyPwdWith:REQ_UPDATE_PWD oldpw:m_oldPassWord newpw:m_newPassWord tpuserid:m_personalData.m_accountXLWBuuid tptype:@"1" delegate:self];
        }
        else if (loginType == 6)
        {
            [MWAccountOperator accountModifyPwdWith:REQ_UPDATE_PWD oldpw:m_oldPassWord newpw:m_newPassWord tpuserid:m_personalData.m_accountTXWBuuid tptype:@"2" delegate:self];
        }
        else
        {
            [MWAccountOperator accountModifyPwdWith:REQ_UPDATE_PWD oldpw:m_oldPassWord newpw:m_newPassWord tpuserid:nil tptype:nil delegate:self];
        }
        
        
    }
    else if (m_itemType == GD_Account_Item_Signature)
    {
        if ([m_signature length] > 140)
        {
            [[AccountNotify SharedInstance] ShowAccountMessageWithTag:Account_Alert_Signature_Condition delegate:s_myViewDelegate];
            return;
        }
        m_personalData.p_profileSignature = m_signature;
        m_personalData.m_modifyType = ACCOUNT_MODIFY_SIGN;
        
        NSArray *tmpArray;
        GDBL_GetAccountInfo(&tmpArray);
        int loginType = [[tmpArray objectAtIndex:0] intValue];//0未登录，1老用户登录，2新用户登录，3新浪微博帐号登录，4腾讯微博帐号登录，5 新浪帐号绑定高德帐号 6 腾讯帐号绑定高德帐号

        if (loginType == 5)
        {
            [MWAccountOperator accountUpadataProfileWith:REQ_UPDATE_PROFILE nickName:nil province:nil city:nil birthday:nil signature:m_signature sex:nil firstname:nil tpuserid:m_personalData.m_accountXLWBuuid tptype:@"1" delegate:self];
        }
        else if (loginType == 6)
        {
            [MWAccountOperator accountUpadataProfileWith:REQ_UPDATE_PROFILE nickName:nil province:nil city:nil birthday:nil signature:m_signature sex:nil firstname:nil tpuserid:m_personalData.m_accountTXWBuuid tptype:@"2" delegate:self];
        }
        else
        {
            [MWAccountOperator accountUpadataProfileWith:REQ_UPDATE_PROFILE nickName:nil province:nil city:nil birthday:nil signature:m_signature sex:nil firstname:nil tpuserid:nil tptype:nil delegate:self];
        }
        
        
    }
    [QLoadingView showLoadingView:nil view:(UIWindow *)self.view];
    
}

#pragma mark - normal method
- (void)Delay_Method
{
    if (m_itemType == GD_Account_Item_Signature)
    {
         Plugin_GDAccount_InputCell *cell = (Plugin_GDAccount_InputCell*)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:m_currentFieldTag]];
        
        UITextView *view = (UITextView *)[cell viewWithTag:100];
        [view becomeFirstResponder];
        return;
    }
    m_currentFieldTag = 0;
    Plugin_GDAccount_InputCell *cell = (Plugin_GDAccount_InputCell*)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:m_currentFieldTag]];
    [cell.m_input becomeFirstResponder];
}

-(void) setViewFrame:(int)flag
{
    
    
    CGSize size = _tableView.bounds.size;
    
    int count = [_tableView numberOfRowsInSection:0];
    CGRect currentCellRect = [_tableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:count - 1 inSection:0]];
    m_finishButton.frame = CGRectMake(0, currentCellRect.origin.y + currentCellRect.size.height + 15, size.width, 46);
    
    [_tableView reloadData];
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

#pragma maik - notify delegate
-(void)getListenMessage:(NSNotification*)notify
{
    if (self.navigationController.topViewController != self)
	{
		return;
	}
	
	NSArray* result = (NSArray*)[notify object];
    
    NSString *net_result = [result objectAtIndex:0];
    
    if ([net_result isEqualToString:NET_CON_TIMEOUT] || [net_result isEqualToString:PARSE_DATA_NIL] || [net_result isEqualToString:PARSE_ERROR] )
    {
        [[AccountNotify SharedInstance] ShowAccountMessageWithTag:Account_Alert_Net_Error delegate:s_myViewDelegate];
        [QLoadingView hideWithAnimated:NO];//动画停止
        return;
    }
    
    if ([result count] < 3)
    {
        [QLoadingView hideWithAnimated:NO];//动画停止
        return;
    }
	
	NSString *notifyName =[notify name];
	if ([notifyName isEqual:HEAD_UPDATE_PWD])
    {
        [QLoadingView hideWithAnimated:NO];//动画停止
        int nResult = [[result objectAtIndex:2] intValue];
        if (nResult == GD_ERR_OK)
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            self.m_confirmPassWord = @"";
            self.m_newPassWord = @"";
            self.m_oldPassWord = @"";
            [_tableView reloadData];
        }
        
    }
    else
    {
        [QLoadingView hideWithAnimated:NO];//动画停止
    }
}

#pragma mark - NetReqToViewCtrDelegate delegate

- (void)requestToViewCtrWithRequestType:(RequestType)requestType didFinishLoadingWithResult:(id)result
{
    if (requestType == REQ_UPDATE_PWD)
    {
        [QLoadingView hideWithAnimated:NO];//动画停止
        if ([[result objectForKey:@"Result"] isEqualToString:@"SUCCESS"])
        {
            [[AccountNotify SharedInstance] ShowAccountMessageWithTag:Account_Alert_ModifyPassword_Success delegate:s_myViewDelegate];
            [self.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            [[AccountNotify SharedInstance] ShowAccountMessageWithTag:Account_Alert_OldPassword_Error delegate:s_myViewDelegate];
            self.m_confirmPassWord = @"";
            self.m_newPassWord = @"";
            self.m_oldPassWord = @"";
            [_tableView reloadData];
        }
    }
    else if (requestType == REQ_UPDATE_PROFILE)
    {
        [QLoadingView hideWithAnimated:NO];//动画停止
        if ([[result objectForKey:@"Result"] isEqualToString:@"SUCCESS"])
        {
            AccountPersonalData *personalData = [AccountPersonalData SharedInstance];
            if (personalData.m_modifyType == ACCOUNT_MODIFY_SEX)
            {
                personalData.m_profileSex = personalData.p_profileSex;
                [[AccountNotify SharedInstance] ShowAccountMessageWithTag:Account_Alert_Sex_Success delegate:s_myViewDelegate];
            }
            else if (personalData.m_modifyType == ACCOUNT_MODIFY_REGION)
            {
                personalData.m_profileProvince = personalData.p_profileProvince;
                personalData.m_profileCity = personalData.p_profileCity;
                [[AccountNotify SharedInstance] ShowAccountMessageWithTag:Account_Alert_Region_Success delegate:s_myViewDelegate];
            }
            else if (personalData.m_modifyType == ACCOUNT_MODIFY_AGE)
            {
                personalData.m_profileYear = personalData.p_profileYear;
                personalData.m_profileMonth = personalData.p_profileMonth;
                personalData.m_profileDay = personalData.p_profileDay;
                [[AccountNotify SharedInstance] ShowAccountMessageWithTag:Account_Alert_Age_Success delegate:s_myViewDelegate];
            }
            else if (personalData.m_modifyType == ACCOUNT_MODIFY_NICK)
            {
                personalData.m_profileNickName = personalData.p_profileNickName;
                [[AccountNotify SharedInstance] ShowAccountMessageWithTag:Account_Alert_Nickname_Success delegate:s_myViewDelegate];
                GDBL_setAccountNickName(personalData.m_profileNickName);
            }
            else if (personalData.m_modifyType == ACCOUNT_MODIFY_SIGN)
            {
                personalData.m_profileSignature = personalData.p_profileSignature;
                [[AccountNotify SharedInstance] ShowAccountMessageWithTag:Account_Alert_Signature_Success delegate:s_myViewDelegate];
            }
            else if (personalData.m_modifyType == ACCOUNT_MODIFY_FIRST_NAME)
            {
                personalData.m_icallFirstName = personalData.p_icallFirstName;
                [[AccountNotify SharedInstance] ShowAccountMessageWithTag:Account_Alert_First_Success delegate:s_myViewDelegate];
            }
            else if (personalData.m_modifyType == ACCOUNT_MODIFY_TXINFO)
            {
                personalData.m_profileNickName = personalData.p_profileNickName;
                personalData.m_profileSex = personalData.p_profileSex;
                personalData.m_profileYear = personalData.p_profileYear;
                personalData.m_profileMonth = personalData.p_profileMonth;
                personalData.m_profileDay = personalData.p_profileDay;
                personalData.m_profileProvince = personalData.p_profileProvince;
                personalData.m_profileCity = personalData.p_profileCity;
                personalData.m_profileSignature = personalData.p_profileSignature;
            }
            else if (personalData.m_modifyType == ACCOUNT_MODIFY_XLINFO)
            {
                personalData.m_profileNickName = personalData.p_profileNickName;
                personalData.m_profileSex = personalData.p_profileSex;
                personalData.m_profileProvince = personalData.p_profileProvince;
                personalData.m_profileCity = personalData.p_profileCity;
                personalData.m_profileSignature = personalData.p_profileSignature;
            }
            else
            {
                if (!(personalData.m_modifyType == ACCOUNT_MODIFY_TXINFO || personalData.m_modifyType == ACCOUNT_MODIFY_XLINFO))
                {
                    [[AccountNotify SharedInstance] ShowAccountMessageWithTag:Account_Alert_Modify_Error delegate:s_myViewDelegate];
                    
                }
            }
            [_tableView reloadData];
        }
    }
}

- (void)requestToViewCtrWithRequestType:(RequestType)requestType didFailWithError:(NSError *)error
{
    if ([error code] == NSURLErrorTimedOut)
    {
        [[AccountNotify SharedInstance] ShowAccountMessageWithTag:Account_Alert_Net_TimeOut delegate:s_myViewDelegate];
    }
    else
    {
        [[AccountNotify SharedInstance] ShowAccountMessageWithTag:Account_Alert_Net_Error delegate:s_myViewDelegate];
    }
    [QLoadingView hideWithAnimated:NO];
}

#pragma mark UITextField delegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    m_currentFieldTag = textField.tag;
	return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    
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
        if (m_itemType == GD_Account_Item_NickName)
        {
            self.m_nickName = textField.text;
        }
        else if (m_itemType == GD_Account_Item_ModifyPSW)
        {
            self.m_oldPassWord = textField.text;
        }
        else if (m_itemType == GD_Account_Item_FirstName)
        {
            self.m_firstName = textField.text;
        }
    }
    else if (textField.tag == 1)
    {
        if (m_itemType == GD_Account_Item_ModifyPSW)
        {
            self.m_newPassWord = textField.text;
        }
    }
    else if (textField.tag == 2)
    {
        self.m_confirmPassWord = textField.text;
    }
}


- (void)textFieldDidEndEditing:(UITextField *)textField
{
   
}
- (BOOL)textFieldShouldClear:(UITextField *)textField
{
	if (textField.tag == 0)
    {
        if (m_itemType == GD_Account_Item_NickName)
        {
            self.m_nickName = nil;
        }
        else if (m_itemType == GD_Account_Item_ModifyPSW)
        {
            self.m_oldPassWord = nil;
        }
        else if (m_itemType == GD_Account_Item_FirstName)
        {
            self.m_firstName = nil;
        }

    }
    else if (textField.tag == 1)
    {
        if (m_itemType == GD_Account_Item_ModifyPSW)
        {
            self.m_newPassWord = nil;
        }

    }
    else if (textField.tag == 2)
    {
        self.m_confirmPassWord = nil;
    }
	return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    _tableView.frame = CGRectMake(CCOMMON_TABLE_X, 0, self.view.bounds.size.width - CCOMMON_TABLE_X * 2, self.view.bounds.size.height);
    m_currentFieldTag = -1;
	[textField resignFirstResponder];
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

#pragma mark -
#pragma mark UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textview
{
	return YES;
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
    return [s length];
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


- (void)textViewDidBeginEditing:(UITextView *)textView
{
    
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    self.m_signature = textView.text;
}

- (BOOL)textView:(UITextView *)textview shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    return YES;
}

- (void)textViewNotify:(NSNotification *)notify
{
    if (self.navigationController.topViewController != self)
    {
        return;
    }
    
    
    UITextView *textview = nil;
    NSObject* obj = [notify object];
    if ([obj isKindOfClass:[UITextView class]])
    {
        textview = (UITextView*)obj;
        
    }
    
    NSString *temptext = [NSString stringWithFormat:@"%@",textview.text];
	int myInputcount = [self CountWord:temptext];
    
    if (myInputcount > 140)
    {
        textview.text = [textview.text substringToIndex:140];
        myInputcount = 140;
    }
    
    UITableViewCell *cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    UILabel *countLable = (UILabel *)[cell viewWithTag:101];
	countLable.text = [NSString stringWithFormat:@"%d/140",myInputcount];
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
    if (m_itemType == GD_Account_Item_NickName || m_itemType == GD_Account_Item_FirstName || m_itemType == GD_Account_Item_Signature)
    {
        return 1;
    }
    else
    {
        return 3;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (m_itemType == GD_Account_Item_Signature && indexPath.section == 0)
    {
        return 100;
    }
    return kHeight2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 1)
    {
        return 15;
    }
    return 10.0;
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 80;
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
    static NSString *CellIdentifier = @"Modify_Cell";
    Plugin_GDAccount_InputCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell)
    {
        cell = [[[Plugin_GDAccount_InputCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.m_input.delegate = self;
    cell.m_input.tag = indexPath.row;
    cell.m_input.userInteractionEnabled = YES;
    cell.backgroundColor = GETSKINCOLOR(HUD_CLEAR_BACKGROUND_COLOR);
    
    
    
    int count =[_tableView numberOfRowsInSection:indexPath.section];
    if (count==1) {
        cell.backgroundType=BACKGROUND_GROUP;
    }
    else
    {
        if(indexPath.row == 0 )
        {
            cell.backgroundType = BACKGROUND_HEAD;
        }
        else if(indexPath.row == count - 1)
        {
            cell.backgroundType = BACKGROUND_FOOTER;
        }
        else
        {
            cell.backgroundType = BACKGROUND_MIDDLE;
        }
        
    }
    // Configure the cell...
    
    if (m_itemType == GD_Account_Item_Signature)
    {
        
        float width = self.view.bounds.size.width - m_boundary;
        
        UILabel *countLable = (UILabel *)[cell viewWithTag:101];
        if (indexPath.section == 0 && indexPath.row == 0)
        {
            if (!countLable)
            {
                countLable = [[UILabel alloc] init];
                countLable.textColor = TEXTCOLOR;
                countLable.backgroundColor = GETSKINCOLOR(HUD_CLEAR_BACKGROUND_COLOR);
                countLable.textAlignment = NSTextAlignmentRight;
                countLable.tag = 101;
                [cell.contentView addSubview:countLable];
                [countLable release];
            }
            countLable.frame = CGRectMake(0, 75, width - 10, 20);
        }
        else
        {
            [countLable removeFromSuperview];
        }
        
        
        
        cell.m_input.userInteractionEnabled = NO;
        UITextView *textView1 = nil;
        textView1 = (UITextView *)[cell viewWithTag:100];
        if (indexPath.section == 0  && indexPath.row == 0)
        {
            if (!textView1)
            {
                textView1 = [[[UITextView alloc] initWithFrame:CGRectMake(0, 0, width, 90) ]autorelease];
                textView1.userInteractionEnabled = YES;
                
                [textView1.layer setBackgroundColor:[GETSKINCOLOR(HUD_CLEAR_BACKGROUND_COLOR) CGColor]];
                [textView1.layer setBorderColor:[GETSKINCOLOR(HUD_CLEAR_BACKGROUND_COLOR) CGColor]];
                [textView1.layer setBorderWidth:0.5];
                [textView1.layer setCornerRadius:8.5];
                [textView1.layer setMasksToBounds:YES];
                textView1.clipsToBounds = YES;
                
                textView1.textColor = TEXTCOLOR;
                textView1.font = [UIFont fontWithName:@"Arial" size:18];
                textView1.delegate = self;
                textView1.backgroundColor = GETSKINCOLOR(HUD_CLEAR_BACKGROUND_COLOR);
                
                textView1.returnKeyType = UIReturnKeyDefault;
                textView1.keyboardType = UIKeyboardTypeDefault;	// use the default type input method (entire keyboard)
                textView1.scrollEnabled = YES;
                textView1.bounces = NO;
                textView1.tag = 100;
                textView1.text = m_personalData.m_profileSignature;
                [cell.contentView addSubview: textView1];
            }
            textView1.frame = CGRectMake(0, 3, width, 77);
        }
        else
        {
            [textView1 removeFromSuperview];
        }
        int myInputcount = [self CountWord:textView1.text];
        countLable.text = [NSString stringWithFormat:@"%D/140",myInputcount];
        
    }
    switch (m_itemType) {
        case GD_Account_Item_NickName:
            [cell SetTitle:[NSString stringWithFormat:@"%@ : ",[m_Content objectAtIndex:0]]];
            if (m_nickName)
            {
                cell.m_input.text = m_nickName;
            }
            break;
        case GD_Account_Item_FirstName:
            [cell SetTitle:[NSString stringWithFormat:@"%@ : ",[m_Content objectAtIndex:4]]];
            if (m_firstName)
            {
                cell.m_input.text = m_firstName;
            }
            break;
        case GD_Account_Item_ModifyPSW:
            
            if (indexPath.section == 0 && indexPath.row == 0)
            {
                cell.m_input.placeholder = [NSString stringWithFormat:@"%@",[m_Content objectAtIndex:1]];
                if (m_oldPassWord)
                {
                    cell.m_input.text = m_oldPassWord;
                }
            }
            else if (indexPath.section == 0 && indexPath.row == 1)
            {
                cell.m_input.placeholder = [NSString stringWithFormat:@"%@",[m_Content objectAtIndex:2]];
                if (m_newPassWord)
                {
                    cell.m_input.text = m_newPassWord;
                }
            }
            else if (indexPath.section == 0 && indexPath.row == 2)
            {
                cell.m_input.placeholder = [NSString stringWithFormat:@"%@",[m_Content objectAtIndex:3]];
                if (m_confirmPassWord)
                {
                    cell.m_input.text = m_confirmPassWord;
                }
            }
            cell.m_input.secureTextEntry = YES;
            break;
        default:
            break;
    }
    
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

@end

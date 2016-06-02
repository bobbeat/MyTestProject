//
//  AccountBindPhoneViewController.m
//  AutoNavi
//
//  Created by yaying.xiao on 14-10-21.
//
//

#import "AccountBindPhoneViewController.h"
#import "MWAccountRequest.h"
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
#import "NSString+Category.h"
#import "GDAlertView.h"
#import "Account.h"
#import "AccountLoginViewController.h"


#define TableView_Head_Height 20.0f

@interface AccountBindPhoneViewController ()<NetReqToViewCtrDelegate>
{
    
    NSArray *m_registContent;
    Plugin_GDAccount_InputView *m_checkButton;
    Plugin_GDAccount_InputView *m_phoneButton;
    UIButton *m_bindphoneButton;
    Plugin_ColorTitleButton *m_bindNexttimeButton;
    UILabel *m_accountLabel;
    AccountTimeButton *m_btnGetAuthCode;
    
    UITextField *m_phoneField;
    
    UITextField *m_checkField;
    
    UITextField *m_currentField;
    
    UIButton *button_prompt;
    UIImageView *m_imageViewTips;
    UILabel *m_labelTips ;
    UIButton *m_buttonClose;
    MWAccountRequest *m_accountNetReq;
    int m_logintype;
    
    NSString *m_getCheckcodePhone;//获取验证码的手机号，用于合法性检查
}

@end

@implementation AccountBindPhoneViewController

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
    
    self.title = STR(@"Account_BindPhoneNumber", Localize_Account);
    self.navigationItem.leftBarButtonItem =BARBUTTON(@"",@selector(goBack_Click));
    NSArray *accountinfo = [[Account AccountInstance]getAccountInfo];
    NSString *username = [accountinfo caObjectsAtIndex:1];
    m_logintype = [[accountinfo caObjectsAtIndex:0]intValue];

    
    m_registContent = [[NSArray alloc] initWithObjects:STR(@"Account_PhoneNumber", Localize_Account),STR(@"Account_Verification", Localize_Account),STR(@"Account_BindNow", Localize_Account),[NSString stringWithFormat:STR(@"Account_BindPhoneAccount", Localize_Account),username],STR(@"AccountBindPhone_Tips", Localize_Account),STR(@"Account_BindNextTime", Localize_Account), nil];
    //用户名
    m_accountLabel = [[UILabel alloc] init];
    m_accountLabel.font = [UIFont boldSystemFontOfSize:16];
    m_accountLabel.text = [m_registContent objectAtIndex:3];
    m_accountLabel.textColor = TEXTCOLOR;
    m_accountLabel.backgroundColor = GETSKINCOLOR(HUD_LABEL_CLEAR_BACK_COLOR);
    m_accountLabel.numberOfLines = 2;
    [_tableView addSubview:m_accountLabel];
    [m_accountLabel release];
    //手机号码
    m_phoneButton = [[Plugin_GDAccount_InputView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, kHeight2)];
    m_phoneButton.m_input.delegate = self;
    m_phoneButton.userInteractionEnabled = YES;
    m_phoneButton.m_input.tag = 0;
    m_phoneButton.m_input.placeholder = [m_registContent objectAtIndex:0];
    m_phoneButton.m_input.keyboardType = UIKeyboardTypeNumberPad;
    [_tableView addSubview:m_phoneButton];
    [m_phoneButton release];
    m_phoneField =(UITextField*) m_phoneButton.m_input;

    [m_phoneField becomeFirstResponder];
    
    //验证码
    m_checkButton = [[Plugin_GDAccount_InputView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 95, kHeight2)];
    m_checkButton.m_input.delegate = self;
    m_checkButton.userInteractionEnabled = YES;
    m_checkButton.m_input.tag = 10;
    m_checkButton.m_input.placeholder = [m_registContent objectAtIndex:1];
    [_tableView addSubview:m_checkButton];
    [m_checkButton release];
    m_checkField = m_checkButton.m_input;
    
    m_bindphoneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [m_bindphoneButton addTarget:self action:@selector(btn_bindphone_click)forControlEvents:UIControlEventTouchUpInside];
    [m_bindphoneButton setTitleColor:GETSKINCOLOR(ACCOUNT_BUTTON_TITLE_COLOR) forState:(UIControlState)UIControlStateNormal];
    m_bindphoneButton.titleLabel.font =  [UIFont boldSystemFontOfSize:18];
    UIImage *buttonImageNormal1 = IMAGE(@"CommonBtn1.png", IMAGEPATH_TYPE_1);
    UIImage *stretchableButtonImageNormal = [buttonImageNormal1 stretchableImageWithLeftCapWidth:buttonImageNormal1.size.width/2 topCapHeight:buttonImageNormal1.size.height/2];
    UIImage *buttonImagePressed = IMAGE(@"CommonBtn2.png", IMAGEPATH_TYPE_1);
    UIImage *stretchableButtonImagePressed = [buttonImagePressed stretchableImageWithLeftCapWidth:buttonImageNormal1.size.width/2 topCapHeight:buttonImageNormal1.size.height/2];
    [m_bindphoneButton setBackgroundImage:stretchableButtonImageNormal forState:UIControlStateNormal];
    [m_bindphoneButton setBackgroundImage:stretchableButtonImagePressed forState:(UIControlState)UIControlStateHighlighted];
    [m_bindphoneButton setTitle:[m_registContent objectAtIndex:2] forState:(UIControlState)UIControlStateNormal];
    
    [_tableView  addSubview:m_bindphoneButton];
    
    
    
    m_bindNexttimeButton = [[Plugin_ColorTitleButton alloc] init];
    [m_bindNexttimeButton addTarget:self action:@selector(btn_bindnexttime_click)forControlEvents:UIControlEventTouchUpInside];
    m_bindNexttimeButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    [m_bindNexttimeButton setTitleColor:GETSKINCOLOR(ACCOUNT_REGIST_COLOR)  forState:(UIControlState)UIControlStateNormal];
    [m_bindNexttimeButton setTitle:[m_registContent objectAtIndex:5] forState:UIControlStateNormal];
    [_tableView addSubview:m_bindNexttimeButton];
    [m_bindNexttimeButton release];
    m_bindNexttimeButton.hidden = YES;
    
    m_btnGetAuthCode  = [[AccountTimeButton alloc] initWithFrame:CGRectZero countDown:60 viewType:FIND_PSW_VIEW];
    [m_btnGetAuthCode addTarget:self action:@selector(getAuthCode_click)forControlEvents:UIControlEventTouchUpInside];
    m_btnGetAuthCode.titleLabel.font =  [UIFont boldSystemFontOfSize:14];
    [_tableView addSubview:m_btnGetAuthCode];
    [m_btnGetAuthCode release];
    
    
    
    m_imageViewTips = [[UIImageView alloc]init];
    m_imageViewTips.backgroundColor = RGBACOLOR(255.0f, 255.0f, 255.0f, 0.56f);
    m_imageViewTips.userInteractionEnabled = YES;
    //文字设置
    m_labelTips = [[UILabel alloc]init];
    m_labelTips.text = [m_registContent objectAtIndex:4];
    m_labelTips.backgroundColor = [UIColor clearColor];
    m_labelTips.textAlignment = NSTextAlignmentLeft;
    m_labelTips.numberOfLines = 2;
    m_labelTips.lineBreakMode = NSLineBreakByWordWrapping;
    m_labelTips.font  = [UIFont systemFontOfSize:14.0f];
    [m_imageViewTips addSubview:m_labelTips];
    [m_labelTips release];
    
    m_buttonClose = [UIButton buttonWithType:UIButtonTypeCustom];
    [m_buttonClose setImage:IMAGE(@"CarServiceCloseTips.png", IMAGEPATH_TYPE_1) forState:UIControlStateNormal];
    [m_buttonClose setImage:IMAGE(@"CarServiceCloseTipsPress.png", IMAGEPATH_TYPE_1) forState:UIControlStateHighlighted];
    [m_buttonClose addTarget:self action:@selector(closeButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    [m_imageViewTips addSubview:m_buttonClose];
    
    [_tableView addSubview:m_imageViewTips];
    [m_imageViewTips release];
    
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
    m_accountLabel.frame = CGRectMake(offsetx, 5,size.width - 2*offsetx, kHeight1);
    
    m_phoneButton.frame = CGRectMake(offsetx, 50,size.width - 2*offsetx, kHeight2);
    
    
    m_checkButton.frame = CGRectMake(offsetx, 105,size.width - 150, kHeight2);
    
    m_btnGetAuthCode.frame = CGRectMake(size.width - 130, 105, 120, kHeight2);
    
    m_bindphoneButton.frame = CGRectMake(offsetx, 165, size.width - 2*offsetx, 46.0f);
    
    CGSize button_size = [m_bindNexttimeButton.m_colorTitle sizeWithFont:m_bindNexttimeButton.titleLabel.font];
    m_bindNexttimeButton.frame = CGRectMake(size.width - button_size.width  - 10 , 215, button_size.width + 10, 40.0f);
    
    if(flag == 1 && isiPhone)//iphone 横屏
    {
        [m_imageViewTips setFrame:CGRectMake(0, size.height +10.0f  , size.width, 54.0f)];
        [m_labelTips setFrame:CGRectMake(20.0f, 0.0f, size.width - 70.0f, 54.0f)];
        [m_buttonClose setFrame:CGRectMake(size.width - 50.0f, 0.0f, 50.0f, 54.0f)];
        
    }
    
    else
    {
        [m_imageViewTips setFrame:CGRectMake(0, size.height - 54.0f  , size.width, 54.0f)];
        [m_labelTips setFrame:CGRectMake(20.0f, 0.0f, size.width - 70.0f, 54.0f)];
        [m_buttonClose setFrame:CGRectMake(size.width - 50.0f, 0.0f, 50.0f, 54.0f)];
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
    //清除网络请求回调
    m_accountNetReq.delegate = nil;
    [[NetExt sharedInstance] Net_CancelRequestWithType:REQ_CHECK_CODE];
    [[NetExt sharedInstance] Net_CancelRequestWithType:REQ_BIND_PHONE_NUMBER];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if ([CustomWindow existCustomWindow])
    {
        [CustomWindow DestroyCustomWindow];
        return;
    }
    
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



- (void)btn_bindnexttime_click
{
    [self goBack_Click];
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

-(void) btn_bindphone_click
{
    if (m_currentField)
    {
        [m_currentField resignFirstResponder];
        m_currentField = nil;
    }
    
    if ([m_phoneField.text length]<1 || [[Plugin_Account_Utility shareInstance] bCheckPhone:m_phoneField.text]==NO)
    {
        [[AccountNotify SharedInstance] ShowAccountMessageWithTag:Account_Alert_Input_Phone delegate:self];
        return;
    }
    
    if([m_checkField.text length]<1)
    {
        [[AccountNotify SharedInstance] ShowAccountMessageWithTag:Account_Alert_Input_Check delegate:self];
        return;
    }
    
    if(m_getCheckcodePhone && [m_getCheckcodePhone isEqualToString:m_phoneField.text]==NO)
    {
        [[AccountNotify SharedInstance] ShowAccountMessageWithTag:Account_Alert_Phone_Different delegate:self];
        return;
    }
    if(m_logintype ==3 || m_logintype ==4)//第三方登陆,不会走到这个分支
    {
        //    [MWAccountOperator accountCheckCodeWith:REQ_CHECK_CODE phone:m_userNameField.text license_val: m_checkField.text delegate:self];
    }
    else
    {
        [m_accountNetReq accountbindphoneRequest:REQ_BIND_PHONE_NUMBER newphone:m_phoneField.text checkcode:m_checkField.text];
         m_accountNetReq.delegate = self;
    }
    [QLoadingView showLoadingView:nil view:(UIWindow *)self.view];
    return;
    
}

-(void) getAuthCode_click
{
    if (m_currentField)
    {
        [m_currentField resignFirstResponder];
        m_currentField = nil;
    }
    
    if ([m_phoneField.text length]<1 || [[Plugin_Account_Utility shareInstance] bCheckPhone:m_phoneField.text]==NO)
    {
        [[AccountNotify SharedInstance] ShowAccountMessageWithTag:Account_Alert_Input_Phone delegate:self];
        return;
    }
    

    if(m_logintype ==3 || m_logintype ==4)//第三方登陆，不会走到这个分支
    {

    }
    else
    {
        [m_accountNetReq accountCheckCodeRequest:REQ_CHECK_CODE phone:m_phoneField.text actiontype:@"updatephone" ];
        m_accountNetReq.delegate = self;
        CRELEASE(m_getCheckcodePhone);
        m_getCheckcodePhone = [[NSString alloc]initWithString:m_phoneField.text];
    }
    [m_btnGetAuthCode ButtonPressd];
    [QLoadingView showLoadingView:nil view:(UIWindow *)self.view];
}

- (void) closeButtonPress:(id) sender
{
    m_imageViewTips.hidden = YES;
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
//    return 150;
    if (Interface_Flag == 1)
    {
        CGFloat offset = SCREENWIDTH - 320;  //plus偏移添加
        return 270 + offset;
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



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark - NetReqToViewCtrDelegate method
- (void)requestToViewCtrWithRequestType:(RequestType)requestType didFinishLoadingWithResult:(id)result
{
    if (requestType == REQ_CHECK_CODE)//获取验证码
    {
        if ([[result objectForKey:@"rspcode"] isEqualToString:@"0000"])
        {
            [[AccountNotify SharedInstance] ShowAccountMessageWithTag:Account_Alert_Check_Success delegate:self];
        }
        else
        {
            [m_btnGetAuthCode ButtonActive:FIND_PSW_VIEW];
            
            NSString *key_error = [result objectForKey:@"rspcode"];
            if ([key_error isEqualToString:ERROR_SENDMSG_MORE8])
            {
                [[AccountNotify SharedInstance] ShowAccountMessageWithTag:Account_Alert_SMS_Limit delegate:self];
            }
            else if ([key_error isEqualToString:@"1218"])
            {
                [[AccountNotify SharedInstance] ShowAccountMessageWithTag:Account_Alert_Phone_Unregisted delegate:self];
            }
            else 
            {
                [[AccountNotify SharedInstance] ShowAccountMessageWithTag:Account_Alert_Phone_Registed delegate:self];
            }
        }
    }
    else if (requestType == REQ_BIND_PHONE_NUMBER) //绑定手机号
    {
        if ([[result objectForKey:@"rspcode"] isEqualToString:@"0000"])
        {
            [[AccountNotify SharedInstance] ShowAccountMessageWithTag:Account_Alert_Bind_Success delegate:self];
            [self goBack_Click];

        }
        else if ([[result objectForKey:@"rspcode"] isEqualToString:@"1031"] || [[result objectForKey:@"rspcode"] isEqualToString:@"1027"])
        {
            
            [[AccountNotify SharedInstance] ShowAccountMessageWithTag:Account_Alert_Check_Error delegate:nil];
        }
        else
        {
            [[AccountNotify SharedInstance] ShowAccountMessageWithTag:Account_Alert_Check_Error delegate:self];
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
    m_btnGetAuthCode.enabled = YES;
    
}
@end

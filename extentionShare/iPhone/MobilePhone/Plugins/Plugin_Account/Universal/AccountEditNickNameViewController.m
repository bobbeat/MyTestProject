//
//  AccountEditNickNameViewController.m
//  AutoNavi
//
//  Created by yaying.xiao on 14-10-22.
//
//

#import "AccountEditNickNameViewController.h"
#import "MWAccountRequest.h"
#import "AccountNotify.h"
#import "ANParamValue.h"
#import "QLoadingView.h"
#import "Plugin_Account_Globall.h"
#import "Plugin_GDAccount_InputView.h"
#import "Account.h"

#define TableView_Head_Height 20.0f

@interface AccountEditNickNameViewController ()<NetReqToViewCtrDelegate>
{
    
    NSArray *m_registContent;

    Plugin_GDAccount_InputView *m_NicknameButton;
    UITextField *m_NicknameField;
    
    UITextField *m_currentField;

    MWAccountRequest *m_accountNetReq;
}

@end

@implementation AccountEditNickNameViewController

#pragma mark -
#pragma mark initialization


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = STR(@"Account_NickName", Localize_Account);
    self.navigationItem.leftBarButtonItem =BARBUTTON(@"",@selector(goBack_Click));
    m_registContent = [[NSArray alloc] initWithObjects:STR(@"Account_NickName", Localize_Account),STR(@"Account_Save", Localize_Account),STR(@"Account_InputNickName", Localize_Account), nil];
    
    m_NicknameButton = [[Plugin_GDAccount_InputView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, kHeight2)];
    m_NicknameButton.m_input.delegate = self;
    m_NicknameButton.userInteractionEnabled = YES;
    m_NicknameButton.m_input.keyboardType = UIKeyboardTypeDefault;
    [_tableView addSubview:m_NicknameButton];
    [m_NicknameButton release];
    m_NicknameField = m_NicknameButton.m_input;
    m_NicknameField.placeholder = [m_registContent objectAtIndex:2];
    
    NSArray *accountinfo = [[Account AccountInstance]getAccountInfo];
    m_NicknameField.text = [accountinfo caObjectsAtIndex:3];
    [m_NicknameField becomeFirstResponder];

    //网络请求
    m_accountNetReq = [[MWAccountRequest alloc]init];
    m_accountNetReq.delegate = self;
    
    
    self.navigationItem.rightBarButtonItem = RIGHTBARBUTTONITEM([m_registContent objectAtIndex:1], @selector(saveNickName_click:));
    
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
    m_accountNetReq.delegate = nil;
    CRELEASE(m_accountNetReq);
    CRELEASE(m_registContent);
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
    m_NicknameButton.frame = CGRectMake(offsetx, 10,size.width - 2*offsetx, kHeight2);

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
    [[NetExt sharedInstance] Net_CancelRequestWithType:REQ_CHANGE_NICKNAME];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.navigationController popViewControllerAnimated:YES];
}


-(void) saveNickName_click:(id)sender
{
    if (m_currentField)
    {
        [m_currentField resignFirstResponder];
        m_currentField = nil;
    }
    
    if ([m_NicknameField.text length]<1)
    {
        [[AccountNotify SharedInstance] ShowAccountMessageWithTag:Account_Alert_Nickname_Condition delegate:self];
        return;
    }
    [m_accountNetReq accountChangeNickNameRequest:REQ_CHANGE_NICKNAME nickname:m_NicknameField.text];
    m_accountNetReq.delegate = self;
    
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



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}


#pragma mark - NetReqToViewCtrDelegate method
- (void)requestToViewCtrWithRequestType:(RequestType)requestType didFinishLoadingWithResult:(id)result
{
    if (requestType == REQ_CHANGE_NICKNAME)
    {
        if ([[result objectForKey:@"rspcode"] isEqualToString:@"0000"])
        {
            [[AccountNotify SharedInstance] ShowAccountMessageWithTag:Account_Alert_Nickname_Success delegate:self];
            __block AccountEditNickNameViewController *weakself = self;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakself goBack_Click];
            });
        }
        else
        {
            
            NSString *key_error = [result objectForKey:@"rspcode"];
            if ([key_error isEqualToString:@"1027"])
            {
                [[AccountNotify SharedInstance] ShowAccountMessageWithTag:Account_Alert_Phone_Unregisted delegate:self];
            }
            else
            {
                [[AccountNotify SharedInstance] ShowAccountMessageWithTag:Account_Alert_Modify_Error delegate:self];
            }
        }
    }
    [QLoadingView hideWithAnimated:NO];
}

- (void)requestToViewCtrWithRequestType:(RequestType)requestType didFailWithError:(NSError *)error
{
    
    if (requestType == REQ_CHANGE_NICKNAME)
    {
        if ([error code] == NSURLErrorTimedOut)
        {
            [[AccountNotify SharedInstance] ShowAccountMessageWithTag:Account_Alert_Net_TimeOut delegate:self];
        }
        else
        {
            [[AccountNotify SharedInstance] ShowAccountMessageWithTag:Account_Alert_Net_Error delegate:self];
        }
    }
    [QLoadingView hideWithAnimated:NO];
    
}
 
@end

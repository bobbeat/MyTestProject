//
//  AccountInfoViewController.m
//  AutoNavi
//
//  Created by yaying.xiao on 14-10-22.
//
//

#import "AccountInfoViewController.h"
#import "Plugin_Account_Globall.h"
#import "AccountInfoCell.h"
#import "AccountBindPhoneViewController.h"
#import "AccountEditNickNameViewController.h"
#import "MWAccountRequest.h"
#import "AccountNotify.h"
#import "QLoadingView.h"
#import "AccountLoginViewController.h"
#import "GDActionSheet.h"
#import "GDImagePickerController.h"
#import "AccountPersonalData.h"
#import "Account.h"
#import "Plugin_Account_Utility.h"
#import "MWAccountOperator.h"
#import "AccountRegistPhoneViewController.h"

@interface AccountInfoViewController ()<NetReqToViewCtrDelegate,UIImagePickerControllerDelegate,UIActionSheetDelegate,UIAlertViewDelegate,UIPopoverControllerDelegate,UINavigationControllerDelegate>

{
    UIButton *m_logoutButton;
    NSArray *m_contentArray;
    
    MWAccountRequest *m_accountNetReq;
    
    UIImagePickerController *_picker;
    UIPopoverController *m_popoverController;
    AccountPersonalData *m_personalData;
    int m_logintype;

}

@end

@implementation AccountInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = STR(@"Account_MyInformation", Localize_Account);
    self.navigationItem.leftBarButtonItem =BARBUTTON(@"",@selector(goBack_Click));
    m_contentArray = [[NSArray alloc] initWithObjects:STR(@"Account_LogOut1", Localize_Account),STR(@"Account_Head", Localize_Account),STR(@"Account_NickName", Localize_Account),STR(@"Account_PhoneNumber", Localize_Account), STR(@"Account_NotBind", Localize_Account),nil];
    
    m_logoutButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [m_logoutButton addTarget:self action:@selector(btn_logout_click)forControlEvents:UIControlEventTouchUpInside];
    [m_logoutButton setTitleColor:GETSKINCOLOR(SETTING_RESET_BUTTON_COLOR) forState:(UIControlState)UIControlStateNormal];
    m_logoutButton.titleLabel.font =  [UIFont systemFontOfSize:17];
    UIImage *buttonImageNormal1 = IMAGE(@"accountLogout.png", IMAGEPATH_TYPE_1);
    UIImage *stretchableButtonImageNormal = [buttonImageNormal1 stretchableImageWithLeftCapWidth:buttonImageNormal1.size.width/2 topCapHeight:buttonImageNormal1.size.height/2];
    UIImage *buttonImagePressed = IMAGE(@"accountLogoutPress.png", IMAGEPATH_TYPE_1);
    UIImage *stretchableButtonImagePressed = [buttonImagePressed stretchableImageWithLeftCapWidth:buttonImageNormal1.size.width/2 topCapHeight:buttonImageNormal1.size.height/2];
    [m_logoutButton setBackgroundImage:stretchableButtonImageNormal forState:UIControlStateNormal];
    [m_logoutButton setBackgroundImage:stretchableButtonImagePressed forState:(UIControlState)UIControlStateHighlighted];
    [m_logoutButton setTitle:[m_contentArray objectAtIndex:0] forState:(UIControlState)UIControlStateNormal];

   
    [_tableView  addSubview:m_logoutButton];
    
    //网络请求
    m_accountNetReq = [[MWAccountRequest alloc]init];
    m_accountNetReq.delegate = self;
    
    m_personalData = [AccountPersonalData SharedInstance];

 
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO; 
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [self setViewFrame:Interface_Flag];
     [_tableView reloadData];
 
}

- (void)dealloc{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    m_accountNetReq.delegate = nil;
    CRELEASE(m_accountNetReq);
    CRELEASE(m_contentArray);
    if (m_popoverController)
    {
        m_popoverController.delegate = nil;
        [m_popoverController dismissPopoverAnimated:NO];
    }
    [super dealloc];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) setViewFrame:(int)flag
{

    if(flag==0){
        
        m_logoutButton.frame = CGRectMake(10, 186, APPWIDTH-20, 48);
    }
    else
    {
        m_logoutButton.frame = CGRectMake(10,  186, APPHEIGHT-20, 48);
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
    [[NetExt sharedInstance] Net_CancelRequestWithType:REQ_LOGOUT];
    [[NetExt sharedInstance] Net_CancelRequestWithType:REQ_UPLOAD_HEAD];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)btn_logout_click
{
    
    NSString *message = nil;
    message = STR(@"Account_SureLogOut", Localize_Account);
    __block AccountInfoViewController *weakself = self;
    GDAlertView *Myalert_ext = [[GDAlertView alloc] initWithTitle:nil andMessage:message];
    [Myalert_ext addButtonWithTitle:STR(@"Universal_cancel", Localize_Universal) type:GDAlertViewButtonTypeCancel handler:nil];
    [Myalert_ext addButtonWithTitle:STR(@"Universal_ok", Localize_Universal) type:GDAlertViewButtonTypeDefault handler:^(GDAlertView *alertView)
     {
         [weakself logoutRequest];
     }];
    Myalert_ext.tag = 1;
    [Myalert_ext show];
    [Myalert_ext release];
}

-(void)logoutRequest
{
    int logintype = [[Plugin_Account getAccountInfoWith:1] intValue];
    if(logintype==1 || logintype==2)//调用北京后台
    {
        m_accountNetReq.delegate = self;
        //调用登出
        [m_accountNetReq accountLogoutRequest:REQ_LOGOUT];
        NSLog(@"lalalalalalallalalala");
    }
    else //第三方登陆，调用厦门后台
    {
        [MWAccountOperator accountLogoutWith:REQ_LOGOUT delegate:self];
    }
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
    
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0)
    {
        return 70;
    }
    return kHeight2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    
    return 0;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    AccountInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell)
    {
        cell = [[[AccountInfoCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...

    UIImageView *tempimg = [[UIImageView alloc] initWithImage:IMAGE(@"Accessory.png",IMAGEPATH_TYPE_1)];
    cell.accessoryView = tempimg;
    [tempimg release];

    if(indexPath.row == 0)
    {
        cell.textLabel.text = [m_contentArray objectAtIndex:1];
        cell.headImageView.hidden = NO;
        NSArray *accountinfo = [[Account AccountInstance]getAccountInfo];
        UIImage *headImage = [UIImage imageWithData:[accountinfo caObjectsAtIndex:4]];

        if(headImage){
            headImage = [UIImage getRoundImageWithImage:headImage from:0 to:360];
            cell.headImageView.image = headImage;
        }
        else
        {
            cell.headImageView.image = IMAGE(@"non_head.png",IMAGEPATH_TYPE_1);
        }
        
        int logintype = [[Plugin_Account getAccountInfoWith:1] intValue];
        if(logintype == 3 || logintype ==4 || logintype ==5 || logintype ==6)
        {
            cell.accessoryView.hidden = YES;
        }



    }
    
    else if (indexPath.row==1) {
        cell.textLabel.text = [m_contentArray objectAtIndex:2];
        NSArray *accountinfo = [[Account AccountInstance]getAccountInfo];
        cell.detailTextLabel.text = [accountinfo caObjectsAtIndex:3];
        cell.headImageView.hidden = YES;
        
        int logintype = [[Plugin_Account getAccountInfoWith:1] intValue];
        if(logintype == 3 || logintype ==4 || logintype ==5 || logintype ==6)
        {
            cell.accessoryView.hidden = YES;
        }
    }
    else if(indexPath.row ==2)
    {
        cell.textLabel.text = [m_contentArray objectAtIndex:3];
        NSArray *accountinfo = [[Account AccountInstance]getAccountInfo];
        int logintype = [[accountinfo objectAtIndex:0]intValue];
        
        if(logintype==1 || logintype==2){
            NSString *username = [accountinfo caObjectsAtIndex:1];
            BOOL IsPhone = [[Plugin_Account_Utility shareInstance]bCheckPhone:username];
            if(IsPhone)
            {
                cell.detailTextLabel.text = username;
            }
            else
            {
                cell.detailTextLabel.text = [m_contentArray objectAtIndex:4];
            }
        }
        else if(logintype==3 || logintype==4)
        {
            cell.detailTextLabel.text = [m_contentArray objectAtIndex:4];
        }
        else if(logintype==5 || logintype==6)
        {
            AccountPersonalData *personalData = [AccountPersonalData SharedInstance];
            if(personalData.m_accountPhoneNumber)
            {
                BOOL IsPhone = [[Plugin_Account_Utility shareInstance]bCheckPhone:personalData.m_accountPhoneNumber];
                if(IsPhone)
                {
                    cell.detailTextLabel.text = personalData.m_accountPhoneNumber;
                }
                else
                {
                    cell.detailTextLabel.text = [m_contentArray objectAtIndex:4];
                }
            }
        }
        
        cell.headImageView.hidden = YES;
    }
    
    

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = GETSKINCOLOR(HUD_LABEL_CLEAR_BACK_COLOR);
    cell.backgroundView = nil;
    return cell;
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int logintype = [[Plugin_Account getAccountInfoWith:1] intValue];
    if(indexPath.row == 0)//点击头像
    {
        if (logintype == 0)
        {
            AccountLoginViewController *login=[[AccountLoginViewController alloc] initWithAccountName:nil  Password:nil back:YES];
            self.navigationController.navigationBarHidden = NO;   /*为了解决ios7下，导航栏会闪一下的问题*/
            [self.navigationController pushViewController:login animated:YES];
            [login release];
            
        }
        else
        {
            if (logintype == 3 || logintype == 4|| logintype == 5|| logintype == 6)
            {
                return;
            }
            [self createGDActionSheetWithTitle:STR(@"Universal_edit", Localize_Universal) delegate:self cancelButtonTitle:STR(@"Universal_cancel", Localize_Universal) destructiveButtonTitle:nil tag:1 otherButtonTitles:STR(@"Universal_chooseFromAlbum", Localize_Universal),STR(@"Universal_tackPhoto", Localize_Universal), nil];
        }

    }
    
    else if(indexPath.row == 1)//编辑昵称
    {
        if(logintype==1 || logintype==2)
        {
            AccountEditNickNameViewController *ctl = [[AccountEditNickNameViewController alloc]init];
            [self.navigationController pushViewController:ctl animated:YES];
            [ctl release];
        }

    }
    
    else if(indexPath.row == 2)//编辑手机号码
    {
        if(logintype==1 || logintype==2)//北京后台绑定手机号
        {
            AccountBindPhoneViewController *bindphonectl = [[AccountBindPhoneViewController alloc]init];
            [self.navigationController pushViewController:bindphonectl animated:YES];
            [bindphonectl release];
        }
        else  if (logintype == 3 || logintype == 4 || logintype ==5 || logintype == 6)//3，4，5，6第三方绑定手机号，走厦门后台
        {
            AccountRegistPhoneViewController *ctl = [[AccountRegistPhoneViewController alloc] initWithType:1];
            [self.navigationController pushViewController:ctl animated:YES];
            [ctl release];
        }
    }
}

#pragma mark - actionSheet

- (void)GDActionSheet:(GDActionSheet *)actionSheet clickedButtonAtIndex:(int)index
{
    switch (actionSheet.tag)
    {
        case 1:
        {
            switch (index) {
                case 0:
                {
                    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
                        _picker = [[GDImagePickerController alloc] init];
                        _picker.delegate = self;
                        _picker.allowsEditing = YES;
                        _picker.mediaTypes =[UIImagePickerController availableMediaTypesForSourceType:_picker.sourceType];
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
                    } else {
                        GDAlertView *Myalert_ext = [[GDAlertView alloc] initWithTitle:nil andMessage:STR(@"Icall_NoSupportCall", Localize_Icall)];
                        [Myalert_ext addButtonWithTitle:STR(@"Universal_ok", Localize_Universal) type:GDAlertViewButtonTypeCancel handler:nil];
                        [Myalert_ext show];
                        [Myalert_ext release];
                    }
                }
                    break;
                case 1:
                {
                    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
                    {
                        _picker = [[GDImagePickerController alloc]init];
                        _picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                        _picker.delegate = self;
                        _picker.allowsEditing = YES;
                        [self presentModalViewController:_picker animated:YES];
                        [_picker release];
                    } else
                    {
                        GDAlertView *Myalert_ext = [[GDAlertView alloc] initWithTitle:nil andMessage:STR(@"Icall_NoSupportCall", Localize_Icall)];
                        [Myalert_ext addButtonWithTitle:STR(@"Universal_ok", Localize_Universal) type:GDAlertViewButtonTypeCancel handler:nil];
                        [Myalert_ext show];
                        [Myalert_ext release];
                    }
                }
                    break;
                default:
                    break;
            }
        }
    }
}


#pragma mark-
#pragma mark UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if (picker.sourceType==UIImagePickerControllerSourceTypeCamera ||
        picker.sourceType==UIImagePickerControllerSourceTypePhotoLibrary)
    {
        UIImage *originalImage = [info objectForKey:UIImagePickerControllerEditedImage];
        if (originalImage)
        {
            m_personalData.p_profileHead = [self scaleToSize:originalImage size:CGSizeMake(ACCOUNT_HEAD_SIZE, ACCOUNT_HEAD_SIZE) changeRect:CGRectMake(0, 0, ACCOUNT_HEAD_SIZE, ACCOUNT_HEAD_SIZE)];
            m_personalData.bTip = YES;
            
            NSArray *tmpArray;
            GDBL_GetAccountInfo(&tmpArray);
            int loginType = [[tmpArray caObjectsAtIndex:0] intValue];
            if (loginType == 5)
            {

            }
            else if (loginType == 6)
            {

            }
            else
            {
                [m_accountNetReq accountHeaderImgRequest:REQ_UPLOAD_HEAD image:m_personalData.p_profileHead ];
                m_accountNetReq.delegate = self;
            }
            [QLoadingView showLoadingView:nil view:(UIWindow *)self.view];
        }
    }
    if (m_popoverController)
    {
        [m_popoverController dismissPopoverAnimated:YES];
    }
    [picker dismissModalViewControllerAnimated:YES];
    _picker = nil;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissModalViewControllerAnimated:YES];
    _picker = nil;
}

- (void)saveTheImage:(UIImage*)image
{
    NSString *uniquePath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"selectedImage.png"];
    [UIImagePNGRepresentation(image) writeToFile: uniquePath atomically:YES];
    
    
}

//图片缩放到指定大小尺寸
- (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size changeRect:(CGRect)changRect
{
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(size);
    // 绘制改变大小的图片
    [img drawInRect:changRect];
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    // 返回新的改变大小后的图片
    return scaledImage;
}

#pragma mark - UIPopoverControllerDelegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    [popoverController release];
    m_popoverController = nil;
}

#pragma mark - NetReqToViewCtrDelegate method
- (void)requestToViewCtrWithRequestType:(RequestType)requestType didFinishLoadingWithResult:(id)result
{
    if (requestType == REQ_LOGOUT)
    {
        if ([[result objectForKey:@"Result"] isEqualToString:@"SUCCESS"] ||[[result objectForKey:@"rspcode"] isEqualToString:@"0000"] || [[result objectForKey:@"rspcode"] isEqualToString:@"1027"])//账户不存在也是退出成功
        {
            [self goBack_Click];
            GDBL_setAccountImage(IMAGE(@"non_head.png", IMAGEPATH_TYPE_1));
            GDBL_setAccountNickName(@"");
            [[Account AccountInstance] setLoginStatus:0];
            [[AccountPersonalData SharedInstance] AccountClearAll];
        }
        else
        {
            {
                [[AccountNotify SharedInstance] ShowAccountMessageWithTag:Account_Alert_Modify_Error delegate:self];
            }
        }
    }
    else if(requestType == REQ_UPLOAD_HEAD)
    {
        if([[result objectForKey:@"rspcode"] isEqualToString:@"0000"])
        {
            [[AccountNotify SharedInstance] ShowAccountMessageWithTag:Account_Alert_Head_Success delegate:self];
            NSData *data = UIImagePNGRepresentation(m_personalData.p_profileHead);
            if (data)
            {
                NSMutableArray *accountInfoArray = [NSMutableArray arrayWithArray:[[Account AccountInstance] getAccountInfo]];
                [accountInfoArray replaceObjectAtIndex:4 withObject:data];
                [[Account AccountInstance] setAccountInfo:accountInfoArray];
            }
            [_tableView reloadData];
        }
    }

    [QLoadingView hideWithAnimated:NO];
}

- (void)requestToViewCtrWithRequestType:(RequestType)requestType didFailWithError:(NSError *)error
{
    
    if (requestType == REQ_LOGOUT)
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

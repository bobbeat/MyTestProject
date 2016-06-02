//
//  Setting_VersionViewController.m
//  AutoNavi
//
//  Created by huang on 13-8-12.
//
//

#import "SettingVersionViewController.h"
#import "launchRequest.h"
#import "SettingSinaWeiboViewController.h"
#import "NSString+Category.h"
#import "launchRequest.h"
#import "POIDefine.h"
#import "GDSwitchCell.h"
#import "GDAlertView.h"
#import "POITableHeadView.h"
#import "PluginFactory.h"
#import "XMLDictionary.h"

#import <MessageUI/MessageUI.h>
#import<MessageUI/MFMailComposeViewController.h>

#define AutoNaviPhone @"400-810-0080"
#define AutoNaviSinaWeibo @"http://e.weibo.com/autonavigation"
#define AutoNaviEmail @"NaviService@autonavi.com"



@interface SettingVersionViewController ()<GDSwitchCellDelegate>
{
    UIView *view;
}
@end

@implementation SettingVersionViewController

#pragma mark -
#pragma mark viewcontroller ,
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
    CLOG_DEALLOC(self);
    CRELEASE(_updateCommand);
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
    [self initControl];
}
#pragma mark -
#pragma mark control related
//初始化控件
-(void) initControl{
    
    view=[[UIView alloc] initWithFrame:CGRectMake(CCOMMON_TABLE_X, 0, APPWIDTH-CCOMMON_TABLE_X*2, 110)];
    view.autoresizingMask=UIViewAutoresizingFlexibleWidth;
	[self labelCompany_created];
	[self labelVersion_created];
	
	_imagViewAutonavi=[[UIImageView alloc]initWithImage:IMAGE(@"AutoNavi_Logo.png",IMAGEPATH_TYPE_1)];
    
    _imagViewAutonavi.center=CGPointMake(APPWIDTH/2, CGRectGetHeight(_imagViewAutonavi.frame)/2+10);
	[view addSubview:_imagViewAutonavi];
	[_imagViewAutonavi release];
    _tableView.tableHeaderView=view;
    [view release];
    
    
}

//调整控件竖屏坐标和图片
-(void)changePortraitControlFrameWithImage
{
    
    [_tableView setFrame:CGRectMake(CCOMMON_TABLE_X, 0.0f, CGRectGetWidth(self.view.bounds)-2*CCOMMON_TABLE_X, CGRectGetHeight(self.view.bounds))];
    
    _imagViewAutonavi.center=CGPointMake(CGRectGetWidth(view.frame)/2, CGRectGetHeight(_imagViewAutonavi.frame)/2+10);
    [_tableView reloadData];
    
}

//调整控件横屏坐标和图片
-(void)changeLandscapeControlFrameWithImage
{
    _imagViewAutonavi.center=CGPointMake((APPHEIGHT-CCOMMON_TABLE_X*2)/2, CGRectGetHeight(_imagViewAutonavi.frame)/2+10);
    
    [_tableView setFrame:CGRectMake(CCOMMON_TABLE_X, 0.0f, APPHEIGHT , APPWIDTH - 40.)];
    [_tableView reloadData];
}

//改变控件文本
-(void)changeControlText
{
    self.navigationItem.leftBarButtonItem=LEFTBARBUTTONITEM(@"", @selector(leftBtnEvent:));
    _labelCompany.text=STR(@"Setting_AutoNavi",Localize_Setting);
    _labelVersion.text=STR(@"Setting_Copyright",Localize_Setting);
    self.title=STR(@"Setting_VersionInformation",Localize_Setting);
    [_tableView reloadData];
}
-(void)leftBtnEvent:(id)sender
{
    if (isCheck) {

       [[GDBL_LaunchRequest sharedInstance] Net_CancelRequestWithType:RT_LaunchRequest_SoftWareUpdate];
        
    }
	[self.navigationController popViewControllerAnimated:YES];
}
-(void)labelCompany_created
{
	_labelCompany = [[UILabel alloc] initWithFrame:CGRectMake(0,65,APPWIDTH-2*CCOMMON_TABLE_X, 21)];
    _labelCompany.autoresizingMask=UIViewAutoresizingFlexibleWidth;
	_labelCompany.textAlignment = UITextAlignmentCenter;
	_labelCompany.textColor =TEXTCOLOR;
	_labelCompany.backgroundColor = [UIColor clearColor];
	_labelCompany.font = [UIFont systemFontOfSize:kSize2];
	[view  addSubview:_labelCompany];
	[_labelCompany release];
}
-(void)labelVersion_created
{
	_labelVersion = [[UILabel alloc] initWithFrame:CGRectMake(0,85,APPWIDTH-2*CCOMMON_TABLE_X, 15)];
    _labelVersion.autoresizingMask=UIViewAutoresizingFlexibleWidth;
	_labelVersion.textAlignment = UITextAlignmentCenter;
	_labelVersion.textColor = GETSKINCOLOR(@"CopyrightColor");
	_labelVersion.backgroundColor = [UIColor clearColor];
	_labelVersion.font = [UIFont systemFontOfSize:10.0f];
	[view addSubview:_labelVersion];
	[_labelVersion release];
}



#pragma mark -
#pragma mark UISwitchAction
-(void)switchAction:(id)object cell:(GDSwitchCell *)cell
{
    [[MWPreference sharedInstance] setValue:PREF_STARTUPWARNING Value:[object isOn]];
    
}

#pragma mark -
#pragma mark xxx delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	 if(section == 0){
		return 0;
	}
	else if(section == 1){
		return 3;
	}
	else if(section == 2){
		return 1;
	}
    else if(section == 3){
		return 7;
	}
    else if(section == 4){
		return 1;
	}
	
	return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    static NSString *tableCell=@"tableCellIdentifire";
    static NSString *updateCell=@"UpdataCell";
	GDTableViewCell *cell = (GDTableViewCell *)[tableView dequeueReusableCellWithIdentifier:indexPath.section==4?tableCell:indexPath.section==0?updateCell: CellIdentifier];
    
	if(cell == nil)
	{
        if (indexPath.section==4) {
            
            GDSwitchCell * mycell = [[[GDSwitchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tableCell] autorelease];
            cell=mycell;
            mycell.delegate=self;
            
        }
        else if(indexPath.section==0)
        {
            cell = [[[GDTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:updateCell] autorelease];
        }
        else
            cell = [[[GDTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
	}

    cell.detailTextLabel.text=nil;
//    cell.accessoryView=nil;
    switch (indexPath.section) {
        case 0:
        {
            UILabel *label=(UILabel*)[cell.contentView viewWithTag:1001];
            if (!label) {
                label =[[UILabel alloc] initWithFrame:CGRectMake(0, 0,CCOMMON_APP_WIDTH-2*CCOMMON_TABLE_X, kHeight2)];
                label.textColor=TEXTCOLOR;
                label.backgroundColor=[UIColor clearColor];
                label.tag=1001;
                [cell.contentView addSubview:label];
                label.textAlignment=UITextAlignmentCenter;
                [label release];
                label.font=[UIFont systemFontOfSize:kSize2];
            }
            label.frame=CGRectMake(0, 0,CGRectGetWidth(_tableView.frame), kHeight2);
            label.text=STR(@"Settin_DetectionUpdate",Localize_Setting);
           
            
            
//            cell.textLabel.text=STR(@"Settin_DetectionUpdate",Localize_Setting);
//            cell.textLabel.textAlignment=UITextAlignmentCenter;
            UIImageView *tempimg = [[UIImageView alloc] initWithImage:IMAGE(@"Accessory.png",IMAGEPATH_TYPE_1)];
            cell.accessoryView = tempimg;
            [tempimg release];
        }
            break;
        case 1:
        {
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text =  [NSString stringWithFormat:STR(@"Setting_SystemVersion",Localize_Setting),SOFTVERSION];
                    
                    break;
                case 1:
					cell.textLabel.text = [NSString stringWithFormat:STR(@"Setting_EngineVersion",Localize_Setting),GDEngineVersion];
					break;
				case 2:
                {
                    //add by gzm for 显示数据版本号时，若存在城市数据版本号则显示，否则显示基础数据版本号 at 2014-7-23
                    GCARINFO carinfo = {0};
                    [[MWMapOperator sharedInstance] GMD_GetCarInfo:&carinfo];
                    NSString *mapVersion = [MWEngineTools GetMapCityVersion:[MWAdminCode GetAdminCode:carinfo.Coord]];
                    if ([mapVersion length] == 0)
                    {
                        mapVersion = [MWEngineTools GetMapVersion];
                    }
                    cell.textLabel.text = [NSString stringWithFormat:STR(@"Setting_DataVersion",Localize_Setting),mapVersion];
                    //add by gzm for 显示数据版本号时，若存在城市数据版本号则显示，否则显示基础数据版本号 at 2014-7-23
                }
					
					break;
                    
                    
                default:
                    break;
            }
            cell.accessoryView= nil;
        }
            break;
        case 2:
        {
            
            cell.textLabel.text = [MWEngineTools GetReadDataCheckNumber];
            cell.textLabel.numberOfLines = 0;
            cell.accessoryView=nil;
        }
            break;
            
        case 3:
        {
            cell.textLabel.textAlignment=UITextAlignmentLeft;
            cell.textLabel.backgroundColor=[UIColor clearColor];
            NSString *string;
            CGSize size;
            switch (indexPath.row)
            {
                    
                case 0:
                {

                    cell.textLabel.text=STR(@"Setting_webSite",Localize_Setting);
                    string=@"anav.com";
                    UIImageView *tempimg = [[UIImageView alloc] initWithImage:IMAGE(@"Accessory.png",IMAGEPATH_TYPE_1)];
                    cell.accessoryView = tempimg;
                    [tempimg release];

                }
                    break;
                    
                case 1:
                {
                    
                    cell.textLabel.text=STR(@"Setting_GDweibo",Localize_Setting);
                    string=@"weibo.com/autonavigation";
                    UIImageView *tempimg = [[UIImageView alloc] initWithImage:IMAGE(@"Accessory.png",IMAGEPATH_TYPE_1)];
                    cell.accessoryView = tempimg;
                    [tempimg release];
                }
                    break;
                case 2:
                {
                    string=@"autonavi_navigation";
                    cell.textLabel.text=STR(@"Setting_GDweChat",Localize_Setting);
                     cell.accessoryView = nil;
                }
                    break;
                case 3:
                {
                    string=@"bbs.amap.com";
                    cell.textLabel.text=STR(@"Setting_OfficialCommunity",Localize_Setting);
                    UIImageView *tempimg = [[UIImageView alloc] initWithImage:IMAGE(@"Accessory.png",IMAGEPATH_TYPE_1)];
                    cell.accessoryView = tempimg;
                    [tempimg release];
            
                }
                    break;
                case 4:
                {
                    string=@"138035491、75400172";
                    cell.textLabel.text=STR(@"Setting_GDQQqun",Localize_Setting);
                    cell.accessoryView = nil;
                }
                    break;
                case 5:
                {
                    string=@"400-810-0080";
                    cell.textLabel.text=STR(@"Setting_ServicePhone",Localize_Setting);
                    UIImageView *tempimg = [[UIImageView alloc] initWithImage:IMAGE(@"Accessory.png",IMAGEPATH_TYPE_1)];
                    cell.accessoryView = tempimg;
                    [tempimg release];
                    
                }
                    break;
                case 6:
                {
                    string= AutoNaviEmail;
                    cell.textLabel.text= STR(@"Setting_GDEmail",Localize_Setting);
                    
                     Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
                    if(!(!mailClass || ![mailClass canSendMail]))
                    {
                        UIImageView *tempimg = [[UIImageView alloc] initWithImage:IMAGE(@"Accessory.png",IMAGEPATH_TYPE_1)];
                        cell.accessoryView = tempimg;
                        [tempimg release];
                    }
                    else
                    {
                        cell.accessoryView = nil;
                    }
                    
                }
                    break;
                default:
                {
                }
                    break;

            }
            size=[cell.textLabel.text sizeWithFont:cell.textLabel.font];

            cell.detailTextLabel.text=string;
            cell.detailTextLabel.textColor=GETSKINCOLOR(@"AboutNaviInfoColor");
            
        }
            break;
        case 4:
            {
                GDSwitchCell *myCell=(GDSwitchCell*)cell;
                [myCell.onswitch setOn:[[MWPreference sharedInstance] getValue:PREF_STARTUPWARNING] animated:NO];
                myCell.textLabel.text=STR(@"Setting_LegalNotices",Localize_Setting);
                
            }
            break;
            
        
            break;
        default:
            break;
    }
    if (indexPath.section == 0 ||indexPath.section==4 )
    {
        cell.backgroundType=BACKGROUND_GROUP;
    }
    else if ((indexPath.section == 1 && indexPath.row == 2)||(indexPath.section==3 &&indexPath.row==3)||(indexPath.section==2 &&indexPath.row==0))
    {
        cell.backgroundType=BACKGROUND_FOOTER;
    }
	else if((indexPath.section == 1 && indexPath.row == 0))
    {
        cell.backgroundType=BACKGROUND_MIDDLE;
	}
    else if(indexPath.row==0 &&indexPath.section!=1)
    {
        cell.backgroundType=BACKGROUND_HEAD;
    }
    else
    {
        cell.backgroundType=BACKGROUND_MIDDLE;
    }
	
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
	return cell;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    UIView *headView=nil;
	if(section == 1)
	{
        NSString *str=STR(@"Setting_SoftwareVersion",Localize_Setting);
		headView=[[[POITableHeadView alloc] initWithTitle:str] autorelease];
        [(POITableHeadView*)headView downMove];
	}
	else if(section == 2){
        NSString *str=STR(@"Setting_MapCopyright",Localize_Setting);
		headView=[[[POITableHeadView alloc] initWithTitle:str] autorelease];
       [(POITableHeadView*)headView downMove];
	}
	else
    {
        headView=[[[UIView alloc] init] autorelease];
        [headView setBackgroundColor:[UIColor clearColor]];
    }
	return headView;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    //    CGFloat height = 40.0;
    if (section==0) {
        return 0;
    }
        return section>2?15:40+CCTABLE_VIEW_SPACE_HEIGHT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	
	if(indexPath.section == 2)
	{
        int lang=[[MWPreference sharedInstance] getValue:PREF_UILANGUAGE];
        if (lang==2) {
            if (Interface_Flag==0&&!isPad) {
                return 130+26;
            }
        }
		return 130.0;
	}
    else if(indexPath.section==3)
        return kHeight5;
	else{
	    return kHeight2;
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (indexPath.section==0) {
        //版本更新
        isCheck=YES;
        [self showLoadingViewInView:STR(@"Setting_CheckingUpdate", Localize_Setting) view:self.view];

        [[GDBL_LaunchRequest sharedInstance] Net_SoftWareVersionUpdateRequest:self withRequestType:RT_LaunchRequest_HandSoftWareUpdate];
        
    }
    else if(indexPath.section==3)
    {
        switch (indexPath.row) {
                case 0:
            {
                UINavigationController *navi = [PluginFactory allocNavigationController];
                SettingSinaWeiboViewController *sinaWeibo=[[SettingSinaWeiboViewController alloc] init];
                sinaWeibo.webUrl=@"http://anav.com";
                sinaWeibo.title=STR(@"Setting_webSite",Localize_Setting);
                [navi setViewControllers:@[sinaWeibo]];
                [self presentModalViewController:navi animated:YES];
                [sinaWeibo release];

            }
                break;
            case 1:
            {
                //
                   UINavigationController *navi = [PluginFactory allocNavigationController];
                SettingSinaWeiboViewController *sinaWeibo=[[SettingSinaWeiboViewController alloc] init];
                sinaWeibo.webUrl=@"http://weibo.com/autonavigation";
                sinaWeibo.title=STR(@"Setting_GDweibo",Localize_Setting);
                 [navi setViewControllers:@[sinaWeibo]];
                [self presentModalViewController:navi animated:YES];
                [sinaWeibo release];
            }
                break;
            case 3:
            {

                UINavigationController *navi = [PluginFactory allocNavigationController];
                SettingSinaWeiboViewController *sinaWeibo=[[SettingSinaWeiboViewController alloc] init];
                sinaWeibo.webUrl=@"http://bbs.amap.com";
                sinaWeibo.title=STR(@"Setting_OfficialCommunity",Localize_Setting);
                [navi setViewControllers:@[sinaWeibo]];
                [self presentModalViewController:navi animated:YES];
                [sinaWeibo release];
            }
                break;
            case 5:
            {
                NSString *phoneNumber = @"400-810-0080";
                GDAlertView *alertView=[[[GDAlertView alloc] initWithTitle:nil andMessage:[NSString stringWithFormat:@"%@",phoneNumber ]] autorelease];
                [alertView addButtonWithTitle:STR(@"Setting_AlertBack", Localize_Setting)
                                         type:GDAlertViewButtonTypeCancel
                                      handler:nil];
                [alertView addButtonWithTitle:STR(@"Setting_AlertSure", Localize_Setting)
                                         type:GDAlertViewButtonTypeCancel
                                      handler:^(GDAlertView *alertView)
                {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",phoneNumber ]]];
                }];

                [alertView show];
                
            }
                break;
            case 6:
            {
                [self launchMailApp];
            }
                break;
            default:
                break;
        }
    }
}

-(void)launchMailApp
{
    
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    if (!mailClass)
    {
        
        NSMutableString *mailUrl = [[[NSMutableString alloc]init]autorelease];
        //添加收件人
        NSArray *toRecipients = [NSArray arrayWithObject: AutoNaviEmail];
        [mailUrl appendFormat:@"mailto:%@", [toRecipients componentsJoinedByString:@","]];
        
        //添加主题
        NSString *mailSubject = STR(@"Setting_UserFeedback", Localize_Setting);
        [mailUrl appendString:[NSString stringWithFormat:@"?subject=%@",mailSubject]];
        //添加邮件内容
        [mailUrl appendString:@"&body="];
        NSString* email = [mailUrl stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
        [[UIApplication sharedApplication] openURL: [NSURL URLWithString:email]];

        
        return;
    }
    if (![mailClass canSendMail]) {
//        UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"发送邮件"
//                                                         message:@"用户没有设置邮件账户"
//                                                        delegate:self
//                                               cancelButtonTitle:@"我知道啦"
//                                               otherButtonTitles: nil] autorelease];
//        [alert show];
        return;
    }
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    
    if(mc)
    {
        mc.mailComposeDelegate = self;
        [mc setSubject:STR(@"Setting_UserFeedback", Localize_Setting)];
        [mc setToRecipients:[NSArray arrayWithObject:AutoNaviEmail]];
        //    [mc setCcRecipients:[NSArray arrayWithObject:@"xxxxx@163.com"]];
        //    [mc setBccRecipients:[NSArray arrayWithObject:@"secret@gmail.com"]];
        [mc setMessageBody:@"" isHTML:NO];

        [self presentViewController:mc animated:YES completion:nil];
        [mc release];
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail send canceled...");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved...");
            break;
        case MFMailComposeResultSent:
        {
            GDAlertView *alertView=[[[GDAlertView alloc] initWithTitle:nil
                                                            andMessage:STR(@"Account_SuccessSendVerification", Localize_Account)] autorelease];
            [alertView addButtonWithTitle:STR(@"Setting_AlertBack", Localize_Setting)
                                     type:GDAlertViewButtonTypeCancel
                                  handler:nil];
            [alertView show];
        }
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail send errored: %@...", [error localizedDescription]);
            break;
        default:
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark UIAlertDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{

}
#pragma mark -
#pragma mark NetReqToViewCtrDelegate

- (void)requestToViewCtrWithRequestType:(RequestType)requestType didFinishLoadingWithResult:
(id)result//id类型可以是NSDictionary NSArray
{
    isCheck=NO;
    [self hideLoadingViewWithAnimated:YES];
    if (result==nil) {
        return;
    }
    
    
    if (requestType==RT_LaunchRequest_HandSoftWareUpdate) {
        
        NSString *tmp = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
        NSLog(@"软件升级：%@",tmp);
        [tmp release];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            
            NSDictionary *softWareDic = [NSDictionary dictionaryWithXMLData:result];
            
            NSDictionary *responseDic = [softWareDic objectForKey:@"response"];
            
            if (responseDic && [[responseDic objectForKey:@"rspcode"] isEqualToString:@"0000"]) {
                
                NSDictionary *infoDic = [responseDic objectForKey:@"info"];
                
                if (infoDic && ([[infoDic objectForKey:@"update"] intValue] == 1) ) { //有新版本
                    
                    NSString *descString = [infoDic objectForKey:@"desc"];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        GDAlertView *alertView = [[GDAlertView alloc] initWithTitle:STR(@"Setting_NewVersion",Localize_Setting) andMessage:descString];
                        [alertView addButtonWithTitle:STR(@"Setting_UpdateCancel",Localize_Setting) type:GDAlertViewButtonTypeCancel handler:nil];
                        
                        [alertView addButtonWithTitle:STR(@"Setting_UpdateSure",Localize_Setting) type:GDAlertViewButtonTypeDefault handler:^(GDAlertView *alertView){
                            [ANOperateMethod rateToAppStore:0];
                            
                        }];
                        [alertView show];
                        [alertView release];
                    });
                    
                }
                else if (infoDic && ([[infoDic objectForKey:@"update"] intValue] == 0))//是最新版本
                {
                    GDAlertView *alertView = [[GDAlertView alloc] initWithTitle:nil andMessage:STR(@"Setting_NewestVersion",Localize_Setting)];
                    [alertView show];
                    [alertView release];
                }
            }
            
        });
      
    }
    
}
- (void)requestToViewCtrWithRequestType:(RequestType)requestType didFailWithError:(NSError *)error//上层需根据error的值来判断网络连接超时还是网络连接错误
{
    isCheck=NO;
    [self hideLoadingViewWithAnimated:YES];
    NSString *string=@"";
    if ([error.domain isEqualToString:KNetResponseErrorDomain])
    {
        //        服务器返回内容异常，HTTP error" 其中HTTP error后面要跟error的成员变量code
        
        string=[NSString stringWithFormat:STR(@"Universal_httpError",Localize_Universal),error.code];
        
    }
    else
    {
        if (error.code==NSURLErrorTimedOut) {
            
            string=STR(@"Universal_networkTimeout",Localize_Universal);
        }
        else
        {
            string=STR(@"Universal_networkError",Localize_Universal);
        }
        
    }
    GDAlertView *alertView=[[[GDAlertView alloc] initWithTitle:nil andMessage:string] autorelease];
    [alertView show];

}


@end

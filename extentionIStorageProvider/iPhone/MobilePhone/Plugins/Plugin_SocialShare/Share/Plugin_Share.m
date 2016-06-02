//
//  Plugin_Share.m
//  AutoNavi
//
//  Created by gaozhimin on 13-8-14.
//
//

#import "Plugin_Share.h"
#import "ShareSinaViewController.h"
#import "ShareTencentViewController.h"
#import "ShareMessageViewController.h"
#import "ShareMailViewController.h"
#import "WXApi.h"
#import "GDBL_SinaWeibo.h"
#import "GDBL_TCWeibo.h"
#import "GDAlertView.h"
//AppID： wxddf9197f5578cae3
//AppKey： 9ef46ebf3dc18304b03876f123484a32

#define WechatAppID @"wxddf9197f5578cae3"

@interface Plugin_Share()<ModuleDelegate,UIAlertViewDelegate,GDBL_SinaWeiboDelegate,GDBL_TCWeiboDelegate>

@property (nonatomic,assign) UIViewController *viewController;

@property (nonatomic,retain) NSDictionary *paramDic;

@end

@implementation Plugin_Share

@synthesize paramDic;

/**
 *	推送点击按钮进入消息盒子
 *
 *	@param	navigationController	视图控制器
 */
+ (void)enterBoxWith:(UINavigationController *)navigationController
{
//    ShareBoxViewController *interface = [[ShareBoxViewController alloc] init];
//    NSArray *array = [NSArray arrayWithObjects:[navigationController.viewControllers objectAtIndex:0], interface,nil];
//    [navigationController setViewControllers:array animated:NO];
//    [interface release];
}

- (void)dealloc
{
    self.paramDic = nil;
    [super dealloc];
}

/*!
  @brief 相应模块调用该方法进入该模块
  @param param: NSDictionary 包含  
    字典关键字         值说明            类型                 
   viewController   加载视图的控制器   UIViewController
   shareType        进入视图的类型     Share_Type          
   image           加载的图片         UIImage
   content          加载的内容         NSString          
   scene          微享分享场景          int           0：表示分享给好友  1：分享到朋友圈
   URL            微信分享的URL
   Title          标题                NSString
  @return 0失败;1成功
  */
-(int) enter:(NSObject *)param
{
    if ([param isKindOfClass:[NSDictionary class]])
    {
        NSDictionary * values=(NSDictionary*)param;
        self.paramDic =(NSDictionary *) param;
        if ([values count] > 1 && [[values objectForKey:@"viewController"] isKindOfClass:[UIViewController class]])
        {
            UIImage *image = nil;
            NSString *content = @"";
            int scene = 0;
            NSString * Title = @"";
            NSString * StringUrl   = @"";
            UIViewController *viewController = (UIViewController*)[values objectForKey:@"viewController"];
            self.viewController = viewController;
            UINavigationController * navigation = viewController.navigationController;
            Share_Type shareType=nil;
            if ([values objectForKey:@"shareType"]) {//样式
               shareType = [[values objectForKey:@"shareType"] intValue];
            }
            if ([values objectForKey:@"image"]) {//图片
                NSLog(@"%@",image);
                image = [values objectForKey:@"image"];
            }
            if ([values objectForKey:@"content"]) {//内容
                content = [values objectForKey:@"content"];
            }
            if ([values objectForKey:@"scene"]) {//朋友 还是朋友圈
                 scene = [[values objectForKey:@"scene"] intValue];
            }
            if ([values objectForKey:@"Title"]) {
                Title = [values objectForKey:@"Title"];
            }//标题
            if ([values objectForKey:@"URL"]) {
                StringUrl = [values objectForKey:@"URL"];
            }
            if (shareType == Share_Sina)
            {
                if (![self checkSinaAuthValid])
                {
                    return 0;
                }
                ShareSinaViewController *ctl = [[ShareSinaViewController alloc] initWithPicture:image];
                ctl.share_content = content;
                UIViewController *sinaViewControlelr=nil;
                if (isPad) {
                    UINavigationController * navi=[[[UINavigationController alloc] initWithRootViewController:ctl] autorelease];
                    navi.navigationBarHidden=YES;
                    sinaViewControlelr=navi;
                }else
                {
                    sinaViewControlelr=ctl;
                }
                [viewController presentModalViewController:sinaViewControlelr animated:YES];

                [ctl release];
                return  YES;
            }
            else if (shareType == Share_Tencent)
            {
                if (![self checkTCAuthValid])
                {
                    return 0;
                }
                
                ShareTencentViewController *ctl = [[ShareTencentViewController alloc] initWithPicture:image];
                ctl.share_content = content;
                [navigation pushViewController:ctl animated:YES];
                [ctl release];
                return YES;
            }
            else if (shareType == Share_Mail)
            {
                ShareMailViewController *ctl = [[ShareMailViewController alloc] init];
                if (ctl)
                {
                    [ctl setMessageBody:content isHTML:NO];
                    [ctl setSubject:STR(@"Share_WeShare", Localize_POIShare)];
                    [ctl addAttachmentData:UIImagePNGRepresentation(image) mimeType:@"image/png" fileName:[NSString stringWithFormat:@"%@.png",STR(@"Share_WeShare", Localize_POIShare)]];
                    [viewController presentModalViewController:ctl animated:YES];
                    [ctl release];
                    return YES;
                }
            }
            else if (shareType == Share_Message)
            {
                ShareMessageViewController *ctl = [[ShareMessageViewController alloc] init];
                BOOL canSendSMS = [MFMessageComposeViewController canSendText];
                if (canSendSMS && ctl != nil)
                {
                    ctl.body = content;
                    [viewController presentModalViewController:ctl animated:YES];
                }
                [ctl release];
                return YES;
            }
            else if (shareType == Share_Box)
            {

            }
            else if (shareType == Share_WeChat)
            {
                [WXApi registerApp:WechatAppID];
                if (![WXApi isWXAppInstalled])
                {
                    [self ShowAlertWiWithTitle:nil message:STR(@"Share_CheckWechat", Localize_POIShare) cancelButtonTitle:STR(@"Universal_cancel", Localize_Universal) otherButtonTitles:STR(@"Universal_ok", Localize_Universal) tag:0];
                    return 0;
                }
                WXMediaMessage * message = [WXMediaMessage message];
                message.title = Title;
                message.description = content;
                [message setThumbImage:[UIImage imageNamed:@"POIShareImage.png"]];
                WXWebpageObject * ext = [WXWebpageObject object];
                ext.webpageUrl = StringUrl;
                message.mediaObject = ext;
                SendMessageToWXReq* req = [[[SendMessageToWXReq alloc] init]autorelease];
                req.bText = NO;
                req.message = message;
                req.scene = scene;
                
                BOOL sign = [WXApi sendReq:req];
                
                return sign;

            }
            //里程分享
            else if (shareType == Share_mileage_Message)
            {
                ShareMessageViewController * ctl = [[ShareMessageViewController alloc] init];
                BOOL canSendSMS = [MFMessageComposeViewController canSendText];
                if (canSendSMS && ctl != nil)
                {
                    ctl.body = content; // 内容
                    [viewController presentModalViewController:ctl animated:YES];
                }
                [ctl release];
                return YES;

            }
            else if (shareType == Share_mileage_Friend || shareType == Share_mileage_WeChat)
            {
                [WXApi registerApp:WechatAppID];
                if (![WXApi isWXAppInstalled])
                {
                    [self ShowAlertWiWithTitle:nil message:STR(@"Share_CheckWechat", Localize_POIShare) cancelButtonTitle:STR(@"Universal_cancel", Localize_Universal) otherButtonTitles:STR(@"Universal_ok", Localize_Universal) tag:0];
                    return 0;
                }
                WXMediaMessage * message = [WXMediaMessage message];
                message.title = Title;
                message.description = content;
                [message setThumbImage:[UIImage imageNamed:@"POIShareImage.png"]];
                WXWebpageObject *ext = [WXWebpageObject object];
                ext.webpageUrl = StringUrl;
                message.mediaObject = ext;
                SendMessageToWXReq* req = [[[SendMessageToWXReq alloc] init]autorelease];
                req.bText = NO;
                req.message = message;
                req.scene = scene;
                
                BOOL sign = [WXApi sendReq:req];
                
                return sign;
            }
            else if (shareType == Share_mileage_SinaWeiBo)
            {
                if (![self checkSinaAuthValid])
                {
                    return 0;
                }
                ShareSinaViewController *ctl = [[ShareSinaViewController alloc] initWithPicture:image];
               ctl.share_content = content;
                UIViewController *sinaViewControlelr=nil;
                if (isPad) {
                    UINavigationController * navi=[[[UINavigationController alloc] initWithRootViewController:ctl] autorelease];
                    navi.navigationBarHidden=YES;
                    sinaViewControlelr=navi;
                }else
                {
                    sinaViewControlelr=ctl;
                }
                [viewController presentModalViewController:sinaViewControlelr animated:YES];
                [ctl release];
                return  YES;
            }
            
        }
    }
    return NO;
    
}



// 导航模块调用该方法离开子模块（一般情况下，子模块是调用backToNavi回到导航主模块）
// 返回值：0失败；1成功
-(int) leave
{
    return 0;
}

// 导航模块调用该方法终止子模块（在导航模块因某种原因而需要退出程序，而此时子模块可能还处于执行中，此时导航模块将调用该方法）
// 返回值：0失败；1成功
-(int) exit
{
    return 0;
}

#pragma mark -  private method

-(BOOL)checkTCAuthValid
{
    GDBL_TCWeibo *tcWeibo=[GDBL_TCWeibo shareTCWeibo];//腾讯微博初始化
	if (![tcWeibo isAuthValid])
    {
		[self ShowAlertWiWithTitle:nil message:STR(@"Share_CheckTC", Localize_POIShare) cancelButtonTitle:STR(@"Universal_cancel", Localize_Universal) otherButtonTitles:STR(@"Universal_ok", Localize_Universal) tag:1];
        return NO;
    }
    return YES;
}

-(BOOL)checkSinaAuthValid
{
    GDBL_SinaWeibo *sinaWeibo=[GDBL_SinaWeibo shareSinaWeibo];//新浪微博初始化
    sinaWeibo.delegate = self;
	if (!sinaWeibo.sinaweibo.isAuthValid)
	{
        [self ShowAlertWiWithTitle:nil message:STR(@"Share_CheckSina", Localize_POIShare) cancelButtonTitle:STR(@"Universal_cancel", Localize_Universal) otherButtonTitles:STR(@"Universal_ok", Localize_Universal) tag:2];
        return NO;
    }
    return YES;
}

- (void)ShowAlertWiWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancel otherButtonTitles:(NSString *)other tag:(int)tag
{
    [self retain];

    __block Plugin_Share *weakself = self;
    GDAlertView *Myalert_ext = [[GDAlertView alloc] initWithTitle:nil andMessage:message];
    if (cancel)
    {
        [Myalert_ext addButtonWithTitle:cancel type:GDAlertViewButtonTypeCancel handler:nil];
    }
    if (other)
    {
        [Myalert_ext addButtonWithTitle:other type:GDAlertViewButtonTypeDefault handler:^(GDAlertView *alertView)
         {
             [weakself alertView:(UIAlertView *)alertView clickedButtonAtIndex:1];
         }];
    }
    Myalert_ext.tag = tag;
    [Myalert_ext show];
    [Myalert_ext release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag)
    {
        case 0:
        {
            switch (buttonIndex)
            {
                case 0:
                    
                    break;
                case 1:
                {
                    NSString *instalUrl = [WXApi getWXAppInstallUrl];
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:instalUrl]];
                }
                    break;
                default:
                    break;
            }
            break;
        }
        case 1:
        {
            switch (buttonIndex)
            {
                case 0:
                    
                    break;
                case 1:
                {
                    [self retain];
                    GDBL_TCWeibo *tcWeibo=[GDBL_TCWeibo shareTCWeibo];//腾讯微博初始化
                    tcWeibo.delegate = self;
                    [tcWeibo setController:self.viewController];
                    [tcWeibo logIn:self.viewController];
                }
                    break;
                default:
                    break;
            }
            break;
        }
        case 2:
        {
            switch (buttonIndex)
            {
                case 0:
                    
                    break;
                case 1:
                {
                    [self retain];
                    GDBL_SinaWeibo *sinaWeibo=[GDBL_SinaWeibo shareSinaWeibo];//新浪微博初始化
                    sinaWeibo.delegate = self;
                    double delayInSeconds = 0.5;
                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                    {
                        [sinaWeibo logIn:self.viewController.navigationController];
                    });
                }
                    break;
                default:
                    break;
            }
            break;
        }
            
        default:
            break;
    }
    [self release];
}

#pragma mark - SinaWeibo Delegate

- (void)sinaweiboDidLogIn:(SinaWeibo *)sinaweibo
{
    GDBL_SinaWeibo *sinaWeibo=[GDBL_SinaWeibo shareSinaWeibo];
    [sinaWeibo storeAuthData];
    [self enter:self.paramDic];
//    [self ShowAlertWiWithTitle:nil message:STR(@"Share_LoginSuccess", Localize_POIShare) cancelButtonTitle:STR(@"Universal_ok", Localize_Universal) otherButtonTitles:nil tag:-1];
    [self release];
}

- (void)sinaweiboLogInDidCancel:(SinaWeibo *)sinaweibo
{
    [self release];
}

- (void)sinaweibo:(SinaWeibo *)sinaweibo logInDidFailWithError:(NSError *)error
{
    [self ShowAlertWiWithTitle:nil message:STR(@"Share_LoginFail", Localize_POIShare) cancelButtonTitle:STR(@"Universal_ok", Localize_Universal) otherButtonTitles:nil tag:-1];
    [self release];
}

#pragma mark - TC delegate

- (void)TCWeiboDidLogIn:(WeiboApi *)TCweibo
{
    [self enter:self.paramDic];
//    [self ShowAlertWiWithTitle:nil message:STR(@"Share_LoginSuccess", Localize_POIShare) cancelButtonTitle:STR(@"Universal_ok", Localize_Universal) otherButtonTitles:nil tag:-1];
    [self release];
}

- (void)TCWeiboLogInDidCancel:(WeiboApi *)TCweibo
{
    [self release];
}

- (void)TCWeibo:(WeiboApi *)TCweibo logInDidFailWithError:(NSError *)error
{
    [self ShowAlertWiWithTitle:nil message:STR(@"Share_LoginFail", Localize_POIShare) cancelButtonTitle:STR(@"Universal_ok", Localize_Universal) otherButtonTitles:nil tag:-1];
    [self release];
}
@end

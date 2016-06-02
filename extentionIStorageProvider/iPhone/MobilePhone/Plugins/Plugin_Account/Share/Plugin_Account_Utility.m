//
//  Plugin_Account_Utility.m
//  Plugin_Account
//
//  Created by yang yi on 11-12-21.
//  Copyright 2011 autonavi.com. All rights reserved.
//

#import "Plugin_Account_Utility.h"
#import "Plugin_Account_Globall.h"
#import "AccountXmlParser.h"
#import "ANParamValue.h"
#import <CommonCrypto/CommonDigest.h>
#import "GDAlertView.h"

Class object_getClass(id object);

static Plugin_Account_Utility *instance =nil;


@implementation Plugin_Account_Utility


- (id)init
{
    self = [super init];
    if (self) 
	{
        // Initialization code here.
    }
    
    return self;
}
+(Plugin_Account_Utility*) shareInstance
{
	if (instance == nil) {
		instance =[[Plugin_Account_Utility alloc] init];
	}
	return instance;
}

#pragma mark UI
/**
 * 设置界面上下移动效果,移动量根据各view计算得出(亦可扩展任意大小值),viewToSlide需非主view,若需移动主view待扩展 
 */
-(void)slideView:(UIView *)viewToSlide
{
	if (moveHeight<0) {
		moveHeight =0;
	}
	[UIView beginAnimations: @"flipping" context: nil];
	[UIView setAnimationBeginsFromCurrentState: YES];
	[UIView setAnimationDuration: 0.3];
	
	viewToSlide.frame =CGRectOffset(viewToSlide.superview.frame, 0, -moveHeight);
	

	[UIView commitAnimations];
}

/**
 *计算UITableView中某个UITableViewCell所在高度(包含当前row)
 *参数:row 所在的行号,section: 所在分段 table 所属的UITableView
 */
-(int)calcHeightOfTableCell:(int)row Section:(int) section TableObject:(UITableView*) table
{
	int h =table.frame.origin.y;
	for (int i=0; i<row; i++) {
		NSIndexPath *tableIndex=[NSIndexPath indexPathForRow:i inSection:section];
		UITableViewCell *cell =(UITableViewCell*)[table cellForRowAtIndexPath:tableIndex];
		h+=cell.bounds.size.height;
	}
	return h;
}

/**
 *按运行设备类型设置UI模式
 *涉及到UITextField,UILabel样式及字体大小等,
 *扩展:iphone,ipad界面统一设计
 */
-(void) setUiTypeOfDevice:(int)type
{
	g_UI_Type = type;
	g_Font_Size =type==1?18:25;
}
/**
 *敬告框模块(单按钮)
 *参数说明:
 *tipText: 敬告提示内容,btnContent:按钮名,target:Delegate来源,tags:可按事件定义扩展类型值
 */
-(void) UIAlertFormWithTip:(NSString *)tipText BtnText:(NSString*)btnContent Delegate:(id)target Tag:(int) tags
{
    __block id weakDelegate = target;
    GDAlertView *alert = [[GDAlertView alloc] initWithTitle:nil andMessage:tipText];
    if (btnContent)
    {
        [alert addButtonWithTitle:btnContent type:GDAlertViewButtonTypeDefault handler:^(GDAlertView *alertView)
         {
             if (weakDelegate && [weakDelegate respondsToSelector:@selector(alertView:clickedButtonAtIndex:)])
             {
                 [weakDelegate alertView:(UIAlertView *)alertView clickedButtonAtIndex:0];
             }
         }];
    }
    [alert show];
    [alert release];
}

-(void) UIAlertFormWithErrorType:(NSString *)ErrorType Delegate:(id)target Tag:(int) tags
{
    NSString *tipText = @"";
    NSString *btnContent = @"";
    NSString *cancel_btnContent = nil;
    tipText = [NSString stringWithFormat:STR(@"Account_OperatorError", Localize_Account),ErrorType];
    btnContent = STR(@"Universal_ok", Localize_Universal);
    
    if ([ErrorType isEqual:ERROR_PHONE_BOUND])
    {
        tipText =STR(@"Account_PhoneNumberBinded", Localize_Account);
    }
    else if ([ErrorType isEqual:NET_CON_FAILE])
    {
        tipText =STR(@"Account_NetError", Localize_Account);
    }
    else if ([ErrorType isEqual:NET_CON_TIMEOUT])
    {
        tipText =STR(@"Account_NetTimeout", Localize_Account);
    }
    else if ([ErrorType isEqual:ERROR_LICENSE_CHECK])
    {
        tipText =STR(@"Account_InputVerificationError", Localize_Account);
    }
    else if ([ErrorType isEqual:ERROR_False_Authenticate])
    {
        tipText =STR(@"Account_ReloginGDAccount", Localize_Account);
    }
    else if ([ErrorType isEqual:ERROR_PHONE_USED])
    {
        tipText =STR(@"Account_PhoneBindByOther", Localize_Account);
    }
    else if ([ErrorType isEqual:ERROR_SMS_FAIL])
    {
        tipText =STR(@"Account_MessageSendFail", Localize_Account);
    }
    else if ([ErrorType isEqual:ERROR_OVER_TIMES])
    {
        tipText =STR(@"Account_PhoneModifyLimit", Localize_Account);
    }
    else if ([ErrorType isEqual:ERROR_NOORDER_INFO])
    {
        tipText =STR(@"Account_NoUserInfo", Localize_Account);
    }
    else if ([ErrorType isEqual:ERROR_NODEST_INFO])
    {
        tipText =STR(@"Account_NoDes", Localize_Account);
    }
    else if ([ErrorType isEqual:ERROR_NOCURDEST_INFO])
    {
        tipText =STR(@"Account_CurNoDes", Localize_Account);
    }
    else if ([ErrorType isEqual:ERROR_NOT_BOUND])
    {
        tipText =STR(@"Account_PhoneNeedCheck", Localize_Account);
        cancel_btnContent = STR(@"Universal_cancel", Localize_Universal);
    }
    
    __block id weakDelegate = target;
    GDAlertView *alert = [[GDAlertView alloc] initWithTitle:nil andMessage:tipText];
    Class origin = object_getClass(weakDelegate);
    if (cancel_btnContent)
    {
        [alert addButtonWithTitle:cancel_btnContent type:GDAlertViewButtonTypeDefault handler:^(GDAlertView *alertView)
         {
             if (object_getClass(weakDelegate) == origin)
             {
                 if (weakDelegate && [weakDelegate respondsToSelector:@selector(alertView:clickedButtonAtIndex:)])
                 {
                     [weakDelegate alertView:(UIAlertView *)alertView clickedButtonAtIndex:0];
                 }
             }
             
         }];
    }
    if (btnContent)
    {
        [alert addButtonWithTitle:btnContent type:GDAlertViewButtonTypeDefault handler:^(GDAlertView *alertView)
         {
             if (object_getClass(weakDelegate) == origin)
             {
                 if (weakDelegate && [weakDelegate respondsToSelector:@selector(alertView:clickedButtonAtIndex:)])
                 {
                     [weakDelegate alertView:(UIAlertView *)alertView clickedButtonAtIndex:1];
                 }
             }
         }];
    }
	[alert show];
    alert.tag =tags;
	[alert release];
}

/**
 *UIButton
 */
-(void)setButtonStyle:(UIButton*)button
{
	[button setTitleColor:GETSKINCOLOR(ACCOUNT_BUTTON_TITLE_COLOR) forState:(UIControlState)UIControlStateNormal];
	button.titleLabel.font = [UIFont fontWithName:[[UIFont familyNames] objectAtIndex:3] size:g_Font_Size];
	
	UIImage *buttonImageNormal1 = IMAGE(@"button_back2_1.png", IMAGEPATH_TYPE_1);
    UIImage *stretchableButtonImageNormal = [buttonImageNormal1 stretchableImageWithLeftCapWidth:12 topCapHeight:0];
	UIImage *buttonImagePressed = IMAGE(@"button_back2_2.png", IMAGEPATH_TYPE_1) ;
    UIImage *stretchableButtonImagePressed = [buttonImagePressed stretchableImageWithLeftCapWidth:12 topCapHeight:0];
    [button setBackgroundImage:stretchableButtonImageNormal forState:UIControlStateNormal];
    [button setBackgroundImage:stretchableButtonImagePressed forState:(UIControlState)UIControlStateHighlighted];
}

/**
 *创建label
 */
-(UILabel *)UILabelCreate
{
	UILabel *label;
	if (1==g_UI_Type)  //ui iphone
	{
		if (1 == g_NaviStatus_Interface_Flag)
		{
			label = [[[UILabel alloc] initWithFrame:CGRectMake(100.0f, 7.0f, 280.0f, 30.0f)] autorelease];
		}else if(0 == g_NaviStatus_Interface_Flag)
		{		
			label = [[[UILabel alloc] initWithFrame:CGRectMake(95.0f, 7.0f, 200.0f, 30.0f)] autorelease];	
		}
		
	}else//ui ipad
	{
//		if (1 == g_NaviStatus_Interface_Flag)
//		{
			label = [[[UILabel alloc] initWithFrame:CGRectMake(130.0f, 7.0f, 580.0f, 50.0f)] autorelease];
//		}else if(0 == g_NaviStatus_Interface_Flag)
//		{		
//			label = [[[UILabel alloc] initWithFrame:CGRectMake(130.0f, 7.0f, 400.0f, 50.0f)] autorelease];	
//		}
		
	}
	
	label.textAlignment = UITextAlignmentLeft;
	label.backgroundColor = GETSKINCOLOR(HUD_CLEAR_BACKGROUND_COLOR);
	label.textColor = GETSKINCOLOR(ACCOUNT_BUTTON_TITLE_COLOR);
//	if (1==g_UI_Type) 
//	{ //ui iphone
//		label.font = [UIFont fontWithName:[[UIFont familyNames] objectAtIndex:7] size:18];
//	}else//ui ipad
//	{
//		label.font = [UIFont fontWithName:[[UIFont familyNames] objectAtIndex:7] size:25];
//	}
	label.font =[UIFont fontWithName:[[UIFont familyNames]objectAtIndex:7] size:g_Font_Size];
	return label;
}
/**
 *创建textfield,并设置target
 */
-(UITextField *)UITextFieldCreateByTarget:(id) target
{
	
	UITextField *textField;
	if (1==g_UI_Type) { //ui iphone
		if(1 == g_NaviStatus_Interface_Flag)
		{
			textField=[[[UITextField alloc] initWithFrame:CGRectMake(100.0f, 5.0f, 240.0f, 30.0f)] autorelease];
		}
		else if(0 == g_NaviStatus_Interface_Flag)
		{
			textField =[[[UITextField alloc] initWithFrame:CGRectMake(95.0f, 5.0f, 190, 30.0f)] autorelease];
		}
		
	}else//ui ipad
	{
//		if(1 == g_NaviStatus_Interface_Flag)
//		{
			textField=[[[UITextField alloc] initWithFrame:CGRectMake(130.0f, 5.0f, 360.0f, 50.0f)] autorelease];
//		}
//		else if(0 == g_NaviStatus_Interface_Flag)
//		{
//			textField =[[[UITextField alloc] initWithFrame:CGRectMake(130.0f, 5.0f, 340.0f, 50.0f)] autorelease];
//		}
		
	}
	textField.borderStyle = UITextBorderStyleNone;
	textField.textColor = GETSKINCOLOR(ACCOUNT_BUTTON_TITLE_COLOR);

//	if (1== g_UI_Type) //ui iphone
//	{
//		textField.font = [UIFont systemFontOfSize:17.0];
//
//	}else {//ui ipad
//		textField.font = [UIFont systemFontOfSize:25.0];
//
//	}
	textField.font = [UIFont fontWithName:[[UIFont familyNames]objectAtIndex:7] size:(g_Font_Size-2)];
	textField.backgroundColor = GETSKINCOLOR(HUD_CLEAR_BACKGROUND_COLOR);
	textField.autocorrectionType = UITextAutocorrectionTypeNo;
	textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;

	textField.keyboardType = UIKeyboardTypeDefault;
	textField.returnKeyType = UIReturnKeyDone;
	
	
	textField.clearButtonMode = UITextFieldViewModeWhileEditing;	// has a clear 'x' button to the right
	textField.delegate = target;
	return textField;
	
}
/**
 *判断邮箱字符串或密码是否为合法的格式
 */
-(BOOL)bCheckStrFormat:(NSString *)checkStr MatchStr:(NSString*) matchStr
{
	NSCharacterSet *allowedCharacters =[[NSCharacterSet characterSetWithCharactersInString:matchStr] invertedSet];
	NSRange foundRange =[checkStr rangeOfCharacterFromSet:allowedCharacters];
	if (foundRange.location !=NSNotFound) {
		return NO;
	}
	return YES;
}
/**
 *判断邮箱字符串是否为合法的email格式
 *主要判断'@'及是否以'.com'或'.cn'或'.net'结尾
 */
-(BOOL)bCheckEmail:(NSString *)mail
{
	if (([mail rangeOfString:@"@"].location>0)
		&&([mail rangeOfString:@"@"].length>0))
	{
		NSString *tmpStr=[mail substringFromIndex:[mail rangeOfString:@"@"].location+1];
		if (([tmpStr rangeOfString:@"@"].location>0)&&([tmpStr rangeOfString:@"@"].length>0)) {
			return NO;//multiple'@'
		}
		if (([tmpStr rangeOfString:@"."].location<1)&&([tmpStr rangeOfString:@"."].length>0)) {
			return NO;//str '@'-'.'len <1
		}
		if([mail hasSuffix:@".com"]||[mail hasSuffix:@".cn"]||[mail hasSuffix:@".net"])
		{
			if ([self bCheckStrFormat:mail MatchStr:MATCH_MAIL]==NO) {
				return NO;
			}
			return YES;
		}
		return NO;
	}else {
		return NO;
	}
}/**
 *判断手机号码是否为合法的格式,
 *主要判断长度为11
 */
-(BOOL)bCheckPhone:(NSString *)phone
{
	if ([phone length]==11) {
		return YES;
	}
	return NO;
}
/**
 *判断输入文本是否超过49位
 */
- (BOOL) bCheckTextLong:(NSString *)textField
{
	NSLog(@"%@", textField);
	if ([textField length] > 0) {
		if (strlen( NSSTRING_TO_CSTRING(textField) ) > 49)
		{
			UIAlertView *Myalert_ext;
			if (ACC_GETLANGUAGE == LANGUAGE_ZH) {
				Myalert_ext = [[UIAlertView alloc] initWithTitle: @"已超过规定的长度"
														 message:nil 
														delegate:self 
											   cancelButtonTitle:nil 
											   otherButtonTitles:@"返回",nil];
			} else if (ACC_GETLANGUAGE == LANGUAGE_HK) {
				Myalert_ext = [[UIAlertView alloc] initWithTitle: @"已超過規定的長度"
														 message:nil 
														delegate:self 
											   cancelButtonTitle:nil 
											   otherButtonTitles:@"返回",nil];	
			} else {
				Myalert_ext = [[UIAlertView alloc] initWithTitle: @"Exceed the specified length."
														 message:nil 
														delegate:self 
											   cancelButtonTitle:nil 
											   otherButtonTitles:@"Back",nil];	
			}
			
			[Myalert_ext show]; 
			[Myalert_ext release];
			return YES;
		}
	}
	
	return NO;
}

-(NSString*)splitSpaceChar:(NSString*)originStr
{
	return [originStr stringByReplacingOccurrencesOfString:@" " withString:@""];

}



@end

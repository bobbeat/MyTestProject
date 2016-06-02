//
//  Plugin_Account.m
//  AutoNavi
//
//  Created by gaozhimin on 13-5-10.
//
//

#import "Plugin_Account.h"
#import "AccountLoginViewController.h"
#import "Plugin_Account_Utility.h"
#import "Plugin_Account_Globall.h"
#import "Account.h"
#import "VCCustomNavigationBar.h"
#import "ParentViewController.h"
#import "MWAccountOperator.h"
#import "AccountPersonalViewController.h"

@implementation Plugin_Account


-(id)init
{
    self =[super init];
    if (self) {
        
    }
    return self;
}

/*!
  @brief 相应模块调用该方法进入该模块
  @param 
 param: NSDictionary 
        关键字             值
navigationController    UINavigationController or UIViewController   -- 加载视图的UINavigationController或者UIViewController
      loginType         NSNumber                 --   10:新建一个window将登陆界面加入window，且可翻转  1：进入登陆界面或者帐号管理界面 2,进入个人中心界面
        bBack           NSNumber                 --    Yes:返回原界面  NO：进入账户管理界面
  @return 0失败;1成功
  */
//
-(int) enter:(id)param
{
    if ([param isKindOfClass:[NSDictionary class]])
    {
        NSDictionary* values=(NSDictionary*)param;
        
        int isLogin = [(NSNumber*)[values objectForKey:@"loginType"] intValue];
        BOOL bBack =  [(NSNumber*)[values objectForKey:@"bBack"] intValue];
        
        if (isLogin == 10)
        {
            UIViewController* navigation =(UIViewController*)[values objectForKey:@"navigationController"];
            
            NSArray *accountInfo = [[Account AccountInstance] getAccountInfo];
            NSString *myAccount = (NSString*)[accountInfo objectAtIndex:1];
            NSString *myPwd = (NSString*)[accountInfo objectAtIndex:1];
            
            AccountLoginViewController *login=[[AccountLoginViewController alloc] initWithAccountName:myAccount Password:myPwd back:bBack];
            ParentViewController *ctl = [[ParentViewController alloc] initWithNavigationBarClass:[VCCustomNavigationBar class] toolbarClass:nil];
            ctl.viewControllers = [NSArray arrayWithObject:login];
            
            [CustomWindow CreatCustomWindowWithRootViewController:ctl ModalViewController:navigation];
            
            [login release];
            [ctl release];
            return 1;
        }
        else if (isLogin == 2)
        {
            if ([[values objectForKey:@"navigationController"] isKindOfClass:[UIViewController class]])
            {
                UIViewController* navigation =(UIViewController*)[values objectForKey:@"navigationController"];
                AccountPersonalViewController *personal = [[AccountPersonalViewController alloc] init];
                [navigation.navigationController pushViewController:personal animated:YES];
                [personal release];
            }
        }
        
        if ([[values objectForKey:@"navigationController"] isKindOfClass:[UINavigationController class]])
        {
            UINavigationController* navigation =(UINavigationController*)[values objectForKey:@"navigationController"];
            NSArray *accountInfo = [[Account AccountInstance] getAccountInfo];
            isLogin = [[accountInfo objectAtIndex:0] intValue];
			NSString *myAccount = (NSString*)[accountInfo objectAtIndex:1];
			NSString *myPwd = (NSString*)[accountInfo objectAtIndex:1];
            if (isLogin)
            {
                return 1;
            }else if(0==isLogin)
            {
                AccountLoginViewController *login=[[AccountLoginViewController alloc] initWithAccountName:myAccount Password:myPwd back:bBack];
                [navigation pushViewController:login animated:YES];
                [login release];
                return 1;
            }
        }
    }
    return 0;
    
}

/*
 @brief 获取帐号信息 根据 index
 index     说明              返回值类型
 0:   获取用户登陆状态      NSNumber  注：此判断与用户id无关
 1:   获取用户登陆状态      NSNumber  注：此判断与用户id有关，不存在用户id，将会把登陆状态置为未登录
 2:   获取用户ID           NSString
 3:   获取用户名           NSString
 4:   获取用户头像~~~
 */
+ (id)getAccountInfoWith:(int)index
{
    NSArray *array = nil;
    [MWAccountOperator accountGetInfo:&array];
    if (array == nil)
    {
        return nil;
    }
    if (index == 0)
    {
        return [array objectAtIndex:0];
    }
    else if (index == 1)
    {
        int loginState=[[array objectAtIndex:0] intValue];
        if (loginState!=0)
        {
            if (array.count>7)
            {
                NSString *userId=[array objectAtIndex:7];
                if ([userId length]==0)
                {
                    GSTATUS status = GDBL_AccountLogout();
                    if (status==GD_ERR_OK)
                    {
                        GDBL_clearAccountInfo();
                    }
                    return [NSNumber numberWithInt:0];
                }
                else
                {
                    return [NSNumber numberWithInt:loginState];
                }
            }
        }
        return [NSNumber numberWithInt:0];
    }
    else if (index == 2)
    {
        int loginType = [[array objectAtIndex:0] intValue];
        if (loginType == 0)
        {
            return @"";
        }
        else
        {
            if ([array count] > 7)
            {
                return [array objectAtIndex:7];
            }
        }
    }
    else if (index == 3)
    {
        int loginType = [[array objectAtIndex:0] intValue];
        if (loginType == 1 || loginType == 2 || loginType == 5 || loginType == 6)
        {
            return [array objectAtIndex:1];
        }
        else if (loginType == 3 || loginType == 4)
        {
            return [array objectAtIndex:3];
        }
        else
        {
            return @"unknowUser";
        }
    }
    else if (index == 4)
    {
        int loginType = [[array objectAtIndex:0] intValue];
        if (loginType == 0)
        {
            return IMAGE(@"non_head.png", IMAGEPATH_TYPE_1);
        }
        else
        {
            UIImage *origImage = [UIImage imageWithData:[array objectAtIndex:4]];
            NSLog(@"%@",NSStringFromCGSize(origImage.size));
            UIImage *changeImage = nil;
            if (origImage.size.width != 60)
            {
                UIImage *temp = [self scaleToSize:origImage size:CGSizeMake(60.0, 60.0) changeRect:CGRectMake(0, 0, 60.0, 60.0)];
                changeImage = [UIImage getRoundImageWithImage:temp from:0 to:360];  //将图片改成圆形
            }
            else
            {
                changeImage = [UIImage getRoundImageWithImage:origImage from:0 to:360];  //将图片改成圆形
            }
            return changeImage;
        }
    }
    else if (index == 5)
    {
        int loginType = [[array objectAtIndex:0] intValue];
        if (loginType == 0)
        {
            return @"";
        }
        else
        {
            return [array objectAtIndex:8];
        }
    }
    return nil;
}

//图片缩放到指定大小尺寸
+ (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size changeRect:(CGRect)changRect
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

// 导航模块调用该方法离开子模块（一般情况下，子模块是调用backToNavi回到导航主模块）
// 返回值：0失败；1成功
-(int) leave
{
    return 1;
}

// 导航模块调用该方法终止子模块（在导航模块因某种原因而需要退出程序，而此时子模块可能还处于执行中，此时导航模块将调用该方法）
// 返回值：0失败；1成功
-(int) exit
{
    return 1;
}

#pragma mark -
#pragma mark NSObject lifecycle
-(void) dealloc
{
    [super dealloc];
}

@end

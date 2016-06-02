//
//  MainTabBarController.m
//  RoadFreightage
//
//  Created by yu.liao on 15/6/2.
//  Copyright (c) 2015年 WuKongSuYun. All rights reserved.
//

#import "MainTabBarController.h"
#import "WorkspaceViewController.h"
#import "OrderViewController.h"
#import "ServiceViewController.h"
#import "MoreViewController.h"

@interface MainTabBarController () <UITabBarControllerDelegate>

@property (nonatomic,strong) NSMutableArray *arrayItems;

@end

@implementation MainTabBarController

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.edgesForExtendedLayout=UIRectEdgeNone;
    self.extendedLayoutIncludesOpaqueBars=NO;
    self.automaticallyAdjustsScrollViewInsets=NO;
    
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wk_banner"]];
    
    // Do any additional setup after loading the view.
    
    self.arrayItems = [[NSMutableArray alloc]initWithCapacity:0];
    
    NSArray *arrayImageString = @[@"wk_bottombar_state",
                                  @"wk_bottombar_order",
                                  @"wk_bottombar_map",
                                  @"wk_bottombar_more"];
    
    WorkspaceViewController *viewCtr1 = [[WorkspaceViewController alloc] init];
    viewCtr1.title = @"工作台";
    viewCtr1.tabBarItem.image = [UIImage imageNamed:[arrayImageString objectAtIndex:0]];
    [self.arrayItems addObject:viewCtr1];
    
    OrderViewController *viewCtr2 = [[OrderViewController alloc]init];
    viewCtr2.title = @"订单";
    viewCtr2.tabBarItem.image = [UIImage imageNamed:[arrayImageString objectAtIndex:1]];
    [self.arrayItems addObject:viewCtr2];
    
    ServiceViewController *viewCtr3 = [[ServiceViewController alloc]init];
    viewCtr3.title = @"服务";
    viewCtr3.tabBarItem.image = [UIImage imageNamed:[arrayImageString objectAtIndex:2]];
    [self.arrayItems addObject:viewCtr3];
    
    MoreViewController *viewCtr4 = [[MoreViewController alloc] initWithStyle:UITableViewStyleGrouped];
    viewCtr4.title = @"我的";
    viewCtr4.tabBarItem.image = [UIImage imageNamed:[arrayImageString objectAtIndex:3]];
    [self.arrayItems addObject:viewCtr4];
    
    self.viewControllers = self.arrayItems;
    
    self.tabBar.tintColor =  [UIColor redColor];

    self.delegate = self;
    
   
    
}



- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;

}



#pragma mark - UITabBarControllerDelegate
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    NSLog(@"select %lu",(unsigned long)tabBarController.selectedIndex);
//    self.title = viewController.title;
    switch (tabBarController.selectedIndex) {
        case 0:
        {
            self.navigationController.navigationBarHidden = NO;
        }
            break;
        case 1:
        {
            self.navigationController.navigationBarHidden = NO;
        }
            break;
        case 2:
        {
            self.navigationController.navigationBarHidden = YES;
        }
            break;
        case 3:
        {
            self.navigationController.navigationBarHidden = NO;
        }
            break;
        default:
            break;
    }
    
}

@end

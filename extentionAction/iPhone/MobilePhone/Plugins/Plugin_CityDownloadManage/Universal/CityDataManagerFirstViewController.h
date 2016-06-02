//
//  CityDataManagerFirstViewController.h
//  plugin-CityDataManager
//
//  Created by hlf on 11-11-8.
//  Copyright (c) 2011年 Autonavi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "plugin-cdm-TaskManager.h"
#import "UIApplication+Category.h"
#import "ANParamValue.h"
#import "CustomCell.h"
#import "DMDataDownloadPagesContainer.h"

#define  kAddEarthquakesNotif @"kAddEarthquakesNotif"
#define  remallTask @"remallTask" 


@interface CityDataManagerFirstViewController : UIViewController<UITableViewDelegate, UITableViewDataSource,UIActionSheetDelegate,TaskStatusDelegate,CustomCellDelegate>
{

}

@property (nonatomic,assign) int  isWholeMap;   //是否是完整的地图
@property (nonatomic,assign) id managerController;


//横竖屏切换
-(void)set_HV:(int)flag;
-(void)Back:(id)sender;

@end

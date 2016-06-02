//
//  FileItemTableCell.m
//  autonavi
//
//  Created by hlf on 11-11-9.
//  Copyright 2011 autonavi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CityDataManagerFirstViewController.h"
#import "SectionHeaderView.h"
#import "UIApplication+Category.h"
#import "POIAroundTextField.h"
#import "POIKeyBoardEvent.h"


@interface DownLoadCityDataController : UIViewController<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate,SectionHeaderViewDelegate,TaskStatusDelegate,POIAroundTextFieldDelegate,POIKeyBoardEventProtocol,NetReqToViewCtrDelegate>
{

}

@property (nonatomic, retain) NSDictionary       *cityAdminCodeArray; //下载城市的行政编码
@property (nonatomic,assign) id managerController;

- (void)set_HV:(int)flag;
- (void)loadingDataList;

@end

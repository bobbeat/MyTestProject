//
//  DMDataDownloadManagerViewController.h
//  AutoNavi
//
//  Created by huang longfeng on 13-9-05.
//
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, GDDownloadViewType) {
    GDDownloadViewTypeManager = 0,//下载管理页面
    GDDownloadViewTypeList,//省市列表页面
};

@class DMDataDownloadPagesContainer;

@interface DMDataDownloadManagerViewController : ANViewController

@property (retain, nonatomic) DMDataDownloadPagesContainer *pagesContainer;

- (id)initWithViewType:(GDDownloadViewType)viewType DataType:(int)dataType CityAdminCodeArray:(NSDictionary *)adminArray;

//隐藏导航栏右边按钮
- (void)setRightBarButtonHidden:(BOOL)hidden;

@end

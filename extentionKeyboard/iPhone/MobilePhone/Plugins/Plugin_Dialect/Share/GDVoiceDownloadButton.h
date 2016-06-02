//
//  GDVoiceDownloadButton.h
//  AutoNavi
//
//  Created by jiangshu-fu on 14-1-16.
//
//

#import <UIKit/UIKit.h>

#pragma mark -
#pragma mark ---  声音下载的按钮类  ---

@interface GDVoiceDownloadButton : UIButton
{
    UILabel *_labelPercent;
    UIImageView *_downloadImageView;
}
//上一层视图中，cell的长宽 大小
@property (nonatomic, assign) CGSize sizeCell;
@property (nonatomic, assign) SKIN_DOWNLOAD_TYPE downloadType;
@property (nonatomic, assign) int  downloadPercent; //下载的百分比
@property (nonatomic, assign) int  typeID;
@property (nonatomic, assign) long long total;
/***
 * @name    初始化button按鈕，以及是否已下載的屬性
 * @param
 * @author  by bazinga
 ***/
- (id)initwithIsDownload:(SKIN_DOWNLOAD_TYPE)isdownload withPercent:(int)percent withID:(int)typeID;

@end

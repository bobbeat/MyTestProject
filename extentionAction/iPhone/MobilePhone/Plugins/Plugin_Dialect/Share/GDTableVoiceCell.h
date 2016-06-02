//
//  GDTableVoiceCell.h
//  AutoNavi
//
//  Created by jiangshu-fu on 14-1-16.
//
//

#import "GDTableViewCell.h"
@class GDVoiceDownloadButton;

//按钮点击手势~
typedef void(^GDDownloadButtonTap)(GDVoiceDownloadButton *);


@interface GDTableVoiceCell : GDTableViewCell
{

}

//是否有可下载的按钮
@property (nonatomic, retain)  GDVoiceDownloadButton *voiceDownloadButton;
@property (nonatomic, copy) GDDownloadButtonTap downloadButtonTap;
@property (nonatomic, assign) BOOL hasDownloadButton;

/***
 * @name    需要调用这个函数，否者，默认不显示下载按钮
 * @param   style --  cell的样式
 * @param   reuseIdentifier  --  cell 的唯一id
 * @param   hasDownloadButton --  是否已下载  YES： 下载完成，不显示  NO： 下载未完成，显示button按钮
 * @author  by bazinga
 ***/
- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
     withIsDownload:(BOOL)hasDownloadButton;

@end

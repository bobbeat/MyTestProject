//
//  GDTableVoiceCell.m
//  AutoNavi
//
//  Created by jiangshu-fu on 14-1-16.
//
//

#import "GDTableVoiceCell.h"
#import "GDVoiceDownloadButton.h"

#pragma mark -
#pragma mark ---  下载的自定义  ---

@implementation GDTableVoiceCell

@synthesize hasDownloadButton = _hasDownloadButton;
@synthesize voiceDownloadButton = _voiceDownloadButton;
/***
 * @name    需要调用这个函数，否者，默认不显示下载按钮
 * @param   style --  cell的样式
 * @param   reuseIdentifier  --  cell 的唯一id
 * @param   hasDownloadButton --  是否已下载  YES： 下载完成，不显示  NO： 下载未完成，显示button按钮
 * @author  by bazinga
 ***/
- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
     withIsDownload:(BOOL)hasDownloadButton
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self)
    {
        _hasDownloadButton = hasDownloadButton;
        //id默认为0，在设置cell的tag的时候，同时设置id，id即tag
        _voiceDownloadButton = [[GDVoiceDownloadButton alloc]initwithIsDownload:SKIN_STATUS_NO withPercent:0 withID:0];
        [self addSubview:_voiceDownloadButton];
        [_voiceDownloadButton release];
        [_voiceDownloadButton setDownloadType:SKIN_STATUS_NO];
        _voiceDownloadButton.hidden = !_hasDownloadButton;
        
        UITapGestureRecognizer *tap;
        tap = [[UITapGestureRecognizer alloc]initWithTarget:self  action:@selector(downloadTap)];
        [_voiceDownloadButton  addGestureRecognizer:tap];
        [tap release];
    }
    return self;
}

- (void) dealloc
{
    CRELEASE(_downloadButtonTap);
    [super dealloc];
}


- (void) layoutSubviews
{
    [super layoutSubviews];
    //如果有按钮，就可以去设置按钮的位置大小等……
    if(_hasDownloadButton)
    {
        CGRect contentRect = [self.contentView bounds];
        _voiceDownloadButton.sizeCell = contentRect.size;
        [_voiceDownloadButton setCenter:CGPointMake(contentRect.size.width - 60, contentRect.size.height / 2)];
        _voiceDownloadButton.downloadType = _voiceDownloadButton.downloadType;
    }
}

- (void) setTag:(NSInteger)tag
{
    [super setTag:tag];
    _voiceDownloadButton.typeID = tag;
}

- (void) setHasDownloadButton:(BOOL)hasDownloadButton
{
    _hasDownloadButton = hasDownloadButton;
    _voiceDownloadButton.hidden = !_hasDownloadButton;
}

- (void) downloadTap
{
    if(self.downloadButtonTap)
    {
        self.downloadButtonTap(self.voiceDownloadButton);
    }
}

@end

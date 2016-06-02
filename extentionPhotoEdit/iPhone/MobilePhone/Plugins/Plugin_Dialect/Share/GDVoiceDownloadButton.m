//
//  GDVoiceDownloadButton.m
//  AutoNavi
//
//  Created by jiangshu-fu on 14-1-16.
//
//

#import "GDVoiceDownloadButton.h"

#pragma mark -
@implementation GDVoiceDownloadButton

@synthesize sizeCell = _sizeCell;
@synthesize downloadType = _downloadType;
@synthesize downloadPercent = _downloadPercent;
@synthesize typeID = _typeID;
@synthesize total = _total;

#define  DIALECT_TEXT_COLOR (RGBACOLOR(131.0f, 194.0f, 69.0f, 1.0f))

- (id)initwithIsDownload:(SKIN_DOWNLOAD_TYPE)isdownload withPercent:(int)percent withID:(int)typeID
{
    self  = [super init];
    if(self)
    {
        _downloadPercent = percent;
        _typeID = typeID;
        _downloadType = isdownload;
        _labelPercent = [[UILabel alloc]init];
        _labelPercent.backgroundColor = [UIColor clearColor];
        _labelPercent.textColor = DIALECT_TEXT_COLOR;
        _labelPercent.font = [UIFont systemFontOfSize:10.0f];
        [self addSubview:_labelPercent];
        [_labelPercent release];
        self.titleLabel.font = [UIFont systemFontOfSize:10.0f];
        _total = 0;
        UIImage *normalImage = IMAGE(@"DialectDownload_on.png", IMAGEPATH_TYPE_1);
        UIImage *heightImage = IMAGE(@"DialectDownload_onPress.png", IMAGEPATH_TYPE_1);
        [self setTitleColor:DIALECT_TEXT_COLOR forState:UIControlStateNormal];
        
       _downloadImageView = [[UIImageView alloc] initWithImage:normalImage highlightedImage:heightImage];
        [self addSubview:_downloadImageView];
        [_downloadImageView release];
        
    }
    return self;
}

/***
 * @name    設置按鈕是否下載的狀態
 * @param
 * @author  by bazinga
 ***/
- (void) setDownloadType:(SKIN_DOWNLOAD_TYPE)downloadType
{
    
    self.hidden = NO;
    _downloadType = downloadType;
    //根据状态，设置frame的大小
    CGSize buttonSize;
    BOOL hasAnimate = NO;
    NSString *title  = @"";
    
    //是否是未下载，未下载的——下载图标显示
    if(downloadType == DOWNLOAD_NO)
    {
        _downloadImageView.hidden = NO;
    }
    else
    {
        _downloadImageView.hidden = YES;
    }
    //根据类型不同，设置显示
    if(downloadType == DOWNLOAD_NO)//未下载 || 继续
    {
        buttonSize = CGSizeMake(80.0f,30.0f);
        
        [_labelPercent setFrame:CGRectMake(10, 0, 45.0f, 30.0f)];
        NSString *title = @"";
        if(_total == 0)
        {
            title = STR(@"SkinDownload_unDownload", Localize_Setting);
        }
        else
        {
            title = [NSString stringWithFormat:@"%.1lfMB",((_total * 1.0f) / 1024.0f / 1024.0f)];
        }
        _labelPercent.text = title;
        [self setTitle:@"" forState:UIControlStateNormal];
        
        [_downloadImageView setCenter:CGPointMake(buttonSize.width - 12.0f - _downloadImageView.frame.size.width / 2,
                                                  buttonSize.height / 2)];
    }
    else if (downloadType == DOWNLOAD_WAITING)
    {
        buttonSize = CGSizeMake(80.0f, 30.0f);
        [_labelPercent setFrame:CGRectMake(0, 0, 0, 0)];
        
        title = STR(@"SkinDownload_waiting", Localize_Setting);
        
    }
    else  if(downloadType == DOWNLOAD_UPDATE)//未下载 || 继续
    {
        buttonSize = CGSizeMake(80.0f, 30.0f);
        
        [_labelPercent setFrame:CGRectMake(0, 0, 0, 0)];
        title = STR(@"SkinDownload_update", Localize_Setting);
    }
    else if(downloadType == DOWNLOAD_ING)     //下载中
    {
        buttonSize  = CGSizeMake(115.0f, 30.0f);
        
        [_labelPercent setFrame:CGRectMake(80.0f, 0.0f, 30.0f, 30.0f)];

        if(self.frame.origin.x == 0 && self.frame.origin.y == 0)
        {
            hasAnimate = NO;
        }
        else
        {
            hasAnimate  = YES;
        }
       
    }
    else if (downloadType == DOWNLOAD_UNZIP)  //解压
    {
        [_labelPercent setFrame:CGRectMake(0, 0, 0, 0)];
        
        buttonSize  = CGSizeMake(80.0f, 30.0f);
        if(self.frame.origin.x == 0 && self.frame.origin.y == 0)
        {
            hasAnimate = NO;
        }
        else
        {
            hasAnimate  = YES;
        }
         title = STR(@"SkinDownload_unzip", Localize_Setting);
    }
    else if (downloadType == DOWNLOAD_STOP)
    {
         [_labelPercent setFrame:CGRectMake(0, 0, 0, 0)];
        
         buttonSize  = CGSizeMake(80.0f, 30.0f);
        if(self.frame.origin.x == 0 && self.frame.origin.y == 0)
        {
            hasAnimate = NO;
        }
        else
        {
            hasAnimate  = YES;
        }
        title = STR(@"SkinDownload_continue", Localize_Setting);
    }
    else if (downloadType == DOWNLOAD_COMPLETE)  //完成
    {
        self.hidden = YES;
//        if(_delegate && [_delegate respondsToSelector:@selector(downloadComplete)])
//        {
//            [_delegate downloadComplete];
//        }
    }
    
    //设置按钮的位置
    if(_sizeCell.width != 0 || _sizeCell.height != 0)
    {
        if (hasAnimate == NO)
        {
            [self setFrame: CGRectMake(_sizeCell.width - buttonSize.width - 15.0f,
                                       (_sizeCell.height - buttonSize.height) / 2,
                                       buttonSize.width,
                                       buttonSize.height)];
        }
        else
        {

                 [self setFrame: CGRectMake(_sizeCell.width - buttonSize.width - 15.0f,
                                            (_sizeCell.height - buttonSize.height) / 2,
                                            buttonSize.width,
                                            buttonSize.height)];
        }
    }

    [self setTitle:title forState:UIControlStateNormal];
    [self setNeedsDisplay];

}

- (void) setSizeCell:(CGSize)sizeCell
{
    _sizeCell.width = sizeCell.width;
    _sizeCell.height = sizeCell.height;
}

/***
 * @name    設置下載的百分比
 * @param
 * @author  by bazinga
 ***/
- (void) setDownloadPercent:(int)downloadPercent
{
    _downloadPercent = downloadPercent;
    if(downloadPercent >= 100)
    {
        self.downloadType = DOWNLOAD_UNZIP;
        return;
    }
    
    [_labelPercent setText:[NSString stringWithFormat:@"%d%%",_downloadPercent]];
    self.downloadType = DOWNLOAD_ING;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    //[super drawRect:rect];
    UIImage *backImage = [IMAGE(@"DialectDownload_back.png", IMAGEPATH_TYPE_1) stretchableImageWithLeftCapWidth:20.0f topCapHeight:15.0f];
    [backImage drawInRect:rect];
    
    // Drawing code
    if(self.downloadType == DOWNLOAD_ING)
    {
        float width = 60.0f;
        float percentHeight = 6.0f;
        float height = self.frame.size.height;
        
        UIImage *backImage = [IMAGE(@"DialectDownload_Percent.png", IMAGEPATH_TYPE_1) stretchableImageWithLeftCapWidth:8
                                                                                                          topCapHeight:3];
        UIImage *percentImage = [IMAGE(@"DialectDownload_hasPercent.png", IMAGEPATH_TYPE_1) stretchableImageWithLeftCapWidth:8
                                                                                                                topCapHeight:3];
        [backImage drawInRect:CGRectMake(13.0f,
                                         (height - percentHeight) / 2,
                                         width,
                                         percentHeight)];
        [percentImage drawInRect:CGRectMake(13.0f,
                                            (height - percentHeight) / 2,
                                            (_downloadPercent/100.0f) * width,
                                            percentHeight)];
    }
}

- (void) setFrame:(CGRect)frame
{
    NSLog(@"~~~~~~~%@",NSStringFromCGRect(frame));
    [super setFrame:frame];
}


@end


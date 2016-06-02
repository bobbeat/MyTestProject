//
//  CarServiceMoreCell.m
//  AutoNavi
//
//  Created by jiangshu-fu on 14-3-8.
//
//

#import "CarServiceMoreCell.h"
#import "CarServiceVarDefine.h"
#import "GDCacheManager.h"
#import "MWSkinAndCarListRequest.h"

@implementation CarServiceMoreCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _carServiceCellType = CARSERVICE_CELL_MORE;
        _imageLoadRequest = [[MWSkinAndCarListRequest alloc] init];
        _imageLoadRequest.delegate = self;
        _cellIamgeLoad = nil;
        _showNewPoint = NO;
        
        _imageViewNew = [[UIImageView alloc] init];
        _imageViewNew.image = IMAGE(@"main_newPointMore.png", IMAGEPATH_TYPE_1);
        [_imageViewNew setFrame:CGRectMake(0, 0, _imageViewNew.image.size.width, _imageViewNew.image.size.height)];
        [self.imageView addSubview:_imageViewNew];
        _imageViewNew.hidden = YES;
        [_imageViewNew release];
    }
    return self;
}

- (void) dealloc
{
    _imageLoadRequest.delegate = nil;
    if(_imageLoadRequest)
    {
        [_imageLoadRequest release];
        _imageLoadRequest = nil;
    }
    if(_cellIamgeLoad)
    {
        [_cellIamgeLoad release];
        _cellIamgeLoad = nil;
        
    }
    
    [super dealloc];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    switch (_carServiceCellType) {
        case CARSERVICE_CELL_MORE:
        {
            [self setMoreCellFrame];
        }
            break;
        case CARSERVICE_CELL_DETAIL_IMAGE:
        {
            [self setDetailWithImageCellFrame];
        }
            break;
        case CARSERVICE_CELL_DETAIL:
        {
            [self setDetailCellFrame];
        }
            break;
            
        default:
            break;
    }
}

#pragma  mark -  ---  请求图片  ---
- (void) setImageString:(NSString *)imageString
{
    NSLog(@"imageString = %@..................",imageString);
    UIImage *image = [[GDCacheManager globalCache] imageForKey:imageString];
    if(image)
    {
        self.imageView.image = image;
    }
    else
    {
        //REQ_SKIN_DATA 这个类型，其实是皮肤请求的，拿来用的，不然应该再自定义一个类型来请求的
        [_imageLoadRequest Net_RequestImage:imageString
                                withRequest:REQ_SKIN_DATA];
    }

}

//id类型可以是NSDictionary NSArray
- (void)requestToViewCtrWithRequestType:(RequestType)requestType didFinishLoadingWithResult:(id)result
{
    if(REQ_SKIN_DATA == requestType)
    {
        if([result isKindOfClass:[NSDictionary class]]) //图片文件
        {
            if(self.cellIamgeLoad)
            {
                self.cellIamgeLoad();
            }
        }
    }
}
//上层需根据error的值来判断网络连接超时还是网络连接错误
- (void)requestToViewCtrWithRequestType:(RequestType)requestType didFailWithError:(NSError *)error
{
    NSLog(@"request image  fail");
}


#pragma mark - ---  车主服务更多以及详情的cell内部的控件的坐标  ---
/***
 * @name    更多服务cell的控件位置
 * @param
 * @author  by bazinga
 ***/
- (void) setMoreCellFrame
{
    if(self.imageView.image)
    {
        //图片的位置坐标
        CGRect rect ;
        rect.origin.x = 10;
        rect.origin.y = 10;
        rect.size.height = self.contentView.bounds.size.height - 20.0f;
        rect.size.width = rect.size.height;
    
        self.imageView.frame=rect;
        if(self.showNewPoint)
        {
            _imageViewNew.hidden = NO;
            _imageViewNew.center = CGPointMake(rect.size.width, 0);
        }
        else
        {
            _imageViewNew.hidden = YES;
        }
        
        //textLabel的frame数值
        CGRect contentRect = [self.textLabel frame];
        contentRect.origin.y = 14.0f;
        contentRect.origin.x = 64.0f;
        contentRect.size.width = self.contentView.bounds.size.width - self.imageView.frame.size.width - 40.0f;
        self.textLabel.frame = contentRect;
    
        //detailTextLabel的frame数值
        contentRect = [self.detailTextLabel frame];
        contentRect.origin.x = 64.0f;
        contentRect.size.width = self.contentView.bounds.size.width - self.imageView.frame.size.width - 40.0f;
        contentRect.origin.y = 40.0f;
        self.detailTextLabel.frame = contentRect;
    }
    else
    {
        //textLabel的frame数值
        CGRect contentRect = [self.textLabel frame];
        contentRect.origin.y -= 6.0f;
        self.textLabel.frame = contentRect;
        
        //detailTextLabel的frame数值
        contentRect = [self.detailTextLabel frame];
        contentRect.origin.y += 3.0f;
        self.detailTextLabel.frame = contentRect;
    }
}

/***
 * @name    详情服务中，有图片的cell的控件位置
 * @param
 * @author  by bazinga
 ***/
- (void) setDetailWithImageCellFrame
{
    if(self.imageView.image)
    {
        //图片的位置坐标
        CGRect rect ;
        rect.origin.x = 10;
        rect.origin.y = 10;
        rect.size.height = self.contentView.bounds.size.height - 20.0f;
        rect.size.width = rect.size.height;
    
        self.imageView.frame=rect;
    
        //textLabel的frame数值
        CGRect contentRect = [self.textLabel frame];
        contentRect.origin.x = 71.0f;
        contentRect.size.width = self.contentView.bounds.size.width - self.imageView.frame.size.width - 30.0f ;
        self.textLabel.frame = contentRect;
    
        //detailTextLabel的frame数值
        contentRect = [self.detailTextLabel frame];
        contentRect.origin.x = 71.0f;
        contentRect.size.width = self.contentView.bounds.size.width - self.imageView.frame.size.width - 30.0f;
        contentRect.origin.y -= 1.0f ;
        self.detailTextLabel.frame = contentRect;
    }
    else
    {
        //textLabel的frame数值
        CGRect contentRect = [self.textLabel frame];
        self.textLabel.frame = contentRect;
        
        //detailTextLabel的frame数值
        contentRect = [self.detailTextLabel frame];
        contentRect.origin.y -= 1.0f ;
        self.detailTextLabel.frame = contentRect;

    }
}

/***
 * @name    详情服务中，无图片的cell的控件位置
 * @param
 * @author  by bazinga
 ***/
- (void) setDetailCellFrame
{
    CGRect contentRect = [self.textLabel frame];
    contentRect.origin.x = 19.0f;
    contentRect.origin.y = 13.0f;
    self.textLabel.frame = contentRect;
    
    //detailTextLabel的frame数值
    contentRect = [self.detailTextLabel frame];
    contentRect.origin.x = 19.0f;
    contentRect.size = [self.detailTextLabel.text sizeWithFont:[UIFont systemFontOfSize:12.0f]
                                             constrainedToSize:CGSizeMake(CARSERVICE_DETAIL_LABEL_WIDTH,2000)
                                                 lineBreakMode:UILineBreakModeWordWrap];
    
    contentRect.origin.y = 37.0f ;
    
    self.detailTextLabel.frame = contentRect;
}

@end

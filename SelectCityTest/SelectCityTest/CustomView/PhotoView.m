//
//  PhotoView.m
//  RoadFreightage
//
//  Created by gaozhimin on 15/6/5.
//  Copyright (c) 2015年 WuKongSuYun. All rights reserved.
//

#import "PhotoView.h"
#import "UIImage+Category.h"

@interface PhotoView()<UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    UIButton *imageButton;
    UIImagePickerController *_picker;
    UIViewController *_viewController;
    UIButton *_takePhotoButton;
    
    UIView *_shadeView;
    UIImageView *_zoomImageView;
}

@end

@implementation PhotoView
@synthesize imageView,informationlabel;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self loadSubView];
    }
    return self;
}

- (instancetype)init
{
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithController:(UIViewController *)viewController
{
    _viewController = viewController;
    return [self init];
}

- (void)loadSubView
{
    _takePhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _takePhotoButton.backgroundColor = [UIColor clearColor];
    [_takePhotoButton addTarget:self action:@selector(takePhoto) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_takePhotoButton];
    
    imageView = [[UIImageView alloc] init];
    imageView.image = [UIImage imageNamed:@"wk_photo_img"];
    imageView.userInteractionEnabled = YES;
    [self addSubview:imageView];
    
    imageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    imageButton.backgroundColor = [UIColor clearColor];
    [imageButton addTarget:self action:@selector(ButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [imageView addSubview:imageButton];
    
    informationlabel = [[UILabel alloc] init];
    informationlabel.backgroundColor = [UIColor clearColor];
    informationlabel.textAlignment = NSTextAlignmentLeft;
    informationlabel.font = [UIFont systemFontOfSize:18];
    informationlabel.textColor = [UIColor blackColor];
    [self addSubview:informationlabel];
    self.userInteractionEnabled = YES;
    
    _shadeView = [[UIView alloc] init];
    _shadeView.backgroundColor = [UIColor colorWithHue:0 saturation:0 brightness:0 alpha:0.5];
  
    _zoomImageView = [[UIImageView alloc] init];
    
    //单击，点击移图
    UITapGestureRecognizer *singleFingerOne = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(handleSingleFingerEvent:)];
    singleFingerOne.numberOfTouchesRequired = 1; //手指数
    singleFingerOne.numberOfTapsRequired = 1; //tap次数
    [_shadeView addGestureRecognizer:singleFingerOne];
}

- (void)takePhoto
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"编辑" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"从相册中获取",@"手机拍照", nil];
    [actionSheet showInView:self];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    informationlabel.frame = CGRectMake(20, 10, self.bounds.size.width - 120, self.bounds.size.height - 20);
    imageView.frame = CGRectMake(self.bounds.size.width - 100, 10, 60, self.bounds.size.height - 20);
    imageButton.frame = imageView.bounds;
    _takePhotoButton.frame =self.bounds;
}


- (void)ButtonPressed
{
    UIView *view = imageView;
    CGRect rect = imageView.bounds;
    while (view) {
        
        rect.origin.x += view.frame.origin.x;
        rect.origin.y += view.frame.origin.y;
        if (view.superview == nil)
        {
            break;
        }
        if ([view isKindOfClass:[UIScrollView class]])
        {
            UITableView *tableView = (UITableView *)view;
            CGPoint point = tableView.contentOffset;
            rect.origin.y -= point.y;
            rect.origin.x -= point.x;
        }
        view = view.superview;
        
    }
    [view addSubview:_shadeView];
    [view addSubview:_zoomImageView];
    _shadeView.frame = view.bounds;
    _zoomImageView.frame = rect;
    _zoomImageView.image = imageView.image;
    
    
    [UIView animateWithDuration:0.5 animations:^{
        _shadeView.frame = view.bounds;
        _zoomImageView.bounds = CGRectMake(0, 0, imageView.image.size.width, imageView.image.size.height);
        _zoomImageView.center = CGPointMake(view.bounds.size.width/2, view.bounds.size.height/2);
    }];
}

#pragma mark - UITapGestureRecognizer
- (void)handleSingleFingerEvent:(UITapGestureRecognizer *)recognizer
{
    UIView *view = imageView;
    CGRect rect = imageView.bounds;
    while (view) {
        rect.origin.x += view.frame.origin.x;
        rect.origin.y += view.frame.origin.y;
        if (view.superview == nil)
        {
            break;
        }
        if ([view isKindOfClass:[UIScrollView class]])
        {
            UITableView *tableView = (UITableView *)view;
            CGPoint point = tableView.contentOffset;
            rect.origin.y -= point.y;
            rect.origin.x -= point.x;
        }
        view = view.superview;
        
    }
    [UIView animateWithDuration:0.5 animations:^{
        _zoomImageView.frame = rect;
    } completion:^(BOOL finished) {
        [_shadeView removeFromSuperview];
        [_zoomImageView removeFromSuperview];
    }];
}


#pragma mark - actionSheet
// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (_viewController == nil)
    {
        return;
    }
    switch (buttonIndex) {
        case 0:
        {
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
                _picker = [[UIImagePickerController alloc] init];
                _picker.delegate = self;
                _picker.allowsEditing = YES;
                _picker.mediaTypes =[UIImagePickerController availableMediaTypesForSourceType:_picker.sourceType];
                _picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                [_viewController presentViewController:_picker animated:NO completion:nil];
            } else {
                UIAlertView *Myalert_ext = [[UIAlertView alloc] initWithTitle:nil message:@"该设备支持该功能" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [Myalert_ext show];
            }
        }
            break;
        case 1:
        {
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
            {
                _picker = [[UIImagePickerController alloc]init];
                _picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                _picker.delegate = self;
                _picker.allowsEditing = YES;
                [_viewController presentViewController:_picker animated:NO completion:nil];
            } else
            {
                UIAlertView *Myalert_ext = [[UIAlertView alloc] initWithTitle:nil message:@"该设备支持该功能" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [Myalert_ext show];
            }
        }
            break;
        default:
            break;
    }
}
#pragma mark-
#pragma mark UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if (picker.sourceType==UIImagePickerControllerSourceTypeCamera ||
        picker.sourceType==UIImagePickerControllerSourceTypePhotoLibrary)
    {
        UIImage *originalImage = [info objectForKey:UIImagePickerControllerEditedImage];
        if (originalImage)
        {
            imageView.image = originalImage;
        }
    }
    [picker dismissViewControllerAnimated:NO completion:nil];
    _picker = nil;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:NO completion:nil];
    _picker = nil;
}

- (void)saveTheImage:(UIImage*)image
{
    NSString *uniquePath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"selectedImage.png"];
    [UIImagePNGRepresentation(image) writeToFile: uniquePath atomically:YES];
    
    
}

//图片缩放到指定大小尺寸
- (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size changeRect:(CGRect)changRect
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


@end

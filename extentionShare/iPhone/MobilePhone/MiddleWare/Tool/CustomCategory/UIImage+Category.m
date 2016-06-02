//
//  UIImage+Category.m
//  AutoNavi
//
//  Created by huang longfeng on 13-3-1.
//
//

#import "UIImage+Category.h"
#import "NSString+Category.h"

#define Img_ls         @"_ls"
#define iphone5_i5     @"_i5"
#define iphone6_i6     @"_i6"
#define iphone5_i5_HD  @"_i5@2x"
#define iphone6_i6_HD  @"_i6@2x"
#define retina         @"@2x"
#define iphone_extern  @"~iphone"
#define iphone_retina1 @"@2x~iphone"
#define ipad_normal    @"_iPad"
#define ipad_retina    @"_iPad@2x"
#define ipad_extern    @"~ipad"
#define ipad_retina1   @"@2x~ipad"

#define DayBundleName  @"DayImage.bundle/"
#define NightBundleName @"NightImage.bundle/"

static BOOL ImageDayNightMode = NO; //NO 白天,YES 黑夜
static BOOL ImageSkinType = NO;     //皮肤类型：NO 默认 YES 指定皮肤
static NSString *ImageSkinPath;          //皮肤路径


@implementation UIImage (Category)

//获取图片 name:图片名称 imagePathType:图片获取类型(1 从mainbundle中获取 2 区分白天黑夜的bundle)
+ (UIImage *)imageWithName:(NSString *)name pathType:(IMAGEPATHTYPE)imagePathType
{
    
    UIImage *image;
    NSMutableString *imageNameMutable = [name mutableCopy];
    
    NSString *type = [NSString stringWithFormat:@".%@",[name pathExtension]];
    NSRange extension = [name rangeOfString:type options:NSBackwardsSearch];
    
    if (extension.location == NSNotFound) {
        if(imageNameMutable)
        {
            [imageNameMutable release];
            imageNameMutable = nil;
        }
        return nil;
    }
    
    if (IMAGEPATH_TYPE_1 == imagePathType) {//从bundle中获取图片资源
        
        if (ImageSkinType) {//指定皮肤路径
            image = [self imageWithName:name pathType:IMAGEPATH_TYPE_3];
            if (image) {
                if(imageNameMutable)
                {
                    [imageNameMutable release];
                    imageNameMutable = nil;
                }
                return image;
            }
        }
        
        if (iPhone6) {
            
            [imageNameMutable insertString:iphone6_i6 atIndex:extension.location];
            
            image = [UIImage imageNamed:imageNameMutable];
            
            if (image) {
                if(imageNameMutable)
                {
                    [imageNameMutable release];
                    imageNameMutable = nil;
                }
                return image;
            }
            
        }
        else if (iPhone5) {
            
            [imageNameMutable insertString:iphone5_i5 atIndex:extension.location];
            
            image = [UIImage imageNamed:imageNameMutable];
            
            if (image) {
                if(imageNameMutable)
                {
                    [imageNameMutable release];
                    imageNameMutable = nil;
                }
                return image;
            }
            
        }
        if(imageNameMutable)
        {
            [imageNameMutable release];
            imageNameMutable = nil;
        }
        return [UIImage imageNamed:name];
    }
    else if (IMAGEPATH_TYPE_2 == imagePathType)//从document中指定文件夹获取图片资源
    {
        if (iPhone6) {
            
            [imageNameMutable insertString:iphone6_i6 atIndex:extension.location];
            
            //白天,黑夜图片切换
            NSString *tmp;
            if (ImageDayNightMode) {
                
                tmp = [NSString stringWithFormat:@"%@%@",NightBundleName,imageNameMutable];
                
            }
            else{
                
                if (ImageSkinType) {//指定皮肤路径
                    image = [self imageWithName:imageNameMutable pathType:IMAGEPATH_TYPE_3];
                    if (image) {
                        if(imageNameMutable)
                        {
                            [imageNameMutable release];
                            imageNameMutable = nil;
                        }
                        return image;
                    }
                }
                
                tmp = [NSString stringWithFormat:@"%@%@",DayBundleName,imageNameMutable];
            }
            
            image = [UIImage imageNamed:tmp];
            
            if (image) {
                if(imageNameMutable)
                {
                    [imageNameMutable release];
                    imageNameMutable = nil;
                }
                return image;
            }
        }
        else if (iPhone5) {
            
            [imageNameMutable insertString:iphone5_i5 atIndex:extension.location];
            
            //白天,黑夜图片切换
            NSString *tmp;
            if (ImageDayNightMode) {
                
                tmp = [NSString stringWithFormat:@"%@%@",NightBundleName,imageNameMutable];
                
            }
            else{
                
                if (ImageSkinType) {//指定皮肤路径
                    image = [self imageWithName:imageNameMutable pathType:IMAGEPATH_TYPE_3];
                    if (image) {
                        if(imageNameMutable)
                        {
                            [imageNameMutable release];
                            imageNameMutable = nil;
                        }
                        return image;
                    }
                }
                
                tmp = [NSString stringWithFormat:@"%@%@",DayBundleName,imageNameMutable];
            }
            
            image = [UIImage imageNamed:tmp];
            
            if (image) {
                if(imageNameMutable)
                {
                    [imageNameMutable release];
                    imageNameMutable = nil;
                }
                return image;
            }
        }
        //白天,黑夜图片切换
        NSString *tmp;
        
        if (ImageDayNightMode) {
            
            tmp = [NSString stringWithFormat:@"%@%@",NightBundleName,name];
            
        }
        else{
            if (ImageSkinType) {//指定皮肤路径
                
                image = [self imageWithName:name pathType:IMAGEPATH_TYPE_3];
                if (image) {
                    if(imageNameMutable)
                    {
                        [imageNameMutable release];
                        imageNameMutable = nil;
                    }
                    return image;
                }
            }
            tmp = [NSString stringWithFormat:@"%@%@",DayBundleName,name];
        }
        
        image = [UIImage imageNamed:tmp];
        
        if (image) {
            if(imageNameMutable)
            {
                [imageNameMutable release];
                imageNameMutable = nil;
            }
            return image;
        }
        if(imageNameMutable)
        {
            [imageNameMutable release];
            imageNameMutable = nil;
        }
        return [UIImage imageNamed:name];
    }
    else if (IMAGEPATH_TYPE_3 == imagePathType)
    {
        if(imageNameMutable)
        {
            [imageNameMutable release];
            imageNameMutable = nil;
        }
        imageNameMutable = [name mutableCopy];
        
        NSRange ls_extension = [name rangeOfString:@"_ls" options:NSBackwardsSearch];
        
        if (ls_extension.location != NSNotFound) {//需要拉伸
            
            if (ISRETINA) {//高清
                
                [imageNameMutable insertString:retina atIndex:extension.location];
            }
            
            image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",ImageSkinPath,imageNameMutable]];
            
            if (!image) {
                if(imageNameMutable)
                {
                    [imageNameMutable release];
                    imageNameMutable = nil;
                }
                return [UIImage imageWithContentsOfFile:name];
            }
            if(imageNameMutable)
            {
                [imageNameMutable release];
                imageNameMutable = nil;
            }
            return image;
        }
        else
        {
            if (isiPhone) {
                
                if (iPhone6) {
                    //_i6@2x
                    [imageNameMutable insertString:iphone6_i6_HD atIndex:extension.location];
                    
                    image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",ImageSkinPath,imageNameMutable]];
                    if (image) {
                        if(imageNameMutable)
                        {
                            [imageNameMutable release];
                            imageNameMutable = nil;
                        }
                        return image;
                    }
                    //_i6
                    NSRange extension_HD = [imageNameMutable rangeOfString:retina options:NSBackwardsSearch];
                    
                    if (extension_HD.location != NSNotFound) {
                        [imageNameMutable deleteCharactersInRange:extension_HD];
                        image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",ImageSkinPath,imageNameMutable]];
                        if (image) {
                            if(imageNameMutable)
                            {
                                [imageNameMutable release];
                                imageNameMutable = nil;
                            }
                            return image;
                        }
                    }
                    
                    //~iphone
                    NSInteger result = [imageNameMutable replaceOccurrencesOfString:iphone6_i6 withString:iphone_extern options:
                                        NSCaseInsensitiveSearch range:NSMakeRange(0, [imageNameMutable length])];
                    if (result > 0) {
                        image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",ImageSkinPath,imageNameMutable]];
                        if (image) {
                            if(imageNameMutable)
                            {
                                [imageNameMutable release];
                                imageNameMutable = nil;
                            }
                            return image;
                        }
                    }
                    
                    image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",ImageSkinPath,name]];
                    if (image) {
                        if(imageNameMutable)
                        {
                            [imageNameMutable release];
                            imageNameMutable = nil;
                        }
                        return image;
                    }
                    
                }
                else if (iPhone5) {
                    //_i5@2x
                    [imageNameMutable insertString:iphone5_i5_HD atIndex:extension.location];
                    
                    image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",ImageSkinPath,imageNameMutable]];
                    if (image) {
                        if(imageNameMutable)
                        {
                            [imageNameMutable release];
                            imageNameMutable = nil;
                        }
                        return image;
                    }
                    //_i5
                    NSRange extension_HD = [imageNameMutable rangeOfString:retina options:NSBackwardsSearch];
                    
                    if (extension_HD.location != NSNotFound) {
                        [imageNameMutable deleteCharactersInRange:extension_HD];
                        image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",ImageSkinPath,imageNameMutable]];
                        if (image) {
                            if(imageNameMutable)
                            {
                                [imageNameMutable release];
                                imageNameMutable = nil;
                            }
                            return image;
                        }
                    }
                    
                    //~iphone
                    NSInteger result = [imageNameMutable replaceOccurrencesOfString:iphone5_i5 withString:iphone_extern options:
                                        NSCaseInsensitiveSearch range:NSMakeRange(0, [imageNameMutable length])];
                    if (result > 0) {
                        image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",ImageSkinPath,imageNameMutable]];
                        if (image) {
                            if(imageNameMutable)
                            {
                                [imageNameMutable release];
                                imageNameMutable = nil;
                            }
                            return image;
                        }
                    }
                    
                    image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",ImageSkinPath,name]];
                    if (image) {
                        if(imageNameMutable)
                        {
                            [imageNameMutable release];
                            imageNameMutable = nil;
                        }
                        return image;
                    }
                    
                }
                
                if(imageNameMutable)
                {
                    [imageNameMutable release];
                    imageNameMutable = nil;
                }
                imageNameMutable = [name mutableCopy];
                
                if (ISRETINA) {//高清手机
                    
                    //@2x~iphone
                    [imageNameMutable insertString:iphone_retina1 atIndex:extension.location];
                    
                    image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",ImageSkinPath,imageNameMutable]];
                    if (image) {
                        if(imageNameMutable)
                        {
                            [imageNameMutable release];
                            imageNameMutable = nil;
                        }
                        return image;
                    }
                    //@2x
                    NSRange extension_HD = [imageNameMutable rangeOfString:iphone_extern options:NSBackwardsSearch];
                    if (extension_HD.location != NSNotFound) {
                        [imageNameMutable deleteCharactersInRange:extension_HD];
                        image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",ImageSkinPath,imageNameMutable]];
                        if (image) {
                            if(imageNameMutable)
                            {
                                [imageNameMutable release];
                                imageNameMutable = nil;
                            }
                            return image;
                        }
                    }
                    
                    //~iphone
                    NSInteger result = [imageNameMutable replaceOccurrencesOfString:retina withString:iphone_extern options:
                                        NSCaseInsensitiveSearch range:NSMakeRange(0, [imageNameMutable length])];
                    if (result > 0) {
                        image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",ImageSkinPath,imageNameMutable]];
                        if (image) {
                            if(imageNameMutable)
                            {
                                [imageNameMutable release];
                                imageNameMutable = nil;
                            }
                            return image;
                        }
                    }
                    
                    image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",ImageSkinPath,name]];
                    //非高清图片
                    if(imageNameMutable)
                    {
                        [imageNameMutable release];
                        imageNameMutable = nil;
                    }
                    return image;
                    
                }
                else{//非高清手机
                    //非高清图片
                    image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",ImageSkinPath,name]];
                    if (image) {
                        if(imageNameMutable)
                        {
                            [imageNameMutable release];
                            imageNameMutable = nil;
                        }
                        return image;
                    }
                    
                    //~iphone
                    [imageNameMutable insertString:iphone_extern atIndex:extension.location];
                    
                    image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",ImageSkinPath,imageNameMutable]];
                    if (image) {
                        if(imageNameMutable)
                        {
                            [imageNameMutable release];
                            imageNameMutable = nil;
                        }
                        return image;
                    }
                    
                    
                    //@2x~iphone
                    NSInteger result = [imageNameMutable replaceOccurrencesOfString:iphone_extern withString:iphone_retina1 options:
                                        NSCaseInsensitiveSearch range:NSMakeRange(0, [imageNameMutable length])];
                    if (result > 0) {
                        image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",ImageSkinPath,imageNameMutable]];
                        if (image) {
                            if(imageNameMutable)
                            {
                                [imageNameMutable release];
                                imageNameMutable = nil;
                            }
                            return image;
                        }
                    }
                    
                    //@2x
                    NSRange extension_HD = [imageNameMutable rangeOfString:iphone_extern options:NSBackwardsSearch];
                    if (extension_HD.location != NSNotFound) {
                        [imageNameMutable deleteCharactersInRange:extension_HD];
                        
                    }
                    image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",ImageSkinPath,imageNameMutable]];
                    if(imageNameMutable)
                    {
                        [imageNameMutable release];
                        imageNameMutable = nil;
                    }
                    
                    return image;
                }
                
            }
            else//ipad
            {
                if (ISRETINA==1) {//高清手机
                    //@2x~ipad
                 
                    [imageNameMutable insertString:ipad_retina1 atIndex:extension.location];
                    
                    image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",ImageSkinPath,imageNameMutable]];
                    if (image) {
                        if(imageNameMutable)
                        {
                            [imageNameMutable release];
                            imageNameMutable = nil;
                        }
                        return image;
                    }
                    //@2x
                    NSRange extension_HD = [imageNameMutable rangeOfString:ipad_extern options:NSBackwardsSearch];
                    if (extension_HD.location != NSNotFound) {
                        [imageNameMutable deleteCharactersInRange:extension_HD];
                        image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",ImageSkinPath,imageNameMutable]];
                        if (image) {
                            if(imageNameMutable)
                            {
                                [imageNameMutable release];
                                imageNameMutable = nil;
                            }
                            return image;
                        }
                    }
                    
                    //~ipad
                    NSInteger result = [imageNameMutable replaceOccurrencesOfString:retina withString:ipad_extern options:
                                        NSCaseInsensitiveSearch range:NSMakeRange(0, [imageNameMutable length])];
                    if (result > 0) {
                        image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",ImageSkinPath,imageNameMutable]];
                        if (image) {
                            if(imageNameMutable)
                            {
                                [imageNameMutable release];
                                imageNameMutable = nil;
                            }
                            return image;
                        }
                    }
                    
                    image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",ImageSkinPath,name]];
                    //非高清图片
                    if(imageNameMutable)
                    {
                        [imageNameMutable release];
                        imageNameMutable = nil;
                    }
                    return image;
                    
                }
                else{//非高清手机
                    //非高清图片
                    image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",ImageSkinPath,name]];
                    if (image) {
                        if(imageNameMutable)
                        {
                            [imageNameMutable release];
                            imageNameMutable = nil;
                        }
                        return image;
                    }
                    
                    //~ipad
                    [imageNameMutable insertString:ipad_extern atIndex:extension.location];
                    
                    image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",ImageSkinPath,imageNameMutable]];
                    if (image) {
                        if(imageNameMutable)
                        {
                            [imageNameMutable release];
                            imageNameMutable = nil;
                        }
                        return image;
                    }
                    
                    //@2x~ipad
                    NSInteger result = [imageNameMutable replaceOccurrencesOfString:ipad_extern withString:ipad_retina1 options:
                                        NSCaseInsensitiveSearch range:NSMakeRange(0, [imageNameMutable length])];
                    if (result > 0) {
                        image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",ImageSkinPath,imageNameMutable]];
                        if (image) {
                            if(imageNameMutable)
                            {
                                [imageNameMutable release];
                                imageNameMutable = nil;
                            }
                            return image;
                        }
                    }
                    
                    //@2x
                    NSRange extension_HD = [imageNameMutable rangeOfString:ipad_extern options:NSBackwardsSearch];
                    if (extension_HD.location != NSNotFound) {
                        [imageNameMutable deleteCharactersInRange:extension_HD];
                        
                    }
                    image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",ImageSkinPath,imageNameMutable]];
                    if(imageNameMutable)
                    {
                        [imageNameMutable release];
                        imageNameMutable = nil;
                    }
                    return image;
                }
            }
        }
    }
    else if (IMAGEPATH_TYPE_4 == imagePathType)
    {
        if(imageNameMutable)
        {
            [imageNameMutable release];
            imageNameMutable = nil;
        }
        imageNameMutable = [name mutableCopy];
        
        NSRange ls_extension = [name rangeOfString:@"_ls" options:NSBackwardsSearch];
        
        if (ls_extension.location != NSNotFound) {//需要拉伸
            
            if (ISRETINA) {//高清
                
                [imageNameMutable insertString:retina atIndex:extension.location];
            }
            
            image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@",imageNameMutable]];
            
            if (!image) {
                if(imageNameMutable)
                {
                    [imageNameMutable release];
                    imageNameMutable = nil;
                }
                return [UIImage imageWithContentsOfFile:name];
            }
            if(imageNameMutable)
            {
                [imageNameMutable release];
                imageNameMutable = nil;
            }
            return image;
        }
        else
        {
            if (isiPhone) {
                if (iPhone6) {
                    //_i5@2x
                    [imageNameMutable insertString:iphone6_i6_HD atIndex:extension.location];
                    
                    image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@",imageNameMutable]];
                    if (image) {
                        if(imageNameMutable)
                        {
                            [imageNameMutable release];
                            imageNameMutable = nil;
                        }
                        return image;
                    }
                    //_i5
                    NSRange extension_HD = [imageNameMutable rangeOfString:retina options:NSBackwardsSearch];
                    
                    if (extension_HD.location != NSNotFound) {
                        [imageNameMutable deleteCharactersInRange:extension_HD];
                        image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@",imageNameMutable]];
                        if (image) {
                            if(imageNameMutable)
                            {
                                [imageNameMutable release];
                                imageNameMutable = nil;
                            }
                            return image;
                        }
                    }
                    
                    //~iphone
                    NSInteger result = [imageNameMutable replaceOccurrencesOfString:iphone6_i6 withString:iphone_extern options:
                                        NSCaseInsensitiveSearch range:NSMakeRange(0, [imageNameMutable length])];
                    if (result > 0) {
                        image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@",imageNameMutable]];
                        if (image) {
                            if(imageNameMutable)
                            {
                                [imageNameMutable release];
                                imageNameMutable = nil;
                            }
                            return image;
                        }
                    }
                    
                    image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@",name]];
                    if (image) {
                        if(imageNameMutable)
                        {
                            [imageNameMutable release];
                            imageNameMutable = nil;
                        }
                        return image;
                    }
                    
                }
                else if (iPhone5) {
                    //_i5@2x
                    [imageNameMutable insertString:iphone5_i5_HD atIndex:extension.location];
                    
                    image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@",imageNameMutable]];
                    if (image) {
                        if(imageNameMutable)
                        {
                            [imageNameMutable release];
                            imageNameMutable = nil;
                        }
                        return image;
                    }
                    //_i5
                    NSRange extension_HD = [imageNameMutable rangeOfString:retina options:NSBackwardsSearch];
                    
                    if (extension_HD.location != NSNotFound) {
                        [imageNameMutable deleteCharactersInRange:extension_HD];
                        image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@",imageNameMutable]];
                        if (image) {
                            if(imageNameMutable)
                            {
                                [imageNameMutable release];
                                imageNameMutable = nil;
                            }
                            return image;
                        }
                    }
                    
                    //~iphone
                    NSInteger result = [imageNameMutable replaceOccurrencesOfString:iphone5_i5 withString:iphone_extern options:
                                        NSCaseInsensitiveSearch range:NSMakeRange(0, [imageNameMutable length])];
                    if (result > 0) {
                        image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@",imageNameMutable]];
                        if (image) {
                            if(imageNameMutable)
                            {
                                [imageNameMutable release];
                                imageNameMutable = nil;
                            }
                            return image;
                        }
                    }
                    
                    image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@",name]];
                    if (image) {
                        if(imageNameMutable)
                        {
                            [imageNameMutable release];
                            imageNameMutable = nil;
                        }
                        return image;
                    }
                    
                }
                
                if(imageNameMutable)
                {
                    [imageNameMutable release];
                    imageNameMutable = nil;
                }
                imageNameMutable = [name mutableCopy];
                
                if (ISRETINA) {//高清手机
                    
                    //@2x~iphone
                    [imageNameMutable insertString:iphone_retina1 atIndex:extension.location];
                    
                    image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@",imageNameMutable]];
                    if (image) {
                        if(imageNameMutable)
                        {
                            [imageNameMutable release];
                            imageNameMutable = nil;
                        }
                        return image;
                    }
                    //@2x
                    NSRange extension_HD = [imageNameMutable rangeOfString:iphone_extern options:NSBackwardsSearch];
                    if (extension_HD.location != NSNotFound) {
                        [imageNameMutable deleteCharactersInRange:extension_HD];
                        image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@",imageNameMutable]];
                        if (image) {
                            if(imageNameMutable)
                            {
                                [imageNameMutable release];
                                imageNameMutable = nil;
                            }
                            return image;
                        }
                    }
                    
                    //~iphone
                    NSInteger result = [imageNameMutable replaceOccurrencesOfString:retina withString:iphone_extern options:
                                        NSCaseInsensitiveSearch range:NSMakeRange(0, [imageNameMutable length])];
                    if (result > 0) {
                        image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@",imageNameMutable]];
                        if (image) {
                            if(imageNameMutable)
                            {
                                [imageNameMutable release];
                                imageNameMutable = nil;
                            }
                            return image;
                        }
                    }
                    
                    image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@",name]];
                    //非高清图片
                    if(imageNameMutable)
                    {
                        [imageNameMutable release];
                        imageNameMutable = nil;
                    }
                    return image;
                    
                }
                else{//非高清手机
                    //非高清图片
                    image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@",name]];
                    if (image) {
                        if(imageNameMutable)
                        {
                            [imageNameMutable release];
                            imageNameMutable = nil;
                        }
                        return image;
                    }
                    
                    //~iphone
                    [imageNameMutable insertString:iphone_extern atIndex:extension.location];
                    
                    image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@",imageNameMutable]];
                    if (image) {
                        if(imageNameMutable)
                        {
                            [imageNameMutable release];
                            imageNameMutable = nil;
                        }
                        return image;
                    }
                    
                    
                    //@2x~iphone
                    NSInteger result = [imageNameMutable replaceOccurrencesOfString:iphone_extern withString:iphone_retina1 options:
                                        NSCaseInsensitiveSearch range:NSMakeRange(0, [imageNameMutable length])];
                    if (result > 0) {
                        image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@",imageNameMutable]];
                        if (image) {
                            if(imageNameMutable)
                            {
                                [imageNameMutable release];
                                imageNameMutable = nil;
                            }
                            return image;
                        }
                    }
                    
                    //@2x
                    NSRange extension_HD = [imageNameMutable rangeOfString:iphone_extern options:NSBackwardsSearch];
                    if (extension_HD.location != NSNotFound) {
                        [imageNameMutable deleteCharactersInRange:extension_HD];
                        
                    }
                    image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@",imageNameMutable]];
                    if(imageNameMutable)
                    {
                        [imageNameMutable release];
                        imageNameMutable = nil;
                    }
                    
                    return image;
                }
                
            }
            else//ipad
            {
                if (ISRETINA==1) {//高清手机
                    //@2x~ipad
                    
                    [imageNameMutable insertString:ipad_retina1 atIndex:extension.location];
                    
                    image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@",imageNameMutable]];
                    if (image) {
                        if(imageNameMutable)
                        {
                            [imageNameMutable release];
                            imageNameMutable = nil;
                        }
                        return image;
                    }
                    //@2x
                    NSRange extension_HD = [imageNameMutable rangeOfString:ipad_extern options:NSBackwardsSearch];
                    if (extension_HD.location != NSNotFound) {
                        [imageNameMutable deleteCharactersInRange:extension_HD];
                        image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@",imageNameMutable]];
                        if (image) {
                            if(imageNameMutable)
                            {
                                [imageNameMutable release];
                                imageNameMutable = nil;
                            }
                            return image;
                        }
                    }
                    
                    //~ipad
                    NSInteger result = [imageNameMutable replaceOccurrencesOfString:retina withString:ipad_extern options:
                                        NSCaseInsensitiveSearch range:NSMakeRange(0, [imageNameMutable length])];
                    if (result > 0) {
                        image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@",imageNameMutable]];
                        if (image) {
                            if(imageNameMutable)
                            {
                                [imageNameMutable release];
                                imageNameMutable = nil;
                            }
                            return image;
                        }
                    }
                    
                    image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@",name]];
                    //非高清图片
                    if(imageNameMutable)
                    {
                        [imageNameMutable release];
                        imageNameMutable = nil;
                    }
                    return image;
                    
                }
                else{//非高清手机
                    //非高清图片
                    image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@",name]];
                    if (image) {
                        if(imageNameMutable)
                        {
                            [imageNameMutable release];
                            imageNameMutable = nil;
                        }
                        return image;
                    }
                    
                    //~ipad
                    [imageNameMutable insertString:ipad_extern atIndex:extension.location];
                    
                    image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@",imageNameMutable]];
                    if (image) {
                        if(imageNameMutable)
                        {
                            [imageNameMutable release];
                            imageNameMutable = nil;
                        }
                        return image;
                    }
                    
                    //@2x~ipad
                    NSInteger result = [imageNameMutable replaceOccurrencesOfString:ipad_extern withString:ipad_retina1 options:
                                        NSCaseInsensitiveSearch range:NSMakeRange(0, [imageNameMutable length])];
                    if (result > 0) {
                        image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@",imageNameMutable]];
                        if (image) {
                            if(imageNameMutable)
                            {
                                [imageNameMutable release];
                                imageNameMutable = nil;
                            }
                            return image;
                        }
                    }
                    
                    //@2x
                    NSRange extension_HD = [imageNameMutable rangeOfString:ipad_extern options:NSBackwardsSearch];
                    if (extension_HD.location != NSNotFound) {
                        [imageNameMutable deleteCharactersInRange:extension_HD];
                        
                    }
                    image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@",imageNameMutable]];
                    if(imageNameMutable)
                    {
                        [imageNameMutable release];
                        imageNameMutable = nil;
                    }
                    return image;
                }
            }
        }
    }
    if(imageNameMutable)
    {
        [imageNameMutable release];
        imageNameMutable = nil;
    }
    return nil;
}

//设置白天黑夜模式
+ (void)setImageDayNightMode:(BOOL)dayNightMode
{
    ImageDayNightMode = dayNightMode;
}

//设置皮肤类型：NO 默认 YES 指定皮肤
+ (void)setImageSkinType:(BOOL)skinType SkinPath:(NSString *)skinPath
{
    ImageSkinType = skinType;
    if (ImageSkinPath) {
        [ImageSkinPath release];
        ImageSkinPath = nil;
    }
    if(skinPath)
    {
        ImageSkinPath = [[NSString alloc] initWithString:skinPath];
    }
}


/**
 *	获取图片 扇形部分
 *
 *	@param	image	需要剪切的图片
 *	@param	startDegree	剪切的起始度数。以正北为基准 范围（0 - 360）
 *	@param	endDegree	剪切的结束度数。以正北为基准 范围（0 - 360）
 *
 *	@return	返回剪切后的扇形图片
 */
+ (UIImage *)getRoundImageWithImage:(UIImage *)image from:(int)startDegree to:(int)endDegree
{
    if (![image isKindOfClass:[UIImage class]])
    {
        return nil;
    }
    startDegree = startDegree - 90;
    endDegree = endDegree - 90;
    CGSize size = image.size;
    
    CGPoint center = CGPointMake(size.width/2, size.height/2);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextMoveToPoint(context, center.x, center.y);
    CGContextAddArc(context, center.x, center.y, size.width/2, startDegree* M_PI / 180.0, endDegree* M_PI / 180.0, 0);
    CGContextClosePath(context);
    CGContextClip(context);
    CGContextTranslateCTM(context, 0,size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextDrawImage(context, CGRectMake(0, 0, size.width, size.height), image.CGImage);
    UIImage *changeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return changeImage;
}

@end

//
//  GDSkinColor.m
//  AutoNavi
//
//  Created by jiangshu.fu on 13-11-21.
//
//

#import "GDSkinColor.h"
#import "GDSkinDownloadData.h"

@interface GDSkinColor ()
{
}

@property (nonatomic,retain) NSDictionary * dictionarySkinColor;

@end


@implementation GDSkinColor

@synthesize dictionarySkinColor = _dictionarySkinColor;

#pragma mark ---  单例  ---
+ (GDSkinColor *)sharedInstance {
    static GDSkinColor *gdSkinColorShared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        gdSkinColorShared = [[GDSkinColor alloc] init];
    });
	return gdSkinColorShared;
}


- (id) init
{
    self = [super init];
    if (self) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"colorConfig" ofType:@"plist"];
        _dictionarySkinColor = [[NSDictionary alloc] initWithContentsOfFile:path];
    }
    return self;
}


/***
 * @name    通过key值获取
 * @param   传入的key值
 * @return  返回的颜色值
 * @author  by bazinga
 ***/
- (UIColor *) getColorByKey:(NSString *) key
{
    //默认返回白色颜色
    UIColor *returnColor = RGBACOLOR(0.0f, 0.0f, 0.0f,1.0f);
    if(_dictionarySkinColor)
    {
        NSString *colorString = [_dictionarySkinColor objectForKey:key];
    
        if(colorString != nil)
        {
            NSArray *colorRGB = [colorString componentsSeparatedByString:@","];
            @try
            {
                if([colorRGB count] == 3)
                {
                    returnColor = RGBCOLOR([[colorRGB objectAtIndex:0] floatValue],
                                           [[colorRGB objectAtIndex:1] floatValue],
                                           [[colorRGB objectAtIndex:2] floatValue]);
                }
                else if([colorRGB count] == 4)
                {
                    returnColor = RGBACOLOR([[colorRGB objectAtIndex:0] floatValue],
                                            [[colorRGB objectAtIndex:1] floatValue],
                                            [[colorRGB objectAtIndex:2] floatValue],
                                            [[colorRGB objectAtIndex:3] floatValue]);
                }
            }
            @catch (NSException *ex)
            {
                return returnColor;
            }
        }
    }
    
    return returnColor;
}


/***
 * @name    通过key值获取RGB的数值
 * @param   传入的key值
 * @return  RGB的数组
 * @author  by bazinga
 ***/
- (NSArray *) getArrayByKey:(NSString *) key
{
    //默认返回白色透明图片
    if(_dictionarySkinColor)
    {
        NSString *colorString = [_dictionarySkinColor objectForKey:key];
        
        if(colorString != nil)
        {
            NSArray *colorRGB = [colorString componentsSeparatedByString:@","];
            if([colorRGB count] == 3 || [colorRGB count] == 4)
            {

                return colorRGB;
            }

        }
    }
    
    return nil;
}


/***
 * @name    刷新获取单例对象中的字典属性值
 * @param   plisth文件的路径名称
 * @author  by bazinga
 ***/
- (void) refresh:(NSString *)plistUrl
{
//    NSDictionary *dictionary = [[NSDictionary alloc] initWithContentsOfFile:plistUrl];
//    if(dictionary)
//    {
//        self.dictionarySkinColor = dictionary;
//        [dictionary release];
//    }
}

/***
 * @name    获取当前皮肤的版本信息
 * @param
 * @author  by bazinga
 ***/
- (NSString *)getSkinVersion
{
    NSString *returnString = [_dictionarySkinColor objectForKey:@"Version"];
    if(!returnString)
    {
        returnString = @"1.0";
    }
    return returnString;
}

/***
 * @name    根据皮肤id，获取皮肤名称
 * @param   皮肤id
 * @author  by bazinga
 ***/
- (NSString *)getSkinNameByID:(NSString *)skinId
{
    GDSkinDownloadData *skinData = [[[GDSkinDownloadData alloc] init] autorelease];
    NSMutableArray *skinPathArray = [NSMutableArray arrayWithArray:[skinData getSkinData]];
    NSString *arrayString = @"";
    for (int i = 0; i < skinPathArray.count; i++) {
       if( [[[skinPathArray objectAtIndex:i] objectForKey:CONFIG_SKIN_ID] isEqualToString:skinId])
       {
           arrayString = [[skinPathArray objectAtIndex:i] objectForKey:CONFIG_SKIN_NAME] ;
       }
    }
    return  [self getSkinTitle:arrayString];
}


/***
 * @name    根据皮肤id，获取皮肤的文件夹
 * @param   皮肤id
 * @author  by bazinga
 ***/
- (NSString *)getFolderByID:(int)skinId
{
    GDSkinDownloadData *skinData = [[[GDSkinDownloadData alloc] init] autorelease];
    NSMutableArray *skinPathArray = [NSMutableArray arrayWithArray:[skinData getSkinData]];
    NSString *arrayString = nil;
    for (int i = 0; i < skinPathArray.count; i++) {
        if( [[[skinPathArray objectAtIndex:i] objectForKey:CONFIG_SKIN_ID] intValue] == skinId)
        {
            arrayString = [[skinPathArray objectAtIndex:i] objectForKey:CONFIG_SKIN_FLODER] ;
        }
    }
    return  arrayString;
}

/***
 * @name    根据传入的皮肤字符串，获取对应语言的皮肤名称
 * @param   传入皮肤字符串，使用“,”进行区分
 * @author  by bazinga
 ***/
- (NSString *)getSkinTitle:(NSString *)arrayString
{
    NSArray *stringArray = [arrayString componentsSeparatedByString:@","];
    NSString *returnTitle = @"";
    if(stringArray.count >= 3)
    {
        returnTitle = [stringArray objectAtIndex:fontType];
    }
    return returnTitle;
}

/***
 * @name    获取plist文件中的版本号
 * @param   plisth文件夹名称
 * @author  by bazinga
 ***/
- (NSString *)getVersionByPath:(NSString *)folder
{
    NSString *path = [NSString stringWithFormat:@"%@%@%@",Skin_path,folder,SKIN_PLIST_NAME];
    NSDictionary *dictionary = [[[NSDictionary alloc] initWithContentsOfFile:path] autorelease];
    NSString *version = @"";
    if(dictionary)
    {
        version = (NSString *)[dictionary objectForKey:@"Version"];
    }
    
    return version;
}


@end

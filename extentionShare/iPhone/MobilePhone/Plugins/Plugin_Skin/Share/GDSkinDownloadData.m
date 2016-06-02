//
//  GDSkinDownloadData.m
//  AutoNavi
//
//  Created by jiangshu-fu on 13-12-19.
//
//

#import "GDSkinDownloadData.h"
#import "MWSkinDownloadManager.h"
#import "plugin-cdm-Task.h"
#import "GDSkinColor.h"
#import "MWSkinAndCarListRequest.h"

//获取下载状态字符串 a -- int 类型
#define getSkinStatus(a)  [NSString stringWithFormat:@"%d",(a)]



@implementation GDSkinDownloadData

@synthesize  delegate = _delegate;
@synthesize arrayData = _arrayData;

- (id) init
{
    self  = [super init];
    if(self)
    {
        //向document中获取数据
        _arrayData = [[NSMutableArray alloc]init];
        NSArray *array = [NSArray arrayWithContentsOfFile:skinConfigDocumentPath];
        if(array.count == 0)
        {
            //如果请求不到，就从bundle中获取数据
            array = [NSMutableArray arrayWithContentsOfFile:skinConfigBundlePath];
        }
        
        [self setSkinData:array];
        
        _skinAndCarRequest = [[MWSkinAndCarListRequest alloc] init];
    }
    return self;
}

- (void) dealloc
{
    
    if(_arrayData)
    {
        [_arrayData writeToFile:skinConfigDocumentPath atomically:YES];
        [_arrayData release];
        _arrayData = nil;
    }
    if(_skinAndCarRequest)
    {
        [_skinAndCarRequest release];
        _skinAndCarRequest = nil;
    }
    _delegate = nil;
    [super dealloc];
}

#pragma  mark -
#pragma  mark ---  数组数据设置读取修改  ---
/***
 * @name    获取皮肤的数据（皮肤界面的数据的数组）
 * @param
 * @author  by bazinga
 ***/
- (NSArray *) getSkinData
{
    return self.arrayData;
}



/***
 * @name    获取皮肤的数据（皮肤界面的数据的数组）
 * @param
 * @author  by bazinga
 ***/
- (void) setSkinData:(NSArray *)setArray
{
    //移除所有数据
    [self.arrayData removeAllObjects];
    //把NSDictionary 转化成 可变的 NSMutableDictionary
    for (int  i = 0; i < ((NSArray *)setArray).count; i++) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[setArray objectAtIndex:i]];
        [self.arrayData  addObject:dict];
    }
    //self.arrayData = [NSMutableArray arrayWithArray:result];
    for (int  i = 0; i < self.arrayData.count; i++)
    {
        int taskID = [[ [self.arrayData objectAtIndex:i] objectForKey:CONFIG_SKIN_ID] intValue];
        //获取下载任务
        Task *task = [[MWSkinDownloadManager sharedInstance] getTaskWithTaskID:taskID];
        //如果任务存在，就判断任务下载状态
        if(task)
        {
            if (TASK_STATUS_FINISH == task.status)  //  下载状态完成，需要判断是否要更新
            {
                NSString *stringFolder = [[[self arrayData]objectAtIndex:i] objectForKey:CONFIG_SKIN_FLODER];
                NSString *currentVersion = [[GDSkinColor sharedInstance] getVersionByPath:stringFolder];
                NSString *downloadVersion = [[self.arrayData objectAtIndex:i] objectForKey:CONFIG_SKIN_VERSION];
                //如果当前版本和网络下载版本相同，说明已经下载完成
                if([currentVersion isEqualToString:downloadVersion])
                {
                    [[self.arrayData objectAtIndex:i]  setObject:[NSNumber numberWithInt:SKIN_DOWNLOAD_STATUS]
                                                          forKey:CONFIG_SKIN_HASDOWNLOAD];
                }
                else
                {
                    [[self.arrayData objectAtIndex:i]  setObject:[NSNumber numberWithInt:SKIN_UPDATE_STATUS]
                                                          forKey:CONFIG_SKIN_HASDOWNLOAD];
                }
            }
            else    //未下载完成，设置为0
            {
                [[self.arrayData objectAtIndex:i]  setObject:[NSNumber numberWithInt:SKIN_NO_DOWNLOAD_STATUS]
                                                      forKey:CONFIG_SKIN_HASDOWNLOAD];
            }
        }
        else    //任务不存在，那么，就把下载状态置为0
        {
            if([[[self.arrayData objectAtIndex:i] objectForKey:CONFIG_SKIN_ID] intValue] == [SKIN_DEFAULT_ID intValue])
            {
                [[self.arrayData objectAtIndex:i] setObject:[NSNumber numberWithInt:SKIN_DOWNLOAD_STATUS]
                                                     forKey:CONFIG_SKIN_HASDOWNLOAD];
            }
            else
            {
                [[self.arrayData objectAtIndex:i] setObject:[NSNumber numberWithInt:SKIN_NO_DOWNLOAD_STATUS]
                                                     forKey:CONFIG_SKIN_HASDOWNLOAD];
            }
        }
    }

    [self.arrayData writeToFile:skinConfigDocumentPath atomically:YES];
}

/***
 * @name    在皮肤的数组对象中，添加数据
 * @param
 * @author  by bazinga
 ***/
- (void) addData:(NSMutableDictionary *)dict
{
    [self.arrayData addObject:dict];
}

/***
 * @name    更具key值，来替换数组对象中的字典数据
 * @param   key - 索引值   dict - 字典数据
 * @author  by bazinga
 ***/
- (void) replaceDataByKey:(NSString *)key withData:(NSMutableDictionary *)dict
{
    for (int i = 0; i < self.arrayData.count; i++)
    {
        if([[[self.arrayData objectAtIndex:i] objectForKey:key] isEqualToString:[dict objectForKey:key]])
        {
            [self.arrayData replaceObjectAtIndex:i withObject:dict];
        }
    }
}

#pragma  mark -
#pragma mark ---  向服务器请求数据  ---
/***
 * @name    服务器请求数据
 * @param
 * @author  by bazinga
 ***/
- (void) requestPlistData
{
    //请求plist数据
    [_skinAndCarRequest Net_SkinListRequest:REQ_SKIN_DATA delegate:self];

}

#pragma  mark -
#pragma mark ---  请求数据委托函数  ---
//id类型可以是NSDictionary NSArray
- (void)requestToViewCtrWithRequestType:(RequestType)requestType didFinishLoadingWithResult:(id)result
{
    if([result isKindOfClass:[NSDictionary class]]) //图片文件
    {
        //返回URL地址，通过URL地址，读取缓存，获取图片
        if(_delegate && [_delegate respondsToSelector:@selector(refreshImageByUrl:withImage:)])
        {
            NSArray *keys = [result allKeys];
            for (id key in keys)
            {
                [_delegate refreshImageByUrl:key withImage:[result objectForKey:key]];
                NSLog(@"图片文件:%@",key);
            }
        }
        
    }
    else if([result isKindOfClass:[NSArray class]])    //plist文件
    {
        //获取PLIST文件列表
        if(_delegate && [_delegate respondsToSelector:@selector(refreshPlistData)])
        {
            [self setSkinData:result];
            [_delegate refreshPlistData];
        }
        NSLog(@"plist文件");
    }
}
//上层需根据error的值来判断网络连接超时还是网络连接错误
- (void)requestToViewCtrWithRequestType:(RequestType)requestType didFailWithError:(NSError *)error
{
    NSLog(@"GDSkinDownloadData 请求超时");
}
@end

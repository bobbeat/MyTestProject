//
//  CarServicItemView.m
//  AutoNavi
//
//  Created by jiangshu-fu on 14-3-6.
//
//

#import "CarServiceItemView.h"
#import "MWCarOwnerServiceManage.h"
#import "GDCacheManager.h"
#import "MWSkinAndCarListRequest.h"
#import "NewRedPointData.h"

@implementation CarServiceItemView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

#pragma mark -  ---  对象初始化  ---
/***
 * @name    初始化对象
 * @param   itemImage —— 按钮的图片
            carLevel  —— 服务的级别（默认,推荐,更新,禁用）
            itemText  —— 服务的名称
 * @author  by bazinga
 ***/
- (id) initWithItemImage:(UIImage *)itemImage
               withLevel:(int) carLevel
            withItemText:(NSString *)itemText
{
    self = [super init];
    if(self)
    {
        //初始化控件
        _buttonItem = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:_buttonItem];
        
        _imageViewLevel = [[UIImageView alloc]init];
        [self addSubview:_imageViewLevel];
        [_imageViewLevel release];
        
        _labelItem = [[UILabel alloc]init];
        [self addSubview:_labelItem];
        [_labelItem release];

        //设置控件的显示数据
        [self setItemImage:itemImage];
        [self setItemLevel:carLevel withIsVip:0];
        _carLevel = carLevel;
        [self setItemText:itemText];
        
        //添加事件响应 --点击事件和长按事件
        [_buttonItem addTarget:self action:@selector(buttonPress:) forControlEvents:UIControlEventTouchUpInside];
        
        UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(buttonLongPress:)];
        recognizer.delegate = self;
        recognizer.minimumPressDuration = 1.0f;
        [_buttonItem addGestureRecognizer:recognizer];
        [recognizer release];
        //初始化置为空
        self.itemClick = nil;
        self.itemLongPress = nil;
        self.itemData = nil;
        //设置位置
        [self setLocation];
        //控件属性设置
        _labelItem.backgroundColor = GETSKINCOLOR(MAIN_LABEL_CLEARBACK_COLOR);
        _labelItem.font = [UIFont systemFontOfSize:12.0f];
        _labelItem.textAlignment = UITextAlignmentCenter;
        _labelItem.textColor = GETSKINCOLOR(CAR_SERVICE_LABEL_TEXT_COLOR);
        //长按的状态默认为NO
        _isLongPress = NO;
        
        _imageLoadRequest = [[MWSkinAndCarListRequest alloc] init];
        _imageLoadRequest.delegate = self;
    }
    return self;
}

/* ↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑ */
/* ---             上面的三个参数的细化               ---  */
/* ↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑ */
- (void) setItemImage:(UIImage *)itemImage
{
    if(itemImage)
    {
        [_buttonItem setBackgroundImage:itemImage forState:UIControlStateNormal];
    }
    else
    {
        [_buttonItem setBackgroundImage:IMAGE(@"carServiceNilItem.png", IMAGEPATH_TYPE_1) forState:UIControlStateNormal];
    }
}

//服务状态（非空 1-未安装; 2-未安装,不适合安装; 3-有更新; 4-有更新,不适合安装; 5-强制更新6-禁用;7-非法）
//vip:
/***
 * @name    设置项目的等级
 * @param   carLevel ： 服务状态（非空 1-未安装; 2-未安装,不适合安装; 3-有更新; 4-有更新,不适合安装; 5-强制更新6-禁用;7-非法） -1 : 非推荐，更多
 * @param   vip : 0 -- 正常状态     1 -- 推荐
 * @author  by bazinga
 ***/
- (void) setItemLevel:(int) carLevel withIsVip:(int)vip
{
//    if(vip == 1 && self.itemData.serviceStatus != 0)
//    {
//        _imageViewLevel.hidden = NO;
//        [_imageViewLevel setImage:IMAGE(@"carServiceRecommend.png", IMAGEPATH_TYPE_1)];
//    }
//    else
//    {
    if (self.itemData.serviceID == nil && carLevel != -1 ) {
        return;
    }
    _carLevel = carLevel;
    NSString *type = (carLevel != -1 ? RED_TYPE_RECOMMEND : RED_TYPE_NO_RECOMMEND);
    BOOL isCarNew = NO;
    if(carLevel == -1)
    {
        //如果非推荐，并且没有安装完成，才去判断是否要在更多处显示红点
//        NSArray *tempArray = [[MWCarOwnerServiceManage sharedInstance] carOwnerMoreTaskList];
//        NSArray *bestArray = [[MWCarOwnerServiceManage sharedInstance] carOwnerTaskList];
//        for (MWCarOwnerServiceTask *temp in [[MWCarOwnerServiceManage sharedInstance] carOwnerMoreTaskList])
//        {
//            NSLog(@"ID = %@",temp.serviceID);
//        }
        //非推荐的数组,获取非推荐数组，通过遍历非推荐数组，判断显示的红点，是否下载完成，
        //下载完成则不在更多显示，反之，则显示
        NSDictionary *noRecommendDictionary = [[NewRedPointData sharedInstance] getArrayByType:type];
        if([noRecommendDictionary isKindOfClass:[NSDictionary class]])
        {
            NSArray *noRecommendArrayKeys = [noRecommendDictionary allKeys];
            for (NSString *key in noRecommendArrayKeys)
            {
                if([[[noRecommendDictionary  objectForKey:key] objectForKey:RED_POINT_ISPRESS] boolValue])
                {
                    NSString *serviceId = key;
                    MWCarOwnerServiceTask *task = [[MWCarOwnerServiceManage sharedInstance] getTaskWithTaskID:serviceId];
                    if(task == nil || task.status != TASK_STATUS_FINISH)
                    {
                        isCarNew =  YES;
                        break;
                    }

                }
            }
            
        }
    }
    else
    {
        //如果该应用是非推荐，并且已安装，在该应用处显示红点，而不是在更多处显示红点
        type = (self.itemData.vip == 1 ? RED_TYPE_RECOMMEND : RED_TYPE_NO_RECOMMEND);
        isCarNew = [[NewRedPointData sharedInstance] getValueByType:type
                                                             withID:self.itemData.serviceID];
    }
    
    if(isCarNew && carLevel != 3 && carLevel != 4 && carLevel != 5)
    {
        NSLog(@"%@ ------ yes",self.itemData.serviceID);
        _imageViewLevel.hidden = NO;
        [_imageViewLevel setImage:IMAGE(@"main_newPointMore.png", IMAGEPATH_TYPE_1)];
    }
    else
    {
    
        switch (carLevel)
        {
            case 3:
            case 4:
            case 5:
            {
                _imageViewLevel.hidden = NO;
                [_imageViewLevel setImage:IMAGE(@"carServiceUpdate.png", IMAGEPATH_TYPE_1)];
                NSLog(@"%@ ------ carServiceUpdate.png",self.itemData.serviceID);
            }
                break;
            case 6:
            case 7:
            {
                _imageViewLevel.hidden = NO;
                [_imageViewLevel setImage:IMAGE(@"carServiceDisable.png", IMAGEPATH_TYPE_1)];
                NSLog(@"%@ ------ carServiceDisable.png",self.itemData.serviceID);
            }
                break;
            default:
            {
                
                NSLog(@"%@ ------ no",self.itemData.serviceID);
                _imageViewLevel.hidden = YES;
            }
                break;
        }
    }
    [self setImageLevelFrame];
}

- (void) setItemText:(NSString *)itemText
{
    _labelItem.text = itemText;
}


/***
 * @name    设置单个项目的数据
 * @param   itemData ： 请求到的数据
 * @author  by bazinga
 ***/
- (void) setItemData:(MWCarOwnerServiceTask *)itemData
{
    _itemData = itemData;
    if(itemData)
    {
        if (itemData.serviceStatus == 1 || itemData.serviceStatus == 2)
        {
            [self setItemText: [[MWCarOwnerServiceManage sharedInstance] getStringFormJson:self.itemData.title]];
            [self setItemLevel:self.itemData.serviceStatus withIsVip:self.itemData.vip];
            [self loadImageWithUrl:self.itemData.iconUrl];
        }
        else//已安装
        {
            NSDictionary *infoDictionary = [[MWCarOwnerServiceManage sharedInstance] getInstallCarOwnerServiceInfoWithTaskID:itemData.serviceID];
            NSString *title  = @"";
            switch (fontType) {
                case 0:
                {
                    title = [infoDictionary objectForKey:CAR_SERVICE_TITLE_CN];
                }
                    break;
                case 1:
                {
                    title = [infoDictionary objectForKey:CAR_SERVICE_TITLE_TW];
                }
                    break;
                case 2:
                {
                    title = [infoDictionary objectForKey:CAR_SERVICE_TITLE_EN];
                }
                    break;
                    
                default:
                    break;
            }
            
            [self setItemText: title];
            
            [self setItemLevel:self.itemData.serviceStatus withIsVip:self.itemData.vip];
            
            [self setItemImage:[[MWCarOwnerServiceManage sharedInstance] getInstallCarOwnerServiceIconWithTaskID:itemData.serviceID]];
        }
        
    }
}

- (void) dealloc
{
    if(_itemClick)
    {
        [_itemClick release];
        _itemClick = nil;
    }
    if(_itemLongPress)
    {
        [_itemLongPress release];
        _itemLongPress = nil;
    }
    _imageLoadRequest.delegate = nil;
    if(_imageLoadRequest)
    {
        [_imageLoadRequest release];
        _imageLoadRequest = nil;
    }
    [super dealloc];
}

- (void) removeFromSuperview
{
    
    if(_itemClick)
    {
        [_itemClick release];
        _itemClick = nil;
    }
    if(_itemLongPress)
    {
        [_itemLongPress release];
        _itemLongPress = nil;
    }
    _imageLoadRequest.delegate = nil;
    if(_imageLoadRequest)
    {
        [_imageLoadRequest release];
        _imageLoadRequest = nil;
    }
    [super removeFromSuperview];
}

#pragma mark -  ---  控件位置修改  ---
- (void) setLocation
{
    if(isiPhone)
    {
        self.frame = CGRectMake(0.0f, 0.0f, 60.0f, CARSERVICE_ITEMVIEW_HEIGHT);
        //控件大小
        _buttonItem.frame = CGRectMake(0.0f,0.0f, 60.0f, 60.0f);
        _labelItem.frame = CGRectMake(0, 0, self.frame.size.width+15, 13.0f);
        //控件位置
        _buttonItem.center = CGPointMake(self.frame.size.width / 2, _buttonItem.frame.size.height / 2);
        _labelItem.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height - _labelItem.frame.size.height / 2);
    }
    else
    {
        self.frame = CGRectMake(0.0f, 0.0f, 72.0f, CARSERVICE_ITEMVIEW_HEIGHT);
        //控件大小
        _buttonItem.frame = CGRectMake(0.0f,0.0f, 72.0f, 72.0f);
        _labelItem.frame = CGRectMake(0, 0, self.frame.size.width, 13.0f);
        //控件位置
        _buttonItem.center = CGPointMake(self.frame.size.width / 2, _buttonItem.frame.size.height / 2);
        _labelItem.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height - _labelItem.frame.size.height / 2);
    }
    [self setImageLevelFrame];
}

- (void)  setImageLevelFrame
{
    if(isiPhone)
    {
        _imageViewLevel.frame = CGRectMake(0.0f, 0.0f, _imageViewLevel.image.size.width , _imageViewLevel.image.size.height );
        _imageViewLevel.center = CGPointMake(self.frame.size.width, 0.0f);

    }
    else
    {
        _imageViewLevel.frame = CGRectMake(0.0f, 0.0f, _imageViewLevel.image.size.width , _imageViewLevel.image.size.height);
        _imageViewLevel.center = CGPointMake(self.frame.size.width, 0.0f);
    }
}

#pragma mark - ---  按钮响应事件  ---
-(void) buttonPress:(id)sender
{
    if(self.itemClick)
    {
        self.itemClick(self.itemData);
        NSString *type = (_carLevel != -1 ? RED_TYPE_RECOMMEND : RED_TYPE_NO_RECOMMEND);
        type = (self.itemData.vip == 1 ? RED_TYPE_RECOMMEND : RED_TYPE_NO_RECOMMEND);
        [[NewRedPointData sharedInstance] setItemPress:type withID:self.itemData.serviceID];
        [self setItemLevel:_carLevel withIsVip:0];
    }
}

-(void) buttonLongPress:(UILongPressGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        if(self.itemLongPress)
        {
            self.itemLongPress(self.itemData);
        }
    }
    else if (recognizer.state == UIGestureRecognizerStateChanged)
	{
	}
    else if (recognizer.state == UIGestureRecognizerStateEnded)
	{
	}
    
}


#pragma  mark -  ---  请求图片  ---
- (void) loadImageWithUrl:(NSString *)imageUrl
{
    UIImage *image = [[GDCacheManager globalCache] imageForKey:imageUrl];
    if(image)
    {
        [self setItemImage:image];
    }
    else
    {
        [self setItemImage:nil];
        [_imageLoadRequest Net_RequestImage:imageUrl
                                 withRequest:REQ_SKIN_DATA];//这个类型，其实是皮肤请求的，拿来用的，不然应该再自定义一个类型来请求的
    }
}


//id类型可以是NSDictionary NSArray
- (void)requestToViewCtrWithRequestType:(RequestType)requestType didFinishLoadingWithResult:(id)result
{
   if(REQ_SKIN_DATA == requestType)
   {
       if([result isKindOfClass:[NSDictionary class]]) //图片文件
       {
           if([self.itemData isKindOfClass:[MWCarOwnerServiceTask class]])
           {
               [self setItemImage:[result objectForKey:self.itemData.iconUrl]];
           }
       }
   }
}
//上层需根据error的值来判断网络连接超时还是网络连接错误
- (void)requestToViewCtrWithRequestType:(RequestType)requestType didFailWithError:(NSError *)error
{
}



@end

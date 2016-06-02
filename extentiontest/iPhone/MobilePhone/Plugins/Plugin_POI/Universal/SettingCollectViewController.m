//
//  SettingCollectViewController.m
//  AutoNavi
//
//  Created by huang on 13-9-2.
//
//

#import "SettingCollectViewController.h"
#import "POIDefine.h"
#import "MWSearchResult.h"
#import "POICommon.h"
#import "POIFavoritesEditViewController.h"
#import "POICameraEditViewController.h"
#import "MWPoiOperator.h"
#import "POIDataCache.h"
#import "PluginStrategy.h"
#import "GDSearchListCell.h"
#import "ShadeImageView.h"
#import "UMengEventDefine.h"
#import "POIDataCache.h"
@interface SettingCollectViewController ()<MWPoiOperatorDelegate>
{
    UIImageView *_imageView;
}

@end

@implementation SettingCollectViewController

#pragma mark -
#pragma mark viewcontroller ,
- (id)init
{
	self = [super init];
	if (self)
	{
		
	}
	return self;
}


- (void)dealloc
{
    [_tableView setEditing:NO];
    CRELEASE(_arrayData);
	[super dealloc];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
    [self initControl];
}
-(void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden=NO;
    [self setShowTableViewData:_type];
//    SEARCH_FAVORITES=0,                     //收藏
//    SEARCH_RECENTDESTINATIONS,              //历史目地的
//    SEARCH_CAMERA,                          //摄像头
    [super viewWillAppear:animated];
    
}

#pragma mark -
#pragma mark control related
//初始化控件
-(void) initControl{
    _arrayData=[[NSMutableArray alloc] initWithCapacity:0];
}


//调整控件竖屏坐标和图片
-(void)changePortraitControlFrameWithImage
{
    //解决横竖屏POI提示没数据时候 闪退的bug
    [self setShowTableViewData:_type];
    float height=0;
    [_tableView setFrame:CGRectMake(CCOMMON_TABLE_X, -10.0f, CCOMMON_APP_WIDTH-2*CCOMMON_TABLE_X, CCOMMON_CONTENT_HEIGHT-height+10)];
    [_tableView reloadData];

}

//调整控件横屏坐标和图片
-(void)changeLandscapeControlFrameWithImage
{
    //解决横竖屏POI提示没数据时候 闪退的bug
    [self setShowTableViewData:_type];
    float height=0;
    [_tableView setFrame:CGRectMake(CCOMMON_TABLE_X, -10.0f, CCOMMON_APP_WIDTH-2*CCOMMON_TABLE_X, CCOMMON_CONTENT_HEIGHT-height+10)];
    [_tableView reloadData];

}
//改变控件文本
-(void)changeControlText
{
    self.navigationItem.leftBarButtonItem=LEFTBARBUTTONITEM(@"", @selector(leftBtnEvent:));
    
}
-(void)leftBtnEvent:(id)object
{
    [self.navigationController popViewControllerAnimated:YES];
}
//获取收藏数组
-(void)setShowTableViewData:(int)type
{
    _isNull=NO;
    [_arrayData removeAllObjects];
    switch (type) {
            
        case SEARCH_RECENTDESTINATIONS:
        {
            //历史目的地
            [_arrayData addObjectsFromArray:[POICommon getCollectList:SEARCH_RECENTDESTINATIONS]];
            if (_arrayData.count==0) {
                _isNull=YES;
                [_arrayData addObject:@"POI_NoHistiryAddress"];
            }else
            {
                _isNull = NO;
                [_arrayData addObject:@"POI_CleanHistiryAddress"];
            }
        }
            break;
        case SEARCH_FAVORITES:
        {
            //收藏
            [_arrayData addObjectsFromArray:[POICommon getCollectList:SEARCH_FAVORITES]];
            if (_arrayData.count==0) {
                _isNull=YES;
                [_arrayData addObject:@"POI_NoFavorit"];
            }else
            {
                [_arrayData addObject:@"POI_ClearFavorit"];
            }
        }
            break;
        case SEARCH_CAMERA:
        {
            //电子眼
            [_arrayData addObjectsFromArray:[POICommon getCollectList:SEARCH_CAMERA]];
            if (_arrayData.count==0) {
                _isNull = YES;
                [_arrayData addObject:@"POI_NOCamera"];
            }else
            {
                [_arrayData addObject:@"POI_ClearCinema"];
            }
        }
    }
    [_tableView reloadData];
}

-(void)buttonAction:(UIButton*)button
{
    
    if (button.tag==10) {
    }
    else
    {
         int tag = button.tag-100;
        if (_type==SEARCH_FAVORITES) {
            //进入收藏夹编辑
            POIFavoritesEditViewController *favorites=[[POIFavoritesEditViewController alloc] init];
            favorites.poi=[_arrayData caObjectsAtIndex:tag];
            [self.navigationController pushViewController:favorites animated:YES];
            [favorites release];
        }
        else
        {
            //进入电子眼编辑
            POICameraEditViewController *cameraEdit=[[POICameraEditViewController alloc] init];
            cameraEdit.smartEyesItem=[_arrayData caObjectsAtIndex:tag];
            cameraEdit.isAdd=NO;
            [self.navigationController pushViewController:cameraEdit animated:YES];
            [cameraEdit release];
        }
    }
}
-(void)editCollect:(int)type withIndexPath:(NSIndexPath*)indexPath
{
    MWFavoritePoi * object=[_arrayData caObjectsAtIndex:indexPath.row];
    BOOL gstat =[POICommon deleteOneCollect:type withIndex:[object nIndex]];
    
    if (gstat==YES) {
        [self setShowTableViewData:type];
    }
    if (_isNull==YES) {
        [_tableView setEditing:NO animated:NO];
    }
    
}
#pragma mark -
#pragma mark xxx delegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  _arrayData.count?_arrayData.count:0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_intoType==SETTING_INTO)
    {
      
        if(_isNull)
        {
            return kHeight2;
        }
          return kHeight5+10;
    }
    return 0;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *string=@"cell";
    GDSetFavTableCell *cell=[tableView dequeueReusableCellWithIdentifier:string];
    if (!cell) {
        cell=[[[GDSetFavTableCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:string] autorelease];
        [cell.naviButton addTarget:self action:@selector(naviEvent:) forControlEvents:UIControlEventTouchUpInside];
    }
    cell.emptyLineLength = 0;
    UILabel *labelCenter = (UILabel *)[cell viewWithTag:1000];
    if (labelCenter) {
        [labelCenter removeFromSuperview];
        labelCenter = Nil;
    }
    cell.labelName.text=@"";
    cell.labelAddress.text=@"";
    if ([_arrayData count]==1&&_isNull) {
        cell.labelName.text=STR([_arrayData caObjectsAtIndex:0],Localize_POI);
        cell.searchType=SEARCH_CELL_NO;
         cell.editing=NO;
        return cell;
    }
    else
    {
        MWPoi * poi=[_arrayData caObjectsAtIndex:indexPath.row];
       if (_intoType==SETTING_INTO)
       {
           if (_arrayData.count == indexPath.row+1)
           {
               if (!labelCenter) {
                   labelCenter = [self createLabelWithText:STR([_arrayData caObjectsAtIndex:_arrayData.count-1], Localize_POI) fontSize:kSize2 textAlignment:NSTextAlignmentCenter];
                   [labelCenter setFrame:CGRectMake(0, 0, _tableView.bounds.size.width, kHeight5+10)];
                   [cell addSubview:labelCenter];
                   labelCenter.tag=1000;labelCenter.textColor=TEXTCOLOR;
                   labelCenter.backgroundColor=[UIColor clearColor];
               }
        }
           else
           {
             cell.labelName.text=[POICommon addressNameTransition:poi.szName withAdminCode:poi.lAdminCode];
             cell.labelAddress.text = [POICommon getPoiAddress:poi];
            
           }
            cell.searchType=SEARCH_CELL_NO;
       }
    }
    cell.accessoryView=nil;
    if (_type!=SEARCH_RECENTDESTINATIONS)
    {
        if(!_isNull&& indexPath.row != _arrayData.count -1 )
        {
            if (_intoType==SETTING_INTO) {
                UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
                [button setBackgroundColor:[UIColor clearColor]];
                [button setImage:IMAGE(@"PersonalEdit1.png",IMAGEPATH_TYPE_1) forState:UIControlStateNormal];
                [button setImage:IMAGE(@"PersonalEdit2.png",IMAGEPATH_TYPE_1) forState:UIControlStateHighlighted];
                button.tag=indexPath.row+100;
                [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
                cell.accessoryView = button;
                button.frame = CGRectMake(0,0,kHeight5, kHeight5+10);
            }
        }
        
    }
    if(_isNull)
    {
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
    }
    cell.backgroundType = BACKGROUND_FOOTER;
    return cell;
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (_arrayData.count == 1) {
        return;
    }
    if (_intoType == SETTING_INTO)
    {
        if ( _arrayData.count - 1==indexPath.row&&_arrayData.count>1)
        {
        if (self.type == SEARCH_RECENTDESTINATIONS) {//历史目的地
            GDAlertView *alertView=[[[GDAlertView alloc] initWithTitle:nil andMessage:STR(@"POI_EmptyAlertRecentDestinationsMessage", Localize_POI)] autorelease];
            [alertView addButtonWithTitle:STR(@"Universal_cancel",Localize_Universal) type:GDAlertViewButtonTypeCancel handler:nil];
            
            __block SettingCollectViewController *weakSelf=self;
            [alertView addButtonWithTitle:STR(@"Universal_ok",Localize_Universal) type:GDAlertViewButtonTypeDefault handler:^(GDAlertView *alertView){
                [POICommon deleteCollectList:SEARCH_RECENTDESTINATIONS];
                [weakSelf setShowTableViewData:SEARCH_RECENTDESTINATIONS];
            }];
            [alertView show];
        }
        else if(self.type == SEARCH_FAVORITES)////收藏点
        {
            GDAlertView *alertView=[[[GDAlertView alloc] initWithTitle:nil andMessage:STR(@"POI_ClearALlFavorit", Localize_POI)] autorelease];
            [alertView addButtonWithTitle:STR(@"Universal_cancel",Localize_Universal) type:GDAlertViewButtonTypeCancel handler:nil];
            
            __block SettingCollectViewController *weakSelf=self;
            [alertView addButtonWithTitle:STR(@"Universal_ok",Localize_Universal) type:GDAlertViewButtonTypeDefault handler:^(GDAlertView *alertView){
                [POICommon deleteCollectList:SEARCH_FAVORITES];
                [weakSelf setShowTableViewData:SEARCH_FAVORITES];
            }];
            [alertView show];

        }else if(self.type == SEARCH_CAMERA)////摄像头
        {
            GDAlertView *alertView=[[[GDAlertView alloc] initWithTitle:nil andMessage:STR(@"POI_ClearAllCinema", Localize_POI)] autorelease];
            [alertView addButtonWithTitle:STR(@"Universal_cancel",Localize_Universal) type:GDAlertViewButtonTypeCancel handler:nil];
            
            __block SettingCollectViewController *weakSelf=self;
            [alertView addButtonWithTitle:STR(@"Universal_ok",Localize_Universal) type:GDAlertViewButtonTypeDefault handler:^(GDAlertView *alertView){
                [POICommon deleteCollectList:SEARCH_CAMERA];
                [weakSelf setShowTableViewData:SEARCH_CAMERA];
            }];
            [alertView show];

        }
            return;
        }
        [_arrayData removeLastObject];
    }
    if (_isNull) {
        return;
    }
    if (_intoType==SETTING_INTO)
    {
      [POICommon intoPOIViewController:self withIndex:indexPath.row withViewFlag:INTO_TYPE_FAV withPOIArray:_arrayData  withTitle:self.gdtitle];
    }
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == _arrayData.count - 1) {
        return NO;
    }
    if (_intoType==SETTING_INTO) {
        
        return !_isNull;
    }
    return NO;
}
-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return  STR(@"Universal_delete", Localize_Universal);
    
    
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //删除
        if (indexPath.row==_arrayData.count -1) {
            return;
        }
        [self editCollect:_type withIndexPath:indexPath];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        
    }
}
@end

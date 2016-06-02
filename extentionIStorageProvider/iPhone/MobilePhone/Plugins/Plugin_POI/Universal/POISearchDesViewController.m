//
//  POISearchDesViewController.m
//  AutoNavi
//
//  Created by weisheng on 14-7-11.
//
//

#import "POISearchDesViewController.h"
#import "GDTableViewCell.h"
#import "POITextField.h"
#import "PluginStrategy.h"
#import "POICellButtonEvent.h"
#import "POIVoiceSearch.h"
#import "MWPoiOperator.h"
#import "POICommon.h"
@interface POISearchDesViewController ()<MWPoiOperatorDelegate>
{
    POITextField      * _textField;
    POIVoiceSearch    * _voiceSearch;
    MWPoiOperator     * _poiOperator;
    POICellButtonEvent* _cellButtonEvent;
    
    BOOL                _bOpen;
    UIButton          * _buttonVoice;
    UIImageView       * _imageViewSearchBg;
}
@property(retain,nonatomic)MWPoi * poiCurrentNearby;
@end

@implementation POISearchDesViewController
@synthesize     arrayDestinations,arrayFavorites;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)dealloc
{
    
    CRELEASE(arrayFavorites);
    CRELEASE(arrayDestinations);
    CRELEASE(_indexPathName);
    CRELEASE(_cellButtonEvent);
    CRELEASE(_poiOperator);
    CRELEASE(_poiCurrentNearby);
    CRELEASE(_voiceSearch);
    CRELEASE(_imageViewSearchBg)
    [super dealloc];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
   
    int flag  = [POIDataCache sharedInstance].flag;
    if (flag == EXAMINE_POI_ADD_ADDRESS)
    {
        self.title = STR(@"POI_addWayPoint", Localize_POI);
    }
    else if (flag== EXAMINE_POI_ADD_FAV)
    {
        NSString * str = [POIDataCache sharedInstance].isSetHomeAddress?@"POI_SetCompanyAddress":@"POI_SetHomeAddress";
        self.title=STR(str, Localize_POI);
        
    }
    else if (flag == EXAMINE_POI_ADD_START)
    {
        self.title = STR(@"Main_setStart", Localize_Main);
    }
    else if (flag == EXAMINE_POI_ADD_END)
    {
        self.title = STR(@"Main_setDestination", Localize_Main);
    }
    _cellButtonEvent=[[POICellButtonEvent alloc] init];
    
    _bOpen = NO;//默认下列表是关的
    arrayFavorites = [[NSMutableArray alloc]init];
    arrayDestinations = [[NSMutableArray alloc]init];
    [self setFavouriteAndDestions];
    [self setDestions];
    [self initControl];
    [self getCurrentNearbyPOI];
    self.navigationItem.leftBarButtonItem=LEFTBARBUTTONITEM(@"", @selector(leftBtnEvent:));
   
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _cellButtonEvent.viewController=self;
     self.navigationController.navigationBarHidden=NO;
     self.navigationItem.rightBarButtonItem=RIGHTBARBUTTONITEM1([POICommon getCityName], @selector(rightBtnEvent:));
}

-(void)initControl
{
    UIImage *searchBG =[IMAGE(@"POISearchInput.png", IMAGEPATH_TYPE_1) stretchableImageWithLeftCapWidth:7 topCapHeight:7];
    _imageViewSearchBg = [[self createImageViewWithFrame:CGRectMake(SearchBar_Weight,SearchBar_Weight,  APPWIDTH-SearchBar_Weight*2,34) normalImage:searchBG tag:4001]retain];
    _imageViewSearchBg.userInteractionEnabled=YES;
    [self.view addSubview:_imageViewSearchBg];
    
    _imageViewSearchBg.autoresizingMask=UIViewAutoresizingFlexibleWidth;
    _textField =[[POITextField alloc] initWithFrame:CGRectMake(10,2, CGRectGetWidth(_imageViewSearchBg.frame)-36-5-10, 30)];
    _textField.delegate=self;
    [_imageViewSearchBg addSubview:_textField];
    [_textField release];
    _textField.offsetY=3;
    
    _buttonVoice  =[UIButton buttonWithType:UIButtonTypeCustom];
    _buttonVoice.frame=CGRectMake(0,0,30,30);
    [_buttonVoice setImage:IMAGE(@"POIVoiceSearch1.png",IMAGEPATH_TYPE_1) forState:UIControlStateNormal];
    _buttonVoice.center=CGPointMake(_imageViewSearchBg.frame.size.width-36/2.0f-10, _imageViewSearchBg.frame.size.height/2);
    [_buttonVoice addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    _buttonVoice.tag=10;
    [_imageViewSearchBg addSubview:_buttonVoice];
    [ANParamValue sharedInstance].isSelectCity = 0;

}
-(void)setFavouriteAndDestions
{
    [arrayFavorites removeAllObjects];
    [arrayFavorites addObject:STR(@"POI_FavPoint",Localize_POI )];
    [arrayFavorites addObjectsFromArray:[POICommon getCollectList:SEARCH_FAVORITES]];
    if (arrayFavorites.count==1) {
        _bOpen = NO;
    }
}
-(void)setDestions
{
    [arrayDestinations removeAllObjects];
    [arrayDestinations addObjectsFromArray:[POICommon getCollectList:SEARCH_RECENTDESTINATIONS]];
}
//调整控件竖屏坐标和图片
-(void)changePortraitControlFrameWithImage
{
    _imageViewSearchBg.frame=CGRectMake(SearchBar_Weight, 10,  APPWIDTH-SearchBar_Weight*2, _imageViewSearchBg.frame.size.height);
    _textField.frame= CGRectMake(10,2, CGRectGetWidth(_imageViewSearchBg.frame)-36-5-10, 30);
    _buttonVoice.center=CGPointMake(_imageViewSearchBg.frame.size.width-16-5, _imageViewSearchBg.frame.size.height/2);
    [_tableView setFrame:CGRectMake(CCOMMON_TABLE_X,54, APPWIDTH-2*CCOMMON_TABLE_X, CONTENTHEIGHT_V-54)];
    [_tableView reloadData];
}

//调整控件横屏坐标和图片
-(void)changeLandscapeControlFrameWithImage
{
    _imageViewSearchBg.frame=CGRectMake(SearchBar_Weight, 10,  APPHEIGHT-SearchBar_Weight*2, _imageViewSearchBg.frame.size.height);
    _textField.frame= CGRectMake(10,2, CGRectGetWidth(_imageViewSearchBg.frame)-36-5-10, 30);
    _buttonVoice.center=CGPointMake(_imageViewSearchBg.frame.size.width-16-5, _imageViewSearchBg.frame.size.height/2);
    [_tableView setFrame:CGRectMake(CCOMMON_TABLE_X,54, APPHEIGHT-2*CCOMMON_TABLE_X, CONTENTHEIGHT_H-54)];
    [_tableView reloadData];
}
-(void)leftBtnEvent:(id)object
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)rightBtnEvent:(id)object
{
    [[PluginStrategy sharedInstance] allocViewControllerWithName:@"POICityViewController" withType:0 withViewController:self];
}
-(NSString*)getCityName
{
    return [POICommon getCityName];
}
#pragma mark 获取当前位置最近点的POI信息
-(void)getCurrentNearbyPOI
{
    GCOORD  gcoord = {0};
    GCARINFO carInfo = {0};
    [[MWMapOperator sharedInstance] GMD_GetCarInfo:&carInfo];
    gcoord.x = carInfo.Coord.x;
    gcoord.y = carInfo.Coord.y;
    _poiOperator = [[MWPoiOperator alloc]initWithDelegate:self];
    [_poiOperator poiNearestSearchWithCoord:gcoord];
}
#pragma mark 获取当前位置最近点的POI信息 只有经纬度
-(MWPoi *)getCurrentPOI
{
    MWPoi * poi = [[MWPoi alloc]init];
    GCARINFO carInfo = {0};
    [[MWMapOperator sharedInstance] GMD_GetCarInfo:&carInfo];
    poi.latitude = carInfo.Coord.y;
    poi.longitude = carInfo.Coord.x;
    poi.szName = STR(@"Main_unNameRoad", Localize_Main);
    return [poi autorelease];
}
-(void)buttonAction:(UIButton*)button
{
    if(button.tag == 10)//语音
    {
        if (!_voiceSearch) {
            _voiceSearch=[[POIVoiceSearch alloc] initWithViewController:self];
        }
        [_voiceSearch startVoiceSearch];
    }else if (button.tag == 11)//我的当前位置
    {
        [_cellButtonEvent buttonTouchEvent:self.poiCurrentNearby];
    }else if(button.tag == 12)//地图选点
    {
        POIDataCache *dataCache=[POIDataCache sharedInstance];
        int flag = nil;
       if(dataCache.flag==EXAMINE_POI_ADD_FAV)
           //设置家或公司
        {
            flag=INTO_TYPE_ADD_FAVANDCHOOSEMAP;
        }
        //设置途经点
        else if ([POIDataCache sharedInstance].flag==EXAMINE_POI_ADD_ADDRESS) {
            flag=INTO_TYPE_ADD_THROUGH_POINT_FROM_MAPMARK;
        }
        //设置起点
        else if([POIDataCache sharedInstance].flag ==EXAMINE_POI_ADD_START)
        {
            flag=INFO_TYPE_ADD_THROUGH_POINT_FROM_START;
        }
        //设置终点
        else if([POIDataCache sharedInstance].flag == EXAMINE_POI_ADD_END)
        {
            flag=INFO_TYPE_ADD_THROUGH_POINT_FROM_END;
        }
        [POICommon intoPOIViewController:self withIndex:0 withViewFlag:flag withPOIArray:nil];

    }
}

#pragma mark UITableViewDataSource/UITableViewDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 0;
    }
    else if(section == 1)
    {
        if (_bOpen&&self.indexPathName.section==section)
        {
            return self.arrayFavorites.count;
        }
        return 1;
        
    }
    return arrayDestinations.count?arrayDestinations.count:0;

}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section ==0 )
    {
        return kHeight5;
    }return 0;
}
-(UIImageView *)createImageViewWithFrame:(CGRect)frame
{
    UIImage * imageName = IMAGE(@"TableCellBgFooter.png", IMAGEPATH_TYPE_1);
    UIImageView * imageViewbg = [[UIImageView alloc]init];
    [imageViewbg setFrame:frame];
    imageViewbg.image =[IMAGE(@"TableCellBgFooter.png", IMAGEPATH_TYPE_1) stretchableImageWithLeftCapWidth:imageName.size.height/2 topCapHeight:imageName.size.height/2];
    imageViewbg.userInteractionEnabled = YES;
    return [imageViewbg autorelease];;
}
-(void)createLabel:(NSString *)title andView:(GDSearchListCell *)cell andCount:(int )count
{
    UILabel * labelFav = [[UILabel alloc]init];
    labelFav.text = title;
    labelFav.font = [UIFont systemFontOfSize:kSize2];
    CGSize textSize = [labelFav.text sizeWithFont:labelFav.font];
    labelFav.frame = CGRectMake(50,0,50+textSize.width,kHeight5+10);
    labelFav.tag = 1000;
    labelFav.textColor = GETSKINCOLOR(ROUTE_ADDRESS_COLOR);
    labelFav.backgroundColor = [UIColor clearColor];
    [cell addSubview:labelFav];
    [labelFav release];
    
    UILabel * labelNum = [[UILabel alloc]init];
    labelNum.tag = 2000;
    labelNum.font = [UIFont systemFontOfSize:kSize2];
    labelNum.backgroundColor = [UIColor clearColor];
    labelNum.textColor = GETSKINCOLOR(ROUTE_NO_ADDRESS_COLOR);
    labelNum.frame = CGRectMake(50+textSize.width,0,_tableView.frame.size.width -50-textSize.width, kHeight5+10);
    if (count>0) {
        labelNum.text = [NSString stringWithFormat:@" ( %d )",count];

    }else
    {
        labelNum.text = [NSString stringWithFormat:@" ( %@ )",STR(@"Account_No", Localize_Account)];
    }
        [cell addSubview:labelNum];
    [labelNum release];
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        _headView=[[UIView alloc]initWithFrame:CGRectMake(0,0, _tableView.bounds.size.width,kHeight5)];
        UIImageView *  imageViewbg =[self createImageViewWithFrame:CGRectMake(0,0,_headView.frame.size.width, kHeight5)];
        [_headView addSubview:imageViewbg];

        UIImage * imageLine = IMAGE(@"POIVerLine.png", IMAGEPATH_TYPE_1);
        UIImageView * imageViewLine = [[UIImageView alloc]init];
        imageViewLine.image = [imageLine stretchableImageWithLeftCapWidth:imageLine.size.width/2 topCapHeight:imageLine.size.height/2];

        [imageViewLine setFrame:CGRectMake(0,_headView.frame.size.height-1.5, _tableView.bounds.size.width,1.5)];
        [imageViewbg addSubview:imageViewLine];
        [imageViewLine release];
        
        UIImage * image =[IMAGE(@"POILine.png", IMAGEPATH_TYPE_1) stretchableImageWithLeftCapWidth:0.5 topCapHeight:5];
        UIImageView * imageH = [[UIImageView alloc]initWithFrame:CGRectMake(_tableView.bounds.size.width/2, 0, 1.5, kHeight5)];
        imageH.image = image;
        [_headView addSubview:imageH];
        [imageH release];
        
        _buttonNaviGation = [self createButtonWithTitle:STR(@"POI_MyCurrentLocation", Localize_POI) normalImage:nil heightedImage:@"POISelectImage.png" tag:11 strechParamX:4 strechParamY:5];
        [_buttonNaviGation setImage:IMAGE(@"POI_CurrentLoc.png", IMAGEPATH_TYPE_1) forState:UIControlStateNormal];
        [_buttonNaviGation setTitleColor:GETSKINCOLOR(@"POINaviGationColor") forState:UIControlStateNormal];
        [_buttonNaviGation setFrame:CGRectMake(0, 0, _tableView.frame.size.width/2, kHeight5)];
        
        _buttonMap = [self createButtonWithTitle:STR(@"POI_SelectPointsInMap", Localize_POI) normalImage:@"" heightedImage:@"POISelectImage.png" tag:12 strechParamX:4 strechParamY:5];
         [_buttonMap setImage:IMAGE(@"POI_MapChose.png", IMAGEPATH_TYPE_1) forState:UIControlStateNormal];
        [_buttonMap setTitleColor:GETSKINCOLOR(@"POI_NavigationButtonColor") forState:UIControlStateNormal];
        [_buttonMap setFrame:CGRectMake(_tableView.frame.size.width/2, 0, _tableView.frame.size.width/2, kHeight5)];
        [_headView addSubview:_buttonNaviGation];
        [_headView addSubview:_buttonMap];
        
        return [_headView autorelease];
    }
    return nil;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1)
    {
        if (indexPath.row==0) {
              return kHeight5 + 10;
        }else
        {
             return kHeight5 + 10;
        }
      
      
    }
    else if (indexPath.section ==2)
    {
        return kHeight5 + 10;
    }return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1)//收藏点
    {
        static NSString * identy = @"cellFav";
        GDSearchListCell * cell = [tableView dequeueReusableCellWithIdentifier:identy];
        if (cell == nil)
        {
            cell = [[[GDSearchListCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identy]autorelease];
            [cell.naviButton addTarget:self action:@selector(naviEvent:) forControlEvents:UIControlEventTouchUpInside];
        }
        UILabel * labelFav = (UILabel *)[cell viewWithTag:1000];
        if (labelFav) {
            [labelFav removeFromSuperview];
            labelFav = nil;
        }
        UILabel * labelNum = (UILabel *)[cell viewWithTag:2000];
        if (labelNum) {
            [labelNum removeFromSuperview];
            labelNum = nil;
        }
        if (_bOpen&&self.indexPathName.section==indexPath.section&&indexPath.row!=0)
        {
                MWPoi * poi = [arrayFavorites objectAtIndex:indexPath.row];
                cell.labelAddress.text = [POICommon getPoiAddress:poi];
                cell.labelName.text = poi.szName;
                if ([POIDataCache sharedInstance].flag==EXAMINE_POI_NO)
                {
                    cell.searchType = SEARCH_CELL_NO;
                }
                else
                {
                    cell.accessoryType=UITableViewCellAccessoryNone;
                    cell.accessoryView=nil;
                    cell.searchType=SEARCH_CELL_ADD;
                }
        }
        else
        {
            cell.searchType = SEARCH_CELL_NO;
            cell.labelName.text = nil;
            cell.labelAddress.text = nil;
            NSString * string = [NSString stringWithFormat:@"%@",[arrayFavorites objectAtIndex:indexPath.row]];
            [self createLabel:string andView:cell andCount:arrayFavorites.count -1];
        }
        if (indexPath.row == 0)
        {
            cell.emptyLineLength = 0;
            cell.imageView.image = IMAGE(@"PersonalCollectFull.png", IMAGEPATH_TYPE_1);
            if (_bOpen) {
                  cell.accessoryView=[[[UIImageView alloc] initWithImage:IMAGE(@"POIAroundBigAccessoryDown.png",IMAGEPATH_TYPE_1)] autorelease];
            }else
            {
                cell.accessoryView=[[[UIImageView alloc] initWithImage:IMAGE(@"POIAroundBigAccessoryUp.png",IMAGEPATH_TYPE_1)] autorelease];
            }
        }
        else if (indexPath.row == arrayFavorites.count -1)
        {
             cell.emptyLineLength = 0;
            cell.imageView.image = IMAGE(@"PersonalCollectEmpty.png", IMAGEPATH_TYPE_1);;
        }
        else
        {
            cell.imageView.image = IMAGE(@"PersonalCollectEmpty.png", IMAGEPATH_TYPE_1);;
            cell.emptyLineLength = 50;
            
        }
        return cell;
    }
    else if (indexPath.section ==2)//历史目的地
    {
        static NSString * identy2 = @"cellDes";
        GDSearchListCell * listCell = [tableView dequeueReusableCellWithIdentifier:identy2];
        if (listCell == nil)
        {
            listCell = [[[GDSearchListCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identy2]autorelease];
            [listCell.naviButton addTarget:self action:@selector(naviEvent:) forControlEvents:UIControlEventTouchUpInside];
        }
        listCell.accessoryView = nil;
        listCell.emptyLineLength = 0;
        if (arrayDestinations)
        {
            listCell.imageView.image = IMAGE(@"POIHistory_des.png", IMAGEPATH_TYPE_1);
            MWPoi * poi = [arrayDestinations objectAtIndex:indexPath.row];
            listCell.labelName.text=poi.szName;
            listCell.labelAddress.text=[POICommon getPoiAddress:poi];
            if ([POIDataCache sharedInstance].flag==EXAMINE_POI_NO)
            {
                listCell.searchType=SEARCH_CELL_NAVI;
            }
            else
            {
                listCell.accessoryType=UITableViewCellAccessoryNone;
                listCell.accessoryView=nil;
                listCell.searchType=SEARCH_CELL_ADD;
            }
        }
        return listCell;
    }
    return nil;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
     [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1)
    {
        openCellCount = self.arrayFavorites.count;
        if (indexPath.row==0)
        {
            if ([indexPath isEqual:self.indexPathName])
            {
                _bOpen=NO;
                [self didSelectCellRowFirstDo:NO nextDo:NO];
                self.indexPathName=nil;
            }
            else
            {
                if (!self.indexPathName)
                {
                    self.indexPathName = indexPath;
                    [self didSelectCellRowFirstDo:YES nextDo:NO];
                }
                else
                {
                    [self didSelectCellRowFirstDo:NO nextDo:YES];
                }
            }
            if(_bOpen==NO&&openCellCount==1)
            {
                [_tableView reloadData];
               // MWPoiCategory * sectionInfo = [self.sectionInfoArray objectAtIndex:indexPath.section];
                
            }
        }
        else
        {
            if (self.arrayFavorites.count>1) {
                NSMutableArray * array = [NSMutableArray array];
                [array addObjectsFromArray:self.arrayFavorites];;
                [array removeObjectAtIndex:0];
                [self gotoMapAndArray:array andIndexPath:indexPath.row -1];
            }
        }
    }
    else if (indexPath.section == 2)
    {
        if (self.arrayDestinations.count>0) {
            [self gotoMapAndArray:self.arrayDestinations andIndexPath:indexPath.row];
        }
    }
   
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==0) {
        return NO;
    }
    else if (indexPath.section == 1)
    {
        if (indexPath.row ==0) {
            return NO;
        }
        return arrayFavorites.count==1?NO:YES;
    }else if (indexPath.section ==2)
    {
        return arrayDestinations.count?YES:NO;
    }return NO;
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle==UITableViewCellEditingStyleDelete)
    {
        if (indexPath.section==1) {
            if (indexPath.row == 0) {
                return;
            }else
            {
                MWFavoritePoi *object=[arrayFavorites objectAtIndex:indexPath.row];
                BOOL gstat = [POICommon deleteOneCollect:SEARCH_FAVORITES withIndex:[object nIndex]];
                if (gstat==YES) {
                    [self setFavouriteAndDestions];
                }
                [_tableView reloadData];
               
                
            }
        }
        else if (indexPath.section==2)
        {
            BOOL gstat = [POICommon deleteOneCollect:SEARCH_RECENTDESTINATIONS withIndex:indexPath.row];
            if (gstat==YES) {
                [self setDestions];
            }
            [_tableView reloadData];
           
        }
    }
    
}
-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return  STR(@"Universal_delete", Localize_Universal);
    
}
#pragma mark 调用此方法进入地图
-(void)gotoMapAndArray:(NSArray *)arrray andIndexPath:(int)indexPath
{
    int flag;
    POIDataCache *dataCache=[POIDataCache sharedInstance];
    if (dataCache.flag==EXAMINE_POI_NO)
    {
        flag=INTO_TYPE_NORMAL;
    }
    else if(dataCache.flag==EXAMINE_POI_ADD_FAV)
    {
        //添加家或公司
        flag=INTO_TYPE_ADD_FAV;
    }
    else if(dataCache.flag==EXAMINE_POI_ADD_ADDRESS)
    {
        //添加途径点
        flag=INTO_TYPE_ADD_THROUGH_POINT;
    }
    else if (dataCache.flag ==EXAMINE_POI_ADD_START)
    {
        //添加起点
        flag = INTO_TYPE_ADD_THROUGH_START;
    }
    else if(dataCache.flag ==EXAMINE_POI_ADD_END)
    {
        //添加终点
        flag = INTO_TYPE_ADD_THROUGH_END;
    }
    if (arrray&&flag) {
        if (indexPath >= [arrray count])
        {
            return;
        }
        [POICommon intoPOIViewController:self withIndex:indexPath withViewFlag:flag withPOIArray:arrray];
    }
}
#pragma mark 点击添加或开始导航
-(void)naviEvent:(id)object
{
    NSIndexPath * path=[_cellButtonEvent buttonInTableCell:object withTableView:_tableView];
    if (path.section == 2) {//历史目的地
        MWPoi * poi=[arrayDestinations objectAtIndex:path.row];
        [_cellButtonEvent buttonTouchEvent:poi];
    }
    else if (path.section == 1)//收藏点
    {
        if (path.row ==0) {
            return;
        }else
        {
            MWPoi * poi=[arrayFavorites objectAtIndex:path.row];
            [_cellButtonEvent buttonTouchEvent:poi];
        }
    }
}

- (void)didSelectCellRowFirstDo:(BOOL)firstDoInsert nextDo:(BOOL)nextDoInsert
{
    _bOpen = firstDoInsert;
    [_tableView beginUpdates];
    int section = self.indexPathName.section;
    openCellCount=self.arrayFavorites.count;
    int contentCount=openCellCount - 1;
	NSMutableArray * rowToInsert = [[NSMutableArray alloc] init];
    if (openCellCount>1)
    {
        for (NSUInteger i = 1; i < contentCount+1 ; i++)
        {
            NSIndexPath * indexPathToInsert = [NSIndexPath indexPathForRow:i inSection:section];
            [rowToInsert addObject:indexPathToInsert];
        }
    }
    else
    {
        _bOpen=NO;
    }
	if (_bOpen)
    {
        NSIndexPath *indexPath=[NSIndexPath indexPathForRow:0 inSection:section];
        UITableViewCell *cell=[_tableView cellForRowAtIndexPath:indexPath];
        cell.accessoryView=[[[UIImageView alloc] initWithImage:IMAGE(@"POIAroundBigAccessoryDown.png",IMAGEPATH_TYPE_1)] autorelease];
        
        [_tableView insertRowsAtIndexPaths:rowToInsert withRowAnimation:UITableViewRowAnimationTop];
    }
	else
    {
        NSIndexPath *indexPath=[NSIndexPath indexPathForRow:0 inSection:section];
        UITableViewCell *cell=[_tableView cellForRowAtIndexPath:indexPath];
        cell.accessoryView=[[[UIImageView alloc] initWithImage:IMAGE(@"POIAroundBigAccessoryUp.png",IMAGEPATH_TYPE_1)] autorelease];
        [_tableView deleteRowsAtIndexPaths:rowToInsert withRowAnimation:UITableViewRowAnimationTop];
    }
    [rowToInsert release];
	[_tableView endUpdates];//
    if (nextDoInsert)
    {
        _bOpen=YES;
        self.indexPathName= [_tableView indexPathForSelectedRow];
        [self didSelectCellRowFirstDo:YES nextDo:NO];
    }
    if (_bOpen)
    {
        [_tableView scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    
}
#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField        // return NO to disallow editing.
{
    [[PluginStrategy sharedInstance] allocViewControllerWithName:@"POISearchInputViewController" withType:0 withViewController:self];
    return NO;
}
#pragma mark MWPoiOperatorDelegate
-(void)poiNearestSearch:(GCOORD)coord Poi:(MWPoi *)poi
{
    self.poiCurrentNearby = nil;
    if (poi) {
        self.poiCurrentNearby = poi;
    }else
    {
        self.poiCurrentNearby = [self getCurrentPOI];
    }
    [_tableView reloadData];
}
-(void)search:(id)poiOperatorOption Error:(NSError *)error
{
    self.poiCurrentNearby= nil;
    self.poiCurrentNearby = [self getCurrentPOI];
    [_tableView reloadData];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end

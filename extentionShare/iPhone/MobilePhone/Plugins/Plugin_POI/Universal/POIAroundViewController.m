//
//  POIAroundViewController.m
//  AutoNavi
//
//  Created by huang on 13-8-20.
//
//

#import "POIAroundViewController.h"
#import "ControlCreat.h"
#import "MWPoiOperator.h"
#import "MWSearchResult.h"
#import "MWMapOperator.h"
#import "POIAroundListViewController.h"
#import "POIDefine.h"
#import "plugin_PoiNode.h"
#import "POIToolBar.h"
#import "UMengEventDefine.h"
@interface POIAroundViewController ()<MWPoiOperatorDelegate>
{
    enum _SEARCH_POINT_INDEX{
        SEARCH_BY_MAPCENTRAL = 0,
        SEARCH_BY_CARPOSITION,
        SEARCH_BY_DESTINATION,
    };
    POIAroundTextField *_aroundTextField;
    POIKeyBoardEvent   *_keyBoardEvent;
    
    int                 _selectAround;
}


@property (nonatomic, retain) NSMutableArray * arrayArroundCategory;
@end

@implementation POIAroundViewController
@synthesize arrayArroundCategory;

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
    _aroundTextField.delegate=nil;
    _keyBoardEvent.delegate=nil;
    CRELEASE(arrayArroundCategory);
    CRELEASE(_keyBoardEvent);
    CLOG_DEALLOC(self);
	[super dealloc];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
    _bOpen=NO;
    [self initControl];
    _tableView.sectionFooterHeight=0;
    _tableView.sectionHeaderHeight=0;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden=NO;
}
#pragma mark -
#pragma mark control related
//初始化控件
-(void) initControl{
    // 周边检索修改lyh10-25
	[self showLoadingViewInView:@"" view:self.view];
    //键盘视图
    UIImage *searchBG =[IMAGE(@"POISearchInputBg.png", IMAGEPATH_TYPE_1) stretchableImageWithLeftCapWidth:7 topCapHeight:0];
    _imageView = [self createImageViewWithFrame:CGRectMake(CCOMMON_SPACE,0,  APPWIDTH-CCOMMON_SPACE*2, searchBG.size.height) normalImage:searchBG tag:4000];
    _imageView.userInteractionEnabled=YES;
    [self.view addSubview:_imageView];
    _imageView.autoresizingMask=UIViewAutoresizingFlexibleWidth;
    
    _aroundTextField=[[POIAroundTextField alloc] initWithFrame:CGRectMake(10,0, CGRectGetWidth(_imageView.frame)-36-5-10, 34)];
    _aroundTextField.delegate=self;
    _aroundTextField.isHaveVoice= YES;
    [_imageView addSubview:_aroundTextField];
    [_aroundTextField release];
    
    //键盘事件
    _keyBoardEvent=[[POIKeyBoardEvent alloc] initWithView:self.view];
    _keyBoardEvent.delegate=self;
    _keyBoardEvent.textFiled=(UITextField*)_aroundTextField.textField;
    [_keyBoardEvent setHiddenButton:YES];
	[self initWithFatherArray];
    aroundSearchType=0;
    
    currentCell=-1;
    openCellCount=0;
    _selectAround = -1;
	//获取地图中心信
    if (_isNearBy) {
        GCARINFO carInfo;
        GDBL_GetCarInfo(&carInfo);
        [ANParamValue sharedInstance].searchMapInfo=carInfo.Coord;
                
    }
    else
    {
        GMAPCENTERINFO mapinfo = {0};
        [[MWMapOperator sharedInstance] MW_GetMapViewCenterInfo:GMAP_VIEW_TYPE_MAIN mapCenterInfo:&mapinfo];
        [ANParamValue sharedInstance].searchMapInfo = mapinfo.CenterCoord;
    }
}
- (void)initWithFatherArray
{
    //获取周边搜索关键字
    MWPoiOperator * poiOperator=[[MWPoiOperator alloc] init];
    MWPoiCategoryList *poiCategoryList=[[[MWPoiCategoryList alloc] init] autorelease];
    BOOL category =  [poiOperator getAroundListWith:0 list:&poiCategoryList];
    [poiOperator release];
    if (category) {
        NSMutableArray *infoArray = [[NSMutableArray alloc] init];
        for (int i=0;i<poiCategoryList.pCategoryArray.count;i++) {
            
            MWPoiCategory * object = [poiCategoryList.pCategoryArray objectAtIndex:i];
            [infoArray addObject:object];
        }
        self.arrayArroundCategory = infoArray;
        [infoArray release];
    }
    [self hideLoadingViewWithAnimated:YES];
}

//调整控件竖屏坐标和图片
-(void)changePortraitControlFrameWithImage
{
    _imageView.frame=CGRectMake(SearchBar_Weight,10,  APPWIDTH-SearchBar_Weight*2,34);
    _aroundTextField.frame= CGRectMake(0,0, CGRectGetWidth(_imageView.frame), 34);
    [_aroundTextField changePortraitControlFrameWithImage];
    
    float tableY=_imageView.frame.origin.y+CGRectGetHeight(_imageView.frame)+10;
    [_tableView setFrame:CGRectMake(CCOMMON_TABLE_X, tableY, APPWIDTH-2*CCOMMON_TABLE_X, CONTENTHEIGHT_V-tableY)];
    [_tableView reloadData];
}

//调整控件横屏坐标和图片
-(void)changeLandscapeControlFrameWithImage
{
    _imageView.frame=CGRectMake(SearchBar_Weight, 10,  APPHEIGHT-SearchBar_Weight*2,34);
    _aroundTextField.frame= CGRectMake(0,0, CGRectGetWidth(_imageView.frame), 34);
    [_aroundTextField changeLandscapeControlFrameWithImage];

    
    float tableY=_imageView.frame.origin.y+CGRectGetHeight(_imageView.frame)+10;
    [_tableView setFrame:CGRectMake(CCOMMON_TABLE_X, tableY, APPHEIGHT-2*CCOMMON_TABLE_X, CONTENTHEIGHT_H-tableY)];
    [_tableView reloadData];
}
//改变控件文本
-(void)changeControlText
{
    self.title= _isNearBy ? STR(@"POI_Nearby",@"POI"):STR(@"POI_AroundBy",@"POI");
     self.navigationItem.leftBarButtonItem=LEFTBARBUTTONITEM(@"", @selector(leftBtnEvent:));
}
-(void)leftBtnEvent:(id)object
{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark -
#pragma mark  methods
- (void)buttonAction:(id)sender
{
	
	UIButton *button = (UIButton *)sender;
	[self button:button clickedWithTag:button.tag];
}
- (void)button:(UIButton *)button clickedWithTag:(NSInteger)tag
{
	
    switch (tag-1) {
        case 0:
        {
            GMAPCENTERINFO mapinfo = {0};
            [[MWMapOperator sharedInstance] MW_GetMapViewCenterInfo:GMAP_VIEW_TYPE_MAIN mapCenterInfo:&mapinfo];
            [ANParamValue sharedInstance].searchMapInfo = mapinfo.CenterCoord;
            
            aroundSearchType=0;
            
        }
            break;
        case SEARCH_BY_CARPOSITION:
        {
  
            aroundSearchType=1;
            
        }
            break;
        case SEARCH_BY_DESTINATION:
        {
            GCOORD descoord;
            plugin_PoiNode *tmp = [MWJourneyPoint GetJourneyPointWithID:6];
            descoord.x = tmp.lLon;
            descoord.y = tmp.lLat;
            [ANParamValue sharedInstance].searchMapInfo = descoord;
            
            aroundSearchType=0;
            
        }
            break;
        default:
            break;
    }
    if([_aroundTextField.textField isFirstResponder])
    {
        [_aroundTextField.textField resignFirstResponder];
    }
}

-(void)pressedButton:(id)sender
{
    // 周边检索修改lyh10-25
	UIButton *button = (UIButton *)sender;
	[self button:button clickedWithTag:button.tag];
}

-(void)intoListViewController:(NSString*)title keytitle:(NSString *)title2 withObject:(MWPoiCategory*)poiCategory withSearchType:(int)searchType
{
    switch (_selectAround)
    {
        case 0:
        {
            [MobClick event:UM_EVENTID_AROUND_COUNT label:UM_LABEL_AROUND_GasStation];
        }
            break;
        case 1:
        {
            [MobClick event:UM_EVENTID_AROUND_COUNT label:UM_LABEL_AROUND_Park];
        }
            break;
        case 2:
        {
            [MobClick event:UM_EVENTID_AROUND_COUNT label:UM_LABEL_AROUND_Food];
        }
            break;
        case 3:
        {
            [MobClick event:UM_EVENTID_AROUND_COUNT label:UM_LABEL_AROUND_Hotel];
        }
            break;
        case 4:
        {
            [MobClick event:UM_EVENTID_AROUND_COUNT label:UM_LABEL_AROUND_ScenicSpot];
        }
            break;
        case 5:
        {
             [MobClick event:UM_EVENTID_AROUND_COUNT label:UM_LABEL_AROUND_Shopping];
        }
            break;
        case 6:
        {
              [MobClick event:UM_EVENTID_AROUND_COUNT label:UM_LABEL_AROUND_Car];
        }
            break;
        case 7:
        {
           [MobClick event:UM_EVENTID_AROUND_COUNT label:UM_LABEL_AROUND_Life];
        }
            break;
        case 8:
        {
             [MobClick event:UM_EVENTID_AROUND_COUNT label:UM_LABEL_AROUND_Traffic];
        }
            break;
        case 9:
        {
            [MobClick event:UM_EVENTID_AROUND_COUNT label:UM_LABEL_AROUND_Entertainment];
        }
            break;
        case 10:
        {
             [MobClick event:UM_EVENTID_AROUND_COUNT label:UM_LABEL_AROUND_Financial];
        }
            break;
        case 11:
        {
            [MobClick event:UM_EVENTID_AROUND_COUNT label:UM_LABEL_AROUND_Hospital];
         
        }
            break;

        case 12:
        {
             [MobClick event:UM_EVENTID_AROUND_COUNT label:UM_LABEL_AROUND_Building];
            
        }
            break;

        case 13:
        {
            [MobClick event:UM_EVENTID_AROUND_COUNT label:UM_LABEL_AROUND_Company];
         
        }
            break;
        case 14:
        {
            [MobClick event:UM_EVENTID_AROUND_COUNT label:UM_LABEL_AROUND_Government];
        }
            break;

        default:
            break;
    }
    if([_aroundTextField isFirstResponder])
    {
        [_aroundTextField resignFirstResponder];
    }
    POIAroundListViewController * aroundListViewController=[[POIAroundListViewController alloc]initWithTitle:title keyName:title2 withPoiCategroy:poiCategory];
    aroundListViewController.searchType=searchType;
    [self.navigationController pushViewController:aroundListViewController animated:YES];
    [aroundListViewController release];
    
}

#pragma mark Table view methods
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.arrayArroundCategory.count;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_bOpen&&self.indexPathName.section==section)
    {
        return openCellCount+1;
    }
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return kHeight2;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   // static NSString * CellIdentifier = @"Cell";
    NSString * CellIdentifier=[NSString stringWithFormat:@"%d %d",indexPath.section,indexPath.row];
    GDTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[[GDTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    cell.endLineLength = -1;
    cell.emptyLineLength = 0;
    //没有打开
    cell.textLabel.font=[UIFont systemFontOfSize:kSize2];
    cell.textLabel.textColor=TEXTCOLOR;
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    if (_bOpen&&self.indexPathName.section==indexPath.section&&indexPath.row!=0)
    {
     
            MWPoiCategory * items=[self.arrayArroundCategory objectAtIndex:indexPath.section];
            items = [items.pSubCategoryArray objectAtIndex:indexPath.row-1];
            cell.textLabel.text=[NSString stringWithFormat:@"           %@",items.szName];
            NSLog(@"%@",items.szName);
            cell.backgroundType=nil;
            cell.backgroundType=BACKGROUND_TWO_MIDDLE;
            cell.imageView.image=nil;
            cell.accessoryView=[[[UIImageView alloc] initWithImage:IMAGE(@"POIAroundSmallAccessoryUp.png",IMAGEPATH_TYPE_1)] autorelease];
            cell.textLabel.textColor=TOOLBARBUTTONCOLOR;
            cell.textLabel.font=[UIFont systemFontOfSize:kSize3];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
            cell.endLineLength = -1;
            cell.emptyLineLength = 0;
    }
    else
    {
        MWPoiCategory * items=[self.arrayArroundCategory objectAtIndex:indexPath.section];
        NSString *sonName = [NSString stringWithFormat:@"%@",items.szName];
        cell.textLabel.text = sonName;
        NSString *imageName=[NSString stringWithFormat:@"POISearchIcon%i.png",indexPath.section];
        cell.imageView.image=IMAGE(imageName,IMAGEPATH_TYPE_1);
        cell.accessoryView=[[[UIImageView alloc] initWithImage:IMAGE(@"POIAroundBigAccessoryUp.png",IMAGEPATH_TYPE_1)] autorelease];
        if (_selectAround == indexPath.section&&_bOpen) {
            cell.accessoryView=[[[UIImageView alloc] initWithImage:IMAGE(@"POIAroundBigAccessoryDown.png",IMAGEPATH_TYPE_1)] autorelease];
        }
    }
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _selectAround = indexPath.section;
    MWPoiCategory * object=[self.arrayArroundCategory objectAtIndex:indexPath.section];
    openCellCount=object.pSubCategoryArray.count;
    if (indexPath.row==0)
    {
        if ([indexPath isEqual:self.indexPathName]) {
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
        if(_bOpen==NO&&openCellCount==0)
        {
            MWPoiCategory * sectionInfo = [self.arrayArroundCategory objectAtIndex:indexPath.section];
            [self intoListViewController:sectionInfo.szName keytitle:sectionInfo.szName withObject:sectionInfo withSearchType:0];

        }
    }
    else
    {
            MWPoiCategory * sectionInfo = [self.arrayArroundCategory objectAtIndex:indexPath.section];
            MWPoiCategory * quotation = [[sectionInfo pSubCategoryArray] objectAtIndex: indexPath.row-1] ;
            [self intoListViewController:quotation.szName keytitle:sectionInfo.szName withObject:quotation withSearchType:1];
    }
     [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)didSelectCellRowFirstDo:(BOOL)firstDoInsert nextDo:(BOOL)nextDoInsert
{
    _bOpen = firstDoInsert;
    [_tableView beginUpdates];
    int section = self.indexPathName.section;
    MWPoiCategory * object=[self.arrayArroundCategory objectAtIndex:section];
    openCellCount=object.pSubCategoryArray.count;
    int contentCount=object.pSubCategoryArray.count;
	NSMutableArray * rowToInsert = [[NSMutableArray alloc] init];
    if (openCellCount>1) {
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
#pragma mark -
#pragma mark SearchBar methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	if ([_aroundTextField.textField isFirstResponder])
	{
		[_aroundTextField.textField resignFirstResponder];
	}
	
}
#pragma mark -
#pragma mark POIAroundTextFieldDelegate
-(void)buttonTouchEvent:(NSString*)string withButton:(UIButton*)button
{
    if (button.tag == 100) {
        [self gotoVoiceSearch];
    }else
    {
        if([NSString checkStringStandardWith:string]==NO)
        {
            GDAlertView *alert = [[[GDAlertView alloc] initWithTitle:nil andMessage:STR(@"POI_TextFeildErroeMessage", @"POI")] autorelease];
            [alert addButtonWithTitle:STR(@"POI_OK",@"POI") type:GDAlertViewButtonTypeCancel handler:nil];
            [alert show];
            return;
        }
        [self intoListViewController:string keytitle:nil withObject:nil withSearchType:2];
    }
  
    
}
-(void)textFieldReturn:(NSString *)string
{
    if([NSString checkStringStandardWith:string]==NO)
    {
        GDAlertView *alert = [[[GDAlertView alloc] initWithTitle:nil andMessage:STR(@"POI_TextFeildErroeMessage", @"POI")] autorelease];
        [alert addButtonWithTitle:STR(@"POI_OK",@"POI") type:GDAlertViewButtonTypeCancel handler:nil];
        [alert show];
        return;
    }
    [self intoListViewController:string keytitle:nil withObject:nil withSearchType:2];
    
}
-(BOOL)textFieldChanage:(UITextField*)textField withRange:(NSRange)range withString:(NSString *)string
{
    if (range.location>19) {
        return NO;
    }
  return YES;
}
#pragma mark POIKeyBoardEventProtocol
-(void)keyBoardEvent:(BOOL)isShow//0表示隐藏，1表示显示
{
    NSLog(@"isShow=%i",isShow);
}
#pragma mark 调用科大语音的弹出框
-(void)gotoVoiceSearch
{
    if ([POICommon isCanVoiceInput]==NO) {
        return;
    }
   MWPoiOperator * poiOperator = [[MWPoiOperator alloc]initWithDelegate:self];
    GMAPCENTERINFO mapinf = {0};
    [[MWMapOperator sharedInstance] MW_GetMapViewCenterInfo:GMAP_VIEW_TYPE_MAIN mapCenterInfo:&mapinf];
    int adminCode = [MWAdminCode GetCurAdminCode];
    MWVoiceOption *option = [[MWVoiceOption alloc] init];
    option.longitude = mapinf.CenterCoord.x;
    option.latitude = mapinf.CenterCoord.y;
    option.lAdminCode = adminCode;
    [poiOperator voiceSearchWith:option withSuperView:self.view];
    [option release];
    
    if (Interface_Flag == 0) {
        [MWPoiOperator setRecognizeViewCenter:CGPointMake(APPWIDTH/2.0, APPHEIGHT/2.0)];
		
	}
	else if(Interface_Flag == 1){
        [MWPoiOperator setRecognizeViewCenter:CGPointMake(APPHEIGHT/2.0, APPWIDTH/2.0)];
        
	}
    [poiOperator release];
}
#pragma mark MWPoiOperatorDelegate
- (void)voiceSearchResult:(MWVoiceResult *)result
{
    NSString * stringVoiceName = nil;
    if ([result.cmdtxt length] > 0)
    {
        stringVoiceName = result.cmdtxt;
        //_aroundTextField.textField.text = stringVoiceName;
        _aroundTextField.text=stringVoiceName;
        [self intoListViewController:stringVoiceName keytitle:nil withObject:nil withSearchType:2];
         //[self intoListViewController:string keytitle:nil withObject:nil withSearchType:2];
    }
    else
    {
        [POICommon showAutoHideAlertView:STR(@"POI_TheWordNotMatched",Localize_POI) ];
    }
    
}
-(void)voiceSearchFail:(int)errorCode
{
    if (errorCode==0) {
        return;
    }
    [self hideLoadingViewWithAnimated:NO];
    [POICommon showAutoHideAlertView:STR(@"POI_TheWordNotMatched",Localize_POI)];
}
@end

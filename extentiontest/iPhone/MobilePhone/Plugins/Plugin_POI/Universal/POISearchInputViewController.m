//
//  POISearchInputViewController.m
//  AutoNavi
//
//  Created by huang on 13-8-16.
//
//

#import "POISearchInputViewController.h"
#import "POISearchListViewController.h"
#import "POISearchHistory.h"
#import "POIDefine.h"
#import "POIKeyBoardEvent.h"
#import "GDAlertView.h"
#import "POIOtherCityViewController.h"
#import "ControlCreat.h"
#import "POITextField.h"
#import "POIAroundTextField.h"
#import "PluginStrategy.h"
#import "POIDataCache.h"
#import "MWPoiOperator.h"
@interface POISearchInputViewController ()<MWPoiOperatorDelegate,POIAroundTextFieldDelegate>
{
    MWPoiOperator      *_poiOperator;
    POIAroundTextField *_aroundTextField;
    POIKeyBoardEvent   *_keyBoardEvent;
    POISearchHistory   *_searchHistory;
    
    UIImageView        *_imageViewSearch;
    NSMutableArray     *_arrayData;
    BOOL                _isNull;           //判断数据是否为空 YES表示数据为空，NO表示有数据
}
@property(nonatomic,copy)NSString * searchKey;
@end

@implementation POISearchInputViewController

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
    CLOG_DEALLOC(self);
    CRELEASE(_searchHistory);
    CRELEASE(_keyBoardEvent);
    CRELEASE(_arrayData)
    CRELEASE(_poiOperator);
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
    }else
    {
        self.title=STR(@"POI_Search", Localize_POI);
    }
   
    [self initControl];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden=NO;
    [self getHistoryKey];
 
 
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [_aroundTextField.textField becomeFirstResponder];
}
#pragma mark -
#pragma mark control related
//初始化控件
-(void) initControl{
     
    UIImage *searchBG =[IMAGE(@"", IMAGEPATH_TYPE_1) stretchableImageWithLeftCapWidth:7 topCapHeight:7];
    _imageViewSearch=[[UIImageView alloc] initWithFrame:CGRectMake(10,10,  APPWIDTH-20,34)];
    _imageViewSearch.backgroundColor=[UIColor clearColor];
    _imageViewSearch.image=searchBG;
    _imageViewSearch.userInteractionEnabled=YES;
    [self.view addSubview:_imageViewSearch];
    [_imageViewSearch release];
    _aroundTextField=[[POIAroundTextField alloc] initWithFrame:CGRectMake(0,0,_imageViewSearch.frame.size.width-0,34)];
    _aroundTextField.delegate=self;
     _aroundTextField.isHaveVoice= YES;
    [_imageViewSearch addSubview:_aroundTextField];
    [_aroundTextField release];
    
    _keyBoardEvent=[[POIKeyBoardEvent alloc] initWithView:self.view];
    _keyBoardEvent.textFiled=_aroundTextField.textField;
    _aroundTextField.textField.text=self.searchText;

    _searchHistory=[[POISearchHistory alloc] init];
    _arrayData=[[NSMutableArray alloc] init];
}

//调整控件竖屏坐标和图片
-(void)changePortraitControlFrameWithImage
{
    _imageViewSearch.frame=CGRectMake(SearchBar_Weight, 10,  APPWIDTH-2*SearchBar_Weight,34);
    _aroundTextField.frame=CGRectMake(0, 0,_imageViewSearch.frame.size.width, 34);
    [_tableView setFrame:CGRectMake(CCOMMON_TABLE_X,54, CCOMMON_APP_WIDTH-2*CCOMMON_TABLE_X, CCOMMON_CONTENT_HEIGHT-54)];
    [_tableView reloadData];
    [_aroundTextField changePortraitControlFrameWithImage];
}

//调整控件横屏坐标和图片
-(void)changeLandscapeControlFrameWithImage
{
    _imageViewSearch.frame=CGRectMake(SearchBar_Weight, 10,  APPHEIGHT-2*SearchBar_Weight,34);
    _aroundTextField.frame=CGRectMake(0,0,_imageViewSearch.frame.size.width, 34);
    [_tableView setFrame:CGRectMake(CCOMMON_TABLE_X, 54, CCOMMON_APP_WIDTH-2*CCOMMON_TABLE_X, CCOMMON_CONTENT_HEIGHT-54)];
    [_tableView reloadData];
    [_aroundTextField changeLandscapeControlFrameWithImage];
}
//改变控件文本
-(void)changeControlText
{

    self.navigationItem.leftBarButtonItem= LEFTBARBUTTONITEM(@"", @selector(leftBtnEvent:));
    self.navigationItem.rightBarButtonItem=RIGHTBARBUTTONITEM1([POICommon getCityName], @selector(rightBtnEvent:));
     
}
-(void)leftBtnEvent:(id)object
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)rightBtnEvent:(id)object
{
     [[PluginStrategy sharedInstance] allocViewControllerWithName:@"POICityViewController" withType:0 withViewController:self];
}
#pragma mark -
#pragma mark -Action
-(void)buttonAction:(UIButton*)object
{
    switch (object.tag) {
        
        case 1:
        {
            {
                _searchKey=_aroundTextField.textField.text;
                [self intoSearchListViewControllerL:_searchKey];

            }
            
            
        }
            break;
                   
        default:
            break;
    }

}

-(void)getHistoryKey
{
    [_arrayData removeAllObjects];
    [_arrayData addObjectsFromArray:[_searchHistory restoreHistory]];
    if (_arrayData.count==0) {
        _isNull=YES;
        [_arrayData addObject:STR(@"POI_NoHistoryKey",Localize_POI)];
    }
    else
    {
        _isNull=NO;
        [_arrayData addObject:STR(@"POI_EmptyHistoryKey", Localize_POI)];
    }

    [_tableView reloadData];
}
-(void)intoSearchListViewControllerL:(NSString*)str
{
    self.navigationController.navigationBarHidden=NO;

    if([NSString checkStringStandardWith:str]==NO)
    {
        GDAlertView *alert = [[[GDAlertView alloc] initWithTitle:nil andMessage:STR(@"POI_TextFeildErroeMessage", Localize_POI)] autorelease];
        [alert addButtonWithTitle:STR(@"POI_OK",Localize_POI) type:GDAlertViewButtonTypeCancel handler:nil];
        [alert show];
        return;
    }
    if([_aroundTextField isFirstResponder])
    {
        [_aroundTextField resignFirstResponder];
    }
    POISearchListViewController *listView=[[POISearchListViewController alloc] init];
    listView.keyWord=self.searchKey;
    [listView keyWordsearch];
    _aroundTextField.text=self.searchKey;
    listView.backType=1;
    [self.navigationController pushViewController:listView animated:YES];
    [listView release];
}


#pragma mark -
#pragma mark UITableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _arrayData.count?_arrayData.count:0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kHeight2;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *string=@"cell";
    GDTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:string];
    if (!cell) {//UITableViewCellStyleDefault cell.textLabel.textAlignment=NSTextAlignmentCenter可以居中 其他不可以
        cell=[[[GDTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:string] autorelease];
    }
    cell.emptyLineLength = 0;
    cell.textLabel.textColor=TEXTCOLOR;
    cell.textLabel.textAlignment=NSTextAlignmentLeft;
    if( _arrayData.count==1 &&_isNull==YES)
    {
        cell.textLabel.textColor=TEXTDETAILCOLOR;
        cell.textLabel.textAlignment=NSTextAlignmentCenter;
    }
    else if(_arrayData.count==indexPath.row+1)
    {
        cell.textLabel.textAlignment=NSTextAlignmentCenter;
        cell.textLabel.textColor=TEXTDETAILCOLOR;
    }
    cell.backgroundType = BACKGROUND_FOOTER;
    cell.textLabel.text=[_arrayData objectAtIndex:indexPath.row];
    return cell;

}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_tableView deselectRowAtIndexPath:indexPath animated:NO];
    if(_isNull==NO)
    {
        if (indexPath.row==[_arrayData count]-1) {
            
            GDAlertView *alertView=[[[GDAlertView alloc] initWithTitle:nil andMessage:STR(@"POI_EmptyHistoryAlertMessage",Localize_POI)] autorelease];
            [alertView addButtonWithTitle:STR(@"Universal_cancel", Localize_Universal) type:GDAlertViewButtonTypeCancel handler:nil];
            
            __block POISearchHistory *weakSearch=_searchHistory;
            __block POISearchInputViewController *weakSelf=self;
            [alertView addButtonWithTitle:STR(@"Universal_ok", Localize_Universal) type:GDAlertViewButtonTypeDefault handler:^(GDAlertView *alertView){
                [weakSearch removeAllHistory];
                [weakSelf getHistoryKey];

            }];
            [alertView show];
        }
        else
        {
            NSString *str=[_arrayData objectAtIndex:indexPath.row];
            _searchKey=str;
            [self intoSearchListViewControllerL:_searchKey];
        }
    }
    
}

#pragma mark -
#pragma mark UITextFieldDelegate


-(BOOL)textFieldChanage:(UITextField*)textField withRange:(NSRange)range withString:(NSString*)string
{
    if (range.location>20-1) {
        return NO;
    }
    return YES;

}

- (BOOL)textFieldShouldClear:(UITextField *)textField{
    textField.text=@"";
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    _searchKey=textField.text;
    [self intoSearchListViewControllerL:textField.text];
    return YES;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_aroundTextField.textField resignFirstResponder];
}

#pragma mark -
-(void)buttonTouchEvent:(NSString*)string withButton:(UIButton*)button
{
    if (button.tag ==100) {
        [self gotoVoiceSearch];
        
    }else
    {
        _searchKey=string;
       [self intoSearchListViewControllerL:_searchKey];
    }
}
-(void)textFieldReturn:(NSString *)string
{
    _searchKey=string;
    [self intoSearchListViewControllerL:_searchKey];
    
}
-(void)gotoVoiceSearch
{
    if ([POICommon isCanVoiceInput]==NO) {
        return;
    }
    _poiOperator = [[MWPoiOperator alloc]initWithDelegate:self];
    GMAPCENTERINFO mapinf = {0};
    [[MWMapOperator sharedInstance] MW_GetMapViewCenterInfo:GMAP_VIEW_TYPE_MAIN mapCenterInfo:&mapinf];
    
    int adminCode = [MWAdminCode GetCityAdminCodeWithAdminCode:[MWAdminCode GetCurAdminCode]];
    MWVoiceOption *option = [[MWVoiceOption alloc] init];
    option.longitude = mapinf.CenterCoord.x;
    option.latitude = mapinf.CenterCoord.y;
    option.lAdminCode = adminCode;
    [_poiOperator voiceSearchWith:option withSuperView:self.view];
    [option release];
    
    if (Interface_Flag == 0) {
        [MWPoiOperator setRecognizeViewCenter:CGPointMake(APPWIDTH/2.0, APPHEIGHT/2.0)];
		
	}
	else if(Interface_Flag == 1){
        [MWPoiOperator setRecognizeViewCenter:CGPointMake(APPHEIGHT/2.0, APPWIDTH/2.0)];
        
	}
}
#pragma mark MWPoiOperatorDelegate
- (void)voiceSearchResult:(MWVoiceResult *)result
{
    NSString * stringVoiceName = nil;
    if ([result.cmdtxt length] > 0)
    {
        stringVoiceName = result.cmdtxt;
        _searchKey=stringVoiceName;
        [self intoSearchListViewControllerL:_searchKey];
        
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

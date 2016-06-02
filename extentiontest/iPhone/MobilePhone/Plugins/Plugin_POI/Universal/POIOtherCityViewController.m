//
//  POIOtherCityViewController.m
//  AutoNavi
//
//  Created by huang on 13-8-19.
//
//

#import "POIOtherCityViewController.h"
#import "GDSearchListCell.h"
#import "MWSearchResult.h"
#import "POIOtherCityDetailViewController.h"
#import "POIDefine.h"

@interface POIOtherCityViewController ()
{
     UIView   *  tableHeadView;
     UILabel  * _labelStringText;
     UILabel  * _labelRecoveryKey;
     UIButton * _buttonRecovery;
}
@end

@implementation POIOtherCityViewController
@synthesize arrayOtherCityData,keyWord,recoveryKeyWorld;
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
    CRELEASE(arrayOtherCityData);
    CRELEASE(recoveryKeyWorld);
    CRELEASE(_labelStringText);
	[super dealloc];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
    [self initControl];
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.navigationController.navigationBarHidden=NO;
}
#pragma mark -
#pragma mark control related
//初始化控件
-(void) initControl{
    
    float lableHeight = self.recoveryKeyWorld.length>0?40.0:0.0;
     // 提示栏
     tableHeadView = [[UIView alloc]init];
    [tableHeadView setFrame:CGRectMake(0, 0, APPWIDTH, 56.0+lableHeight)];
    if (self.recoveryKeyWorld.length>0) {
        _labelRecoveryKey = [self createLabelWithText:STR(@"POI_SearchingFor", Localize_POI) fontSize:kSize2 textAlignment:NSTextAlignmentCenter];
        _labelRecoveryKey.numberOfLines = 0;
        _labelRecoveryKey.textColor = [UIColor colorWithRed:120.0/255.0 green:120.0/255.0 blue:120.0/255 alpha:1.0];
        CGSize textSize = [_labelRecoveryKey.text sizeWithFont:_labelRecoveryKey.font];
        [_labelRecoveryKey setFrame:CGRectMake(0+5, 0, textSize.width, kHeight5)];
        [tableHeadView addSubview:_labelRecoveryKey];
        
        _buttonRecovery = [self createButtonWithTitle:self.recoveryKeyWorld normalImage:@"" heightedImage:@"" tag:0 withImageType:IMAGEPATH_TYPE_1];
        [_buttonRecovery setTitleColor:[UIColor colorWithRed:55.0/255.0f green:135.0/255.0f blue:51/255.0f alpha:1.0] forState:UIControlStateNormal];
        CGSize buttonSize = [self.recoveryKeyWorld sizeWithFont:_labelRecoveryKey.font];
        [_buttonRecovery setFrame:CGRectMake(5+textSize.width+2, 0, buttonSize.width+10, kHeight5)];
        [tableHeadView addSubview:_buttonRecovery];
    }
    NSString *city =  [POICommon getCityName];
    NSString *stPrompt;
    if (NULL!=self.keyWord&&NULL!=city) {
         stPrompt = [NSString stringWithFormat:STR(@"POI_OtherCityMessage", Localize_POI), city, keyWord];
        if ([[MWPreference sharedInstance] getValue:PREF_UILANGUAGE]==2) {
             stPrompt = [NSString stringWithFormat:STR(@"POI_OtherCityMessage", Localize_POI), keyWord, city];
        }
       
    }
    
    _labelStringText = [[self createLabelWithText:stPrompt fontSize:kSize2 textAlignment:NSTextAlignmentLeft] retain];
    [_labelStringText setFrame:CGRectMake(5+0.0, lableHeight, APPWIDTH-10, 56.0)];
    _labelStringText.lineBreakMode =UILineBreakModeWordWrap;
    _labelStringText.numberOfLines = 0;
    _labelStringText.textColor =TEXTCOLOR ;
    self.title=self.keyWord;
    [tableHeadView addSubview:_labelStringText];
    
    _tableView.tableHeaderView=tableHeadView;
    [tableHeadView release];
    
}

//调整控件竖屏坐标和图片
-(void)changePortraitControlFrameWithImage
{
    float height=46;
     float lableHeight = self.recoveryKeyWorld.length>0?40.0:0.0;
    CGSize size=[_labelStringText.text sizeWithFont:_labelStringText.font constrainedToSize:CGSizeMake(CCOMMON_APP_WIDTH-2*CCOMMON_TABLE_X, 100)];
    if (size.height>46) {
       height = size.height+10;
    }
     [tableHeadView setFrame:CGRectMake(5, 0, APPWIDTH-10, 56.0+lableHeight)];
    CGSize textSize = [_labelRecoveryKey.text sizeWithFont:_labelRecoveryKey.font];
    CGSize buttonSize = [self.recoveryKeyWorld sizeWithFont:_labelRecoveryKey.font];
    [_labelRecoveryKey setFrame:CGRectMake(5+0, 0, textSize.width, kHeight5)];
    [_buttonRecovery setFrame:CGRectMake(5+textSize.width+2, 0, buttonSize.width+10, kHeight5)];
    [_labelStringText setFrame:CGRectMake(5+0.0f, 10.0f+lableHeight, CCOMMON_APP_WIDTH-2*CCOMMON_TABLE_X-10, height)];
    _tableView.tableHeaderView=tableHeadView;
     [_tableView setFrame:CGRectMake(CCOMMON_TABLE_X, 0, CCOMMON_APP_WIDTH-2*CCOMMON_TABLE_X, CCOMMON_CONTENT_HEIGHT-0)];
    [_tableView reloadData];
}

//调整控件横屏坐标和图片
-(void)changeLandscapeControlFrameWithImage
{
    float height=46;
     float lableHeight = self.recoveryKeyWorld.length>0?40.0:0.0;
     [tableHeadView setFrame:CGRectMake(0, 0, APPWIDTH, 56.0+lableHeight)];
    CGSize textSize = [_labelRecoveryKey.text sizeWithFont:_labelRecoveryKey.font];
    CGSize buttonSize = [self.recoveryKeyWorld sizeWithFont:_labelRecoveryKey.font];
    [_labelRecoveryKey setFrame:CGRectMake(5, 0, textSize.width, kHeight5)];
    [_buttonRecovery setFrame:CGRectMake(5+textSize.width+2, 0, buttonSize.width+10, kHeight5)];
    [_labelStringText setFrame:CGRectMake(5+0.0f, 10.0f+ lableHeight, CCOMMON_APP_WIDTH-2*CCOMMON_TABLE_X-10, height)];
    _tableView.tableHeaderView=tableHeadView;
    [_tableView setFrame:CGRectMake(CCOMMON_TABLE_X, 0, CCOMMON_APP_WIDTH-2*CCOMMON_TABLE_X, CCOMMON_CONTENT_HEIGHT-0)];
    [_tableView reloadData];
}
//改变控件文本
-(void)changeControlText
{
//   self.title=STR(@"POI_WhereToGoTitle", Localize_POI);
    self.navigationItem.leftBarButtonItem=LEFTBARBUTTONITEM(@"", @selector(leftBtnEvent:));
}
-(void)leftBtnEvent:(id)object
{
	[self.navigationController popViewControllerAnimated:YES];
}



#pragma mark -
#pragma mark UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kHeight2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arrayOtherCityData.count?arrayOtherCityData.count:0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return  0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    GDTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[GDTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    cell.emptyLineLength = 0;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    UIImageView *tempimg = [[UIImageView alloc] initWithImage:IMAGE(@"Accessory.png",IMAGEPATH_TYPE_1)];
    cell.accessoryView = tempimg;
    [tempimg release];
    cell.backgroundType = BACKGROUND_FOOTER;
    if (self.arrayOtherCityData) {
        MWArea * node = (MWArea *)[self.arrayOtherCityData objectAtIndex:indexPath.row];
        NSString * stOtherCityInfo =nil;
        stOtherCityInfo = [NSString stringWithFormat:@"%@ (%d)",node.szAdminName, node.lNumberOfSubAdarea];
        cell.textLabel.text  = stOtherCityInfo;
    }
    return cell;
}
#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.arrayOtherCityData) {
        MWArea * node = (MWArea *)[self.arrayOtherCityData objectAtIndex:indexPath.row];
        POIOtherCityDetailViewController * otherCityDetail=[[POIOtherCityDetailViewController alloc] init];
        otherCityDetail.sizePageCount=node.lNumberOfSubAdarea;
        otherCityDetail.searchType=self.searchType;
        otherCityDetail.keyWord=self.keyWord;
        otherCityDetail.nAdminCode=node.lAdminCode;
        [self.navigationController pushViewController:otherCityDetail animated:YES];
        [otherCityDetail release];
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
}
-(void)buttonAction:(UIButton*)button
{
    if (button.tag == 0) {
        POIOtherCityDetailViewController * otherCityDetail=[[POIOtherCityDetailViewController alloc] init];
        otherCityDetail.searchType=self.searchType;
        otherCityDetail.keyWord=self.recoveryKeyWorld;
        int adminCode=[MWAdminCode GetCityAdminCodeWithAdminCode:[MWAdminCode GetCurAdminCode]];
        if ([ANParamValue sharedInstance].isSelectCity==1) {
            MWAreaInfo * info = [MWAdminCode GetCurAdarea];
            adminCode = info.lAdminCode;
        }
        otherCityDetail.nAdminCode = adminCode;
        [self.navigationController pushViewController:otherCityDetail animated:YES];
        [otherCityDetail release];
    }
}

@end

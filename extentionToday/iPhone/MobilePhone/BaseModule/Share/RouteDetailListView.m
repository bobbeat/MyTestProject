//
//  RouteDetailListView.m
//  AutoNavi
//
//  Created by jiangshu-fu on 14-7-16.
//
//

#import "RouteDetailListView.h"
#import "RouteDetailListCell.h"
#import "MainDefine.h"

#define SELF_VIEW_HEIGHT (isiPhone ? (MAIN_POR_HEIGHT - 109.0f - DIFFENT_STATUS_HEIGHT + 3.0f) : (MAIN_POR_HEIGHT - 74.0f - 112.0f - DIFFENT_STATUS_HEIGHT  + 3))
#define SELF_VIEW_HEIGHT_HENG (isiPhone ? (MAIN_LAND_HEIGHT - 72.0f - DIFFENT_STATUS_HEIGHT ) :(MAIN_LAND_HEIGHT - 112.0f  + 3- DIFFENT_STATUS_HEIGHT ))

#define headViewHeight 44.0f



@implementation RouteDetailViewController


#pragma mark -
#pragma mark viewcontroller ,
- (id)init
{
	self = [super init];
	if (self)
	{
        NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:0];
        self.arrayListData = array;
        [array release];
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.separatorStyle = NO;
        [_tableView setSeparatorColor:[UIColor clearColor]];
        [self addSubview:_tableView];
        [_tableView release];
        self.avoidCell = nil;
        self.selectCell = nil;
        self.closePress = nil;
        
        _shadeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MAIN_POR_WIDTH, SELF_VIEW_HEIGHT + 20)];
        //不用修改。
        _shadeView.backgroundColor = RGBACOLOR(0, 0, 0, 0.5);
        [self addSubview:_shadeView];
        [_shadeView release];
        _dictionaryOpen = [[NSMutableDictionary alloc]init];
        [self initControl];
        [self sendSubviewToBack:_shadeView];

	}
	return self;
}


- (void)dealloc
{
    CRELEASE(_arrayListData);
    CRELEASE(_dictionaryOpen);
    CRELEASE(_imageHeaderView);
    CRELEASE(_closePress);
    CRELEASE(_avoidCell);
    CRELEASE(_selectCell);
	[super dealloc];
}

#pragma mark -
#pragma mark control related
//初始化控件
-(void) initControl
{
    _imageHeaderView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, headViewHeight)];
    _imageHeaderView.userInteractionEnabled = YES;
    _imageHeaderView.image = [IMAGE(@"Route_DetailheaderBG.png", IMAGEPATH_TYPE_1) stretchableImageWithLeftCapWidth:3 topCapHeight:34];
    _labelTitle = [[UILabel alloc]init];
    [_labelTitle setFrame:CGRectMake(0, 0, _imageHeaderView.frame.size.width, _imageHeaderView.frame.size.height)];
    _labelTitle.text = STR(@"RoutePointview_RouteDetail", Localize_RouteOverview);
    _labelTitle.textAlignment = NSTextAlignmentCenter;
    _labelTitle.backgroundColor = [UIColor clearColor];
    _labelTitle.font = [UIFont systemFontOfSize:17.0f];
    _labelTitle.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_imageHeaderView addSubview:_labelTitle];
    _buttonClose = [UIButton buttonWithType:UIButtonTypeCustom];
    [_buttonClose addTarget:self action:@selector(closePress:) forControlEvents:UIControlEventTouchUpInside];
    [_buttonClose setImage:IMAGE(@"RouteDetailClose.png", IMAGEPATH_TYPE_1)
                            forState:UIControlStateNormal];
    [_buttonClose setFrame:CGRectMake(_imageHeaderView.frame.size.width - headViewHeight,
                                     0,
                                     headViewHeight,
                                      headViewHeight)];
    _buttonClose.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [_imageHeaderView addSubview:_buttonClose];
    [_labelTitle release];
    _imageHeaderView.backgroundColor = [UIColor redColor];
    if(Interface_Flag == 0)
    {
        [self changePortraitControlFrameWithImage];
    }
    else
    {
        [self changeLandscapeControlFrameWithImage];
    }
}


//调整控件竖屏坐标和图片
-(void)changePortraitControlFrameWithImage
{
    self.frame = CGRectMake(0.0f, 0.0f, MAIN_POR_WIDTH, SELF_VIEW_HEIGHT);
    _tableView.frame = CGRectMake(0, DIFFENT_STATUS_HEIGHT == 0 ? 0.0f : 20.0f, MAIN_POR_WIDTH, SELF_VIEW_HEIGHT);
    _shadeView.frame = CGRectMake(0, 0, MAIN_POR_WIDTH, SELF_VIEW_HEIGHT + DIFFENT_STATUS_HEIGHT);

}

//调整控件横屏坐标和图片
-(void)changeLandscapeControlFrameWithImage
{
    self.frame = CGRectMake(0.0f, 0.0f, MAIN_LAND_WIDTH, SELF_VIEW_HEIGHT_HENG );
    _tableView.frame = CGRectMake(0, DIFFENT_STATUS_HEIGHT == 0 ? 0.0f : 20.0f, MAIN_LAND_WIDTH, SELF_VIEW_HEIGHT_HENG );
    _shadeView.frame = CGRectMake(0, 0, MAIN_LAND_WIDTH, SELF_VIEW_HEIGHT_HENG + DIFFENT_STATUS_HEIGHT);
}

#pragma mark -  ---  按钮事件  ---
- (void) closePress:(id) sender
{
    self.hidden = YES;
    if(self.closePress)
    {
        self.closePress();
    }
}

#pragma mark - ---  tableView 的 datasource  ---

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.arrayListData.count;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int returnCount = 1;
    ManeuverInfo *data = (ManeuverInfo *)[self.arrayListData objectAtIndex:section];
    if(data.isExtension)
    {
        returnCount += data.nNumberOfSubManeuver;
    }
    return returnCount;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if(section == 0)
    {
        return _imageHeaderView;
    }
    else
    {
        UIView *view = [[[UIView alloc]init] autorelease];
        view.backgroundColor = [UIColor clearColor];
        return view;
    }
}

#pragma mark ---  cell的高度和标题视图的高度  ---
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat cellHeight = 60.0f;
    if(indexPath.row != 0)
    {
        cellHeight = 40.0f;
    }
	return cellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(section == 0)
    {
        return headViewHeight;
    }
    else
    {
        return 0;
    }
}



#pragma mark ---  cell的设计  ---
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    RouteDetailListCell *cell = (RouteDetailListCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil)
    {
        cell = [[[RouteDetailListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    if(indexPath.row == 0)
    {
        cell.cellData = (ManeuverInfo *)[self.arrayListData objectAtIndex:indexPath.section];
        
        if (cell.cellData.isExtension == YES)
        {
            cell.emptyLineLength = -1;
        }
        else
        {
            cell.emptyLineLength = 52.0f;
        }
    }
    else
    {
        ManeuverInfo *tempInfo = ((ManeuverInfo *)[self.arrayListData objectAtIndex:indexPath.section]);
        cell.cellData = [tempInfo.pstSubManeuverText objectAtIndex:(indexPath.row - 1)];
        if(tempInfo.nNumberOfSubManeuver == indexPath.row)
        {
            cell.emptyLineLength = 52.0f;
        }
        else
        {
            cell.emptyLineLength = -1;
        }
        int i = ((ManeuverInfo *)[((ManeuverInfo *)[self.arrayListData objectAtIndex:indexPath.section]).pstSubManeuverText
                          objectAtIndex:(indexPath.row - 1)]).unTurnID;
        NSLog(@"cell %d,%d : i =  %d",indexPath.section,indexPath.row,i);
    }
    
    __block RouteDetailListCell *blockcell = cell;
    __block RouteDetailViewController *blockSelf = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        blockcell.avoidPress =^(ManeuverInfo *info){
            [blockSelf avoidCellPress:info];
        };
    });
    return cell;
}

#pragma mark -  避让按钮点击  -
- (void) avoidCellPress:(ManeuverInfo *)info
{
    NSLog(@"12312312312312312");
    if(self.avoidCell)
    {
        self.avoidCell(info);
    }
}

- (void) reloadData
{
    [_tableView reloadData];
}

#pragma mark ---  tableView 的 delegate  ---
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0)
    {
        ManeuverInfo *data = (ManeuverInfo *)[self.arrayListData objectAtIndex:indexPath.section];
        if(data.nNumberOfSubManeuver == 0)
        {
#warning - ---  push节点界面  ---
            if(self.selectCell)
            {
                self.selectCell(self.arrayListData,indexPath);
            }
        }
        else
        {
//            [_tableView beginUpdates];
            data.isExtension = !data.isExtension;
//            [_tableView endUpdates];

            [_tableView reloadData];
        }
        
    }
    else
    {
        if(self.selectCell)
        {
            self.selectCell(self.arrayListData,indexPath);
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end

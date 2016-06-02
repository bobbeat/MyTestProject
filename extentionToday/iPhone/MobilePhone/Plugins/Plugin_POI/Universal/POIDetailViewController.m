//
//  POIDetailViewController.m
//  AutoNavi
//
//  Created by huang longfeng on 13-9-9.
//
//

#import "POIDetailViewController.h"
#import "ControlCreat.h"
#import "MWSearchResult.h"
#import "POIRouteCalculation.h"
#import "POICommon.h"
#import "Plugin_Share.h"
#import "PluginStrategy.h"
#import "POIDetailViewController.h"
#import "ANDataSource.h"
#import "POIDefine.h"
#import "Plugin_Main.h"
#import "UMengEventDefine.h"
#import "Plugin_UserFeedBack.h"
#import "GDSearchListCell.h"
#import "LXActivity.h"
#import "POICellButtonEvent.h"
#import "Plugin_POI.h"
#define ButtonBackground   @""
#define ButtonBackground1  @"POISelectImage.png"
#define POIFriend          @"POIFriend.png"
#define POICollect1        @"POICollect_1.png"
#define POICollect2        @"POICollect_2.png"
#define POISetDes          @"POISetDes.png"
#define POISetStart        @"POISetStart.png"
#define POISina            @"POISina.png"
#define POIWechat          @"POIWechat.png"
#define POICall            @"POICall.png"
#define POIMessage         @"POIMessage.png"
#define POIHome            @"POIHome.png"
#define POICompany         @"POICompany.png"

@interface POIDetailViewController ()<LXActivityDelegate>
{
    POIRouteCalculation * _routeCalculation;
    

    UIButton     *buttonSetStart;
    UIButton     *buttonSetDes;
    UIButton     *buttonCollect;
    UIButton     *buttonCall;
    UIButton     *buttonHome;
    UIButton     *buttonComany;
    UIButton     *buttonShare;
    UIButton     *buttonError;
    UIImageView  * _imageViewLine;
    UIImageView  * imageViewDetail;
    UIImageView  * imageViewAction;
    
    BOOL isCollect;
}

@property (nonatomic,retain) MWPoi *poiDetail;

@end

@implementation POIDetailViewController

@synthesize poiDetail;

#pragma mark -
#pragma mark viewcontroller ,
- (id)initWithPOI:(MWPoi *)detailInfo
{
	self = [super init];
	if (self)
	{
       
		self.poiDetail = detailInfo;
        
      
	}
	return self;
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (self.poiDetail) {
        [self.poiDetail release];
    }
    CRELEASE(_routeCalculation);
	[super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}
- (void)viewDidUnLoad
{
	[super viewDidLoad];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
    self.title = STR(@"POI_Detail", Localize_POI);
    self.navigationItem.leftBarButtonItem = LEFTBARBUTTONITEM(nil, @selector(goBack:));
  
    [self changeControlText];
   
}
// Called when the view is about to made visible. Default does nothing
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [_tableView reloadData];
    
    
}
// Called when the view has been fully transitioned onto the screen. Default does nothing

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}
// Called when the view is dismissed, covered or otherwise hidden. Default does nothing

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

// Called after the view was dismissed, covered or otherwise hidden. Default does nothing
-(void)viewDidDisappear:(BOOL)animated;
{
    [super viewDidDisappear:animated];
}
-(void)changeControlText
{
    
}
-(void)changeLandscapeControlFrameWithImage
{
    [_tableView setFrame:CGRectMake(0, 0,APPHEIGHT, CONTENTHEIGHT_H)];
    [_tableView reloadData];
}
//述评
-(void)changePortraitControlFrameWithImage
{
    [_tableView setFrame:CGRectMake(0, 0, APPWIDTH, APPHEIGHT)];
    [_tableView reloadData];
}
#pragma mark UITableViewDelegate, UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section ==0 ) {
        return 2;
    }else if (section ==1)
    {
        return 2;
    }return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        return  indexPath.row==0?kHeight5+10:kHeight2;
    }return kHeight5;
}
-(void)naviEvent:(id)object
{
    if (_routeCalculation == nil) {
        _routeCalculation=[[POIRouteCalculation alloc] initWithViewController:self];
    }
    [_routeCalculation setBourn:poiDetail];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            static NSString * identy = @"cell";
            GDSearchListCell * cell = [tableView dequeueReusableCellWithIdentifier:identy];
            if (cell ==nil) {
                cell = [[[GDSearchListCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identy] autorelease];
                [cell.naviButton addTarget:self action:@selector(naviEvent:) forControlEvents:UIControlEventTouchUpInside];
            }
            cell.emptyLineLength = 0;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.searchType =    SEARCH_CELL_NAVI;
            cell.backgroundType = BACKGROUND_FOOTER;
            cell.type = SEARCH_CELL_LINE_TYPE;
            
                GCARINFO carInfo={0};
                GDBL_GetCarInfo(&carInfo);
                GCOORD des={0};
                des.x=poiDetail.longitude;
                des.y=poiDetail.latitude;
            int distance=   [MWEngineTools CalcDistanceFrom:carInfo.Coord  To:des];
            poiDetail.lDistance = distance;
            NSLog(@"%d",distance);
            cell.poi = poiDetail;
            return cell;
        }else
        {
            static NSString * identy = @"cell";
            GDTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identy];
            if (cell ==nil) {
                cell = [[[GDTableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identy] autorelease];
            }
            for(UIView *view in cell.contentView.subviews)
            {
                [view removeFromSuperview];
            }
            cell.emptyLineLength = 0;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            cell.backgroundType = BACKGROUND_FOOTER;
            //打电话
            buttonCall = [[self createButtonWithTitle:STR(@"Main_call", Localize_Main) normalImage:ButtonBackground heightedImage:ButtonBackground1 tag:POIButtonType_Call strechParamX:5 strechParamY:10] retain];
            buttonCall.titleLabel.font = [UIFont systemFontOfSize:kSize3];
            [buttonCall setImage:IMAGE(POICall, IMAGEPATH_TYPE_1) forState:UIControlStateNormal];
            buttonCall.frame = CGRectMake(2*_tableView.bounds.size.width/3, 0 ,_tableView.bounds.size.width/3, kHeight2);
            [buttonCall setTitleColor:TEXTDETAILCOLOR forState:UIControlStateDisabled];
            [buttonCall setBackgroundImage:[IMAGE(ButtonBackground,IMAGEPATH_TYPE_1) stretchableImageWithLeftCapWidth:5 topCapHeight:10] forState:UIControlStateDisabled];
            [cell.contentView addSubview:buttonCall];
            [buttonCall release];
            buttonCall.enabled = YES;
            if (poiDetail.szTel && [poiDetail.szTel length] > 0) {
                if (!isiPhone) {
                     buttonCall.enabled = NO;
                }
            }
            else{
                buttonCall.enabled = NO;
            }
            [buttonCall setTitleColor:TEXTCOLOR forState:UIControlStateNormal];
            [self createLabelHight:CGRectMake(_tableView.bounds.size.width/3,7, 1.5,30) andCell:cell];
            
            //收藏//POISetDes.png
            buttonCollect = [[self createButtonWithTitle:STR(@"Main_collect", Localize_Main) normalImage:ButtonBackground heightedImage:ButtonBackground1 tag:POIButtonType_Collect strechParamX:5 strechParamY:10] retain];
            buttonCollect.titleLabel.font = [UIFont systemFontOfSize:kSize3];
            isCollect = [MWPoiOperator isCollect:self.poiDetail];
            [buttonCollect setImage:IMAGE(isCollect?POICollect2:POICollect1, IMAGEPATH_TYPE_1) forState:UIControlStateNormal];
            buttonCollect.frame = CGRectMake(_tableView.bounds.size.width/3, 0,_tableView.bounds.size.width/3,kHeight2);
            [cell.contentView addSubview:buttonCollect];[buttonCollect release];
            [buttonCollect setTitleColor:TEXTCOLOR forState:UIControlStateNormal];
//            //分享
            [self createLabelHight:CGRectMake(2*_tableView.bounds.size.width/3,7, 1.5,30) andCell:cell];
            buttonShare = [[self createButtonWithTitle:STR(@"MR_Share", Localize_MileRecord) normalImage:ButtonBackground heightedImage:ButtonBackground1 tag:POIButtonType_Share strechParamX:5 strechParamY:10] retain];
            buttonShare.titleLabel.font = [UIFont systemFontOfSize:kSize3];
            [buttonShare setImage:IMAGE(@"POIShare.png", IMAGEPATH_TYPE_1) forState:UIControlStateNormal];
            buttonShare.frame = CGRectMake(0, 0 ,_tableView.bounds.size.width/3, kHeight2);
            [buttonShare setTitleColor:TEXTDETAILCOLOR forState:UIControlStateDisabled];
            [cell.contentView addSubview:buttonShare];
            [buttonShare release];
            [buttonShare setTitleColor:TEXTCOLOR forState:UIControlStateNormal];
         
            
            return cell;
        }
        
        
    }else
    {
        static NSString * identy = @"cell";
        GDTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identy];
        if (cell ==nil) {
            cell = [[[GDTableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identy] autorelease];
        }
        if (indexPath.section ==1)
        {
            for(UIView *view in cell.contentView.subviews)
            {
                [view removeFromSuperview];
            }
            
            if (indexPath.row ==0) {
                cell.backgroundType = BACKGROUND_FOOTER;
                //设为起点
                buttonSetStart = [[self createButtonWithTitle:STR(@"Main_setAsStart", Localize_Main) normalImage:ButtonBackground heightedImage:ButtonBackground1 tag:POIButtonType_SetStart strechParamX:5 strechParamY:10] retain];
                buttonSetStart.titleLabel.font = [UIFont systemFontOfSize:kSize3];
                [buttonSetStart setImage:IMAGE(@"POISetStart.png", IMAGEPATH_TYPE_1) forState:UIControlStateNormal];
                buttonSetStart.frame = CGRectMake(0,0,_tableView.bounds.size.width/2,kHeight5);
                [cell.contentView addSubview:buttonSetStart];[buttonSetStart release];
                [buttonSetStart setTitleColor:TEXTCOLOR forState:UIControlStateNormal];
                [self createLabelHight:CGRectMake(_tableView.bounds.size.width/2, 0, 1.5, kHeight5) andCell:cell];
                //谁为佳 POIHome
                buttonHome=[[self createButtonWithTitle:STR(@"POI_SetHomeAddress", Localize_POI) normalImage:ButtonBackground heightedImage:ButtonBackground1 tag:POIButtonType_Home strechParamX:5 strechParamY:10] retain];
                buttonHome.titleLabel.font = [UIFont systemFontOfSize:kSize3];
                [buttonHome setImage:IMAGE(POIHome, IMAGEPATH_TYPE_1) forState:UIControlStateNormal];
                buttonHome.frame = CGRectMake(_tableView.bounds.size.width/2, 0,_tableView.bounds.size.width/2,kHeight5);
                [buttonHome setTitleColor:TEXTDETAILCOLOR forState:UIControlStateDisabled];
                [buttonHome setBackgroundImage:[IMAGE(ButtonBackground,IMAGEPATH_TYPE_1) stretchableImageWithLeftCapWidth:5 topCapHeight:10] forState:UIControlStateDisabled];
                 [buttonHome setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 10)];
                [cell.contentView addSubview:buttonHome];
                [buttonHome release];
                [buttonHome setTitleColor:TEXTCOLOR forState:UIControlStateNormal];
                
                
            }
            else
            {
                buttonSetDes = [[self createButtonWithTitle:STR(@"Main_setAsDestination", Localize_Main) normalImage:ButtonBackground heightedImage:ButtonBackground1 tag:POIButtonType_SetDes strechParamX:5 strechParamY:10] retain];
                
                buttonSetDes.titleLabel.font = [UIFont systemFontOfSize:kSize3];
                [buttonSetDes setImage:IMAGE(POISetDes, IMAGEPATH_TYPE_1) forState:UIControlStateNormal];
                buttonSetDes.frame = CGRectMake(0,0,_tableView.bounds.size.width/2,kHeight5);
                
                [cell.contentView addSubview:buttonSetDes];[buttonSetDes release];
                [buttonSetDes setTitleColor:TEXTCOLOR forState:UIControlStateNormal];
                
                [self createLabelHight:CGRectMake(_tableView.bounds.size.width/2, 0, 1.5, kHeight5) andCell:cell];
                buttonComany=[[self createButtonWithTitle:STR(@"POI_SetCompanyAddress", Localize_POI) normalImage:ButtonBackground heightedImage:ButtonBackground1 tag:POIButtonType_Company strechParamX:5 strechParamY:10] retain];
                buttonComany.titleLabel.font = [UIFont systemFontOfSize:kSize3];
                [buttonComany setImage:IMAGE(@"POICompany.png", IMAGEPATH_TYPE_1) forState:UIControlStateNormal];
                buttonComany.frame = CGRectMake(_tableView.bounds.size.width/2, 0,_tableView.bounds.size.width/2,kHeight5);
                [buttonComany setTitleColor:TEXTDETAILCOLOR forState:UIControlStateDisabled];
                [buttonComany setBackgroundImage:[IMAGE(ButtonBackground,IMAGEPATH_TYPE_1) stretchableImageWithLeftCapWidth:5 topCapHeight:10] forState:UIControlStateDisabled];
                [cell.contentView addSubview:buttonComany];
                [buttonComany release];
                [buttonComany setTitleColor:TEXTCOLOR forState:UIControlStateNormal];
                cell.backgroundType = BACKGROUND_FOOTER;
            }
            
        }else if(indexPath.section ==2)
        {
            for(UIView *view in cell.contentView.subviews)
            {
                [view removeFromSuperview];
            }
            cell.backgroundType = BACKGROUND_FOOTER;
            buttonError = [[self createButtonWithTitle:STR(@"TS_AnError", Localize_UserFeedback) normalImage:ButtonBackground heightedImage:ButtonBackground1 tag:POIButtonType_Error strechParamX:5 strechParamY:10] retain];
            buttonError.titleLabel.font = [UIFont systemFontOfSize:kSize3];;
            buttonError.frame = CGRectMake(0, 0,_tableView.bounds.size.width,kHeight5);
            [buttonError setImage:IMAGE(@"POIError.png", IMAGEPATH_TYPE_1) forState:UIControlStateNormal];
            [cell.contentView addSubview:buttonError];[buttonError release];
            [buttonError setTitleColor:TEXTCOLOR forState:UIControlStateNormal];
        }
        
        return cell;
        
    }
    return nil;
}
-(void)createLabelHight:(CGRect)frame andCell:(GDTableViewCell *)cell
{
    UIImage * image =[IMAGE(@"POILine.png", IMAGEPATH_TYPE_1) stretchableImageWithLeftCapWidth:0.5 topCapHeight:5];
    _imageViewLine = [self createImageViewWithFrame:frame normalImage:image tag:nil];
    [cell.contentView addSubview:_imageViewLine];
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section ==2) {
        
    }
}
-(void)goBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark -
#pragma mark control action
- (void)didClickOnImageIndex:(NSInteger )didSelect
{// 1 短信 2 微信好友 3 微信朋友圈 4 新浪微博
    int type=-1;
    int isFriend;
    NSString  * stringURL = nil;
    switch (didSelect) {
        case 0:
        {
            [MobClick event:UM_EVENTID_POI_DETAIL_COUNT label:UM_LABEL_POI_DETAIL_MESSAGE];
            type=Share_Message;
        }
            break;
        case 1:
        {
            [MobClick event:UM_EVENTID_POI_DETAIL_COUNT label:UM_LABEL_POI_DETAIL_WEIXIN];
            type=Share_WeChat;
            isFriend=0;
        }break;
        case 2 :
        {
            [MobClick event:UM_EVENTID_POI_DETAIL_COUNT label:UM_LABEL_POI_DETAIL_FRIEND];
            type=Share_WeChat;
            isFriend=1;
        }break;
        case 3:
        {
            [MobClick event:UM_EVENTID_POI_DETAIL_COUNT label:UM_LABEL_POI_DETAIL_WEIBO];
            type=Share_Sina;

        }break;
        default:
            break;;
    }
    if(type!=-1)
    {
        GCOORD  gcoord= {0};
        gcoord.x = self.poiDetail.longitude;
        gcoord.y = self.poiDetail.latitude;
        NSString * m_strSPcode = [MWEngineTools GeoCoordToSP:&gcoord];
        NSLog(@"%@",m_strSPcode);
        NSMutableString *mutableString = nil;
        mutableString  =[NSMutableString stringWithFormat:@"%@\n\n\%@: %@ \n%@\n",STR(@"Share_ShareTitle",Localize_POIShare),STR(@"Share_Name",Localize_POIShare),self.poiDetail.szName,self.poiDetail.szAddr];
        if (poiDetail.szTel.length>0) {
            [mutableString appendFormat:@"%@\n",self.poiDetail.szTel];
        }
        [mutableString appendFormat:@"\n"];
        
        if (type==Share_Sina) {
            [mutableString appendFormat:@"%@: http://iphone.autonavi.com/annex/ff/%@\n",STR(@"Share_LocationPoint",Localize_POIShare),m_strSPcode];
            [mutableString appendFormat:@"\n%@:\n http://itunes.apple.com/cn/app/id324101974?mt=8 @高德导航",STR(@"Share_Sina",Localize_POIShare)];
            
        }
        else if(type==Share_Message)
        {
            [mutableString appendFormat:@"%@: Autonavi://%@ \n\n%@: http://iphone.autonavi.com/annex/ff/%@",STR(@"Share_Navi",Localize_POIShare),[NSString stringWithFormat:@"IA%@",m_strSPcode],STR(@"Share_NOInstall",Localize_POIShare),m_strSPcode];
        }
        else
        {
            stringURL = [NSString stringWithFormat:@"http://iphone.autonavi.com/annex/ff/%@",m_strSPcode];
            if (mutableString) {
                mutableString = nil;
            }
            mutableString = [NSMutableString stringWithFormat:@"%@",self.poiDetail.szAddr];
            if (poiDetail.szTel.length>0) {
                 [mutableString appendFormat:@"\n%@%@\n",STR(@"POI_Phone", Localize_POI),self.poiDetail.szTel];
            }
        }
        NSString * stringName = [NSString stringWithFormat:@"%@",self.poiDetail.szName];
        
        NSMutableDictionary * dic = [NSMutableDictionary dictionary];
        if (type) {
            [dic setObject:[NSString stringWithFormat:@"%d",type] forKey:@"shareType"];
        }
        [dic setObject:self forKey:@"viewController"];
        if (mutableString) {
            [dic setObject:mutableString forKey:@"content"];
        }
        if (isFriend) {
            [dic setObject:[NSString stringWithFormat:@"%d",isFriend] forKey:@"scene"];
        }
        if (stringURL) {
            [dic setObject:stringURL forKey:@"URL"];
        }
        if (stringName) {
            [dic setObject:stringName forKey:@"Title"];
        }
        [[PluginStrategy sharedInstance] allocModuleWithName:@"Plugin_Share" withObject:dic];
    }
}
- (void)buttonAction:(id)sender
{
    UIButton *button = (UIButton *)sender;
    switch (button.tag) {
            case POIButtonType_Error:
        {
            Plugin_UserFeedBack * userBack = [[Plugin_UserFeedBack alloc]init];
            NSMutableDictionary * dic = [NSMutableDictionary dictionary];
            [dic setObject:@"2" forKey:@"controllertype"];
            [dic setObject:self.poiDetail forKey:@"poi"];
            [dic setObject:self  forKey:@"controller"];
            [userBack enter:dic];
            [userBack release];
        }break;
        case POIButtonType_Share:
        {

           NSArray* arrayTitle=@[STR(@"Share_Sms", Localize_POIShare),STR(@"Share_Friend", Localize_POIShare),STR(@"Share_Moments", Localize_POIShare),STR(@"Share_Sina", Localize_POIShare),STR(@"Share_Cancel",Localize_POIShare)];
           NSArray* arrayImage =@[@"shareMess",@"shareFriend",@"shareWeixin",@"shareSina",@"Main_SettingCancel"];
   
            [SociallShareManage ShowViewWithDelegate:self andWithImage:arrayImage andWithTitle:arrayTitle];
        }break;
        case POIButtonType_SetStart:
        {
            
            [MobClick event:UM_EVENTID_POI_DETAIL_COUNT label:UM_LABEL_POI_DETAIL_SET_START];
            GSTATUS res = [MWJourneyPoint AddJourneyPointWith:poiDetail type:GJOURNEY_START option:0];
            if (res != GD_ERR_OK) {
                NSLog(@"添加起点失败");
            }
            Plugin_POI * poi =[[Plugin_POI alloc]init];
            NSMutableDictionary * dic = [[NSMutableDictionary alloc]init];
            NSMutableArray * array = [[NSMutableArray alloc]init];
            [array addObject:poiDetail];
            [dic setObject:@"0" forKey:POI_TYPE];
            [dic setObject:@"1" forKey:POI_WhereGo];
            [dic setObject:self.navigationController forKey:POI_NAVIGATIONCONTROLLER];
            [dic setObject:array forKey:POI_Array];
            [poi enter:dic];
            [dic release];
            [array release];
        }
            break;
        case POIButtonType_SetDes:
        {
            [MobClick event:UM_EVENTID_POI_DETAIL_COUNT label:UM_LABEL_POI_DETAIL_SET_END];
            if (_routeCalculation == nil) {
                _routeCalculation=[[POIRouteCalculation alloc] initWithViewController:self];
            }
            [MobClick event:UM_EVENTID_NAVI_COUNT label:UM_LABEL_NAVI_FROM_POI_DETAIL];
            [_routeCalculation setBourn:poiDetail];
        }
            break;
        case POIButtonType_Collect:
        {
            [MobClick event:UM_EVENTID_POI_DETAIL_COUNT label:UM_LABEL_POI_DETAIL_FAVORITES];
            BOOL isSuccess;
            if ([poiDetail isMemberOfClass:[MWFavoritePoi class]]) {
                isSuccess= [MWPoiOperator reverseCollectPoi:(MWFavoritePoi*)poiDetail];
                NSLog(@"isSuccess =%i",isSuccess);
                if (isSuccess) {
                    isCollect=!isCollect;

                }
                
                
            }
            else if([poiDetail isMemberOfClass:[MWSmartEyesItem class]])
            {
                MWSmartEyesItem *smartEyesItem=(MWSmartEyesItem*)poiDetail;
                
                MWFavoritePoi *favoritePoi=[[MWFavoritePoi alloc] init];
                favoritePoi.eCategory=GFAVORITE_CATEGORY_DEFAULT;
                favoritePoi.eIconID=GFAVORITE_ICON_DEFAULT;
                favoritePoi.longitude=smartEyesItem.longitude;
                favoritePoi.latitude=smartEyesItem.latitude;
                favoritePoi.lAdminCode=smartEyesItem.lAdminCode;
                favoritePoi.lCategoryID=smartEyesItem.lCategoryID;
                favoritePoi.szName=smartEyesItem.szName;
                favoritePoi.szAddr=smartEyesItem.szAddr;
                favoritePoi.szTel=smartEyesItem.szTel;
                favoritePoi.szTown=smartEyesItem.szTown;
                isSuccess = [MWPoiOperator reverseCollectPoi:favoritePoi];
                if (isSuccess) {
                    isCollect=!isCollect;

                }
                [favoritePoi release];
                
            }
            else
            {
                MWFavoritePoi *favoritePoi=[[MWFavoritePoi alloc] init];
                [POICommon copyWMPoiValutToSubclass:poiDetail withPoiSubclass:favoritePoi];
                
                favoritePoi.eCategory=GFAVORITE_CATEGORY_DEFAULT;
                favoritePoi.eIconID=GFAVORITE_ICON_DEFAULT;
                isSuccess =[MWPoiOperator reverseCollectPoi:favoritePoi];
                if (isSuccess) {
                    isCollect=!isCollect;

                }
                [favoritePoi release];
                
                
            }
            if(isSuccess)
            {
            if(isCollect)
            {
                [POICommon showAutoHideAlertView:STR(@"Main_colloectOK", Localize_Main) showTime:1.0f];
            }
            else
            {
                [POICommon showAutoHideAlertView:STR(@"Main_collectCancel", Localize_Main) showTime:1.0f];
            }
            [buttonCollect setImage:IMAGE(isCollect?POICollect2:POICollect1, IMAGEPATH_TYPE_1) forState:UIControlStateNormal];
            }
        }
            break;
        case POIButtonType_Call:
        {
            [MobClick event:UM_EVENTID_POI_DETAIL_COUNT label:UM_LABEL_POI_DETAIL_PHONE];
            NSLog(@"%@",poiDetail.szTel);
            [MWAdminCode telephoneCall:poiDetail.szTel Lon:poiDetail.longitude Lat:poiDetail.latitude];
        }
            break;
        case POIButtonType_Home:
        {
            [MobClick event:UM_EVENTID_POI_DETAIL_COUNT label:UM_LABEL_POI_DETAIL_SET_HOME];
            [self setHomeOrCompany:0];
        }
            break;
        case POIButtonType_Company:
        {
            [MobClick event:UM_EVENTID_POI_DETAIL_COUNT label:UM_LABEL_POI_DETAIL_SET_COMPANY];
            [self setHomeOrCompany:1];
        }
            break;

        default:
            break;
    }
    
   

}
-(void)setHomeOrCompany:(BOOL)isCampany
{
    BOOL isSuccess;
    MWFavoritePoi *favoritePoi=[[MWFavoritePoi alloc] init];
    [POICommon copyWMPoiValutToSubclass:self.poiDetail withPoiSubclass:favoritePoi];
    isSuccess = [POICommon collectFavorite:isCampany withPOI:favoritePoi];
    [favoritePoi release];
    if (isSuccess) {
        
        GDAlertView *alertView =  [[[GDAlertView alloc] initWithTitle:nil andMessage:STR(isCampany==0?@"POI_SetHomeAddressSuccess":@"POI_SetCompanyAddressSuccess", Localize_POI)] autorelease];
        [alertView show];
    }

}

@end

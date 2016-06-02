//
//  POICameraEditViewController.m
//  AutoNavi
//
//  Created by huang on 13-8-20.
//
//

#import "POICameraEditViewController.h"
#import "POIInputCell.h"
#import "POIDefine.h"
#import "POICommon.h"
#import "POITableHeadView.h"
#import "NSString+Category.h"
@interface POICameraEditViewController ()
@property(nonatomic,copy)NSString *cameraName;
@end

@implementation POICameraEditViewController
@synthesize smartEyesItem;
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
    CRELEASE(smartEyesItem);
    self.cameraName=nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    if (self.isAdd==0) {
        if (_textField) {
              [_textField becomeFirstResponder];
        }
      
    }
}

#pragma mark -
#pragma mark control related
//初始化控件
-(void) initControl{
    [ANParamValue sharedInstance].nSpeed = smartEyesItem.nSpeed;
    if(_isAdd)
    {
        [ANParamValue sharedInstance].nSpeed = 200;
    }
    else
    {
        [ANParamValue sharedInstance].eCategory=smartEyesItem.eCategory;
    }
    self.cameraName=smartEyesItem.szName;
//    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(notificationReceived:) name: UITextFieldTextDidChangeNotification object: nil];
}

//调整控件竖屏坐标和图片
-(void)changePortraitControlFrameWithImage
{
    [super changePortraitControlFrameWithImage];
//    [_tableView setFrame:CGRectMake(CCOMMON_TABLE_X, 0.0f, APPWIDTH-2*CCOMMON_TABLE_X, CONTENTHEIGHT_V)];
    [_tableView reloadData];
}

//调整控件横屏坐标和图片
-(void)changeLandscapeControlFrameWithImage
{
    [super changeLandscapeControlFrameWithImage];
//    [_tableView setFrame:CGRectMake(CCOMMON_TABLE_X, 0.0f, APPHEIGHT-2*CCOMMON_TABLE_X, CONTENTHEIGHT_H)];
    [_tableView reloadData];
}
//改变控件文本
-(void)changeControlText
{
    
    if (_isAdd) {
        self.title=STR(@"POI_AddCamera", Localize_POI);
        
    }
    else
    {
        self.title=STR(@"POI_EditInfoTitle",Localize_POI);
    }
    self.navigationItem.leftBarButtonItem=LEFTBARBUTTONITEM(@"", @selector(leftBtnEvent:));
     self.navigationItem.rightBarButtonItem =RIGHTBARBUTTONITEM(STR(@"POI_CameraSave", Localize_POI), @selector(saveCameraEdit));

}
-(void)leftBtnEvent:(id)object
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)saveCameraEdit
{
    smartEyesItem.szName = [NSString stringWithFormat:@"%@",_textField.text];
    NSString *newName=[smartEyesItem.szName stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (newName.length<1)
     {
        GDAlertView *alert = [[[GDAlertView alloc] initWithTitle:nil andMessage:STR(@"POI_TextFieldPromptMessage", Localize_POI)] autorelease];
        [alert addButtonWithTitle:STR(@"POI_OK",Localize_POI) type:GDAlertViewButtonTypeCancel handler:nil];
        [alert show];
        return;
    }
    smartEyesItem.nSpeed = [ANParamValue sharedInstance].nSpeed;
    smartEyesItem.eCategory = [ANParamValue sharedInstance].eCategory;
    //modify by wws for 解决电子眼没有地址的 为电子眼添加adCode at 2017-7-31
    GCOORD coor1 = {0};
    coor1.x = smartEyesItem.longitude;
    coor1.y = smartEyesItem.latitude;
    smartEyesItem.lAdminCode = [MWAdminCode GetAdminCode:coor1];
    if (_isAdd) {
       if(smartEyesItem.nSpeed==200)
       {
           
           [self showAutoHideAlertView:STR(@"POI_CameraAlertTitle", Localize_POI) showTime:2.0f];
           return;
       }
    }
    NSString *prompt=nil;
    if (smartEyesItem.szName.length>20) {
        prompt=STR(@"POI_Name",Localize_POI);
    }
    if (prompt) {
        NSString *message=[NSString stringWithFormat:@"%@%@",prompt,STR(@"POI_LengthLimitExceeded", Localize_POI)];
        //去除冒号
        message =[message stringByReplacingOccurrencesOfString:@" : " withString:@""];
        GDAlertView *alert = [[[GDAlertView alloc] initWithTitle:nil andMessage:message] autorelease];
        [alert addButtonWithTitle:STR(@"POI_OK",Localize_POI) type:GDAlertViewButtonTypeCancel handler:nil];
        [alert show];
        return;
    }
    GSTATUS gst=_isAdd==NO?[MWPoiOperator editeSmartEyesWith:smartEyesItem]:[MWPoiOperator collectSmartEyesWith:smartEyesItem];

	if(gst == GD_ERR_OK)
	{
        if (_isAdd) {
            NSLog(@"收藏成功");
            [self showAutoHideAlertView:STR(@"POI_AddCameraSuccess", Localize_POI) showTime:2.0f];

            [self.navigationController popViewControllerAnimated:YES];
        }
        else
            [self.navigationController popViewControllerAnimated:YES];
	}
	else
	{
        
        if (_isAdd) {
            if (gst==GD_ERR_DUPLICATE_DATA) {
                [self showAutoHideAlertView:STR(@"POI_AddCameraSuccess", Localize_POI) showTime:2.0f];
                [self.navigationController popViewControllerAnimated:YES];
            }
            
        }
        else{
            [self showAutoHideAlertView:STR(@"POI_CameraFailed", Localize_POI) showTime:2.0f];
        }

     
	}
	
}
#pragma mark -
#pragma mark notification
-(void)notificationReceived:(NSNotification*) notification
{
    UITextField *textField = nil;
    NSObject* obj = [notification object];
    if ([obj isKindOfClass:[UITextField class]])
    {
        textField = (UITextField*)obj;
        
    }
    
	if(_textField.text.length >20)
	{
		_textField.text = [textField.text substringToIndex:[textField.text length] - 1];
	}
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
//    return !self.isAdd;
}
- (BOOL)textFieldShouldClear:(UITextField *)textField
{
	textField.text = @"";
	return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string   // return NO to not change text
{
	
    if (string.length==0) {
        return YES;
    }
   
    
    int location=20-1;
    if (range.location>location) {
        return NO;
    }
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
    return YES;
}


#pragma mark -
#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return kHeight2;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section==0) {
        return 10;
    }
    return 55-3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section==0?1:10;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section==0) {
        UIView *view=[[[UIView alloc] init] autorelease];
        [view setBackgroundColor:[UIColor clearColor]];
        return view;
    }
    POITableHeadView *headView=[[[POITableHeadView alloc] initWithTitle:STR(@"POI_CameraType",Localize_POI)] autorelease];
    [headView downMove];
    return headView;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    static NSString *CellIdentifier_1 = @"Cell_1";
    
	if(indexPath.section == 0)
	{
        POIInputCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell)
        {
            cell = [[[POIInputCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            _textField = cell.textField;
            
            if ([smartEyesItem.szName length] == 0)
            {
                _textField.text= [NSString stringWithFormat:@"%@",STR(@"POI_UnnamedPoint",Localize_POI)];
            }
            else
            {
                _textField.text = [NSString stringWithFormat:@"%@",self.cameraName];
            }

        }
         cell.backgroundType = BACKGROUND_FOOTER;
         cell.emptyLineLength = 0;
        cell.textField.delegate = self;
        cell.detailTextLabel.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
       
        cell.textLabel.text=STR(@"POI_Name",Localize_POI);
        return cell;
		
	}
	else if(indexPath.section == 1)
	{
        GDTableViewCell *cell = (GDTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier_1];
        if( cell == nil)
        {
            cell = [[[GDTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier_1] autorelease];
        }
        cell.emptyLineLength = 0;
        UILabel *label=(UILabel*)[cell.contentView viewWithTag:1001];
        if (!label) {
            label=[[UILabel alloc] initWithFrame:CGRectMake(150, 0, 100, 48)];
            label.textColor=TEXTDETAILCOLOR;
            label.font=[UIFont systemFontOfSize:kSize3];
            label.backgroundColor=[UIColor clearColor];
            [cell.contentView addSubview:label];
            label.tag=1001;
            [label release];
        }
        label.frame=CGRectMake(0, 0, 80, 48);

        if(indexPath.row == 0)
        {
            cell.textLabel.text =STR(@"POI_SurveillanceCamera", Localize_POI);
            label.text = @"";
        }
        else
        {
            cell.textLabel.text =STR(@"POI_SpeedLimitCamera", Localize_POI);
            CGSize size=[cell.textLabel.text sizeWithFont:cell.textLabel.font];
            CGRect rect = label.frame;
            rect.origin.x +=17+size.width+15;
            label.frame=rect;
            label.text = [NSString stringWithFormat:@"%d%@", 40 + (indexPath.row - 1) * 10,STR(@"Universal_KM", Localize_Universal)];
        }
         cell.backgroundType = BACKGROUND_FOOTER;
        if ([ANParamValue sharedInstance].nSpeed==0&&indexPath.row==0) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            UIImageView *tempimg = [[UIImageView alloc] initWithImage:IMAGE(@"Checkmark.png",IMAGEPATH_TYPE_1)];
            cell.accessoryView = tempimg;
            [tempimg release];
        }
        else if ([ANParamValue sharedInstance].nSpeed==40+(indexPath.row-1)*10) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            UIImageView *tempimg = [[UIImageView alloc] initWithImage:IMAGE(@"Checkmark.png",IMAGEPATH_TYPE_1)];
            cell.accessoryView = tempimg;
            [tempimg release];
        }
        else
        {
            cell.accessoryType=UITableViewCellAccessoryNone;
            cell.accessoryView=nil;
        }
        return cell;
    }
	
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

           
    if (indexPath.section==1)
    {
        if(indexPath.row == 0)
        {
            [ANParamValue sharedInstance].eCategory = 28;
            [ANParamValue sharedInstance].nSpeed = 0;
        }
        else
        {
            [ANParamValue sharedInstance].eCategory = 1;
            [ANParamValue sharedInstance].nSpeed = 40 + (indexPath.row - 1) * 10;
        }
    
    }
    [tableView reloadData];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([_textField isFirstResponder]) {
        [_textField resignFirstResponder];
    }
}

@end

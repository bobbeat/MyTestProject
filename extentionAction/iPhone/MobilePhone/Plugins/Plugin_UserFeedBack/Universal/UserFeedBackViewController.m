//
//  ICallFeedBackViewController.m
//  AutoNavi
//
//  Created by weisheng on 14-6-5.
//
//

#import "UserFeedBackViewController.h"
#import "GDSearchListCell.h"
#import "HTextVIewPlaceholder.h"
#import "MWFeedbackRequest.h"
#import "CheckBox.h"
#import "FeedBackImageView.h"
#import "FeedBackTableViewCell.h"
#import "AccountTextFieldListener.h"
#define BTN_WEIGHT (_tableView.bounds.size.width - 20)/2
#define BTN_WEIGHT_W (_tableView.bounds.size.width - 20)/2+15
#define screenHeight (SCREENHEIGHT- (((float)NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) ? 0 : 20))
typedef enum AlertTag
{
    Alert_TextViewNull_tag,//描述为空的时候
    Alert_NetError_tag,    //网络出错的时候
}AlertTag;
@interface UserFeedBackViewController ()<NetReqToViewCtrDelegate,CheckBoxDelegate,UITextViewDelegate,UITextFieldDelegate,feedBackImageViewDelegate>
{
  
    UIButton *              _btnCommit;
    NSMutableDictionary *   _tableDictionary ;
    HTextVIewPlaceholder * _textViewDes;
    UITextField *          _textFieldPhone;//描述
    UIView *               _footView;
    
}
@property(retain,nonatomic)FeedBackImageView * feedBackImage;
@property(retain,nonatomic)UITextField * textFieldQQ;
@property(retain,nonatomic)UITextView  * textViewName;
@property(assign,nonatomic)BOOL  boxButton1;
@property(assign,nonatomic)BOOL  boxButton2;
@property(assign,nonatomic)BOOL  boxButton3;
@property(assign,nonatomic)BOOL  boxButton4;
@property(assign,nonatomic)BOOL  boxButton5;
@property(assign,nonatomic)BOOL  boxButton6;
@property(assign,nonatomic)BOOL  boxButton7;
@end

@implementation UserFeedBackViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}
-(void)dealloc
{
    [AccountTextFieldListener StopAccountTextFieldListner];
    CRELEASE(_tableDictionary);
    CRELEASE(_textViewDes);
    CRELEASE(_textFieldPhone);
    CRELEASE(_footView);
    CRELEASE(_textViewName);
    CRELEASE(_textFieldQQ);
    CRELEASE(_feedBackImage);
    [MWFeedBackRequest sharedInstance].feedBackDelegate = nil;
    [super dealloc];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [AccountTextFieldListener startAccountTextFieldListner];
    _tableView.bounces = YES;
    _tableView.scrollEnabled = YES;
    if (_tableDictionary) {
        _tableDictionary = nil;
    }
       _tableDictionary =[[NSMutableDictionary alloc]init];
       self.navigationItem.leftBarButtonItem=LEFTBARBUTTONITEM(@"", @selector(leftBtnEvent:));
       self.title = STR(@"TS_UserFeedback", Localize_UserFeedback);
 
    _footView =[[UIView alloc] initWithFrame:CGRectMake(0, 0,_tableView.frame.size.width ,80)];
    [_footView setBackgroundColor:[UIColor clearColor]];
    _btnCommit = [self createButtonWithTitle:STR(@"TS_Commit",Localize_UserFeedback) normalImage:@"CommonBtn1.png" heightedImage:@"CommonBtn2.png" tag:REQ_USER_Feedback strechParamX:5 strechParamY:10];
    [_btnCommit setTitleColor:GETSKINCOLOR(@"SubmitButtonColor") forState:UIControlStateNormal];
    [_btnCommit setFrame:CGRectMake(0,20,_tableView.bounds.size.width, 48)];
    [_footView addSubview:_btnCommit];
    _tableView.tableFooterView = _footView;
   
}
- (void)buttonAction:(UIButton *)button
{
    if (button.tag == REQ_USER_Feedback) {
        [self keyBoardBack];
        NSMutableString * tableString = [NSMutableString string];
        if (_tableDictionary) {
            for ( id arr in _tableDictionary) {
                [tableString appendString:[NSString stringWithFormat:@"%@",arr]];
            }
        }
        if (self.textViewName.text) {
            [tableString appendString:[NSString stringWithFormat:@" %@",self.textViewName.text] ];
        }
        if (tableString.length<=1) {
            [self NetAlertWithTag:Alert_TextViewNull_tag];
        }else
        {
            [self showLoadingViewInView:nil view:self.view];
            MWFeedbackFunctionCondition * condition = [[MWFeedbackFunctionCondition alloc]init];
            if (self.textFieldQQ) {
                condition.tel = self.textFieldQQ.text;
            }
            if (self.feedBackImage.selectImage) {
                condition.pic = self.feedBackImage.selectImage;
            }
            condition.errorDesc = tableString;
            [self showLoadingViewInView:nil view:self.view];
            [[MWFeedBackRequest sharedInstance]Net_FeedbackGetUser:condition requestType:REQ_USER_Feedback delegate:self];
            [condition release];
        }
       
    }
}
-(void)leftBtnEvent:(id)sender
{
    [[MWFeedBackRequest sharedInstance]Net_CancelRequestWithType:REQ_USER_Feedback];
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)changePortraitControlFrameWithImage
{
    _tableView.frame = CGRectMake(10,0.0, self.view.bounds.size.width - 10 * 2,self.view.bounds.size.height);
     [_btnCommit setFrame:CGRectMake(0,20,_tableView.bounds.size.width, 48)];
    [_textViewDes setFrame:CGRectMake(2,5,_tableView.bounds.size.width-4, 110)];
    [_textFieldPhone setFrame:CGRectMake(5, 5, _tableView.bounds.size.width - 10, 40)];
    [_tableView reloadData];
   
}
//调整横屏控件坐标和图片
-(void)changeLandscapeControlFrameWithImage
{
    [_tableView setFrame:CGRectMake(10, 0.0f, CCOMMON_APP_WIDTH-2*10,CCOMMON_CONTENT_HEIGHT)];
    [_btnCommit setFrame:CGRectMake(0,20,_tableView.bounds.size.width, 48)];
    [_textViewDes setFrame:CGRectMake(2,5,_tableView.bounds.size.width-4, 110)];
    [_textViewDes setFrame:CGRectMake(2,5,CCOMMON_APP_WIDTH-2*CCOMMON_TABLE_X-4, 110)];
    [_textFieldPhone setFrame:CGRectMake(5, 5, CCOMMON_APP_WIDTH-2*CCOMMON_TABLE_X-10, 40)];
    [_tableView reloadData];
  
}

-(CheckBox *)createCheckBox:(NSString *)title andFrame:(CGRect )frame with:(UIView *)cell andTag:(int)tag
{
    CheckBox * _check2 = [[CheckBox alloc] initWithDelegate:self];
    _check2.frame =frame;
    _check2.tag = tag;
    [_check2  setTitleColor:TEXTCOLOR forState:UIControlStateNormal];
    _check2.titleLabel.numberOfLines = 2;
    [_check2 setTitle:title forState:UIControlStateNormal];
    [_check2.titleLabel setFont:[UIFont systemFontOfSize:kSize2-2]];
    [cell addSubview:_check2];
    return [_check2 autorelease];
}
#pragma mark --CheckBoxDelegate
- (void)didSelectedCheckBox:(CheckBox *)checkbox checked:(BOOL)checked {
    if (checkbox.titleLabel.text && checked == 1) {
        if (checkbox.tag == 1) {
            self.boxButton1 = YES;
        }else if (checkbox.tag == 2)
        {
            self.boxButton2 = YES;
        }else if (checkbox.tag ==3)
        {
            self.boxButton3 = YES;
        }else if (checkbox.tag == 4)
        {
            self.boxButton4 = YES;
        }else if (checkbox.tag == 5)
        {
            self.boxButton5 = YES;
        }else if (checkbox.tag == 6)
        {
            self.boxButton6 = YES;
        }else
        {
            self.boxButton7 = YES;
        }
        [_tableDictionary setObject:checkbox.titleLabel.text forKey:checkbox.titleLabel.text];
        
    }else
    {
        if (checkbox.tag == 1) {
            self.boxButton1 = NO;
        }else if (checkbox.tag == 2)
        {
            self.boxButton2 = NO;
        }else if (checkbox.tag ==3)
        {
            self.boxButton3 = NO;
        }else if (checkbox.tag == 4)
        {
            self.boxButton4 = NO;
        }else if (checkbox.tag == 5)
        {
            self.boxButton5 = NO;
        }else if (checkbox.tag == 6)
        {
            self.boxButton6 = NO;
        }else
        {
            self.boxButton7 = NO;
        }
        
        
        if ([_tableDictionary objectForKey:checkbox.titleLabel.text]) {
            [_tableDictionary removeObjectForKey:checkbox.titleLabel.text];
        }
    }
}
#pragma mark UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 160;
    }else if (indexPath.section == 1)
    {
        return 120;
    }else if (indexPath.section == 2)
    {
        return 70;
    }
    return 50;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * identy = [NSString stringWithFormat:@"%d %d",indexPath.section,indexPath.row];
    FeedBackTableViewCell * cell =[tableView dequeueReusableCellWithIdentifier:identy];
    if (cell == nil) {
        cell = [[[FeedBackTableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identy] autorelease];
    }
    cell.emptyLineLength = -1;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    for(UIView * view in cell.contentView.subviews)
    {
        [view removeFromSuperview];
    }
    if (indexPath.section ==0) {
     
        cell.backgroundColor = [UIColor whiteColor];
        cell.emptyLineLength = -1;
        cell.backgroundType = 100;
     
   CheckBox * box1=  [self createCheckBox:STR(@"TS_RoadError", Localize_UserFeedback) andFrame:CGRectMake(0,0,BTN_WEIGHT, 40)with:cell.contentView andTag:1];
    box1.checked = self.boxButton1;
  
   
    CheckBox * box2=   [self createCheckBox:STR(@"TS_Update", Localize_UserFeedback) andFrame:CGRectMake(BTN_WEIGHT_W,0,BTN_WEIGHT, 40) with:cell.contentView andTag:2];
    box2.checked = self.boxButton2;
 
        
     CheckBox * box3=  [self createCheckBox:STR(@"TS_NoGPSsignal", Localize_UserFeedback) andFrame:CGRectMake(0,40,BTN_WEIGHT, 40)with:cell.contentView andTag:3];
    box3.checked = self.boxButton3;
      
        
     CheckBox * box4=  [self createCheckBox:STR(@"TS_Lackcamera", Localize_UserFeedback) andFrame:CGRectMake(BTN_WEIGHT_W, 40,BTN_WEIGHT, 40)with:cell.contentView andTag:4];
    box4.checked =self.boxButton4;
        
     CheckBox * box5=  [self createCheckBox:STR(@"TS_NOSuondNavigation", Localize_UserFeedback) andFrame:CGRectMake(0, 80,BTN_WEIGHT,40)with:cell.contentView andTag:5];
     box5.checked = self.boxButton5;
  
        
      CheckBox * box6=  [self createCheckBox:STR(@"TS_SoftwareError", Localize_UserFeedback) andFrame:CGRectMake(BTN_WEIGHT_W, 80,BTN_WEIGHT, 40)with:cell.contentView andTag:6];
     box6.checked = self.boxButton6;
        
      CheckBox * box7=   [self createCheckBox:STR(@"TS_Advice", Localize_UserFeedback) andFrame:CGRectMake(0, 120,BTN_WEIGHT, 40)with:cell.contentView andTag:7];
      box7.checked = self.boxButton7;
      
    }
    if (indexPath.section == 1) {
        cell.backgroundType = BACKGROUND_GROUP;
        [self createTextView:cell];
        if (self.textViewName) {
            _textViewDes.text = self.textViewName.text;
        }self.textViewName = _textViewDes;
 
    }
    else if (indexPath.section == 2)
    {
        cell.backgroundType = BACKGROUND_GROUP;
        [self createCinema:cell];
    }
    else if (indexPath.section == 3)
    {
        cell.backgroundType = BACKGROUND_GROUP;
        [self createTextField:cell];
    }
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2) {
        [self selectImageView];
      
    }
}
#pragma mark NetReqToViewCtrDelegate
- (void)requestToViewCtrWithRequestType:(RequestType)requestType didFinishLoadingWithResult:(id)result
{
    [self hideLoadingViewWithAnimated:YES];
    if (requestType == REQ_USER_Feedback) {
        if ([[result objectForKey:@"message"] isEqualToString:@"Successful."]) {
            [POICommon showAutoHideAlertView:STR(@"TS_FeedBackThankyou", Localize_UserFeedback) showTime:2.0f];
            [self.navigationController popViewControllerAnimated:YES];
        }else
        {
            [POICommon showAutoHideAlertView:STR(@"TS_SummitFail", Localize_UserFeedback) showTime:2.0f];
        }
    }
}

- (void)requestToViewCtrWithRequestType:(RequestType)requestType didFailWithError:(NSError *)error
{
    [self hideLoadingViewWithAnimated:YES];
    [self NetAlertWithTag:Alert_NetError_tag];
}
#pragma mark 创建一个TextView
-(void)createTextView :(UITableViewCell *)cell
{
    _textViewDes= [[HTextVIewPlaceholder alloc]init];
    _textViewDes.delegate = self;
    [_textViewDes setFrame:CGRectMake(2,5,_tableView.bounds.size.width-4, 110)];
    [cell.contentView addSubview:_textViewDes];
}
-(void)createTextField :(UITableViewCell *)cell
{
    UITextField * textField = [self createTextFieldWithPlaceholder:STR(@"TS_MailAndPhone", Localize_UserFeedback) fontSize:kSize2 tag:123];
    [textField setFrame:CGRectMake(10,10, _tableView.bounds.size.width -20, 50-20)];
    textField.borderStyle = UITextBorderStyleNone;
    textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    textField.delegate = self;
    if (self.textFieldQQ) {
        textField.text = self.textFieldQQ.text;
    }self.textFieldQQ = textField;
    [cell addSubview:textField];
}
#pragma mark 创建一个相框
-(void)createCinema :(UITableViewCell *)cell
{
    FeedBackImageView * feedBack = [[FeedBackImageView alloc]initWithFrame:CGRectMake(0,0,_tableView.bounds.size.width-5, 70)];
    feedBack.userInteractionEnabled = YES;
    feedBack.delegate = self;
    [cell.contentView addSubview:feedBack];
    if (self.feedBackImage) {
        feedBack.selectImage = self.feedBackImage.selectImage;
    }
    self.feedBackImage = feedBack;
    [feedBack release];
}
-(void)CtImagePickerDealWithPicture:(UIImage*)imgPicture
{
    if (imgPicture) {
        self.feedBackImage.selectImage=[self CtIncapsulateImage:imgPicture andSize:30] ;
    }
}
-(void)keyBoardBack
{
    if ([_textViewDes isFirstResponder]) {
        [_textViewDes resignFirstResponder];
    }
    if ([self.textFieldQQ isFirstResponder]) {
        [self.textFieldQQ resignFirstResponder];
    }
}
#pragma mark  PTrafficDescribeProtocol
-(void)selectImageView
{
    [self keyBoardBack];
    [self CtImagePickerChoosePic];

}
- (void)NetAlertWithTag:(int)tag
{
    NSString * stringName = nil ;
    if (tag==Alert_TextViewNull_tag) {
        stringName = STR(@"TS_Describe", Localize_UserFeedback);
    }else if (tag == Alert_NetError_tag)
    {
        stringName = STR(@"Universal_networkError", Localize_Universal);
    }
    GDAlertView *Myalert_ext = [[GDAlertView alloc] initWithTitle:nil andMessage:stringName ];
    [Myalert_ext addButtonWithTitle:STR(@"Universal_ok", Localize_Universal)  type:GDAlertViewButtonTypeCancel handler:^(GDAlertView * alert){
    }];
    [Myalert_ext show];
    [Myalert_ext release];
}
#pragma mark - UITextView Delegate Methods UITextViewDelegate
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    if (range.location>=299) {
        return NO;
    }
    return YES;
}
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    return YES;
}
-(BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    _tableView.frame = CGRectMake(10,0.0, self.view.bounds.size.width - 10 * 2,self.view.bounds.size.height);
    return YES;
}
#pragma mark UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (range.location>=30) {
        return NO;
    }return YES;
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    _tableView.contentOffset=CGPointMake(0,0);
    _tableView.frame = CGRectMake(10,0.0, self.view.bounds.size.width - 10 * 2,self.view.bounds.size.height);
    return  YES;
}
- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    textField.text=@"";
    return YES;
}
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (isPad&&Interface_Flag==1&&textField.tag==123) {
        _tableView.contentOffset=CGPointMake(0,200);
    }
    return YES;
}
#pragma mark ReceiveMemoryWarning
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end

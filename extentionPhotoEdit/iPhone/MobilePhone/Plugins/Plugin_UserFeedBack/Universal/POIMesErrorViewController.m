//
//  POIMesErrorViewController.m
//  AutoNavi
//
//  Created by weisheng on 14-6-10.
//
//

#import "POIMesErrorViewController.h"
#import "MWFeedBackRequest.h"
#import "FeedBackTableViewCell.h"
#import "POIAnErrorViewController.h"
#import "AccountTextFieldListener.h"
#define screenHeight (SCREENHEIGHT- (((float)NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) ? 0 : 20))
 //screenHeight = SCREENHEIGHT- (((float)NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) ? 0 : 20);
@interface POIMesErrorViewController ()<UITextFieldDelegate,NetReqToViewCtrDelegate>
{
    UIButton * _btnCommit;
}

@end

@implementation POIMesErrorViewController

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
    CRELEASE(_poi);
    CRELEASE(_feedBackImage);
    CRELEASE(_textFieldAdd1);
    CRELEASE(_textFieldOther);
    CRELEASE(_textFieldPhone);
    CRELEASE(_textFieldTel1);
    CRELEASE(_textFieldName1);
     [AccountTextFieldListener StopAccountTextFieldListner];
    [MWFeedBackRequest sharedInstance].feedBackDelegate = nil;
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    
    [super dealloc];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [AccountTextFieldListener startAccountTextFieldListner];
    self.navigationItem.leftBarButtonItem=LEFTBARBUTTONITEM(@"", @selector(leftBtnEvent:));
    self.title = STR(@"TS_Detail", Localize_UserFeedback);
    
    UIView * footView =[[UIView alloc] initWithFrame:CGRectMake(0,0,_tableView.frame.size.width ,80)];
    [footView setBackgroundColor:[UIColor clearColor]];
    _btnCommit = [self createButtonWithTitle:STR(@"TS_Commit",Localize_UserFeedback) normalImage:@"CommonBtn1.png" heightedImage:@"CommonBtn2.png" tag:10 strechParamX:5 strechParamY:10];
    [_btnCommit setFrame:CGRectMake(0,20,_tableView.bounds.size.width, 48)];
    [_btnCommit setTitleColor:GETSKINCOLOR(@"SubmitButtonColor") forState:UIControlStateNormal];
    [footView addSubview:_btnCommit];
    _tableView.tableFooterView = footView;
    [footView release];
    
}
#pragma mark 创建一个UitextField
-(void)createTextField :(UITableViewCell *)cell
{
    UITextField * textField = [self createTextFieldWithPlaceholder:STR(@"TS_MailAndPhone", Localize_UserFeedback) fontSize:kSize2 tag:1000];
    [textField setFrame:CGRectMake(10,10, _tableView.bounds.size.width -20, 30)];
    textField.delegate = self;
    textField.borderStyle = UITextBorderStyleNone;
    textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    if (self.textFieldPhone) {
        textField.text = self.textFieldPhone.text;
    }self.textFieldPhone = textField;
    [cell addSubview:textField];
    
}
-(UITextField *)createTextFieldAndView:(UITableViewCell *)cell andFrame:(CGRect)frame
{
    for(UIView * view in cell.contentView.subviews)
    {
        [view removeFromSuperview];
    }
    UITextField * textField = [self createTextFieldWithPlaceholder:nil fontSize:kSize2 tag:nil];
    textField.delegate = self;
    textField.borderStyle = UITextBorderStyleNone;
    textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [textField setFrame:CGRectMake(frame.origin.x,frame.origin.y, frame.size.width-10, frame.size.height)];
    [cell.contentView addSubview:textField];
    return textField;
    
}
-(UILabel *)createLabelWithText:(NSString *)text andView:(FeedBackTableViewCell *)cell
{
    UILabel * label =(UILabel *) [cell viewWithTag:3000];
    if (label) {
        [label removeFromSuperview];label = nil;
    }
    CGSize textSize = [text sizeWithFont:[UIFont systemFontOfSize:kSize2]];
    label = [self createLabelWithText:text fontSize:kSize2 textAlignment:NSTextAlignmentLeft];
    label.textColor = TEXTCOLOR;label.tag = 3000;
    [label setFrame:CGRectMake(10, 5,textSize.width + 10 , 40)];
    [cell addSubview:label];
    return label;
}
-(void)leftBtnEvent:(id)sender
{
    [[MWFeedBackRequest sharedInstance]Net_CancelRequestWithType:REQ_USER_Feedback_POI];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)buttonAction:(UIButton *)button
{
    if (button.tag == 10) {
        [self keyBoardBack];
        [self showLoadingViewInView:nil view:self.view];
        MWPoi * dePoi = [[MWPoi alloc]init];
        dePoi.szName = self.textFieldName1.text;
        dePoi.szAddr = self.textFieldAdd1.text;
        dePoi.szTel = self.textFieldTel1.text;
        
        dePoi.lAdminCode = self.poi.lAdminCode;
        dePoi.latitude = self.poi.latitude;
        dePoi.longitude = self.poi.longitude;
//        dePoi.lPoiId = self.poi.lPoiId;
        dePoi.lDistance = self.poi.lDistance;
        dePoi.lCategoryID = self.poi.lCategoryID;
        dePoi.lPoiIndex = self.poi.lPoiIndex;
        
        MWFeedbackFunctionCondition * condition = [[MWFeedbackFunctionCondition alloc]init];
        if (self.textFieldPhone) {
            condition.tel = self.textFieldPhone.text;
        }
        condition.questionType = 2003;
        if (_textFieldOther.text.length ==0) {
            condition.errorDesc = STR(@"TS_MessageError", Localize_UserFeedback);
        }condition.errorDesc = self.textFieldOther.text;
        if (self.feedBackImage.selectImage) {
            condition.pic = self.feedBackImage.selectImage;
        }
        [[MWFeedBackRequest sharedInstance]Net_FeedbackGetUserFromPoi:dePoi withDescription:condition requestType:REQ_USER_Feedback_POI delegate:self];
        [dePoi release];
        [condition release];
    }
}
-(void)changePortraitControlFrameWithImage
{    _tableView.frame = CGRectMake(10,0.0, self.view.bounds.size.width - 10 * 2,self.view.bounds.size.height);
    [_btnCommit setFrame:CGRectMake(0,20,_tableView.bounds.size.width, 48)];
    [_tableView reloadData];
    
}
//调整横屏控件坐标和图片
-(void)changeLandscapeControlFrameWithImage
{
    [_tableView setFrame:CGRectMake(10, 0.0f, CCOMMON_APP_WIDTH-2*10,CCOMMON_CONTENT_HEIGHT)];
    [_btnCommit setFrame:CGRectMake(0,20,_tableView.bounds.size.width, 48)];
    [_tableView reloadData];
}


#pragma mark UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 6;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 4 )
    {
        return 70;
    }return 50;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * cellIdentifier=[NSString stringWithFormat:@"%d %d",indexPath.section,indexPath.row];
    NSString * cellIdentifier1=[NSString stringWithFormat:@"%d %d",indexPath.section,indexPath.row];
    if (indexPath.section>=0&&indexPath.section<4)
    {
        FeedBackTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (!cell) {
            cell=[[[FeedBackTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
        }
        cell.backgroundType = BACKGROUND_GROUP;
        cell.emptyLineLength = -1;
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        if (indexPath.section == 0) {
            UILabel * Laber1 = [self createLabelWithText:STR(@"POI_Name", Localize_POI) andView:cell];
            UITextField * text = [self createTextFieldAndView:cell andFrame:CGRectMake(Laber1.frame.size.width, 5, _tableView.bounds.size.width-Laber1.frame.size.width, 40)];
            if (self.poi.szName) {
                text.text = self.poi.szName;
            }
            if (self.textFieldName1) {
                text.text = self.textFieldName1.text;
            }self.textFieldName1 = text;
        }
        else if (indexPath.section ==1)
        {
            UILabel * Laber2 = [self createLabelWithText:STR(@"POI_Address", Localize_POI) andView:cell];
            UITextField * text = [self createTextFieldAndView:cell andFrame:CGRectMake(Laber2.frame.size.width, 5, _tableView.bounds.size.width-Laber2.frame.size.width, 40)];
            if (self.poi.szAddr) {
                text.text = self.poi.szAddr;
            }
            if (self.textFieldAdd1) {
                text.text = self.textFieldAdd1.text;
            }self.textFieldAdd1 = text;
        }
        else if (indexPath.section ==2)
        {
            UILabel * Laber3 = [self createLabelWithText:STR(@"POI_Phone", Localize_POI) andView:cell];
            UITextField * textTel = [self createTextFieldAndView:cell andFrame:CGRectMake(Laber3.frame.size.width, 5, _tableView.bounds.size.width-Laber3.frame.size.width, 40)];
            textTel.keyboardType = UIKeyboardTypePhonePad;
            if (self.poi.szTel) {
                textTel.text = self.poi.szTel;
            }
            if (self.textFieldTel1) {
                textTel.text = self.textFieldTel1.text;
            }self.textFieldTel1 = textTel;
        }
        else if (indexPath.section ==3)
        {
            UILabel * Laber4 = [self createLabelWithText:STR(@"TS_Other", Localize_UserFeedback) andView:cell];
            UITextField * textOther = [self createTextFieldAndView:cell andFrame:CGRectMake(Laber4.frame.size.width, 5, _tableView.bounds.size.width-Laber4.frame.size.width, 40)];
            textOther.tag = 2000;
            if (self.textFieldOther) {
                textOther.text = self.textFieldOther.text;
            }self.textFieldOther = textOther;
        }
        return cell;
    }
    else
    {
        FeedBackTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier1];
        if (cell == nil) {
            cell = [[[FeedBackTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier1]autorelease];
        }
        FeedBackImageView * feedBack =(FeedBackImageView *) [cell viewWithTag:5000];
        if (feedBack) {
            [feedBack removeFromSuperview];feedBack = nil;
        }
        UITextField * textField =(UITextField *) [cell viewWithTag:1000];
        if (textField) {
            [textField removeFromSuperview];textField = nil;
        }
        cell.emptyLineLength = -1;
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        if (indexPath.section ==4)
        {
            cell.backgroundType = BACKGROUND_GROUP;
            [self createCinema:cell];
        }else if (indexPath.section == 5)
        {
            cell.backgroundType = BACKGROUND_GROUP;
            [self createTextField:cell];
        }
        
        return cell;
    }
    return nil;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 4) {
        [self selectImageView];
    }
}
#pragma mark NetReqToViewCtrDelegate
- (void)requestToViewCtrWithRequestType:(RequestType)requestType didFinishLoadingWithResult:(id)result
{
    [self hideLoadingViewWithAnimated:YES];
    if (requestType == REQ_USER_Feedback_POI) {
        if ([[result objectForKey:@"message"] isEqualToString:@"Successful."]) {
            [POICommon showAutoHideAlertView:STR(@"TS_FeedBackThankyou", Localize_UserFeedback) showTime:2.0f];
            [self .navigationController popViewControllerAnimated:YES];
        }else
        {
             [POICommon showAutoHideAlertView:STR(@"TS_SummitFail", Localize_UserFeedback) showTime:2.0f];
        }
    }
    
}
- (void)requestToViewCtrWithRequestType:(RequestType)requestType didFailWithError:(NSError *)error
{
    [self hideLoadingViewWithAnimated:YES];
    [self NetRequestError];
    
}
#pragma mark 创建一个相框
-(void)createCinema :(UITableViewCell *)cell
{
    FeedBackImageView * feedBack = [[FeedBackImageView alloc]initWithFrame:CGRectMake(0, 0,_tableView.bounds.size.width-5, 70)];
    feedBack.delegate = self;
    feedBack.tag = 5000;
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
    if ([_textFieldPhone isFirstResponder]) {
        [_textFieldPhone resignFirstResponder];
    }
    if ([self.textFieldName1 isFirstResponder]) {
        [self.textFieldName1 resignFirstResponder];
    }
    if ([self.textFieldAdd1 isFirstResponder]) {
        [self.textFieldAdd1 resignFirstResponder];
    }
    if ([self.textFieldTel1 isFirstResponder]) {
        [self.textFieldTel1 resignFirstResponder];
    }
    if ([self.textFieldOther isFirstResponder]) {
        [self.textFieldOther resignFirstResponder];
    }
}
#pragma mark  PTrafficDescribeProtocol
-(void)selectImageView
{
    [self keyBoardBack];
    [self CtImagePickerChoosePic];
}
#pragma mark -- UITextFieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    _tableView.contentOffset=CGPointMake(0,0);
    return  YES;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (range.location>=30) {
        return NO;
    }return YES;
}
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (isPad&&Interface_Flag==1&&textField.tag==1000) {
        _tableView.contentOffset=CGPointMake(0,200);
    }

    return YES;
}
-(BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    _tableView.frame = CGRectMake(10,0.0, self.view.bounds.size.width - 10 * 2,self.view.bounds.size.height);
    return YES;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
- (void)NetRequestError
{
    GDAlertView *Myalert_ext = [[GDAlertView alloc] initWithTitle:nil andMessage:STR(@"Universal_networkError", Localize_Universal) ];
    [Myalert_ext addButtonWithTitle:STR(@"Universal_ok", Localize_Universal)  type:GDAlertViewButtonTypeCancel handler:^(GDAlertView * alert){
    }];
    [Myalert_ext show];
    [Myalert_ext release];
}


@end

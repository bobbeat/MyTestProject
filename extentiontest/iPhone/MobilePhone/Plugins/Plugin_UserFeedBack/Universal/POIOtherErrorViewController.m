//
//  POIOtherErrorViewController.m
//  AutoNavi
//
//  Created by weisheng on 14-6-10.
//
//

#import "POIOtherErrorViewController.h"
#import "MWFeedBackRequest.h"
#import "POIDefine.h"
#import "POIAnErrorViewController.h"
#import "ViewPOIController.h"

#define screenHeight (SCREENHEIGHT- (((float)NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1) ? 0 : 20))
typedef enum AlertTag
{
    Alert_TextViewNull_tag,//描述为空的时候
    Alert_NetError_tag,//网络出错的时候
}AlertTag;
@interface POIOtherErrorViewController ()<UITextViewDelegate,UITextFieldDelegate,NetReqToViewCtrDelegate>

@end

@implementation POIOtherErrorViewController

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
    CRELEASE(_textViewDes);
    CRELEASE(_textViewAdd);
    CRELEASE(_textFieldQQ);
    CRELEASE(_feedBackImage);
    CRELEASE(_poi);
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    [MWFeedBackRequest sharedInstance].feedBackDelegate = nil;
    [super dealloc];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
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
-(void)leftBtnEvent:(id)sender
{
    [[MWFeedBackRequest sharedInstance] Net_CancelRequestWithType:REQ_USER_Feedback_POI];
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)GetLastViewController
{
    POIAnErrorViewController * ctl = [[POIAnErrorViewController alloc]init];
    ctl.feedBackPoi = self.poi;
    NSMutableArray * ctl_array = [[NSMutableArray alloc] init];
    [ctl_array addObjectsFromArray:self.navigationController.viewControllers];
      NSMutableArray * array= [NSMutableArray array];
    if ([ctl_array count] >0)
    {
        [ctl_array removeObjectAtIndex:[ctl_array count] - 1];
        [ctl_array removeLastObject];
        for (id arr in ctl_array) {
            if ([arr isKindOfClass:[self class]]||[arr isKindOfClass:[ctl class]] ) {
                NSLog(@"%@",arr);
            }else
            {
                [array addObject:arr];
            }
        }
        [array addObject:ctl];
        NSLog(@"%@",array);
    }
    [self.navigationController setViewControllers:array animated:NO];
    [ctl release];
    [ctl_array release];
    return;
}
- (void)buttonAction:(UIButton *)button
{
    if (button.tag == 10) {
            [self keyBoardBack];
            [self showLoadingViewInView:nil view:self.view];
        
            MWFeedbackFunctionCondition * condition = [[MWFeedbackFunctionCondition alloc]init];
            if (self.textFieldQQ) {
                condition.tel = self.textFieldQQ.text;
            }
            if (self.textViewAdd.text) {
                condition.errorDesc = self.textViewAdd.text;
            }
            if (self.type) {
                condition.questionType = self.type;
            }
            if (self.feedBackImage.selectImage) {
                condition.pic  = self.feedBackImage.selectImage;
            }
            [[MWFeedBackRequest sharedInstance]Net_FeedbackGetUserFromPoi:self.poi withDescription:condition requestType:REQ_USER_Feedback_POI delegate:self];
            [condition release];
    }
}
-(void)changePortraitControlFrameWithImage
{    _tableView.frame = CGRectMake(10,0.0, self.view.bounds.size.width - 10 * 2,self.view.bounds.size.height);
    [_btnCommit setFrame:CGRectMake(0,20,_tableView.bounds.size.width, 48)];
    [_textViewDes setFrame:CGRectMake(5, 5, _tableView.bounds.size.width-10, 110)];
    [_tableView reloadData];

}
//调整横屏控件坐标和图片
-(void)changeLandscapeControlFrameWithImage
{
    [_tableView setFrame:CGRectMake(10, 0.0f, CCOMMON_APP_WIDTH-2*10,CCOMMON_CONTENT_HEIGHT)];
    [_btnCommit setFrame:CGRectMake(0,20,_tableView.bounds.size.width, 48)];
    [_textViewDes setFrame:CGRectMake(10, 5, _tableView.bounds.size.height-20, 110)];
    [_tableView reloadData];
}


#pragma mark UITableViewDataSource/
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.type ==2007) {
        if (section ==0) {
            return 2;
        }
        
    }
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section ==0 )
    {
        if (self.type ==2007) {
            if (indexPath.row ==0) {
                return 120;
            }else
            {
                return 40;
            }
        }
        else
        {
            return 120;
        }
    }else if (indexPath.section == 1)
    {
        return 70;
    }
    return 50;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * identy = @"cellidenty";
    FeedBackTableViewCell * cell =[tableView dequeueReusableCellWithIdentifier:identy];
    if (cell == nil) {
        cell = [[[FeedBackTableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identy] autorelease];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = nil;
    cell.detailTextLabel.text = nil;
    cell.accessoryView  = nil;
    
    UITextField * textField =(UITextField *) [cell viewWithTag:123];
    if (textField) {
        [textField removeFromSuperview];
        textField = nil;
    }
    HTextVIewPlaceholder *  textViewDes =(HTextVIewPlaceholder *) [cell viewWithTag:124];
    if (textViewDes) {
        [textViewDes removeFromSuperview];
        textViewDes = nil;
    }
    
    FeedBackImageView * feedBack =(FeedBackImageView *) [cell viewWithTag:5000];
    if (feedBack) {
        [feedBack removeFromSuperview];
        feedBack = nil;
    }
    if (indexPath.section == 0)
    {
        if (self.type == 2007) {
            if (indexPath.row == 0) {
                cell.backgroundType = BACKGROUND_HEAD;
                [self createTextView:cell];
                cell.accessoryView  = nil;
            }
            else
            {
                cell.backgroundType = BACKGROUND_TRACKTOP;
                cell.emptyLineLength = -1;
                cell.imageView.image = IMAGE(@"PersonalKM.png", IMAGEPATH_TYPE_1);
                UIImageView * tempimg = [[UIImageView alloc] initWithImage:IMAGE(@"Accessory.png", IMAGEPATH_TYPE_1)];
                cell.accessoryView = tempimg;
                [tempimg release];
                cell.textLabel.text = STR(@"Universal_noSpecifiedPoint", Localize_Universal);
                if (self.poi.szName) {
                    cell.textLabel.text = self.poi.szName;
                }
            }
            
        }
        else
        {
            cell.backgroundType = BACKGROUND_GROUP;
            cell.emptyLineLength = -1;
            [self createTextView:cell];
            cell.accessoryView  = nil;
        }
        
    }
    else if (indexPath.section == 1)
    {
        cell.backgroundType = BACKGROUND_GROUP;
        cell.emptyLineLength = -1;
        cell.imageView.image = nil;
        [self createCinema:cell];
    }
    else if(indexPath.section == 2)
    {
        cell.backgroundType = BACKGROUND_GROUP;
        cell.emptyLineLength = -1;
        cell.imageView.image = nil;
        [self createTextField:cell];
    }
  
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section ==0) {
        if (indexPath.row ==1&&self.type == 2007) {
            [POICommon intoPOIViewController:self withIndex:0 withViewFlag:INTO_TYPE_ADD_FeedBack_Point withPOIArray:nil];
        }
    }
    else if (indexPath.section ==1)
    {
        [self selectImageView];
       
    }
}

#pragma mark 创建一个UitextField
-(void)createTextField :(UITableViewCell *)cell
{
    UITextField * textField = [self createTextFieldWithPlaceholder:STR(@"TS_MailAndPhone", Localize_UserFeedback) fontSize:kSize2 tag:123];
    textField.borderStyle = UITextBorderStyleNone;
    [textField setFrame:CGRectMake(10, 10, _tableView.bounds.size.width -20, 30)];
    textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;//设置光标在中心
    textField.delegate = self;
    [cell addSubview:textField];
    if (self.textFieldQQ) {//将数据保存起来
        textField.text = self.textFieldQQ.text;
    }self.textFieldQQ = textField;
}
#pragma mark 创建一个TextView
-(void)createTextView :(UITableViewCell *)cell
{
    HTextVIewPlaceholder * textViewDes= [[HTextVIewPlaceholder alloc]init];
    textViewDes.delegate = self;
    if (self.textViewAdd) {
        textViewDes.text = self.textViewAdd.text;
    }self.textViewAdd = textViewDes;
    [textViewDes setFrame:CGRectMake(2,5,_tableView.bounds.size.width-4, 110)];
    textViewDes.tag = 124;
    [cell.contentView addSubview:textViewDes];
    [textViewDes release];
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
    if ([_textViewAdd isFirstResponder]) {
        [ _textViewAdd resignFirstResponder];
    }
    if ([_textFieldQQ isFirstResponder]) {
        [_textFieldQQ resignFirstResponder];
    }
}
#pragma mark  PTrafficDescribeProtocol
-(void)selectImageView
{
    [self keyBoardBack];
    [self CtImagePickerChoosePic];
}
#pragma mark  NetReqToViewCtrDelegate
- (void)requestToViewCtrWithRequestType:(RequestType)requestType didFinishLoadingWithResult:(id)result
{
    [self hideLoadingViewWithAnimated:YES];
    if (requestType == REQ_USER_Feedback_POI) {
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
#pragma mark - UITextView Delegate Methods
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

#pragma mark -- UITextFieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
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
    if (!isPad) {
        if (Interface_Flag == 1) {
            _tableView.contentOffset=CGPointMake(0,210);
        }else
        {
            _tableView.contentOffset=CGPointMake(0,150);
        }
    }

    return YES;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
#pragma mark NSNotificationCenter
- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    NSLog(@"%f",keyboardRect.size.height);
    if (Interface_Flag ==1) {
        _keyBoardHeight = APPWIDTH/2;
        [_tableView setFrame:CGRectMake(10, 0.0f, CCOMMON_APP_WIDTH-2*10,CCOMMON_CONTENT_HEIGHT -APPWIDTH/2)];
    }else
    {
        _keyBoardHeight = keyboardRect.size.height;
        [_tableView setFrame:CGRectMake(10,0, APPWIDTH - 20 , screenHeight - keyboardRect.size.height -44)];
    }
}
- (void)keyboardWillHide:(NSNotification *)notification {
    NSDictionary* userInfo = [notification userInfo];
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    if (Interface_Flag ==1) {
        [_tableView setFrame:CGRectMake(10, 0.0f, CCOMMON_APP_WIDTH-2*10,CCOMMON_CONTENT_HEIGHT -0)];
    }else
    {
        [_tableView setFrame:CGRectMake(10,0, APPWIDTH - 20 , screenHeight - 0 -44)];
    }
    _keyBoardHeight = 0;
    _tableView.contentOffset = CGPointMake(0,_keyBoardHeight);
}

@end

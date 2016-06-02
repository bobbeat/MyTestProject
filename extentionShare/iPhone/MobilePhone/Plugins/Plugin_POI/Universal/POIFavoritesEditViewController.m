//
//  POIFavoritesEditViewController.m
//  AutoNavi
//
//  Created by huang on 13-8-20.
//
//

#import "POIFavoritesEditViewController.h"
#import "Plugin_GDAccount_InputCell.h"
#import "MWPoiOperator.h"
#import "POIDefine.h"
#import "POIInputCell.h"
@interface POIFavoritesEditViewController ()

@end

@implementation POIFavoritesEditViewController
@synthesize poi;
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
    CRELEASE(poi);
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
    if (_textFieldName) {
        [_textFieldName becomeFirstResponder];
    }
    
}

#pragma mark -
#pragma mark control related
//初始化控件
-(void) initControl{
//    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(notificationReceived:) name: UITextFieldTextDidChangeNotification object: nil];

}

//调整控件竖屏坐标和图片
-(void)changePortraitControlFrameWithImage
{
    [_tableView setFrame:CGRectMake(CCOMMON_TABLE_X, 0.0f, APPWIDTH-2*CCOMMON_TABLE_X, CONTENTHEIGHT_V)];
//    [_tableView reloadData];
    [_tableView scrollRectToVisible:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-40.0) animated:YES];

}

//调整控件横屏坐标和图片
-(void)changeLandscapeControlFrameWithImage
{
    [_tableView setFrame:CGRectMake(CCOMMON_TABLE_X, 0.0f, APPHEIGHT-2*CCOMMON_TABLE_X, CONTENTHEIGHT_H)];
//    [_tableView reloadData];
    if (!isPad&&[_textFieldLocal isFirstResponder]) {
        [_tableView setFrame:CGRectMake(CCOMMON_TABLE_X, -1*kHeight2 , APPHEIGHT-2*CCOMMON_TABLE_X, CONTENTHEIGHT_H)];
    }
 
}
//改变控件文本
-(void)changeControlText
{
    self.title=STR(@"POI_EditInfoTitle",Localize_POI);
      self.navigationItem.leftBarButtonItem=LEFTBARBUTTONITEM(@"", @selector(leftBtnEvent:));
    self.navigationItem.rightBarButtonItem=RIGHTBARBUTTONITEM(STR(@"POI_Save", Localize_POI), @selector(saveEdit));
}
-(void)leftBtnEvent:(id)object
{
    [self.navigationController popViewControllerAnimated:YES];
}



#pragma mark -
#pragma mark UITextFieldDelegate
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField==_textFieldLocal) {
        if (!isPad && Interface_Flag) {
            [_tableView setFrame:CGRectMake(CCOMMON_TABLE_X, -1*kHeight2 , APPHEIGHT-2*CCOMMON_TABLE_X, CONTENTHEIGHT_H)];
        }
    }
    return YES;
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
    int location=textField==_textFieldName?20:textField==_textFieldTel?30:20;
    if (range.location>location-1) {
        return NO;
    }
    return YES;

}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[textField resignFirstResponder];
	
	return YES;
}
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if (!isPad&&_textFieldLocal==textField && Interface_Flag) {
        [_tableView setFrame:CGRectMake(CCOMMON_TABLE_X, 0 , APPHEIGHT-2*CCOMMON_TABLE_X, CONTENTHEIGHT_H)];
    }
}
-(void)saveEdit
{

	poi.szName = [NSString stringWithFormat:@"%@",_textFieldName.text];
	poi.szAddr = [NSString stringWithFormat:@"%@",_textFieldLocal.text];
	poi.szTel =  [NSString stringWithFormat:@"%@",_textFieldTel.text];
    BOOL isPrompt=NO;

    if(poi.szTel.length>0&& [NSString checkPhoneStandardWith:poi.szTel]==NO)
    {
        isPrompt=YES;
    }
    if (isPrompt) {
        GDAlertView *alert = [[[GDAlertView alloc] initWithTitle:nil andMessage:STR(@"POI_TextFeildErroeMessage", Localize_POI)] autorelease];
        [alert addButtonWithTitle:STR(@"POI_OK",Localize_POI) type:GDAlertViewButtonTypeCancel handler:nil];
        [alert show];
        return;

    }
    NSString *newName=[poi.szName stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (newName.length<1||_textFieldName.text.length==0) {
        GDAlertView *alert = [[[GDAlertView alloc] initWithTitle:nil andMessage:STR(@"POI_TextFieldPromptMessage", Localize_POI)] autorelease];
        [alert addButtonWithTitle:STR(@"POI_OK",Localize_POI) type:GDAlertViewButtonTypeCancel handler:nil];
        [alert show];
        return;
    }
    NSString *prompt=nil;
    if (poi.szName.length>20) {
        prompt=STR(@"POI_Name",Localize_POI);
    }
    else if (poi.szAddr.length>20) {
        prompt=STR(@"POI_Address",Localize_POI);
    }
    else if (poi.szTel.length>30) {
        prompt=STR(@"POI_Phone",Localize_POI);
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
    
    GSTATUS gst= [MWPoiOperator editeFavoritePoiWith:(MWFavoritePoi*)poi];
    if (gst==GD_ERR_OK) {
        NSLog(@"编辑成功");
    }
	[self.navigationController popViewControllerAnimated:YES];
	
}
#pragma mark -
#pragma mark xxx delegate
#pragma mark -
#pragma mark UITableViewDataSource


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 3;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return kHeight2 ;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    static NSString *cellIdentifier=@"Cell";
    POIInputCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell=[[[POIInputCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
    }
     cell.backgroundType = BACKGROUND_FOOTER;
     cell.emptyLineLength = 0;
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
   
    
    if (indexPath.row==0) {
        cell.textLabel.text=STR(@"POI_Name", Localize_POI);
        _textFieldName = cell.textField;
        _textFieldName.keyboardType=UIKeyboardTypeDefault;
        if ([poi.szName length] == 0) {
            _textFieldName.text = @"";
        }
        else
        {
            _textFieldName.text = [NSString stringWithFormat:@"%@", poi.szName];
        }
    }
    else if(indexPath.row == 1)
    {
        cell.textLabel.text=STR(@"POI_Phone", Localize_POI);
        _textFieldTel = cell.textField;
        _textFieldTel.keyboardType=UIKeyboardTypePhonePad;
        if ([poi.szTel length] == 0) {
            _textFieldTel.text = @"";
        }
        else
        {
            _textFieldTel.text = [NSString stringWithFormat:@"%@",poi.szTel];
        }
    }
    else if(indexPath.row == 2)
    {
        cell.textLabel.text=STR(@"POI_Address", Localize_POI);
        _textFieldLocal = cell.textField;
        _textFieldLocal.keyboardType=UIKeyboardTypeDefault;
        if ([poi.szAddr length] == 0) {
            _textFieldLocal.text = @"";
        }
        else
        {
            _textFieldLocal.text = [NSString stringWithFormat:@"%@", poi.szAddr];
        }
        cell.backgroundType=BACKGROUND_FOOTER;
    }
   
    cell.textField.textColor=TEXTCOLOR;
    cell.textField.font=[UIFont systemFontOfSize:kSize2];
    cell.textField.delegate=self;
    cell.textLabel.textColor=TEXTCOLOR;
    cell.textLabel.font=[UIFont systemFontOfSize:kSize2];

    return cell;
 }
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([_textFieldTel isFirstResponder]) {
        [_textFieldTel resignFirstResponder];
    }
    else if ([_textFieldLocal isFirstResponder]) {
        [_textFieldLocal resignFirstResponder];
    }
    else  {
        [_textFieldName resignFirstResponder];
    }
}

@end

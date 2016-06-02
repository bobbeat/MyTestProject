//
//  CityChooseViewController.m
//  RoadFreightage
//
//  Created by gaozhimin on 15/7/20.
//  Copyright (c) 2015年 WuKongSuYun. All rights reserved.
//

#import "CityChooseViewController.h"
#import "CustomCellDataContainTextField.h"
#import "UIImage+Category.h"
#import "CustomTextFieldCell.h"
#import "LoginStorage.h"
#import "MainTabBarController.h"
#import "NSString+Category.h"

//城市分类，首字母相同的都在其中的数组中
@interface GZCityCategory : NSObject

@property (nonatomic,copy) NSString *cityFirstLetter; //城市首字母
@property (nonatomic,strong) NSMutableArray *cityHanziArray; //城市名数组-汉字
@property (nonatomic,strong) NSMutableArray *cityPinyinArray; //城市名数组-拼音

@end

@implementation GZCityCategory

- (void)dealloc
{
    self.cityFirstLetter = nil;
    self.cityHanziArray = nil;
    self.cityPinyinArray = nil;
}

- (void)setCityHanziArray:(NSMutableArray *)array
{
    _cityHanziArray = array;
    
}

@end
#define HotCityViewHeight 120

@interface CityChooseViewController ()<UITextFieldDelegate>
{
    UIImageView *_logoImageView;
    UIImageView *_logoTextImageView;
    
    UIButton *_loginButton;
    
    SYNetAPI * _syNet;
    
    NSArray *_arrayLetter;
    
    UILabel *_labelLetter;
    UITextField *_textField;
    
    UIView *_viewHotCity;
    
    NSMutableArray *_cityArray;    //城市列表数组-
}

@property (nonatomic,strong)  NSArray *cellDataObj;
@property (nonatomic,strong)  NSArray *arraySearchResult;
@property (nonatomic,copy)  NSString *strSearchKey;

@end

@implementation CityChooseViewController

- (void)dealloc
{
    self.arraySearchResult = nil;
    self.cellDataObj = nil;
    self.strSearchKey = nil;
}

- (NSString *)ChToP:(NSString *)chinese
{
    //先转换为带声调的拼音
    
    NSMutableString *str = [chinese mutableCopy];
    
    CFStringTransform((CFMutableStringRef)str,NULL, kCFStringTransformMandarinLatin,NO);
    
    //再转换为不带声调的拼音
    
    CFStringTransform((CFMutableStringRef)str,NULL, kCFStringTransformStripDiacritics,NO);
    
    return str;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    CGSize size = self.view.bounds.size;
    
    int hotCityHeight = HotCityViewHeight;
    int row = 3;
    int line = 3;
    _viewHotCity = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, HotCityViewHeight)];
    _viewHotCity.backgroundColor = [UIColor clearColor];
    
    for (int i = 0; i < line; i++) {
        
        float buttony = (hotCityHeight/line)*i + (hotCityHeight/line)/2 + 10;
        
        for (int j = 0; j < row; j++)
        {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            [button addTarget:self action:@selector(HotCityChoose:) forControlEvents:UIControlEventTouchUpInside];
            [button setTitle:@"北京" forState:UIControlStateNormal];
            [_viewHotCity addSubview:button];
            
            float buttonx = (size.width/row)*j + (size.width/row)/2;
            button.frame = CGRectMake(0, 0, 60, 40);
            button.center =CGPointMake(buttonx, buttony);
            button.tag = i*line + j;
        }
    }
    
    
    _textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 10, size.width - 30, size.height-20)];
    _textField.backgroundColor = [UIColor clearColor];
    _textField.textColor = [UIColor blackColor];
    _textField.borderStyle = UITextBorderStyleNone;
    _textField.autocorrectionType = UITextAutocorrectionTypeNo;
    _textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _textField.keyboardType = UIKeyboardTypeDefault;
    _textField.returnKeyType = UIReturnKeyDone;
    _textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _textField.placeholder = @"请输入";
    _textField.leftView=nil;
    _textField.background=nil;
    _textField.delegate = self;
    [self.tableView addSubview:_textField];
    _textField.center = CGPointMake(size.width/2, 50/2);
    
    _syNet = [[SYNetAPI alloc] init];
    _syNet.delegate = self;
    
    _logoImageView = [[UIImageView alloc] init];
    _logoImageView.image = [UIImage imageNamed:@"wk_appicon"];
    _logoImageView.bounds = CGRectMake(0, 0, _logoImageView.image.size.width, _logoImageView.image.size.height);
    
    _logoTextImageView = [[UIImageView alloc] init];
    _logoTextImageView.image = [UIImage imageNamed:@"wk_banner"];
    _logoTextImageView.bounds = CGRectMake(0, 0, _logoTextImageView.image.size.width, _logoTextImageView.image.size.height);
    
    _loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_loginButton setBackgroundImage:[UIImage getStretchableImageWith:[UIImage imageNamed:@"wk_btn_background.png"]] forState:UIControlStateNormal];
    [_loginButton setTitle:@"登录" forState:UIControlStateNormal];
    [_loginButton addTarget:self action:@selector(loginAction) forControlEvents:UIControlEventTouchUpInside];
    
    NSMutableArray *dataArray = [NSMutableArray array];
    NSMutableArray *sectionArray = [NSMutableArray array];
    CustomCellData *cellData = [[CustomCellData alloc] init];
    cellData.text = @"定位城市";
    [sectionArray addObject:cellData];
    [dataArray addObject:sectionArray];
    
    NSMutableArray *existLetter = [NSMutableArray array];
    [existLetter addObject:@"热门"];
    
    _cityArray = [NSMutableArray array];
    
    GZCityCategory *city = [[GZCityCategory alloc] init];
    city.cityFirstLetter = @"a";
    city.cityHanziArray = [NSMutableArray arrayWithArray:@[@"阿里",@"艾斯",@"俺们"]];
    [_cityArray addObject:city];
    
    city = [[GZCityCategory alloc] init];
    city.cityFirstLetter = @"c";
    city.cityHanziArray = [NSMutableArray arrayWithArray:@[@"曹操",@"侧耳",@"瞅瞅"]];
    [_cityArray addObject:city];
    
    city = [[GZCityCategory alloc] init];
    city.cityFirstLetter = @"g";
    city.cityHanziArray = [NSMutableArray arrayWithArray:@[@"改改",@"尴尬",@"嘎哈"]];
    [_cityArray addObject:city];
    
    city = [[GZCityCategory alloc] init];
    city.cityFirstLetter = @"j";
    city.cityHanziArray = [NSMutableArray arrayWithArray:@[@"解决",@"接口",@"距离"]];
    [_cityArray addObject:city];
    
    city = [[GZCityCategory alloc] init];
    city.cityFirstLetter = @"x";
    city.cityHanziArray = [NSMutableArray arrayWithArray:@[@"下午",@"信号",@"相加"]];
    [_cityArray addObject:city];
    
    for (int i = 0; i < [_cityArray count]; i++)
    {
        sectionArray  = [NSMutableArray array];
        GZCityCategory *dic = [_cityArray objectAtIndex:i];
        NSString *key = dic.cityFirstLetter;
        [existLetter addObject:key];
        NSArray *array = dic.cityHanziArray;
        for (int j = 0; j < [array count]; j++) {
            cellData = [[CustomCellData alloc] init];
            cellData.text = [array objectAtIndex:j];
            [sectionArray addObject:cellData];
        }
        [dataArray addObject:sectionArray];
    }
   
    
    self.cellDataObj = [NSArray arrayWithArray:dataArray];
    
    _arrayLetter = [NSArray arrayWithArray:existLetter];
  //@[@"热门",@"a",@"b",@"c",@"d",@"e",@"f",@"g",@"h",@"i",@"j",@"k",@"l",@"m",@"n",@"o",@"p",@"q",@"r",@"s",@"t",@"u",@"v",@"w",@"x",@"y",@"z",@"#"];
    NSString *letter = [[_arrayLetter componentsJoinedByString:@"\r"] uppercaseString];
    CGSize letterSize = [letter sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]}];
    letterSize.height = ceilf(letterSize.height); //向上取整
    _labelLetter = [[UILabel alloc] initWithFrame:CGRectMake(self.view.bounds.size
                                                             .width-30, size.height - letterSize.height - 30, 30, letterSize.height + 1)];
    _labelLetter.numberOfLines = 28;
    _labelLetter.text = letter;
    _labelLetter.font = [UIFont systemFontOfSize:12];
    _labelLetter.backgroundColor = [UIColor clearColor];
    _labelLetter.textAlignment = NSTextAlignmentCenter;
    _labelLetter.textColor = [UIColor redColor];
    [self.navigationController.view addSubview:_labelLetter];
    _labelLetter.userInteractionEnabled = YES;
    _labelLetter.center = CGPointMake(self.view.bounds.size
                                      .width-15, self.view.bounds.size
                                      .height/2 + 20);
    
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognizer:)];
    recognizer.numberOfTapsRequired = 1;
    recognizer.numberOfTouchesRequired = 1;
    [_labelLetter addGestureRecognizer:recognizer];
    
}
- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super viewWillDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(textFieldDidChange:) name: UITextFieldTextDidChangeNotification object: nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tapGestureRecognizer:(UITapGestureRecognizer *)recognizer
{
    CGPoint touchPoint = [recognizer locationInView:recognizer.view];
    CGSize size = [recognizer.view bounds].size;
    float _oneHeight = size.height/(float)[_arrayLetter count];
    int index = touchPoint.y/_oneHeight;
    if (index < [_arrayLetter count]) {
        NSLog(@"%@",[_arrayLetter objectAtIndex:index]);
        int section = [self FindCityFirstLetterIndex:[_arrayLetter objectAtIndex:index]];
        CGRect rect = [self.tableView rectForHeaderInSection:section];
        
        float maxY = self.tableView.contentSize.height - self.tableView.frame.size.height;
        if (rect.origin.y > maxY)
        {
            rect.origin.y = maxY;
        }
        [self.tableView setContentOffset:CGPointMake(0, rect.origin.y)];
    }
}

//查找城市首字母所在section位置
- (int)FindCityFirstLetterIndex:(NSString *)city
{
    if ([city isEqualToString:@"#"]) {
        return (int)[_cityArray count] - 1;
    }
    int section = 0;
    char city_letter = [city UTF8String][0];
    for (int i = 0; i < [_cityArray count]; i++)
    {
        section = i;
        
        NSDictionary *dic = [_cityArray objectAtIndex:i];
        char temp = [[[dic allKeys] firstObject] UTF8String][0];
        if (temp > city_letter)
        {
            break;
        }
    }
    return section;
}



- (void)SearchAction:(NSString *)key
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableArray *searchResult = [NSMutableArray array];
        
        NSString *regex = @"^[\u4e00-\u9fa5A-Za-z]+$";
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
        BOOL sign = [predicate evaluateWithObject:key];
        if (sign)
        {
            regex = @"^[A-Za-z]+$";
            predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
            sign = [predicate evaluateWithObject:key];
            if (sign)
            {
                
            }
            else
            {
                for (int i = 0; i < [_cityArray count]; i++)
                {
                    GZCityCategory *cityCategory = [_cityArray objectAtIndex:i];
                    NSArray *array = cityCategory.cityHanziArray;
                    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF CONTAINS %@",key];
                    NSArray *temp = [array filteredArrayUsingPredicate:pred];
                    [searchResult addObjectsFromArray:temp];
                };
            }
        }
        if ([searchResult count] == 0) {
            [searchResult addObject:@"无搜索结果"];
        }
        _arraySearchResult = [NSArray arrayWithArray:searchResult];
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    });
    
   
    
}

#pragma mark -  Action Handle

- (void)HotCityChoose:(UIButton *)button
{
    NSLog(@"button %ld",button.tag);
}

- (void)getVerificationCodeAction
{
    [QLoadingView showDefaultLoadingView:@"加载中"];
    
    CustomCellDataContainTextField *cellData = [[self.cellDataObj objectAtIndex:0] objectAtIndex:0];
    NSString *phone = cellData.cellFieldText;
    VerifyCodeRequest *verifyCode = [[VerifyCodeRequest alloc] init];
    verifyCode.requestType  = SYNetType_VerifyCode;
    verifyCode.sid          = @"";
    verifyCode.userid       = 0;
    verifyCode.usertype     = @"driver";
    verifyCode.platform     = @"IOS";
    verifyCode.phone        = phone;
    
    [_syNet getVerifyCode:verifyCode];
}

- (void)loginAction
{
    [QLoadingView showDefaultLoadingView:@"加载中"];
    
    CustomCellDataContainTextField *cellData = [[self.cellDataObj objectAtIndex:0] objectAtIndex:0];
    NSString *phone = cellData.cellFieldText;
    
    cellData = [[self.cellDataObj objectAtIndex:0] objectAtIndex:1];
    NSString *code = cellData.cellFieldText;
    
    LoginRequest *loginObj = [[LoginRequest alloc] init];
    loginObj.requestType  = SYNetType_Login;
    loginObj.sid          = @"";
    loginObj.userid       = 0;
    loginObj.usertype     = @"driver";
    loginObj.platform     = @"IOS";
    loginObj.phone        = phone;
    loginObj.code         = code;
    [_syNet login:loginObj];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if ([self.strSearchKey length] > 0)
    {
        return 1;
    }
    return [self.cellDataObj count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self.strSearchKey length] > 0)
    {
        return [self.arraySearchResult count];
    }
    return [[self.cellDataObj objectAtIndex:section] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ([self.strSearchKey length] > 0)
    {
        return 50;
    }
    if (section == 0)
    {
        return 50;
    }
    return 20;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if ([self.strSearchKey length] > 0)
    {
        return nil;
    }
    float height = [self tableView:tableView heightForHeaderInSection:section];
    
    UIView *view = nil;
    view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, height)];
    view.backgroundColor = [UIColor clearColor];
    if (section == 0)
    {
        [self.tableView bringSubviewToFront:_textField];
    }
    else
    {
        UILabel *letterLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 100, height)];
        GZCityCategory *cityCategory = [_cityArray objectAtIndex:section-1];
        letterLabel.text = cityCategory.cityFirstLetter;
        letterLabel.backgroundColor = [UIColor clearColor];
        letterLabel.textColor = [UIColor grayColor];
        letterLabel.font = [UIFont systemFontOfSize:14];
        [view addSubview:letterLabel];
    }
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if ([self.strSearchKey length] > 0)
    {
        return 10;
    }
    if (section == 0)
    {
        return HotCityViewHeight + 40;
    }
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if ([self.strSearchKey length] > 0)
    {
        return nil;
    }
    float height = [self tableView:tableView heightForFooterInSection:section];
    
    UIView *view = nil;
    view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, height)];
    view.backgroundColor = [UIColor clearColor];
    if (section == 0)
    {
        [view addSubview:_viewHotCity];
        _viewHotCity.center = CGPointMake(view.bounds.size.width/2, height/2);
        
        UILabel *hotCityLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 100, 40)];
        hotCityLabel.text = @"热门城市";
        hotCityLabel.backgroundColor = [UIColor clearColor];
        hotCityLabel.textColor = [UIColor grayColor];
        hotCityLabel.font = [UIFont systemFontOfSize:14];
        [view addSubview:hotCityLabel];
    }
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    if ([self.strSearchKey length] > 0)
    {
        cell.textLabel.text = [self.arraySearchResult objectAtIndex:indexPath.row];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else
    {
        CustomCellData *cellData = [[self.cellDataObj objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        cell.textLabel.text = cellData.text;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CustomCellData *cellData = [[self.cellDataObj objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    if (cellData.cellActionBlock)
    {
        cellData.cellActionBlock(nil);
    }
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    
    
}
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    
}

- (void)textFieldDidChange:(NSNotification *)notification
{
    UITextField *textField = nil;
    
    NSObject* obj = [notification object];
    if ([obj isKindOfClass:[UITextField class]])
    {
        textField = (UITextField*)obj;
        
    }
    if (textField)
    {
        self.strSearchKey = textField.text;
        [self SearchAction:textField.text];
    }
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

#pragma mark - SYNetDelegate

- (void)netRequest:(id)request didFailWithError:(NSError *)error;
{
    [QLoadingView hideWithAnimated:NO];
    
    [super netRequest:request didFailWithError:error];
}

- (void)onVerifyCodeDone:(VerifyCodeRequest *)request response:(VerifyCodeResponse *)response
{
    [QLoadingView hideWithAnimated:NO];
    
    
    NSLog(@"\r\n%s: netRequest = %@, resoponse= %@\r\n", __func__, [request class], response);
}

- (void)onLoginDone:(LoginRequest *)request response:(LoginResponse *)response
{
    [QLoadingView hideWithAnimated:NO];
    
    MainTabBarController *ctl = [[MainTabBarController alloc] init];
    self.navigationController.viewControllers = @[ctl];
    
    [LoginStorage saveUserData:response];
    
    NSLog(@"\r\n%s: netRequest = %@, resoponse= %@\r\n", __func__, [request class], response);
    
}


@end

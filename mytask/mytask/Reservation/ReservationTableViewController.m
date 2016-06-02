//
//  ReservationTableViewController.m
//  mytask
//
//  Created by gaozhimin on 2/4/15.
//  Copyright (c) 2015 autonavi. All rights reserved.
//

#import "ReservationTableViewController.h"
#import "DatePickerView.h"
#import "MWSearchResult.h"

#define FooterViewHeight 230

@interface ReservationTableViewController ()
{
    DatePickerView *_datePickView;
    UIView *_footerView;
    UILabel *_lable1;
    UILabel *_lable2;
    UILabel *_lable3;
    UIButton *_buttonTks;
    UIButton *_buttonTakrWorks;
    UIButton *_buttonSure;
}

@end

@implementation ReservationTableViewController

- (instancetype)init
{
    return [self initWithStyle:UITableViewStylePlain];
}


- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
    }
    return self;
}

- (void)dealloc
{
    [_footerView release];
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.tableView.dataSource = self;
//    self.tableView.delegate = self;
    
    _datePickView  = [[DatePickerView alloc] initWithdelegate:self cancel:@selector(date_cancel_click) sure:@selector(date_ok_click)];
    [self.view addSubview:_datePickView];
    _datePickView.hidden = YES;
    [_datePickView release];
    
    _footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), FooterViewHeight)];
    
    _lable1 = [[UILabel alloc] init];
    _lable1.textColor = [UIColor blackColor];
    _lable1.textAlignment = NSTextAlignmentCenter;
    _lable1.font = [UIFont boldSystemFontOfSize:24];
    _lable1.text = @"29.0元";
    [_footerView addSubview:_lable1];
    [_lable1 release];
    
    _lable2 = [[UILabel alloc] init];
    _lable2.textColor = [UIColor blackColor];
    _lable2.textAlignment = NSTextAlignmentCenter;
    _lable2.font = [UIFont systemFontOfSize:16];
    _lable2.text = @"约20.1km，打车费用56元";
    [_footerView addSubview:_lable2];
    [_lable2 release];
    
    
    _lable3 = [[UILabel alloc] init];
    _lable3.textColor = [UIColor blackColor];
    _lable3.textAlignment = NSTextAlignmentCenter;
    _lable3.font = [UIFont systemFontOfSize:17];
    _lable3.text = @"高速费、过路费由乘客另行支付";
    [_footerView addSubview:_lable3];
    [_lable3 release];
    
    _buttonTks = [UIButton buttonWithType:UIButtonTypeCustom];
    [_buttonTks setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_buttonTks setBackgroundImage:[[UIImage imageNamed:@"CommonBtnWhit.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:10] forState:UIControlStateNormal];
    [_buttonTks setBackgroundImage:[[UIImage imageNamed:@"CommonBtnWhitPress.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:10] forState:UIControlStateHighlighted];
    [_buttonTks setImage:[UIImage imageNamed:@"PersonalHome.png"] forState:UIControlStateNormal];
    [_buttonTks setTitle:@"感谢费" forState:UIControlStateNormal];
    [_buttonTks addTarget:self action:@selector(funThanks) forControlEvents:UIControlEventTouchUpInside];
    [_footerView addSubview:_buttonTks];
    
    _buttonTakrWorks = [UIButton buttonWithType:UIButtonTypeCustom];
    [_buttonTakrWorks setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_buttonTakrWorks setBackgroundImage:[[UIImage imageNamed:@"CommonBtnWhit.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:10] forState:UIControlStateNormal];
    [_buttonTakrWorks setBackgroundImage:[[UIImage imageNamed:@"CommonBtnWhitPress.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:10] forState:UIControlStateHighlighted];
    [_buttonTakrWorks setImage:[UIImage imageNamed:@"PersonalHome.png"] forState:UIControlStateNormal];
    [_buttonTakrWorks setTitle:@"捎句话" forState:UIControlStateNormal];
    [_buttonTakrWorks addTarget:self action:@selector(funTakrWorks) forControlEvents:UIControlEventTouchUpInside];
    [_footerView addSubview:_buttonTakrWorks];
    
    _buttonSure = [UIButton buttonWithType:UIButtonTypeCustom];
    [_buttonSure setBackgroundImage:[[UIImage imageNamed:@"CommonBtn1.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:10] forState:UIControlStateNormal];
    [_buttonSure setBackgroundImage:[[UIImage imageNamed:@"CommonBtn2.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:10] forState:UIControlStateHighlighted];
    [_buttonSure setTitle:@"确认预约" forState:UIControlStateNormal];
    [_buttonSure addTarget:self action:@selector(funSure) forControlEvents:UIControlEventTouchUpInside];
    [_footerView addSubview:_buttonSure];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)funThanks
{
    
}

- (void)funTakrWorks
{
    
}

- (void)funSure
{
    
}

- (void)setFooterView
{
    CGSize size = _footerView.frame.size;
    _lable1.frame = CGRectMake(0, 0, size.width, 40);
    _lable1.center = CGPointMake(size.width/2, 35);
    
    _lable2.frame = CGRectMake(0, 0, size.width, 40);
    _lable2.center = CGPointMake(size.width/2, 60);
    
    _lable3.frame = CGRectMake(0, 0, size.width, 40);
    _lable3.center = CGPointMake(size.width/2, 80);
    
    _buttonTks.frame = CGRectMake(0, 0, 120, 40);
    _buttonTks.center = CGPointMake(size.width/4, size.height - 80);
    
    _buttonTakrWorks.frame = CGRectMake(0, 0, 120, 40);
    _buttonTakrWorks.center = CGPointMake(size.width*3/4, size.height - 80);
    
    _buttonSure.frame = CGRectMake(0, 0, size.width, 50);
    _buttonSure.center = CGPointMake(size.width/2, size.height - 25);
}

- (MWPoi *)getHome
{
    MWPoi *poi = [[MWPoi alloc] init];
    poi.szName = @"我的家";
    return [poi autorelease];
}

- (MWPoi *)getCompany
{
    MWPoi *poi = [[MWPoi alloc] init];
    poi.szName = @"我的公司";
    return [poi autorelease];
}

- (void)date_cancel_click
{
    [_datePickView ShowOrHiddenPickView:NO Animation:YES];
}

- (void)date_ok_click
{
    [_datePickView ShowOrHiddenPickView:NO Animation:YES];
    [self.tableView reloadData];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self setFooterView];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 48;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 10;
    }
    return 15;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 1)
    {
        return FooterViewHeight;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == 1)
    {
        _footerView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), FooterViewHeight);
        [self setFooterView];
        return _footerView;
    }
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section == 0) {
        return 1;
    }
    else if (section == 1)
    {
        return 2;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    NSString *reuseIdentifier = @"reuseIdentifier";
    if (indexPath.section == 1)
    {
        reuseIdentifier = @"reuseIdentifier1";
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
    }
    
    if (indexPath.section == 1)
    {
        cell.detailTextLabel.textColor = [UIColor colorWithRed:9.0/255.0 green:30.0/255.0 blue:65.0/255.0 alpha:1.0];
        cell.textLabel.textColor = [UIColor blackColor];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        if (indexPath.row == 0)
        {
            cell.imageView.image = [UIImage imageNamed:@"PersonalHome.png"];
            cell.detailTextLabel.text = [self getHome].szName;
            cell.textLabel.text= @"家";
        }
        else
        {
            cell.imageView.image = [UIImage imageNamed:@"PersonalCompany.png"];
            cell.detailTextLabel.text = [self getCompany].szName;
            cell.textLabel.text= @"公司";
        }
        
    }
    else
    {
        UILabel *lable = (UILabel *)[cell viewWithTag:1];
        if (lable == nil) {
            lable = [[UILabel alloc] init];
            lable.tag = 1;
            lable.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 48);
            lable.textColor = [UIColor blackColor];
            lable.textAlignment = NSTextAlignmentCenter;
            lable.font = [UIFont systemFontOfSize:18];
            lable.backgroundColor = [UIColor clearColor];
            [cell addSubview:lable];
            [lable release];
        }
        
        if (_datePickView.m_day == -1 && _datePickView.m_hour == -1 && _datePickView.m_minus == -1) {
            lable.text= @"选择出发时间";
        }else
        {
            lable.text= [NSString stringWithFormat:@"%@ %@ %@",[_datePickView pickerView:_datePickView.m_pickView titleForRow:_datePickView.m_day forComponent:0],[_datePickView pickerView:_datePickView.m_pickView titleForRow:_datePickView.m_hour forComponent:1],[_datePickView pickerView:_datePickView.m_pickView titleForRow:_datePickView.m_minus forComponent:2]];
        }
        
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    // Configure the cell...
    
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0)
    {
        if (_datePickView.m_day != -1)
        {
            _datePickView.m_showhour = _datePickView.m_hour;
            _datePickView.m_showday = _datePickView.m_day;
            _datePickView.m_showminus = _datePickView.m_minus;
        }
        [_datePickView ShowOrHiddenPickView:YES Animation:YES];
    }
}


@end

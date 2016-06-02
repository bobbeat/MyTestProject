//
//  ANTableViewController.m
//  AutoNavi
//
//  Created by gaozhimin on 13-9-20.
//
//

#import "ANTableViewController.h"


@interface ANTableViewController ()

@end

@implementation ANTableViewController

#pragma mark -
#pragma mark viewcontroller
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
    [_tableView setEditing:NO];
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
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.separatorStyle = NO;
    _tableView.backgroundColor = [UIColor clearColor];
    [_tableView setSeparatorColor:[UIColor clearColor]];
    if ([UITableView instancesRespondToSelector:@selector(backgroundView)])
    {
        _tableView.backgroundView = nil;
    }
    [self.view addSubview:_tableView];
    [_tableView release];
}
// Called when the view is about to made visible. Default does nothing
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    
    
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

#pragma mark -
#pragma mark control related

//调整控件竖屏坐标和图片
-(void)changePortraitControlFrameWithImage
{
    [super changePortraitControlFrameWithImage];
    _tableView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
}

//调整控件横屏坐标和图片
-(void)changeLandscapeControlFrameWithImage
{
    [super changeLandscapeControlFrameWithImage];
    _tableView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 10;
    }
    return 15-3;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    float height = [self tableView:tableView heightForHeaderInSection:section];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, height)];

    return [view autorelease];
}

@end

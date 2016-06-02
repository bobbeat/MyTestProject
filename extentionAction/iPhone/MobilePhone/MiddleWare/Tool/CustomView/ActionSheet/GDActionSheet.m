//
//  GDActionSheet.m
//  AutoNavi
//
//  Created by huang longfeng on 13-8-21.
//
//

#import "GDActionSheet.h"

Class object_getClass(id object);

static UIWindow *g_window = nil;
static UIWindowLevel Action_UIWindowLevelSIAlert = 1999.0;  // 不覆盖系统警告

@interface GDActionSheetViewController : UIViewController
{
    GDActionSheet *_actionSheet;
@public
    UIView *_actionView;
}
@property (nonatomic) BOOL isSupportAutorotate;

@end

@implementation GDActionSheetViewController
@synthesize isSupportAutorotate;
- (void)viewDidLoad
{
    
}

- (void)setDelegate:(id)delegate
{
    
}

- (void)start
{
    
}

- (void)stop
{
    
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [_actionView setFrame:self.view.bounds];
}

- (BOOL)shouldAutorotate
{
    if (isSupportAutorotate) {
        return NO;
    }
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationUnknown) {
        return YES;
    }
//    if (!OrientationSwitch)
//    {
//        return NO;
//    }
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if (isSupportAutorotate) {
        return NO;
    }
    if (!OrientationSwitch)
    {
        return (Orientation == interfaceOrientation);
    }
	return  YES;
    
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationUnknown) {
        [[MWPreference sharedInstance] loadPreference];
    }
    
    if ([[ANParamValue sharedInstance] bSupportAutorate] == NO)
    {
        return  UIInterfaceOrientationMaskPortrait;
    }
    else{
        if (!OrientationSwitch){
            return (1<<[[UIApplication sharedApplication] statusBarOrientation]);
        }
        return  UIInterfaceOrientationMaskAll;
    }
}

@end

@interface GDActionSheet()
{
    UITableView *m_tableView;
    UIView      *_blockerView;
    UIView *_actionSuperView;
    GDActionSheetViewController *ctl;
}

@property (nonatomic,assign) UITableViewStyle customType;
@property (nonatomic,copy) NSMutableString *titleString;
@property (nonatomic,retain) NSMutableArray *destrucArray;
@property (nonatomic,retain) NSMutableArray *cancelArray;
@property (nonatomic,retain) NSMutableArray *otherArray;
@property (nonatomic,retain) NSMutableArray *section0Array;
@property (nonatomic,assign) Class originalClass;

@end

@implementation GDActionSheet
@synthesize isSupportAutorotate;
@synthesize cancelArray,otherArray,destrucArray,delegate,titleString,section0Array,tag,originalClass;

- (id)initWithTitle:titleT delegate:(id)delegate1 cancelButtonTitle:(NSString *)cancelString destructiveButtonTitle:(NSString *)destrucString otherButtonTitles:(NSString*)other,...
{
    if (g_window)
    {
        [_actionSuperView removeFromSuperview];
        [g_window release];
        g_window = nil;
    }
    self = [super init];
    if (self)
    {
       ctl = [[GDActionSheetViewController alloc] init];
        isSupportAutorotate=NO;
        g_window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        g_window.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        g_window.opaque = NO;
        g_window.windowLevel = Action_UIWindowLevelSIAlert;
        g_window.rootViewController = ctl;
        g_window.hidden = NO;
        [ctl release];
        
        _actionSuperView = ctl.view;
        ctl->_actionView = self;
        
        self.cancelArray = [NSMutableArray array];
        self.destrucArray = [NSMutableArray array];
        self.otherArray = [NSMutableArray array];
        self.section0Array = [NSMutableArray array];
        self.delegate = delegate1;
        self.originalClass = object_getClass(delegate1);
        if (titleT) {
            titleString = [titleT mutableCopy];
            
            [self.section0Array addObject:titleT];
        }
        
        
        va_list list;
        va_start(list, other);
        NSString *string=other;//va_arg(list, (NSString*));
        while (string) {
            [self.otherArray addObject:string];
            [self.section0Array addObject:string];
            string= va_arg(list,NSString*);
        }
        if (cancelString) {
            [self.cancelArray addObject:cancelString];
        }
        if (destrucString) {
            [self.destrucArray addObject:destrucString];
            [self.section0Array addObject:destrucString];
        }
        
        [self initControl];
    }
    return self;
}
-(void)setIsSupportAutorotate:(BOOL)_isSupportAutorotate
{
//    isSupportAutorotate=_isSupportAutorotate;
    ctl.isSupportAutorotate=_isSupportAutorotate;
    
}
- (void)initControl
{
    self.hidden = YES;
    self.frame = _actionSuperView.bounds;
    [_actionSuperView addSubview:self];
    
    _blockerView = [[UIView alloc] initWithFrame:self.bounds];
    _blockerView.backgroundColor = [UIColor colorWithWhite: 0.0 alpha: 0.7];
//    _blockerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _blockerView.userInteractionEnabled = YES;
    [self addSubview: _blockerView];
    [_blockerView release];_blockerView.alpha = 0.0;
    _blockerView.hidden = YES;
    
    m_tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    m_tableView.delegate = self;
    m_tableView.dataSource = self;
    m_tableView.scrollEnabled = NO;
    m_tableView.backgroundColor = [UIColor clearColor];
    if ([UITableView instancesRespondToSelector:@selector(backgroundView)])
    {
        m_tableView.backgroundView = nil;
    }
    [self addSubview:m_tableView];
    [m_tableView release];
}

- (void)ShowOrHiddenActionSheet:(BOOL)show Animation:(BOOL)animation
{
    CGSize size = self.bounds.size;
    float oriHeight = 0.0;
    if (self.cancelArray && self.cancelArray.count > 0) {
        if (self.titleString) {
            oriHeight = (self.section0Array.count)*44+65;
        }
        else{
            oriHeight = (self.section0Array.count + 1)*44+20;
        }
        
    }
    else{
        if (self.titleString) {
            oriHeight = self.section0Array.count*44;
        }
        else{
            oriHeight = self.section0Array.count*44+15;
        }
        
    }
    
    if (show)
    {
        if (self.hidden == NO)
        {
            return;
        }
        _blockerView.hidden = NO;
        _blockerView.alpha = 0.0;
        self.hidden = NO;
        if (YES == animation)
        {
            CGRect frame = CGRectMake(-5, size.height, size.width+10, size.height);
            [m_tableView setFrame:frame];
            
            [UIView animateWithDuration:0.3f animations:^
             {
                 _blockerView.alpha = 0.7;
                
                 CGRect frame = CGRectMake(-5, size.height-oriHeight, size.width+10, size.height);
                 [m_tableView setFrame:frame];
                 [m_tableView reloadData];
                 
             }
                             completion:^(BOOL finished)
             {
                 
             }];
        }
        else{
            CGRect frame = CGRectMake(-5, size.height-oriHeight, size.width+10, size.height);
            [m_tableView setFrame:frame];
            [m_tableView reloadData];
            _blockerView.alpha = 0.7;
        }
    }
    else
    {
        if (self.hidden == YES)
        {
            return;
        }
        
        if (YES == animation) {
            _blockerView.alpha = 0.7;
           
            [UIView animateWithDuration:0.5f animations:^
             {
                 _blockerView.alpha = 0.0;
                 CGRect frame = CGRectMake(-5, size.height, size.width+10, size.height);
                 [m_tableView setFrame:frame];
             }
                             completion:^(BOOL finished)
             {
                 if (g_window)
                 {
                     [_actionSuperView removeFromSuperview];
                     [g_window release];
                     g_window = nil;
                 }
             }];
        }
        else{
            if (g_window)
            {
                [_actionSuperView removeFromSuperview];
                [g_window release];
                g_window = nil;
            }
        }
        
    }
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    CGSize size = frame.size;
    
    float oriHeight = 0.0;
    if (self.cancelArray && self.cancelArray.count > 0) {
        if (self.titleString) {
            oriHeight = (self.section0Array.count)*44+65;
        }
        else{
            oriHeight = (self.section0Array.count + 1)*44+20;
        }
        
    }
    else{
        if (self.titleString) {
            oriHeight = self.section0Array.count*44;
        }
        else{
            oriHeight = self.section0Array.count*44+15;
        }
        
    }

    frame = CGRectMake(-5, size.height-oriHeight, size.width+10, size.height);
    [m_tableView setFrame:frame];
    
    [_blockerView setFrame:CGRectMake(0.0, 0.0, size.width, size.height)];
}

- (void)addOtherButton:(NSString *)otherString
{
    [self.otherArray addObject:otherString];
    [self.section0Array addObject:otherString];
}

- (void)dealloc
{
    if (section0Array) {
        [section0Array release];
        section0Array = nil;
    }
    if (titleString) {
        [titleString release];
        titleString = nil;
    }
    if (cancelArray) {
        [cancelArray release];
        cancelArray = nil;
    }
    if (otherArray) {
        [otherArray release];
        otherArray = nil;
    }
    if (destrucArray) {
        [destrucArray release];
        destrucArray = nil;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}
#pragma mark tableview
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.cancelArray && self.cancelArray.count > 0) {
        return 2;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    if (section == 0) {
        return self.section0Array ? self.section0Array.count : 0;
    }
    else{
        return 1;
    }
	
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        
    }
    cell.backgroundColor = [UIColor colorWithRed:0.960784F green:0.960784F blue:0.960784F alpha:1.0F];
    cell.textLabel.textAlignment = UITextAlignmentCenter;

    
    if (indexPath.section == 0) {
        
        if (indexPath.row == 0 && self.titleString) {//标题
            cell.textLabel.text = self.titleString;
            cell.textLabel.textColor = [UIColor colorWithRed:0.541176F green:0.541176F blue:0.541176F alpha:1.0F];
            cell.textLabel.font = [UIFont systemFontOfSize:13.0];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        else if (indexPath.row == (self.section0Array.count -1) && self.destrucArray.count > 0){//destruc按钮
            cell.textLabel.text = [self.destrucArray objectAtIndex:indexPath.row];
            cell.textLabel.textColor = [UIColor colorWithRed:0.000000F green:0.478431F blue:1.000000F alpha:1.0F];
            cell.textLabel.font = [UIFont systemFontOfSize:kSize1];
        }
        else{//其他
            cell.textLabel.text = [self.section0Array objectAtIndex:indexPath.row];
            cell.textLabel.textColor = [UIColor colorWithRed:0.000000F green:0.478431F blue:1.000000F alpha:1.0F];
            cell.textLabel.font = [UIFont systemFontOfSize:kSize1];
        }
    }
    else{
        cell.textLabel.text = self.cancelArray.count > 0 ? [self.cancelArray objectAtIndex:0] : @"";
        cell.textLabel.font = [UIFont boldSystemFontOfSize:kSize1];
        cell.textLabel.textColor = [UIColor colorWithRed:0.000000F green:0.478431F blue:1.000000F alpha:1.0F];;
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
{
	
    return nil;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.titleString && indexPath.section == 0 && indexPath.row == 0) {
        return 49.;
    }
	return 44.;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section

{
    
    return 3;
    
}


- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section

{
    
    return [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section

{
    
    return 1;
    
}


- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section

{
    UIView *view = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
    view.backgroundColor = [UIColor clearColor];
    return view;
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    Class currentClass = object_getClass(self.delegate);
    if (currentClass == self.originalClass)
    {
        if (indexPath.section == 0) {
            if (self.titleString && [self.titleString length] > 0 ) {
                if (indexPath.row > 0 && delegate && [delegate respondsToSelector:@selector(GDActionSheet:clickedButtonAtIndex:)]) {
                    [delegate GDActionSheet:self clickedButtonAtIndex:indexPath.row-1];
                }
            }
            else{
                if (delegate && [delegate respondsToSelector:@selector(GDActionSheet:clickedButtonAtIndex:)]) {
                    [delegate GDActionSheet:self clickedButtonAtIndex:indexPath.row];
                }
            }
        }
        else{
            if (self.titleString && [self.titleString length] > 0 && indexPath.row > 0) {
                if (delegate && [delegate respondsToSelector:@selector(GDActionSheet:clickedButtonAtIndex:)]) {
                    [delegate GDActionSheet:self clickedButtonAtIndex:([tableView numberOfRowsInSection:0]-1+indexPath.row)];
                }
            }
            else{
                if (delegate && [delegate respondsToSelector:@selector(GDActionSheet:clickedButtonAtIndex:)]) {
                    [delegate GDActionSheet:self clickedButtonAtIndex:([tableView numberOfRowsInSection:0]+indexPath.row)];
                }
            }
            
        }
        
    }
    else
    {
        NSLog(@"delegate dealloc");
    }
    
   
	
    [m_tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self ShowOrHiddenActionSheet:NO Animation:YES];
}
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
	
}


@end

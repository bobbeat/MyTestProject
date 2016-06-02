//
//  AccountTextFieldListener.m
//  AutoNavi
//
//  Created by gaozhimin on 13-9-22.
//
//

#import "AccountTextFieldListener.h"

static AccountTextFieldListener *g_listener = nil;
static UITableView *g_notifyTableView = nil;
static int g_heightOffSet = 0;

@interface AccountTextFieldListener()
{
    BOOL _existKeyBorad;    //是否存在键盘
    ListenerType listenerType;
}

@property (nonatomic,assign)  ListenerType listenerType;

@end

@implementation AccountTextFieldListener

@synthesize listenerType;

+ (id)startAccountTextFieldListner
{
    if (isPad)
    {
        return nil;
    }
    if (g_listener == nil)
    {
        g_listener = [[AccountTextFieldListener alloc] init];
    }
    g_listener.listenerType = ListenerType_changeBounds;
    return g_listener;
}

+ (id)startAccountTextFieldListner:(ListenerType)Type
{
    if (isPad)
    {
        return nil;
    }
    if (g_listener == nil)
    {
        g_listener = [[AccountTextFieldListener alloc] init];
    }
    g_listener.listenerType = Type;
    return g_listener;
}

+ (void)StopAccountTextFieldListner
{
    if (g_listener)
    {
        [g_listener release];
        g_listener = nil;
    }
}

- (void)dealloc
{
    g_notifyTableView = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self)
    {
        [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(textFieldBeginEditing:) name: UITextFieldTextDidBeginEditingNotification object: nil];
        [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(textFieldEndEditing:) name: UITextFieldTextDidEndEditingNotification object: nil];
        
        [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(textFieldBeginEditing:) name: UITextViewTextDidBeginEditingNotification object: nil];
        [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(textFieldEndEditing:) name: UITextViewTextDidEndEditingNotification object: nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeOrientation:) name:UIDeviceOrientationDidChangeNotification object:nil];
    }
    return self;
}

- (void)changeOrientation:(NSNotification *)notification
{
    UIInterfaceOrientation toInterfaceOrientation;
    NSDictionary *userInfo = [notification userInfo];
    toInterfaceOrientation = [[userInfo objectForKey:@"UIDeviceOrientationRotateAnimatedUserInfoKey"] integerValue];
    if ((toInterfaceOrientation == UIDeviceOrientationFaceUp)
        || (toInterfaceOrientation == UIDeviceOrientationFaceDown)
        || (toInterfaceOrientation == UIDeviceOrientationUnknown)) {
        return;
    }
    if (!_existKeyBorad)
    {
        return;
    }
    if (toInterfaceOrientation == UIDeviceOrientationPortrait || toInterfaceOrientation == UIDeviceOrientationPortraitUpsideDown)
    {
        UITableView *tableView = g_notifyTableView;
        CGRect rect = tableView.frame;
        CGRect super_rect = tableView.superview.frame;
        CGRect table_rect = rect;
        
        if (Interface_Flag == 0)  //竖屏
        {
            table_rect = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, super_rect.size.height - 216 - rect.origin.y);
        }
        else
        {
            table_rect = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, super_rect.size.height - 161 - rect.origin.y);
        }
        
        if (listenerType == ListenerType_changeBounds)
        {
            [tableView setFrame:table_rect];
        }
        
        if (g_heightOffSet + 10 > table_rect.size.height)
        {
            [(UITableView *)tableView setContentOffset:CGPointMake(0, g_heightOffSet - 10) animated:YES];
        }
    }
}

- (void)textFieldBeginEditing:(NSNotification *)notification
{
    NSObject* obj = [notification object];
    if ([obj isKindOfClass:[UITextField class]] || [obj isKindOfClass:[UITextView class]])
    {
        UIView *superView = (UIView *)obj;
        UIView *tableView = nil;
        UITableViewCell *tableViewCell = nil;

        while (superView)
        {
            superView = superView.superview;
            if ([superView isKindOfClass:[UITableView class]])
            {
                tableView = superView;
                superView = nil;
            }
            if ([superView isKindOfClass:[UITableViewCell class]])
            {
                tableViewCell = (UITableViewCell *)superView;
            }
        }
        int heightOffSet = 0;
        if (tableViewCell)
        {
            heightOffSet = tableViewCell.frame.origin.y;
        }
        g_heightOffSet = heightOffSet;
        if ([tableView isKindOfClass:[UITableView class]])
        {
            _existKeyBorad = YES;
            g_notifyTableView = (UITableView *)tableView;
            CGRect rect = tableView.frame;
            CGRect super_rect = tableView.superview.frame;
            CGRect table_rect = rect;
            
            if (Interface_Flag == 0)  //竖屏
            {
                table_rect = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, super_rect.size.height - 216 - rect.origin.y);
            }
            else
            {
                table_rect = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, super_rect.size.height - 161 - rect.origin.y);
            }
            
            if (listenerType == ListenerType_changeBounds)
            {
                [tableView setFrame:table_rect];
            }
            
            if (heightOffSet + 10 > table_rect.size.height)
            {
                [(UITableView *)tableView setContentOffset:CGPointMake(0, heightOffSet - 10) animated:YES];
            }
            
        }
    }
    
    
}

- (void)textFieldEndEditing:(NSNotification *)notification
{
    NSObject* obj = [notification object];
    if ([obj isKindOfClass:[UITextField class]] || [obj isKindOfClass:[UITextView class]])
    {
        UIView *superView = (UIView *)obj;
        UIView *tableView = nil;
        while (superView)
        {
            superView = superView.superview;
            if ([superView isKindOfClass:[UITableView class]])
            {
                tableView = superView;
                superView = nil;
            }
        }
        
        if ([tableView isKindOfClass:[UITableView class]])
        {
            _existKeyBorad = NO;
            
            if (listenerType == ListenerType_changeBounds)
            {
                __block UITableView *blockTable = (UITableView *)tableView;
                double delayInSeconds = 0.1;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    if (!_existKeyBorad)
                    {
                        CGRect rect = tableView.frame;
                        CGRect super_rect = tableView.superview.frame;
                        CGRect table_rect = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, super_rect.size.height - rect.origin.y);
                        [blockTable setFrame:table_rect];
                    }
                });
            }
        }
    }
}

@end

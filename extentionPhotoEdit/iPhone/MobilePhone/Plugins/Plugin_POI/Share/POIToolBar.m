//
//  POIToolBar.m
//  AutoNavi
//
//  Created by huang on 13-9-10.
//
//

#import "POIToolBar.h"
#import "POIDefine.h"
@interface POIToolBar ()
{
    UIButton *_buttonHighlighted;   //当前哪个按钮高亮
    BOOL isCanAction;               //判断是否可以移动
}

@end

@implementation POIToolBar

-(id)initWithView:(UIView*)superView withHighlighted:(int)whichOne withButtons:(UIButton*)buttons,...
{
    self=[super init];
    if (self) {
        
        va_list list;
        va_start(list, buttons);
        if (buttons==nil) {
            NSLog(@"没有按钮");
            return self;
        }
        else
        {
            _buttonArray=[[NSMutableArray alloc] init];
            UIButton *newButton=buttons;
            while (newButton) {
                [_buttonArray addObject:newButton];
                [newButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
                newButton=va_arg(list,UIButton*);
            }
            _buttonHighlighted=nil;
            if (whichOne>_buttonArray.count) {
                whichOne=0;
            }
            UIButton *button=[_buttonArray objectAtIndex:whichOne];
            isCanAction=NO;
            _viewAction=[[UIView alloc] init];
            [_viewAction setBackgroundColor:GETSKINCOLOR(@"ToolBarSliderColor")];//191  50 56
            if (superView) {
                isCanAction=YES;
                [superView addSubview:_viewAction];
            }
            [_viewAction release];
            [self buttonAction:button];
            [self moveWithButton:button];
    
        }
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationReceived:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
        
    }
    return self;

}


//Highlighted
-(void)notificationReceived:(NSNotification*)notification
{
    if ([notification.name isEqualToString: UIApplicationDidChangeStatusBarOrientationNotification]) {

        [self refresh];
        return;
    }
}
-(void)refresh
{
   // float y=_type==POITOOLBAR_IN_BUTTON_HEAD?0:CGRectGetHeight(_buttonHighlighted.frame)+CGRectGetMidY(_buttonHighlighted.frame);
    float y=_type ==POITOOLBAR_IN_BUTTON_HEAD?0:_buttonHighlighted.frame.size.height -2;
    CGRect rect  =_buttonHighlighted.frame;
    rect.origin.y=y;
    rect.size.height=2;
   // rect.size.width = _buttonHighlighted.frame.size.width /2;
    if (_type==POITOOLBAR_IN_BUTTON_NO)
    {
         rect.size.height=0;
    }
    _viewAction.frame =rect;
//    if (rect.origin.x==0) {
//        _viewAction.frame = CGRectMake(30, rect.origin.y-1.5, rect.size.width-2*30, rect.size.height);
//    }else
//    {
//        _viewAction.frame = CGRectMake(30+rect.size.width, rect.origin.y-1.5, rect.size.width-2*30, rect.size.height);
//    }
    //_viewAction.frame=rect;
    //_viewAction.frame = CGRectMake(40, rect.origin.y -3, rect.size.width-2*40, rect.size.height);
}
-(void)buttonAction:(UIButton*)button
{
    if (_buttonHighlighted) {
        _buttonHighlighted.enabled=YES;
    }
        button.enabled=NO;
    _buttonHighlighted=button;
//    UIButton *buttonLast=button;

//   __block UIButton *currentButton=_buttonHighlighted;
//    if(currentButton)
//    {
//        if (currentButton!=buttonLast) {
//            [currentButton setHighlighted:NO];
//            currentButton=buttonLast;
//        }
//       
//    }
//    else
//    {
//        currentButton=buttonLast;
//    }
//    _buttonHighlighted=button;
//    double delayInSeconds = 0.1;
//    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//        [currentButton setHighlighted:YES];
//    });
    [self moveWithButton:_buttonHighlighted];
}
-(void)moveWithButton:(UIButton*)button
{
    if (isCanAction) {
        __block UIView *view=_viewAction;
         float y=_type ==POITOOLBAR_IN_BUTTON_HEAD?0:_buttonHighlighted.frame.size.height -2;
        //float y=_type==POITOOLBAR_IN_BUTTON_HEAD?0:CGRectGetHeight(button.frame)+CGRectGetMidY(button.frame);
        CGRect rect  =button.frame;
        rect.origin.y=y;
        rect.size.height=2;
        if (_type==POITOOLBAR_IN_BUTTON_NO)
        {
            rect.size.height=0;
        }
      //  rect.size.width = _buttonHighlighted.frame.size.width /2;

        [UIView animateWithDuration:0.08 animations:^{
            view.frame=rect;
//            if (rect.origin.x==0) {
//                _viewAction.frame = CGRectMake(30, rect.origin.y-1.5, rect.size.width-2*30, rect.size.height);
//            }else
//            {
//                _viewAction.frame = CGRectMake(30+rect.size.width, rect.origin.y-1.5, rect.size.width-2*30, rect.size.height);
//            }
            
        }];
    }
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    CRELEASE(_buttonArray);
    CLOG_DEALLOC(self);
    [super dealloc];
    
}
@end

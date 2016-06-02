//
//  POIGoHomeAndCompany.m
//  AutoNavi
//
//  Created by huang on 13-8-27.
//
//

#import "POIRouteCalculation.h"
#import "GDBL_typedef.h"
#import "MWMapOperator.h"
#import "ANOperateMethod.h"
#import "POIDefine.h"
#import "PluginStrategy.h"

@interface POIViewControllerManager : NSObject

@end

static POIViewControllerManager *g_POIViewControllerManager = nil;

@implementation POIViewControllerManager

+ (instancetype)SharedInstance
{
    if (g_POIViewControllerManager == nil)
    {
        g_POIViewControllerManager = [[POIViewControllerManager alloc] init];
    }
    return g_POIViewControllerManager;
}

- (void)popToRootControllerWith:(UIViewController *)ModalViewController animated:(BOOL)animated
{
    if (ModalViewController == nil)
    {
        return;
    }
    if ([[[ModalViewController class] description] isEqualToString:@"ParentViewController"])
    {
        [[PluginStrategy sharedInstance] allocModuleWithName:@"Plugin_Main" withObject:@{@"controller":ModalViewController,@"parma":@"RoutePlanningAndDetailViewController",@"animate":@(animated)}];
        return;
    }
    
    __block UIViewController *presentingViewController = ModalViewController.presentingViewController;
    [ModalViewController dismissViewControllerAnimated:NO completion:^{
        [self popToRootControllerWith:presentingViewController animated:animated];
    }];
}

@end

@interface POIRouteCalculation ()<RouteCalDelegate>
{
    BOOL animate;
}
@end




@implementation POIRouteCalculation
@synthesize delegate;

-(id)initWithViewController:(UIViewController*)viewController
{
    self=[super init];
    if (self) {
  
        if (viewController==nil) {
            NSLog(@"没有传入 UINavigationController");
            return self;
        }
        animate=YES;
        self.viewController=viewController;

    }
    return self;
}
-(void)setViewController:(UIViewController *)viewController
{
    if (viewController==nil) {
        _viewController=nil;
        _viewControllerCount=0;
        return;
    }
    _viewController=viewController;
    _viewControllerCount=[_viewController.navigationController.viewControllers count];
}
-(void)gotoNavigationWithArray:(NSMutableArray *)array
{
    if (!_viewController.navigationController) {
        return;
    }
    [MWRouteCalculate setDelegate:self];
    [MWRouteCalculate wayPointCalcRoute:array bResetCarPosition:YES];
}
-(void)goHome
{
    if (!_viewController.navigationController) {
        return;
    }
    [MWRouteCalculate setDelegate:self];
    [MWRouteCalculate GoHome];
}
-(void)goCompany
{
    if (!_viewController.navigationController) {
        return;
    }
    [MWRouteCalculate setDelegate:self];
    [MWRouteCalculate GoCompany];
}
static bool isSuccess = NO;
- (void)RouteCalResult:(GSTATUS)result guideType:(long)guideType calType:(GCALROUTETYPE)calType
{
    if (calType == GROU_CAL_MULTI)//单路径
    {
        if([ANParamValue sharedInstance].isRequestParking != 2)
        {
            [ANParamValue sharedInstance].isRequestParking = 1;
        }
        if (result == 0)
        {
            if (self.modalViewController)
            {
                [[POIViewControllerManager SharedInstance] popToRootControllerWith:self.modalViewController animated:animate];
            }
            else
            {
                //modify by wws for 代理解决 添加途经点一直循环的问题 at 2017-7-24
                if (self.delegate && [self.delegate respondsToSelector:@selector(poiDeleteControlViewController)]) {
                    [self.delegate poiDeleteControlViewController];
                }
                if (_viewController.navigationController) {
                    [[PluginStrategy sharedInstance] allocModuleWithName:@"Plugin_Main" withObject:@{@"controller":_viewController.navigationController,@"parma":@"RoutePlanningAndDetailViewController",@"animate":@(NO)}];
                }
            }
        }
        else
        {
            if (self.delegate && [self.delegate respondsToSelector:@selector(poiDeleteControlViewController)]) {
                [self.delegate poiDeleteControlViewController];
            }
            if([[ANParamValue sharedInstance] isPath])
            {
                [MWRouteGuide GuidanceOperateWithMainID:1 GuideHandle:NULL];
            }
            if (result == GD_ERR_TOO_NEAR||result ==GD_ERR_NO_DATA||result ==GD_ERR_NO_ROUTE ) //距离过近不需要提示演算失败，因为已提示了距离太近
            {
                NSLog(@"不提示 起点终点距离太近，无法规划路径，无相关数据，没有引导路径 ");
            }else
            {
                GDAlertView *alertView=[[[GDAlertView alloc] initWithTitle:nil andMessage:STR(@"POI_RotueCalculationFail",Localize_POI)] autorelease];
                [alertView addButtonWithTitle:STR(@"POI_Back",Localize_POI) type:GDAlertViewButtonTypeCancel handler:^(GDAlertView *alert)
                 {
                     
                 }];
                [alertView show];
            }
        }
    }
}

-(void)setBourn:(MWPoi*)poi
{
    [self setBourn:poi withAnimate:YES];
}
-(void)setBourn:(MWPoi *)poi withAnimate:(BOOL)_animate
{
    if (poi) {
        [MWRouteCalculate setDelegate:self];
        animate=_animate;
        GPOI gPoi = {0};
        [MWPoiOperator MWPoiToGPoi:poi GPoi:&gPoi];
        [MWRouteCalculate setDesWithPoi:gPoi poiType:GJOURNEY_GOAL calType:GROU_CAL_MULTI];
    }
}
-(void)dealloc
{
    _viewController=nil;
    self.delegate = nil;
    CLOG_DEALLOC(self);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

@end

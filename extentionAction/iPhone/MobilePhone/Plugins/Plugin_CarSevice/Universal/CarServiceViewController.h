//
//  CarServiceViewController.h
//  AutoNavi
//
//  Created by jiangshu-fu on 14-3-7.
//
//

#import "ANViewController.h"

@class CarServiceJavascriptBridge;
@class MWCarOwnerServiceTask;

@interface CarServiceViewController : ANViewController <UIWebViewDelegate,UIActionSheetDelegate,NetReqToViewCtrDelegate,GDActionSheetDelegate,UIAlertViewDelegate>
{
    UIWebView *_webViewWeather;
    //滑动界面设置
    UIScrollView *_scrollerViewItems;
    NSMutableArray *_arrayCarServices;
    CarServiceJavascriptBridge *_carserviceJavascriptBridege;
    
    //低栏的提示框
    UIImageView *_imageViewTips;
    //文字
    UILabel *_labelTips;
    //按钮
    UIButton *_buttonClose;
    
    MWCarOwnerServiceTask *_longPressTask;
    CarServiceViewController *_carPressController;
    //后退按钮，刷新按钮
    UIButton *_buttonBack;
    UIButton *_buttonReload;
    
    //判断是否从登入界面跳转回来的界面
    __block BOOL _isFromLoginInView;
    
    //是否要进行刷新
    BOOL _isRefresh;
    
    //是否点击了更多按钮
    BOOL _isClickMore;
    
    //网页请求失败，显示失败页面~ 再请求失败，就不再请求
    BOOL _isRequestFail;
    
    //是否正在重新加载页面
    BOOL _isReloadCarServiceItem;
    
    //是否进入了该界面，即，显示该界面
    BOOL _isViewAppear;
    
    
    //web页面是否正在请求，正在请求中就不进行请求
    BOOL _isRequestWeb;
}
@end

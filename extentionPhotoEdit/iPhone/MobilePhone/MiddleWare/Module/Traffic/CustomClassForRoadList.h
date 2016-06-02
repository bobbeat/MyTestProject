//
//  CustomClassForRoadList.h
//  AutoNavi
//
//  Created by liyuhang on 12-12-11.
//
//

#import <UIKit/UIKit.h>
//
/*
 自定义路线详情界面的列表单元格
 */
enum Position{
    kRoadNameOffset = 22,         // 一 道路名左移
    kDisOffset = 70,              // 二 距离显示（70） 中间左移动30开始显示
    kDirectionImageSize = 30,     // 三 道路方向位置，根据箭头长度的一半
    kDetourBtnSize = 25,          // 四 规避按钮，在三的基础上
};
@protocol CustomCellForRoadListDelegate<NSObject>
-(void) CustomCellForRoadListHandlebCheck:(BOOL) bCheck atIndex:(int) nIndex ;
@end
//
@interface CustomCellForRoadList : UITableViewCell
{
    UIImageView *m_imageViewArrow;
    UIImageView *m_imgViewTopArrow;  // 在顶部也加一个
    UIImageView *m_imageViewDirection;
    UIImageView *m_imageViewCar;
    UILabel *m_lableDis;
    UILabel *m_lableRoad;
    UIButton *m_buttonSelect;
    //
    BOOL m_bSelect;
    //
    BOOL m_bShowSelectButtton;
    //
    id<CustomCellForRoadListDelegate> m_delegate;
    //
    int m_nIndexInTableView;
}
@property (nonatomic,readonly) UIImageView *psImageViewCar;
@property (nonatomic,readonly) UIImageView *psImgViewTopArrow;
@property (nonatomic,readonly) UIImageView *m_imageViewArrow;
@property (nonatomic,readonly) UIImageView *m_imageViewDirection;
@property (nonatomic,readonly) UILabel *m_lableDis;
@property (nonatomic,readonly) UILabel *m_lableRoad;
@property (nonatomic,readonly) UIButton *m_buttonSelect;
@property (nonatomic,assign) BOOL m_bSelect;
@property (nonatomic, assign) BOOL m_bShowSelectButtton;
@property (nonatomic,assign) int m_nIndexInTableView;
@property (nonatomic,retain) id<CustomCellForRoadListDelegate> m_delegate;
@end

/*
 
 路线详情界面交通情况分布
 
 */

@interface TraficStatusForRoutes : UIView
{
    //
    CGRect m_rcVerticalFrame;
    CGRect m_rcHorizontalFrame;
    //
    UIImageView *m_imgBackGround;
    //
    UIImageView *m_imageDestination;
    UIImageView *m_imageCar;
    //
    UIImageView *m_imageGrayComponent;
    UIImageView *m_imageYellowComponent;
    UIImageView *m_imageRedComponent;
    UIImageView *m_imageGreenComponent;
    //
    float m_fGrayComponent;
    float m_fYellowComponent;
    float m_fRedComponent;
    float m_fGreenComponent;
    //
    int m_nOrientationOfSubviews; // 0 竖直排列；1 横向排列
    //
    float m_fwideForCarImage;
}
@property (nonatomic, assign) float psfWideForCarImage;
-(id)initWithGrayComponet:(float)fGray YellowComponent:(float)fYellow RedComponent:(float)fRed GreenComponent:(float)fGreen forIpad:(BOOL)bForIpad;
-(void) setViewFrame:(CGRect)frame;
@end

/*
 自定义路线详情界面的列表单元格
 */
@protocol CustomHeaderForRoadListDelegate;
//
@interface CustomHeaderForRoadList : UIView
{
    UIImageView *m_imageViewArrow;
    UIImageView *m_imgViewTopArrow;  // 在顶部也加一个
    UIImageView *m_imageViewDirection;
    UIImageView *m_imageViewCar;
    UILabel *m_lableDis;
    UILabel *m_lableRoad;
    UIButton *m_buttonSelect;
    UIButton *m_btnDetailInfo;
    // 手势试图
    UIView* m_viewGesture;
    // 分割线
    UIView* m_viewSpearate;
    //
    BOOL m_bSelect;
    //
    BOOL m_bShowSelectButtton;
    //
    BOOL m_bShowDetails;            // 显示子列数据
    id<CustomHeaderForRoadListDelegate> m_delegate;
    //
    int m_nIndexInTableView;
//    enum Position{
//        kRoadNameOffset = 22,         // 一 道路名左移
//        kDisOffset = 70,              // 二 距离显示（70） 中间左移动30开始显示
//        kDirectionImageSize = 30,     // 三 道路方向位置，根据箭头长度的一半
//        kDetourBtnSize = 25,          // 四 规避按钮，在三的基础上
//    };
}
@property (nonatomic,readonly) UIImageView *psImageViewCar;
@property (nonatomic,readonly) UIImageView *psImgViewTopArrow;
@property (nonatomic,readonly) UIImageView *m_imageViewArrow;
@property (nonatomic,readonly) UIImageView *m_imageViewDirection;
@property (nonatomic,readonly) UILabel *m_lableDis;
@property (nonatomic,readonly) UILabel *m_lableRoad;
@property (nonatomic,readonly) UIButton *m_buttonSelect;
@property (nonatomic,readonly) UIButton *psBtnDetailInfo;
@property (nonatomic,assign) BOOL m_bSelect;
@property (nonatomic, assign) BOOL m_bShowSelectButtton;
@property (nonatomic, assign) BOOL psbShowDetails;
@property (nonatomic,assign) int m_nIndexInTableView;
@property (nonatomic,assign) id<CustomHeaderForRoadListDelegate> m_delegate;
-(void)toggleOpenWithUserAction:(BOOL)userAction;
@end


@protocol CustomHeaderForRoadListDelegate<NSObject>

-(void)sectionHeaderView:(CustomHeaderForRoadList*)sectionHeaderView sectionOpened:(NSInteger)section;
-(void)sectionHeaderView:(CustomHeaderForRoadList*)sectionHeaderView sectionClosed:(NSInteger)section;
-(void)clickDetourButton:(BOOL) bCheck atIndex:(int) nIndex ;
@end

//
//  CustomBtn.m
//  AutoNavi
//
//  Created by liyuhang on 12-12-20.
//
//

#import "CustomBtn.h"
#import "ANParamValue.h"
#import "MoveTextLable.h"
#import "MWPreference.h"

@implementation CustomBtn
@synthesize psLabelTitle1 = m_labelTitle1;
@synthesize psLabelTitle2 = m_labelTitle2;
@synthesize psLabelTitle3 = m_labelTitle3;
@synthesize psnLabelNumber = m_nLableNumber;
@synthesize psfOffsetForTitle = m_fOffsetForTitle;
@synthesize psnStyleForThreeLable = m_nStyleForThreeLable;
@synthesize psfOffsetForTitleRight = m_fOffsetForTitleRight;
@synthesize psnHeightOffset = m_nHeightOffSet;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        m_fOffsetForTitle = 0;
        m_fOffsetForTitleRight = 0;
    }
    return self;
}
// 添加带拉伸参数的初始化函数
- (id)createButtonWithTitle:(NSString *)titleT normalImage:(NSString *)normalImage heightedImage:(NSString *)heightedImage tag:(NSInteger)tagN strechParamX:(NSInteger)xParam strechParamY:(NSInteger)yParam 
{
	self = [super initWithFrame:CGRectZero];
    if (self) {
        self.tag = tagN;
        
        if (normalImage != nil)
        {
            UIImage *stretchableButtonImageNormal = [IMAGE(normalImage, IMAGEPATH_TYPE_1) stretchableImageWithLeftCapWidth:xParam topCapHeight:yParam];
            [self setBackgroundImage:stretchableButtonImageNormal  forState:UIControlStateNormal];
            
        }
        
        if (heightedImage != nil)
        {
            UIImage *stretchableButtonImageNormal = [ IMAGE(heightedImage, IMAGEPATH_TYPE_1) stretchableImageWithLeftCapWidth:xParam topCapHeight:yParam];
            [self setBackgroundImage:stretchableButtonImageNormal  forState:UIControlStateHighlighted];
        }
        
        [self setBackgroundColor:[UIColor clearColor]];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        if (titleT != nil)
        {
            [self setTitle:titleT forState:UIControlStateNormal];
        }
    }
	return self;
}
// 添加标题
-(void) setTitleSubViewNumber:(int) nNum        
{
    // 2个或者3个
    for (UIView* view in self.subviews) {
        [view removeFromSuperview];
    }
    m_nLableNumber = nNum;
    m_nStyleForThreeLable = 0;
    //
    m_labelTitle1 = [[MoveTextLable alloc] initWithFrame:CGRectZero];
    [m_labelTitle1 setBackgroundColor:[UIColor clearColor]];
    m_labelTitle1.textAlignment = UITextAlignmentCenter;
    m_labelTitle1.font = [UIFont systemFontOfSize:18.0f];
    m_labelTitle1.textColor = [UIColor whiteColor];
    [self addSubview:m_labelTitle1];
    [m_labelTitle1 release];
    //
    m_labelTitle2 = [[MoveTextLable alloc] initWithFrame:CGRectZero];
    [m_labelTitle2 setBackgroundColor:[UIColor clearColor]];
    m_labelTitle2.textAlignment = UITextAlignmentCenter;
    m_labelTitle2.font = [UIFont systemFontOfSize:18.0f];
    m_labelTitle2.textColor = [UIColor whiteColor];
    [self addSubview:m_labelTitle2];
    [m_labelTitle2 release];
    if(nNum == 3) {
        //
        m_labelTitle3 = [[MoveTextLable alloc] initWithFrame:CGRectZero];
        [m_labelTitle3 setBackgroundColor:[UIColor clearColor]];
        m_labelTitle3.font = [UIFont systemFontOfSize:18.0f];
        m_labelTitle3.textAlignment = UITextAlignmentCenter;
        m_labelTitle3.textColor = [UIColor whiteColor];
        [self addSubview:m_labelTitle3];
        [m_labelTitle3 release];
    }
}

// 设置区域，同时重新设置子区域
-(void) setBtnFrame:(CGRect) rcFrame
{
    float fOffsetEdage = 2.0f;
    [self setFrame:rcFrame];
    if (m_nLableNumber == 2) {
        float fHight = rcFrame.size.height/2;
        [m_labelTitle1 setFrame:CGRectMake(m_fOffsetForTitle, fOffsetEdage, rcFrame.size.width-m_fOffsetForTitle-fOffsetEdage-m_fOffsetForTitleRight, fHight-fOffsetEdage)];
        [m_labelTitle2 setFrame:CGRectMake(m_fOffsetForTitle, fHight, rcFrame.size.width-m_fOffsetForTitle-fOffsetEdage-m_fOffsetForTitleRight, fHight-fOffsetEdage)];
    } else if(m_nLableNumber == 3) {
        if (m_nStyleForThreeLable == 0) {
            float fHight = rcFrame.size.height/3;
            [m_labelTitle1 setFrame:CGRectMake(m_fOffsetForTitle, fOffsetEdage, rcFrame.size.width-m_fOffsetForTitle-fOffsetEdage-m_fOffsetForTitleRight, fHight-fOffsetEdage)];
            [m_labelTitle2 setFrame:CGRectMake(m_fOffsetForTitle, fHight, rcFrame.size.width-m_fOffsetForTitle-fOffsetEdage-m_fOffsetForTitleRight, fHight)];
            [m_labelTitle3 setFrame:CGRectMake(m_fOffsetForTitle, fHight*2, rcFrame.size.width-m_fOffsetForTitle-fOffsetEdage-m_fOffsetForTitleRight, fHight-fOffsetEdage)];
        } else {
            float fHight = rcFrame.size.height/2;
            float fWide = rcFrame.size.width/2;
            [m_labelTitle1 setFrame:CGRectMake(m_fOffsetForTitle, fOffsetEdage, rcFrame.size.width-m_fOffsetForTitle-fOffsetEdage-m_fOffsetForTitleRight, fHight-fOffsetEdage)];
            [m_labelTitle2 setFrame:CGRectMake(m_fOffsetForTitle, fHight, fWide-m_fOffsetForTitle-fOffsetEdage-m_fOffsetForTitleRight, fHight-fOffsetEdage)];
            [m_labelTitle3 setFrame:CGRectMake(fWide+m_fOffsetForTitle, fHight, fWide-m_fOffsetForTitle-fOffsetEdage-m_fOffsetForTitleRight, fHight-fOffsetEdage)];
        }

    }
    if (m_nStyleForThreeLable == 2) {
        float fHight = rcFrame.size.height;
        [m_labelTitle1 setFrame:CGRectMake(fOffsetEdage+m_fOffsetForTitle, fOffsetEdage+m_nHeightOffSet, rcFrame.size.width-m_fOffsetForTitle-fOffsetEdage*2-m_fOffsetForTitleRight, fHight-fOffsetEdage*2)];
    }
}
-(void) setViewHidden:(BOOL)bHidden                                           //  设置视图的隐藏喝显示
{
    // 显示的条件（1 有路径；2 设置开关为开；3 实时交通打开）
    if (!bHidden&&[MWEngineSwitch isTMCOn]&&[[MWPreference sharedInstance] getValue:PREF_TRAFFICMESSAGE]) {
        self.hidden = NO;
    } else {
        self.hidden = YES;
    }
}

@end

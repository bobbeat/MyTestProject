//
//  GDSearchListCell.h
//  AutoNavi
//
//  Created by huang on 13-9-9.
//
//

#import "GDTableViewCell.h"
#import "KeyWordLable.h"

typedef enum
{
    SEARCH_CELL_NO  =0,//什么都没有
    SEARCH_CELL_NAVI=1,//导航功能
    SEARCH_CELL_ADD,   //天假功能
}SEARCH_CELL_TYPE;

typedef enum
{
    SEARCH_CELL_LINE_TYPE_NO = 0,//不存在线
    SEARCH_CELL_LINE_TYPE    = 1,//存在分割线
}SEARCH_LINE_TYPE;

@interface GDsearchButton : UIButton

@property (nonatomic,assign) UITableViewCell *buttonCell;

@end

@interface GDSearchListCell : GDTableViewCell
{

}
@property(nonatomic,assign)KeyWordLable *labelName;
@property(nonatomic,assign)KeyWordLable *labelAddress;
@property(nonatomic,assign)MWPoi *poi;
@property(nonatomic,readonly)GDsearchButton *naviButton;
@property(nonatomic) SEARCH_CELL_TYPE searchType;
@property(nonatomic) SEARCH_LINE_TYPE type;
@property(nonatomic,assign)UIImageView *imageViewButton;
@property(retain,nonatomic)UILabel * labelNaviGation;
@property(retain,nonatomic)UIImageView * imageViewLine;
@end

//
//  AccountPersonalCell.h
//  AutoNavi
//
//  Created by gaozhimin on 14-6-11.
//
//

#import "GDTableViewCell.h"
#import "DringTracksManage.h"

@interface AccountPersonalCell : GDTableViewCell

@property (nonatomic,assign) UILabel *seeMoreLable;

@property (nonatomic,assign) UILabel *numberLable;

@end

@interface AccountTrackRecordCell : GDTableViewCell

- (void)SetTrackInfo:(DrivingInfo *)trackInfo;

@end

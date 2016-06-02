//
// CustomCell.m
//  autonavi
//
//  Created by hlf on 11-11-9.
//  Copyright 2011 autonavi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GDTableViewCell.h"

@protocol CustomCellDelegate <NSObject>

- (void)cellButtonTaped:(id)cell;
- (void)customCellUpdateData:(id)cell;


@end

@interface CustomCell : GDTableViewCell
{
	id<CustomCellDelegate> m_CustomCellDelegate;
	NSString *title;
	UILabel *label;
	UIProgressView	*progressBar;
    UIButton *buttonDownloadStatus;
	UIButton *buttonDelete;
    UIButton *m_updateButton;
    UIImageView*	m_checkImageView;
	BOOL			m_checked;
}

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) UIProgressView *progressBar;
@property (nonatomic, retain) UILabel *label;
@property (nonatomic, retain) UIButton *m_updateButton;
@property (nonatomic, retain) UIButton *buttonDownloadStatus;
@property (nonatomic, retain) UIButton *buttonDelete;
@property (nonatomic, assign) id<CustomCellDelegate> m_CustomCellDelegate;
@property (nonatomic, assign) BOOL checked;
@property (nonatomic, assign) int taskID;
@property (nonatomic, assign) int clickType;
@property (nonatomic, assign) BOOL editStyle;

- (void) setChecked:(BOOL)mChecked edit:(BOOL)edit;

@end

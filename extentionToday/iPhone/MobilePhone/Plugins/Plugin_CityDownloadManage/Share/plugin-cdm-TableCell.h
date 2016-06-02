//
//  FileItemTableCell.m
//  autonavi
//
//  Created by hlf on 11-11-9.
//  Copyright 2011 autonavi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GDTableViewCell.h"

@interface FileItemTableCell : GDTableViewCell
{
	UIImageView*	m_checkImageView;
@private
	
	BOOL			m_checked;
}
@property (nonatomic, retain) UIImageView*	m_checkImageView;
- (void) setChecked:(BOOL)checked;

@end

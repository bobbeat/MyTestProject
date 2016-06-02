//
//  FileItemTableCell.m
//  autonavi
//
//  Created by hlf on 11-11-9.
//  Copyright 2011 autonavi. All rights reserved.
//

#import "plugin-cdm-TableCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation FileItemTableCell
@synthesize m_checkImageView;

+ (Class)layerClass {
    
    return [CAGradientLayer class];
}
- (void) setEditing:(BOOL)editting animated:(BOOL)animated
{
	
	self.selectionStyle = UITableViewCellSelectionStyleNone;
	self.textLabel.backgroundColor = [UIColor clearColor];
	self.detailTextLabel.backgroundColor = [UIColor clearColor];
    self.detailTextLabel.font = [UIFont systemFontOfSize:13.];
    
}
- (void)layoutSubviews
{
	[super layoutSubviews];
	CGRect contentRect = [self.contentView bounds];
	
	CGRect frame = CGRectMake(contentRect.origin.x + 13.0, 8.0, contentRect.size.width, 30.0);
	self.textLabel.frame = frame;
    frame = CGRectMake(contentRect.size.width-120, 8.0, 100.0, 30.0);
    self.detailTextLabel.frame = frame;
    frame = CGRectMake(self.bounds.size.width-38, 12.0, 18.0,18.0);
    self.accessoryView.frame = frame;
}

- (void)dealloc 
{
    [super dealloc];
}

- (void) setChecked:(BOOL)checked 
{
	if (!checked)
	{
		

		
	}
	
	m_checked = checked;
}

@end

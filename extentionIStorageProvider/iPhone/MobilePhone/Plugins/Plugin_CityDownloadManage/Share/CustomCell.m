//
//  CustomCell.m
//  autonavi
//
//  Created by hlf on 11-11-9.
//  Copyright 2011 autonavi. All rights reserved.
//

#import "CustomCell.h"
#import <QuartzCore/QuartzCore.h>
#import "ShadeImageView.h"

@interface CustomCell ()
{
    ShadeImageView *shadeView;
}
@end
@implementation CustomCell

@synthesize checked;
@synthesize title;
@synthesize progressBar;
@synthesize label;
@synthesize m_CustomCellDelegate;
@synthesize m_updateButton;
@synthesize buttonDownloadStatus;
@synthesize buttonDelete;
@synthesize taskID;
@synthesize clickType;
@synthesize editStyle;

+ (Class)layerClass {
    
    return [CAGradientLayer class];
}

- (void)ButtonPressed:(UITapGestureRecognizer *)button;
{
    self.clickType = 0;
    {
        if (self.editingStyle==UITableViewCellEditingStyleDelete) {
            return;
        }
        UIImage *image = (self.checked) ?  IMAGE(@"DownloadStart1.png", IMAGEPATH_TYPE_1) :IMAGE(@"DownloadStop1.png", IMAGEPATH_TYPE_1);
        UIImage *selectImage = (self.checked) ?  IMAGE(@"DownloadStart2.png", IMAGEPATH_TYPE_1) : IMAGE(@"DownloadStop2.png", IMAGEPATH_TYPE_1);
        [buttonDownloadStatus setImage:image forState:UIControlStateNormal];
        [buttonDownloadStatus setImage:selectImage forState:UIControlStateHighlighted];
        
    }
    if ([m_CustomCellDelegate respondsToSelector:@selector(cellButtonTaped:)])
    {
        [m_CustomCellDelegate cellButtonTaped:self];
    }
}

- (void) updateButtonPressed: (UITapGestureRecognizer*) tapgesture
{
    if([m_CustomCellDelegate respondsToSelector:@selector(customCellUpdateData:)])
    {
        [m_CustomCellDelegate customCellUpdateData:self];
    }
    
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
	{
        
        self.backgroundColor = [UIColor clearColor];
		self.textLabel.backgroundColor = [UIColor clearColor];
		self.textLabel.opaque = NO;
		self.textLabel.textColor = GETSKINCOLOR(@"DownloadCellColor");
		self.textLabel.font = [UIFont systemFontOfSize:18.0];
        
        label = [[UILabel alloc] init];
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = UITextAlignmentLeft;
        [self.contentView addSubview:label];
        [label release];
        
        self.m_updateButton = [UIButton buttonWithType:UIButtonTypeCustom];
        m_updateButton.backgroundColor = [UIColor clearColor];
        [m_updateButton setImage:IMAGE(@"Download.png", IMAGEPATH_TYPE_1) forState:UIControlStateNormal];
        UITapGestureRecognizer *tapGesture1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(updateButtonPressed:)];
        [m_updateButton addGestureRecognizer:tapGesture1];
        [tapGesture1 release];
        [m_updateButton setTitle:STR(@"CityDownloadManage_hasupdatedata", Localize_CityDownloadManage) forState:UIControlStateNormal];
        
        [m_updateButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        if (fontType == 2)
        {
            m_updateButton.titleLabel.font = [UIFont systemFontOfSize:16];
        }
        else
        {
            m_updateButton.titleLabel.font = [UIFont systemFontOfSize:17];
        }
        [m_updateButton setTitleEdgeInsets:UIEdgeInsetsMake(0, -30, 0, 30)];
        [m_updateButton setImageEdgeInsets:UIEdgeInsetsMake(0, 50, 0, -50)];
        [self addSubview:m_updateButton];
        m_updateButton.hidden = YES;
        
        buttonDownloadStatus = [UIButton buttonWithType:UIButtonTypeCustom];
        buttonDownloadStatus.backgroundColor = [UIColor clearColor];
        buttonDownloadStatus.titleLabel.backgroundColor = [UIColor clearColor];
        if (fontType == 2)
        {
            buttonDownloadStatus.titleLabel.font = [UIFont systemFontOfSize:14];
        }
        else
        {
            buttonDownloadStatus.titleLabel.font = [UIFont systemFontOfSize:15];
        }
        buttonDownloadStatus.tag = 0;
        [self.contentView addSubview:buttonDownloadStatus];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(ButtonPressed:)];
        [buttonDownloadStatus addGestureRecognizer:tapGesture];
        [tapGesture release];
        
        buttonDelete = [UIButton buttonWithType:UIButtonTypeCustom];
        [buttonDelete setImage:IMAGE(@"POIDeleteAllBtn1.png", IMAGEPATH_TYPE_1) forState:UIControlStateNormal];
        [buttonDelete setImage:IMAGE(@"POIDeleteAllBtn2.png", IMAGEPATH_TYPE_1) forState:UIControlStateHighlighted];
        buttonDelete.backgroundColor = [UIColor clearColor];
        buttonDelete.titleLabel.backgroundColor = [UIColor clearColor];
        buttonDelete.tag = 1;
        [buttonDelete addTarget:self action:@selector(ButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:buttonDelete];buttonDelete.hidden = YES;
		
		progressBar = [[UIProgressView alloc] init];
        progressBar.progressViewStyle = UIProgressViewStyleDefault;
        progressBar.trackImage = IMAGE(@"DownloadProgressTrack.png", IMAGEPATH_TYPE_1);
        if (IOS_7)
        {
            progressBar.progressTintColor = RGBCOLOR(46, 151, 40);
        }
        else
        {
            progressBar.progressImage = IMAGE(@"DownloadProgress.png", IMAGEPATH_TYPE_1);
        }
		[self.contentView addSubview:progressBar];
		[progressBar release];
	}
	return self;
}
-(void)touchImageView:(id)object
{
    [buttonDownloadStatus sendActionsForControlEvents:UIControlEventTouchUpInside];
}
- (void)layoutSubviews
{
	[super layoutSubviews];
	
    CGRect contentRect = [self.contentView bounds];
	
	CGRect frame;
    if (buttonDownloadStatus.hidden) {
        frame = CGRectMake(contentRect.origin.x + 17.0, 17.0, contentRect.size.width-70., 30.0);
    }
    else{
        frame = CGRectMake(contentRect.origin.x + 17.0, 10.0, contentRect.size.width-70., 30.0);
    }
    
	self.textLabel.frame = frame;
	
    frame = CGRectMake(contentRect.origin.x +17.0, 46.0, self.bounds.size.width-185.0, 4.0);
	progressBar.frame = frame;
    
    if (buttonDownloadStatus.hidden) {
        progressBar.hidden = YES;
        frame = CGRectMake( contentRect.origin.x + self.bounds.size.width - 95., 23.0, contentRect.size.width-115.0, 20.0);
    }
    else{
        progressBar.hidden = NO;
        frame = CGRectMake( contentRect.origin.x + self.bounds.size.width - 155., 36.0, contentRect.size.width-115.0, 20.0);
    }
	
	label.frame = frame;
    
    frame = CGRectMake(self.bounds.size.width - 65, 10.0, 60, 40);
    buttonDownloadStatus.frame = frame;
    shadeView.frame=CGRectMake(0, 0, frame.size.width,frame.size.height);
    frame = CGRectMake(contentRect.size.width - 40, 15.0, 40, 40);
    buttonDelete.frame = frame;
    
    frame = CGRectMake(contentRect.size.width - 85, 17.0, 80, 30);
    m_updateButton.frame = frame;
    
	
}

- (void)dealloc
{
    [m_updateButton release];
    m_updateButton = nil;
    [m_checkImageView release];
	m_checkImageView = nil;
	[title release];
    [super dealloc];
}

- (void) setCheckImageViewCenter:(CGPoint)pt alpha:(CGFloat)alpha animated:(BOOL)animated
{
	if (animated)
	{
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationBeginsFromCurrentState:YES];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[UIView setAnimationDuration:0.3];
		
		m_checkImageView.center = pt;
		m_checkImageView.alpha = alpha;
		m_checkImageView.image = nil;
		[UIView commitAnimations];
	}
	else
	{
		m_checkImageView.center = pt;
		m_checkImageView.alpha = alpha;
	}
}

- (void) setEditing:(BOOL)editting animated:(BOOL)animated
{
	if (self.editing == editting)
	{
		return;
	}
	
	[super setEditing:editting animated:animated];
	
	if (editting)
	{

		if (m_checkImageView == nil)
		{
            if (self.taskID == 0) {
                m_checkImageView = [[UIImageView alloc] initWithImage:IMAGE(@"unSelected1.png", IMAGEPATH_TYPE_1)];
            }
            else{
                m_checkImageView = [[UIImageView alloc] initWithImage:IMAGE(@"unSelected.png", IMAGEPATH_TYPE_1)];
            }
			
			[self addSubview:m_checkImageView];
		}
		
		[self setChecked:m_checked edit:editting];
		m_checkImageView.center = CGPointMake(-CGRectGetWidth(m_checkImageView.frame) * 0.5,
											  CGRectGetHeight(self.bounds) * 0.5);
		m_checkImageView.alpha = 0.0;
		[self setCheckImageViewCenter:CGPointMake(24.0, CGRectGetHeight(self.bounds) * 0.5)
								alpha:1.0 animated:animated];
        
	}
	else
	{
		m_checked = NO;
		
		if (m_checkImageView)
		{
			[self setCheckImageViewCenter:CGPointMake(-CGRectGetWidth(m_checkImageView.frame) * 0.5,
													  CGRectGetHeight(self.bounds) * 0.5)
									alpha:0.0
								 animated:animated];
            
		}
	}
}

- (void) setChecked:(BOOL)mChecked edit:(BOOL)edit
{
    
    if (edit) {
        if (mChecked)
        {
            m_checkImageView.image = IMAGE(@"selected.png", IMAGEPATH_TYPE_1);

        }
        else
        {
            if (self.taskID == 0) {
                m_checkImageView.image = IMAGE(@"unSelected1.png", IMAGEPATH_TYPE_1);
            }
            else{
                m_checkImageView.image = IMAGE(@"unSelected.png", IMAGEPATH_TYPE_1);
            }

        }
        m_checked = mChecked;
    }
    else{
        m_checkImageView.image = nil;
    }
	
}
@end

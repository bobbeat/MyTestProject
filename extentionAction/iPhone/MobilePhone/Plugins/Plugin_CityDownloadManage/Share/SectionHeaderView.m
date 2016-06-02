
//
//  SectionHeaderView.h
//  AutoNavi
//
//  Created by huang longfeng on 11-12-14.
//  Copyright 2011 autonavi. All rights reserved.
//

#import "SectionHeaderView.h"
#import <QuartzCore/QuartzCore.h>

@implementation SectionHeaderView


@synthesize titleLabel,sizeLabel, disclosureButton, delegate, section,clickButton,sectionSelect;


+ (Class)layerClass {
    
    return [CAGradientLayer class];
}


-(id)initWithFrame:(CGRect)frame title:(NSString*)title size:(NSString*)totalsize section:(NSInteger)sectionNumber sectionOpen:(BOOL)select delegate:(id <SectionHeaderViewDelegate>)aDelegate {
    
    self = [super initWithFrame:frame];
    
    if (self != nil) {

        delegate = aDelegate;        
        self.userInteractionEnabled = YES;
        
        // Create and configure the title label.
        self.sectionSelect = select;
        section = sectionNumber;
        CGRect titleLabelFrame = self.bounds;
        titleLabelFrame.origin.x += 20.0;
        titleLabelFrame.size.width -= 15.0;
        CGRectInset(titleLabelFrame, 0.0, 5.0);
        titleLabel = [[UILabel alloc] initWithFrame:titleLabelFrame];
        titleLabel.font = [UIFont systemFontOfSize:15.0];
        titleLabel.textColor = GETSKINCOLOR(@"DownloadCellColor");
        titleLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:titleLabel];
		[titleLabel release];
        
		sizeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.size.width-147, 8.0, 100.0, 30.0)];
        sizeLabel.font = [UIFont systemFontOfSize:13.0];
        sizeLabel.textColor = GETSKINCOLOR(@"DownloadCellColor");
        sizeLabel.backgroundColor = [UIColor clearColor];
		 sizeLabel.textAlignment = UITextAlignmentRight;
        [self addSubview:sizeLabel];
        [sizeLabel release];
        
        clickButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        clickButton.frame = CGRectMake(0.0, 0.0, self.bounds.size.width-20,50.0);
		clickButton.backgroundColor = [UIColor clearColor];
        [clickButton addTarget:self action:@selector(toggleOpen:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:clickButton];
        [clickButton release];
        
        // Create and configure the disclosure button.
        disclosureButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        disclosureButton.frame = CGRectMake(self.bounds.size.width-37, 10.0, 18.0,18.0);
		disclosureButton.backgroundColor = [UIColor clearColor];
        
        [disclosureButton addTarget:self action:@selector(sectionOpen:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:disclosureButton];
        [disclosureButton release];
        

		
    }
    
    return self;
}
-(void)layoutSubviews
{
    [super layoutSubviews];
    CGRect contentRect = self.bounds;
	
    
	CGRect frame = CGRectMake(contentRect.size.width-120, 12.0, 100.0, 30.0);
    sizeLabel.frame = frame;
    
    frame = CGRectMake(13., 10.0, contentRect.size.width-100, 30.0);
    titleLabel.frame = frame;
    
    frame = CGRectMake(0.0, 0.0, contentRect.size.width-20,50.0);
    clickButton.frame = frame;
    
    frame = CGRectMake(self.bounds.size.width-48, 6.0, 40.0,40.0);
    disclosureButton.frame = frame;
    
}
-(void)sectionOpen:(id)sender
{

    if ([delegate respondsToSelector:@selector(provinceClick:)]) {
        [delegate provinceClick:section];
    }
    
    self.sectionSelect = !self.sectionSelect;
    if (self.sectionSelect) {
        
        if ([delegate respondsToSelector:@selector(sectionHeaderView:sectionOpened:)]) {
            [delegate sectionHeaderView:self sectionOpened:section];
        }
    }
    else {
        if ([delegate respondsToSelector:@selector(sectionHeaderView:sectionClosed:)]) {
            [delegate sectionHeaderView:self sectionClosed:section];
        }
    }
}

-(IBAction)toggleOpen:(id)sender {
    
    [self toggleOpenWithUserAction:YES];
}


-(void)toggleOpenWithUserAction:(BOOL)userAction {
    
    self.sectionSelect = !self.sectionSelect;
    if (userAction) {
        if (self.sectionSelect) {
			
            if ([delegate respondsToSelector:@selector(sectionHeaderView:sectionOpened:)]) {
                [delegate sectionHeaderView:self sectionOpened:section];
            }
        }
        else {
            if ([delegate respondsToSelector:@selector(sectionHeaderView:sectionClosed:)]) {
                [delegate sectionHeaderView:self sectionClosed:section];
            }
        }

    }
        
}


- (void)dealloc {
    
    [super dealloc];
}


@end

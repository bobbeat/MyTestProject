
//
//  SectionHeaderView.h
//  AutoNavi
//
//  Created by huang longfeng on 11-12-14.
//  Copyright 2011 autonavi. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "GDTableViewCell.h"

@protocol SectionHeaderViewDelegate;


@interface SectionHeaderView : GDTableViewCell {
}

@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UILabel *sizeLabel;
@property (nonatomic, retain) UIButton *disclosureButton;
@property (nonatomic, retain) UIButton *clickButton;
@property (nonatomic, assign) NSInteger section;
@property (nonatomic, assign) BOOL      sectionSelect;
@property (nonatomic, assign) id <SectionHeaderViewDelegate> delegate;

-(id)initWithFrame:(CGRect)frame title:(NSString*)title size:(NSString*)totalsize section:(NSInteger)sectionNumber sectionOpen:(BOOL)select delegate:(id <SectionHeaderViewDelegate>)aDelegate;
-(void)toggleOpenWithUserAction:(BOOL)userAction;

@end


@protocol SectionHeaderViewDelegate <NSObject>

@optional
-(void)sectionHeaderView:(SectionHeaderView*)sectionHeaderView sectionOpened:(NSInteger)section;
-(void)sectionHeaderView:(SectionHeaderView*)sectionHeaderView sectionClosed:(NSInteger)section;
-(BOOL)provinceClick:(int)section;
@end


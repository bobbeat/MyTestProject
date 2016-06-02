//
//  CustomTextFieldCell.m
//  RoadFreightage
//
//  Created by mac on 15/6/6.
//  Copyright (c) 2015年 WuKongSuYun. All rights reserved.
//

#import "CustomTextFieldCell.h"

@interface CustomTextFieldCell()
{
    UIButton *_verificationButton;
    UIView *_lineView;
    NSTimer *_countTimer;
    int _currentCountNumber;
}


@end

@implementation CustomTextFieldCell

@synthesize textField,cellTitle,isShowVerificationButton,verificationBlock,isCountDown;

- (void)dealloc
{
    if (_countTimer) {
        [_countTimer invalidate];
        _countTimer = nil;
    }
    self.verificationBlock = nil;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        CGSize size = self.contentView.bounds.size;
        textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 10, size.width - 30, size.height-20)];
        textField.backgroundColor = [UIColor clearColor];
        textField.textColor = [UIColor blackColor];
        textField.borderStyle = UITextBorderStyleNone;
        textField.autocorrectionType = UITextAutocorrectionTypeNo;
        textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        textField.keyboardType = UIKeyboardTypeDefault;
        textField.returnKeyType = UIReturnKeyDone;
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.leftView=nil;
        textField.background=nil;
        [self.contentView addSubview:textField];
        
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)setCellTitle:(NSString *)title
{
    self.textLabel.text = title;
    [self layoutSubviews];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGSize size = self.contentView.bounds.size;
    
    float textFieldOffsetX = 25;
    float textFieldOffsetY = 6;
    CGSize title_size = [self.textLabel.text sizeWithAttributes:@{NSFontAttributeName:self.textLabel.font}];
    CGSize imageSize = self.imageView.image.size;
    CGSize verificationButtonSize = CGSizeMake(0, 0);   // 验证码按钮大小
    if (isShowVerificationButton == YES) {
        verificationButtonSize = CGSizeMake(120, size.height);
        _verificationButton.frame = CGRectMake(size.width - verificationButtonSize.width, 0, verificationButtonSize.width, verificationButtonSize.height);
        _lineView.frame = CGRectMake(0, 6, 1, verificationButtonSize.height - 12);
    }
    
    textField.frame = CGRectMake(textFieldOffsetX +imageSize.width + title_size.width, textFieldOffsetY, size.width - imageSize.width - title_size.width - 2*textFieldOffsetX - verificationButtonSize.width, size.height - 2*textFieldOffsetY);
    if ([self.textLabel.text length] != 0)
    {
        CGRect rect = self.textLabel.frame;
        rect.size.width = title_size.width + 5;
        self.textLabel.frame = rect;
    }
}

#pragma mark -验证码相关函数

- (void)VerficationButtonPressed
{
    if (self.verificationBlock) {
        self.verificationBlock(self);
    }
}

- (void)setIsCountDown:(BOOL)sign
{
    isCountDown = sign;
    if (sign == YES)
    {
        if (_countTimer == nil) {
            _currentCountNumber = 60;
            _countTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(CountDown) userInfo:nil repeats:YES];
            [_countTimer fire];
        }
    }
    else
    {
        _currentCountNumber = 0;
        if (_countTimer) {
            [_countTimer invalidate];
            _countTimer = nil;
        }
        _verificationButton.enabled = YES;
    }
}

- (void)CountDown
{
    _verificationButton.enabled = NO;
    [_verificationButton setTitle:[NSString stringWithFormat:@"%ds后重新获取",_currentCountNumber] forState:UIControlStateNormal];
    _currentCountNumber --;
    if (_currentCountNumber == 0) {
        _verificationButton.enabled = YES;
        if (_countTimer) {
            [_countTimer invalidate];
            _countTimer = nil;
        }
        [_verificationButton setTitle:[NSString stringWithFormat:@"获取验证码"] forState:UIControlStateNormal];
    }
}

- (void)setIsShowVerificationButton:(BOOL)show
{
    isShowVerificationButton = show;
    if (show)
    {
        if (_verificationButton == nil) {
            _verificationButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [_verificationButton setTitle:@"获取验证码" forState:UIControlStateNormal];
            [_verificationButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            _verificationButton.titleLabel.font = [UIFont systemFontOfSize:15];
            [_verificationButton addTarget:self action:@selector(VerficationButtonPressed) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:_verificationButton];
            
            _lineView = [[UIView alloc] init];
            _lineView.backgroundColor = [UIColor grayColor];
            [_verificationButton addSubview:_lineView];
        }
    }
    else
    {
        if (_verificationButton)
        {
            [_lineView removeFromSuperview];
            _lineView = nil;
            
            [_verificationButton removeFromSuperview];
            _verificationButton = nil;
        }
    }
    [self layoutSubviews];
}

@end

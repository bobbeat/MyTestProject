//
//  POIAroundTextfield.m
//  AutoNavi
//
//  Created by huang on 13-8-24.
//
//

#import "POIAroundTextField.h"
#import "POIDefine.h"

@interface POIAroundTextField()
{
    BOOL backspace;
    UIImageView * _imageView;
}
@property(nonatomic) BOOL isShowVoiceButton;                //设置当前要不要显示语言按钮 YES->显示 NO->不显示
@end

@implementation POIAroundTextField
@synthesize textField=_textField,limitLength,isShowVoiceButton,isHaveVoice;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor=[UIColor clearColor];
        UIImage *searchBG =[IMAGE(@"POISearchInput.png", IMAGEPATH_TYPE_1) stretchableImageWithLeftCapWidth:7 topCapHeight:7];
        _imageView=[[UIImageView alloc] initWithFrame:CGRectMake(10,0, frame.size.width-30,frame.size.height)];
        _imageView.backgroundColor=[UIColor clearColor];
        _imageView.image=searchBG;
        _imageView.userInteractionEnabled=YES;
        [self addSubview:_imageView];
        
        _textField=[[POITextField alloc] initWithFrame:CGRectMake(10, 0,_imageView.frame.size.width-30, frame.size.height)];
        _textField.autocorrectionType = UITextAutocorrectionTypeNo;
        _textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _textField.delegate=self;
        [_imageView addSubview:_textField];
     
        _textField.clearButtonMode=UITextFieldViewModeWhileEditing;
        //设置键盘的显示方式
        _textField.keyboardType = UIKeyboardTypeDefault;
        _textField.enablesReturnKeyAutomatically = YES;
        _textField.offsetY=3;
        _textField.imageViewTextfield.center = CGPointMake(22,17);
        [_textField release];

        
        _button=[UIButton buttonWithType:UIButtonTypeCustom];
        [_button addTarget:self action:@selector(buttonAction:) forControlEvents:
         UIControlEventTouchUpInside];
        _button.tag = 200;
        [_button setTitle:STR(@"POI_Search", Localize_POI) forState:UIControlStateNormal];
        _button.titleLabel.font=[UIFont systemFontOfSize:kSize2];
        
        [_button setBackgroundImage:[IMAGE(@"POISearchBtn.png",IMAGEPATH_TYPE_1) stretchableImageWithLeftCapWidth:5 topCapHeight:6]forState:UIControlStateNormal];
        [_button setBackgroundImage:[IMAGE(@"POISearchBtn1.png",IMAGEPATH_TYPE_1) stretchableImageWithLeftCapWidth:5 topCapHeight:6]forState:UIControlStateHighlighted];
        [_button setBackgroundImage:[IMAGE(@"POISearchBtn2.png",IMAGEPATH_TYPE_1) stretchableImageWithLeftCapWidth:5 topCapHeight:6]forState:UIControlStateDisabled];
        
        [_button setTitleColor:GETSKINCOLOR(@"POISearchButtonTitleColor") forState:UIControlStateNormal];
        [_button setTitleColor:GETSKINCOLOR(@"POISearchButtonTitleDisableColor") forState:UIControlStateDisabled];
        [self addSubview:_button];
            _buttonVoice  =[UIButton buttonWithType:UIButtonTypeCustom];
            [_buttonVoice setImage:IMAGE(@"POIVoiceSearch1.png",IMAGEPATH_TYPE_1) forState:UIControlStateNormal];
            _buttonVoice.tag = 100;
            [_buttonVoice addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
            [_imageView addSubview:_buttonVoice];
        _buttonVoice.hidden = YES;
        isShowVoiceButton = YES;
        [_button setEnabled:NO];
       // _button.hidden=YES;
        _isShowAlways=YES;
        _resignShowButton=NO;
        limitLength=0;

    }
    return self;
}
-(void)listenNotication:(NSNotification*)notification
{
    if (backspace==YES) {
        return;
    }
    else{
        NSLog(@"%@",notification);
    }
    
}
-(void)hiddenButton
{
    [self changeFrame];
    [_button setHidden:YES];
}

-(void)dealloc
{
    CLOG_DEALLOC(self);
    self.delegate=nil;
    CRELEASE(_text);
    CRELEASE(_buttonText);
    CRELEASE(_imageView);
    [super dealloc];
    
}
-(BOOL)isFirstResponder
{
   return  _textField.isFirstResponder;
}
-(BOOL)resignFirstResponder
{
    return  [_textField resignFirstResponder];
}
- (BOOL)becomeFirstResponder
{
    return [_textField becomeFirstResponder];
}

-(void)setText:(NSString *)text
{
    if (_text) {
        [_text release];
    }
    _text=[text copy];
    _textField.text=text;
    BOOL isEndable=text.length>0?1:0;
    [_button setEnabled:isEndable];
    
}
-(void)setButtonText:(NSString *)buttonText
{
    if (_buttonText) {
        [_buttonText release];
    }
    _buttonText=[buttonText copy];
    [_button setTitle:_buttonText forState:UIControlStateNormal];
}

-(void)buttonAction:(UIButton*)button
{
    
    if (self.delegate&&[self.delegate respondsToSelector:@selector(buttonTouchEvent:withButton:)]) {
        [self.delegate buttonTouchEvent:_textField.text withButton:button];
    }
    [_textField resignFirstResponder];
}
-(void)setIsShowButton:(BOOL) isshow
{
    _isShowButton=isshow;
    [self changeFrame];
    if (self.textField.text.length==0) {
        [_button setEnabled:NO];
    }
}
-(void)changeFrame
{
    if (Interface_Flag==0) {
        [self changePortraitControlFrameWithImage];
    }
    else
    {
        [self changeLandscapeControlFrameWithImage];
    }

}
//调整控件竖屏坐标和图片
-(void)changePortraitControlFrameWithImage
{

    int width=0;
    //if (_isShowButton) {
        width=67;
    //}
    if (!_isShowButton) {
        isShowVoiceButton = YES;
    }
    int voiceWight = 0;
    if (isHaveVoice == YES) {
        _buttonVoice.hidden = isShowVoiceButton == YES?NO:YES;
        voiceWight = isShowVoiceButton == YES?30:0;
    }
   
    _button.hidden=!width;
    _imageView.frame = CGRectMake(0, 0,self.frame.size.width-width,self.frame.size.height);
    _textField.frame=CGRectMake(0,0, _imageView.frame.size.width - voiceWight , 34);
    _button.frame=CGRectMake(self.frame.size.width -width +10, 0, width-10, 34);
    _buttonVoice.frame =CGRectMake(self.frame.size.width -width - voiceWight,2,30, 30);
    
}
//调整控件横屏坐标和图片
-(void)changeLandscapeControlFrameWithImage
{
   
    int width=0;
    //if (_isShowButton) {
        width=67;
   // }
    if (!_isShowButton) {
        isShowVoiceButton = YES;
    }
    int voiceWight = 0;
    if (isHaveVoice == YES) {
        _buttonVoice.hidden = isShowVoiceButton == YES?NO:YES;
        voiceWight = isShowVoiceButton == YES?30:0;
    }
    _button.hidden=!width;
    _imageView.frame = CGRectMake(0, 0,self.frame.size.width-width,self.frame.size.height);
    _textField.frame=CGRectMake(0,0,_imageView.frame.size.width -voiceWight  , 34);
    _button.frame=CGRectMake(self.frame.size.width -width+10, 0, width-10, 34);
    _buttonVoice.frame =CGRectMake(self.frame.size.width -width -voiceWight, 2, 30, 30);
  
}

-(void)textFieldChanage:(UITextField*)textField
{
    if (limitLength==0) {
        return;
    }
    if ([textField.text length]>limitLength) {
        textField.text = [textField.text substringToIndex:limitLength];
    }
    

}
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField.text.length>0) {
        isShowVoiceButton = NO;
    }else
    {
        isShowVoiceButton = YES;
    }
    self.isShowButton=_isShowAlways;
    return YES;
}
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    backspace=NO;
    if (string.length==0) {
    
        backspace=YES;
        if (textField.text.length==1) {
            isShowVoiceButton = YES;
            self.isShowButton=_isShowAlways;
            [_button setEnabled:NO];
        }
        if ([self.delegate respondsToSelector:@selector(textFieldBackSpace:)]) {
            [self.delegate textFieldBackSpace:_button.enabled==NO?@"":[textField.text substringToIndex:textField.text.length-1]];
        }
        
        return YES;
    }
    else
    {
            isShowVoiceButton = NO;
        if (textField.text.length==0) {
        
            self.isShowButton=YES;
          
        }
        if (self.delegate&&[self.delegate respondsToSelector:@selector(textFieldChanage:withRange:withString:)]) {
            BOOL isNo  =[self.delegate textFieldChanage:textField withRange:range withString:string];
            if(isNo==NO)
            {
                if (textField.text.length==0) {
                    self.isShowButton=_isShowAlways;
                }
                return NO;
            }
        }
        [_button setEnabled:YES];
       
    }
    return YES;
}
- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    isShowVoiceButton = YES;
    self.isShowButton=_isShowAlways;
    [_button setEnabled:NO];
    if(self.delegate &&[self.delegate respondsToSelector:@selector(textFieldClear:)])
    {
        [self.delegate textFieldClear:textField];
    }
    return YES;
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (self.delegate&&[self.delegate respondsToSelector:@selector(textFieldReturn:)]) {
        [self.delegate textFieldReturn:_textField.text ];
    }
    [_textField resignFirstResponder];
    return YES;
}
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    isShowVoiceButton = YES;
    self.isShowButton=self.resignShowButton;
}
@end

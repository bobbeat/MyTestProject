//
//  KLSwitch.m
//  KLSwitch
//
//  Created by Kieran Lafferty on 2013-06-15.
//  Copyright (c) 2013 Kieran Lafferty. All rights reserved.
//
// https://github.com/KieranLafferty/KLSwitch

#import "KLSwitch.h"

#define kConstrainsFrameToProportions YES
#define kHeightWidthRatio 1.6451612903  //Magic number as a result of dividing the height by the width on the default UISwitch size (51/31)

//NSCoding Keys
#define kCodingOnKey @"on"
#define kCodingLockedKey @"off"
#define kCodingOnTintColorKey @"onColor"
#define kCodingOnColorKey @"onTintColor"    //Not implemented
#define kCodingTintColorKey @"tintColor"
#define kCodingThumbTintColorKey @"thumbTintColor"
#define kCodingOnImageKey @"onImage"
#define kCodingOffImageKey @"offImage"
#define kCodingConstrainFrameKey @"constrainFrame"

//Appearance Defaults - Colors
//Track Colors
#define kDefaultTrackOnColor     [UIColor colorWithRed:83/255.0 green: 214/255.0 blue: 105/255.0 alpha: 1]
#define kDefaultTrackOffColor    [UIColor colorWithWhite: 0.9f alpha:1.0f]
#define kDefaultTrackContrastColor [UIColor whiteColor]

//Thumb Colors
#define kDefaultThumbTintColor [UIColor whiteColor]
#define kDefaultThumbBorderColor [UIColor colorWithWhite: 0.9f alpha:1.0f]

//Appearance - Layout

//Size of knob with respect to the control - Must be a multiple of 2
#define kThumbOffset 1
#define kThumbTrackingGrowthRatio 1.2f                //Amount to grow the thumb on press down

#define kDefaultPanActivationThreshold 0.7                    //Number between 0.0 - 1.0 describing how far user must drag before initiating the switch

//Appearance - Animations
#define kDefaultAnimationSlideLength 0.25f           //Length of time to slide the thumb from left/right to right/left
#define kDefaultAnimationScaleLength 0.15f           //Length of time for the thumb to grow on press down
#define kDefaultAnimationContrastResizeLength 0.25f           //Length of time for the thumb to grow on press down

#define kSwitchTrackContrastViewShrinkFactor 0.0001f     //Must be very low but not 0 or else causes iOS 5 issues

typedef enum {
    KLSwitchThumbJustifyLeft,
    KLSwitchThumbJustifyRight
} KLSwitchThumbJustify;

@interface KLSwitchThumb : UIView
@property (nonatomic, assign) BOOL isTracking;
-(void) growThumbWithJustification:(KLSwitchThumbJustify) justification;
-(void) shrinkThumbWithJustification:(KLSwitchThumbJustify) justification;
@end

@interface KLSwitchTrack : UIView
@property(nonatomic, getter=isOn) BOOL on;
@property (nonatomic, retain) UIColor* contrastColor;
@property (nonatomic, retain) UIColor* onTintColor;
@property (nonatomic, retain) UIColor* tintColor;
-(id) initWithFrame:(CGRect)frame
            onColor:(UIColor*) onColor
           offColor:(UIColor*) offColor
      contrastColor:(UIColor*) contrastColor;
-(void) growContrastView;
-(void) shrinkContrastView;
-(void) setOn:(BOOL) on
     animated:(BOOL) animated;
@end


@interface KLSwitch () <UIGestureRecognizerDelegate>
{
    UIPanGestureRecognizer* panGesture;
    UITapGestureRecognizer* tapGesture;
    KLSwitchTrack* track;
    KLSwitchThumb* thumb;
    UIView *_shadeView;
}


-(void) configureSwitch;
-(void) initializeDefaults;
-(void) toggleState;
-(void) setThumbOn:(BOOL) on
          animated:(BOOL) animated;

@end

@implementation KLSwitch

- (void)dealloc
{
    NSLog(@"KLSwitch is dealloc");
    self.thumbBorderColor = nil;
    self.thumbTintColor = nil;
    self.tintColor = nil;
    self.onImage = nil;
    self.onTintColor = nil;
    self.offImage = nil;
    self.didChangeHandler = nil;
    self.contrastColor = nil;
    [super dealloc];
}
#pragma mark - Initializers

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder: aCoder];
    
    [aCoder encodeBool: _on
                forKey: kCodingOnKey];
    
    [aCoder encodeObject: _onTintColor
                  forKey: kCodingOnTintColorKey];
    
    [aCoder encodeObject: _tintColor
                  forKey: kCodingTintColorKey];
    
    [aCoder encodeObject: _thumbTintColor
                  forKey: kCodingThumbTintColorKey];
    
    [aCoder encodeObject: _onImage
                  forKey: kCodingOnImageKey];
    
    [aCoder encodeObject: _offImage
                  forKey: kCodingOffImageKey];
    
    [aCoder encodeBool: _shouldConstrainFrame
                forKey: kCodingConstrainFrameKey];
    
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    [self initializeDefaults];
    if (self = [super initWithCoder: aDecoder]) {
        
        self.on = [aDecoder decodeBoolForKey:kCodingOnKey];
        self.locked = [aDecoder decodeBoolForKey:kCodingLockedKey];
        self.onTintColor = [aDecoder decodeObjectForKey: kCodingOnTintColorKey];
        self.tintColor = [aDecoder decodeObjectForKey: kCodingTintColorKey];
        self.thumbTintColor = [aDecoder decodeObjectForKey: kCodingThumbTintColorKey];
        self.onImage = [aDecoder decodeObjectForKey: kCodingOnImageKey];
        self.offImage = [aDecoder decodeObjectForKey: kCodingOffImageKey];
        self.onTintColor = [aDecoder decodeObjectForKey: kCodingOnTintColorKey];
        self.shouldConstrainFrame = [aDecoder decodeBoolForKey: kCodingConstrainFrameKey];
        
        [self configureSwitch];

    }
    return self;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self configureSwitch];
    }
    return self;
}
- (id)initWithFrame:(CGRect)frame
   didChangeHandler:(changeHandler) didChangeHandler {
    if (self = [self initWithFrame: frame]) {
        self.didChangeHandler = didChangeHandler ;
    }
    return self;
}
-(void) setFrame:(CGRect)frame {
    if (self.shouldConstrainFrame) {
        [super setFrame: CGRectMake(frame.origin.x, frame.origin.y, frame.size.height*kHeightWidthRatio, frame.size.height)];
    }
    else [super setFrame: frame];
}

#pragma mark - Defaults and layout/appearance

-(void) initializeDefaults {
    self.onTintColor = kDefaultTrackOnColor;
    self.tintColor = kDefaultTrackOffColor;
    self.thumbTintColor = kDefaultThumbTintColor;
    self.thumbBorderColor = kDefaultThumbBorderColor;
    self.contrastColor = kDefaultThumbTintColor;
    self.panActivationThreshold = kDefaultPanActivationThreshold;
    self.shouldConstrainFrame = kConstrainsFrameToProportions;
}
-(void) configureSwitch {
    [self initializeDefaults];
 
    //Configure visual properties of self
    [self setBackgroundColor: [UIColor clearColor]];
    
    
    // tap gesture for toggling the switch
	tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                              action:@selector(didTap:)];
	[tapGesture setDelegate:self];
	[self addGestureRecognizer:tapGesture];
    [tapGesture release];
    
	// pan gesture for moving the switch knob manually
	panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                              action:@selector(didDrag:)];
	[panGesture setDelegate:self];
	[self addGestureRecognizer:panGesture];
    [panGesture release];
    /*
     Subview layering as follows :
     
     TOP
         thumb
         track
     BOTTOM
     */
    // Initialization code
    if (!track) {
        track = [[KLSwitchTrack alloc] initWithFrame: self.bounds
                                              onColor: self.onTintColor
                                             offColor: self.tintColor
                                        contrastColor: self.contrastColor];
        [track setOn: self.isOn
             animated: NO];
        [self addSubview: track];
        [track release];
    }
    if (!thumb) {
        thumb = [[KLSwitchThumb alloc] initWithFrame:CGRectMake(kThumbOffset, kThumbOffset, self.bounds.size.height - 2 * kThumbOffset, self.bounds.size.height - 2 * kThumbOffset)];
        [self addSubview: thumb];
        [thumb release];
    }
    
    _shadeView = [[UIView alloc] initWithFrame:self.bounds];
    CGFloat cornerRadius = self.bounds.size.height/2.0f;
    [_shadeView.layer setCornerRadius: cornerRadius];
    [_shadeView setBackgroundColor: [UIColor blackColor]];
    _shadeView.alpha = 0.2;
    [self addSubview:_shadeView];
    [_shadeView release];
    _shadeView.hidden = YES;
}

-(void) setOnTintColor:(UIColor *)onTintColor
{
    if (_onTintColor)
    {
        [_onTintColor release];
        _onTintColor = nil;
    }
    _onTintColor = [onTintColor retain];
    [track setOnTintColor: _onTintColor];
}
-(void) setTintColor:(UIColor *)tintColor {
    if (_tintColor)
    {
        [_tintColor release];
        _tintColor = nil;
    }
    _tintColor = [tintColor retain];
    [track setTintColor: _tintColor];
}
-(void) setContrastColor:(UIColor *)contrastColor {
    if (_contrastColor)
    {
        [_contrastColor release];
        _contrastColor = nil;
    }
    _contrastColor = [contrastColor retain];
    [track setContrastColor: _contrastColor];
}
-(void) setThumbBorderColor:(UIColor *)thumbBorderColor {
    if (_thumbBorderColor)
    {
        [_thumbBorderColor release];
        _thumbBorderColor = nil;
    }
    _thumbBorderColor = [thumbBorderColor retain];
    [thumb.layer setBorderColor: [_thumbBorderColor CGColor]];
}
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    // Drawing code
    //[self.trackingKnob setTintColor: self.thumbTintColor];
    [thumb setBackgroundColor: [UIColor whiteColor]];
    
    //Make the knob a circle and add a shadow
    CGFloat roundedCornerRadius = thumb.frame.size.height/2.0f;
    [thumb.layer setBorderWidth: 0.5];
    [thumb.layer setBorderColor: [self.thumbBorderColor CGColor]];
    [thumb.layer setCornerRadius: roundedCornerRadius];
    [thumb.layer setShadowColor: [[UIColor grayColor] CGColor]];
    [thumb.layer setShadowOffset: CGSizeMake(0, 3)];
    [thumb.layer setShadowOpacity: 0.40f];
    [thumb.layer setShadowRadius: 0.8];
}

- (void)setEnabled:(BOOL)enabled
{
    [super setEnabled:enabled];
    if (enabled)
    {
        _shadeView.hidden = YES;
    }
    else
    {
        _shadeView.hidden = NO;
    }
}

#pragma mark - UIGestureRecognizer implementations
-(void) didTap:(UITapGestureRecognizer*) gesture {
    if (gesture.state == UIGestureRecognizerStateEnded) {
        [self toggleState];
    }
}
-(void) didDrag:(UIPanGestureRecognizer*) gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        //Grow the thumb horizontally towards center by defined ratio
        [self setThumbIsTracking: YES
                   animated: YES];
    }
    else if (gesture.state == UIGestureRecognizerStateChanged) {
        //If touch crosses the threshold then toggle the state
        CGPoint locationInThumb = [gesture locationInView: thumb];
        
        //Toggle the switch if the user pans left or right past the switch thumb bounds
        if ((self.isOn && locationInThumb.x <= 0)
            || (!self.isOn && locationInThumb.x >= thumb.bounds.size.width)) {
            [self toggleState];
        }
        
        CGPoint locationOfTouch = [gesture locationInView:self];
        if (CGRectContainsPoint(self.bounds, locationOfTouch))
            [self sendActionsForControlEvents:UIControlEventTouchDragInside];
        else
            [self sendActionsForControlEvents:UIControlEventTouchDragOutside];
    }
    else  if (gesture.state == UIGestureRecognizerStateEnded) {
        [self setThumbIsTracking: NO
                   animated: YES];
    }
}

#pragma mark - Event Handlers

-(void) toggleState {
    //Alternate between on/off
    [self setOn: self.isOn ? NO : YES
       animated: YES];
}

- (void)setOn:(BOOL)on
     animated:(BOOL)animated {
    //Cancel notification to parent if attempting to set to current state
    if (_on == on) {
        return;
    }
    
    //Move the thumb to the new position
    [self setThumbOn: on
            animated: animated];
    
    //Animate the contrast view of the track
    [track setOn: on
             animated: animated];
    
    _on = on;
    
    //Trigger the completion block if exists
    if (self.didChangeHandler) {
        self.didChangeHandler(_on);
    }
//    [self sendActionsForControlEvents:UIControlEventTouchUpInside];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void) setOn:(BOOL)on {
    [self setOn: on animated: NO];
}

- (void) setLocked:(BOOL)locked {
    //Cancel notification to parent if attempting to set to current state
    if (_locked == locked) {
        return;
    }
    _locked = locked;

    UIImageView *lockImageView = (UIImageView *)[track viewWithTag:LOCK_IMAGE_SUBVIEW];
    
    if (!locked && (lockImageView != nil)) {
        
        [lockImageView removeFromSuperview];
        lockImageView = nil;
        
    } else if (locked && (lockImageView == nil)) {
        
        UIImage *lockImage = IMAGE(@"lock-icon.png", IMAGEPATH_TYPE_1) ;
        
        lockImageView = [[UIImageView alloc] initWithImage:lockImage];
        
        lockImageView.frame = CGRectMake(7, 8, lockImage.size.width, lockImage.size.height);
        lockImageView.tag = LOCK_IMAGE_SUBVIEW;
        
        [track addSubview:lockImageView];
        [track bringSubviewToFront:lockImageView];
        [lockImageView release];
    }
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesBegan:touches withEvent:event];
    [self sendActionsForControlEvents:UIControlEventTouchDown];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesEnded:touches withEvent:event];
	[self sendActionsForControlEvents:UIControlEventTouchUpInside];
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesCancelled:touches withEvent:event];
	[self sendActionsForControlEvents:UIControlEventTouchUpOutside];
}

-(void) setThumbIsTracking:(BOOL)isTracking {
    if (isTracking) {
        //Grow
        [thumb growThumbWithJustification: self.isOn ? KLSwitchThumbJustifyRight : KLSwitchThumbJustifyLeft];
    }
    else {
        //Shrink
        [thumb shrinkThumbWithJustification: self.isOn ? KLSwitchThumbJustifyRight : KLSwitchThumbJustifyLeft];
    }
    [thumb setIsTracking: isTracking];
}
-(void) setThumbIsTracking:(BOOL)isTracking
             animated:(BOOL) animated {
    __block KLSwitch *weakSelf = self;
    [UIView animateWithDuration: kDefaultAnimationScaleLength
                          delay: fabs(kDefaultAnimationSlideLength - kDefaultAnimationScaleLength)
                        options: UIViewAnimationOptionCurveEaseOut
                     animations: ^{
                         [weakSelf setThumbIsTracking: isTracking];
                     }
                     completion:nil];
}
-(void) setThumbOn:(BOOL) on
          animated:(BOOL) animated {
    if (animated) {
        [UIView animateWithDuration:0.3 animations:^{
            [self setThumbOn:on animated:NO];
        }];
    }
    CGRect thumbFrame = thumb.frame;
    if (on) {
        thumbFrame.origin.x = self.bounds.size.width - (thumbFrame.size.width + kThumbOffset);
    }
    else {
        thumbFrame.origin.x = kThumbOffset;
    }
    [thumb setFrame: thumbFrame];
}
@end


@implementation KLSwitchThumb

- (void)dealloc
{
    [super dealloc];
}

-(void) growThumbWithJustification:(KLSwitchThumbJustify) justification {
    if (self.isTracking) 
        return;

    CGRect thumbFrame = self.frame;
    
    CGFloat deltaWidth = self.frame.size.width * (kThumbTrackingGrowthRatio - 1);
    thumbFrame.size.width += deltaWidth;
    if (justification == KLSwitchThumbJustifyRight) {
        thumbFrame.origin.x -= deltaWidth;
    }
    [self setFrame: thumbFrame];
}
-(void) shrinkThumbWithJustification:(KLSwitchThumbJustify) justification {
    if (!self.isTracking) 
        return;

    CGRect thumbFrame = self.frame;
    
    CGFloat deltaWidth = self.frame.size.width * (1 - 1 / (kThumbTrackingGrowthRatio));
    thumbFrame.size.width -= deltaWidth;
    if (justification == KLSwitchThumbJustifyRight) {
        thumbFrame.origin.x += deltaWidth;
    }
    [self setFrame: thumbFrame];

}
@end

@interface KLSwitchTrack ()
{
    UIView* contrastView;
    UIView* onView;
}

@end

@implementation KLSwitchTrack

- (void)dealloc
{
    self.onTintColor = nil;
    self.tintColor = nil;
    self.contrastColor = nil;
    [super dealloc];
}

-(id) initWithFrame:(CGRect)frame
            onColor:(UIColor*) onColor
           offColor:(UIColor*) offColor
      contrastColor:(UIColor*) contrastColor {
    if (self = [super initWithFrame: frame]) {
        _onTintColor = [onColor retain];
        _tintColor = [offColor retain];
        
        CGFloat cornerRadius = frame.size.height/2.0f;
        [self.layer setCornerRadius: cornerRadius];
        [self setBackgroundColor: _tintColor];
        
        CGRect contrastRect = frame;
        contrastRect.size.width = frame.size.width - 2*kThumbOffset;
        contrastRect.size.height = frame.size.height - 2*kThumbOffset;
        CGFloat contrastRadius = contrastRect.size.height/2.0f;

        contrastView = [[UIView alloc] initWithFrame:contrastRect];
        [contrastView setBackgroundColor: contrastColor];
        [contrastView setCenter: self.center];
        [contrastView.layer setCornerRadius: contrastRadius];
        [self addSubview: contrastView];
        [contrastView release];

        onView = [[UIView alloc] initWithFrame:frame];
        [onView setBackgroundColor: _onTintColor];
        [onView setCenter: self.center];
        [onView.layer setCornerRadius: cornerRadius];
        [self addSubview: onView];
        [onView release];

    }
    return self;
}

-(void) setOn:(BOOL)on {
    if (on) {
        [onView setAlpha: 1.0];
        [self shrinkContrastView];
    }
    else {
        [onView setAlpha: 0.0];
        [self growContrastView];
    }
}

-(void) setOn:(BOOL)on
     animated:(BOOL)animated {
    if (animated) {
        __block KLSwitchTrack *weakSelf = self;
            //First animate the color switch
        [UIView animateWithDuration: kDefaultAnimationContrastResizeLength
                              delay: 0.0
                            options: UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             [weakSelf setOn: on
                                animated: NO];
                         }
                         completion:nil];
    }
    else {
        [self setOn: on];
    }
}

-(void) setOnTintColor:(UIColor *)onTintColor {
    if (_onTintColor)
    {
        [_onTintColor release];
        _onTintColor = nil;
    }
    _onTintColor = [onTintColor retain];
    [onView setBackgroundColor: _onTintColor];
}

-(void) setTintColor:(UIColor *)tintColor {
    if (_tintColor)
    {
        [_tintColor release];
        _tintColor = nil;
    }
    _tintColor = [tintColor retain];
    [self setBackgroundColor: _tintColor];
}

-(void) setContrastColor:(UIColor *)contrastColor {
    if (_contrastColor)
    {
        [_contrastColor release];
        _contrastColor = nil;
    }
    _contrastColor = [contrastColor retain];
    [contrastView setBackgroundColor: _contrastColor];
}

-(void) growContrastView {
    //Start out with contrast view small and centered
    [contrastView setTransform: CGAffineTransformMakeScale(kSwitchTrackContrastViewShrinkFactor, kSwitchTrackContrastViewShrinkFactor)];
    [contrastView setTransform: CGAffineTransformMakeScale(1, 1)];
}

-(void) shrinkContrastView {
    //Start out with contrast view the size of the track
    [contrastView setTransform: CGAffineTransformMakeScale(1, 1)];
    [contrastView setTransform: CGAffineTransformMakeScale(kSwitchTrackContrastViewShrinkFactor, kSwitchTrackContrastViewShrinkFactor)];
}

@end

//
//  iFlySpeechService.h
//  AutoNavi
//
//  Created by lin jingjie on 11-12-14.
//  Copyright 2011 autonavi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SpeechService.h"

#import "iflyMSC/IFlyRecognizerView.h"
#import "iflyMSC/IFlyRecognizerViewDelegate.h"

@interface iFlySpeechService : SpeechService<IFlyRecognizerViewDelegate>
{
	int mResultType;
}
@property(nonatomic,retain) IFlyRecognizerView *voiceRecognizeController;
-(id)initWithView:(UIView *) view Lon:(int)lon Lat:(int)lat AdminCode:(int)adminCode;
- (void) updateResult:(NSString *)resultText;
- (void) errorHappend:(NSNumber *)errorCode;
@end

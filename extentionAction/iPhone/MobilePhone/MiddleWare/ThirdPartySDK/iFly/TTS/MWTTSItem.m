//
//  MWTTSItem.m
//  AutoNavi
//
//  Created by longfeng.huang on 14-4-28.
//
//

#import "MWTTSItem.h"

@implementation MWTTSItem

- (void)dealloc
{
    if (_playString) {
        [_playString release];
        _playString = nil;
    }
    
    if (_playPath) {
        [_playPath release];
        _playPath = nil;
    }
    
    [super dealloc];
    
}
@end

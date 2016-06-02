//
//  POIVoiceSearchViewController.h
//  AutoNavi
//
//  Created by huang on 13-8-19.
//
//

#import "ANViewController.h"
#import "MWPoiOperator.h"


@interface POIVoiceSearchViewController : ANTableViewController
{

}
@property(nonatomic,retain)NSMutableArray * arraySearchData;
@property(nonatomic,assign) int aroundFlag;
@property(nonatomic,copy)NSString *cmdtxt;
@property(nonatomic,assign) MWVoiceTyoe voiceType;


@end

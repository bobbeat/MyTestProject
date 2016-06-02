//
//  POITextField.h
//  AutoNavi
//
//  Created by huang on 13-9-8.
//
//

#import <UIKit/UIKit.h>

@interface POITextField : UITextField
@property(nonatomic)int placeholderFontSize;
@property(nonatomic,retain)UIFont * placeholderFont;
@property (nonatomic) float offsetY;
@property(retain,nonatomic) UIImageView *imageViewTextfield;
@end

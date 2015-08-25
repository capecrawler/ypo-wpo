//
//  YPOGenderController.h
//  YPO-WPO SG
//
//  Created by Mario Antonio A. Cape on 8/23/15.
//  Copyright (c) 2015 Raketeers. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YPOGenderController;
@protocol YPOGenderControllerDelegate <NSObject>
- (void)genderController:(YPOGenderController *)controller didSelectGender:(NSString *)gender;
@end

@interface YPOGenderController : UITableViewController
@property (nonatomic, weak)id<YPOGenderControllerDelegate> genderDelegate;
- (void)presentPopoverFromRect:(CGRect)rect inView:(UIView *)view;
- (void)show;
@end

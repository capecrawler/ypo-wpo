//
//  YPOCountryController.h
//  YPO-WPO SG
//
//  Created by Mario Antonio A. Cape on 8/26/15.
//  Copyright (c) 2015 Raketeers. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YPOCountryController;
@class YPOCountry;

@protocol YPOCountryControllerDelegate <NSObject>

- (void)countryController:(YPOCountryController *)controller didSelectCountry:(YPOCountry *)country;

@end


@interface YPOCountryController : UITableViewController

@property (nonatomic, weak)id<YPOCountryControllerDelegate> countryDelegate;
- (void)presentPopoverFromRect:(CGRect)rect inView:(UIView *)view;
- (void)show;

@end

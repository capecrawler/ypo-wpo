//
//  YPODateController.h
//  YPO-WPO SG
//
//  Created by Mario Antonio A. Cape on 8/23/15.
//  Copyright (c) 2015 Raketeers. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YPODateController;

@protocol YPODateControllerDelegate <NSObject>

- (void)dateController:(YPODateController *)controller dateSelected:(NSDate*)date;

@end


@interface YPODateController : UIViewController

@property (nonatomic, assign) id<YPODateControllerDelegate> delegate;
@property (nonatomic, assign) NSInteger tag;

- (instancetype)initWithSelectedDate:(NSDate *)date;
- (void)show;
- (void)presentPopoverFromRect:(CGRect)rect inView:(UIView *)view;

@end

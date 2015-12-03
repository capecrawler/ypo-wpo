//
//  YPOTabBarController.h
//  YPO-WPO SG
//
//  Created by Mario Antonio A. Cape on 7/30/15.
//  Copyright (c) 2015 Raketeers. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YPOTabBarController : UITabBarController

- (void)pushViewControllerOnTop:(UIViewController *)controller animated:(BOOL)animated;
- (void)setNotificationBadge;

@end

//
//  YPOTabBarController.m
//  YPO-WPO SG
//
//  Created by Mario Antonio A. Cape on 7/30/15.
//  Copyright (c) 2015 Raketeers. All rights reserved.
//

#import "YPOTabBarController.h"
#import <Parse/Parse.h>

@implementation YPOTabBarController

- (void)pushViewControllerOnTop:(UIViewController *)controller animated:(BOOL)animated {
    UINavigationController *navigationController = self.selectedViewController;
    [navigationController pushViewController:controller animated:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setNotificationBadge)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setNotificationBadge];
}

- (void)tabBar:(UITabBar *)theTabBar didSelectItem:(UITabBarItem *)item {
    NSUInteger indexOfTab = [[theTabBar items] indexOfObject:item];
    [self setNotificationBadgeOnSelectedIndex:indexOfTab];
}

- (void)setNotificationBadge {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self setNotificationBadgeOnSelectedIndex:self.selectedIndex];
    });

}

- (void)setNotificationBadgeOnSelectedIndex:(NSInteger)index {
    if (index != 3) {
        NSInteger badgeCount = [UIApplication sharedApplication].applicationIconBadgeNumber;
        if (badgeCount > 0) {
            NSString *badge = [NSString stringWithFormat:@"%ld",(long)badgeCount];
            [[self.tabBar.items objectAtIndex:3] setBadgeValue:badge];
        } else {
            [[self.tabBar.items objectAtIndex:3] setBadgeValue:nil];
        }
    } else {
        [[self.tabBar.items objectAtIndex:3] setBadgeValue:nil];
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    }
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    currentInstallation.badge = [UIApplication sharedApplication].applicationIconBadgeNumber;
    [currentInstallation saveEventually];
}

@end

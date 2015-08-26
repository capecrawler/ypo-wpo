//
//  AppDelegate.h
//  YPO-WPO SG
//
//  Created by Mario Antonio A. Cape on 6/6/15.
//  Copyright (c) 2015 Raketeers. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
- (void)signIn;
- (void)logout;
- (void)showLogin:(BOOL)show;
- (double) getDidEnteredBGTimestamp;
@end


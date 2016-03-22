//
//  AppDelegate.m
//  YPO-WPO SG
//
//  Created by Mario Antonio A. Cape on 6/6/15.
//  Copyright (c) 2015 Raketeers. All rights reserved.
//

#import "AppDelegate.h"
#import <AFNetworking/AFNetworkActivityIndicatorManager.h>
#import <AFNetworkActivityLogger/AFNetworkActivityLogger.h>
#import <MagicalRecord/MagicalRecord.h>
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "YPOSyncManager.h"
#import "LoginViewController.h"
#import "YPOAPIClient.h"
#import <SDWebImage/SDImageCache.h>
#import "YPOImageCache.h"
#import "YPOUser.h"
#import <WYPopoverController/WYPopoverController.h>
#import <Parse/Parse.h>
#import "YPODeeplinkManager.h"
#import "YPONotificationManager.h"
#import "YPOTabBarController.h"

#define APP_DID_ENTER_BG_TIMESTAMP @"app_did_background_timestamp"

@interface AppDelegate ()

@property (nonatomic, strong) YPOTabBarController *tabController;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [Parse setApplicationId:@"Ohujzor69llWxaI1CZ6865ecABH9DMSeoPpo2bQO"
                  clientKey:@"tom8KEfqogegzaiNI8YMeykmWZJvAwa2T8jCwZc0"];
    
    if (launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]) {
        [self handleRemoteNotification:launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]];
        [self decrementBadge];
    }
    
    [[YPODeeplinkManager sharedManager] setRoutes];
    
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    [[AFNetworkActivityLogger sharedLogger]startLogging];
    [self configureAppearanceProxy];    
    [MagicalRecord setupCoreDataStackWithAutoMigratingSqliteStoreNamed:@"YPOSqlite"];
    
    [Fabric with:@[CrashlyticsKit]];
    
    [[YPOSyncManager sharedManager] purgeAllData];
    if (![YPOUser currentUser]) {
        [[YPOSyncManager sharedManager]deleteAllData];
        [self showLogin:YES];
    } else {
        NSLog(@"try to register");
        UIUserNotificationSettings* notificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
    }
    
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [self setDidEnteredBGTimeStamp:CACurrentMediaTime()];
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.

}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [MagicalRecord cleanUp];
    [[SDImageCache sharedImageCache] cleanDisk];
    [[YPOImageCache sharedImageCache] cleanDisk];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {

    if ([YPOUser currentUser]) {
        [[YPODeeplinkManager sharedManager]handleURL:url withCompletion:nil];
    }
    
    return YES;
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
    NSLog(@"did register remote notif");
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    currentInstallation.channels = @[ @"global" ];
    currentInstallation[@"member_id"] = [[YPOUser currentUser] memberID];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
//    [PFPush handlePush:userInfo];
    if ( application.applicationState != UIApplicationStateActive ) {
        [self handleRemoteNotification:userInfo];
        [self decrementBadge];
    }
}


- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"notification error: %@", error);
}

#pragma mark - AppearanceProxy

- (void)configureAppearanceProxy{
    [[UINavigationBar appearance] setBarTintColor:UIColorFromRGB(0x034784)];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor],
                                                           NSFontAttributeName: [UIFont fontWithName:@"Georgia-Bold" size:18]}];
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTintColor:[UIColor whiteColor]];
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]} forState:UIControlStateNormal];    
}


#pragma mark - Routines

- (void)handleRemoteNotification:(NSDictionary *)userInfo {
    [[YPONotificationManager sharedManager]handleNotification:userInfo];
}

- (void)decrementBadge {
    NSInteger badgeCount = [UIApplication sharedApplication].applicationIconBadgeNumber;
    badgeCount = (badgeCount > 0)? badgeCount-1:0;
    [UIApplication sharedApplication].applicationIconBadgeNumber = badgeCount;
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    currentInstallation.badge = [UIApplication sharedApplication].applicationIconBadgeNumber;
    [currentInstallation saveEventually];
}

- (double) getDidEnteredBGTimestamp{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    return [defaults doubleForKey:APP_DID_ENTER_BG_TIMESTAMP];
}


- (void) setDidEnteredBGTimeStamp: (double) time{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults setDouble:time forKey:APP_DID_ENTER_BG_TIMESTAMP];
    [defaults synchronize];
}


- (void)logout {
    [[YPOSyncManager sharedManager] cancelSync];    
    [[YPOAPIClient sharedClient].operationQueue cancelAllOperations];
    [[YPOSyncManager sharedManager]deleteAllData];
    [YPOUser setCurrentUser:nil];
    [self showLogin:YES];
}


- (void)signIn {
    [self showLogin:NO];    
}


- (void)showLogin:(BOOL)show{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    if (show) {
        [[UIApplication sharedApplication] unregisterForRemoteNotifications];
        UIViewController *loginController = [sb instantiateViewControllerWithIdentifier:@"LoginViewController"];
        [UIView transitionFromView:self.window.rootViewController.view toView:loginController.view duration:0.5 options:UIViewAnimationOptionTransitionFlipFromRight completion:^(BOOL finished) {
            if (finished) {
                self.window.rootViewController = loginController;
            }
        }];
    } else {
        UIUserNotificationSettings* notificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
        self.tabController = [sb instantiateViewControllerWithIdentifier:@"YPOTabBarController"];
        [UIView transitionFromView:self.window.rootViewController.view toView:self.tabController.view duration:0.5 options:UIViewAnimationOptionTransitionFlipFromRight completion:^(BOOL finished) {
            if (finished) {
                self.window.rootViewController = self.tabController;
            }
        }];
    }
}



@end

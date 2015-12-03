//
//  YPONotificationManager.m
//  YPO-WPO SG
//
//  Created by Mario Antonio A. Cape on 12/2/15.
//  Copyright © 2015 Raketeers. All rights reserved.
//

#import "YPONotificationManager.h"
#import "EventDetailsViewController.h"
#import "YPOTabBarController.h"
#import "AppDelegate.h"
#import "MemberDetailsViewController.h"
#import "NewsDetailsViewController.h"
#import "YPOArticle.h"


@implementation YPONotificationManager

+ (instancetype)sharedManager {
    static YPONotificationManager *sharedManager;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedManager = [[YPONotificationManager alloc] init];
    });
    return sharedManager;
}

- (void)handleNotification:(NSDictionary *)notification {
    NSString *type = notification[@"type"];
    NSNumber *contentID = notification[@"content_id"];
    NSString *title = notification[@"title"];
    if ([type isEqualToString:@"event"]) {
        [self showEventDetails:contentID];
    } else if ([type isEqualToString:@"member"]) {
        [self showMemberProfile:contentID];
    } else if ([type isEqualToString:@"news"] || [type isEqualToString:@"comment"]) {
        [self showArticle:contentID title:title];
    }
}

- (void)showEventDetails:(NSNumber *)eventID {
    __weak __typeof(self)weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        EventDetailsViewController *eventController = [storyboard instantiateViewControllerWithIdentifier:@"EventDetailsViewController"];
        eventController.eventID = eventID;
        [[weakSelf currentRootController] pushViewControllerOnTop:eventController animated:YES];
    });
}

- (void)showMemberProfile:(NSNumber *)memberID {
    __weak __typeof(self)weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        MemberDetailsViewController *memberController = [storyboard instantiateViewControllerWithIdentifier:@"MemberDetailsViewController"];
        memberController.memberID = memberID;
        [[weakSelf currentRootController] pushViewControllerOnTop:memberController animated:YES];
    });
}

- (void)showArticle:(NSNumber *)articleID title:(NSString *)title {
    __weak __typeof(self)weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        NewsDetailsViewController *newsController = [storyboard instantiateViewControllerWithIdentifier:@"NewsDetailsViewController"];
        newsController.articleID = articleID.integerValue;
        newsController.articleTitle = title;
        [[weakSelf currentRootController] pushViewControllerOnTop:newsController animated:YES];
    });
}

- (YPOTabBarController *)currentRootController {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if ([appDelegate.window.rootViewController isKindOfClass:[YPOTabBarController class]]) {
        YPOTabBarController *tabController = (YPOTabBarController*) appDelegate.window.rootViewController;
        return tabController;
    }
    return nil;
}


@end

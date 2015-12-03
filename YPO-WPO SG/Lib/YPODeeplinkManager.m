//
//  YPODeeplinkManager.m
//  YPO-WPO SG
//
//  Created by Mario Antonio A. Cape on 12/1/15.
//  Copyright © 2015 Raketeers. All rights reserved.
//

#import "YPODeeplinkManager.h"
#import "EventDetailsViewController.h"
#import "YPOTabBarController.h"
#import "AppDelegate.h"
#import "MemberDetailsViewController.h"
#import "NewsDetailsViewController.h"
#import "YPOArticle.h"

@interface YPODeeplinkManager()

@property (nonatomic, strong) DPLDeepLinkRouter *router;

@end

@implementation YPODeeplinkManager

+ (instancetype)sharedManager {
    static YPODeeplinkManager *sharedManager;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedManager = [[YPODeeplinkManager alloc] init];
    });
    return sharedManager;
}

- (void)setRoutes {
    __weak __typeof(self)weakSelf = self;
    self.router = [[DPLDeepLinkRouter alloc] init];
    self.router[@"event/:event_id"] = ^(DPLDeepLink *link) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            EventDetailsViewController *eventController = [storyboard instantiateViewControllerWithIdentifier:@"EventDetailsViewController"];
            eventController.eventID = link.routeParameters[@"event_id"];
            [[weakSelf currentRootController] pushViewControllerOnTop:eventController animated:YES];
        });
    };
    
    self.router[@"member/:member_id"] = ^(DPLDeepLink *link) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            MemberDetailsViewController *memberController = [storyboard instantiateViewControllerWithIdentifier:@"MemberDetailsViewController"];
            memberController.memberID = link.routeParameters[@"member_id"];
            [[weakSelf currentRootController] pushViewControllerOnTop:memberController animated:YES];
        });
    };
    
    self.router[@"article/:article_id/:title"] = ^(DPLDeepLink *link) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            NewsDetailsViewController *newsController = [storyboard instantiateViewControllerWithIdentifier:@"NewsDetailsViewController"];
            NSNumber *articleID = link.routeParameters[@"article_id"];
            NSString *articleTitle = link.routeParameters[@"title_id"];
            YPOArticle *article = [weakSelf fetchOrCreateArticleWithID:articleID];
            newsController.articleID = article.articleID.integerValue;
            newsController.articleTitle = articleTitle;
            [[weakSelf currentRootController] pushViewControllerOnTop:newsController animated:YES];
        });
    };
}

- (YPOTabBarController *)currentRootController {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if ([appDelegate.window.rootViewController isKindOfClass:[YPOTabBarController class]]) {
        YPOTabBarController *tabController = (YPOTabBarController*) appDelegate.window.rootViewController;
        return tabController;
    }
    return nil;
}

- (YPOArticle *)fetchOrCreateArticleWithID:(NSNumber *)articleID {
    NSManagedObjectContext *temporaryContext = [NSManagedObjectContext MR_contextWithParent:[NSManagedObjectContext MR_defaultContext]];
    YPOArticle *article = [YPOArticle MR_findFirstByAttribute:@"articleID" withValue:articleID inContext:temporaryContext];
    if (article == nil) {
        article = [YPOArticle MR_createEntityInContext:temporaryContext];
        article.articleID = articleID;
    }
    return article;
}


- (BOOL)handleURL:(NSURL *)url withCompletion:(DPLRouteCompletionBlock)completionHandler {
    return [self.router handleURL:url withCompletion:completionHandler];
}



@end

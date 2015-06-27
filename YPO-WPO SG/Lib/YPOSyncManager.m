//
//  YPOSyncManager.m
//  YPO-WPO SG
//
//  Created by Mario Antonio A. Cape on 6/27/15.
//  Copyright (c) 2015 Raketeers. All rights reserved.
//

#import "YPOSyncManager.h"
#import "YPOMember.h"
#import "YPOArticle.h"
#import <Bolts/Bolts.h>

NSString *const YPODataStartedLoadingNotification   = @"YPODataStartedLoadingNotification";
NSString *const YPODataFinishedLoadingNotification  = @"YPODataFinishedLoadingNotification";
NSString *const YPODataFailedToLoadNotification     = @"YPODataFailedToLoadNotification";

@interface YPOSyncManager()

@property (nonatomic, assign, readwrite, getter=isSyncing) BOOL syncing;

@end

@implementation YPOSyncManager

+ (instancetype)sharedManager {
    static YPOSyncManager *sharedManager;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedManager = [[YPOSyncManager alloc] init];
    });
    return sharedManager;
}

- (void)startSync {
    @synchronized(self){
        if (!self.isSyncing){
            self.syncing = YES;
            NSNotification *startNotification =
            [NSNotification notificationWithName:YPODataStartedLoadingNotification
                                          object:nil];
            [[NSNotificationCenter defaultCenter] postNotification:startNotification];
            
            [[[BFTask taskWithResult:nil] continueWithBlock:^id(BFTask *task) {
                NSMutableArray *parallelTask = [[NSMutableArray alloc]init];
                [parallelTask addObject:[self loadArticles]];
                [parallelTask addObject:[self loadNewMembers]];
                return [BFTask taskForCompletionOfAllTasks:parallelTask];
            }] continueWithBlock:^id(BFTask *task) {
                self.syncing = NO;
                if (task.error) {
                    NSNotification *errorNotification =
                    [NSNotification notificationWithName:YPODataFailedToLoadNotification
                                                  object:nil];
                    [[NSNotificationCenter defaultCenter] postNotification:errorNotification];
                    [[YPOErrorhandler sharedHandler]handlerError:task.error];
                } else {
                    NSNotification *errorNotification =
                    [NSNotification notificationWithName:YPODataFinishedLoadingNotification
                                                  object:nil];
                    [[NSNotificationCenter defaultCenter] postNotification:errorNotification];
                }
                return nil;
            }];
        }
    }
}


- (BFTask *)loadArticles {
    BFTaskCompletionSource *requestTask = [BFTaskCompletionSource taskCompletionSource];
    YPOArticleRequest *request = (YPOArticleRequest*)[YPOArticle constructRequest];
    [request startRequestSuccess:^(NSURLSessionDataTask *task, id responseObject) {
        [requestTask setResult:responseObject];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [requestTask setError:error];
    }];
    return requestTask.task;
}


- (BFTask *)loadNewMembers {
    BFTaskCompletionSource *requestTask = [BFTaskCompletionSource taskCompletionSource];
    YPOMemberRequest *request = (YPOMemberRequest*)[YPOMember constructRequest];
    request.newMembers = YES;
    [request startRequestSuccess:^(NSURLSessionDataTask *task, id responseObject) {
        [requestTask setResult:responseObject];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [requestTask setError:error];
    }];
    return requestTask.task;
}



@end

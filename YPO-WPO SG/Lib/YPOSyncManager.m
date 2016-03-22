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
#import "YPOChapter.h"
#import "YPOForum.h"
#import "YPORole.h"
#import "YPOEvent.h"
#import "YPOComment.h"
#import "YPOMember.h"
#import <Bolts/Bolts.h>
#import "YPOUser.h"
#import "YPOCountry.h"
#import "YPONotification.h"
#import "YPOCancellationToken.h"

NSString *const YPODataStartedLoadingNotification   = @"YPODataStartedLoadingNotification";
NSString *const YPODataFinishedLoadingNotification  = @"YPODataFinishedLoadingNotification";
NSString *const YPODataFailedToLoadNotification     = @"YPODataFailedToLoadNotification";

@interface YPOSyncManager()

@property (nonatomic, assign, readwrite, getter=isSyncing) BOOL syncing;
@property (nonatomic, strong) NSDate *syncDate;
@property (nonatomic, strong) YPOCancellationToken *cancellationToken;

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
    @synchronized(self) {
        if (!self.isSyncing){
            self.syncing = YES;
            self.syncDate = [[NSDate alloc] init];
            self.cancellationToken = [[YPOCancellationToken alloc]init];
            NSNotification *startNotification =
            [NSNotification notificationWithName:YPODataStartedLoadingNotification
                                          object:nil];
            [[NSNotificationCenter defaultCenter] postNotification:startNotification];
            
            [[[BFTask taskWithResult:nil] continueWithBlock:^id(BFTask *task) {
                NSMutableArray *parallelTask = [[NSMutableArray alloc]init];
                [parallelTask addObject:[self loadCountry:self.cancellationToken]];
                [parallelTask addObject:[self loadArticles:self.cancellationToken]];
                [parallelTask addObject:[self loadNewMembers:self.cancellationToken]];
                [parallelTask addObject:[self loadChapters:self.cancellationToken]];
                [parallelTask addObject:[self loadRoles:self.cancellationToken]];
                [parallelTask addObject:[self loadForums:self.cancellationToken]];
                [parallelTask addObject:[self loadMembers:self.cancellationToken]];
                return [BFTask taskForCompletionOfAllTasks:parallelTask];
            }] continueWithBlock:^id(BFTask *task) {
                self.syncing = NO;
                if (task.error) {
                    NSNotification *errorNotification =
                    [NSNotification notificationWithName:YPODataFailedToLoadNotification
                                                  object:nil];
                    [[NSNotificationCenter defaultCenter] postNotification:errorNotification];
                    [[YPOErrorhandler sharedHandler]handleError:task.error];
                } else {
                    [YPOMember purgeDataPriorToSyncDate:self.syncDate];                    
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


- (BFTask *)loadArticles:(YPOCancellationToken *)cancellationToken {
    BFTaskCompletionSource *requestTask = [BFTaskCompletionSource taskCompletionSource];
    YPOArticleRequest *request = (YPOArticleRequest*)[YPOArticle constructRequest:cancellationToken];
    [request startRequestSuccess:^(NSURLSessionDataTask *task, id responseObject) {
        [requestTask setResult:responseObject];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [requestTask setError:error];
    }];
    return requestTask.task;
}


- (BFTask *)loadNewMembers:(YPOCancellationToken *)cancellationToken {
    BFTaskCompletionSource *requestTask = [BFTaskCompletionSource taskCompletionSource];
    YPOMemberRequest *request = (YPOMemberRequest*)[YPOMember constructRequest:cancellationToken];
    request.newMembers = YES;
    request.dateSynced = self.syncDate;
    [request startRequestSuccess:^(NSURLSessionDataTask *task, id responseObject) {
        [requestTask setResult:responseObject];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [requestTask setError:error];
    }];
    return requestTask.task;
}


- (BFTask *)loadChapters:(YPOCancellationToken *)cancellationToken {
    BFTaskCompletionSource *requestTask = [BFTaskCompletionSource taskCompletionSource];
    YPOChapterRequest *request = (YPOChapterRequest*)[YPOChapter constructRequest:cancellationToken];
    [request startRequestSuccess:^(NSURLSessionDataTask *task, id responseObject) {
        [requestTask setResult:responseObject];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [requestTask setError:error];
    }];
    return requestTask.task;
}


- (BFTask *)loadRoles:(YPOCancellationToken *)cancellationToken {
    BFTaskCompletionSource *requestTask = [BFTaskCompletionSource taskCompletionSource];
    YPORoleRequest *request = (YPORoleRequest *)[YPORole constructRequest:cancellationToken];
    [request startRequestSuccess:^(NSURLSessionDataTask *task, id responseObject) {
        [requestTask setResult:responseObject];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [requestTask setError:error];
    }];
    return requestTask.task;
}


- (BFTask *)loadForums:(YPOCancellationToken *)cancellationToken {
    BFTaskCompletionSource *requestTask = [BFTaskCompletionSource taskCompletionSource];
    YPOForumRequest *request = (YPOForumRequest*)[YPOForum constructRequest:cancellationToken];
    [request startRequestSuccess:^(NSURLSessionDataTask *task, id responseObject) {        
        [requestTask setResult:responseObject];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [requestTask setError:error];
    }];
    return requestTask.task;
}


- (BFTask *)loadCountry:(YPOCancellationToken *)cancellationToken {
    BFTaskCompletionSource *requestTask = [BFTaskCompletionSource taskCompletionSource];
    YPOCountryRequest *request = (YPOCountryRequest *)[YPOCountry constructRequest:cancellationToken];
    [request startRequestSuccess:^(NSURLSessionDataTask *task, id responseObject) {
        [requestTask setResult:responseObject];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [requestTask setError:error];
    }];
    return requestTask.task;
}


- (BFTask *)loadMembers:(YPOCancellationToken *)cancellationToken {
//    return [[self loadMembersLastUpdate:[YPOUser currentUser].lastUpdate page:1] continueWithBlock:^id(BFTask *task) {
    return [[self loadMembersLastUpdate:nil page:1 cancellationToken:cancellationToken] continueWithBlock:^id(BFTask *task) {
        if ([task.result isKindOfClass:[NSNumber class]]) {
            NSNumber *number = task.result;
            if (number.integerValue == 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [YPOUser currentUser].lastUpdate = [NSDate new];
                });
            }
        }
        return nil;
    }];
}

- (BFTask *)loadMembersLastUpdate:(NSDate *)date page:(NSInteger)page cancellationToken:(YPOCancellationToken *)cancellationToken{
    __block BFTaskCompletionSource *requestTask = [BFTaskCompletionSource taskCompletionSource];
    [[BFTask taskWithResult:nil] continueWithBlock:^id(BFTask *task) {
        YPOMemberRequest *request = (YPOMemberRequest *)[YPOMember constructRequest:cancellationToken];
        request.lastUpdate = date;
        request.dateSynced = self.syncDate;
        request.page = page;
        [request startRequestSuccess:^(NSURLSessionDataTask *task, id responseObject) {
            NSDictionary *response = responseObject;
            NSDictionary *paging = response[@"paging"];
            NSNumber *next = paging[@"next"];
            if (next.integerValue == 0) {
                [requestTask setResult:next];
            } else {
                [[self loadMembersLastUpdate:date page:next.integerValue cancellationToken:cancellationToken]
                 continueWithBlock:^id(BFTask *task) {
                    [requestTask setResult:task.result];
                    return nil;
                }];
            }
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            [requestTask setError:error];
        }];
        return nil;
    }];
    return requestTask.task;
}

- (void)cancelSync {
    [self.cancellationToken cancel];            
    self.syncing = NO;
}


- (void)purgeAllData {
    [YPOEvent purgeData];
    [YPONotification purgeData];
    [YPONotification purgeData];
}



- (void)deleteAllData {
    [YPOEvent MR_truncateAll];
    [YPOMember MR_truncateAll];
    [YPOArticle MR_truncateAll];
    [YPOChapter MR_truncateAll];
    [YPOForum MR_truncateAll];
    [YPORole MR_truncateAll];
    [YPOComment MR_truncateAll];
    [YPONotification MR_truncateAll];
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];    
}

@end

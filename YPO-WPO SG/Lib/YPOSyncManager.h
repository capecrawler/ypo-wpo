//
//  YPOSyncManager.h
//  YPO-WPO SG
//
//  Created by Mario Antonio A. Cape on 6/27/15.
//  Copyright (c) 2015 Raketeers. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const YPODataStartedLoadingNotification;
extern NSString *const YPODataFinishedLoadingNotification;
extern NSString *const YPODataFailedToLoadNotification;

@interface YPOSyncManager : NSObject

@property (nonatomic, assign, readonly, getter=isSyncing) BOOL syncing;

+ (instancetype)sharedManager;

- (void)startSync;

@end

//
//  YPONotificationManager.h
//  YPO-WPO SG
//
//  Created by Mario Antonio A. Cape on 12/2/15.
//  Copyright © 2015 Raketeers. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YPONotificationManager : NSObject

+ (instancetype)sharedManager;

- (void)handleNotification:(NSDictionary *)notification;


@end

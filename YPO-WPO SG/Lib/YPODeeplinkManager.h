//
//  YPODeeplinkManager.h
//  YPO-WPO SG
//
//  Created by Mario Antonio A. Cape on 12/1/15.
//  Copyright © 2015 Raketeers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DeepLinkKit/DeepLinkKit.h>

@interface YPODeeplinkManager: NSObject

+ (instancetype)sharedManager;
- (void)setRoutes;
- (BOOL)handleURL:(NSURL *)url withCompletion:(DPLRouteCompletionBlock)completionHandler;

@end

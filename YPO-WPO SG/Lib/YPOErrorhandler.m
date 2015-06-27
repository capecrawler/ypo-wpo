//
//  YPOErrorhandler.m
//  YPO-WPO SG
//
//  Created by Mario Antonio A. Cape on 6/27/15.
//  Copyright (c) 2015 Raketeers. All rights reserved.
//

#import "YPOErrorhandler.h"

@implementation YPOErrorhandler

+ (instancetype)sharedHandler {
    static YPOErrorhandler *sharedHandler = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedHandler = [[YPOErrorhandler alloc] init];
    });
    return sharedHandler;
}


- (void) handlerError:(NSError *)error {    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:self cancelButtonTitle:NSLocalizedString(@"Ok", @"Alert Ok button label") otherButtonTitles: nil];
    [alertView show];
}

@end

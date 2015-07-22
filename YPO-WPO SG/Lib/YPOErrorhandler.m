//
//  YPOErrorhandler.m
//  YPO-WPO SG
//
//  Created by Mario Antonio A. Cape on 6/27/15.
//  Copyright (c) 2015 Raketeers. All rights reserved.
//

#import "YPOErrorhandler.h"
#import <Bolts/Bolts.h>

@implementation YPOErrorhandler

+ (instancetype)sharedHandler {
    static YPOErrorhandler *sharedHandler = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedHandler = [[YPOErrorhandler alloc] init];
    });
    return sharedHandler;
}


- (void) handleError:(NSError *)error {
    NSError *catchError = [self extractErrorFromTaskError:error];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:catchError.localizedDescription delegate:self cancelButtonTitle:NSLocalizedString(@"Ok", @"Alert Ok button label") otherButtonTitles: nil];
    [alertView show];
}

- (NSError *)extractErrorFromTaskError:(NSError *)taskError {
    if ([taskError.domain isEqualToString:BFTaskErrorDomain]) {
        if (taskError.code == kBFMultipleErrorsError) {
            NSArray *errors = taskError.userInfo[@"errors"];
            return [errors firstObject];
        } else {
            return taskError;
        }
    } else {
        return taskError;
    }
}

@end

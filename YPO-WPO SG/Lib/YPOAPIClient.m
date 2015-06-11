//
//  YPOAPIClient.m
//  YPO-WPO SG
//
//  Created by Mario Antonio A. Cape on 6/11/15.
//  Copyright (c) 2015 Raketeers. All rights reserved.
//

#import "YPOAPIClient.h"

@implementation YPOAPIClient

+ (instancetype)sharedClient {
    static YPOAPIClient * _sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[YPOAPIClient alloc] initWithBaseURL:@""];
    });
    return _sharedClient;
}

@end

//
//  YPOAPIClient.h
//  YPO-WPO SG
//
//  Created by Mario Antonio A. Cape on 6/11/15.
//  Copyright (c) 2015 Raketeers. All rights reserved.
//

#import "AFHTTPSessionManager.h"

@interface YPOAPIClient : AFHTTPSessionManager

+ (instancetype)sharedClient;

@end

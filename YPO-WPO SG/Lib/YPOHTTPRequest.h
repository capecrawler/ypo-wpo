//
//  YPOHTTPRequest.h
//  YPO-WPO SG
//
//  Created by Mario Cape on 6/24/15.
//  Copyright (c) 2015 Raketeers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YPOCancellationToken.h"

typedef NS_ENUM(NSUInteger, HTTPMethod) {
    HTTPMethodGET = 0,
    HTTPMethodPOST,
};


@interface YPOHTTPRequest : NSObject

@property (nonatomic, strong) NSString *function;
@property (nonatomic, assign) HTTPMethod method;
@property (nonatomic, strong) NSString *apiPath;
@property (nonatomic, strong) NSDictionary *params;
@property (nonatomic, assign) BOOL useJSONLoader;
@property (nonatomic, strong) YPOCancellationToken * cancellationToken;

- (void)startRequest;
- (void)startRequestSuccess:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                    failure:(void (^)(NSURLSessionDataTask *task, NSError *error)) failure;
- (void)loadJSONObject:(id)jsonObject;
- (void)beforeLoadJSON:(id)jsonObject;
- (void)endLoadJSON:(id)jsonObject;
@end

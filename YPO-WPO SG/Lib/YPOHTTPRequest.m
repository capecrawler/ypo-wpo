//
//  YPOHTTPRequest.m
//  YPO-WPO SG
//
//  Created by Mario Cape on 6/24/15.
//  Copyright (c) 2015 Raketeers. All rights reserved.
//

#import "YPOHTTPRequest.h"
#import "YPOAPIClient.h"

@implementation YPOHTTPRequest


- (id)init {
    self = [super init];
    if (self) {
        self.method = HTTPMethodGET;
        self.apiPath = @"/ypo/api/v1/";
        self.useJSONLoader = YES;
    }
    return self;
}


- (void)startRequest {
    [self startRequestSuccess:nil failure:nil];
}


- (void)startRequestSuccess:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                    failure:(void (^)(NSURLSessionDataTask *task, NSError *error)) failure {
    
    switch (self.method) {
        case HTTPMethodGET:
            [self executeGETSuccess:success failure:failure];
            break;
        case HTTPMethodPOST:
            [self executePOSTSuccess:success failure:failure];
            break;
        default:
            break;
    }
}


- (void)executeGETSuccess:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                  failure:(void (^)(NSURLSessionDataTask *task, NSError *error)) failure {
    [[YPOAPIClient sharedClient] GET:self.apiPath parameters:self.params success:^(NSURLSessionDataTask *task, id responseObject) {
        if (self.useJSONLoader) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self beforeLoadJSON:responseObject];
                [self loadJSONObject:responseObject];
                [self endLoadJSON:responseObject];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (success) {
                        success(task, responseObject);
                    }
                });
            });
        } else {
            if (success) {
                success(task, responseObject);
            }
        }
    } failure:failure];
}


- (void)executePOSTSuccess:(void (^)(NSURLSessionDataTask *task, id reponseObject))success
                   failure:(void (^)(NSURLSessionDataTask *task, NSError *error)) failure {
    [[YPOAPIClient sharedClient] POST:self.apiPath parameters:self.params success:success failure:failure];
}


- (NSDictionary *)params {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:_params];
    [params setObject:self.function forKey:@"func"];
    return params;
}


- (void) loadJSONObject:(id)jsonObject {
    // must be overriden
}

- (void)beforeLoadJSON:(id)jsonObject {
    
}

- (void)endLoadJSON:(id)jsonObject {
    
}

@end

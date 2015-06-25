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
    }
    return self;
}


- (void)startRequest {
    [self startRequestSuccess:nil failure:nil];
}


- (void)startRequestSuccess:(void (^)(NSURLSessionDataTask *task, id reponseObject))success
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


- (void)executeGETSuccess:(void (^)(NSURLSessionDataTask *task, id reponseObject))success
                  failure:(void (^)(NSURLSessionDataTask *task, NSError *error)) failure {
    [[YPOAPIClient sharedClient] GET:self.apiPath parameters:self.params success:success failure:failure];
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


@end

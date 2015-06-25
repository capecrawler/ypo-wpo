//
//  YPOHTTPRequestSerializer.m
//  YPO-WPO SG
//
//  Created by Mario Cape on 6/24/15.
//  Copyright (c) 2015 Raketeers. All rights reserved.
//

#import "YPOHTTPRequestSerializer.h"

@implementation YPOHTTPRequestSerializer

- (NSURLRequest *)requestBySerializingRequest:(NSURLRequest *)request withParameters:(id)parameters error:(NSError *__autoreleasing *)error {
    if ([parameters isKindOfClass:[NSDictionary class]] || [parameters isKindOfClass:[NSMutableDictionary class]]) {
        NSMutableDictionary * params = [[NSMutableDictionary alloc] initWithDictionary:parameters];
        [params setObject:YPOAccessID forKey:@"access_id"];
        [params setObject:YPOSecretKey forKey:@"secret_key"];
        return [super requestBySerializingRequest:request withParameters:params error:error];
    } else {
        return [super requestBySerializingRequest:request withParameters:parameters error:error];
    }
}

@end

//
//  YPORemoteManagedObject.m
//  YPO-WPO SG
//
//  Created by Mario Cape on 6/23/15.
//  Copyright (c) 2015 Raketeers. All rights reserved.
//

#import "YPORemoteManagedObject.h"

@implementation YPORemoteManagedObject

- (void)parseDictionary:(NSDictionary *)dictionary {
    
}

+ (YPOHTTPRequest *)constructRequest:(YPOCancellationToken *)cancellationToken {
    YPOHTTPRequest * request = [[YPOHTTPRequest alloc] init];
    request.cancellationToken = cancellationToken;
    return request;
}


@end

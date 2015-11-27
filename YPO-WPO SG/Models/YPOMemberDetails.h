//
//  YPOMemberDetails.h
//  YPO-WPO SG
//
//  Created by Mario Antonio A. Cape on 6/28/15.
//  Copyright (c) 2015 Raketeers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YPOHTTPRequest.h"

@class YPOMember;

@interface YPOMemberDetails : NSObject

@property (nonatomic, strong) NSNumber *memberID;
@property (nonatomic, strong) NSManagedObjectContext *context;

- (void)parseDictionary:(NSDictionary *)dictionary;
+ (YPOHTTPRequest *)constructRequest:(YPOCancellationToken *)cancellationToken;
@end


@interface YPOMemberDetailsRequest : YPOHTTPRequest
@property (nonatomic, strong) NSNumber *memberID;

@end
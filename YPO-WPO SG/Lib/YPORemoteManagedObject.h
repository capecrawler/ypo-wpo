//
//  YPORemoteManagedObject.h
//  YPO-WPO SG
//
//  Created by Mario Cape on 6/23/15.
//  Copyright (c) 2015 Raketeers. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "YPOHTTPRequest.h"

@interface YPORemoteManagedObject : NSManagedObject

- (void)parseDictionary:(NSDictionary *)dictionary;

+ (YPOHTTPRequest *)constructRequest:(YPOCancellationToken *)cancellationToken;


@end

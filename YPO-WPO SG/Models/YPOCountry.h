//
//  YPOCountry.h
//  YPO-WPO SG
//
//  Created by Mario Antonio A. Cape on 8/26/15.
//  Copyright (c) 2015 Raketeers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YPORemoteManagedObject.h"


@interface YPOCountry : YPORemoteManagedObject

@property (nonatomic, retain) NSNumber * countryID;
@property (nonatomic, retain) NSString * name;

@end


@interface YPOCountryRequest : YPOHTTPRequest

@end

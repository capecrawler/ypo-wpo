//
//  YPOContactDetails.m
//  YPO-WPO SG
//
//  Created by Mario Antonio A. Cape on 6/28/15.
//  Copyright (c) 2015 Raketeers. All rights reserved.
//

#import "YPOContactDetails.h"
#import "YPOMember.h"


@implementation YPOContactDetails

@dynamic business;
@dynamic email;
@dynamic home;
@dynamic mobile;
@dynamic member;

- (void)parseDictionary:(NSDictionary *)dictionary {
    [super parseDictionary:dictionary];
    self.email = dictionary[@"email"];
    self.mobile = dictionary[@"mobile"];
    self.home = dictionary[@"home"];
    self.business = dictionary[@"business"];
}


@end

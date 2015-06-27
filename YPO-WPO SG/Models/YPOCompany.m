//
//  YPOCompany.m
//  YPO-WPO SG
//
//  Created by Mario Antonio A. Cape on 6/28/15.
//  Copyright (c) 2015 Raketeers. All rights reserved.
//

#import "YPOCompany.h"
#import "YPOMember.h"


@implementation YPOCompany

@dynamic address1;
@dynamic address2;
@dynamic business;
@dynamic city;
@dynamic country;
@dynamic countryID;
@dynamic name;
@dynamic position;
@dynamic province;
@dynamic website;
@dynamic zip;
@dynamic member;

- (void)parseDictionary:(NSDictionary *)dictionary {
    [super parseDictionary:dictionary];
    self.name = dictionary[@"name"];
    self.business = dictionary[@"business"];
    self.position = dictionary[@"position"];
    self.address1 = dictionary[@"address1"];
    self.address2 = dictionary[@"address2"];
    self.city = dictionary[@"city"];
    self.province = dictionary[@"province"];
    self.zip = dictionary[@"zip_code"];
    self.countryID = dictionary[@"country_id"];
    self.country = dictionary[@"country"];
    self.website = dictionary[@"website"];
}


@end

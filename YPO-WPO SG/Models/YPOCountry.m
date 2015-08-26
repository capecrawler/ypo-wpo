//
//  YPOCountry.m
//  YPO-WPO SG
//
//  Created by Mario Antonio A. Cape on 8/26/15.
//  Copyright (c) 2015 Raketeers. All rights reserved.
//

#import "YPOCountry.h"


@implementation YPOCountry

@dynamic countryID;
@dynamic name;


- (void)parseDictionary:(NSDictionary *)dictionary {
    [super parseDictionary:dictionary];
    self.countryID = dictionary[@"country_id"];
    self.name = dictionary[@"name"];
}

+ (YPOHTTPRequest *)constructRequest {
    YPOCountryRequest *request = [[YPOCountryRequest alloc] init];
    request.function = @"country.list";
    return request;
}

@end

@implementation  YPOCountryRequest

- (void)loadJSONObject:(NSDictionary *)jsonObject {
    if ([jsonObject[@"status"] boolValue]) {
        NSArray *data = jsonObject[@"data"];
        [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
            for (NSDictionary *raw in data) {
                YPOCountry * country = [YPOCountry MR_findFirstByAttribute:@"countryID" withValue:raw[@"country_id"] inContext:localContext];
                if (country == nil) {
                    country = [YPOCountry MR_createEntityInContext:localContext];
                }
                [country parseDictionary:raw];
            }
        }];
    }
}

@end
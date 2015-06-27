//
//  YPOMemberDetails.m
//  YPO-WPO SG
//
//  Created by Mario Antonio A. Cape on 6/28/15.
//  Copyright (c) 2015 Raketeers. All rights reserved.
//

#import "YPOMemberDetails.h"
#import "YPOMember.h"
#import "YPOCompany.h"
#import "YPOContactDetails.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface YPOMemberDetails()



@end


@implementation YPOMemberDetails

- (void)parseDictionary:(NSDictionary *)dictionary {
    YPOMember *member = [YPOMember MR_findFirstByAttribute:@"memberID" withValue:self.memberID inContext:self.context];
    if (member != nil) {
        NSDictionary *contactRaw = dictionary[@"contact"];
        NSDictionary *companyRaw = dictionary[@"company"];
        
        YPOCompany *company = member.company;
        if (company == nil) {
            company = [YPOCompany MR_createEntityInContext:self.context];
            member.company = company;
        }
        [company parseDictionary:companyRaw];
        
        YPOContactDetails *contactDetails = member.contactDetails;
        if (contactDetails == nil) {
            contactDetails = [YPOContactDetails MR_createEntityInContext:self.context];
            member.contactDetails = contactDetails;
        }
        [contactDetails parseDictionary:contactRaw];
    }
}


+ (YPOHTTPRequest *)constructRequest {
    YPOMemberDetailsRequest *request = [[YPOMemberDetailsRequest alloc] init];
    request.function = @"members.details";
    return request;
}


@end


@implementation YPOMemberDetailsRequest


- (NSDictionary *)params {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:[super params]];
    [params setObject:self.memberID forKey:@"member_id"];
    return params;
}


- (void) loadJSONObject:(NSDictionary *)jsonObject {
    if ([jsonObject[@"status"] boolValue]) {
        NSDictionary *data = jsonObject[@"data"];
        [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
            YPOMemberDetails * memberDetails = [[YPOMemberDetails alloc]init];
            memberDetails.memberID = self.memberID;
            memberDetails.context = localContext;
            [memberDetails parseDictionary:data];
        }];
    }
}



@end
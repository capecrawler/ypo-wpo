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
#import "YPORole.h"
#import "YPOChapter.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface YPOMemberDetails()



@end


@implementation YPOMemberDetails

- (void)parseDictionary:(NSDictionary *)dictionary {
    YPOMember *member = [YPOMember MR_findFirstByAttribute:@"memberID" withValue:self.memberID inContext:self.context];
    [member parseDictionary:dictionary];    
    if (member != nil) {
        
        NSNumber *chapterID = dictionary[@"chapter_id"];
        YPOChapter *chapter = [YPOChapter MR_findFirstByAttribute:@"chapterID" withValue:chapterID inContext:self.context];
        member.chapterID = chapterID;
        member.chapterOrg = chapter;        
        
        NSDictionary    *contactRaw = dictionary[@"contact"];
        NSDictionary    *companyRaw = dictionary[@"company"];
        NSArray         *roles      = dictionary[@"role"];
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
        
        
        
        for (NSDictionary *roleRaw in roles) {
            NSNumber *roleID = roleRaw[@"role_id"];
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"roleID == %@", roleID];
            NSSet *roleAssigned = [member.role filteredSetUsingPredicate:predicate];
            if (roleAssigned.count == 0) {
                YPORole *role = [YPORole MR_findFirstByAttribute:@"roleID" withValue:roleID inContext:self.context];
                [member addRoleObject:role];
            }
        }
    }
}


+ (YPOHTTPRequest *)constructRequest:(YPOCancellationToken *)cancellationToken {
    YPOMemberDetailsRequest *request = [[YPOMemberDetailsRequest alloc] init];
    request.cancellationToken = cancellationToken;
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
            YPOMember * member = [YPOMember MR_findFirstByAttribute:@"memberID" withValue:data[@"member_id"] inContext:localContext];
            if (member == nil) {
                member = [YPOMember MR_createEntityInContext:localContext];
            }
            [member parseDictionary:data];
            NSLog(@"member url: %@", member.profilePicURL);
            YPOMemberDetails * memberDetails = [[YPOMemberDetails alloc]init];
            memberDetails.memberID = self.memberID;
            memberDetails.context = localContext;
            [memberDetails parseDictionary:data];
        }];
    }
}



@end
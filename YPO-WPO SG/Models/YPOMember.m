//
//  YPOMember.m
//  YPO-WPO SG
//
//  Created by Mario Cape on 6/24/15.
//  Copyright (c) 2015 Raketeers. All rights reserved.
//

#import "YPOMember.h"
#import "YPORole.h"
#import "YPOContactDetails.h"
#import "YPOCompany.h"
#import "YPOAPIClient.h"
#import "YPOForum.h"
#import "YPOChapter.h"

@implementation YPOMember

@dynamic chapterID;
@dynamic firstName;
@dynamic lastName;
@dynamic memberID;
@dynamic name;
@dynamic nickname;
@dynamic profilePicURL;
@dynamic joinedDate;
@dynamic role;
@dynamic middleName;
@dynamic chapter;
@dynamic company;
@dynamic contactDetails;
@dynamic forum;
@dynamic chapterOrg;

- (void)parseDictionary:(NSDictionary *)dictionary {
    [super parseDictionary:dictionary];    
    self.memberID = dictionary[@"member_id"];
    self.profilePicURL = dictionary[@"profile_picture_url"];
    self.name = dictionary[@"name"];
    self.firstName = dictionary[@"first_name"];
    self.lastName = dictionary[@"last_name"];
    self.middleName = dictionary[@"middle_name"];
    self.nickname = dictionary[@"nickname"];
    self.chapterID = dictionary[@"chapter_id"];
    self.chapter = dictionary[@"chapter"];
    NSString * joinedDate = dictionary[@"chapter_joined"];
    self.joinedDate = [NSDate dateFromString:joinedDate format:ISODateFormat];
}


+ (YPOMemberRequest *)constructRequest {
    YPOMemberRequest *request = [[YPOMemberRequest alloc] init];
    request.function = @"members.list";
    return request;
}

@end


@implementation YPOMemberRequest

- (id)init {
    self = [super init];
    if (self) {
        self.newMembers = NO;
        self.roleID = -1;
        self.chapterID = -1;
        self.forumID = -1;
        self.page = 1;
        self.rowCount = 15;
    }
    return self;
}


- (NSDictionary *)params {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:[super params]];
    [params setObject:@(self.page) forKey:@"page"];
    [params setObject:@(self.rowCount) forKey:@"row_count"];
    [params setObject:@(self.newMembers) forKey:@"new_members"];
    if (self.roleID != -1) {
        [params setObject:@(self.roleID) forKey:@"role_id"];
    }
    if (self.chapterID != -1) {
        [params setObject:@(self.chapterID) forKey:@"chapter_id"];
    }
    if (self.forumID != -1) {
        [params setObject:@(self.forumID) forKey:@"forum_id"];
    }
    return params;
}


- (void) loadJSONObject:(NSDictionary *)jsonObject {
    if ([jsonObject[@"status"] boolValue]) {
        NSArray *data = jsonObject[@"data"];
        [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
            for (NSDictionary *raw in data) {
                YPOMember * member = [YPOMember MR_findFirstByAttribute:@"memberID" withValue:raw[@"member_id"] inContext:localContext];
                if (member == nil) {
                    member = [YPOMember MR_createEntityInContext:localContext];
                }
                [member parseDictionary:raw];
            }
        }];
    }
}


@end


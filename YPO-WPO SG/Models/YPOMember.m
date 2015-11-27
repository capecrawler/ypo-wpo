//
//  YPOMember.m
//  YPO-WPO SG
//
//  Created by Mario Antonio A. Cape on 6/30/15.
//  Copyright (c) 2015 Raketeers. All rights reserved.
//

#import "YPOMember.h"
#import "YPOChapter.h"
#import "YPOCompany.h"
#import "YPOContactDetails.h"
#import "YPOForum.h"
#import "YPORole.h"


@implementation YPOMember

@dynamic chapter;
@dynamic chapterID;
@dynamic firstName;
@dynamic joinedDate;
@dynamic lastName;
@dynamic memberID;
@dynamic middleName;
@dynamic name;
@dynamic nickname;
@dynamic profilePicURL;
@dynamic company;
@dynamic contactDetails;
@dynamic role;
@dynamic chapterOrg;
@dynamic forum;
@dynamic memberType;
@dynamic gender;
@dynamic birthdate;
@dynamic lastModifiedDate;
@dynamic passion;
@dynamic managementCommittee;
@dynamic managementCommitteeOrder;
@dynamic dateSynced;


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
    self.gender = dictionary[@"gender"];
    
    NSNumber *memberTypeID = dictionary[@"member_type_id"];
    if (memberTypeID != nil) {
        self.memberType = memberTypeID;
    }
    NSString *birthdate = dictionary[@"birth_date"];
    if (birthdate != nil) {
        self.birthdate = [NSDate dateFromString:birthdate format:ISODateFormat];
    }
    NSString * joinedDate = dictionary[@"chapter_joined"];
    self.joinedDate = [NSDate dateFromString:joinedDate format:ISODateFormat];
    NSString * passion = dictionary[@"passion"];
    if (passion != nil) {
        self.passion = passion;
    }
}


+ (YPOMemberRequest *)constructRequest:(YPOCancellationToken *)cancellationToken {
    YPOMemberRequest *request = [[YPOMemberRequest alloc] init];
    request.cancellationToken = cancellationToken;
    request.function = @"members.list";
    return request;
}

- (NSString *)firstLetterName {
    return [self.name substringToIndex:1];
}

- (NSString *)joinedDateFormatted {
    if (self.joinedDate == nil) return @"";
    return [self.joinedDate stringWithFormat:@"dd MMMM YYYY"];
}

- (NSString *)birthdateFormatted {
    if (self.birthdate == nil)return @"";
    return [self.birthdate stringWithFormat:@"dd MMMM YYYY"];
}

- (NSString *)genderLabel {
    if ([[self.gender lowercaseString] isEqual:@"m"]) {
        return NSLocalizedString(@"Male", nil);
    } else if ([[self.gender lowercaseString] isEqual:@"f"]) {
        return NSLocalizedString(@"Female", nil);
    } else {
        return @"";
    }
}

+ (void)purgeDataPriorToSyncDate:(NSDate *)lastSyncDate {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"dateSynced < %@", lastSyncDate];
    NSArray *deletedMembers = [YPOMember MR_findAllWithPredicate:predicate inContext:[NSManagedObjectContext MR_defaultContext]];
    for (YPOMember *member in deletedMembers) {
        [member MR_deleteEntityInContext:[NSManagedObjectContext MR_defaultContext]];
    }
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
        if (self.forumID == -99) {
            [params setObject:@"not-in-local-forum" forKey:@"forum_id"];
        } else {
            [params setObject:@(self.forumID) forKey:@"forum_id"];
        }
    }
    if (self.managementCommittee) {
        [params setObject:@(YES) forKey:@"management_committee"];
    }
    [params setObject:@(self.memberTypeID) forKey:@"member_type_id"];
    if (self.lastUpdate != nil) {
        NSString *date = [self.lastUpdate stringWithFormat:@"yyyy-MM-dd HH:mm:ss"];
        [params setObject:date forKey:@"last_modified"];
    }
    
    
    return params;
}


- (void)loadJSONObject:(NSDictionary *)jsonObject {
    if ([jsonObject[@"status"] boolValue]) {
        NSArray *data = jsonObject[@"data"];
        [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
            
            if (self.managementCommittee && self.page == 1) {
                [self purgeManagementCommiteeInContext:localContext];
            }
            NSInteger latestManagementCommitteeOrder = [self latestOrderOfManagementCommittee:localContext] + 1;
            for (NSDictionary *raw in data) {
                NSNumber *memberID = raw[@"member_id"];
                YPOMember * member = [YPOMember MR_findFirstByAttribute:@"memberID" withValue:memberID inContext:localContext];
                if (member == nil) {
                    member = [YPOMember MR_createEntityInContext:localContext];
                }
                [member parseDictionary:raw];
                member.dateSynced = self.dateSynced;
//                member.memberType = @(self.memberTypeID);
                if (self.managementCommittee) {
                    member.managementCommittee = @(YES);
                    member.managementCommitteeOrder = @(latestManagementCommitteeOrder++);
                }
                
                NSNumber *chapterID = raw[@"chapter_id"];
                if (chapterID != nil) {
                    YPOChapter *chapter = [YPOChapter MR_findFirstByAttribute:@"chapterID" withValue:chapterID inContext:localContext];
                    if (chapter != nil)
                        member.chapterOrg = chapter;
                }
                
                if (self.chapterID != -1) {
                    YPOChapter *chapter = [YPOChapter MR_findFirstByAttribute:@"chapterID" withValue:@(self.chapterID) inContext:localContext];
                    if (chapter != nil)
                        member.chapterOrg = chapter;
                } else if (self.forumID != -1) {
                    YPOForum *forum = [YPOForum MR_findFirstByAttribute:@"forumID" withValue:@(self.forumID) inContext:localContext];
                    if (forum != nil)
                        [forum addMembersObject:member];
                }
                
                NSArray *roles = raw[@"role"];
                for (NSDictionary *roleRaw in roles) {
                    NSNumber *roleID = roleRaw[@"role_id"];
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"roleID == %@", roleID];
                    NSSet *roleAssigned = [member.role filteredSetUsingPredicate:predicate];
                    if (roleAssigned.count == 0) {
                        YPORole *role = [YPORole MR_findFirstByAttribute:@"roleID" withValue:roleID inContext:localContext];
                        [member addRoleObject:role];
                    }
                }
            }
        }];
    }
}


- (void)purgeManagementCommiteeInContext:(NSManagedObjectContext *)context {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"managementCommittee == %@", @(YES)];
    NSArray *committee = [YPOMember MR_findAllWithPredicate:predicate inContext:context];
    for (YPOMember *member in committee) {
        member.managementCommittee = @(NO);
        member.managementCommitteeOrder = @(0);
    }
    
}

- (NSInteger)latestOrderOfManagementCommittee:(NSManagedObjectContext *)context {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"managementCommittee == %@", @(YES)];
    YPOMember *member = [YPOMember MR_findFirstWithPredicate:predicate sortedBy:@"managementCommitteeOrder" ascending:NO inContext:context];
    if (member) {
        return member.managementCommitteeOrder.integerValue;
    }
    return 0;
}



@end

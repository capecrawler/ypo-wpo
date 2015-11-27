//
//  YPOMember.h
//  YPO-WPO SG
//
//  Created by Mario Antonio A. Cape on 6/30/15.
//  Copyright (c) 2015 Raketeers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YPORemoteManagedObject.h"

typedef NS_ENUM(NSUInteger, MemberTypeID) {
    MemberTypeAll = 0,
    MemberTypeMembers,
    MemberTypeContributors,
    MemberTypeChapterAdmin,
    MemberTypeManagementCommittee,
};

@class YPOChapter, YPOCompany, YPOContactDetails, YPOForum, YPORole, YPOCountry;

@interface YPOMember : YPORemoteManagedObject

@property (nonatomic, retain) NSString * chapter;
@property (nonatomic, retain) NSNumber * chapterID;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSDate * joinedDate;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSNumber * memberID;
@property (nonatomic, retain) NSString * middleName;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * gender;
@property (nonatomic, retain) NSString * nickname;
@property (nonatomic, retain) NSString * profilePicURL;
@property (nonatomic, retain) NSNumber * memberType;
@property (nonatomic, retain) NSDate * birthdate;
@property (nonatomic, retain) YPOCompany *company;
@property (nonatomic, retain) YPOContactDetails *contactDetails;
@property (nonatomic, retain) NSSet *role;
@property (nonatomic, retain) YPOChapter *chapterOrg;
@property (nonatomic, retain) NSSet *forum;
@property (nonatomic, retain) NSDate *lastModifiedDate;
@property (nonatomic, retain) NSString *passion;
@property (nonatomic, retain) NSNumber *managementCommittee;
@property (nonatomic, retain) NSNumber *managementCommitteeOrder;
@property (nonatomic, retain) NSDate *dateSynced;
@end

@interface YPOMember (CoreDataGeneratedAccessors)

- (void)addRoleObject:(YPORole *)value;
- (void)removeRoleObject:(YPORole *)value;
- (void)addRole:(NSSet *)values;
- (void)removeRole:(NSSet *)values;

- (void)addForumObject:(YPOForum *)value;
- (void)removeForumObject:(YPOForum *)value;
- (void)addForum:(NSSet *)values;
- (void)removeForum:(NSSet *)values;
- (NSString *)firstLetterName;
- (NSString *)joinedDateFormatted;
- (NSString *)birthdateFormatted;
- (NSString *)genderLabel;
+ (void)purgeDataPriorToSyncDate:(NSDate *)lastSyncDate;

@end


@interface YPOMemberRequest : YPOHTTPRequest

@property (nonatomic, assign) BOOL newMembers;
@property (nonatomic, assign) NSInteger roleID;
@property (nonatomic, assign) NSInteger chapterID;
@property (nonatomic, assign) NSInteger forumID;
@property (nonatomic, assign) NSDate *lastUpdate;
@property (nonatomic, assign) NSUInteger page;
@property (nonatomic, assign) NSInteger rowCount;
@property (nonatomic, assign) MemberTypeID memberTypeID;
@property (nonatomic, assign) BOOL managementCommittee;
@property (nonatomic, strong) NSDate *dateSynced;

@end

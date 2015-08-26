//
//  YPOUser.m
//  YPO-WPO SG
//
//  Created by Mario Antonio A. Cape on 8/3/15.
//  Copyright (c) 2015 Raketeers. All rights reserved.
//

#import "YPOUser.h"

static YPOUser * __currentUser = nil;
static NSString * const kYPOUserMemberIdKey = @"memberID";

@implementation YPOUser

@dynamic memberID;
@dynamic name;
@dynamic email;
@dynamic userName;
@dynamic profilePictureURL;
@dynamic lastUpdate;

- (void)parseDictionary:(NSDictionary *)dictionary {
    self.memberID = dictionary[@"member_id"];
    self.name = dictionary[@"name"];
    self.email = dictionary[@"email"];
    self.profilePictureURL = dictionary[@"profile_picture_url"];
    self.userName = dictionary[@"username"];
}


+ (YPOUser *)currentUser {
    if (__currentUser == nil) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSNumber *memberID = [userDefaults objectForKey:kYPOUserMemberIdKey];
        if (!memberID)return nil;
        __currentUser = [YPOUser MR_findFirstByAttribute:@"memberID" withValue:memberID];
    }
    return __currentUser;
}


+ (void)setCurrentUser:(YPOUser *)user {
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    if (!user){
        __currentUser = nil;
        [userDefaults removeObjectForKey:kYPOUserMemberIdKey];
        NSManagedObjectContext * context = [NSManagedObjectContext MR_defaultContext];
        [YPOUser MR_truncateAllInContext:context];
        [context MR_saveToPersistentStoreAndWait];
    }else{
        __currentUser = user;
        [userDefaults setObject:user.memberID forKey:kYPOUserMemberIdKey];
    }
    [userDefaults synchronize];
}

@end

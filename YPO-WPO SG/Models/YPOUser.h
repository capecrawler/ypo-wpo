//
//  YPOUser.h
//  YPO-WPO SG
//
//  Created by Mario Antonio A. Cape on 8/3/15.
//  Copyright (c) 2015 Raketeers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "YPOMember.h"


@interface YPOUser : NSManagedObject

@property (nonatomic, retain) NSNumber * memberID;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * userName;
@property (nonatomic, retain) NSString * profilePictureURL;

+ (YPOUser *)currentUser;
+ (void)setCurrentUser:(YPOUser *)user;
- (void)parseDictionary:(NSDictionary *)dictionary;
@end

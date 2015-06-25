//
//  YPOMember.h
//  YPO-WPO SG
//
//  Created by Mario Cape on 6/24/15.
//  Copyright (c) 2015 Raketeers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YPORemoteManagedObject.h"

@class YPORole;

@interface YPOMember : YPORemoteManagedObject

@property (nonatomic, retain) NSNumber * chapterID;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSNumber * memberID;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * nickname;
@property (nonatomic, retain) NSString * profilePicURL;
@property (nonatomic, retain) NSDate * joinedDate;
@property (nonatomic, retain) YPORole *role;

@end

//
//  YPORole.h
//  YPO-WPO SG
//
//  Created by Mario Cape on 6/24/15.
//  Copyright (c) 2015 Raketeers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class YPOMember;

@interface YPORole : NSManagedObject

@property (nonatomic, retain) NSNumber * roleID;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *member;
@end

@interface YPORole (CoreDataGeneratedAccessors)

- (void)addMemberObject:(YPOMember *)value;
- (void)removeMemberObject:(YPOMember *)value;
- (void)addMember:(NSSet *)values;
- (void)removeMember:(NSSet *)values;

@end

//
//  YPOChapter.h
//  YPO-WPO SG
//
//  Created by Mario Antonio A. Cape on 6/30/15.
//  Copyright (c) 2015 Raketeers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YPORemoteManagedObject.h"

@class YPOMember;

@interface YPOChapter : YPORemoteManagedObject

@property (nonatomic, retain) NSNumber * chapterID;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *members;
@end

@interface YPOChapter (CoreDataGeneratedAccessors)

- (void)addMembersObject:(YPOMember *)value;
- (void)removeMembersObject:(YPOMember *)value;
- (void)addMembers:(NSSet *)values;
- (void)removeMembers:(NSSet *)values;

@end



@interface YPOChapterRequest : YPOHTTPRequest

@end
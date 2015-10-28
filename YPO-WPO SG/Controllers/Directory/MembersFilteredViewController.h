//
//  MembersFilteredViewController.h
//  YPO-WPO SG
//
//  Created by Mario Antonio A. Cape on 6/27/15.
//  Copyright (c) 2015 Raketeers. All rights reserved.
//

typedef NS_ENUM(NSUInteger, MemberFilterType) {
    MemberFilterNone,
    MemberFilterForum,
    MemberFilterChapter,
    MemberFilterManagementCommittee,
};


#import "BaseTableViewController.h"
#import "YPOChapter.h"
#import "YPOForum.h"
#import "YPOMember.h"

@interface MembersFilteredViewController : BaseTableViewController

//@property (nonatomic, assign, readonly)MemberFilterType filterType;
@property (nonatomic, strong) YPOChapter *chapterFilter;
@property (nonatomic, strong) YPOForum *forumFilter;
@property (nonatomic, assign) MemberTypeID memberTypeID;
@property (nonatomic, assign) BOOL newMembers;
@property (nonatomic, assign) BOOL managementCommittee;
@end

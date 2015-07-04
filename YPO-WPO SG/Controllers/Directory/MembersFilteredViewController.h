//
//  MembersFilteredViewController.h
//  YPO-WPO SG
//
//  Created by Mario Antonio A. Cape on 6/27/15.
//  Copyright (c) 2015 Raketeers. All rights reserved.
//

typedef NS_ENUM(NSUInteger, MemberFilterType) {
    MemberFilterNew,
    MemberFilterForum,
    MemberFilterChapter,
};


#import "BaseTableViewController.h"
#import "YPOChapter.h"
#import "YPOForum.h"

@interface MembersFilteredViewController : BaseTableViewController

@property (nonatomic, assign, readonly)MemberFilterType filterType;
@property (nonatomic, strong) YPOChapter *chapterFilter;
@property (nonatomic, strong) YPOForum *forumFilter;

@end

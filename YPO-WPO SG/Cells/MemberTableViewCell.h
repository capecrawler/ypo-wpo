//
//  MemberTableViewCell.h
//  YPO-WPO SG
//
//  Created by Mario Antonio A. Cape on 6/11/15.
//  Copyright (c) 2015 Raketeers. All rights reserved.
//

#import <UIKit/UIKit.h>
@class YPOMember;

@interface MemberTableViewCell : UITableViewCell

@property (nonatomic, strong) YPOMember *member;
@property (nonatomic, assign) BOOL showJoinedDate;
@property (nonatomic, assign) BOOL showRole;

@end

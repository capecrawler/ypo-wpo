//
//  CommentTableViewCell.h
//  YPO-WPO SG
//
//  Created by Mario Antonio A. Cape on 6/29/15.
//  Copyright (c) 2015 Raketeers. All rights reserved.
//

#import <UIKit/UIKit.h>
@class YPOComment;

#define kAvatarSize 30.0
#define kMinimumHeight 50.0

@interface CommentTableViewCell : UITableViewCell

@property (nonatomic, strong) YPOComment *comment;

@end

//
//  MemberTableViewCell.m
//  YPO-WPO SG
//
//  Created by Mario Antonio A. Cape on 6/11/15.
//  Copyright (c) 2015 Raketeers. All rights reserved.
//

#import "MemberTableViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "YPOMember.h"
#import "YPORole.h"
#import "NSDate+FormattedString.h"

@interface MemberTableViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *membershipLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateJoinedLabel;

@end

@implementation MemberTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    // Hack to remove autolayout warning prior to iOS 8.0 when subviews with fixed width using autolayout
    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.showJoinedDate = YES;
 
    // set up a path to mask/clip to, and draw it.
    CAShapeLayer *mask = [CAShapeLayer layer];
    CGRect imageRect = CGRectMake(0, 0, self.profileImageView.bounds.size.width, self.profileImageView.bounds.size.height);
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithOvalInRect:imageRect];
    mask.path = circlePath.CGPath;
    self.profileImageView.layer.mask = mask;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
}

- (void)setMember:(YPOMember *)member {
    _member = member;
    self.nameLabel.text = self.member.name;
    
    if (self.showRole) {
        YPORole *role = self.member.role.allObjects.firstObject;
        if ([role.name isNotEmpty]) {
            self.membershipLabel.text = role.name;
        } else {
            self.membershipLabel.text = self.member.chapter;
        }
    } else {
        self.membershipLabel.text = self.member.chapter;
    }
    
    [self.profileImageView sd_setImageWithURL:[NSURL URLWithString:self.member.profilePicURL] placeholderImage:[UIImage imageNamed:@"profile"]];
    if (self.showJoinedDate) {
        self.dateJoinedLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Date Joined: %@", @"Date joined text"), [self.member.joinedDate stringWithFormat:@"dd MMMM yyyy"]];
    } else {
        self.dateJoinedLabel.text = @"";
    }
}

- (void)setShowJoinedDate:(BOOL)showJoinedDate {
    _showJoinedDate = showJoinedDate;
    if (showJoinedDate) {
        if (self.member != nil){
            self.dateJoinedLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Date Joined: %@", @"Date joined text"), [self.member.joinedDate stringWithFormat:@"dd MMMM yyyy"]];
        }
    } else {
        self.dateJoinedLabel.text = @"";
    }
}

@end


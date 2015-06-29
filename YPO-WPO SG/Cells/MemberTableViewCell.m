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
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.profileImageView sd_setImageWithURL:[NSURL URLWithString:self.member.profilePicURL] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        self.profileImageView.layer.shouldRasterize = YES;
        self.profileImageView.layer.rasterizationScale = [UIScreen mainScreen].scale;
    }];
}

- (void)setMember:(YPOMember *)member {
    _member = member;
    self.nameLabel.text = self.member.name;
    self.membershipLabel.text = self.member.chapter;
    if (self.showJoinedDate) {
        self.dateJoinedLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Date Joined: %@", @"Date joined text"), [self.member.joinedDate stringWithFormat:@"dd MMMM yyyy"]];
    } else {
        self.dateJoinedLabel.text = @"";
    }
}



@end

//
//  EventDetailsTableViewCell.m
//  YPO-WPO SG
//
//  Created by Mario Antonio A. Cape on 10/26/15.
//  Copyright © 2015 Raketeers. All rights reserved.
//

#import "EventDetailsTableViewCell.h"

@implementation EventDetailsTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.contentView setNeedsLayout];
    [self.contentView layoutIfNeeded];
    self.detailLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.detailLabel.bounds);    
}


@end

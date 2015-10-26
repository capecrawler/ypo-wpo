//
//  EventDetailsView.m
//  YPO-WPO SG
//
//  Created by Mario Antonio A. Cape on 10/26/15.
//  Copyright © 2015 Raketeers. All rights reserved.
//

#import "EventDetailsView.h"


@interface EventDetailsView()

@end

@implementation EventDetailsView

- (void)layoutSubviews {
    [super layoutSubviews];
    self.titleLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.titleLabel.bounds);
    self.descriptionLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.descriptionLabel.bounds);
}


@end

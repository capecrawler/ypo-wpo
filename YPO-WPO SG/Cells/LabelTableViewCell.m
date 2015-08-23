//
//  LabelTableViewCell.m
//  YPO-WPO SG
//
//  Created by Mario Antonio A. Cape on 8/20/15.
//  Copyright (c) 2015 Raketeers. All rights reserved.
//

#import "LabelTableViewCell.h"

@implementation LabelTableViewCell

- (void)setContentLabel:(UILabel *)contentLabel {
    if (_contentLabel != nil) {
        [_contentLabel removeFromSuperview];
    }
    
    if (_contentLabel != contentLabel) {
        _contentLabel = contentLabel;
    }
    if (contentLabel == nil) return;
    
    [self.contentView addSubview:_contentLabel];
    _contentLabel.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *viewDictionary = @{@"contentLabel" : _contentLabel};
    NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[contentLabel]-|" options:0 metrics:nil views:viewDictionary];
    [self.contentView addConstraints:constraints];
    
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[contentLabel]-|" options:0 metrics:nil views:viewDictionary];
    [self.contentView addConstraints:constraints];
    
//    NSLayoutConstraint *verticalCenter = [NSLayoutConstraint constraintWithItem:_contentLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
//    [self.contentView addConstraint:verticalCenter];
}


@end

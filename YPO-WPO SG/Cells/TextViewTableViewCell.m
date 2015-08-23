//
//  TextViewTableViewCell.m
//  YPO-WPO SG
//
//  Created by Mario Antonio A. Cape on 8/20/15.
//  Copyright (c) 2015 Raketeers. All rights reserved.
//

#import "TextViewTableViewCell.h"

@implementation TextViewTableViewCell

- (void)setContentTextView:(UITextView *)contentTextView {
    if (_contentTextView != nil) {
        [_contentTextView removeFromSuperview];
    }
    
    if (_contentTextView != contentTextView) {
        _contentTextView = contentTextView;
    }
    if (contentTextView == nil) return;
    
    [self.contentView addSubview:_contentTextView];
    _contentTextView.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *viewDictionary = @{@"contentTextView" : _contentTextView};
    NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[contentTextView]-|" options:0 metrics:nil views:viewDictionary];
    [self.contentView addConstraints:constraints];
    
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[contentTextView]-|" options:0 metrics:nil views:viewDictionary];
    [self.contentView addConstraints:constraints];    
}

@end

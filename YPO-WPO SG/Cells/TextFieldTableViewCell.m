//
//  TextFieldTableViewCell.m
//  YPO-WPO SG
//
//  Created by Mario Antonio A. Cape on 8/20/15.
//  Copyright (c) 2015 Raketeers. All rights reserved.
//

#import "TextFieldTableViewCell.h"

@implementation TextFieldTableViewCell


- (void)setContentTextField:(UITextField *)contentTextField {
    if (_contentTextField != nil) {
        [_contentTextField removeFromSuperview];
    }
    
    if (_contentTextField != contentTextField) {
        _contentTextField = contentTextField;
    }
    if (contentTextField == nil) return;
    
    [self.contentView addSubview:_contentTextField];
    _contentTextField.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *viewDictionary = @{@"contentTextField" : _contentTextField};
    NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[contentTextField]-|" options:0 metrics:nil views:viewDictionary];
    [self.contentView addConstraints:constraints];
    
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[contentTextField]-|" options:0 metrics:nil views:viewDictionary];
    [self.contentView addConstraints:constraints];
    
//    NSLayoutConstraint *verticalCenter = [NSLayoutConstraint constraintWithItem:_contentTextField attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];
//    [self.contentView addConstraint:verticalCenter];
    
}

@end

//
//  MaterialTextFieldCell.m
//  YPO-WPO SG
//
//  Created by Mario Antonio A. Cape on 8/22/15.
//  Copyright (c) 2015 Raketeers. All rights reserved.
//

#import "MaterialTextFieldCell.h"
#import <MaterialControls/MDTextField.h>

@implementation MaterialTextFieldCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self){
        [self initContent];
    }
    return self;
    
}


- (void)initContent {
    MDTextField *textField = [[MDTextField alloc] init];
    textField.label = @"label";
    textField.fullWidth = YES;
    textField.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:textField];
    NSDictionary *viewDictionary = @{@"textField" : textField};
    NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[textField]-|" options:0 metrics:nil views:viewDictionary];
    [self.contentView addConstraints:constraints];
    
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[textField]" options:0 metrics:nil views:viewDictionary];
    [self.contentView addConstraints:constraints];
}

- (void)layoutSubviews {
    [super layoutSubviews];
//    self.separatorInset = UIEdgeInsetsMake(0.f, 0.f, 0.f, self.contentView.bounds.size.width);


    
}


- (void)setContentTextField:(MDTextField *)contentTextField {
    if (_contentTextField != nil) {
        [_contentTextField removeFromSuperview];
    }
    
    if (_contentTextField != contentTextField) {
        _contentTextField = contentTextField;
    }


    if (contentTextField == nil) return;
    
    
    
    
    
    /*
    [self.contentView addSubview:_contentTextField];
    _contentTextField.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *viewDictionary = @{@"contentTextField" : _contentTextField};
    NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[contentTextField]-|" options:0 metrics:nil views:viewDictionary];
    [self.contentView addConstraints:constraints];
    
    constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[contentTextField]" options:0 metrics:nil views:viewDictionary];
    [self.contentView addConstraints:constraints];
     */
     
    
}



@end

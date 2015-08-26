//
//  KeyboardAccessoryView.m
//  YPO-WPO SG
//
//  Created by Mario Antonio A. Cape on 8/26/15.
//  Copyright (c) 2015 Raketeers. All rights reserved.
//

#import "KeyboardAccessoryView.h"

@interface KeyboardAccessoryView()

@property (nonatomic, strong) UIBarButtonItem *doneButton;

@end


@implementation KeyboardAccessoryView


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizesSubviews = YES;
        [self addSubview:self.toolbar];
    }
    return self;
}


- (void)layoutSubviews {
    [super layoutSubviews];
    self.toolbar.frame = CGRectMake(0, 0, self.bounds.size.width, 44);
}


- (UIToolbar *)toolbar {
    if (_toolbar == nil) {
        _toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 44)];
        _toolbar.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth);
        UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        self.doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonClicked:)];
        _toolbar.items = @[flexibleSpace, self.doneButton];
    }
    return _toolbar;
}


- (void)doneButtonClicked:(id)sender {
    if ([self.delegate respondsToSelector:@selector(keyboardAccessoryViewDoneButtonClicked:)]) {
        [self.delegate keyboardAccessoryViewDoneButtonClicked:self];
    }
}

- (void)setTintColor:(UIColor *)tintColor {
    [super setTintColor:tintColor];
    self.doneButton.tintColor = tintColor;
}


@end

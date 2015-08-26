//
//  KeyboardAccessoryView.h
//  YPO-WPO SG
//
//  Created by Mario Antonio A. Cape on 8/26/15.
//  Copyright (c) 2015 Raketeers. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KeyboardAccessoryView;

@protocol KeyboardAccessoryViewDelegate <NSObject>

- (void)keyboardAccessoryViewDoneButtonClicked:(KeyboardAccessoryView *)accessoryView;

@end

@interface KeyboardAccessoryView : UIView

@property (nonatomic, strong) UIToolbar *toolbar;
@property (nonatomic, weak) id<KeyboardAccessoryViewDelegate> delegate;


@end

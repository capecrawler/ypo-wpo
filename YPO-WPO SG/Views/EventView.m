//
//  EventView.m
//  YPO-WPO SG
//
//  Created by Mario Antonio A. Cape on 7/11/15.
//  Copyright (c) 2015 Raketeers. All rights reserved.
//

#import "EventView.h"

@implementation EventView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [[[NSBundle mainBundle] loadNibNamed:@"EventView" owner:self options:nil]firstObject];
    if (self) {
        self.frame = frame;
        self.layer.cornerRadius = 2;
        self.layer.masksToBounds = YES;
    }
    return self;
}


@end

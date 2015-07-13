//
//  EventHeaderView.m
//  YPO-WPO SG
//
//  Created by Mario Antonio A. Cape on 7/12/15.
//  Copyright (c) 2015 Raketeers. All rights reserved.
//

#import "EventHeaderView.h"

@interface EventHeaderView()

@end

@implementation EventHeaderView


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.dateLabel = [[UILabel alloc] init];
        self.dateLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.dateLabel.font = [UIFont systemFontOfSize:32];
        self.dateLabel.textAlignment = NSTextAlignmentCenter;
        self.dateLabel.text = @"14";
        [self addSubview:self.dateLabel];
        
        self.monthLabel = [[UILabel alloc] init];
        self.monthLabel.font = [UIFont systemFontOfSize:13];
        self.monthLabel.textAlignment = NSTextAlignmentCenter;
        self.monthLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.monthLabel.text = @"JUL";
        [self addSubview:self.monthLabel];
        
        NSDictionary *viewDictionary = @{@"dateLabel" :self.dateLabel, @"monthLabel" :self.monthLabel};
        NSMutableArray *constraints = [[NSMutableArray alloc] init];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[dateLabel(50)]" options:0 metrics:nil views:viewDictionary]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[monthLabel(50)]" options:0 metrics:nil views:viewDictionary]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-4-[dateLabel][monthLabel]|" options:0 metrics:nil views:viewDictionary]];
        [self addConstraints:constraints];
    }
    return self;
}

@end

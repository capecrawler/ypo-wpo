//
//  EventCollectionViewCell.m
//  YPO-WPO SG
//
//  Created by Mario Antonio A. Cape on 7/12/15.
//  Copyright (c) 2015 Raketeers. All rights reserved.
//

#import "EventCollectionViewCell.h"
#import "EventView.h"


@interface EventCollectionViewCell()

@end

@implementation EventCollectionViewCell

- (instancetype) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.eventView];        
        NSDictionary *viewDictionary = @{@"eventView" :self.eventView};
        self.eventView.translatesAutoresizingMaskIntoConstraints = NO;
        NSMutableArray *constraints = [[NSMutableArray alloc]init];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(88)-[eventView]-8-|" options:0 metrics:nil views:viewDictionary]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[eventView]|" options:0 metrics:nil views:viewDictionary]];
        [self.contentView addConstraints:constraints];
    }
    return self;
}


#pragma mark - Properties

- (EventView *)eventView {
    if (_eventView == nil) {
        _eventView = [[EventView alloc] init];
    }
    return _eventView;
}


@end

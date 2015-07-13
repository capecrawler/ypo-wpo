//
//  EventDetailsViewController.h
//  YPO-WPO SG
//
//  Created by Mario Antonio A. Cape on 7/13/15.
//  Copyright (c) 2015 Raketeers. All rights reserved.
//

#import "BaseViewController.h"
@class YPOEvent;

@interface EventDetailsViewController : BaseViewController

@property (nonatomic, strong) YPOEvent *event;

@end

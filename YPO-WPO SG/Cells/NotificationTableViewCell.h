//
//  NotificationTableViewCell.h
//  YPO-WPO SG
//
//  Created by Mario Antonio A. Cape on 7/25/15.
//  Copyright (c) 2015 Raketeers. All rights reserved.
//

#import <UIKit/UIKit.h>
@class YPONotification;


@interface NotificationTableViewCell : UITableViewCell

@property (nonatomic, strong) YPONotification *notification;

@end

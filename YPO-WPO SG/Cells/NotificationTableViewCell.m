//
//  NotificationTableViewCell.m
//  YPO-WPO SG
//
//  Created by Mario Antonio A. Cape on 7/25/15.
//  Copyright (c) 2015 Raketeers. All rights reserved.
//

#import "NotificationTableViewCell.h"
#import "YPONotification.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <DateTools/NSDate+DateTools.h>
@interface NotificationTableViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *thumbView;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation NotificationTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    // Hack to remove autolayout warning prior to iOS 8.0 when subviews with fixed width using autolayout
    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

- (void) setNotification:(YPONotification *)notification {
    _notification = notification;
    [self.thumbView sd_setImageWithURL:[NSURL URLWithString:self.notification.thumbURL]];
    [self processLabelForNotification:notification];
    self.dateLabel.text = notification.sorting.timeAgoSinceNow;
}

- (void) processLabelForNotification:(YPONotification *)notification {
    NSMutableAttributedString * attributedString;
    if ([notification.type isEqualToString:@"event"]) {
        NSString *text = [NSString stringWithFormat:@"New event %@", notification.title];
        attributedString = [[NSMutableAttributedString alloc] initWithString:text];
        NSRange range = [text rangeOfString:notification.title];
        [attributedString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:14] range:range];
    } else if ([notification.type isEqualToString:@"comment"]) {
        NSString *text = [NSString stringWithFormat:@"%@ commented on %@", notification.title, notification.articleTitle];
        attributedString = [[NSMutableAttributedString alloc] initWithString:text];
        NSRange range = [text rangeOfString:notification.title];
        [attributedString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:14] range:range];
        range = [text rangeOfString:notification.articleTitle];
        [attributedString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:14] range:range];
    } else if ([notification.type isEqualToString:@"member"]) {
        NSString *text = [NSString stringWithFormat:@"%@ has joined the group.", notification.title];
        attributedString = [[NSMutableAttributedString alloc] initWithString:text];
        NSRange range = [text rangeOfString:notification.title];
        [attributedString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:14] range:range];
    } else {
        NSString *text = [NSString stringWithFormat:@"%@", notification.title];
        attributedString = [[NSMutableAttributedString alloc] initWithString:text];
        NSRange range = [text rangeOfString:notification.title];
        [attributedString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:14] range:range];
    }
    
    self.titleLabel.attributedText = attributedString;
}


@end

//
//  EventDetailsView.h
//  YPO-WPO SG
//
//  Created by Mario Antonio A. Cape on 10/26/15.
//  Copyright © 2015 Raketeers. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventDetailsView : UIView

@property (weak, nonatomic) IBOutlet UIImageView *coverView;
@property (weak, nonatomic) IBOutlet UILabel *eventTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@end

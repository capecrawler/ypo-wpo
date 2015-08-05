//
//  EventDetailsViewController.m
//  YPO-WPO SG
//
//  Created by Mario Antonio A. Cape on 7/13/15.
//  Copyright (c) 2015 Raketeers. All rights reserved.
//

#import "EventDetailsViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "YPOEvent.h"
#import "YPOAPIClient.h"
#import <SVProgressHUD/SVProgressHUD.h>

@interface EventDetailsViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *icLocationHeightConstraint;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *icParkingHeightConstraint;
@property (weak, nonatomic) IBOutlet UILabel *parkingLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *parkingTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *locationTopConstraint;

@end

@implementation EventDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self fetchEventDetails];
    [self showDetails];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)fetchEventDetails {
    
    NSDictionary *parameters = @{@"func" : @"event.details",
                                 @"event_id" : self.event.eventID};
    [[YPOAPIClient sharedClient] GET:YPOAPIPathPrefix parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        [self.event parseDictionary:responseObject[@"data"]];
        [self showDetails];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [SVProgressHUD showErrorWithStatus:error.localizedDescription maskType:SVProgressHUDMaskTypeBlack];
    }];
    
}


- (void)showDetails {
    [self.coverImageView sd_setImageWithURL:[NSURL URLWithString:self.event.thumbUrl]];
    self.titleLabel.text = self.event.title;
    self.typeLabel.text = self.event.type;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"EEEE, MMM d 'at' hh:mm aa";
    NSString *dateString = [NSString stringWithFormat:@"%@ - %@", [formatter stringFromDate:self.event.startDate], [formatter stringFromDate:self.event.endDate]];
    self.dateLabel.text = dateString;
    
    if ([self.event.location isNotEmpty]) {
        self.icLocationHeightConstraint.constant = 24;
        self.locationTopConstraint.constant = 16;
        self.locationLabel.text = self.event.location;
    } else {
        self.icLocationHeightConstraint.constant = 0;
        self.locationTopConstraint.constant = 0;
        self.locationLabel.text = @"";
    }
    
    
    if ([self.event.parking isNotEmpty]) {
        self.icParkingHeightConstraint.constant = 24;
        self.parkingTopConstraint.constant = 16;
        self.parkingLabel.text = self.event.parking;
    } else {
        self.icParkingHeightConstraint.constant = 0;
        self.parkingTopConstraint.constant = 0;
        self.parkingLabel.text = @"";
    }

}


@end
